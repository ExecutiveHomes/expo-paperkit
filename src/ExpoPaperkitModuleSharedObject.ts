import { SharedObject, useReleasingSharedObject } from 'expo-modules-core';

import ExpoPaperkitModule from './ExpoPaperkitModule';

export declare class ExpoPaperkitModuleSharedObject extends SharedObject {
  count: number;
}

/**
 * Creates a new ExpoPaperkitModuleSharedObject instance.
 * You are responsible for releasing it from memory by calling `release()` when done.
 */
export function createExpoPaperkitModuleSharedObject(): ExpoPaperkitModuleSharedObject {
  return new ExpoPaperkitModule.ExpoPaperkitModuleSharedObject();
}

/**
 * A hook that creates a ExpoPaperkitModuleSharedObject instance and automatically
 * releases it when the component unmounts.
 */
export function useExpoPaperkitModuleSharedObject(): ExpoPaperkitModuleSharedObject {
  return useReleasingSharedObject(() => new ExpoPaperkitModule.ExpoPaperkitModuleSharedObject(), []);
}
