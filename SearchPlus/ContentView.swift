//
//  ContentView.swift
//  Search Plus
//
//  Created by McCoy Zhu on 11/9/20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var env: ENV
    @State var notifySearchPlus = false
    @State var highlightSearchPlus = false
    @State var isSearchPlusActivated = false
    
    init() {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
        UINavigationBar.appearance().barTintColor = .secondarySystemBackground
    }
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom != .phone || UIScreen.main.bounds.height != 812 {
            HomeView(isSearchPlusActivated: self.$isSearchPlusActivated).environmentObject(self.env)
        } else {
            Image("ins")
                .resizable()
                .ignoresSafeArea(.all, edges: .all)
                .overlay(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(self.highlightSearchPlus ? UIColor.secondarySystemBackground : UIColor.systemBackground))
                            .animation(.default, value: self.highlightSearchPlus)
                            .frame(width: 50, height: 50)
                        
                        Button(action: {
                            self.isSearchPlusActivated = true
                            self.highlightSearchPlus = false
                        }, label: {
                            SearchPlusIcon(scale: 1.05, foregroundColor: Color(UIColor.label))
                                .padding()
                        })
                    }.padding(.trailing, 50)
                    .padding(.vertical, 2),
                    alignment: .topTrailing
                ).overlay(
                    Button(action: {
                        self.notifySearchPlus = true
                        self.highlightSearchPlus = true
                    }, label: {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 378)
                            .alert(isPresented: self.$notifySearchPlus) {
                                Alert(title: Text("This app supports Search Plus"), message: Text("Tap on the highlighted icon on top of the screen to enjoy a much easier experience powered by Search Plus."), dismissButton: nil)
                            }
                    }),
                    alignment: .bottom
                ).sheet(isPresented: self.$isSearchPlusActivated) {
                    HomeView(isSearchPlusActivated: self.$isSearchPlusActivated).environmentObject(self.env)
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
