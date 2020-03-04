
export interface Device {
  volume: number;
  uid: string;
  hasVolume: boolean;
  id: number;
  isOutput: boolean;
  isInput: boolean;
  name: string;
}

/**
Get all the audio devices

@example
```
const devices = getAllDevices();
```

@returns An array of devices
*/
export const getAllDevices: () => Device[];

/**
Get all the output devices

@example
```
const devices = getOutputDevices();
```

@returns An array of output devices
*/
export const getOutputDevices: () => Device[];

/**
Get all the input devices

@example
```
const devices = getInputDevices();
```

@returns An array of input devices
*/
export const getInputDevices: () => Device[];

/**
Get the default output device

@example
```
const defaultOutputDevice = getDefaultOutputDevice()
```

@returns The default output device.
*/
export const getDefaultOutputDevice: () => Device;

/**
Get the default input device

@example
```
const defaultInputDevice = getDefaultInputDevice()
```

@returns The default input device.
*/
export const getDefaultInputDevice: () => Device;

/**
Get the default system sound effects device

@example
```
const defaultSystemDevice = getDefaultSystemDevice()
```

@returns The default system device.
*/
export const getDefaultSystemDevice: () => Device;

/**
Set the default output device

@example
```
setDefaultOutputDevice(74)
```

@param deviceId - The ID of the output device to set as the default
*/
export const setDefaultOutputDevice: (deviceId: number) => void;

/**
Set the default input device

@example
```
setDefaultInputDevice(74)
```

@param deviceId - The ID of the input device to set as the default
*/
export const setDefaultInputDevice: (deviceId: number) => void;

/**
Set the default system sound effects device (only output devices)

@example
```
setDefaultSystemDevice(74)
```

@param deviceId - The ID of the output device to set as the default for system sounds
*/
export const setDefaultSystemDevice: (deviceId: number) => void;

/**
Get the volume of an output device that supports it

@example
```
const volume = getOutputDeviceVolume(74)
```

@param deviceId - The ID of the output device
@returns The volume of the device
*/
export const getOutputDeviceVolume: (deviceId: number) => number;

/**
Set the volume of an output device that supports it

@example
```
setOutputDeviceVolume(74, 0.5)
```

@param deviceId - The ID of the output device
@param voluem - The voume level between 0 and 1
*/
export const setOutputDeviceVolume: (deviceId: number, volume: number) => void;

/**
Create an aggregate device from other existing devices.

@example
```
const aggregateDevice = createAggregateDevice("My Aggregate Device", 74, [81, 86], {multiOutput: true});
```

@param name - The name of the aggregate device
@param mainDeviceId - The id of main device
@param otherDeviceIds - Array of the rest of the device ids to combine
@param options.multiOutput - Wether to create the device as a Multi-Output Device
@returns The newly created aggregate device
*/
export const createAggregateDevice: (name: string, mainDeviceId: number, otherDeviceIds: number[], options?: {multiOutput: boolean}) => Device;

/**
Destroy an aggregate device

@example
```
destroyAggregateDevice(74)
```

@param deviceId - The ID of the output device
*/
export const destroyAggregateDevice: (deviceId: number) => void;


/**
Whether or not this module is supported.
*/
export const isSupported: boolean;
