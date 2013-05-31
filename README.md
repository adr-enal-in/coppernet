# Coppernet

Welcome to the telephonic cyberspace. Coppernet is an attempt at replacing my Google Voice account with additional features.

*Note: requires Ruby 1.9.3+*

## Features
- Simultaneously forward to multiple numbers
- Dialing out with caller ID
- Customizable telemarketer blacklist

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

## Setup ENV Vars
- Account SID: `ENV["ACCOUNT_SID"]`
- Auth token: `ENV["AUTH_TOKEN"]`
- Cell number: `ENV["CELL_NUMBER"]`
- Twilio number: `ENV["TWILIO_NUMBER"]`
- VoIP number: `ENV["VOIP_NUMBER"]`
