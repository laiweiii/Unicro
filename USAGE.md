# Unicro Usage

Unicro is a microinteraction layer for existing SwiftUI views.

It does not generate business screens.
It helps you take an existing source view and attach a consistent interaction flow to it:

`intent -> resolver -> recipe -> transformer host -> motion / presentation`

## What To Use

For the current architecture, the main entry point is:

- [`IKTransformerHost.swift`](/Users/laiwei/Documents/hustle/Unicro/Unicro/Sources/Unicro/InteractionKit/Core/IKTransformerHost.swift)

The supporting core files are:

- [`IKIntent.swift`](/Users/laiwei/Documents/hustle/Unicro/Unicro/Sources/Unicro/InteractionKit/Core/IKIntent.swift)
- [`IKResolver.swift`](/Users/laiwei/Documents/hustle/Unicro/Unicro/Sources/Unicro/InteractionKit/Core/IKResolver.swift)
- [`IKRuleEngine.swift`](/Users/laiwei/Documents/hustle/Unicro/Unicro/Sources/Unicro/InteractionKit/Core/IKRuleEngine.swift)
- [`IKTransformerMapping.swift`](/Users/laiwei/Documents/hustle/Unicro/Unicro/Sources/Unicro/InteractionKit/Core/IKTransformerMapping.swift)
- [`IKTransformerMotion.swift`](/Users/laiwei/Documents/hustle/Unicro/Unicro/Sources/Unicro/InteractionKit/Core/IKTransformerMotion.swift)
- [`IKInteractionExecutor.swift`](/Users/laiwei/Documents/hustle/Unicro/Unicro/Sources/Unicro/InteractionKit/Core/IKInteractionExecutor.swift)

## Mental Model

You provide:

- a source view
- a destination view
- an `IKIntent`

Unicro provides:

- a resolved interaction recipe
- a transformer choice
- presentation behavior
- motion and trigger wiring
- dismiss handling for the supported transformer

In other words, product code should mostly describe:

- what the source view wants to do
- what content should appear next

Unicro should handle:

- trigger
- backdrop
- dismiss flow
- motion / presentation

## Standard Flow

The normal setup is:

1. Create an `IKIntent`
2. Resolve it with `IKResolver`
3. Pass the resulting `recipe` into `IKTransformerHost`
4. Provide a source view and a destination view

Minimal setup:

```swift
let intent = IKIntent(
    goal: .inspect,
    entity: IKTransformerMapping.item,
    stage: .discovery,
    context: .init(
        capability: .browse(.read)
    )
)

let resolved = IKResolver().resolve(intent)
```

Then:

```swift
IKTransformerHost(recipe: resolved.recipe) {
    SourceView()
} destination: { dismiss in
    DestinationView()
}
```

## The Main API

`IKTransformerHost` is the current recommended integration point.

It owns the interaction flow for the supported transformers:

- open
- dismiss
- backdrop
- outside tap dismissal
- motion / presentation wiring

This means product code should no longer manually manage:

- `isPresented`
- `sheetPosition`
- backdrop visibility
- outside tap dismiss

## anchoredPopup

Use `anchoredPopup` when a small source view should expand into a focused detail view.

Typical cases:

- map marker -> popup card
- compact item -> contextual detail
- tile -> expanded focus panel

### Example

```swift
import SwiftUI
import Unicro

struct AnchoredPopupExample: View {
    private let resolver = IKResolver()

    private var resolved: IKResolvedInteraction {
        resolver.resolve(
            IKIntent(
                goal: .inspect,
                entity: IKTransformerMapping.item,
                stage: .discovery,
                context: .init(
                    capability: .browse(.read)
                )
            )
        )
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            IKTransformerHost(
                recipe: resolved.recipe,
                sourceUnitPoint: UnitPoint(x: 0.5, y: 0.82)
            ) {
                Circle()
                    .fill(.blue)
                    .frame(width: 44, height: 44)
                    .padding(.bottom, 120)
            } destination: { dismiss in
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white)
                    .frame(height: 300)
                    .overlay {
                        VStack(spacing: 16) {
                            Text("Anchored Popup")
                                .font(.title3.bold())

                            Button("Close") {
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
            }
        }
    }
}
```

### Notes

- `sourceUnitPoint` defines where the motion should originate.
- For marker-like interactions, pass the marker location instead of defaulting to the container bottom.
- `anchoredPopup` currently uses Unicro's custom motion path.

## bottomReveal

Use `bottomReveal` when a source view should open a sheet-like detail panel.

Typical cases:

- marker -> detail sheet
- row -> action sheet
- item -> task-oriented bottom presentation

### Example

```swift
import SwiftUI
import Unicro

struct BottomRevealExample: View {
    private let resolver = IKResolver()

    private var resolved: IKResolvedInteraction {
        resolver.resolve(
            IKIntent(
                goal: .manage,
                entity: IKTransformerMapping.item,
                stage: .execution,
                context: .init(
                    isAsync: true,
                    capability: .task(.manage)
                )
            )
        )
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            IKTransformerHost(recipe: resolved.recipe) {
                Circle()
                    .fill(.teal)
                    .frame(width: 44, height: 44)
                    .padding(.bottom, 120)
            } destination: { dismiss in
                VStack(spacing: 20) {
                    Text("Bottom Reveal")
                        .font(.title3.bold())

                    Button("Close") {
                        dismiss()
                    }
                }
                .padding()
            }
        }
    }
}
```

### Current Behavior

At the moment:

- `anchoredPopup`
  uses custom Unicro motion

- `bottomReveal`
  defaults to the system iOS `sheet` presentation inside `IKTransformerHost`

This is intentional.
It keeps the complete interaction flow stable while the custom bottom-reveal runtime is still evolving.

## Intent Guidelines

For the current motion-first core, `domain` is optional metadata.

The most important fields are:

- `goal`
- `entity`
- `stage`
- `context.capability`

Current built-in mappings are:

- `inspect + item + discovery`
  -> `anchoredPopup`

- `manage + item + execution`
  -> `bottomReveal`

Those rules live in:

- [`IKTransformerMapping.swift`](/Users/laiwei/Documents/hustle/Unicro/Unicro/Sources/Unicro/InteractionKit/Core/IKTransformerMapping.swift)

## Motion Principles

In Unicro, motion should only define transition flow.

Motion should control:

- scale progression
- offset progression
- spring timing
- reveal / settle behavior

Motion should not own:

- colors
- corner radius
- shadows
- handle visuals
- content styling

Those belong to the destination view.

## Example Domain Mappings

The repo still includes:

- [`TrafficVocabulary.swift`](/Users/laiwei/Documents/hustle/Unicro/Unicro/Sources/Unicro/InteractionKit/Domain/Traffic/TrafficVocabulary.swift)
- [`TrafficIntentMapping.swift`](/Users/laiwei/Documents/hustle/Unicro/Unicro/Sources/Unicro/InteractionKit/Domain/Traffic/TrafficIntentMapping.swift)

These are examples only.
They are not part of the required core motion path.

## Demo References

Live examples:

- [`ContentView.swift`](/Users/laiwei/Documents/hustle/Unicro/DemoApp/DemoApp/DemoApp/ContentView.swift)
- [`SimpleView.swift`](/Users/laiwei/Documents/hustle/Unicro/DemoApp/DemoApp/DemoApp/SimpleView.swift)

They show:

- one source marker
- switching between `anchoredPopup` and `bottomReveal`
- using `IKTransformerHost`
- moving dismiss and backdrop behavior out of product code
