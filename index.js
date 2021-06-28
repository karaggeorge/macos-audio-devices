'use strict';
const path = require('path');
const execa = require('execa');
const electronUtil = require('electron-util/node');

const binary = path.join(electronUtil.fixPathForAsarUnpack(__dirname), 'audio-devices');

const generateExport = (name, getArgs, callback) => {
  module.exports[name] = async (...inputs) => {
    let args = getArgs(...inputs).filter(Boolean)
    const result = await execa(binary, args);
    return callback(result);
  };

  module.exports[name].sync = (...inputs) => {
    let args = getArgs(...inputs).filter(Boolean)
    const result = execa.sync(binary, args);
    return callback(result);
  };
};

const throwIfStderr = ({stderr}) => {
  if (stderr) {
    throw new Error(stderr);
  }
};

const parseStdout = ({stdout, stderr}) => {
  throwIfStderr({stderr});
  return JSON.parse(stdout);
};

const ChannelType = {
  input: "input",
  output: "output"
}

module.exports['ChannelType'] = ChannelType

const getChannelTypeFlag = channelType => {
  if (channelType) {
    return `--${channelType}`
  }
  return null
}

generateExport('getAllDevices', () => ['list', '--json'], parseStdout);

generateExport('getInputDevices', () => ['list', '--input', '--json'], parseStdout);

generateExport('getOutputDevices', () => ['list', '--output', '--json'], parseStdout);

generateExport('getDevice', deviceId => ['get', '--json', deviceId], parseStdout);

generateExport('getDefaultOutputDevice', () => ['output', 'get', '--json'], parseStdout);

generateExport('getDefaultInputDevice', () => ['input', 'get', '--json'], parseStdout);

generateExport('getDefaultSystemDevice', () => ['system', 'get', '--json'], parseStdout);

generateExport('setDefaultOutputDevice', deviceId => ['output', 'set', deviceId], throwIfStderr);

generateExport('setDefaultInputDevice', deviceId => ['input', 'set', deviceId], throwIfStderr);

generateExport('setDefaultSystemDevice', deviceId => ['system', 'set', deviceId], throwIfStderr);

generateExport('getOutputDeviceVolume', deviceId => ['volume', 'get', deviceId], ({stdout, stderr}) => stderr ? undefined : stdout);

generateExport('setOutputDeviceVolume', (deviceId, volume) => ['volume', 'set', deviceId, volume], throwIfStderr);

generateExport('getDeviceMute', (deviceId, channelType) => ['mute', 'get', deviceId, getChannelTypeFlag(channelType)], ({stdout, stderr}) => stderr ? undefined : stdout == "true");

generateExport('setDeviceMute', (deviceId, isMuted, channelType) => ['mute', 'set', deviceId, isMuted, getChannelTypeFlag(channelType)], ({stdout, stderr}) => stderr ? undefined : stdout == "true");

generateExport('toggleDeviceMute', (deviceId, channelType) => ['mute', 'toggle', deviceId, getChannelTypeFlag(channelType)], throwIfStderr);

generateExport(
  'createAggregateDevice',
  (name, mainDeviceId, otherDeviceIds, {multiOutput} = {}) => [
    'aggregate', 'create', '--json', (multiOutput && '--multi-output'), name, mainDeviceId, ...otherDeviceIds
  ].filter(Boolean),
  parseStdout
);

generateExport('destroyAggregateDevice', deviceId => ['aggregate', 'destroy', deviceId], throwIfStderr);
