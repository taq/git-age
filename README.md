# Git::Age

Would you like to know how many lines from the past still persists on your
repository? This gem can help with that.

It will create a CSV file with year, month and the line count from the specified
period.

Also, with some CLI graphic processor installed, it can create an image with a
graph showing the CSV data as a bar graph.

## Installation

```
$ gem install git-age
```

## Usage

Go to your repository and run:

```
Usage: git-age [options]
    -b, --branch=BRANCH              Git branch
    -m, --map                        Create a file with processed files and dates
    -o, --output=FILE                Output file
    -i, --image=FILE                 Image file
    -g, --graph=PROCESSOR            Graphic processor
    -t, --title=TITLE                Graphic title
    -x, --xtitle=TITLE               X axis title
    -y, --ytitle=TITLE               Y axis title
    -c, --code=PATTERN               Code dir pattern
    -e, --test=PATTERN               Test dir pattern
    -y, --type=TYPE                  Graph type, default to bar
    -v, --version                    Show version
```

Example:

```
$ git-age -o /tmp/data.csv -t 'Test project' -x 'Dates here' -y 'Lines here' -i /tmp/data.png
```

Sending a dir pattern as your test dir, creating a test column to compare:

```
$ git-age -o /tmp/data.csv -t 'Test project' -x 'Dates here' -y 'Lines here' -i /tmp/data.png -e test
```

If you're sending a test dir, it can be unfair if you don't also send a dir
pattern to your code dir, because all other files (configurations, temporary
files) will count as code and your code to test ratio will implode. So, sending
a code dir pattern:

```
$ git-age -o /tmp/data.csv -t 'Test project' -x 'Dates here' -y 'Lines here' -i /tmp/data.png -e test -c app
```

Supported image processors:

- [graph-cli](https://github.com/mcastorina/graph-cli)
  Supports bar graphs (`-y bar`, default) and line graphs (`-y line`).

Example image:

![graph-cli graph](https://github.com/taq/git-age/blob/master/graph-cli.png?raw=true)

Default options are:

- branch: master
- output: git-age.csv
- image: git-age.png
- graph: graph-cli
- title: Git age statistics
- xtitle: Dates
- ytitle: Lines

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/taq/git-age.
