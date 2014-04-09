/*
 * This file contains the GameEngine class, which does the following:
 * - Generates the world terrain (fairly randomly)
 * - Processes world-object and object-object interactions (e.g. gravity and collisions)
 * - Renders everything that should be rendered (both objects and terrain). 
 *     Rendering is very simple currently, though. I'll work harder on it
 *
 * Note that for an object to be rendered it must be added to the GameEngine (via the method addObject) AND be active,
 * which is determined by an 'enabled' attribute on each object (which on the already implemented classes, defaults to true)
 */

class GameEngine {
	GameObject[] objects;
	BackgroundLayer[] layers;
	int objCount, nextObj;

	GameEngine(int maxSize) {
		this.objects = new GameObject[maxSize];
		this.objCount = this.nextObj = 0;
		this.layers = new BackgroundLayer[0];
	}

	void generateWorld(int numSections) {
		float aux = 0, startPos;
		int previousIndex;

		TERRAIN_LIST = new Terrain[numSections];

		TERRAIN_LIST[0] = new LandSection(50, 0);

		for(int i = 1; i < TERRAIN_LIST.length; i++) {
			startPos = TERRAIN_LIST[i - 1].getEndPosition();

			if(round(random(1)) == 0 && TERRAIN_LIST[i - 1].getMinimumHeight() != 0 && numSections - i > 1) {
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

	void addBackgroundLayer(BackgroundLayer newLayer) {
		this.layers = (BackgroundLayer[]) append(this.layers, newLayer);
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

					if(!otherObject.isEnabled()) {
						continue;
					}

					if(currentObject.getHitbox().intersectsWith(otherObject.getHitbox())) {
						this.collisionOccurred(currentObject, otherObject);

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
		this.renderBackground();
		this.renderObjects();
		this.renderTerrain();
	}

	void renderBackground() {
		for(int i = 0; i < this.layers.length; i++) {
			this.layers[i].render();
		}
	}

	void renderTerrain() {
		float leftScreenEdge = PLAYER.getXPosition() - (PLAYER.getScreenXPosition() - PLAYER.getOffsetX()),
				rightScreenEdge = leftScreenEdge + width;

		int startIndex = PLAYER.getCurrentTerrainIndex(), 
			endIndex = PLAYER.getCurrentTerrainIndex();

		while(startIndex > 0 && TERRAIN_LIST[startIndex].getEndPosition() > leftScreenEdge) startIndex--;

		while(endIndex + 1 < TERRAIN_LIST.length && TERRAIN_LIST[endIndex].getStartingPosition() < rightScreenEdge) endIndex++;

		for(int i = startIndex; i <= endIndex; i++) {
			TERRAIN_LIST[i].calculatePositionThenRender(leftScreenEdge);
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

	void collisionOccurred(GameObject anObject, GameObject otherObject) {
		GameObject playerOrNull = null, other = null;

		if(anObject == PLAYER) {
			playerOrNull = PLAYER;
			other = otherObject;
		} else if(otherObject == PLAYER) {
			playerOrNull = PLAYER;
			other = anObject;
		}

		if(playerOrNull != null) {
			for(int i = 0; i < TOKENS.length; i++) {
				if(other == TOKENS[i]) {
					JUNGLE_SOUNDS[i].unmute();
					TOKENS[i].disable();
				}
			}
		}
	}

	void handleObjectFall(GameObject obj) {
		obj.disable();
	}

	void changeState(int newState) {
		//code to be executed on 
		this.onExitState();

		CURRENT_STATE = newState;

		this.onEnterState();
	}

	void onExitState() {
		switch (CURRENT_STATE) {
			case 0:
				START_SCREEN_SONG.close();
				break;
			default:
				//not expected
				break;
		}
	}

	void onEnterState() {}

	void generateSounds() {
		START_SCREEN_SONG = MINIM.loadFile("intro.mp3");
		START_SCREEN_SONG.loop();

		JUNGLE_SOUNDS = new AudioPlayer[5];

		for(int i = 1; i <= JUNGLE_SOUNDS.length; i++) {
			JUNGLE_SOUNDS[i - 1] = MINIM.loadFile("sounds/j"+i+".wav");
			JUNGLE_SOUNDS[i - 1].mute();
			JUNGLE_SOUNDS[i - 1].loop();
		}
	}

	void generateTokens() {
		TOKENS = new Token[5];

		//TODO: generate tokens appropriately
		TOKENS[0] = new Token(400, 200, 50, 50);
		TOKENS[1] = new Token(1000, 200, 50, 50);
		TOKENS[2] = new Token(1500, 200, 50, 50);
		TOKENS[3] = new Token(2000, 200, 50, 50);
		TOKENS[4] = new Token(2500, 200, 50, 50);

		for(int i = 0; i < TOKENS.length; i++) {
			this.addObject(TOKENS[i]);
		}
	}
}