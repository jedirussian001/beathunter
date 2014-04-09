import ddf.minim.*;

Minim MINIM;
AudioPlayer START_SCREEN_SONG;
AudioPlayer[] JUNGLE_SOUNDS;
PImage traya, well;
StartScreen START_SCREEN;

float GRAVITY = 30, PLAYER_CAMERA_DISTANCE = 400;
int TERRAIN_WIDTH = 600, PIT_WIDTH = 200, LEVEL_LENGTH = 10; 
int LAND_TEXTURE_WIDTH = 150, LAND_TEXTURE_HEIGHT = 150, CURRENT_STATE = 0;
int STANDING = 0, WALK = 1, JUMP = 2, ATTACK = 3;
int walkingFrames = 35, jumpingFrames = 42, attackFrames = 11;
GameEngine ENGINE;
PlayerObject PLAYER;
Token[] TOKENS;
Terrain[] TERRAIN_LIST;
PImage LAND_TEXTURE = null, GRASS_TEXTURE = null;

void setup() {
	size(800, 450);
	frameRate(30);

	ENGINE = new GameEngine(2);
	MINIM = new Minim(this);

	START_SCREEN = new StartScreen();

	//a ser refatorado ASAP
	traya = loadImage("TryAgain.jpg");
	well = loadImage("WellDone.jpg");
	//in need of refactoring asap

	ENGINE.generateSounds();
	ENGINE.generateWorld(LEVEL_LENGTH);
	ENGINE.generateTokens();

	PLAYER = new PlayerObject(200, 100, 35, 0, 80, 150);

	ENGINE.addBackgroundLayer(new ResizedImageLayer("data/landscape/sky.png", 100, 500, 1000));
	ENGINE.addBackgroundLayer(new ResizedImageLayer("data/landscape/clouds_back.png", 3000, 450, 900));
	ENGINE.addBackgroundLayer(new ResizedImageLayer("data/landscape/clouds_front.png", 3000, 450, 500));
	ENGINE.addBackgroundLayer(new ResizedImageLayer("data/landscape/trees.png", 1097, 450, 300));

	ENGINE.addObject(PLAYER);
}

void draw() {
	if(CURRENT_STATE == 0) {
		START_SCREEN.draw();
	} else if(CURRENT_STATE == 1) {
		ENGINE.processObjects();
		ENGINE.renderWorld();
		if(!PLAYER.isEnabled()) {
			ENGINE.changeState(3);
		}
	} else if(CURRENT_STATE == 2) {
		imageMode(CORNER);
		image(well, 0, 0);
	} else if(CURRENT_STATE == 3) {
		imageMode(CORNER);
		image(traya, 0, 0);
	}
}

void mouseClicked() {
	if(CURRENT_STATE == 0) {
		ENGINE.changeState(1);
	}
}

void keyPressed() {
	if(CURRENT_STATE == 0) {
		ENGINE.changeState(1);
	} else if(CURRENT_STATE == 1) {
		PLAYER.interactWithKeyPressed(keyCode);
	}
}

void keyReleased() {
	PLAYER.interactWithKeyReleased(keyCode);
}

