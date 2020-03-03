import Cocoa
import CoreAudio

struct AudioDevice: Hashable, Codable {
  let name: String
  let id: AudioDeviceID
  let uid: String
  let isInput: Bool
  let isOutput: Bool
  let hasVolume: Bool
  let volume: Float32

  func getVolumeString() -> String {
    if hasVolume {
      switch volume {
        case 0:
          return " \t🔇"
        case 0...0.33:
          return " \t🔈"
        case 0.33...0.66:
          return " \t🔉"
        case 0.66...1:
          return " \t🔊"
        default:
          return ""
      }
    }

    return ""
  }

  func print(showVolume: Bool = false) {
    Swift.print("\(id) - \(name)", showVolume ? getVolumeString() : "")
  }
}

class AudioDeviceType {
  let selector: AudioObjectPropertySelector

  init(selector: AudioObjectPropertySelector) {
    self.selector = selector;
  }

  static let input = AudioDeviceType(selector: kAudioHardwarePropertyDefaultInputDevice)
  static let output = AudioDeviceType(selector: kAudioHardwarePropertyDefaultOutputDevice)
}

class AudioDevices {
  static func getAudioDevice(_ deviceId: AudioDeviceID) -> AudioDevice? {
    var deviceName: CFString = "" as CFString

    guard getAudioData(
      id: deviceId,
      selector: kAudioObjectPropertyName,
      initialSize: UInt32(MemoryLayout<CFString>.size),
      value: &deviceName
    ) else {
      return nil
    }

    var deviceUID: CFString = "" as CFString

    guard getAudioData(
      id: deviceId,
      selector: kAudioDevicePropertyDeviceUID,
      initialSize: UInt32(MemoryLayout<CFString>.size),
      value: &deviceUID
    ) else {
      return nil
    }

    let inputChannels: UInt32 = getAudioDataSize(
      id: deviceId,
      selector: kAudioDevicePropertyStreams,
      scope: kAudioDevicePropertyScopeInput
    )

    let outputChannels: UInt32 = getAudioDataSize(
      id: deviceId,
      selector: kAudioDevicePropertyStreams,
      scope: kAudioDevicePropertyScopeOutput
    )

    let hasVolume = hasAudioData(
      id: deviceId,
      selector: kAudioDevicePropertyVolumeScalar,
      scope: kAudioDevicePropertyScopeOutput
    )

    var volume: Float32 = 0.0

    if (hasVolume) {
      _ = getAudioData(
        id: deviceId,
        selector: kAudioDevicePropertyVolumeScalar,
        scope: kAudioDevicePropertyScopeOutput,
        initialSize: UInt32(MemoryLayout<Float32>.size),
        value: &volume
      )
    }

    return AudioDevice(
      name: deviceName as String,
      id: deviceId,
      uid: deviceUID as String,
      isInput: inputChannels > 0,
      isOutput: outputChannels > 0,
      hasVolume: hasVolume,
      volume: volume
    )
  }

  static func getAudioDevices() -> [AudioDevice] {
    let devicesSize = getAudioDataSize(selector: kAudioHardwarePropertyDevices)
    let devicesLength = devicesSize / UInt32(MemoryLayout<AudioDeviceID>.size)

    var deviceIds: Array<AudioDeviceID> = Array(repeating: 0, count: Int(devicesLength))
    
    guard getAudioData(
      selector: kAudioHardwarePropertyDevices,
      initialSize: devicesSize,
      value: &deviceIds
    ) else {
      return []
    }

    return deviceIds.compactMap { getAudioDevice($0) }
  }

  static func listAudioDevices(inputOnly: Bool = false, outputOnly: Bool = false, json: Bool = false) {
    let devices = getAudioDevices()

    if json {
      do {
        print(try toJson(devices))
      } catch {
        print("[]")
      }
      return
    }

    if !outputOnly {
      print("Input Devices:\n")
      devices.forEach { device in
        if device.isInput {
          device.print()
        }
      }
    }

    if !inputOnly {
      if !outputOnly {
        print("")
      }

      print("Output Devices:\n")
      devices.forEach { device in
        if device.isOutput {
          device.print(showVolume: true)
        }
      }
    }
  }

  static func getDefaultDevice(deviceType: AudioDeviceType, json: Bool = false) {
    var deviceId: AudioDeviceID = 0

    guard getAudioData(
      selector: deviceType.selector,
      initialSize: UInt32(MemoryLayout<AudioDeviceID>.size),
      value: &deviceId
    ) else {
      print("Something went wrong", to: .standardError)
      return
    }

    let device = getAudioDevice(deviceId)

    guard let unwrappedDevice = device else {
      print("Something went wrong", to: .standardError)
      return
    }
    
    if json {
      do {
        print(try toJson(unwrappedDevice))
      } catch {
        print("{}")
      }
      return
    }

    unwrappedDevice.print(showVolume: deviceType.selector == kAudioHardwarePropertyDefaultOutputDevice)
  }

  static func setDefaultDevice(deviceType: AudioDeviceType, deviceId: Int) {
    var id = UInt32(deviceId)

    let device = getAudioDevice(id)

    guard let unwrappedDevice = device else {
      print("Device with id \(id) does not exist", to: .standardError)
      return;
    }

    guard setAudioData(
      selector: deviceType.selector,
      value: &id
    ) else {
      print("Something went wrong", to: .standardError)
      return
    }

    print("Set \(unwrappedDevice.name) as the default")
  }

  static func getDeviceVolume(deviceId: Int) {
    let device = getAudioDevice(UInt32(deviceId))
    
    guard let unwrappedDevice = device else {
      print("Device with id \(deviceId) does not exist", to: .standardError)
      return;
    }

    guard unwrappedDevice.hasVolume else {
      print("Device \(unwrappedDevice.name) does not support volume", to: .standardError)
      return;
    }

    print(String(format: "%.2f", unwrappedDevice.volume))
  }

  static func setDeviceVolume(deviceId: Int, volume: Float) {
    guard volume >= 0 && volume <= 1 else {
      print("Volume must be a between 0 and 1", to: .standardError)
      return
    }

    let device = getAudioDevice(UInt32(deviceId))
    
    guard let unwrappedDevice = device else {
      print("Device with id \(deviceId) does not exist", to: .standardError)
      return;
    }

    guard unwrappedDevice.hasVolume else {
      print("Device \(unwrappedDevice.name) does not support volume", to: .standardError)
      return;
    }

    var value = volume;
    guard setAudioData(
      id: unwrappedDevice.id,
      selector: kAudioDevicePropertyVolumeScalar,
      scope: kAudioDevicePropertyScopeOutput,
      value: &value
    ) else {
      print("Something went wrong", to: .standardError)
      return
    }

    print("Set volume for \(unwrappedDevice.name) to \(volume)")
  }
}


func getAudioData<T>(
  id: UInt32 = AudioObjectID(kAudioObjectSystemObject),
  selector: AudioObjectPropertySelector,
  scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
  element: AudioObjectPropertyElement = kAudioObjectPropertyElementMaster,
  initialSize: UInt32 = 0,
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

func setAudioData<T>(
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

func hasAudioData(
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

func getAudioDataSize(
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
