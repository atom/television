# Television

Television is an experimental, minimal implementation of the virtual DOM approach to view construction that aims to integrate with the web platform rather than abstract it away. This library is a thin wrapper around the [virtual-dom][virtual-dom] library, and it focuses on allowing you to define HTML 5 custom elements with declarative markup. Efficient DOM access can be ensured in a manner that cooperates with other libraries by assigning an external DOM update scheduler. Other concerns, such as defining and observing a data model and listening for DOM events, are left to other libraries. The examples in this README use an embedded DSL syntax, but it should be possible to target this library with a JSX preprocessor for integrated support for HTML literals.

```coffee
tv = require 'television'
{TaskList, li, input} = tv.buildTagFunctions('task-list')

tv.registerElement 'task-list',
  render: ->
    TaskList id: "on-deck",
      for task in @tasks
        li className: 'task',
          input type: 'checkbox', checked: task.done
          task.title
```

In the example above, we define a `task-list` element via `tv.registerElement`. The prototype template we provide contains a `::render` method, which returns a virtual DOM fragment describing the view. To create an element:

```coffee
taskListElement = document.createElement('task-list')
taskListElement.tasks = [
  {title: "Write code", done: true}
  {title: "Feed cats", done: false}
  {title: "Clean room", done: false}
]
document.body.appendChild(taskListElement)
```

To update an element:

```coffee
taskListElement.tasks.push {title: "Do Homework", done: false}
taskListElement.update()
```

## References

Custom elements have a `refs` hash that can be populated with references to DOM nodes. Use a `ref` attribute on any element in your `render` method to automatically maintain a reference to its node.

```coffee
tv.registerElement 'user-card',
  render: ->
    UserCard(
      img href: user.avatarURL, ref: 'avatarImage'
      span user.fullName
    )

userCard = document.createElement('user-card')
userCard.refs.avatarImage # --> reference to avatar image DOM element
```

## Lifecycle Hooks

Elements registered via `registerElement` can define a few lifecycle hooks:

* `::didCreate` Called after the element is created but before it has content.
* `::didAttach` Called after the element is attached and rendered.
* `::didDetach` Called after the element is detached but before its content is cleared.
* `::readSync` Called after the element is updated. If you need to read the DOM, you can safely do so here without blocking a DOM write. Do not write to the DOM in this method!

[virtual-dom]: https://github.com/Matt-Esch/virtual-dom

## Assigning a DOM Scheduler

You should assign a DOM update scheduler on Television that's responsible for coordinating DOM updates among all components. The scheduler should have an `updateDocument` and a `readDocument` method. If you're using this library within Atom, you can assign `atom.views` as the scheduler:

```coffee
tv = require 'television'
tv.setDOMScheduler(atom.view)
```

## Unregistering Elements

To unregister a custom element, call `.unregisterElement` on the element constructor. After doing so, you'll be able to register another element with the same name.

```coffee
UserCard = tv.registerElement 'my-element',
  render: -> MyElement("Hello World")

# Later...
UserCard.unregisterElement()
```

Under the hood, we dynamically reassign prototypes to make this possible, since the current DOM APIs don't support unregistering elements.
