import AppKit

func wheel(_ units: CGScrollEventUnit, y: Int32, x: Int32) -> CGEvent {
    CGEvent(scrollWheelEvent2Source: nil, units: units, wheelCount: 2, wheel1: y, wheel2: x, wheel3: 0)!
}

func values(_ e: CGEvent, _ axis: (CGEventField, CGEventField, CGEventField)) -> [Double] {
    [Double(e.getIntegerValueField(axis.0)), e.getDoubleValueField(axis.1), Double(e.getIntegerValueField(axis.2))]
}

let vertical = (CGEventField.scrollWheelEventDeltaAxis1, CGEventField.scrollWheelEventFixedPtDeltaAxis1, CGEventField.scrollWheelEventPointDeltaAxis1)
let horizontal = (CGEventField.scrollWheelEventDeltaAxis2, CGEventField.scrollWheelEventFixedPtDeltaAxis2, CGEventField.scrollWheelEventPointDeltaAxis2)

// A wheel event flips the vertical axis at exactly the same speed and keeps the horizontal axis.
let mouse = wheel(.line, y: -3, x: 2)
let beforeY = values(mouse, vertical), beforeX = values(mouse, horizontal)
assert(beforeY.allSatisfy { $0 != 0 })
assert(flipMouseScroll(mouse, vertical: true, horizontal: false))
assert(values(mouse, vertical) == beforeY.map { -$0 }, "\(values(mouse, vertical)) vs \(beforeY)")
assert(values(mouse, horizontal) == beforeX)

// Apps read the flipped value through NSEvent.
let appView = NSEvent(cgEvent: mouse)!
assert(appView.scrollingDeltaY == 3)

// The horizontal option flips only the horizontal axis.
let side = wheel(.line, y: -3, x: 2)
let sideY = values(side, vertical), sideX = values(side, horizontal)
flipMouseScroll(side, vertical: false, horizontal: true)
assert(values(side, vertical) == sideY)
assert(values(side, horizontal) == sideX.map { -$0 })

// A continuous (trackpad) event is not changed.
let trackpad = wheel(.pixel, y: -30, x: 4)
let padY = values(trackpad, vertical), padX = values(trackpad, horizontal)
assert(!flipMouseScroll(trackpad, vertical: true, horizontal: true))
assert(values(trackpad, vertical) == padY)
assert(values(trackpad, horizontal) == padX)

print("all checks passed")
