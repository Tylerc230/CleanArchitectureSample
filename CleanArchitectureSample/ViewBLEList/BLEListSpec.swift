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
                expect(state.numSectionsInList) == 1
            }
            
            it("has one row in the section") {
                expect(state.numRows(inSection: 0)) == 1
            }
            
            it("has two rows after another device discovered") {
                let device = BLEDevice(identifier: UUID())
                _ = state.append(discoveredBLEDevices: [device])
                expect(state.numRows(inSection: 0)) == 2
            }
        }
        
        describe("three ble devices in range, two devices known, one in range device is known") {
            let knownNotInRangeUUID = UUID()
            beforeEach {
                let knownInRangeUUID = UUID()
                let knownDeviceEntry = DeviceEntry(identifier: knownInRangeUUID, name: "Fake name")
                let knownNotInRangeDeviceEntry = DeviceEntry(identifier: knownNotInRangeUUID, name: "Not in range device")
                state.knownDevices = [knownNotInRangeDeviceEntry, knownDeviceEntry]
                
                let knownDevice = BLEDevice(identifier: knownInRangeUUID)
                _ = state.append(discoveredBLEDevices: [knownDevice])
                (0..<2).forEach { _ in
                    let unknownDevice = BLEDevice(identifier: UUID())
                   _ = state.append(discoveredBLEDevices: [unknownDevice])
                }
            }
            
            it("has 2 sections") {
                expect(state.numSectionsInList) == 2
            }
            
            it("has 2 rows in section 0") {
                expect(state.numRows(inSection: 0)) == 2
            }
            
            it("has 2 rows in section 1") {
                expect(state.numRows(inSection: 1)) == 2
            }
            
            it("has a disabled row in section 0") {
                let config = state.cellConfig(atRow: 0, section: 0)
                if case .known(let enabled) = config {
                    expect(enabled) == false
                } else {
                    fail()
                }
            }
            
            it("has an enabled row in section 0") {
                let config = state.cellConfig(atRow: 1, section: 0)
                if case .known(let enabled) = config {
                    expect(enabled) == true
                } else {
                    fail()
                }
            }
            
            describe("the previously known not in range device comes in range") {
                it("generates a table view change request updating the newly in range cell") {
                    let newlyInRangeBLEDevice = BLEDevice(identifier: knownNotInRangeUUID)
                    let tableChangeSet = state.append(discoveredBLEDevices: [newlyInRangeBLEDevice])
                    expect(tableChangeSet.rowsUpdated).toNot(beEmpty())
                }
            }
        }
    }
}
