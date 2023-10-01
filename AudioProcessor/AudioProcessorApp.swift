//
//  AudioProcessorApp.swift
//  AudioProcessor
//

import SwiftUI

@main
struct AudioProcessorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
