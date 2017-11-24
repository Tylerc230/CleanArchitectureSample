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
        
        describe("three ble devices in range one is known") {
            beforeEach {
                let knownUUID = UUID()
                let deviceEntry = DeviceEntry(identifier: knownUUID, name: "Fake name")
                state.knownDeviceEntries = [deviceEntry]
                
                let knownDevice = BLEDevice(identifier: knownUUID)
                state.append(discoveredBLEDevice: knownDevice)
                (0..<2).forEach { _ in
                    let unknownDevice = BLEDevice(identifier: UUID())
                    state.append(discoveredBLEDevice: unknownDevice)
                }
            }
            
            it("should have 2 sections") {
                expect(state.numSectionsInList) == 2
            }
            
            it("should have 1 row in section 0") {
                expect(state.numRows(inSection: 0)) == 1
            }
            
            it("should have 2 rows in section 1") {
                expect(state.numRows(inSection: 1)) == 2
            }
        }
    }
}
