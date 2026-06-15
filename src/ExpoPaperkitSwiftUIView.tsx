import { requireNativeView } from 'expo';
import { type CommonViewModifierProps } from '@expo/ui/swift-ui';
import { createViewModifierEventListener } from '@expo/ui/swift-ui/modifiers';
import * as React from 'react';

export interface ExpoPaperkitSwiftUIViewProps extends CommonViewModifierProps {
  title: string;
  children?: React.ReactNode;
}

const NativeExpoPaperkitSwiftUIView = requireNativeView<ExpoPaperkitSwiftUIViewProps>(
  'ExpoPaperkit',
  'ExpoPaperkitSwiftUIView'
);

export default function ExpoPaperkitSwiftUIView({
  modifiers,
  ...rest
}: ExpoPaperkitSwiftUIViewProps) {
  return (
    <NativeExpoPaperkitSwiftUIView
      modifiers={modifiers}
      {...(modifiers ? createViewModifierEventListener(modifiers) : undefined)}
      {...rest}
    />
  );
}
