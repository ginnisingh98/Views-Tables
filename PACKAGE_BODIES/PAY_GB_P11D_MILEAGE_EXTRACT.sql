--------------------------------------------------------
--  DDL for Package Body PAY_GB_P11D_MILEAGE_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_P11D_MILEAGE_EXTRACT" as
/* $Header: pygbmxpl.pkb 115.2 2003/05/06 11:01:42 gbutler noship $
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2003 Oracle Corporation UK Ltd.,                *
   *                   Reading, England.                            *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

    Name        : pay_gb_p11d_mileage_extract

    Description : This package contains functions and procedures to
    		  create the extract file for P11d Mileage Claims

    Uses        :

    Used By     : P11d 2003 Mileage Claims Extract Process


    Change List :

    Version     Date     Author         Description
    -------     -----    --------       ----------------

     115.0      14/4/03  GBUTLER        Created
     115.2      06/5/03  GBUTLER        Altered detail record layout

*/

g_package_name  varchar2(27) := 'pay_gb_p11d_mileage_extract';

-- Declare global variables:
g_veh_rcd_id        NUMBER;
g_ext_rslt_id       NUMBER;
g_person_id         NUMBER;
g_bg_id             NUMBER;

---------------------------------------------------------------------------
--  Function:    GET_BUS_GROUP_ID
--  Description: This function gets business group_id
---------------------------------------------------------------------------
FUNCTION get_bus_group_id (p_asg_id IN NUMBER) RETURN NUMBER IS
   --
   CURSOR get_bus_group_id IS
      SELECT  business_group_id
      FROM    per_all_assignments_f
      WHERE   assignment_id = p_asg_id;
   --
   l_bus_group_id NUMBER;

BEGIN

   -- Get Business Group ID
   OPEN get_bus_group_id;
   FETCH get_bus_group_id INTO l_bus_group_id;
   CLOSE get_bus_group_id;
   --
   RETURN l_bus_group_id;
   --

END get_bus_group_id;

---------------------------------------------------------------------------
--  Function:    GET_PARAM_TAX_YEAR
--  Description: This function gets tax year parameter from UDT
---------------------------------------------------------------------------
FUNCTION get_param_tax_year (p_bus_grp_id IN NUMBER) return number is

l_tax_year number;

   --
BEGIN

   BEGIN
      hr_utility.set_location('get_param_tax_year',1);

      l_tax_year :=  hruserdt.get_table_value(p_bus_grp_id,
                                              'PAY GB P11D Mileage Extract',
                                              'Parameter Value',
                                              'Tax Year (YYYY)',
                                              ben_ext_person.g_effective_date );


   EXCEPTION

      WHEN others THEN
         -- tax year parameter not set or wrong format
         -- raise an error
         hr_utility.set_location('get_param_tax_year',2);
         hr_utility.trace('ERROR: Seeded value for tax year not found or data corrupt');
         raise;

   END;
   --
hr_utility.set_location('get_param_tax_year',3);

hr_utility.trace('Tax year: '||to_char(l_tax_year));
hr_utility.set_location('get_param_tax_year',99);

RETURN l_tax_year;

end get_param_tax_year;


---------------------------------------------------------------------------
--  Function:    GET_TAX_YEAR_START
--  Description: This function gets tax year start date based on the
--               extract end date or effective date of the concurrent
--               process if extract end date is null
---------------------------------------------------------------------------
FUNCTION get_tax_year_start (p_bus_grp_id IN NUMBER) return date is

l_tax_year_start date;

l_tax_year number;

l_cal_year_start date;
   --
BEGIN

hr_utility.set_location('get_tax_year_start',1);

l_tax_year := get_param_tax_year(p_bus_grp_id);

hr_utility.set_location('get_tax_year_start',2);

l_cal_year_start := fnd_date.displaydate_to_date('01-JAN-'||to_char(l_tax_year));

l_tax_year_start := fnd_date.displaydate_to_date('06-APR-'||to_char(l_cal_year_start - 365, 'YYYY'));

hr_utility.trace('Tax year start: '||to_char(l_tax_year_start,'DD-MON-YYYY'));
hr_utility.set_location('get_tax_year_start',99);

RETURN l_tax_year_start;

end get_tax_year_start;

---------------------------------------------------------------------------
--  Function:    GET_TAX_YEAR_END
--  Description: Overloaded function gets tax year end date based on the
--               extract end date or effective date of the concurrent
--               process if extract end date is null
---------------------------------------------------------------------------

FUNCTION get_tax_year_end (p_bus_grp_id IN NUMBER) return date is

l_tax_year_end date;

l_tax_year number;

l_cal_year_start date;
   --
BEGIN

hr_utility.set_location('get_tax_year_end',1);

l_tax_year := get_param_tax_year(p_bus_grp_id);
   --
hr_utility.set_location('get_tax_year_end',2);

l_cal_year_start := fnd_date.displaydate_to_date('01-JAN-'||to_char(l_tax_year));

l_tax_year_end := fnd_date.displaydate_to_date('05-APR-'||to_char(l_cal_year_start,'YYYY'));

hr_utility.trace('Tax year end: '||to_char(l_tax_year_end,'DD-MON-YYYY'));
hr_utility.set_location('get_tax_year_end',99);

RETURN l_tax_year_end;

end get_tax_year_end;


---------------------------------------------------------------------------
--  Function:    GET_PARAM_EXT_END_DATE
--  Description: This function gets value of extract end date parameter
---------------------------------------------------------------------------
FUNCTION get_param_ext_end_date(p_bus_group_id IN NUMBER) RETURN DATE IS
   --
   l_ext_end_date DATE;
   --
BEGIN

   BEGIN
      hr_utility.set_location('get_param_ext_end_date',1);

      l_ext_end_date := fnd_date.displaydate_to_date(hruserdt.get_table_value(p_bus_group_id,
                                                                              'PAY GB P11D Mileage Extract',
                                                                              'Parameter Value',
                                                                              'Extract End Date (DD-MON-YYYY)',
                                                                              ben_ext_person.g_effective_date ));


      l_ext_end_date := nvl(l_ext_end_date,get_tax_year_end(p_bus_group_id));

   EXCEPTION

      WHEN others THEN
         -- extract date parameter not set or wrong format
         -- default to end of fiscal year
         hr_utility.set_location('get_param_ext_end_date',2);

         l_ext_end_date := get_tax_year_end(p_bus_group_id);

   END;
   --
   hr_utility.set_location('get_param_ext_end_date',99);

   RETURN l_ext_end_date;

END get_param_ext_end_date;


---------------------------------------------------------------------------
--  Function:    GET_PARAM_PAYROLL_ID
--  Description: This function gets id of payroll name parameter
---------------------------------------------------------------------------
FUNCTION get_param_payroll_id(p_bus_group_id IN NUMBER) RETURN NUMBER IS
   --
   l_payroll_name pay_all_payrolls_f.payroll_name%TYPE;
   l_payroll_id   pay_all_payrolls_f.payroll_id%TYPE;
   --
   CURSOR get_payroll_id IS
   SELECT payroll_id
   FROM   pay_all_payrolls_f
   WHERE  payroll_name = l_payroll_name
   AND    nvl(business_group_id, p_bus_group_id) = p_bus_group_id
   AND    ben_ext_person.g_effective_Date BETWEEN effective_start_date AND effective_end_Date;
   --
BEGIN

   -- Get user Table Value

   BEGIN

      -- Get Payroll Name Parameter Value
      l_payroll_name := hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Mileage Extract',
                                          'Parameter Value',
                                          'Payroll Name',
                                          ben_ext_person.g_effective_date );
      --
      -- Get Payroll_id
      OPEN  get_payroll_id;
      FETCH get_payroll_id INTO l_payroll_id;
      CLOSE get_payroll_id;
      --
   EXCEPTION

     WHEN others THEN
         l_payroll_name := NULL;
         l_payroll_id := NULL;
   END;
   --
   RETURN l_payroll_id;
   --
END get_param_payroll_id;

---------------------------------------------------------------------------
--  Function:    GET_PARAM_TAX_DIST
--  Description: This function gets value of Tax District Reference
--               parameter
---------------------------------------------------------------------------
FUNCTION get_param_tax_dist(p_bus_group_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_tax_dist hr_organization_information.org_information1%TYPE;
   --
BEGIN
   BEGIN
      -- Get Tax District Reference Parameter Value
      l_tax_dist := hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Mileage Extract',
                                          'Parameter Value',
                                          'Tax District Reference',
                                          ben_ext_person.g_effective_date );
      --
   EXCEPTION
      WHEN others THEN
         l_tax_dist  := NULL;
   END;
   --
   RETURN l_tax_dist;
   --
END get_param_tax_dist;

---------------------------------------------------------------------------
--  Function:    GET_PARAM_PERSON_ID
--  Description: This function gets person id based on employee number
--               parameter
---------------------------------------------------------------------------
FUNCTION get_param_person_id(p_bus_group_id IN NUMBER) RETURN NUMBER IS
   --
   l_employee_number per_all_people_f.employee_number%TYPE;
   l_person_id       per_all_people_f.person_id%TYPE;
   --
   CURSOR get_person_id IS
   SELECT person_id
   FROM   per_all_people_f
   WHERE  employee_number = l_employee_number
   AND    nvl(business_group_id, p_bus_group_id) = p_bus_group_id
   AND    ben_ext_person.g_effective_Date BETWEEN effective_start_date AND effective_end_Date;
   --
BEGIN
   BEGIN
      -- Get Employee Number Parameter Value
      l_employee_number := hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Mileage Extract',
                                          'Parameter Value',
                                          'Employee Number',
                                          ben_ext_person.g_effective_date );
      --
      -- Get Person Id
      OPEN  get_person_id;
      FETCH get_person_id INTO l_person_id;
      CLOSE get_person_id;
      --
   EXCEPTION
      WHEN others THEN
         l_employee_number := NULL;
         l_person_id := NULL;
   END;
   --
   RETURN l_person_id;
   --
END get_param_person_id;

---------------------------------------------------------------------------
--  Function:    GET_PARAM_CONSOLIDATION_SET_ID
--  Description: This function gets consolidation set id based on
--               consolidation set parameter
---------------------------------------------------------------------------
FUNCTION get_param_consolidation_set_id(p_bus_group_id IN NUMBER) RETURN NUMBER IS
   --
   l_consolidation_set    pay_consolidation_sets.consolidation_set_name%TYPE;
   l_consolidation_set_id pay_consolidation_sets.consolidation_set_id%TYPE;
   --
   CURSOR get_consolidation_set_id IS
   SELECT consolidation_set_id
   FROM   pay_consolidation_sets
   WHERE  consolidation_Set_name = l_consolidation_set
   AND    nvl(business_group_id, p_bus_group_id) = p_bus_group_id;
   --
BEGIN
   BEGIN
      -- Get Consolidation Set Parameter Value
      l_consolidation_set := hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Mileage Extract',
                                          'Parameter Value',
                                          'Consolidation Set',
                                          ben_ext_person.g_effective_date );
      --
      -- Get Consolidation Set Id
      OPEN  get_consolidation_set_id;
      FETCH get_consolidation_set_id INTO l_consolidation_set_id;
      CLOSE  get_consolidation_set_id;
      --
   EXCEPTION
      WHEN others THEN
         l_consolidation_set    := NULL;
         l_consolidation_set_id := NULL;
   END;
   --
   RETURN l_consolidation_set_id;
   --
END get_param_consolidation_set_id;


---------------------------------------------------------------------------
--  Function:    GET_PARAM_ASSIGNMENT_SET_ID
--  Description: This function gets assignment set id based on
--               assignment set parameter
---------------------------------------------------------------------------
FUNCTION get_param_assignment_set_id(p_bus_group_id IN NUMBER) RETURN NUMBER IS
   --
   l_assignment_set    hr_assignment_sets.assignment_set_name%TYPE;
   l_assignment_set_id hr_assignment_sets.assignment_set_id%TYPE;
   --
   CURSOR get_assignment_set_id IS
   SELECT assignment_set_id
   FROM   hr_assignment_sets
   WHERE  assignment_set_name = l_assignment_set
   AND    nvl(business_group_id, p_bus_group_id) = p_bus_group_id;
   --
BEGIN
   BEGIN
      -- Get Assignment Set Parameter Value
      l_assignment_set := hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Mileage Extract',
                                          'Parameter Value',
                                          'Assignment Set',
                                          ben_ext_person.g_effective_date );
      --
      -- Get Assignment Set Id
      OPEN  get_assignment_set_id;
      FETCH get_assignment_set_id INTO l_assignment_set_id;
      CLOSE  get_assignment_set_id;
      --
   EXCEPTION
      WHEN others THEN
         l_assignment_set    := NULL;
         l_assignment_set_id := NULL;
   END;
   --
   RETURN l_assignment_set_id;
   --
END get_param_assignment_set_id;



---------------------------------------------------------------------------
-- Function:    CHECK_ASG_INCLUSION
-- Description: This function checks whether given assignment satisfies
--              input criteria and mileage ASG_YTD > 0
---------------------------------------------------------------------------
FUNCTION check_asg_inclusion(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_bus_group_id    NUMBER;

   l_ext_end_Date    DATE;
   l_ext_payroll_id  NUMBER;
   l_ext_person_id   NUMBER;
   l_ext_tax_dist    VARCHAR2(150);
   l_ext_con_set_id  NUMBER;
   l_ext_asg_set_id  NUMBER;
   --
   l_asg_set_include VARCHAR2(1) := 'N';
   --
   l_asg_include VARCHAR2(1) := 'N';
   --
   l_mileage_balance NUMBER;
   --
   CURSOR get_asg_eff_dates(p_asg_id IN NUMBER) IS
   SELECT min(effective_start_date) min_start_date, max(effective_end_date) max_end_date
   FROM   per_all_assignments_f
   WHERE  assignment_id = p_asg_id;
   --
   l_min_start_date DATE;
   l_max_end_date   DATE;
   --
   CURSOR get_asg_details(p_asg_id IN NUMBER) IS
   SELECT pp.payroll_id, asg.person_id, pp.consolidation_set_id, flex.segment1 tax_dist
   FROM   pay_all_payrolls_f pp,
          per_all_assignments_f asg,
          hr_soft_coding_keyflex flex
   WHERE  asg.assignment_id = p_asg_id
   AND    asg.payroll_id = pp.payroll_id
   AND    ben_ext_person.g_effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date
   AND    pp.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    asg.effective_start_date < l_ext_end_date
   AND    asg.effective_end_date > ben_start_date(p_asg_id);
   --
   CURSOR check_asg_set_include(p_asg_id IN NUMBER) IS
   SELECT 'Y' include_flag
   FROM   hr_assignment_set_amendments hasa,
          hr_assignment_sets has,
          per_all_assignments_f paaf
   WHERE  has.assignment_set_id = l_ext_asg_set_id
   AND    paaf.assignment_id = p_asg_id
--   AND    ben_ext_person.g_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND    has.assignment_set_id = hasa.assignment_set_id (+)
   AND    NVL (hasa.assignment_id, paaf.assignment_id) = paaf.assignment_id
   AND    NVL (hasa.include_or_exclude, 'I') = 'I'
   AND    NVL (has.payroll_id, paaf.payroll_id) = paaf.payroll_id;
   --

   --
BEGIN

   hr_utility.trace('Entering CHECK_ASG_INCLUSION, p_assignment_id='||p_assignment_id);

   -- Get Business Group Id
   l_bus_group_id := get_bus_group_id(p_assignment_id);

   -- Get Input Parameter Values

   l_ext_end_date   := get_param_ext_end_date(l_bus_group_id);
   l_ext_payroll_id := get_param_payroll_id(l_bus_group_id);
   l_ext_person_id  := get_param_person_id(l_bus_group_id);
   l_ext_tax_dist   := get_param_tax_dist(l_bus_group_id);
   l_ext_con_set_id := get_param_consolidation_set_id(l_bus_group_id);
   l_ext_asg_set_id := get_param_assignment_set_id(l_bus_group_id);

   --

   hr_utility.trace('CHECK_ASG_INCLUSION: l_ext_end_date='||to_char(l_ext_end_date, 'DD-MON-YYYY'));
   hr_utility.trace('CHECK_ASG_INCLUSION: l_ext_payroll_id='||to_char(l_ext_payroll_id));
   hr_utility.trace('CHECK_ASG_INCLUSION: l_ext_tax_dist='||l_ext_tax_dist);
   hr_utility.trace('CHECK_ASG_INCLUSION: l_ext_con_set_id='||to_char(l_ext_con_set_id));
   hr_utility.trace('CHECK_ASG_INCLUSION: l_ext_asg_set_id='||to_char(l_ext_asg_set_id));

   --
   -- Get details of primary assignment
   -- Start with effective dates
   OPEN  get_asg_eff_dates(p_assignment_id);
   FETCH get_asg_eff_dates INTO l_min_start_date, l_max_end_date;
   CLOSE get_asg_eff_dates;
   --
   hr_utility.trace('CHECK_ASG_INCLUSION: l_min_start_date='||to_char(l_min_start_date, 'DD-MON-YYYY'));
   hr_utility.trace('CHECK_ASG_INCLUSION: l_max_end_date='||to_char(l_max_end_date, 'DD-MON-YYYY'));
   --

   IF l_min_start_date > l_ext_end_date OR l_max_end_date < get_tax_year_start(l_bus_group_id) THEN
      -- Person not active within input date range therefore exclude
      RETURN 'N';
   END IF;

   -- Check if assignment is included in the input assignment set
   IF l_ext_asg_set_id IS NOT NULL THEN
      -- Get asg set include flag
      OPEN  check_asg_set_include(p_assignment_id);
      FETCH check_asg_set_include INTO l_asg_set_include;
      CLOSE check_asg_set_include;
      --
   ELSE
      l_asg_set_include := 'Y';  -- no input asg set specified
   END IF;

   --
   hr_utility.trace('CHECK_ASG_INCLUSION: l_asg_set_include='||l_asg_set_include);

   -- Loop through all changes in the assignment during the input date range
   FOR asg_det_rec IN get_asg_details(p_assignment_id) LOOP
      --
      hr_utility.trace('CHECK_ASG_INCLUSION: asg_det_rec.payroll_id='||asg_det_rec.payroll_id);
      hr_utility.trace('CHECK_ASG_INCLUSION: asg_det_rec.person_id='||asg_det_rec.person_id);
      hr_utility.trace('CHECK_ASG_INCLUSION: asg_det_rec.tax_dist='||asg_det_rec.tax_dist);
      hr_utility.trace('CHECK_ASG_INCLUSION: asg_det_rec.consolidation_set_id='||asg_det_rec.consolidation_set_id);
      --
      IF (nvl(l_ext_payroll_id, nvl(asg_det_rec.payroll_id, -999)) = nvl(asg_det_rec.payroll_id, -999)
      AND nvl(l_ext_person_id, nvl(asg_det_rec.person_id, -999)) = nvl(asg_det_rec.person_id, -999)
      AND nvl(l_ext_tax_dist, nvl(asg_det_rec.tax_dist, 'ZZZ')) = nvl(asg_det_rec.tax_dist, 'ZZZ')
      AND nvl(l_ext_con_set_id, nvl(asg_det_rec.consolidation_set_id, -999)) = nvl(asg_det_rec.consolidation_set_id, -999)
      AND l_asg_set_include = 'Y') THEN

         -- Assignment satisfies input criteria,
         -- now check whether Mileage ASG_YTD balance > 0

         l_mileage_balance := to_number(mileage_balance(p_assignment_id));

         if l_mileage_balance > 0
         then

            l_asg_include := 'Y';

         end if;

         --
         hr_utility.trace('CHECK_ASG_INCLUSION: In Loop, l_asg_include='||l_asg_include);
      END IF;
   END LOOP;

   --
   hr_utility.trace('Leaving CHECK_ASG_INCLUSION, l_asg_include='||l_asg_include);

   RETURN l_asg_include;
   --
END check_asg_inclusion;

---------------------------------------------------------------------------
--  Function:    GET_LATEST_ASG_ACT_EXT
--  Description: Gets latest assignment action id for a specific assignment
--               before extract end date
---------------------------------------------------------------------------
function get_latest_asg_act_ext (p_assignment_id in number,
                                 p_ext_end_date  in date,
                                 p_ben_start_date in date)
return pay_assignment_actions.assignment_action_id%type is

l_asg_act_id pay_assignment_actions.assignment_action_id%type;

cursor csr_latest_asg_act_id is
    select max(paa.assignment_action_id)
    from per_time_periods ptp,
         pay_payroll_actions pact,
         pay_assignment_actions paa
    where paa.assignment_id = p_assignment_id
    and paa.payroll_action_id = pact.payroll_action_id
    and pact.time_period_id = ptp.time_period_id
    and pact.action_type in ('Q','R','B','I','V')
    and paa.action_status = 'C'
    and pact.effective_date <= p_ext_end_date
    and ptp.regular_payment_date between p_ben_start_date
                                 and p_ext_end_date;

begin

  hr_utility.set_location('get_latest_asg_act_ext',1);

  open csr_latest_asg_act_id;
  fetch csr_latest_asg_act_id into l_asg_act_id;
  close csr_latest_asg_act_id;

  hr_utility.trace('Asg act id: '||l_asg_act_id);
  hr_utility.set_location('get_latest_asg_act_ext',99);

  return l_asg_act_id;

exception

  when others then
  hr_utility.set_location('get_latest_asg_act_ext',999);
  hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
  raise;

end get_latest_asg_act_ext;

---------------------------------------------------------------------------
--  Function:    GET_LATEST_ASG_ACT_TYE
--  Description: Gets latest assignment action id for a specific assignment
--               as at Tax Year End
---------------------------------------------------------------------------
function get_latest_asg_act_tye (p_assignment_id in number,
                                 p_tax_year_end_date  in date,
                                 p_ben_start_date in date)
return pay_assignment_actions.assignment_action_id%type is

l_asg_act_id pay_assignment_actions.assignment_action_id%type;

cursor csr_latest_asg_act_id is
    select max(paa.assignment_action_id)
    from per_time_periods ptp,
         pay_payroll_actions pact,
         pay_assignment_actions paa
    where paa.assignment_id = p_assignment_id
    and paa.payroll_action_id = pact.payroll_action_id
    and pact.time_period_id = ptp.time_period_id
    and pact.action_type in ('Q','R','B','I','V')
    and paa.action_status = 'C'
    and pact.effective_date <= p_tax_year_end_date
    and ptp.regular_payment_date between p_ben_start_date
                                 and p_tax_year_end_date;

begin

  hr_utility.set_location('get_latest_asg_act_tye',1);

  open csr_latest_asg_act_id;
  fetch csr_latest_asg_act_id into l_asg_act_id;
  close csr_latest_asg_act_id;

  hr_utility.trace('Asg act id: '||l_asg_act_id);
  hr_utility.set_location('get_latest_asg_act_tye',99);

  return l_asg_act_id;

exception

  when others then
  hr_utility.set_location('get_latest_asg_act_tye',999);
  hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
  raise;

end get_latest_asg_act_tye;

---------------------------------------------------------------------------
--  Function:    CHECK_ODD_EVEN_YEAR
--  Description: Returns 'ODD' or 'EVEN' depending on whether the year
--               for the supplied tax year end date is odd or even
---------------------------------------------------------------------------
function check_odd_even_year (p_tax_year_end_date in date) return varchar2 is

l_odd_even_marker   varchar2(5);

begin

  hr_utility.set_location('check_odd_even_year',1);

  hr_utility.trace('Tax Year End Date: '||p_tax_year_end_date);

  if mod(to_number(to_char(p_tax_year_end_date,'YYYY')),2) = 0
  then

     l_odd_even_marker := 'EVEN';

  else

     l_odd_even_marker := 'ODD';

  end if;

  hr_utility.set_location('check_odd_even_year',99);
  return l_odd_even_marker;

end check_odd_even_year;
---------------------------------------------------------------------------
--  Function:    BEN_START_DATE
--  Description: Function returns benefit start date for Mileage Claim/
--               Additional Passenger Claim assignments
---------------------------------------------------------------------------

function ben_start_date (p_assignment_id in number) return varchar2 is

l_ben_start_date date;

l_bus_group_id   number;

l_tax_year_start date;


cursor csr_ben_start_date is
    select greatest(pps.date_start, l_tax_year_start)
    from per_periods_of_service pps,
         per_all_assignments_f paf
    where paf.period_of_service_id = pps.period_of_service_id
    and paf.assignment_id = p_assignment_id;

begin

  hr_utility.set_location('ben_start_date',1);

  l_bus_group_id    := get_bus_group_id(p_assignment_id);
  l_tax_year_start  := get_tax_year_start(l_bus_group_id);

  hr_utility.set_location('ben_start_date',2);

    open csr_ben_start_date;
    fetch csr_ben_start_date into l_ben_start_date;
    close csr_ben_start_date;

  hr_utility.trace('Benefit start date: '||to_char(l_ben_start_date,'DD-MON-YYYY'));
  hr_utility.set_location('ben_start_date',99);

return to_char(l_ben_start_date,'DD-MON-YYYY');

exception

    when others then
    hr_utility.set_location('ben_start_date',999);
    hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
    raise;

end ben_start_date;

---------------------------------------------------------------------------
--  Function:    BEN_END_DATE
--  Description: Function returns benefit end date for Mileage Claim/
--               Additional Passenger Claim assignments
---------------------------------------------------------------------------
function ben_end_date (p_assignment_id in number) return varchar2 is

l_bus_group_id number;

l_ben_end_date date;
l_tax_year_end date;

cursor csr_ben_end_date is
    select least(nvl(pps.actual_termination_date,hr_general.end_of_time),
                 l_tax_year_end)
    from   per_periods_of_service pps,
           per_all_assignments_f paf
    where  paf.period_of_service_id = pps.period_of_service_id
    and    paf.assignment_id = p_assignment_id;

begin

  hr_utility.set_location('ben_end_date',1);

  l_bus_group_id := get_bus_group_id(p_assignment_id);
  l_tax_year_end := get_tax_year_end(l_bus_group_id);

  hr_utility.set_location('ben_end_date',2);

    open csr_ben_end_date;
    fetch csr_ben_end_date into l_ben_end_date;
    close csr_ben_end_date;

  hr_utility.trace('Benefit end date: '||to_char(l_ben_end_date,'DD-MON-YYYY'));
  hr_utility.set_location('ben_end_date',99);

return to_char(l_ben_end_date,'DD-MON-YYYY');

exception

    when others then
    hr_utility.set_location('ben_end_date',999);
    hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
    raise;

end ben_end_date;

---------------------------------------------------------------------------
--  Function:    ASG_START_DATE
--  Description: Function returns greater of assignment start date or TYS
---------------------------------------------------------------------------
function asg_start_date (p_assignment_id in number) return varchar2 is

l_bus_group_id number;

l_asg_start_date date;
l_tax_year_start date;

cursor csr_asg_start_date is
    select greatest(min(paf.effective_start_date),l_tax_year_start)
    from per_all_assignments_f paf
    where paf.assignment_id = p_assignment_id;

begin

  hr_utility.set_location('asg_start_date',1);

  l_bus_group_id := get_bus_group_id(p_assignment_id);
  l_tax_year_start := get_tax_year_start(l_bus_group_id);

  hr_utility.set_location('asg_start_date',2);

    open csr_asg_start_date;
    fetch csr_asg_start_date into l_asg_start_date;
    close csr_asg_start_date;

  hr_utility.trace('Asg start date: '||to_char(l_asg_start_date,'DD-MON-YYYY'));
  hr_utility.set_location('asg_start_date',99);

return to_char(l_asg_start_date,'DD-MON-YYYY');

exception

    when others then
    hr_utility.set_location('asg_start_date',999);
    hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
    raise;

end asg_start_date;


---------------------------------------------------------------------------
--  Function:    ASG_END_DATE
--  Description: Function returns lesser of assignment end date or TYE
---------------------------------------------------------------------------
function asg_end_date (p_assignment_id in number) return varchar2 is

l_bus_group_id number;

l_asg_end_date date;
l_tax_year_end date;

cursor csr_asg_end_date is
    select least(max(paf.effective_end_date),l_tax_year_end)
    from per_all_assignments_f paf,
         per_assignment_status_types past
    where paf.assignment_id = p_assignment_id
    and   past.per_system_status = 'ACTIVE_ASSIGN'
    and   paf.assignment_status_type_id = past.assignment_status_type_id;

begin

  hr_utility.set_location('asg_end_date',1);

  l_bus_group_id := get_bus_group_id(p_assignment_id);
  l_tax_year_end := get_tax_year_end(l_bus_group_id);

  hr_utility.set_location('asg_end_date',2);

    open csr_asg_end_date;
    fetch csr_asg_end_date into l_asg_end_date;
    close csr_asg_end_date;

  hr_utility.trace('Asg end date: '||to_char(l_asg_end_date,'DD-MON-YYYY'));
  hr_utility.set_location('asg_end_date',99);

return to_char(l_asg_end_date,'DD-MON-YYYY');

exception

    when others then
    hr_utility.set_location('asg_end_date',999);
    hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
    raise;

end asg_end_date;


---------------------------------------------------------------------------
--  Function:    MILEAGE_BALANCE
--  Description: Function returns mileage balance for a specific assignment
---------------------------------------------------------------------------
function mileage_balance (p_assignment_id in number) return varchar2 is

l_asg_act_id_tye       pay_assignment_actions.assignment_action_id%type;
l_asg_act_id_ext       pay_assignment_actions.assignment_action_id%type;

l_bus_group_id      number;

l_ext_end_date      date;

l_ben_start_date    date;

l_def_bal_id        pay_defined_balances.defined_balance_id%type;

cursor csr_get_odd_def_bal_id is
    select pdb.defined_balance_id
    from pay_balance_types pbt,
         pay_defined_balances pdb,
         pay_balance_dimensions pbd
    where pbt.balance_type_id = pdb.balance_type_id
    and pdb.balance_dimension_id = pbd.balance_dimension_id
    and pbt.balance_name = 'Mileage Odd Taxable Amt'
    and pbd.dimension_name = '_ASG_YTD';

cursor csr_get_even_def_bal_id is
    select pdb.defined_balance_id
    from pay_balance_types pbt,
         pay_defined_balances pdb,
         pay_balance_dimensions pbd
    where pbt.balance_type_id = pdb.balance_type_id
    and pdb.balance_dimension_id = pbd.balance_dimension_id
    and pbt.balance_name = 'Mileage Even Taxable Amt'
    and pbd.dimension_name = '_ASG_YTD';

l_odd_even_marker   varchar2(5);

l_tax_year_end      date;

l_tye_balance       number;
l_ext_balance       number;

l_balance_amt       number;

begin

  hr_utility.set_location('mileage_balance',1);

  -- get necessary data

  l_bus_group_id := get_bus_group_id(p_assignment_id);

  hr_utility.set_location('mileage_balance',2);

  l_tax_year_end := get_tax_year_end(l_bus_group_id);

  hr_utility.set_location('mileage_balance',3);


  -- check whether year in which tax year end date falls is odd or even

  l_odd_even_marker := check_odd_even_year(l_tax_year_end);

  -- retrieve appropriate odd/even defined balance id for Mileage Taxable Amt
  -- based on odd/even marker
  hr_utility.set_location('mileage_balance',4);

  if l_odd_even_marker = 'ODD'
  then

     open csr_get_odd_def_bal_id;
     fetch csr_get_odd_def_bal_id into l_def_bal_id;
     close csr_get_odd_def_bal_id;

  else

     open csr_get_even_def_bal_id;
     fetch csr_get_even_def_bal_id into l_def_bal_id;
     close csr_get_even_def_bal_id;

  end if;

  hr_utility.set_location('mileage_balance',5);

  -- get params to pass to get_latest_asg_act

  l_ext_end_date := get_param_ext_end_date(l_bus_group_id);

  hr_utility.set_location('mileage_balance',6);

  l_ben_start_date := fnd_date.displaydate_to_date(ben_start_date(p_assignment_id));

  hr_utility.set_location('mileage_balance',7);

  -- fetch latest assignment action ids for that assignment as at TYE and
  -- extract end date (or closest asg action to either)

  l_asg_act_id_ext := get_latest_asg_act_ext(p_assignment_id => p_assignment_id,
                                             p_ext_end_date => l_ext_end_date,
                                             p_ben_start_date => l_ben_start_date);

  l_asg_act_id_tye := get_latest_asg_act_tye(p_assignment_id => p_assignment_id,
                                             p_tax_year_end_date => l_tax_year_end,
                                             p_ben_start_date => l_ben_start_date);

  -- now get ASG_YTD balances for that assignment, using defined balance id
  -- and latest assignment actions just obtained
  hr_utility.set_location('mileage_balance',8);

  l_ext_balance := pay_balance_pkg.get_value (p_defined_balance_id => l_def_bal_id,
                                              p_assignment_action_id => l_asg_act_id_ext);

  l_tye_balance := pay_balance_pkg.get_value (p_defined_balance_id => l_def_bal_id,
                                              p_assignment_action_id => l_asg_act_id_tye);

  hr_utility.trace('l_ext_balance: '||l_ext_balance);
  hr_utility.trace('l_tye_balance: '||l_tye_balance);

  if l_tye_balance <> l_ext_balance
  -- e.g. if user has processed back-dated mileage claims after TYE so balance
  -- as of extract end date is greater
  then

     l_balance_amt := l_tye_balance + l_ext_balance;

  else
  -- just take the balance as at TYE or closest asg action to that

     l_balance_amt := l_tye_balance;

  end if;

  hr_utility.set_location('mileage_balance',9);
  hr_utility.trace('Mileage Balance Amount: '||l_balance_amt);
  hr_utility.trace('Assignment id: '||p_assignment_id);

  hr_utility.set_location('mileage_balance',99);

  return to_char(l_balance_amt);

exception

  when others then
  hr_utility.set_location('mileage_balance',999);
  hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
  raise;

end mileage_balance;

---------------------------------------------------------------------------
--  Function:    ADD_PASS_BALANCE
--  Description: Function returns addl passenger balance for a specific
--               assignment
---------------------------------------------------------------------------
function add_pass_balance (p_assignment_id in number) return varchar2 is

l_asg_act_id_tye       pay_assignment_actions.assignment_action_id%type;
l_asg_act_id_ext       pay_assignment_actions.assignment_action_id%type;

l_bus_group_id      number;

l_ext_end_date      date;

l_ben_start_date    date;

l_def_bal_id        pay_defined_balances.defined_balance_id%type;

cursor csr_get_odd_def_bal_id is
    select pdb.defined_balance_id
    from pay_balance_types pbt,
         pay_defined_balances pdb,
         pay_balance_dimensions pbd
    where pbt.balance_type_id = pdb.balance_type_id
    and pdb.balance_dimension_id = pbd.balance_dimension_id
    and pbt.balance_name = 'Addl Pasg Odd Taxable Amt'
    and pbd.dimension_name = '_ASG_YTD';

cursor csr_get_even_def_bal_id is
    select pdb.defined_balance_id
    from pay_balance_types pbt,
         pay_defined_balances pdb,
         pay_balance_dimensions pbd
    where pbt.balance_type_id = pdb.balance_type_id
    and pdb.balance_dimension_id = pbd.balance_dimension_id
    and pbt.balance_name = 'Addl Pasg Even Taxable Amt'
    and pbd.dimension_name = '_ASG_YTD';

l_odd_even_marker   varchar2(5);

l_tax_year_end      date;

l_tye_balance       number;
l_ext_balance       number;

l_balance_amt       number;

begin

  hr_utility.set_location('add_pass_balance',1);

  -- get necessary data

  l_bus_group_id := get_bus_group_id(p_assignment_id);

  hr_utility.set_location('add_pass_balance',2);

  l_tax_year_end := get_tax_year_end(l_bus_group_id);

  hr_utility.set_location('add_pass_balance',3);

  -- check whether year in which tax year end date falls is odd or even

  l_odd_even_marker := check_odd_even_year(l_tax_year_end);

  -- retrieve appropriate odd/even defined balance id for Mileage Taxable Amt
  -- based on odd/even marker
  hr_utility.set_location('add_pass_balance',4);

  if l_odd_even_marker = 'ODD'
  then

     open csr_get_odd_def_bal_id;
     fetch csr_get_odd_def_bal_id into l_def_bal_id;
     close csr_get_odd_def_bal_id;

  else

     open csr_get_even_def_bal_id;
     fetch csr_get_even_def_bal_id into l_def_bal_id;
     close csr_get_even_def_bal_id;

  end if;

  hr_utility.set_location('add_pass_balance',5);

  -- get params to pass to get_latest_asg_act

  l_ext_end_date := get_param_ext_end_date(l_bus_group_id);

  hr_utility.set_location('add_pass_balance',6);

  l_ben_start_date := fnd_date.displaydate_to_date(ben_start_date(p_assignment_id));

  hr_utility.set_location('add_pass_balance',7);

  -- fetch latest assignment action ids for that assignment as at TYE and
  -- extract end date (or closest asg act to either)

  l_asg_act_id_ext := get_latest_asg_act_ext(p_assignment_id => p_assignment_id,
                                             p_ext_end_date => l_ext_end_date,
                                             p_ben_start_date => l_ben_start_date);

  l_asg_act_id_tye := get_latest_asg_act_tye(p_assignment_id => p_assignment_id,
                                             p_tax_year_end_date => l_tax_year_end,
                                             p_ben_start_date => l_ben_start_date);

  -- now get ASG_YTD balances for that assignment, using defined balance id
  -- and latest assignment actions just obtained
  hr_utility.set_location('add_pass_balance',8);

  l_ext_balance := pay_balance_pkg.get_value (p_defined_balance_id => l_def_bal_id,
                                              p_assignment_action_id => l_asg_act_id_ext);

  l_tye_balance := pay_balance_pkg.get_value (p_defined_balance_id => l_def_bal_id,
                                              p_assignment_action_id => l_asg_act_id_tye);

  hr_utility.trace('l_ext_balance: '||l_ext_balance);
  hr_utility.trace('l_tye_balance: '||l_tye_balance);

  if l_tye_balance <> l_ext_balance
  -- e.g. if user has processed back-dated mileage claims after TYE so balance
  -- as of extract end date is greater
  then

     l_balance_amt := l_tye_balance + l_ext_balance;

  else
  -- just take the balance as at TYE or closest asg action to that

     l_balance_amt := l_tye_balance;

  end if;

  hr_utility.set_location('add_pass_balance',9);
  hr_utility.trace('Addl Passenger Balance Amount: '||l_balance_amt);
  hr_utility.trace('Assignment id: '||p_assignment_id);

  hr_utility.set_location('add_pass_balance',99);

  return to_char(l_balance_amt);

exception

  when others then
  hr_utility.set_location('mileage_balance',999);
  hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
  raise;

end add_pass_balance;

---------------------------------------------------------------------------
--  Function:    CREATE_EXT_RSLT_DTL
--  Description: Write new details records to extract table
---------------------------------------------------------------------------
PROCEDURE create_ext_rslt_dtl(p_asg_id             in number,
                              p_benefit_start_date in varchar2,
                              p_benefit_end_date   in varchar2,
                              p_mileage_balance    in varchar2,
                              p_add_pass_balance   in varchar2,
                              p_asg_start_date     in varchar2,
                              p_asg_end_date       in varchar2) IS
   --
   l_ext_rslt_dtl_id NUMBER;
   l_object_version_no NUMBER;
   --
   CURSOR chk_exists IS
   SELECT ext_rslt_dtl_id
   FROM   ben_ext_rslt_dtl
   WHERE  ext_rslt_id = g_ext_rslt_id
   AND    person_id = g_person_id
   AND    ext_rcd_id = g_veh_rcd_id
   AND    val_02 = to_char(p_asg_id)
   AND    val_04 = p_benefit_end_date
   AND    val_09 = p_benefit_start_date
   AND    val_10 = p_benefit_end_date
   AND    val_12 = p_mileage_balance;
   --
   l_chk_exists chk_exists%ROWTYPE;

BEGIN

   hr_utility.trace('Entering CREATE_EXT_RSLT_DTL: p_asg_id='|| p_asg_id);
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_benefit_start_date='||p_benefit_start_date);
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_benefit_end_date='||p_benefit_end_date);
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_mileage_balance='||p_mileage_balance);
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_add_pass_balance='||p_add_pass_balance);
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_asg_start_date='||p_asg_start_date);
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_asg_end_date='||p_asg_end_date);
  --
   -- CHeck if record already exists
   OPEN chk_exists;
   FETCH chk_exists INTO l_chk_exists;
   --
   IF chk_exists%NOTFOUND THEN
      -- Record does not exist
      -- Call API to create extract details record
      BEGIN
       ben_ext_rslt_dtl_api.create_ext_rslt_dtl( p_ext_rslt_dtl_id   => l_ext_rslt_dtl_id
                                                ,p_ext_rslt_id       => g_ext_rslt_id
                                                ,p_ext_rcd_id        => g_veh_rcd_id
                                                ,p_person_id         => g_person_id
                                                ,p_business_group_id => g_bg_id
                                                ,p_val_01            => 'A'
                                                ,p_val_02            => to_char(p_asg_id)
                                                ,p_val_03            => '~~~~~~~~~~~~~~~~~~~~~~~~~'
                                                ,p_val_04            => p_benefit_end_date
                                                ,p_val_05            => p_asg_start_date
                                                ,p_val_06            => p_asg_end_date
                                                ,p_val_07            => 'Mileage Allowance and PPayment'
                                                ,p_val_08            => '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                                                ,p_val_09            => p_benefit_start_date
                                                ,p_val_10            => p_benefit_end_date
                                                ,p_val_11            => '~~~'
                                                ,p_val_12            => p_mileage_balance
                                                ,p_val_13            => '~'
                                                ,p_val_14            => p_add_pass_balance
                                                ,p_val_15            => '~~'
                                                ,p_val_16            => '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                                                ,p_object_version_number => l_object_version_no);

      hr_utility.trace('Wrote detail record: '||l_ext_rslt_dtl_id);


      EXCEPTION WHEN others THEN
         hr_utility.trace('CREATE_EXT_RSLT_DTL: '||substr(sqlerrm, 1, 100));
         hr_utility.trace('CREATE_EXT_RSLT_DTL: '||substr(sqlerrm, 101, 100));
         hr_utility.trace('CREATE_EXT_RSLT_DTL: '||substr(sqlerrm, 201, 100));
         hr_utility.trace('CREATE_EXT_RSLT_DTL: '||substr(sqlerrm, 301, 100));
         RAISE;
      END;
   END IF;
   --
   CLOSE chk_exists;

end create_ext_rslt_dtl;

---------------------------------------------------------------------------
--  Function:    PROCESS_SEC_ASG
--  Description: Process secondary assignments. Check that assignment meets
--               criteria, retrieve any balances and write new detail
--               records
---------------------------------------------------------------------------
PROCEDURE process_sec_asg(p_asg_id IN NUMBER) IS
   --
   CURSOR csr_sec_asg IS
   SELECT distinct paa1.assignment_id
   FROM   per_all_assignments_f paa1, per_all_assignments_f paa2
   WHERE  paa2.assignment_id = p_asg_id
   AND    paa2.person_id = paa1.person_id
   AND    nvl(paa1.primary_flag, 'N') = 'N';
   --
   l_asg_include        VARCHAR2(1) := 'N';

   l_ben_start_date     varchar2(30);
   l_ben_end_date       varchar2(30);

   l_mileage_balance    varchar2(30);
   l_add_pass_balance   varchar2(30);

   l_asg_start_date     varchar2(30);
   l_asg_end_date       varchar2(30);
   --
BEGIN
   hr_utility.set_location('process_sec_asg',1);
   hr_utility.trace('p_asg_id= '||p_asg_id);
   --
   -- Loop through all secondary assignments
   FOR sec_asg_rec IN csr_sec_asg LOOP
      --
      hr_utility.set_location('process_sec_asg',2);
      l_asg_include := 'N';
      l_asg_include := check_asg_inclusion(sec_asg_rec.assignment_id);
      --
      -- if assignment meets criteria and mileage balance for that assignment
      -- is greater than zero, then retrieve all details and write new
      -- detail record
      IF l_asg_include = 'Y' and to_number(mileage_balance(sec_asg_rec.assignment_id)) > 0
      THEN

         hr_utility.set_location('process_sec_asg',3);

         l_ben_start_date   := ben_start_date(sec_asg_rec.assignment_id);
         l_ben_end_date     := ben_end_date(sec_asg_rec.assignment_id);
         l_mileage_balance  := mileage_balance(sec_asg_rec.assignment_id);
         l_add_pass_balance := add_pass_balance(sec_asg_rec.assignment_id);
         l_asg_start_date   := asg_start_date(sec_asg_rec.assignment_id);
         l_asg_end_date     := asg_end_date(sec_asg_rec.assignment_id);

         create_ext_rslt_dtl( p_asg_id             => sec_asg_rec.assignment_id,
                              p_benefit_start_date => l_ben_start_date,
                              p_benefit_end_date   => l_ben_end_date,
                              p_mileage_balance    => l_mileage_balance,
                              p_add_pass_balance   => l_add_pass_balance,
                              p_asg_start_date     => l_asg_start_date,
                              p_asg_end_date       => l_asg_end_date);

      END IF;

   END LOOP;
   --
   hr_utility.set_location('process_sec_asg',99);

exception

when others then

  hr_utility.set_location('process_sec_asg',999);
  hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
  raise;

END process_sec_asg;

---------------------------------------------------------------------------
--  Function:    PROCESS_TERM_PRIMARY_ASG
--  Description: Process primary assignments that were terminated prior to
--               the extract being run e.g. for rehires where primary assignment
--               being passed in is the current primary assignment.
--               Check that assignment meets criteria, retrieve any balances
--               and write new detail records
---------------------------------------------------------------------------
PROCEDURE process_term_primary_asg(p_asg_id IN NUMBER) IS
   --
   CURSOR csr_term_prim_asg IS
   SELECT distinct paa1.assignment_id
   FROM   per_all_assignments_f paa1, per_all_assignments_f paa2
   WHERE  paa2.assignment_id = p_asg_id
   AND    paa2.person_id = paa1.person_id
   AND    paa1.effective_end_date < paa2.effective_start_date
--   AND    paa1.period_of_service_id <> paa2.period_of_service_id
   AND    nvl(paa1.primary_flag, 'Y') = 'Y';
   --
   l_asg_include        VARCHAR2(1) := 'N';

   l_ben_start_date     varchar2(30);
   l_ben_end_date       varchar2(30);

   l_mileage_balance    varchar2(30);
   l_add_pass_balance   varchar2(30);

   l_asg_start_date     varchar2(30);
   l_asg_end_date       varchar2(30);
   --
BEGIN
   hr_utility.set_location('process_term_primary_asg',1);
   hr_utility.trace('p_asg_id= '||p_asg_id);
   --
   -- Loop through all terminated primary assignments
   FOR term_prim_asg_rec IN csr_term_prim_asg LOOP
      --
      hr_utility.set_location('process_term_primary_asg',2);
      l_asg_include := 'N';
      l_asg_include := check_asg_inclusion(term_prim_asg_rec.assignment_id);
      --
      -- if assignment meets criteria and mileage balance for that assignment
      -- is greater than zero, then retrieve all details and write new
      -- detail record
      IF l_asg_include = 'Y' and to_number(mileage_balance(term_prim_asg_rec.assignment_id)) > 0
      THEN

         hr_utility.set_location('process_term_primary_asg',3);

         l_ben_start_date   := ben_start_date(term_prim_asg_rec.assignment_id);
         l_ben_end_date     := ben_end_date(term_prim_asg_rec.assignment_id);
         l_mileage_balance  := mileage_balance(term_prim_asg_rec.assignment_id);
         l_add_pass_balance := add_pass_balance(term_prim_asg_rec.assignment_id);
         l_asg_start_date   := asg_start_date(term_prim_asg_rec.assignment_id);
         l_asg_end_date     := asg_end_date(term_prim_asg_rec.assignment_id);

         create_ext_rslt_dtl( p_asg_id             => term_prim_asg_rec.assignment_id,
                              p_benefit_start_date => l_ben_start_date,
                              p_benefit_end_date   => l_ben_end_date,
                              p_mileage_balance    => l_mileage_balance,
                              p_add_pass_balance   => l_add_pass_balance,
                              p_asg_start_date     => l_asg_start_date,
                              p_asg_end_date       => l_asg_end_date);

      END IF;

   END LOOP;
   --
   hr_utility.set_location('process_term_primary_asg',99);

exception

when others then

  hr_utility.set_location('process_term_primary_asg',999);
  hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
  raise;

END process_term_primary_asg;

---------------------------------------------------------------------------
--  Function:    POST_PROCESS_RULE
--  Description: Extract post-processing functionality. Processes any
--               secondary assignments that meet the criteria, as well as
--               cleaning up any unnecessary assignment and details records
---------------------------------------------------------------------------
FUNCTION post_process_rule(p_ext_rslt_id IN NUMBER) RETURN VARCHAR2 IS

 CURSOR csr_asg_record_id IS
   SELECT rcd.ext_rcd_id
   FROM   ben_ext_rcd rcd,
          ben_ext_rcd_in_file rif,
          ben_ext_dfn dfn,
          ben_ext_rslt rslt
   WHERE  rslt.ext_rslt_id = p_ext_rslt_id
   AND    rslt.ext_dfn_id = dfn.ext_dfn_id
   AND    dfn.ext_file_id = rif.ext_file_id
   AND    rif.ext_rcd_id = rcd.ext_rcd_id
   AND    rcd.name like '%PAY GB P11D Mileage Extract 2003 - Assignment Details Record';
   --
   l_asg_rcd_id NUMBER;
   --
   CURSOR csr_detail_record_id IS
   SELECT rcd.ext_rcd_id
   FROM   ben_ext_rcd rcd,
          ben_ext_rcd_in_file rif,
          ben_ext_dfn dfn,
          ben_ext_rslt rslt
   WHERE  rslt.ext_rslt_id = p_ext_rslt_id
   AND    rslt.ext_dfn_id = dfn.ext_dfn_id
   AND    dfn.ext_file_id = rif.ext_file_id
   AND    rif.ext_rcd_id = rcd.ext_rcd_id
   AND    rcd.name like '%PAY GB P11D Mileage Extract 2003 - Mileage and Passenger Record';
   --
   --
   CURSOR csr_ext_asg IS
   SELECT person_id, val_01 asg_id, ext_rslt_dtl_id, object_version_number
   FROM   ben_ext_rslt_dtl
   WHERE  ext_rslt_id = p_ext_rslt_id
   AND    ext_rcd_id = l_asg_rcd_id;
   --
   l_obj_no NUMBER := NULL;
   --
   CURSOR csr_balance_detail(p_person_id IN NUMBER) IS
   SELECT *
   FROM   ben_ext_rslt_dtl
   WHERE  ext_rslt_id = p_ext_rslt_id
   AND    ext_rcd_id = g_veh_rcd_id
   AND    person_id = p_person_id;
   --
   l_balance_detail csr_balance_detail%ROWTYPE;
   --
   l_asg_include VARCHAR2(1);
   --
BEGIN

   hr_utility.trace('Entering POST_PROCESS_RULE, p_ext_rslt_id='||p_ext_rslt_id);

   g_ext_rslt_id := p_ext_rslt_id;

   -- Get assignment details record id
   OPEN csr_asg_record_id;
   FETCH csr_asg_record_id INTO l_asg_rcd_id;
   CLOSE csr_asg_record_id;
   --
   hr_utility.trace('POST_PROCESS_RULE: l_asg_rcd_id='||l_asg_rcd_id);

   -- Get Balance Detail Record Id
   OPEN  csr_detail_record_id;
   FETCH csr_detail_record_id INTO g_veh_rcd_id;
   CLOSE csr_detail_record_id;
   --
   hr_utility.trace('POST_PROCESS_RULE: g_veh_rcd_id='||g_veh_rcd_id);

   -- Loop through all people extracted
   FOR ext_asg_rec IN csr_ext_asg LOOP

      -- reset balance detail record at start of each loop
      l_balance_detail := null;

      g_person_id := ext_asg_rec.person_id;
      g_bg_id := get_bus_group_id(ext_asg_rec.asg_id);
      --
      hr_utility.trace('POST_PROCESS_RULE: ext_asg_rec.asg_id='||ext_asg_rec.asg_id);
      hr_utility.trace('POST_PROCESS_RULE: g_person_id='||g_person_id);

      -- Fetch in full detail record for primary assignment
      -- Delete balance detail record if mileage ASG_YTD balance is zero
      OPEN csr_balance_detail(ext_asg_rec.person_id);
      FETCH csr_balance_detail INTO l_balance_detail;
      CLOSE csr_balance_detail;
      --
      hr_utility.trace('POST_PROCESS_RULE: l_balance_detail.ext_rslt_dtl_id= '||l_balance_detail.ext_rslt_dtl_id);
      hr_utility.trace('POST_PROCESS_RULE: l_balance_detail.val_12(mileage balance)= '||l_balance_detail.val_12);

      --
      l_asg_include := check_asg_inclusion(ext_asg_rec.asg_id);

      IF l_balance_detail.ext_rslt_dtl_id IS NOT NULL AND l_asg_include = 'N'
      THEN
         -- Primary assignment does not qualify for extract
         -- Delete this detail record
         hr_utility.trace('Primary asg does not qualify for extract - deleting detail record');
         ben_ext_rslt_dtl_api.delete_ext_rslt_dtl(p_ext_rslt_dtl_id => l_balance_detail.ext_rslt_dtl_id,
                                                  p_object_version_number => l_balance_detail.object_version_number);

      END IF;

      --
      -- Process any terminated primary assignments which may qualify
      process_term_primary_asg(ext_asg_rec.asg_id);
      --
      -- Process any secondary assignments which may qualify
      process_sec_asg(ext_asg_rec.asg_id);
      --
      hr_utility.trace('POST_PROCESS_RULE: Assignment processed, remove it from the extract details table.');
      l_obj_no := ext_asg_rec.object_version_number;
      -- Delete this assignment details record
      ben_ext_rslt_dtl_api.delete_ext_rslt_dtl(p_ext_rslt_dtl_id => ext_asg_rec.ext_rslt_dtl_id,
                                               p_object_version_number => l_obj_no);
      --
   END LOOP;
   --
   hr_utility.trace('Leaving Post_process_rule.');
   RETURN 'Y';
   --
exception

when others then

  hr_utility.set_location('post_process_rule',999);
  hr_utility.trace('SQLERRM: '||substr(sqlerrm,1,200));
  raise;



end post_process_rule;


---------------------------------------------------------------------------
-- Function:    CHECK_PERSON_INCLUSION
-- Description: This function checks all primary and secondary assignments
--              for inclusion and returns Y if any of them should be
--              included.
---------------------------------------------------------------------------
FUNCTION check_person_inclusion(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_person_include VARCHAR2(1);
   --
   CURSOR get_all_asg IS
   SELECT distinct paa1.assignment_id
   FROM   per_all_assignments_f paa1, per_all_assignments_f paa2
   WHERE  paa2.assignment_id = p_assignment_id
   AND    paa2.person_id = paa1.person_id
   ORDER BY paa1.assignment_id;
   --
   l_asg_id NUMBER;

BEGIN

   hr_utility.trace('Entering CHECK_PERSON_INCLUSION, p_assignment_id='||p_assignment_id);

   --  check whether any assignment qualifies
   OPEN get_all_asg;
   LOOP

      FETCH get_all_asg INTO l_asg_id;
      IF get_all_asg%FOUND THEN
         l_person_include := check_asg_inclusion(l_asg_id);
      END IF;
      EXIT WHEN (get_all_asg%NOTFOUND OR l_person_include = 'Y');

   END LOOP;
   --
hr_utility.trace('Leaving CHECK_PERSON_INCLUSION, l_person_include='||l_person_include);

RETURN l_person_include;
   --
END check_person_inclusion;

/* end of package body */
end pay_gb_p11d_mileage_extract;

/
