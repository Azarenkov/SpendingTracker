//
//  SpendingTrackerCoreDataApp.swift
//  SpendingTrackerCoreData
//
//  Created by Алексей Азаренков on 12.02.2024.
//

import SwiftUI

@main
struct SpendingTrackerCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
