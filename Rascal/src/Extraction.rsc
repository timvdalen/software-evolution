module Extraction

import IO;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import DiagramLanguage;
import OFG;
import Set;

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
		{Method::method(meth, getName(m, meth), getReturn(m, meth), getAllParamSpec(m, meth), modifierForLoc(m, meth)) | meth <- methods(m,c)};

// Informatie over relaties tussen classes
public set[Relation] onzeRelaties(M3 m) = {
	
	// relations from OFG 
	rel[loc,loc] OFGrel = {<field, ref> | <field, ref> <- OFG::calc(true) + OFG::calc(false), isField(field), ref != |id:///|};
	rel[loc,loc] OFGassocs 
			= OFGrel
			- {<field3,bla3> | 	<field2, bla2> <- OFGrel, 
								<field3, bla3> <- OFGrel, 
								field2 == field3, <bla3, bla2> <- m@extends};
	
	// associations
	set[Relation] associations = {Relation::association(onzeClass(m, c), onzeClass(m, to), Field::field(from, typ, modifierForLoc(m, from))) |
		 <from, to> <- fieldAssociations(m) + OFGassocs, <from, c> <- fieldWithClass(m), <from, typ> <- fieldWithType(m)};
		 
	// dependency (can not be an association, dependency is weaker) like class A {void f(B b){b.g()}}
	set[Relation] dependencies1 = {Relation::dependency(from, to) |
		 from <- onzeClasses(m), meth <- from.functions, <typ, _> <- meth.parameters, to <- getSystemClass(m, typ)}
		 - {Relation::dependency(from, to) | Relation::association(from, to, _) <- associations};
		 
	set[Relation] generalizations = {Relation::generalization(onzeClass(m, relat.from), onzeClass(m, relat.to)) | relat <- m@extends};
	set[Relation] realizations = {Relation::realization(onzeClass(m, relat.from), onzeClass(m, relat.to)) | relat <- m@implements};
	
	return associations + dependencies1 + generalizations + realizations;
};

// Helper functies
public rel[loc, TypeSymbol] fieldWithType(M3 m) =
		 {<field, typ> | <field, typ> <- m@types, isField(field)};

public rel[loc, TypeSymbol] fieldWithTypePerClass(M3 m, loc c) =
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

public str getName(M3 m, loc l) = getOneFrom({name | <name, l> <- m@names});

public TypeSymbol getReturn(M3 m, loc meth) = {
		if (meth.scheme == "java+constructor") {
			return getOneFrom({TypeSymbol::\class(c, typ.parameters) | <meth, typ> <- m@types, <c, meth> <- m@containment, isMethod(meth), isClass(c)});
		}
		if (meth.scheme == "java+method") {
			return getOneFrom({typ.returnType | <meth, typ> <- m@types, isMethod(meth)});
		}
};

public set[loc] getMethParam(M3 m, loc meth) = 
		{param | <meth, param> <- m@containment, isParameter(param), isMethod(meth)};

public rel[TypeSymbol, str] getAllParamSpec(M3 m, loc meth) =
		{a | param <- getMethParam(m, meth), a <- getParamSpec(m, param)};

public rel[TypeSymbol, str] getParamSpec(M3 m, loc param) =
		{<typ, name> | <param, typ> <- m@types, <name, param> <- m@names, isParameter(param)};

		
/**
 * Returns the Class representing the given typesymbol.
 * It returns the Class as a singleton set, or an empty set when typ is no system class
 */
public set[Class] getSystemClass(M3 m, TypeSymbol typ) = 
	{onzeClass(m, l) | class(l, _) <- {typ}, l in classes(m)};
	
