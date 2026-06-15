import { requireNativeView } from 'expo';
import * as React from 'react';

import { ExpoPaperkitViewProps } from './ExpoPaperkit.types';

const NativeView: React.ComponentType<ExpoPaperkitViewProps> = requireNativeView('ExpoPaperkit');

export default function ExpoPaperkitView(props: ExpoPaperkitViewProps) {
  return <NativeView {...props} />;
}
