# Yet anoter Settings Plugin for Rails



Groupped::Settings is a plugin that manage groupped settings :) Settings stored in own database table as json(b) field. Splitted by groups and can have polymorphyc referece to other models.

## Setup

`rake groupped_settings:install`

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

```
class User
  include Groupped::Settings::Settingsable
end


s = User.first.settings_group(:general, GeneralSettings)
```
