prefix rdf = http://www.w3.org/1999/02/22-rdf-syntax-ns#;
prefix owl = http://www.w3.org/2002/07/owl#;
prefix xsd = http://www.w3.org/2001/XMLSchema#;
prefix rdfs = http://www.w3.org/2000/01/rdf-schema#;
prefix first = http://www.w3.org/2002/03owlt/SymmetricProperty/premises001#;
namespace is http://etri.re.kr/Test#;
rulebase CollectionReasoning
{
	fact Fact1 is rdfs:Class(rdf:List);
	fact Fact2 is rdf:Property(rdf:first);
	fact Fact3 is rdfs:domain(rdf:first,rdf:List);
	fact Fact4 is rdfs:range(rdf:first,rdfs:Resource);
	fact Fact5 is rdf:Property(rdf:rest);
	fact Fact6 is rdfs:domain(rdf:rest,rdf:List);
	fact Fact7 is rdfs:range(rdf:rest,rdf:List);
	fact Fact8 is rdf:List(rdf:nil);
	
	rule RangeRule1 is if rdfs:range(?p,?r) and ?p(?x,?y) then ?r(?y);
	rule DomainRule1 is if rdfs:domain(?p,?d) and ?p(?x,?y) then ?d(?x);
	
	rule Collection1 is if rdf:first(?list,?i) then member(?i,?list);
	rule Collection2 is if rdf:rest(?list,?rest) and [?list != ?rest] and first(?rest,?i) then member(?i,?list);
	rule Collection3 is if owl:oneOf(?c,?l) and member(?i,?l) then ?c(?i);
}
