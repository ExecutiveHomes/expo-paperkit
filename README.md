<img src="https://github.com/user-attachments/assets/e65f8f67-32ab-43bd-850c-5bcd45dd7aa4" alt="expo-paperkit" width="100%" height="300">

# expo-paperkit

Apple PaperKit markup experience for Expo/React Native — drawings, shapes, and annotations powered by PaperKit (iOS 26+, macOS 26+).

## Features

- ✏️ Full PaperKit drawing canvas with Apple Pencil support
- 🔶 Shape, text box, and arrow/line insertion
- 💾 Save/restore markup data (base64 serialization)
- 🖼️ Export canvas as PNG or JPG
- ↩️ Undo/redo support
- ⚙️ Configurable feature sets, zoom, and canvas size
- 🎨 PKToolPicker integration (iOS) and MarkupToolbar (macOS)
- 🏞️ Background image support
- 👁️ Read-only mode for viewing saved markup

## Requirements

- iOS 26.0+ or macOS 26.0+
- Expo SDK 54+
- React Native 0.81+

## Installation

```bash
npm install expo-paperkit
# or
yarn add expo-paperkit
```

Run `npx expo prebuild` to generate the native project, then build with Xcode.

## Quick Start

```tsx
import { PaperMarkupView, type PaperMarkupRef } from 'expo-paperkit';
import { useRef, useState } from 'react';

export default function App() {
  const markupRef = useRef<PaperMarkupRef>(null);
  const [savedData, setSavedData] = useState<string | null>(null);

  const handleSave = async () => {
    const data = await markupRef.current!.save();
    setSavedData(data);
  };

  const handleExport = async () => {
    const uri = await markupRef.current!.exportAsImage('png', 1.0);
    console.log('Exported to:', uri);
  };

  return (
    <PaperMarkupView
      ref={markupRef}
      style={{ flex: 1 }}
      initialData={savedData ?? undefined}
      allowFingerDrawing
      featureSet={{
        shapes: true,
        textBoxes: true,
        arrows: true,
      }}
      onMarkupChanged={() => console.log('Markup changed')}
    />
  );
}
```

## Documentation

- [API Reference](docs/API_REFERENCE.md) — Full props, events, ref methods, and types documentation

## License

MIT
