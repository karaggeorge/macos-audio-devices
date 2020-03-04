import {expectType, expectError} from 'tsd';

import {
  Device,
  getAllDevices,
  getInputDevices,
  getOutputDevices,
  getDefaultInputDevice,
  getDefaultOutputDevice,
  getDefaultSystemDevice,
  setDefaultInputDevice,
  setDefaultOutputDevice,
  setDefaultSystemDevice,
  getOutputDeviceVolume,
  setOutputDeviceVolume,
  createAggregateDevice,
  destroyAggregateDevice,
  isSupported
} from '.';

expectType<Device[]>(getAllDevices())
expectType<Device[]>(getInputDevices())
expectType<Device[]>(getOutputDevices())
expectType<Device>(getDefaultInputDevice())
expectType<Device>(getDefaultOutputDevice())
expectType<Device>(getDefaultSystemDevice())

expectType<void>(setDefaultInputDevice(1))
expectError(setDefaultInputDevice())
expectError(setDefaultInputDevice('1'))

expectType<void>(setDefaultOutputDevice(1))
expectError(setDefaultOutputDevice())
expectError(setDefaultOutputDevice('1'))

expectType<void>(setDefaultSystemDevice(1))
expectError(setDefaultSystemDevice())
expectError(setDefaultSystemDevice('1'))

expectType<number>(getOutputDeviceVolume(1))
expectError(getOutputDeviceVolume())
expectError(getOutputDeviceVolume('1'))

expectType<void>(setOutputDeviceVolume(1, 0.5))
expectError(setOutputDeviceVolume())
expectError(setOutputDeviceVolume(1))
expectError(setOutputDeviceVolume('1', 1))
expectError(setOutputDeviceVolume(1, '1'))

expectType<Device>(createAggregateDevice('name', 74, [32], {multiOutput: true}))
expectType<Device>(createAggregateDevice('name', 74, [32, 72]))
expectError(createAggregateDevice())
expectError(createAggregateDevice(74))
expectError(createAggregateDevice('name', 74, 32))

expectType<void>(destroyAggregateDevice(1))
expectError(destroyAggregateDevice())
expectError(destroyAggregateDevice('1'))

expectType<boolean>(isSupported)