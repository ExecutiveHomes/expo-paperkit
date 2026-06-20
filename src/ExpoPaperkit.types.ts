import type { ColorValue, StyleProp, ViewStyle } from 'react-native';

export interface FeatureSetConfig {
  shapes?: boolean;
  textBoxes?: boolean;
  arrows?: boolean;
  signatures?: boolean;
  hdr?: boolean;
}

export type ToolPickerVisibility = 'visible' | 'hidden' | 'inactive';

export type TouchMode = 'drawing' | 'selection';

export interface PaperMarkupRef {
  save(): Promise<string>;
  exportAsImage(format: 'png' | 'jpg', quality?: number): Promise<string>;
  clear(): void;
  undo(): void;
  redo(): void;
  showMarkupTools(): void;
  setToolPickerVisibility(visibility: ToolPickerVisibility): void;
}

export interface CanvasSize {
  width: number;
  height: number;
}

export interface PaperMarkupViewProps {
  showToolbar?: boolean;
  readOnly?: boolean;
  showPencilKit?: boolean;
  allowFingerDrawing?: boolean;
  initialData?: string;
  backgroundImageUri?: string;
  featureSet?: FeatureSetConfig;
  /** Size of the paper canvas in points. Defaults to the view size. */
  canvasSize?: CanvasSize;
  /** Minimum zoom scale. Defaults to 0.25. */
  minZoomScale?: number;
  /** Maximum zoom scale. Defaults to 4.0. */
  maxZoomScale?: number;
  /** Show/hide the ruler overlay on the canvas. Defaults to false. */
  isRulerActive?: boolean;
  /** Let the system decide when direct touches draw vs. select. Defaults to false. */
  directTouchAutomaticallyDraws?: boolean;
  /** Trackpad/mouse behavior on macOS: 'drawing' or 'selection'. Defaults to 'drawing'. */
  indirectPointerTouchMode?: TouchMode;
  toolPickerVisibility?: ToolPickerVisibility;
  /** Background color of the native view. Accepts hex strings, named CSS colors, rgb()/rgba(), or 'transparent'. */
  paperBackgroundColor?: ColorValue;
  onMarkupChanged?: () => void;
  onSelectionChanged?: (event: { hasSelection: boolean }) => void;
  onDrawingBegan?: () => void;
  onContentVisibleFrameChanged?: (event: {
    x: number;
    y: number;
    width: number;
    height: number;
  }) => void;
  style?: StyleProp<ViewStyle>;
}
