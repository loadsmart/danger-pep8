[![CircleCI](https://circleci.com/gh/loadsmart/danger-pep8.svg?style=svg)](https://circleci.com/gh/loadsmart/danger-pep8)

# danger-pep8

Find [PEP 8](https://www.python.org/dev/peps/pep-0008/) issues in python files.

## Installation

### Via global gems

```
$ gem install danger-pep8
```

### Via Bundler

Add the following line to your Gemfile and then run `bundle install`:

```rb
gem 'danger-pep8'
```

## Usage

### Basic

Check for issues running the script from current directory. Prints a markdown table with all issues found:
```rb
pep8.lint
```

### Advanced

#### Running from a custom directory

Changes root folder from where script is running:
```rb
pep8.base_dir = "src"
pep8.lint
```

#### Running using a configuration file different than the usual

If you need to specify a different configuration file, use the `config_file` parameter below. Check [this link](http://flake8.pycqa.org/en/latest/user/configuration.html#configuration-locations) for more information about Configuration Locations.
```rb
pep8.config_file = ".flake8_ci"
pep8.lint
```

#### Printing a warning message with number of errors

Adds an entry onto the warnings/failures table:
```rb
pep8.count_errors
```

#### Defining a threshold of max errors

Warns if number of issues is greater than a given threshold:
```rb
pep8.threshold = 10
pep8.count_errors
```

Fails if number of issues is greater than a given threshold:
```rb
pep8.threshold = 10
pep8.count_errors(should_fail = true)
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.

## License

MIT
