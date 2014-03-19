/*
 * This file contains the basic classes that are commonly used by other classes, and classes that only serve as superclasses for
 * other ones.
 */

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

/*
 * GameObject class
 *
 * The GameObject class acts as an abstraction for all objects that can interact with each other or with the environment. 
 * This way, the engine is able to perform basic common operations upon these objects (like rendering them) just by knowing
 * that they are GameObjects, without knowing how are they rendered. Inheritance FTW!
 */

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
			ENGINE.handleObjectFall(this);
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

	float centerToBottom() {
		return this.getHitbox().getHeight() / 2;
	}

	float centerToLeft() {
		return this.getHitbox().getWidth() / 2;
	}
	
	float centerToRight() {
		return this.getHitbox().getWidth() / 2;
	}

	float centerToTop() {
		return this.getHitbox().getHeight() / 2;
	}
	abstract void render();
};

/*
 * Terrain class
 *
 * The Terrain class acts as an abstraction for all terrain in the generated world (even the lack of terrain - scary killer pits).
 * The only thing worth mentioning about this class is the interactWithObject method, which is called when a certain object is 
 * standing upon the piece of terrain.
 */

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
