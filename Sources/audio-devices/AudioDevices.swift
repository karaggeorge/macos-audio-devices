import Cocoa
import CoreAudio

enum AudioDevicesError: Error {
    case invalidDeviceId
    case unknownError
    case invalidDevice
    case volumeNotSupported
    case invalidVolumeValue
}

struct AudioDevice: Hashable, Codable, Identifiable {
  let id: AudioDeviceID
  let name: String
  let uid: String
  let isInput: Bool
  let isOutput: Bool
  let volume: Double?

  init(withId deviceId: AudioDeviceID) throws {
    id = deviceId
    var deviceName: CFString = "" as CFString
    var deviceUID: CFString = "" as CFString

    guard CoreAudioData.getAudioData(
      id: deviceId, selector: kAudioObjectPropertyName, value: &deviceName
    ) else {
      throw AudioDevicesError.invalidDeviceId
    }

    name = deviceName as String

    guard CoreAudioData.getAudioData(
      id: deviceId, selector: kAudioDevicePropertyDeviceUID, value: &deviceUID
    ) else {
      throw AudioDevicesError.invalidDeviceId
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

      if CoreAudioData.getAudioData(
        id: deviceId,
        selector: kAudioDevicePropertyVolumeScalar,
        scope: kAudioDevicePropertyScopeOutput,
        value: &deviceVolume
      ) {
        volume = Double(deviceVolume)
      } else {
        volume = nil
      }
    } else {
      volume = nil
    }
  }

  func setVolume(_ newVolume: Double) throws {
    if volume == nil {
      throw AudioDevicesError.volumeNotSupported
    }

    guard newVolume >= 0 && newVolume <= 1 else {
      throw AudioDevicesError.invalidVolumeValue
    }

    var value = Float32(newVolume)
    guard CoreAudioData.setAudioData(
      id: id,
      selector: kAudioDevicePropertyVolumeScalar,
      scope: kAudioDevicePropertyScopeOutput,
      value: &value
      ) else {
        throw AudioDevicesError.unknownError
    }
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
  static func getAudioDevices() -> [AudioDevice] {
    let devicesSize = CoreAudioData.getAudioDataSize(selector: kAudioHardwarePropertyDevices)
    let devicesLength = devicesSize / UInt32(MemoryLayout<AudioDeviceID>.size)

    var deviceIds: [AudioDeviceID] = Array(repeating: 0, count: Int(devicesLength))

    guard CoreAudioData.getAudioData(
      selector: kAudioHardwarePropertyDevices,
      initialSize: devicesSize,
      value: &deviceIds
    ) else {
      return []
    }

    return deviceIds.compactMap {
      do {
        return try AudioDevice(withId: $0)
      } catch {
        return nil
      }
    }
  }

  static func getDefaultDevice(deviceType: AudioDeviceType) throws -> AudioDevice {
    var deviceId: AudioDeviceID = 0

    guard CoreAudioData.getAudioData(
      selector: deviceType.selector,
      value: &deviceId
    ) else {
      throw AudioDevicesError.unknownError
    }

    return try AudioDevice(withId: deviceId)
  }

  static func setDefaultDevice(deviceType: AudioDeviceType, device: AudioDevice) throws {
    if (deviceType.isInput && !device.isInput) || (deviceType.isOutput && !device.isOutput) {
      throw AudioDevicesError.invalidDevice
    }

    var deviceId: AudioDeviceID = device.id

    guard CoreAudioData.setAudioData(
      selector: deviceType.selector,
      value: &deviceId
    ) else {
      throw AudioDevicesError.unknownError
    }
  }

  static func createAggregate(
    name: String,
    uid: String = UUID().uuidString,
    mainDevice: AudioDevice,
    otherDevices: [AudioDevice],
    stack: Bool = false
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
      kAudioAggregateDeviceIsStackedKey: stack ? 1 : 0
    ]

    var aggregateDeviceId: AudioDeviceID = 0

    guard AudioHardwareCreateAggregateDevice(description as CFDictionary, &aggregateDeviceId) == 0 else {
      throw AudioDevicesError.unknownError
    }

    return try AudioDevice(withId: aggregateDeviceId)
  }

  static func destroyAggregate(device: AudioDevice) throws {
    guard AudioHardwareDestroyAggregateDevice(device.id) == 0 else {
      throw AudioDevicesError.unknownError
    }
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
  ) -> Bool {
    var size = initialSize
    var address = AudioObjectPropertyAddress(
      mSelector: selector,
      mScope: scope,
      mElement: element
    )

    let result = AudioObjectGetPropertyData(id, &address, 0, nil, &size, value)

    return result == 0
  }

  static func setAudioData<T>(
    id: UInt32 = AudioObjectID(kAudioObjectSystemObject),
    selector: AudioObjectPropertySelector,
    scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
    element: AudioObjectPropertyElement = kAudioObjectPropertyElementMaster,
    value: UnsafeMutablePointer<T>
  ) -> Bool {
    let size = UInt32(MemoryLayout<T>.size)
    var address = AudioObjectPropertyAddress(
      mSelector: selector,
      mScope: scope,
      mElement: element
    )

    return AudioObjectSetPropertyData(id, &address, 0, nil, size, value) == 0
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
