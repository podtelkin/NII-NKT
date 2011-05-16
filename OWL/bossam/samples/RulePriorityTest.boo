namespace is http://etri.re.kr/Bossam#;
rulebase RulePriorityTest
{
	fact Fact1 is Man(John);
	fact Fact2 is Woman(Susan);
	rule Rule1(2) is if Man(?x) then Hey(?x);
	rule Rule2(3) is if Woman(?x) then Hi(?x);	
}
