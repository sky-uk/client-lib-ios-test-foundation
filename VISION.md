## ReactiveAPI Vision

### Goals
- Defines a domain specific language (DSL) for testing, available for different platforms (like iOS and Android).
- Write a test once and run it on different platforms
- Facilitate the adoption of a Test Driven Development approach 

### Scope
#### Things we will not support:
- Wrappers or adapters to/from other networking stacks on iOS (e.g. Alamofire)
- Anything which is not an open and standardized network protocol
- Objective-C compatibility. We moved away from that language and we prefer pure idiomatic Swift

You can, of course, implement anything you want on top of this library on your own and maintain it, but we are not going to include it if it's something specific to a single use-case. We prefer snippets and posts on StackOverflow for that specific scenarios.

### Technical Considerations
- **iOS version**:
We support iOS 10.3+ and we are going to move forward at the same pace as Apple does, closing support for iOS versions which falls behind, to keep maintenance effort at minimum.

- **Backports**:
We will not make new features available on older versions of this library. Only the latest will have all the features.
