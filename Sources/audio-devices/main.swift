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

let audioDevices = CLI(name: "audio-devices")
audioDevices.commands = [ListCommand(), OutputGroup(), InputGroup(), VolumeGroup()]
_ = audioDevices.go()