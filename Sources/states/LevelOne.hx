package states;

import com.collision.platformer.CollisionEngine;
import format.tmx.Data.TmxObject;
import controllers.DragonController;
import com.loading.basicResources.SoundLoader;
import com.collision.platformer.CollisionGroup;
import gameObjects.Dragon;
import com.collision.platformer.CollisionBox;
import com.collision.platformer.Tilemap;
import com.loading.Resources;

class LevelOne extends BaseLevel {
	var dragon: Dragon;
	var dangerZone: CollisionBox;
	var dragonController = new DragonController();
	var fireballCollisionGroup = new CollisionGroup();

	public function new() {
		super();
		tmxName = 'levelOne_tmx';
	}

	override function load(resources: Resources) {
		super.load(resources);
		dragonController.load(resources);
		resources.add(new SoundLoader("dragon_death_fx"));
	}

	override function init() {
		super.init();
		dragonController.init(simulationLayer, worldMap);
	}

	override function parseMapObjects(layerTilemap: Tilemap, object: TmxObject) {
		super.parseMapObjects(layerTilemap, object);

		switch (object.name.toLowerCase()) {
			case "playerposition":
				if (princess != null) {
					dragonController.setPrincess(princess);
				}

			case "enemyposition":
				if (dragon == null) {
					dragon = new Dragon(object.x, object.y, simulationLayer);
					dragonController.setDragon(dragon);
					addChild(dragon);
				}

			case "dangerzone":
				dangerZone = new CollisionBox();
				dangerZone.x = object.x;
				dangerZone.y = object.y;
				dangerZone.width = object.width;
				dangerZone.height = object.height;
				dangerZone.staticObject = true;
				dragonController.setDangerZone(dangerZone);
		}
	}

	override function update(dt: Float) {
		super.update(dt);
		dragonController.update(dt, addChild, changeState);

		if (CollisionEngine.overlap(princess.collision, winZone)) {
			changeState(new LevelTwo());
		}
	}
}
