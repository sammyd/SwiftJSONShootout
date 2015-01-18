# Swift JSON Shoot-Out

## Introduction

- Enormous amount been written on this topic, but some of us don't want to
understand all the theory.
- This is a pragmatic review of the current offering in Swift
- All use the JSONSerializer to convert the raw json string into a tree of Cocoa
objects
- How do we interpret the resulting blob - given that all we know is that we are
given an `AnyObject`?


### Wishlist

- Have model objects inside our app
- These should be used to represent the incoming JSON stream
- Should operate in a type-safe manner
- Don't want partially formed model objects

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


