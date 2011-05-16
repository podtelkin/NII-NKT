prefix xsd = http://www.w3.org/2001/XMLSchema#;
prefix rdfs = http://www.w3.org/2000/01/rdf-schema#;
prefix func = http://www.etri.re.kr/2003/10/bossam-builtin#;
namespace is http://etri.re.kr/2003/10/Bossam#;
/**
 * A bossam sample for using date and time constants and related builtin functions.
 * @author zebehn(minsu@etri.re.kr)
 * @since 2005.07.10.
 */
rulebase TimeConstants
{
	class Person;
	property birthdate for Person is xsd:date;
	individual John is Person and birthdate = 1970-10-05;
	individual Sam is Person and birthdate = 1970-05-05;

	rule r1 is if birthdate(?x,?date1) and birthdate(?y,?date2) and [func:after(?date1,?date2) = true] then isYoungerThan(?x,?y);
	rule r2 is if birthdate(?x,?date1) and birthdate(?y,?date2) and [func:before(?date1,?date2) = true] then isOlderThan(?x,?y);
	
	fact f01 is beginsAt(MeetingA,2005-10-04T12:00:00);
	fact f02 is endsAt(MeetingA,2005-10-04T15:00:00);
	fact f03 is beginsAt(MeetingB,2005-10-04T14:00:00);
	fact f04 is endsAt(MeetingB,2005-10-04T17:00:00);
	fact f05 is beginsAt(MeetingC,2005-10-04T16:00:00);
	fact f06 is endsAt(MeetingC,2005-10-04T17:00:00);

	rule CompatibleMeetings is
		if endsAt(?m1,?t1) and beginsAt(?m2,?t2) and [func:after(?t2,?t1) = true]
		then Compatible(?m1,?m2);
}
