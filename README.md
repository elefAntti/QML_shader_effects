# QML_shader_effects

What are these? This repository contains various pixel shader effects using QML to host the shaders (create window etc),
load the assets and animate things. This allows to create nice graphical effects with relatively little code.

You need qmlscene to view these. Use command "qmlscene MyScene.qml".

Each of the qml files in scenes directory are viewable this way:
 - SceneMandelbrot.qml
   The first pixel shader I did. What would be the best "hello world" if not the infamous mandelbrot set.
   
 - SceneMetaballs.qml  
   The scene that began it all. This is a signed distance field raycasting algorithm rendering metaballs effect,
   that was originally run on a custom C++ launcher, but I later ported it to use QML, so there would be less boilerplate.
   The code is bit old and result of some hacking, so it may not be the clearest.

 - SceneVoxels.qml
   I made the raycast algorithm render everything blocky like it was made out of voxels.
   
 - SceneDotGrid.qml
   This is a 2D effect that renders objects (2D signed distance field) as a collection of evenly spaced
   circles, whose radii are determined by the distance to the object surface

 - SceneSphereVoxels.qml
   This kind of combines the two effects above. It uses the voxel renderer as a basis and draws on object as
   a collection of spheres, growing and shrinking as they get closer/further from the surface.
   
 - SceneCRT.qml
   Render an image as if it was on a really bad CRT screen. This was intended as a post processing step or something.
   
 - SceneOsciloscope.qml
   And since I did CRT, the logical next step was to emulate oscilloscope screen
   

Toys directory has a mandelbrot zoomer that you can use with mouse wheel and dragging.

