
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
Whether or not this module is supported.
*/
export const isSupported: boolean;
