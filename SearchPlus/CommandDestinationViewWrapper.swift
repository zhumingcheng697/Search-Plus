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
    let destination: (ENV) -> [(content: AnyView, header: String, footer: String)]
    var reset: (ENV) -> () = {_ in}
    var resetDisabled: (ENV) -> Bool = {_ in true}
    var onDismiss: () -> () = {}
    
    var body: some View {
        List {
            ForEach(0..<self.destination(self.env).count) { index in
                Section(header: Text(self.destination(self.env)[index].header).padding(self.destination(self.env)[index].header.isEmpty ? [] : [.top]), footer: Text(self.destination(self.env)[index].footer).padding(self.destination(self.env)[index].footer.isEmpty || (self.destination(self.env)[index].header.isEmpty && index != self.destination(self.env).count - 1) ? [] : [.bottom])) {
                    self.destination(self.env)[index].content
                }
            }
            
            Button(action: {
                self.reset(self.env)
            }, label: {
                HStack {
                    Text("Reset")
                        .foregroundColor(Color(UIColor.systemRed))
                }
            })
            .disabled(self.resetDisabled(self.env))
            .opacity(self.resetDisabled(self.env) ? 0.5 : 1)
            
            .navigationBarHidden(false)
            .navigationBarItems(trailing: Button(action: {
                self.onDismiss()
                self.presentation.wrappedValue.dismiss()
            }, label: {
                Text("Done")
                    .fontWeight(.bold)
                    .padding([.vertical, .leading])
            }))
        }.listStyle(GroupedListStyle())
    }
}

struct CommandDestinationViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        CommandDestinationViewWrapper(destination: {_ in [(AnyView(Text("Hi")), "", "")]}).environmentObject(env)
    }
}
