module Danger

  # @example Ensure all python files inside the current directory follow the PEP 8 rules
  #
  #          pep8.lint
  #
  # @see  loadsmart/danger-pep8
  # @tags lint, python, pep8, code, style
  #
  class DangerPep8 < Plugin

    MARKDOWN_TEMPLATE = %{
    ## DangerPep8 found issues

    | File | Line | Column | Reason |\n
    |------|------|--------|--------|\n
    }

    attr_accessor :config_file

    # Lint all python files inside the current directory
    # @return [void]
    #
    def lint(path=".")
      ensure_flake8_is_installed

      errors = run_flake_on_path(path)
      return if errors.empty?

      report = errors.inject(MARKDOWN_TEMPLATE) do |out, error_line|
        file, line, column, reason = error_line.split(":")
        out += "| #{file} | #{line} | #{column} | #{reason.strip.gsub("'", "`")} |\n"
      end

      markdown(report)
    end

    private

    def run_flake_on_path(path)
      command = "flake8 #{path}"
      command << " --config #{config_file}" if config_file
      `#{command}`.split("\n")
    end

    def ensure_flake8_is_installed
      system "pip install --user flake8" unless flake8_installed?
    end

    def flake8_installed?
      `which flake8`.strip.empty? == false
    end
  end
end
