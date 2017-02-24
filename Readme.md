### Extensible Deep Link Router

A handler for deep/universal links that can match URLs to their corresponding actions in the app. The goals were to make something that was very clear at call site, wasn’t a singleton that required registering routes at runtime, and did not require changing a giant switch statement every time a new route was added. The basic structure is such that `Action`s are units of work that can optionally be made `Routable`. A `Routable` action provides a URI template to match and extract params out of.
Callsite just looks like `Action.from(url)`. It iterates over all the actions and finds the first one that can be initialized from the passed URL.
Something I do not like is that `Action` struct maintains an array `allRoutableActions` and one has to remember to add any new actions to that array. Maybe Sourcery can help there.


#### Running the playground

1. Open `URITemplate.xcworkspace` in Xcode > 8.0.
2. Build `UITemplatePlaygroundScheme`.
3. Open `URITemplate.playground` in the workspace.