package states;

import js.html.Console;
import com.gEngine.display.Sprite;
import format.tmx.Data.TmxTileLayer;
import com.collision.platformer.CollisionBox;
import helpers.Tray;
import com.gEngine.display.extra.TileMapDisplay;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.framework.utils.VirtualGamepad;
import format.tmx.Data.TmxObject;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.collision.platformer.CollisionEngine;
import gameObjects.Princess;
import com.loading.basicResources.TilesheetLoader;
import com.loading.basicResources.SpriteSheetLoader;
import com.gEngine.display.Layer;
import com.loading.basicResources.DataLoader;
import com.collision.platformer.Tilemap;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;

class GameState extends State {
	var worldMap:Tilemap;
	var princess:Princess;
	var simulationLayer:Layer;
	var touchJoystick:VirtualGamepad;
	var tray:helpers.Tray;
	var castleMap:TileMapDisplay;
	var room:String;
	var winZone:CollisionBox;


	public function new(room:String, fromRoom:String = null) {
		super();
		this.room=room;
	}

	override function load(resources:Resources) {
		resources.add(new DataLoader("testRoom_tmx"));
		var atlas = new JoinAtlas(2048, 2048);

		atlas.add(new TilesheetLoader("castle_tileset_part1", 16, 16, 0));
		atlas.add(new SpriteSheetLoader("hero", 22, 36, 0, [
			new Sequence("fall", [9]),
			new Sequence("slide", [5]),
			new Sequence("jump", [8]),
			new Sequence("run", [0, 1, 2, 3, 4]),
			new Sequence("idle", [6]),
			new Sequence("wallGrab", [5])
		]));
		resources.add(atlas);
	}

	override function init() {
		stageColor(0.5, .5, 0.5);
		simulationLayer = new Layer();
		stage.addChild(simulationLayer);

		worldMap = new Tilemap("testRoom_tmx", "castle_tileset_part1");
		worldMap.init(parseTileLayers, parseMapObjects);

		tray = new Tray(castleMap);
		stage.defaultCamera().limits(16*2, 0, worldMap.widthIntTiles * 16 - 4*16, worldMap.heightInTiles * 16 );
		createTouchJoystick();
	}

	function createTouchJoystick() {
		touchJoystick = new VirtualGamepad();
		touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.Left);
		touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.Right);
		touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.Up);
		touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.Space);
		touchJoystick.addKeyButton(XboxJoystick.X, KeyCode.X);
		touchJoystick.addKeyButton(XboxJoystick.Y, KeyCode.G);
		
		touchJoystick.notify(princess.onAxisChange, princess.onButtonChange);

		var gamepad = Input.i.getGamepad(0);
		gamepad.notify(princess.onAxisChange, princess.onButtonChange);
	}

	function parseTileLayers(layerTilemap:Tilemap, tileLayer:TmxTileLayer) {
		if (!tileLayer.properties.exists("noCollision")) {
			layerTilemap.createCollisions(tileLayer);
		}
		simulationLayer.addChild(layerTilemap.createDisplay(tileLayer));
		 castleMap = layerTilemap.createDisplay(tileLayer);
		 simulationLayer.addChild(castleMap);
	}

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {
		if(compareName(object,"playerPosition")){
			if(princess==null){
				princess = new Princess(object.x, object.y, simulationLayer);
				addChild(princess);
			}
		}else
		if(compareName(object,"winZone"))
		{
			winZone=new CollisionBox();
			winZone.x=object.x;
			winZone.y=object.y;
			winZone.width=object.width;
			winZone.height=object.height;
		}else
		if(compareName(object,"powerFlower")){
			var sprite=new Sprite("tiles2");
			sprite.x=object.x;
			sprite.y=object.y-object.height;
			sprite.timeline.gotoAndStop(1);
			stage.addChild(sprite);
		}
	}
	inline function compareName(object:TmxObject,name:String) {
		return object.name.toLowerCase() == name.toLowerCase();
	}

	override function update(dt:Float) {
		super.update(dt);

		stage.defaultCamera().setTarget(princess.collision.x, princess.collision.y);

		CollisionEngine.collide(princess.collision,worldMap.collision);
		if(CollisionEngine.overlap(princess.collision,winZone)){
			// changeState(new GameState("",""));
		}

		//tray.setContactPosition(princess.collision.x + princess.collision.width / 2, princess.collision.y + princess.collision.height + 1, Sides.BOTTOM);
		//tray.setContactPosition(princess.collision.x + princess.collision.width + 1, princess.collision.y + princess.collision.height / 2, Sides.RIGHT);
		//tray.setContactPosition(princess.collision.x-1, princess.collision.y+princess.collision.height/2, Sides.LEFT);
	}

	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera = stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer, camera);
	}
	#end
}
