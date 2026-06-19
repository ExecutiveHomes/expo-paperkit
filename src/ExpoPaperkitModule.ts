import { NativeModule, requireNativeModule } from 'expo';

declare class ExpoPaperkitModule extends NativeModule {}

export default requireNativeModule<ExpoPaperkitModule>('ExpoPaperkit');
