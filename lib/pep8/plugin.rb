module Danger

  # Find [PEP 8](https://www.python.org/dev/peps/pep-0008/) issues in python files.
  #
  # This is done using the [flake8](https://pypi.python.org/pypi/flake8) python egg.
  # Results are passed out as a markdown table.
  #
  # @example Lint files inside the current directory
  #
  #          pep8.lint
  #
  # @example Lint files inside a given directory
  #
  #          pep8.lint "src"
  #
  # @example Warns if number of issues is greater than a given threshold
  #
  #          #TODO
  #
  # @see  loadsmart/danger-pep8
  # @tags lint, python, pep8, code, style
  #
  class DangerPep8 < Plugin

    MARKDOWN_TEMPLATE = ""\
      "## DangerPep8 found issues\n\n"\
      "| File | Line | Column | Reason |\n"\
      "|------|------|--------|--------|\n"\

    attr_accessor :config_file
    attr_writer :max_errors

    def max_errors
      @max_errors || 0
    end

    # Lint all python files inside a given directory. Defaults to "."
    # @return [void]
    #
    def lint(path=".")
      ensure_flake8_is_installed

      errors = run_flake_on_path(path)
      return if errors.empty?

      report = errors.inject(MARKDOWN_TEMPLATE) do |out, error_line|
        file, line, column, reason = error_line.split(":")
        out += "| #{short_link(file, line)} | #{line} | #{column} | #{reason.strip.gsub("'", "`")} |\n"
      end

      markdown(report)
    end

    # Triggers a warning if total lint errors found exceedes @max_errors threshold
    # @return [void]
    #
    def count_errors(path=".")
      ensure_flake8_is_installed

      total_errors = run_flake_on_path(path, :count => true).first.to_i
      if total_errors > 0 and total_errors >= self.max_errors
        warn("#{total_errors} PEP 8 issues were found")
      end
    end

    private

    def run_flake_on_path(path, options = {})
      command = "flake8 #{path}"
      command << " --config #{config_file}" if config_file
      # We need quiet flag 2 times to return only the count
      command << " --quiet --quiet --count" if options[:count]
      `#{command}`.split("\n")
    end

    def ensure_flake8_is_installed
      system "pip install --user flake8" unless flake8_installed?
    end

    def flake8_installed?
      `which flake8`.strip.empty? == false
    end

    def short_link(file, line)
      if danger.scm_provider.to_s == "github"
        return github.html_link("#{file}#L#{line}", full_path: false)
      end

      file
    end
  end
end
