# Swift JSON Shoot-Out

## Introduction

I'm not entirely sure why, but parsing JSON in Swift appears to be one of the
most popular topics to write about. Maybe it's a right of passage to becoming a
Swift blogger? Anyway, it seems like a good time to get involved.

There have been some truly excellent blog posts about using JSON with Swift, but
they mainly focus on the theory behind using the functional aspects of the new
language to the best effect. This is great, and I recommend you read them, but
we don't necessarily want to have to learn a whole new programming paradigm to
implement the network data layer of our app.

This article is a pragmatic review of the current options available for JSON
parsing in Swift, covering some of the most popular new libraries.

All approaches rely on Cocoa's `NSJSONSerialization` class to handle the JSON
string to Foundation object parsing. The interesting question is what happens at
this point. In the Swift world, the output of 
`JSONObjectWithData(_:, options:, error:)` is an `AnyObject?` blob. What can we
do with this? We know it's made up of Foundation objects such as `NSArray`, 
`NSDictionary`, `NSNumber` etc, but the structure is dependent on the schema of
the JSON.

First of all we'll take a look at what we'd actually like from a JSON parser, in
an ideal world, before reviewing the naïve approaches you'd expect as a seasoned
objective-C developer. Then we'll consider two new frameworks that have popped
up in the last few months, explaining their underlying concepts and reviewing
how close they come to our ideal scenario.


### Wishlist

JSON is a great serialization technology due to its simple specification, and
accessibility to both humans and machines. However, it quickly becomes unwieldy
within the context of an application. Most software design architectures have
the concept of a model layer - that is a selection of objects used to model the
data structure that you application acts upon. It is these model objects that
the JSON should be turned in to once inside the application.

Since the `NSJSONSerialization` class has no knowledge of the specific model
layer within your application, it translates the JSON into the generic types
within Foundation. It is the next step - translating these Foundation types into
our data model - that is important.

Our parser should leverage the type-safety that underlies Swift, and also not
allow partial objects to be created.

As you'll see, satisfying these requirements is not too difficult in a
'best-case' scenario, but becomes increasingly difficult when attempting to cope
with errors in the JSON data structure.

### Other approaches

Before diving into the problem from a Swift point of view, let's take a moment
to review how other languages handle JSON.

C# offers an approach which uses dynamic objects. That is to say that the
structure of the objects is not known at compile time, but instead they are
created at runtime. In some respects, this is a lot like the behavior of
`NSJSONSerialization`, with the extension of using properties on a dynamic
objects instead of a dictionary keyed on strings. This approach is not typesafe,
in that the type-checker has no knowledge of the dynamic objects, and therefore
lets you do whatever you wish with them in the code. It isn't until runtime
(i.e. once the JSON has been parsed) that you discover particular properties
don't exist, or are of the incorrect type.

Sticking with C#, there are alternative approaches that automatically
deserialize JSON into pre-defined model objects through reflection and
annotations. Since your define the model objects in code, you retain the type
safety you're used to, and the annotations/reflection mean that you don't
repeat yourself.

Ideally we'd like to use the latter of these two approaches in Swift. Swift
doesn't yet support reflection or annotations, so we can't get quite the same
functionality, but how close can we get?

### Accompanying Project

This article has accompanying code to demonstrate the different approaches to
JSON parsing in Swift, and it takes the form of three playgrounds, combined
together in a workspace. The workspace also contains projects for the three
framework dependencies - SwiftyJSON, Argo and Runes. Combining everything in a
workspace allows you to use dependencies within playgrounds.

Carthage was used to import the dependencies, but since they have been committed
into the repo, you shouldn't need to worry about it. You will, however, need to
build the frameworks in the workspace. The playgrounds are for OSX, so select
each of __ArgoMac__ and __SwiftJSONOSX__ from the build schemes menu and then
build it. Then the playgrounds will work as expected.

## Naïve Parsing

The output from the `NSJSONSerialization` class is composed of Foundation
objects - `NSDictionary`, `NSArray`, `NSString`, `NSNumber`, `NSDate` and
the all-important `NSNull`. Understandably, coming from an objective-C
heritage, your first attempt at interpreting this data structure to match your
model layer might be to deal with it directly. Since all the constituent parts
are subclasses of `NSObject`, and properly implement key-value coding (KVC), you
can jump straight in with the `valueForKeyPath:` method.

For example, given an `NSDictionary` that represents a GitHub repository from
the __repos__ API, you could find discover the repo name as follows:

    let repo_name = repo_json.valueForKeyPath("name")

Notice that since you're leveraging KVC, you can delve further into the nested
structure:

    let owner_login = repo_json.valueForKeyPath("owner.login")

This approach is quite powerful for pulling out the odd element from a JSON
structure, however, it doesn't stack up very well when trying to populate a
model object. For example, the `Repo` struct is a small subset of the data
returned in the JSON:

    struct Repo {
      let id: Int
      let name: String
      let desc: String?
      let url: NSURL
      let homepage: NSURL?
      let fork: Bool
    }

To correctly populate an array of `Repo` objects using `valueForKeyPath`, you'd
have to write code along the following lines:

var repos = [Repo]()

    if let json : AnyObject = json {
      if let array = json as? NSArray {
        for jsonItem in array as [AnyObject] {
          if let id = jsonItem.valueForKey("id") as? Int {
            if let name = jsonItem.valueForKey("name") as? String {
              if let url_string = jsonItem.valueForKey("url") as? String {
                if let fork = jsonItem.valueForKey("fork") as? Bool {
                  if let url = NSURL(string: url_string) {
                    let description = jsonItem.valueForKey("description") as? String
                    var homepage: NSURL? = .None
                    if let homepage_string = jsonItem.valueForKey("homepage") as? String {
                      homepage = NSURL(string: homepage_string)
                    }
                    let repo = Repo(id: id, name: name, desc: description, url: url,
                                    homepage: homepage, fork: fork)
                    repos += [repo]
                  }
                }
              }
            }
          }
        }
      }
    }

There are a few points to note about this code:

- __Rightward Drift__ If the JSON is malformed, or there is a mistake in the
parsing code, then `valueForKeyPath()` will return `nil`. Therefore you need to
check that each time you extract a value, it is not `nil`, and it is of the
expected type. This leads to the optional-checking tree.
- __Type conversions__ If your JSON includes types which are not directly
supported by `NSJSONSerialization` (such as `NSURL`) then the conversion code is
likely to end up mixed in with the optional checking tree, as it does here.
- __Repeated Structure__ Notice that all this code is really doing is extracting
the appropriate values for your pre-defined `Repo` struct and then creating one.
This feels like repeated effort, especially since the property names in the
struct are identical to those in the JSON itself.
- __Legibility__ I bet you haven't actually read the above code block. Not
_really_ read it - I mean read it to understand it. I don't blame you - it's an
impenetrable mess. It's responsible for extracting values, type checking,
validation, type conversion, object creation and appending to an array. That's
not a sign of a well-formed block of code.

Don't dwell on this example too much - the code could almost certainly be
reformatted and improved, whilst retaining the same approach. However, as we
progress, you'll see that there are better approaches from the outset.

You might have looked at this and decided that the `valueForKeyPath` approach is
a deliberate attempt to be obtuse - there are better ways of working with
Foundation objects in Swift. To an extent you'd be correct - `valueForKeyPath`
is great at diving deep into object structures, but that might not always be
ideal. For the interests of fairness, let's take a look at a slightly more
Swift-friendly approach.

The Foundation objects that are supported by `NSJSONSerialization` all have
Swift counterparts that are bridged. For example, `NSString` in Foundation can
be represented as a `String` in Swift. This gets a little more complicated with
`NSArray` and `NSDictionary`, but with some optional casting, and liberal use of
`AnyObject` you can work with pure Swift representations of the underlying
Foundation objects.

The previous code block for creating an array of `Repo` objects can be rewritten
as the following:

    var repos_ot = [Repo]()

    if let repo_array = json as? NSArray {
      for repo_item in repo_array {
        if let repo_dict = repo_item as? NSDictionary {
          if let id = repo_dict["id"] as? Int {
            if let name = repo_dict["name"] as? String {
              if let url_string = repo_dict["url"] as? String {
                if let fork = repo_dict["fork"] as? Bool {
                  if let url = NSURL(string: url_string) {
                    let description = repo_dict["description"] as? String
                    var homepage: NSURL? = .None
                    if let homepage_string = repo_dict["homepage"] as? String {
                      homepage = NSURL(string: homepage_string)
                    }
                    let repo = Repo(id: id, name: name, desc: description, url: url,
                                    homepage: homepage, fork: fork)
                    repos_ot += [repo]
                  }
                }
              }
            }
          }
        }
      }
    }

You should notice straight away that there isn't actually a huge amount of
difference. The code still suffers from rightward drift from the optional
nesting, it still has the type conversion embedded in the tree, and the
structure has once again been replicated.

OK, so we've established how far we can get with this naïve approach, somewhat
inspired by our traditional objective-C days, but what happens when we start to
use some of the new features of Swift?

## SwiftyJSON

As was mentioned in the intro to this article, we're not actually going to dig
too far into _how_ things are being implemented in Swift, but rather discover
how others (via frameworks) have used the functionality to improve the developer
experience associated with parsing JSON.

First up is an open source library called __SwiftyJSON__. The key functionality
within Swift that drives the approach taken in __SwiftyJSON__ is the
introduction of a more complete `enum` type - more specifically, one that allows
associated values. This is used to create a `JSON` type, which can take a
variety of different cases, each with an associated value. i.e. every element in
a JSON structure can be represented using a single type - a string is still of
type JSON, but with an associated `String` value, etc. This might sound a little
confusing, but once you get your head round it you'll see that it's really
powerful. This is starting to scratch the surface of a topic known as
"Algebraic Data Types" from within functional programming. As with all topics in
functional programming, it sounds a lot more complicated than it actually is.

In addition to this fundamental `JSON` datatype, __SwiftyJSON__ also adds lots
of implicit type conversions to simplify the typing frenzy that is optional
chaining.

So, enough theory, what does this actually look like when applied to the
aforementioned `Repo` array?

    let json = JSON(data: rawJSON!, options: .allZeros, error: nil)

    var repos = [Repo]()
    for (index: String, subJson: JSON) in json {
      if let id = subJson["id"].int {
        if let name = subJson["name"].string {
          if let url = subJson["url"].string {
            if let fork = subJson["fork"].bool {
              var homepage: NSURL? = .None
              if let homepage_raw = subJson["homepage"].string {
                homepage = NSURL(string: homepage_raw)
              }
              let url_url = NSURL(string: url)!
              repos += [Repo(id: id, name: name, desc: subJson["description"].string,
                url: url_url, homepage: homepage, fork: fork)]
            }
          }
        }
      }
    }

Some things to note about this code segment:
- __Implicit NSJSONSerialization__. SwiftyJSON includes this as part of its
implementation, so you actually just need to pass the raw `NSData` object.
- __Custom enumeration__. A new `for(index:, subJson:)` method has been created
which looks a little bit like a `for-in` loop. This works on a JSON array, and
provides each element as a `JSON` object.
- __JSON Subscripting__. If a `JSON` element is of a dictionary type then
subscripting behaves as you might expect, allowing things like `subJson["url"]`.
- __JSON casting__. `JSON` elements also have properties on them which allow you
to extract the associated value. For example, if the element is of a string
type, you can extract that string with the `string` method. These properties are
all optionals, so if you attempt to extract a string from a number element,
you'll get rewarded with `.None`. 
- __Rightward Drift__. It's still there - again ensuring that it's impossible to
construct a malformed `Repo` object. This is because the accessor properties on
the `JSON` enum are all optional, and not all of our `Repo` properties accept
optionals.
- __Type Conversion__. The `NSString` to `NSURL` type conversion is still part
of the parsing tree. This is probably a little unfair; it is perfectly possible
to define an extension to the `JSON` enum to add a property of type `NSURL?`.
This would implement the same functionality as the existing code, but would be
in a more appropriate place.

So in summary, it's a lot better than the original approach, but it is still
liable to end up with an optional tree somewhere. It's great for extracting
specific values from a JSON data structure, but doesn't solve the problem of
converting the JSON to model objects in a particularly elegant way. You could
argue that maybe it's not supposed to do that - it has succeeded in making
working with JSON a much more type-safe exercise, but you're still left with
writing a lot of the parsing logic yourself.

## Argo

- A 'pure-functional' approach to JSON parsing
- Designed to populate model objects directly from the JSON stream
- Copes with primitives automatically
- Requires a `decode` method to be written for custom objects (since there's no
reflection)
- Written in a functional style, so succinct, but complex for a first-timer
- Built in support for incomplete model objects


## Conclusion

- Can't get what I want yet
- Argo is the closest, and doesn't involve a huge amount of code
- However, it can be difficult to get your head around at first
- With reflection, the `decode` method in Argo could be replaced with a default,
which would get exactly what I want


