--------------------------------------------------------
--  DDL for Package Body PAY_GB_NICAR_06042002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_NICAR_06042002" as
/* $Header: pygbncpl.pkb 115.21 2003/01/15 09:38:10 mmahmad noship $
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

    Name        : pay_gb_nicar_2002

    Description : This package contains calculations for use in processing
	          of NI Car Primary and Secondary elements

    Uses        :

    Used By     : NI Car fast formulas for tax year 2002/3


    Change List :

    Version     Date     Author         Description
    -------     -----    --------       ----------------

     115.0      20/8/01  GBUTLER        Created
     115.1	30/9/01	 GBUTLER	Commented out trace_on
					and trace_Off commands
     115.2      5/10/01  GBUTLER        Changed pro-ration aspects
			   		on benefit charges and fuel
					scale
     115.3      8/11/01  GBUTLER        Check on CO2 emissions for
                                        petrol/diesel & bi-fuel conversion
					cars - if emissions figure
                                        entered below min level for year, level
                                        adjusted up to match min level.
     115.4      9/11/01  GBUTLER        Included fix for potential week 53 problem
                                        when comparing current payroll period to
                                        number of payroll periods in year
     115.5      4/12/01  vmkhande       Modified some functions
                                        such that they can be used to
                                        do the calculation for P11D element
                                        verifications
     115.9	15/1/02	 GBUTLER	Bug 2142983. Added nicar_main procedure to
     					deal with date-tracked updates to car
     					element entries and modified nicar_nicable_
     					value_CO2 and nicar_nicable_value_non_CO2 to
     					be called from nicar_main. Fast formulas for
     					NI Car will now call nicar_main directly
     					instead of calling the other 2 procedures as
     					happened previously. Also removed specific
     					parameters for P11d and get_next_pay_date function as
					no longer required. Changed code for deduction of
					employee contributions (payments)
     115.10	11/4/02 GBUTLER		Put nvl() around condition which determines which
     					calculation procedure to call to deal with cars registered
     					before 01-JAN-1998 with no fuel type attached. Also included
     					defaults for engine size where required so that auto
     					calculation of fuel scale charges work correctly. Bugs 2281529
     					and 2279049. Changed fuel default to diesel.
     					Added functionality to process Euro IV diesel cars
     115.11	24/4/02 GBUTLER		Updated handling of messages to provide more logical approach.
     					Moved defaulting of fuel type and engine size to nicar_main
     					function.
     115.12	10/5/02 GBUTLER		Replaced p_message parameter in nicar_nicable_value_non_co2
     					function as parameter required by p11d packages that call
     					this function. Added l_cc_message in nicar_main to capture
     					output from p_message even though output will be null.
     					This fix for 11i only (not required on 11 or 10.7)
     115.13	03/7/02 GBUTLER		Bug 2444082. Added functionality to annualise period
     					numbers for non-standard payrolls (e.g. lunar) so that
     					comparison between current payroll period number and
     					payroll periods per year is effective when determining
     					whether to use tax year end date or current payroll period
     					end date in calculation.
     115.14     13/11/02 RMAKHIJA       Legislative changes to fuel scale charge for
                                        tax year 2003-2004
     115.15     29/11/02 RMAKHIJA       Commented Out trace on and off
     115.16     29/11/02 RMAKHIJA       Added WHWENVER OSERROR command at the top to fix
                                        GSCC warning.
     115.17     09/12/02 RMAKHIJA       Changed to count 29-FEB in calculation for leap years
     115.18     09/12/02 RMAKHIJA       Added NOCOPY to out parameters to fix GSCC warning
     115.19     12/12/02 RMAKHIJA       Added g_last_opt_out_date and csr_last_opt_out_date cursor
                                        to make sure fuel scale charge is not calculated for the
                                        last opted out period if the employee remains opted out.
     115.20     07/01/03 MMAHMAD        Added HYBRID ELECTRIC in the IN clause for the calculation
                                        of fuel charge.
     115.21     15/01/03 MMAHMAD        Added a call for the get_CO2_percentage function to calculate
                                        CO2 percentage for HYBRID ELECTRIC, LPG_CNG, LPG_CNG_Petrol and
                                        LPG_CNG_Petrol_Conv fuel types.
*/

g_package_name VARCHAR2(21) := 'PAY_GB_NICAR_06042002';

g_ignore_fuel_opt_out VARCHAR2(1) := 'N';
g_last_opt_out_date       date := to_date('01-01-0001', 'DD-MM-YYYY');
g_tax_year_start          date := to_date('06-04-2002', 'DD-MM-YYYY');
g_tax_year_end            date := to_date('05-04-2003', 'DD-MM-YYYY');
g_days_in_year            number := 365;

/* New NI Car Fast formula determines whether or not calculation of taxable / NICable */
/* value will be based on CO2 emissions or engine capacity - appropriate function is */
/* then called here */


/* Function to calculate taxable / NICable value based on CO2 emissions data for car */
/* Parameters p_business_group_id, p_assignment_id, p_element_type_id provided by */
/* context-set variables */
function nicar_nicable_value_CO2
( p_assignment_id				   IN NUMBER,
  p_element_type_id				   IN NUMBER,
  p_business_group_id			           IN NUMBER,
  /* Import direct from fast formula */
  p_car_price 				           IN NUMBER,
  p_reg_date  					   IN DATE,
  p_fuel_type 					   IN VARCHAR2,
  p_engine_size 				   IN NUMBER,
  p_fuel_scale					   IN NUMBER DEFAULT NULL,
  p_payment					   IN NUMBER,
  p_CO2_emissions 				   IN NUMBER DEFAULT NULL,
  p_start_date					   IN DATE,
  p_end_date					   IN DATE,
  p_end_of_period_date			   	   IN DATE,
  p_emp_term_date				   IN DATE,
  p_session_date				   IN DATE,
  p_message					   OUT NOCOPY VARCHAR2,
  p_number_of_days                 		   IN NUMBER DEFAULT 0)
return NUMBER is

l_function_name				VARCHAR2(23) := 'nicar_nicable_value_CO2';

l_CO2_emissions 			NUMBER;
l_percentage				NUMBER;

l_difference				NUMBER;

l_fixed_discount			NUMBER;
l_extra_discount			NUMBER;
l_discount_total			NUMBER;

l_diesel_supplement			NUMBER;

l_benefit_charge			NUMBER;

l_car_price				NUMBER;

l_min_qual_level 			NUMBER;
l_max_level 			        NUMBER;

l_min_percentage			NUMBER;
l_max_percentage			NUMBER;

l_reg_date				DATE;

l_start_date				DATE;
l_end_date				DATE;

l_end_of_period_date	 		DATE;

l_price_cap 				NUMBER;

l_days_available 			NUMBER;

l_fuel_scale				NUMBER;

l_fuel_type 				VARCHAR2(100);




cursor csr_min_qual_level is
	  select min(pur.row_low_range_or_name)
  	  from pay_user_rows_f pur,
	       pay_user_tables put
  	  where put.user_table_id = pur.user_table_id
	  and put.user_table_name = 'GB_CO2_EMISSIONS'
	  and p_session_date between
	  	  pur.effective_start_date and pur.effective_end_date;

cursor csr_max_level is
	 select max(pur.row_low_range_or_name)
  	 from pay_user_rows_f pur,
	      pay_user_tables put
  	 where put.user_table_id = pur.user_table_id
	 and put.user_table_name = 'GB_CO2_EMISSIONS'
	 and p_session_date between
	  	  pur.effective_start_date and pur.effective_end_date;


cursor csr_min_percentage is
	select min(value)
       	from   pay_user_column_instances_f puci,
    	       pay_user_columns puc
        where puc.user_column_id = puci.user_column_id
    	and puc.user_table_id =
    		(select user_table_id
    		 from pay_user_tables
    		 where user_table_name = 'GB_CO2_EMISSIONS')
    	and p_session_date between
			puci.effective_start_date and puci.effective_end_date;


cursor csr_max_percentage is
	select max(value)
        from   pay_user_column_instances_f puci,
    	       pay_user_columns puc
        where puc.user_column_id = puci.user_column_id
    	and puc.user_table_id =
    		(select user_table_id
    		 from pay_user_tables
    		 where user_table_name = 'GB_CO2_EMISSIONS')
    	and p_session_date between
			puci.effective_start_date and puci.effective_end_date;


cursor csr_max_price_global is
	   select to_number(global_value)
	   from ff_globals_f
	   where global_name = 'NI_CAR_MAX_PRICE'
	   and p_session_date between
	   	   effective_start_date and effective_end_date;




begin



hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,1);

hr_utility.trace('** Parameter values ** ');
hr_utility.trace('p_assignment_id: '||p_assignment_id);
hr_utility.trace('p_element_type_id: '||p_element_type_id);
hr_utility.trace('p_business_group_id: '||p_business_group_id);
hr_utility.trace('p_car_price: '||p_car_price);
hr_utility.trace('p_reg_date: '||p_reg_date);
hr_utility.trace('p_fuel_type: '||p_fuel_type);
hr_utility.trace('p_engine_size: '||p_engine_size);
hr_utility.trace('p_fuel_scale: '||p_fuel_scale);
hr_utility.trace('p_payment: '||p_payment);
hr_utility.trace('p_CO2_emissions: '||p_CO2_emissions);
hr_utility.trace('p_start_date: '||p_start_date);
hr_utility.trace('p_end_date: '||p_end_date);
hr_utility.trace('p_end_of_period_date: '||p_end_of_period_date);
hr_utility.trace('p_emp_term_date: '||p_emp_term_date);
hr_utility.trace('p_session_date: '||p_session_date);

hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,2);


l_start_date := trunc(p_start_date);
l_end_date   := trunc(p_end_date);
l_reg_date   := trunc(p_reg_date);
l_end_of_period_date := trunc(p_end_of_period_date);

l_car_price := p_car_price;
l_fuel_type := p_fuel_type;



hr_utility.trace('l_start_date: '||l_start_date);
hr_utility.trace('l_end_date: '||l_end_date);
hr_utility.trace('l_reg_date: '||l_reg_date);
hr_utility.trace('l_end_of_period_date: '||l_end_of_period_date);
hr_utility.trace('p_session_date: '||p_session_date);
hr_utility.trace('l_fuel_type: '||l_fuel_type);

hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,4);

/* Check if CO2 emissions figure is a multiple of 5, if not round down to nearest 5 */
l_CO2_emissions := p_CO2_emissions;

if mod(l_CO2_emissions,5) <> 0
then

	l_CO2_emissions := round_CO2_val(l_CO2_emissions);

end if;

hr_utility.trace('l_CO2_emissions: '||l_CO2_emissions);

hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,5);

/* Get values for minimum and maximum percentage rates */

open csr_min_percentage;
fetch csr_min_percentage into l_min_percentage;
close csr_min_percentage;

hr_utility.trace('l_min_percentage: '||l_min_percentage);


open csr_max_percentage;
fetch csr_max_percentage into l_max_percentage;
close csr_max_percentage;

hr_utility.trace('l_max_percentage: '||l_max_percentage);

hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,6);


/* Determine percentage rate for car based on fuel type and emissions data */

if l_fuel_type = 'BATTERY_ELECTRIC' -- battery electric
then
/* No CO2 emissions figure, deduct fixed discount from minimum percentage rate */

   l_percentage := l_min_percentage - get_discount(l_fuel_type,p_session_date);
   hr_utility.trace('l_percentage: '||l_percentage);

   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,7);

else
/* All other fuel types have CO2 emissions rating, find applicable percentage rate */
/* Calculation of discounts and percentage rates vary according to fuel type, check each in sequence */

   if l_fuel_type in ('HYBRID_ELECTRIC','LPG_CNG') -- hybrid electric or LPG/CNG
   then

   /* find minumum qualifying level for year, check if car CO2 rating on or below that level */
       hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,8);

	   open csr_min_qual_level;
	   fetch csr_min_qual_level into l_min_qual_level;
	   close csr_min_qual_level;

	   hr_utility.trace('l_min_qual_level: '||l_min_qual_level);
	   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,9);

	   if l_CO2_emissions < l_min_qual_level
	   then
	   /* Extra discount for every full 20 g/km below min qualifying level */

	   	   l_difference := l_min_qual_level - l_CO2_emissions;
		   l_extra_discount := trunc((l_difference/20),0);
           l_CO2_emissions := l_min_qual_level;

	   else
	   /* No extra discount if car CO2 rating same as min qualifying level */

	   	   l_extra_discount := 0;

	   end if;

  /* Check that CO2 level entered does not exceed maximum level for year */
  /* If it does, adjust it down to match maximum level */

	   open csr_max_level;
	   fetch csr_max_level into l_max_level;
	   close csr_max_level;

	   if l_co2_emissions > l_max_level
	   then

		  hr_utility.trace('Car CO2 emissions above max level for year, adjusting down');
		  l_co2_emissions := l_max_level;
		  p_message := p_message||'CO2 emissions adjusted down to max level.';

	   end if;

   	   l_percentage := get_CO2_percentage(p_business_group_id,l_co2_emissions,p_session_date);
	   hr_utility.trace('l_percentage: '||l_percentage);


	   hr_utility.trace('l_extra_discount: '||l_extra_discount);
	   /* Fixed discount varies according to fuel type */

	   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,10);

	   l_fixed_discount := get_discount(l_fuel_type,p_session_date);

	   hr_utility.trace('l_fixed_discount: '||l_fixed_discount);
	   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,11);

	   /* Calculate final discount amount, subtract from minimum percentage amount */

	   l_discount_total := l_fixed_discount + l_extra_discount;
	   l_percentage     := l_percentage - l_discount_total;


	   hr_utility.trace('l_percentage: '||l_percentage);
	   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,12);

   elsif l_fuel_type in ('LPG_CNG_PETROL', 'LPG_CNG_PETROL_CONV') -- bi-fuel (built as bi-fuel and converted)
   then

   	   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,13);

	   /* Calculation based on whether car built as bi-fuel or later converted */
	   /* Check when car first registered as calculation will differ based on registration date */

	   if ( l_fuel_type = 'LPG_CNG_PETROL' -- Bi-fuel (not converted)
	   	    and l_reg_date >= to_date('01/01/2000','DD/MM/YYYY'))  -- registered on/after Jan 1 2000
            or l_fuel_type = 'LPG_CNG_PETROL_CONV'
	   then

		   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,14);
		   /* find minumum qualifying level for year, check if car CO2 rating on or below that level */

		   open csr_min_qual_level;
		   fetch csr_min_qual_level into l_min_qual_level;
		   close csr_min_qual_level;

		   hr_utility.trace('l_min_qual_level: '||l_min_qual_level);
	   	   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,15);

		   if l_CO2_emissions < l_min_qual_level
		   then
		   /* Extra discount for every full 20 g/km below min qualifying level */

		   	   l_difference := l_min_qual_level - l_CO2_emissions;
			   l_extra_discount := trunc((l_difference/20),0);
               l_CO2_emissions := l_min_qual_level;

		   else
		   /* No extra discount if car CO2 rating same as min qualifying level */

		   	   l_extra_discount := 0;

		   end if;

      /* Check that CO2 level entered does not exceed maximum level for year */
	  /* If it does, adjust it down to match maximum level */

	   open csr_max_level;
	   fetch csr_max_level into l_max_level;
	   close csr_max_level;

	   if l_co2_emissions > l_max_level
	   then

		  hr_utility.trace('Car CO2 emissions above max level for year, adjusting down');
		  l_co2_emissions := l_max_level;
		  p_message := p_message||'CO2 emissions adjusted down to max level.';

	   end if;

   	   l_percentage := get_CO2_percentage(p_business_group_id,l_co2_emissions,p_session_date);
	   hr_utility.trace('l_percentage: '||l_percentage);

	   	   hr_utility.trace('l_extra_discount: '||l_extra_discount);

	   	   /* Find fixed discount */

		   l_fixed_discount := get_discount(l_fuel_type,p_session_date);

		   hr_utility.trace('l_fixed_discount: '||l_fixed_discount);
		   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,16);

		   /* Calculate final discount amount, subtract from minimum percentage amount */
		   l_discount_total := l_fixed_discount + l_extra_discount;
	   	   l_percentage := l_percentage - l_discount_total;

		   hr_utility.trace('l_percentage: '||l_percentage);
		   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,17);

	   /* Conversion bi-fuel cars and bi-fuel cars registered before Jan 1 2000 */

	   elsif (l_fuel_type = 'LPG_CNG_PETROL' and l_reg_date < to_date('01/01/2000','DD/MM/YYYY'))
	   then

		   	   p_message := 'Bi-fuel car calculated as if converted to bi-fuel.';
			   hr_utility.trace('Calculating bi-fuel car as if converted');

		   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,18);

		   /* get percentage rating based on car's actual CO2 emissions */
		   /* if CO2 level below minimum level for year, adjust up to match minimum level */

           	  open csr_min_qual_level;
	          fetch csr_min_qual_level into l_min_qual_level;
	          close csr_min_qual_level;

                  if l_co2_emissions < l_min_qual_level
                  then

              		hr_utility.trace('Car CO2 emissions below min level for year, adjusting up');
              		l_co2_emissions := l_min_qual_level;
              		p_message := p_message||'CO2 emissions adjusted up to min level.';

           	  end if;

		  /* Check that CO2 level entered does not exceed maximum level for year */
		  /* If it does, adjust it down to match maximum level */


		   open csr_max_level;
		   fetch csr_max_level into l_max_level;
		   close csr_max_level;

		   if l_co2_emissions > l_max_level
		   then

			  hr_utility.trace('Car CO2 emissions above max level for year, adjusting down');
			  l_co2_emissions := l_max_level;
			  p_message := p_message||'CO2 emissions adjusted down to max level.';

		   end if;

           	  l_percentage := get_CO2_percentage(p_business_group_id,
 		   				      l_co2_emissions,
						      p_session_date);


		   hr_utility.trace('l_percentage: '||l_percentage);
		   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,19);

		   /* fixed discount of 1% for this fuel type */

		   l_fixed_discount := get_discount(l_fuel_type,p_session_date);
		   hr_utility.trace('l_fixed_discount: '||l_fixed_discount);


		   l_percentage := l_percentage - l_fixed_discount;


   	   end if;


	elsif l_fuel_type in ('PETROL','DIESEL','EURO_IV_DIESEL') -- petrol, diesel, Euro IV diesel for compliant cars
	then

	/* Find appropriate percentage charge for CO2 emissions rating */

	   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,20);

       /* if CO2 level below minimum level for year, adjust up to match minimum level */

       	   open csr_min_qual_level;
	   fetch csr_min_qual_level into l_min_qual_level;
	   close csr_min_qual_level;

       	   if l_co2_emissions < l_min_qual_level
           then

              hr_utility.trace('Car CO2 emissions below min level for year, adjusting up');
              l_co2_emissions := l_min_qual_level;
              p_message := 'CO2 emissions adjusted up to min level.';

           end if;

	   /* Check that CO2 level entered does not exceed maximum level for year */
	   /* If it does, adjust it down to match maximum level */


	   open csr_max_level;
	   fetch csr_max_level into l_max_level;
	   close csr_max_level;

	   if l_co2_emissions > l_max_level
	   then

		hr_utility.trace('Car CO2 emissions above max level for year, adjusting down');
		l_co2_emissions := l_max_level;
		p_message := 'CO2 emissions adjusted down to max level.';

	   end if;

	   l_percentage := get_CO2_percentage(p_business_group_id,
 		   		              l_co2_emissions,
					      p_session_date);

	   hr_utility.trace('l_percentage: '||l_percentage);
	   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,21);

	   /* Extra supplements apply if fuel type is diesel */
	   /* Supplement varies according to percentage rate */

	   if l_fuel_type = 'DIESEL'
	   then

	   	   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,22);

	   	   if (l_percentage >= l_min_percentage and l_percentage <= 32)
	   	   then

	   	   	   l_diesel_supplement := 3;

		   elsif (l_percentage = 33)
		   then

		   	   l_diesel_supplement := 2;

		   elsif (l_percentage = 34)
		   then

		   	   l_diesel_supplement := 1;

		   else l_diesel_supplement := 0;

		   end if;

		   hr_utility.trace('l_diesel_supplement: '||l_diesel_supplement);
		   hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,23);

		   l_percentage := l_percentage + l_diesel_supplement;

	   end if;

	 end if;

end if;


/* Calculate final car benefit charge based on car list price and percentage rate */

l_benefit_charge := l_car_price * (l_percentage/100);

hr_utility.trace('l_benefit_charge: '||l_benefit_charge);
hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,24);

IF p_element_type_id IS NOT NULL
THEN


   /* Find number of days for which car is available to employee */
   /* Need to find 1) greatest between start date of NI Car element entry or start of tax year */
   /* 2) least between entry end date, payroll period/ tax year end date, employee termination date */
   /* Relevant dates set above */


   hr_utility.trace('l_start_date: '||l_start_date);
   hr_utility.trace('l_end_date: '||l_end_date);

   IF g_tax_year_start >= to_date('06-04-2003', 'DD-MM-YYYY') THEN -- Effective from year 2003-04
      l_days_available := trunc(l_end_date) - trunc(l_start_date) + 1; -- use actual number of days
   ELSE
      l_days_available := hr_gbnicar.nicar_days_between(l_start_date,l_end_date); -- ignore 29-FEB
   END IF;

ELSE

   l_days_available := p_number_of_days;

END IF;

hr_utility.trace('l_days_available: '||l_days_available);
hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,25);

/* Deduct annual payment from annual benefit charge */

hr_utility.trace('p_payment: '||p_payment);

l_benefit_charge := l_benefit_charge - p_payment;


hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,28);

/* If result < 0, then benefit charge will be 0 */
if l_benefit_charge < 0
then

	 l_benefit_charge := 0;
	 hr_utility.trace('Benefit charge reset to 0');

end if;

hr_utility.trace('l_benefit_charge (after payment): '||l_benefit_charge);

/* Pro-rate the benefit charge, based on the number of days available */

l_benefit_charge := (l_benefit_charge / g_days_in_year) * l_days_available;
hr_utility.trace('l_benefit_charge (pro-rated): '||l_benefit_charge);
hr_utility.trace('g_days_in_year = '||g_days_in_year);
hr_utility.trace('p_start_date: '||p_start_date);
hr_utility.trace('p_end_date: '||p_end_date);
hr_utility.trace('p_assignment_id = '||p_assignment_id);
hr_utility.trace('p_element_type_id = '||p_element_type_id);
hr_utility.trace('l_percentage = '||l_percentage);
hr_utility.trace('l_days_available = '||l_days_available);
hr_utility.trace('g_ignore_fuel_opt_out = '||g_ignore_fuel_opt_out);
hr_utility.trace('g_last_opt_out_date = '||to_char(g_last_opt_out_date, 'DD/MM/YYYY'));
hr_utility.trace('l_fuel_type = '||l_fuel_type);

IF p_element_type_id IS NOT NULL
THEN

   /* Add on any fuel scale charges after pro-ration */
   /* Use manually entered value if exists, else retrieve value from user table */
   /* based on engine size and fuel type */
   /* Value of p_fuel_scale parameter will be null unless overriden */
   hr_utility.trace('p_fuel_scale: '||p_fuel_scale);

   /* Check inputs to see if fuel scale user table should be queried or not */


   /* if p_fuel_scale > 0 then user-entered input */
   if (p_fuel_scale > 0)
   then

   	 l_fuel_scale := p_fuel_scale;

    	 /* Pro-rate fuel scale according to total days available */

   	 l_fuel_scale := (l_fuel_scale / g_days_in_year) * l_days_available;

   /* if fuel scale entry is 0, user wants fuel scale calculated automatically */
   /* check fuel type and visit user table if required */
   elsif (p_fuel_scale = 0 or (p_fuel_scale is null and g_ignore_fuel_opt_out = 'Y' and p_start_date < g_last_opt_out_date))
   then
   	 	 if l_fuel_type in ('HYBRID_ELECTRIC','PETROL','DIESEL','LPG_CNG','LPG_CNG_PETROL','LPG_CNG_PETROL_CONV','EURO_IV_DIESEL')
   		 then

   		 	 hr_utility.trace('Fuel type: '||l_fuel_type);


   			 if l_fuel_type in ('HYBRID_ELECTRIC','LPG_CNG','LPG_CNG_PETROL','LPG_CNG_PETROL_CONV')
   			 then

   			 	 l_fuel_type := 'PETROL';


   			 elsif l_fuel_type = 'EURO_IV_DIESEL'
   			 then

   			 	l_fuel_type := 'DIESEL';

   			 else

   			 	 l_fuel_type := l_fuel_type;

   			 end if;


   			 hr_utility.trace('Engine size: '||p_engine_size);
   			 hr_utility.trace('Session date: '||p_session_date);
   			 l_fuel_scale := fnd_number.canonical_to_number(hruserdt.get_table_value(p_business_group_id,
   	                                                                   				'FUEL_SCALE',
   	                                                                   				 l_fuel_type,
                           											            	 p_engine_size,
   	                                                                   				 p_session_date));

   			 /* Pro-rate fuel scale according to total days available */

   			 l_fuel_scale := (l_fuel_scale / g_days_in_year) * l_days_available;

   		 else -- alternative fuel types

   			 l_fuel_scale := 0;


   		 end if;


   /* if p_fuel_scale is null, then set l_fuel_scale to 0 */
   elsif (p_fuel_scale is null and (g_ignore_fuel_opt_out = 'N' OR p_start_date >= g_last_opt_out_date) )
   then

   	  l_fuel_scale := 0;

   /* anything else, do nothing */

   else null;

   end if;

ELSE

   l_fuel_scale := 0;

END IF;


hr_utility.trace('l_fuel_scale: '||l_fuel_scale);
hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,29);
IF nvl(p_fuel_scale, 0) = 0 and g_tax_year_start >= to_date('06-04-2003', 'DD-MM-YYYY') THEN -- Effective from year 2003-04
   l_fuel_scale := l_fuel_scale * (l_percentage/100);
END IF;
hr_utility.trace('l_fuel_scale: '||l_fuel_scale);
l_benefit_charge:= l_benefit_charge + l_fuel_scale;

hr_utility.trace('l_benefit_charge (after fuel scale): '||l_benefit_charge);
/* Check if message has been set, if not leave as null */

p_message := nvl(p_message,null);

/* Round down benefit charge to nearest pound */

l_benefit_charge := trunc(l_benefit_charge);

hr_utility.trace('l_benefit_charge (final): '||l_benefit_charge);


hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,999);



/* Return final benefit charge */

return l_benefit_charge;

exception

when others
then raise;


end nicar_nicable_value_CO2;

/* Function to calculate taxable / NICable value based on engine capacity for cars without */
/* approved CO2 emissions ratings */
/* Parameter p_business_group_id provided by context-set variable */
function nicar_nicable_value_non_CO2
( p_assignment_id				   IN NUMBER,
  p_element_type_id				   IN NUMBER,
  p_business_group_id			           IN NUMBER,
  /* Import direct from fast formula */
  p_car_price 				       	   IN NUMBER,
  p_reg_date  					   IN DATE,
  p_fuel_type 					   IN VARCHAR2,
  p_engine_size 				   IN NUMBER,
  p_fuel_scale					   IN NUMBER DEFAULT NULL,
  p_payment					   IN NUMBER,
  p_start_date					   IN DATE,
  p_end_date					   IN DATE,
  p_end_of_period_date			   	   IN DATE,
  p_emp_term_date				   IN DATE,
  p_session_date				   IN DATE,
  p_message					   OUT NOCOPY VARCHAR2,
  p_number_of_days                 		   IN NUMBER DEFAULT 0)
return NUMBER is

l_function_name 			VARCHAR2(27) := 'nicar_nicable_value_non_CO2';



l_percentage				NUMBER;
l_diesel_supplement			NUMBER;

l_benefit_charge			NUMBER;

l_car_price				NUMBER;

l_reg_date				DATE;

l_entry_start_date 			DATE;
l_entry_end_date			DATE;

l_end_of_period_date 		        DATE;

l_start_date				DATE;
l_end_date				DATE;

l_price_cap 				NUMBER;

l_days_available 			NUMBER;

l_fuel_scale				NUMBER;

l_fuel_type				VARCHAR2(100);


cursor csr_max_price_global is
	   select to_number(global_value)
	   from ff_globals_f
	   where global_name = 'NI_CAR_MAX_PRICE'
	   and p_session_date between
	   	   effective_start_date and effective_end_date;





begin



hr_utility.set_location(g_package_name||'.'||l_function_name,100);


hr_utility.trace('** Parameter values ** ');
hr_utility.trace('p_assignment_id: '||p_assignment_id);
hr_utility.trace('p_element_type_id: '||p_element_type_id);
hr_utility.trace('p_business_group_id: '||p_business_group_id);
hr_utility.trace('p_car_price: '||p_car_price);
hr_utility.trace('p_reg_date: '||p_reg_date);
hr_utility.trace('p_fuel_type: '||p_fuel_type);
hr_utility.trace('p_engine_size: '||p_engine_size);
hr_utility.trace('p_fuel_scale: '||p_fuel_scale);
hr_utility.trace('p_payment: '||p_payment);
hr_utility.trace('p_start_date: '||p_start_date);
hr_utility.trace('p_end_date: '||p_end_date);
hr_utility.trace('p_end_of_period_date: '||p_end_of_period_date);
hr_utility.trace('p_emp_term_date: '||p_emp_term_date);
hr_utility.trace('p_session_date: '||p_session_date);



hr_utility.set_location(g_package_name||'.'||l_function_name,102);

l_start_date := trunc(p_start_date);
l_end_date := trunc(p_end_date);
l_reg_date := trunc(p_reg_date);
l_end_of_period_date := trunc(p_end_of_period_date);

l_car_price   := p_car_price;
l_fuel_type   := p_fuel_type;

hr_utility.trace('l_start_date: '||l_start_date);
hr_utility.trace('l_end_date: '||l_end_date);
hr_utility.trace('l_reg_date: '||l_reg_date);
hr_utility.trace('l_end_of_period_date: '||l_end_of_period_date);
hr_utility.trace('l_fuel_type: '||l_fuel_type);
hr_utility.trace('p_session_date: '||p_session_date);



hr_utility.set_location(g_package_name||'.'||l_function_name,104);


/* Find percentage charge for vehicle */

l_percentage := get_cc_percentage(p_business_group_id,
			 	  p_engine_size,
			 	  p_reg_date,
				  p_session_date);


hr_utility.trace('l_percentage: '||l_percentage);
hr_utility.set_location(g_package_name||'.'||l_function_name,106);

/* Check if diesel supplements apply to that vehicle */

if (p_reg_date >= to_date('01/01/1998','DD/MM/YYYY')
   and l_fuel_type = 'DIESEL')
then

	/* supplements vary according to engine cc */
	if to_number(p_engine_size) between 0 and 2000
	then

		l_diesel_supplement := 3;

	else

		l_diesel_supplement := 0;

	end if;



/* Add supplement to percentage */
hr_utility.trace('l_diesel_supplement: '||l_diesel_supplement);
hr_utility.set_location(g_package_name||'.'||l_function_name,106);

l_percentage := l_percentage + l_diesel_supplement;

end if;

hr_utility.set_location(g_package_name||'.'||l_function_name,107);

/* Calculate car benefit charge */

l_benefit_charge := l_car_price * (l_percentage/100);

hr_utility.trace('l_benefit_charge: '||l_benefit_charge);
hr_utility.set_location(g_package_name||'.'||l_function_name,108);

IF p_element_type_id is NOT NULL
THEN

   /* Find number of days for which car is available to employee */
   /* Need to find 1) greatest between start date of NI Car element entry or start of tax year */
   /* 2) least between entry end date, payroll period/ tax year end date, employee termination date */
   /* Relevant dates set above */

   hr_utility.trace('l_start_date: '||l_start_date);
   hr_utility.trace('l_end_date: '||l_end_date);

   IF g_tax_year_start >= to_date('06-04-2003', 'DD-MM-YYYY') THEN -- Effective from year 2003-04
      l_days_available := trunc(l_end_date) - trunc(l_start_date) + 1; -- use actual number of days
   ELSE
      l_days_available := hr_gbnicar.nicar_days_between(l_start_date,l_end_date); -- ignore 29-FEB
   END IF;

ELSE

   l_days_available := p_number_of_days;

END IF;

hr_utility.trace('l_days_available: '||l_days_available);
hr_utility.set_location(g_package_name||'.'||l_function_name,109);

/* Deduct annual payment from annual benefit charge */

hr_utility.trace('p_payment: '||p_payment);

l_benefit_charge := l_benefit_charge - p_payment;


hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,110);

/* If result < 0, then benefit charge will be 0 */
if l_benefit_charge < 0
then

	 l_benefit_charge := 0;
	 hr_utility.trace('Benefit charge reset to 0');

end if;

hr_utility.trace('l_benefit_charge (after payment): '||l_benefit_charge);

/* Pro-rate the benefit charge, based on the number of days available */

l_benefit_charge := (l_benefit_charge / g_days_in_year) * l_days_available;
hr_utility.trace('l_benefit_charge (pro-rated): '||l_benefit_charge);
hr_utility.trace('g_days_in_year = '||g_days_in_year);
hr_utility.trace('p_start_date: '||p_start_date);
hr_utility.trace('p_end_date: '||p_end_date);
hr_utility.trace('p_assignment_id = '||p_assignment_id);
hr_utility.trace('p_element_type_id = '||p_element_type_id);
hr_utility.trace('l_percentage = '||l_percentage);
hr_utility.trace('l_days_available = '||l_days_available);
hr_utility.trace('g_ignore_fuel_opt_out = '||g_ignore_fuel_opt_out);
hr_utility.trace('g_last_opt_out_date = '||to_char(g_last_opt_out_date, 'DD/MM/YYYY'));
hr_utility.trace('l_fuel_type = '||l_fuel_type);

IF p_element_type_id is NOT NULL
THEN

   /* Add on any fuel scale charges after pro-ration */
   /* Use manually entered value if exists, else retrieve value from user table */
   /* based on engine size and fuel type */
   /* Value of p_fuel_scale parameter will be null unless overriden */
   hr_utility.trace('p_fuel_scale: '||p_fuel_scale);

   /* Check inputs to see if fuel scale user table should be queried or not */

   /* If fuel scale > 0 then manual user-entered input */

   if (p_fuel_scale > 0)
   then

   	 l_fuel_scale := p_fuel_scale;

   	 /* Pro-rate fuel scale according to total days available */

   	 l_fuel_scale := (l_fuel_scale / g_days_in_year) * l_days_available;


   /* if fuel scale entry is 0, user wants fuel scale calculated automatically */
   /* check fuel type and visit user table if required */
   elsif (p_fuel_scale = 0 or (p_fuel_scale is null and g_ignore_fuel_opt_out = 'Y' and p_start_date < g_last_opt_out_date))
   then
   	 	 if l_fuel_type in ('HYBRID_ELECTRIC','PETROL','DIESEL','LPG_CNG','LPG_CNG_PETROL','LPG_CNG_PETROL_CONV','EURO_IV_DIESEL')
   		 then

   		 	 hr_utility.trace('Fuel type: '||l_fuel_type);


   			 if l_fuel_type in ('HYBRID_ELECTRIC','LPG_CNG','LPG_CNG_PETROL','LPG_CNG_PETROL_CONV')
   			 then

   			 	 l_fuel_type := 'PETROL';

   			 elsif l_fuel_type = 'EURO_IV_DIESEL'
   			 then

   			 	l_fuel_type := 'DIESEL';

   			 else

   			 	 l_fuel_type := l_fuel_type;

   			 end if;


   			 hr_utility.trace('Engine size: '||p_engine_size);
   			 hr_utility.trace('Session date: '||p_session_date);
   			 l_fuel_scale := fnd_number.canonical_to_number(hruserdt.get_table_value(p_business_group_id,
   	                                                           				'FUEL_SCALE',
   	                                                           				 l_fuel_type,
   												 p_engine_size,
   	                                                           				 p_session_date));


   		     /* Pro-rate fuel scale according to total days available */

   			 l_fuel_scale := (l_fuel_scale / g_days_in_year) * l_days_available;

   		 else -- alternative fuel types

   			 l_fuel_scale := 0;


   		 end if;



   /* if p_fuel_scale is null, then set l_fuel_scale to 0 */
   elsif (p_fuel_scale is null and (g_ignore_fuel_opt_out = 'N' OR p_start_date >= g_last_opt_out_date) )
   then

   	  l_fuel_scale := 0;

   /* anything else, do nothing */

   else null;

   end if;
ELSE

    l_fuel_scale := 0;

END IF;


hr_utility.trace('l_fuel_scale: '||l_fuel_scale);
hr_utility.SET_LOCATION(g_package_name||'.'||l_function_name,113);

IF nvl(p_fuel_scale, 0) = 0 and g_tax_year_start >= to_date('06-04-2003', 'DD-MM-YYYY') THEN -- Effective from year 2003-04
   l_fuel_scale := l_fuel_scale * (l_percentage/100);
END IF;
hr_utility.trace('l_fuel_scale: '||l_fuel_scale);
l_benefit_charge:= l_benefit_charge + l_fuel_scale;


/* Return final benefit charge */

hr_utility.trace('l_benefit_charge (after fuel scale): '||l_benefit_charge);



/* Round down benefit charge to nearest pound */

l_benefit_charge := trunc(l_benefit_charge);
hr_utility.trace('l_benefit_charge (final): '||l_benefit_charge);

/* Set p_message parameter to null */
p_message := null;

hr_utility.set_location(g_package_name||'.'||l_function_name,999);

return l_benefit_charge;

exception

when others
then raise;

end nicar_nicable_value_non_CO2;


/* Round CO2 emissions figure down to nearest multiple of 5 */
function round_CO2_val
(p_value 	   	   IN NUMBER)
return NUMBER is

l_function_name 	   VARCHAR2(13) := 'round_CO2_val';
l_value			   NUMBER;

begin

hr_utility.set_location(g_package_name||'.'||l_function_name,1);

l_value := p_value;
hr_utility.trace('Value before rounding: '||l_value);

loop

	l_value := l_value - 1;

exit when mod(l_value,5) = 0;
end loop;

hr_utility.trace('Value after rounding: '||l_value);
hr_utility.set_location(g_package_name||'.'||l_function_name,2);

return l_value;

end round_CO2_val;

/* Return applicable percentage charge based on CO2 emissions for car */
function get_CO2_percentage
(p_business_group_id 	   IN NUMBER,
 p_co2_emissions	   IN NUMBER,
 p_session_date	   	   IN DATE)
return NUMBER is

l_percentage  		   NUMBER;
l_function_name		   VARCHAR2(18) := 'get_CO2_percentage';

l_co2_emissions		   NUMBER;

e_invalid_input	          EXCEPTION;

begin

hr_utility.set_location(g_package_name||'.'||l_function_name,1);

/* Validate inputs */

if p_business_group_id is null
or p_co2_emissions 	   is null
or p_session_date 	   is null
then

	 raise e_invalid_input;

end if;

hr_utility.trace('p_business_group_id: '||p_business_group_id);
hr_utility.trace('p_co2_emissions: '||p_co2_emissions);
hr_utility.trace('p_session_date: '||p_session_date);

hr_utility.set_location(g_package_name||'.'||l_function_name,2);

l_co2_emissions := p_co2_emissions;

/* Get table value */
l_percentage := fnd_number.canonical_to_number(hruserdt.get_table_value(p_business_group_id,
                                                   		        'GB_CO2_EMISSIONS',
                                                           		'PERCENTAGE_CHARGE',
                                                           		 l_co2_emissions,
                                                         		 p_session_date));



hr_utility.set_location(g_package_name||'.'||l_function_name,4);

return l_percentage;

exception

when e_invalid_input
then
	hr_utility.trace('ERROR: Input into get_CO2_percentage invalid');
	hr_utility.trace('Business group id: '||p_business_group_id);
	hr_utility.trace('CO2 emissions figure: '||p_co2_emissions);
	hr_utility.trace('Session date: '||to_char(p_session_date,'DD/MM/YYYY'));
	raise;

when too_many_rows
then
	 hr_utility.trace('ERROR: Retrieving CO2 percentage from user table retrieved too many rows');
	 raise;


when no_data_found
then
	hr_utility.trace('ERROR: Call to GB_CO2_EMISSIONS user table retrieved no value');
	raise;

when others
then raise;


end get_CO2_percentage;


/* Return applicable percentage based on engine size */
function get_cc_percentage
( p_business_group_id  	  IN NUMBER,
  p_engine_size		  IN NUMBER,
  p_reg_date		  IN DATE,
  p_session_date	  IN DATE)
return NUMBER is

l_percentage  		  NUMBER;
l_function_name		  VARCHAR2(17) := 'get_cc_percentage';
l_column_name		  VARCHAR2(40);


begin

hr_utility.set_location(g_package_name||'.'||l_function_name,1);

/* Check to see what registration date is as value retrieved will differ */

if p_reg_date < to_date('01/01/1998','DD/MM/YYYY')
then

	l_column_name := 'BEFORE_JAN_1_1998';

else

	l_column_name := 'ON_AFTER_JAN_1_1998';

end if;

hr_utility.set_location(g_package_name||'.'||l_function_name,2);

l_percentage := fnd_number.canonical_to_number(hruserdt.get_table_value(p_business_group_id,
                                                                        'GB_CC_SCALE',
                                                                        l_column_name,
                                                                        p_engine_size,
                                                                        p_session_date));


hr_utility.set_location(g_package_name||'.'||l_function_name,3);

return l_percentage;

exception

when too_many_rows
then
	 hr_utility.trace('ERROR: Retrieving CC percentage from user table retrieved too many rows');
	 raise;

when no_data_found
then
	 hr_utility.trace('ERROR: Retrieving CC percentage from user table retrieved no value');
	 hr_utility.trace('p_business_group_id: '||p_business_group_id);
	 hr_utility.trace('p_engine_size: '||p_engine_size);
	 hr_utility.trace('p_session_date: '||p_session_date);
	 raise;


when others
then raise;



end get_cc_percentage;


/* Return fixed discount percentage for certain alternative fuel cars */
function get_discount
( p_fuel_type 		 	 IN VARCHAR2,
  p_session_date	 	 IN DATE)
return NUMBER is

l_percentage  		 	 NUMBER;
l_global_value			 ff_globals_f.global_value%type;
l_global_name			 ff_globals_f.global_name%type;

l_function_name 		 VARCHAR2(12):= 'get_discount';

l_discount			 NUMBER;

cursor csr_global_value is
	   select to_number(global_value)
	   from ff_globals_f
	   where legislation_code = 'GB'
	   and upper(global_name) = upper(l_global_name)
	   and p_session_date between effective_start_date
	   	   				  and effective_end_date;


begin

hr_utility.set_location(g_package_name||'.'||l_function_name,1);

/* Check which fuel type is being used */

if p_fuel_type = 'BATTERY_ELECTRIC' -- Battery electric
then

	l_global_name := 'NI_CAR_BATTERY_ELECTRIC_DISCOUNT';

elsif p_fuel_type in ('LPG_CNG_PETROL','LPG_CNG_PETROL_CONV') -- Bi-fuel/conversion
then

	l_global_name := 'NI_CAR_BI_FUEL_DISCOUNT';

elsif p_fuel_type = 'HYBRID_ELECTRIC' -- Hybrid electric
then

	l_global_name := 'NI_CAR_HYBRID_ELECTRIC_DISCOUNT';

elsif p_fuel_type = 'LPG_CNG' -- LPG/CNG
then

	l_global_name := 'NI_CAR_LPG_DISCOUNT';

end if;

hr_utility.set_location(g_package_name||'.'||l_function_name,2);

/* Get value of the global based on its name */

open csr_global_value;
fetch csr_global_value into l_global_value;
close csr_global_value;


hr_utility.set_location(g_package_name||'.'||l_function_name,10);

l_discount := to_number(l_global_value) * 100;

return l_discount;

exception

when too_many_rows
then
	 hr_utility.trace('ERROR: Retrieving global value for '||l_global_name||' retrieved too many rows');
	 raise;

when no_data_found
then
	 hr_utility.trace('ERROR: Retrieving global value for '||l_global_name||' retrieved no value');
	 hr_utility.trace('p_fuel_type: '||p_fuel_type);
	 hr_utility.trace('p_session_date: '||p_session_date);
	 raise;


when others
then raise;



end get_discount;



/* Primary function for pay_gb_nicar_06042002 package */
/* Called by fast formula and NI Car Detail report */
/* Function invokes nicar_nicable_value_CO2 and nicar_nicable_value_non_CO2 as appropriate */
/* Parameter list:
 Context-set parameters
 p_assignment_id
 p_element_type_id
 p_business_group_id

 Fast formula parameters:
 p_pay_periods_of_year
 p_pay_period_number
 p_pay_period_end_date
 p_emp_term_date
 p_session_date

 Returns:

 l_running_total - running total of car benefit value up to end date
 1-4 messages, dependent on how many messages produced

*/
function nicar_main
( /* Context set parameters */
  p_assignment_id 		   		  IN number,
  p_element_type_id				  IN number,
  p_business_group_id			  	  IN number,
  /* Fast formula parameters */
  p_pay_periods_per_year	   	  	  IN number,
  p_curr_payroll_period			  	  IN number,
  p_curr_payroll_period_end_date  		  IN date,
  p_emp_term_date				  IN date,
  p_session_date				  IN date,
  /* OUT parameter */
  p_message_1		   	 		  OUT NOCOPY varchar2,
  p_message_2					  OUT NOCOPY varchar2,
  p_message_3					  OUT NOCOPY varchar2,
  p_message_4					  OUT NOCOPY varchar2)
return number is

--
-- N.B. When called from FastFormula, p_assignment_id, p_element_type_id
---     and p_business_group_id are
-- provided via context-set variables.
--
        csr0_session_date         date;
--
        csr1_price_max            number;
	csr1_ni_rate              number;
--
        csr2_element_name         pay_element_types_f.element_name%type;
        csr2_pr                   number;
        csr2_rd                   number;
        csr2_rn                   number;
        csr2_mb                   number;
        csr2_ft                   number;
        csr2_cc                   number;
        csr2_fs                   number;
        csr2_ap                   number;
        csr2_co2                  number;
--

        csr3_price                number;
        csr3_reg_date             date;
        csr3_mileage_band         number;
        csr3_fuel_scale           number;
	csr3_fuel_type            varchar2(100);
	csr3_engine_cc            number;
        csr3_payment              number;
        csr3_co2_emissions        number;
        csr3_start_date           date;
        csr3_end_date             date;
--
	l_fuel_scale              number :=0;
        l_running_total           number :=0;
        l_nicable_benefit         number :=0;

        l_end_of_period_date      date;
        l_start_date              date;
        l_end_date                date;

        l_reg_date_lower_limit    date := to_date('01/01/1998','DD/MM/YYYY');

        l_message                 varchar2(500);
        l_co2_message		  varchar2(500);
        l_cc_message		  varchar2(500);
	l_msg_count		  number := 1;
        type l_msg_tabtype	  is table of varchar2(500) index by binary_integer;
	tbl_msg_table		  l_msg_tabtype;

	l_pay_period_type         per_time_period_types.period_type%type;
        l_periods_per_period      number;
        l_annualised_pay_period   number;
        l_next_period_end_date	  date;



	l_function_name		  varchar2(10) := 'nicar_main';




--
--
  cursor csr1_globals is
  SELECT        fnd_number.canonical_to_number(LIM.global_value)
	,	fnd_number.canonical_to_number(NIR.global_value)
  FROM          ff_globals_f    LIM
	,	ff_globals_f	NIR
  WHERE         LIM.global_name = 'NI_CAR_MAX_PRICE'
  AND     csr0_session_date between LIM.effective_start_date and LIM.effective_end_date
  AND     NIR.global_name = 'NI_ERS_RATE'
  AND     csr0_session_date between NIR.effective_start_date and NIR.effective_end_date;
--
  cursor csr2_pri_sec is
  SELECT        E_TL.element_name
    	,	IPR.input_value_id
	,	IRD.input_value_id
	,	IRN.input_value_id
	,	IMB.input_value_id
	,	IFT.input_value_id
	,	ICC.input_value_id
	,	IFS.input_value_id
	,	IAP.input_value_id
    	,   	ICO.input_value_id
  FROM		pay_input_values_f	IPR
	,	pay_input_values_f	IRD
	,	pay_input_values_f	IRN
	,	pay_input_values_f	IMB
	,	pay_input_values_f	IFT
	,	pay_input_values_f	ICC
	,	pay_input_values_f	IFS
	,	pay_input_values_f	IAP
    	,   	pay_input_values_f  	ICO
	,	pay_element_types_f_tl	E_TL
	,	pay_element_types_f	E
  WHERE	E_TL.element_type_id = E.element_type_id
        AND     E.element_type_id       = p_element_type_id
        AND     userenv('LANG')         = E_TL.language
	AND	IPR.element_type_id   	= E.element_type_id
	AND	IPR.name             	= 'Price'
	AND	IRD.element_type_id   	=E.element_type_id
	AND	IRD.name		= 'Registration Date'
	AND	IRN.element_type_id   	= E.element_type_id
	AND	IRN.name		= 'Registration Number'
	AND	IMB.element_type_id   	= E.element_type_id
	AND	IMB.name		= 'Mileage Band'
	AND	IFT.element_type_id   	= E.element_type_id
	AND	IFT.name		= 'Fuel Type'
	AND	ICC.element_type_id   	= E.element_type_id
	AND	ICC.name		= 'Engine cc'
	AND	IFS.element_type_id   	= E.element_type_id
	AND	IFS.name		= 'Fuel Scale'
	AND	IAP.element_type_id   	= E.element_type_id
	AND	IAP.name             	= 'Payment'
    AND ICO.element_type_id     = E.element_type_id
    AND ICO.name                = 'CO2 Emissions'
    AND csr0_session_date between E.effective_start_date and E.effective_end_date;
--
--
  cursor csr3_nicar is
-- bug 504994 changed the entry cursor to use a single join on values table
-- to improve performance
  select
	max(decode(V.input_value_id,csr2_pr,
		fnd_number.canonical_to_number(V.Screen_entry_value),null) )       csr3_price
	,max(decode(V.input_value_id, csr2_mb,
		fnd_number.canonical_to_number(V.Screen_entry_value),null)) 	   csr3_mileage_band
	,max(decode(V.input_value_id,csr2_rd,
		fnd_date.canonical_to_date(V.Screen_entry_value),null))            csr3_reg_date
	,max(decode(V.input_value_id,csr2_ft,
		V.Screen_entry_value,null))                                        csr3_fuel_type
	,max(decode(V.input_value_id,csr2_cc,
		fnd_number.canonical_to_number(v.Screen_entry_value),null))        csr3_engine_cc
	,max(decode(V.input_value_id,csr2_fs,
		fnd_number.canonical_to_number(V.Screen_entry_value),null))        csr3_fuel_scale
	,max(decode(V.input_value_id,csr2_ap,
		nvl(fnd_number.canonical_to_number(V.Screen_entry_value),0),null)) csr3_payment
    ,max(decode(V.input_value_id,csr2_co2,
		fnd_number.canonical_to_number(V.Screen_entry_value),null))        csr3_co2
        ,EENT.effective_end_date                                                   csr3_end_date
        ,EENT.effective_start_date                                                 csr3_start_date

  FROM          pay_element_entries_f           EENT
        ,       pay_element_links_f             LINK
        ,       pay_element_entry_values_f      V
  WHERE         EENT.effective_end_date         >= g_tax_year_start
  AND     EENT.effective_start_date       <=
                 least(p_emp_term_date,l_end_of_period_date,g_tax_year_end)
  AND     EENT.assignment_id              = p_assignment_id
  AND     LINK.element_type_id            = p_element_type_id
  AND     EENT.element_link_id            = LINK.element_link_id
  AND     EENT.effective_start_date       >= LINK.effective_start_date
  AND     EENT.effective_end_date         <= LINK.effective_end_date
  AND     EENT.entry_type		  = 'E'
  AND     V.Element_entry_id              = EENT.element_entry_id
  AND     V.Effective_start_date          = EENT.effective_start_date
  group by EENT.effective_end_date, EENT.effective_start_date;

  /* Find out if employee has opted back into free fuel part way through the tax year */
  CURSOR csr_ignore_fuel_opt_out IS
  SELECT 'Y'
  FROM  pay_element_entries_f pee,
        pay_element_links_f pel,
        pay_element_entry_values_f peev
  WHERE pee.effective_start_date > g_tax_year_start
  AND   pee.effective_start_date <= least(p_emp_term_date, l_end_of_period_date, g_tax_year_end)
  AND   pee.assignment_id = p_assignment_id
  AND   pel.element_type_id = p_element_type_id
  AND   pee.element_link_id = pel.element_link_id
  AND   pee.effective_start_date >= pel.effective_start_date
  AND   pee.effective_end_date <= pel.effective_end_date
  AND   pee.entry_type = 'E'
  AND   peev.element_entry_id = pee.element_entry_id
  AND   peev.effective_start_date = pee.effective_start_date
  AND   peev.input_value_id = csr2_fs
  AND   peev.screen_entry_value IS NOT NULL;

  /* If employee has currently opted out of the free fuel then find out the start date of this change
     else return a date after end of the year */
  CURSOR csr_last_opt_out_date IS
  SELECT nvl(max(pee.effective_start_date), g_tax_year_end+1)
  FROM  pay_element_entries_f pee,
        pay_element_links_f pel,
        pay_element_entry_values_f peev
  WHERE least(p_emp_term_date, l_end_of_period_date, g_tax_year_end) BETWEEN
        pee.effective_start_date AND pee.effective_end_date
  AND   pee.assignment_id = p_assignment_id
  AND   pel.element_type_id = p_element_type_id
  AND   pee.element_link_id = pel.element_link_id
  AND   pee.effective_start_date >= pel.effective_start_date
  AND   pee.effective_end_date <= pel.effective_end_date
  AND   pee.entry_type = 'E'
  AND   peev.element_entry_id = pee.element_entry_id
  AND   peev.effective_start_date = pee.effective_start_date
  AND   peev.input_value_id = csr2_fs
  AND   peev.screen_entry_value IS NULL;

  /* Get payroll period type for payroll period currently being processed */
  cursor csr_period_type is
	select ptpt.period_type
	from per_time_period_types ptpt,
	     per_time_periods ptp,
	     per_assignments_f paf
	where paf.payroll_id = ptp.payroll_id
	and ptpt.period_type = ptp.period_type
	and paf.assignment_id = p_assignment_id
	and trunc(p_session_date) between trunc(ptp.start_date) and trunc(ptp.end_date);

 /* Get end date of next payroll period after the one currently being processed */
 cursor csr_next_end_date is
 	select ptp.end_date
	from per_time_periods ptp,
	     pay_all_payrolls_f papf,
	     per_assignments_f paf
	where paf.payroll_id = papf.payroll_id
	and papf.payroll_id = ptp.payroll_id
	and paf.assignment_id = p_assignment_id
	and ptp.start_date = p_curr_payroll_period_end_date + 1;

--
--
  BEGIN
--  hr_utility.trace_on(null,'NICAR');

  hr_utility.set_location(g_package_name||'.'||l_function_name,1);


--
-- Get the session date
      csr0_session_date := p_session_date;


--
--
-- Get the tax year start and end dates from the session date;
--
    g_tax_year_start := hr_gbnicar.uk_tax_yr_start(csr0_session_date);
    g_tax_year_end   := hr_gbnicar.uk_tax_yr_end(csr0_session_date);
    g_days_in_year   := trunc(g_tax_year_end) - trunc(g_tax_year_start) + 1;

   hr_utility.set_location(g_package_name||'.'||l_function_name,2);



   open csr_period_type;
   fetch csr_period_type into l_pay_period_type;
   close csr_period_type;


   IF l_pay_period_type = 'Calendar Month'
   THEN
    l_periods_per_period       := 1;

   ELSIF l_pay_period_type = 'Week'
   THEN
    l_periods_per_period       := 1;

   ELSIF l_pay_period_type = 'Bi-Week'
   THEN
    l_periods_per_period       := 2;

   ELSIF l_pay_period_type = 'Lunar Month'
   THEN
    l_periods_per_period       := 4;

   ELSIF l_pay_period_type = 'Semi-Year'
   THEN
    l_periods_per_period       := 6;

   ELSIF l_pay_period_type = 'Year'
   THEN
     l_periods_per_period       := 12;

   END IF;

   l_annualised_pay_period := p_curr_payroll_period / l_periods_per_period;

   /* Check if pay period being run is last in current tax year */
   if l_annualised_pay_period >= p_pay_periods_per_year
   then

   	open csr_next_end_date;
   	fetch csr_next_end_date into l_next_period_end_date;
   	close csr_next_end_date;

   	if l_next_period_end_date > g_tax_year_end
   	then
   	/* use tax year end as end of period date */

   	   l_end_of_period_date := g_tax_year_end;

   	else
   	/* use end date of current payroll period as end of period date */

   	   l_end_of_period_date := p_curr_payroll_period_end_date;

   	end if;


   else
   /* at all other times, use end date of current payroll period */

  	 l_end_of_period_date := p_curr_payroll_period_end_date;

   end if;


   hr_utility.set_location(g_package_name||'.'||l_function_name,3);
--
--
-- Get the max allowable price,  and the contrib rate
--
    hr_utility.set_location(g_package_name||'.'||l_function_name,10);
    open csr1_globals;
    hr_utility.set_location(g_package_name||'.'||l_function_name,20);
    fetch csr1_globals
    into        csr1_price_max
	,	csr1_ni_rate;
    close csr1_globals;

    hr_utility.trace('csr1_price_max: '||csr1_price_max);
    hr_utility.trace('csr1_ni_rate: '||csr1_ni_rate);
--
--
-- Get the element_name for the element type id, and all the associated
-- input value ids.
--
    hr_utility.set_location(g_package_name||'.'||l_function_name,30);
    open csr2_pri_sec;
    hr_utility.set_location(g_package_name||'.'||l_function_name,40);
    fetch csr2_pri_sec
      into        csr2_element_name
		, csr2_pr
		, csr2_rd
		, csr2_rn
		, csr2_mb
		, csr2_ft
		, csr2_cc
		, csr2_fs
		, csr2_ap
        	, csr2_co2;

    close csr2_pri_sec;

    g_ignore_fuel_opt_out := 'N';
    hr_utility.trace('p_assignment_id = '||p_assignment_id);
    hr_utility.trace('g_tax_year_start = '||to_char(g_tax_year_start, 'DD-MON-YYYY'));
    hr_utility.trace('g_tax_year_end = '||to_char(g_tax_year_end, 'DD-MON-YYYY'));
    -- Find out if employee has opted back into free fuel part way through the
    -- tax year. If yes then fuel scale will be charged for full availability
    -- for the car.
    IF g_tax_year_start >= to_date('06-04-2003', 'DD-MM-YYYY') THEN --Effective from year 2003
       hr_utility.trace('Opening csr_ignore_opt_out.');
       open csr_ignore_fuel_opt_out;
       fetch csr_ignore_fuel_opt_out into g_ignore_fuel_opt_out;
       close csr_ignore_fuel_opt_out;
       --
       hr_utility.trace('Opening csr_last_opt_out_date.');
       open csr_last_opt_out_date;
       fetch csr_last_opt_out_date into g_last_opt_out_date;
       close csr_last_opt_out_date;
    END IF;
    --
    hr_utility.trace('g_ignore_fuel_out_out = '||g_ignore_fuel_opt_out);
    hr_utility.trace('g_last_opt_out_date = '||g_last_opt_out_date);
--
--
-- Get the required details for all company car benefits for the assignment
--
    hr_utility.set_location(g_package_name||'.'||l_function_name,50);
    open csr3_nicar;
--
    hr_utility.set_location(g_package_name||'.'||l_function_name,60);



    loop
        fetch csr3_nicar
        into    csr3_price
        ,       csr3_mileage_band
        ,       csr3_reg_date
	,	csr3_fuel_type
	,	csr3_engine_cc
        ,       csr3_fuel_scale
        ,       csr3_payment
        ,       csr3_co2_emissions
        ,       csr3_end_date
        ,       csr3_start_date;
--
        exit when csr3_nicar%notfound;
--

--
	   /* Initialise message variables to null */

	   l_message     := null;
	   l_co2_message := null;
	   l_cc_message	 := null;

	   /* Choose either tax year start date or entry start date, whichever is greater */

	   l_start_date := greatest(g_tax_year_start,csr3_start_date);


	   /* Choose either entry end date, payroll period end date/tax year end date or employee termination date, */
	   /* whichever is the least */

	   l_end_date := least(csr3_end_date,l_end_of_period_date,p_emp_term_date);

	   hr_utility.set_location(g_package_name||'.'||l_function_name,70);

	   /* Check all parameters are valid */

	    if csr3_price <0
	    then
	          hr_utility.set_message(800,'HR_7361_LOC_INVALID_PRICE');
	          hr_utility.raise_error;

	    elsif csr3_reg_date > g_tax_year_end
	    then
	          hr_utility.set_message(800,'HR_7367_LOC_INVALID_REG_DATE');
	          hr_utility.raise_error;

	    elsif csr3_reg_date > l_start_date
	    then
	          hr_utility.set_message(800,'HR_7367_LOC_INVALID_REG_DATE');
	          hr_utility.raise_error;

	    elsif csr3_fuel_scale <0
	    then
	          hr_utility.set_message(800,'HR_7368_LOC_INVALID_FUELCHG');
	          hr_utility.raise_error;

	    elsif csr3_payment <0
	    then
	          hr_utility.set_message(800,'HR_7369_LOC_INVALID_ANN_PAY');
	          hr_utility.raise_error;
	    end if;

	   	hr_utility.set_location(g_package_name||'.'||l_function_name,80);

	    /* Check car price does not exceed the price cap */
	    if csr3_price > csr1_price_max
	    then

	       csr3_price  := csr1_price_max;
	       hr_utility.trace('Price cap applied to car list price.');
	       l_message   := 'Price Cap applied to car price.';

	    end if;

	    /* Check if fuel type retrieved is null */
	    if csr3_fuel_type is null
	    then

	    	csr3_fuel_type := 'DIESEL';
	    	hr_utility.trace('Fuel type defaulted to Diesel.');
	    	l_message      := l_message||'Fuel type defaulted to Diesel.';

	    end if;

	    /* Check if engine size retrieved is null */
	    if csr3_engine_cc is null
	    then

	    	csr3_engine_cc := 9999;
	    	hr_utility.trace('Defaulted engine size to 9999cc');
	    	l_message      := l_message||'Engine size defaulted to 9999cc.';

	    end if;



	    hr_utility.set_location(g_package_name||'.'||l_function_name,90);

	    hr_utility.trace('***************************');
	    hr_utility.trace('Input parameters to calculation: ');
	    hr_utility.trace('p_assignment_id: '||p_assignment_id);
	    hr_utility.trace('p_element_type_id: '||p_element_type_id);
	    hr_utility.trace('p_business_group_id: '||p_business_group_id);

	    hr_utility.trace('csr3_start_date: '||l_start_date);
	    hr_utility.trace('csr3_end_date: '||l_end_date);
	    hr_utility.trace('csr3_price: '||csr3_price);
	    hr_utility.trace('csr3_reg_date: '||csr3_reg_date);
	    hr_utility.trace('csr3_mileage_band: '||csr3_mileage_band);
	    hr_utility.trace('csr3_fuel_type: '||csr3_fuel_type);
	    hr_utility.trace('csr3_engine_cc: '||csr3_engine_cc);
	    hr_utility.trace('csr3_fuel_scale: '||csr3_fuel_scale);
	    hr_utility.trace('csr3_payment: '||csr3_payment);
	    hr_utility.trace('csr3_co2_emissions: '||csr3_co2_emissions);
	    hr_utility.trace('***************************');

	    IF (csr3_co2_emissions is null AND csr3_fuel_type <> 'BATTERY_ELECTRIC')
	    OR (csr3_reg_date < l_reg_date_lower_limit AND csr3_fuel_type <> 'BATTERY_ELECTRIC')
	    THEN
	    /* Calculate nicable value based on engine size */
	        hr_utility.trace('Engine size calc');

	        l_nicable_benefit := pay_gb_nicar_06042002.nicar_nicable_value_non_CO2
	                       ( p_assignment_id      	  => p_assignment_id,
	                         p_element_type_id	  => p_element_type_id,
	                         p_business_group_id  	  => p_business_group_id,
	                         p_car_price 		  => csr3_price,
	                         p_reg_date  		  => csr3_reg_date,
	                         p_fuel_type 		  => csr3_fuel_type,
	                         p_engine_size 		  => csr3_engine_cc,
	                         p_fuel_scale	      	  => csr3_fuel_scale,
	                         p_payment		  => csr3_payment,
	                         p_start_date		  => l_start_date,
	                         p_end_date		  => l_end_date,
	                         p_end_of_period_date 	  => l_end_of_period_date,
	                         p_emp_term_date	  => p_emp_term_date,
	                         p_session_date		  => p_session_date,
	                         p_message		  => l_cc_message);

	    else
	    /* Calculate nicable value based on CO2 emissions */
	        hr_utility.trace('CO2 emissions calc');

	        l_nicable_benefit := pay_gb_nicar_06042002.nicar_nicable_value_CO2
	                       ( p_assignment_id      	  => p_assignment_id,
	                         p_element_type_id	  => p_element_type_id,
	                         p_business_group_id      => p_business_group_id,
	                         p_car_price 		  => csr3_price,
	                         p_reg_date  		  => csr3_reg_date,
	                         p_fuel_type 		  => csr3_fuel_type,
	                         p_engine_size 		  => csr3_engine_cc,
	                         p_fuel_scale	          => csr3_fuel_scale,
	                         p_payment	          => csr3_payment,
	                         p_CO2_emissions 	  => csr3_co2_emissions,
	                         p_start_date		  => l_start_date,
	                         p_end_date		  => l_end_date,
	                         p_end_of_period_date     => l_end_of_period_date,
	                         p_emp_term_date	  => p_emp_term_date,
	                         p_session_date		  => p_session_date,
	                         p_message	          => l_co2_message);

	    end if;

	    hr_utility.set_location(g_package_name||'.'||l_function_name,100);

	    l_nicable_benefit := trunc((l_nicable_benefit * csr1_ni_rate),2);

	    hr_utility.trace('l_nicable_benefit: '||l_nicable_benefit);

	    l_running_total := l_running_total + l_nicable_benefit;


	    /* Check for messages originating from the CO2 emissions calculation; if they */
	    /* exist, add them to any messages from the engine size/fuel type/price cap   */
	    /* check section above, then add to message table				  */

	    if l_message is not null and l_co2_message is not null
	    then

	    	l_message := l_message||l_co2_message;
	    	tbl_msg_table(l_msg_count) := 'Entry dated '||l_start_date||': '||l_message;
		l_msg_count := l_msg_count + 1;

	    elsif l_message is not null and l_co2_message is null
	    then

	    	tbl_msg_table(l_msg_count) := 'Entry dated '||l_start_date||': '||l_message;
		l_msg_count := l_msg_count + 1;

	    elsif l_message is null and l_co2_message is not null
	    then

	    	tbl_msg_table(l_msg_count) := 'Entry dated '||l_start_date||': '||l_co2_message;
		l_msg_count := l_msg_count + 1;

	    end if;



    end loop;
--
    close csr3_nicar;
--
    hr_utility.set_location(g_package_name||'.'||l_function_name,110);


	/* Deal with any messages produced by calculation runs */
	/* If 5 or more messages produced then output first 3 messages plus generic message */
	/* otherwise output messages to 1 to 4 to fast formula */

	hr_utility.trace('Message lines: '||tbl_msg_table.COUNT);

	if tbl_msg_table.COUNT >= 5
	then

		hr_utility.trace('In messages(1)');

		p_message_1 := tbl_msg_table(1);
		p_message_2 := tbl_msg_table(2);
		p_message_3 := tbl_msg_table(3);
		p_message_4 := 'More than 4 messages were generated for NI Car in this run.' ||
					   ' Check element entries for NI Car up to current payroll run date';



	else

		hr_utility.trace('In messages(2)');

		for i in 1..tbl_msg_table.COUNT loop

			if i = 1
			then
				 p_message_1 := tbl_msg_table(i);
			end if;

			if i = 2
			then
				 p_message_2 := tbl_msg_table(i);
			end if;

			if i = 3
			then
				 p_message_3 := tbl_msg_table(i);
			end if;

			if i = 4
			then
				 p_message_4 := tbl_msg_table(i);
			end if;

	   end loop;

	end if;



    hr_utility.trace('l_running_total: '||l_running_total);



--
hr_utility.set_location(g_package_name||'.'||l_function_name,999);

--hr_utility.trace_off;

return l_running_total;


end nicar_main;


/* end of package body */
end pay_gb_nicar_06042002;

/
