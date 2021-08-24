//
//  CommandDestinationViewWrapper.swift
//  Search Plus
//
//  Created by McCoy Zhu on 11/20/20.
//

import SwiftUI

struct CommandDestinationViewWrapper: View {
    @EnvironmentObject var env: ENV
    @Environment(\.presentationMode) var presentation
    @State var isAlertPresented = false
    let destination: (ENV) -> [(content: AnyView, header: String, footer: String)]
    var reset: (ENV) -> () = {_ in}
    var resetDisabled: (ENV) -> Bool = {_ in true}
    var onDismiss: () -> () = {}
    
    func shouldHaveBottomPadding(index: Int) -> Bool {
        return !self.destination(self.env)[index].footer.isEmpty && (index == self.destination(self.env).count - 1 || !self.destination(self.env)[index + 1].header.isEmpty)
    }
    
    var content: some View {
        Group {
            ForEach(0..<self.destination(self.env).count) { index in
                Section(header: Text(self.destination(self.env)[index].header),
                        footer: Text(self.destination(self.env)[index].footer)
                            .padding(shouldHaveBottomPadding(index: index) ? [.bottom] : [])) {
                    self.destination(self.env)[index].content
                }
            }
            
            Button(action: {
                self.isAlertPresented = true
            }, label: {
                HStack {
                    Text("Reset")
                        .foregroundColor(Color(UIColor.systemRed))
                }
            })
            .disabled(self.resetDisabled(self.env))
            .opacity(self.resetDisabled(self.env) ? 0.5 : 1)
            .alert(isPresented: self.$isAlertPresented) {
                Alert(title: Text("Are sure you want to reset?"), message: Text("This action cannot be reverted."), primaryButton: .destructive(Text("Reset"), action: { self.reset(self.env) }), secondaryButton: .cancel())
            }
            
            .navigationBarHidden(false)
            .navigationBarItems(trailing: Button(action: {
                self.onDismiss()
                self.presentation.wrappedValue.dismiss()
            }, label: {
                Text("Done")
                    .fontWeight(.bold)
                    .padding([.vertical, .leading])
            }))
        }
    }
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            Form {
                self.content
            }
        } else {
            List {
                self.content
            }.listStyle(GroupedListStyle())
        }
        
    }
}

struct CommandDestinationViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        CommandDestinationViewWrapper(destination: {_ in [(AnyView(Text("Hi")), "", "")]}).environmentObject(env)
    }
}
