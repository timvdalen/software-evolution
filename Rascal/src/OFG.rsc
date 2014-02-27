module OFG

import lang::ofg::ast::Java2OFG;
import lang::ofg::ast::FlowLanguage;
import List;
import Relation;

alias OFG = rel[loc from, loc to];

rel[loc,loc] genforward = { <class + "this", class> | newAssign(x, class, _, _) <- prog.statemens };
rel[loc,loc] genbackward
		= {<y, cast> | assign(x, cast, y) <- prog.statemens}
		+ {<meth + "return", cast> | call(x, cast, _, meth, _) <- prog.statemens};
rel[loc,loc] kill = {};

OFG buildGraph(Program p) 
	// return value of the constructor (x = cons(...))
  = { <class + "this", x> | newAssign(x, class, _, _) <- p.statemens }
	// filling in the parameters of the constructor (... = cons(a, b, c))
  + { <params[i], fparams[i]> | newAssign(x, cl, c, params) <- p.statemens, constructor(c, fparams) <- p.decls, i <- index(params) }
	// simple assign statement (x = y)
  + {<y, x> | assign(x, _, y) <- p.statemens}
	// return value of a function (x = y.getTest(...))
  + {<meth + "return", x> | call(x, _, _, meth, _) <- p.statemens}
	// filling in the parameters
  + {<params[i], fparams[i]> | call(_, _, _, meth, params) <- p.statemens, method(meth, fparams) <- p.decls, i <- index(params)}
	// calling the object
  + {<y, meth + "this"> | call(_, _, y, meth, _) <- p.statemens};
   
OFG prop(OFG g, rel[loc,loc] gen, rel[loc,loc] kill, bool back) {
  OFG IN = { };
  OFG OUT = gen + (IN - kill);
  gi = g<to,from>;
  set[loc] pred(loc n) = gi[n];
  set[loc] succ(loc n) = g[n];
  
  solve (IN, OUT) {
    IN = { <n,\o> | n <- carrier(g), p <- (back ? pred(n) : succ(n)), \o <- OUT[p] };
    OUT = gen + (IN - kill);
  }
  
  return OUT;
}

OFG calc(bool forward) {
	if(forward) {
		return {<field, bla> | <field, bla> <- prop(buildGraph(prog), genforward, kill, true)};
	} else {
		return {<field, bla> | <field, bla> <- prop(buildGraph(prog), genbackward, kill, false)};
	}
}
