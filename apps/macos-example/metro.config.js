const { getDefaultConfig } = require('@expo/metro-config');
const { makeMetroConfig } = require('@rnx-kit/metro-config');
const path = require('path');

const projectRoot = __dirname;
const workspaceRoot = path.resolve(projectRoot, '../..');

const config = makeMetroConfig(getDefaultConfig(__dirname));

config.resolver.blockList = [
  ...Array.from(config.resolver.blockList ?? []),
  new RegExp(path.resolve(workspaceRoot, 'node_modules', 'react').replace(/\\/g, '\\\\')),
  new RegExp(path.resolve(workspaceRoot, 'node_modules', 'react-native').replace(/\\/g, '\\\\')),
];

config.resolver.nodeModulesPaths = [
  path.resolve(projectRoot, 'node_modules'),
  path.resolve(workspaceRoot, 'node_modules'),
];

config.resolver.extraNodeModules = {
  'expo-paperkit': workspaceRoot,
};

config.watchFolders = [workspaceRoot];

module.exports = config;
