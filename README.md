# GMod Parallax Hole Addon

A pure-Lua Garry's Mod SENT that fakes an infinite hole using a render target and a virtual camera. It does not use custom shaders, binary modules, or real hole physics.

## Installation

Copy the `lua/` directory into an addon folder under `garrysmod/addons/`.

The entity appears in the **Fun** spawnmenu category. The optional tool is under **Construction > Parallax Hole**.

## Behavior

The plate remains solid. The shaft is client-side visual geometry only, so players cannot walk or fall into the apparent hole. Entity dimensions and depth are preserved through duplicator data and normal save/restore paths.

The render-target resolution and distance culling constants are at the top of `cl_init.lua`. For large numbers of holes, the intended next optimization is reducing the render-target size or updating visible holes every other frame.
