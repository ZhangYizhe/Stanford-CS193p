//
//  ContentView.swift
//  Memorize
//
//  Created by 张艺哲 on 2020/11/25.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
            RoundedRectangle(cornerRadius: 10)
                .stroke()
            Text("👻")
        }.foregroundColor(.orange)
        .padding(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
