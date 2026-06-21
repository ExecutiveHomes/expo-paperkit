# API Reference

## PaperMarkupView

The main component for rendering a PaperKit drawing canvas.

```tsx
import { PaperMarkupView, type PaperMarkupRef } from 'expo-paperkit';
```

---

## Props

### `showToolbar`

Show the native markup toolbar (macOS only).

| Type | Default Value | Platform |
| --------- | ------------- | -------- |
| `boolean` | `true` | macOS |

---

### `showPencilKit`

Show the floating PKToolPicker for drawing tools.

| Type | Default Value | Platform |
| --------- | ------------- | -------- |
| `boolean` | `true` | iOS |

---

### `readOnly`

Disable all editing. The canvas becomes view-only.

| Type | Default Value | Platform |
| --------- | ------------- | -------- |
| `boolean` | `false` | Both |

---

### `allowFingerDrawing`

Allow finger input to draw (by default, finger input is used for selection/panning on iOS).

| Type | Default Value | Platform |
| --------- | ------------- | -------- |
| `boolean` | `false` | iOS |

---

### `directTouchAutomaticallyDraws`

Let the system decide when direct touches should draw vs. select based on context (e.g., Apple Pencil presence).

| Type | Default Value | Platform |
| --------- | ------------- | -------- |
| `boolean` | `false` | iOS |

---

### `indirectPointerTouchMode`

Controls trackpad/mouse behavior on macOS.

| Type | Default Value | Platform |
| ----------------------- | ------------- | -------- |
| `'drawing' \| 'selection'` | `'drawing'` | Both |

**Example:**

```tsx
<PaperMarkupView
  indirectPointerTouchMode="selection"
/>
```

---

### `initialData`

Base64-encoded markup data to restore. Typically the output of a previous `save()` call.

| Type | Default Value | Platform |
| -------- | ------------- | -------- |
| `string` | — | Both |

**Example:**

```tsx
const [savedData, setSavedData] = useState<string | null>(null);

<PaperMarkupView
  initialData={savedData ?? undefined}
/>
```

---

### `backgroundImageUri`

URI for a background image displayed behind the markup content.

| Type | Default Value | Platform |
| -------- | ------------- | -------- |
| `string` | — | Both |

---

### `featureSet`

Configure which PaperKit features are available on the canvas.

| Type | Default Value | Platform |
| ------------------ | ------------- | -------- |
| `FeatureSetConfig` | all enabled | Both |

**FeatureSetConfig:**

```typescript
interface FeatureSetConfig {
  shapes?: boolean;     // Shape tools (rectangle, ellipse, star, etc.)
  textBoxes?: boolean;  // Text box insertion
  arrows?: boolean;     // Arrow/line tools and line markers
  hdr?: boolean;        // HDR color support (extended color range)
}
```

**Example:**

```tsx
<PaperMarkupView
  featureSet={{
    shapes: true,
    textBoxes: true,
    arrows: true,
    hdr: false,
  }}
/>
```

---

### `canvasSize`

Size of the paper canvas in points. Defaults to the view's size.

| Type | Default Value | Platform |
| ---------------------- | ------------- | -------- |
| `{ width, height }` | view size | Both |

**Example:**

```tsx
<PaperMarkupView
  canvasSize={{ width: 1024, height: 768 }}
/>
```

---

### `minZoomScale`

Minimum zoom scale factor.

| Type | Default Value | Platform |
| -------- | ------------- | -------- |
| `number` | `0.25` | Both |

---

### `maxZoomScale`

Maximum zoom scale factor.

| Type | Default Value | Platform |
| -------- | ------------- | -------- |
| `number` | `4.0` | Both |

---

### `isRulerActive`

Show the ruler overlay on the canvas.

| Type | Default Value | Platform |
| --------- | ------------- | -------- |
| `boolean` | `false` | iOS |

---

### `toolPickerVisibility`

Control the visibility state of the tool picker.

| Type | Default Value | Platform |
| ---------------------------------------- | ------------- | -------- |
| `'visible' \| 'hidden' \| 'inactive'` | `'visible'` | iOS |

- `'visible'` — tool picker is shown and active
- `'hidden'` — tool picker is hidden but can be restored
- `'inactive'` — tool picker is deactivated

---

### `canvasBackgroundColor`

Background color of the native canvas view.

| Type | Default Value | Platform |
| ------------ | --------------- | -------- |
| `ColorValue` | system default | Both |

Accepts hex strings, named CSS colors, `rgb()`/`rgba()`, or `'transparent'`.

**Example:**

```tsx
<PaperMarkupView
  canvasBackgroundColor="#ffffff"
/>
```

---

### `style`

Standard React Native view style for the component container.

| Type | Default Value | Platform |
| --------------------- | ------------- | -------- |
| `StyleProp<ViewStyle>` | — | Both |

---

## Events

### `onMarkupChanged`

Fired when the markup content changes (stroke completed, element added/removed/modified).

| Type | Platform |
| ------------ | -------- |
| `() => void` | Both |

---

### `onSelectionChanged`

Fired when the selection state changes.

| Type | Platform |
| -------------------------------------------- | -------- |
| `(event: { hasSelection: boolean }) => void` | Both |

**Example:**

```tsx
<PaperMarkupView
  onSelectionChanged={({ hasSelection }) => {
    console.log('Has selection:', hasSelection);
  }}
/>
```

---

### `onDrawingBegan`

Fired when the user begins a drawing stroke.

| Type | Platform |
| ------------ | -------- |
| `() => void` | Both |

---

### `onContentVisibleFrameChanged`

Fired when the user scrolls or zooms the canvas content.

| Type | Platform |
| ------------------------------------------------- | -------- |
| `(event: { x, y, width, height }) => void` | Both |

---

## Ref Methods

Access imperative methods via a ref:

```tsx
const markupRef = useRef<PaperMarkupRef>(null);

<PaperMarkupView ref={markupRef} />
```

### `save()`

Serialize the current markup to a base64-encoded string. This data can be stored and later passed back via `initialData` to restore the drawing.

| Returns | Throws |
| ---------------- | ----------------------- |
| `Promise<string>` | If no markup data exists |

**Example:**

```tsx
const data = await markupRef.current!.save();
// Store `data` in AsyncStorage, a database, etc.
```

---

### `exportAsImage(format, quality?)`

Export the canvas as a rasterized image file.

| Parameter | Type | Default |
| --------- | -------------- | ------- |
| `format` | `'png' \| 'jpg'` | — |
| `quality` | `number` | `0.9` |

| Returns | Description |
| ---------------- | ---------------------- |
| `Promise<string>` | File URI of the exported image |

**Example:**

```tsx
const uri = await markupRef.current!.exportAsImage('png', 1.0);
// Use `uri` in an <Image /> or share it
```

---

### `clear()`

Remove all markup content from the canvas.

| Returns |
| ------- |
| `void` |

---

### `undo()`

Undo the last action.

| Returns |
| ------- |
| `void` |

---

### `redo()`

Redo the last undone action.

| Returns |
| ------- |
| `void` |

---

### `showMarkupTools()`

Present the markup insertion tools UI. On iOS, this shows a popover with shape/text/line insertion options. On macOS, this ensures the toolbar is visible.

| Returns |
| ------- |
| `void` |

---

### `setToolPickerVisibility(visibility)`

Programmatically show or hide the tool picker at runtime.

| Parameter | Type |
| ------------ | ---------------------------------------- |
| `visibility` | `'visible' \| 'hidden' \| 'inactive'` |

| Returns |
| ------- |
| `void` |

**Example:**

```tsx
markupRef.current?.setToolPickerVisibility('hidden');
```

---

## Types

### `PaperMarkupRef`

```typescript
interface PaperMarkupRef {
  save(): Promise<string>;
  exportAsImage(format: 'png' | 'jpg', quality?: number): Promise<string>;
  clear(): void;
  undo(): void;
  redo(): void;
  showMarkupTools(): void;
  setToolPickerVisibility(visibility: ToolPickerVisibility): void;
}
```

### `FeatureSetConfig`

```typescript
interface FeatureSetConfig {
  shapes?: boolean;
  textBoxes?: boolean;
  arrows?: boolean;
  hdr?: boolean;
}
```

### `ToolPickerVisibility`

```typescript
type ToolPickerVisibility = 'visible' | 'hidden' | 'inactive';
```

### `TouchMode`

```typescript
type TouchMode = 'drawing' | 'selection';
```

### `CanvasSize`

```typescript
interface CanvasSize {
  width: number;
  height: number;
}
```

---

## Platform Differences

| Feature | iOS | macOS |
|---------|-----|-------|
| Tool UI | PKToolPicker (floating) | MarkupToolbarViewController (bottom bar) |
| Finger drawing | `allowFingerDrawing` prop | N/A (uses mouse natively) |
| Pointer mode | N/A | `indirectPointerTouchMode` prop |
| Ruler | `isRulerActive` prop | Not available |
| Tool picker visibility | Full show/hide/inactive | Toolbar add/remove only |
| Text formatting | Built-in "Aa" popover | System Font Panel (Cmd+T) |
| Markup tools | Popover UI | Toolbar buttons |
