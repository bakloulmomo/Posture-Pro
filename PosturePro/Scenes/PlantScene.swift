//
//  PlantScene.swift
//  PosturePro
//

import SpriteKit
import UIKit

// MARK: - Design (modifica qui)

private enum PlantDesign {
    static let healthyGreen = SKColor(red: 0.32, green: 0.72, blue: 0.42, alpha: 1)
    static let healthyHighlight = SKColor(red: 0.45, green: 0.82, blue: 0.52, alpha: 1)
    static let sickAmber = SKColor(red: 0.94, green: 0.65, blue: 0.32, alpha: 1)
    static let potTerracotta = SKColor(red: 0.88, green: 0.62, blue: 0.50, alpha: 1)
    static let potRim = SKColor(red: 0.80, green: 0.54, blue: 0.42, alpha: 1)
}

final class PlantScene: SKScene {
    
    private var stemNode: SKShapeNode?
    private var leafNodes: [SKShapeNode] = []
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        setupPlant()
    }
    
    private func setupPlant() {
        let cx = size.width / 2
        let cy = size.height / 2
        
        setupPot(centerX: cx)
        
        let stem = SKShapeNode(rectOf: CGSize(width: 12, height: 118), cornerRadius: 7)
        stem.fillColor = PlantDesign.healthyGreen
        stem.strokeColor = .clear
        stem.position = CGPoint(x: cx, y: cy - 8)
        addChild(stem)
        stemNode = stem
        
        addOrganicLeaf(to: stem, width: 56, height: 32, x: -26, y: 42, rotation: .pi / 7)
        addOrganicLeaf(to: stem, width: 62, height: 36, x: 28, y: 52, rotation: -(.pi / 6))
        addOrganicLeaf(to: stem, width: 44, height: 26, x: -18, y: 8, rotation: .pi / 10)
    }
    
    private func setupPot(centerX cx: CGFloat) {
        let potTop: CGFloat = 115
        let potBottom: CGFloat = 42
        let potW: CGFloat = 88
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cx - potW/2 + 14, y: potTop))
        path.addLine(to: CGPoint(x: cx - potW/2 - 10, y: potBottom))
        path.addLine(to: CGPoint(x: cx + potW/2 + 10, y: potBottom))
        path.addLine(to: CGPoint(x: cx + potW/2 - 14, y: potTop))
        path.closeSubpath()
        
        let pot = SKShapeNode(path: path)
        pot.fillColor = PlantDesign.potTerracotta
        pot.strokeColor = .clear
        addChild(pot)
        
        let rim = SKShapeNode(ellipseOf: CGSize(width: potW + 12, height: 20))
        rim.fillColor = PlantDesign.potRim
        rim.strokeColor = .clear
        rim.position = CGPoint(x: cx, y: potTop + 6)
        addChild(rim)
    }
    
    /// Foglia organica a forma di lacrima (base verso stelo, punta verso l'esterno)
    private func addOrganicLeaf(to parent: SKNode, width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat, rotation: CGFloat) {
        let path = UIBezierPath()
        let w = width / 2
        let h = height / 2
        
        path.move(to: CGPoint(x: 0, y: -h))
        path.addCurve(
            to: CGPoint(x: 0, y: h),
            controlPoint1: CGPoint(x: w, y: -h * 0.3),
            controlPoint2: CGPoint(x: w, y: h * 0.3)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: -h),
            controlPoint1: CGPoint(x: -w, y: h * 0.3),
            controlPoint2: CGPoint(x: -w, y: -h * 0.3)
        )
        path.close()
        
        let leaf = SKShapeNode(path: path.cgPath)
        leaf.fillColor = PlantDesign.healthyGreen
        leaf.strokeColor = .clear
        leaf.position = CGPoint(x: x, y: y)
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
                SKAction.scaleY(to: 1.05, duration: 2.0),
                SKAction.scaleY(to: 1.0, duration: 2.0)
            ])
            stem.run(SKAction.repeatForever(breathe), withKey: "breathe")
        } else {
            stem.removeAction(forKey: "breathe")
            let wobble = SKAction.sequence([
                SKAction.rotate(byAngle: 0.05, duration: 0.1),
                SKAction.rotate(byAngle: -0.1, duration: 0.1),
                SKAction.rotate(byAngle: 0.05, duration: 0.1)
            ])
            stem.run(SKAction.repeatForever(wobble), withKey: "wobble")
        }
    }
}
