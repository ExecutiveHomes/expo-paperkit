import { PaperMarkupView, type PaperMarkupRef, type ToolPickerVisibility } from 'expo-paperkit';
import { useRef, useState } from 'react';
import {
  Alert,
  Image,
  Platform,
  Pressable,
  SafeAreaView,
  StyleSheet,
  Text,
  View,
} from 'react-native';

export default function App() {
  const markupRef = useRef<PaperMarkupRef>(null);
  const [hasChanges, setHasChanges] = useState(false);
  const [pickerVisible, setPickerVisible] = useState(true);
  const [savedData, setSavedData] = useState<string | null>(null);
  const [exportedUri, setExportedUri] = useState<string | null>(null);
  const drawingTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const [isDrawing, setIsDrawing] = useState(false);

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

  return (
    <View style={styles.root}>
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.header}>
          <View style={styles.headerLeft}>
            <Text style={styles.logo}>expo-paperkit</Text>
            <Text style={styles.version}>0.1.0</Text>
          </View>
          <View style={styles.statusRow}>
            {isDrawing && <View style={[styles.statusDot, { backgroundColor: '#34d399' }]} />}
            {hasChanges && !savedData && (
              <View style={[styles.statusDot, { backgroundColor: '#fbbf24' }]} />
            )}
            {savedData && <View style={[styles.statusDot, { backgroundColor: '#60a5fa' }]} />}
          </View>
        </View>

        <View style={styles.topBar}>
          <View style={styles.actionGroup}>
            <ActionButton icon="⟲" onPress={() => markupRef.current?.undo()} />
            <ActionButton icon="⟳" onPress={() => markupRef.current?.redo()} />
          </View>

          <View style={styles.actionGroup}>
            <ActionButton icon="◇" onPress={() => markupRef.current?.showMarkupTools()} />
            <ActionButton
              icon={pickerVisible ? '⊘' : '⊙'}
              onPress={toggleToolPicker}
              active={pickerVisible}
            />
          </View>

          <View style={styles.actionGroup}>
            <ActionButton icon="↓" onPress={handleSave} disabled={!hasChanges} />
            <ActionButton icon="⎙" onPress={handleExport} />
            <ActionButton icon="×" onPress={() => markupRef.current?.clear()} destructive />
          </View>
        </View>

        {exportedUri && (
          <Pressable style={styles.previewCard} onPress={() => setExportedUri(null)}>
            <View style={styles.previewHeader}>
              <View style={styles.previewBadge}>
                <Text style={styles.previewBadgeText}>EXPORTED</Text>
              </View>
              <Text style={styles.previewDismissText}>Tap to dismiss</Text>
            </View>
            <Image source={{ uri: exportedUri }} style={styles.previewImage} resizeMode="contain" />
          </Pressable>
        )}

        <View style={styles.canvasContainer}>
          <PaperMarkupView
            ref={markupRef}
            style={styles.canvas}
            showPencilKit
            initialData={savedData ?? undefined}
            canvasBackgroundColor="#ffffff"
            allowFingerDrawing={Platform.OS !== 'ios'}
            featureSet={{
              shapes: true,
              textBoxes: true,
              arrows: true,
            }}
            onMarkupChanged={() => setHasChanges(true)}
            onDrawingBegan={() => {
              setIsDrawing(true);
              if (drawingTimeoutRef.current) clearTimeout(drawingTimeoutRef.current);
              drawingTimeoutRef.current = setTimeout(() => setIsDrawing(false), 1500);
            }}
          />
        </View>
      </SafeAreaView>
    </View>
  );
}

function ActionButton({
  icon,
  onPress,
  active,
  disabled,
  destructive,
}: {
  icon: string;
  onPress: () => void;
  active?: boolean;
  disabled?: boolean;
  destructive?: boolean;
}) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      style={({ pressed }) => [
        styles.actionBtn,
        active && styles.actionBtnActive,
        pressed && styles.actionBtnPressed,
        disabled && styles.actionBtnDisabled,
      ]}>
      <Text
        style={[
          styles.actionIcon,
          active && styles.actionIconActive,
          disabled && styles.actionIconDisabled,
          destructive && styles.actionIconDestructive,
        ]}>
        {icon}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: '#f2f2f7',
  },
  safeArea: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: 8,
  },
  logo: {
    fontSize: 20,
    fontWeight: '800',
    color: '#1a1a1a',
    letterSpacing: -0.5,
  },
  version: {
    fontSize: 12,
    fontWeight: '500',
    color: '#999',
  },
  statusRow: {
    flexDirection: 'row',
    gap: 6,
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
  },
  canvasContainer: {
    flex: 1,
    marginHorizontal: 12,
    marginBottom: 8,
    borderRadius: 20,
    overflow: 'hidden',
    backgroundColor: '#ffffff',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 16,
    elevation: 8,
  },
  canvas: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  topBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  actionGroup: {
    flexDirection: 'row',
    gap: 6,
  },
  actionBtn: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: '#ffffff',
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.06,
    shadowRadius: 4,
    elevation: 2,
  },
  actionBtnActive: {
    backgroundColor: '#007aff',
  },
  actionBtnPressed: {
    transform: [{ scale: 0.9 }],
    opacity: 0.7,
  },
  actionBtnDisabled: {
    opacity: 0.3,
  },
  actionIcon: {
    fontSize: 20,
    fontWeight: '300',
    color: '#333',
  },
  actionIconActive: {
    color: '#fff',
  },
  actionIconDisabled: {
    color: '#bbb',
  },
  actionIconDestructive: {
    color: '#ff3b30',
  },
  previewCard: {
    marginHorizontal: 12,
    marginBottom: 8,
    backgroundColor: '#ffffff',
    borderRadius: 16,
    padding: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 3,
  },
  previewHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  previewBadge: {
    backgroundColor: '#007aff',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 6,
  },
  previewBadgeText: {
    color: '#fff',
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 0.8,
  },
  previewDismissText: {
    color: '#999',
    fontSize: 12,
    fontWeight: '500',
  },
  previewImage: {
    width: '100%',
    height: 160,
    borderRadius: 10,
    backgroundColor: '#f8f8f8',
  },
});
