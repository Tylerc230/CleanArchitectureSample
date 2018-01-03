//
//  BLEEditSpec.swift
//  CleanArchitectureCLITests
//
//  Created by Tyler Casselman on 12/4/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import Foundation
import Quick
import Nimble
class BLEEditSpec: QuickSpec {
    override func spec() {
        var state: BLEEditState!
        describe("creating a new device entry") {
            let discovered = BLEDevice(identifier: UUID(), type: "Fake Type")
            beforeEach {
                state = BLEEditState(newEntryWith: discovered)
            }
            
            it("has an empty input name string") {
                expect(state.inputName) == ""
            }
            
            it("has a specific placeholder text") {
                expect(state.namePlaceholderText) == "Name your new device"
            }
            
            it("has a disabled create button") {
                expect(state.saveButtonEnabled).to(beFalse())
            }
            
            context("user enters 2 characters for name") {
                beforeEach {
                    state.inputName = "ab"
                }
                
                it("still has disabled create button") {
                    expect(state.saveButtonEnabled).to(beFalse())
                }
                
                it("can't save yet because the new name is invalide (needs to be at least 3 characters long)") {
                    expect(state.save()).to(beNil())
                }
            }
            context("user enters 3 characters for name") {
                beforeEach {
                    state.inputName = "abc"
                }
                
                it("has an enabled create button") {
                    expect(state.saveButtonEnabled).to(beTrue())
                }
                

                it("issues a create command with the same uuid and type as the BLEDevice and text matches text field") {
                    guard let command = state.save(), case let .create(device) = command else {
                        fail("no command found or not a create command")
                        return
                    }
                    expect(device.identifier) == discovered.identifier
                    expect(device.type) == discovered.type
                    expect(device.name) == "abc"
                }
            }
        }
        
        describe("updating an existing entry") {
            let knownDevice = DeviceEntry(identifier: UUID(), name: "old name", type: "Fake Type")
            beforeEach {
                state = BLEEditState(updateEntryWith: knownDevice)
            }
            
            it("has the old name set to input text") {
                expect(state.inputName) == "old name"
            }
            
            it("is not valid to be saved b/c the name hasn't been modified yet") {//we don't want to allow saving of unmodified entries
                expect(state.saveButtonEnabled).to(beFalse())
            }
            
            context("a valid name has been entered") {
                beforeEach {
                    state.inputName = "new name"
                }
                it("issues an update command with the proper parameters set") {
                    guard let command = state.save(), case let .update(device) = command else {
                        fail("no command issued or not update command")
                        return
                    }
                    expect(device.name) == "new name"
                    expect(device.identifier) == knownDevice.identifier
                    expect(device.type) == knownDevice.type
                }
                
            }
        }
        
    }
}
