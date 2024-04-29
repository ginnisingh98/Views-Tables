--------------------------------------------------------
--  DDL for Package Body PAY_US_PTO_ACCRUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_PTO_ACCRUAL" as
 /* $Header: pyusptoa.pkb 120.1 2005/10/04 03:38:12 schauhan noship $
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************
    Name        : pay_us_pto_accrual
    Description : This package holds building blocks used in PTO accrual
                  calculation.
    Uses        : hr_utility
    Change List
    -----------
    Date        Name          Vers      Bug No   Description
    ----        ----          ----      ------   -----------
    FEB-16-1994 RMAMGAIN      1.0                Created with following proc.
                                                  . get_accrual
                                                  . get_accrual_for_plan
                                                  . get_first_accrual_period
                                                  . ceiling_calc

    24-NOV-1994 RFINE				Suppressed index on
                                                business_group_id

    14-JUN-1995	HPARICHA	40.6	287032	Corrected length of service
					287076	calculation and accrual
						entitlement logic.
    10-OCT-1995 JTHURING        40.9            Added missing '/', exit
    11-OCT-1995 JTHURING        40.10           Removed spurious IF clause:
				    "if P_net_accrual > P_current_ceiling then
               			        P_net_accrual := P_current_ceiling;"
    06-DEC-1995 AMILLS          40.11           Changed date format to DDMMYYYY
                                                (on one check of end date)
                                                for translation.
    19-Jan-96	rfine	 40.12	305751  Changed cursor csr_get_time_periods in
   					proc get_accrual_for_plan so it gets
					the correct time periods for the
					accrual period. Also allowed a period
					after six months eligiblity to count if
					its start date matches the six month
					anniversary. (i.e. if you join on 1 Jan
					and periods start on the first of the
					month, you start accruing on 1 Jul, not
					1 Aug.
    04-Nov-96  khabibul  40.13  367438  added close cursor XXX at various places
					as the cursors were not closed at the right
					time especially when an error was raised. This
					left the open cursor's open and during the next
					call to this package (same session) the db was
					in a confusion state and gave spurious messages.
					Also included a new message which is raised if the
					effective date is not within the range of payroll
					time periods.
    13-Nov-96  lwthomps  40.14          Added a performance fix to csr_get_plan_details.
    15-NOV-96  gpaytonm  40.15		Added close cursor csr_get_period

    25-Mar-98  lwthomps  40.16(110.1)   Truncated date coming in from
                                        check writer for bug: 464550
    21-May-98	Djeng	110.2		fixed bug 672443
    23-Mar-99   Sdoshi  115.2           Flexible Dates Conversion
    08-APR-99   djoshi                  Verfied and converted for Canonical
                                        Complience of Date
    21-May-01  dcasemor 115.10          Removed assignment_action_id check when deciding
                                        whether to use hard-coded or Fast Formula-based
                                        PTO solution.
    22-May-01  dcasemor 115.11          Convert assignment_action_id to -1 if
                                        a null is passed or defaulted. This
                                        prevents an error running the formulae.
    16-Oct-02  dcasemor 115.12 2628433  Added delete_plan_from_cache and
                                        use_fast_formula.  These remove the dependency
                                        on the "Use FF-based PTO Accruals" profile
                                        option.

  */
--
-- Private PL/SQL table to cache a list of accrual plans.
--
TYPE per_plans IS TABLE OF BOOLEAN INDEX BY binary_integer;
g_plan_list    per_plans;
g_package      VARCHAR2(30) := 'pay_us_pto_accrual.';

--
------------------------- delete_plan_from_cache ----------------------------
--
PROCEDURE delete_plan_from_cache (p_plan_id IN NUMBER)
IS

BEGIN

  IF g_plan_list.exists(p_plan_id) THEN
    --
    -- Delete the plan from the cache.
    --
    g_plan_list.DELETE(p_plan_id);

  END IF;

END delete_plan_from_cache;
--
------------------------- use_fast_formula ----------------------------
--
FUNCTION use_fast_formula
  (p_effective_date IN DATE
  ,p_plan_id        IN NUMBER) RETURN BOOLEAN
IS

  --
  -- Fetches FALSE if the old 10.7 hard-coded PTO rules can be used
  -- instead of the Fast Formula.  The sole reason for doing this is
  -- because its faster to execute PL/SQL than Fast Formula so improves
  -- the performance of batch processes such as Checkwriter.
  --
  CURSOR csr_use_ff IS
  SELECT NULL
  FROM   pay_accrual_plans pap
        ,ff_formulas_f ff
  WHERE  pap.accrual_plan_id = p_plan_id
  AND    pap.accrual_formula_id = ff.formula_id
  AND    p_effective_date BETWEEN
         ff.effective_start_date and ff.effective_end_date
  AND   (ff.formula_name = 'PTO_PAYROLL_CALCULATION'
   OR   (ff.formula_name = 'PTO_PAYROLL_BALANCE_CALCULATION' AND
         pap.defined_balance_id IS NULL));

  l_return BOOLEAN := TRUE;
  l_dummy  NUMBER;

BEGIN

  --
  -- Check to see if this plan has already been cached.
  --
  IF g_plan_list.exists(p_plan_id) THEN

    l_return := g_plan_list(p_plan_id);

  ELSE

    --
    -- The plan has not been cached. Calculate if the Fast Formula
    -- must be used and cache the value.
    --
    OPEN  csr_use_ff;
    FETCH csr_use_ff INTO l_dummy;
    --
    -- If the cursor returns no rows, l_return will default to its
    -- declared value of TRUE.
    --
    IF csr_use_ff%FOUND THEN
      l_return := FALSE;
    END IF;

    CLOSE csr_use_ff;

    g_plan_list(p_plan_id) := l_return;

  END IF;

  RETURN l_return;

END use_fast_formula;
--
------------------------- get_accrual ----------------------------
--
FUNCTION get_accrual
                    ( P_assignment_id        number,
                      P_calculation_date     date,
                      P_plan_id              number   DEFAULT NULL,
                      P_plan_category        varchar2 DEFAULT NULL)
         RETURN Number is
--
-- Function calls the actual proc. which will calc. accrual and pass back all
-- the details in formula we will call functions so this will be the cover
-- function to call the proc.
--
l_accrual  number := 0;
--
c_date date := P_calculation_date;
n1 number;
n2 number;
n3 number;
d1 date;
d2 date;
d3 date;
d4 date;
d5 date;
d6 date;
d7 date;
p_mod varchar2(1) := 'N';
--
BEGIN
--

   pay_us_pto_accrual.accrual_calc_detail(
       P_assignment_id      => P_assignment_id,
       P_calculation_date   => c_date,
       P_plan_id            => P_plan_id,
       P_plan_category      => P_plan_category,
       P_accrual            => l_accrual,
       P_payroll_id         => n1,
       P_first_period_start => d1,
       P_first_period_end   => d2,
       P_last_period_start  => d3,
       P_last_period_end    => d4,
       P_cont_service_date  => d5,
       P_start_date         => d6,
       P_end_date           => d7,
       P_current_ceiling    => n2,
       P_current_carry_over => n3);
--
  IF l_accrual is null
  THEN
    l_accrual := 0;
  END IF;
--
  RETURN(l_accrual);
--
END get_accrual;
--
------------------------- accrual_calc_detail ------------------------------
--
-- This procedure can be called directly this procedure will return start
-- date, end dates etc. which can be used by CO or net calc routines.
--
PROCEDURE accrual_calc_detail
              (P_assignment_id          IN    number,
               P_calculation_date    IN OUT nocopy  date,
               P_plan_id                IN    number   DEFAULT NULL,
               P_plan_category          IN    varchar2 DEFAULT NULL,
               P_mode                   IN    varchar2 DEFAULT 'N',
               P_accrual                OUT nocopy  number,
               P_payroll_id          IN OUT nocopy  number,
               P_first_period_start  IN OUT nocopy  date,
               P_first_period_end    IN OUT nocopy  date,
               P_last_period_start   IN OUT nocopy  date,
               P_last_period_end     IN OUT nocopy  date,
               P_cont_service_date      OUT nocopy  date,
               P_start_date             OUT nocopy  date,
               P_end_date               OUT nocopy  date,
               P_current_ceiling        OUT nocopy  number,
               P_current_carry_over     OUT nocopy  number)  IS
-- Get Plan details
-- lwthomps disabled an index on pev, 13-NOV-1996
CURSOR csr_get_plan_details ( P_business_group Number) is
       select pap.accrual_plan_id,
              pap.accrual_plan_element_type_id,
              pap.accrual_units_of_measure,
              pap.ineligible_period_type,
              pap.ineligible_period_length,
              pap.accrual_start,
              pev.SCREEN_ENTRY_VALUE,
              pee.element_entry_id
       from   pay_accrual_plans            pap,
              pay_element_entry_values_f   pev,
              pay_element_entries_f        pee,
              pay_element_links_f          pel,
              pay_element_types_f          pet,
              pay_input_values_f           piv
       where  ( pap.accrual_plan_id            = p_plan_id     OR
                pap.accrual_category           = P_plan_category )
       and    pap.business_group_id + 0            = P_business_group
       and    pap.accrual_plan_element_type_id = pet.element_type_id
       and    P_calculation_date between pet.effective_start_date and
                                         pet.effective_end_date
       and    pet.element_type_id              = pel.element_type_id
       and    P_calculation_date between pel.effective_start_date and
                                         pel.effective_end_date
       and    pel.element_link_id              = pee.element_link_id
       and    pee.assignment_id                = P_assignment_id
       and    P_calculation_date between pee.effective_start_date and
                                         pee.effective_end_date
       and    piv.element_type_id              =
                                         pap.accrual_plan_element_type_id
       and    piv.name                         = 'Continuous Service Date'
       and    P_calculation_date between piv.effective_start_date and
                                         piv.effective_end_date
       and    pev.element_entry_id             = pee.element_entry_id
       and    pev.input_value_id + 0           = piv.input_value_id
       and    P_calculation_date between pev.effective_start_date and
                                         pev.effective_end_date;
--
--
-- Local Variable
--
l_asg_eff_start_date date   := null;
l_asg_eff_end_date   date   := null;
l_business_group_id  number := null;
l_service_start_date date   := null;
l_termination_date   date   := null;
--
l_calc_period_num    number := 0;
l_calc_start_date    date   := null;
l_calc_end_date      date   := null;
--
l_number_of_period   number := 0;
--
l_acc_plan_type_id   number := 0;
l_acc_plan_ele_type  number := 0;
l_acc_uom            varchar2(30) := null;
l_inelig_period      varchar2(30) := null;
l_inelig_p_length    number := 0;
l_accrual_start      varchar2(30) := null;
l_cont_service_date  date := null;
l_csd_screen_value   varchar2(30) := null;
l_element_entry_id   number := 0;
--
l_plan_start_date    date   := null;
--
l_total_accrual      number := 0;
l_plan_accrual       number := 0;
--
l_temp               varchar2(30) := null;
l_temp_date          date         := null;
--
p_param_first_pstdt  date   := null;
p_param_first_pendt  date   := null;
p_param_first_pnum   number := 0;
p_param_acc_calc_edt date   := null;
p_param_acc_calc_pno number := 0;
--
-- Main process
--
BEGIN
--
  P_payroll_id         := 0;
  P_first_period_start := null;
  P_first_period_end   := null;
  P_last_period_start  := null;
  P_last_period_end    := null;
--
  hr_utility.set_location('get_accrual',5);
---
--- If both param null. RETURN
--
  IF P_plan_id is null AND P_plan_category is null
  THEN
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','get_accrual');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  END IF;

  OPEN  csr_get_payroll(P_assignment_id, P_calculation_date);
  FETCH csr_get_payroll INTO P_payroll_id,
                             l_asg_eff_start_date,
                             l_asg_eff_end_date,
                             l_business_group_id,
                             l_service_start_date,
                             l_termination_date;
  IF csr_get_payroll%NOTFOUND
  THEN
    CLOSE csr_get_payroll;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','get_accrual');
    hr_utility.set_message_token('STEP','2');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_get_payroll;
  hr_utility.set_location('get_accrual',10);
--
-- Get start and end date for the Calculation date
--
  hr_utility.set_location('get_accrual',15);

  OPEN  csr_get_period(P_payroll_id, P_calculation_date);
  FETCH csr_get_period INTO l_calc_period_num,
                            l_calc_start_date,
                            l_calc_end_date;
  IF csr_get_period%NOTFOUND
  THEN
    CLOSE csr_get_period;
      hr_utility.set_message(801,'HR_51731_PTO_DATE_OUT_TIMEPRD');
   -- hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
   -- hr_utility.set_message_token('PROCEDURE','get_accrual');
   -- hr_utility.set_message_token('STEP','3');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_get_period;
  hr_utility.set_location('get_accrual',20);
--
-- Partial first period if start
--
-- Set return dates for the net process if nothing to accrue in this period
--
      P_start_date := l_calc_start_date;
      P_end_date   := P_calculation_date;
--
--
/*
  -- 14 JUN 1995: HPARICHA removed this logic until it can be explained why it's
  -- required.  "Partial first period is start"..?..

  IF l_calc_period_num = 1 AND P_calculation_date < l_calc_end_date
  THEN
    P_accrual := 0;
  ELSE
*/

--
-- Get total number of periods for the year of calculation
--

  OPEN  csr_get_total_periods(P_payroll_id, l_calc_end_date);
  FETCH csr_get_total_periods INTO P_first_period_start,
                                   P_first_period_end,
                                   P_last_period_start,
                                   P_last_period_end,
                                   l_number_of_period;
  IF csr_get_total_periods%NOTFOUND
  THEN
    CLOSE csr_get_total_periods;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','get_accrual');
    hr_utility.set_message_token('STEP','4');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_get_total_periods;
  -- Set l_number_of_period such that it is based on NUMBER_PER_FISCAL_YEAR
  -- for period type of payroll.  Ie. The number returned from
  -- csr_get_total_periods is the number of periods defined for this payroll
  -- in the given calendar year - so payrolls defined mid-year accrue at a
  -- different rate than if it had a full year of payroll periods.
  --
  SELECT number_per_fiscal_year
  INTO   l_number_of_period
  FROM   per_time_period_types TPT,
         pay_payrolls_f PPF
  WHERE  TPT.period_type = PPF.period_type
  AND    PPF.payroll_id = P_payroll_id
  AND    l_calc_end_date BETWEEN PPF.effective_start_date
			     AND PPF.effective_end_date;
  --
  hr_utility.set_location('get_accrual',25);
  --
  -- In case of carry over a dummy date of 31-JUL-YYYY is passed in order to get
  -- the no. of periods first and last period od that year etc. Check if P_mode
  -- is 'C' then set the calculation date to the end date of last period and
  -- get period number for that period again.
  --
  hr_utility.set_location('get_accrual',27);
  IF P_mode = 'C'
  THEN
    l_calc_period_num := l_number_of_period;
    l_calc_start_date := P_last_period_start;
    l_calc_end_date   := P_last_period_end;
    P_calculation_date:= nvl(l_termination_date,P_last_period_end);
  END IF;
  --
  --
  /* Replacing these 3 lines w/call to csr_get_period for 1st period start date.
   Remember the first period number is NOT NECESSARILY "1".
   "p_param_first..." become the beginning of accrual time, need to be
   set according to accrual plans' "Accrual Start Rule" - ie.
	Accrual Start Rule	Accrual Begins
	Beginning of Year	Beginning of year FOLLOWING year of hire.
	Hire Date		As of beginning of month of hire.
	6 Months After Hire	As of beginning of the first full pay period
				following the 6 month anniversary of hire date.

   Note: "Hire Date" above refers to the actual period of service hire date
	 OR the "Continuous Service Date" element entry value on the accrual
	 plan element entry.  This "Continuous Service Date" entry value
         overrides the employee's period of service start (Hire) date.

   ALSO: Does "Beginning of Year" need to deal with case of
         Hire Date = '01-JAN-...." of a calendar year?

  p_param_first_pnum  := 1;
  p_param_first_pstdt := P_first_period_start;
  p_param_first_pendt := P_first_period_end;

  */

  hr_utility.set_location('get_accrual',30);
  OPEN  csr_get_period (P_payroll_id, P_first_period_start);
  FETCH csr_get_period INTO p_param_first_pnum,
                            p_param_first_pstdt,
                            p_param_first_pendt;
  IF csr_get_period%NOTFOUND
  THEN
     CLOSE csr_get_period;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','get_accrual');
     hr_utility.set_message_token('STEP','5');
     hr_utility.raise_error;
  END IF;
  CLOSE csr_get_period;
  --
  --  Check termination date and adjust end date of the last calc Period
  --
  OPEN  csr_get_period (P_payroll_id,
                        nvl(l_termination_date,P_calculation_date));
  FETCH csr_get_period INTO p_param_acc_calc_pno,
                            l_temp_date,
                            p_param_acc_calc_edt;
  IF csr_get_period%NOTFOUND
  THEN
	CLOSE csr_get_period;
        hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE','get_accrual');
        hr_utility.set_message_token('STEP','6');
        hr_utility.raise_error;
  END IF;
  CLOSE csr_get_period;
--
  hr_utility.set_location('get_accrual',35);
--
-- No accruals for the partial periods
--
  IF nvl(l_termination_date,P_calculation_date) < p_param_acc_calc_edt
  THEN
     hr_utility.set_location('get_accrual',36);
     p_param_acc_calc_pno := p_param_acc_calc_pno - 1;
     p_param_acc_calc_edt := l_temp_date - 1;

  END IF;
--
-- Open plan cursor and check at least one plan should be there
--
  hr_utility.set_location('get_accrual',40);
  OPEN  csr_get_plan_details(l_business_group_id);
  FETCH csr_get_plan_details INTO l_acc_plan_type_id,
                                  l_acc_plan_ele_type,
                                  l_acc_uom,
                                  l_inelig_period,
                                  l_inelig_p_length,
                                  l_accrual_start,
                                  l_csd_screen_value,
                                  l_element_entry_id;
  IF csr_get_plan_details%NOTFOUND
  THEN
    CLOSE csr_get_plan_details;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','get_accrual');
    hr_utility.set_message_token('STEP','7');
    hr_utility.raise_error;
  END IF;
--
-- Loop thru all the plans and call function to calc. accruals for a plan
--
  hr_utility.set_location('get_accrual',45);
  LOOP
    l_temp_date := null;
    --
    hr_utility.set_location('get_accrual',50);
    --
    --	"Continous Service Date" is ALWAYS determined by:
    --	1. "Continuous Service Date" entry value on accrual plan.
    --	2. Hire Date of current period of service (ie. in absence of 1.)
    --
    IF l_csd_screen_value is null
    THEN
       hr_utility.set_location('get_accrual',51);
       l_cont_service_date := l_service_start_date;
    ELSE
       hr_utility.set_location('get_accrual',52);
       l_cont_service_date := fnd_date.canonical_to_date(l_csd_screen_value);
    END IF;
    --
    -- The "p_param_first..." variables determine when accrual begins for this
    -- plan and assignment.  Accrual begins according to "Accrual Start Rule" and
    -- hire date as follows:
    -- Accrual Start Rule	Begin Accrual on...
    -- ==================	==================================================
    -- Beginning of Year	First period of new calendar year FOLLOWING hire date.
    -- Hire Date		First period following hire date.
    -- 6 Months After Hire	First period following 6 month anniversary of hire date.
    -- NOTE: "Hire Date" is the "Continuous Service Date" as determined above.
    --
      IF l_accrual_start = 'BOY'
      THEN
          l_temp_date := TRUNC(ADD_MONTHS(l_cont_service_date,12),'YEAR');
          OPEN  csr_get_period (P_payroll_id, l_temp_date);
          FETCH csr_get_period INTO p_param_first_pnum,
                                    p_param_first_pstdt,
                                    p_param_first_pendt;
          IF csr_get_period%NOTFOUND
          THEN
             CLOSE csr_get_period;
             hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','get_accrual');
             hr_utility.set_message_token('STEP','8');
             hr_utility.raise_error;
          END IF;
          CLOSE csr_get_period;
          l_temp_date := null;
      ELSIF l_accrual_start = 'HD'
      THEN
        NULL;
          -- p_param_first... vars have been set above (location get_accrual.30)
      ELSIF l_accrual_start = 'PLUS_SIX_MONTHS'
      THEN
	  --
	  -- Actually get the period in force the day before the six months is up.
	  -- This is because we subsequently get the following period as the one
	  -- in which accruals should start. If a period starts on the six
	  -- month anniversary, the asg should qualify from that period, and
	  -- not have to wait for the next one. Example:
	  --
	  -- Assume monthly periods.
	  --
	  -- l_cont_service_date = 02-Jan-95
	  -- six month anniversary = 02-Jul-95
	  -- accruals start on 01-Aug-95
	  --
	  -- l_cont_service_date = 01-Jan-95
	  -- six month anniversary = 01-Jul-95
	  -- accruals should start on 01-Jul-95, not 01-Aug-95
	  --
	  -- RMF 19-Jan-96.
	  --
          OPEN  csr_get_period (P_payroll_id,
		  	        ADD_MONTHS(l_cont_service_date,6) -1 );
          FETCH csr_get_period INTO p_param_first_pnum,
                                    p_param_first_pstdt,
				    l_temp_date;
          IF csr_get_period%NOTFOUND
          THEN
             CLOSE csr_get_period;
             hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','get_accrual');
             hr_utility.set_message_token('STEP','10');
             hr_utility.raise_error;
          END IF;
          CLOSE csr_get_period;
          --
          OPEN  csr_get_period (P_payroll_id, l_temp_date + 1);
          FETCH csr_get_period INTO p_param_first_pnum,
                                    p_param_first_pstdt,
                                    p_param_first_pendt;
          IF csr_get_period%NOTFOUND
          THEN
             CLOSE csr_get_period;
             hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','get_accrual');
             hr_utility.set_message_token('STEP','11');
             hr_utility.raise_error;
          END IF;
          CLOSE csr_get_period;
          l_temp_date := null;
      END IF;
      hr_utility.set_location('get_accrual',55);
--
--    Add period of ineligibility
--
      IF l_accrual_start   <> 'PLUS_SIX_MONTHS'  AND
         l_inelig_p_length >  0
      THEN
        hr_utility.set_location('get_accrual',60);
        IF l_inelig_period = 'BM'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                    (l_inelig_p_length * 2));
        ELSIF l_inelig_period = 'F'
        THEN
          l_temp_date := fnd_date.canonical_to_date(to_char(l_cont_service_date +
	                  (l_inelig_p_length * 14),'YYYY/MM/DD'));
        ELSIF l_inelig_period = 'CM'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                    l_inelig_p_length);
        ELSIF l_inelig_period = 'LM'
        THEN
          l_temp_date := fnd_date.canonical_to_date(to_char(l_cont_service_date +
	                     (l_inelig_p_length * 28),'YYYY/MM/DD'));
        ELSIF l_inelig_period = 'Q'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                    (l_inelig_p_length * 3));
        ELSIF l_inelig_period = 'SM'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                   (l_inelig_p_length/2));
        ELSIF l_inelig_period = 'SY'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                    (l_inelig_p_length * 6));
        ELSIF l_inelig_period = 'W'
        THEN
          l_temp_date := fnd_date.canonical_to_date(to_char(l_cont_service_date +
	                    (l_inelig_p_length * 7),'YYYY/MM/DD'));
        ELSIF l_inelig_period = 'Y'
        THEN
          l_temp_date := ADD_MONTHS(l_cont_service_date,
                                    (l_inelig_p_length * 12));
        END IF;
      END IF;

--
-- Determine start and end date and setup return parmas.
--    check Period of Service start date, plan element entry start date
--    if later then first period start. Accrual period start date accordingly.
--
      hr_utility.set_location('get_accrual',65);
      select min(effective_start_date)
      into   l_plan_start_date
      from   pay_element_entries_f
      where  element_entry_id = l_element_entry_id;
      hr_utility.set_location('get_accrual',67);
---

--- Set the return params
--
      P_cont_service_date := l_cont_service_date;
      P_start_date := GREATEST(l_service_start_date,l_cont_service_date,
                              l_plan_start_date,P_first_period_start);
      P_end_date   := LEAST(NVL(L_termination_date,P_calculation_date)
                             ,P_calculation_date);

--
    hr_utility.set_location('get_accrual',68);
    IF ( l_temp_date is not null AND
         l_temp_date >= p_param_acc_calc_edt ) OR
       l_cont_service_date >= p_param_acc_calc_edt OR

       p_param_first_pstdt >= p_param_acc_calc_edt

    THEN
      hr_utility.set_location('get_accrual',70);
      l_plan_accrual := 0;
    ELSE
      --
      -- Set the Start Date appropriately.
      -- #305751. Don't understand why this code is here at all, seeing as these
      -- parameters have already been set up above. However, I'll leave the code
      -- alone, except to prevent it from resetting a later start date to earlier,
      -- which sometimes happened on 6 Month plans.  Added a test to prevent the
      -- date being reset if it's already been set, to later than l_temp_date
      -- below. RMF 18-Jan-96.
      --
      l_temp_date := GREATEST(l_service_start_date,l_cont_service_date,
                              l_plan_start_date);
      --
      IF  l_temp_date > P_first_period_start
          AND l_temp_date > nvl(p_param_first_pstdt, l_temp_date - 1)
      THEN
           hr_utility.set_location('get_accrual',71);
           OPEN  csr_get_period (P_payroll_id, l_temp_date);
           FETCH csr_get_period INTO p_param_first_pnum,
                                     p_param_first_pstdt,
                                     p_param_first_pendt;
           IF csr_get_period%NOTFOUND
           THEN
	      CLOSE csr_get_period;
              hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
              hr_utility.set_message_token('PROCEDURE','get_accrual');
              hr_utility.set_message_token('STEP','12');
              hr_utility.raise_error;
           END IF;
           CLOSE csr_get_period;
           hr_utility.set_location('get_accrual',80);
      --
      -- No Accruals fro the partial periods. First period to start the
      -- accrual will be next one.
      --
           IF l_temp_date > p_param_first_pstdt
           THEN
              hr_utility.set_location('get_accrual',85);
              p_param_first_pendt := p_param_first_pendt +1;
              OPEN  csr_get_period (P_payroll_id, p_param_first_pendt);
              FETCH csr_get_period INTO p_param_first_pnum,
                                         p_param_first_pstdt,
                                         p_param_first_pendt;
              IF csr_get_period%NOTFOUND
              THEN
	         CLOSE csr_get_period;
                 hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
                 hr_utility.set_message_token('PROCEDURE','get_accrual');
                 hr_utility.set_message_token('STEP','13');
                 hr_utility.raise_error;
              END IF;
              CLOSE csr_get_period;
           END IF;
      END IF;
      --
      --      Call Function to Calculate accruals for a plan
      --
      IF p_param_acc_calc_edt < P_first_period_end
      THEN
        l_plan_accrual := 0;
      ELSE
      --
        hr_utility.set_location('get_accrual_for_plan',90);
        pay_us_pto_accrual.get_accrual_for_plan
                  ( p_plan_id                 => l_acc_plan_type_id,
                    p_first_p_start_date      => p_param_first_pstdt,
                    p_first_p_end_date        => p_param_first_pendt,
                    p_first_calc_P_number     => p_param_first_pnum,
                    p_accrual_calc_p_end_date => p_param_acc_calc_edt,
                    P_accrual_calc_P_number   => p_param_acc_calc_pno,
                    P_number_of_periods       => l_number_of_period,
                    P_payroll_id              => P_payroll_id,
                    P_assignment_id           => P_assignment_id,
                    P_plan_ele_type_id        => l_acc_plan_ele_type,
                    P_continuous_service_date => l_cont_service_date,
                    P_Plan_accrual            => l_plan_accrual,
                    P_current_ceiling         => P_current_ceiling,
                    P_current_carry_over      => P_current_carry_over);
      END IF;
      --
    END IF;
--
--    Add accrual to the total and Fetch next set of plan
--
    hr_utility.set_location('get_accrual',95);
    l_total_accrual := l_total_accrual + l_plan_accrual;
    l_plan_accrual  := 0;

    FETCH csr_get_plan_details INTO l_acc_plan_type_id,
                                    l_acc_plan_ele_type,
                                    l_acc_uom,
                                    l_inelig_period,
                                    l_inelig_p_length,
                                    l_accrual_start,
                                    l_csd_screen_value,
                                    l_element_entry_id;
--

    EXIT WHEN csr_get_plan_details%NOTFOUND;
    hr_utility.set_location('get_accrual',100);
--
  END LOOP;
--
  CLOSE csr_get_plan_details;
--
  IF l_total_accrual is null
  THEN
     hr_utility.set_location('get_accrual',105);
     l_total_accrual := 0;
  END IF;
  hr_utility.set_location('get_accrual',110);
  l_total_accrual := round(l_total_accrual,3);
  P_accrual := l_total_accrual;
--
-- Partial first period if end
--
/*
 END IF; -- Start Date...partial eh?
*/

--
END accrual_calc_detail;
--
---------------- get_accrual_for_plan -------------------------------------
--
PROCEDURE get_accrual_for_plan
                    ( p_plan_id                 Number,
                      p_first_p_start_date      date,
                      p_first_p_end_date        date,
                      p_first_calc_P_number     number,
                      p_accrual_calc_p_end_date date,
                      P_accrual_calc_P_number   number,
                      P_number_of_periods       number,
                      P_payroll_id              number,
                      P_assignment_id           number,
                      P_plan_ele_type_id        number,
                      P_continuous_service_date date,
                      P_Plan_accrual            OUT nocopy number,
                      P_current_ceiling         OUT nocopy number,
                      P_current_carry_over      OUT nocopy number) IS
--
--
CURSOR csr_all_asg_status is
       select a.effective_start_date,
              a.effective_end_date,
              b.PER_SYSTEM_STATUS
       from   per_assignments_f           a,
              per_assignment_status_types b
       where  a.assignment_id       = P_assignment_id
       and    a.effective_end_date between p_first_p_start_date and
                                   to_date('31-12-4712','DD-MM-YYYY')
       and    a.ASSIGNMENT_STATUS_TYPE_ID =
                                      b.ASSIGNMENT_STATUS_TYPE_ID;
--
--
CURSOR csr_get_bands (P_time_worked number ) is
       select annual_rate,
              ceiling,
              lower_limit,
              upper_limit,
              max_carry_over
       from   pay_accrual_bands
       where  accrual_plan_id     = P_plan_id
       and    P_time_worked      >= lower_limit
       and    P_time_worked      <  upper_limit;
--
-- #305751 I think this cursor is intended to get all the time periods over
-- which the accrual should be calculated. However, it looks as if the select
-- only gets the numbered periods for which the asg qualified in its first year.
-- So, if they qualified from Aug in year 1, this cursor only ever returns
-- the periods from Aug onwards. Perhaps this was put in to make the first
-- year work correctly, but it works too widely.
--
-- Revised the cursor so it picks up all the time periods from the start of
-- year to the current point unless the asg only qualified for the plan at
-- some point during the year, in which case start from then. The old version
-- of the cursor is retained here, commented out.
--
-- The decode in the cursor means: "If the year for which we're doing the
-- calculation is also the year in which the asg qualified for the plan, just
-- take it from the first qualifying period; otherwise, take it from the
-- first period of the year. RMF 18-Jan96.
--
-- CURSOR csr_get_time_periods is
--        select start_date,
--               end_date,
--              period_num
--       from   per_time_periods
--       where  to_char(end_date,'YYYY') =
--                         to_char(p_first_p_end_date,'YYYY')
--       and    end_date                  <= p_accrual_calc_p_end_date
--       and    period_num                >= p_first_calc_P_number
--       and    payroll_id                 = p_payroll_id
--ORDER by period_num;
--
CURSOR csr_get_time_periods is
       select start_date,
              end_date,
              period_num
       from   per_time_periods
       where  to_char(end_date,'YYYY') =
                         to_char(p_accrual_calc_p_end_date,'YYYY')
       and    end_date                 <= p_accrual_calc_p_end_date
       and    period_num               >=
		decode (to_char(p_first_p_start_date,'YYYY'),
			to_char(p_accrual_calc_p_end_date,'YYYY'),
			p_first_calc_P_number, 1)
       and    payroll_id                 = p_payroll_id
ORDER by period_num;
--
--
--Local varaiables
l_start_Date         date :=null;
l_end_date           date :=null;
l_period_num         number := 0;
l_asg_eff_start_date date := null;
l_asg_eff_end_date   date := null;
l_asg_status         varchar2(30) := null;
l_acc_rate_pp_1      number := 0;
l_acc_rate_pp_2      number := 0;
l_acc_deds           number := 0;
l_annual_rate        number := 0;
l_ceiling_1          number := 0;
l_ceiling_2          number := 0;
l_carry_over_1       number := 0;
l_carry_over_2       number := 0;
l_lower_limit        number := 0;
l_upper_limit        number := 0;
l_year_1             number := 0;
l_year_2             number := 0;
l_accrual            number := 0;
l_temp               number := 0;
l_temp2              varchar2(30) := null;
l_band_change_date   date   := null;
l_ceiling_flag       varchar2(1) := 'N';
l_curr_p_stdt        date   := null;
l_curr_p_endt        date   := null;
l_curr_p_num         number := 0;
l_mult_factor        number := 0;
l_unpaid_day         number := 0;
l_vac_taken          number := 0;
l_prev_end_date      date   := null;
l_running_total      number := 0;
l_curr_p_acc         number := 0;
l_working_day        number := 0;
l_curr_ceiling       number := 0;
--
--
BEGIN
--
  hr_utility.set_location('get_accrual_for_plan',1);
  l_year_1 := TRUNC(ABS(months_between(P_continuous_service_date,
                             P_first_p_end_date)/12));
  l_year_2 := TRUNC(ABS(months_between(P_continuous_service_date,
                             p_accrual_calc_p_end_date)/12));

--
-- Get the band details using the years of service.
--
  OPEN  csr_get_bands (l_year_1);
  FETCH csr_get_bands INTO l_annual_rate,l_ceiling_1,
                           l_lower_limit,l_upper_limit,
                           l_carry_over_1;
  hr_utility.set_location('get_accrual_for_plan',5);

  IF csr_get_bands%NOTFOUND THEN
     l_acc_rate_pp_1 := 0;
  ELSE
     l_acc_rate_pp_1 := l_annual_rate/P_number_of_periods;
     IF l_ceiling_1 is not null THEN
        l_ceiling_flag := 'Y';
     END IF;
  END IF;
  CLOSE csr_get_bands;
  hr_utility.set_location('get_accrual_for_plan',10);
  --
  IF l_year_2 < l_upper_limit and l_acc_rate_pp_1 > 0 THEN
     l_acc_rate_pp_2 := 0;
  ELSE
     hr_utility.set_location('get_accrual_for_plan',15);
     OPEN  csr_get_bands (l_year_2);
     FETCH csr_get_bands INTO l_annual_rate,l_ceiling_2,
                              l_lower_limit,l_upper_limit,
                              l_carry_over_2;

     IF csr_get_bands%NOTFOUND THEN
--        CLOSE csr_get_bands;   -- bug 672443
        l_accrual := 0;
        P_current_ceiling    := 0;
        P_current_carry_over := 0;
        CLOSE csr_get_bands;
        GOTO exit_out;
     ELSE
        l_acc_rate_pp_2 := l_annual_rate/P_number_of_periods;
        IF l_ceiling_1 is not null THEN
           l_ceiling_flag := 'Y';
        END IF;
        CLOSE csr_get_bands;
     END IF;
  END IF;
  hr_utility.set_location('get_accrual_for_plan',20);
--
--
  IF ((l_acc_rate_pp_1 <> l_acc_rate_pp_2) AND
       l_acc_rate_pp_2 <> 0 ) THEN
     l_temp := trunc(ABS(months_between(P_continuous_service_date,
                             p_accrual_calc_p_end_date))/12) * 12 ;

     l_band_change_date := ADD_MONTHS(P_continuous_service_date,l_temp);

  ELSE
     l_band_change_date := (p_accrual_calc_p_end_date + 2);

  END IF;
  --
  -- Set output params.
  --
  IF l_ceiling_2 = 0 OR l_ceiling_2 is null
  THEN
     P_current_ceiling := l_ceiling_1;
  ELSE
     P_current_ceiling := l_ceiling_2;
  END IF;
  --
  IF l_carry_over_2 = 0 OR l_carry_over_2 is null
  THEN
     P_current_carry_over := l_carry_over_1;
  ELSE
     P_current_carry_over := l_carry_over_2;
  END IF;
  --
  hr_utility.set_location('get_accrual_for_plan',25);
  OPEN  csr_all_asg_status;
  FETCH csr_all_asg_status into l_asg_eff_start_date,
                                l_asg_eff_end_date,
                                l_asg_status;
  hr_utility.set_location('get_accrual_for_plan',30);
  --
  -- Check if calc method should use ceiling calculation or Non-ceiling
  -- calculation. For simplicity if there is any asg. status change then
  -- ceiling calculation method is used.
  --
  IF l_ceiling_flag = 'N'
     and  (p_first_p_end_date   	>= l_asg_eff_start_date
     and   p_accrual_calc_p_end_date    <= l_asg_eff_end_date
     and   l_asg_status                  =  'ACTIVE_ASSIGN') THEN
    --
    -- Non Ceiling Calc
    --
    OPEN  csr_get_period(P_Payroll_id, l_band_change_date);
    FETCH csr_get_period INTO l_curr_p_num,l_curr_p_stdt,l_curr_p_endt;
    hr_utility.set_location('get_accrual_for_plan',35);
    IF csr_get_period%NOTFOUND THEN
      CLOSE csr_get_period;
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','get_accrual_for_plan');
      hr_utility.set_message_token('STEP','14');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_get_period;
--
-- gpaytonm 15-nov mod - added close csr_get_period
--
    --
    hr_utility.set_location('get_accrual_for_plan',40);
    if l_curr_p_num = 1 AND
      p_accrual_calc_p_end_date < l_band_change_date
    then
      l_curr_p_num := P_number_of_periods;
    elsif p_accrual_calc_p_end_date >= l_band_change_date  then
      l_curr_p_num := l_curr_p_num - 1;
    else
      l_curr_p_num := P_accrual_calc_P_number;
    end if;
    --
    -- Entitlement from first period to Band change date.
    --
    l_accrual := l_acc_rate_pp_1 * (l_curr_p_num - (p_first_calc_P_number - 1));
    hr_utility.set_location('get_accrual_for_plan',45);
    --
    -- Entitlement from Band change date to Calc. date
    --
    IF p_accrual_calc_p_end_date >= l_band_change_date  THEN
      l_accrual := l_accrual + l_acc_rate_pp_2 * (P_accrual_calc_P_number - l_curr_p_num);
    END IF;
 ELSE
   --
   -- Ceiling Calc
   --
   hr_utility.set_location('get_accrual_for_plan',50);
   OPEN  csr_get_time_periods;
   l_running_total := 0;
   l_curr_p_acc    := 0;
   LOOP
     hr_utility.set_location('get_accrual_for_plan',55);
     FETCH csr_get_time_periods into l_start_Date,
                                       	l_end_date,
                                       	l_period_num;
     EXIT WHEN csr_get_time_periods%NOTFOUND;
     IF l_period_num > P_accrual_calc_P_number then
       EXIT;
     END IF;
  	--
  	-- #305751 Remove the following IF statement. The csr_get_time_periods cursor
  	-- already restricts which period numbers we get.
  	--
  	--   IF l_period_num >= p_first_calc_P_number then
  	--      Check for Any assignment status change in the current period
  	--
        	l_mult_factor   := 1;
        	l_working_day   := 0;
        	l_unpaid_day    := 0;
        	l_vac_taken     := 0;
        	l_prev_end_date := l_asg_eff_end_date;
        	hr_utility.set_location('get_accrual_for_plan',60);
        	--
        	IF l_asg_eff_end_date between l_start_Date and l_end_date
        	THEN
          	  IF l_asg_status <> 'ACTIVE_ASSIGN' THEN
             	  l_unpaid_day := get_working_days(l_start_Date,
                                              l_asg_eff_end_date);
            	END IF;
          	--
          	--
          	hr_utility.set_location('get_accrual_for_plan',65);
          	LOOP
            		hr_utility.set_location('get_accrual_for_plan',70);
            		l_prev_end_date := l_asg_eff_end_date;
            		FETCH csr_all_asg_status into 	l_asg_eff_start_date,
                                         		l_asg_eff_end_date,
                                          		l_asg_status;
            		IF csr_all_asg_status%NOTFOUND THEN
               		  CLOSE csr_all_asg_status;
               		  EXIT;
            		ELSIF l_asg_status <> 'ACTIVE_ASSIGN'  and
                  	  l_asg_eff_start_date <= l_end_date
            		THEN
               		  l_unpaid_day := l_unpaid_day +
                          get_working_days(l_asg_eff_start_date,
                          least(l_end_date,l_asg_eff_end_date));
            		END IF;
            	EXIT WHEN l_asg_eff_end_date > l_end_date;
          	END LOOP;
           	--
           	--
 ELSIF csr_all_asg_status%ISOPEN and l_asg_status <> 'ACTIVE_ASSIGN'   THEN
   l_mult_factor   := 0;
   hr_utility.set_location('get_accrual_for_plan',75);
 ELSIF NOT (csr_all_asg_status%ISOPEN ) THEN
    hr_utility.set_location('get_accrual_for_plan',80);
    l_mult_factor   := 0;
 ELSE
    hr_utility.set_location('get_accrual_for_plan',85);
    l_mult_factor   := 1;
 END IF;
 --
 --
 IF l_unpaid_day <> 0 THEN
    hr_utility.set_location('get_accrual_for_plan',90);
    l_working_day := get_working_days(l_start_Date,l_end_date);
    IF l_working_day = l_unpaid_day THEN
       l_mult_factor := 0;
    ELSE
       l_mult_factor := (1 - (l_unpaid_day/l_working_day));
    END IF;
 END IF;
--
-- Find out vacation and carry over if the method is ceiling
--
 IF l_ceiling_flag = 'Y' THEN
    hr_utility.set_location('get_accrual_for_plan',95);
    OPEN  csr_calc_accrual(l_start_Date,    l_end_date,
                           P_assignment_id, P_plan_id);
    FETCH csr_calc_accrual INTO l_vac_taken;
    IF csr_calc_accrual%NOTFOUND  or l_vac_taken is null THEN
           l_vac_taken := 0;
    END IF;
           CLOSE csr_calc_accrual;
 END IF;
 --
 --  Multiply the Accrual rate for the current band and  Multiplication
 --  Factor to get current period accrual.
 --
  hr_utility.set_location('get_accrual_for_plan',100);
  IF (l_band_change_date between l_start_Date and l_end_date)
      OR ( l_band_change_date < l_end_date)
  THEN
     l_curr_p_acc   := l_acc_rate_pp_2 * l_mult_factor;
     l_curr_ceiling := l_ceiling_2;
  ELSE
     l_curr_p_acc   := l_acc_rate_pp_1 * l_mult_factor;
     l_curr_ceiling := l_ceiling_1;
  END IF;
  --
  --
  --   Check for ceiling limits
  --
  hr_utility.set_location('get_accrual_for_plan',105);
  IF l_ceiling_flag = 'Y' THEN
     l_running_total := l_running_total + l_vac_taken + l_curr_p_acc;
     IF l_running_total > l_curr_ceiling THEN
        IF (l_running_total - l_curr_ceiling) < l_curr_p_acc
           THEN
              l_temp    := (l_curr_p_acc -
                           (l_running_total - l_curr_ceiling));
              l_accrual := l_accrual + l_temp;
              l_running_total := l_running_total + l_temp;
         END IF;
              l_running_total := l_running_total - l_curr_p_acc;
         ELSE
              l_accrual := l_accrual + l_curr_p_acc;
         END IF;
     ELSE
       l_accrual := l_accrual + l_curr_p_acc;
     END IF;
     hr_utility.set_location('get_accrual_for_plan',110);
     --
     --
     -- #305751 Remove the END IF matching the removed IF above.
     --
     --   END IF;
     --
   END LOOP;
   --
   CLOSE csr_get_time_periods;
  --
  END IF;
--
--
IF l_accrual is null THEN
   l_accrual := 0;
END IF;
--
<<exit_out>>
P_Plan_accrual := l_accrual;
--
--
END get_accrual_for_plan;
--
--------------------------- get_working_days ------------------------
--
FUNCTION get_working_days (P_start_date date,
                           P_end_date   date )
         RETURN   NUMBER is
l_total_days    NUMBER        := 0;
l_curr_date     DATE          := NULL;
l_curr_day      VARCHAR2(3)   := NULL;
--
BEGIN
--
-- Check for valid range
hr_utility.set_location('get_working_days', 5);
IF p_start_date > P_end_date THEN
  hr_utility.set_location('get_working_days', 8);
  RETURN l_total_days;
END IF;
--
l_curr_date := P_start_date;
hr_utility.set_location('get_working_days', 10);
LOOP
  l_curr_day := TO_CHAR(l_curr_date, 'DY');
  hr_utility.set_location('get_working_days', 15);
  IF UPPER(l_curr_day) in ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
    l_total_days := l_total_days + 1;
    hr_utility.set_location('get_working_days', 20);
  END IF;
  l_curr_date := l_curr_date + 1;
  EXIT WHEN l_curr_date > P_end_date;
END LOOP;
--
RETURN l_total_days;
--
END get_working_days;
--
--
----------------------- get_net_accrual --------------------------------------
--
FUNCTION get_net_accrual
                    ( P_assignment_id        number,
                      P_calculation_date     date,
                      P_plan_id              number   default null,
                      P_plan_category        Varchar2 default null,
                      P_assignment_action_id number   default null)
         RETURN NUMBER is
--
--
-- Function calls the actual proc. which will calc. net accrual and pass back
-- the details.In formula we will call functions so this will be the cover
-- function to call the proc.
--

cursor c_asg_details is
select business_group_id,
       payroll_id
from per_all_assignments_f
where assignment_id = p_assignment_id
and p_calculation_date between effective_start_date
                       and     effective_end_date;

l_proc                 varchar2(80) := g_package||'get_net_accrual';
l_entitlement          number := 0;
l_payroll_id           number;
l_business_group_id    number;
l_assignment_action_id number;

--
c_date date := P_calculation_date;
n1 number;
n2 number;
n3 number;
n4 number;
d1 date;
d2 date;
d3 date;
d4 date;
d5 date;
d6 date;
d7 date;
--
BEGIN
--
  hr_utility.set_location('Entering: '||l_proc, 10);

  IF NOT use_fast_formula(p_effective_date => p_calculation_date
                         ,p_plan_id        => p_plan_id) THEN
    --
    -- It has been determined that:
    --   a) the Fast Formula used by this accrual plan contain
    --      the same logic as the old 10.7 PL/SQL code and
    --   b) this accrual plan does not store accruals in a
    --      payroll balance.
    -- For this reason, the old 10.7 code is called because it
    -- is significantly faster than executing Fast Formula.
    --
    hr_utility.set_location(l_proc, 20);

    pay_us_pto_accrual.net_accruals(
       P_assignment_id      => P_assignment_id,
       P_calculation_date   => c_date,
       P_plan_id            => P_plan_id,
       P_plan_category      => P_plan_category,
       P_mode               => 'N',
       P_accrual            => n4,
       P_net_accrual        => l_entitlement,
       P_payroll_id         => n1,
       P_first_period_start => d1,
       P_first_period_end   => d2,
       P_last_period_start  => d3,
       P_last_period_end    => d4,
       P_cont_service_date  => d5,
       P_start_date         => d6,
       P_end_date           => d7,
       P_current_ceiling    => n2,
       P_current_carry_over => n3);

    if l_entitlement is null then
      l_entitlement := 0;
    end if;
  --
  ELSE
    --
    -- It has been determined that:
    --   a) the Fast Formula used by this accrual plan differ
    --      from the logic used in the old 10.7 PL/SQL code or
    --   b) this accrual plan stores the accruals in a payroll
    --      balance.
    -- For either of these reasons, the newer call to
    -- get_net_accrual (in per_accrual_calc_functions) is used.
    --
    -- If the assignment_action_id is passed the accruals are
    -- simply retrieved from a payroll balance, if the
    -- assignment_action_id is not passed, the Fast Formula
    -- must instead be executed.
    --
    open c_asg_details;
    fetch c_asg_details into l_business_group_id,
                             l_payroll_id;
    close c_asg_details;

    -- Here we set a null assignment_action_id to -1 to prevent
    -- an error running the Accrual formula later.

    if p_assignment_action_id is null then
      l_assignment_action_id := -1;
    else
      l_assignment_action_id := p_assignment_action_id;
    end if;

    hr_utility.set_location(l_proc, 30);

    per_accrual_calc_functions.get_net_accrual(
       P_assignment_id          => p_assignment_id,
       P_plan_id                => p_plan_id,
       P_payroll_id             => l_payroll_id,
       p_business_group_id      => l_business_group_id,
       p_assignment_action_id   => l_assignment_action_id,
       P_calculation_date       => p_calculation_date,
       p_accrual_start_date     => null,
       p_accrual_latest_balance => null,
       p_calling_point          => 'BP',
       P_start_date             => d1,
       P_End_Date               => d2,
       P_Accrual_End_Date       => d3,
       P_accrual                => n1,
       P_net_entitlement        => l_entitlement
       );
  --
  end if;

  hr_utility.trace('l_entitlement: '||to_char(l_entitlement));

  hr_utility.set_location('Leaving: '||l_proc, 90);

  RETURN(l_entitlement);
--
END get_net_accrual;
---
---
--------------------------- net_accruals -----------------------------------
--
--
-- This procedure can be called directly this procedure will return start
-- date, end dates etc. which can be used by CO.
--
PROCEDURE net_accruals
              (P_assignment_id          IN    number,
               P_calculation_date    IN OUT nocopy  date,
               P_plan_id                IN    number   DEFAULT NULL,
               P_plan_category          IN    varchar2 DEFAULT NULL,
               P_mode                   IN    varchar2 DEFAULT 'N',
               P_accrual             IN OUT nocopy  number,
               P_net_accrual            OUT nocopy  number,
               P_payroll_id          IN OUT nocopy  number,
               P_first_period_start  IN OUT nocopy  date,
               P_first_period_end    IN OUT nocopy  date,
               P_last_period_start   IN OUT nocopy  date,
               P_last_period_end     IN OUT nocopy  date,
               P_cont_service_date      OUT nocopy  date,
               P_start_date          IN OUT nocopy  date,
               P_end_date            IN OUT nocopy  date,
               P_current_ceiling        OUT nocopy  number,
               P_current_carry_over     OUT nocopy  number)  IS
--
--
l_taken              number := 0;
--
l_temp               number := 0;
--
BEGIN
--
-- Get vaction accrued
--
  hr_utility.set_location('get_net_accrual',5);
  pay_us_pto_accrual.accrual_calc_detail(
       P_assignment_id      => P_assignment_id,
       P_calculation_date   => P_calculation_date,
       P_plan_id            => P_plan_id,
       P_plan_category      => P_plan_category,
       P_mode               => P_mode,
       P_accrual            => P_accrual,
       P_payroll_id         => P_payroll_id,
       P_first_period_start => P_first_period_start,
       P_first_period_end   => P_first_period_end,
       P_last_period_start  => P_last_period_start,
       P_last_period_end    => P_last_period_end,
       P_cont_service_date  => P_cont_service_date,
       P_start_date         => P_start_date,
       P_end_date           => P_end_date,
       P_current_ceiling    => P_current_ceiling,
       P_current_carry_over => P_current_carry_over);
--
-- Get vac taken purchase etc using net Calc rules.
--

   OPEN  csr_calc_accrual(P_start_Date,    P_end_date,
                          P_assignment_id, P_plan_id);
   FETCH csr_calc_accrual INTO l_taken;
   IF csr_calc_accrual%NOTFOUND  or
      l_taken is null
   THEN
      l_taken := 0;
   END IF;
   CLOSE csr_calc_accrual;
   hr_utility.set_location('get_net_accrual',20);
--
--
   P_net_accrual := ROUND((P_accrual + l_taken),3);

--
-- if mode is carry over then return next years first period start
-- and end dates in P_start_date nad P_end_date params.
--
   IF P_mode = 'C'
   THEN
     OPEN csr_get_period(p_payroll_id,(P_last_period_end +1));
     hr_utility.set_location('get_net_accrual',21);
     FETCH csr_get_period into l_temp,P_start_date,P_end_date;
     IF csr_get_period%NOTFOUND THEN
       CLOSE csr_get_period;
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','net_accruals');
       hr_utility.set_message_token('STEP','15');
       hr_utility.raise_error;
     END IF;
     CLOSE csr_get_period;
     hr_utility.set_location('get_net_accrual',22);
   END IF;
--
--
END net_accruals;
--
END pay_us_pto_accrual;

/
