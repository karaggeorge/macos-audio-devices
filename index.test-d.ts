import { expectType, expectError } from 'tsd';

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
} from '.';

expectType<Device[]>(getAllDevices.sync())
expectType<Promise<Device[]>>(getAllDevices())
expectType<Device[]>(getInputDevices.sync())
expectType<Promise<Device[]>>(getInputDevices())
expectType<Device[]>(getOutputDevices.sync())
expectType<Promise<Device[]>>(getOutputDevices())

expectType<Device>(getDefaultInputDevice.sync())
expectType<Promise<Device>>(getDefaultInputDevice())

expectType<Device>(getDefaultOutputDevice.sync())
expectType<Promise<Device>>(getDefaultOutputDevice())

expectType<Device>(getDefaultSystemDevice.sync())
expectType<Promise<Device>>(getDefaultSystemDevice())

expectType<void>(setDefaultInputDevice.sync(1))
expectType<Promise<void>>(setDefaultInputDevice(1))
expectError(setDefaultInputDevice.sync())
expectError(setDefaultInputDevice.sync('1'))

expectType<void>(setDefaultOutputDevice.sync(1))
expectType<Promise<void>>(setDefaultOutputDevice(1))
expectError(setDefaultOutputDevice.sync())
expectError(setDefaultOutputDevice.sync('1'))

expectType<void>(setDefaultSystemDevice.sync(1))
expectType<Promise<void>>(setDefaultSystemDevice(1))
expectError(setDefaultSystemDevice.sync())
expectError(setDefaultSystemDevice.sync('1'))

expectType<number>(getOutputDeviceVolume.sync(1))
expectType<Promise<number>>(getOutputDeviceVolume(1))
expectError(getOutputDeviceVolume.sync())
expectError(getOutputDeviceVolume.sync('1'))

expectType<void>(setOutputDeviceVolume.sync(1, 0.5))
expectType<Promise<void>>(setOutputDeviceVolume(1, 0.5))
expectError(setOutputDeviceVolume.sync())
expectError(setOutputDeviceVolume.sync(1))
expectError(setOutputDeviceVolume('1', 1))
expectError(setOutputDeviceVolume(1, '1'))

expectType<Device>(createAggregateDevice.sync('name', 74, [32], { multiOutput: true }))
expectType<Device>(createAggregateDevice.sync('name', 74, [32, 72]))
expectType<Promise<Device>>(createAggregateDevice('name', 74, [32, 72]))
expectError(createAggregateDevice.sync())
expectError(createAggregateDevice.sync(74))
expectError(createAggregateDevice.sync('name', 74, 32))

expectType<void>(destroyAggregateDevice.sync(1))
expectType<Promise<void>>(destroyAggregateDevice(1))
expectError(destroyAggregateDevice.sync())
expectError(destroyAggregateDevice.sync('1'))
