//
//  CustomSearchBar.swift
//  Search Plus
//
//  Created by McCoy Zhu on 11/19/20.
//

import UIKit
import SwiftUI

struct CustomSearchBar: UIViewRepresentable {

    class Coordinator: NSObject, UISearchBarDelegate {

        var searchText: Binding<String>
        var isSearching: Binding<Bool>
        
        init(searchText: Binding<String>, isSearching: Binding<Bool>) {
            self.searchText = searchText
            self.isSearching = isSearching
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.searchText.wrappedValue = searchText
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.isSearching.wrappedValue = true
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            self.isSearching.wrappedValue = false
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            self.searchText.wrappedValue = ""
            searchBar.resignFirstResponder()
        }
    }

    @Binding var searchText: String
    @Binding var isSearching: Bool

    func makeUIView(context: UIViewRepresentableContext<CustomSearchBar>) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.text = self.searchText
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchBar.setPositionAdjustment(.init(horizontal: 25, vertical: 0), for: .search)
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search with Search Plus"
        searchBar.delegate = context.coordinator
        searchBar.returnKeyType = .search
        return searchBar
    }

    func makeCoordinator() -> CustomSearchBar.Coordinator {
        return Coordinator(searchText: self.$searchText, isSearching: self.$isSearching)
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<CustomSearchBar>) {
        uiView.delegate = context.coordinator
        
        if !self.isSearching || self.searchText.isEmpty {
            uiView.text = self.searchText
        }
        
        if self.isSearching || !self.searchText.isEmpty {
            uiView.setShowsCancelButton(true, animated: true)
        } else {
            uiView.setShowsCancelButton(false, animated: true)
        }
        
        if self.isSearching && !uiView.isFirstResponder { 
            uiView.becomeFirstResponder()
        } else if !self.isSearching && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
        
        if let cancelButton = uiView.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
}

struct CustomSearchBar_Previews: PreviewProvider {
    @State static var searchText = ""
    @State static var isFirstResponder = false
    
    static var previews: some View {
        Group {
            CustomSearchBar(searchText: $searchText, isSearching: $isFirstResponder)
        }
    }
}
