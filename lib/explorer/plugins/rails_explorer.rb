module Explorer
  module Plugins
    module RailsExplorer
      def individual_action(option)
        complete_file_name = @nodes[option].name_file
        file_name = complete_file_name.split('/')[-1]
        return unless (file_name[0] == '_') && (file_name[-3..] == 'erb')

        plugin_rails_command = "render.*#{file_name.split('.').first[1..]}" # TODO: Here we need to apply a plugin
        choices = [
          { name: "Spawn explorer to search >>\"#{plugin_rails_command}\"<<", value: 1 },
          { name: 'Return', value: 'q' },
        ]
        option = @prompt.enum_select("INDIVIDUAL ACTION #{complete_file_name}", choices)  
        return if option == 'q'

        explorer_child_data = @explorer_data
        explorer_child_data[:search_term] = plugin_rails_command
        new_data = {search_term: plugin_rails_command, path: @explorer_data[:path]}
        pd = @previous_data.clone
        pd << new_data
        explorer_child = Nodes.new(explorer_data: explorer_child_data, previous_data: pd, configuration: @configuration)
        explorer_child.menu
      end
    end
  end
end
