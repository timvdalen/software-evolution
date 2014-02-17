module Test

import IO;
import lang::ofg::ast::FlowLanguage;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

// Gets the classes from m3
set[loc] classes(M3 m3) = {c | <c, _> <- m3@containment, c.scheme == "java+class"};

// Gets the name of a location
str loc2name(loc l) = {
	if (/^\/<x:.*>/ := l.path) x;
	else "";
};
