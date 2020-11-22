//
//  ContentView.swift
//  Search Plus
//
//  Created by McCoy Zhu on 11/9/20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var env: ENV
    @State var searchText = ""
    @State var isSearching = false
    
    init() {
        UIScrollView.appearance().keyboardDismissMode = .onDrag
        UINavigationBar.appearance().barTintColor = .secondarySystemBackground
    }
    
    var body: some View {
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
                NavigationView {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            if !self.isSearching && self.searchText.isEmpty {
                                HStack {
                                    Text("Search Plus")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        self.env.isSearchPlusOn = false
                                    }, label: {
                                        Text("Done")
                                            .fontWeight(.bold)
                                    })
                                }.padding([.top, .horizontal])
                            }
                            
                            SearchPlusBar(searchText: self.$searchText, isSearching: self.$isSearching)
                                .padding(.horizontal, !self.isSearching && self.searchText.isEmpty ? 7 : 2)
                                .background(
                                    Color(UIColor.secondarySystemBackground)
                                        .ignoresSafeArea(.all, edges: [.horizontal, .top])
                                )
                        }.background(
                            Color(UIColor.secondarySystemBackground)
                                .ignoresSafeArea(.all, edges: [.horizontal, .top])
                        )
                        
                        Divider()
                            .ignoresSafeArea(.all, edges: .horizontal)
                        
                        if !self.isSearching && self.searchText.isEmpty {
                            Spacer()
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))]) {
                                ForEach(commands) { command in
                                    if command.isSuggested {
                                        SuggestedCommandLink(searchText: self.$searchText, isSearching: self.$isSearching, command: command).environmentObject(env)
                                    }
                                }
                            }.padding()
                            
                            Spacer()
                            
                            Group {
                                Text("Powered by Search Plus")
                                    .font(.callout)
                                    .padding(.bottom, 3)
                                
                                Text("© 2020 Mingcheng (McCoy) Zhu")
                                    .font(.footnote)
                            }.foregroundColor(Color(UIColor.systemGray))
                            .padding(.horizontal)
                        } else {
                            Group {
                                if self.searchText.isEmpty {
                                    VStack {
                                        Spacer()
                                        
                                        Text("Please type in the command name.")
                                            .foregroundColor(Color(UIColor.systemGray))
                                            .multilineTextAlignment(.center)
                                            .padding()
                                        
                                        Spacer()
                                    }
                                } else if commands.count(where: { $0.isMatch(of: self.searchText) }) == 0 {
                                    VStack {
                                        Spacer()
                                        
                                        Text("Sorry, no commands found.\nMaybe try something different?")
                                            .foregroundColor(Color(UIColor.systemGray))
                                            .multilineTextAlignment(.center)
                                            .padding()
                                        
                                        Spacer()
                                    }
                                } else {
                                    ScrollView {
                                        LazyVStack(spacing: 0) {
                                            ForEach(commands) { command in
                                                if command.isMatch(of: self.searchText) {
                                                    MatchedCommandLink(searchText: self.$searchText, isSearching: self.$isSearching, command: command).environmentObject(env)
                                                }
                                            }
                                        }
                                    }
                                    .simultaneousGesture(TapGesture().onEnded{
                                        self.isSearching = false
                                    })
                                }
                            }
                        }
                    }
                    .navigationBarHidden(true)
                }.navigationViewStyle(StackNavigationViewStyle())
                .animation(.easeInOut(duration: 0.3), value: self.isSearching || !self.searchText.isEmpty)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(env)
    }
}
