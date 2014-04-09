abstract class Creature extends GameObject {
	Creature(float x, float y, float offX, float offY) {
		super(x, y, offX, offY);
	}

	abstract void behaviour();
};

// not yet implemented. going to do that next
// Daniel
class Pig extends Creature {
	Pig(float x, float y, float offX, float offY) {
		super(x, y, offX, offY);
	}

	void behaviour() {

	}

	void render() {

	}
};

class Monkey extends Creature {
	Monkey(float x, float y, float offX, float offY) {
		super(x, y, offX, offY);
	}

	void behaviour() {

	}

	void render() {
		
	}
}