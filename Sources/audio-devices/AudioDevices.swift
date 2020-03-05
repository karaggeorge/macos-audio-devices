import Cocoa
import CoreAudio

struct AudioDevice: Hashable, Codable, Identifiable {
  let id: AudioDeviceID
  let name: String
  let uid: String
  let isInput: Bool
  let isOutput: Bool
  var volume: Double?

  init(withId deviceId: AudioDeviceID) throws {
    id = deviceId
    var deviceName: CFString = "" as CFString
    var deviceUID: CFString = "" as CFString

    do {
      try CoreAudioData.getAudioData(id: deviceId, selector: kAudioObjectPropertyName, value: &deviceName)
    } catch {
      throw AudioDevices.Error.invalidDeviceId
    }

    name = deviceName as String

    do {
      try CoreAudioData.getAudioData(id: deviceId, selector: kAudioDevicePropertyDeviceUID, value: &deviceUID)
    } catch {
      throw AudioDevices.Error.invalidDeviceId
    }

    uid = deviceUID as String

    let inputChannels: UInt32 = CoreAudioData.getAudioDataSize(
      id: deviceId,
      selector: kAudioDevicePropertyStreams,
      scope: kAudioDevicePropertyScopeInput
    )

    isInput = inputChannels > 0

    let outputChannels: UInt32 = CoreAudioData.getAudioDataSize(
      id: deviceId,
      selector: kAudioDevicePropertyStreams,
      scope: kAudioDevicePropertyScopeOutput
    )

    isOutput = outputChannels > 0

    let hasVolume = CoreAudioData.hasAudioData(
      id: deviceId,
      selector: kAudioDevicePropertyVolumeScalar,
      scope: kAudioDevicePropertyScopeOutput
    )

    if hasVolume {
      var deviceVolume: Float32 = 0.0

      do {
        try CoreAudioData.getAudioData(
          id: deviceId,
          selector: kAudioDevicePropertyVolumeScalar,
          scope: kAudioDevicePropertyScopeOutput,
          value: &deviceVolume
        )

        volume = Double(deviceVolume)
      } catch {
        volume = nil
      }
    } else {
      volume = nil
    }
  }

  mutating func setVolume(_ newVolume: Double) throws {
    if volume == nil {
      throw AudioDevices.Error.volumeNotSupported
    }

    guard newVolume >= 0 && newVolume <= 1 else {
      throw AudioDevices.Error.invalidVolumeValue
    }

    var value = Float32(newVolume)
    try CoreAudioData.setAudioData(
      id: id,
      selector: kAudioDevicePropertyVolumeScalar,
      scope: kAudioDevicePropertyScopeOutput,
      value: &value
    )

    volume = newVolume
  }
}

struct AudioDeviceType {
  let selector: AudioObjectPropertySelector
  let isInput: Bool
  let isOutput: Bool

  static let input = AudioDeviceType(
    selector: kAudioHardwarePropertyDefaultInputDevice,
    isInput: true,
    isOutput: false
  )
  static let output = AudioDeviceType(
    selector: kAudioHardwarePropertyDefaultOutputDevice,
    isInput: false,
    isOutput: true
  )
  static let system = AudioDeviceType(
    selector: kAudioHardwarePropertyDefaultSystemOutputDevice,
    isInput: false,
    isOutput: true
  )
}

class AudioDevices {
  static var all: [AudioDevice] {
    let devicesSize = CoreAudioData.getAudioDataSize(selector: kAudioHardwarePropertyDevices)
    let devicesLength = devicesSize / UInt32(MemoryLayout<AudioDeviceID>.size)

    var deviceIds: [AudioDeviceID] = Array(repeating: 0, count: Int(devicesLength))

    do {
      try CoreAudioData.getAudioData(
        selector: kAudioHardwarePropertyDevices,
        initialSize: devicesSize,
        value: &deviceIds
      )
    } catch {
      return []
    }

    return deviceIds.compactMap { try? AudioDevice(withId: $0) }
  }

  static var input: [AudioDevice] {
    return all.filter { $0.isInput }
  }

  static var output: [AudioDevice] {
    return all.filter { $0.isOutput }
  }

  static func getDefaultDevice(for deviceType: AudioDeviceType) throws -> AudioDevice {
    var deviceId: AudioDeviceID = 0

    try CoreAudioData.getAudioData(
      selector: deviceType.selector,
      value: &deviceId
    )

    return try AudioDevice(withId: deviceId)
  }

  static func setDefaultDevice(for deviceType: AudioDeviceType, device: AudioDevice) throws {
    if (deviceType.isInput && !device.isInput) || (deviceType.isOutput && !device.isOutput) {
      throw Error.invalidDevice
    }

    var deviceId: AudioDeviceID = device.id

    try CoreAudioData.setAudioData(
      selector: deviceType.selector,
      value: &deviceId
    )
  }

  /// This function uses two or more devices to create an aggregate device.
  ///
  /// Usage:
  ///
  ///     createAggregate(
  ///       name: "Aggregate Device Name",
  ///       mainDevice: AudioDevice(withId: 73),
  ///       otherDevices: [AudioDevice(withId: 84)],
  ///       shouldStack: true
  ///     )
  ///
  /// - Parameter name: The name for the device to be created
  /// - Parameter mainDevice: The main device
  /// - Parameter otherDevices: The rest of the devices to be combined with the main one
  /// - Parameter shouldStack: Whether or not it should create a Multi-Output Device
  ///
  /// - Returns: The newly created device.
  static func createAggregate(
    name: String,
    uid: String = UUID().uuidString,
    mainDevice: AudioDevice,
    otherDevices: [AudioDevice],
    shouldStack: Bool = false
  ) throws -> AudioDevice {
    let allDevices = [mainDevice] + otherDevices
    let deviceList = allDevices.map {
      return [
        kAudioSubDeviceUIDKey: $0.uid,
        kAudioSubDeviceDriftCompensationKey: $0.id == mainDevice.id ? 0 : 1
      ]
    }

    let description: [String: Any] = [
      kAudioAggregateDeviceNameKey: name,
      kAudioAggregateDeviceUIDKey: uid,
      kAudioAggregateDeviceSubDeviceListKey: deviceList,
      kAudioAggregateDeviceMasterSubDeviceKey: mainDevice.uid,
      kAudioAggregateDeviceIsStackedKey: shouldStack ? 1 : 0
    ]

    var aggregateDeviceId: AudioDeviceID = 0

    let result = AudioHardwareCreateAggregateDevice(description as CFDictionary, &aggregateDeviceId)
    guard result == 0 else {
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(result), userInfo: nil)
    }

    return try AudioDevice(withId: aggregateDeviceId)
  }

  static func destroyAggregate(device: AudioDevice) throws {
    let result = AudioHardwareDestroyAggregateDevice(device.id)

    guard result == 0 else {
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(result), userInfo: nil)
    }
  }

  enum Error: Swift.Error {
    case invalidDeviceId
    case unknownError
    case invalidDevice
    case volumeNotSupported
    case invalidVolumeValue
  }
}

struct CoreAudioData {
  static func getAudioData<T>(
    id: UInt32 = AudioObjectID(kAudioObjectSystemObject),
    selector: AudioObjectPropertySelector,
    scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
    element: AudioObjectPropertyElement = kAudioObjectPropertyElementMaster,
    initialSize: UInt32 = UInt32(MemoryLayout<T>.size),
    value: UnsafeMutablePointer<T>
  ) throws {
    var size = initialSize
    var address = AudioObjectPropertyAddress(
      mSelector: selector,
      mScope: scope,
      mElement: element
    )

    let result = AudioObjectGetPropertyData(id, &address, 0, nil, &size, value)

    if result != 0 {
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(result), userInfo: nil)
    }
  }

  static func setAudioData<T>(
    id: UInt32 = AudioObjectID(kAudioObjectSystemObject),
    selector: AudioObjectPropertySelector,
    scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
    element: AudioObjectPropertyElement = kAudioObjectPropertyElementMaster,
    value: UnsafeMutablePointer<T>
  ) throws {
    let size = UInt32(MemoryLayout<T>.size)
    var address = AudioObjectPropertyAddress(
      mSelector: selector,
      mScope: scope,
      mElement: element
    )

    let result = AudioObjectSetPropertyData(id, &address, 0, nil, size, value)

    if result != 0 {
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(result), userInfo: nil)
    }
  }

  static func hasAudioData(
    id: UInt32 = AudioObjectID(kAudioObjectSystemObject),
    selector: AudioObjectPropertySelector,
    scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
    element: AudioObjectPropertyElement = kAudioObjectPropertyElementMaster
  ) -> Bool {
    var address = AudioObjectPropertyAddress(
      mSelector: selector,
      mScope: scope,
      mElement: element
    )

    return AudioObjectHasProperty(id, &address)
  }

  static func getAudioDataSize(
    id: UInt32 = AudioObjectID(kAudioObjectSystemObject),
    selector: AudioObjectPropertySelector,
    scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
    element: AudioObjectPropertyElement = kAudioObjectPropertyElementMaster
  ) -> UInt32 {
    var size: UInt32 = 0

    var address = AudioObjectPropertyAddress(
      mSelector: selector,
      mScope: scope,
      mElement: element
    )

    let result = AudioObjectGetPropertyDataSize(id, &address, 0, nil, &size)

    guard result == 0 else {
      return 0
    }

    return size
  }
}
