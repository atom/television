# Television

Television aims to cleanly integrate the virtual DOM approach of React.js into HTML 5 custom elements.

```coffee
tv = require 'television'
[TaskList, li, input] = tv.tags 'task-list', 'li', 'input'

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
taskListElement.updateSync()
```

## Ideas

I don't think this library should include any state management system. When you want an element to update, you should just request it explicitly. This makes it easier to keep state in whatever location makes sense.

## Possible next steps:

* Add an asynchronous `::update` method that participates in a managed lifecycle
  to avoid reflows.
* Add `::didAttach` and `::didDetach` hooks.
* Add `::willUpdate` and `::didUpdate` hooks.
* Add `::readBeforeUpdate` and `::readAfterUpdate` hooks where DOM reads can
  be performed at moments that won't cause a reflow.
* Cascade attribute updates through custom child elements.
