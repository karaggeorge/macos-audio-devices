
export interface Device {
  id: number;
  name: string;
  uid: string;
  isOutput: boolean;
  isInput: boolean;
  // If the volume is missing the device does not support it
  volume?: number;
}

export const getAllDevices: {
  /**
  Get all the audio devices

  @example
  ```
  const devices = await getAllDevices();
  ```

  @returns A promise that resolves with an array of devices
  */
  (): Promise<Device[]>;

  /**
  Get all the audio devices

  @example
  ```
  const devices = getAllDevices.sync();
  ```

  @returns An array of devices
  */
  sync: () => Device[];
};

export const getDevice: {
  /**
  Get an audio device by id

  @example
  ```
  const device = await getDevice(73);
  ```

  @returns A promise that resolves with the device
  */
  (): Promise<Device>;

  /**
  Get an audio device by id

  @example
  ```
  const device = getDevice.sync(73);
  ```

  @returns The device
  */
  sync: () => Device;
};

export const getOutputDevices: {
  /**
  Get all the output devices

  @example
  ```
  const devices = await getOutputDevices();
  ```

  @returns A promise that resolves with an array of output devices
  */
  (): Promise<Device[]>;

  /**
  Get all the output devices

  @example
  ```
  const devices = getOutputDevices.sync();
  ```

  @returns An array of output devices
  */
  sync: () => Device[];
};

export const getInputDevices: {
  /**
  Get all the input devices

  @example
  ```
  const devices = await getInputDevices();
  ```

  @returns A promise that resolves with an array of input devices
  */
  (): Promise<Device[]>;

  /**
  Get all the input devices

  @example
  ```
  const devices = getInputDevices.sync();
  ```

  @returns An array of input devices
  */
  sync: () => Device[];
};

export const getDefaultOutputDevice: {
  /**
  Get the default output device

  @example
  ```
  const defaultOutputDevice = await getDefaultOutputDevice()
  ```

  @returns A promise that resolves with the default output device.
  */
  (): Promise<Device>;

  /**
  Get the default output device

  @example
  ```
  const defaultOutputDevice = getDefaultOutputDevice.sync()
  ```

  @returns The default output device.
  */
  sync: () => Device;
};

export const getDefaultInputDevice: {
  /**
  Get the default input device

  @example
  ```
  const defaultInputDevice = await getDefaultInputDevice()
  ```

  @returns A promise that resolves with the default input device.
  */
  (): Promise<Device>;

  /**
  Get the default input device

  @example
  ```
  const defaultInputDevice = getDefaultInputDevice.sync()
  ```

  @returns The default input device.
  */
  sync: () => Device;
};

export const getDefaultSystemDevice: {
  /**
  Get the default system sound effects device

  @example
  ```
  const defaultSystemDevice = await getDefaultSystemDevice()
  ```

  @returns A promise that resolves with the default system device.
  */
  (): Promise<Device>;

  /**
  Get the default system sound effects device

  @example
  ```
  const defaultSystemDevice = getDefaultSystemDevice.sync()
  ```

  @returns The default system device.
  */
  sync: () => Device;
}

export const setDefaultOutputDevice: {
  /**
  Set the default output device

  @example
  ```
  await setDefaultOutputDevice(74)
  ```

  @param deviceId - The ID of the output device to set as the default
  */
  (deviceId: number): Promise<void>;

  /**
  Set the default output device

  @example
  ```
  setDefaultOutputDevice.sync(74)
  ```

  @param deviceId - The ID of the output device to set as the default
  */
  sync: (deviceId: number) => void;
};

export const setDefaultInputDevice: {
  /**
  Set the default input device

  @example
  ```
  await setDefaultInputDevice(74)
  ```

  @param deviceId - The ID of the input device to set as the default
  */
  (deviceId: number): Promise<void>;

  /**
  Set the default input device

  @example
  ```
  setDefaultInputDevice.sync(74)
  ```

  @param deviceId - The ID of the input device to set as the default
  */
  sync: (deviceId: number) => void;
};

export const setDefaultSystemDevice: {
  /**
  Set the default system sound effects device (only output devices)

  @example
  ```
  await setDefaultSystemDevice(74)
  ```

  @param deviceId - The ID of the output device to set as the default for system sounds
  */
  (deviceId: number): Promise<void>;

  /**
  Set the default system sound effects device (only output devices)

  @example
  ```
  setDefaultSystemDevice.sync(74)
  ```

  @param deviceId - The ID of the output device to set as the default for system sounds
  */
  sync: (deviceId: number) => void;
};

export const getOutputDeviceVolume: {
  /**
  Get the volume of an output device that supports it

  @example
  ```
  const volume = await getOutputDeviceVolume(74)
  ```

  @param deviceId - The ID of the output device
  @returns A promise that resolves with the volume of the device
  */
  (deviceId: number): Promise<number>;

  /**
  Get the volume of an output device that supports it

  @example
  ```
  const volume = getOutputDeviceVolume.sync(74)
  ```

  @param deviceId - The ID of the output device
  @returns The volume of the device
  */
  sync: (deviceId: number) => number;
};

export const setOutputDeviceVolume: {
  /**
  Set the volume of an output device that supports it

  @example
  ```
  await setOutputDeviceVolume(74, 0.5)
  ```

  @param deviceId - The ID of the output device
  @param voluem - The voume level between 0 and 1
  */
  (deviceId: number, volume: number): Promise<void>;

  /**
  Set the volume of an output device that supports it

  @example
  ```
  setOutputDeviceVolume.sync(74, 0.5)
  ```

  @param deviceId - The ID of the output device
  @param voluem - The voume level between 0 and 1
  */
  sync: (deviceId: number, volume: number) => void;
};

export const createAggregateDevice: {
  /**
  Create an aggregate device from other existing devices.

  @example
  ```
  const aggregateDevice = await createAggregateDevice("My Aggregate Device", 74, [81, 86], {multiOutput: true});
  ```

  @param name - The name of the aggregate device
  @param mainDeviceId - The id of main device
  @param otherDeviceIds - Array of the rest of the device ids to combine
  @param options.multiOutput - Wether to create the device as a Multi-Output Device
  @returns A promise that resolves with the newly created aggregate device
  */
  (name: string, mainDeviceId: number, otherDeviceIds: number[], options?: { multiOutput: boolean }): Promise<Device>;

  /**
  Create an aggregate device from other existing devices.

  @example
  ```
  const aggregateDevice = createAggregateDevice.sync("My Aggregate Device", 74, [81, 86], {multiOutput: true});
  ```

  @param name - The name of the aggregate device
  @param mainDeviceId - The id of main device
  @param otherDeviceIds - Array of the rest of the device ids to combine
  @param options.multiOutput - Wether to create the device as a Multi-Output Device
  @returns The newly created aggregate device
  */
  sync: (name: string, mainDeviceId: number, otherDeviceIds: number[], options?: { multiOutput: boolean }) => Device;
};

export const destroyAggregateDevice: {
  /**
  Destroy an aggregate device

  @example
  ```
  await destroyAggregateDevice(74)
  ```

  @param deviceId - The ID of the output device
  */
  (deviceId: number): Promise<void>;

  /**
  Destroy an aggregate device

  @example
  ```
  destroyAggregateDevice.sync(74)
  ```

  @param deviceId - The ID of the output device
  */
  sync: (deviceId: number) => void;
};
