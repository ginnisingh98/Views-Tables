--------------------------------------------------------
--  DDL for Package Body PAY_US_SQWL_UDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_SQWL_UDF" as
/* $Header: pyussqut.pkb 120.0.12010000.5 2010/04/12 13:17:55 emunisek ship $ */
/*  +======================================================================+
REM |                Copyright (c) 1997 Oracle Corporation                 |
REM |                   Redwood Shores, California, USA                    |
REM |                        All rights reserved.                          |
REM +======================================================================+
REM SQL Script File Name : pyussqut.pkb
REM Description          : Package and procedure to build sql for payroll
REM                        processes.
REM Package Name         : pay_us_sqwl_udf
REM Purpose              : Using the transfer_date and A_EMP_PER_HIRE_DATE,
REM                        this function will determine if the hire date is
REM                        within the quarter defined by the transfer_date.
REM Arguments            : 1. A_EMP_PER_HIRE_DATE,
REM                        2. transfer_date.
REM Notes                : The following value is returned, qtr_hire_flag.
REM                        This flag will contain the value 'Y' if the hire
REM                        date is within the quarter and a value of 'N' if
REM                        the hire date is outside the quarter.
REM
REM Change List:
REM ------------
REM
REM Name         Date       Version Bug     Text
REM ------------ ---------- ------- ------- ------------------------------
REM M Doody      16-FEB-2001 115.0          Initial Version
REM
REM tmehra       17-SEP-2001 115.1          Added 'get_gre_wage_plan_code'
REM                                         function.
REM tmehra       15-OCT-2001 115.2          Added 'get_asg_wage_plan_code'
REM                                         function.
REM tmehra       06-DEC-2001 115.3          Made GSCC compliant
REM tmehra       07-MAY-2003 115.4          Added new validation for
REM                                         california sqwl as a new
REM                                         new segment has been introduced
REM                                         for the info type.
REM tmehra       22-MAY-2003 115.5          Added validation for duplicate
REM                                         Wage Plan entered for the Same
REM                                         GRE and for the same state.
REM                                         Also added the check to trigger
REM                                         this validation only for the
REM                                         PAY_US_STATE_WAGE_PLAN_INFO
REM                                         context.
REM tmehra       28-MAY-2003 115.6 2971577  Fixed the Message Token -
REM                                         changed 'atleast' to 'at least'
REM tmehra       26-AUG-2003 115.7 2219097  Added two new functions for the
REM                                         US W2 enhancements for Govt
REM                                         employer.
REM                                           - get_employment_code
REM                                           - chk_govt_employer
REM tmehra       12-NOV-2003 115.8 3189039  Modified the chk_for_default_wp
REM                                         to execute only for California.
REM tmehra       15-NOV-2003 115.9 2219097  Added a new functions for the
REM                                         US W2 enhancements for Govt
REM                                         employer.
REM                                           - get_archived_emp_code
REM emunisek     05-Mar-2010 115.10 9356178 Added get_out_of_state_code
REM                                         function
REM emunisek     30-Mar-2010 115.11 9356178 Modified the parameter type of
REM                                         p_out_of_state_taxable parameter
REM                                         in function get_out_of_state_code
REM                                         Modified to fetch the balances
REM                                         based on virtual date
REM emunisek     30-Mar-2010 115.12 9356178 Made file GSCC Compliant
REM emunisek     12-Apr-2010 115.13 9561700 Made changes to use the maximum
REM                                         effective date of Assignment's
REM                                         payroll actions in Balance Call
REM                                         if the assignment ends in between
REM                                         the Quarter.
REM ========================================================================

CREATE OR REPLACE PACKAGE BODY pay_us_sqwl_udf as
*/
     FUNCTION get_qtr_hire_flag
     (
      p_emp_per_hire_date in     DATE,
      p_transfer_date     in     DATE
     )
     RETURN  VARCHAR2 is
             qtr_hire_flag VARCHAR2(1) := 'N';

     BEGIN

         IF (
             p_emp_per_hire_date > (trunc(p_transfer_date, 'Q') - 1)
             AND
             p_emp_per_hire_date < (round(p_transfer_date, 'Q') )
            )
         THEN
             qtr_hire_flag := 'Y';
         END IF;

         RETURN (qtr_hire_flag);

    END get_qtr_hire_flag;


----
---- A new function to return Gre Level Wage Plan Code
---- For Single Wage Plan Code SQWL Format for 'CA'
----
   FUNCTION get_gre_wage_plan_code
     (
      p_tax_unit_id       in     number,
      p_transfer_state    in     varchar
     )
     RETURN  VARCHAR2 is

     l_wage_plan_code  VARCHAR2(1) := ' ';

     CURSOR  c_gre_wage_plan IS
     SELECT  hoi.org_information3 wage_plan
       FROM  hr_organization_information hoi
      WHERE  hoi.org_information_context = 'PAY_US_STATE_WAGE_PLAN_INFO'
        AND  hoi.organization_id    = p_tax_unit_id
        AND  hoi.org_information1   = p_transfer_state;

    BEGIN

     FOR i IN c_gre_wage_plan
     LOOP
      l_wage_plan_code := i.wage_plan;
     END LOOP;

     RETURN l_wage_plan_code;

    END get_gre_wage_plan_code;

----
---- A new function to return Asg Level Wage Plan Code
---- For Single Wage Plan Code SQWL Format for 'CA'
----
   FUNCTION get_asg_wage_plan_code
     (
      p_assignment_id     in     number,
      p_transfer_state    in     varchar
     )
     RETURN  VARCHAR2 is

     l_wage_plan_code  VARCHAR2(1) := ' ';

     CURSOR c_asg_wage_plan IS
     SELECT DISTINCT aei_information3 wage_plan
       FROM per_assignment_extra_info paei
      WHERE paei.assignment_id       = p_assignment_id
        AND paei.aei_information1    = p_transfer_state
        AND paei.information_type    = 'PAY_US_ASG_STATE_WAGE_PLAN_CD';

    BEGIN

     FOR i IN c_asg_wage_plan
     LOOP
      l_wage_plan_code := i.wage_plan;
     END LOOP;

     RETURN l_wage_plan_code;

    END get_asg_wage_plan_code;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_for_default_wp > ----------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Verify that only one wage plan is designated as default and
--   that at least one wage plan is designated as default
--   Added for US Payroll specific situations.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   organization_id, information_context, org_information1, org_information2
--   org_information3, org_information4
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Access Status:
--   Internal Table Handler Use Only.
-- ----------------------------------------------------------------------------
PROCEDURE chk_for_default_wp     ( p_organization_id     number,
                                   p_org_information_context varchar2,
                                   p_org_information1    varchar2
                                   ) IS

  --
  l_proc  varchar2(100) := 'pay_us_sqwl_udf.chk_for_default_wp';

  l_count number        := 0;
  --
  CURSOR c1 (p_organization_id     number,
             p_information_context varchar2,
             p_org_information1    varchar2
            )IS
  SELECT count(*) ct
  FROM   hr_organization_information
  WHERE  organization_id          = p_organization_id
    AND  org_information_context  = p_org_information_context
    AND  org_information1         = p_org_information1
    AND  org_information4         = 'Y';
  --
CURSOR c2(p_organization_id     number) IS
SELECT count(*) ct
  FROM (select distinct
              a.organization_id,
              a.org_information1,
              a.org_information3
        FROM  hr_organization_information a
       WHERE  org_information_context  = 'PAY_US_STATE_WAGE_PLAN_INFO') b
 WHERE b.organization_id = p_organization_id
   AND 1 < (   SELECT count(*)
                        FROM  hr_organization_information orgi
                       WHERE  organization_id          = p_organization_id
                         AND  org_information_context  = 'PAY_US_STATE_WAGE_PLAN_INFO'
                         AND  org_information1         = b.org_information1
                         AND  org_information3         = b.org_information3);
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --

  IF p_org_information_context = 'PAY_US_STATE_WAGE_PLAN_INFO'
     AND p_org_information1 = 'CA'  THEN

        l_count := 0;

        FOR c1_rec IN c1 (p_organization_id,
                          p_org_information_context,
                          p_org_information1) LOOP

           l_count := c1_rec.ct;


        END LOOP;

          hr_utility.set_location(l_proc, 20);


           --
           -- raise error if the count > 1 or count = 0
           --

        IF l_count <> 1 THEN

           hr_utility.set_message(801, 'PAY_7024_USERTAB_BAD_ROW_VALUE');
           hr_utility.set_message_token('FORMAT',' with at least 1 and only 1 marked as default');

           hr_utility.raise_error;

        END IF;


        l_count := 0;

        FOR c2_rec IN c2 (p_organization_id) LOOP

           l_count := c2_rec.ct;


        END LOOP;

          hr_utility.set_location(l_proc, 20);


           --
           -- raise error if the count > 1 or count = 0
           --

        IF l_count > 0 THEN

           hr_utility.set_message(801, 'PAY_7024_USERTAB_BAD_ROW_VALUE');
           hr_utility.set_message_token('FORMAT',' with unique tax type and state code');

           hr_utility.raise_error;

        END IF;


  END IF;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
END chk_for_default_wp;
--

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_govt_employer > ----------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Verify if the employee/employer is a US government employee/employer
--   Added for US Payroll W2 specific situations.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   tax_unit_id, assignment_action_id, assignment_id
--
--
-- Post Success:
--   Returns Yes/No
--
--
-- Access Status:
--   Internal Table Handler Use Only.
-- ----------------------------------------------------------------------------
FUNCTION chk_govt_employer       ( p_tax_unit_id           number DEFAULT NULL,
                                   p_assignment_action_id  number DEFAULT NULL
                                 ) RETURN BOOLEAN IS

  --
  l_proc        varchar2(100) := 'pay_us_sqwl_udf.chk_govt_employer';
  l_tax_unit_id number;
  l_yes_no      boolean := FALSE;
  --
  CURSOR c_get_tax_unit_id IS
  SELECT tax_unit_id
  FROM   pay_assignment_actions
  WHERE  assignment_action_id = p_assignment_action_id;


  CURSOR c_chk_govt_employer IS
  SELECT target.ORG_INFORMATION8 yes_no
    FROM hr_organization_information           target
   WHERE target.organization_id                = l_tax_unit_id
     AND target.org_information_context        = 'Federal Tax Rules';

  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --

  IF p_tax_unit_id IS NOT NULL THEN
     l_tax_unit_id := p_tax_unit_id;
  ELSE

     FOR c_rec IN c_get_tax_unit_id
     LOOP
         l_tax_unit_id := c_rec.tax_unit_id;
     END LOOP;
  END IF;


  FOR c_rec IN c_chk_govt_employer
  LOOP
     IF c_rec.yes_no = 'Y' THEN
       l_yes_no := TRUE;
     ELSE
       l_yes_no := FALSE;
     END IF;
  END LOOP;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --

  RETURN l_yes_no;

END chk_govt_employer;

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_employment_code > ----------------------------|
-- ----------------------------------------------------------------------------
-- Description:
--   Returns the employment code 'Q' or 'R' based on medicare and SS withheld.
--   Added for US Payroll W2 specific situations.
--
-- Pre Conditions:
--
--
-- In Parameters:
--   Medicare Wages, SS wages
--
--
-- Post Success:
--   Returns 'Q' or 'R'
--
--
-- ----------------------------------------------------------------------------
FUNCTION get_employment_code    ( p_medicare_wh           number DEFAULT NULL,
                                  p_ss_wh                 number DEFAULT NULL
                                ) RETURN varchar2 IS

  --
  l_proc        varchar2(100) := 'pay_us_sqwl_udf.get_employement_code';
  l_tax_unit_id number;
  l_code        varchar2(1);
  --
  --

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --

  IF p_ss_wh = 0 and p_medicare_wh > 0 THEN
     l_code := 'Q';
   ELSE
     l_code := 'R';
  END IF;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --

  RETURN l_code;

END get_employment_code;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_archived_emp_code >---------------------------
-- ----------------------------------------------------------------------------
-- Description:
--   Returns the archived employment code 'Q' or 'R' for the passed assignment
--   action_id.
--   Added for US Payroll W2 specific situations.
--
-- Pre Conditions:
--   If no archived value is found, default value of 'R' is returned. This is
--   done to support the employees whose data was archived before these
--   changes.
--
--
-- In Parameters:
--   p_assignment_action_id
--
--
-- Post Success:
--   Returns 'Q' or 'R'
--
--
-- ----------------------------------------------------------------------------
FUNCTION get_archived_emp_code  ( p_assignment_action_id  number DEFAULT NULL
                                ) RETURN varchar2 IS

  --
  l_proc        varchar2(100) := 'pay_us_sqwl_udf.get_archived_emp_code';
  l_code        varchar2(1);
  l_ue_id       NUMBER;
  --
  --
  CURSOR c_get_user_entity_id IS
  SELECT user_entity_id
    FROM ff_user_entities
   WHERE user_entity_name  = 'A_ASG_GRE_EMPLOYMENT_TYPE_CODE';


  CURSOR c_get_archived_emp_code (p_user_entity_id NUMBER) IS
  SELECT arch.value
    FROM ff_archive_items arch
   WHERE arch.user_entity_id    = p_user_entity_id
     AND arch.context1          = p_assignment_action_id;

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --


  -- Get the user entity id for A_ASG_GRE_EMPLOYMENT_TYPE_CODE

  FOR c_rec IN c_get_user_entity_id
  LOOP

    l_ue_id := c_rec.user_entity_id;

  END LOOP;


  -- Get the archived emp code for the passed assignment_action

  l_code := 'R';

  FOR c_rec IN c_get_archived_emp_code(l_ue_id)
  LOOP

    l_code := c_rec.value;

  END LOOP;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --

  RETURN l_code;

END get_archived_emp_code;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_out_of_state_code >---------------------------
-- ----------------------------------------------------------------------------

/*Added for Bug#9356178*/
FUNCTION get_out_of_state_code   ( p_assignment_action_id number,
                                   p_assignment_id number,
                                   p_tax_unit_id   number,
                                   p_reporting_date date,
				   p_out_of_state_taxable IN OUT nocopy number
                                 ) RETURN varchar2 IS

CURSOR get_person_id IS
 select distinct person_id
   from per_all_assignments_f
  where assignment_id = p_assignment_id;

/* Added for Bug#9561700*/
/*Since we are using the Date Based approach to fetch the Balances
of the assignment, we need to ensure that on the Date we pass for the
assignment, the Assignment record is present.Incase, the employee
is terminated, we need to pass the last effective date applicable to the
assignment to fetch the balances.This we do by referring to the pay_payroll_actions
table to find the maximum effective_date of this person in this Quarter.*/

CURSOR get_effective_date (p_quarter_start_date DATE,
                           p_quarter_end_date DATE) IS
select max(ppa.effective_date)
  from per_all_assignments_f   asg,
       pay_assignment_actions  paa,
       pay_payroll_actions     ppa
 where ppa.effective_date between p_quarter_start_date
                              and p_quarter_end_date
   and ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
   and paa.payroll_action_id = ppa.payroll_action_id
   and paa.assignment_id = asg.assignment_id
   and paa.action_status <> 'S'
   and asg.effective_end_date   >= p_quarter_start_date
   and asg.effective_start_date <= p_quarter_end_date
   and asg.business_group_id = ppa.business_group_id
   and asg.assignment_type = 'E'
   and paa.tax_unit_id = p_tax_unit_id
   and asg.assignment_id = p_assignment_id;

/*End Bug#9561700*/

CURSOR get_emp_state_codes (p_person_id per_all_people_f.person_id%TYPE,
                            p_year_start_date DATE,
                            p_quarter_end_date DATE) IS
  select distinct pest.state_code,pus.state_abbrev
    from per_all_assignments_f paaf,
         hr_soft_coding_keyflex hsck,
         pay_us_emp_state_tax_rules_f pest,
         pay_us_states pus
   where paaf.person_id = p_person_id
     and paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
     and paaf.effective_end_date >=  p_year_start_date
     and paaf.effective_start_date <=  p_quarter_end_date
     and hsck.segment1=to_char(p_tax_unit_id)
     and pest.assignment_id = paaf.assignment_id
     and pest.business_group_id = paaf.business_group_id
     and pest.effective_end_date >=  p_year_start_date
     and pest.effective_start_date <=  p_quarter_end_date
     and pus.state_code=pest.state_code;

CURSOR get_missed_emp_state_codes (p_person_id per_all_people_f.person_id%TYPE,
                                   p_year_start_date DATE,
                                   p_quarter_end_date DATE) IS
  select distinct substr(peev.screen_entry_value,1,2),pus.state_abbrev
    from per_all_assignments_f paaf,
         hr_soft_coding_keyflex hsck,
         pay_element_entries_f pee,
         pay_element_entry_values_f peev,
         pay_input_values_f piv1,
         pay_input_values_f piv2,
         pay_balance_types pbt,
         pay_balance_feeds_f pbf,
         pay_element_links_f pel,
         pay_us_states pus
   where paaf.person_id=p_person_id
     and paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
     and paaf.effective_end_date >=  p_year_start_date
     and paaf.effective_start_date <=  p_quarter_end_date
     and hsck.segment1=to_char(p_tax_unit_id)
     and pee.assignment_id = paaf.assignment_id
     and pee.effective_end_date >=  p_year_start_date
     and pee.effective_start_date <=  p_quarter_end_date
     and pee.element_link_id = pel.element_link_id
     and pee.element_entry_id = peev.element_entry_id
     and paaf.business_group_id = pel.business_group_id
     and pel.effective_end_date >=  p_year_start_date
     and pel.effective_start_date <=  p_quarter_end_date
     and pel.element_type_id = piv1.element_type_id
     and piv1.name='Jurisdiction'
     and piv1.effective_end_date >=  p_year_start_date
     and piv1.effective_start_date <=  p_quarter_end_date
     and piv1.input_value_id = peev.input_value_id
     and pbt.balance_name ='SUI ER Taxable'
     and pbt.balance_type_id = pbf.balance_type_id
     and pbf.input_value_id = piv2.input_value_id
     and piv2.effective_end_date >= p_year_start_date
     and piv2.effective_start_date <=  p_quarter_end_date
     and piv2.element_type_id = pee.element_type_id
     and pus.state_code=substr(peev.screen_entry_value,1,2)

     minus

  select distinct pest.state_code,pus.state_abbrev
    from per_all_assignments_f paaf,
         hr_soft_coding_keyflex hsck,
         pay_us_emp_state_tax_rules_f pest,
         pay_us_states pus
   where paaf.person_id = p_person_id
     and paaf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
     and paaf.effective_end_date >=  p_year_start_date
     and paaf.effective_start_date <=  p_quarter_end_date
     and hsck.segment1=to_char(p_tax_unit_id)
     and pest.assignment_id = paaf.assignment_id
     and pest.business_group_id = paaf.business_group_id
     and pest.effective_end_date >=  p_year_start_date
     and pest.effective_start_date <=  p_quarter_end_date
     and pus.state_code=pest.state_code;

CURSOR get_defined_balance_id(p_dimension_name pay_balance_dimensions.dimension_name%TYPE) IS
  select pdb.defined_balance_id
    from pay_balance_types pbt,
         pay_balance_dimensions pbd,
         pay_defined_balances pdb
   where pbt.legislation_code = 'US'
     and pbt.balance_name = 'SUI ER Taxable'
     and pbd.legislation_code = 'US'
     and pbd.dimension_name = p_dimension_name
     and pdb.balance_type_id = pbt.balance_type_id
     and pdb.balance_dimension_id = pbd.balance_dimension_id;

l_person_id per_all_people_f.person_id%TYPE;
l_state_code pay_us_states.state_code%TYPE;
l_state_abbrev pay_us_states.state_abbrev%TYPE;
l_out_of_state_code pay_us_states.state_abbrev%TYPE;
l_defined_balance_id pay_defined_balances.defined_balance_id%TYPE;
l_year_start_date DATE;
l_quarter_start_date DATE;
l_quarter_end_date DATE;
l_effective_end_date DATE;
l_effective_date DATE;
l_reporting_date DATE;
l_total_state_taxable NUMBER;
l_total_out_of_state_taxable NUMBER;
l_out_of_state_taxable NUMBER;
l_state_earnings NUMBER;
l_count NUMBER;
fl_jurisdiction_code varchar2(11);

BEGIN

 hr_utility.trace('Entering get_out_of_state_code');
 hr_utility.trace('Parameters Passed are');
 hr_utility.trace('p_assignment_id'||p_assignment_id);
 hr_utility.trace('p_tax_unit_id'||p_tax_unit_id);
 hr_utility.trace('p_assignment_action_id'||p_assignment_action_id);
 hr_utility.trace('p_reporting_date'||to_char(p_reporting_date));

 l_year_start_date := trunc(p_reporting_date,'YEAR');
 l_quarter_start_date := add_months(last_day(p_reporting_date),-3)+1;
 l_quarter_end_date := last_day(p_reporting_date);

 fl_jurisdiction_code := '10-000-0000';

 OPEN get_person_id;

 FETCH get_person_id INTO l_person_id;

 CLOSE get_person_id;

/* Added for Bug#9561700*/
/* First find out if the Assignment record is ending in between the Quarter.If
it is not, then call the balance procedure with Quarter End Date.If the Assignment
record ends in between the Quarter, we need to use find the maximum effective
date for the assignment from payroll actions and use it in balance calls.*/

 SELECT least(max(effective_end_date),p_reporting_date)
 INTO   l_effective_end_date
 FROM   per_all_assignments_f
 WHERE  assignment_id = p_assignment_id
 AND    assignment_type = 'E'
 AND    effective_end_date >= l_quarter_start_date ;

 IF l_effective_end_date < p_reporting_date THEN

   OPEN get_effective_date(l_quarter_start_date,l_quarter_end_date);

   FETCH get_effective_date INTO l_reporting_date;

   CLOSE get_effective_date;

 hr_utility.trace('Modified l_reporting_date'||to_char(l_reporting_date));

 ELSE

 l_reporting_date := p_reporting_date;

 hr_utility.trace('Use original l_reporting_date'||to_char(l_reporting_date));

 END IF;

 /*End Bug#9561700*/

 /*Fetch the Total Taxable Wages of the Employee*/

 OPEN get_defined_balance_id('Person within Government Reporting Entity Year to Date');
 FETCH get_defined_balance_id INTO l_defined_balance_id;

 IF get_defined_balance_id%NOTFOUND THEN

    hr_utility.trace('Not able to find Defined Balance for combination of SUI ER Taxable and Person within Government Reporting Entity Year to Date');

   END IF;

 CLOSE get_defined_balance_id;

 l_total_state_taxable := 0;

 l_total_state_taxable := pay_balance_pkg.get_value( l_defined_balance_id,
                                                     p_assignment_id,
                                                     l_reporting_date);

 hr_utility.trace('Total SUI Taxable till this Quarter'||l_total_state_taxable);


 OPEN get_defined_balance_id('Person in JD within GRE Year to Date');
 FETCH get_defined_balance_id INTO l_defined_balance_id;

 IF get_defined_balance_id%NOTFOUND THEN

    hr_utility.trace('Not able to find Defined Balance for combination of SUI ER Taxable and Person in JD within GRE Year to Date');

   END IF;

 CLOSE get_defined_balance_id;

 pay_balance_pkg.set_context('JURISDICTION_CODE',fl_jurisdiction_code);

 l_total_out_of_state_taxable := 0;

 l_total_out_of_state_taxable := l_total_state_taxable -
                       pay_balance_pkg.get_value( l_defined_balance_id,
                                                  p_assignment_id,
                                                  l_reporting_date);

 hr_utility.trace('Total Out of State SUI Taxable till this Quarter'||l_total_out_of_state_taxable);

 hr_utility.trace('p_out_of_state_taxable passed into function'||p_out_of_state_taxable);

 p_out_of_state_taxable := l_total_out_of_state_taxable;

 hr_utility.trace('p_out_of_state_taxable passed out of function'||p_out_of_state_taxable);

 l_count := 0;

 l_out_of_state_taxable := 0;

 OPEN get_emp_state_codes(l_person_id,l_year_start_date,l_quarter_end_date);

 FETCH get_emp_state_codes INTO l_state_code,l_state_abbrev;

 WHILE get_emp_state_codes%FOUND

 LOOP

 hr_utility.trace('StateCode Fetched'||l_state_code);
 hr_utility.trace('State Fetched'||l_state_abbrev);

 IF l_state_abbrev <> 'FL'
 THEN

   l_state_earnings := 0;

   pay_balance_pkg.set_context('JURISDICTION_CODE',l_state_code||'-000-0000');

   l_state_earnings := pay_balance_pkg.get_value( l_defined_balance_id,
                                                  p_assignment_id,
                                                  l_reporting_date);

   l_out_of_state_taxable := l_out_of_state_taxable + l_state_earnings;

   hr_utility.trace('State Earnings YTD'||l_state_earnings);
   hr_utility.trace('l_out_of_state_taxable'||l_out_of_state_taxable);

    IF l_state_earnings > 0 THEN

     l_out_of_state_code := l_state_abbrev;
     l_count := l_count + 1;

     hr_utility.trace('Found State with YTD Taxable more than 0 and not Florida, Increase out of states count by 1');

    END IF;


 END IF;

 FETCH get_emp_state_codes INTO l_state_code,l_state_abbrev;

 END LOOP;

  hr_utility.trace('Number of States other than Florida'||l_count);
  hr_utility.trace('Out of State Taxable as of now'||l_out_of_state_taxable);
  hr_utility.trace('Actual Out of State Taxable'||p_out_of_state_taxable);

 IF l_out_of_state_taxable <> p_out_of_state_taxable THEN

  hr_utility.trace('Missed some of the Out of States.Get them Now');

    OPEN get_missed_emp_state_codes(l_person_id,l_year_start_date,l_quarter_end_date);

    FETCH get_missed_emp_state_codes INTO l_state_code,l_state_abbrev;

    WHILE get_missed_emp_state_codes%FOUND

    LOOP

    hr_utility.trace('StateCode Fetched'||l_state_code);
    hr_utility.trace('State Fetched'||l_state_abbrev);

    IF l_state_abbrev <> 'FL'
    THEN

      l_state_earnings := 0;

      pay_balance_pkg.set_context('JURISDICTION_CODE',l_state_code||'-000-0000');

      l_state_earnings := pay_balance_pkg.get_value( l_defined_balance_id,
                                                     p_assignment_id,
                                                     l_reporting_date);

      l_out_of_state_taxable := l_out_of_state_taxable + l_state_earnings;

      hr_utility.trace('State Earnings YTD'||l_state_earnings);
      hr_utility.trace('l_out_of_state_taxable'||l_out_of_state_taxable);

       IF l_state_earnings > 0 THEN

        l_out_of_state_code := l_state_abbrev;
        l_count := l_count + 1;

        hr_utility.trace('Found State with YTD Taxable more than 0 and not Florida, Increase out of states count by 1');

       END IF;


    END IF;

    FETCH get_missed_emp_state_codes INTO l_state_code,l_state_abbrev;

    END LOOP;

 END IF;


 IF l_count > 1 THEN

   l_out_of_state_code := 'MU';

 ELSIF l_count = 0 THEN

   l_out_of_state_code := 'XX';

 END IF;

 CLOSE get_emp_state_codes;

   hr_utility.trace('Out of State Code returned'||l_out_of_state_code);

RETURN l_out_of_state_code;

EXCEPTION

  when others then
    hr_utility.trace('Error ORA-'||TO_CHAR(SQLCODE));
    hr_utility.raise_error;

END get_out_of_state_code;

END pay_us_sqwl_udf;

/
