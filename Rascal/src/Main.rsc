module Main

import DiagramLanguage;
import Extraction;
import Visualize;
import IO;
import lang::java::jdt::m3::Core;

/*
 * Creates a UML Class Diagram for the eLib project.
 */

public void run() = {
	loc project = |project://eLib|;
	M3 m3 = createM3FromEclipseProject(project);
	Diagram diagram = onsDiagram(m3);
	str dot = diagram2dot(diagram);
	
	// saving the file
	loc file = |home:///software_evolution|;
	writeFile(file, dot);
	println("Output written to <file>");
};
