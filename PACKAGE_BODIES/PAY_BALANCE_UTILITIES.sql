--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_UTILITIES" AS
 /* $Header: pyblutil.pkb 120.1 2005/10/05 03:16:56 schauhan noship $ */

  /* Name     : get_work_codes
   Purpose  : To get the work state code, work state name, work city code,
              work city name, work county code and work county name.

	      This procedure is a copy of the procedure in PAY_US_EMP_DT_TAX_VAL
	      which is a Rel 11 package for Date-tracked W4.  It is duplicated here
	      so that no dependancy on the patch for W4 is needed.  In the Rel 11
	      version of this form the above package is used.
									*/

procedure  get_work_codes (p_assignment_id         in number,
                           p_session_date          in date,
                           p_work_state_code       out nocopy varchar2,
                           p_work_county_code      out nocopy varchar2,
                           p_work_city_code        out nocopy varchar2,
                           p_work_state_name       out nocopy varchar2,
                           p_work_county_name      out nocopy varchar2,
                           p_work_city_name        out nocopy varchar2) is

/* Cursor to get the work state, county and city */
cursor csr_get_work is
       select pus.state_code,
              puc.county_code,
              puci.city_code,
              pus.state_name,
              puc.county_name,
              puci.city_name
       from   PER_ASSIGNMENTS_F   paf,
              HR_LOCATIONS        hrl,
              PAY_US_STATES       pus,
              PAY_US_COUNTIES     puc,
              PAY_US_CITY_NAMES   puci
       where  paf.assignment_id         = p_assignment_id
       and    p_session_date between paf.effective_start_date and
                                     paf.effective_end_date
       and    paf.location_id           = hrl.location_id
       and    pus.state_abbrev          = hrl.region_2
       and    puc.state_code            = pus.state_code
       and    puc.county_name           = hrl.region_1
       and    puci.state_code           = pus.state_code
       and    puci.county_code          = puc.county_code
       and    puci.city_name            = hrl.town_or_city;

begin
  hr_utility.set_location('hr_tools.get_work_codes',1);
  /* Get the work location details */
  open  csr_get_work;
  fetch csr_get_work into p_work_state_code,
                          p_work_county_code,
                          p_work_city_code,
                          p_work_state_name,
                          p_work_county_name,
                          p_work_city_name;
  if csr_get_work%NOTFOUND then
     p_work_state_code   := null;
     p_work_county_code  := null;
     p_work_city_code    := null;
     p_work_state_name   := null;
     p_work_county_name  := null;
     p_work_city_name    := null;
  end if;
  hr_utility.set_location('hr_tools.get_work_codes',3);
  close csr_get_work;
end get_work_codes;


FUNCTION get_current_asact_id (p_date IN DATE,
			p_assignment_id IN NUMBER,
                        p_tax_unit_id IN NUMBER,
			p_action_type IN OUT NOCOPY VARCHAR2,
			p_eff_date IN OUT NOCOPY DATE)RETURN NUMBER  IS

  /* Name     : get_current_asact_id
   Purpose  : To get the assignment_action_id given a date and assignment id.  The
			function finds the greatest assignment action id with an effective
			date on or before the date parameter.  If there are no actions in the
			same year, the function returns a 0 for the assignemnt_action_id.
    */
 CURSOR c_asact IS
   SELECT max(paa.assignment_action_id), ppa.action_type, ppa.effective_date
   FROM   pay_payroll_actions    ppa,
          pay_assignment_actions paa
   WHERE  paa.assignment_id = p_assignment_id
   AND    ppa.effective_date <= p_date
   AND    to_char(ppa.effective_date,'YYYY') = to_char(p_date,'YYYY')
   and    ppa.payroll_action_id = paa.payroll_action_id
   and    ppa.action_type in ('Q','R','V','I','B')
   and    paa.action_status = 'C'
   and   paa.tax_unit_id = p_tax_unit_id
   and   paa.action_sequence =
         ( SELECT max(paa2.action_sequence)
           FROM pay_assignment_actions paa2,
                pay_payroll_actions    ppa2
           WHERE paa2.assignment_id = paa.assignment_id
           AND   ppa2.effective_date <= p_date
           AND   to_char(ppa2.effective_date,'YYYY') = to_char(p_date,'YYYY')
           and   ppa2.payroll_action_id = paa2.payroll_action_id
           and   ppa2.action_type in ('Q','R','V','I','B')
           and   paa2.action_status = 'C'
           and   paa2.tax_unit_id = paa.tax_unit_id
         )
   group by action_type, effective_date;

 l_asact NUMBER;


BEGIN
	OPEN c_asact;
	FETCH c_asact INTO l_asact, p_action_type, p_eff_date;
	IF c_asact%NOTFOUND
	THEN
		l_asact:= 0;
	END IF;
	CLOSE c_asact;
	RETURN l_asact;

END;


end pay_balance_utilities;

/
