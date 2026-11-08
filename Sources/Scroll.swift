import CoreGraphics

/// Reverses the chosen axes of a mouse-wheel event. Returns false and leaves the event alone for trackpads.
@discardableResult
func flipMouseScroll(_ event: CGEvent, vertical: Bool, horizontal: Bool) -> Bool {
    // Wheels send line-based events. Trackpads and the Magic Mouse send continuous ones.
    guard event.getIntegerValueField(.scrollWheelEventIsContinuous) == 0 else { return false }
    if vertical {
        flip(event, .scrollWheelEventDeltaAxis1, .scrollWheelEventFixedPtDeltaAxis1, .scrollWheelEventPointDeltaAxis1)
    }
    if horizontal {
        flip(event, .scrollWheelEventDeltaAxis2, .scrollWheelEventFixedPtDeltaAxis2, .scrollWheelEventPointDeltaAxis2)
    }
    return true
}

private func flip(_ event: CGEvent, _ delta: CGEventField, _ fixed: CGEventField, _ point: CGEventField) {
    // Read all three first: writing delta makes CoreGraphics recompute the others at a different speed.
    let d = event.getIntegerValueField(delta)
    let f = event.getDoubleValueField(fixed)
    let p = event.getIntegerValueField(point)
    event.setIntegerValueField(delta, value: -d)
    event.setDoubleValueField(fixed, value: -f)
    event.setIntegerValueField(point, value: -p)
}
