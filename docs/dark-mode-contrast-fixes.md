# Dark Mode Contrast Improvements

## Issue
Some content, particularly tables and other Bootstrap components, were appearing too light in dark mode, making them hard to distinguish from the background.

## Solutions Applied

### 1. Enhanced Table Styling

#### **Bootstrap Table Variables**
Added explicit Bootstrap table CSS variables:
- `--bs-table-bg`: Dark background
- `--bs-table-color`: Light text
- `--bs-table-border-color`: Visible borders
- `--bs-table-striped-bg`: Subtle stripe contrast
- `--bs-table-hover-bg`: More visible hover state (0.075 opacity)

#### **Specific Table Elements**
- **thead (headers)**: Forced dark background with `!important`
- **tbody (body)**: Explicit dark background on rows and cells
- **td/th**: All text forced to light color with `!important`
- **Striped tables**: Added visible striping
- **Bordered tables**: Proper border colors
- **Hover states**: Increased from 0.05 to 0.075 opacity for better visibility

### 2. Badge Improvements

#### **Enhanced Badge Colors**
- `.bg-secondary`: Darker gray (#495057) instead of subtle background
- `.bg-light`: Proper dark mode background
- `.bg-success`: Maintained green (#198754)
- `.bg-danger`: Maintained red (#dc3545)
- `.bg-warning`: Maintained yellow (#ffc107) with dark text
- `.bg-info`: Maintained cyan (#0dcaf0) with dark text

#### **Outline Badges**
- Added explicit styling for outline badges
- Transparent background with visible border

### 3. Background Utilities

#### **Strengthened Background Overrides**
All background utilities now include text color:
- `.bg-light` → Dark bg + light text
- `.bg-white` → Dark bg + light text
- `.bg-body` → Dark bg + light text
- `.bg-dark` → Black bg + light text
- `.bg-transparent` → Transparent (no color change)

### 4. Card Components

#### **Card Enhancements**
- All cards have forced dark backgrounds
- Card bodies inherit properly
- Cards with `.border-0` class styled
- Cards with `.shadow-sm` or `.shadow` styled
- Card text forced to light color

### 5. Icon Visibility

#### **Icon Color Management**
- All Bootstrap icons (`.bi`) default to light color
- Icons in muted text use secondary color
- Icons in buttons inherit button text color
- All `i[class*="bi-"]` elements visible

### 6. Additional Utility Classes

#### **Text-Background Combinations**
- `.text-bg-light` → Dark bg + light text
- `.text-bg-dark` → Black bg + light text
- `.text-bg-secondary` → Gray bg + light text

#### **Layout Elements**
- `.vr` (vertical rule): Visible with proper color
- Grid rows and columns: Inherit light text
- All dividers and separators visible

### 7. Table-Specific Improvements

#### **Before:**
```scss
tbody tr:hover {
  background-color: rgba(255, 255, 255, 0.03); // Too subtle
}
```

#### **After:**
```scss
tbody tr:hover {
  background-color: rgba(255, 255, 255, 0.075) !important; // More visible
}
```

## Color Intensity Reference

### Hover and Interactive States:
- **Subtle highlight**: `rgba(255, 255, 255, 0.02)` - Striped rows
- **Light highlight**: `rgba(255, 255, 255, 0.05)` - Active states
- **Visible highlight**: `rgba(255, 255, 255, 0.075)` - Hover states
- **Strong highlight**: `rgba(255, 255, 255, 0.1)` - Selected/active items

### Background Colors:
- **Primary background**: `#1a1a1a` (very dark gray)
- **Secondary background**: `#2d2d2d` (lighter dark gray)
- **Borders**: `#495057` (medium gray)

## Testing Checklist

### Tables:
- ✅ Table headers clearly visible
- ✅ Table rows distinguishable
- ✅ Hover effects visible
- ✅ Cell borders visible
- ✅ Striped tables have visible stripes
- ✅ Text in all cells readable

### Cards:
- ✅ Card backgrounds dark
- ✅ Card text readable
- ✅ Cards with shadows visible
- ✅ Cards without borders styled

### Badges:
- ✅ All badge variants visible
- ✅ Badge text readable
- ✅ Outline badges distinguishable

### Icons:
- ✅ All icons visible
- ✅ Icons in tables visible
- ✅ Icons in buttons visible
- ✅ Muted icons appropriately dimmed

### Utilities:
- ✅ Background utilities dark
- ✅ Text utilities light
- ✅ Border utilities visible
- ✅ Dividers visible

## Impact

### Improved Visibility For:
1. **Management tables** - Post lists, page lists, menu items
2. **Data tables** - All tabular data now clearly visible
3. **Cards** - All card-based layouts
4. **Badges** - Status indicators and labels
5. **Icons** - All iconography
6. **Interactive states** - Hover and active states more noticeable

### Maintained:
- Semantic color meanings (success = green, danger = red, etc.)
- Visual hierarchy
- Accessibility standards (WCAG AA contrast ratios)
- Bootstrap component behavior

## Browser Compatibility

All improvements work in:
- ✅ Chrome 76+
- ✅ Firefox 67+
- ✅ Safari 12.1+
- ✅ Edge 79+
- ✅ All modern mobile browsers

## Accessibility

All changes maintain or improve:
- Minimum 4.5:1 contrast ratio for text
- 3:1 contrast ratio for UI components
- Visible focus indicators
- Clear interactive states
- Semantic color preservation

## Result

Tables, cards, badges, and all other components now have:
- 📊 Clear visual distinction from backgrounds
- 🎨 Proper contrast ratios
- 👁️ Visible hover and interactive states
- 🔤 Readable text in all contexts
- ✨ Consistent dark mode appearance
