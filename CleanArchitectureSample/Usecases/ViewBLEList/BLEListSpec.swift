import Quick
import Nimble

class BLEListSpec: QuickSpec {
    override func spec() {
        var state: BLEListState!
        beforeEach {
            state = BLEListState()
        }
        describe("a ble list with no known items and no discovered items") {
            it("shows some copy explaining that the user needs a discoverable device") {
                expect(state.showNoDevicesCopy).to(beTrue())
            }
            
            it("has one section added when a device comes into range") {
                let device = bleDevice()
                let (_, changeSet) = state.append(bleDevices: [device])
                expect(changeSet.addedRows) == [IndexPath(row: 0, section: 0)]
                expect(changeSet.addedSections) == [0]
                expect(changeSet.deletedSections) == []
            }
        }
        
        describe("one ble devices is in range") {
            var tableViewModel: BLEListState.TableViewModel!
            let unknownUUID = UUID()
            beforeEach {
                let device = bleDevice(withUUID: unknownUUID)
                let (tvm, _) = state.append(bleDevices: [device])
                tableViewModel = tvm
            }
            
            it("does not show the copy") {
                expect(state.showNoDevicesCopy).to(beFalse())
            }
            
            it("has 1 section") {
                expect(tableViewModel.numSections) == 1
            }
            
            it("has one row in the section") {
                expect(tableViewModel.numRows(inSection: 0)) == 1
            }
            
            it("has two rows after another device discovered") {
                let device = bleDevice()
                let (tableViewModel, changeSet) = state.append(bleDevices: [device])
                expect(tableViewModel.numRows(inSection: 0)) == 2
                expect(changeSet.addedRows) == [IndexPath(row: 1, section: 0)]
            }
            
            it("deletes discovered devices section and adds known devices section in its place, after the user adds a corresponding entry") {
                let newEntry = deviceEntry(withUUID: unknownUUID)
                let (_, changeSet) = state.append(deviceEntries: [newEntry])
                expect(changeSet.deletedSections) == IndexSet(integer: 0)
                expect(changeSet.addedSections) == IndexSet(integer: 0)
            }
            
            it("starts the 'create new device entry' flow on tapping a row") {
                let transition = state.didSelectRow(at: IndexPath(row: 0, section: 0))
                if case BLEListState.Transition.newDeviceEntry = transition {
                    
                } else {
                    fail("should create new device entry when selecting a ble device")
                }
            }
        }
        
        describe("two ble devices in range") {
            let unknownUUID = UUID()
            beforeEach {
                let device1 = bleDevice(withUUID: unknownUUID)
                let device2 = bleDevice()
                _ = state.append(bleDevices: [device1, device2])
            }
            
            it("adds a new section, removes a row and adds a row when one of the devices is added to the db") {
                let entry = deviceEntry(withUUID: unknownUUID)
                let (_, changeSet) = state.append(deviceEntries: [entry])
                expect(changeSet.addedSections) == [0]
                expect(changeSet.addedRows) == [IndexPath(row: 0, section: 0)]
                expect(changeSet.deletedRows) == [IndexPath(row: 0, section: 0)]
            }
        }
        
        describe("three ble devices in range, two devices known, one in range device is known") {
            let knownNotInRangeUUID = UUID()
            let unknownInRangeUUID = UUID()
            var tableViewModel: BLEListState.TableViewModel!
            beforeEach {
                //Originally has 2 unknown devices in the bottom section and 2 devices in the top (one is in range and one is not)
                let knownInRangeUUID = UUID()
                let knownNotInRangeDeviceEntry = deviceEntry(withUUID: knownNotInRangeUUID)//row:0, sec:0 disabled
                let knownInRangeDeviceEntry = deviceEntry(withUUID: knownInRangeUUID)//row: 1, sec: 0 and will be enabled b/c it is in range
                _ = state.append(deviceEntries: [knownNotInRangeDeviceEntry, knownInRangeDeviceEntry])

                let knownDevice = bleDevice(withUUID: knownInRangeUUID)//This one will be in section 0 (bc it is known)
                let unknownDevice1 = bleDevice(withUUID: unknownInRangeUUID)//This one will be at row: 0, sec: 1
                let unknownDevice2 = bleDevice()//This one will be at row: 1, sec: 1
                let (tvm, _) = state.append(bleDevices: [knownDevice, unknownDevice1, unknownDevice2])
                tableViewModel = tvm
            }
            
            it("has 2 sections") {
                expect(tableViewModel.numSections) == 2
            }
            
            it("has 2 rows in section 0") {
                expect(tableViewModel.numRows(inSection: 0)) == 2
            }
            
            it("has 2 rows in section 1") {
                expect(tableViewModel.numRows(inSection: 1)) == 2
            }
            
            it("has a disabled row in section 0") {
                let row = IndexPath(row: 0, section: 0)
                let config = tableViewModel.cellConfig(at: row)
                if case let .known(_, _, enabled) = config {
                    expect(enabled) == false
                } else {
                    fail()
                }
            }
            
            it("has an enabled row in section 0") {
                let row = IndexPath(row: 1, section: 0)
                let config = tableViewModel.cellConfig(at: row)
                if case let .known(_, _, enabled) = config {
                    expect(enabled) == true
                } else {
                    fail()
                }
            }
            
            it("transitions to update device entry when section 0 row tapped") {
                let transition = state.didSelectRow(at: IndexPath(row:0, section: 0))
                if case BLEListState.Transition.updateDeviceEntry = transition {
                    
                } else {
                    fail("Should transition to updating an existing device entry when selecting a known device entry row")
                }
            }
            
            it("adds another cell to the bottom when another unknown BLEDevice comes into range") {
                let newDevice = bleDevice()
                let (_, changeSet) = state.append(bleDevices: [newDevice])
                expect(changeSet.addedRows).to(haveCount(1))
            }
            
            it("removes a cell from section 1 to adds a cell section 0 when the user adds a device entry to an unknown device, making it known") {
                let newDeviceEntry = deviceEntry(withUUID: unknownInRangeUUID)
                let (_, changeSet) = state.append(deviceEntries: [newDeviceEntry])
                expect(changeSet.addedRows) == [IndexPath(row: 2, section: 0)]
                expect(changeSet.deletedRows) == [IndexPath(row:0, section: 1)]
            }
            
            it("reloads the cell when a device entry is updated") {
                let updatedDevice = DeviceEntry(identifier: knownNotInRangeUUID, name: "Updated name", type: "Fake device type")
                let (_, changeSet) = state.update(deviceEntries: [updatedDevice])
                expect(changeSet.reloadedRows) == [IndexPath(row: 0, section: 0)]
            }
        }
        
        describe("section addition and removal") {
            context("one known device (one section only)") {
                beforeEach {
                    _ = state.append(deviceEntries: [deviceEntry()])
                }
                it("adds a section in the changeset when a new device is discovered") {
                    let (_, changeSet) = state.append(bleDevices: [bleDevice()])
                    expect(changeSet.addedSections) == [1]
                }
            }
        }
    }
}


func deviceEntry(withUUID uuid: UUID = UUID()) -> DeviceEntry {
    return DeviceEntry(identifier: uuid, name: "Fake Device", type: "Fake Device Type")
}

func bleDevice(withUUID uuid: UUID = UUID()) -> BLEDevice {
    return BLEDevice(identifier: uuid, type: "Fake Device Type")
}
