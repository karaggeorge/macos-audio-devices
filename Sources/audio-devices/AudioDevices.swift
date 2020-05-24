import Cocoa
import CoreAudio
import AudioToolbox

struct AudioDevice: Hashable, Codable, Identifiable {
  enum Error: Swift.Error {
    case invalidDeviceId
    case invalidDevice
    case volumeNotSupported
    case invalidVolumeValue
  }

  let id: AudioDeviceID
  let name: String
  let uid: String
  let hasInput: Bool
  let hasOutput: Bool
  
  init(withId deviceId: AudioDeviceID) throws {
    id = deviceId
    var deviceName = "" as CFString
    var deviceUID = "" as CFString
    
    do {
      try CoreAudioData.get(id: deviceId, selector: kAudioObjectPropertyName, value: &deviceName)
    } catch {
      throw Error.invalidDeviceId
    }
    
    name = deviceName as String
    
    do {
      try CoreAudioData.get(id: deviceId, selector: kAudioDevicePropertyDeviceUID, value: &deviceUID)
    } catch {
      throw Error.invalidDeviceId
    }
    
    uid = deviceUID as String
    
    let inputChannels: UInt32 = try CoreAudioData.size(
      id: deviceId,
      selector: kAudioDevicePropertyStreams,
      scope: kAudioDevicePropertyScopeInput
    )
    let outputChannels: UInt32 = try CoreAudioData.size(
      id: deviceId,
      selector: kAudioDevicePropertyStreams,
      scope: kAudioDevicePropertyScopeOutput
    )
    
    hasInput = inputChannels > 0
    hasOutput = outputChannels > 0
  }
  
  var inputVolume: Double? {
    do {
      var deviceVolume: Float32 = 0.0
      try CoreAudioData.get(
        id: id,
        selector: kAudioDevicePropertyVolumeScalar,
        scope: kAudioDevicePropertyScopeInput,
        value: &deviceVolume
      )
      
      return Double(deviceVolume)
    } catch {
      return nil
    }
  }

  var outputVolume: Double? {
    do {
      var deviceVolume: Float32 = 0.0
      try CoreAudioData.get(
        id: id,
        selector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
        scope: kAudioDevicePropertyScopeOutput,
        value: &deviceVolume
      )
      
      return Double(deviceVolume)
    } catch {
      return nil
    }
  }
  
  var volume: Double? {
    // TODO: need to think how to handle when hasInput && hasOutput
    if hasInput {
      return self.inputVolume
    }
    if hasOutput {
      return self.outputVolume
    }
    
    return nil
  }

  func setVolume(to newVolume: Double, for type: AudioDeviceType) throws {
    if (type.hasInput) {
      guard (0...1).contains(newVolume) else {
        throw AudioDevices.Error.invalidVolumeValue
      }
      
      var value = Float32(newVolume)
      try CoreAudioData.set(
        id: id,
        selector: kAudioDevicePropertyVolumeScalar,
        scope: kAudioDevicePropertyScopeInput,
        value: &value
      )
    }
    if (type.hasOutput) {
      guard (0...1).contains(newVolume) else {
        throw AudioDevices.Error.invalidVolumeValue
      }
      
      var value = Float32(newVolume)
      try CoreAudioData.set(
        id: id,
        selector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
        scope: kAudioDevicePropertyScopeOutput,
        value: &value
      )
    }
  }

  func setVolume(to newVolume: Double) throws {
    // TODO: need to think how to handle when hasInput && hasOutput
    if hasInput {
      return try setVolume(to: newVolume, for: .input)
    }
    if hasOutput {
      return try setVolume(to: newVolume, for: .output)
    }
  }
  
  var isInputMuted: Bool? {
    do {
      var muteValue: UInt32 = 0
      try CoreAudioData.get(
        id: id,
        selector: kAudioDevicePropertyMute,
        scope: kAudioDevicePropertyScopeInput,
        value: &muteValue
      )
      
      return muteValue != 0
    } catch {
      return nil
    }
  }
  
  var isOutputMuted: Bool? {
    do {
      var muteValue: UInt32 = 0
      try CoreAudioData.get(
        id: id,
        selector: kAudioDevicePropertyMute,
        scope: kAudioDevicePropertyScopeOutput,
        value: &muteValue
      )
      
      return muteValue != 0
    } catch {
      return nil
    }
  }
  
  var isMuted: Bool? {
    // TODO: need to think how to handle when hasInput && hasOutput
    if hasInput {
      return self.isInputMuted
    }
    if hasOutput {
      return self.isOutputMuted
    }
    
    return nil
  }

  func toggleMute(for type: AudioDeviceType) throws {
    if (type.hasInput) {
      guard let isInputMuted = self.isInputMuted else {
        throw AudioDevices.Error.muteNotSupported
      }
      
      var newValue = NSNumber(booleanLiteral: !isInputMuted).uint32Value
      
      try CoreAudioData.set(
        id: id,
        selector: kAudioDevicePropertyMute,
        scope: kAudioDevicePropertyScopeInput,
        value: &newValue
      )
    }

    if (type.hasOutput) {
      guard let isOutputMuted = self.isOutputMuted else {
        throw AudioDevices.Error.muteNotSupported
      }
      
      var newValue = NSNumber(booleanLiteral: !isOutputMuted).uint32Value
      
      try CoreAudioData.set(
        id: id,
        selector: kAudioDevicePropertyMute,
        scope: kAudioDevicePropertyScopeOutput,
        value: &newValue
      )
    }
  }

  func toggleMute() throws {
    // TODO: need to think how to handle when hasInput && hasOutput
    if hasInput {
      return try toggleMute(for: .input)
    }
    if hasOutput {
      return try toggleMute(for: .output)
    }
  }
}

struct AudioDeviceType {
  let selector: AudioObjectPropertySelector
  let hasInput: Bool
  let hasOutput: Bool
  
  static let input = AudioDeviceType(
    selector: kAudioHardwarePropertyDefaultInputDevice,
    hasInput: true,
    hasOutput: false
  )
  
  static let output = AudioDeviceType(
    selector: kAudioHardwarePropertyDefaultOutputDevice,
    hasInput: false,
    hasOutput: true
  )
  
  static let system = AudioDeviceType(
    selector: kAudioHardwarePropertyDefaultSystemOutputDevice,
    hasInput: false,
    hasOutput: true
  )
}

extension AudioDevice {
  static var all: [Self] {
    do {
      let devicesSize = try CoreAudioData.size(selector: kAudioHardwarePropertyDevices)
      let devicesLength = devicesSize / UInt32(MemoryLayout<AudioDeviceID>.size)
      
      var deviceIds: [AudioDeviceID] = Array(repeating: 0, count: Int(devicesLength))

      try CoreAudioData.get(
        selector: kAudioHardwarePropertyDevices,
        initialSize: devicesSize,
        value: &deviceIds
      )

      return deviceIds.compactMap { try? self.init(withId: $0) }
    } catch {
      return []
    }
  }

  static var input: [Self] {
    all.filter { $0.isInput }
  }

  static var output: [Self] {
    all.filter { $0.isOutput }
  }

  static func getDefaultDevice(for deviceType: AudioDeviceType) throws -> Self {
    var deviceId: AudioDeviceID = 0

    try CoreAudioData.get(
      selector: deviceType.selector,
      value: &deviceId
    )

    return try self.init(withId: deviceId)
  }

  static func setDefaultDevice(for deviceType: AudioDeviceType, device: Self) throws {
    if (deviceType.isInput && !device.isInput) || (deviceType.isOutput && !device.isOutput) {
      throw Error.invalidDevice
    }
    
    var deviceId = device.id

    try CoreAudioData.set(
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
  /// - Parameter name: The name for the device to be created.
  /// - Parameter mainDevice: The main device.
  /// - Parameter otherDevices: The rest of the devices to be combined with the main one.
  /// - Parameter shouldStack: Whether or not it should create a Multi-Output Device.
  ///
  /// - Returns: The newly created device.
  static func createAggregate(
    name: String,
    uid: String = UUID().uuidString,
    mainDevice: Self,
    otherDevices: [Self],
    shouldStack: Bool = false
  ) throws -> Self {
    let allDevices = [mainDevice] + otherDevices
    
    let deviceList = allDevices.map {
      [
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
    
    try NSError.checkOSStatus {
      AudioHardwareCreateAggregateDevice(description as CFDictionary, &aggregateDeviceId)
    }

    return try self.init(withId: aggregateDeviceId)
  }

  static func destroyAggregate(device: Self) throws {
    try NSError.checkOSStatus {
      AudioHardwareDestroyAggregateDevice(device.id)
    }
  }
}

struct CoreAudioData {
  static func get<T>(
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
    
    try NSError.checkOSStatus {
      AudioObjectGetPropertyData(id, &address, 0, nil, &size, value)
    }
  }

  static func set<T>(
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
    
    try NSError.checkOSStatus {
      AudioObjectSetPropertyData(id, &address, 0, nil, size, value)
    }
  }

  static func has(
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

  static func size(
    id: UInt32 = AudioObjectID(kAudioObjectSystemObject),
    selector: AudioObjectPropertySelector,
    scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
    element: AudioObjectPropertyElement = kAudioObjectPropertyElementMaster
  ) throws -> UInt32 {
    var size: UInt32 = 0
    
    var address = AudioObjectPropertyAddress(
      mSelector: selector,
      mScope: scope,
      mElement: element
    )
    
    try NSError.checkOSStatus {
      AudioObjectGetPropertyDataSize(id, &address, 0, nil, &size)
    }
    
    return size
  }
}
