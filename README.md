# GrandCentral

GrandCentral is a state-management and action-dispatching library for Opal apps. It was created with Clearwater apps in mind, but there's no reason you couldn't use it with other types of Opal apps.

GrandCentral is based on ideas similar to [Redux](http://rackt.github.io/redux/). You have a central store that holds all your state. This state is updated via a reducer block when you dispatch actions to the store.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grand_central'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grand_central

## Usage

First, you'll need a store. You'll need to seed it with initial state and give it a reducer function:

```ruby
require 'grand_central'

store = GrandCentral::Store.new(a: 1, b: 2) do |state, action|
  case action
  when :a
    # Notice we aren't updating the state in-place. We are returning a new
    # value for it by passing a new value for the :a key
    state.merge a: state[:a] + 1
  when :b
    state.merge b: state[:b] + 1
  else # Always return the given state if you aren't updating it.
    state
  end
end
```

Your actions can be anything. We used symbols above, but we also provide a class called `GrandCentral::Action` to help you set up your actions:

```ruby
module Actions
  include GrandCentral

  # The :todo becomes a method on the action, similar to a Struct
  AddTodo    = Action.with_attributes(:todo)
  DeleteTodo = Action.with_attributes(:todo)
  ToggleTodo = Action.with_attributes(:todo) do
    # We don't want to toggle the Todo in place. We want a new instance of it.
    def toggled_todo
      Todo.new(
        id: todo.id,
        name: todo.name,
        complete: !todo.complete?
      )
    end
  end
end
```

Then your reducer can use these actions to update the state more easily:

```ruby
store = GrandCentral::Store.new(todos: []) do |state, action|
  case action
  when Actions::AddTodo
    state.merge todos: state[:todos] + [action.todo]
  when Actions::DeleteTodo
    state.merge todos: state[:todos] - [action.todo]
  when Actions::ToggleTodo
    state.merge todos: state[:todos].map { |todo|
      # We want to replace the todo in the array
      if todo.id == action.todo.id
        action.todo
      else
        todo
      end
    }
  else
    state
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/clearwater-rb/grand_central. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

