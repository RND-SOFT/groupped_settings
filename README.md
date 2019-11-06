# Yet anoter Settings Plugin for Rails

[![Gem Version](https://badge.fury.io/rb/groupped_settings.svg)](https://rubygems.org/gems/groupped_settings)
[![Gem](https://img.shields.io/gem/dt/groupped_settings.svg)](https://rubygems.org/gems/groupped_settings/versions)
[![YARD](https://badgen.net/badge/YARD/doc/blue)](http://www.rubydoc.info/gems/groupped_settings)


[![Coverage](https://lysander.x.rnds.pro/api/v1/badges/gs_quality.svg)](https://lysander.x.rnds.pro/api/v1/badges/gs_quality.html)
[![Quality](https://lysander.x.rnds.pro/api/v1/badges/gs_quality.svg)](https://lysander.x.rnds.pro/api/v1/badges/gs_quality.html)
[![Outdated](https://lysander.x.rnds.pro/api/v1/badges/gs_outdated.svg)](https://lysander.x.rnds.pro/api/v1/badges/gs_outdated.html)
[![Vulnerabilities](https://lysander.x.rnds.pro/api/v1/badges/gs_vulnerable.svg)](https://lysander.x.rnds.pro/api/v1/badges/gs_vulnerable.html)


Groupped::Settings is a plugin that manage groupped settings for Rails :) Settings stored in own database table as json(b) field. Splitted by groups and can have polymorphyc referece to other models.

## Setup

`rails g rake groupped_settings:install`
`rails g rake groupped:settings:migration`

Now update your database with:

`rake db:migrate`

## Usage

Define settings group class.
```ruby
class GeneralSettings < Groupped::Settings::Group
  self.group_name = 'general'

  attribute :identifier, :string, default: 'application'
  attribute :secret, :string

  validates :identifier, presence: true
  validates :secret, length: { minimum: 16 }
end
```

Using global settings:
```ruby
s = GeneralSettings.load
s.identifier = '123123123'
s.save!

s = Groupped::Settings[:general, GeneralSettings]
s.secret = '12345678987654321'
s.save!
```


Using settings fot some model:
```ruby
s = GeneralSettings.load(target: User.first)
s.identifier = '123123123'
s.save!

s = Groupped::Settings[:general, User.first]
s.secret = '12345678987654321'
s.save!
```

Include Settingsable concern:

```ruby
class User
  include Groupped::Settings::Settingsable
end


s = User.first.settings_group(:general, GeneralSettings)
```
