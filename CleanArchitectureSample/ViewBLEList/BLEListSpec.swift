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
                state.append(discoveredBLEDevice: device)
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
                state.append(discoveredBLEDevice: device)
                expect(state.numRows(inSection: 0)) == 2
            }
        }
        
        describe("three ble devices in range, two devices known, one in range device is known") {
            beforeEach {
                let knownInRangeUUID = UUID()
                let knownDeviceEntry = DeviceEntry(identifier: knownInRangeUUID, name: "Fake name")
                let knownNotInRangeDeviceEntry = DeviceEntry(identifier: UUID(), name: "Not in range device")
                state.knownDevices = [knownNotInRangeDeviceEntry, knownDeviceEntry]
                
                let knownDevice = BLEDevice(identifier: knownInRangeUUID)
                state.append(discoveredBLEDevice: knownDevice)
                (0..<2).forEach { _ in
                    let unknownDevice = BLEDevice(identifier: UUID())
                    state.append(discoveredBLEDevice: unknownDevice)
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
            
            it("has a disabled row in section 1") {
                let row = state.knownDeviceRow(at: 0)
                expect(row.inRange) == false
            }
            
            it("has an enabled row in section 1") {
                let row = state.knownDeviceRow(at: 1)
                expect(row.inRange) == true
            }
        }
    }
}
