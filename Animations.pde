/*
 * Author: Jesus Eduardo Russian
 * 
 * This files contains animation-related classes.
 */

 abstract class VisualState {
 	abstract void draw(float x, float y);
 }

 class SingleSprite extends VisualState {
 	PImage img;

 	SingleSprite(String path) {
 		this.img = loadImage("data/" + path);
 		// this.img = loadImage(path);
 	}

 	void draw(float x, float y) {
 		imageMode(CENTER);
 		image(this.img, x, y);
 	}
 }

 class Animation extends VisualState {
 	PImage[] imgs;
 	int stepCounter;

 	Animation(String imgFolder, int numImages) {
 		this.imgs = new PImage[numImages];
 		for(int i = 1 ; i <= numImages; i++) {
 			this.imgs[i-1] = loadImage("data/" + imgFolder + "/" + i + ".png");
 			// this.imgs[i-1] = loadImage(imgFolder + "/" + i + ".png");
 		}
 		this.stepCounter = 0;
 	}

 	void step() {
 		stepCounter++;
    	if(stepCounter == imgs.length) {  // uses the images up to the last one
    		stepCounter = 0;
    	}
	}

	void draw(float x, float y) {
		imageMode(CENTER);
		image(imgs[stepCounter], x, y);
		this.step();
	}
};

class OneTimeAnimation extends Animation { //  extends the animation func
	OneTimeAnimation(String imgFolder, int numImages) {
		super(imgFolder, numImages); 
	}

	void step() {
		if(stepCounter < imgs.length-1) {
			stepCounter++;
		}
	}

	void reset() {
		stepCounter = 0;
	}
};
