package gameObjects;

import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class Fireball extends Entity {
	public var display: Sprite;
	public var collision: CollisionBox;

	public function new(x: Float, y: Float, layer: Layer) {
		super();
		display = new Sprite("fireball");
		display.smooth = false;
		layer.addChild(display);

		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		display.pivotX = display.width() * 0.5;
		
		display.scaleX = display.scaleY = 1;
		collision.x = x;
		collision.y = y;

		collision.userData = this;

		collision.accelerationX = 1200;
		collision.maxVelocityX = 500;
		collision.dragX = 0.9;
	}

	override function update(dt: Float) {
		super.update(dt);
		collision.update(dt);
	}

	override function render() {
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		display.timeline.frameRate = (1 / 24) * s + (1 - s) * (1 / 10);	
    display.timeline.playAnimation("moving");

		display.x = collision.x;
		display.y = collision.y;
	}
}
