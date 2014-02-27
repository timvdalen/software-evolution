module Visualize

/*
 * This modules support DOT generation for the a uml class diagram.
 */

import DiagramLanguage;
import lang::java::m3::AST;
import lang::java::m3::TypeSymbol;
import lang::ofg::ast::FlowLanguage;
import String;
import List;

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
	
private str class2dot(Class cls) = "<classID(cls)> [
	'  label = \"{<className(cls)>| " +
	"<for (f <- cls.fields) {><field2dot(f)>\\l<}>|" +
	"<for (m <- cls.methods) {><method2dot(m)>\\l<}>" +
	"}\"\n]";
	
private str field2dot(Field fld) = 
	"<modifiers2dot(fld.modifiers)> <fieldName(fld)>: <typeName(fld.typeSymbol)>";

private str method2dot(Method meth) = {
	//generics = [typeName(typ) | typ <- meth.typ.typeParameters];
	generics = []; // for testing
	genericsString = isEmpty(generics)? "": "\\\<<intercalate(", ", generics)>\\\> ";
	return "<modifiers2dot(meth.modifiers)> <genericsString>" + 
		"<meth.name>(<parameters2dot(meth.parameters)>): <typeName(meth.typ)>";
};
	 
/** A String for the parameters, with parameters seperated by ", " */
private str parameters2dot(rel[TypeSymbol, str] parameters) = 
	intercalate(", ", ["<name> :<typeName(typ)>" | <typ, name> <- parameters]);
	
/** Generates the UML modifiers for a given list of Modifiers */
private str modifiers2dot(set[Modifier] mods) = {

	str result;

	// add visibility modifier to attr
	if (Modifier::\private() in mods) result = "-";
	else if (Modifier::\public() in mods) result = "+";
	else if (Modifier::\protected() in mods) result = "#";
	else result = "";
	
	// add static modifier to field (we use $ to indicate $tatic)
	if (Modifier::\static() in mods) result = "$<result>";
	
	return result;
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
	"<classID(from)> -\> <classID(to)>";
	
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
private str className(Class c) = {
	// getting parts that make the class name
	name = locName(c.typeSymbol.decl);
	generics = [typeName(typ) | typ <- c.typeSymbol.typeParameters];
	
	// no generics => just use name
	if (isEmpty(generics)) return name;
	// generics => add brackes <T, M, ...>
	else return "<name> \\\<<intercalate(", ", generics)>\\\>";
};

/** An identifier to use in DOT to refere to the node of the class */
private str classID(Class c) = 
	locName(c.typeSymbol.decl);

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
