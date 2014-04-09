class Token extends GameObject {
	PImage sprite;
	float tWidth;
	float tHeight;

	Token(float x, float y, float w, float h) {
		super(x, y, 0, 0);
		this.tWidth = w;
		this.tHeight = h;
		this.sprite = loadImage("data/note.png");
		this.affectedByGRAVITY = false;
		this.hitbox = new Rectangle(this.getCenter(), w, h);
	}

	void render() {
		imageMode(CENTER);
		image(this.sprite, this.getScreenXPosition(), this.getScreenYPosition(), this.tWidth, this.tHeight);
	}
}