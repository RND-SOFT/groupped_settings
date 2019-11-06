<<<<<<< HEAD
# Settings Plugin for Rails

[![Build Status](https://secure.travis-ci.org/ledermann/rails-settings.png)](http://travis-ci.org/ledermann/rails-settings)

Settings is a plugin that makes managing a table of key/value pairs easy. Think of it like a Hash stored in you database, that uses simple ActiveRecord like methods for manipulation. Keep track of any setting that you don't want to hard code into your rails app. You can store any kind of object: Strings, numbers, arrays, or any object which can be noted as YAML.


## Requirements

ActiveRecord 2.3.x, 3.0.x or 3.1.x

Tested with Ruby 1.8.7, 1.9.2, 1.9.3 and RBX2.0


## Setup

You have to create the table used by the Settings model by using this migration:

    class CreateSettingsTable < ActiveRecord::Migration
      def self.up
        create_table :settings, :force => true do |t|
          t.string  :var,         :null => false
          t.text    :value
          t.integer :target_id
          t.string  :target_type, :limit => 30
          t.timestamps
        end

        add_index :settings, [ :target_type, :target_id, :var ], :unique => true
      end

      def self.down
        drop_table :settings
      end
    end
    
Now put update your database with:

    rake db:migrate

## Usage

The syntax is easy. First, lets create some settings to keep track of:

    Settings.admin_password = 'supersecret'
    Settings.date_format    = '%m %d, %Y'
    Settings.cocktails      = ['Martini', 'Screwdriver', 'White Russian']
    Settings.foo            = 123
    Settings.credentials    = { :username => 'tom', :password => 'secret' }

Now lets read them back:

    Settings.foo
    # => 123

Changing an existing setting is the same as creating a new setting:

    Settings.foo = 'super duper bar'

For changing an existing setting which is a Hash, you can merge new values with existing ones:

    Settings.merge! :credentials, :password => 'topsecret'
    Settings.credentials
    # => { :username => 'tom', :password => 'topsecret' }

Decide you dont want to track a particular setting anymore?

    Settings.destroy :foo
    Settings.foo
    # => nil

Want a list of all the settings?

    Settings.all
    # => { 'admin_password' => 'super_secret', 'date_format' => '%m %d, %Y' }

You need name spaces and want a list of settings for a give name space? Just choose your prefered named space delimiter and use Settings.all like this:

    Settings['preferences.color'] = :blue
    Settings['preferences.size'] = :large
    Settings['license.key'] = 'ABC-DEF'
    Settings.all('preferences.')
    # => { 'preferences.color' => :blue, 'preferences.size' => :large }

Set defaults for certain settings of your app.  This will cause the defined settings to return with the
Specified value even if they are not in the database.  Make a new file in config/initializers/settings.rb
with the following:

    Settings.defaults[:some_setting] = 'footastic'
  
Now even if the database is completely empty, you app will have some intelligent defaults:

    Settings.some_setting
    # => 'footastic'

Settings may be bound to any existing ActiveRecord object. Define this association like this:

    class User < ActiveRecord::Base
      has_settings
    end

Then you can set/get a setting for a given user instance just by doing this:

    user = User.find(123)
    user.settings.color = :red
    user.settings.color
    # => :red
    
    user.settings.all
    # => { "color" => :red }

I you want to find users having or not having some settings, there are named scopes for this:

    User.with_settings
    # returns a scope of users having any setting
    
    User.with_settings_for('color')
    # returns a scope of users having a 'color' setting
  
    User.without_settings
    # returns a scope of users having no setting at all (means user.settings.all == {})
    
    User.without_settings('color')
    # returns a scope of users having no 'color' setting (means user.settings.color == nil)

That's all there is to it! Enjoy!
=======
# Settings for Rails

[![Build Status](https://travis-ci.org/ledermann/rails-settings.svg?branch=master)](https://travis-ci.org/ledermann/rails-settings)
[![Code Climate](https://codeclimate.com/github/ledermann/rails-settings.svg)](https://codeclimate.com/github/ledermann/rails-settings)
[![Coverage Status](https://coveralls.io/repos/ledermann/rails-settings/badge.svg?branch=master)](https://coveralls.io/r/ledermann/rails-settings?branch=master)

Ruby gem to handle settings for ActiveRecord instances by storing them as serialized Hash in a separate database table. Namespaces and defaults included.

## Requirements

* Ruby 2.4 or newer
* Rails 4.2 or newer (including Rails 6)


## Installation

Include the gem in your Gemfile and run `bundle` to install it:

```ruby
gem 'ledermann-rails-settings'
```

Generate and run the migration:

```shell
rails g rails_settings:migration
rake db:migrate
```


## Usage

### Define settings

```ruby
class User < ActiveRecord::Base
  has_settings do |s|
    s.key :dashboard, :defaults => { :theme => 'blue', :view => 'monthly', :filter => false }
    s.key :calendar,  :defaults => { :scope => 'company'}
  end
end
```

If no defaults are needed, a simplified syntax can be used:

```ruby
class User < ActiveRecord::Base
  has_settings :dashboard, :calendar
end
```

Every setting is handled by the class `RailsSettings::SettingObject`. You can use your own class, e.g. for validations:

```ruby
class Project < ActiveRecord::Base
  has_settings :info, :class_name => 'ProjectSettingObject'
end

class ProjectSettingObject < RailsSettings::SettingObject
  validate do
    unless self.owner_name.present? && self.owner_name.is_a?(String)
      errors.add(:base, "Owner name is missing")
    end
  end
end
```

In case you need to define settings separatedly for the same models, you can use the persistent option

```ruby
module UserDashboardConcern
  extend ActiveSupport::Concern

  included do
    has_settings persistent: true do |s|
      s.key :dashboard
    end
  end
end

class User < ActiveRecord::Base
  has_settings persistent: true do |s|
    s.key :calendar
  end
end
```

### Set settings

```ruby
user = User.find(1)
user.settings(:dashboard).theme = 'black'
user.settings(:calendar).scope = 'all'
user.settings(:calendar).display = 'daily'
user.save! # saves new or changed settings, too
```

or

```ruby
user = User.find(1)
user.settings(:dashboard).update! :theme => 'black'
user.settings(:calendar).update! :scope => 'all', :display => 'daily'
```


### Get settings

```ruby
user = User.find(1)
user.settings(:dashboard).theme
# => 'black

user.settings(:dashboard).view
# => 'monthly'  (it's the default)

user.settings(:calendar).scope
# => 'all'
```

### Delete settings

```ruby
user = User.find(1)
user.settings(:dashboard).update! :theme => nil

user.settings(:dashboard).view = nil
user.settings(:dashboard).save!
```

### Using scopes

```ruby
User.with_settings
# => all users having any setting

User.without_settings
# => all users without having any setting

User.with_settings_for(:calendar)
# => all users having a setting for 'calendar'

User.without_settings_for(:calendar)
# => all users without having settings for 'calendar'
```

### Eager Loading
```ruby
User.includes(:setting_objects)
# => Eager load setting_objects when querying many users
```

## Compatibility

Version 2 is a complete rewrite and has a new DSL, so it's **not** compatible with Version 1. In addition, Rails 2.3 is not supported anymore. But the database schema is unchanged, so you can continue to use the data created by 1.x, no conversion is needed.

If you don't want to upgrade, you find the old version in the [1.x](https://github.com/ledermann/rails-settings/commits/1.x) branch. But don't expect any updates there.


## Changelog

See https://github.com/ledermann/rails-settings/releases


## License

MIT License

Copyright (c) 2012-2019 [Georg Ledermann](http://www.georg-ledermann.de)

This gem is a complete rewrite of [rails-settings](https://github.com/Squeegy/rails-settings) by [Alex Wayne](https://github.com/Squeegy)
>>>>>>> 78b5e6f... v1
