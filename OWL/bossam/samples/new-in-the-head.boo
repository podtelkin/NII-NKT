namespace is http://etri.re.kr/Bossam#;
rulebase NewInTheHead
{
	fact Fact1 is isBlue(sky);

	rule Rule1 is if isBlue(?x) then java://java.lang/String#Class(?y) and great(?y);
}
