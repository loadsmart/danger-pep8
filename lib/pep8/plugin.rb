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
  #          pep8.base_dir "src"
  #          pep8.lint
  #
  # @example Warns if number of issues is greater than a given threshold
  #
  #          pep8.threshold = 10
  #          pep8.count_errors
  #
  # @example Fails if number of issues is greater than a given threshold
  #
  #          pep8.threshold = 10
  #          pep8.count_errors(should_fail: true)
  #
  # @see  loadsmart/danger-pep8
  # @tags lint, python, pep8, code, style
  #
  class DangerPep8 < Plugin

    MARKDOWN_TEMPLATE = ""\
      "## DangerPep8 found issues\n\n"\
      "| File | Line | Column | Reason |\n"\
      "|------|------|--------|--------|\n"\

    # A custom configuration file to run with flake8
    # By default, flake will look for setup.cfg, tox.ini, or .flake8
    # inside the current directory or your top-level user directory
    # @see http://flake8.pycqa.org/en/latest/user/configuration.html#configuration-locations
    # @return [String]
    attr_accessor :config_file

    # Root directory from where flake8 will run.
    # Defaults to current directory.
    # @return [String]
    attr_writer :base_dir

    # Max number of issues allowed.
    # If number of issues is lesser than the threshold, nothing happens.
    # @return [Int]
    attr_writer :threshold

    # Lint all python files inside a given directory. Defaults to "."
    # @return [void]
    #
    def lint
      ensure_flake8_is_installed

      errors = run_flake
      return if errors.empty? || errors.count <= threshold

      report = errors.inject(MARKDOWN_TEMPLATE) do |out, error_line|
        file, line, column, reason = error_line.split(":")
        out += "| #{short_link(file, line)} | #{line} | #{column} | #{reason.strip.gsub("'", "`")} |\n"
      end

      markdown(report)
    end

    # Triggers a warning/failure if total lint errors found exceedes @threshold
    # @param [Bool] should_fail
    #        A flag to indicate whether it should warn ou fail the build.
    #        It adds an entry on the corresponding warnings/failures table. 
    # @return [void]
    #
    def count_errors(should_fail = false)
      ensure_flake8_is_installed

      total_errors = run_flake(:count => true).first.to_i
      if total_errors > threshold
        message = "#{total_errors} PEP 8 issues found"
        should_fail ? fail(message) : warn(message)
      end
    end

    def base_dir
      @base_dir || "."
    end

    def threshold
      @threshold || 0
    end

    private

    def run_flake(options = {})
      command = "flake8 #{base_dir}"
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
