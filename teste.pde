float GRAVITY = 30, PLAYER_CAMERA_DISTANCE = 400;
int TERRAIN_WIDTH = 600, PIT_WIDTH = 200, LEVEL_LENGTH = 10; 
int LAND_TEXTURE_WIDTH = 150, LAND_TEXTURE_HEIGHT = 150;
int STANDING = 0, WALK = 1, JUMP = 2, ATTACK = 3;
int walkingFrames = 35, jumpingFrames = 42, attackFrames = 11;
GameEngine ENGINE;
PlayerObject PLAYER;
Terrain[] TERRAIN_LIST;
PImage LAND_TEXTURE, GRASS_TEXTURE;

void setup() {
	size(800, 450);
	frameRate(30);

	LAND_TEXTURE = loadImage("data/landscape/land.png");
	GRASS_TEXTURE = loadImage("data/landscape/grass.png");

	ENGINE = new GameEngine(2);
	ENGINE.generateWorld(LEVEL_LENGTH);

	PLAYER = new PlayerObject(200, 100, 35, 0, 80, 150);

	ENGINE.addBackgroundLayer(new ResizedImageLayer("data/landscape/sky.png", 100, 500, 1000));
	ENGINE.addBackgroundLayer(new ResizedImageLayer("data/landscape/clouds_back.png", 3000, 450, 900));
	ENGINE.addBackgroundLayer(new ResizedImageLayer("data/landscape/clouds_front.png", 3000, 450, 700));

	ENGINE.addObject(PLAYER);
	// ENGINE.addObject(new EllipseObject(color(0, 0, 150), 350, 50, 25));
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

