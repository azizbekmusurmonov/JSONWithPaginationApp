//
//  ContentView.swift
//  JSONWithPagination
//
//  Created by Azizbek Musurmonov   on 25/03/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("Json Parsing")
        }
    }
}

#Preview {
    ContentView()
}
