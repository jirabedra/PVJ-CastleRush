let project = new Project('New Project');
project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addDefine('debugInfo');
project.addDefine('DEBUGDRAW');
project.addSources('Sources');
await project.addProject('khawy');
project.addLibrary('tiled');


resolve(project);
