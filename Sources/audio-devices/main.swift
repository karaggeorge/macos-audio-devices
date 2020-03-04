import Cocoa
import SwiftCLI

class ListCommand: Command {
  let name = "list"
  let shortDescription = "List the available audio devices"
  
  @Flag("-i", "--input", description: "Only list input devices")
  var inputOnly: Bool

  @Flag("-o", "--output", description: "Only list output devices")
  var outputOnly: Bool

  @Flag("-j", "--json", description: "Print the result in json format")
  var json: Bool

  var optionGroups: [OptionGroup] {
    return [.atMostOne($inputOnly, $outputOnly)]
  }

  func execute() throws {
    AudioDevices.listAudioDevices(inputOnly: inputOnly, outputOnly: outputOnly, json: json)
  }
}

class OutputGroup: CommandGroup {
  let shortDescription = "Get or set the default output device"
  let name = "output"
  let children = [GetOutputCommand(), SetOutputCommand()] as [Routable]
}

class GetOutputCommand: Command {
  let name = "get"
  
  @Flag("-j", "--json", description: "Print the result in json format")
  var json: Bool

  func execute() throws {
    AudioDevices.getDefaultDevice(deviceType: .output, json: json)
  }
}

class SetOutputCommand: Command {
  let name = "set"

  @Param var deviceId: Int

  func execute() throws {
    AudioDevices.setDefaultDevice(deviceType: .output, deviceId: deviceId)
  }
}

class InputGroup: CommandGroup {
  let shortDescription = "Get or set the default input device"
  let name = "input"
  let children = [GetInputCommand(), SetInputCommand()] as [Routable]
}

class GetInputCommand: Command {
  let name = "get"

  @Flag("-j", "--json", description: "Print the result in json format")
  var json: Bool

  func execute() throws {
    AudioDevices.getDefaultDevice(deviceType: .input, json: json)
  }
}

class SetInputCommand: Command {
  let name = "set"

  @Param var deviceId: Int

  func execute() throws {
    AudioDevices.setDefaultDevice(deviceType: .input, deviceId: deviceId)
  }
}

class SystemGroup: CommandGroup {
  let shortDescription = "Get or set the default device for system sounds"
  let name = "system"
  let children = [GetSystemCommand(), SetSystemCommand()] as [Routable]
}

class GetSystemCommand: Command {
  let name = "get"
  
  @Flag("-j", "--json", description: "Print the result in json format")
  var json: Bool

  func execute() throws {
    AudioDevices.getDefaultDevice(deviceType: .system, json: json)
  }
}

class SetSystemCommand: Command {
  let name = "set"

  @Param var deviceId: Int

  func execute() throws {
    AudioDevices.setDefaultDevice(deviceType: .system, deviceId: deviceId)
  }
}

class VolumeGroup: CommandGroup {
  let shortDescription = "Get or set the volume of an output device"
  let name = "volume"
  let children = [GetVolumeCommand(), SetVolumeCommand()] as [Routable]
}

class GetVolumeCommand: Command {
  let name = "get"

  @Param var deviceId: Int

  func execute() throws {
    AudioDevices.getDeviceVolume(deviceId: deviceId)
  }
}

class SetVolumeCommand: Command {
  let name = "set"

  @Param var deviceId: Int
  @Param var volume: Float

  func execute() throws {
    AudioDevices.setDeviceVolume(deviceId: deviceId, volume: volume)
  }
}

class AggregateGroup: CommandGroup {
  let shortDescription = "Create or delete aggregate audio devices"
  let name = "aggregate"
  let children = [CreateAggregate(), DestroyAggregate()] as [Routable]
}

class CreateAggregate: Command {
  let name = "create"
  let shortDescription = "Create an aggregate device using existing devices"

  @Flag("-j", "--json", description: "Print the result in json format")
  var json: Bool

  @Flag("-m", "--multi-output", description: "Create the aggregate device as a Multi-Output Device")
  var stack: Bool

  @Param var deviceName: String
  @Param var mainDeviceId: Int
  @CollectedParam(minCount: 1) var deviceIds: [Int]

  func execute() throws {
    AudioDevices.createAggregate(name: deviceName, mainId: mainDeviceId, otherIds: deviceIds, json: json, stack: stack)
  }
}

class DestroyAggregate: Command {
  let name = "destroy"
  let shortDescription = "Destory a created aggregate device"

  @Param var deviceId: Int

  func execute() throws {
    AudioDevices.destroyAggregate(deviceId: deviceId)
  }
}

let audioDevices = CLI(name: "audio-devices")
audioDevices.commands = [ListCommand(), OutputGroup(), InputGroup(), SystemGroup(), VolumeGroup(), AggregateGroup()]
_ = audioDevices.go()