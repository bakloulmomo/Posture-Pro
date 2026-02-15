//
//  PlantScene.swift
//  PosturePro
//
//  Pianta amichevole che reagisce alla postura.
//

import SpriteKit

// MARK: - Design (modifica qui per cambiare la pianta)

private enum PlantDesign {
    static let healthyGreen = SKColor(red: 0.35, green: 0.75, blue: 0.45, alpha: 1)
    static let sickAmber = SKColor(red: 0.92, green: 0.68, blue: 0.38, alpha: 1)
    static let potTerracotta = SKColor(red: 0.82, green: 0.58, blue: 0.48, alpha: 1)
    static let potRim = SKColor(red: 0.75, green: 0.52, blue: 0.42, alpha: 1)
}

final class PlantScene: SKScene {
    
    private var stemNode: SKShapeNode?
    private var leafNodes: [SKShapeNode] = []
    private var potBody: SKShapeNode?
    private var potRimNode: SKShapeNode?
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        setupPlant()
    }
    
    private func setupPlant() {
        let cx = size.width / 2
        let cy = size.height / 2
        
        // Vaso: corpo trapezoidale con bordo superiore
        setupPot(centerX: cx)
        
        // Stelo morbido (rettangolo arrotondato)
        let stem = SKShapeNode(rectOf: CGSize(width: 14, height: 130), cornerRadius: 8)
        stem.fillColor = PlantDesign.healthyGreen
        stem.strokeColor = .clear
        stem.position = CGPoint(x: cx, y: cy - 10)
        addChild(stem)
        stemNode = stem
        
        // Foglie: forme organiche, più carine
        addLeaf(to: stem, size: CGSize(width: 48, height: 28), position: CGPoint(x: -22, y: 40), rotation: .pi / 6)
        addLeaf(to: stem, size: CGSize(width: 52, height: 30), position: CGPoint(x: 24, y: 50), rotation: -(.pi / 6))
        addLeaf(to: stem, size: CGSize(width: 40, height: 24), position: CGPoint(x: -14, y: 5), rotation: .pi / 8)
    }
    
    private func setupPot(centerX cx: CGFloat) {
        // Corpo vaso (trapezio arrotondato)
        let potTop: CGFloat = 120
        let potBottom: CGFloat = 45
        let potW: CGFloat = 90
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx - potW/2 + 12, y: potTop))
        path.addLine(to: CGPoint(x: cx - potW/2 - 8, y: potBottom))
        path.addLine(to: CGPoint(x: cx + potW/2 + 8, y: potBottom))
        path.addLine(to: CGPoint(x: cx + potW/2 - 12, y: potTop))
        path.closeSubpath()
        
        let pot = SKShapeNode(path: path)
        pot.fillColor = PlantDesign.potTerracotta
        pot.strokeColor = .clear
        addChild(pot)
        potBody = pot
        
        // Bordo superiore (ellisse orizzontale)
        let rim = SKShapeNode(ellipseOf: CGSize(width: potW + 8, height: 18))
        rim.fillColor = PlantDesign.potRim
        rim.strokeColor = .clear
        rim.position = CGPoint(x: cx, y: potTop + 4)
        addChild(rim)
        potRimNode = rim
    }
    
    private func addLeaf(to parent: SKNode, size: CGSize, position: CGPoint, rotation: CGFloat) {
        let leaf = SKShapeNode(ellipseOf: size)
        leaf.fillColor = PlantDesign.healthyGreen
        leaf.strokeColor = .clear
        leaf.position = position
        leaf.zRotation = rotation
        parent.addChild(leaf)
        leafNodes.append(leaf)
    }
    
    func updatePostureState(isGood: Bool) {
        guard let stem = stemNode else { return }
        
        let color = isGood ? PlantDesign.healthyGreen : PlantDesign.sickAmber
        let colorize = SKAction.customAction(withDuration: 0.5) { node, _ in
            (node as? SKShapeNode)?.fillColor = color
        }
        
        stem.run(colorize)
        leafNodes.forEach { $0.run(colorize) }
        
        if isGood {
            stem.removeAction(forKey: "wobble")
            let breathe = SKAction.sequence([
                SKAction.scaleY(to: 1.06, duration: 2.2),
                SKAction.scaleY(to: 1.0, duration: 2.2)
            ])
            stem.run(SKAction.repeatForever(breathe), withKey: "breathe")
        } else {
            stem.removeAction(forKey: "breathe")
            let wobble = SKAction.sequence([
                SKAction.rotate(byAngle: 0.06, duration: 0.1),
                SKAction.rotate(byAngle: -0.12, duration: 0.1),
                SKAction.rotate(byAngle: 0.06, duration: 0.1)
            ])
            stem.run(SKAction.repeatForever(wobble), withKey: "wobble")
        }
    }
}
