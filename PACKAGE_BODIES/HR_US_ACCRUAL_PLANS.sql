--------------------------------------------------------
--  DDL for Package Body HR_US_ACCRUAL_PLANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_US_ACCRUAL_PLANS" as
/* $Header: pyusaccr.pkb 120.3 2006/07/31 07:39:13 risgupta noship $ */
/*
+======================================================================+
|                Copyright (c) 1994 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : hr_us_accrual_plans
    Filename	: pyusudfs.sql
    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    26-JAN-95	hparicha	40.0	G1565	Vacation/Sick correlation
						to Regular Pay - changes to
						Calc Period Earns.
						Also need separate fn to calc
						Vac/Sick Pay as well as a fn
						to check for entry of Vac/Sick
						Hours against an accrual plan.
    09-JUL-95	hparicha	40.1	282299	Check accrual ineligibility.
						Currently only used from
						PayMIX.
    04-OCT-95   ramurthy        40.3    312537  Added NO_DATA_FOUND
						exception in procedure
						get_accrual_ineligibility.
    05-Jan-96   rfine           40.4    323214  Prevented TOO_MANY_ROWS error
						when > 1 Plan has the same
						absence element.
    11-JAN-96   ramurthy	40.5	326766	Changed procedure
						get_accrual_ineligibility
						to handle accrual start rules
						'Hire Date' and 'Beginning
						of Year' when they do not
						have any period of
						ineligibility.  That is,
						the eligible dates are now
						set accordingly.
    04-NOV-96	hparicha	40.6	408507	Changed accrual_time_taken
						function to sum entry values
						for vacation or sick time taken.
    16-MAR-99   alogue         115.1            Support of new accrual functionality
                                                by use of ineligibility_formula_id.
    07-APR-99   alogue         115.2            Canonical date support in ff
                                                pl sql engine call within
                                                get_accrual_ineligibility.
    08-APR-99  djoshi          115.3            Verfied and converted for Canonical
                                                Complience of Date
    15-APR-99  VMehta          115.4  764244    Accessing the
	per_periods_of_service through a
						date effective join


    21-Apr-99   scgrant        115.5            Multi-radix changes.
--
    26-FEB-02   Rmonge         115.6            Fix for bug 2006907

    03-SEP-03   rmonge         115.10           Removed NOCOPY from
                                                in arguments.
     20-SEP-05   ghshanka      115.11            bug 4123194 deleted the functions
						calc_accrual_pay and accrual_time_taken .
     29-Nov-05  irgonzal       115.12           Bug fix 4762608. Altered
                                                get_accrual_ineligibility procedure.
                                                Handled scenario when accrual plan
                                                does not have a "start date" rule.
     31-AUG-06  risgupta       115.13  5405255 obsoleted functions being re-added on request
                                               of US payroll
    Description: User-Defined Functions required for US implementations.
*/
--
-- **********************************************************************

--
--  Procedure
--     get_accrual_ineligibility
--
--  Purpose
--     Check for accrual plan ineligibility period and indicate if the current
--     assignment is within the ineligible period - ie. the batch line entry
--     for time taken against the accrual should be invalidated.
--
--  Arguments
--     p_iv_id
--     p_bg_id
--     p_asg_id
--     p_sess_date
--
--  History
--     8th July 1995     Hankins Parichabutr	Created.
--     4th Oct  1995     Ranjana Murthy         Added NO_DATA_FOUND exception
--     05-Jan-96  rfine            323214  Prevented TOO_MANY_ROWS error when
--					   > 1 Plan has the same absence element
--     11-JAN-96  ramurthy	   326766  Set eligible dates properly for
--					   start rules 'Hire Date' and
--					   'Beginning of Year'.
--
PROCEDURE get_accrual_ineligibility(	p_iv_id    	IN NUMBER,
				      	p_bg_id  	IN NUMBER,
					p_asg_id 	IN NUMBER,
					p_sess_date	IN DATE,
					p_eligible   	OUT NOCOPY VARCHAR2
		              		) IS

v_inel_length		NUMBER(2);
v_inel_period_type	VARCHAR2(30);
v_start_rule		VARCHAR2(30);
v_service_start		DATE;
v_inel_days		NUMBER(9);
v_semi_days		NUMBER(9);
v_eligible_date		DATE;
v_plan_id               NUMBER(9);
v_formula_id            NUMBER(9);
l_inputs                ff_exec.inputs_t;
l_outputs               ff_exec.outputs_t;

CURSOR	plan_for_input_value IS
SELECT	nvl(ineligible_period_length, 0),
	ineligible_period_type,
	accrual_start,
        accrual_plan_id,
        ineligibility_formula_id
FROM	PAY_ACCRUAL_PLANS
WHERE	pto_input_value_id	= p_iv_id
AND	business_group_id	= p_bg_id;

BEGIN

  --
  -- Check that this input value is used for accrual pto recording.
  -- #323214 Redefined as an explicit cursor with an unlooped fetch.
  -- This prevents a TOO_MANY_ROWS error when > 1 Plan has the same
  -- absence element.
  --
  -- However, if this is the case, note that you cannot guarantee which
  -- plan for the absence element the details are being retrieved from. There
  -- may come a subsequent Enhancement Request to prevent users from setting
  -- up more than one plan with the same absence element. RMF 05-Jan-96.
  --
  hr_utility.set_location('get_accrual_ineligibility', 1);

  open  plan_for_input_value;
  fetch plan_for_input_value into v_inel_length,
				  v_inel_period_type,
				  v_start_rule,
                                  v_plan_id,
                                  v_formula_id;
  --
  -- If there is no associated plan, there is no further work to be
  -- done in this procedure.
  --
  if plan_for_input_value%notfound then
    close  plan_for_input_value;
    return;
  end if;
  --
  hr_utility.set_location('get_accrual_ineligibility', 2);

  close  plan_for_input_value;

  -- Now check for the assignment's enrollment into the plan
  -- and the assignment's length of service relative to ineligible period.

  SELECT	pps.date_start
  INTO		v_service_start
  FROM		per_periods_of_service	pps,
		per_assignments_f	paf
  WHERE		paf.assignment_id	= p_asg_id
  AND		p_sess_date	BETWEEN paf.effective_start_date
				AND	paf.effective_end_date
  AND		pps.person_id		= paf.person_id
  AND		paf.business_group_id	= p_bg_id
  AND		p_sess_date	BETWEEN pps.date_start AND pps.final_process_date;

  if v_formula_id is null then

     --
     --  As no eligibility formula, we use the info in the
     --  accrual plan table to check for ineligibility
     --

     -- First check ineligible period, then check accrual start...

     hr_utility.set_location('get_accrual_ineligibility', 3);
     hr_utility.trace('Service Start is: ' || v_service_start);
     hr_utility.trace('Ineligible length is:' || v_inel_length);

     IF v_inel_length <> 0 THEN

       hr_utility.set_location('get_accrual_ineligibility', 4);

       -- Calculate how many days are ineligible...
       IF v_inel_period_type = 'CM' THEN

         v_eligible_date := ADD_MONTHS(v_service_start, v_inel_length);

       ELSIF v_inel_period_type = 'W' THEN

         v_eligible_date := v_service_start + (v_inel_length * 7);

       ELSIF v_inel_period_type = 'F' THEN

         v_eligible_date := v_service_start + (v_inel_length * 14);

       ELSIF v_inel_period_type = 'SM' THEN

         v_semi_days := MOD(v_inel_length, 2);

         IF v_semi_days <> 0 THEN

           v_semi_days := 15;	-- ie. an odd number of semi-months.

         END IF;

         v_eligible_date := ADD_MONTHS(v_service_start, (v_inel_length / 2));
         v_eligible_date := v_eligible_date + v_semi_days;

       ELSIF v_inel_period_type = 'Q' THEN

         v_eligible_date := ADD_MONTHS(v_service_start, (v_inel_length * 3));

       ELSIF v_inel_period_type = 'Y' THEN

         v_eligible_date := ADD_MONTHS(v_service_start, (v_inel_length * 12));

       ELSIF v_inel_period_type = 'SY' THEN

         v_eligible_date := ADD_MONTHS(v_service_start, (v_inel_length * 6));

       ELSIF v_inel_period_type = 'LM' THEN

         v_eligible_date := v_service_start + (v_inel_length * 26);

       ELSIF v_inel_period_type = 'BM' THEN

         v_eligible_date := ADD_MONTHS(v_service_start, (v_inel_length * 2));

       END IF;	-- Inel Period Types

     ELSIF v_start_rule = 'PLUS_SIX_MONTHS' THEN

       -- Inel length = 0, check Accrual Start for 6 month inel.
       -- Ie. you can't take time against an accrual for which you haven't
       -- started accruing!

       v_eligible_date := ADD_MONTHS(v_service_start, 6);

     ELSIF v_start_rule = 'HD' then

       v_eligible_date := v_service_start;

     ELSIF v_start_rule = 'BOY' then

       v_eligible_date := TRUNC(ADD_MONTHS(v_service_start, 12), 'YEAR');

     END IF;

     hr_utility.set_location('get_accrual_ineligibility', 5);
     hr_utility.trace('Eligible Date is: ' || v_eligible_date);
     hr_utility.trace('Session Date is: ' || p_sess_date);

     -- Eligible or what?

     IF p_sess_date >= nvl(v_eligible_date,p_sess_date) THEN -- #4762608
       hr_utility.set_location('get_accrual_ineligibility', 6);

       p_eligible := 'Y';

     ELSE
       hr_utility.set_location('get_accrual_ineligibility', 7);

       p_eligible := 'N';

     END IF;

  else
     --
     -- Use ineligibilty accrual plan formula to calculate
     -- ineligibility
     --

     -- Initialise the Inputs and  Outputs tables
     ff_exec.init_formula
        ( v_formula_id
        , p_sess_date
        , l_inputs
        , l_outputs );
--
     -- Set up context values for the formula
     for i in l_inputs.first..l_inputs.last loop

       if l_inputs(i).name = 'DATE_EARNED' then
         l_inputs(i).value := p_sess_date;

       elsif l_inputs(i).name = 'ASSIGNMENT_ID' then
         l_inputs(i).value := p_asg_id;

       elsif l_inputs(i).name = 'ACCRUAL_PLAN_ID' then
         l_inputs(i).value := v_plan_id;

       end if;
     end loop;

     -- Run the formula
     ff_exec.run_formula( l_inputs, l_outputs );

     -- Get the result
     p_eligible := l_outputs(l_outputs.first).value;

  end if;

EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;

END get_accrual_ineligibility;

--
-- **********************************************************************

FUNCTION calc_accrual_pay (	p_bg_id		IN   NUMBER,
				p_asg_id 	IN   NUMBER,
				p_eff_date	IN   DATE,
				p_hours_taken 	IN   NUMBER,
				p_curr_rate	IN   NUMBER,
				p_mode		IN   VARCHAR2) RETURN NUMBER IS

l_vac_pay	NUMBER(27,7)	:= 0;
l_vac_hours	NUMBER(10,7)	:= 0;
l_vac_tot_hrs	NUMBER(10,7)	:= 0;

l_sick_pay	NUMBER(27,7)	:= 0;
l_sick_hours	NUMBER(10,7)	:= 0;
l_sick_tot_hrs	NUMBER(10,7)	:= 0;

CURSOR get_vac_hours IS
select  fnd_number.canonical_to_number(pev.screen_entry_value)
from	pay_accrual_plans 		pap,
	pay_element_entries_f 		pee,
	pay_element_entry_values_f	pev
where	pap.accrual_category 	= 'V'
and	pap.business_group_id	= p_bg_id
and	pev.input_value_id	= pap.pto_input_value_id
and	p_eff_date              between pev.effective_start_date
			    	    and pev.effective_end_date
and	pee.element_entry_id	= pev.element_entry_id
and	pee.assignment_id	= p_asg_id
and	p_eff_date              between pee.effective_start_date
			    	    and pee.effective_end_date;

-- The "vacation_pay" function looks for hours entered against Vacation plans
-- in the current period.  The number of hours are summed and multiplied by
-- the current rate of Regular Pay..
-- Return immediately when no vacation time has been taken.
-- Need to loop thru all "Vacation Plans" and check for entries in the current
-- period for this assignment.

CURSOR get_sick_hours IS
select	fnd_number.canonical_to_number(pev.screen_entry_value)
from	pay_accrual_plans 		pap,
	pay_element_entries_f 		pee,
	pay_element_entry_values_f	pev
where	pap.accrual_category 	= 'S'
and	pap.business_group_id	= p_bg_id
and	pev.input_value_id	= pap.pto_input_value_id
and	p_eff_date	        between pev.effective_start_date
			    	    and pev.effective_end_date
and	pee.element_entry_id	= pev.element_entry_id
and	pee.assignment_id	= p_asg_id
and	p_eff_date              between pee.effective_start_date
			    	    and pee.effective_end_date;

-- The "sick_pay" function looks for hours entered against Sick plans in the
-- current period.  The number of hours are summed and multiplied by the
-- current rate of Regular Pay.
-- Return immediately when no sick time has been taken.

BEGIN

hr_utility.set_location('calc_accrual_pay', 11);
IF p_mode = 'V' THEN

  hr_utility.set_location('calc_accrual_pay', 12);
  OPEN get_vac_hours;
  LOOP

    hr_utility.set_location('calc_accrual_pay', 13);
    FETCH get_vac_hours
    INTO  l_vac_hours;
    EXIT  WHEN get_vac_hours%NOTFOUND;

    hr_utility.set_location('calc_accrual_pay', 14);
    hr_utility.set_location('l_vac_hours =', l_vac_hours);
    l_vac_tot_hrs := l_vac_tot_hrs + l_vac_hours;
    hr_utility.set_location('l_vac_tot_hrs =', l_vac_tot_hrs);

  END LOOP;
  CLOSE get_vac_hours;
  hr_utility.set_location('calc_accrual_pay', 15);

  IF l_vac_tot_hrs <> 0 THEN

    hr_utility.set_location('calc_accrual_pay', 16);
    l_vac_pay := p_hours_taken * p_curr_rate;

  ELSE

    l_vac_pay := -777.77;

  END IF;

  RETURN l_vac_pay;

ELSIF p_mode = 'S' THEN

  hr_utility.set_location('calc_accrual_pay', 17);
  OPEN get_sick_hours;
  LOOP

    hr_utility.set_location('calc_accrual_pay', 18);
    FETCH get_sick_hours
    INTO  l_sick_hours;
    EXIT  WHEN get_sick_hours%NOTFOUND;

    hr_utility.set_location('calc_accrual_pay', 19);
    l_sick_tot_hrs := l_sick_tot_hrs + l_sick_hours;

  END LOOP;
  CLOSE get_sick_hours;
  hr_utility.set_location('calc_accrual_pay', 20);
--
-- Rmonge 02/26/2002
-- Fix for bug 2006907
-- Changing sick_tot_hrs > 0 to sick_tot_hrs <> 0
--
  IF l_sick_tot_hrs <> 0 THEN

    hr_utility.set_location('calc_accrual_pay', 21);
    l_sick_pay := p_hours_taken * p_curr_rate;

  ELSE

    l_sick_pay := -999.99;

  END IF;

  RETURN l_sick_pay;

ELSE

  hr_utility.set_location('Accrual Pay mode not set to V or S', 99);
  l_vac_pay := 0;
  return l_vac_pay;

END IF;

END calc_accrual_pay;
--
FUNCTION accrual_time_taken (	p_bg_id		IN  NUMBER,
				p_asg_id 	IN  NUMBER,
				p_eff_date	IN  DATE,
				p_mode		IN  VARCHAR2) RETURN NUMBER IS

l_hours_taken	NUMBER(7,3)	:= 0;

BEGIN

hr_utility.set_location('accrual_time_taken', 1);
select	sum(fnd_number.canonical_to_number(pev.screen_entry_value))
into	l_hours_taken
from	pay_accrual_plans 		pap,
	pay_element_entries_f 		pee,
	pay_element_entry_values_f	pev
where	pap.accrual_category 	= p_mode
and	pap.business_group_id	= p_bg_id
and	pev.input_value_id	= pap.pto_input_value_id
and	p_eff_date              between pev.effective_start_date
			    	    and pev.effective_end_date
and	pee.element_entry_id	= pev.element_entry_id
and	pee.assignment_id	= p_asg_id
and	p_eff_date              between pee.effective_start_date
			    	    and pee.effective_end_date;

hr_utility.set_location('accrual_time_taken', 3);
return l_hours_taken;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    hr_utility.set_location('accrual_time_taken', 5);
    return l_hours_taken;

END accrual_time_taken;

END hr_us_accrual_plans;

/
