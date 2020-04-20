import Cocoa
import CoreAudio
import AudioToolbox

struct AudioDevice: Hashable, Codable, Identifiable {
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
        
        let inputChannels: UInt32 = try CoreAudioData.getAudioDataSize(
            id: deviceId,
            selector: kAudioDevicePropertyStreams,
            scope: kAudioDevicePropertyScopeInput
        )
        let outputChannels: UInt32 = try CoreAudioData.getAudioDataSize(
            id: deviceId,
            selector: kAudioDevicePropertyStreams,
            scope: kAudioDevicePropertyScopeOutput
        )
        
        hasInput = inputChannels > 0
        hasOutput = outputChannels > 0
    }
    
    func getInputVolume() -> Double? {
        do {
            var deviceVolume: Float32 = 0.0
            try CoreAudioData.getAudioData(
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
    
    func getOutputVolume() -> Double? {
        do {
            var deviceVolume: Float32 = 0.0
            try CoreAudioData.getAudioData(
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

    func getVolume() -> Double? {
        // TODO: need to think how to handle when hasInput && hasOutput
        if hasInput {
            return getInputVolume()
        }
        if hasOutput {
            return getOutputVolume()
        }

        return nil
    }
    
    func getInputMute() -> Bool? {
        do {
            var muteValue: UInt32 = 0
            try CoreAudioData.getAudioData(
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

    func getOutputMute() -> Bool? {
        do {
            var muteValue: UInt32 = 0
            try CoreAudioData.getAudioData(
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
    
    func getMute() -> Bool? {
        // TODO: need to think how to handle when hasInput && hasOutput
        if hasInput {
            return getInputMute()
        }
        if hasOutput {
            return getOutputMute()
        }

        return nil
    }
    
    mutating func setInputVolume(_ newVolume: Double) throws {
        guard (0...1).contains(newVolume) else {
            throw AudioDevices.Error.invalidVolumeValue
        }
        
        var value = Float32(newVolume)
        try CoreAudioData.setAudioData(
            id: id,
            selector: kAudioDevicePropertyVolumeScalar,
            scope: kAudioDevicePropertyScopeInput,
            value: &value
        )
    }
    
    mutating func setOutputVolume(_ newVolume: Double) throws {
        guard (0...1).contains(newVolume) else {
            throw AudioDevices.Error.invalidVolumeValue
        }
        
        var value = Float32(newVolume)
        try CoreAudioData.setAudioData(
            id: id,
            selector: kAudioHardwareServiceDeviceProperty_VirtualMasterVolume,
            scope: kAudioDevicePropertyScopeOutput,
            value: &value
        )
    }
    
    mutating func setVolume(_ newVolume: Double) throws {
        // TODO: need to think how to handle when hasInput && hasOutput
        if hasInput {
            return try setInputVolume(newVolume)
        }
        if hasOutput {
            return try setOutputVolume(newVolume)
        }
    }
    
    mutating func toggleInputMute() throws {
        guard let isInputMuted = getInputMute() else {
            throw AudioDevices.Error.muteNotSupported
        }
        
        var newValue = NSNumber(booleanLiteral: !isInputMuted).uint32Value
        
        try CoreAudioData.setAudioData(
            id: id,
            selector: kAudioDevicePropertyMute,
            scope: kAudioDevicePropertyScopeInput,
            value: &newValue
        )
    }
    
    mutating func toggleOutputMute() throws {
        guard let isOutputMuted = getOutputMute() else {
            throw AudioDevices.Error.muteNotSupported
        }
        
        var newValue = NSNumber(booleanLiteral: !isOutputMuted).uint32Value
        
        try CoreAudioData.setAudioData(
            id: id,
            selector: kAudioDevicePropertyMute,
            scope: kAudioDevicePropertyScopeOutput,
            value: &newValue
        )
    }
    
    mutating func toggleMute() throws {
        // TODO: need to think how to handle when hasInput && hasOutput
        if hasInput {
            return try toggleInputMute()
        }
        if hasOutput {
            return try toggleOutputMute()
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


struct AudioDevices {
    enum Error: Swift.Error {
        case invalidDeviceId
        case invalidDevice
        case volumeNotSupported
        case muteNotSupported
        case invalidVolumeValue
    }
    
    static var all: [AudioDevice] {
        do {
            let devicesSize = try CoreAudioData.getAudioDataSize(selector: kAudioHardwarePropertyDevices)
            let devicesLength = devicesSize / UInt32(MemoryLayout<AudioDeviceID>.size)
            
            var deviceIds: [AudioDeviceID] = Array(repeating: 0, count: Int(devicesLength))
            
            try CoreAudioData.getAudioData(
                selector: kAudioHardwarePropertyDevices,
                initialSize: devicesSize,
                value: &deviceIds
            )
            
            return deviceIds.compactMap { try? AudioDevice(withId: $0) }
        } catch {
            return []
        }
    }
    
    static var input: [AudioDevice] {
        all.filter { $0.hasInput }
    }
    
    static var output: [AudioDevice] {
        all.filter { $0.hasOutput }
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
        if (deviceType.hasInput && !device.hasInput) || (deviceType.hasOutput && !device.hasOutput) {
            throw Error.invalidDevice
        }
        
        var deviceId = device.id
        
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
    /// - Parameter name: The name for the device to be created.
    /// - Parameter mainDevice: The main device.
    /// - Parameter otherDevices: The rest of the devices to be combined with the main one.
    /// - Parameter shouldStack: Whether or not it should create a Multi-Output Device.
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
        
        return try AudioDevice(withId: aggregateDeviceId)
    }
    
    static func destroyAggregate(device: AudioDevice) throws {
        try NSError.checkOSStatus {
            AudioHardwareDestroyAggregateDevice(device.id)
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
        
        try NSError.checkOSStatus {
            AudioObjectSetPropertyData(id, &address, 0, nil, size, value)
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
