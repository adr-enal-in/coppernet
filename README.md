# CopperNet

Welcome to the telephonic cyberspace. Coppernet is an attempt at replacing my Google Voice account with additional features.

*Note: requires Ruby 1.9.3+*

## Setup
- Set environment variables in `.rbenv-vars` using the [example file](https://github.com/adr-enal-in/coppernet/blob/master/example.rbenv-vars).
- `bundle` to install gems
- Run with `ruby config.ru`

## Database Stuff
- __Creating migrations__: `rake db:create_migration NAME=create_table_name`
- __Running migrations__: `rake db:migrate` (duh)
- __Creating records via console__: `bundle exec irb`

[Guide](http://danneu.com/posts/15-a-simple-blog-with-sinatra-and-active-record-some-useful-tools/) for using ActiveRecord with Sinatra.

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

## Heroku Tips
Because Heroku shuts down inactive apps you might want to hit the web URL on a recurring basis with a cron or site uptime checking service to prevent it from sleeping lest your callers get a weird delay before the app runs.
