package gameObjects;

import com.collision.platformer.Sides;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class Dragon extends Entity {
	public var display: Sprite;
	public var collision: CollisionBox;
	var isAttacking = false;
	var hasThrownFirstFireball = false;
	var timeSinceLastFireball: Float = 0;

	public var x(get, null): Float;
	private inline function get_x(): Float{
		return display.x;
	}

	public var y(get, null): Float;
	private inline function get_y(): Float{
		return display.y;
	}

	public function new(x: Float, y: Float, layer: Layer) {
		super();
		display = new Sprite("dragon");
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

		collision.accelerationY = 2000;
		collision.maxVelocityX = 500;
		collision.maxVelocityY = 800;
		collision.dragX = 0.9;
		collision.staticObject = true;
	}

	override function update(dt: Float) {
		super.update(dt);
		collision.update(dt);
	}

	override function render() {
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		display.timeline.frameRate = (1 / 24) * s + (1 - s) * (1 / 10);
		
		if (isAttacking) {
			display.timeline.playAnimation("attack");
			isAttacking = false;
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX == 0) {
			display.timeline.playAnimation("idle");
		}

		display.x = collision.x;
		display.y = collision.y;
	}

	public inline function attack(target: Princess): Bool {
		if (isDead()) {
			return false;
		}

		isAttacking = true;
		return !hasThrownFirstFireball || timeSinceLastFireball > 1.5;
	}

	public inline function increaseTimeSinceLastFireball(dt: Float) {
		timeSinceLastFireball += dt;
		hasThrownFirstFireball = true;
	}

	public inline function resetTimeSinceLastFireball() {
		timeSinceLastFireball = 0;
	}

	override function destroy() {
		super.destroy();
		display.removeFromParent();
		collision.removeFromParent();
	}
}
