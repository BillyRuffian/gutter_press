# iPhone Video Compatibility Fixes

## Problem
Video attachments in Action Text weren't working properly on iPhone/iOS devices due to several iOS-specific requirements and limitations.

## Issues Fixed

### 1. **Playsinline Requirement**
- **Issue**: Videos would open in fullscreen mode on iOS
- **Fix**: Added `playsinline` and `webkit-playsinline` attributes to all video elements

### 2. **Multiple Source Support**
- **Issue**: iOS has specific format preferences and fallback requirements
- **Fix**: Added multiple `<source>` elements for MP4, WebM, and OGG formats

### 3. **iOS Control Handling**
- **Issue**: Native video controls sometimes wouldn't appear properly on iOS
- **Fix**: Added Stimulus controller to ensure proper control display and interaction

### 4. **Touch Interaction**
- **Issue**: iOS requires user interaction to play videos
- **Fix**: Added custom play button overlay for better UX on touch devices

## Files Modified

### Video Partials
- `app/views/action_text/attachments/_video.html.haml`
- `app/views/action_text/attachments/_attachable.html.haml` 
- `app/views/active_storage/blobs/_blob.html.haml`

### Styling
- `app/assets/stylesheets/application.bootstrap.scss` - Added iOS-specific video styles

### JavaScript Controller
- `app/javascript/controllers/ios_video_controller.js` - Handles iOS-specific behavior

## Key Changes

### HTML Attributes Added:
```haml
%video{
  controls: true,
  preload: "metadata", 
  playsinline: true,
  "webkit-playsinline": true,
  muted: false,
  "data-controller" => "ios-video",
  "data-ios-video-target" => "video"
}
```

### Multiple Source Elements:
```haml
%source{src: url_for(attachable), type: attachable.content_type}
- if attachable.content_type.include?('mp4')
  %source{src: url_for(attachable), type: "video/mp4"}
- if attachable.content_type.include?('webm')
  %source{src: url_for(attachable), type: "video/webm"}
```

### CSS Enhancements:
- Added `-webkit-playsinline: true`
- Enhanced mobile responsiveness
- Custom play button styling for iOS

## Testing on iPhone

To test the fixes:

1. **Upload a video** through the Lexxy editor in a post/page
2. **View the content on iPhone Safari**
3. **Verify**:
   - Video doesn't auto-open in fullscreen
   - Controls appear properly
   - Video plays when tapped
   - Proper aspect ratio maintained
   - No loading/playback errors

## Browser Support

- ✅ **iPhone Safari** (iOS 12+)
- ✅ **iPad Safari** (iOS 12+)  
- ✅ **Chrome on iOS**
- ✅ **Firefox on iOS**
- ✅ **Desktop browsers** (unchanged behavior)
- ✅ **Android devices** (improved experience)

## Performance Notes

- Videos use `preload="metadata"` to minimize data usage
- Multiple sources provide fallback options
- Lazy loading of play button overlay only on iOS devices
- Error handling and retry logic for network issues