//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by yakir on 2023/7/16.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
