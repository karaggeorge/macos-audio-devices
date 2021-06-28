# macos-audio-devices [![Actions Status](https://github.com/karaggeorge/macos-audio-devices/workflows/Node%20CI/badge.svg)](https://github.com/karaggeorge/macos-audio-devices/actions)

> Get, set and configure the audio devices on macOS

Requires macOS 10.12 or later. macOS 10.13 or earlier needs to download the [Swift runtime support libraries](https://support.apple.com/kb/DL1998).

## Run as CLI

### Using [npx](https://github.com/npm/npx)

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
  system          Get or set the default device for system sounds
  volume          Get or set the volume of an output device
  mute            Mute or unmute audio device
  aggregate       Create or delete aggregate audio devices

Commands:
  list            List the available audio devices
  get             Get a device by its ID
  toggle          Toggle muting state for audio device
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

const outputDevices = audioDevices.getOutputDevices.sync();
const targetDevice = outputDevices[0];

const defaultDevice = audioDevices.getDefaultOutputDevice.sync();

if (defaultDevice.id !== targetDevice.id) {
  setDefaultOutputDevice(targetDevice.id)
}

if (targetDevice.hasVolume) {
  setOutputDeviceVolume(targetDevice.id, 0.5); // 50%
}
```

### API

#### `Device`

##### `id: number`

The unique ID of the device.

##### `uid: string`

The UID of the device for the [`AVCaptureDevice`](https://developer.apple.com/documentation/avfoundation/avcapturedevice) API.

##### `name: string`

The human readable name of the device.

##### `isOutput: bool`

Whether the device is an output device.

##### `isInput: bool`

Whether the device is an input device.

##### `volume: number`

A number between 0 and 1 representing the volume setting of the device. Only applicable on output devices that support it. It will be undefined otherwise.

##### `transportType: TransportType`

The value of this property represents the [transport type](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1387804-transporttype) of the device (USB, PCI, etc).

#### `TransportType: string`

Can be one of:
- `avb`
- `aggregate`
- `airplay`
- `autoaggregate`
- `bluetooth`
- `bluetoothle`
- `builtin`
- `displayport`
- `firewire`
- `hdmi`
- `pci`
- `thunderbolt`
- `usb`
- `virtual`
- `unknown`

#### `ChannelType: enum`

Can be:
  - `input`
  - `output`

#### Sync

Each method described below is asynchronous, but can be called synchronously, by calling `.sync` on it instead. For example:

```js
getDevice(73).then(device => {…}); // async

const device = getDevice.sync(73); // sync
```

#### `getAllDevices(): Promise<Device[]>`

Get all the audio devices.

#### `getOutputDevices(): Promise<Device[]>`

Get all the output devices.

#### `getInputDevices(): Promise<Device[]>`

Get all the input devices.

#### `getDevice(deviceId: number): Promise<Device>`

Get an audio device by its ID.

##### `deviceId: number`

The [unique ID](#id-number) of the device.

#### `getDefaultOutputDevice(): Promise<Device>`

Get all the default output device.

#### `getDefaultInputDevice(): Promise<Device>`

Get all the default input device.

#### `getDefaultSystemDevice(): Promise<Device>`

Get all the default input device.

#### `setDefaultOutputDevice(deviceId: number): Promise<void>`

Set the default output device.

##### `deviceId: number`

The [unique ID](#id-number) of an output device.

#### `setDefaultInputDevice(deviceId: number): Promise<void>`

Set the default input device.

##### `deviceId: number`

The [unique ID](#id-number) of an input device.

#### `setDefaultSystemDevice(deviceId: number): Promise<void>`

Set the default input device. Can only be an output device.

##### `deviceId: number`

The [unique ID](#id-number) of an output device.

#### `getOutputDeviceVolume(deviceId: number): Promise<void>`

Get the volume level of an output device that [supports it](#volume-number).

Throws an error if the device is not an output device or if it doesn't support volume.

##### `deviceId: number`

The [unique ID](#id-number) of the supported output device.

#### `setOutputDeviceVolume(deviceId: number, volume: number): Promise<void>`

Set the volume level of an output device that [supports it](#volume-number).

Throws an error if the device is not an output device or if it doesn't support volume.

##### `deviceId: number`

The [unique ID](#id-number) of the supported output device.

##### `volume: number`

The volume level to set the device to. Must be between 0 and 1, otherwise and error will be thrown.

#### `getDeviceMute(deviceId: number, channelType: ChannelType? = null): Promise<void>`

Get muting state for audio device.

##### `deviceId: number`

The [unique ID](#id-number) of the supported device.

##### `channelType: ChannelType`

[optional] [Channel type](#channeltype-enum) to get information from.

#### `toggleDeviceMute(deviceId: number, channelType: ChannelType? = null): Promise<void>`

Toggle muting state for audio device.

##### `deviceId: number`

The [unique ID](#id-number) of the supported device.

##### `channelType: ChannelType`

[optional] [Channel type](#channeltype-enum) to use.

#### `createAggregateDevice(name: string, mainDeviceId: number, otherDeviceIds: number[], options: object): Promise<Device>`

Create an [aggregate device](https://support.apple.com/en-us/HT202000) from other existing devices.

Note that aggregate devices do not support volume, so make sure to update the volume on the devices used to create it instead.

##### `name: string`

Human-readable name for the new device.

##### `mainDeviceId: number`

The [unique ID](#id-number) of the main device.

##### `otherDeviceIds: number[]`

An array od [unique IDs](#id-number) of the rest of the devices. Needs to have at least one.

##### `options: object`

###### `options.multiOutput: boolean`

Whether or not to create a [Multi-Output Device](https://support.apple.com/guide/audio-midi-setup/play-audio-through-multiple-devices-at-once-ams7c093f372/mac).

If this is enabled, all the devices need to be output devices.

#### `destroyAggregateDevice(deviceId: number): Promise<void>`

Destroy an aggregate device.

##### `deviceId: number`

The [unique ID](#id-number) of an aggregate device.

## Contributing

If you want to use this and need more features or find a bug, please open an issue and I'll do my best to implement.

PRs are always welcome as well 😃
