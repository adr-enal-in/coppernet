# CopperNet

Welcome to the telephonic cyberspace. Coppernet is an attempt at replacing my Google Voice account with additional features.

*Note: requires Ruby 1.9.3+*

## Setup
- Set environment variables in `.rbenv-vars` using the [example file](https://github.com/adr-enal-in/coppernet/blob/master/example.rbenv-vars).
- `bundle` to install gems
- Run with `ruby config.ru`

## Features
- Simultaneously forward to multiple numbers
- Dialing out with caller ID
- Customizable telemarketer blacklist
- Missed call notification

## To Do
- Voicemail

## Blacklist
Add numbers to the [blacklist](https://gist.github.com/adr-enal-in/5578514) in the format:

```
[
  {"number": "3101938822", "comment": "Insurance Company"},
  {"number": "3103438822", "comment": "Cable Company"}
]
```
