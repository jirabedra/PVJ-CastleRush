package;

import states.FirstLevel;
import kha.WindowMode;
import kha.FramebufferOptions;
import kha.WindowOptions;
import kha.System;
import com.framework.Simulation;
#if (kha_html5 && js)
import js.html.CanvasElement;
import js.Browser.document;
import js.Browser.window;
import js.Browser.navigator;
#end

class Main {
	
	public static function main() {
		#if hotml new hotml.Client(); #end
		var windowsOptions = new WindowOptions("Castle Rush v0.0.1", 0, 0, 1280, 720, null, true, WindowFeatures.FeatureResizable,WindowMode.Windowed);
		var frameBufferOptions = new FramebufferOptions(60, true, 32, 16, 8, 0);
		System.start(new SystemOptions("Castle Rush v0.0.1", 1280, 720, windowsOptions, frameBufferOptions), (w) -> {
			new Simulation(FirstLevel, 1280, 720, 1, 0);
		});
	}
}
