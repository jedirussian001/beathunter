/*
 * This file contains the PlayerObject class, which represents the GameObject controlled by the player. 
 * It contains basic interaction methods, and some nasty-ish code (I'm sorry, this was kind of made in a hurry) 
 * to make the "camera" feel right and to avoid weird behavior (going off-screen and such)
 */

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