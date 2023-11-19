# Sub FileSystem plugin for Godot

Sub FileSystem is a plugin for the Godot Editor designed to integrate
with the default FileSystem dock of Godot Editor.

While Godot Editor is excellent, it offers only a single FileSystem dock. 

I felt what I'm so exhauted and spending lot of time with scrolling up and down 
through the entire of my huge resources.
The favorite system was not enough to me.

With this plugin, you can use your own multiple FileSystem docks and tabs
to organize complex folder structures according to your preferences.

<img src="./doc/screenshot.png" width="800"/>
<img src="./doc/screenshot2.png" width="400"/>


## Supported Version (Currently tested)

* godot 4.1 or higher

## Key Features

* Explore the file system of the Godot project
* Support multiple file system docks
* Add/Remove multiple tabs for each dock
* Support user-owned docks and project-shared docks
  * Configure by pressing the top-right button inside the dock panel
* Pin specific directories
  * Press the pin button to place them at the top inside the tab; other folders will be hidden
* Search for files and folders by resource path
  * Enter 'res://' path in the resource path field and press enter
* Search for resources by UID
  * Expand additional information by pressing the top-right button inside the tab
  * Enter 'uid://' in the UID field and press enter
* Set focus on the selected item in the default FileSystem dock
  * Toggle the search button at the top-right inside the tab (default is on)
* Opening a resource by double-click
  * Opening the import panel (.glb/.gltf) is currently not functional. I will implement it once it becomes possible, considering the exposure of additional Godot APIs.
* Write permissioned features
  * Create a directory
  * Remove folders and files
  * Create a script
  * Other features such as creating scenes or resources require exposing Godot APIs to deal with them.


## TODO

- [ ] Filter files
