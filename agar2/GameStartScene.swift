//
//  GameStartScene.swift
//  agar2
//
//  Created by zheng on 6/10/2015.
//  Copyright © 2015 zheng. All rights reserved.
//

import SpriteKit
import Darwin
protocol GameStartSceneDelegate
{
    func PassDataBeteenScenes (_ nickname : String)
    
}
class GameStartScene: SKScene,UITextFieldDelegate{
     var thisDelegate : GameStartSceneDelegate?
    var nickNameTextField = UITextField()

    override func didMove(to view: SKView)
    {
             let background = SKSpriteNode(imageNamed: "startpage")
            self.anchorPoint  = background.anchorPoint
            background.position = self.position
        nickNameTextField = UITextField.init(frame: CGRect(x: 180, y: 50, width: 250, height: 40))
        nickNameTextField.backgroundColor = UIColor.clear
//        nickNameTextField.layer.cornerRadius=12.0;
//        nickNameTextField.layer.borderWidth=2.0;
//        nickNameTextField.center = self.view!.center;
//        nickNameTextField.borderStyle =  UITextBorderStyle.line
        nickNameTextField.placeholder = "   Enter your nickname here! "
        nickNameTextField.delegate = self
        //define singel play label and multiplay
        
       let siglePlayLabel  = childNode(withName: "singlePlayModeLabel")  as!SKLabelNode
    let multiPlayLabel  = childNode(withName: "MultiplayModeLabel") as! SKLabelNode
        
        siglePlayLabel.position = CGPoint(x: background.position.x-150, y: background.position.y-100)
        
        siglePlayLabel.fontName =  "Arial"
        siglePlayLabel.zPosition = 0.5
        multiPlayLabel.position = CGPoint(x: background.position.x+150, y: background.position.y-100)
        multiPlayLabel.zPosition = 0.5
//        siglePlayLabel.text = "Single Mode"
//        multiPlayLabel.text = "Multiplayer Mode"
//        
//        background.addChild(siglePlayLabel)
//        background.addChild(multiPlayLabel)
        addChild( background)
        self.view?.addSubview(nickNameTextField)

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch : AnyObject in touches
        {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            if let nodeName = node.name {
                print(nodeName)
                switch nodeName {
                
                    case "singlePlayModeLabel":
                        let GameSceneView = GameScene( fileNamed: "GameScene" )
                        let transitionAction = SKAction.run()
                            {
                                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                                self.view?.presentScene(GameSceneView!, transition: reveal)
                        }
                        GameSceneView!.PassDataBeteenScenes("no name")
                        
                        run(transitionAction)
                        nickNameTextField.removeFromSuperview()

                        //实现页面跳转 跟从textfield 跳转相同
                    print("siglePlayLabel")
                    case "MultiplayModeLabel":
                    //实现连接服务器 发请求 接受 blahblah
                    print("multiPlayLabel")
                    default :
                    print("you should do sth else")
                
                }
            
            }

        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {

        let GameSceneView = GameScene( fileNamed: "GameScene" )
        if textField == nickNameTextField
        {

            
            let transitionAction = SKAction.run()
                {
                    let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                    self.view?.presentScene(GameSceneView!, transition: reveal)
            }
            GameSceneView!.PassDataBeteenScenes(nickNameTextField.text!)

            run(transitionAction)
            nickNameTextField.removeFromSuperview()
        }
        return true
    }
    
    
}
