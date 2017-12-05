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
            beforeEach {
                let discovered = BLEDevice(identifier: UUID(), type: "Fake Type")
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
            }
            context("user enters 3 characters for name") {
                beforeEach {
                    state.inputName = "abc"
                }
                
                it("has an enabled create button") {
                    expect(state.saveButtonEnabled).to(beTrue())
                }
            }
        }
        
        describe("updating an existing entry") {
            beforeEach {
                let knownDevice = DeviceEntry(identifier: UUID(), name: "old name", type: "Fake Type")
                state = BLEEditState(updateEntryWith: knownDevice)
            }
            
            it("has the old name set to input text") {
                expect(state.inputName) == "old name"
            }
        }
        
    }
}
