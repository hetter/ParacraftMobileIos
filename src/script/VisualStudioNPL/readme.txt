NPL Language Service for Visual Studio 2008
-------------------------------------------
author: LiXizhi
date: 2008.10.16

Installation
--------------
VsNPL is a visual studio package for NPL/lua syntax highlighting. 
- Install it from SDKRoot/VsNPL/SetupVsNPL/Release/SetupVsNPL.msi
- Copy XML files you need in script/VisualStudioNPL to [SetupVsNPL Install Dir]/Documentation/. The latter is usually at C:\Program Files\ParaEngine\NPL language service\Documentation\
- If you want user defined intellisense, just edit above XML files manually and restart visual studio.

Requirement
--------------
- Visual studio 2008 to run.
- Visual studio 2008 SDK to build the source code.

Features
--------------
- Lua syntax highlighting
- Lua code comment and uncomment
- NPL/Lua code sense(intellisense) with word completion, member listing and quick info.
- Extensible code sense via XML files
- compatible with visual assist

