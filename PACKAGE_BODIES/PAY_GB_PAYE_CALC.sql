--------------------------------------------------------
--  DDL for Package Body PAY_GB_PAYE_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_PAYE_CALC" as
/* $Header: pygbpaye.pkb 120.6.12010000.8 2010/02/03 05:15:57 rlingama ship $
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1989 Oracle Corporation UK Ltd.,                *
   *                   Richmond, England.                           *
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

    Name        : pay_gb_paye_calc

    Description : This package contains calculations for use in PAYE processing

    Uses        :

    Used By     : FOT fast formula


    Change List :

    Version	Date	 Author		Description
    ------- 	-----	 --------	----------------
    115.0	6/6/01	 GBUTLER	Created
    115.3     21/12/06   SBAIRAGI       Added check_tax_ref function
    115.5     28/12/05   TUKUMAR	Bug 4528372 : added function tax_year_of_pensioners_death
    115.6     04/01/06   SBAIRAGI       4724096 - PAYE Aggregated Assignments validation.
    115.7     12/07/07   SBAIRAGI       PAYE Details check for bug 6018309
    115.8     25/09/08   rlingama       Bug 7389532 - Added the distinct and null condition on period of service id
                                        column for cur_chk_tax_code cursor.
    115.9     03/11/08	 rlingama       Bug 7492621 the PAYE mismatch error should come after
                                        6th April 2008 check is added.
    115.11    12/11/08	 rlingama       Bug 7492621 - Reverted the root cause for the issue introduced in HRMS FPK
                                        Rollup 3 for the PAYE mismatch error.
    115.12    03/04/08	 rlingama       Bug 7601088 - Re-introduced the PAYE validation.
    115.13    19/11/09	 jvaradra       Bug 9127942 - Changed the PAYE validation from 06-Apr-2009 to 06-Apr-2010.
    115.14    02/02/10   rlingama       Bug 9278271 -  Replaced the select query with cursor cur_get_paye_agg to avoid
                                        technical errors.
*/


/* Calculate free pay for given amount */
function free_pay
( p_amount IN NUMBER,
  p_tax_code IN VARCHAR2,
  p_tax_basis IN VARCHAR2,
  p_stat_annual_periods IN NUMBER,
  p_current_period IN NUMBER)
return NUMBER
as

l_tax_code 		VARCHAR2(8);
l_scots_code		BOOLEAN := FALSE;
l_k_code 		BOOLEAN := FALSE;
l_num_code		NUMBER;
l_remainder		NUMBER;
l_part1			NUMBER;
l_ann_value		NUMBER;
l_period1_pay		NUMBER;
l_free_or_add_pay	NUMBER;
l_taxable_pay		NUMBER;
l_amount 		NUMBER;



begin

--hr_utility.trace_on(null,'FOT');

hr_utility.trace('ENTERING: pay_gb_paye_calc.free_pay');

hr_utility.trace('***********************');
hr_utility.trace('INPUT values:	     ');
hr_utility.trace('Amount: '||p_amount);
hr_utility.trace('Tax code: '||p_tax_code);
hr_utility.trace('Tax basis: '||p_tax_basis);
hr_utility.trace('Stat annual periods: '||p_stat_annual_periods);
hr_utility.trace('Current pay period: '||p_current_period);
hr_utility.trace('***********************');

l_amount := p_amount;

/* Check for Scottish tax code, S prefix, strip off S prefix if present */
if upper(substrb(p_tax_code,1,1)) = 'S'
then

   l_scots_code := TRUE;
   l_tax_code := ltrim(p_tax_code,'S');

else

   l_tax_code := p_tax_code;

end if;


/* Check for K codes */
if substrb(l_tax_code,1,1) = 'K'
then

   l_k_code := TRUE;
   l_num_code := to_number(substrb(l_tax_code,2,length(l_tax_code) -1 ));


else


   l_num_code := to_number(substrb(l_tax_code,1,length(l_tax_code) -1 ));

end if;

hr_utility.trace('Numeric component: '||l_num_code);


/* Check if numeric component > 500 */
if l_num_code > 500
then

    l_remainder := floor((l_num_code - 1)/500);
    l_part1 := l_num_code - ( l_remainder * 500) + 1;
    l_ann_value := ((l_part1 * 10) + 9) + (5000 * l_remainder);


else

    l_ann_value := (l_num_code * 10) + 9;

end if;

hr_utility.trace('Annual free/additional pay: '||l_ann_value);



/* Calculate free/additional pay for period 1, apply rounding rules*/

l_period1_pay := (l_ann_value/p_stat_annual_periods);

if mod((l_period1_pay * 100),1) <> 0
then

   l_period1_pay := round(l_period1_pay,4);

   l_period1_pay := trunc(l_period1_pay + 0.01,2);

end if;


hr_utility.trace('Free/additional pay for period 1: '||l_period1_pay);


/* If tax basis is cumulative, find free/additional pay for year to date */
/* else just use free/additional pay for period 1			 */

if p_tax_basis = 'C'
then

	/* Calculate free/additional pay for year to date, based on current pay period (cumulative basis only) */


	l_free_or_add_pay := p_current_period * l_period1_pay;

else

	l_free_or_add_pay := l_period1_pay;


end if;


hr_utility.trace('Free/additional pay : '||l_free_or_add_pay);



/* Now calculate the taxable pay to date by subtracting/adding free/additional pay */
/* to the cumulative value entered in as an input value */
/* 1) If taxable pay is less then cumulative/period 1 free pay and tax code is not K, then set free pay to 0 */
/* as subtracting free pay from taxable pay would result in negative amount (cumulative tax basis only)*/
/* 2) If tax code was a K code then add the free/additional pay, else subtract it */


if (l_k_code)
then

   hr_utility.trace('K code is TRUE');
   l_taxable_pay := l_amount + l_free_or_add_pay;

else

   hr_utility.trace('K code is FALSE');

   if (l_free_or_add_pay >= l_amount)
   then

     hr_utility.trace('Free pay exceeds taxable pay for this period - setting taxable pay to 0');
     l_taxable_pay := 0;

   else

     l_taxable_pay := l_amount - l_free_or_add_pay;

   end if;

end if;

hr_utility.trace('********************');
hr_utility.trace('OUTPUT values:      ');
hr_utility.trace('Taxable pay: '||l_taxable_pay);
hr_utility.trace('********************');

hr_utility.trace('LEAVING: pay_gb_paye_calc.free_pay');

--hr_utility.trace_off;

return l_taxable_pay;

exception


when others
then raise;

end free_pay;

/* Calculate tax due to date on taxable pay */

function tax_to_date
(p_session_date IN DATE,
 p_taxable_pay IN NUMBER,
 p_tax_code IN VARCHAR2,
 p_tax_basis IN VARCHAR2,
 p_stat_annual_periods IN NUMBER,
 p_current_period IN NUMBER)
return NUMBER
as


l_row_num            NUMBER := 0;
l_current_deduct     NUMBER;
l_band_tax_deduct    NUMBER;
l_temp_val 	     NUMBER;
l_tax_liable	     NUMBER;
l_scots_code	     BOOLEAN := FALSE;
l_taxable_pay	     NUMBER;


l_td_net_low         NUMBER;
l_td_net_high	     NUMBER;
l_td_tax_col	     NUMBER;



cursor csr_paye is
   select pur.row_low_range_or_name,
   	  pur.row_high_range,
   	  puci.value
   from pay_user_tables put,
   	pay_user_rows_f pur,
   	pay_user_columns puc,
   	pay_user_column_instances_f puci
   where put.user_table_id = puc.user_table_id
   and pur.user_table_id = puc.user_table_id
   and puci.user_row_id = pur.user_row_id
   and puci.user_column_id = puc.user_column_id
   and upper(puc.user_column_name) = upper('paye_percentage')
   and put.legislation_code = 'GB'
   and upper(put.user_table_name) = upper('PAYE')
   and p_session_date between puci.effective_start_date and puci.effective_end_date
   and p_session_date between pur.effective_start_date and pur.effective_end_date
   order by pur.row_low_range_or_name;


cursor csr_scot_paye is
   select pur.row_low_range_or_name,
   	  pur.row_high_range,
   	  puci.value
   from pay_user_tables put,
   	pay_user_rows_f pur,
   	pay_user_columns puc,
   	pay_user_column_instances_f puci
   where put.user_table_id = puc.user_table_id
   and pur.user_table_id = puc.user_table_id
   and puci.user_row_id = pur.user_row_id
   and puci.user_column_id = puc.user_column_id
   and upper(puc.user_column_name) = upper('paye_percentage_svr')
   and put.legislation_code = 'GB'
   and upper(put.user_table_name) = upper('PAYE')
   and p_session_date between puci.effective_start_date and puci.effective_end_date
   and p_session_date between pur.effective_start_date and pur.effective_end_date
   order by pur.row_low_range_or_name;


begin

--hr_utility.trace_on(null,'FOT');

hr_utility.trace('ENTERING: pay_gb_paye_calc.tax_to_date');

hr_utility.trace('*********************');
hr_utility.trace('INPUT values: 	   ');
hr_utility.trace('Session date: '||to_char(p_session_date,'DD/MM/YYYY'));
hr_utility.trace('Taxable Pay: '||p_taxable_pay);
hr_utility.trace('Tax code: '||p_tax_code);
hr_utility.trace('Tax basis: '||p_tax_basis);
hr_utility.trace('Stat annual periods: '||p_stat_annual_periods);
hr_utility.trace('Current pay period: '||p_current_period);
hr_utility.trace('*********************');

l_taxable_pay := p_taxable_pay;


/* Convert down to nearest pound */

l_taxable_pay := floor(l_taxable_pay);

hr_utility.trace('Rounded taxable pay: '||l_taxable_pay);


/* Check for Scottish tax code, S prefix */

if upper(substrb(p_tax_code,1,1)) <> 'S'
then


-- Populate PL/SQL table if not already populated
-- else bypass this phase

if not g_table_inited
then

   hr_utility.trace('Initing PAYE table...');

	for r_paye in csr_paye loop

	  l_row_num := l_row_num + 1;

	  tbl_paye_table(l_row_num).g_gross_low_value := r_paye.row_low_range_or_name;
	  tbl_paye_table(l_row_num).g_gross_high_value := r_paye.row_high_range;
	  tbl_paye_table(l_row_num).g_rate := r_paye.value;
	  tbl_paye_table(l_row_num).g_gross_denom := 100 - r_paye.value;

	  /* First iteration, set net low value to 0 */
	  /* Set tax to be rated percentage of gross high value for this row */
	  /* Set tax column for this row to 0 */
	  if l_row_num = 1
	  then

	     tbl_paye_table(l_row_num).g_net_low_value := 0;

	     tbl_paye_table(l_row_num).g_tax_deduct := tbl_paye_table(l_row_num).g_gross_high_value * (tbl_paye_table(l_row_num).g_rate/100);
	     tbl_paye_table(l_row_num).g_tax_column := 0;

	  /* Subsequent iterations, set net low value to be net high value of previous row + 0.01*/
	  /* get gross high value of this row first, then subtract from that the gross high values of previous rows*/
	  else

	     tbl_paye_table(l_row_num).g_net_low_value := tbl_paye_table(l_row_num-1).g_net_high_value + 0.01;

	     l_temp_val := tbl_paye_table(l_row_num).g_gross_high_value;

	     for i in reverse 1..l_row_num-1 loop

	      l_temp_val := l_temp_val - tbl_paye_table(i).g_gross_high_value;

	     end loop;

	  /* Get the percentage of the values found above */
	     l_current_deduct := l_temp_val * (tbl_paye_table(l_row_num).g_rate/100);

	  /* add percentage for this row to that of the row before to get */
	  /* max deductible amount for this row */
	  /* set tax column to tax deductible value of previous row */
	     tbl_paye_table(l_row_num).g_tax_deduct := l_current_deduct + tbl_paye_table(l_row_num-1).g_tax_deduct;

	     tbl_paye_table(l_row_num).g_tax_column := tbl_paye_table(l_row_num-1).g_tax_deduct;



	  end if;

	 /* Find net high value for this row by subtracting the max deductible amount */
	 /* from the gross high value for this row */
	 tbl_paye_table(l_row_num).g_net_high_value := tbl_paye_table(l_row_num).g_gross_high_value - tbl_paye_table(l_row_num).g_tax_deduct;

	end loop;

g_table_inited := TRUE;

end if;

-- Show what's in the table

for loop_count in 1..tbl_paye_table.count loop


   hr_utility.trace('*************************');
   hr_utility.trace('Tax band '||loop_count);
   hr_utility.trace('*************************');
   hr_utility.trace('Gross low: '||tbl_paye_table(loop_count).g_gross_low_value||'  Gross high: '||tbl_paye_table(loop_count).g_gross_high_value);
   hr_utility.trace('Rate: '||tbl_paye_table(loop_count).g_rate);
   hr_utility.trace('Gross denominator: '||tbl_paye_table(loop_count).g_gross_denom);
   hr_utility.trace('Net low: '||tbl_paye_table(loop_count).g_net_low_value||'      Net high: '||tbl_paye_table(loop_count).g_net_high_value);
   hr_utility.trace('Tax deduct: '||tbl_paye_table(loop_count).g_tax_deduct);
   hr_utility.trace('Tax column: '||tbl_paye_table(loop_count).g_tax_column);
   hr_utility.trace('************************');


   if p_tax_basis = 'C'
   then

      l_td_net_low := (tbl_paye_table(loop_count).g_net_low_value * p_current_period) / p_stat_annual_periods;
      l_td_net_high := (tbl_paye_table(loop_count).g_net_high_value * p_current_period) / p_stat_annual_periods;
      l_td_tax_col := (tbl_paye_table(loop_count).g_tax_column * p_current_period) / p_stat_annual_periods;


   else

      l_td_net_low := tbl_paye_table(loop_count).g_net_low_value / p_stat_annual_periods;
      l_td_net_high := tbl_paye_table(loop_count).g_net_high_value / p_stat_annual_periods;
      l_td_tax_col := tbl_paye_table(loop_count).g_tax_column / p_stat_annual_periods;

   end if;



   if (l_taxable_pay <= ceil(l_td_net_high)
      AND l_taxable_pay >= ceil(l_td_net_low))
   then

        hr_utility.trace('Band/loop count: '||loop_count);
        hr_utility.trace('TD NL: '||l_td_net_low);
        hr_utility.trace('TD NH: '||l_td_net_high);
        hr_utility.trace('TD TC: '||l_td_tax_col);

        l_tax_liable := l_td_tax_col +
		    (((l_taxable_pay - l_td_net_low) * (tbl_paye_table(loop_count).g_rate/100))
                     * (100/tbl_paye_table(loop_count).g_gross_denom));

   end if;


end loop;




/* Code is Scots tax code, treat accordingly */

else

l_scots_code := TRUE;

-- Populate PL/SQL table if not already populated
-- else bypass this phase

if not g_table_inited
then

  hr_utility.trace('Initing PAYE table...');

	for r_scot_paye in csr_scot_paye loop

	  l_row_num := l_row_num + 1;

	  tbl_paye_table(l_row_num).g_gross_low_value := r_scot_paye.row_low_range_or_name;
	  tbl_paye_table(l_row_num).g_gross_high_value := r_scot_paye.row_high_range;
	  tbl_paye_table(l_row_num).g_rate := r_scot_paye.value;
	  tbl_paye_table(l_row_num).g_gross_denom := 100 - r_scot_paye.value;

	  /* First iteration, set net low value to 0 */
	  /* Set tax to be rated percentage of gross high value for this row */
	  /* Set tax column for this row to 0 */
	  if l_row_num = 1
	  then

	     tbl_paye_table(l_row_num).g_net_low_value := 0;

	     tbl_paye_table(l_row_num).g_tax_deduct := tbl_paye_table(l_row_num).g_gross_high_value * (tbl_paye_table(l_row_num).g_rate/100);
	     tbl_paye_table(l_row_num).g_tax_column := 0;

	  /* Subsequent iterations, set net low value to be net high value of previous row + 0.01*/
	  /* get gross high value of this row first, then subtract from that the gross high values of previous rows*/
	  else

	     tbl_paye_table(l_row_num).g_net_low_value := tbl_paye_table(l_row_num-1).g_net_high_value + 0.01;

	     l_temp_val := tbl_paye_table(l_row_num).g_gross_high_value;

	     for i in reverse 1..l_row_num-1 loop

	      l_temp_val := l_temp_val - tbl_paye_table(i).g_gross_high_value;

	     end loop;

	  /* Get the percentage of the values found above */
	     l_current_deduct := l_temp_val * (tbl_paye_table(l_row_num).g_rate/100);

	  /* add percentage for this row to that of the row before to get */
	  /* max deductible amount for this row */
	  /* set tax column to tax deductible value of previous row */
	     tbl_paye_table(l_row_num).g_tax_deduct := l_current_deduct + tbl_paye_table(l_row_num-1).g_tax_deduct;

	     tbl_paye_table(l_row_num).g_tax_column := tbl_paye_table(l_row_num-1).g_tax_deduct;



	  end if;

	 /* Find net high value for this row by subtracting the max deductible amount */
	 /* from the gross high value for this row */
	 tbl_paye_table(l_row_num).g_net_high_value := tbl_paye_table(l_row_num).g_gross_high_value - tbl_paye_table(l_row_num).g_tax_deduct;

	end loop;

g_table_inited := TRUE;

end if;


-- Show what's in the table

for loop_count in 1..tbl_paye_table.count loop


   hr_utility.trace('*************************');
   hr_utility.trace('Tax band '||loop_count);
   hr_utility.trace('*************************');
   hr_utility.trace('Gross low: '||tbl_paye_table(loop_count).g_gross_low_value||'  Gross high: '||tbl_paye_table(loop_count).g_gross_high_value);
   hr_utility.trace('Rate: '||tbl_paye_table(loop_count).g_rate);
   hr_utility.trace('Gross denominator: '||tbl_paye_table(loop_count).g_gross_denom);
   hr_utility.trace('Net low: '||tbl_paye_table(loop_count).g_net_low_value||'      Net high: '||tbl_paye_table(loop_count).g_net_high_value);
   hr_utility.trace('Tax deduct: '||tbl_paye_table(loop_count).g_tax_deduct);
   hr_utility.trace('Tax column: '||tbl_paye_table(loop_count).g_tax_column);
   hr_utility.trace('************************');



   if p_tax_basis = 'C'
   then

      l_td_net_low := (tbl_paye_table(loop_count).g_net_low_value * p_current_period) / p_stat_annual_periods;
      l_td_net_high := (tbl_paye_table(loop_count).g_net_high_value * p_current_period) / p_stat_annual_periods;
      l_td_tax_col := (tbl_paye_table(loop_count).g_tax_column * p_current_period) / p_stat_annual_periods;

   else

      l_td_net_low := tbl_paye_table(loop_count).g_net_low_value / p_stat_annual_periods;
      l_td_net_high := tbl_paye_table(loop_count).g_net_high_value / p_stat_annual_periods;
      l_td_tax_col := tbl_paye_table(loop_count).g_tax_column / p_stat_annual_periods;

   end if;



   if (l_taxable_pay <= ceil(l_td_net_high)
      AND l_taxable_pay >= ceil(l_td_net_low))
   then

	hr_utility.trace('Band/loop count: '||loop_count);
	hr_utility.trace('TD NL: '||l_td_net_low);
        hr_utility.trace('TD NH: '||l_td_net_high);
        hr_utility.trace('TD TC: '||l_td_tax_col);

        l_tax_liable := l_td_tax_col +
		    (((l_taxable_pay - l_td_net_low) * (tbl_paye_table(loop_count).g_rate/100))
                     * (100/tbl_paye_table(loop_count).g_gross_denom));


   end if;



end loop;



end if;


/* Round down */

l_tax_liable := round(l_tax_liable,4);

l_tax_liable := trunc(l_tax_liable,2);

hr_utility.trace('Tax liability: '||l_tax_liable);


if (l_scots_code)
then

  hr_utility.trace('Scots code : TRUE');

else

  hr_utility.trace('Scots code : FALSE');

end if;


hr_utility.trace('********************');
hr_utility.trace('OUTPUT values:      ');
hr_utility.trace('Tax liability to date: '||l_tax_liable);
hr_utility.trace('********************');

hr_utility.trace('LEAVING: pay_gb_paye_calc.tax_to_date');

--hr_utility.trace_off;

return l_tax_liable;

exception

   when others
   then raise;

end tax_to_date;



--- Called from GB_TAX_REF_CHK formula.
--- Effective from 06-APR-2006.

function check_tax_ref(p_assignment_id number, p_payroll_id number, p_pay_run_date date,p_payroll_action_id number) return number
is

l_date_soy           date            ;
l_date_eoy           date            ;
l_effective_date     date            ;
l_assgt_creation_date  date ;
l_return number  ;

CURSOR cur_assgt_first_eff_start_date(p_assignment_id number )
	IS
		select min(effective_start_date) effective_start_date
		from   per_all_assignments_f
		where  assignment_id = p_assignment_id
	;

CURSOR cur_chk_pay_actions( p_payroll_action_id number, p_assignment_id number )
	IS
	    select   ppa.payroll_id old_payroll_id
		from   pay_payroll_actions ppa,
	      	       pay_assignment_actions paa
		where  ppa.payroll_action_id = paa.payroll_action_id
	        and    paa.assignment_id     = p_assignment_id
	        and    ppa.payroll_action_id <> p_payroll_action_id
		and    ppa.action_type       in  ('Q', 'R', 'B', 'I' , 'V')
		and    ppa.effective_date    >= l_date_soy
		and    ppa.effective_date    <= l_date_eoy ;



CURSOR cur_check_payroll_tax_ref(p_old_payroll_id number, p_new_payroll_id number)
	IS
		select count(*)     l_exist           -- if this cursor fetches '1', that means new payroll is valid.
		from   pay_all_payrolls_f           pap
	      	      ,hr_soft_coding_keyflex       scl
		where  pap.payroll_id               = p_new_payroll_id
		and    pap.soft_coding_keyflex_id   = scl.soft_coding_keyflex_id
		and    scl.segment1                 in
	        (
	        	select distinct scl.segment1
			from   pay_all_payrolls_f           pap
		      	  ,hr_soft_coding_keyflex       scl

			where
			      pap.payroll_id             = p_old_payroll_id
			and   pap.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
            and   pap.effective_start_date   <= l_effective_date
			and   pap.effective_end_date     >= l_effective_date
		)
	;

CURSOR cur_check_aggregated_asg(p_assignment_id number) is
  select count (distinct nvl(per_information10,'N') ) l_count
  from per_all_people_f papf , per_all_assignments_f paaf
    where paaf.assignment_id=p_assignment_id
    and papf.person_id=paaf.person_id
    and papf.effective_start_date > l_date_soy
    and papf.effective_start_date < l_date_eoy  ;



    /* PAYE Details check for bug 6018309*/
CURSOR cur_get_tax_reference(c_payroll_id number) is
   select hsck.segment1
  from pay_all_payrolls_f papf,
       hr_soft_coding_keyflex hsck
  where
       papf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
       and papf.payroll_id=c_payroll_id;

-- Start of bug 7601088 - commented out few columns which are not related to PAYE details.
CURSOR cur_chk_tax_code(c_tax_reference varchar2,
                        c_assignment_id number,c_pay_run_date date) IS
select count(*)
from
(
 select
     distinct
     ppev.INPUT_VALUE_ID1,
     ppev.TAX_CODE,
     ppev.INPUT_VALUE_ID2,
     ppev.D_TAX_BASIS,
     ppev.INPUT_VALUE_ID4,
     ppev.D_PAY_PREVIOUS,
     ppev.INPUT_VALUE_ID5,
     ppev.D_TAX_PREVIOUS,
     ppev.INPUT_VALUE_ID3,
     ppev.D_REFUNDABLE,
     ppev.INPUT_VALUE_ID6,
     ppev.D_AUTHORITY
   --ppev.entry_information1,
   --ppev.entry_information2

     from
(
SELECT ele.rowid ROW_ID, ele.element_entry_id, min(decode(inv.name, 'Tax Code', eev.input_value_id, null)) INPUT_VALUE_ID1,
min(decode(inv.name, 'Tax Code', eev.screen_entry_value, null)) Tax_Code,
min(decode(inv.name, 'Tax Basis', eev.input_value_id, null)) INPUT_VALUE_ID2,
min(decode(inv.name, 'Tax Basis', substr(HR_GENERAL.DECODE_LOOKUP('GB_TAX_BASIS',eev.screen_entry_value),1,80),null)) D_Tax_Basis,
min(decode(inv.name, 'Tax Basis', eev.screen_entry_value, null)) Tax_Basis, min(decode(inv.name, 'Refundable',
eev.input_value_id, null)) INPUT_VALUE_ID3,
min(decode(inv.name, 'Refundable', substr(HR_GENERAL.DECODE_LOOKUP('GB_REFUNDABLE',eev.screen_entry_value),1,80),null)) D_Refundable,
--min(decode(inv.name, 'Refundable', eev.screen_entry_value, null)) Refundable,
min(decode(inv.name, 'Pay Previous', eev.input_value_id, null)) INPUT_VALUE_ID4,
hr_chkfmt.changeformat(nvl(min(decode(inv.name, 'Pay Previous', eev.screen_entry_value, null)), 0), 'M', 'GBP') D_Pay_Previous,
--min(decode(inv.name, 'Pay Previous', eev.screen_entry_value, null)) Pay_Previous,
min(decode(inv.name, 'Tax Previous', eev.input_value_id, null)) INPUT_VALUE_ID5,
hr_chkfmt.changeformat(nvl(min(decode(inv.name, 'Tax Previous', eev.screen_entry_value, null)), 0), 'M', 'GBP') D_Tax_Previous,
--min(decode(inv.name, 'Tax Previous', eev.screen_entry_value, null)) Tax_Previous,
min(decode(inv.name, 'Authority', eev.input_value_id, null)) INPUT_VALUE_ID6,
min(decode(inv.name, 'Authority', substr(HR_GENERAL.DECODE_LOOKUP('GB_AUTHORITY',eev.screen_entry_value),1,80),null)) D_AUTHORITY,
--min(decode(inv.name, 'Authority', eev.screen_entry_value, null)) Authority,
ele.assignment_id,
ele.effective_start_date,
ele.effective_end_date,
ele.entry_information_category,
ele.entry_information1,
ele.entry_information2
from
pay_element_entries_f ele,
pay_element_entry_values_f eev,
pay_input_values_f inv,
pay_element_links_f lnk,
pay_element_types_f elt,

pay_all_payrolls_f papf,
per_all_assignments_f paaf,
hr_soft_coding_keyflex hsck

where  ele.element_entry_id = eev.element_entry_id
AND c_pay_run_date between ele.effective_start_date and ele.effective_end_date
AND eev.input_value_id + 0 = inv.input_value_id
AND c_pay_run_date between eev.effective_start_date and eev.effective_end_date
AND inv.element_type_id = elt.element_type_id
AND c_pay_run_date between inv.effective_start_date and inv.effective_end_date
AND ele.element_link_id = lnk.element_link_id
AND elt.element_type_id = lnk.element_type_id
AND c_pay_run_date between lnk.effective_start_date and lnk.effective_end_date
AND elt.element_name = 'PAYE Details'
AND c_pay_run_date between elt.effective_start_date and elt.effective_end_date

AND c_pay_run_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
AND c_pay_run_date BETWEEN papf.effective_start_date AND papf.effective_end_date

AND ele.assignment_id=paaf.assignment_id

AND papf.payroll_id=paaf.payroll_id
AND papf.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
AND hsck.segment1=c_tax_reference
AND paaf.person_id = (select distinct pap.person_id
                      from per_all_people_f pap,
                           per_all_assignments_f paaf1
                      where paaf1.person_id=pap.person_id
                      and   paaf1.assignment_id=c_assignment_id)
AND pay_gb_eoy_archive.get_agg_active_start (paaf.assignment_id, c_tax_reference,c_pay_run_date)
  = pay_gb_eoy_archive.get_agg_active_start(c_assignment_id, c_tax_reference,c_pay_run_date)
AND pay_gb_eoy_archive.get_agg_active_end(paaf.assignment_id, c_tax_reference,c_pay_run_date)
  = pay_gb_eoy_archive.get_agg_active_end(c_assignment_id, c_tax_reference,c_pay_run_date)
-- Bug 7601088 Ignore the P45 issued assignments while checking the aggregated assignment PAYE details with in CPE.
AND pay_p45_pkg.paye_return_p45_issued_flag(c_assignment_id,p_payroll_action_id) = 'N'
AND pay_p45_pkg.paye_return_p45_issued_flag(paaf.assignment_id,p_payroll_action_id) = 'N'
/*Bug 7389532 - Added the distinct and null condition */
AND paaf.period_of_service_id = (select distinct period_of_service_id
                                        from per_all_assignments_f paaf2
					where paaf2.assignment_id=c_assignment_id
					and paaf.person_id =paaf2.person_id
					and period_of_service_id is not null)

group by ele.rowid, ele.element_entry_id, ele.assignment_id, ele.entry_information_category,
ele.entry_information1, ele.entry_information2, ele.effective_start_date, ele.effective_end_date
) ppev
);

-- Bug#9278271
CURSOR cur_get_paye_agg(p_assignment_id number,
                        p_pay_run_date date) IS
select nvl(PER_INFORMATION10,'N')
from per_all_people_f
where person_id = (select distinct papf.person_id
                   from per_all_people_f papf, per_all_assignments_f paaf1
                   where  papf.person_id=paaf1.person_id
		   and paaf1.assignment_id= p_assignment_id)
and p_pay_run_date between effective_start_date and effective_end_date;

l_cur_chk_pay_actions	          cur_chk_pay_actions%ROWTYPE;
l_cur_check_payroll_tax_ref	  cur_check_payroll_tax_ref%ROWTYPE;
l_cur_check_aggregated_asg	  cur_check_aggregated_asg%ROWTYPE;

l_tax_reference_code  varchar2(30);
l_count_c number default 0;
l_aggregated_asg   varchar2(10);
l_pay_run_date    date;

begin
l_return:=0;


hr_utility.set_location('Enter CHECK_TAX_REF',10);


/*PAYE Details check for bug 6018309*/

select regular_payment_date into l_pay_run_date
 from per_time_periods ptp ,
      pay_payroll_actions ppa
 where ptp.time_period_id=ppa.time_period_id
 and ppa.payroll_action_id=p_payroll_action_id;


open cur_get_tax_reference(p_payroll_id);
fetch cur_get_tax_reference into l_tax_reference_code;
close cur_get_tax_reference;

-- Start of bug#9278271
 /*  select nvl(PER_INFORMATION10,'N') into l_aggregated_asg
       from per_all_people_f
       where person_id = (select distinct papf.person_id
                          from per_all_people_f papf, per_all_assignments_f paaf1
                          where  papf.person_id=paaf1.person_id
			   AND paaf1.assignment_id= p_assignment_id
			)
       and l_pay_run_date  between effective_start_date and effective_end_date;*/

open cur_get_paye_agg(p_assignment_id,l_pay_run_date);
fetch cur_get_paye_agg into l_aggregated_asg;
close cur_get_paye_agg;
-- End of bug#9278271

if (l_aggregated_asg='Y') then
open cur_chk_tax_code(l_tax_reference_code,p_assignment_id, l_pay_run_date);
fetch cur_chk_tax_code into l_count_c;
close cur_chk_tax_code;

/* Bug 7492621 the PAYE mismatch error should come after 6th April 2008 check is added*/
--if (l_count_c > 1) and (p_pay_run_date >= to_date('06/04/2008','dd/mm/yyyy')) then
 /*Bug 7492621 - changed the return value to 0 so the error won't come.*/
 --l_return:= 3;
 -- BUg 7601088 the PAYE mismatch error added after 6th April 2009.
 if (l_count_c > 1) and (p_pay_run_date >= to_date('06/04/2010','dd/mm/yyyy')) then  -- for bug 9127942
   l_return:= 3;
 return l_return;   /* Exit the function */
end if;
end if;
/* end of check for bug 6018309*/

select effective_date into l_effective_date
 from pay_payroll_actions ppa
 where ppa.payroll_action_id=p_payroll_action_id;


hr_utility.set_location('effetive date:'||to_char(l_effective_date),12);

        If l_effective_date >=to_date('06-04-'||substr(to_char(l_effective_date,'YYYY/MON/DD'),1,4),'DD-MM-YYYY' ) Then
		l_date_soy := to_date('06-04-'||substr(to_char(l_effective_date,'YYYY/MON/DD'),1,4),'DD-MM-YYYY' ) ;
		l_date_eoy := to_date('05-04-'||to_char(to_number(substr(to_char(l_effective_date,'YYYY/MON/DD'),1,4))+1 ),'DD-MM-YYYY')  ;
	Else
		l_date_soy := to_date('06-04-'||to_char(to_number(substr(to_char(l_effective_date,'YYYY/MON/DD'),1,4))-1 ),'DD-MM-YYYY')  ;
		l_date_eoy := to_date('05-04-'||substr(to_char(l_effective_date,'YYYY/MON/DD'),1,4),'DD-MM-YYYY') ;
	End If;

hr_utility.set_location('effetive date:'||to_char(l_effective_date)||'l_date_soy'||to_char(l_date_soy)||'l_date_eoy'||to_char(l_date_eoy),12);

open cur_assgt_first_eff_start_date(p_assignment_id);
fetch cur_assgt_first_eff_start_date into l_assgt_creation_date;

hr_utility.set_location('Payroll_id'||to_char(p_payroll_id)||'Assignment_id:'||to_char(p_assignment_id),13);

open cur_check_aggregated_asg(p_assignment_id);
fetch cur_check_aggregated_asg into l_cur_check_aggregated_asg;

 if(l_cur_check_aggregated_asg.l_count>1) then
      l_return :=2;
 end if;
close cur_check_aggregated_asg;

for l_cur_chk_pay_actions in cur_chk_pay_actions(p_payroll_action_id,p_assignment_id)
loop
  hr_utility.set_location('Old payroll Id:'||to_char(l_cur_chk_pay_actions.old_payroll_id)||' New payroll:'||to_char(p_payroll_id)||'l_return:'||to_char(l_return)||'Rows'||to_char(cur_chk_pay_actions%ROWCOUNT),13);
  exit when l_return<>0;

  for l_cur_check_payroll_tax_ref in cur_check_payroll_tax_ref(l_cur_chk_pay_actions.old_payroll_id , p_payroll_id)
   loop

    if ( l_cur_check_payroll_tax_ref.l_exist =0) then
     l_return :=1;
     exit when l_return<>0;
    end if ;

   end loop;

end loop;


hr_utility.set_location('L_return '||to_char(l_return)||'l_date_soy:'||to_char(l_date_soy)||'l_date_eoy:'||to_char(l_date_eoy),13);

hr_utility.set_location('Exit CHECK_TAX_REF',15);

close cur_assgt_first_eff_start_date;

return l_return;
end check_tax_ref;



-- Function tax_year_of_pensioners_death : Bug 4528372
-- To find out if the date of death of the pensioner is in the same tax year as
-- the date of the payment
-- called from PAYE formula for persioners VALIDATE_TAX_YEAR_OF_DEATH


function tax_year_of_pensioners_death(p_assignmnet_id IN number ,p_pay_run_date IN date)
return varchar2
is

 l_return number  ;
 l_tax_year_start date ;
 l_tax_year_end date ;
 l_date_of_death date := to_date('31-12-4712','DD-MM-YYYY') ;

 l_pay_date  number;
 l_pay_month number;
 l_start_factor NUMBER;
 l_end_factor NUMBER;



 cursor csr_date_of_death is
  select PEOPLE.DATE_OF_DEATH
  from   per_all_assignments_f           ASSIGN
        ,per_all_people_f               PEOPLE
        ,fnd_sessions                   SES
  where   SES.effective_date BETWEEN ASSIGN.effective_start_date
                            AND ASSIGN.effective_end_date
  and 	  SES.effective_date BETWEEN PEOPLE.effective_start_date
                            AND PEOPLE.effective_end_date
  and     ASSIGN.assignment_id           = p_assignmnet_id
  and     PEOPLE.person_id               = ASSIGN.person_id
  and     PEOPLE.per_information4        ='Y'
  and     PEOPLE.DATE_OF_DEATH is not null
  and     SES.session_id                 = USERENV('sessionid') ;


BEGIN

  hr_utility.set_location('tax_year_of_pensioners_death',0);

  l_pay_date  :=  to_number( to_char( p_pay_run_date ,'DD' ) ) ;
  l_pay_month :=  to_number( to_char( p_pay_run_date ,'MM' ) ) ;

  If l_pay_month >=4 and l_pay_date >=6 then
   l_start_factor := 0;
   l_end_factor   := 1;
  end if;

  If ( l_pay_month >=4 and l_pay_date < 6 ) OR l_pay_month < 4 then
   l_start_factor := 1;
   l_end_factor   := 0;
  end if;

  l_tax_year_start := to_date('06-04-' ||
            to_char(to_number(to_char(p_pay_run_date,'YYYY' ) ) -l_start_factor ),'DD-MM-YYYY' );

  l_tax_year_end := to_date('05-04-' ||
            to_char(to_number(to_char(p_pay_run_date,'YYYY' ) ) + l_end_factor ),'DD-MM-YYYY' );

  open csr_date_of_death;
  fetch csr_date_of_death into l_date_of_death;
  close csr_date_of_death;

  if l_date_of_death >= l_tax_year_start and l_date_of_death <= l_tax_year_end then
	l_return :=1;
  else
	l_return :=0;
  end if;

  hr_utility.set_location('tax_year_of_pensioners_death',99);
  return(l_return);

END tax_year_of_pensioners_death;


/* End of package body */
end pay_gb_paye_calc;

/
