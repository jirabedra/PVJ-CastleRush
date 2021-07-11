package controllers;

import com.loading.basicResources.SoundLoader;
import com.loading.Resources;
import states.GameOver;
import com.collision.platformer.CollisionBox;
import com.collision.platformer.Sides;
import gameObjects.Princess;
import com.collision.platformer.Tilemap;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionGroup;
import gameObjects.Fireball;
import com.collision.platformer.CollisionEngine;
import gameObjects.Dragon;
import com.loading.basicResources.SpriteSheetLoader;
import com.loading.basicResources.JoinAtlas;

class DragonController {
  var simulationLayer: Layer;
  var worldMap: Tilemap;
  var princess: Princess;
  var dragon: Dragon;
  var dangerZone: CollisionBox;
  var fireballCollisionGroup = new CollisionGroup();

  public function new() { }

  public function load(resources: Resources) {
    var atlas = new JoinAtlas(2048, 2048);
    atlas.add(new SpriteSheetLoader("dragon", 30, 28, 0, [
			new Sequence("idle", [0]),
			new Sequence("attack", [1, 2, 3])
		]));
		atlas.add(new SpriteSheetLoader("fireball", 32, 13, 0, [
			new Sequence("moving", [0, 1, 2, 3, 4])
		]));

    resources.add(atlas);
    resources.add(new SoundLoader("dragon_death_fx"));
  }

  public function init(simulationLayer: Layer, worldMap: Tilemap) {
    this.simulationLayer = simulationLayer;
    this.worldMap = worldMap;
  }

  public function setDragon(dragon: Dragon) {
    this.dragon = dragon;
  }

  public function setPrincess(princess: Princess) {
    this.princess = princess;
  }

  public function setDangerZone(dangerZone: CollisionBox) {
    this.dangerZone = dangerZone;
  }

  public function update(dt: Float, addChild, changeState) {
    if (dragon != null) {
			CollisionEngine.collide(dragon.collision, worldMap.collision);

			if (CollisionEngine.overlap(princess.collision, dangerZone)) {
				var shouldThrowFireball = dragon.attack(princess);
				dragon.increaseTimeSinceLastFireball(dt);
	
				if (shouldThrowFireball) {
					dragon.resetTimeSinceLastFireball();
					var fireball = new Fireball(dragon.x, dragon.y, simulationLayer, fireballCollisionGroup);
					addChild(fireball);
				}
			}
	
			CollisionEngine.collide(princess.collision, dragon.collision, (princessC, dragonC) -> {
				if (princess.powerfulAf || dragon.collision.isTouching(Sides.TOP)) {
					if (!dragon.collision.isTouching(Sides.TOP)) {
						princess.powerfulAf = false;
					}

					dragon.die();
					dragon = null;
				}
			});
	
			CollisionEngine.overlap(princess.collision, fireballCollisionGroup, (fireballC, princessC) -> {
				var fireball: Fireball = cast fireballC.userData;
				fireball.destroy();
				princess.takeDamage(dt);
	
				if (princess.isDead()) {
					changeState(new GameOver());
				}
			});
		}
  }
}
