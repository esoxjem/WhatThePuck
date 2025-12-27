# iOS Human Interface Guidelines Checklist

## Navigation Patterns

### When to Use Each Pattern
- **Tab Bar**: 3-5 top-level destinations, frequent switching (WTP: Shots, Beans, Grinders, Settings)
- **Navigation Stack**: Hierarchical drill-down (WTP: Shot list → Shot detail → Edit)
- **Modal/Sheet**: Focused task, creation flows, interrupting context (WTP: New shot entry)
- **Sidebar**: iPad/Mac, many destinations, power users

### Navigation Anti-patterns
- ❌ More than 5 tabs
- ❌ Deep nesting (>3 levels feels lost)
- ❌ Modal for browsing content
- ❌ Hidden hamburger menus as primary nav

## Touch Targets & Gestures

### Minimum Sizes
- **Tap targets**: 44×44 pt minimum (Apple guideline)
- **Spacing**: 8pt minimum between tappable elements
- **Text buttons**: Generous padding, not just text bounds

### Standard Gestures
- **Tap**: Primary action
- **Long press**: Secondary actions, context menus
- **Swipe**: Delete, actions on list items
- **Pull to refresh**: Reload content
- **Pinch**: Zoom (if applicable)

### Gesture Considerations
- Don't override system gestures (edge swipes)
- Provide visible alternatives for gesture-only actions
- Gesture discovery is poor—don't hide critical actions behind gestures only

## Typography & Readability

### Dynamic Type
- Support all text sizes (accessibility requirement)
- Use semantic styles: `.title`, `.headline`, `.body`, `.caption`
- Test at largest accessibility sizes

### Hierarchy
- Clear visual hierarchy through size/weight
- Limit to 2-3 type sizes per screen
- Sufficient contrast (4.5:1 minimum for body text)

### Content
- Front-load important information
- Truncate gracefully with ellipsis
- Avoid ALL CAPS for long text

## Layout & Spacing

### Safe Areas
- Respect safe area insets (notch, home indicator)
- Content shouldn't be obscured by system UI

### Consistency
- Use 8pt grid for spacing
- Consistent margins and padding throughout
- Align elements on grid

### Responsive
- Support all iPhone sizes
- Consider iPad if applicable
- Adapt to landscape if supported

## System Integration

### iOS Features to Consider
- **Widgets**: At-a-glance info, quick actions
- **Shortcuts**: Automation, Siri integration
- **Spotlight**: Search indexing for shots/beans
- **Share Sheet**: Export data, share shots
- **Notifications**: Reminders, insights
- **Haptics**: Confirm actions, feedback

### System Conventions
- Use SF Symbols for icons (consistent, accessible)
- Support Dark Mode
- Respect Reduce Motion setting
- Use system colors where appropriate

## Forms & Input

### Text Entry
- Appropriate keyboard types (numeric for dose/yield)
- Input validation with inline feedback
- Clear error states and recovery

### Selection
- Pickers for constrained choices
- Segmented controls for 2-4 mutually exclusive options
- Toggle for binary on/off

### Smart Defaults
- Pre-fill with likely values
- Remember last-used values
- Reduce required fields to minimum

## Feedback & State

### Loading States
- Indicate progress for operations >1 second
- Skeleton screens > spinners for content loading
- Never leave user wondering if something is happening

### Empty States
- Helpful, not just "no data"
- Guide toward first action
- Maintain visual interest

### Error States
- Clear what went wrong
- Actionable: what to do next
- Don't blame the user

### Success Confirmation
- Acknowledge completed actions
- Subtle for minor actions (haptic, brief toast)
- Prominent for significant milestones

## Performance Perception

### Responsiveness
- Immediate visual feedback on tap (<100ms)
- Animations 60fps
- Avoid blocking UI thread

### Optimistic Updates
- Show expected result immediately
- Reconcile with server in background
- Handle conflicts gracefully

## WTP-Specific HIG Applications

### Shot Entry Modal
- Numeric keypad for dose/yield/time
- Large touch targets for quick entry
- Pre-filled with smart defaults
- Minimal required fields

### Shot List
- Swipe actions for quick operations
- Pull to refresh if syncing
- Clear visual distinction between good/bad shots

### Grinder Settings
- Custom picker or slider for grind setting
- Visual representation of coarse ↔ fine
- Per-grinder context always clear
