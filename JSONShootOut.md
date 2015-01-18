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

- C# offers a dynamic object approach. This is a small extension compared to the
existing JSON serializer, and doesn't help a lot
- Alternatively, via annotations and reflection, C# can take a JSON string and
return the appropriate model object structure.
- Ideally we want the latter of these two approaches, but can't achieve it
without reflection. How close can we get to it?

### Accompanying Project

- A workspace containing multiple playgrounds - each demonstrating a different
part of this article
- Two of the playgrounds rely on 3rd party dependencies, which are referenced
using Carthage. These should be checked into the repo, so you shouldn't need to
fiddle with Carthage to get it to work
- The dependencies will need to be built tho. Select each OSX scheme in turn,
and build it.

## Naïve Parsing

- First approach looks at how to deal with the raw JSON structure. 
- Can use `valueForKeyPath`
- Not very safe
- Involves lots of optional nesting
- Alternatively, can cast the Cocoa objects to their Swift counterparts and
extract data that way.
- Marginally safer
- Still a huge optional nesting tree

## SwiftyJSON

- Open source library to assist with parsing of JSON
- Under the hood it involves specification of a JSON enum as a type to represent
the JSON structure
- Also got lots of implicit type conversions to simplify optional chaining
- In our required situation, still ends up with a tree of optionals to ensure
model object is completely formed
- Good for extracting specific values from a JSON structure

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


