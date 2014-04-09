/*
 * This file contains all the Terrain subclasses.
 */

class LandSection extends Terrain {
	LandSection(float h, float pos) {
		super(pos, h, TERRAIN_WIDTH, true);

		if(LAND_TEXTURE == null)
			LAND_TEXTURE = loadImage("data/landscape/land.png");

		if(GRASS_TEXTURE == null)
			GRASS_TEXTURE = loadImage("data/landscape/grass.png");
	}

	void calculatePositionThenRender(float leftScreenEdge) {
		float startX = this.getStartingPosition() - leftScreenEdge;

		this.render(startX, height - this.getHeight(), this.getWidth());
	}

	void render(float x, float y, float w) {
		// rectMode(CORNER);
		// fill(180, 0, 0);
		// noStroke();
		// rect(x, y, w, this.getHeight());

		imageMode(CORNER);
		for(float j = y; j < height; j += LAND_TEXTURE_HEIGHT) {
			for(float i = x; i < x + w; i += LAND_TEXTURE_WIDTH) {
				image(LAND_TEXTURE, i, j, LAND_TEXTURE_WIDTH, LAND_TEXTURE_HEIGHT);
			}
		}
		imageMode(CENTER);
		for(float i = x + (LAND_TEXTURE_WIDTH / 2); i < x + w; i += LAND_TEXTURE_WIDTH) {
			image(GRASS_TEXTURE, i, y, LAND_TEXTURE_WIDTH, 20);
		}
	}

	float interactWithObject(GameObject obj, float y) {
		obj.setSpeedY(0);

		if(obj == PLAYER) { // if the player touches the floor, he can jump again!
			PLAYER.resetJumps();
			if(PLAYER.getState() != ATTACK) {
				if(PLAYER.getSpeedX() == 0) {
					PLAYER.setState(STANDING);
				} else {
					PLAYER.setState(WALK);
				}
			}
		}

		return (height - this.getHeight()) - obj.centerToBottom();
	}
};

class Pit extends Terrain {
	Pit(float pos) {
		super(pos, 0, PIT_WIDTH, false);
	}

	void calculatePositionThenRender(float leftScreenEdge) {}

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