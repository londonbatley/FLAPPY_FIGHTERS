//
//  GameScene.swift
//  FLAPPY_FIGHTERS
//
//  Created by iD Student on 6/29/15.
//  Copyright (c) 2015 iD Student. All rights reserved.
//
/*
RULES:

1. Avoid your flappy falling of the screen. (By being pushed back by the lightning bolts.)
2. You may not  hit the ground, but you may hit the lightning bolts.
3. Kill as many evil flappies as you can, and see what tricks you can make your flappy do while doing sso.
4. You increase the speed of the good flappy by using the scroll bar on the right.



ONLY CALL THE FUNCTION WITH THE COMPUTER FLAPPY WHEN A NEW LIGHTNING BOLT IS MADE
*/

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Simulated jump physics
    
    
    //var isJumping = false
    
    var jumpTouchDetected: Bool = false
    /*
    var jumpStartTime: Double = 0.0
    var jumpCurrentTime: Float = 0.0
    var jumpEndTime: Float = 0.0
    let jumpDuration: Float = 0.35
    let jumpVelocity: Float = 500.0
    var currentVelocity: Float = 0.0
    var jumpInertiaTime: Float!
    var fallInertiaTime: Float!
    sksprite
    //Delta time
    var lastUpdateTimeInterval: CFTimeInterval = -1.0
    var deltaTime: Float = 0.0
    
    */
    var timer: NSTimer?
    
    var myScene: GameViewController!
    
    var scoreLabel: Int = 0
    
    
    
    let totalGroundPieces = 7
    var groundPieces = [SKSpriteNode]()
    let groundSpeed: Double = 10.25
    var moveGroundAction: SKAction!
    var moveGroundForeverAction: SKAction!
    let groundResetXCoord: Float = -120
    
    var flappySpeed: Double = 0
    var flappy: SKSpriteNode!
    var flappyAtlas = SKTextureAtlas(named: "flappy")
    var flappyFrames = [SKTexture]()
    var yPosOfEvilFlappy: Int = 320
    var yPos: Int!
    
    //obstacles variables
    var obstacles = [SKNode]()
    let heightBetweenObstacles = 485
    let timeBetweenObstacles = 1.50
    let bottomObstacleMaxYPos = 185
    let bottomObstacleMinYPos = -85
    let ObstacleXStartPos: CGFloat = 1085
    let ObstacleXDestroyPos: CGFloat = -150
    var moveObstacleAction: SKAction!
    var moveObstacleForeverAction: SKAction!
    var obstacleTimer: NSTimer!
    
    ///
    let category_flappy: UInt32 = 1 << 0
    let category_ground: UInt32 = 1 << 1
    let category_obstacle: UInt32 = 1 << 2
    let category_score: UInt32 = 1 << 3
    let category_projectile: UInt32 = 1 << 4
    let category_evilFlappy: UInt32 = 1 << 4
    
    
    var evilFlappy: SKSpriteNode!
    var projectile: SKSpriteNode!
    var nothing = false
    
    
    var projectileOnScreen = true
    
    var scoreUp: Bool = false
    var scoreStaySame: Bool!
    // when right side of screen is pressed it becomes true
    //when it is true it is added to the screen, and gets an impulse
    //then if it's position is within a range near the y and x values of the enemy bird, the enemy will disapear, the good bird will reset to the start of the screen, and score will go up one
    
    
    //make it so that when the bird goes off the screen it dies
    //when the bird goes off the screen it dies, and goes to the other screen which is also the title screen, and rules screen.
    //there are only two screens: the playing screen and the title/score/gameover/rules screen
    //also make a small display on the play screen which shows current score
    
    override func didMoveToView(view: SKView) { //you can think of this also as button pressed
        
        
        physicsWorld.contactDelegate = self
        myScene.gameOverLabel.hidden = true
        
        
        projectile = SKSpriteNode(imageNamed: "projectile")
        
        scoreStaySame = false
        
        setupScenery()
        initSetup()
        startGame()
        setupGoodFlappies()
        self.physicsWorld.gravity = CGVectorMake(0, -2)
        
        
        
    }
    
    func movedSlider(value: Float) {
        flappySpeed = Double(value)
        
    }
    
    
    func createBottomObstacleSet(timer : NSTimer) {
        var ObstacleSet = SKNode()
        
        var spriteName = "bottom-01 copy"
        
        //bottomobstacles
        var bottomObstacle = SKSpriteNode(imageNamed: spriteName)
        ObstacleSet.addChild(bottomObstacle)
        var yPos = Int(arc4random()) % (bottomObstacleMaxYPos - bottomObstacleMinYPos)
        yPosOfEvilFlappy = yPos + 226
        moveEvilFlappy()
        bottomObstacle.position = CGPointMake(0, CGFloat(yPos))
        bottomObstacle.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "bottom-01 copy.png"), size: bottomObstacle.size)//makes transparent pixels not be recognized
        bottomObstacle.physicsBody!.dynamic = false
        bottomObstacle.physicsBody!.categoryBitMask = category_obstacle
        bottomObstacle.physicsBody!.contactTestBitMask = category_flappy
        bottomObstacle.name = "bottomBolt"
        
        
        //topobstacles
        spriteName = "top-01 copy"
        var topObstacle = SKSpriteNode(imageNamed: spriteName)
        topObstacle.position = CGPointMake(0, bottomObstacle.position.y + CGFloat(heightBetweenObstacles))
        ObstacleSet.addChild(topObstacle)
        topObstacle.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "top-01 copy.png"), size: topObstacle.size)//makes transparent pixels not be recognized
        topObstacle.physicsBody!.dynamic = false
        topObstacle.physicsBody!.categoryBitMask = category_obstacle
        topObstacle.physicsBody!.contactTestBitMask = category_flappy
        topObstacle.name = "topBolt"
        
        moveObstacleForeverAction = SKAction.moveTo(CGPoint(x: -bottomObstacle.size.width, y: ObstacleSet.position.y), duration: 5)//SKAction.moveBy(CGVector(dx: -0.2, dy: 0), duration: 0.001)
        
        
        
        obstacles.append(ObstacleSet)
        ObstacleSet.zPosition = 4
        ObstacleSet.runAction(moveObstacleForeverAction, completion: {
            ObstacleSet.removeFromParent()
        })
        self.addChild(ObstacleSet)
        ObstacleSet.position = CGPointMake(ObstacleXStartPos, ObstacleSet.position.y)
    }
    
    
    
    
    func setupGoodFlappies()
    {
        var totalImgs = flappyAtlas.textureNames.count
        
        for var x = 1; x < totalImgs; x++
        {
            var textureName = "flappy-0\(x)"
            var texture = flappyAtlas.textureNamed(textureName)
            flappyFrames.append(texture)
        }
        
        flappy = SKSpriteNode(texture: flappyFrames[0])
        flappy.physicsBody = SKPhysicsBody(circleOfRadius: flappy.size.height/2)
        flappy.physicsBody?.dynamic = true
        flappy.zPosition = 6
        flappy.physicsBody?.affectedByGravity = true
        self.addChild(flappy)
        flappy.position = CGPointMake(CGRectGetMidX(self.frame)-350, CGRectGetMidY(self.frame)+100)
        flappy.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(flappyFrames, timePerFrame: 0.2, resize: false, restore: true)))
        
        flappy.physicsBody!.categoryBitMask = category_flappy
        flappy.physicsBody!.collisionBitMask = category_ground | category_obstacle
        flappy.physicsBody!.contactTestBitMask = category_ground | category_obstacle
        flappy.name = "flappy"
        
        
    }
    
    
    func setupScenery() {
        /* Setup your scene here */
        var bg = SKSpriteNode(imageNamed: "SkyNew")
        bg.position = CGPointMake(bg.size.width / 2, bg.size.height / 2)
        
        
        
        self.addChild(bg)
        
        var HillsNew = SKSpriteNode(imageNamed: "HillsNew")
        HillsNew.position = CGPointMake(HillsNew.size.width / 2, HillsNew.size.height/2)
        
        
        self.addChild(HillsNew)
        for var x = 0; x < totalGroundPieces; x=x+1
        {
            var sprite = SKSpriteNode(imageNamed: "ground_piece")
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
            sprite.physicsBody!.dynamic = false
            sprite.physicsBody!.categoryBitMask = category_ground
            sprite.zPosition = 5
            groundPieces.append(sprite)
            
            var wSpacing = sprite.size.width / 2
            var hSpacing = sprite.size.height / 2
            
            if x == 0
            {
                sprite.position = CGPointMake(wSpacing, hSpacing)
            }
            else
            {
                sprite.position = CGPointMake((wSpacing * 2) + groundPieces[x - 1].position.x,groundPieces[x - 1].position.y)
            }
            
            self.addChild(sprite)
            sprite.name = "sprite"
        }
    }
    func initSetup() {
        
        moveGroundAction = SKAction.moveByX(CGFloat(-groundSpeed), y: 0.0, duration: 0.05)
        moveGroundForeverAction = SKAction.repeatActionForever(SKAction.sequence([moveGroundAction]))
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            if touch.locationInNode(self).x <= size.width / 2 {
                
                flappy.physicsBody?.velocity = CGVectorMake(0, 0)
                let a = SKAction.moveByX(0, y: 80, duration: 0.13)
                flappy.runAction(a)
                let b = SKAction.rotateToAngle(0.3, duration: Double(0.08))
                flappy.runAction(b)
                NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("timerFired"), userInfo: nil, repeats: false)
                
                
            }else if projectileOnScreen == true{
                projectileOnScreen = false
                setupProjectileWhenTrue()
                
            }else{
                setupProjectileWhenFalse()
            }
            
        }
        
        
    }
    
    
    func timerFired() {
        let action = SKAction.rotateToAngle(6.28318531, duration: 0.05, shortestUnitArc: true)
        flappy.runAction(action)
    }
    
    func groundMovement(){
        
        for var x = 0; x < groundPieces.count; x++
        {
            if groundPieces[x].position.x <= CGFloat(groundResetXCoord)
            {
                if x != 0
                {
                    groundPieces[x].position = CGPointMake(groundPieces[x - 1].position.x + groundPieces[x].size.width,groundPieces[x].position.y)
                }
                else
                {
                    groundPieces[x].position = CGPointMake(groundPieces[groundPieces.count - 1].position.x + groundPieces[x].size.width,groundPieces[x].position.y)
                }
            }
        }
    }
    
    func startGame() {
        for sprite in groundPieces{
            sprite.runAction(moveGroundForeverAction)
        }
        
        setupEvilFlappy()
        evilFlappy.hidden = false
        evilFlappy.zPosition = 6
        obstacleTimer = NSTimer(timeInterval: timeBetweenObstacles, target: self, selector: "createBottomObstacleSet:", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(obstacleTimer, forMode: NSDefaultRunLoopMode)
        obstacleTimer.fire()
        
        
    }
    
    
    override func update(currentTime: CFTimeInterval)
    {
        groundMovement()
        if jumpTouchDetected == true {
            
            //Move the bird up
            SKAction.moveByX(2, y: 0, duration: 0)
            flappy.zRotation = 0.5;
            
        }
        
        
        flappy.physicsBody?.applyImpulse(CGVector(dx: flappySpeed, dy: 0))
        
        
        if flappy.position.x < 0 || flappy.position.x > self.frame.size.width{
            gameOver()
        }
        if flappy.position.y > self.frame.size.height + 50{
            gameOver()
        }
    }
    
    func gameOver() {
        myScene.gameOverLabel.hidden = false
        scene?.removeAllChildren()
        obstacleTimer.invalidate()
        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "unwindToMenu:", userInfo: nil, repeats: false)
    }
    
    func unwindToMenu(timer : NSTimer){
        
        myScene.unwind()
        //the name of the label = scoreLabel
    }
    
    
    func setupEvilFlappy(){
        let tex = SKTexture(imageNamed: "evilFlappy.png")
        
        evilFlappy = SKSpriteNode(imageNamed: "evilFlappy.png")
        
        evilFlappy.physicsBody = SKPhysicsBody(texture: tex, size: tex.size())
        
       // evilFlappy.physicsBody = SKPhysicsBody(texture: tex, size: tex.size())//makes transparent pixels not be recognized
        
        evilFlappy.physicsBody!.dynamic = false
        evilFlappy.physicsBody!.categoryBitMask = category_evilFlappy
        evilFlappy.physicsBody!.contactTestBitMask = category_projectile
        evilFlappy.name = "evilFlappy"
        
        
        evilFlappy.position = CGPointMake(940, 320)
        self.addChild(evilFlappy)
        evilFlappy.hidden = false
        
    }
    func moveEvilFlappy(){
        
        
        var moveAction = SKAction.moveToY(CGFloat(yPosOfEvilFlappy), duration: (0.6))
        
        evilFlappy.runAction(moveAction)
        
        //if statement
        
        
    }
    func setupProjectileWhenTrue(){
        
        projectile.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "projectile.png"), size: projectile.size)
        projectile.position = CGPoint(x: flappy.position.x + 20, y: flappy.position.y)
        self.addChild(projectile)
        projectile.zPosition = 6
        projectile.physicsBody?.applyImpulse(CGVector(dx: 60, dy: 0))
        projectile.physicsBody?.allowsRotation = false
        projectile.physicsBody?.affectedByGravity = false
        projectile.hidden = false
        
        projectile.physicsBody!.categoryBitMask = category_projectile
        projectile.physicsBody!.contactTestBitMask = category_obstacle
        
        projectile.name = "projectile"
    }
    
    func setupProjectileWhenFalse(){
        projectile.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "projectile.png"), size: projectile.size)
        projectile.position = CGPoint(x: flappy.position.x + 20, y: flappy.position.y)
        projectile.zPosition = 6
        projectile.physicsBody?.applyImpulse(CGVector(dx: 60, dy: 0))
        projectile.physicsBody?.allowsRotation = false
        projectile.physicsBody?.affectedByGravity = false
        projectile.hidden = false
        
        projectile.physicsBody!.categoryBitMask = category_projectile
        projectile.physicsBody!.contactTestBitMask = category_obstacle
        
        projectile.name = "projectile"
        
    }
    
    func scoreTimer(timer: NSTimer){
        scoreStaySame = false
    }
    
    func scoreUpOne() {
        if scoreUp == true && scoreStaySame == false{
            scoreLabel++
            myScene.scoreLabel.text = "\(scoreLabel)"
            scoreUp = false
            scoreStaySame = true
            NSTimer.scheduledTimerWithTimeInterval(1.7, target: self, selector: "scoreTimer:", userInfo: nil, repeats: false)
            
        }
        else if scoreUp == true && scoreStaySame == true{
            nothing = false
        }
        else if scoreUp == false && scoreStaySame == true{
            nothing = false
        }
        
        else {
            abort()
        }
    }
    
    
    func evilFlappyRespawnTimer(timer : NSTimer){
        evilFlappy.position = CGPointMake(940, 320)
        evilFlappy.hidden = false
    }
    //respawn

    
    func didBeginContact(contact: SKPhysicsContact) {
        if (contact.bodyA.node?.name == "projectile" && contact.bodyB.node?.name == "bottomBolt"){
            projectile.hidden = true
        }else if (contact.bodyA.node?.name == "projectile" && contact.bodyB.node?.name == "topBolt"){
            projectile.hidden = true
        }else if (contact.bodyA.node?.name == "topBolt" && contact.bodyB.node?.name == "projectile"){
            projectile.hidden = true
        }else if (contact.bodyA.node?.name == "bottomBolt" && contact.bodyB.node?.name == "projectile"){
            projectile.hidden = true
            
            
        }
        
        if (contact.bodyA.node?.name == "flappy" && contact.bodyB.node?.name == "bottomBolt"){
            gameOver()
        }else if (contact.bodyA.node?.name == "flappy" && contact.bodyB.node?.name == "topBolt"){
            gameOver()
        }else if (contact.bodyA.node?.name == "topBolt" && contact.bodyB.node?.name == "flappy"){
            gameOver()
        }else if (contact.bodyA.node?.name == "bottomBolt" && contact.bodyB.node?.name == "flappy"){
            gameOver()
            
            
        }
        
        if (contact.bodyA.node?.name == "projectile" && contact.bodyB.node?.name == "evilFlappy") {
            projectile.hidden = true
            evilFlappy.hidden = true

            
            scoreUp = true
            scoreUpOne()
            NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "evilFlappyRespawnTimer:", userInfo: nil, repeats: false)
            
        }
        else if (contact.bodyA.node?.name == "evilFlappy" && contact.bodyB.node?.name == "projectile"){

            evilFlappy.hidden = true
            projectile.hidden = true
            scoreUp = true
            scoreUpOne()
            NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "evilFlappyRespawnTimer:", userInfo: nil, repeats: false)
            
            
        }
        if (contact.bodyA.node?.name == "flappy" && contact.bodyB.node?.name == "sprite") {
            gameOver()
        }
        else if  (contact.bodyA.node?.name == "sprite" && contact.bodyB.node?.name == "flappy") {
            gameOver()
        }
        
        
    }
    
    //calculates delta time
    /*
    deltaTime = Float(currentTime - lastUpdateTimeInterval)
    lastUpdateTimeInterval = currentTime
    
    //Prevents problems with when delta time is too long
    if deltaTime > 1
    {
    deltaTime = 1.0 / 60.0
    lastUpdateTimeInterval = currentTime
    }
    
    //one time per touch; sets jump start time and sets current velocity to max jump velocity
    if touchDetected
    {
    touchDetected = false
    jumpStartTime = currentTime
    currentVelocity = jumpVelocity
    }
    
    if isJumping
    {
    //How long we have been jumping
    var currentDuration = CGFloat(currentTime) - CGFloat(jumpStartTime)
    
    //Time to end the jump
    if currentDuration >= CGFloat(jumpDuration)
    {
    isJumping = false
    jumpEndTime = Float(currentTime)
    }
    else
    {
    //Rotate the bird to an angle over a certain period of time
    if flappy.zRotation < 0.5
    {
    flappy.zRotation += 2.0 * CGFloat(deltaTime)
    }
    
    //Move the bird up
    flappy.position = CGPointMake(CGFloat(flappy.position.x), CGFloat(flappy.position.y) + (CGFloat(currentVelocity) * CGFloat(deltaTime)))
    
    //don't decrease velocity until after the initial jump inertia has taken place
    if Float(currentDuration) > jumpInertiaTime
    {
    currentVelocity -= (currentVelocity * Float(deltaTime)) * 2
    }
    
    else //If not jumping then falling
    {
    //Rotate the bird to a certain angle over a certain period of time
    if flappy.zRotation > -0.5
    {
    (flappy.zRotation) -= CGFloat(2.0 * deltaTime)
    
    }
    
    //Move the bird down
    flappy.position = CGPointMake(CGFloat(flappy.position.x), CGFloat(flappy.position.y) - (CGFloat(currentVelocity) * CGFloat(deltaTime)))
    
    //Only start increasing velocity after floating for a little bit
    if Float(currentTime) - jumpEndTime > fallInertiaTime
    {
    currentVelocity += currentVelocity * Float(deltaTime)
    }
    }
    }
    
    }
    */
    
}



