module Extraction

import IO;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::ofg::ast::Java2OFG;
import lang::ofg::ast::FlowLanguage;
import DiagramLanguage;

public M3 m = createM3FromEclipseProject(|project://eLib|);

public Program p = createOFG(|project://eLib|);

// Informatie over heel programma
public Diagram onsDiagram(M3 m) = Diagram::diagram(onzeClasses(m), onzeRelaties(m));

// Static informatie uit classes
public set[Class] onzeClasses(M3 m) = 
		{onzeClass(m,c) | c <- classes(m)};

public Class onzeClass(M3 m, loc c) = 
		Class::class(c,
					{Field::field(f, typ, modifierForLoc(m, f)) | <f, typ> <- fieldWithTypePerClass(m,c)},
					onzeMethods(m, c));

public set[Method] onzeMethods(M3 m, loc c) = 
		{Method::method(getMethodAST(meth, model = m), modifierForLoc(m, meth)) | meth <- methods(m,c)};

// Informatie over relaties tussen classes
public set[Relation] onzeRelaties(M3 m) = 
		{Relation::association(onzeClass(m, c), onzeClass(m, to), Field::field(from, typ, modifierForLoc(m, from))) | <from, to> <- fieldAssociations(m), <from, c> <- fieldWithClass(m), <from, typ> <- fieldWithType(m)} +
		{Relation::dependency(onzeClass(m, c), onzeClass(m, to)) | <from, to> <- fieldAssociations(m), <from, c> <- fieldWithClass(m)} +
		{Relation::generalization(onzeClass(m, relat.from), onzeClass(m, relat.to)) | relat <- m@extends} +
		{Relation::realization(onzeClass(m, relat.from), onzeClass(m, relat.to)) | relat <- m@implements};

// Helper functies
public rel[loc, TypeSymbol] fieldWithType(M3 m) =
		 {<field, typ> | <field, typ> <- m@types, isField(field)};

private rel[loc, TypeSymbol] fieldWithTypePerClass(M3 m, loc c) =
		 {<field, typ> | <field, typ> <- m@types, isField(field), field <- fields(m,c)};
 
public rel[loc, loc] fieldWithClass(M3 m) = 
		{<field, class> | <class, field> <- m@containment, isField(field)};

public set[Modifier] modifierForLoc(M3 m, loc c) =
		{modi | <c,modi> <- m@modifiers};

public rel[loc, loc] fieldAssociations(M3 m) =
		 {<field, class> | <field, class> <- m@typeDependency, isField(field), isClass(class), class <- m@declarations<name>};

public rel[loc, loc] fieldDependencies(M3 m) =
		{<var, class> | <var, class> <- m@typeDependency, isVariable(var), isClass(class), class <- m@declarations<name>} +
		{<param, class> | <param, class> <- m@typeDependency, isParameter(param), isClass(class), class <- m@declarations<name>};

