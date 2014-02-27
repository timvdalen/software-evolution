module Visualize

/*
 * This modules support DOT generation for the a uml class diagram.
 */

import DiagramLanguage;
import lang::java::m3::AST;
import lang::java::m3::TypeSymbol;
import lang::ofg::ast::FlowLanguage;
import String;

/**
 * Writes diagram to file in dot file format
 */
public str diagram2dot(Diagram diagram) ="<header>
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
	
private str field2dot(Field fld) = 
	"<modifiers2dot(fld.modifiers, fieldName(fld))>: <typeName(fld.typeSymbol)>";

private str method2dot(Method meth) =
	 "<modifiers2dot(meth.modifiers, meth.name)>(<parameters2dot(meth.parameters)>): <typeName(meth.typ)>";

private str parameters2dot(rel[TypeSymbol, str] parameters) = 
	// replace last gets rid of extra ", " from loop
	replaceLast("<for(<ts, name> <- parameters){><name>: <typeName(ts)>, <}>", ", ", "");
	
/** Takes a set of modifiers and modifies field to show the Modifiers in UML. */
private str modifiers2dot(set[Modifier] mods, str field) = {
	// add visibility modifier to attr
	if (Modifier::\private() in mods) field = "- <field>";
	else if (Modifier::\public() in mods) field = "+ <field>";
	else if (Modifier::\protected() in mods) field = "# <field>";
	
	// add static modifier to field (we use $ to indicate $tatic)
	if (Modifier::\static() in mods) field = "$<field>";
	
	return field;
};

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
	switch (ts) { // switching of classes ts can be
		case class(l, _): return locName(l);
		case interface(l, _): return locName(l);
		case enum(l): return locName(l);
		case array(ts2, _): return typeName(ts2); 
		case typeParameter(l, _): return locName(l);
		case other: {// take the name of the object without ()
			str string = "<other>";
			if (/<x: .*>\(\)$/ := string) return x;
			else return string;
		}
	};
};

// TODO: nodig voor methods maar moet verbeterd
private str param(Decl d) = "<d.\type>: <d.name>";

str locName(loc l) = {
	if (/<x: [^\/]*>$/ := l.path) x;
	else "unknown";
};
