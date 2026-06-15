import { requireNativeView } from 'expo';
import { type PrimitiveBaseProps } from '@expo/ui/jetpack-compose';
import { createViewModifierEventListener } from '@expo/ui/jetpack-compose/modifiers';
import * as React from 'react';

export interface ExpoPaperkitComposeViewProps extends PrimitiveBaseProps {
  title: string;
  children?: React.ReactNode;
}

const NativeExpoPaperkitComposeView = requireNativeView<ExpoPaperkitComposeViewProps>(
  'ExpoPaperkit',
  'ExpoPaperkitComposeView'
);

export default function ExpoPaperkitComposeView({
  modifiers,
  ...rest
}: ExpoPaperkitComposeViewProps) {
  return (
    <NativeExpoPaperkitComposeView
      modifiers={modifiers}
      {...(modifiers ? createViewModifierEventListener(modifiers) : undefined)}
      {...rest}
    />
  );
}
