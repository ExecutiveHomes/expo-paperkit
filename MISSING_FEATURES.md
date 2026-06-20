# expo-paperkit — Missing PaperKit Features

Audit against [Apple PaperKit documentation](https://developer.apple.com/documentation/paperkit) (iOS/macOS 26+).

---

## 1. Selection API

| Method / Prop | Native API | Description |
|---|---|---|
| `getSelection()` | `vc.selectedMarkup` | Read the currently selected elements |
| `clearSelection()` | (set selection to empty) | Programmatically deselect all |

**Effort:** Low — read-only access + one imperative method.

---

## 2. Scroll & Zoom Control

| Method / Prop | Native API | Description |
|---|---|---|
| `scrollToRect(rect, animated)` | `setContentVisibleFrame(_:animated:)` | Programmatically zoom/pan to a specific area |
| `getContentVisibleFrame()` | `contentVisibleFrame` | Get the current visible rect |
| `scrollConfiguration` | `scrollConfiguration` | Access underlying scroll view settings |

**Effort:** Medium — need to bridge CGRect values between JS and native.

---

## 3. Touch Modes (Granular)

| Prop | Native API | Description |
|---|---|---|
| ~~`directTouchAutomaticallyDraws`~~ | ~~`vc.directTouchAutomaticallyDraws`~~ | ✅ **Implemented** |
| ~~`indirectPointerTouchMode`~~ | ~~`vc.indirectPointerTouchMode`~~ | ✅ **Implemented** |

**Effort:** Done.

---

## 4. FeatureSet (Granular)

Our current `featureSet` prop exposes 5 high-level booleans (`shapes`, `textBoxes`, `arrows`, `signatures`, `hdr`). PaperKit's `FeatureSet` is much more granular:

### Element features (`FeatureSet.Feature`)

| Feature | Description |
|---|---|
| `images` | Support for image elements |
| `stickers` | Support for inserting stickers |
| `loupes` | Support for loupe (magnifier) elements |
| `links` | Support for link elements |
| `drawing` | Toggle drawing support entirely |
| `text` | Toggle text inside shapes |

### Shape features

| Feature | Description |
|---|---|
| `shapeFills` | Shapes with fills |
| `shapeStrokes` | Shapes with strokes |
| `shapeOpacity` | Shapes with opacity |

### Ink & color features

| Feature | Description |
|---|---|
| `inks` | Configure supported ink types |
| `lineMarkerPositions` | Arrow marker positions (start, end, both) |
| `colorMaximumLinearExposure` | HDR color range cap (float) |

### Versioning

| Feature | Description |
|---|---|
| `contentVersion` | `.version1` \| `.version2` \| `.latest` |

**Effort:** Medium — expand `FeatureSetConfig` to support all toggles and rebuild `buildFeatureSet()`.

---

## 5. Programmatic Content Insertion

| Method | Native API | Description |
|---|---|---|
| `insertShape(config, frame, rotation)` | `markup.insertNewShape(configuration:frame:rotation:)` | Add a shape (rect, ellipse, star, arrow, etc.) |
| `insertImage(imageUri, frame, rotation)` | `markup.insertNewImage(_:frame:rotation:)` | Add an image element |
| `insertLine(config, from, to, startMarker, endMarker)` | `markup.insertNewLine(configuration:from:to:startMarker:endMarker:)` | Add a line/arrow |
| `insertTextbox(text, frame, rotation)` | `markup.insertNewTextbox(attributedText:frame:rotation:)` | Add a text box |

### ShapeConfiguration

```typescript
interface ShapeConfiguration {
  type: 'rectangle' | 'ellipse' | 'line' | 'chatBubble' | 'roundedRectangle' | 'regularPolygon' | 'star' | 'arrowShape';
  fillColor?: string;
  strokeColor?: string;
  lineWidth?: number;
}
```

**Effort:** Medium-High — need to bridge shape configs, frames, and image loading.

---

## 6. Content Transformation

| Method | Native API | Description |
|---|---|---|
| `transformContent(transform)` | `markup.transformContent(_:)` | Apply an affine transform to all content |
| `appendContent(base64Data)` | `markup.append(contentsOf:)` | Merge another PaperMarkup into current one |
| `appendDrawing(base64Data)` | `markup.append(contentsOf:)` (PKDrawing overload) | Merge a PencilKit drawing into current markup |

**Effort:** Medium — affine transform bridging, data deserialization.

---

## 7. Adornments (Custom Overlays)

Adornments are image-based overlays positioned on the canvas that can be dragged and scaled.

| Method | Native API | Description |
|---|---|---|
| `addAdornment(config)` | `vc.adornments.append(...)` | Add a visual overlay |
| `removeAdornment(id)` | (filter adornments array) | Remove an overlay |
| `getAdornmentFrame(id)` | `vc.adornmentFrame(for:)` | Get current frame of an adornment |

### Adornment config

```typescript
interface MarkupAdornment {
  id: string;
  anchor: { type: 'content' | 'viewport'; point: { x: number; y: number } };
  image: { systemName?: string; uri?: string; tintColor?: string };
  dragRegion?: { ... };
  scalesWithZoom?: boolean;
}
```

### Adornment delegate events

| Event | Description |
|---|---|
| `onAdornmentTapped(id)` | User tapped an adornment |
| `onAdornmentMoved(id, anchor)` | Drag ended for an adornment |

**Effort:** High — custom bridging for image configs, anchors, drag regions.

---

## 8. PaperMarkup Model Properties

| Prop / Method | Native API | Description |
|---|---|---|
| `paperBackgroundColor` (on model) | `markup.backgroundColor` | Background color of the paper itself (separate from VC view) |
| `getContentsRenderFrame()` | `markup.contentsRenderFrame` | Tight bounding frame of all rendered content |
| `getSubelements()` | `markup.subelements` | Read back the list of markup elements |

**Effort:** Low-Medium — `backgroundColor` is a simple prop; subelements would need serialization.

---

## 9. Markup Element Interactions

Per-element interaction control via `MarkupInteractions`:

```typescript
type MarkupInteraction = 'select' | 'move' | 'resize' | 'rotate' | 'style' | 'delete';
type AllowedInteractions = MarkupInteraction[] | 'all' | 'readOnly';
```

| Prop | Native API | Description |
|---|---|---|
| `allowedInteractions` | `markup.allowedInteractions` | Control which actions users can perform on elements |

**Effort:** Medium — need to bridge the option set.

---

## 10. Rendering Options (for Export)

| Option | Native API | Description |
|---|---|---|
| `darkMode` | `RenderingOptions.darkUserInterfaceStyle` | Render export in dark mode |
| `rtl` | `RenderingOptions.rightToLeftLayoutDirection` | Render export with RTL layout |

**Effort:** Low — pass options to `exportAsImage`.

---

## 11. Display Mode

| Prop | Native API | Description |
|---|---|---|
| `displayMode` | `PaperDocumentDisplayMode` | `.continuousScroll` \| `.twoUp` |

**Effort:** Low — single enum prop (unclear if VC exposes this directly).

---

## 12. macOS Toolbar (`MarkupToolbarViewController`)

macOS uses `MarkupToolbarViewController` instead of iOS's `PKToolPicker`. Several toolbar-specific features are not yet exposed:

| Feature | Native API | Description |
|---|---|---|
| `selectedDrawingTool` | `toolbar.selectedDrawingTool` | Get/set the active drawing tool programmatically |
| `selectedDrawingToolItem` | `toolbar.selectedDrawingToolItem` | Get/set the active tool item |
| `indirectPointerTouchModes` | `toolbar.indirectPointerTouchModes` | Configure which pointer modes are available in toolbar UI |
| `selectedIndirectPointerTouchMode` | `toolbar.selectedIndirectPointerTouchMode` | Get/set pointer mode from toolbar |
| Toolbar delegate | `MarkupToolbarViewController.Delegate` | Events for when user changes tools/modes via toolbar |
| Toolbar visibility toggle | — | Show/hide toolbar without destroying it (currently add/remove) |
| Font Panel integration | `NSFontPanel.shared` | macOS text formatting (font size, weight, color) — iOS uses built-in "Aa" popover, macOS needs explicit Font Panel trigger |

**Effort:** Medium — need delegate bridging and tool serialization.

---

## 13. Drawing Tool Control

Available on both platforms via `PaperMarkupViewController`:

| Feature | Native API | Description |
|---|---|---|
| `drawingTool` (get/set) | `vc.drawingTool` | Programmatically get or set the active drawing tool |
| `onDrawingToolChanged` | (KVO/observation) | Event when tool changes |

**Effort:** Medium — `DrawingTool` is a complex type that needs serialization.

---

## Summary by Priority

### Quick wins (Low effort)
- [x] `directTouchAutomaticallyDraws` prop
- [x] Improved `exportAsImage` using `PaperMarkup.draw()` for native rendering
- [x] `indirectPointerTouchMode` prop
- [ ] Export rendering options (`darkMode`, `rtl`)
- [ ] Selection API (`getSelection`, `clearSelection`)

### Medium effort
- [ ] Scroll/zoom control (`scrollToRect`, `getContentVisibleFrame`)
- [ ] Granular `FeatureSet` expansion
- [ ] `allowedInteractions`
- [ ] `PaperMarkup.backgroundColor` (model-level, separate from view)
- [ ] `getContentsRenderFrame()`
- [ ] Content transformation (`transformContent`, `appendContent`)
- [ ] `displayMode`
- [ ] macOS toolbar: expose `selectedDrawingTool`, pointer modes, delegate events
- [ ] Drawing tool control (`drawingTool` get/set on VC)

### High effort
- [ ] Programmatic insertion (`insertShape`, `insertImage`, `insertLine`, `insertTextbox`)
- [ ] Adornments system (add/remove/events)
- [ ] `getSubelements()` with full serialization
