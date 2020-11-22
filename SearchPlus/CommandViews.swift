//
//  CommandViews.swift
//  Search Plus
//
//  Created by McCoy Zhu on 11/20/20.
//

import SwiftUI

struct SuggestedCommandLink: View {
    @EnvironmentObject var env: ENV
    @Binding var searchText: String
    @Binding var isSearching: Bool
    let command: Command
    
    var body: some View {
        NavigationLink(destination: 
            self.command.destinationView {
                self.isSearching = false
                self.searchText = ""
            }.environmentObject(env)
        ) {
            ZStack {
                VStack {
                    Text(self.command.name)
                        .multilineTextAlignment(.center)
                    
                    if !self.command.pathName().isEmpty {
                        Text(self.command.pathName(level: 2))
                            .lineLimit(1)
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.systemGray))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }.buttonStyle(PlainButtonStyle())
    }
}

struct MatchedCommandLink: View {
    @EnvironmentObject var env: ENV
    @Binding var searchText: String
    @Binding var isSearching: Bool
    let command: Command
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: 
                self.command.destinationView {
                    self.isSearching = false
                    self.searchText = ""
                }.environmentObject(env)
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(self.command.name)
                            .foregroundColor(Color(UIColor.label))
                            .padding(.bottom, 3)
                        
                        if !self.command.pathName().isEmpty {
                            Text(self.command.pathName())
                                .lineLimit(1)
                                .font(.footnote)
                                .foregroundColor(Color(UIColor.systemGray2))
                        }
                    }.padding(.vertical, 5)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .font(.headline)
                        .foregroundColor(Color(UIColor.placeholderText))
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.horizontal)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .padding(.leading)
        }
    }
}
