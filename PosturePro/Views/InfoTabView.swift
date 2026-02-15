//
//  InfoTabView.swift
//  PosturePro
//

import SwiftUI

struct InfoTabView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Versione", value: "1.0")
                } header: {
                    Text("App")
                }
                
                Section {
                    Text("SpineSprout usa i sensori degli AirPods per monitorare la postura del collo. Mantieni la schiena dritta e la pianta resterà verde!")
                        .font(AppTheme.Typography.body)
                } header: {
                    Text("Come funziona")
                }
            }
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    InfoTabView()
}
