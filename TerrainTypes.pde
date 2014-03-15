/*
 * This file contains all the Terrain subclasses.
 */

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

		if(obj == PLAYER) { // if the player touches the floor, he can jump again!
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