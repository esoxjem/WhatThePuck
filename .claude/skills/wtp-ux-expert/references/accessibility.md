# iOS Accessibility Guidelines

## VoiceOver Support

### Labels & Hints
- Every interactive element needs an accessibility label
- Labels: What the element *is* ("Shot rating, 4 stars")
- Hints: What it *does* ("Double tap to edit rating")
- Avoid redundancy: don't say "button" in label (VoiceOver adds it)

### Traits
- `.button`, `.link`, `.header`, `.image`, etc.
- `.adjustable` for sliders, steppers
- `.updatesFrequently` for live data

### Grouping
- Group related elements into single accessibility element
- Example: Shot card → single element with combined label
- Reduces swipe count, improves comprehension

### Custom Actions
- Provide accessible alternatives for gestures
- swipe actions → custom accessibility actions
- long press menus → accessible actions

### Reading Order
- Ensure logical reading order
- Override if needed with `accessibilityElements` array
- Test by swiping through entire screen

## Dynamic Type

### Implementation
- Use `.font(.body)` style semantic fonts, not fixed sizes
- Support up to AX5 (largest size)
- Test at all sizes, especially largest

### Layout Adaptation
- Layouts must reflow at large sizes
- Horizontal stacks may need to become vertical
- Truncation only as last resort

### Minimum Sizes
- Never go below 11pt equivalent
- Critical UI (buttons, labels) always readable

## Color & Contrast

### Contrast Ratios (WCAG AA)
- Body text: 4.5:1 minimum
- Large text (18pt+): 3:1 minimum
- UI components: 3:1 minimum

### Color Independence
- Never use color alone to convey information
- Pair color with icons, patterns, or text
- Example: Bad shot = red + icon + "Sour" label

### Dark Mode
- Full Dark Mode support
- Test contrast in both modes
- Use semantic colors (`.label`, `.secondaryLabel`)

## Motor Accessibility

### Touch Targets
- 44×44 pt minimum (Apple requirement)
- More generous for frequent/important actions
- Sufficient spacing to prevent mistaps

### Reduce Motion
- Check `UIAccessibility.isReduceMotionEnabled`
- Simplify or remove animations
- No autoplaying animations

### Alternative Input
- Support keyboard navigation (external keyboards)
- Switch Control compatibility
- Voice Control labels

## Cognitive Accessibility

### Clarity
- Clear, simple language
- Consistent terminology throughout
- Explain domain terms on first use

### Error Prevention
- Confirmation for destructive actions
- Undo when possible
- Clear error messages with recovery steps

### Predictability
- Consistent navigation patterns
- No unexpected context changes
- Stable layout (elements don't move)

## WCAG 2.1 Quick Reference

### Perceivable
- 1.1.1: Text alternatives for images
- 1.3.1: Info and relationships (semantic structure)
- 1.4.1: Use of color (not sole indicator)
- 1.4.3: Contrast minimum (4.5:1)
- 1.4.4: Resize text (200% without loss)

### Operable
- 2.1.1: Keyboard accessible
- 2.4.3: Focus order (logical sequence)
- 2.4.6: Headings and labels (descriptive)
- 2.5.5: Target size (44×44 pt)

### Understandable
- 3.1.2: Language of parts (if multilingual)
- 3.2.3: Consistent navigation
- 3.3.1: Error identification (clear messaging)
- 3.3.2: Labels or instructions (form guidance)

### Robust
- 4.1.2: Name, role, value (accessibility labels)

## WTP-Specific Accessibility

### Shot Entry
- VoiceOver: Announce current field, valid range
- Large targets for numeric keypad
- Clear feedback when value entered

### Charts & Visualizations
- Provide text summary of trends
- Data table alternative for screen readers
- Describe axes and data points

### Grind Setting
- If using custom control, ensure `.adjustable` trait
- Announce current value and direction on change
- Consider numeric input alternative

### Timer
- If auto-timing shots, provide audio/haptic cues
- Announce time periodically for VoiceOver users
- Stop accessible via voice/switch

## Testing Checklist

### Manual Testing
- [ ] VoiceOver: Navigate entire app by swiping
- [ ] VoiceOver: Activate all controls
- [ ] Dynamic Type: Test at largest sizes
- [ ] Dark Mode: Full pass through all screens
- [ ] Reduce Motion: Verify animations respect setting
- [ ] Color only: Check all status indicators

### Automated
- Xcode Accessibility Inspector
- XCUI accessibility audits
- Contrast checking tools

### User Testing
- Include users with disabilities in testing
- Gather feedback on real-world usage
- Iterate based on actual barriers discovered
