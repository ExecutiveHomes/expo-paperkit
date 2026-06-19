import { PaperMarkupView, type PaperMarkupRef, type ToolPickerVisibility } from 'expo-paperkit';
import { useRef, useState } from 'react';
import {
  Alert,
  Image,
  Platform,
  Pressable,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';

export default function App() {
  const markupRef = useRef<PaperMarkupRef>(null);
  const [hasChanges, setHasChanges] = useState(false);
  const [pickerVisible, setPickerVisible] = useState(true);
  const [hasSelection, setHasSelection] = useState(false);
  const [isDrawing, setIsDrawing] = useState(false);
  const [savedData, setSavedData] = useState<string | null>(null);
  const [exportedUri, setExportedUri] = useState<string | null>(null);
  const drawingTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const toggleToolPicker = () => {
    const next: ToolPickerVisibility = pickerVisible ? 'hidden' : 'visible';
    markupRef.current?.setToolPickerVisibility(next);
    setPickerVisible(!pickerVisible);
  };

  const handleSave = async () => {
    try {
      const data = await markupRef.current!.save();
      setSavedData(data);
      setHasChanges(false);
    } catch (error: any) {
      Alert.alert('Save Error', error.message);
    }
  };

  const handleExport = async () => {
    try {
      const uri = await markupRef.current!.exportAsImage('png', 1.0);
      setExportedUri(uri);
    } catch (error: any) {
      Alert.alert('Export Error', error.message);
    }
  };

  const handleRestore = () => {
    if (!savedData) return;
    markupRef.current?.clear();
    setSavedData(null);
    setHasChanges(false);
  };

  const formatBytes = (base64: string) => {
    const bytes = Math.round((base64.length * 3) / 4);
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>PaperKit Demo</Text>
        {hasChanges && <Text style={styles.badge}>Modified</Text>}
        {hasSelection && <Text style={styles.badge}>Selected</Text>}
        {isDrawing && <Text style={[styles.badge, { backgroundColor: '#34c759' }]}>Drawing</Text>}
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        style={styles.toolbarScroll}
        contentContainerStyle={styles.toolbar}>
        <ToolbarButton label="Undo" onPress={() => markupRef.current?.undo()} />
        <ToolbarButton label="Redo" onPress={() => markupRef.current?.redo()} />
        <ToolbarButton label="Tools" onPress={() => markupRef.current?.showMarkupTools()} />
        <ToolbarButton
          label={pickerVisible ? 'Hide Picker' : 'Show Picker'}
          onPress={toggleToolPicker}
          active={pickerVisible}
        />
        <ToolbarButton label="Clear" onPress={() => markupRef.current?.clear()} />
        <ToolbarButton label="Save" onPress={handleSave} />
        <ToolbarButton label="Export" onPress={handleExport} />
        {savedData && <ToolbarButton label="Restore" onPress={handleRestore} />}
        {exportedUri && (
          <ToolbarButton label="Clear Preview" onPress={() => setExportedUri(null)} />
        )}
      </ScrollView>

      {(savedData || exportedUri) && (
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          style={styles.previewScroll}
          contentContainerStyle={styles.previewContent}>
          {savedData && (
            <View style={styles.previewCard}>
              <Text style={styles.previewLabel}>Saved Data</Text>
              <Text style={styles.previewMeta}>{formatBytes(savedData)}</Text>
            </View>
          )}
          {exportedUri && (
            <View style={styles.previewCard}>
              <Text style={styles.previewLabel}>Exported Image</Text>
              <Image
                source={{ uri: exportedUri }}
                style={styles.previewImage}
                resizeMode="contain"
              />
            </View>
          )}
        </ScrollView>
      )}

      <PaperMarkupView
        ref={markupRef}
        style={styles.canvas}
        showPencilKit
        initialData={savedData ?? undefined}
        paperBackgroundColor="#ffffff"
        allowFingerDrawing={Platform.OS !== 'ios'}
        featureSet={{
          shapes: true,
          textBoxes: true,
          arrows: true,
        }}
        onMarkupChanged={() => setHasChanges(true)}
        onSelectionChanged={(e) => setHasSelection(e.hasSelection)}
        onDrawingBegan={() => {
          setIsDrawing(true);
          if (drawingTimeoutRef.current) clearTimeout(drawingTimeoutRef.current);
          drawingTimeoutRef.current = setTimeout(() => setIsDrawing(false), 1000);
        }}
      />
    </SafeAreaView>
  );
}

function ToolbarButton({
  label,
  onPress,
  active,
}: {
  label: string;
  onPress: () => void;
  active?: boolean;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.button,
        active && styles.buttonActive,
        pressed && styles.buttonPressed,
      ]}>
      <Text style={[styles.buttonText, active && styles.buttonTextActive]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    gap: 8,
  },
  title: {
    fontSize: 22,
    fontWeight: '700',
  },
  badge: {
    fontSize: 12,
    color: '#fff',
    backgroundColor: '#007aff',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 8,
    overflow: 'hidden',
  },
  canvas: {
    flex: 1,
    backgroundColor: '#fff',
    marginHorizontal: 8,
    borderRadius: 12,
    overflow: 'hidden',
  },
  toolbarScroll: {
    flexGrow: 0,
  },
  toolbar: {
    gap: 6,
    paddingVertical: 8,
    paddingHorizontal: 8,
    alignItems: 'center',
  },
  button: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
    backgroundColor: '#e8e8e8',
  },
  buttonActive: {
    backgroundColor: '#007aff',
  },
  buttonPressed: {
    opacity: 0.7,
  },
  buttonText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#333',
  },
  buttonTextActive: {
    color: '#fff',
  },
  previewScroll: {
    maxHeight: 160,
    flexGrow: 0,
  },
  previewContent: {
    flexDirection: 'row',
    gap: 8,
    paddingHorizontal: 8,
    paddingVertical: 8,
  },
  previewCard: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 8,
    alignItems: 'center',
    minWidth: 120,
  },
  previewLabel: {
    fontSize: 11,
    fontWeight: '700',
    color: '#888',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 4,
  },
  previewMeta: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  previewImage: {
    width: 140,
    height: 100,
    borderRadius: 6,
    backgroundColor: '#f0f0f0',
  },
});
