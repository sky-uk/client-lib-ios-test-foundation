//
//  Utils.swift
//  PetStoreApp
//
//  Created by sky on 21/02/22.
//

import Foundation
import SwiftUI

// This is used in .sheet(isPresented: !$userSession.isUserLogged) to provide "not"
prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}
