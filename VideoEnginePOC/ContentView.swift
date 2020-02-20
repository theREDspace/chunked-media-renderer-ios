//
//  ContentView.swift
//  VideoEnginePOC
//
//  Created by Chris Baltzer on 2019-12-18.
//  Copyright © 2019 Redspace. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let player: Player = Player()
    
    var body: some View {
        VStack {
            PlayerView(player: self.player)
                .frame(height: 320)
                
            Button(action: {
                self.player.load(filename: "BigBuckBunny")
            }) {
                Text("LOAD")
            }
            
            Button(action: {
               self.player.play()
            }) {
                Text("Play")
            }

            Button(action: {
               self.player.pause()
            }) {
                Text("Pause")
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
