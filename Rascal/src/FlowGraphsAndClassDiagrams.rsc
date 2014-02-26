module FlowGraphsAndClassDiagrams
 
import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;
import List;
import Relation;
import lang::java::m3::Core;
 
import IO;
import vis::Figure; 
import vis::Render;
 
alias OFG = rel[loc from, loc to];

//rel[loc,loc] gforward = { <cl + "this", cl> | newAssign(x, cl, _, _) <- p.statemens };
//rel[loc,loc] gbackward = {<y, cast> | assign(x, cast, y) <- p.statemens} + {<meth + "return", cast> | call(x, cast, _, meth, _) <- p.statemens}
//rel[loc,loc] k = {};

//forward propagation: {<field, bla> | <field, bla> <- prop(buildGraph(p), { <cl + "this", cl> | newAssign(x, cl, _, _) <- p.statemens }, {}, true), isField(field)}
//backward propagation: {<field, bla> | <field, bla> <- prop(buildGraph(p), {<y, cast> | assign(x, cast, y) <- p.statemens} + {<meth + "return", cast> | call(x, cast, _, meth, _) <- p.statemens}, {}, false), isField(field)}

OFG buildGraph(Program p) 
  = { <as[i], fps[i]> | newAssign(x, cl, c, as) <- p.statemens, constructor(c, fps) <- p.decls, i <- index(as) }
  + { <cl + "this", x> | newAssign(x, cl, _, _) <- p.statemens }
  + {<y, x> | assign(x, _, y) <- p.statemens}
  + {<meth + "return", x> | call(x, _, _, meth, _) <- p.statemens}
  + {<params[i], fparams[i]> | call(_, _, _, meth, params) <- p.statemens, method(meth, fparams) <- p.decls, i <- index(params)}
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
 
public void drawDiagram(M3 m) {
  classFigures = [box(text("<cl.path[1..]>"), id("<cl>")) | cl <- classes(m)]; 
  edges = [edge("<to>", "<from>") | <from,to> <- m@extends ];  
  
  render(graph(classFigures, edges, hint("layered"), std(gap(10)), std(font("Bitstream Vera Sans")), std(fontSize(8))));
}
 
public str dotDiagram(M3 m) {
  return "digraph classes {
         '  fontname = \"Bitstream Vera Sans\"
         '  fontsize = 8
         '  node [ fontname = \"Bitstream Vera Sans\" fontsize = 8 shape = \"record\" ]
         '  edge [ fontname = \"Bitstream Vera Sans\" fontsize = 8 ]
         '
         '  <for (cl <- classes(m)) { /* a for loop in a string template, just like PHP */>
         ' \"N<cl>\" [label=\"{<cl.path[1..] /* a Rascal expression between < > brackets is spliced into the string */>||}\"]
         '  <} /* this is the end of the for loop */>
         '
         '  <for (<from, to> <- m@extends) {>
         '  \"N<to>\" -\> \"N<from>\" [arrowhead=\"empty\"]<}>
         '}";
}
 
public void showDot(M3 m) = showDot(m, |home:///<m.id.authority>.dot|);
 
public void showDot(M3 m, loc out) {
  writeFile(out, dotDiagram(m));
}
