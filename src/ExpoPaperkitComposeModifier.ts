import { createModifier, type ModifierConfig } from '@expo/ui/jetpack-compose/modifiers';

export const expoPaperkitComposeModifier = (params: {
  color?: number;
  width?: number;
  cornerRadius?: number;
}): ModifierConfig => createModifier('expoPaperkitComposeModifier', params);
