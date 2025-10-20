# Dark Mode Text Visibility Fixes

## Problem
Some text was appearing as dark text on dark backgrounds in dark mode, making it unreadable. This was caused by Bootstrap utility classes like `.text-dark` being hardcoded in the HAML templates.

## Solution
Instead of modifying all the HAML templates (which would be tedious and error-prone), we override the Bootstrap utility classes in CSS specifically for dark mode.

## CSS Overrides Applied

### 1. Text Color Utilities
```scss
.text-dark { color: var(--text-primary) !important; }      // Light color in dark mode
.text-body { color: var(--text-primary) !important; }      // Light color in dark mode
.text-black { color: var(--text-primary) !important; }     // Light color in dark mode
.text-secondary { color: var(--text-secondary) !important; } // Muted light color
.text-muted { color: var(--text-secondary) !important; }   // Readable muted color
```

### 2. Background Utilities
```scss
.bg-light { background-color: var(--bg-secondary) !important; }  // Dark gray
.bg-white { background-color: var(--bg-primary) !important; }    // Dark background
.bg-body { background-color: var(--bg-primary) !important; }     // Dark background
```

### 3. Content Elements
- All headings (h1-h6) now use `var(--text-primary)` 
- Paragraphs inherit proper light text color
- Articles and post content have light text
- Links maintain distinct blue colors for dark mode

### 4. Bootstrap Components
- **Pagination**: Dark backgrounds with light text and proper hover states
- **Dropdowns**: Dark backgrounds with light text
- **Cards**: Dark backgrounds with light text and borders
- **Badges**: Proper contrast in dark mode
- **List groups**: Dark backgrounds with light text

### 5. Special Link Handling
Links with `.text-dark` class now:
- Display in light text color (not dark)
- Show link color on hover for better UX
- Maintain proper contrast

## Color Variables Used

**Dark Mode Colors:**
- `--text-primary`: `#e9ecef` (light gray for main text)
- `--text-secondary`: `#adb5bd` (muted light gray for secondary text)
- `--text-muted`: `#6c757d` (dimmer gray for less important text)
- `--bg-primary`: `#1a1a1a` (very dark gray, almost black)
- `--bg-secondary`: `#2d2d2d` (lighter dark gray for cards/panels)
- `--link-color`: `#6ea8fe` (light blue for links)
- `--link-hover-color`: `#9ec5fe` (lighter blue for hover)

## Testing Checklist

✅ Post titles on index page  
✅ Post content text  
✅ Post metadata (dates, authors)  
✅ Navigation links  
✅ Footer text  
✅ Headings (h1-h6)  
✅ Paragraphs and body text  
✅ Links (normal and with text-dark class)  
✅ Code blocks  
✅ Pagination controls  
✅ Buttons and forms  
✅ Alerts and notifications  

## Result

All text is now properly visible in dark mode with good contrast ratios, while maintaining the automatic system preference detection. No template changes were required - everything is handled through CSS overrides.
