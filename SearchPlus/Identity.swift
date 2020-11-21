//
//  Identity.swift
//  Search Plus
//
//  Created by McCoy Zhu on 11/8/20.
//

import SwiftUI

struct SearchPlusIcon: View {
    var scale: CGFloat = 1
    var foregroundColor: Color = Color(UIColor.label)
    
    var body: some View {
        ZStack {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17 * scale, weight: .medium, design: .default))
                .padding(.trailing, 4 * scale)
            
            Image(systemName: "plus")
                .font(.system(size: 11 * scale, weight: .semibold, design: .default))
                .offset(x: 8 * scale, y: -9 * scale)
        }
        .foregroundColor(self.foregroundColor)
    }
}

struct SearchPlusBar: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            CustomSearchBar(searchText: self.$searchText, isSearching: self.$isSearching)
            
            SearchPlusIcon(foregroundColor: Color(UIColor.systemGray))
                .padding(.top, 2)
                .padding(.leading, 16)
        }
    }
}

struct Identity_Previews: PreviewProvider {
    @State static var searchText = ""
    @State static var isFirstResponder = false
    
    static var previews: some View {
        Group {
            SearchPlusIcon()
            SearchPlusBar(searchText: $searchText, isSearching: $isFirstResponder)
        }
    }
}
