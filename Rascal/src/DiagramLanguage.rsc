module DiagramLanguage

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
 */
data Class = class(loc id, set[Field] variables, set[Field] functions);

/**
 * A field of a class (can either be a variable or a function)
 */
data Field = field(loc id, TypeSymbol typeSymbol);

/**
 * The relations possible between two classes.
 * Some have an id representing the name of the relationship.
 */
data Relation = association(Class from, Class to, Field field)
			  | dependency(Class from, Class to)
			  | generalization(Class from, Class to)
			  | realization(Class from, Class to);
