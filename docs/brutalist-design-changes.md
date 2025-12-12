# Brutalist Design System - Implementation Guide

## Overview

This document outlines the brutalist/retro design changes implemented across the portfolio site. The design emphasizes bold black lines, an eggwhite background, sharp edges, and high contrast for a distinctive aesthetic.

## Color Palette

### Primary Colors
- **Eggwhite**: `#faf8f3` - Main background color
- **Eggwhite Dark**: `#f5f2e9` - Secondary background for contrast
- **Black**: `#000000` - Text, borders, and accents

### Usage
- Text: Pure black (`#000000`) for maximum readability
- Backgrounds: Eggwhite tones for warmth without harshness
- Borders: Bold black borders (2-4px) for structure

## Design Principles

### 1. Bold Borders
- **Standard**: `2px solid #000000` - All borders use 2px width for consistency
- Maximum border width is 2px throughout the design system

### 2. No Rounded Corners
- Removed all `rounded-*` classes
- Sharp, geometric edges throughout
- Creates a more architectural feel

### 3. No Soft Shadows
- Eliminated `shadow-*` utilities
- Removed gradient backgrounds
- Flat design with no depth illusions

### 4. High Contrast Typography
- Pure black text on eggwhite backgrounds
- Bold font weights (`font-bold`, `font-semibold`)
- Underlines for links instead of color changes

### 5. Simple Hover States
- Background color shifts (eggwhite → eggwhite-dark)
- Inverted colors (black bg with white text)
- Underlines for text links
- No smooth transitions or animations

## Component Changes

### Sidebar
- **Border**: Changed from `border-r border-gray-200` to `border-r-2 border-black`
- **Background**: Changed from `bg-white` to `bg-eggwhite`
- **Icons**: Active state uses black background with eggwhite text
- **Profile Card**: Sharp edges with `border-2 border-black`
- **Avatar**: Black square with white text (removed gradient)

### Navigation Bar
- **Background**: From `bg-white/80 backdrop-blur-md` to solid `bg-eggwhite`
- **Border**: From `border-b border-gray-200` to `border-b-2 border-black`
- **Links**: Black text with underline on hover/active states
- **Mobile Menu**: Uses `bg-eggwhite-dark` for distinction

### Content Cards
- **Borders**: From `border border-gray-200 rounded-xl` to `border-2 border-black`
- **Hover**: From `hover:shadow-lg` to `hover:bg-eggwhite-dark`
- **Background**: Eggwhite for cards, creating subtle contrast

### Buttons
- **Primary**: Black background, eggwhite text, `border-2 border-black`
- **Secondary**: Eggwhite background, black text, `border-2 border-black`
- **Hover**: Background inversion (black ↔ eggwhite)

### Typography
- **Headings**: Pure black (`text-black`), bold weights
- **Body Text**: Black instead of gray variations
- **Links**: Black with underline on hover
- **Active States**: Font-bold + underline

## Tailwind Utilities Added

### Custom Classes
```css
.bg-eggwhite          /* Main background color */
.bg-eggwhite-dark     /* Darker variant for contrast */
.focus-brutalist       /* 3px black focus outline */
```

### Utility Shortcuts
- `border-2` - 2px border (standard weight for all borders)
- `border-t-2`, `border-b-2`, `border-l-2`, `border-r-2` - Directional borders

## Files Modified

### CSS Configuration
- `app/assets/tailwind/application.css` - Added custom theme and utilities

### Layout Files
- `app/views/layouts/application.html.erb` - Updated navigation, footer, flash messages

### Partial Views
- `app/views/shared/_sidebar.html.erb` - Brutalist styling for sidebar and profile card

### Page Views
- `app/views/home/index.html.erb` - Homepage content cards and sections

## Before & After Comparison

### Before (Soft Modern)
- White backgrounds with subtle gray borders
- Rounded corners (rounded-xl, rounded-lg)
- Soft shadows and gradients
- Gray text hierarchy
- Smooth transitions
- Backdrop blur effects

### After (Brutalist)
- Eggwhite backgrounds with bold black borders
- Sharp geometric edges
- Flat, high-contrast design
- Pure black text
- Direct hover states
- Solid colors only

## Design Benefits

### Readability
- High contrast ensures excellent legibility
- Bold typography stands out
- Clear visual hierarchy

### Performance
- No backdrop filters or blur effects
- Fewer CSS transitions
- Simpler rendering

### Aesthetic
- Distinctive, memorable design
- Retro/brutalist appeal
- Architectural and structured feel
- Timeless style that won't feel dated

## Future Enhancements

### Potential Additions
- [ ] ASCII art decorations
- [ ] Dot matrix-style headings
- [ ] Terminal-inspired typography
- [ ] Brutalist form inputs
- [ ] Black-and-white image filters
- [ ] Grid-based layouts with thick dividers

### Considerations
- Maintain accessibility (WCAG AAA contrast ratio already met)
- Keep loading times fast
- Ensure mobile responsiveness
- Test with different font families (monospace could enhance brutalist feel)

## Maintenance Notes

When adding new components:
1. Use `bg-eggwhite` or `bg-eggwhite-dark` for backgrounds
2. Apply `border-2 border-black` for all borders (2px max)
3. Use `text-black` for all text
4. Use `font-bold` or `font-semibold` for emphasis
5. Avoid rounded corners, shadows, and gradients
6. Prefer underlines for link hover states
7. Keep hover states simple (bg color changes or inversions)

## Accessibility

The brutalist design maintains excellent accessibility:
- **Contrast Ratio**: Black on eggwhite exceeds WCAG AAA standards (>7:1)
- **Focus States**: Bold 2px black outlines clearly indicate focus
- **Typography**: Large, bold text improves readability
- **No Reliance on Color**: Structure uses borders and weight, not just color

## Resources

- [Brutalist Web Design](https://brutalistwebsites.com/)
- [Neobrutalism in Web Design](https://hype4.academy/articles/design/neobrutalism-design-trend)
- [Swiss Design Principles](https://www.smashingmagazine.com/2009/07/lessons-from-swiss-style-graphic-design/)
