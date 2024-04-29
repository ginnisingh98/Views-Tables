--------------------------------------------------------
--  DDL for Package Body PAY_GB_WORKING_TAX_CREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_WORKING_TAX_CREDIT" as
/* $Header: pygbwtcp.pkb 115.1 2003/12/17 01:29:18 asengar noship $
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2002 Oracle Corporation UK Ltd.,                *
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

    Name        : pay_gb_working_tax_credit

    Description : This package contains calculations for use in processing
        	  working tax credits from 06 April 2003 onwards

    Uses        :

    Used By     : WORKING_TAX_CREDIT fast formula

    Change List :

    Version     Date     	Author         Description
    -------     -----    	--------       ----------------

   115.0        4/10/2002   	GBUTLER        Created
   115.1        12/12/2003      asengar        BUG 3221422 Changed Query of CURSOR
                                               csr_daily_amt_iv_id for
                                               improving performance.
*/

g_package_name VARCHAR2(25) := 'PAY_GB_WORKING_TAX_CREDIT';

/* Primary function to calculate total amount payable to employee */
/* Called by WORKING_TAX_CREDIT fast formula			  */
/* Context parameters: p_assignment_id				  */

/* Function parameters: p_start_date				  */
/*			p_end_date				  */

function calculate_payable
	 (p_assignment_id 		IN NUMBER,
	  p_start_date 			IN DATE,
	  p_end_date   			IN DATE)
	  return number is

l_function_name 	VARCHAR2(17) := 'calculate_payable';

l_daily_amt_iv_id	pay_input_values_f.input_value_id%TYPE;

l_calc_start_date	DATE;
l_calc_end_date		DATE;

l_days_payable		NUMBER := 0;

l_running_total		NUMBER := 0;

l_total_payable		NUMBER := 0;

/* Get input value id for Daily Amount */
-- BUG 3221422 Changed Query for improving performance
cursor csr_daily_amt_iv_id is
	select piv.input_value_id
	from pay_input_values_f piv,
	     pay_element_types_f petf
	where petf.element_type_id = piv.element_type_id
	and petf.element_name = 'Working Tax Credit'
	and piv.name = 'Daily Amount'
	and petf.legislation_code = 'GB';

/* Find Working Tax Credit element entries 			  */
/* Only retrieve those entries that begin in or cross over into   */
/* the period defined by the p_start_date and p_end_date 	  */
/* parameters; past and future entries not relevant here	  */
cursor csr_wtc_entries is
	select peef.effective_start_date as start_date,
	       peef.effective_end_date	 as end_date,
		max(decode(peev.input_value_id,l_daily_amt_iv_id,
			fnd_number.canonical_to_number(peev.Screen_entry_value),null)) as daily_amount
	from pay_element_entry_values_f peev,
	     pay_element_entries_f peef,
	     pay_element_links_f pelf,
	     pay_element_types_f petf
	where pelf.element_link_id = peef.element_link_id
	and peef.element_entry_id = peev.element_entry_id
	and petf.element_type_id = pelf.element_type_id
	and peev.effective_start_date = peef.effective_start_date
	and upper(petf.element_name) = upper('Working Tax Credit')
	and petf.legislation_code = 'GB'
	and peef.assignment_id = p_assignment_id
	and peef.effective_start_date <= p_end_date
	and (	peef.effective_start_date >= p_start_date
	 	OR (peef.effective_start_date <= p_start_date
	     	    AND peef.effective_end_date >= p_start_date)
	    )
	and peef.entry_type = 'E'
	group by peef.effective_start_date, peef.effective_end_date;

begin

hr_utility.set_location(g_package_name||'.'||l_function_name,1);

hr_utility.trace('p_start_date: '||p_start_date);
hr_utility.trace('p_end_date:   '||p_end_date);

/* Get Daily Amount input value */
open csr_daily_amt_iv_id;
fetch csr_daily_amt_iv_id into 	l_daily_amt_iv_id;
close csr_daily_amt_iv_id;

hr_utility.set_location(g_package_name||'.'||l_function_name,2);

/* Open cursor to retrieve working tax credit element entries up to p_end_date */
/* Loop round until all relevant entries retrieved			       */

for current_entry in csr_wtc_entries loop

	hr_utility.set_location(g_package_name||'.'||l_function_name,3);

	hr_utility.trace('current_entry.start_date: '||current_entry.start_date);
	hr_utility.trace('current_entry.end_date:   '||current_entry.end_date);

	/* Initialise calculation start and end dates to null */
	l_calc_start_date := null;
	l_calc_end_date   := null;

	/* Determine which start date and end date to use when determining days */
	/* payable for this current element entry				*/

	/* Start date */
	if p_start_date between current_entry.start_date
			     and current_entry.end_date
	then
	/* an active tax credit entry crosses into this period  */
	/* use period start date as start point for calculation */
		l_calc_start_date := p_start_date;

	else
	/* start date of tax credit entry must be greater than */
	/* period start date, so use start date of entry       */
		l_calc_start_date := current_entry.start_date;

	end if;

	/* End date */

	if p_end_date between current_entry.start_date
			   and current_entry.end_date
	then
	/* an active tax credit entry continues beyond this period   	 */
	/* Use period end date as end point for calculation		 */
	/* Tax credit entries where the employee has been terminated 	 */
	/* or a stop notice has been issued will not have been end-dated */
	/* by this point, so they will be included in this scenario as	 */
	/* p_end_date will be the least of payroll period end date,	 */
	/* actual termination date and Stop Date of the tax credit	 */
		l_calc_end_date := p_end_date;

	else
	/* user or another process must have manually end-dated current */
	/* entry, so use end date of entry				*/
		l_calc_end_date := current_entry.end_date;

	end if;

	hr_utility.trace('Calculation start date: '||l_calc_start_date);
	hr_utility.trace('Calculation end date:   '||l_calc_end_date);

	hr_utility.set_location(g_package_name||'.'||l_function_name,4);

	/* Work out number of days between calculation start and end date */

	l_days_payable := pay_gb_working_tax_credit.days_between(l_calc_start_date, l_calc_end_date);


	/* Multiply days payable for this loop by daily rate for current entry */
	/* Add this amount to the running total amount for entries retrieved   */
	hr_utility.trace('Days payable: '||l_days_payable||' * current daily amount: '||
			 current_entry.daily_amount||' = '||(l_days_payable * current_entry.daily_amount));

	l_running_total := l_running_total + (l_days_payable * current_entry.daily_amount);

	hr_utility.trace('l_running_total: '||l_running_total);

	hr_utility.set_location(g_package_name||'.'||l_function_name,5);

end loop;

hr_utility.set_location(g_package_name||'.'||l_function_name,6);

l_total_payable := l_running_total;

hr_utility.trace('Total amount payable: '||l_total_payable);

hr_utility.set_location(g_package_name||'.'||l_function_name,7);

return l_total_payable;

end calculate_payable;


function days_between
     (p_start_date      date,
      p_end_date        date)
    return number is
--

  v_days_between       number := 0;
--
  begin

    v_days_between := p_end_date - p_start_date +1;

--
  return v_days_between;
--
  end days_between;


/* end of package */
end pay_gb_working_tax_credit;

/
