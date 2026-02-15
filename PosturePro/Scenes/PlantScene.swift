//
//  PlantScene.swift
//  PosturePro
//
//  Scena SpriteKit che visualizza una pianta che reagisce alla postura dell'utente.
//

import SpriteKit
import SwiftUI

final class PlantScene: SKScene {
    
    // MARK: - Nodes
    private var stemNode: SKShapeNode?
    private var leafLeft: SKShapeNode?
    private var leafRight: SKShapeNode?
    private var potNode: SKShapeNode?
    
    // MARK: - Colors (SF Green palette)
    private let healthyColor = SKColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1)
    private let sickColor = SKColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 0.9)
    private let potColor = SKColor(red: 0.55, green: 0.45, blue: 0.33, alpha: 1)
    
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        setupPlant()
    }
    
    // MARK: - Setup
    
    private func setupPlant() {
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        // Vaso (trapezio stilizzato)
        let potWidth: CGFloat = 80
        let potTopY: CGFloat = 115
        let potBottomY: CGFloat = 55
        let potPath = CGMutablePath()
        potPath.move(to: CGPoint(x: centerX - potWidth/2 + 10, y: potTopY))
        potPath.addLine(to: CGPoint(x: centerX - potWidth/2 - 5, y: potBottomY))
        potPath.addLine(to: CGPoint(x: centerX + potWidth/2 + 5, y: potBottomY))
        potPath.addLine(to: CGPoint(x: centerX + potWidth/2 - 10, y: potTopY))
        potPath.closeSubpath()
        
        potNode = SKShapeNode(path: potPath)
        potNode?.fillColor = potColor
        potNode?.strokeColor = .clear
        if let pot = potNode { addChild(pot) }
        
        // Stelo
        let stemSize = CGSize(width: 12, height: 120)
        stemNode = SKShapeNode(rectOf: stemSize, cornerRadius: 6)
        stemNode?.fillColor = healthyColor
        stemNode?.strokeColor = .clear
        stemNode?.position = CGPoint(x: centerX, y: centerY - 20)
        if let stem = stemNode { addChild(stem) }
        
        // Foglia sinistra
        leafLeft = SKShapeNode(ellipseOf: CGSize(width: 45, height: 22))
        leafLeft?.fillColor = healthyColor
        leafLeft?.strokeColor = .clear
        leafLeft?.position = CGPoint(x: -18, y: 35)
        leafLeft?.zRotation = .pi / 5
        stemNode?.addChild(leafLeft!)
        
        // Foglia destra
        leafRight = SKShapeNode(ellipseOf: CGSize(width: 50, height: 24))
        leafRight?.fillColor = healthyColor
        leafRight?.strokeColor = .clear
        leafRight?.position = CGPoint(x: 22, y: 45)
        leafRight?.zRotation = -(.pi / 5)
        stemNode?.addChild(leafRight!)
    }
    
    // MARK: - Public
    
    func updatePostureState(isGood: Bool) {
        guard let stem = stemNode, let l1 = leafLeft, let l2 = leafRight else { return }
        
        let targetColor = isGood ? healthyColor : sickColor
        let colorAction = SKAction.customAction(withDuration: 0.6) { node, _ in
            (node as? SKShapeNode)?.fillColor = targetColor
        }
        
        stem.run(colorAction)
        l1.run(colorAction)
        l2.run(colorAction)
        
        if isGood {
            stem.removeAction(forKey: "shake")
            let breathe = SKAction.sequence([
                SKAction.scaleY(to: 1.08, duration: 2.0),
                SKAction.scaleY(to: 1.0, duration: 2.0)
            ])
            stem.run(SKAction.repeatForever(breathe), withKey: "breathe")
        } else {
            stem.removeAction(forKey: "breathe")
            let wobble = SKAction.sequence([
                SKAction.rotate(byAngle: 0.08, duration: 0.08),
                SKAction.rotate(byAngle: -0.16, duration: 0.16),
                SKAction.rotate(byAngle: 0.08, duration: 0.08)
            ])
            stem.run(SKAction.repeatForever(wobble), withKey: "shake")
        }
    }
}
