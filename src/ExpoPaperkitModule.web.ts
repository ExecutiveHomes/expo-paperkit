import { registerWebModule, NativeModule } from 'expo';

import { ExpoPaperkitModuleEvents } from './ExpoPaperkit.types';

// ExpoPaperkitModule is not available on the web platform.
class ExpoPaperkitModule extends NativeModule<ExpoPaperkitModuleEvents> {}

export default registerWebModule(ExpoPaperkitModule, 'ExpoPaperkitModule');
