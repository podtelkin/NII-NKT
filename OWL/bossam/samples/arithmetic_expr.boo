prefix xsd = http://www.w3.org/2001/XMLSchema#;
prefix rdfs = http://www.w3.org/2000/01/rdf-schema#;
namespace is http://etri.re.kr/2003/10/Bossam#;
/**
 * A bossam sample for writing arithmetic expressions.
 * @author zebehn(minsu@etri.re.kr)
 * @since 2005.07.10.
 */
rulebase ArithmeticExpressions
{
	class Rectangle;
	property width for Rectangle is xsd:integer;
	property height for Rectangle is xsd:integer;
	individual R is Rectangle and width = 10, height = 20;
	individual S is Rectangle and width = 20, height = 30;

	rule r is if Rectangle(?r) and width(?r,?w) and height(?r,?h) and [?w*?h <= 200] then SmallRectangle(?r,[?w*?h]);
}
