class StartScreen {
	PImage bg;
	PImage arrow;
	PImage beat;
	PImage hunter;
	PImage button;

	float posX, posY;
	float speedX, speedY;

	StartScreen() {
		posX = 0;
		speedX = -1;

		bg = loadImage("background.png");
		arrow = loadImage("arrow.png");
		beat = loadImage("beat.png");
		hunter = loadImage("hunter.png");
		button = loadImage("button.png");
	}

	void draw() {
		posX += speedX;

		if(posX > 0) {
			posX = -300;
		} else if(posX < -300) {
			posX = 0;
		}

		background(50, 205, 50);

		image(bg, posX, 0);
		image(arrow, 0, 0);
		image(beat, 0, 0);
		image(hunter, 0, 0);
		image(button, 0, 0);
	}
}