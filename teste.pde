float GRAVITY = 30, PLAYER_CAMERA_DISTANCE = 400;
int TERRAIN_WIDTH = 400, PIT_WIDTH = 200, LEVEL_LENGTH = 10;
GameEngine ENGINE;
PlayerObject PLAYER;
Terrain[] TERRAIN_LIST;
ResizedImageLayer teste;

void setup() {
	size(800, 450);
	frameRate(30);

	ENGINE = new GameEngine(2);
	ENGINE.generateWorld(LEVEL_LENGTH);

	PLAYER = new PlayerObject(200, 100, 35, 0, 80, 150);

	ENGINE.addBackgroundLayer(new ResizedImageLayer("data/bg.jpg", 800, 600, 100));

	ENGINE.addObject(PLAYER);
	ENGINE.addObject(new EllipseObject(color(0, 0, 150), 350, 50, 25));
}

void draw() {
	background(200, 200, 255);

	ENGINE.processObjects();
	ENGINE.renderWorld();
}

void keyPressed() {
	PLAYER.interactWithKeyPressed(keyCode);
}

void keyReleased() {
	PLAYER.interactWithKeyReleased(keyCode);
}

