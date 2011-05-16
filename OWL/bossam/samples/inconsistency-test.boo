prefix bossam = http://etri.re.kr/2003/Bossam#;
namespace is http://etri.re.kr/Bossam#;
rulebase QueryProcessing1
{
	rule DisjointRule1 is if disjoint(?x,?y) and [?x != ?y] and ?x(?z) then neg ?y(?z);
	rule DisjointRule2 is if disjoint(?x,?y) and [?x != ?y] and neg ?x(?z) then ?y(?z);
	rule DisjointRule3 is if disjoint(?x,?y) and [?x != ?y] and ?x(?z) and ?y(?z) then bossam:Inconsistent;
	fact Fact1 is disjoint(Man,Woman);
	fact Fact2 is Man(John);
	fact Fact3 is Woman(John);
}
