
export type TransportType = 'avb'
  | 'aggregate'
  | 'airplay'
  | 'autoaggregate'
  | 'bluetooth'
  | 'bluetoothle'
  | 'builtin'
  | 'displayport'
  | 'firewire'
  | 'hdmi'
  | 'pci'
  | 'thunderbolt'
  | 'usb'
  | 'virtual'
  | 'unknown'

export interface Device {
  /*
  The unique ID of the device.
  */
  id: number;

  /**
  The human readable name of the device.
  */
  name: string;

  /**
  The UID of the device for the [`AVCaptureDevice`](https://developer.apple.com/documentation/avfoundation/avcapturedevice) API.
  */
  uid: string;

  /**
  Whether the device is an output device.
  */
  isOutput: boolean;

  /**
  Whether the device is an input device.
  */
  isInput: boolean;

  /**
  A number between 0 and 1 representing the volume setting of the device.

  Only applicable on output devices that support it. It will be undefined otherwise.
  */
  volume?: number;

  /**
  The [transport type](https://developer.apple.com/documentation/avfoundation/avcapturedevice/1387804-transporttype) of the device.
  */
  transportType: TransportType
}

export const getAllDevices: {
  /**
  Get all the audio devices.

  @returns A promise that resolves with an array of devices.

  @example
  ```
  const devices = await getAllDevices();
  ```
  */
  (): Promise<Device[]>;

  /**
  Get all the audio devices.

  @returns An array of devices.

  @example
  ```
  const devices = getAllDevices.sync();
  ```
  */
  sync: () => Device[];
};

export const getDevice: {
  /**
  Get an audio device by ID.

  @returns A promise that resolves with the device.

  @example
  ```
  const device = await getDevice(73);
  ```
  */
  (): Promise<Device>;

  /**
  Get an audio device by ID.

  @returns The device.

  @example
  ```
  const device = getDevice.sync(73);
  ```
  */
  sync: () => Device;
};

export const getOutputDevices: {
  /**
  Get all the output devices.

  @returns A promise that resolves with an array of output devices.

  @example
  ```
  const devices = await getOutputDevices();
  ```
  */
  (): Promise<Device[]>;

  /**
  Get all the output devices.

  @returns An array of output devices.

  @example
  ```
  const devices = getOutputDevices.sync();
  ```
  */
  sync: () => Device[];
};

export const getInputDevices: {
  /**
  Get all the input devices.

  @returns A promise that resolves with an array of input devices.

  @example
  ```
  const devices = await getInputDevices();
  ```
  */
  (): Promise<Device[]>;

  /**
  Get all the input devices.

  @returns An array of input devices.

  @example
  ```
  const devices = getInputDevices.sync();
  ```
  */
  sync: () => Device[];
};

export const getDefaultOutputDevice: {
  /**
  Get the default output device.

  @returns A promise that resolves with the default output device.

  @example
  ```
  const defaultOutputDevice = await getDefaultOutputDevice();
  ```
  */
  (): Promise<Device>;

  /**
  Get the default output device.

  @returns The default output device.

  @example
  ```
  const defaultOutputDevice = getDefaultOutputDevice.sync();
  ```
  */
  sync: () => Device;
};

export const getDefaultInputDevice: {
  /**
  Get the default input device.

  @returns A promise that resolves with the default input device.

  @example
  ```
  const defaultInputDevice = await getDefaultInputDevice();
  ```
  */
  (): Promise<Device>;

  /**
  Get the default input device.

  @returns The default input device.

  @example
  ```
  const defaultInputDevice = getDefaultInputDevice.sync();
  ```
  */
  sync: () => Device;
};

export const getDefaultSystemDevice: {
  /**
  Get the default system sound effects device.

  @returns A promise that resolves with the default system device.

  @example
  ```
  const defaultSystemDevice = await getDefaultSystemDevice();
  ```
  */
  (): Promise<Device>;

  /**
  Get the default system sound effects device.

  @returns The default system device.

  @example
  ```
  const defaultSystemDevice = getDefaultSystemDevice.sync();
  ```
  */
  sync: () => Device;
}

export const setDefaultOutputDevice: {
  /**
  Set the default output device.

  @param deviceId - The ID of the output device to set as the default.

  @example
  ```
  await setDefaultOutputDevice(74);
  ```
  */
  (deviceId: number): Promise<void>;

  /**
  Set the default output device.

  @param deviceId - The ID of the output device to set as the default.

  @example
  ```
  setDefaultOutputDevice.sync(74);
  ```
  */
  sync: (deviceId: number) => void;
};

export const setDefaultInputDevice: {
  /**
  Set the default input device.

  @param deviceId - The ID of the input device to set as the default.

  @example
  ```
  await setDefaultInputDevice(74);
  ```
  */
  (deviceId: number): Promise<void>;

  /**
  Set the default input device.

  @param deviceId - The ID of the input device to set as the default.

  @example
  ```
  setDefaultInputDevice.sync(74);
  ```
  */
  sync: (deviceId: number) => void;
};

export const setDefaultSystemDevice: {
  /**
  Set the default system sound effects device (only output devices).

  @param deviceId - The ID of the output device to set as the default for system sounds.

  @example
  ```
  await setDefaultSystemDevice(74);
  ```
  */
  (deviceId: number): Promise<void>;

  /**
  Set the default system sound effects device (only output devices).

  @param deviceId - The ID of the output device to set as the default for system sounds.

  @example
  ```
  setDefaultSystemDevice.sync(74);
  ```
  */
  sync: (deviceId: number) => void;
};

export const getOutputDeviceVolume: {
  /**
  Get the volume of an output device that supports it.

  @param deviceId - The ID of the output device.
  @returns A promise that resolves with the volume of the device.

  @example
  ```
  const volume = await getOutputDeviceVolume(74);
  ```
  */
  (deviceId: number): Promise<number>;

  /**
  Get the volume of an output device that supports it.

  @param deviceId - The ID of the output device.
  @returns The volume of the device.

  @example
  ```
  const volume = getOutputDeviceVolume.sync(74);
  ```
  */
  sync: (deviceId: number) => number;
};

export const setOutputDeviceVolume: {
  /**
  Set the volume of an output device that supports it.

  @param deviceId - The ID of the output device.
  @param voluem - The volume level between 0 and 1.

  @example
  ```
  await setOutputDeviceVolume(74, 0.5);
  ```
  */
  (deviceId: number, volume: number): Promise<void>;

  /**
  Set the volume of an output device that supports it.

  @param deviceId - The ID of the output device.
  @param voluem - The volume level between 0 and 1.

  @example
  ```
  setOutputDeviceVolume.sync(74, 0.5);
  ```
  */
  sync: (deviceId: number, volume: number) => void;
};

export const createAggregateDevice: {
  /**
  Create an [aggregate device](https://support.apple.com/en-us/HT202000) from other existing devices.

  Note that aggregate devices do not support volume, so make sure to update the volume on the devices used to create it instead.

  @param name - The name of the aggregate device.
  @param mainDeviceId - The ID of main device.
  @param otherDeviceIds - Array of the rest of the device IDs to combine.
  @param options.multiOutput - Wether to create the device as a “Multi-Output Device”.
  @returns A promise that resolves with the newly created aggregate device.

  @example
  ```
  const aggregateDevice = await createAggregateDevice("My Aggregate Device", 74, [81, 86], {multiOutput: true});
  ```
  */
  (name: string, mainDeviceId: number, otherDeviceIds: number[], options?: { multiOutput: boolean }): Promise<Device>;

  /**
  Create an aggregate device from other existing devices.

  @param name - The name of the aggregate device.
  @param mainDeviceId - The ID of main device.
  @param otherDeviceIds - Array of the rest of the device IDs to combine.
  @param options.multiOutput - Wether to create the device as a “Multi-Output Device”.
  @returns The newly created aggregate device.

  @example
  ```
  const aggregateDevice = createAggregateDevice.sync("My Aggregate Device", 74, [81, 86], {multiOutput: true});
  ```
  */
  sync: (name: string, mainDeviceId: number, otherDeviceIds: number[], options?: { multiOutput: boolean }) => Device;
};

export const destroyAggregateDevice: {
  /**
  Destroy an aggregate device.

  @param deviceId - The ID of the output device.

  @example
  ```
  await destroyAggregateDevice(74);
  ```
  */
  (deviceId: number): Promise<void>;

  /**
  Destroy an aggregate device.

  @param deviceId - The ID of the output device.

  @example
  ```
  destroyAggregateDevice.sync(74);
  ```
  */
  sync: (deviceId: number) => void;
};
