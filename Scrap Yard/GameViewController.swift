import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var skView:SKView!
    var scene: GameScene?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupNotifications()
        
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = false
        skView.showsFPS = true
        
        let option = NSUserDefaults.standardUserDefaults().boolForKey("option")
        loadSplashScene(option)
    }
    
    //Load the main menu
    func loadHomeScene(releaseStop: Bool)
    {
        let mainScene = HomeScene(fileNamed: "Home")
        mainScene?.gameManager = self
        mainScene?.releaseStop = releaseStop
        let reveal = SKTransition.crossFadeWithDuration(1)
        skView.presentScene(mainScene!, transition: reveal)
    }
    
    //Load the splash screen
    func loadSplashScene(releaseStop: Bool)
    {
        let victScene = VictScene(fileNamed: "Splash")
        victScene?.gameManager = self
        victScene?.releaseStop = releaseStop
        let reveal = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 1)
        skView.presentScene(victScene!, transition: reveal)
    }
    
    //Load the main menu
    func loadVictScene(releaseStop: Bool)
    {
        let victScene = VictScene(fileNamed: "Victory")
        victScene?.gameManager = self
        victScene?.releaseStop = releaseStop
        let reveal = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 1)
        skView.presentScene(victScene!, transition: reveal)
    }
    
    //Load a level
    func loadGameScene(level: Int, releaseStop: Bool, win: Bool)
    {
        if(level > levelCount)
        {
            loadVictScene(releaseStop)
            return
        }
        
        scene = GameScene(fileNamed:"Level_\(level)")
        scene?.currentLevel = level
        scene?.gameManager = self
        scene?.releaseStop = releaseStop
        
        //Different transitions in win vs loss
        let reveal = win ?
            SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 1) :
            SKTransition.crossFadeWithDuration(1.0)
        
        reveal.pausesIncomingScene = true
        reveal.pausesOutgoingScene = true
        skView.presentScene(scene!, transition: reveal)
    }
    
    override func shouldAutorotate() -> Bool
    {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            return .AllButUpsideDown
        }
        else
        {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    //NSNotifications for leaving and entering
    func setupNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("willResignActive:"),
            name: UIApplicationWillResignActiveNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("didBecomeActive:"),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
    }
    
    //Pause
    func willResignActive(n:NSNotification)
    {
        print("willResignActive notification")
        scene?.gameLoopPaused = true
    }
    
    //Unpause
    func didBecomeActive(n:NSNotification)
    {
        print("didBecomeActive notification")
        scene?.gameLoopPaused = false
    }
    
    //Remove notifications
    func teardownNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(
            self)
    }
}
