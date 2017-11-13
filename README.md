# GrandCentral

GrandCentral is a state-management and action-dispatching library for Ruby apps. It was created with [Clearwater](https://github.com/clearwater-rb/clearwater) apps in mind, but there's no reason you couldn't use it with other types of Ruby apps.

GrandCentral is based on ideas similar to [Redux](http://rackt.github.io/redux/). You have a central store that holds all your state. This state is updated via a handler block when you dispatch actions to the store.

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

First, you'll need a store. You'll need to seed it with initial state and give it a handler block:

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

store.dispatch :a
store.dispatch :b
store.dispatch "You can dispatch anything you want, really"
```

### Actions

The actions you dispatch to the store can be anything. We used symbols in the above example, but GrandCentral also provides a class called `GrandCentral::Action` to help you set up your actions:

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

Then your handler can use these actions to update the state more easily:

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

### Dispatching actions without the store

There may be parts of your app that need to dispatch actions but you don't want them to know about the store itself. In a [Clearwater](https://github.com/clearwater-rb/clearwater) app, for example, your components may need to fire off actions, but you don't want them to know how to get things from the store.

Subclasses of `GrandCentral::Action` have a `store` attribute where you can set the default store to dispatch to:

```ruby
store = GrandCentral::Store.new(todos: []) do |state, action|
  # ...
end

MyAction = GrandCentral::Action.with_attributes(:a, :b, :c)
MyAction.store = store
```

To use this default store, you can send the `call` message to the action class itself:

```ruby
MyAction.call(1, 2, 3) # these arguments correspond to the a, b, and c attributes above
```

#### Action Currying

You can [curry](https://en.wikipedia.org/wiki/Currying) an action with the `[]` operator instead of `call`. There is a minor difference between action currying and traditional function currying, though: function currying automatically invokes the function once all of the arguments are received, whereas currying a `GrandCentral::Action` will curry until you explicitly invoke it with `call`:

```ruby
SetAttribute = Action.with_attributes(:attr, :value)

# Returns an action type based on `SetAttribute` with `attr` hard-
# coded to `:name`. When you invoke this new action type, you only
# need to provide the value.
SetName = SetAttribute[:name]

# This action is a further specialization where we know both the
# attribute *and* the value. You don't need to provide any values.
ClearName = SetName[nil]
```

These are all equivalent action invocations:

```ruby
SetAttribute.call :name, nil
SetAttribute[:name].call nil
SetAttribute[:name, nil].call
SetName.call nil
ClearName.call
```

#### Using with Clearwater

Because of action currying, we can set action types as event handlers in Clearwater components. GrandCentral even knows how to handle `Bowser::Event` objects whose targets are instances of `Bowser::Element` (Clearwater uses Bowser as its DOM abstraction). So if you set an action to handle toggling a checkbox, the last argument will contain the input's `checked` property; if you use it for a text box, the last argument will be the `value` property. It'll even prevent `form` submission for you:

```ruby
ToggleTodo = Action.with_attributes(:todo, :complete)

class TodoList
  include Clearwater::Component
  
  def initialize(todos, new_description)
    @todos = todos
    @new_description = new_description
  end
  
  def render
    div([
      # When we submit this form, we fire an AddTodo with the description set to @new_description
      form({ onsubmit: AddTodo[@new_description] }, [
        input(oninput: SetNewTodoDescription, value: @new_description),
        button('Add'),
      ]),
      ul(todos.map { |todo|
        li([
          input(type: :checkbox, onchange: ToggleTodo[todo]),
          todo.description,
          button({ onclick: DeleteTodo[todo] }, '✖️'),
        ])
      }),
    ])
  end
```

### Performing actions on dispatch

You may want your application to do something in response to a dispatch. For example, in a Clearwater app, you might want to re-render the application when the store's state has changed:

```ruby
store = GrandCentral::Store.new(todos: []) do |state, action|
  # ...
end

app = Clearwater::Application.new(component: Layout.new)

store.on_dispatch do |old_state, new_state|
  app.render unless old_state.equal?(new_state)
end
```

Notice the `unless old_state.equal?(new_state)` clause. This is one of the reasons we recommend you update state by returning a new value instead of mutating it in-place. It allows you to do cache invalidation in O(1) time.

## Models

We can use the `GrandCentral::Model` base class to store our objects:

```ruby
class Person < GrandCentral::Model
  attributes(
    :id,
    :name,
    :location,
  )
end
```

This will set up a `Person` class we can instantiate with a hash of attributes:

```ruby
jamie = Person.new(name: 'Jamie')
```

### Immutable Models

The attributes of a model cannot be modified once set. That is, there's no way to say `person.name = 'Foo'`. If you need to change the attributes of a model, there's a method called `update` that returns a new instance of the model with the specified attributes:

```ruby
jamie = Person.new(name: 'Jamie')
updated_jamie = jamie.update(location: 'Baltimore')

jamie.location         # => nil
updated_jamie.location # => "Baltimore"
```

This allows you to use the `update` method in your store's handler without mutating the original reference:

```ruby
store = GrandCentral::Store.new(person) do |person, action|
  case action
  when ChangeLocation
    person.update(location: action.location)
  else person
  end
end
```

This keeps each version of your app state intact if you need to roll back to a previous version. In fact, the app state itself can be a `GrandCentral::Model`:

```ruby
class AppState < GrandCentral::Model
  attributes(
    :todos,
    :people,
  )
end

initial_state = AppState.new(
  todos: [],
  people: [],
)

store = GrandCentral::Store.new(initial_state) do |state, action|
  case action
  when AddPerson
    state.update(people: state.people + [action.person])
  when DeleteTodo
    state.update(todos: state.todos - [action.todo])

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

