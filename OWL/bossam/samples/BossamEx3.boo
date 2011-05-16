prefix rdf = http://www.w3.org/1999/02/22-rdf-syntax-ns#;
prefix owl = http://www.w3.org/2002/07/owl#;
prefix xsd = http://www.w3.org/2001/XMLSchema#;
prefix rdfs = http://www.w3.org/2000/01/rdf-schema#;
prefix first = http://www.w3.org/2002/03owlt/FunctionalProperty/premises001#;
namespace is http://www.w3.org/2002/03owlt/FunctionalProperty/premises001#;
rulebase FunctionalProperty
{
	rule FuncProp is if (owl:FunctionalProperty(?p) and ?p(?x,?y) and ?p(?x,?z)) and [?y != ?z]
			 then owl:sameAs(?y,?z);
}