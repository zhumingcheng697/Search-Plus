//
//  HomeView.swift
//  SearchPlus
//
//  Created by McCoy Zhu on 11/21/20.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var env: ENV
    @State var searchText = ""
    @State var isSearching = false
    
    var body: some View {
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
                                    .padding([.vertical, .leading])
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
                    GeometryReader { geo in
                        ScrollView {
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                                    ForEach(commands) { command in
                                        if command.isSuggested {
                                            SuggestedCommandLink(searchText: self.$searchText, isSearching: self.$isSearching, command: command).environmentObject(env)
                                        }
                                    }
                                }.padding()
                                
                                Spacer(minLength: 12)
                                
                                Group {
                                    Text("Powered by Search Plus")
                                        .font(.callout)
                                        .padding(.bottom, 3)
                                    
                                    Text("© 2020 Mingcheng (McCoy) Zhu")
                                        .font(.footnote)
                                        .padding(.bottom)
                                }.foregroundColor(Color(UIColor.systemGray))
                                .padding(.horizontal)
                            }.frame(maxWidth: .infinity, minHeight: geo.size.height)
                        }
                    }
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
        .disableSheetDismissGesture()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(env)
    }
}
