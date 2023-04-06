# frozen_string_literal: true

module FileSelector
    private
  
    def bicep_files
      dependency_files.select { |f| f.name.end_with?(".bicep") }
    end
  end
