//
//  PlayerView.swift
//  NexusPOC
//
//  Created by Chris Baltzer on 2019-12-04.
//  Copyright © 2019 Chris Baltzer. All rights reserved.
//


import SwiftUI
import UIKit
import Foundation

struct PlayerView: UIViewRepresentable {
    
    private let player: Player
    
    init(player: Player) {
        self.player = player
    }
    
    func makeUIView(context: Context) -> UIPlayerView {
        UIPlayerView(player: self.player)
    }
    
    func updateUIView(_ view: UIPlayerView, context: Context) {
        view.setNeedsLayout()
    }
}


struct PlayerView_Preview: PreviewProvider {
    static var previews: some View {
        PlayerView(player: Player())
    }
}


class UIPlayerView: UIView {
    
    var player: Player
        
    init(player: Player) {
        self.player = player
        super.init(frame: .zero)
        
        self.layer.addSublayer(player.displayLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        player.frame = bounds
    }
}
