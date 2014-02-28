module Main

import DiagramLanguage;
import Extraction;
import Visualize;
import IO;
import lang::java::jdt::m3::Core;

/*
 * Creates a UML Class Diagram for the eLib project.
 */
 
/**
 * Creates a UML Class Diagram for the given project and saves at the given file.
 */
public void run(loc project, loc file) {
	M3 m3 = createM3FromEclipseProject(project);
	Diagram diagram = onsDiagram(m3);
	str dot = diagram2dot(diagram);
	
	// saving the file
	writeFile(file, dot);
	println("Output written to <file>");
}

/**
 * Creates and save the Diagram for the ELib project.
 */
public void runELib() = {
	loc project = |project://eLib|;
	loc file = |home:///software_evolution|;
	
	run(project, file);
};
