import { NativeModule, requireNativeModule } from 'expo';

import { ExpoPaperkitModuleEvents } from './ExpoPaperkit.types';
import type { ExpoPaperkitModuleSharedObject } from './ExpoPaperkitModuleSharedObject';

declare class ExpoPaperkitModule extends NativeModule<ExpoPaperkitModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
  ExpoPaperkitModuleSharedObject: typeof ExpoPaperkitModuleSharedObject;
}

export default requireNativeModule<ExpoPaperkitModule>('ExpoPaperkit');
