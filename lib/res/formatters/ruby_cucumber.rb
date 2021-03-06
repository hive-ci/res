# Formatter for ruby cucumber

require 'fileutils'
require 'res'
require 'res/ir'
require 'cucumber/formatter/io'

module Res
  module Formatters
    class RubyCucumber
      include FileUtils
      include ::Cucumber::Formatter::Io

      def initialize(runtime, path_or_io, options)
        cucumber_version = `cucumber --version`
        @cucumber_version = cucumber_version.delete("\n")

        @runtime          = runtime
        @io               = ensure_io(path_or_io, 'reporter')
        @options          = options
        @exceptions       = []
        @indent           = 0
        @prefixes         = options[:prefixes] || {}
        @delayed_messages = []
        @_start_time      = Time.now
      end

      def before_features(_features)
        @_features = []
      end

      # Once everything has run -- whack it in a ResultIR object and
      # dump it as json
      def after_features(_features)
        results = @_features
        ir = ::Res::IR.new(started: @_start_time,
                           finished: Time.now,
                           results: results,
                           type: 'Cucumber')
        @io.puts ir.json
      end

      def before_feature(feature)
        @_feature           = {}
        @_context           = {}
        @_feature[:started] = Time.now
        begin
          uri = if @cucumber_version.to_f < 1.3.to_f
                  feature.file.to_s
                else
                  feature.location.to_s
                end

          hash = RubyCucumber.split_uri(uri)
          @_feature[:file] = hash[:file]
          @_feature[:line] = hash[:line]
          @_feature[:urn]  = hash[:urn]
        rescue
          @_feature[:uri] = 'unknown'
        end
        @_features << @_feature
        @_context = @_feature
      end

      def comment_line(comment_line)
        @_context[:comments] = [] unless @_context[:comments]
        @_context[:comments] << comment_line
      end

      def after_tags(tags); end

      def tag_name(tag_name)
        @_context[:tags] = [] unless @_context[:tag]
        # Strip @ from tags
        @_context[:tags] << tag_name[1..-1]
      end

      # { :type => 'Feature',
      #   :name => 'Feature name',
      #   :description => "As a blah\nAs a blah\n" }
      def feature_name(keyword, name)
        @_feature[:type] = 'Cucumber::' + keyword.gsub(/\s+/, '')

        lines = name.split("\n")
        lines = lines.collect(&:strip)

        @_feature[:name] = lines.shift
        @_feature[:description] = lines.join("\n")
      end

      def after_feature(_feature)
        @_feature[:finished] = Time.now
      end

      def before_feature_element(feature_element)
        @_feature_element = {}
        @_context = {}
        @_feature_element[:started] = Time.now
        begin
          uri = if @cucumber_version.to_f < 1.3.to_f
                  feature_element.file_colon_line
                else
                  feature_element.location.to_s
                end
          hash = RubyCucumber.split_uri(uri)
          @_feature_element[:file] = hash[:file]
          @_feature_element[:line] = hash[:line]
          @_feature_element[:urn] = hash[:urn]
        rescue => e
          @_feature_element[:error] = e.message
          @_feature_element[:file] = 'unknown'
        end

        @_feature[:children] = [] unless @_feature[:children]

        @_feature[:children] << @_feature_element
        @_context = @_feature_element
      end

      # After a scenario
      def after_feature_element(feature_element)
        @_context = {}

        if feature_element.respond_to? :status
          @_feature_element[:status] = feature_element.status
        end
        @_feature_element[:finished] = Time.now
        @_feature_element[:values] = Res.perf_data.pop unless Res.perf_data.empty?
      end

      def before_background(background); end

      def after_background(background); end

      def background_name(keyword, name, file_colon_line, source_indent); end

      def examples_name(keyword, name); end

      def scenario_name(keyword, name, _file_colon_line, _source_indent)
        @_context[:type] = 'Cucumber::' + keyword.gsub(/\s+/, '')
        @_context[:name] = name || ''
      end

      def before_step(_step)
        @_step = {}

        # Background steps can appear totally divorced from scenerios (feature
        # elements). Need to make sure we're not including them as children
        # to scenario that don't exist
        return if @_feature_element && @_feature_element[:finished]

        @_feature_element = {} unless @_feature_element
        @_feature_element[:children] = [] unless @_feature_element[:children]
        @_feature_element[:children] << @_step
        @_context = @_step
      end

      # Argument list changed after cucumber 1.4, hence the *args
      def step_name(keyword, step_match, status, _source_indent, _background, *args)
        file_colon_line = args[0] if args[0]

        @_step[:type] = 'Cucumber::Step'
        name = keyword + step_match.format_args(->(param) { param.to_s })
        @_step[:name] = name
        @_step[:status] = status
        @_step[:type] = 'Cucumber::Step'
      end

      def exception(exception, _status)
        @_context[:message] = exception.to_s
      end

      def before_multiline_arg(multiline_arg); end

      def after_multiline_arg(multiline_arg)
        @_context[:args] = multiline_arg.to_s.gsub(/\e\[(\d+)m/, '')
        @_table = nil
      end

      # Before a scenario outline is encountered
      def before_outline_table(_outline_table)
        # Scenario outlines appear as children like normal scenarios,
        # but really we just want to construct normal-looking children
        # from them
        @_outlines = @_feature_element[:children]
        @_table = []
      end

      def after_outline_table(_outline_table)
        headings = @_table.shift
        description = @_outlines.collect { |o| o[:name] }.join("\n") + "\n" + headings[:name]
        @_feature_element[:children] = @_table
        @_feature_element[:description] = description
      end

      def before_table_row(_table_row)
        @_current_table_row = { type: 'Cucumber::ScenarioOutline::Example' }
        @_table = [] unless @_table
      end

      def after_table_row(table_row)
        if table_row.class == Cucumber::Ast::OutlineTable::ExampleRow
          @_current_table_row[:name] = table_row.name
          if table_row.exception
            @_current_table_row[:message] = table_row.exception.to_s
          end
          if table_row.scenario_outline
            @_current_table_row[:status] = table_row.status
          end
          @_current_table_row[:line] = table_row.line
          @_current_table_row[:urn] = @_feature_element[:file] + ':' + table_row.line.to_s
          @_table << @_current_table_row
        end
      end

      def after_table_cell(cell); end

      def table_cell_value(value, status)
        @_current_table_row[:children] = [] unless @_current_table_row[:children]
        @_current_table_row[:children] << { type: 'Cucumber::ScenarioOutline::Parameter',
                                            name: value, status: status }
      end

      def self.split_uri(uri)
        strings = uri.rpartition(/:/)
        { file: strings[0], line: strings[2].to_i, urn: uri }
      end
    end
  end
end
