abstract class BackgroundLayer {
	float distanceFromPlayer;
	float offset;

	BackgroundLayer(float dbp) {
		this.distanceFromPlayer = dbp;
		this.offset = 0;
	}

	void computeOffset() {
		float totalDistance = this.distanceFromPlayer + PLAYER_CAMERA_DISTANCE,
				deltaX = PLAYER.getSpeedX(), deltaAnglePlayer, deltaAngleLayer;

		deltaAnglePlayer = atan(deltaX / PLAYER_CAMERA_DISTANCE);
		deltaAngleLayer = atan(deltaX / totalDistance);

		this.offset -= deltaX * (deltaAngleLayer / deltaAnglePlayer);
	}

	abstract void render();
};

class ResizedImageLayer extends BackgroundLayer {
	PImage img;
	float layerWidth;
	float layerHeight;

	ResizedImageLayer(String path, float lWidth, float lHeight, float dbp) {
		super(dbp);
		this.img = loadImage(path);
		this.layerWidth = lWidth;
		this.layerHeight = lHeight;
	}

	void computeOffset() {
		super.computeOffset();

		if(this.offset >= this.layerWidth) {
			this.offset -= this.layerWidth;
		} else if(this.offset <= -this.layerWidth) {
			this.offset += this.layerWidth;
		}
	}

	void render() {
		float playerPosition = PLAYER.getXPosition() + PLAYER.getOffsetX(), 
			stageEnd = TERRAIN_LIST[TERRAIN_LIST.length - 1].getEndPosition(),
			repetitionStart = this.offset;

		if(PLAYER.getScreenXPosition() == (width / 2) && PLAYER.getSpeedX() != 0) this.computeOffset();

		imageMode(CORNER);

		while(repetitionStart > 0) repetitionStart -= this.layerWidth;

		while(repetitionStart < width) {
			image(this.img, repetitionStart, 0, this.layerWidth, this.layerHeight);

			repetitionStart += this.layerWidth;
		}
	}
}