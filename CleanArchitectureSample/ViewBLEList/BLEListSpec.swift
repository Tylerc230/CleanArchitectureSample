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
        }
        describe("one ble devices is in range") {
            beforeEach {
                let device = BLEDevice(identifier: UUID())
                _ = state.append(discoveredBLEDevices: [device])
            }
            
            it("does not show the copy") {
                expect(state.showNoDevicesCopy).to(beFalse())
            }
            
            it("has 1 section") {
                expect(state.tableModel.numSections) == 1
            }
            
            it("has one row in the section") {
                expect(state.tableModel.numRows(inSection: 0)) == 1
            }
            
            it("has two rows after another device discovered") {
                let device = BLEDevice(identifier: UUID())
                _ = state.append(discoveredBLEDevices: [device])
                expect(state.tableModel.numRows(inSection: 0)) == 2
            }
        }
        
        describe("three ble devices in range, two devices known, one in range device is known") {
            let knownNotInRangeUUID = UUID()
            let unknownInRangeUUID = UUID()
            beforeEach {
                //Originally has 2 unknown devices in the bottom section and 2 devices in the top (one is in range and one is not)
                let knownInRangeUUID = UUID()
                let knownInRangeDeviceEntry = DeviceEntry(identifier: knownInRangeUUID, name: "Fake name") //row: 0, sec: 0 and will be enabled b/c it is in range
                let knownNotInRangeDeviceEntry = DeviceEntry(identifier: knownNotInRangeUUID, name: "Not in range device")//row:1, sec:0 disabled
                _ = state.append(deviceEntries: [knownNotInRangeDeviceEntry, knownInRangeDeviceEntry])

                let knownDevice = BLEDevice(identifier: knownInRangeUUID)//This one will be in section 0 (bc it is known)
                let unknownDevice1 = BLEDevice(identifier: unknownInRangeUUID)//This one will be at row: 0, sec: 1
                let unknownDevice2 = BLEDevice(identifier: UUID())//This one will be at row: 1, sec: 1
                _ = state.append(discoveredBLEDevices: [knownDevice, unknownDevice1, unknownDevice2])
            }
            
            it("has 2 sections") {
                expect(state.tableModel.numSections) == 2
            }
            
            it("has 2 rows in section 0") {
                expect(state.tableModel.numRows(inSection: 0)) == 2
            }
            
            it("has 2 rows in section 1") {
                expect(state.tableModel.numRows(inSection: 1)) == 2
            }
            
            it("has a disabled row in section 0") {
                let row = IndexPath(row: 0, section: 0)
                let config = state.tableModel.cellConfig(at: row)
                if case .known(let enabled) = config {
                    expect(enabled) == false
                } else {
                    fail()
                }
            }
            
            it("has an enabled row in section 0") {
                let row = IndexPath(row: 1, section: 0)
                let config = state.tableModel.cellConfig(at: row)
                if case .known(let enabled) = config {
                    expect(enabled) == true
                } else {
                    fail()
                }
            }
            
            describe("another unknown BLEDevice comes into range") {
                it("adds another cell to the bottom") {
                    let newDevice = BLEDevice(identifier: UUID())
                    let changeSet = state.append(discoveredBLEDevices: [newDevice])
                    expect(changeSet.addedRows).to(haveCount(1))
                }
            }
            
            describe("the user adds a device entry to an unknown device, making it known") {
                it("removes a cell from section 1 to adds a cell section 0") {
                    let newDeviceEntry = DeviceEntry(identifier: unknownInRangeUUID, name: "New name")
                    let changeSet = state.append(deviceEntries: [newDeviceEntry])
                    expect(changeSet.addedRows) == [IndexPath(row: 2, section: 0)]
                    expect(changeSet.deletedRows) == [IndexPath(row:0, section: 1)]
                    
                }
            }
            
            
            

//            describe("the previously known not in range device comes in range") {
//                it("generates a table view change request updating the newly in range cell") {
//                    let newlyInRangeBLEDevice = BLEDevice(identifier: knownNotInRangeUUID)
//                    let tableChangeSet = state.append(discoveredBLEDevices: [newlyInRangeBLEDevice])
//                    expect(tableChangeSet.updatedRows).toNot(beEmpty())
//                }
//            }
        }
    }
}
