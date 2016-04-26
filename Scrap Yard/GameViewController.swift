import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var skView:SKView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = false
        skView.showsFPS = true  
        loadHomeScene(true)
    }
    
    //Load the main menu
    func loadHomeScene(releaseStop: Bool)
    {
        let scene = HomeScene(fileNamed: "Home")
        scene?.gameManager = self
        scene?.releaseStop = releaseStop
        let reveal = SKTransition.crossFadeWithDuration(1)
        skView.presentScene(scene!, transition: reveal)
    }
    
    //Load a level
    func loadGameScene(level: Int, releaseStop: Bool, win: Bool)
    {
        if(level > levelCount)
        {
            loadHomeScene(releaseStop)
            return
        }
        
        let scene = GameScene(fileNamed:"Level_\(level)")
        scene?.currentLevel = level
        scene?.gameManager = self
        scene?.releaseStop = releaseStop
        
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
}
