import { createModifier, type ModifierConfig } from '@expo/ui/swift-ui/modifiers';

export const expoPaperkitSwiftUIModifier = (params: {
  color?: string;
  width?: number;
  cornerRadius?: number;
}): ModifierConfig => createModifier('expoPaperkitSwiftUIModifier', params);
