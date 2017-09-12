//
//  GameScene.swift
//  agar2
//
//  Created by zheng on 5/10/2015.
//  Copyright (c) 2015 zheng. All rights reserved.
//

import SpriteKit
import Darwin
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


var lastUpdateTimeInterval: CFTimeInterval?
var Global_XDirection : CGFloat = 0.0
var Global_YDirection : CGFloat = 0.0
var changeSpeedDirection = false
let playerCategoryName = "player"
let foodCategoryName = "food"
var AIDict = [String : SKSpriteNode]()


let AmountofFoodieStatic = 1000
var CurrentAmountofFoodie = AmountofFoodieStatic
let AmountofSpikeStatic = 20
var CurrentAmountofSpike = AmountofSpikeStatic
let  AmountofAIPlayerStatic = 10
var CurrentAmountofAIPlayer = AmountofAIPlayerStatic

var playercamera = SKCameraNode()
let PlayerCategory : UInt32 = 0x1 << 0 // 00000000000000000000000000000001
let FoodCategory : UInt32 = 0x1 << 1  //000000000000000000000000000000010
let SpikeCategory : UInt32 = 0x1 << 2//000000000000000000000000000000100
let SceneBorder : UInt32 = 0x1 << 3 //000000000000000000000000000001000
let AIPlayerCategory:  UInt32 = 0x1 << 4 //000000000000000000000000000010000
// set max camera scale . Default is 1.
let MaxCameraScaleX = 6
let MaxCameraScaleY = 6
let MinCameraScaleX = 0.8
let MinCameraScaleY = 0.8

let scoreBoardImage  = SKSpriteNode (imageNamed: "scoreBoard")
var scoreBoardLabel1st = SKLabelNode ()
var scoreBoardLabel2nd = SKLabelNode ()
var scoreBoardLabelSelf = SKLabelNode ()
let splitButton = UIButton()

var isMoving = false
var isTouchMoved = false
var nickName = ""


class GameScene: SKScene ,SKPhysicsContactDelegate, GameStartSceneDelegate {
    func PassDataBeteenScenes(_ nickname: String){
        
        nickName = nickname
        nickName = nickName.trimmingCharacters(in: CharacterSet (charactersIn: " "))
        nickName =  nickName.uppercased()

        //now we can use nickname
    }
    
    var isFingerOndisk = false
    var isDiskMoving = false
    var food = SKSpriteNode.init()
    var spike = SKSpriteNode.init()
    var player = Player()
    var aiPlayer = AIPlayer()


    let playdesk  = SKSpriteNode(imageNamed: "playdesk")
    
    
    // - - - - - - - - - - - - - - - - - - - - - - - - didMoveToView - - - - - - - - - - - - - - - - - - - - - - - - //
    
    override func didMove(to view: SKView) {
        print(nickName)
        player = Player(picName: nickName)
        player.name = "player"
        isMoving = false

        if let someCamera:SKCameraNode = self.childNode(withName: "TheCamera") as? SKCameraNode {
            playercamera = someCamera
            self.camera = someCamera
            playercamera.xScale = 0.8
            playercamera.yScale = 0.8
        }
        
        //physical world setup
        physicsWorld.gravity = CGVector(dx: 0,dy: 0)
        physicsWorld.contactDelegate = self
        self.physicsBody?.friction = 0

         // - - - - - - - - - - - - - - - - - - - - - - - - playdesk - - - - - - - - - - - - - - - - - - - - - - - - //
        
        playdesk.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        playdesk.position = CGPoint(x:self.frame.midX, y:self.frame.midY);
        playdesk.physicsBody?.friction = 0
        // setup Game boarder
        let borderbody  = SKPhysicsBody(edgeLoopFrom:playdesk.frame)
        self.physicsBody = borderbody
        borderbody.categoryBitMask = SceneBorder
        borderbody.collisionBitMask = SceneBorder
        borderbody.contactTestBitMask = SceneBorder
        borderbody.restitution = 0.2

         //       player.physicsBody?.restitution = 0
        
        // - - - - - - - - - - - - - - - - - - - - - -Initialise - - food - - - - - - - - - - - - - - - - - - - - - - - - //

        
        var ramdomnumberX = 0
        var ramdomnumberY = 0
        let BoundX = UInt32(playdesk.size.height)
        let BoundX_half = UInt32(playdesk.size.height/2)
        let BoundY = UInt32(playdesk.size.width)
        let BoundY_half = UInt32(playdesk.size.width/2)
        for _ in 0...AmountofFoodieStatic{

            ramdomnumberX = Int(arc4random_uniform(BoundX))-Int(BoundX_half)
            ramdomnumberY = Int(arc4random_uniform(BoundY))-Int(BoundY_half)

            let pickFoodColor = Int(arc4random_uniform(4))
            switch pickFoodColor
            {
            case 0 :
                 food = SKSpriteNode(imageNamed: "food1.png")
            case 1 :
                 food = SKSpriteNode(imageNamed: "foodBlue.png")
            case 2 :
                food = SKSpriteNode(imageNamed: "foodOrange.png")
            case 3 :
                 food = SKSpriteNode(imageNamed: "foodPurple.png")
            default :
                 food = SKSpriteNode(imageNamed: "foodRed.png")
            
            }

            food.color = UIColor.red
            food.position = CGPoint(x: CGFloat(ramdomnumberX), y: CGFloat(ramdomnumberY))
            food.physicsBody?.friction = 0
            food.physicsBody?.restitution = 1
            food.physicsBody?.mass = 0
            food.zPosition = 0.5
            food.physicsBody = SKPhysicsBody(rectangleOf: food.size)
            food.physicsBody?.categoryBitMask = FoodCategory
            food.physicsBody?.collisionBitMask = PlayerCategory|AIPlayerCategory
            food.physicsBody?.contactTestBitMask = PlayerCategory|AIPlayerCategory
            playdesk.addChild(food)
        
        }
        
        
        // - - - - - - - - - - - - - - - - - - - - - - - - spike - - - - - - - - - - - - - - - - - - - - - - - - //
        
        //generate spikes! I hate them when I am big!
        for _ in 0...AmountofSpikeStatic {
        
            
            ramdomnumberX = Int(arc4random_uniform(BoundX))-Int(BoundX_half)
            ramdomnumberY = Int(arc4random_uniform(BoundY))-Int(BoundY_half)
            
            
            spike = SKSpriteNode(imageNamed: "spike.png")
            spike.position = CGPoint(x: CGFloat(ramdomnumberX), y: CGFloat(ramdomnumberY))
//            spike.physicsBody?.friction = 0
            spike.physicsBody?.isDynamic = false
            spike.physicsBody?.pinned = true
            spike.zPosition = 0.6
            spike.physicsBody?.restitution = 0
            
            spike.physicsBody = SKPhysicsBody(circleOfRadius: spike.size.width/2)
            spike.physicsBody!.categoryBitMask = SpikeCategory
            spike.physicsBody!.collisionBitMask = 0
            spike.physicsBody!.contactTestBitMask = PlayerCategory|AIPlayerCategory
            playdesk.addChild(spike)
            
        }
        playdesk.zPosition = 0
        self.addChild(player)
        self.addChild(playdesk)
//print(view.frame.size)


        
        // - - - - - - - - - - - - - - - - - - - - - - - - AIPlayer - - - - - - - - - - - - - - - - - - - - - - - - //
        
        for i in 0...AmountofAIPlayerStatic{
            
             aiPlayer = AIPlayer()
             aiPlayer.name = "AIplayer\(i)"
            AIDict[aiPlayer.name!] = aiPlayer

            ramdomnumberX = Int(arc4random_uniform(BoundX))-Int(BoundX_half)
            ramdomnumberY = Int(arc4random_uniform(BoundY))-Int(BoundY_half)
            
            aiPlayer.position = CGPoint(x: CGFloat(ramdomnumberX), y: CGFloat(ramdomnumberY))
//            aiPlayer.physicsBody?.categoryBitMask = AIPlayerCategory
//            aiPlayer.physicsBody?.collisionBitMask = PlayerCategory|SceneBorder|AIPlayerCategory
//            aiPlayer.physicsBody?.contactTestBitMask = PlayerCategory|SceneBorder
           
           
            if aiPlayer.name != nil {
            self.addChild(aiPlayer)
                let forceLimit = UInt32(10)
                let forceX = Int(arc4random_uniform(forceLimit))-Int(forceLimit/2)
                
                let forceY = Int(arc4random_uniform(forceLimit))-Int(forceLimit/2)
                
                aiPlayer.physicsBody?.applyImpulse(CGVector(dx: CGFloat(forceX), dy: CGFloat(forceY)))
            }
        
        
        }

        
        
        // - - - - - - - - - - - - - - - - - - - - - - - - splitButton - - - - - - - - - - - - - - - - - - - - - - - - //
        // button of split
        
        
        splitButton.frame = CGRect(x: self.view!.frame.midX + 220, y: self.view!.frame.midY + 100, width: 50, height: 50)
        splitButton.backgroundColor = UIColor.clear
        splitButton.setTitle ("Split", for: UIControlState())
        splitButton.setTitleColor (UIColor.white, for: UIControlState())
        splitButton.addTarget (self, action: #selector(GameScene.buttonAction(_:)),for: UIControlEvents.touchDown)
       // splitButton.backgroundColor = UIColor.blackColor()
        let splitButtonImage = UIImage(named: "splitButton") as UIImage!
        splitButton.setImage( splitButtonImage, for: UIControlState())
        self.view!.addSubview(splitButton)
        
     // - - - - - - - - - - - - - - - - - - - - - - - - scoreBoardLabel - - - - - - - - - - - - - - - - - - - - - - - - //
        
     //   scoreBoardImage.position = CGPointMake(CGRectGetMidX(self.view!.frame) + 145, CGRectGetMidY(self.view!.frame) + 70)
        scoreBoardImage.zPosition = 3
        self.addChild(scoreBoardImage)
        
        // score Board 
        
//        scoreBoardLabel1st.position = CGPointMake(CGRectGetMidX(scoreBoardImage.frame) , CGRectGetMidY(scoreBoardImage.frame) )
        scoreBoardLabel1st.zPosition = 4
        scoreBoardLabel1st.text = "1. " + "first name " + "first score"
        scoreBoardLabel1st.fontSize = 10
        scoreBoardLabel1st.fontColor = UIColor.black
        scoreBoardLabel1st.alpha = 1
        scoreBoardLabel1st.fontName = "Chalkduster"
        self.addChild(scoreBoardLabel1st)
        
        
        scoreBoardLabel2nd.zPosition = 4
        scoreBoardLabel2nd.text="2. " + "seconde name " + "second score"
        scoreBoardLabel2nd.fontSize = 10
        scoreBoardLabel2nd.fontColor = UIColor.black
        scoreBoardLabel2nd.alpha = 1
        scoreBoardLabel2nd.fontName = "Chalkduster"
        
    /**
         The second label is not meant to be displayed as the AI player's stats was not tracked currently, once AI's stats is tracked, we can display the second hight
         
         **/
        
//        self.addChild(scoreBoardLabel2nd)
        
//        scoreBoardLabelSelf.zPosition = 4
//        scoreBoardLabelSelf.text = "no. " + "my name " + "my score"
//        scoreBoardLabelSelf.fontSize = 10
//        scoreBoardLabelSelf.fontColor = UIColor.black
//        scoreBoardLabelSelf.alpha = 1
//        scoreBoardLabelSelf.fontName = "Chalkduster"
//        self.addChild(scoreBoardLabelSelf)
        
        }
        // - - - - - - - - - - - - - - - - - - - - - - - - - - function - - - - - - - - - - - - - - - - - - - - - - - - - //
        
    // - - - - - - - - - - - - - - - - - - - - - - - - - - didBeginContact - - - - - - - - - - - - - - - - - - - - - - - - - //


    
   
    func didBegin(_ contact: SKPhysicsContact) {
//        player.physicsBody?.categoryBitMask = PlayerCategory

        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        firstBody = contact.bodyA
        secondBody = contact.bodyB

         // - - - - - - - - - - - - - - - - - - - - - - - - - - spike vs player - - - - - - - - - - - - - - - - - - - - - - - - - //
        
        if firstBody.categoryBitMask == SpikeCategory     && secondBody.node?.name == "player"    {

          //  firstBody.node?.removeFromParent()
            firstBody.node?.physicsBody?.pinned = true
            
            
        }
        
         // - - - - - - - - - - - - - - - - - - - - - - - - - - player vs spike - - - - - - - - - - - - - - - - - - - - - - - - - //
        // touch the spike
        if secondBody.categoryBitMask == SpikeCategory  && firstBody.node?.name == "player"
        {

            player.physicsBody?.pinned = true
            player.destroy()
           // firstBody.node?.removeFromParent()
            // pause wait for the ending animation to be finished 
var timer = Timer.scheduledTimer(timeInterval: 1.2, target: player, selector: Selector("die"), userInfo: nil, repeats: false)
var timer2 = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(GameScene.restart), userInfo: nil, repeats: false)

        }

        // - - - - - - - - - - - - - - - - - - - - - - - - - - food vs player - - - - - - - - - - - - - - - - - - - - - - - - - //
        
        if firstBody.categoryBitMask == FoodCategory && secondBody.node?.name == "player"
        {
            
            firstBody.node?.removeFromParent()
            player.size.width = player.size.width + 1
            player.size.height = player.size.height + 1

//            player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
            player.physicsBody?.categoryBitMask = PlayerCategory


            player.score += 1


            CurrentAmountofFoodie -= 1

            if player.size.width.truncatingRemainder(dividingBy: 5) == 0 && playercamera.xScale <= CGFloat(MaxCameraScaleX)
            {
                playercamera.xScale =  playercamera.xScale + 0.008
                playercamera.yScale =  playercamera.yScale + 0.008
               
            }

        }
        
        // - - - - - - - - - - - - - - - - - - - - - - - - - - player vs aiPlayer - - - - - - - - - - - - - - - - - - - - - - - - - //
        if secondBody.categoryBitMask == AIPlayerCategory && firstBody.node?.name == "player"
        {
            let aiPlayerNode = AIDict[(secondBody.node?.name)!]
            let px = player.position.x
            let py = player.position.y
            
            let AIx = AIDict[(secondBody.node?.name)!]?.position.x
            let AIy = AIDict[(secondBody.node?.name)!]?.position.y
            let distancex = (px-AIx!)*(px-AIx!)
            let distancey = (py-AIy!)*(py-AIy!)
            let distance = sqrt(distancex+distancey)
            let R1PlusR2 = (aiPlayerNode?.size.height)!/2+player.size.height/2

            if distance < R1PlusR2
            {
                print(aiPlayerNode?.size, player.size)
                if aiPlayerNode?.size.width > player.size.width
                {
                    let GameStartSceneView = GameStartScene( fileNamed: "GameStartScene" )
                    let transitionAction = SKAction.run()
                    {let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                    self.view?.presentScene(GameStartSceneView!, transition: reveal)
                    }
                    run(transitionAction)

                }
                if aiPlayerNode?.size.width < player.size.width
                {
                    player.size.width = player.size.width + (aiPlayerNode?.size.width)!/2
                    player.size.height = player.size.height + (aiPlayerNode?.size.height)!/2
                    CurrentAmountofAIPlayer -= 1
                    secondBody.node?.removeFromParent()
                    player.score = player.score + Int((aiPlayerNode?.size.width)!/2)
                }
                
            }
            
            
            
        }

        // - - - - - - - - - - - - - - - - - - - - - - - - - - food vs aiPlayer - - - - - - - - - - - - - - - - - - - - - - - - - //
        
        
        
        if firstBody.categoryBitMask == FoodCategory && secondBody.categoryBitMask == AIPlayerCategory
        {
            firstBody.node?.removeFromParent()
            AIDict[(secondBody.node?.name)!]?.size.height+=1
            AIDict[(secondBody.node?.name)!]?.size.width+=1
            //secondBody.node?.physicsBody = SKPhysicsBody(circleOfRadius:  (AIDict[(secondBody.node?.name)!]?.size.height)!/2)
            
    
            CurrentAmountofFoodie -= 1

        }
        
        // - - - - - - - - - - - - - - - - - - - - - - - - - - food vs aiPlayer - - - - - - - - - - - - - - - - - - - - - - - - - //

        
        
        
        
        
//        if secondBody.categoryBitMask == FoodCategory
//        {
//            print(2)
//            secondBody.node?.removeFromParent()
//            player.size.width = player.size.width + 1
//            player.size.height = player.size.height + 1
//
//           
//        }
        
    }
    func didEnd(_ contact: SKPhysicsContact) {
        //this gets called automatically
        
    }
    
    
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - touchesBegan - - - - - - - - - - - - - - - - - - - - - - - - - //

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
//        print(player.physicsBody?.categoryBitMask)
        isTouchMoved = false
       
        for touch in touches {
            let touchLocation = touch.location(in: self)
//            let previouseLocation = touch.previousLocationInNode(self)
            let touchnode = atPoint(touchLocation)
         //   print("frame .....  ", self.view?.frame)
            
            //resize the playersize
//            player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
             player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
           // player.physicsBody?.linearDamping = -0.06

             if touchnode.name == "player" && isMoving == false
            {
                player.physicsBody?.pinned = false
            }
            
           else if touchnode.name != "player"
            {
                player.physicsBody?.pinned = false
                isMoving = true

            }

     player.move(touchLocation)
            
//            print(Global_YDirection,Global_XDirection)
           
//            displacement.dx = displacement.dx * 12000 / (player.size.width+100)
//            displacement.dy = displacement.dy * 12000 / (player.size.height+100)

//            let movePlayer : SKAction = SKAction.applyImpulse(displacement, duration: 0.1)
//            player.runAction(movePlayer)
//
//            player.physicsBody?.applyImpulse(displacement)
           
            //player.physicsBody?.applyForce(displacement)
            
                
            if let body = physicsWorld.body(at: touchLocation) {

                    if body.node?.name == "player"
                    {
                
                        isFingerOndisk = true
                       

                    }
            
            
            }

//            定义个action 节点去run
        }
    }
    
     // - - - - - - - - - - - - - - - - - - - - - - - - - - touchesMoved - - - - - - - - - - - - - - - - - - - - - - - - - //
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        let touch = touches.first! as UITouch
        let touchLocation = touch.location(in: self)
        
        let touchnode = atPoint(touchLocation)

        
        if touchnode.name == "player" && isMoving == true
                    {
                     player.physicsBody?.pinned = false
                        isTouchMoved = true
                    }

        
        
        
     player.move(touchLocation)
        
        isMoving = true
        
        
        
    }
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - touchesEnded - - - - - - - - - - - - - - - - - - - - - - - - - //

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        
        let touchLocation = touch.location(in: self)
        if let body = physicsWorld.body(at: touchLocation) {
            
            if body.node?.name == "player" && isTouchMoved == true
            {
                isFingerOndisk = false
            }
            else if body.node?.name == "player" && isMoving == true && isTouchMoved == false
            {
                self.player.physicsBody?.pinned = true
                isMoving = false
            }
            
        }
    }
 
    // - - - - - - - - - - - - - - - - - - - - - - - - - - produceFood - - - - - - - - - - - - - - - - - - - - - - - - - //
    
    //howmany should equal to AmountFoodieStatic minus Currentfood
    func produceFood(_ howmany : Int)
    {
        
        var ramdomnumberX = 0
        var ramdomnumberY = 0
        let BoundX = UInt32(playdesk.size.height)
        let BoundX_half = UInt32(playdesk.size.height/2)
        let BoundY = UInt32(playdesk.size.width)
        let BoundY_half = UInt32(playdesk.size.width/2)
        for _ in 0...howmany {
            ramdomnumberX = Int(arc4random_uniform(BoundX))-Int(BoundX_half)
            ramdomnumberY = Int(arc4random_uniform(BoundY))-Int(BoundY_half)

            let pickFoodColor = Int(arc4random_uniform(4))
            switch pickFoodColor
            {
            case 0 :
                food = SKSpriteNode(imageNamed: "food1.png")
            case 1 :
                food = SKSpriteNode(imageNamed: "foodBlue.png")
            case 2 :
                food = SKSpriteNode(imageNamed: "foodOrange.png")
            case 3 :
                food = SKSpriteNode(imageNamed: "foodPurple.png")
            default :
                food = SKSpriteNode(imageNamed: "foodRed.png")
                
            }

            food.color = UIColor.red
            food.position = CGPoint(x: CGFloat(ramdomnumberX), y: CGFloat(ramdomnumberY))
            food.physicsBody?.friction = 0
            food.zPosition = 0.5
            food.physicsBody = SKPhysicsBody(rectangleOf: food.size)
            food.physicsBody?.categoryBitMask = FoodCategory
            food.physicsBody?.collisionBitMask = PlayerCategory|AIPlayerCategory
            
            food.physicsBody?.contactTestBitMask = PlayerCategory|AIPlayerCategory
            CurrentAmountofFoodie += 1
            playdesk.addChild(food)
            
        }
    }
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - produceSpike - - - - - - - - - - - - - - - - - - - - - - - - - //

    
   
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - produceAIPlayer - - - - - - - - - - - - - - - - - - - - - - - - - //
    
    //howmany should equal to AmountFoodieStatic minus Currentfood
    func produceAIPlayer(_ howmany : Int)
    {
        
        var ramdomnumberX = 0
        var ramdomnumberY = 0
        let BoundX = UInt32(playdesk.size.height)
        let BoundX_half = UInt32(playdesk.size.height/2)
        let BoundY = UInt32(playdesk.size.width)
        let BoundY_half = UInt32(playdesk.size.width/2)
        for i in 0...howmany {
            
            aiPlayer = AIPlayer()
            aiPlayer.name = "AIplayer\(i)"
            
            ramdomnumberX = Int(arc4random_uniform(BoundX))-Int(BoundX_half)
            ramdomnumberY = Int(arc4random_uniform(BoundY))-Int(BoundY_half)
            
            aiPlayer.position = CGPoint(x: CGFloat(ramdomnumberX), y: CGFloat(ramdomnumberY))
            aiPlayer.physicsBody?.categoryBitMask = AIPlayerCategory
            aiPlayer.physicsBody?.collisionBitMask = PlayerCategory
            aiPlayer.physicsBody?.contactTestBitMask = PlayerCategory
            
            self.addChild(aiPlayer)
            CurrentAmountofAIPlayer += 1

            
        }
    }

    
    
    
    
     // - - - - - - - - - - - - - - - - - - - - - - - - - - update - - - - - - - - - - - - - - - - - - - - - - - - - //
    
    override func update(_ currentTime: TimeInterval) {

                /* Called before each frame is rendered */
//        if let luti = lastUpdateTimeInterval {
//            delta = currentTime - luti
//        } else {
//            delta = currentTime
//        }
//        lastUpdateTimeInterval = currentTime
//        print(Int(currentTime%6))
            let test=player.playerName
            scoreBoardLabel1st.text = "1. " + test + " " + String(player.score)

            let moveCamera = SKAction.move(to: player.position, duration:0)
            playercamera.run(moveCamera)
        
       let moveScoreBoardImagex = SKAction.moveTo(x: player.position.x + player.size.width + 100, duration: 0)
       let moveScoreBoardImagey = SKAction.moveTo(y: player.position.y + player.size.width/2 + 52, duration: 0)
        scoreBoardImage.run(moveScoreBoardImagex)
        scoreBoardImage.run(moveScoreBoardImagey)
        
        let moveScoreBoardLabel1stx = SKAction.moveTo(x: scoreBoardImage.position.x, duration: 0)
        let moveScoreBoardLabel1sty = SKAction.moveTo(y: scoreBoardImage.position.y, duration: 0)
        scoreBoardLabel1st.run(moveScoreBoardLabel1stx)
        scoreBoardLabel1st.run(moveScoreBoardLabel1sty)
        
        let moveScoreBoardLabel2ndx = SKAction.moveTo(x: scoreBoardImage.position.x, duration: 0)
        let moveScoreBoardLabel2ndy = SKAction.moveTo(y: scoreBoardImage.position.y - 15, duration: 0)
        scoreBoardLabel2nd.run(moveScoreBoardLabel2ndx)
        scoreBoardLabel2nd.run(moveScoreBoardLabel2ndy)
        
        let moveScoreBoardLabelSelfx = SKAction.moveTo(x: scoreBoardImage.position.x, duration: 0)
        let moveScoreBoardLabelSelfy = SKAction.moveTo(y: scoreBoardImage.position.y - 30, duration: 0)
        scoreBoardLabelSelf.run(moveScoreBoardLabelSelfx)
        scoreBoardLabelSelf.run(moveScoreBoardLabelSelfy)
        
        
        
        

//            lastUpdateTimeInterval = currentTime;
        
        //make speed only relate to size
        
        
         player.physicsBody?.velocity = CGVector(dx: Global_XDirection*5000 / player.size.width,dy: Global_YDirection*5000 / player.size.height)
        
        
//        let speed = sqrt(player.physicsBody!.velocity.dx * player.physicsBody!.velocity.dx + player.physicsBody!.velocity.dy * player.physicsBody!.velocity.dy)
        

//produce food reqularly
        if CurrentAmountofFoodie < 1000 && CurrentAmountofFoodie % 100 == 0
        {
            produceFood(AmountofFoodieStatic - CurrentAmountofFoodie)

        }
//produce AI reqularly
        if CurrentAmountofAIPlayer == 0        {
            
            let GameStartSceneView = GameStartScene( fileNamed: "GameStartScene" )
            let transitionAction = SKAction.run()
                {let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                self.view?.presentScene(GameStartSceneView!, transition: reveal)
            }
            run(transitionAction)
            
        }
        
        
    }
    
    // - - - - - - - - - - - - - - - - - - - - - - - - - - buttonAction - - - - - - - - - - - - - - - - - - - - - - - - - //
    
    func buttonAction(_ sender: UIButton){
        
        split(1)
        
        
        print("button down")
    }
    
        // - - - - - - - - - - - - - - - - - - - - - - - - - - split - - - - - - - - - - - - - - - - - - - - - - - - - //
    
    func split (_ splitTime: Int){
        // generate another 'player'
//             for var i = 1; i <= splitTime; i += 1
        for i in 0...splitTime
        {
            var newsprite = player.copy() as! SKSpriteNode
            newsprite.name = "shape\(i)"
            newsprite.position = player.position
            newsprite.size = CGSize(width: player.size.width/2, height: player.size.height/2)
            newsprite.physicsBody = SKPhysicsBody(circleOfRadius: newsprite.size.width/2)
            newsprite.zPosition = 0.6
            newsprite.physicsBody?.friction = 0
            newsprite.physicsBody?.linearDamping = 0
            newsprite.physicsBody?.categoryBitMask = PlayerCategory
            newsprite.physicsBody!.collisionBitMask = PlayerCategory|FoodCategory|SceneBorder
            newsprite.physicsBody!.contactTestBitMask = PlayerCategory|FoodCategory|SpikeCategory|SceneBorder
            newsprite.physicsBody?.restitution = 0
            
            player.size = CGSize(width: player.size.width/2, height: player.size.height/2)
            self.addChild(newsprite)
            
//            var joint = SKPhysicsJointLimit.jointWithBodyA(player.physicsBody!, bodyB: newsprite.physicsBody!, anchorA: CGPointMake(0.5, 0.5), anchorB: CGPointMake(0.5, 0.5))
//            joint.maxLength = 1
//            physicsWorld.addJoint(joint)

            func touchesBegan(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
                /* Called when a touch begins */
                
                isTouchMoved = false
                
                for touch in touches {
                    let touchLocation = touch.location(in: self)
                    //            let previouseLocation = touch.previousLocationInNode(self)
                    let touchnode = atPoint(touchLocation)
                    //   print("frame .....  ", self.view?.frame)
                    
                    //resize the playersize
                    //            player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
                    player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
                    // player.physicsBody?.linearDamping = -0.06
                    
                    if touchnode.name == "player" && isMoving == false
                    {
                        player.physicsBody?.pinned = false
                    }
                        
                    else if touchnode.name != "player"
                    {
                        player.physicsBody?.pinned = false
                        isMoving = true
                        
                    }
                }
            
            
            
// shooting directino and velocity
            
        
        
        }
        }
    }
    func restart () {
        splitButton.removeFromSuperview()
let GameStartSceneView = GameStartScene( fileNamed: "GameStartScene" )
let transitionAction = SKAction.run()
{let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
self.view?.presentScene(GameStartSceneView!, transition: reveal)
}
run(transitionAction)
}
}
