prefix rdf = http://www.w3.org/1999/02/22-rdf-syntax-ns#;
prefix owl = http://www.w3.org/2002/07/owl#;
prefix xsd = http://www.w3.org/2001/XMLSchema#;
prefix rdfs = http://www.w3.org/2000/01/rdf-schema#;
prefix bossam = http://www.etri.re.kr/2003/10/bossam#;
namespace is http://www.etri.re.kr/2003/10/bossam#;
rulebase BossamEx5
{
	fact f4 is intersectionOf(A,<B,C>);
	fact f5 is A(aa);
	fact f6 is neg E(bb);
	fact f7 is B(bb);
//	fact f8 is C(bb);
	
	rule R3 is if E(?x) then neg C(?x);
	rule R4 is if neg E(?x) then C(?x);
	rule R0 is if intersectionOf(?c,?l) and ?c(?i) and member(?l,?m) then ?m(?i);
	rule R6 is if intersectionOf(?c,?l) and [length(?l) = 2] and member(?l,?m) and member(?l,?m1) and ?m(?x) and ?m1(?x) then ?c(?x);
}