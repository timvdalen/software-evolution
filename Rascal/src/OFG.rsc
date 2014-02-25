module OFG

import lang::ofg::ast::FlowLanguage;

/** an object flow graph. */
data OFG = graph(set[loc] nodes, rel[loc, loc] edges);

/** Creates an OFG from a Program */
public OFG fromProgram(Program program) = {
	stmns = program.statemens;
	decls = program.decls;
		
	// building the edges
	set[loc] edges = 
		// return value of the constructor (x = cons(...))
		{<class + "this", x> | newAssign(x, class, _, _) <- stmns}
		// filling in the parameters of the constructor (... = cons(a, b, c))
		+ {<params[i], fparams[i]> | newAssign(_, _, ctor, params) <- stmns,
			 constructor(ctor, fparams) <- decls, i <- index(params)}
		// simple assign statement (x = y)
		+ {<y, x> | assign(x, _, y) <- stmns}
		// return value of a function (x = y.getTest(...))
		+ {<meth + "return", x> | call(x, _, _, meth, _) <- stmns}
		// filling in the parameters
		+ {<params[i], fparams[i]> | call(_, _, _, meth, params) <- stmns,
			method(meth, fparams) <- decls, i <- index(params)}
		// calling the object
		+ {<y, meth + "this"> | call(_, _, y, meth, _) <- stmns};
	
	// getting the nodes
	set[loc] nodes = {a | <a, _> <- edges} + {b | <_, b> <- edges};
		
	return OFG::graph(nodes, edges);
};
