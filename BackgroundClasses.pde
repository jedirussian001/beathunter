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

		if(this.offset >= width) {
			this.offset -= width;
		} else if(this.offset <= -width) {
			this.offset += width;
		}
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

	void render() {
		float playerPosition = PLAYER.getXPosition() + PLAYER.getOffsetX(), 
			stageEnd = TERRAIN_LIST[TERRAIN_LIST.length - 1].getEndPosition();

		if(PLAYER.getScreenXPosition() == (width / 2) && PLAYER.getSpeedX() != 0) this.computeOffset();

		imageMode(CORNER);
		if(this.offset > 0) image(this.img, this.offset - width, 0, this.layerWidth, this.layerHeight);
		image(this.img, this.offset, 0, this.layerWidth, this.layerHeight);
		if(this.offset < 0) image(this.img, this.offset + width, 0, this.layerWidth, this.layerHeight);
	}
}