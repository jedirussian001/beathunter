/*
 * This file contains classes that represent simple, geometric objects. 
 * They were created for testing purposes on the initial development of this project, but will remain here as code samples.
 */

abstract class ColouredObject extends GameObject {
	color objColor;

	ColouredObject(color objColor, float x, float y) {
		super(x, y);
		this.objColor = objColor;
	}

	color getObjectColor() {
		return this.objColor;
	}

	void setObjectColor(color objColor) {
		this.objColor = objColor;
	}

	void render() {
		fill(this.objColor);
	}
};

class RectangleObject extends ColouredObject {
	float objWidth;
	float objHeight;

	RectangleObject(color objColor, float centerX, float centerY, float objWidth, float objHeight) {
		super(objColor, centerX, centerY);
		this.objWidth = objWidth;
		this.objHeight = objHeight;

		this.hitbox = new Rectangle(this.getCenter(), objWidth, objHeight);
	}

	void render() {
		super.render();
		rectMode(CENTER);
		rect(PLAYER.getScreenXPosition() + (this.getXPosition() - PLAYER.getXPosition()), 
				this.getCenter().getY(), this.objWidth, this.objHeight);
	}

	float centerToBottom() {
		return (this.objHeight / 2);
	}

	float centerToLeft() {
		return (this.objWidth / 2);
	}

	float centerToRight() {
		return (this.objWidth / 2);
	}
};

class EllipseObject extends ColouredObject {
	float radiusX;
	float radiusY;

	EllipseObject(color objColor, float centerX, float centerY, float radiusX, float radiusY) {
		super(objColor, centerX, centerY);
		this.radiusX = radiusX;
		this.radiusY = radiusY;

		this.hitbox = new Rectangle(this.getCenter(), radiusX * 2, radiusY * 2);
	}

	EllipseObject(color objColor, float centerX, float centerY, float radius) {
		super(objColor, centerX, centerY);
		this.radiusX = this.radiusY = radius;

		this.hitbox = new Rectangle(this.getCenter(), radius * 2, radius * 2);
	}

	void render() {
		super.render();
		ellipseMode(RADIUS);
		ellipse(PLAYER.getScreenXPosition() + (this.getXPosition() - PLAYER.getXPosition()), 
				this.getCenter().getY(), this.radiusX, this.radiusY);
	}

	float centerToBottom() {
		return this.radiusY;
	}

	float centerToLeft() {
		return this.radiusX;
	}

	float centerToRight() {
		return this.radiusX;
	}
};