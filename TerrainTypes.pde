/*
 * This file contains all the Terrain subclasses.
 */

class LandSection extends Terrain {
	LandSection(float h, float pos) {
		super(pos, h, TERRAIN_WIDTH, true);
	}

	void render(float x, float y, float w) {
		rectMode(CORNER);
		fill(180, 0, 0);
		noStroke();
		rect(x, y, w, this.getHeight());
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

	void calculateThenRender() {}

	void render(float x, float y, float w) {}

	float interactWithObject(GameObject obj, float y) {
		return y;
	}
};

class Quicksand extends Terrain {
	Quicksand(float h, float pos) {
		super(pos, h, PIT_WIDTH, false);
	}

	void render(float x, float y, float w) {
		rectMode(CORNER);
		fill(0);
		noStroke();
		rect(x, y, w, this.getHeight());
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