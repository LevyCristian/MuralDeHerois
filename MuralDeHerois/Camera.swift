//
//  Camera.swift
//  MuralDeHerois
//
//  Created by Levy Cristian  on 04/03/19.
//  Copyright © 2019 Levy Cristian . All rights reserved.
//

import UIKit
import SpriteKit

class Camera: SKCameraNode {
    
    // MARK: Properties
    
    // MARK: Váriaveis padrões
    
    /** O nó da câmera. Tudo que você querira que seja afetádo pela câmera deve ser filho desse nó. */
    let cenario: SKNode
    
    /** Limites do Tela do iPhone. O valor padrão é o size da View, mas esse valor pode ser mudado. */
    private var bounds: CGRect
    
    /**  Limites do cenário. */
    private var cenarioFrame: CGRect
    
    private var isEnabled: Bool
    /** Habilita/Desabilita a câmera. */
    var enabled: Bool {
        get { return isEnabled }
        set {
            isEnabled = newValue
            //Habilita o gesture quando a câmera for habilitada
            pinchGestureRecognizer.isEnabled = newValue
            
        }
    }
    
    /** Habilita/Desabilita o travamento da câmera */
    var enableClamping: Bool
    
    // MARK: Zoom in/out
    
    /** O atual valor da escala da câmera. */
    private var zoomScale: CGFloat
    
    /** Min/Max possível da escala da câmera durante o zoom in/out. */
    var zoomRange: (min: CGFloat, max: CGFloat)
    
    /** Habilita/Desabilita o zoom da câmera. */
    var allowZoom: Bool
    
    /** Gesture para o zoom da câmera. */
    var pinchGestureRecognizer: UIPinchGestureRecognizer!

    /** Determina a posição inicial do toque quando o usuário faz o pinchGesture. */
    private var initialTouchLocation = CGPoint.zero
   
    
    
    init(sceneView: SKView, cenario: SKNode) {
        //configurações iniciais da câmera
        self.cenario = cenario
        self.cenarioFrame = cenario.frame
        self.bounds = sceneView.bounds

        //determina a escla inicial do zoom para 1
        zoomScale = 1.0
        //determina o intervalo de escla do zoom para o intervalo [1,1.3]
        zoomRange = (1, 1.5)
        //habilita a câmera e o zoom
        allowZoom = true
        isEnabled = true
        //habilita o travamento da câmera para tentativa de sair do cenário
        enableClamping = true
        super.init()
        
        //adiciona o gesture a view da câmera
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.updateScale(_:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Escala e Zoom
    
    /** Aplica uma escala ao Cenário. */
    func applyZoomScale(scale: CGFloat) {
        
        var zoomScale = scale
        
        if zoomScale < zoomRange.min {
            zoomScale = zoomRange.min
        } else if zoomScale > zoomRange.max {
            zoomScale = zoomRange.max
        }
        
        self.zoomScale = zoomScale
        cenario.setScale(zoomScale)
    }
    
    
    // MARK: Bounds
    
    /** Mantém o cenário travado em limites especificos. */
    private func clampWorldNode() {
        
        //A variável enableClamping precisa está habilitada para que os limites serem mantidos
        if !enableClamping { return }
        
        //Cálcula o limites da tela
        // Os cálculos do tipo (bounds.size.width / 2) são necessários para a compensação mátematica da câmera em relação ao seu anchor point. Mais informações na Parte 1 (o link é encontrado no final dessa parte).
        let frame = cenarioFrame
        var minX = frame.minX + (bounds.size.width / 2)
        var maxX = frame.maxX - (bounds.size.width / 2)
        var minY = frame.minY + (bounds.size.height / 2)
        var maxY = frame.maxY - (bounds.size.height / 2)
        
        
        //Essa verificações são necessárias para saber se o tamanho do cenário é menor do que o tamanho da View, se sim os valores são trocados.
        if frame.width < bounds.width {
            swap(&minX, &maxX)
        }
        
        if frame.height < bounds.height {
            swap(&minY, &maxY)
        }
        
        //Verifica se o usuário está nos limites. Caso ele ultrapasse algum deles, será setádo o seu respectivo valor min ou max .
        if position.x < minX {
            position.x = CGFloat(Int(minX))
        } else if position.x > maxX {
            position.x = CGFloat(Int(maxX))
        }
        
        if position.y < minY {
            position.y = CGFloat(Int(minY))
        } else if position.y > maxY {
            position.y = CGFloat(Int(maxY))
        }
        
    }
    
    // MARK: Posicionando
    
    /** Move a câmera pra uma posição checando seus limites. */
    func centerOnPosition(scenePosition: CGPoint) {
        // verifica se a escala está nos parametros válidos e atribui o valor recebido a posição da câmera
        if zoomScale > zoomRange.min && zoomScale < zoomRange.max {
            position = scenePosition
            clampWorldNode()
        }
       
    }
    
    // MARK: Input
    
    /** Escala o cenário a partir de um input proveniente do pinchGestureRecognizer.*/
    @objc func updateScale(_ recognizer: UIPinchGestureRecognizer) {
        
        guard let scene = self.scene else { return }
        
        //captura o primeiro toque do usuário
        if recognizer.state == .began {
            initialTouchLocation = scene.convertPoint(fromView: recognizer.location(in: recognizer.view))
            
        }
        //Cálcula o zoom, aplica no cenário e centraliza a câmera.
        if recognizer.state == .changed && enabled && allowZoom {
            
            zoomScale *= recognizer.scale
            applyZoomScale(scale: zoomScale)
            recognizer.scale = 1
            centerOnPosition(scenePosition: CGPoint(x: initialTouchLocation.x * zoomScale, y: initialTouchLocation.y * zoomScale))
        }
        
        if recognizer.state == .ended { }
    }
}
