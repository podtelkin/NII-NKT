prefix xsd = http://www.w3.org/2001/XMLSchema#;
namespace is http://etri.re.kr/2003/10/bossam-ex1#;
rulebase Example1
{
	fact Fact1 is hasFather(John,Sam);
	fact Fact2 is hasFather(Sam,Bob);
	fact Fact3 is hasFather(Jack,Bob);
	rule GrandFather is if hasFather(?x,?y) and hasFather(?y,?z) then hasGrandFather(?x,?z);
}


