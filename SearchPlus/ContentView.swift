//
//  ContentView.swift
//  Search Plus
//
//  Created by McCoy Zhu on 11/9/20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var env: ENV
    
    init() {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
        UINavigationBar.appearance().barTintColor = .secondarySystemBackground
    }
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom != .phone || max(UIScreen.main.bounds.height, UIScreen.main.bounds.width) != 812 {
            HomeView().environmentObject(self.env)
        } else {
            Image("ins")
                .resizable()
                .ignoresSafeArea(.all, edges: .all)
                .overlay(
                    ZStack {
                        Rectangle()
                            .fill(Color(UIColor.systemBackground))
                            .frame(width: 53, height: 50)
                        
                        Button(action: {
                            self.env.isSearchPlusOn = true
                        }, label: {
                            SearchPlusIcon(scale: 1.05, foregroundColor: Color(UIColor.label))
                                .padding()
                        })
                    }.padding(.trailing, 50)
                    .padding(.vertical, 2),
                    alignment: .topTrailing
                ).sheet(isPresented: self.$env.isSearchPlusOn) {
                    HomeView().environmentObject(self.env)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(env)
    }
}
