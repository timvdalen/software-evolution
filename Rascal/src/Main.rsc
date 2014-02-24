module Main

import DiagramLanguage;
import Extraction;
import Visualize;
import lang::java::jdt::m3::Core;

/*
 * Creates a UML Class Diagram for the eLib project.
 */

public str run() = {
	loc project = |project://eLib|;
	M3 m3 = createM3FromEclipseProject(project);
	Diagram diagram = onsDiagram(m3);
	return diagram2dot(diagram);
};
