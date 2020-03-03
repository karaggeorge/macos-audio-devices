# macos-audio-devices [![Actions Status](https://github.com/karaggeorge/macos-audio-devices/workflows/Node%20CI/badge.svg)](https://github.com/karaggeorge/macos-audio-devices/actions)


> Get, set and configure the Audio Devices on macOS

Requires macOS 10.12 or later. macOS 10.13 or earlier needs to download the [Swift runtime support libraries](https://support.apple.com/kb/DL1998).

## Run as CLI

### Using [npx](https://github.com/zkat/npx)

```
$ npx macos-audio-devices
```

### Installing

```
$ npm install -g macos-audio-devices
$ audio-devices
```

### Usage

```
Usage: audio-devices <command> [options]

Groups:
  output          Get or set the default output device
  input           Get or set the default input device
  volume          Get or set the volume of an output device

Commands:
  list            List the available audio devices
  help            Prints help information
```

## Node API

### Installation

```
$ npm install macos-audio-devices
```

### Usage

```js
const audioDevices = require('macos-audio-devices');

const outputDevices = audioDevices.getOutputDevices();
const targetDevice = outputDevices[0];

const defaultDevice = audioDevices.getDefaultOutputDevice();

if (defaultDevice.id !== targetDevice.id) {
  setDefaultOutputDevice(targetDevice.id)
}

if (targetDevice.hasVolume) {
  setOutputDeviceVolume(targetDevice.id, 0.5) // 50%
}
```

### API

#### Device

##### `id: number`

The unique id of the device 

##### `uid: string`

The UID of the device for the [`AVCaptureDevice`](https://developer.apple.com/documentation/avfoundation/avcapturedevice) API

##### `name: string`

The human readable name of the device

##### `isOutput: bool`

Whether the device is an output device

##### `isInput: bool`

Whether the device is an input device

##### `hasVolume: bool`

Whether the device supports volume. Only applicable to output devices.

##### `volume: number`

A number between 0 and 1 representing the volume setting of the device. Only applicable on output devices that have `hasVolume` of `true`.

#### `getAllDevices(): Device[]`

Get all the audio devices

#### `getOutputDevices(): Device[]`

Get all the output devices

#### `getInputDevices(): Device[]`

Get all the input devices

#### `getDefaultOutputDevice(): Device`

Get all the default output device

#### `getDefaultInputDevice(): Device`

Get all the default input device

#### `setDefaultOutputDevice(deviceId: number): void`

Set the default output device.

##### `deviceId: number`

The [unique id](#id-number) of an output device

#### `setDefaultInputDevice(deviceId: number): void`

Set the default input device.

##### `deviceId: number`

The [unique id](#id-number) of an input device

#### `getOutputDeviceVolume(deviceId: number): void`

Get the volume level of an output device that supports it. Throws an error if the device is not an output device or it doesn't support volume.

##### `deviceId: number`

The [unique id](#id-number) of the supported output device

#### `setOutputDeviceVolume(deviceId: number, volume: number): void`

Set the volume level of an output device that supports it. Throws an error if the device is not an output device or it doesn't support volume.

##### `deviceId: number`

The [unique id](#id-number) of the supported output device

##### `volume: number`

The volume level to set the device to. Must be between 0 and 1, otherwise and error will be thrown.

## Contributing

If you want to use this and need more features or find a bug, please open an issue and I'll do my best to implement.

PRs are always welcome as well 😃

## License

MIT
