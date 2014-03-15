float GRAVITY = 30;
int TERRAIN_WIDTH = 400, PIT_WIDTH = 200;
GameEngine ENGINE;
PlayerObject PLAYER;
Terrain[] TERRAIN_LIST;

void setup() {
	size(700, 400);
	frameRate(30);

	ENGINE = new GameEngine(2);
	ENGINE.generateWorld(10);

	PLAYER = new PlayerObject(200, 50);

	ENGINE.addObject(PLAYER);
	ENGINE.addObject(new EllipseObject(color(0, 0, 150), 350, 50, 25));
}

void draw() {
	background(200, 200, 255);

	ENGINE.processObjects();
	ENGINE.renderWorld();
}

void keyPressed() {
	if(keyCode == 39) { // right arrow
		PLAYER.setSpeedX(max(5, PLAYER.getSpeedX()));
	} else if(keyCode == 37) { // left arrow
		PLAYER.setSpeedX(min(-5, PLAYER.getSpeedX()));
	} else if(keyCode == 32) { // space
		PLAYER.jump();
	} else if(keyCode == 81){
		PLAYER.doMeleeAttack();
	}
}

void keyReleased() {
	if((keyCode == 39 || keyCode == 37)) { // left or right arrow
		PLAYER.setSpeedX(0);
	}
}

