/*
 * This file contains the PlayerObject class, which represents the GameObject controlled by the player. 
 * It contains basic interaction methods, and some nasty-ish code (I'm sorry, this was kind of made in a hurry) 
 * to make the "camera" feel right and to avoid weird behavior (going off-screen and such)
 */

class PlayerObject extends GameObject {
	float xPosition;
	int meleeAttackStage;
	boolean canAirJump;
	VisualState[] visualStates;
	int STANDING = 0, WALK = 1, JUMP = 2, ATTACK = 3;
	int currentState;

	PlayerObject(float x, float y, float offX, float offY, float hitW, float hitH) {
		super(x, y, offX, offY);

		/* UNTIL I FIND A BETTER PLACE FOR THESE VARIABLES, THIS STAYS HERE! */
		// variables for the image counting of the animation;
		int walkingFrames = 35, jumpingFrames, attackFrames;

		this.visualStates = new VisualState[4];
		this.visualStates[STANDING] = new SingleSprite("standing.png");
		this.visualStates[WALK] = new Animation("walk", walkingFrames);

		this.currentState = STANDING;

		this.hitbox = new Rectangle(this.getCenter(), hitW, hitH);
		this.meleeAttackStage = 0;
		this.canAirJump = true;
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
			this.setXPosition(newXPos);

			if(amount > 0 && this.getXPosition() >= TERRAIN_LIST[this.currentTerrainIndex].getEndPosition()) {
				this.currentTerrainIndex++;
			} else if(amount < 0 && this.getXPosition() < TERRAIN_LIST[this.currentTerrainIndex].getStartingPosition()) {
				this.currentTerrainIndex--;
			}
		}
	}

	void render() {
		/*fill(128);
		noStroke();
		rectMode(CENTER);
		rect(this.getScreenXPosition(), this.getCenter().getY(), 100, 100);*/

		this.visualStates[this.currentState].draw(this.getScreenXPosition(), this.getScreenYPosition());
		this.getHitbox().render();

		if(this.meleeAttackStage > 0) {
			float startingAngle = PI + HALF_PI;

			fill(255);
			noStroke();
			arc(this.getScreenXPosition(), this.getScreenYPosition(), 100, 100, startingAngle, startingAngle + (HALF_PI / this.meleeAttackStage));

			//CHECK FOR COLLISION W/ MELEE ATTACK HERE

			this.meleeAttackStage--;
		}
	}

	float getScreenXPosition() {
		float px = this.getXPosition(), ox = this.getOffsetX(), spx = px + ox,
				maxPx = TERRAIN_LIST[TERRAIN_LIST.length - 1].getEndPosition();

		if(px < (width / 2) - ox) {
			return spx;
		} else if(spx > maxPx - (width / 2)) {
			return min(width - this.centerToRight() + ox, width - (maxPx - spx));
		} else {
			return (width / 2);
		}
	}

	float getScreenYPosition() {
		return this.getCenter().getY() + this.getOffsetY();
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

	void interactWithKeyPressed(int keyCode) {
		if(keyCode == 39) { // right arrow
			this.setSpeedX(max(5, this.getSpeedX()));
			this.currentState = WALK;
		} else if(keyCode == 37) { // left arrow
			this.setSpeedX(min(-5, this.getSpeedX()));
			this.currentState = WALK;
		} else if(keyCode == 32) { // space
			this.jump();
		} else if(keyCode == 81){
			this.doMeleeAttack();
		}
	}

	void interactWithKeyReleased(int keyCode) {
		if((keyCode == 39 || keyCode == 37)) { // left or right arrow
			PLAYER.setSpeedX(0);
			this.currentState = STANDING;
		}
	}
};