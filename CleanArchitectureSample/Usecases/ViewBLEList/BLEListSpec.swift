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
                let (_, changeSet) = state.tableViewAndChangeSet { state in
                    state.append(bleDevices: [device])
                }
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
                let (tvm, _) = state.tableViewAndChangeSet { state in
                    state.append(bleDevices: [device])
                }
                tableViewModel = tvm
            }
            
            it("does not show the copy") {
                expect(state.showNoDevicesCopy).to(beFalse())
            }
            
            it("has 1 section and one row") {
                expect(tableViewModel.numSections) == 1
                expect(tableViewModel.numRows(inSection: 0)) == 1
            }
            
            it("has two rows after another device discovered") {
                let device = bleDevice()
                let (tableViewModel, changeSet) = state.tableViewAndChangeSet { state in
                    state.append(bleDevices: [device])
                }
                expect(tableViewModel.numRows(inSection: 0)) == 2
                expect(changeSet.addedRows) == [IndexPath(row: 1, section: 0)]
            }
            
            it("deletes discovered devices section and adds known devices section in its place, after the user adds a corresponding entry") {
                let newEntry = deviceEntry(withUUID: unknownUUID)
                let (_, changeSet) = state.tableViewAndChangeSet { state in
                    state.append(deviceEntries: [newEntry])
                }
                expect(changeSet.deletedSections) == IndexSet(integer: 0)
                expect(changeSet.addedSections) == IndexSet(integer: 0)
            }
            
            it("starts the 'create new device entry' flow on tapping a row") {
                let transition = state.didSelectRow(at: IndexPath(row: 0, section: 0))
                if case BLEListState.Transition.newDeviceEntry = transition {
                    expect(true) == true
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
                state.append(bleDevices: [device1, device2])
            }
            
            it("adds a new section, removes a row and adds a row when one of the devices is added to the db") {
                let entry = deviceEntry(withUUID: unknownUUID)
                let (_, changeSet) = state.tableViewAndChangeSet { state in
                    state.append(deviceEntries: [entry])
                }
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
                state.append(deviceEntries: [knownNotInRangeDeviceEntry, knownInRangeDeviceEntry])

                let knownDevice = bleDevice(withUUID: knownInRangeUUID)//This one will be in section 0 (bc it is known)
                let unknownDevice1 = bleDevice(withUUID: unknownInRangeUUID)//This one will be at row: 0, sec: 1
                let unknownDevice2 = bleDevice()//This one will be at row: 1, sec: 1
                let (tvm, _) = state.tableViewAndChangeSet { state in
                    state.append(bleDevices: [knownDevice, unknownDevice1, unknownDevice2])
                }
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
            
            it("has 1 disabled row and 1 enabled row in section 0") {
                var enabledRowCount = 0
                var disabledRowCount = 0
                (0..<tableViewModel.numRows(inSection: 0)).map {
                    return tableViewModel.cellConfig(at: IndexPath(row: $0, section: 0))
                    }
                    .forEach { config in
                        if case let .known(_, _, enabled) = config {
                            if enabled {
                                enabledRowCount += 1
                            } else {
                                disabledRowCount += 1
                            }
                        }
                }
                expect(enabledRowCount) == 1
                expect(disabledRowCount) == 1
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
                let (_, changeSet) = state.tableViewAndChangeSet { state in
                    state.append(bleDevices: [newDevice])
                }
                expect(changeSet.addedRows) == [IndexPath(row: 2, section: 1)]
            }
            
            it("removes a cell from section 1 and adds a cell section 0 when the user adds a device entry to an unknown device, making it known") {
                let newDeviceEntry = deviceEntry(withUUID: unknownInRangeUUID)
                let (_, changeSet) = state.tableViewAndChangeSet { state in
                    state.append(deviceEntries: [newDeviceEntry])
                }
                expect(changeSet.addedRows[0].section) == 0
                expect(changeSet.deletedRows[0].section) == 1
            }
            
        }
        
        describe("rows moving after a rename") {
            let renamedIdentifier = UUID()
            beforeEach {
                let renamedEntry = DeviceEntry(identifier: renamedIdentifier, name: "A", type: "")
                let otherEntry = DeviceEntry(identifier: UUID(), name: "B", type: "")
                state.append(deviceEntries: [renamedEntry, otherEntry])
            }
            
            it("reloads and moves the cell when a device entry is updated") {
                let updatedDevice = DeviceEntry(identifier: renamedIdentifier, name: "C", type: "")
                
                let (_, changeSet) = state.tableViewAndChangeSet { state in
                    state.update(deviceEntries: [updatedDevice])
                }
                expect(changeSet.reloadedRows) == [IndexPath(row: 1, section: 0)]
                expect(changeSet.movedRows) == [RowChangeSet.Move(start: IndexPath(row: 0, section: 0), end: IndexPath(row: 1, section: 0))]
            }
            
        }
        
        describe("removing rows") {
            let deleted = DeviceEntry(identifier: UUID(), name: "A", type: "")
            let renamed = DeviceEntry(identifier: UUID(), name: "B", type: "")
            beforeEach {
                let lastEntry = DeviceEntry(identifier: UUID(), name: "C", type: "")
                state.append(deviceEntries: [deleted, renamed, lastEntry])
                
            }
            
            it("deletes a row after removing device") {
                let (_, changeSet) = state.tableViewAndChangeSet { state in
                    state.remove(deviceEntries: [deleted])
                }
                expect(changeSet) == RowChangeSet(deletedRows: [IndexPath(row: 0, section: 0)])
            }

            it("deletes a row and moves a row after a delete and an update") {
                let updatedDevice = DeviceEntry(identifier: renamed.identifier, name: "D", type: "")
                let (_, changeSet) = state.tableViewAndChangeSet { state in
                    state.update(deviceEntries: [updatedDevice])
                    state.remove(deviceEntries: [deleted])
                }
                let moved = RowChangeSet.Move(start: IndexPath(row: 1, section: 0), end: IndexPath(row:1, section: 0))
                expect(changeSet) == RowChangeSet(reloadedRows: [IndexPath(row: 1, section: 0)], deletedRows: [IndexPath(row: 0, section: 0)], movedRows: [moved])
            }
            
        }
        
        describe("section addition and removal") {
            context("one known device (one section only)") {
                let singleDeviceEntry = deviceEntry()
                beforeEach {
                    state.append(deviceEntries: [singleDeviceEntry])
                }
                it("adds a section in the changeset when a new device is discovered") {
                    
                    let (_, changeSet) = state.tableViewAndChangeSet { state in
                        state.append(bleDevices: [bleDevice()])
                    }
                    expect(changeSet) == RowChangeSet(addedRows: [IndexPath(row: 0, section: 1)], addedSections: [1])
                }
                
                it("removes a section when device is removed") {
                    let (_, changeSet) = state.tableViewAndChangeSet { state in
                        state.remove(deviceEntries: [singleDeviceEntry])
                    }
                    expect(changeSet) == RowChangeSet(deletedSections: [0])
                }
            }
            
            context("one discovered device") {
                let singleBLEDevice = bleDevice()
                beforeEach {
                    state.append(bleDevices: [singleBLEDevice])
                }
                
                it("adds insertes a section at the top with one row when user adds a device entry") {
                    let (_, changeSet) = state.tableViewAndChangeSet { state in
                        state.append(deviceEntries: [deviceEntry()])
                    }
                    expect(changeSet.addedSections) == [0]
                    expect(changeSet.addedRows) == [IndexPath(row:0, section: 0)]
                }
                
                it("removes a section when single ble device is deleted") {
                    let (_, changeSet) = state.tableViewAndChangeSet { state in
                        state.remove(bleDevices: [singleBLEDevice])
                    }
                    expect(changeSet) == RowChangeSet(deletedSections: [0])
                }
                
                fit("moves a row from device entries to ble devices when the corresponding entry is deleted") {
                    let entry = DeviceEntry(identifier: singleBLEDevice.identifier, name: "New entry", type: "")
                    state.append(deviceEntries: [entry])
                    let (_, changeSet) = state.tableViewAndChangeSet { state in
                        state.remove(deviceEntries: [entry])
                    }
                    let move = RowChangeSet.Move(start: IndexPath(row: 0, section: 0), end: IndexPath(row: 0, section:0))
                    expect(changeSet) == RowChangeSet(reloadedRows: [IndexPath(row: 0, section: 0)], movedRows: [move], addedSections: [0], deletedSections: [0])
                }
            }
        }
        
        describe("device list sorting") {
            context("3 in range known device") {
                beforeEach {
                    ["F", "D", "E"]
                        .map {
                            let identifier = UUID()
                            let entry = DeviceEntry(identifier: identifier, name: $0, type: "Some type")
                            let device = BLEDevice(identifier: identifier, type: "Some type")
                            return (entry, device)
                        }
                        .forEach { (entry, device) in
                            state.append(deviceEntries:[entry], bleDevices: [device])
                    }
                }
                it("sorts the known devices based on their name") {
                    let names = knownDeviceNames(in: state.tableViewModel)
                    expect(names) == ["D", "E", "F"]
                }
                context("3 out of range devices are added to the database") {
                    beforeEach {
                        ["B", "C", "A"]
                            .map { DeviceEntry(identifier: UUID(), name: $0, type: "Some type") }
                            .forEach {
                                _ = state.append(deviceEntries: [$0])
                        }
                    }
                    it("sorts the 3 out of range device last in the list") {
                        let names = knownDeviceNames(in: state.tableViewModel)
                        expect(names) == ["D", "E", "F", "A", "B", "C"]
                    }
                }
                
                func knownDeviceNames(in tableViewModel: BLEListState.TableViewModel) -> [String] {
                    return (0..<tableViewModel.numRows(inSection: 0))
                        .map { tableViewModel.cellConfig(at: IndexPath(row: $0, section: 0)) }
                        .flatMap {
                            guard case .known(let name, _, _) = $0 else { return nil }
                            return name
                    }
                }
            }
        }
    }
}

extension RowChangeSet: Equatable {
    static func ==(lhs: RowChangeSet, rhs: RowChangeSet) -> Bool {
        return lhs.reloadedRows == rhs.reloadedRows &&
        lhs.addedRows == rhs.addedRows &&
        lhs.deletedRows == rhs.deletedRows &&
        lhs.movedRows == rhs.movedRows &&
        lhs.addedSections == rhs.addedSections &&
        lhs.deletedSections == rhs.deletedSections
    }
}

extension RowChangeSet.Move: Equatable {
    static func ==(lhs: RowChangeSet.Move, rhs: RowChangeSet.Move) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}


func deviceEntry(withUUID uuid: UUID = UUID()) -> DeviceEntry {
    return DeviceEntry(identifier: uuid, name: "Fake Device", type: "Fake Device Type")
}

func bleDevice(withUUID uuid: UUID = UUID()) -> BLEDevice {
    return BLEDevice(identifier: uuid, type: "Fake Device Type")
}
