prefix xsd = http://www.w3.org/2001/XMLSchema#;
prefix rdfs = http://www.w3.org/2000/01/rdf-schema#;
namespace is http://etri.re.kr/2003/10/Bossam#;
rulebase Test1
{
	class Person;
	property age for Person is xsd:integer;
	property isFatherOf for Person is Person;
	property name for Person is xsd:string;
	individual Bob is Person and name="Bob";
	individual John is Person and isFatherOf=Bob;
	individual Sam is Person and isFatherOf=John;
	fact Follows is follows(isGrandFatherOf,isMan);
	rule Rule1 is if isFatherOf(?x,?y) and isFatherOf(?y,?z) then isGrandFatherOf(?x,?z);
	rule Rule2 is if ?x(?y,?z) and follows(?x,?a) then ?a(?y);
}
