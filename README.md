# Television

Television is a reactive view framework based on the "model/view/view-model"
paradigm. Views are simple, declarative wrappers around underlying model
objects, enforcing a separation between application logic and display logic.
Like most good ideas, this one isn't new, but Television provides a unique
combination of features to make working in this style intuitive and productive.


## View Classes

A convenient (but option) way to define a view is by creating a `View` subclass.

```coffee
{View} = require 'television'

class BlogView extends View
  @content: """
    <div class="blog">
      <h1>My Blog</h1>
    </div>
  """
```

This is a simple view for `Blog` models. The name of a view class should be
based on the name of the model class it's intended to visualize (with `View`
appended to the end). Note the `@content` class-level property. It contains a
string of HTML on which the view's DOM element will be based. The `@content`
property can also be a DOM element or a function that returns a string or DOM
element. This makes it easy to integrate with third-party templating frameworks
if you choose to do so. Television also includes a markup DSL, which is
convenient if you just want to specify your content with code:

```coffee
class BlogView extends View
  @content: ->
    @div class: 'blog', => @h1 "My Blog"
```


## View Instances

Now that we've defined a view class, we can use it to construct a view.
Television currently only works with Telepath models, so we'll define one first.
It should be easy to allow other types of models in the future.


```coffee
{Model} = require 'telepath'

class Blog extends Model
  @properties 'title', 'author', 'posts'

blog = Blog.createAsRoot(title: "Cats")
view = new BlogView(blog)

expect(view.element.outerHTML).toBe """
  <div class="blog">
    <h1>My Blog</h1>
  </div>
"""
expect(view.model).toBe blog
```

Note that the view instance we constructed has an `element` and a `model`
property, and that the element is based on the `@content` property of the view
class.


## Bindings

Bindings allow you to declaratively wire your view's HTML content to properties
on the view's model. When the view is created, the content is populated based on
the model you pass in. If properties on the model change, the view is updated
automatically.


### Text Bindings

In the example above, we have a `title` property on the blog model that we'd
like to appear in the view. To instruct Television to associate the title with
the text content of the `h1` tag, we use the `x-bind-text` attribute.

```coffee
class BlogView extends View
  @content: """
    <div class="blog">
      <h1 x-bind-text="title">My Blog</h1>
    </div>
  """
  
blog = Blog.createAsRoot(title: "Cats")
view = new BlogView(blog)
expect(view.element.outerHTML).toBe """
  <div class="blog">
    <h1 x-bind-text="title">Cats</h1>
  </div>
"""

# updates view automatically
blog.title = "Dogs"
expect(view.element.outerHTML).toBe """
  <div class="blog">
    <h1 x-bind-text="title">Dogs</h1>
  </div>
"""
```


### Attribute Bindings

The blog model also has an `author` property, which contains a reference to a
`User` model. Let's define a `UserView`, which has an avatar for the user and
their name. To assign the value of the `src` property on the image, we'll use
the `x-bind-attribute-` directive.

```coffee
class User extends Model
  @properties 'name', 'avatarUrl'

class UserView extends View
  @content: -> """
    <div class="user">
      <img class="avatar" x-bind-attribute-src="avatarUrl" src="placeholder.png">
      <div class="name" x-bind-text="name">Name</div>
    </div>
  """
```

Note that the name of the bound attribute is appended to the end of the binding
name. If the value of the bound property isn't defined, the placeholder value
of `placeholder.png` is used instead. If you don't define a placeholder value,
the attribute will be removed when the bound value is undefined.


### Component Bindings

Now we want to include an instance of the `UserView` inside our `BlogView`,
bound to the `author` property on the blog. To do that, we'll use a component
binding.

```coffee
class BlogView extends View
  @register UserView

  @content: """
    <div class='blog'>
      <h1 x-bind-text="title">My Blog</h1>
      <div x-bind-component="author"></div>
    </div>
  """
```

First, we call `@register` on `BlogView` with the `UserView` class. This adds
to the set of views that `BlogView` will consider when constructing a view for
bound components. If `BlogView` were itself embedded as a component in another
view didn't have a registered view for `User`, it would search upward through
its ancestors for a view that matches. Here's the component binding in action:

```coffee
author =
blog = Blog.createAsRoot
  title: "Cats"
  author: new User
    name: "Nathan Sobo"
    avatarUrl: "/images/nathan.png"

view = new BlogView(blog)
expect(view.element.outerHTML).toBe """
  <div class="blog">
    <h1 x-bind-text="title">Cats</h1>
    <div class="user">
      <img class="avatar" x-bind-attribute-src="avatarUrl" src="/images/nathan.png">
      <div class="name" x-bind-text="name">Nathan Sobo</div>
    </div>
  </div>
"""
```


### Collection Bindings

Now we want to include a summary of each of the blog's posts. We assign
`@modelClassName` explicitly to 'Post' since the view name does not match the
standard *Model Class Name + "View"* pattern. For that, we'll use the
`x-bind-collection` directive. First, we define the post summary view, then bind
a list to a collection of posts on the blog.

```coffee
class PostSummaryView extends View
  @modelClassName: 'Post'
  
  @content: """
    <div class="post-summary">
      <h2 x-bind-text="title">Title</h2>
      <div x-bind-text="summary"></div>
    </div>
  """

class BlogView extends View
  @register UserView
  @register PostSummary

  @content: """
    <div class="blog">
      <h1 x-bind-text="title">My Blog</h1>
      <div x-bind-component="author"></div>
      <ol x-bind-collection="posts"></ol>
    </div>
  """
```


## Custom View Methods

You should concentrate the majority of your application logic in the model
layer and use declarative bindings to wire it to the view. You can even design
your own custom binders if the built-in binders don't cover your needs, which
we'll discuss later. But sometimes you're going to need custom view logic, and
for that you'll use custom view methods.


### Lifecycle Hooks

If you define the `created` or `destroyed`  instance methods on your view
classes, they will be called at the appropriate time. Note that Television
performs caching in certain circumstances, so `destroyed` is only guaranteed to
be called when the underlying model object is detached from the document.

```coffee
class UserView extends View
  @content: -> # ...
  
  created: ->
    startCrazyAnimation(@element)

  destroyed: ->
    stopCrazyAnimation(@element)
```

### Instance Methods

You can also define instance methods on your view class, just like you can for
any normal class. Just be careful not to put logic in the view that belongs in
the model.

```coffee
class UserView extends View
  @content: -> # ...
  
  addMoustache: (type) -> # ...

view = new UserView(user)
view.addMoustache("handlebar")
```


## Using a Global Registry

The examples above instantiate the blog view directly, which is good for testing
or more isolated use. A more holistic approach is to create a global
registration point from which all the application's views descend. This allows
third parties to easily register new kinds of views, which can then be displayed
as components anywhere in the application.

```coffee
television = require 'television'
tv = television()

tv.register(BlogView)
tv.register(PostView)
tv.register(UserView)

blogView = tv.viewForModel(blog)

tv.register(SpecialUserView) # add a view for a new type
blog.author = new SpecialUser # the new view will automatically be used by BlogView
```

All registered views are available as properties on whatever you register them
on. So you can access `tv.BlogView`, and `tv.BlogView.PostSummaryView` and
`tv.BlogView.PostSummaryView.SomeOtherSubview` etc.


## Using Without Subclassing View

If you don't want to subclass `View`, you can use the `::register` or
`::buildViewFactory` methods. The `name` and `content` properties are mandatory.
Any other properties will be added to the constructed view objects.

```coffee
television = require 'television'
tv = television()

tv.register
  name: 'BlogView'
  content: # ...
  created: -> # ...
  destroyed: -> # ...
  customMethod: -> # ...
  
view = tv.viewForModel(blog)
view.customMethod()

# or create a standalone factory
factory = tv.buildViewFactory name: 'BlogView' content: # ...
view = factory.viewForModel(blog)
```


## Registering Custom Binders

You can register your own binders by calling `::registerBinder` on any view
class or view factory, including the global registry.

```coffee
tv.registerBinder 'display',
  bind: ({element, model, propertyName}) ->
    model["$#{propertyName}"].onValue (value) ->
      if value
        element.style.display = 'block'
      else
        element.style.display = 'none'

  unbind: (subscription) ->
    subscription.off()
```


Call `::registerBinder` with an object containing a `type` property and two
methods, `bind` and `unbind`. The `type` property can be a string or a regular
expression that will be matched against the suffix of `x-bind-*` attributes.
When an element with a matching attribute is found, your `bind` method will be
called with an object containing the following properties:

* `type` - The name of the binding, e.g. `"text"` or `"attribute-src"`
* `factory` - The factory that built the view containing the bound element
* `element` - The element being bound, that is the element with the matching `x-bind-*` attribute
* `model` - The model being bound
* `propertyName` - The property name on the model to bind

Whatever you return from the `bind` method will be passed to `unbind` when the
binding needs to be destroyed.
