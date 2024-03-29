module DiagramLanguage

import lang::java::m3::AST;
import lang::java::m3::TypeSymbol;

/*
 * This module contains the data objects used to represent a class diagram.
 */
 
/**
 * Representation of a UML class diagram
 */
data Diagram = diagram(set[Class] classes, set[Relation] relations);

/**
 * The class object in the diagram.
 * The typeSymbol is a TypeSymbol::class that holds the identifier and generics of the class
 */
data Class = class(TypeSymbol typeSymbol, set[Field] fields, set[Method] methods);

/**
 * A field of a class (a variable)
 */
data Field = field(loc id, TypeSymbol typeSymbol, set[Modifier] modifiers);

/**
 * A method of a class (a function)
 */
data Method = method(loc id, str name, list[TypeSymbol] typParams, TypeSymbol typ, rel[TypeSymbol,str] parameters, set[Modifier] modifiers);

/**
 * The relations possible between two classes.
 * Some have an id representing the name of the relationship.
 */
data Relation = association(Class from, Class to, Field field)
			  | dependency(Class from, Class to)
			  | generalization(Class from, Class to)
			  | realization(Class from, Class to)
			  | inner(Class from, Class to);
