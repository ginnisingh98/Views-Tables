--------------------------------------------------------
--  DDL for Package PAY_US_SOE_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_SOE_BALANCES_PKG" AUTHID CURRENT_USER AS
/* $Header: pyussoeb.pkh 120.3 2006/08/02 05:04:25 saurgupt noship $ */
/*
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

    Name        : pay_us_soe_balances_pkg

    Description : The package fetches the earnings/deductions values
                  for SOE form and populates them in plsql tables.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    07-NOV-2003 kaverma    115.0            Created.
    10-NOV-2003 kaverma    115.1   3138331  Modified procedure populate_action_ids
    12-NOV-2003 kaverma    115.2   3250653  Corrected populate_action_ids
    03-DEC-2003 kaverma    115.3   3275404  Removed get_phbr_plsql_table and get_earn_plsql_table
                                            and modified populate_earn_bal. Also removed prcedure
                                            get_dedn_plsql_table
    22-JUN-2004 kaverma    115.5   3620872  Added cursor c_get_pay_action_details and
                                            tables for new logic to fetch balances
    23-MAR-2006 saurgupt   115.6   4966938  Modified cursor c_get_pay_action_details. Add
                                            ppa.effective_date in the select statment.
    31-JUL-2006 saurgupt   115.7   5332346  Modified the procedure populate_actions_ids, added p_balance_status.
    02-AUG-2006 saurgut    115.8   5332346  Reversed the changes done in the ver. 115.7

  *****************************************************************************/

  /****************************************************************************
  The package is used by the US SOE Form to get the earnings and deduction values.
  All the procedures fetch the correponding earnings and deduction elements with
  the run and ytd values and populates a plsql table. The plsql table is then
  accessed in the form and the values from the plsql table are displayed in the
  SOE Form blocks.

  Each of the procedure is based on the following logic -

  IF SOE is Viewed for Prepayment/Quick Pay Prepayment
     Get all the run actions locked by the master prepayment action

     Get all the maximum run/quick pay actions for the person till the current
     pay period.

     If the balances are valid,
        Use Run Balance views to get the Run values using the run actions locked
	by the master prepayment.

	Use The Run Balance views to get the corresponding YTD value of the elements
	using the max. run/quick pay action till the current pay period.

     Else ( the balances are not valid)
        Use Run Results views to get the Run values using the run actions locked
	by the master prepayment.

	Use The Run Results views to get the corresponding YTD value of the elements
	using the max. run/quick pay action till the current pay period.
     End if;

   Else ( If the SOE is viewed for the Run action)
     If the balances are valid,
        Use Run Balance views to get the Run/YTD values using the run actions

     Else ( the balances are not valid)
        Use Run Results views to get the Run/YTD values using the run actions

    End if;

    Populate the plsql table of earnings and deductions to be used in the SOE form

  *****************************************************************************/

  -- Global Variables
  g_run_dimension_id    pay_balance_dimensions.balance_dimension_id%type;
  g_ytd_dimension_id    pay_balance_dimensions.balance_dimension_id%type;

  -- Record to store earnings elements
  TYPE  earn_rec is RECORD
  (rep_name	 pay_us_earnings_amounts_v.reporting_name_alt%type,
   hour_val        number,
   cur_val   	 number,
   ytd_val number
   );

  -- Record to store the deduction block elements
  TYPE dedn_rec is RECORD
  (rep_name	pay_us_deductions_v.reporting_name_alt%type,
   cur_val 	 number,
   ytd_val 	 number);

  -- Record to store federal deduction elements
  TYPE fed_rec is RECORD
  (rep_name    pay_us_fed_taxes_v.user_reporting_name%type,
   cur_val     number,
   tax_type    pay_us_fed_taxes_v.tax_type_code%type,
   ytd_val     number
   );

  -- Record to store state deduction elements
  TYPE state_rec is RECORD
  (state_abbrev  pay_us_state_taxes_v.state_abbrev%type,
   rep_name      pay_us_state_taxes_v.user_reporting_name%type,
   cur_val       number,
   tax_type      pay_us_state_taxes_v.tax_type_code%type,
   juris_code    pay_us_state_taxes_v.jurisdiction_code%type,
   ytd_val	 number);

  -- Record to store local deduction elements
  TYPE local_rec is RECORD
  (city_name   pay_us_local_taxes_v.city_name%type,
   juris_code  pay_us_local_taxes_v.jurisdiction_code%type,
   tax_type    pay_us_local_taxes_v.tax_type_code%type,
   rep_name    pay_us_local_taxes_v.user_reporting_name%type,
   cur_val number,
   ytd_val number);


  -- Record to store Earnings Elements for Run Results
  TYPE earnings_elements_rec is RECORD
  (element_reporting_name pay_element_types_f.reporting_name%type,
   element_information10  pay_element_types_f.element_information10%type,
   element_information12  pay_element_types_f.element_information12%type,
   business_group_id      pay_element_types_f.business_group_id%type,
   classification_name    pay_element_classifications.classification_name%type
  );

  -- Record to store Deductions Elements for Run Results
  TYPE deduction_elements_rec is RECORD
  (element_reporting_name pay_element_types_f.reporting_name%type,
   element_information10  pay_element_types_f.element_information10%type,
   business_group_id      pay_element_types_f.business_group_id%type
  );


  -- Record to store the all run actions locked by the prepayment
  -- master action id
  TYPE  master_aaid_rec is RECORD
  (asg_id 	number,
   aaid		number,
   run_type	pay_run_types_f.shortname%type,
   run_type_id 	number
   );

  -- Record to store the all master actions locked by the prepayment
  -- master action id
  TYPE master_aaid is 	RECORD
  (aaid     number);

  -- Declare Tables for all the records
  TYPE earn is TABLE  of earn_rec  INDEX BY BINARY_INTEGER;
  TYPE dedn is TABLE  of dedn_rec  INDEX BY BINARY_INTEGER;
  TYPE fed is TABLE   of fed_rec   INDEX BY BINARY_INTEGER;
  TYPE state is TABLE of state_rec INDEX BY BINARY_INTEGER;

  TYPE local is TABLE of local_rec INDEX BY BINARY_INTEGER;
  TYPE master_aaid_det is TABLE of  master_aaid_rec INDEX BY BINARY_INTEGER;
  TYPE master_aaid_tab is TABLE of master_aaid INDEX BY BINARY_INTEGER;

  --New Tables to store earnings and deduction elements.
  TYPE ded_elements is TABLE of deduction_elements_rec INDEX BY BINARY_INTEGER;
  TYPE earn_elements is TABLE of earnings_elements_rec INDEX BY BINARY_INTEGER;


   dedn_tab1  dedn;
   dedn_tab2  dedn;
   fed_tab    fed;
   state_tab  state;
   local_tab  local;

   run_actions_tab    master_aaid_det;
   master_actions_tab master_aaid_tab;

   earnings_elements_tab earn_elements;
   deduction_elements_tab ded_elements;

 /*****************************************************************************
   Name      : populate_actions_ids
   Purpose   : This procedure populates a PL/SQL Table with the locked master and
               run_actions
 *****************************************************************************/
  PROCEDURE populate_actions_ids(p_master_action_id  in number,
                                 p_assignment_id     in number,
                                 p_period_end_date   in date,
                                 p_asg_multi_flag    in varchar2,
                                 p_period_start_date in date) ;


 /*****************************************************************************
   Name      : populate_earn_bal
   Purpose   : This procedure populates a PL/SQL table with all the earnings elements
               for SOE form.
 *****************************************************************************/
  PROCEDURE populate_earn_bal(p_assignment_action_id in number,
                              p_balance_status       in varchar2,
                              p_action_type          in varchar2,
                              p_earn_tab             out nocopy earn); -- Bug 3275404



 /*****************************************************************************
   Name      : populate_fed_balance
   Purpose   : This procedure populates a PL/SQL table  with all the federal deduction
               elements for SOE form.
 *****************************************************************************/
  PROCEDURE populate_fed_balance(p_assignment_action_id in number,
                                 p_balance_status       in varchar2,
                                 p_action_type          in varchar2,
	    		         p_eic_curr_val         out nocopy number,
                 		 p_eic_ytd_val          out nocopy number,
				 p_dedn_tab             out nocopy dedn);


 /*****************************************************************************
   Name      : populate_state_balance
   Purpose   : This procedure populates a PL/SQL table  with all the state deductions
               elements for SOE form.
 *****************************************************************************/
  PROCEDURE populate_state_balance(p_assignment_action_id in number,
                                   p_balance_status       in varchar2,
                                   p_action_type          in varchar2,
                                   p_steic_curr_val       out nocopy number,
                                   p_steic_ytd_val        out nocopy number,
				   p_dedn_tab             out nocopy  dedn);



 /*****************************************************************************
   Name      : populate_local_balance
   Purpose   : This procedure populates a PL/SQL table with all the local deductions
               elements for SOE form.
 *****************************************************************************/
  PROCEDURE populate_local_balance(p_assignment_action_id in number,
                                   p_balance_status       in varchar2,
                                   p_action_type          in varchar2,
				   p_dedn_tab             out nocopy   dedn);



/*****************************************************************************
   Name      : populate_dedn_balance
   Purpose   : This procedure populates the plsql table with the Pre-Tax and
               and After Tax Deduction elements for SOE form.
*****************************************************************************/
  PROCEDURE populate_dedn_balance(p_assignment_action_id  in number,
                                  p_pre_balance_status    in varchar2,
                 		  p_aft_balance_status    in varchar2,
                                  p_action_type           in varchar2,
				  p_dedn_tab              out nocopy   dedn);




 /*****************************************************************************
   Name      : get_max_actions_table
   Purpose   : This procedure returns the plsql table of all max actions to the
               SOE form. We will store the max actions in sorted order so that
	       we can take advantage to use the last stored value as the max
	       action for Summary Block Values
 *****************************************************************************/
  PROCEDURE get_max_actions_table(p_max_actions_tab out nocopy master_aaid_tab);

   -- Bug 4966938 : Add ppa.effective_date. The ppa.effective_date is nothing but date paid and can be used as
   -- such.
   CURSOR c_get_pay_action_details(cp_assignment_action_id number)
   IS
    select paa.assignment_id,
           paa.assignment_action_id,
           ppa.date_earned,
           paa.tax_unit_id,
	   ppa.effective_date
      from pay_assignment_actions paa,
           pay_payroll_actions  ppa
     where paa.assignment_action_id = cp_assignment_action_id
       and paa.payroll_action_id    = ppa.payroll_action_id ;


END pay_us_soe_balances_pkg;

/
