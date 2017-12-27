{
  "started": "2017-12-28 09:14:52 +0000",
  "finished": "2017-12-28 09:14:52 +0000",
  "results": [
    {
      "type": "Rspec::Describe",
      "name": "I am describe",
      "urn": "./examples/rspec/rspec_formatter_spec.rb:3",
      "children": [
        {
          "type": "Rspec::Describe",
          "name": "Describe#1",
          "urn": "./examples/rspec/rspec_formatter_spec.rb:6",
          "children": [
            {
              "type": "Rspec::Test",
              "name": "I am passing test#1",
              "urn": "./examples/rspec/rspec_formatter_spec.rb:8"
            },
            {
              "type": "Rspec::Test",
              "name": "I am failing test#1",
              "urn": "./examples/rspec/rspec_formatter_spec.rb:12"
            }
          ]
        },
        {
          "type": "Rspec::Describe",
          "name": "Describe#2",
          "urn": "./examples/rspec/rspec_formatter_spec.rb:17",
          "children": [
            {
              "type": "Rspec::Test",
              "name": "I am passing test#2",
              "urn": "./examples/rspec/rspec_formatter_spec.rb:18"
            },
            {
              "type": "Rspec::Test",
              "name": "I am passing test#3",
              "urn": "./examples/rspec/rspec_formatter_spec.rb:22"
            },
            {
              "type": "Rspec::Test",
              "name": "I am passing test#4",
              "urn": "./examples/rspec/rspec_formatter_spec.rb:26"
            }
          ]
        },
        {
          "type": "Rspec::Describe",
          "name": "I am First Context",
          "urn": "./examples/rspec/rspec_formatter_spec.rb:31",
          "children": [
            {
              "type": "Rspec::Describe",
              "name": "I am context 2",
              "urn": "./examples/rspec/rspec_formatter_spec.rb:32",
              "children": [
                {
                  "type": "Rspec::Describe",
                  "name": "I am context 3",
                  "urn": "./examples/rspec/rspec_formatter_spec.rb:33",
                  "children": [
                    {
                      "type": "Rspec::Describe",
                      "name": "I am context 4",
                      "urn": "./examples/rspec/rspec_formatter_spec.rb:34",
                      "children": [
                        {
                          "type": "Rspec::Test",
                          "name": "I am failing test#2",
                          "urn": "./examples/rspec/rspec_formatter_spec.rb:35"
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        },
        {
          "type": "Rspec::Describe",
          "name": "I am context 3",
          "urn": "./examples/rspec/rspec_formatter_spec.rb:43",
          "children": [
            {
              "type": "Rspec::Test",
              "name": "I am passing test#5",
              "urn": "./examples/rspec/rspec_formatter_spec.rb:44"
            }
          ]
        },
        {
          "type": "Rspec::Describe",
          "name": "Context 4",
          "urn": "./examples/rspec/rspec_formatter_spec.rb:49",
          "children": [
            {
              "type": "Rspec::Test",
              "name": "I am passing test#6",
              "urn": "./examples/rspec/rspec_formatter_spec.rb:50"
            }
          ]
        },
        {
          "type": "Rspec::Test",
          "name": "I am passing test#7",
          "urn": "./examples/rspec/rspec_formatter_spec.rb:55"
        },
        {
          "type": "Rspec::Test",
          "name": "I am failing test#3",
          "urn": "./examples/rspec/rspec_formatter_spec.rb:59"
        }
      ]
    }
  ],
  "type": "Rspec"
}
