--------------------------------------------------------
--  DDL for Package Body PAY_NL_EOY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_EOY_PKG" AS
/* $Header: pynleoy.pkb 120.5 2007/01/17 06:44:29 gkhangar noship $ */
g_debug boolean := hr_utility.debug_enabled;
---------------------------------------------------------------------------
-- Procedure: get_prev_year_tax_income
-- Procedure which returns the balance values of a assignment for a given date
---------------------------------------------------------------------------
function GET_PREV_YEAR_TAX_INCOME(p_assignment_id 	NUMBER
				                 ,p_effective_date	DATE)  RETURN NUMBER IS
    l_result NUMBER;
BEGIN
    l_result := GET_PREV_YEAR_TAX_INCOME(p_assignment_id,p_effective_date,-1);
    return l_result;
null;

END GET_PREV_YEAR_TAX_INCOME;
---------------------------------------------------------------------------
-- Function: GET_PREV_YEAR_TAX_INCOME
-- Function which returns the previous year taxable income for a person as
--on effective date
---------------------------------------------------------------------------

function GET_PREV_YEAR_TAX_INCOME(p_assignment_id 	  NUMBER
				                 ,p_effective_date	  DATE
                                 ,p_payroll_action_id NUMBER)  RETURN NUMBER IS


CURSOR get_all_assignments(p_assignment_id	NUMBER) IS
select unique(paa1.assignment_id) assignment_id
from per_all_assignments_f paa
,per_all_assignments_f paa1
where paa.assignment_id=p_assignment_id
and paa.person_id=paa1.person_id;


CURSOR get_payroll_id(p_assignment_id	NUMBER
		     ,p_effective_date  DATE) IS
select payroll_id
from per_all_assignments_f
where assignment_id=p_assignment_id
and p_effective_date between effective_start_date
	             and effective_end_date;

CURSOR get_dates(p_assignment_id	NUMBER) IS
select min(paa.effective_start_date)
      ,max(paa.effective_end_date)
from per_all_assignments_f paa
,per_assignment_status_types pas
where assignment_id=p_assignment_id
and paa.assignment_status_type_id=pas.assignment_status_type_id
and pas.PER_SYSTEM_STATUS='ACTIVE_ASSIGN';

CURSOR get_start_date_period( l_payroll_id	NUMBER
			      ,l_prev_year	VARCHAR2) IS
select START_DATE
       ,END_DATE
       ,PERIOD_NUM
from
per_time_periods
where payroll_id=l_payroll_id
and period_name like '%'||l_prev_year||'%';
--and START_DATE >= l_prev_year_start_date
--and START_DATE <= l_prev_year_end_date;

CURSOR get_payroll_period( l_payroll_id	     NUMBER
			   ,p_effective_date DATE  )   IS
select 	START_DATE
       ,END_DATE
from
per_time_periods
where payroll_id=l_payroll_id
and p_effective_date between START_DATE and END_DATE;
--
CURSOR  get_dp_period(c_pay_act_id	     NUMBER)   IS
select 	ptp.start_date
       ,ptp.end_date
from    pay_payroll_actions ppa
       ,per_time_periods ptp
where   ppa.payroll_action_id = c_pay_act_id
AND     ptp.time_period_id    = ppa.time_period_id;
--
CURSOR get_ass_act_id(c_assignment_id    NUMBER
                     ,c_start_date       DATE
                     ,c_end_date         DATE)   IS
select 	paa.assignment_action_id
from    pay_assignment_actions paa
       ,pay_payroll_actions ppa
where   paa.assignment_id     = c_assignment_id
and     paa.payroll_action_id = ppa.payroll_action_id
AND    ppa.action_type IN ('Q','R')
AND    ppa.action_status in ('C','P')
AND    ppa.date_earned  BETWEEN  c_start_date AND c_end_date
AND     paa.source_action_id IS NOT NULL
ORDER BY 1 desc;
--
l_current_year			VARCHAR2(10);
l_prev_year			VARCHAR2(10);
l_start_of_the_period		NUMBER;
l_periods_of_year		NUMBER;
l_periods_in_service		NUMBER;
l_first_period			NUMBER;
l_estimated_hol_allow		NUMBER;
l_period_start_date		DATE;
l_period_end_date		DATE;
l_prev_year_income		NUMBER;
l_sum_prev_year_income		NUMBER;
l_std_tax_income		NUMBER;
l_spl_tax_income		NUMBER;
l_retrostd_tax_income		NUMBER;
l_retrostdcurrq_tax_income	NUMBER;
l_retrospl_tax_income		NUMBER;
l_hol_allow_pay_income		NUMBER;
l_hol_allow_tax_income		NUMBER;
l_retrohol_allow_tax_income	NUMBER;
l_std_tax_income_ptd		NUMBER;
l_spl_tax_income_ptd		NUMBER;
l_retrostd_tax_income_ptd	NUMBER;
l_retrostdcurrq_tax_income_ptd	NUMBER;
l_retrospl_tax_income_ptd	NUMBER;
l_hol_allow_pay_income_ptd	NUMBER;
l_hol_allow_tax_income_ptd	NUMBER;
l_rethol_allow_tax_income_ptd	NUMBER;
l_special_rate_income_ptd       NUMBER;
l_sum_hol_allow_tax_income	NUMBER;
l_week_days			NUMBER;
l_total_week_days		NUMBER;
l_first_period_income		NUMBER;
l_sum_hol_first_period		NUMBER;
l_sum_hol_prev_year		NUMBER;
l_curr_year_start_date		DATE;
l_prev_year_start_date		DATE;
l_prev_year_end_date		DATE;
l_dummy				DATE;
l_dummy_num			NUMBER;
l_hol_allow_perc		NUMBER;
l_asg_start_date		DATE;
l_asg_end_date			DATE;
l_payroll_id			NUMBER;
l_temp_asg_start_date		DATE;
l_periods_after_last_period	NUMBER;
l_last_period			NUMBER;
l_date_earned_year		DATE;
l_date_earned_period		DATE;
l_spl_rate_income_dbaid_ptd     NUMBER;
l_periods_of_curr_year          NUMBER;
l_current_year_start_date       DATE;
l_current_year_end_date         DATE;
l_current_period_start_date     DATE;
l_current_period_end_date       DATE;
l_special_rate_income           NUMBER;
l_special_rate_annual_income    NUMBER;
l_special_rate_income_add       NUMBER;
l_ass_act_id                    NUMBER;
l_type                          VARCHAR2(10);
l_dp_start_date                 DATE;
l_dp_end_date                   DATE;
--
Begin

l_special_rate_annual_income    :=0;
l_special_rate_income_add       :=0;
l_sum_prev_year_income          :=0;
l_prev_year_income              :=0;

IF (hr_utility.chk_product_install('Oracle Payroll','NL')) THEN
	null;
ELSE
	return 0;
END IF;

--hr_utility.trace_on(null,'GR');
--OPEN  get_dp_period(payroll_action_id);
--FETCH get_dp_period INTO l_dp_start_date,l_dp_end_date;
--CLOSE get_dp_period;

/* Determine the previous year and current year e.g. 2003 and 2004 respectively.*/
l_current_year:=TO_CHAR(p_effective_date,'YYYY');
l_prev_year:=l_current_year-1;
--hr_utility.trace_on(NULL,'NL_PREV');
--if g_debug then
hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year'||l_prev_year,2000);
--end if;

l_curr_year_start_date:=TO_DATE('01/'||'01/'||l_current_year,'DD/MM/YYYY');
l_prev_year_start_date:=TO_DATE('01/'||'01/'||l_prev_year,'DD/MM/YYYY');
l_prev_year_end_date  :=TO_DATE('31/'||'12/'||l_prev_year,'DD/MM/YYYY');

--if g_debug then
hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,2100);
--end if;



/* Get the value of Global NL_TAX_HOLIDAY_ALLOWANCE_PERCENTAGE */

l_hol_allow_perc:=fnd_number.canonical_to_number(pay_nl_general.get_global_value(
						l_date_earned =>p_effective_date,
						l_global_name =>'NL_TAX_HOLIDAY_ALLOWANCE_PERCENTAGE'));

--if g_debug then
hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_hol_allow_perc'||l_hol_allow_perc,2200);
hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: p_assignment_id'||p_assignment_id,2300);
hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: p_effective_date'||p_effective_date,2300);
--end if;

/* LOOP through all assignments for the person, effective in the previous year and current year.*/
FOR l_assignment IN get_all_assignments(p_assignment_id) LOOP

OPEN get_dates(l_assignment.assignment_id);
FETCH get_dates INTO l_asg_start_date,l_asg_end_date;
CLOSE get_dates;

OPEN get_payroll_id(l_assignment.assignment_id,l_asg_start_date);
FETCH get_payroll_id INTO l_payroll_id;
CLOSE  get_payroll_id;

--FOR l_assignment IN get_all_assignments(p_assignment_id,p_effective_date) LOOP

		--if g_debug then
		 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: EFFECTIVE_START_DATE'||l_asg_start_date,2400);
		 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: EFFECTIVE_END_DATE'||l_asg_end_date,2400);
		 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: PAYROLL_ID'||l_payroll_id,2400);
		--end if;
		l_start_of_the_period:=0;
		l_periods_of_year:=0;
		l_periods_in_service:=0;

		/* Loop thr all the periods of the previous year to determine the
		 Number of periods in service, Total periods in the year
		 start date and date of the first period,start date and end date of the previous year */
		OPEN get_start_date_period(l_payroll_id,l_prev_year);
		FETCH get_start_date_period INTO l_prev_year_start_date,l_dummy,l_dummy_num;
		CLOSE get_start_date_period;

		 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_asg_start_date'||l_asg_start_date,2400);
		 l_temp_asg_start_date:=l_asg_start_date;
		IF l_asg_start_date < l_prev_year_start_date THEN
		l_temp_asg_start_date:= l_prev_year_start_date;
		END IF;
		 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_temp_asg_start_date'||l_temp_asg_start_date,2400);
		FOR l_start_date IN get_start_date_period(l_payroll_id,l_prev_year) LOOP

			 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_start_date.START_DATE'||l_start_date.START_DATE,2410);

			IF l_start_date.START_DATE = l_temp_asg_start_date THEN
			l_start_of_the_period:=1;
			END IF;
			l_periods_of_year:=l_periods_of_year+1;
			 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_start_of_the_period'||l_start_of_the_period,2420);
			 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_periods_of_year'||l_periods_of_year,2420);

			IF  l_temp_asg_start_date >= l_start_date.START_DATE THEN

			l_first_period:=l_start_date.PERIOD_NUM;
			l_period_start_date:=l_start_date.START_DATE;
			l_period_end_date:=l_start_date.END_DATE;
			 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_first_period'||l_first_period,2430);
 			 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_period_start_date'||l_period_start_date,2430);
			 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_period_end_date'||l_period_end_date,2430);
			END IF;
			--IF  l_start_date.START_DATE >= l_asg_end_date and l_last_period is null THEN
			--l_last_period:=l_start_date.PERIOD_NUM;
			--END IF;
			 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_last_period'||l_last_period,2440);
			IF l_start_date.PERIOD_NUM=1 THEN
			l_prev_year_start_date:=l_start_date.START_DATE;
			 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_start_date'||l_prev_year_start_date,2440);
			END IF;
			l_prev_year_end_date:=l_start_date.END_DATE;
			 hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: PAYROLL_ID'||l_payroll_id,2450);
		END LOOP;

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_periods_of_year'||l_periods_of_year,2500);
	--end if;
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_periods_of_year'||l_periods_of_year,2500);
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_first_period'||l_first_period,2500);

	l_periods_in_service:=l_periods_of_year - l_first_period;
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_periods_in_service'||l_periods_in_service,2501);
	l_periods_in_service:=l_periods_in_service+1;

	/*IF l_asg_end_date < l_prev_year_end_date THEN
	l_periods_after_last_period:=l_periods_of_year - l_last_period + 1;
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_periods_after_last_period'||l_periods_after_last_period,2502);
	l_periods_in_service:=l_periods_in_service - l_periods_after_last_period;
	END IF;*/

	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_periods_of_year'||l_periods_of_year,2503);
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_periods_in_service'||l_periods_in_service,2504);
	--end if;
	OPEN get_start_date_period(l_payroll_id,l_current_year);
	FETCH get_start_date_period INTO l_curr_year_start_date,l_dummy,l_dummy_num;
	CLOSE get_start_date_period;



	l_std_tax_income		:=0;
	l_spl_tax_income		:=0;
	l_retrostd_tax_income		:=0;
	l_retrostdcurrq_tax_income	:=0;
	l_retrospl_tax_income		:=0;
	l_hol_allow_pay_income		:=0;
	l_std_tax_income_ptd		:=0;
	l_spl_tax_income_ptd		:=0;
	l_retrostd_tax_income_ptd	:=0;
	l_retrostdcurrq_tax_income_ptd	:=0;
	l_retrospl_tax_income_ptd	:=0;
	l_prev_year_income		:=0;
	l_retrohol_allow_tax_income	:=0;
	l_hol_allow_pay_income_ptd	:=0;
	l_hol_allow_tax_income_ptd	:=0;
	l_rethol_allow_tax_income_ptd	:=0;
	l_sum_hol_allow_tax_income	:=0;
	l_estimated_hol_allow		:=0;
	l_first_period_income		:=0;
	l_sum_hol_prev_year		:=0;
	l_sum_hol_first_period		:=0;
	l_sum_hol_prev_year		:=0;
	l_week_days			:=0;
	l_total_week_days		:=0;
	l_periods_of_curr_year          :=0;
	l_special_rate_income           :=0;

	IF l_asg_start_date  < l_curr_year_start_date  THEN
			IF l_asg_end_date < l_prev_year_end_date THEN
			l_date_earned_year:=l_asg_end_date;
			ELSE
			l_date_earned_year:=l_prev_year_end_date;
			END IF;

			IF l_asg_end_date < l_period_end_date THEN
			l_date_earned_period:=l_asg_end_date;
			ELSE
			l_date_earned_period:=l_period_end_date;
			END IF;

			PAY_NL_EOY_PKG.get_balance_values(l_assignment.assignment_id
					  ,l_date_earned_year
					  ,l_date_earned_period
					  ,l_std_tax_income
					  ,l_spl_tax_income
					  ,l_retrostd_tax_income
					  ,l_retrostdcurrq_tax_income
					  ,l_retrospl_tax_income
					  ,l_hol_allow_pay_income
					  ,l_hol_allow_tax_income
					  ,l_retrohol_allow_tax_income
					  ,l_std_tax_income_ptd
					  ,l_spl_tax_income_ptd
					  ,l_retrostd_tax_income_ptd
					  ,l_retrostdcurrq_tax_income_ptd
					  ,l_retrospl_tax_income_ptd
					  ,l_hol_allow_pay_income_ptd
					  ,l_hol_allow_tax_income_ptd
					  ,l_rethol_allow_tax_income_ptd
					  );
	   END IF;

--if g_debug then
hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_std_tax_income'||l_std_tax_income,2600);
--end if;
IF l_periods_in_service IS NULL OR l_periods_in_service=0 THEN
l_periods_in_service:=1;
END IF;

FOR l_start_date IN get_start_date_period(l_payroll_id,l_current_year) LOOP

		l_periods_of_curr_year:=l_periods_of_curr_year+1;
		IF l_start_date.PERIOD_NUM=1 THEN
				l_current_year_start_date:=l_start_date.START_DATE;
		END IF;

		l_current_year_end_date:=l_start_date.END_DATE;
END LOOP;


OPEN get_payroll_period (l_payroll_id,p_effective_date);
FETCH get_payroll_period INTO l_current_period_start_date ,l_current_period_end_date;
CLOSE get_payroll_period;



/* If assignment was valid for the whole of the previous year or if it was ended during previous year.*/
--Bug 3482065
IF (l_asg_start_date <= l_prev_year_start_date  and l_asg_end_date >= l_prev_year_end_date )
or (l_asg_end_date < l_prev_year_end_date  and TO_CHAR(l_asg_end_date,'YYYY') = TO_CHAR(l_prev_year_end_date,'YYYY') )THEN


	/* Set previous year's taxable income for this assignment to be the sum of balances Standard Taxable Income
	Special Taxable Income, Retro Standard Taxable Income, Retro Standard Taxable Income Current Quarter
	and Retro Special Taxable Income for the whole of the previous year */

	l_prev_year_income:= l_std_tax_income + l_spl_tax_income + l_retrostd_tax_income +
				    l_retrostdcurrq_tax_income + l_retrospl_tax_income;


	l_sum_prev_year_income:=l_sum_prev_year_income + l_std_tax_income + l_spl_tax_income + l_retrostd_tax_income +
			    l_retrostdcurrq_tax_income + l_retrospl_tax_income;

--if g_debug then
hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_prev_year_income'||l_sum_prev_year_income,2800);
--end if;

/* If assignment started at the beginning of a period in the previous year.*/
ELSIF l_start_of_the_period = 1 and l_asg_end_date >= l_prev_year_start_date  AND l_asg_start_date < l_curr_year_start_date THEN

	--if g_debug then
  	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,2900);
	--end if;
	/* Add together the values of balances Standard Taxable Income, Special Taxable
	Income, Retro Standard Taxable Income, Retro Standard Taxable Income
	Current Quarter and Retro Special Taxable Income for the previous year.*/

	l_prev_year_income:= l_std_tax_income + l_spl_tax_income + l_retrostd_tax_income +
			    l_retrostdcurrq_tax_income + l_retrospl_tax_income;


	--if g_debug then
  	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_hol_allow_pay_income'||l_hol_allow_pay_income,3000);
	--end if;
	/* Remove the value of balance Holiday Allowance Payment for the previous year.  */

		l_prev_year_income:= l_prev_year_income - l_hol_allow_pay_income;

	/* Divide the total by the number of payroll periods in service.*/
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,3100);
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_periods_in_service'||l_periods_in_service,3200);
	--end if;
		l_prev_year_income:= l_prev_year_income/l_periods_in_service;
	/* Multiply by the total number of payroll periods in the year to provide the estimated taxable income for the previous year */
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_periods_of_year'||l_periods_of_year,3300);
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,3300);
	--end if;
		l_prev_year_income:=l_prev_year_income * l_periods_of_year;


	/* To start with, the value of balance Holiday Allowance Payment must be
        subtracted from the total of balances Holiday Allowance Taxable Income and
        Retro Holiday Allowance Taxable Income, to provide the value of holiday
        allowance taxable income for the part of the year worked.
	*/
		l_sum_hol_allow_tax_income:=l_hol_allow_tax_income + l_retrohol_allow_tax_income;
		--Bug 3479044
		l_sum_hol_allow_tax_income:=l_sum_hol_allow_tax_income-l_hol_allow_pay_income;

		--if g_debug then
		hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_hol_allow_tax_income'||l_sum_hol_allow_tax_income,3400);
		--end if;
		l_sum_hol_allow_tax_income:= l_sum_hol_allow_tax_income/l_periods_in_service;
		l_sum_hol_allow_tax_income:=l_sum_hol_allow_tax_income * l_periods_of_year;

		--if g_debug then
		hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_hol_allow_tax_income'||l_sum_hol_allow_tax_income,3500);
		--end if;
		l_estimated_hol_allow:=l_sum_hol_allow_tax_income * l_hol_allow_perc/100;

		--if g_debug then
		hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_estimated_hol_allow'||l_estimated_hol_allow,3600);
		--end if;
	/* Add the estimated holiday allowance to the estimated taxable income, to provide
	the previous year?s taxable income for this assignment */

	l_prev_year_income:= l_prev_year_income + l_estimated_hol_allow;


		l_sum_prev_year_income:=l_sum_prev_year_income +l_prev_year_income;

		--if g_debug then
		hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,3700);
		--end if;
/* If the assignment started part way through a period in the previous year */
ELSIF l_asg_end_date >= l_prev_year_start_date AND l_asg_start_date < l_curr_year_start_date THEN

	/* Determine the number of week days (Monday to Friday) that the employee
	worked in the period i.e. between the assignment start date and the end of the period.*/

	l_week_days:= pay_nl_si_pkg.get_week_days(l_asg_start_date,l_period_end_date);

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_week_days'||l_week_days,3800);
	--end if;
	IF l_week_days IS NULL OR l_week_days=0 THEN
	l_week_days:=1;
	END IF;
	/*Determine the total number of week days in the period i.e. between the period
	start date and the end of the period.*/

	l_total_week_days := pay_nl_si_pkg.get_week_days(l_period_start_date,l_period_end_date);

	IF l_total_week_days IS NULL THEN
	l_total_week_days:=0;
	END IF;
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_total_week_days'||l_total_week_days,3900);
	--end if;

	/*Add together the balances Standard Taxable Income, Special Taxable
	Income, Retro Standard Taxable Income, Retro Standard Taxable Income
	Current Quarter and Retro Special Taxable Income for this first period.*/

	l_first_period_income:= l_std_tax_income_ptd + l_spl_tax_income_ptd + l_retrostd_tax_income_ptd +
			    l_retrostdcurrq_tax_income_ptd + l_retrospl_tax_income_ptd;
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_first_period_income'||l_first_period_income,4000);
	--end if;

	l_prev_year_income:= l_std_tax_income + l_spl_tax_income + l_retrostd_tax_income +
			    l_retrostdcurrq_tax_income + l_retrospl_tax_income;
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,4100);
	--end if;

	l_prev_year_income:=l_prev_year_income - l_first_period_income;

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,4200);
	--end if;

	/*Then divide this by the number of week days worked and then multiply by the number
	of week days in the period.  This will provide an estimated taxable income for the
	whole of the first period.*/
	--Bug 3479044
	l_first_period_income:=l_first_period_income-l_hol_allow_pay_income_ptd;

	l_first_period_income:=l_first_period_income/l_week_days;
	l_first_period_income:=l_first_period_income * l_total_week_days;
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_first_period_income'||l_first_period_income,4300);
	--end if;

	/*Add together the balances Standard Taxable Income, Special Taxable
       Income, Retro Standard Taxable Income, Retro Standard Taxable Income
       Current Quarter and Retro Special Taxable Income for rest of the previous year
       (excluding the first period), and subtract any value of balance Holiday Allowance
       Payment for the rest of the previous year (excluding the first period).  */
	--Bug 3479044
	l_hol_allow_pay_income:=l_hol_allow_pay_income - l_hol_allow_pay_income_ptd;

	l_prev_year_income:=l_prev_year_income - l_hol_allow_pay_income;

	/*Then add this total to the estimated taxable income for the first period. */
	l_prev_year_income:=l_prev_year_income + l_first_period_income;

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,4500);
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_hol_allow_pay_income'||l_hol_allow_pay_income,4400);
	--end if;
	/*Remove the value of balance Holiday Allowance Payment for the previous year.*/

--	l_prev_year_income:=l_prev_year_income - l_hol_allow_pay_income;

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,4600);
	--end if;
	/*Divide the total by the number of periods in service (including the part period and
	treating this as a full period).*/

	l_prev_year_income:= l_prev_year_income/l_periods_in_service;
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,4700);
	--end if;
	/*Multiply by the total number of payroll periods in the year, to provide the
	estimated taxable income for the previous year.*/

	l_prev_year_income:=l_prev_year_income * l_periods_of_year;
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,4800);
	--end if;
	/*Calculate the estimated value for holiday allowance as a percentage of an
	adjusted total of balances Holiday Allowance Taxable Income and Retro Holiday
	Allowance Taxable Income in the previous year.*/

	l_sum_hol_first_period:=l_hol_allow_tax_income_ptd + l_rethol_allow_tax_income_ptd;
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_hol_first_period'||l_sum_hol_first_period,4900);
	--end if;
	l_sum_hol_prev_year:=l_hol_allow_tax_income + l_retrohol_allow_tax_income;

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_hol_prev_year'||l_sum_hol_prev_year,5000);
	--end if;

	/*convert the holiday allowance taxable income for the first part period to an estimated value
	for the whole period, adding this to the holiday allowance taxable income for the
	rest of the year, dividing by the number of periods in service and the multiplying
	by the total number of payroll periods in the year.  */

	l_sum_hol_prev_year:=l_sum_hol_prev_year - l_sum_hol_first_period;
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_hol_prev_year'||l_sum_hol_prev_year,5100);
	--end if;
	l_sum_hol_first_period:=l_sum_hol_first_period - l_hol_allow_pay_income_ptd;

	l_sum_hol_first_period:=l_sum_hol_first_period/l_week_days;

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_hol_first_period'||l_sum_hol_first_period,5200);
	--end if;

	l_sum_hol_first_period:=l_sum_hol_first_period * l_total_week_days;

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_hol_first_period'||l_sum_hol_first_period,5300);
	--end if;
	l_sum_hol_prev_year:=l_sum_hol_prev_year - l_hol_allow_pay_income;

	l_sum_hol_prev_year:=l_sum_hol_prev_year + l_sum_hol_first_period;

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_hol_prev_year'||l_sum_hol_prev_year,5400);
	--end if;

	l_sum_hol_prev_year:=l_sum_hol_prev_year/l_periods_in_service;

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_hol_prev_year'||l_sum_hol_prev_year,5500);
	--end if;

	l_sum_hol_prev_year:=l_sum_hol_prev_year * l_periods_of_year;

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_hol_prev_year'||l_sum_hol_prev_year,5600);
	--end if;

	l_estimated_hol_allow:=l_sum_hol_prev_year * l_hol_allow_perc/100;

	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_estimated_hol_allow'||l_estimated_hol_allow,5700);
	--end if;
	/* Add the estimated holiday allowance to the estimated taxable income, to provide
	the previous year?s taxable income for this assignment. */

	l_prev_year_income:=l_prev_year_income +l_estimated_hol_allow;
	--if g_debug then
	hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_prev_year_income'||l_prev_year_income,5800);
	--end if;

	l_sum_prev_year_income:=l_sum_prev_year_income +l_prev_year_income;
--if g_debug then
hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME: l_sum_prev_year_income'||l_sum_prev_year_income,5900);
--end if;

END IF;

/* If assignment started in the current year.  then set previous year's taxable income to value based on balance Special Rate Income*/
IF l_asg_start_date >= l_curr_year_start_date OR  l_prev_year_income = 0 THEN

	--
    l_type := 'DP';
    IF p_payroll_action_id <> -1 THEN
        hr_utility.trace('~~VV3');
        l_ass_act_id := NULL;
        OPEN  get_ass_act_id(l_assignment.assignment_id,l_current_period_start_date,l_current_period_end_date);
        FETCH get_ass_act_id INTO l_ass_act_id;
        CLOSE get_ass_act_id;
        --
        l_type := pay_nl_general.check_de_dp_dimension(p_payroll_action_id
                                                     ,l_assignment.assignment_id
                                                     ,l_ass_act_id);
        --

        hr_utility.trace('~~VV l_type : '||l_type);
        IF l_type = 'DE' THEN
            l_spl_rate_income_dbaid_ptd:=pay_nl_general.get_defined_balance_id('SPECIAL_RATE_INCOME_ASG_BDATE_PTD');
            IF l_ass_act_id is NOT NULL THEN
            l_special_rate_income_ptd :=pay_balance_pkg.get_value(p_defined_balance_id=> l_spl_rate_income_dbaid_ptd
                                                         ,p_assignment_action_id  => l_ass_act_id
                                                         ,p_tax_unit_id           => NULL
                                                         ,p_jurisdiction_code     => NULL
                                                         ,p_source_id             => NULL
                                                         ,p_source_text           => NULL
                                                         ,p_tax_group             => NULL
                                                         ,p_date_earned           => NULL
                                                         ,p_get_rr_route          => NULL
                                                         ,p_get_rb_route          => NULL
                                                         ,p_source_text2          => NULL
                                                         ,p_source_number         => NULL
                                                         ,p_time_def_id           => NULL
                                                         ,p_balance_date          => l_current_period_end_date
                                                         ,p_payroll_id            => NULL);
            ELSE
                l_special_rate_income_ptd := 0;
            END IF;
       ELSE
            l_spl_rate_income_dbaid_ptd:=pay_nl_general.get_defined_balance_id('SPECIAL_RATE_INCOME_ASG_PTD');
            IF l_ass_act_id is NOT NULL THEN
            pay_balance_pkg.set_context('BALANCE_DATE',NULL);
            l_special_rate_income_ptd :=pay_balance_pkg.get_value(p_defined_balance_id=> l_spl_rate_income_dbaid_ptd
                                                             ,p_assignment_action_id  => l_ass_act_id
                                                             ,p_get_rr_route          => true
                                                             ,p_get_rb_route          => false);
            ELSE
                l_special_rate_income_ptd := 0;
            END IF;
       END IF;
    ELSE
        hr_utility.trace('~~VV 2');
        l_spl_rate_income_dbaid_ptd:=pay_nl_general.get_defined_balance_id('SPECIAL_RATE_INCOME_ASG_PTD');
        l_special_rate_income_ptd  :=pay_balance_pkg.get_value(l_spl_rate_income_dbaid_ptd
                                           ,l_assignment.assignment_id,l_current_period_end_date);
    END IF;
    --
    l_special_rate_income:=l_special_rate_income_ptd;
    l_special_rate_income_add:=l_special_rate_annual_income;

	IF l_asg_start_date > l_current_period_start_date THEN
		l_week_days      :=pay_nl_si_pkg.get_week_days(l_asg_start_date,l_current_period_end_date);
		l_total_week_days:=pay_nl_si_pkg.get_week_days(l_current_period_start_date,l_current_period_end_date);

		IF l_week_days IS NULL OR l_week_days=0 THEN
			l_week_days:=1;
		END IF;

		IF l_total_week_days IS NULL THEN
			l_total_week_days:=0;
		END IF;

		l_special_rate_income:=(l_special_rate_income_ptd*l_total_week_days)/l_week_days;
	END IF;

	l_special_rate_annual_income:=l_special_rate_income*l_periods_of_curr_year;

	l_special_rate_annual_income:=FLOOR(l_special_rate_annual_income);

	l_special_rate_annual_income:=l_special_rate_annual_income+l_special_rate_income_add;

END IF;
END LOOP;

--if g_debug then
hr_utility.set_location('Inside GET_PREV_YEAR_TAX_INCOME:l_sum_prev_year_income '||l_sum_prev_year_income,6000);
--end if;
--Return the Previous Year Taxable Income
l_sum_prev_year_income:=FLOOR(l_sum_prev_year_income);

l_special_rate_annual_income:=FLOOR(l_special_rate_annual_income);

l_sum_prev_year_income:=l_sum_prev_year_income+l_special_rate_annual_income;


hr_utility.set_location('~~ Final'|| l_sum_prev_year_income,11111);
--hr_utility.trace_off();
RETURN l_sum_prev_year_income;


EXCEPTION
WHEN NO_DATA_FOUND THEN
hr_utility.set_location('GET_PREV_YEAR_TAX_INCOME'||SQLERRM||SQLCODE,4200);
RETURN 0;

END GET_PREV_YEAR_TAX_INCOME;
--
---------------------------------------------------------------------------
-- Procedure: get_balance_values
-- Procedure which returns the balance values of a assignment for a given date
---------------------------------------------------------------------------

Procedure get_balance_values(    l_assignment_id		 IN   NUMBER
				,l_prev_year_end_date		 IN   DATE
				,l_period_end_date		 IN   DATE
				,l_std_tax_income		 OUT NOCOPY  NUMBER
				,l_spl_tax_income		 OUT NOCOPY  NUMBER
				,l_retrostd_tax_income		 OUT NOCOPY  NUMBER
				,l_retrostdcurrq_tax_income	 OUT NOCOPY  NUMBER
				,l_retrospl_tax_income		 OUT NOCOPY  NUMBER
				,l_hol_allow_pay_income		 OUT NOCOPY  NUMBER
				,l_hol_allow_tax_income		 OUT NOCOPY  NUMBER
				,l_retrohol_allow_tax_income	 OUT NOCOPY  NUMBER
				,l_std_tax_income_ptd		 OUT NOCOPY  NUMBER
				,l_spl_tax_income_ptd		 OUT NOCOPY  NUMBER
				,l_retrostd_tax_income_ptd	 OUT NOCOPY  NUMBER
				,l_retrostdcurrq_tax_income_ptd	 OUT NOCOPY  NUMBER
				,l_retrospl_tax_income_ptd	 OUT NOCOPY  NUMBER
				,l_hol_allow_pay_income_ptd	 OUT NOCOPY  NUMBER
				,l_hol_allow_tax_income_ptd	 OUT NOCOPY  NUMBER
				,l_rethol_allow_tax_income_ptd   OUT NOCOPY  NUMBER) IS




l_std_tax_dbalid		NUMBER;
l_spl_tax_dbalid		NUMBER;
l_retrostd_tax_dbalid		NUMBER;
l_retrostdcurrq_tax_dbalid	NUMBER;
l_retrospl_tax_dbalid		NUMBER;
l_hol_allow_pay_dbalid		NUMBER;
l_hol_allow_tax_dbalid		NUMBER;
l_retrohol_allow_tax_dbalid	NUMBER;
l_std_tax_dbalid_ptd		NUMBER;
l_spl_tax_dbalid_ptd		NUMBER;
l_retrostd_tax_dbalid_ptd	NUMBER;
l_retrostdcurrq_tax_dbalid_ptd	NUMBER;
l_retrospl_tax_dbalid_ptd	NUMBER;
l_hol_allow_pay_dbalid_ptd	NUMBER;
l_hol_allow_tax_dbalid_ptd	NUMBER;
l_retrohol_allow_dbalid_ptd	NUMBER;


Begin

--Get the Defined Balance Id's of the required balances
l_std_tax_dbalid		:=pay_nl_general.get_defined_balance_id('STANDARD_TAXABLE_INCOME_ASG_YTD');
l_spl_tax_dbalid		:=pay_nl_general.get_defined_balance_id('SPECIAL_TAXABLE_INCOME_ASG_YTD');
l_retrostd_tax_dbalid		:=pay_nl_general.get_defined_balance_id('RETRO_STANDARD_TAXABLE_INCOME_ASG_YTD');
l_retrostdcurrq_tax_dbalid	:=pay_nl_general.get_defined_balance_id('RETRO_STANDARD_TAXABLE_INCOME_CURRENT_QUARTER_ASG_YTD');
l_retrospl_tax_dbalid		:=pay_nl_general.get_defined_balance_id('RETRO_SPECIAL_TAXABLE_INCOME_ASG_YTD');

l_hol_allow_pay_dbalid		:=pay_nl_general.get_defined_balance_id('HOLIDAY_ALLOWANCE_PAYMENT_ASG_YTD');
l_hol_allow_tax_dbalid		:=pay_nl_general.get_defined_balance_id('HOLIDAY_ALLOWANCE_TAXABLE_INCOME_ASG_YTD');
l_retrohol_allow_tax_dbalid	:=pay_nl_general.get_defined_balance_id('RETRO_HOLIDAY_ALLOWANCE_TAXABLE_INCOME_ASG_YTD');


l_std_tax_dbalid_ptd		:=pay_nl_general.get_defined_balance_id('STANDARD_TAXABLE_INCOME_ASG_PTD');
l_spl_tax_dbalid_ptd		:=pay_nl_general.get_defined_balance_id('SPECIAL_TAXABLE_INCOME_ASG_PTD');
l_retrostd_tax_dbalid_ptd	:=pay_nl_general.get_defined_balance_id('RETRO_STANDARD_TAXABLE_INCOME_ASG_PTD');
l_retrostdcurrq_tax_dbalid_ptd	:=pay_nl_general.get_defined_balance_id('RETRO_STANDARD_TAXABLE_INCOME_CURRENT_QUARTER_ASG_PTD');
l_retrospl_tax_dbalid_ptd	:=pay_nl_general.get_defined_balance_id('RETRO_SPECIAL_TAXABLE_INCOME_ASG_PTD');


l_hol_allow_pay_dbalid_ptd	:=pay_nl_general.get_defined_balance_id('HOLIDAY_ALLOWANCE_PAYMENT_ASG_PTD');
l_hol_allow_tax_dbalid_ptd	:=pay_nl_general.get_defined_balance_id('HOLIDAY_ALLOWANCE_TAXABLE_INCOME_ASG_PTD');
l_retrohol_allow_dbalid_ptd	:=pay_nl_general.get_defined_balance_id('RETRO_HOLIDAY_ALLOWANCE_TAXABLE_INCOME_ASG_PTD');


	--if g_debug then
	hr_utility.set_location('Inside get_balance_values: l_std_tax_dbalid'||l_std_tax_dbalid,2510);
	--end if;

	l_std_tax_income		:=pay_balance_pkg.get_value(l_std_tax_dbalid
								,l_assignment_id
								,l_prev_year_end_date);
	l_spl_tax_income		:=pay_balance_pkg.get_value(l_spl_tax_dbalid
								,l_assignment_id
								,l_prev_year_end_date);
	l_retrostd_tax_income		:=pay_balance_pkg.get_value(l_retrostd_tax_dbalid
								,l_assignment_id
								,l_prev_year_end_date);
	l_retrostdcurrq_tax_income		:=pay_balance_pkg.get_value(l_retrostdcurrq_tax_dbalid
								,l_assignment_id
								,l_prev_year_end_date);
	l_retrospl_tax_income			:=pay_balance_pkg.get_value(l_retrospl_tax_dbalid
								,l_assignment_id
								,l_prev_year_end_date);
	--if g_debug then
	hr_utility.set_location('Inside get_balance_values: l_retrospl_tax_income'||l_retrospl_tax_income,2520);
	--end if;

	l_hol_allow_pay_income			:=pay_balance_pkg.get_value(l_hol_allow_pay_dbalid
								,l_assignment_id
								,l_prev_year_end_date);
	l_hol_allow_tax_income			:=pay_balance_pkg.get_value(l_hol_allow_tax_dbalid
								,l_assignment_id
								,l_prev_year_end_date);
	l_retrohol_allow_tax_income		:=pay_balance_pkg.get_value(l_retrohol_allow_tax_dbalid
								,l_assignment_id
								,l_prev_year_end_date);

	--if g_debug then
	hr_utility.set_location('Inside get_balance_values: l_std_tax_dbalid_ptd'||l_std_tax_dbalid_ptd,2530);
	hr_utility.set_location('Inside get_balance_values: l_assignment_id'||l_assignment_id,2530);
	hr_utility.set_location('Inside get_balance_values: l_period_end_date'||l_period_end_date,2530);
	--end if;


	l_std_tax_income_ptd			:=pay_balance_pkg.get_value(l_std_tax_dbalid_ptd
								,l_assignment_id
								,l_period_end_date);
	--if g_debug then
	hr_utility.set_location('Inside get_balance_values: l_std_tax_income_ptd'||l_std_tax_income_ptd,2531);
	--end if;

	l_spl_tax_income_ptd			:=pay_balance_pkg.get_value(l_spl_tax_dbalid_ptd
								,l_assignment_id
								,l_period_end_date);
	--if g_debug then
	hr_utility.set_location('Inside get_balance_values: l_spl_tax_income_ptd'||l_spl_tax_income_ptd,2532);
	--end if;

	l_retrostd_tax_income_ptd		:=pay_balance_pkg.get_value(l_retrostd_tax_dbalid_ptd
								,l_assignment_id
								,l_period_end_date);
	--if g_debug then
	hr_utility.set_location('Inside get_balance_values: l_retrostd_tax_income_ptd'||l_retrostd_tax_income_ptd,2533);
	--end if;

	l_retrostdcurrq_tax_income_ptd		:=pay_balance_pkg.get_value(l_retrostdcurrq_tax_dbalid_ptd
								,l_assignment_id
								,l_period_end_date);
	--if g_debug then
	hr_utility.set_location('Inside get_balance_values: l_retrostdcurrq_tax_income_ptd'||l_retrostdcurrq_tax_income_ptd,2534);
	--end if;

	l_retrospl_tax_income_ptd		:=pay_balance_pkg.get_value(l_retrospl_tax_dbalid_ptd
								,l_assignment_id
								,l_period_end_date);
	--if g_debug then
	hr_utility.set_location('Inside get_balance_values: l_retrospl_tax_income_ptd'||l_retrospl_tax_income_ptd,2540);
	--end if;

	l_hol_allow_pay_income_ptd		:=pay_balance_pkg.get_value(l_hol_allow_pay_dbalid_ptd
								,l_assignment_id
								,l_period_end_date);
	l_hol_allow_tax_income_ptd		:=pay_balance_pkg.get_value(l_hol_allow_tax_dbalid_ptd
								,l_assignment_id
								,l_period_end_date);
	l_rethol_allow_tax_income_ptd		:=pay_balance_pkg.get_value(l_retrohol_allow_dbalid_ptd
								,l_assignment_id
								,l_period_end_date);
	--if g_debug then
	hr_utility.set_location('Inside get_balance_values: l_rethol_allow_tax_income_ptd'||l_rethol_allow_tax_income_ptd,2550);
	--end if;

Exception
WHEN NO_DATA_FOUND THEN
hr_utility.set_location('get_balance_values'||SQLERRM||SQLCODE,1200);
l_std_tax_income:=0;
l_spl_tax_income:=0;
l_retrostd_tax_income:=0;
l_retrostdcurrq_tax_income:=0;
l_retrospl_tax_income:=0;
l_hol_allow_pay_income:=0;
l_hol_allow_tax_income:=0;
l_retrohol_allow_tax_income:=0;
l_std_tax_income_ptd:=0;
l_spl_tax_income_ptd:=0;
l_retrostd_tax_income_ptd:=0;
l_retrostdcurrq_tax_income_ptd:=0;
l_retrospl_tax_income_ptd:=0;
l_hol_allow_pay_income_ptd:=0;
l_hol_allow_tax_income_ptd:=0;
l_rethol_allow_tax_income_ptd:=0;

END get_balance_values;



---------------------------------------------------------------------------
-- Procedure: reset_override_lastyr_sal
-- Procedure which resets the override value of all the assignments at the
--end of the year
---------------------------------------------------------------------------

PROCEDURE  reset_override_lastyr_sal(errbuf out nocopy varchar2,
				     retcode out nocopy varchar2,
				     p_date in varchar2,
				     p_org_struct_id in number,
				     p_hr_org_id in number,
				     p_business_group_id in number
				     )

IS

  l_concatenated_segments		hr_soft_coding_keyflex.CONCATENATED_SEGMENTS%TYPE;
  l_cagr_grade_def_id			per_all_assignments_f.CAGR_GRADE_DEF_ID%TYPE;
  l_cagr_concatenated_segments		per_cagr_grades_def.CONCATENATED_SEGMENTS%TYPE;
  l_effective_start_date		per_all_assignments_f.EFFECTIVE_START_DATE%TYPE;
  l_effective_end_date			per_all_assignments_f.EFFECTIVE_END_DATE%TYPE;
  l_comment_id				per_all_assignments_f.COMMENT_ID%TYPE;
  l_soft_coding_keyflex_id		per_all_assignments_f.SOFT_CODING_KEYFLEX_ID%TYPE;
  l_other_manager_warning		boolean;
  l_no_managers_warning			boolean;
  l_hourly_salaried_warning		boolean;
  l_gsp_post_process_warning		varchar2(2000);
  l_object_version_number		per_all_assignments_f.OBJECT_VERSION_NUMBER%TYPE;
  l_end					number;
  l_datetrack_update_mode		varchar2(2000);

  ---------------------------------------------------------------------
  --Cursor fetches details of assignments to be updated
  ---------------------------------------------------------------------
  -- Modified for Bug 4200471 to improve performance
  cursor csr_get_asg_details(p_hr_org_id number,
			     p_date varchar2,
			     p_org_struct_id number,
			     p_business_group_id number) is
  select asg.assignment_id
  ,asg.person_id
  ,asg.object_version_number
  ,asg.assignment_number
  ,asg.effective_start_date
  ,asg.effective_end_date
  , scl.segment12 last_year_sal
  , ast.user_status
  from per_all_assignments_f asg
  ,hr_soft_coding_keyflex scl
  , per_assignment_status_types ast
  where organization_id in
  (select pose.organization_id_child
  from per_org_structure_elements pose,per_org_structure_versions posv
  where
  posv.org_structure_version_id = pose.org_structure_version_id
  and posv.organization_structure_id=p_org_struct_id
  and posv.business_group_id = pose.business_group_id
  and posv.business_group_id=p_business_group_id
  UNION ALL
  select p_business_group_id FROM DUAL)
  and nvl(p_hr_org_id,organization_id)=organization_id
  and fnd_date.canonical_to_date(p_date) between effective_start_date and effective_end_date
  and asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
  and scl.segment12 is not null
  and ast.assignment_status_type_id = asg.assignment_status_type_id
  and asg.business_group_id = p_business_group_id
  and ast.PER_SYSTEM_STATUS='ACTIVE_ASSIGN';

  --l_asg_details csr_get_asg_details%ROWTYPE;


Begin
  --hr_utility.trace_on(null,'RESET_OVERRIDE');
  --hr_utility.trace('In reset override');

  retcode := 0;

  --------------------------------------------------------------------
  --Loop through all assignments and update them
  --------------------------------------------------------------------
  for l_asg_details in csr_get_asg_details(p_hr_org_id,p_date,p_org_struct_id,p_business_group_id) loop
	  l_object_version_number := l_asg_details.object_version_number ;
      if l_asg_details.effective_start_date = fnd_date.canonical_to_date(p_date) then
      l_datetrack_update_mode := 'CORRECTION';
      elsif
      l_asg_details.effective_end_date <> hr_general.end_of_time then
      l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
      else
      l_datetrack_update_mode := 'UPDATE';
      end if;
    Begin
    --hr_utility.trace(l_datetrack_update_mode);
    --hr_utility.trace(l_asg_details.assignment_id);
    --hr_utility.trace(l_asg_details.assignment_number);
    --hr_utility.trace(l_asg_details.effective_start_date);
    --hr_utility.trace(l_asg_details.effective_end_date);
    --hr_utility.trace(fnd_date.canonical_to_date(p_date));
    --hr_utility.trace(hr_general.end_of_time);

    --fnd_file.put_line(fnd_file.log,l_asg_details.assignment_id);
	l_soft_coding_keyflex_id := NULL;  -- Bug 5763286
      hr_nl_assignment_api.update_nl_emp_asg
	    (p_validate => FALSE
	    ,p_effective_date => fnd_date.canonical_to_date(p_date)
	    ,p_person_id => l_asg_details.person_id
	    ,p_datetrack_update_mode => l_datetrack_update_mode
	    ,p_assignment_id => l_asg_details.assignment_id
	    ,p_object_version_number => l_object_version_number
	    ,p_assignment_number => l_asg_details.assignment_number
	    ,p_cagr_grade_def_id => l_cagr_grade_def_id
	    ,p_cagr_concatenated_segments => l_cagr_concatenated_segments
	    ,p_concatenated_segments => l_concatenated_segments
	    ,p_soft_coding_keyflex_id => l_soft_coding_keyflex_id
	    ,p_comment_id => l_comment_id
	    ,p_last_year_salary => NULL
	    ,p_effective_start_date => l_effective_start_date
	    ,p_effective_end_date => l_effective_end_date
	    ,p_no_managers_warning => l_no_managers_warning
	    ,p_other_manager_warning => l_other_manager_warning
	    ,p_hourly_salaried_warning => l_hourly_salaried_warning
	    ,p_gsp_post_process_warning => l_gsp_post_process_warning
	    );
        Exception
        WHEN others THEN
        hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
        hr_utility.set_message_token('2',substr(sqlerrm,1,200));
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
        hr_utility.raise_error;
     end;
   end loop;

End reset_override_lastyr_sal ;

---------------------------------------------------------------------------
-- Procedure: end_of_year_process
-- Generic Procedure for end of the year process
---------------------------------------------------------------------------

Procedure end_of_year_process (errbuf out nocopy varchar2,
			       retcode out nocopy varchar2,
			       p_date in varchar2,
			       p_org_struct_id in number,
			       p_hr_org_id in number,
			       p_business_group_id in number) IS

Begin

--Call the reset_override_lastyr_sal procedure to reset the override last year salary field

reset_override_lastyr_sal(errbuf,
			  retcode,
			  p_date,
			  p_org_struct_id,
			  p_hr_org_id,
			  p_business_group_id
			  );
End end_of_year_process;

---------------------------------------------------------------------------
-- Procedure: update_assignments
--Procedure which does the datetrack update of all the assignments of a
--person with override value
---------------------------------------------------------------------------

Procedure update_assignments (p_assignment_id   IN NUMBER
			,p_person_id  		IN  NUMBER
			,p_effective_date 	IN  DATE
			,p_override_value  	IN  NUMBER
			,p_dt_update_mode       IN  VARCHAR2) IS

  CURSOR get_all_assignments (p_person_id NUMBER
                             ,p_effective_date DATE) IS
   select paa.assignment_id
  	,paa.effective_start_date
  	,paa.effective_end_date
  	,paa.object_version_number
  	,hsck.segment12
  from per_all_assignments_f paa
      ,hr_soft_coding_keyflex hsck
      ,per_assignment_status_types pas
  where  person_id=p_person_id
  and  paa.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id (+)
  and pas.assignment_status_type_id=paa.assignment_status_type_id
  and pas.PER_SYSTEM_STATUS='ACTIVE_ASSIGN'
  and pas.business_group_id IS NULL and pas.legislation_code IS NULL
  and p_effective_date between effective_start_date and effective_end_date;


  l_concatenated_segments		hr_soft_coding_keyflex.CONCATENATED_SEGMENTS%TYPE;
  l_cagr_grade_def_id			per_all_assignments_f.CAGR_GRADE_DEF_ID%TYPE;
  l_cagr_concatenated_segments		per_cagr_grades_def.CONCATENATED_SEGMENTS%TYPE;
  l_effective_start_date		per_all_assignments_f.EFFECTIVE_START_DATE%TYPE;
  l_effective_end_date			per_all_assignments_f.EFFECTIVE_END_DATE%TYPE;
  l_comment_id				per_all_assignments_f.COMMENT_ID%TYPE;
  l_soft_coding_keyflex_id		per_all_assignments_f.SOFT_CODING_KEYFLEX_ID%TYPE;
  l_other_manager_warning		boolean;
  l_no_managers_warning			boolean;
  l_hourly_salaried_warning		boolean;
  l_gsp_post_process_warning		varchar2(2000);
  l_object_version_number		per_all_assignments_f.OBJECT_VERSION_NUMBER%TYPE;

  l_datetrack_update_mode		varchar2(2000);


Begin
--hr_utility.trace_on(NULL,'NL_LYS');
if g_debug then
hr_utility.set_location('Inside update_assignments: p_person_id'||p_person_id,900);
hr_utility.set_location('Inside update_assignments: p_effective_date'||p_effective_date,900);
hr_utility.set_location('Inside update_assignments: p_override_value'||p_override_value,900);
end if;

  FOR l_assignment IN get_all_assignments(p_person_id ,p_effective_date) LOOP

if g_debug then
  hr_utility.set_location('Inside update_assignments: l_object_version_number'||l_object_version_number,1000);
  hr_utility.set_location('Inside update_assignments: p_override_value'||p_override_value,1000);
end if;
/*  l_datetrack_update_mode:='UPDATE';

if g_debug then
hr_utility.set_location('Inside l_assignment.effective_start_date'||l_assignment.effective_start_date,1150);
hr_utility.set_location('Inside l_assignment.effective_end_date'||l_assignment.effective_end_date,1150);
end if;

  IF p_effective_date = l_assignment.effective_start_date THEN
  l_datetrack_update_mode:='CORRECTION';
  ELSIF l_assignment.effective_end_date <> hr_general.end_of_time THEN
  l_datetrack_update_mode := 'UPDATE_CHANGE_INSERT';
  END IF; */

if g_debug then
hr_utility.set_location('Inside l_datetrack_update_mode'||l_datetrack_update_mode,1200);
hr_utility.set_location('Inside p_assignment_id'||p_assignment_id,1200);
hr_utility.set_location('Inside l_assignment.assignment_id'||l_assignment.assignment_id,1200);
hr_utility.set_location('Inside l_assignment.segment12'||l_assignment.segment12,1200);
hr_utility.set_location('Inside update_assignments: p_override_value'||fnd_number.number_to_canonical(p_override_value),1200);
end if;

IF p_assignment_id <> l_assignment.assignment_id  and /*4606747*/ nvl(p_override_value,0) <> nvl(fnd_number.canonical_to_number(l_assignment.segment12),0) THEN
hr_utility.set_location('Inside If '||l_assignment.segment12,1200);
l_soft_coding_keyflex_id := NULL; -- Bug 5763286
 hr_nl_assignment_api.update_nl_emp_asg
     (p_validate => FALSE
     ,p_effective_date => p_effective_date
     ,p_person_id => p_person_id
     ,p_datetrack_update_mode => p_dt_update_mode
     ,p_assignment_id => l_assignment.assignment_id
     ,p_object_version_number =>   l_assignment.object_version_number
     ,p_last_year_salary => fnd_number.number_to_canonical(p_override_value)
     ,p_cagr_grade_def_id => l_cagr_grade_def_id
     ,p_cagr_concatenated_segments => l_cagr_concatenated_segments
     ,p_concatenated_segments => l_concatenated_segments
     ,p_soft_coding_keyflex_id => l_soft_coding_keyflex_id
     ,p_comment_id => l_comment_id
     ,p_effective_start_date => l_effective_start_date
     ,p_effective_end_date => l_effective_end_date
     ,p_no_managers_warning => l_no_managers_warning
     ,p_other_manager_warning => l_other_manager_warning
     ,p_hourly_salaried_warning => l_hourly_salaried_warning
     ,p_gsp_post_process_warning => l_gsp_post_process_warning);

END IF;
END LOOP;
--commit; /*commented for bug 4058149 */
Exception
When Others Then
hr_utility.set_location('In update_assignments SQLERRM'||SQLERRM||'SQLCODE'||SQLCODE,2000);

End update_assignments;
END pay_nl_eoy_pkg;

/
