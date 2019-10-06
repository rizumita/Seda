# Seda

[![Build Status](https://app.bitrise.io/app/c10514b3be4f952b/status.svg?token=mngDdqip-JSy0fpv74BRsw)](https://app.bitrise.io/app/c10514b3be4f952b)

Seda is a Redux + Command architecture framework for SwiftUI and UIKit.

## Architecture

Seda's architecture is a composite of the Redux and the Command.

![Architecture](https://github.com/rizumita/Seda/blob/images/Images/Seda's%20Architecture%20Pattern.png?raw=true)

In general, Redux's reducer returns only a state. But Seda's reducer returns the state and the 'Command' as follows.

```
func reducer() -> Reducer<AppState> {
    return { action, state in
        var state = state
        var command = Command.none
        ...
        switch action {
        case Foo.asyncAction:
            command = Command.ofAsyncAction { fullfill in
                asyncFunc { value in fulfill(Foo.updateValue(value)) }
            }
        case Foo.updateValue(let value):
            state.value = value
        ...
        }
        ...
        return (state, command)
    }
}
```

The Command manages async and side effect tasks. The tasks wrapped by the command don't leak out to reducer that should be a pure function. Because of this, we become able to write async and side effect tasks in a reducer in safety.

## Install

### Swift Package Manager

On Xcode, select 'File' menu -> 'Swift Packages' -> 'Add Package Dependency...'.
