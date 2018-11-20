//
//  GameView.swift
//  CannonBallGame
//
//  Created by Hassan Khan on 11/14/18.
//  Copyright © 2018 Hassan Khan. All rights reserved.
//

import UIKit

class GameView: UIView {

    //Declaring all my variables here. Here we go.
    @IBOutlet private var score : UILabel?
    @IBOutlet private var shots : UILabel?
    @IBOutlet private var angle : UILabel?
    @IBOutlet private var velocity : UILabel?
    
    @IBOutlet private var basepic : UIImageView!
    @IBOutlet private var ball : UIImageView!
    
    @IBOutlet private var fire : UIButton?
    
    @IBOutlet private var angleslider : UISlider?
    @IBOutlet private var velocityslider : UISlider?
    
    private var bgimage : UIImage
    private var angleval : Double
    private var velocityval : Double
    
    private var mywidth: Double
    private var myheight: Double
    
    private var pivotx : Double
    private var pivoty : Double
    
    private var barrelmouthx : Double
    private var barrelmouthy : Double
    
    private var barrelrotatex : Double
    private var barrelrotatey : Double
    
    private var moveball : Bool
    
    private var objects = [AnyObject]()
    
    private var timer : Timer!
    private var timekeeper : Double
    
    private var PIX_M = 10.0
    private var GRAVITY = 9.8
    
    private var scoreint : Int
    private var shotsint : Int
    
    override func awakeFromNib()
    {
        
        //Reset all variables
        reset()
        
        //Setting my background image here.
        self.backgroundColor = UIColor(patternImage: bgimage)
        
        //Initialize the labels
        initlabels()
        
        //Making the aliens on the screen
        alienmaker()
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        
        //Code goes here
        bgimage = UIImage(named: "bg2.png")!
        angleval = 0.0
        velocityval = 0.0
        
        mywidth = 0
        myheight = 0
        
        pivotx = 0.0
        pivoty = 0.0
        
        timekeeper = 0.0;
        
        barrelmouthx = 0.0
        barrelmouthy = 0.0
        
        barrelrotatex = 0.0
        barrelrotatey = 0.0
        
        scoreint = 0;
        shotsint = 0;
        
        moveball = false;
        
        super.init(coder: aDecoder)
        
    }
    
    func restart()
    {
        //Reset all variables
        reset()
        
        //Setting my background image here.
        self.backgroundColor = UIColor(patternImage: bgimage)
        
        //Redraw everything
        setNeedsDisplay()
        
        //Initialize the labels
        initlabels()
        
        //Making the aliens on the screen
        alienmaker()

    }
    
    func reset()
    {
        //Reset all variables.
        bgimage = UIImage(named: "bg2.png")!
        angleval = Double(angleslider!.value)*(Double.pi/180)
        velocityval = Double(velocityslider!.value)
        
        mywidth = 0
        myheight = 0
        
        pivotx = 0.0
        pivoty = 0.0
        
        timekeeper = 0.0;
        
        barrelmouthx = 0.0
        barrelmouthy = 0.0
        
        barrelrotatex = 0.0
        barrelrotatey = 0.0
        
        scoreint = 0;
        shotsint = 0;
        
        moveball = false;
    }
    
    func timekeep()
    {
        if (self.frame.contains(ball.frame))
        {
            moveball = true;
            
            //While the ball is moving, also hide the fire button,
            //otherwise user may mess up ball position by pressing fire repeatedly.
            fire?.isHidden = true
        }
        
        else
        {
            //If ball leaves frame, disengage the timer as well.
            //Turn button on again.
            moveball = false;
            fire?.isHidden = false;
            timer.invalidate()
            timekeeper = 0.0
            
            //Clean up any touched/red aliens off the screen.
            for b in 0..<(objects.count)
            {
                //If any of the objects array contain any red aliens, remove them.
                if ((objects[b] as! UIImageView).image?.isEqual(UIImage(named: "touched.png")))!
                {
                    //Remove the red alien, off the screen.
                    (objects[b] as! UIImageView).removeFromSuperview();
                    
                }
            }
        }
        
        //If ball is being displayed and moving:
        if moveball
        {
            //First, make sure ball is visible.
            ball.isHidden = false;
            
            //Second, make sure its trajectory is working right.
            timekeeper += Double(timer.timeInterval)
            let x = (velocityval*(cos(angleval)*timekeeper))*PIX_M + Double(barrelmouthx-5);
            let y1 = (-velocityval*(sin(angleval)*timekeeper) + 0.5*GRAVITY*timekeeper*timekeeper);
            let y = y1*PIX_M + Double(barrelmouthy-10);
            ball.frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: (20), height: (20))
            
            //Third, check if it is hitting any of the aliens. If so, turn them red.
            //Make a temp image with the touched image.
            let temptouched = UIImage(named: "touched.png")
            for z in 0..<(objects.count)
            {
                //If ball intersects the alien, turn it red.
                if (ball.frame.intersects((objects[z] as! UIImageView).frame))
                {
                    //Change image of the alien intersected, if it hasn't been changed already before.
                    if (((objects[z] as! UIImageView).image?.isEqual(UIImage(named: "touched.png")))!==false)
                    {
                        (objects[z] as! UIImageView).image = temptouched
                        
                        //Update score
                        scoreint += 1
                    }}
            }
        }
        else
        {
            ball.isHidden = true;
        }
        
        //Always keeping ball on top and
        //Keeping the cannon-base in the front, my friend.
        self.bringSubview(toFront: ball)
        self.bringSubview(toFront: basepic)
        
        //Updating the shots and score labels.
        shots?.text = String(shotsint)
        score?.text = String (scoreint)
        
        //If all aliens have been hit my friend, let user know game is over, and restart.
        if ((scoreint >= 49) && (moveball == false))
        {
            //First things first. User won. So invalidate timer.
            timer.invalidate()
            
            let telluser = UIAlertController(title: "You're good, my friend!", message: "You've hit em all in \(shotsint) shots! Not bad! Bet you can do better though eh? ", preferredStyle: .alert)
            
            telluser.addAction(UIAlertAction(title: "Yes I can!", style: .default, handler: {action in
                self.restart()
            }))
            
            telluser.addAction(UIAlertAction(title: "Maybe another day..", style: .cancel, handler: {action in
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            }))
            

            var rootViewController = UIApplication.shared.keyWindow?.rootViewController
            if let navigationController = rootViewController as? UINavigationController {
                rootViewController = navigationController.viewControllers.first
            }
            if let tabBarController = rootViewController as? UITabBarController {
                rootViewController = tabBarController.selectedViewController
            }
            rootViewController?.present(telluser, animated: true, completion: nil)

            
        }
        
    }
    
    func initlabels()
    {
        score?.text = "0"
        shots?.text = "0"
        angle?.text = String(Int((angleslider?.value)!))
        velocity?.text = String(Int((velocityslider?.value)!))
    }
    
    func alienmaker()
    {
        //Getting the width and height of the frame.
        mywidth = Double(self.frame.width)
        myheight = Double(self.frame.height)
        
        //Starting the alien making process, my friend
        var startx = 0.5*mywidth
        var starty = 0.1*myheight
        
        let tempalien = UIImage(named: "untouched.png")
        
        //The width and height can also be set according to screensize.
        let alienwidth = 30
        let alienheight = 30
        //Adding the aliens to the object array, and showing them on screen
        for i in 0..<7
        {
            //Move x and y to next line.
            startx = 0.5*mywidth
            starty = (0.1*myheight)+Double(alienheight*i)
            
            for j in 0..<7
            {
                //Create UIImageView
                let view = UIImageView(frame: CGRect(x: CGFloat(startx), y: CGFloat(starty), width: CGFloat(alienwidth), height: CGFloat(alienheight)))
                
                view.image = tempalien
                view.isHidden = false
                
                //Add to array
                objects.append(view)
                
                //Add the image to the view
                self.addSubview(view)
                
                //Move the x position
                startx += Double(alienwidth)
            }
        }
    }
    
    func initializeball()
    {
        //Not displaying ball unless it has started moving.
        if (moveball)
        {
            ball.isHidden = false;
        }
        
        else
        {
            ball.isHidden = true;
        }
        ball.image = UIImage(named: "cannonBall.png");
        ball.frame = CGRect(x: CGFloat(barrelmouthx-5), y: CGFloat(barrelmouthy-10), width: (20), height: (20))
    }
    
    //Setting the inputs from the sliders and button.
    @IBAction func changer (sender : Any?)
    {
        if (sender is UIButton)
        {
            moveball = true
            initializeball()
            timer = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(self.timekeep), userInfo: nil, repeats: true)
            
            //Updating shots
            shotsint += 1
        }
        
        if (sender is UISlider)
        {
            if ((sender as! UISlider).accessibilityLabel == "velocity")
            {
                velocityval = Double((sender as! UISlider).value)
                //Set the label to the value of the slider.
                velocity?.text = String(Int((velocityslider?.value)!))
            }
            
            if ((sender as! UISlider).accessibilityLabel == "angle")
            {
                //Only set the ball again if it isnt already moving.
                if (moveball == false)
                {
                angleval = Double((sender as! UISlider).value)*(Double.pi/180)
                //angleval = Double((sender as! UISlider).value)
                
                //Set the label to the value of the slider.
                angle?.text = String(Int((angleslider?.value)!))
                
                //Setting the barrel as the angle is changed
                setNeedsDisplay()
                
                
                //Setting the ball
                initializeball()
                }
                
                //Otherwise just set the label to the value
                else
                {
                    //Set the label to the value of the slider.
                    angle?.text = String(Int((angleslider?.value)!))
                    
                    //Setting the barrel as the angle is changed
                    setNeedsDisplay()
                }
                
            }
        }
    }
    
    //Following function has been taken from stackoverflow.
    func rotatepoint()
    {
        //If the ball isnt moving, only then change angle values.
        if (moveball == false)
        {
        let s = sin(angleval)
        let c = cos(angleval)
        
        // translate point back to origin:
        let init_x = Double(basepic.frame.origin.x + 0.4*basepic.frame.width) - pivotx;
        let init_y = (Double(basepic.frame.origin.y+(0.5*basepic.frame.height))-70)-pivoty;
        
        // rotate point
        let xnew = init_x * c - init_y * s;
        let ynew = init_x * s + init_y * c;
        
        // translate point back:
        barrelmouthx = xnew + pivotx;
        barrelmouthy = ynew + pivoty;
        }
        
        //If ball is moving, still rotate point to move the cannon around, but
        //dont change the angle of the balls movement.
        else{
            let hmm = Double((angleslider?.value)!)*(Double.pi/180)
            let s = sin(hmm)
            let c = cos(hmm)
            
            // translate point back to origin:
            let init_x = Double(basepic.frame.origin.x + 0.4*basepic.frame.width) - pivotx;
            let init_y = (Double(basepic.frame.origin.y+(0.5*basepic.frame.height))-70)-pivoty;
            
            // rotate point
            let xnew = init_x * c - init_y * s;
            let ynew = init_x * s + init_y * c;
            
            // translate point back:
            barrelrotatex = xnew + pivotx;
            barrelrotatey = ynew + pivoty;
        }
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        //First things first, lets draw the ground, and set the base on the ground.
        let ctx = UIGraphicsGetCurrentContext()
        
        //Drawing the base
        ctx?.setFillColor(red: 0.5, green: 0.5, blue: 0, alpha: 1)
        ctx?.fill(CGRect(x: 0, y: (0.9*myheight), width: mywidth, height: (0.1*myheight)))
        
        //Set the image and position of the cannon base picture.
        let trial = UIImage(named: "cannon_base.png")
        basepic.image = UIImage(named: "cannon_base.png");
        basepic?.frame = CGRect(x: CGFloat(5), y: CGFloat(0.9*myheight-Double((trial?.size.height)!)), width: (trial?.size.width)!, height: (trial?.size.height)!)
        
        //Now my friend, drawing the barrel, using a line.
         ctx?.beginPath ();
         ctx?.setLineWidth(10.0)
        
        //Moving to the starting point, i.e. the center of base
         ctx?.move(to: CGPoint(x: (basepic.frame.origin.x + 0.4*basepic.frame.width), y: (basepic.frame.origin.y+(0.5*basepic.frame.height))))
        
        //Saving the pivot points for the rotation
        pivotx = (Double(basepic.frame.origin.x + 0.4*basepic.frame.width))
        pivoty = (Double(basepic.frame.origin.y+(0.5*basepic.frame.height)))
        
        //Now my friend, calculating the end point after rotation
        //by the angle input by the user through the slider, using function.
        rotatepoint()
        
        //Finally, drawing the barrel.
        if (moveball == false)
        {
        ctx?.addLine(to: CGPoint(x: barrelmouthx, y: barrelmouthy))
        UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).setFill()
        UIColor.black.setStroke()
        ctx?.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        
        else
        {
            //Moving barrel without moving ball.
            ctx?.addLine(to: CGPoint(x: barrelrotatex, y: barrelrotatey))
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).setFill()
            UIColor.black.setStroke()
            ctx?.drawPath(using: CGPathDrawingMode.fillStroke)
        }
    
        //Keeping the cannon-base in the front always
        self.bringSubview(toFront: basepic)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
