prefix wine = http://www.w3.org/TR/2003/PR-owl-guide-20031209/wine#;
namespace is http://etri.re.kr/bossam/examples#;
rulebase Test1
{
  rule r is 
  if
    wine:locatedIn(?x,wine:NapaRegion)
    and wine:hasSugar(?x,wine:Dry)
  then
    answer(?x);
}