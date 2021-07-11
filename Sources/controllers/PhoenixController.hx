package controllers;

import gameObjects.Phoenix;
import com.loading.basicResources.SoundLoader;
import com.loading.Resources;
import states.GameOver;
import com.collision.platformer.CollisionBox;
import com.collision.platformer.Sides;
import gameObjects.Princess;
import com.collision.platformer.Tilemap;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionEngine;
import com.loading.basicResources.SpriteSheetLoader;
import com.loading.basicResources.JoinAtlas;

class PhoenixController {
  var simulationLayer: Layer;
  var worldMap: Tilemap;
  var princess: Princess;
  var phoenix: Phoenix;
  var dangerZone: CollisionBox;

  public function new() { }

  public function load(resources: Resources) {
    var atlas = new JoinAtlas(2048, 2048);
    atlas.add(new SpriteSheetLoader("phoenix", 41, 21, 0, [
			new Sequence("idle", [0, 1, 2, 3, 4, 5, 6])
		]));

    resources.add(atlas);
    resources.add(new SoundLoader("phoenix_death"));
  }

  public function init(simulationLayer: Layer, worldMap: Tilemap) {
    this.simulationLayer = simulationLayer;
    this.worldMap = worldMap;
  }

  public function setPhoenix(phoenix: Phoenix) {
    this.phoenix = phoenix;
  }

  public function setPrincess(princess: Princess) {
    this.princess = princess;
  }

  public function setDangerZone(dangerZone: CollisionBox) {
    this.dangerZone = dangerZone;
  }

  public function update(dt: Float, addChild, changeState) {
    if (phoenix != null) {
			CollisionEngine.collide(phoenix.collision, worldMap.collision);
	
			if (CollisionEngine.overlap(princess.collision, dangerZone)) {
				phoenix.follow(princess);
			}
	
			if (CollisionEngine.collide(princess.collision, phoenix.collision)) {
				if (princess.powerfulAf || phoenix.collision.isTouching(Sides.TOP)) {
          if (!phoenix.collision.isTouching(Sides.TOP)) {
            princess.powerfulAf = false;
          }

					phoenix.die();
					phoenix = null;
				} else if (phoenix.collision.isTouching(Sides.LEFT) || phoenix.collision.isTouching(Sides.RIGHT)) {
					princess.takeDamage(dt);
	
					if (princess.isDead()) {
						changeState(new GameOver());
					}
				}
			}
		}
  }
}
