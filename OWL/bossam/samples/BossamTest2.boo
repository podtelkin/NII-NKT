prefix xsd = http://www.w3.org/2001/XMLSchema#;
prefix rdfs = http://www.w3.org/2000/01/rdf-schema#;
namespace is http://etri.re.kr/2003/10/Bossam#;
/**
 * A bossam test case to test reasoning over object-oriented knowledge.  
 * @author zebehn(minsu@etri.re.kr)
 * @since 2003.10.24.
 */
rulebase BossamTest1
{
	class Human;
	property age for Human is xsd:positiveInteger;
	property father for Human is Human;
	individual John is Human and age = 30, father = Sam;
	individual Sam is Human and age = 15, father = Bob;
	rule Rule1 is if father(?x,?y) and father(?y,?z) then GrandFather(?x,?z);
}
