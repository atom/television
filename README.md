# Television

This is a minimalistic view-to-model binding framework designed to integrate
cleanly with Telepath as the model layer and also provide a migration path from
SpacePen heavyweight views. It's inspired by Rivets.js, but has some small, but
I think important, differences.

## Registering Templates

Templates are registered on Television's root object, which can be assigned to
a `tv` global. In Atom, it will probably be assigned to `atom.templates`. The
following snippet assigns the `tv` global, then registers two templates, `Blog`
and `Post`. The `Blog` template specifies its `content` as a string, while the
second uses an HTML builder DSL. Ignore the `x-bind-` attributes on the markup
for now; we'll discuss them shortly.

```coffee
global.tv = require('television')()

tv.register 'Blog'
  content: """
    <div class="blog">
      <h1 x-bind-text="title">Title</h1>

      <h2>Featured Post</h2>
      <div x-bind-component="featuredPost"></div>

      <h2>Other Posts</h2>
      <ol x-bind-collection="otherPosts"></ol>
    </div>
  """
tv.register 'Post'
  content: ->
    @div class: "post", =>
      @h1 'x-bind-text': "title", "Title"
      @div 'x-bind-text': "body"
```

## Building Views

Now you can construct views based on model objects. So to use the views defined
above, we define model classes, construct model instances, then call
`tv.visualize` with the model for which we want to build a view. The correct
template will automatically be selected based on the name of the model, and the
resulting DOM element will be populated with values from the model based on its
declared bindings, discussed next.

```coffee
{Model} = require 'telepath'

class Blog extends Model
  @properties
    title: ""
    featuredPost: null
    otherPosts: []
  
class Post extends Model
  @properties
    title: ""
    body: ""

post1 = new Post(title: "My Dog", body: "My dog used to be well behaved, but...")
post2 = new Post(title: "Dolphin Cheese", body: "Why do we only make cheese from cows, goats, and sheep?")
post3 = new Post(title: "Bagels & Donuts", body: "Carbohydrates are great, but they're even better with a hole...")

blog = new Blog
  title: "Musings"
  featuredPost: post2
  otherPosts: [post1, post3]

blogView = tv.visualize(blog)
document.body.appendChild(blogView)
```

## Declaring Bindings

To associate the content of a view with its underlying model, you use binding
declarations, which are simply HTML attributes beginning with `x-bind-`.

### Text Bindings

```html
<h1 x-bind-text="title">Title</h1>
```

This is the simplest type of binding, which simply replaces the entire textual
content of the bound element with the value of the bound property on the model
object. The snippet above, pulled from the blog example at the start of the
readme, associates the content of the `h1` element with the title of the blog.
The word "Title", which appears in the template, is just a placeholder and will
be overwritten with the current title in a real view.

### Component Bindings

```html
<h2>Featured Post</h2>
<div x-bind-component="featuredPost"></div>
```

Elements with the `x-bind-component` attribute serve as a placeholder for an
entire view based on the bound property. In this example, Television will
replace the `div` element with a view based on the blog's currently featured
post. Whenever it changes, the view will be updated. If the bound model property
is null, the placeholder element will be used instead.

### Collection Bindings (WIP)

```html
<h2>Other Posts</h2>
<ol x-bind-collection="otherPosts"></ol>
```

Collection bindings populate the bound element with child elements, which are
built automatically based on the type of each element in the bound collection.

## Registering Custom Binders

You can register your own binders by calling `::registerBinder` on the root or
any template.

```coffee
tv.registerBinder 'display',
  bind: (template, element, model, propertyName) ->
    model["$#{propertyName}"].onValue (value) ->
      if value
        element.style.display = 'block'
      else
        element.style.display = 'none'

  unbind: (subscription) ->
    subscription.off()
```

You pass it a string to be matched against `x-bind-*` attributes, then an object
with a `bind` and `unbind` method. The `bind` method will be passed the relevant
objects. The `undbind` method will be called with whatever you returned from
`bind` when the binding is no longer needed.

## Scoped Templates

If you want to make a template available only for use by component/collection
bindings of a certain other template, you can register it on that template
specifically as follows:

```coffee
tv.Blog.register 'Comment', content: # ...
```
Now whenever a comment needs to be rendered within a Blog template, the
specified template will be used. But it won't be used by other top-level
templates. Scoped templates can be nested to arbitrary depth:

```coffee
tv.Blog.Comment.register 'Avatar', content: # ...
```

## Initialization (WIP)

You should try to push as much logic as possible into the model, and failing
that, into a custom binder. Any other concerns can be addressed in an
`initialize` method that is called every time a view is created.

```coffee
tv.register 'Avatar',
  content: # ...
  initialize: ({view, model}) ->
    # set up a hand-crafted relationship between the view and the model...
```

An `initialized` event is also emitted by the template every time a view is
created, following invocation of the main `initialize` hook. This allows third
parties to extend views in an unobtrusive way.

```coffee
tv.Avatar.on 'initialized', ({view, model}) -> addMoustache(view)
```

### Controllers

To organize custom view management code and provide a more convenient interface
for third parties, it can be helpful to define a *controller*. A controller is
just an object that manages the relationship between the view, model, and anyone
that may want to extend the view. Controllers are a convention, but aren't
actually baked into the framework in any way.

```coffee
tv.register 'Avatar',
  content: # ...
  initialize: (params) ->
    # inject the controller into the params object
    params.controller = new AvatarController(params.view, params.model)

tv.Avatar.on 'initialized', (params) ->
  # read the injected controller out of the params hash in 'initialized' event handlers
  params.controller.addMoustache("handlebar")
```

## SpacePen Integration

The plan is still loose, but the hope is that each SpacePen view can be registered
as a template. The content function can be used directly unless it makes any
method calls. Then the `initialize` method will instantiate the jQuery subclass
as a wrapper around the DOM node and assign it as the controller in the params
hash. The SpacePen view shouldn't need to be used very much because most logic
will go into the model, but it could still be helpful to provide people with an
interface for hooking into things like line rendering, etc.
