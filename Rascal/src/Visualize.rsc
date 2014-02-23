module Visualize

/*
 * This modules support DOT generation for the a uml class diagram.
 */

import DiagramLanguage;
import lang::java::m3::TypeSymbol;
import IO;

/**
 * Writes diagram to file in dot file format
 */
str diagram2dot(Diagram diagram) ="<header>
	'<for (c <- diagram.classes) {>
	'  <class2dot(c)> 
	'<}>
	'<for (r <- diagram.relations) {>
	'  <relation2dot(r)>
	'<}>
	'<footer>";
	
private str class2dot(Class cls) = "<className(cls)> [
	'  label = \"{<className(cls)>| " +
	"<for (f <- cls.variables) {><field2dot(f)>\\l<}>|" +
	"<for (m <- cls.functions) {><method2dot(m)>\\l<}>" +
	"}\"\n]";
	
private str field2dot(Field fld) = "<fieldName(fld)>: <typeName(fld.typeSymbol)>";

// TODO: verbeter deze
private str method2dot(Method meth) = "<meth.\return>: <meth.name>(<for (p <- meth.parameters) {><param(p)>,<}>)";
	
private str relation2dot(Relation relation) = {
	switch(relation) {
		case association(from, to, field):
			return "<dotArrow(from, to)> [label = \"<fieldName(field)>\"]";
		case dependency(from, to):
			return "<dotArrow(from, to)> [style = \"dashed\"]";
		case generalization(from, to):
			return "<dotArrow(from, to)> [arrowhead = \"empty\"]";
		case realization(from, to):
			return "<dotArrow(from, to)> [style = \"dashed\", arrowhead = \"empty\"]";
	}
};

/** Generates Dot code for a simple arrow between from and to, with no attributes set */
private str dotArrow(Class from, Class to) = 
	"<className(from)> -\> <className(to)>";
	
private str header = "digraph G {
	'  fontname = \"Bitstream Vera Sans\"
    '  fontsize = 8
	'
    '  node [
    '    fontname = \"Bitstream Vera Sans\"
    '    fontsize = 8
    '    shape = \"record\"
    '  ]
	'
	'  edge [
	'    fontname = \"Bitstream Vera Sans\"
	'    fontsize = 8
	'  ]";
	
private str footer = "}";
    
/** Gets the name of a class */
private str className(Class c) = locName(c.id);

/** Gets the name of the field */
private str fieldName(Field f) = locName(f.id);

/** Gets the name of the TypeSymbol */
private str typeName(TypeSymbol ts) = {
	class(l, _) = ts;
	locName(l);
};

// TODO: nodig voor methods maar moet verbeterd
private str param(Declaration d) = "<d.\type>: <d.name>";

str locName(loc l) = {
	if (/<x: [^\/]*>$/ := l.path) x;
	else "unknown";
};
