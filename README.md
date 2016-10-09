nasne_checker
===
[![Gem Version](https://badge.fury.io/rb/nasne_checker.svg)](https://badge.fury.io/rb/nasne_checker)

A tool to check resavation on nasne and post to slack.

## Install

```bash
$ gem install nasne_checker
```

## Usage

```
Usage: nasne_checker [options]
        --nasne=host                 Nasne host (required)
        --slack=url                  Slack webhook url (required)
        --cron=format                Cron format (optional)
```

Example:
```bash
$ nasne_checker \
  --nasne 192.168.10.10 \
  --slack https://hooks.slack.com/services/XXX/XXX/XXXXX \
  --cron "00 20 * * 1,3,5"
```

## Changelog
* 0.1.0: First release.

## License
MIT
