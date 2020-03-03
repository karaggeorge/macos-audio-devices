import {expectType, expectError} from 'tsd';

import {
  Device,
  getAllDevices,
  getInputDevices,
  getOutputDevices,
  getDefaultInputDevice,
  getDefaultOutputDevice,
  setDefaultInputDevice,
  setDefaultOutputDevice,
  getOutputDeviceVolume,
  setOutputDeviceVolume,
  isSupported
} from '.';

expectType<Device[]>(getAllDevices())
expectType<Device[]>(getInputDevices())
expectType<Device[]>(getOutputDevices())
expectType<Device>(getDefaultInputDevice())
expectType<Device>(getDefaultOutputDevice())

expectType<void>(setDefaultInputDevice(1))
expectError(setDefaultInputDevice())
expectError(setDefaultInputDevice('1'))

expectType<void>(setDefaultOutputDevice(1))
expectError(setDefaultOutputDevice())
expectError(setDefaultOutputDevice('1'))

expectType<number>(getOutputDeviceVolume(1))
expectError(getOutputDeviceVolume())
expectError(getOutputDeviceVolume('1'))

expectType<void>(setOutputDeviceVolume(1, 0.5))
expectError(setOutputDeviceVolume())
expectError(setOutputDeviceVolume(1))
expectError(setOutputDeviceVolume('1', 1))
expectError(setOutputDeviceVolume(1, '1'))

expectType<boolean>(isSupported)