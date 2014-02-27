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
		Class::class(getClassType(m, c),
					{Field::field(f, typ, modifierForLoc(m, f)) | <f, typ> <- fieldWithTypePerClass(m,c)},
					onzeMethods(m, c));

public set[Method] onzeMethods(M3 m, loc c) = 
		{Method::method(meth, getName(m, meth), getTypeParams(m, meth), getReturn(m, meth), getAllParamSpec(m, meth), modifierForLoc(m, meth)) | meth <- methods(m,c)};

// Informatie over relaties tussen classes
public set[Relation] onzeRelaties(M3 m) = {
	
	// associations from OFG 
	rel[loc,loc] OFGassocsRel = {<field, ref> | <field, ref> <- OFG::calc(true) + OFG::calc(false), isField(field), ref != |id:///|};
	rel[loc,loc] OFGassocs 
			= OFGassocsRel
			- {<field3,bla3> | 	<field2, bla2> <- OFGassocsRel, 
								<field3, bla3> <- OFGassocsRel, 
								field2 == field3, <bla3, bla2> <- m@extends};
	
	// associations
	set[Relation] associations = {Relation::association(onzeClass(m, c), onzeClass(m, to), Field::field(from, typ, modifierForLoc(m, from))) |
		 <from, to> <- fieldAssociations(m) + OFGassocs, <from, c> <- fieldWithClass(m), <from, typ> <- fieldWithType(m)};
	
	// dependencies
	set[Relation] dependencies
			= {Relation::dependency(onzeClass(m, from), onzeClass(m, to)) | <meth1, meth2> <- m@methodInvocation, <from, meth1> <- m@containment, <to, meth2> <- m@containment, isClass(from), isClass(to), from != to}
			- {Relation::dependency(from, to) | Relation::association(from, to, _) <- associations}
			- {Relation::dependency(onzeClass(m, from), onzeClass(m, to)) | <from, to> <- m@extends};
	
	// dependencies from OFG
	rel[loc,loc] OFGdepRel = {<var, ref> | <var, ref> <- OFG::calc(true) + OFG::calc(false), isVariable(var), ref <- m@declarations<name>, ref != |id:///|};
	rel[loc,loc] OFGdeps 
			= OFGdepRel
			- {<field3,bla3> | 	<field2, bla2> <- OFGdepRel, 
								<field3, bla3> <- OFGdepRel, 
								field2 == field3, <bla3, bla2> <- m@extends};
								
	// nutteloze comprehensions die nog handig kunnen zijn
	// {<meth, ref> | <metho, ref> <- OFG::calc(true) + OFG::calc(false), meth <- m@declarations<name>, isMethod(meth), metho == meth+"this", ref != |id:///|};
	// {<meth, ref> | <metho, ref> <- OFG::calc(true) + OFG::calc(false), meth <- m@declarations<name>, isMethod(meth), metho == meth+"return", ref != |id:///|};
	
	set[Relation] dependencies2
			= {Relation::dependency(onzeClass(m, from), onzeClass(m, to)) | <var, to> <- OFGdeps, <var, from> <- varWithClass(m)}
			- {Relation::dependency(from, to) | Relation::association(from, to, _) <- associations};
	
	// dependency (can not be an association, dependency is weaker) like class A {void f(B b){b.g()}}
	set[Relation] dependencies1 = {Relation::dependency(from, to) |
		 from <- onzeClasses(m), meth <- from.methods, <typ, _> <- meth.parameters, to <- getSystemClass(m, typ)}
		 - {Relation::dependency(from, to) | Relation::association(from, to, _) <- associations};
		 
	set[Relation] generalizations = {Relation::generalization(onzeClass(m, relat.from), onzeClass(m, relat.to)) | relat <- m@extends};
	set[Relation] realizations = {Relation::realization(onzeClass(m, relat.from), onzeClass(m, relat.to)) | relat <- m@implements};
	set[Relation] inners = {Relation::inner(onzeClass(m, from), onzeClass(m, to)) | 
							<from, to> <- {<inn, outer> | <outer, inn> <- m@containment, isClass(inn), isClass(outer)}};
	
	return associations + dependencies + generalizations + realizations + inners;
};

// Helper functies
public rel[loc, TypeSymbol] fieldWithType(M3 m) =
		 {<field, typ> | <field, typ> <- m@types, isField(field)};

public rel[loc, TypeSymbol] fieldWithTypePerClass(M3 m, loc c) =
		 {<field, typ> | <field, typ> <- m@types, isField(field), field <- fields(m,c)};
 
public rel[loc, loc] fieldWithClass(M3 m) =
		{<field, class> | <class, field> <- m@containment, isField(field)};
		
public rel[loc, loc] varWithClass(M3 m) =
		{<var, class> | <var, class> <- m@typeDependency, isVariable(var), isClass(class), class <- m@declarations<name>};

public set[Modifier] modifierForLoc(M3 m, loc c) =
		{modi | <c,modi> <- m@modifiers};

public rel[loc, loc] fieldAssociations(M3 m) =
		 {<field, class> | <field, class> <- m@typeDependency, isField(field), isClass(class), class <- m@declarations<name>};

public rel[loc, loc] fieldDependencies(M3 m) =
		{<var, class> | <var, class> <- m@typeDependency, isVariable(var), isClass(class), class <- m@declarations<name>} +
		{<param, class> | <param, class> <- m@typeDependency, isParameter(param), isClass(class), class <- m@declarations<name>};

public str getName(M3 m, loc l) = getOneFrom({name | <name, l> <- m@names});

public TypeSymbol getClassType(M3 m, loc c) = getOneFrom({typ | <c, typ> <- m@types, isClass(c)});

public list[TypeSymbol] getTypeParams(M3 m, loc meth) = {
		if (meth.scheme == "java+constructor") {
			return [];
		}
		if (meth.scheme == "java+method") {
			return getOneFrom({typ.typeParameters | <meth, typ> <- m@types, isMethod(meth)});
		}
};

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
	
