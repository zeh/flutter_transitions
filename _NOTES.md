Trying to get it to save images of a screen when navigating, so we can have DOOM-like screen transitions.

Currently there's two avenues of investigation:

# Using a RepaintBoundary() and then doing toImage()

This might work, but it's sort of shitty as it requires wrapping the child in RepaintBoundary() when doing the transition, rather than just the CustomTransition().

So for now tabling this.

# Using context.pushEtc()

We draw everything the same way the fade transition renderer does. Trying to do this now.

---

Another potential solution is just capturing the damn widget into a canvas without RepaintBoundary(), but it's not clear whether that is possible.

On either case, we still need to solve for the animation. We're capturing the _NEW_ screen, not the old one. If we want DOOM-like transitions - where the old screen dissolves and reveals the new one behind it - we want to capture the old screen instead.

One thing at a time.
