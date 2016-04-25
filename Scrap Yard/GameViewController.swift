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
        loadHomeScene()
    }
    
    func loadHomeScene()
    {
        let scene = HomeScene(fileNamed: "Home")
        scene?.gameManager = self
        let reveal = SKTransition.crossFadeWithDuration(1)
        skView.presentScene(scene!, transition: reveal)
    }
    
    func loadGameScene(level: Int, releaseStop: Bool)
    {
        print(level)
        let scene = GameScene(fileNamed:"Level_\(level)")
        scene?.currentLevel = level
        scene?.gameManager = self
        scene?.releaseStop = releaseStop
        
        let reveal = SKTransition.pushWithDirection(SKTransitionDirection.Left, duration: 1)
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
