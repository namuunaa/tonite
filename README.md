[![Build Status](https://travis-ci.org/namuunaa/tonite.svg?branch=development)](https://travis-ci.org/namuunaa/tonite)
[![Coverage Status](https://img.shields.io/codecov/c/github/codecov/example-python.svg?branch=development)](https://codecov.io/gh/namuunaa/tonite)

# Tonite
<p align="center">
<img src= "https://github.com/namuunaa/tonite/blob/master/app/assets/images/tonite_512_round.png" alt="tonite logo" align="center">
</p>

**Tonite** is an event recommendation app that allows users to use Alexa to find an
event going on today for a spontaneous outing.

By connecting users with events and experiences they might never have sought out on their own, we encourage them to embrace serendipity and discover a new side of their city.

## Basic Use

Add the skill _Tonite_ to your Alexa account.

<img src= "https://github.com/namuunaa/tonite/blob/master/app/assets/images/skill.png" alt="add skill" width="400" height="600">
<img src= "https://github.com/namuunaa/tonite/blob/master/app/assets/images/top_event.png" alt="top skill" width="400" height="600">


Say "Alexa, ask Tonite for something to do."

## Installing / Getting Started

<p align="center">
<img src= "https://github.com/namuunaa/tonite/blob/master/app/assets/images/system_overview.png" alt="system overview diagram" align="center">
</p>

### Alexa Skill Setup

[See Getting Started with the Alexa Skills Kit](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/getting-started-guide)

[Our speech interface configuration](./alexa_interface.json)

### Server Setup

```
git clone https://github.com/namuunaa/tonite.git
bundle
bin/rails db:create
rails server
```

### Connecting the Skill and Server

In the Alexa Skill configuration menu paste the location of your server in the
endpoint field. It should be something like `https://your-domain-here/alexa_interface`.

## Tech Stack

 * Ruby on Rails
 * Amazon Alexa Skill
 * Echo Dot
 * Travis-ci
 * CodeCov
 * Eventful API
 * Heroku

## User Stories

[User Stories](./user_stories.md)

## Authors

* Namuun Bayaraa [GitHub](https://github.com/namuunaa)
* Ransom Byers [GitHub](https://github.com/rasnom)
* Brianna Forster [GitHub](https://github.com/b-forster)
* Dillon Arevalo [GitHub](https://github.com/dillonbarevalo)

## Contributing

If you'd like to contribute, please fork the repository and use a feature
branch. Pull requests are warmly welcome.

## Licensing

This project is licensed under [MIT license](./LICENSE)

## Helpful Resources

 * [Primer on the grammar for Alexa custom skills](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/supported-phrases-to-begin-a-conversation)
 * [JSON Interface for Custom Skills](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interface-referenceg)

