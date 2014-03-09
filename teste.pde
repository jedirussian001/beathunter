float GRAVITY = 30;
int TERRAIN_WIDTH = 400, PIT_WIDTH = 200;
GameEngine ENGINE;
PlayerObject PLAYER;
Terrain[] TERRAIN_LIST;

void setup() {
	size(400, 400);
	frameRate(30);

	MechanicsManager manager = new MechanicsManager();

	ENGINE = new GameEngine(2, manager);
	ENGINE.generateWorld(10);

	PLAYER = new PlayerObject(width / 2, 50);

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

/* * * * * * * * * * * * * * * *
 *		CLASS DEFINITIONS	   *
 * * * * * * * * * * * * * * * */

class Point {
	float x;
	float y;

	Point(float x, float y) {
		this.x = x;
		this.y = y;
	}

	float getX() {
		return this.x;
	}

	void setX(float x) {
		this.x = x;
	}

	float getY() {
		return this.y;
	}

	void setY(float y) {
		this.y = y;
	}

	float distanceTo(Point otherPoint) {
		return sqrt(sq(this.x - otherPoint.getX()) + sq(this.y - otherPoint.getY()));
	}
};

class Rectangle {
	Point center;
	float rWidth;
	float rHeight;

	Rectangle(float x, float y, float w, float h) {
		this.center = new Point(x, y);
		this.rWidth = w;
		this.rHeight = h;
	}

	Rectangle(Point center, float w, float h) {
		this.center = center;
		this.rWidth = w;
		this.rHeight = h;
	}

	Point getCenter() {
		return this.center;
	}

	float getWidth() {
		return this.rWidth;
	}

	float getHeight() {
		return this.rHeight;
	}

	boolean intersectsWith(Rectangle otherRectangle) {
		float minimumXDifference = (this.rWidth / 2) + (otherRectangle.getWidth() / 2),
				minimumYDifference = (this.rHeight / 2) + (otherRectangle.getHeight() / 2),
				realXDifference = abs(this.center.getX() - otherRectangle.getCenter().getX()),
				realYDifference = abs(this.center.getY() - otherRectangle.getCenter().getY());

		return (realXDifference < minimumXDifference && realYDifference < minimumYDifference);
	}
};

 /* GameObject and its subclasses */

// This class just acts as an abstraction of any object in the game, so the ENGINE can treat them all equally.
abstract class GameObject {
	boolean affectedByGRAVITY;
	boolean enabled;
	Point center;
	float speedX;
	float speedY;
	Rectangle hitbox;
	int currentTerrainIndex;

	GameObject(float x, float y) {
		float tw, xPos;

		this.center = new Point(x, y);
		this.affectedByGRAVITY = true;
		this.enabled = true;
		if(PLAYER != null) {
			this.setXPosition(PLAYER.getXPosition() + (x - PLAYER.getCenter().getX()));
		}

		xPos = this.getXPosition();
		for(int i = 0; i < TERRAIN_LIST.length; i++) {
			tw = (TERRAIN_LIST[i].getHeight() == 0 ? PIT_WIDTH : TERRAIN_WIDTH);

			if(xPos < tw) {
				this.currentTerrainIndex = i;
				break;
			}

			xPos -= tw;
		}
	}

	float getXPosition() {
		return this.getCenter().getX();
	}

	void setXPosition(float xPos) {
		this.getCenter().setX(xPos);
	}

	boolean isAffectedByGRAVITY() {
		return this.affectedByGRAVITY;
	}

	void setAffectedByGRAVITY(boolean affectedByGRAVITY) {
		this.affectedByGRAVITY = affectedByGRAVITY;
	}

	Point getCenter() {
		return this.center;
	}

	void moveInXAxis(float amount) {
		// float oldX = this.center.getX(), newX = max(this.centerToLeft(), this.center.getX() + amount);
		// this.getCenter().setX(newX);

		// this.xPosition += (newX - oldX);
		this.setXPosition(this.getXPosition() + amount);

		float xPos = this.getXPosition(), terrainLimits = TERRAIN_LIST[this.currentTerrainIndex].getStartingPosition();
		if(amount > 0) {
			terrainLimits += TERRAIN_LIST[this.currentTerrainIndex].getWidth();

			if(xPos >= terrainLimits) {
				this.currentTerrainIndex++;
			}
		} else {
			if(xPos < terrainLimits) {
				this.currentTerrainIndex--;
			}
		}
	}

	void moveInYAxis(float amount) {
		float newY = this.getCenter().getY() + amount,
				groundHeight, maxY;
		Terrain highestTerrain = this.getHighestTerrainBelow();

		groundHeight = height - highestTerrain.getHeight();
		
		maxY = groundHeight - this.centerToBottom();

		if(newY > maxY) {
			newY = highestTerrain.interactWithObject(this, newY);
		}

		if(newY >= height) {
			ENGINE.getManager().handleObjectFall(this);
		}

		this.getCenter().setY(newY);
	}

	Terrain getHighestTerrainBelow() {
		int startIndex, endIndex;
		Terrain highestTerrain;

		startIndex = endIndex = this.currentTerrainIndex;

		if(this.getXPosition() - this.centerToLeft() < TERRAIN_LIST[this.currentTerrainIndex].getStartingPosition()) {
			startIndex--;
		}

		if(this.getXPosition() + this.centerToRight() > TERRAIN_LIST[this.currentTerrainIndex].getEndPosition()) {
			endIndex++;
		}

		highestTerrain = TERRAIN_LIST[startIndex];

		for(int i = startIndex + 1; i <= endIndex; i++) {
			if(TERRAIN_LIST[i].getMinimumHeight() > highestTerrain.getMinimumHeight()) {
				highestTerrain = TERRAIN_LIST[i];
			}
		}

		return highestTerrain;
	}

	float getSpeedX() {
		return this.speedX;
	}

	void setSpeedX(float speedX) {
		this.speedX = speedX;
	}

	float getSpeedY() {
		return this.speedY;
	}

	void setSpeedY(float speedY) {
		this.speedY = speedY;
	}

	void move(float amountX, float amountY) {
		if(amountX != 0) this.moveInXAxis(amountX);
		if(amountY != 0) this.moveInYAxis(amountY);
	}

	boolean isEnabled() {
		return this.enabled;
	}

	void enable() {
		this.enabled = true;
	}

	void disable() {
		this.enabled = false;
	}

	Rectangle getHitbox() {
		return this.hitbox;
	}

	int getCurrentTerrainIndex() {
		return this.currentTerrainIndex;
	}

	abstract float centerToBottom();
	abstract float centerToLeft();
	abstract float centerToRight();
	abstract void render();
};

//This class is the parent for all geometric objects
abstract class ColouredObject extends GameObject {
	color objColor;

	ColouredObject(color objColor, float x, float y) {
		super(x, y);
		this.objColor = objColor;
	}

	color getObjectColor() {
		return this.objColor;
	}

	void setObjectColor(color objColor) {
		this.objColor = objColor;
	}

	void render() {
		fill(this.objColor);
	}
};

class RectangleObject extends ColouredObject {
	float objWidth;
	float objHeight;

	RectangleObject(color objColor, float centerX, float centerY, float objWidth, float objHeight) {
		super(objColor, centerX, centerY);
		this.objWidth = objWidth;
		this.objHeight = objHeight;

		this.hitbox = new Rectangle(this.getCenter(), objWidth, objHeight);
	}

	void render() {
		super.render();
		rectMode(CENTER);
		rect(PLAYER.getScreenXPosition() + (this.getXPosition() - PLAYER.getXPosition()), 
				this.getCenter().getY(), this.objWidth, this.objHeight);
	}

	float centerToBottom() {
		return (this.objHeight / 2);
	}

	float centerToLeft() {
		return (this.objWidth / 2);
	}

	float centerToRight() {
		return (this.objWidth / 2);
	}
};

class EllipseObject extends ColouredObject {
	float radiusX;
	float radiusY;

	EllipseObject(color objColor, float centerX, float centerY, float radiusX, float radiusY) {
		super(objColor, centerX, centerY);
		this.radiusX = radiusX;
		this.radiusY = radiusY;

		this.hitbox = new Rectangle(this.getCenter(), radiusX * 2, radiusY * 2);
	}

	EllipseObject(color objColor, float centerX, float centerY, float radius) {
		super(objColor, centerX, centerY);
		this.radiusX = this.radiusY = radius;

		this.hitbox = new Rectangle(this.getCenter(), radius * 2, radius * 2);
	}

	void render() {
		super.render();
		ellipseMode(RADIUS);
		ellipse(PLAYER.getScreenXPosition() + (this.getXPosition() - PLAYER.getXPosition()), 
				this.getCenter().getY(), this.radiusX, this.radiusY);
	}

	float centerToBottom() {
		return this.radiusY;
	}

	float centerToLeft() {
		return this.radiusX;
	}

	float centerToRight() {
		return this.radiusX;
	}
};

class PlayerObject extends GameObject {
	float screenXPosition;
	float xPosition;
	int meleeAttackStage;
	boolean canAirJump;

	PlayerObject(float x, float y) {
		super(x, y);
		this.hitbox = new Rectangle(this.getCenter(), 100, 100);
		this.meleeAttackStage = 0;
		this.canAirJump = true;

		float maxPositionX = TERRAIN_LIST[TERRAIN_LIST.length - 1].getEndPosition();

		if(x < width / 2) {
			this.setScreenXPosition(max(this.centerToLeft(), x));
		} else if(x > maxPositionX - (width / 2)) {
			this.setScreenXPosition(min(width - this.centerToRight(), width - (maxPositionX - x)));
		} else {
			this.setScreenXPosition(width / 2);
		}
	}

	void moveInXAxis(float amount) {
		float middleScreen = (width / 2), 
				maxPositionX = TERRAIN_LIST[TERRAIN_LIST.length - 1].getEndPosition(),
				newXPos = min(maxPositionX - this.centerToRight(), max(this.centerToLeft(), this.getXPosition() + amount)),
				currentYPos = height - (this.getCenter().getY() + this.centerToBottom());
		int nextPlatformIndex = this.currentTerrainIndex;

		if(amount < 0 && newXPos - this.centerToLeft() < TERRAIN_LIST[this.currentTerrainIndex].getStartingPosition()) {
			nextPlatformIndex--;
		} else if(amount > 0 && newXPos + this.centerToRight() > TERRAIN_LIST[this.currentTerrainIndex].getEndPosition()) {
			nextPlatformIndex++;
		}

		if(TERRAIN_LIST[nextPlatformIndex].getHeight() <= currentYPos) {
			if(this.getXPosition() < middleScreen || this.getXPosition() + amount < middleScreen) {
				this.setScreenXPosition(max(this.centerToLeft(), min(middleScreen, (this.getScreenXPosition() + amount))));
			} else if(this.getXPosition() > maxPositionX - middleScreen || this.getXPosition() + amount > maxPositionX - middleScreen) {
				this.setScreenXPosition(min(width - this.centerToRight(), max(middleScreen, (this.getScreenXPosition() + amount))));
			}

			this.setXPosition(newXPos);

			if(amount > 0 && this.getXPosition() >= TERRAIN_LIST[this.currentTerrainIndex].getEndPosition()) {
				this.currentTerrainIndex++;
			} else if(amount < 0 && this.getXPosition() < TERRAIN_LIST[this.currentTerrainIndex].getStartingPosition()) {
				this.currentTerrainIndex--;
			}
		}
	}

	void render() {
		fill(128);
		noStroke();
		rectMode(CENTER);
		rect(this.getScreenXPosition(), this.getCenter().getY(), 100, 100);

		if(this.meleeAttackStage > 0) {
			float startingAngle = PI + HALF_PI;

			fill(255);
			noStroke();
			arc(this.getScreenXPosition(), this.getCenter().getY(), 100, 100, startingAngle, startingAngle + (HALF_PI / this.meleeAttackStage));

			//CHECK FOR COLLISION W/ MELEE ATTACK HERE

			this.meleeAttackStage--;
		}
	}

	float getXPosition() {
		return this.center.getX();
	}

	void setXPosition(float xPos) {
		this.center.setX(xPos);
	}

	float centerToBottom() {
		return 50;
	}

	float centerToLeft() {
		return 50;
	}

	float centerToRight() {
		return 50;
	}

	float getScreenXPosition() {
		return this.screenXPosition;
	}

	void setScreenXPosition(float sxPos) {
		this.screenXPosition = sxPos;
	}

	void doMeleeAttack() {
		this.meleeAttackStage = 4;
	}

	boolean isStanding() {
		Terrain highestTerrain = this.getHighestTerrainBelow();

		return highestTerrain.isSolid() && (height - this.center.getY() - this.centerToBottom()) == highestTerrain.getHeight();
	}

	void jump() {
		boolean willJump = true;

		if(!this.isStanding()) {
			if(this.canAirJump) {
				this.canAirJump = false;
			} else {
				willJump = false;
			}
		}

		if(willJump) {
			this.setSpeedY(-(sqrt(2 * (GRAVITY / frameRate) * 150)));
		}
	}

	void resetJumps() {
		this.canAirJump = true;
	}
};

/* Terrain class and subclasses */

abstract class Terrain {
	Point startPoint;
	float tWidth;
	boolean solidness;

	Terrain(float x, float y, float w, boolean solidness) {
		this.startPoint = new Point(x, y);
		this.tWidth = w;
		this.solidness = solidness;
	}

	Point getStartPoint() {
		return this.startPoint;
	}

	float getStartingPosition() {
		return this.getStartPoint().getX();
	}

	float getHeight() {
		return this.getStartPoint().getY();
	}

	float getMinimumHeight() {
		return this.getStartPoint().getY();
	}

	float getWidth() {
		return this.tWidth;
	}

	float getEndPosition() {
		return this.getStartingPosition() + this.tWidth;
	}

	boolean isSolid() {
		return this.solidness;
	}

	abstract void render();
	abstract float interactWithObject(GameObject obj, float y);
};


class LandSection extends Terrain {
	LandSection(float h, float pos) {
		super(pos, h, TERRAIN_WIDTH, true);
	}

	void render() {
		float playerPos = PLAYER.getXPosition(), playerScreenPos = PLAYER.getScreenXPosition(),
				playerPosDiff = playerPos - playerScreenPos;

		if(this.getEndPosition() > playerPosDiff) {
			Point stp = this.getStartPoint();
			float posDiff = stp.getX() - playerPos, realStartPos = max(0, playerScreenPos + posDiff), realWidth;

			if(playerPos > this.getStartingPosition()) {
				realWidth = min(this.getWidth(), this.getWidth() - (playerPosDiff - this.getStartingPosition()));
			} else {
				realWidth = min(this.getWidth(), (width + playerPosDiff) - this.getStartingPosition());
			}

			rectMode(CORNER);
			fill(180, 0, 0);
			noStroke();
			rect(realStartPos, height - this.getHeight(), realWidth, this.getHeight());
		}
	}

	float interactWithObject(GameObject obj, float y) {
		obj.setSpeedY(0);

		if(obj == PLAYER) {
			PLAYER.resetJumps();
		}

		return (height - this.getHeight()) - obj.centerToBottom();
	}
};

class Pit extends Terrain {
	Pit(float pos) {
		super(pos, 0, PIT_WIDTH, false);
	}

	void render() {}

	float interactWithObject(GameObject obj, float y) {
		return y;
	}
};

class Quicksand extends Terrain {
	Quicksand(float h, float pos) {
		super(pos, h, PIT_WIDTH, false);
	}

	void render() {
		float playerPos = PLAYER.getXPosition(), playerScreenPos = PLAYER.getScreenXPosition(),
				playerPosDiff = playerPos - playerScreenPos;

		if(this.getEndPosition() > playerPosDiff) {
			Point stp = this.getStartPoint();
			float posDiff = stp.getX() - playerPos, realStartPos = max(0, playerScreenPos + posDiff), realWidth;

			if(playerPos > this.getStartingPosition()) {
				realWidth = min(this.getWidth(), this.getWidth() - (playerPosDiff - this.getStartingPosition()));
			} else {
				realWidth = min(this.getWidth(), (width + playerPosDiff) - this.getStartingPosition());
			}

			rectMode(CORNER);
			fill(0);
			rect(realStartPos, height - this.getHeight(), realWidth, this.getHeight());
		}
	}

	float getMinimumHeight() {
		return 0;
	}

	float interactWithObject(GameObject obj, float y) {
		float spY = min(0, obj.getSpeedY()), realHeight = height - this.getHeight() - obj.centerToBottom();
		Point objCenter = obj.getCenter();

		println("spY: "+spY);
		obj.setSpeedY(spY);

		if(spY == 0) {
			if(objCenter.getY() < realHeight) {
				return realHeight;
			} else {
				return objCenter.getY() + 3;
			}
		} else {
			return y;
		}
	}
};

/* ENGINE class */

class GameEngine {
	GameObject[] objects;
	MechanicsManager gameMechanicsManager;
	int objCount, nextObj;

	GameEngine(int maxSize, MechanicsManager manager) {
		this.objects = new GameObject[maxSize];
		this.objCount = this.nextObj = 0;
		this.gameMechanicsManager = manager;
	}

	MechanicsManager getManager() {
		return this.gameMechanicsManager;
	}

	void generateWorld(int numSections) {
		float aux = 0, startPos;
		int previousIndex;

		TERRAIN_LIST = new Terrain[numSections];

		TERRAIN_LIST[0] = new LandSection(50, 0);

		for(int i = 1; i < TERRAIN_LIST.length; i++) {
			startPos = TERRAIN_LIST[i - 1].getEndPosition();

			if(round(random(1)) == 0 && TERRAIN_LIST[i - 1].getMinimumHeight() != 0) {
				if(round(random(1)) == 0) {
					TERRAIN_LIST[i] = new Pit(startPos);
				} else {
					if(TERRAIN_LIST.length - i > 1) {
						TERRAIN_LIST[i + 1] = this.generateSolidTerrain(TERRAIN_LIST[i - 1].getHeight(), startPos + PIT_WIDTH);
						TERRAIN_LIST[i] = 
							new Quicksand(min(TERRAIN_LIST[i - 1].getHeight(), TERRAIN_LIST[i + 1].getHeight()), startPos);
						i++;
					} else {
						TERRAIN_LIST[i] = new Quicksand(TERRAIN_LIST[i - 1].getHeight(), startPos);
					}
				}
			} else {
				previousIndex = i - ((TERRAIN_LIST[i - 1].getHeight() == 0) ? 2 : 1);

				TERRAIN_LIST[i] = this.generateSolidTerrain(TERRAIN_LIST[previousIndex].getHeight(), startPos);
			}
		}
	}

	Terrain generateSolidTerrain(float previousHeight, float startingPosition) {
		int unitsAboveFifty = int((previousHeight - 50) / 25);
		float newHeight;

		newHeight = previousHeight + (round(random(-min(unitsAboveFifty, 3), 3)) * 25);

		return new LandSection(newHeight, startingPosition);
	}

	void processObjects() {
		GameObject currentObject, otherObject;
		float currentGroundHeight;

		for(int i = 0; i < this.objCount; i++) {
			currentObject = this.objects[i];

			if(currentObject.isAffectedByGRAVITY()) {
				currentObject.setSpeedY(currentObject.getSpeedY() + (GRAVITY / frameRate));
			}

			this.objects[i].move(this.objects[i].getSpeedX(), this.objects[i].getSpeedY());
		}

		for(int i = 0; i < this.objCount; i++) {
			currentObject = this.objects[i];

			if(currentObject.isEnabled()) {
				for(int j = i + 1; j < this.objCount; j++) {
					otherObject = this.objects[j];

					if(currentObject.getHitbox().intersectsWith(otherObject.getHitbox())) {
						this.gameMechanicsManager.collisionOccurred(currentObject, otherObject);

						if(!currentObject.isEnabled()) {
							if(i < this.nextObj) {
								this.nextObj = i;
							}
							break;
						}
					}
				}
			} else {
				if(i < this.nextObj) {
					this.nextObj = i;
				}
			}
		}
	}

	void renderWorld() {
		this.renderTerrain();
		this.renderObjects();
	}

	void renderTerrain() {
		int startIndex = max(0, PLAYER.getCurrentTerrainIndex() - 1),
			endIndex = min(TERRAIN_LIST.length - 1, PLAYER.getCurrentTerrainIndex() + 1);

		for(int i = startIndex; i <= endIndex; i++) {
			TERRAIN_LIST[i].render();
		}
	}

	void renderObjects() {
		for(int i = 0; i < objCount; i++) {
			if(this.objects[i].isEnabled()) this.objects[i].render();
		}
	}

	void addObject(GameObject obj) {
		this.objects[this.nextObj] = obj;

		if(this.nextObj < this.objCount) {
			while(this.objects[this.nextObj].isEnabled() && this.nextObj < this.objCount) {
				this.nextObj++;
			}
		} else {
			this.nextObj = ++this.objCount;
		}

		if(this.objCount == this.objects.length) {
			this.objects = (GameObject[]) expand(this.objects, this.objCount * 2);
		}
	}
};

/* Game Mechanics Manager superclass */

class MechanicsManager {
	void collisionOccurred(GameObject anObject, GameObject otherObject) {
		background(random(0, 256));
	}

	void handleObjectFall(GameObject obj) {
		if(obj == PLAYER) {
			println("GAME OVER");
		} else {
			obj.disable();
		}
	}
};

/* * * * * * * * * * * * * * * *
 *		 HELPER FUNCTIONS	   *
 * * * * * * * * * * * * * * * */

