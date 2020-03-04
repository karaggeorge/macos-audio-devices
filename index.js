'use strict';
const path = require('path');
const execa = require('execa');
const electronUtil = require('electron-util/node');
const macosVersion = require('macos-version');

const binary = path.join(electronUtil.fixPathForAsarUnpack(__dirname), 'audio-devices');

const isSupported = macosVersion.isGreaterThanOrEqualTo('10.14.4');

const getAllDevices = () => {
  const {stdout} = execa.sync(binary, ['list', '-j']);
  return JSON.parse(stdout);
};

module.exports = {
  getAllDevices,
  isSupported
};

module.exports.getInputDevices = () => {
  return getAllDevices().filter(device => device.isInput);
};

module.exports.getOutputDevices = () => {
  return getAllDevices().filter(device => device.isOutput);
};

module.exports.getDefaultOutputDevice = () => {
  const {stdout} = execa.sync(binary, ['output', 'get', '-j']);
  return JSON.parse(stdout);
};

module.exports.getDefaultInputDevice = () => {
  const {stdout} = execa.sync(binary, ['input', 'get', '-j']);
  return JSON.parse(stdout);
};

module.exports.getDefaultSystemDevice = () => {
  const {stdout} = execa.sync(binary, ['system', 'get', '-j']);
  return JSON.parse(stdout);
};

module.exports.setDefaultOutputDevice = deviceId => {
  const {stderr} = execa.sync(binary, ['output', 'set', deviceId]);

  if (stderr) {
    throw new Error(stderr);
  }
};

module.exports.setDefaultInputDevice = deviceId => {
  const {stderr} = execa.sync(binary, ['input', 'set', deviceId]);

  if (stderr) {
    throw new Error(stderr);
  }
};

module.exports.setDefaultSystemDevice = deviceId => {
  const {stderr} = execa.sync(binary, ['system', 'set', deviceId]);

  if (stderr) {
    throw new Error(stderr);
  }
};

module.exports.getOutputDeviceVolume = deviceId => {
  const {stdout, stderr} = execa.sync(binary, ['volume', 'get', deviceId]);
  return stderr ? undefined : stdout;
};

module.exports.setOutputDeviceVolume = (deviceId, volume) => {
  const {stderr} = execa.sync(binary, ['volume', 'set', deviceId, volume]);

  if (stderr) {
    throw new Error(stderr);
  }
};

module.exports.createAggregateDevice = (name, mainDeviceId, otherDeviceIds, {multiOutput} = {}) => {
  const {stderr, stdout} = execa.sync(binary, [
    'aggregate', 'create', '-j', (multiOutput && '-m'), name, mainDeviceId, ...otherDeviceIds
  ].filter(Boolean));

  if (stderr) {
    throw new Error(stderr);
  }

  return JSON.parse(stdout);
};

module.exports.destroyAggregateDevice = deviceId => {
  const {stderr} = execa.sync(binary, ['aggregate', 'destroy', deviceId]);

  if (stderr) {
    throw new Error(stderr);
  }
};
