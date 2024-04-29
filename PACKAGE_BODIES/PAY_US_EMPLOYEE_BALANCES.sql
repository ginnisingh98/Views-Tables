--------------------------------------------------------
--  DDL for Package Body PAY_US_EMPLOYEE_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_EMPLOYEE_BALANCES" AS
/* $Header: pyusempb.pkb 120.2 2006/08/24 11:29:09 kvsankar noship $ */

/******************************************************************************
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

    Name        : pay_us_employee_balances

    Description : The package is used by the Employee Balances form
    		  and it is used to fetch the earnings and non-tax
    		  deduction balances.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -----------------------------------
    26-Dec-2003 kaverma    115.0   3311781  Created.
    26-Mar-2004 kvsankar   115.1   3311781  Modified the code to fetch
                                   3300433  balance values for only those
                                            elements selected by the user
                                            in query mode
                                            Modified the function get_bal
                                            to consider balance adjustments
                                            done after actual termination date.
                                            Modified the cursors
                                            'c_get_element_runs' ,
                                            'csr_element_assact_info',
                                            'csr_element_assact_runs',
                                            'c_element_assact_balances',
                                            'c_element_asg_balances'
                                            to retrieve ROWID.
    06-Apr-2004 kvsankar   115.2   3541052  Modified the date passed for
                                            getting the value of the defined
                                            balances
    12-Apr-2004 kvsankar   115.3   3311781  Corrected GSCC warnings
    15-Apr-2004 kvsankar   115.4   3311781  Removed the cursor
                                            'c_element_assact_balances' since
                                            Balances for 'Balance
                                            Initialization' cannot be seen
                                            using assignment action mode. Also
                                            made changes to cursors
                                            'csr_element_assact_info',
                                            'csr_element_assact_runs',
                                            'c_element_asg_balances' to
                                            include the changes for 'PER'
                                            level balances.
    19-Apr-2004 kvsankar   115.5   3369361  Added the condition
                                            pac.tax_unit_id := p_tax_unit_id
                                            in cursor c_action_type
    11-May-2004 kvsankar   115.6   3300433  Changed the select query written
                                            for Bug Fix 3300433 to return
                                            final process date instead of
                                            last standard process date
    17-Mar-2005 meshah     115.7   4039299  changed cursor
                                            csr_element_assact_runs and changed
                                            the exists clause.
    13-Jan-2006 rpasumar   115.8   4915420  Changed per_assignments_f to
                                            per_all_assignments_f to
                                            improve performance.
    23-Aug-2006 kvsankar   115.9   5460886  Added a new cursor
                                            csr_element_assact_info_dedn for
                                            the following classifications
                                              * Pre-Tax Deductions
                                              * Involuntary Deductions
                                              * Voluntary Deduction
******************************************************************************/

 l_package  VARCHAR2(30);

/******************************************************************************
  Name    :  populate_element_info
  Purpose :  This procedure fetches the elements for which the balances are to
             be retrieved.It then finds out the corresponding balance values and
             stores them in a PL/SQL table.This PL/SQL table is passed to the
             form as an OUT parameter.
******************************************************************************/
 PROCEDURE populate_element_info( p_assignment_id       in  number,
				 p_assignment_action_id in  number,
				 p_classification_id    in  pay_element_classifications.classification_id%TYPE,
				 p_classification_name  in  pay_element_classifications.classification_name%TYPE,
				 p_session_date         in  pay_element_types_f.effective_start_date%TYPE,
				 p_action_date          in  pay_element_types_f.effective_start_date%TYPE,
				 p_pay_start_date       in  pay_element_types_f.effective_start_date%TYPE,
				 p_tax_unit_id          in  number,
				 p_per_month		in  number,
				 p_per_qtd 		in  number,
				 p_per_ytd		in  number,
				 p_asg_ptd 		in  number,
				 p_asg_month 		in  number,
				 p_asg_qtd 		in  number,
				 p_asg_ytd		in  number,
				 p_asg_itd		in  number,
				 p_legislation_code     in  pay_element_types_f.legislation_code%TYPE,
				 p_business_group_id    in  pay_element_types_f.business_group_id%TYPE,
				 p_balance_level        in  varchar2,
				 p_earn_data            out nocopy earn_tbl,
				 p_dedn_data            out nocopy dedn_tbl,
                                 p_element_type_id      in  out nocopy number,
                                 p_flag                 out nocopy varchar2,
                                 p_balance_status       in  varchar2
	                        )
 IS

   /*
    * Cursor to find out which processes have been completed.
    * Most interested in Quick pays or Runs.
    */

   CURSOR c_action_type
   IS
   select pay.action_type
     from pay_assignment_actions pac
         ,pay_payroll_actions pay
    where pay.payroll_action_id = pac.payroll_action_id
      and pac.assignment_id = p_assignment_id
      and pac.action_status = 'C'
      and pac.tax_unit_id = p_tax_unit_id
      and exists (select 'x'
                  from   pay_run_results prr
                  where  prr.assignment_action_id = pac.assignment_action_id )
    order by decode(pay.action_type,'Q','1','R','1','I','2','3');
    -- note: Also check run_results as might have a payment where there
    -- was no pay_value. In this case we'll want to see Initialised balance.



   l_attribute_name pay_bal_attribute_definitions.attribute_name%type;
   l_last_process_date DATE;
   l_date DATE;
   l_ytd_date DATE;
   l_qtd_date DATE ;
   l_temp_assignment_id per_assignments_f.assignment_id%TYPE;
   l_dim_month varchar2(20);
   l_dim_qtd   varchar2(20);
   l_dim_ytd   varchar2(20);



/******************************************************************************
 * Cursor to get element_information in case complete quickpay or run process
 * has been carried out don't include any initial upload elements.
 * This cursor is needed in assignment and date mode.
******************************************************************************/

   CURSOR c_get_element_runs
   IS
    select distinct pet.rowid
           ,pet.element_name
 	   ,pet.element_type_id
	   ,pet.classification_id
           ,pet.element_information10
	   ,pet.element_information11
	   ,pet.element_information12
	   ,pet.element_information14
      from  pay_element_types_f pet
          , pay_element_types_f pet2
          , pay_element_entries_f ee
     WHERE   pet2.classification_id = p_classification_id
       AND   pet2.element_information10 is not null
       AND   ee.effective_end_date >=  p_pay_start_date
       AND   ee.effective_start_date <= nvl(p_action_date , p_session_date  )
       AND   ee.effective_start_date between pet2.effective_start_date and pet2.effective_end_date
       AND   pet2.element_type_id = pet.element_type_id
       AND   PET.effective_start_date =  (select max(pet1.effective_start_date)
	        				   from pay_element_types_f pet1
		         			  where pet1.element_type_id = pet.element_type_id
		      				    and pet1.effective_start_date <= p_session_date  )
       AND    pet.element_name not like  'VERTEX%'
       AND    ee.assignment_id = p_assignment_id
       AND    EXISTS
		    (select prr.element_type_id
		       from    pay_run_results  prr
		      where   prr.source_id  = ee.element_entry_id
		        and     prr.source_type in ( 'E' , 'I' )
		        and     prr.element_type_id + 0 = pet.element_type_id
		    )
     order by 2;



/******************************************************************************
 * Cursor to get balance values incase balances are valid and mode is
 * assignment action mode for ASG/PER level balances.
******************************************************************************/

   CURSOR csr_element_assact_info
   IS
   select /*+ index (pet  pay_element_types_f_fk1) */ distinct pet.rowid
           ,pet.element_name
           ,pet.element_type_id
           ,pet.classification_id
           ,pet.element_information10
           ,pet.element_information11
           ,pet.element_information12
           ,pet.element_information14
           ,decode (p_balance_level,
	            'ASG',(PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pbT.balance_name) ,
	                  'ASG_GRE_PTD' ,
	                   p_assignment_action_id ,
                           NULL,
	                   NULL,
	                   p_tax_unit_id,
	                   p_business_group_id ,
                           NULL)),
		     'PER',NULL) PTD_VAL
           ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
  	     l_dim_month ,
  	     p_assignment_action_id ,
  	     NULL,
  	     NULL ,
  	     p_tax_unit_id,
  	     p_business_group_id ,
             NULL) MONTH_VAL
           ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
	     l_dim_qtd ,
	     p_assignment_action_id ,
	     NULL,
	     NULL ,
	     p_tax_unit_id,
	     p_business_group_id ,
             NULL) QTD_VAL
           ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
	     l_dim_ytd ,
	     p_assignment_action_id ,--global.assignment_action_id
	     NULL,
	     NULL ,
	     p_tax_unit_id,--control.tax_unit_id
	     p_business_group_id ,--ctlglobals.bg_id
             NULL) YTD_VAL
      from  pay_element_types_f pet
          , pay_element_classifications pec
	  , pay_defined_balances pdb
	  , pay_bal_attribute_definitions pbad
	  , pay_balance_attributes pba
	  , pay_balance_types pbt
          , pay_assignment_actions paa
          , pay_payroll_actions ppa
     WHERE   pbad.attribute_name = l_attribute_name
       AND   pbad.business_group_id is null
       AND   pbad.legislation_code = 'US'
       AND   pba.attribute_id = pbad.attribute_id
       AND   pdb.defined_balance_id = pba.defined_balance_id
       AND   pdb.balance_type_id =pbt.balance_type_id
       AND   pec.classification_id = p_classification_id
       AND   pec.classification_id = pet.classification_id
       and   pec.legislation_code = 'US'
       AND   pet.element_information10 is not null
       AND   nvl(ppa.date_earned,ppa.effective_date) between pet.effective_start_date
		                                         and pet.effective_end_date
       AND   paa.assignment_action_id =p_assignment_action_id
       AND   paa.payroll_action_id =ppa.payroll_action_id
       AND   pet.element_name not like  'VERTEX%'
       and   pet.element_information10= pDB.balance_type_id
       AND   EXISTS  (select prb.balance_value
			 from  pay_run_balances prb,
		               pay_defined_balances pdb
		        where prb.defined_balance_id = pdb.defined_balance_id
			  and prb.assignment_id = paa.assignment_id
			  and pdb.balance_type_id = pet.element_information10
	                  and rownum < 2)
     order by 2;

/******************************************************************************
 * Cursor to get balance values incase balances are valid and mode is
 * assignment action mode for ASG/PER level balances.
 * This cursor will be called for the following classifications
 *     * Pre-Tax Deductions
 *     * Involuntary Deductions
 *     * Voluntary Deductions
******************************************************************************/

   CURSOR csr_element_assact_info_dedn
   IS
   select /*+ index (pet  pay_element_types_f_fk1) */ distinct pet.rowid
           ,pet.element_name
           ,pet.element_type_id
           ,pet.classification_id
           ,pet.element_information10
           ,pet.element_information11
           ,pet.element_information12
           ,pet.element_information14
           ,decode (p_balance_level,
	            'ASG',(PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pbT.balance_name) ,
	                  'ASG_GRE_PTD' ,
	                   p_assignment_action_id ,
                           NULL,
	                   NULL,
	                   p_tax_unit_id,
	                   p_business_group_id ,
                           NULL)),
		     'PER',NULL) PTD_VAL
           ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
  	     l_dim_month ,
  	     p_assignment_action_id ,
  	     NULL,
  	     NULL ,
  	     p_tax_unit_id,
  	     p_business_group_id ,
             NULL) MONTH_VAL
           ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
	     l_dim_qtd ,
	     p_assignment_action_id ,
	     NULL,
	     NULL ,
	     p_tax_unit_id,
	     p_business_group_id ,
             NULL) QTD_VAL
           ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
	     l_dim_ytd ,
	     p_assignment_action_id ,--global.assignment_action_id
	     NULL,
	     NULL ,
	     p_tax_unit_id,--control.tax_unit_id
	     p_business_group_id ,--ctlglobals.bg_id
             NULL) YTD_VAL
      from  pay_element_types_f pet
          , pay_element_classifications pec
	  , pay_defined_balances pdb
	  , pay_bal_attribute_definitions pbad
	  , pay_balance_attributes pba
	  , pay_balance_types pbt
          , pay_assignment_actions paa
          , pay_payroll_actions ppa
     WHERE   pbad.attribute_name = l_attribute_name
       AND   pbad.business_group_id is null
       AND   pbad.legislation_code = 'US'
       AND   pba.attribute_id = pbad.attribute_id
       AND   pdb.defined_balance_id = pba.defined_balance_id
       AND   pdb.balance_type_id =pbt.balance_type_id
       AND   pec.classification_id = p_classification_id
       AND   pec.classification_id = pet.classification_id
       and   pec.legislation_code = 'US'
       AND   pet.element_information10 is not null
       AND   nvl(ppa.date_earned,ppa.effective_date) between pet.effective_start_date
                                                         and pet.effective_end_date
       AND   paa.assignment_action_id =p_assignment_action_id
       AND   paa.payroll_action_id =ppa.payroll_action_id
       AND   pet.element_name not like  'VERTEX%'
       and   pet.element_information10= pDB.balance_type_id
       AND   EXISTS  (select prb.balance_value
                        from  pay_run_balances prb,
                              pay_defined_balances pdb
                        where prb.defined_balance_id = pdb.defined_balance_id
                          and prb.assignment_id = paa.assignment_id
                          and pdb.balance_type_id in (pet.element_information10
                                                     ,pet.element_information11
                                                     ,pet.element_information12
                                                     ,pet.element_information14)
                          and rownum < 2)
     order by 2;


/*****************************************************************************
 * Cursor to get balance values incase balances are not valid and mode is
 * assignment action mode for ASG/PER level balances
*****************************************************************************/

   CURSOR csr_element_assact_runs
   IS
    select distinct pet.rowid
           ,pet.element_name
 	   ,pet.element_type_id
	   ,pet.classification_id
           ,pet.element_information10
	   ,pet.element_information11
	   ,pet.element_information12
	   ,pet.element_information14
	   ,decode (p_balance_level,
	            'ASG',(PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pbT.balance_name) ,
	                  'ASG_GRE_PTD' ,
	                  p_assignment_action_id ,
	                  NULL,
	                  NULL,
	                  p_tax_unit_id,
	                  p_business_group_id ,
                          NULL)),
                    'PER', NULL) PTD_VAL
           ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
  	     l_dim_month ,
  	     p_assignment_action_id ,
  	     NULL,
  	     NULL ,
  	     p_tax_unit_id,
  	     p_business_group_id ,
             NULL) MONTH_VAL
           ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
	     l_dim_qtd,
	     p_assignment_action_id ,
	     NULL,
	     NULL ,
	     p_tax_unit_id,
	     p_business_group_id ,
             NULL) QTD_VAL
          ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
	    l_dim_ytd,
	    p_assignment_action_id ,--global.assignment_action_id
	    NULL,
	    NULL ,
	    p_tax_unit_id,--control.tax_unit_id
	    p_business_group_id ,--ctlglobals.bg_id
            NULL) YTD_VAL
      from  pay_element_types_f pet
          , pay_payroll_actions ppa
          , pay_assignment_actions paa
          , pay_balance_types pbt
     WHERE  pet.classification_id = p_classification_id
       AND  pet.element_information10 is not null
       AND  PAA.ASSIGNMENT_ACTION_ID =p_assignment_action_id
       and  paa.payroll_action_id =ppa.payroll_action_id
       AND  nvl(ppa.date_earned,ppa.effective_date) between pet.effective_start_date
                                                 and pet.effective_end_date
       AND  pet.element_name not like  'VERTEX%'
       AND  paa.assignment_id = p_assignment_id
       AND  pet.element_information10 =pbt.balance_type_id
       AND  EXISTS (SELECT 'x'
                    FROM pay_payroll_actions pact,
		         pay_assignment_actions asg,
		         pay_run_results rr
    		    where rr.element_type_id + 0 = pet.element_type_id
		      and rr.assignment_action_id = asg.assignment_action_id
		      and asg.assignment_id = paa.assignment_id
		      and asg.tax_unit_id = paa.tax_unit_id
		      and asg.payroll_action_id = pact.payroll_action_id
		      and pact.effective_date between trunc(ppa.effective_date,'YEAR')
                                                  and ppa.effective_date
                      and rr.source_type in ( 'E' , 'I' )
                    )
    order by 2;
/*
       AND  EXISTS (select prr.element_type_id
                      from pay_run_results  prr
                     where prr.assignment_action_id  = paa.assignment_action_id
                       and prr.source_type in ( 'E' , 'I' )
                       and prr.element_type_id + 0 = pet.element_type_id
                   )
*/


/******************************************************************************
 * Cursor to get element information in case balance uploads are completed and
 * mode is assignment  mode for ASG/PER level balances
******************************************************************************/
     CURSOR c_element_asg_balances
          IS
           select distinct pet2.rowid
                  ,pet2. element_name
                  ,pet2.element_type_id
                  ,pet2.classification_id
                  ,pet2.element_information10
                  ,pet2.element_information11
                  ,pet2.element_information12
                  ,pet2.element_information14
                  ,decode (p_balance_level,
		           'ASG', (PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pbT.balance_name) ,
    	                          'ASG_GRE_PTD' ,
    	                          NULL,
    	                          l_temp_assignment_id,
    	                          l_date,
    	                          p_tax_unit_id,
    	                          p_business_group_id ,
    	                          NULL)),
                             'PER', NULL) PTD_VAL
                  ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
    	                 l_dim_month,
    	                 NULL  ,
    	                 l_temp_assignment_id,
    	                 l_date ,
    	                 p_tax_unit_id,
    	                 p_business_group_id ,
    	                 NULL) MONTH_VAL
                  ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
    	                 l_dim_qtd,
    	                 NULL  ,
    	                 l_temp_assignment_id,
    	                 nvl(l_qtd_date,l_date ),
    	                 p_tax_unit_id,
    	                 p_business_group_id ,
    	                 NULL) QTD_VAL
                  ,PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM (UPPER(pBT.balance_name) ,
    	                 l_dim_ytd,
    	                 NULL  ,--global.assignment_action_id
    	                 l_temp_assignment_id,
    	                 nvl(l_ytd_date,l_date) ,
    	                 p_tax_unit_id,--control.tax_unit_id
    	                 p_business_group_id ,--ctlglobals.bg_id
                	 NULL) YTD_VAL
    		from pay_element_classifications ec
    		    ,pay_element_types_f et
    		    ,pay_element_links_f el
    		    ,pay_element_entries_f ee
    		    ,pay_element_entry_values_f eev
    		    ,pay_balance_feeds_f pbf
    		    ,pay_element_types_f pet2
    		    ,pay_element_classifications pec
    		    ,pay_input_values_f piv
    	            ,pay_balance_types pbt
               where  ec.classification_name =  'Balance Initialization'
    		 and  ec.legislation_code is null
    		 and  ee.assignment_id = p_assignment_id
    		 and  ee.element_link_id = el.element_link_id
    		 and  el.element_type_id = et.element_type_id
    		 and  et.classification_id = ec.classification_id
    		 and  ee.element_entry_id =  eev.element_entry_id
    		 and  eev.input_value_id  = pbf.input_value_id
    		 and  piv.input_value_id  = pbf.input_value_id
    		 and  et.element_type_id  = piv.element_type_id
    		 and  nvl(p_action_date ,p_session_date) between pbf.effective_start_date
                                                             and pbf.effective_end_date
    		 and  pbf.balance_type_id = pet2.element_information10
    		 and  pbt.balance_type_id = pet2.element_information10
                 and  pet2.element_information10 is not null
    		 and  pet2.classification_id = pec.classification_id
    		 and  pec.classification_name = p_classification_name
    		 and  pec.legislation_code = 'US'
    		 and  nvl(p_action_date, p_session_date ) between pet2.effective_start_date
                                                              and pet2.effective_end_date
		 and  eev.screen_entry_value is not null
               order by 2;


   st_cnt  number;
   end_cnt number;
   i       number;
   j       number;
   l_value number;
   l_type  pay_payroll_actions.action_type%TYPE;
   l_procedure VARCHAR2(22) ;
   value pay_balance_types.balance_name%type ;
   p_dedn_data_temp p_dedn_data_temp_tbl;


/******************************************************************************
 * Name        :  get_balance_name
 * Purpose     :  This function is used to get the balance names based on the
 *                balance type id passed.
******************************************************************************/
FUNCTION get_balance_name(l_balance_type_id in number )
 RETURN varchar2 IS
 BEGIN
    SELECT balance_name INTO value
      FROM pay_balance_types
     WHERE balance_type_id =l_balance_type_id;
    RETURN value;

 EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN -1;
END;

/******************************************************************************
 * Name     : get_defined_bal
 * Purpose  : This function is used to get the defined balance ids based on
 *            balance type id and balance dimension id.
******************************************************************************/
FUNCTION get_defined_bal (p_bal_id in number
                         ,p_dim_id in number)
 RETURN number IS
 v_defbal_id number;
 l_function  varchar2(16);
 BEGIN
    l_function :='get_defined_bal';
    hr_utility.set_location(l_package||l_function, 10);

    SELECT   defined_balance_id
      INTO   v_defbal_id
      FROM   pay_defined_balances
     WHERE   balance_type_id = p_bal_id
       AND   balance_dimension_id = p_dim_id
       AND   nvl(business_group_id,p_business_group_id) = p_business_group_id
       AND   nvl(legislation_code,p_legislation_code) = p_legislation_code;

      hr_utility.set_location(l_package||l_function, 20);

      RETURN v_defbal_id;

     EXCEPTION WHEN NO_DATA_FOUND THEN
        hr_utility.set_location(l_package||l_function, 30);
     	RETURN -1;

    END;



/******************************************************************************
 * Name     : get_bal
 * Purpose  : This function is used to get balance values based on defined
 *            balance ids
******************************************************************************/

FUNCTION get_bal (l_defbal_id in number
		   ,l_bal_type_id in number)
 RETURN NUMBER IS
    l_last_process_date DATE;
    l_date DATE;
    l_ytd_id    number(9);
    l_qtd_id    number(9);
    l_temp_assignment_id per_assignments_f.assignment_id%TYPE;
    l_function varchar2(9);

 BEGIN
   l_function :='get_bal';
   hr_utility.set_location(l_package||l_function, 10);
   IF (p_assignment_action_id = -1 ) THEN
      IF  p_balance_level='PER' THEN
         l_ytd_id := get_defined_bal(l_bal_type_id,p_per_ytd);
         l_qtd_id := get_defined_bal(l_bal_type_id,p_per_qtd);

         hr_utility.set_location(l_package||l_function, 20);

         BEGIN

            -- check to see if p_assignment_id exist as of l_date
            select paf.assignment_id
              into  l_temp_assignment_id
              from  per_assignments_f paf,
                    hr_soft_coding_keyflex hsk
             where  paf.assignment_id = p_assignment_id
               and  paf.soft_coding_keyflex_id = hsk.soft_coding_keyflex_id
               and  p_session_date between paf.effective_start_date
                                       and paf.effective_end_date
               and  hsk.segment1 = to_char(p_tax_unit_id);

            l_temp_assignment_id :=    to_number(p_assignment_id);

            hr_utility.set_location(l_package||l_function, 30);

         EXCEPTION
            WHEN NO_DATA_FOUND THEN

            --  Attempt to find any assignment id for the person as of l_date

            BEGIN
               hr_utility.set_location(l_package||l_function, 40);

               select paf2.assignment_id
                 into l_temp_assignment_id
                 from per_assignments_f paf1,
                      per_assignments_f paf2,
                      hr_soft_coding_keyflex hsk
                where paf1.assignment_id = p_assignment_id
                  and paf2.person_id = paf1.person_id
                  and paf2.soft_coding_keyflex_id = hsk.soft_coding_keyflex_id
                  and p_session_date between paf2.effective_start_date
                                         and paf2.effective_end_date
                  and hsk.segment1 = to_char(p_tax_unit_id)
                  and rownum=1;

               hr_utility.set_location(l_package||l_function, 50);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN

               BEGIN
                  --  Find an assignment id for the person with an end date < l_date
                  --  and greater than  trunc(p_session_date,y).
                  hr_utility.set_location(l_package||l_function, 60);

	-- 4915420

		    select paf2.assignment_id
                    into l_temp_assignment_id
                    from per_all_assignments_f paf1,
                         per_all_assignments_f paf2,
                         hr_soft_coding_keyflex hsk
                   where paf1.assignment_id = p_assignment_id
                     and paf2.person_id = paf1.person_id
                     and paf2.soft_coding_keyflex_id = hsk.soft_coding_keyflex_id
                     and hsk.segment1 = to_char(p_tax_unit_id)
                     and paf2.effective_end_date < p_session_date
                     and paf2.effective_end_date >= trunc(p_session_date,'YYYY')
                     and paf2.effective_end_date =
                                (select MAX(paf3.effective_end_date)
                                   from per_all_assignments_f paf3
                                  where paf3.person_id = paf1.person_id
                                    and paf3.effective_end_date  < p_session_date
                                 )
                     and rownum=1;

		 /* select paf2.assignment_id
                    into l_temp_assignment_id
                    from per_assignments_f paf1,
                         per_assignments_f paf2,
                         hr_soft_coding_keyflex hsk
                   where paf1.assignment_id = p_assignment_id
                     and paf2.person_id = paf1.person_id
                     and paf2.soft_coding_keyflex_id = hsk.soft_coding_keyflex_id
                     and hsk.segment1 = to_char(p_tax_unit_id)
                     and paf2.effective_end_date < p_session_date
                     and paf2.effective_end_date >= trunc(p_session_date,'YYYY')
                     and paf2.effective_end_date =
                                (select MAX(paf3.effective_end_date)
                                   from per_assignments_f paf3
                                  where paf3.person_id = paf1.person_id
                                    and paf3.effective_end_date  < p_session_date
                                 )
                     and rownum=1; */


                   hr_utility.set_location(l_package||l_function, 70);

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  hr_utility.set_location(l_package||l_function, 80);
                  NULL;
               END;
            END;
         END;
      ELSE -- Assignment level balances are required

         hr_utility.set_location(l_package||l_function, 90);

         l_temp_assignment_id :=   p_assignment_id;
         l_ytd_id := get_defined_bal(l_bal_type_id,p_asg_ytd);
         l_qtd_id := get_defined_bal(l_bal_type_id,p_asg_qtd);

      END IF; -- Person/asg level balances

      hr_utility.set_location(l_package||l_function, 100);

      l_date := payvwele.get_fpd_or_atd(p_assignment_id => l_temp_assignment_id,
                                          p_session_date => p_session_date);
      -- Bugfix 3300433 start

      IF l_date IS NOT NULL THEN
         SELECT pps.final_process_date
           INTO l_last_process_date
           FROM per_periods_of_service pps
          WHERE date_start <= p_session_date
            AND pps.period_of_service_id = (
                                 SELECT DISTINCT(period_of_service_id)
                                   FROM per_all_assignments_f
                                  WHERE assignment_id = l_temp_assignment_id
                                    AND assignment_type = 'E'
                                            );

         -- Set the year end date as the final process date if not specified
         IF l_last_process_date is NULL THEN
            SELECT trunc(add_months(l_date,12),'Y')-1
              INTO l_last_process_date
              FROM dual;
         END IF;

         IF l_date>nvl(l_last_process_date,l_date) THEN
            l_last_process_date:=l_date;
         END IF;

         IF p_session_date<l_last_process_date THEN
            l_last_process_date:=p_session_date;
         END IF;
      END IF; -- Bugfix 3300433 end

      hr_utility.set_location(l_package||l_function,110);

      IF l_date IS NULL THEN
         l_date := p_session_date;   -- current emp
      ELSIF l_date >= p_session_date THEN
         l_date := p_session_date;  -- current emp
      ELSIF l_date < trunc(p_session_date, 'YEAR') THEN
         -- terminated before this year, so, no balances for this year
         l_date := p_session_date;
      ELSIF l_date < trunc(p_session_date, 'MONTH') THEN
         -- terminated this year but before this month
         IF l_date >= trunc(p_session_date, 'Q') THEN
            -- terminated this quarter
            -- show QTD and YTD balances
            IF l_ytd_id = l_defbal_id OR l_qtd_id = l_defbal_id THEN
               l_date:=l_last_process_date; -- Bugfix 3300433;
            ELSE
               l_date := p_session_date;
            END IF;
         ELSE
            -- only show YTD balance
            IF l_ytd_id = l_defbal_id THEN
               l_date:=l_last_process_date; -- Bugfix 3300433;
            ELSE
               l_date := p_session_date;
            END IF;
         END IF;
      ELSE
         -- terminated this year and this month
         -- show all balances
	 l_date := p_session_date; -- Bugfix 3300433 and 3541052
      END IF;
      hr_utility.set_location(l_package||l_function,120);
      -- set TAX_UNIT_ID context
      pay_balance_pkg.set_context ('TAX_UNIT_ID',  TO_CHAR(p_tax_unit_id));

      l_value := pay_balance_pkg.get_value_lock( p_defined_balance_id => l_defbal_id,
                                                 p_assignment_id      => l_temp_assignment_id,
                                                 p_virtual_date       => l_date,
                                                 p_asg_lock           => 'N' );
      hr_utility.set_location(l_package||l_function, 130);

   END IF;-- End assignment action check

   hr_utility.set_location(l_package||l_function, 150);

   RETURN l_value;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
       hr_utility.set_location(l_package||l_function, 160);
       RETURN NULL;
 END; --End of function get_bal


/******************************************************************************
 * Name     : get_dedn_info
 * Purpose  : This procedure is used to copy element information
 *            in earning tables to deduction tables.
******************************************************************************/
PROCEDURE get_dedn_info(p_earn_data IN earn_tbl,
                        p_dedn_data OUT NOCOPY dedn_tbl) IS
   st_cnt number;
   end_cnt number;
   i number;
   l_procedure VARCHAR2(15);
 BEGIN
    l_procedure :='get_dedn_info';
    hr_utility.set_location(l_package||l_procedure, 10);

    IF p_earn_data.COUNT>0 THEN
       st_cnt:=p_earn_data.FIRST;
       end_cnt:=p_earn_data.LAST;
       FOR i IN st_cnt ..end_cnt
          LOOP
          IF p_earn_data.exists(i) THEN
             p_dedn_data(i).row_id               :=p_earn_data(i).row_id;
             p_dedn_data(i).element_name         :=p_earn_data(i).element_name;
             p_dedn_data(i).element_type_id      :=p_earn_data(i).element_type_id;
             p_dedn_data(i).classification_id    :=p_earn_data(i).classification_id ;
      	     p_dedn_data(i).element_information10:=p_earn_data(i).element_information10;
             p_dedn_data(i).element_information11:=p_earn_data(i).element_information11;
             p_dedn_data(i).element_information12:=p_earn_data(i).element_information12;
             p_dedn_data(i).element_information14:=p_earn_data(i).element_information14;
             p_dedn_data(i).ptd                  :=p_earn_data(i).ptd;
             p_dedn_data(i).month                :=p_earn_data(i).month;
             p_dedn_data(i).qtd                  :=p_earn_data(i).qtd;
             p_dedn_data(i).ytd                  :=p_earn_data(i).ytd;
          END IF;
       END LOOP;
    END IF;
    hr_utility.set_location(l_package||l_procedure, 20);
 END;


/******************************************************************************
 * Name     : get_asg_date
 * Purpose  : This procedure is used to get the correct assignment and date
 *            that have to be passed in the call to the package
 *            PAY_US_TAXBAL_VIEW_PKG
******************************************************************************/
PROCEDURE get_asg_date IS
   l_procedure varchar2(14);
 BEGIN
    l_ytd_date :=NULL;
    l_qtd_date :=NULL;
    l_procedure:='get_asg_date';
    hr_utility.set_location(l_package||l_procedure, 10);

    IF (p_assignment_action_id = -1 ) THEN
       IF  p_balance_level='PER' THEN

          hr_utility.set_location(l_package||l_procedure, 20);
          BEGIN
             -- check to see if p_assignment_id exist as of l_date
             select paf.assignment_id
               into l_temp_assignment_id
               from per_assignments_f paf,
                    hr_soft_coding_keyflex hsk
              where paf.assignment_id = p_assignment_id
                and paf.soft_coding_keyflex_id = hsk.soft_coding_keyflex_id
                and p_session_date between paf.effective_start_date
                                       and paf.effective_end_date
                and hsk.segment1 = to_char(p_tax_unit_id);

             l_temp_assignment_id :=    to_number(p_assignment_id);

             hr_utility.set_location(l_package||l_procedure, 30);

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
             --  Attempt to find any assignment id for the person as of l_date
             BEGIN
                hr_utility.set_location(l_package||l_procedure, 40);


                select paf2.assignment_id
                  into l_temp_assignment_id
                  from per_assignments_f paf1,
                       per_assignments_f paf2,
                       hr_soft_coding_keyflex hsk
                 where paf1.assignment_id = p_assignment_id
                   and paf2.person_id = paf1.person_id
                   and paf2.soft_coding_keyflex_id = hsk.soft_coding_keyflex_id
                   and p_session_date between paf2.effective_start_date
                                          and paf2.effective_end_date
                   and hsk.segment1 = to_char(p_tax_unit_id)
                   and rownum=1;

                hr_utility.set_location(l_package||l_procedure, 50);
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                BEGIN
		   --  Find an assignment id for the person with an end date < l_date
                   --  and greater than  trunc(p_session_date,y).
                   hr_utility.set_location(l_package||l_procedure, 60);

	    -- 4915420

		   select paf2.assignment_id
                     into l_temp_assignment_id
                     from per_all_assignments_f paf1,
                          per_all_assignments_f paf2,
                          hr_soft_coding_keyflex hsk
                    where paf1.assignment_id = p_assignment_id
                      and paf2.person_id = paf1.person_id
                      and paf2.soft_coding_keyflex_id = hsk.soft_coding_keyflex_id
                      and hsk.segment1 = to_char(p_tax_unit_id)
                      and paf2.effective_end_date < p_session_date
                      and paf2.effective_end_date >= trunc(p_session_date,'YYYY')
                      and paf2.effective_end_date =
                                     (select MAX(paf3.effective_end_date)
                                        from per_all_assignments_f paf3
                                       where paf3.person_id = paf1.person_id
                                         and paf3.effective_end_date  < p_session_date
                                     )
                      and rownum=1;

		  /* select paf2.assignment_id
                     into l_temp_assignment_id
                     from per_assignments_f paf1,
                          per_assignments_f paf2,
                          hr_soft_coding_keyflex hsk
                    where paf1.assignment_id = p_assignment_id
                      and paf2.person_id = paf1.person_id
                      and paf2.soft_coding_keyflex_id = hsk.soft_coding_keyflex_id
                      and hsk.segment1 = to_char(p_tax_unit_id)
                      and paf2.effective_end_date < p_session_date
                      and paf2.effective_end_date >= trunc(p_session_date,'YYYY')
                      and paf2.effective_end_date =
                                     (select MAX(paf3.effective_end_date)
                                        from per_assignments_f paf3
                                       where paf3.person_id = paf1.person_id
                                         and paf3.effective_end_date  < p_session_date
                                     )
                      and rownum=1;  */

                   hr_utility.set_location(l_package||l_procedure, 70);

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                      hr_utility.set_location(l_package||l_procedure, 80);
                      NULL;
                END;
             END;
          END;
       ELSE -- Assignment level balances are required

          hr_utility.set_location(l_package||l_procedure, 90);
          l_temp_assignment_id :=   p_assignment_id;
       END IF; -- Person/asg level balances

       hr_utility.set_location(l_package||l_procedure, 100);

       l_date := payvwele.get_fpd_or_atd(p_assignment_id => l_temp_assignment_id,
                                         p_session_date => p_session_date);
       -- Bugfix 3300433 start

       IF l_date IS NOT NULL THEN
          SELECT pps.final_process_date
            into l_last_process_date
            FROM per_periods_of_service pps
           WHERE date_start <= p_session_date
             AND pps.period_of_service_id =
                                  ( SELECT DISTINCT(period_of_service_id)
                                      FROM per_all_assignments_f
                                     WHERE assignment_id = l_temp_assignment_id
                                       AND assignment_type = 'E');

          -- Set the year end date as the final process date if not specified
          IF l_last_process_date is NULL THEN
             SELECT trunc(add_months(l_date,12),'Y')-1
               INTO l_last_process_date
               FROM dual;
          END IF;

          IF l_date>nvl(l_last_process_date,l_date) THEN
             l_last_process_date:=l_date;
          END IF;

          IF p_session_date<l_last_process_date THEN
             l_last_process_date:=p_session_date;
          END IF;
       END IF; -- Bugfix 3300433 end

       hr_utility.set_location(l_package||l_procedure,110);

       IF l_date IS NULL THEN
           l_date := p_session_date;   -- current emp
       ELSIF l_date >= p_session_date THEN
           l_date := p_session_date;  -- current emp
       ELSIF l_date < trunc(p_session_date, 'YEAR') THEN
           -- terminated before this year, so, no balances for this year
           l_date := p_session_date;
       ELSIF l_date < trunc(p_session_date, 'MONTH') THEN
          -- terminated this year but before this month
          IF l_date >= trunc(p_session_date, 'Q') THEN
             -- terminated this quarter
             -- show QTD and YTD balances
             l_ytd_date:=l_last_process_date;
             l_qtd_date:=l_last_process_date;-- Bugfix 3300433;
             l_date := p_session_date;
          ELSE
             -- only show YTD balance
             l_ytd_date:=l_last_process_date;-- Bugfix 3300433;
             l_date := p_session_date;
          END IF;
       ELSE
          -- terminated this year and this month
          -- show all balances
	 l_date := p_session_date; -- Bugfix 3300433 and 3541052
       END IF;

       hr_utility.set_location(l_package||l_procedure,120);
       hr_utility.set_location(l_package||l_procedure, 130);

    END IF;-- End assignment action check

    hr_utility.set_location(l_package||l_procedure, 150);

 END; --End of procedure get_asg_date


 BEGIN  -- populate_element_info

    l_package  := 'pay_us_employee_balances.';
    l_procedure :='populate_element_info';
--    hr_utility.trace_on(null,'EMPB');
    hr_utility.set_location(l_package||l_procedure, 10);
    p_flag:='N';

    IF p_balance_level='ASG' THEN
       l_dim_month := 'ASG_GRE_MONTH';
       l_dim_qtd   := 'ASG_GRE_QTD';
       l_dim_ytd   := 'ASG_GRE_YTD';
    ELSE
       l_dim_month := 'PER_GRE_MONTH';
       l_dim_qtd   := 'PER_GRE_QTD';
       l_dim_ytd   := 'PER_GRE_YTD';
    END IF;

    open c_action_type;
    fetch c_action_type INTO l_type;
    close c_action_type;

    IF l_type ='Q' or l_type = 'R' THEN
       IF p_assignment_action_id <> -1 THEN   -- Assignment_action_mode
          IF(p_balance_status ='Y' ) THEN
             I:=0;
             IF UPPER(p_classification_name) = 'ALIEN/EXPAT EARNINGS' THEN
                l_attribute_name := 'PAY_US_ALIEN_EXPAT_EARNINGS';
             ELSIF UPPER(p_classification_name) = 'EARNINGS' THEN
                l_attribute_name := 'PAY_US_EARNINGS';
               ELSIF UPPER(p_classification_name) = 'SUPPLEMENTAL EARNINGS' THEN
                  l_attribute_name := 'PAY_US_SUPPLEMENTAL_EARNINGS';
	         ELSIF UPPER(p_classification_name) = 'IMPUTED EARNINGS' THEN
                    l_attribute_name := 'PAY_US_IMPUTED_EARNINGS';
	           ELSIF UPPER(p_classification_name) = 'EMPLOYER LIABILITIES' THEN
                      l_attribute_name := 'PAY_US_EMPLOYER_LIABILITY';
	             ELSIF UPPER(p_classification_name) = 'NON-PAYROLL PAYMENTS' THEN
                        l_attribute_name := 'PAY_US_NON_PAYROLL_PAYMENTS';
	               ELSIF UPPER(p_classification_name) = 'PRE-TAX DEDUCTIONS' THEN
                          l_attribute_name := 'PAY_US_PRE_TAX_DEDUCTIONS';
                         ELSIF UPPER(p_classification_name) = 'INVOLUNTARY DEDUCTIONS' THEN
                            l_attribute_name := 'PAY_US_INVOLUNTARY_DEDUCTIONS';
                           ELSIF UPPER(p_classification_name) = 'VOLUNTARY DEDUCTIONS' THEN
                              l_attribute_name := 'PAY_US_VOLUNTARY_DEDUCTIONS';
             END IF;

             hr_utility.set_location('Balances Valid ASG/PER level balances', 40);
             -- Use the cursor csr_element_assact_info_dedn for Deductions
             -- as it checks for existence of Run balances for
             -- Arrears, Accrued, Towards Bond balance apart from
             -- the base balance
             if (UPPER(p_classification_name) = 'PRE-TAX DEDUCTIONS'
                or UPPER(p_classification_name) = 'INVOLUNTARY DEDUCTIONS'
                or UPPER(p_classification_name) = 'VOLUNTARY DEDUCTIONS') then
                OPEN  csr_element_assact_info_dedn;
                LOOP
                   FETCH csr_element_assact_info_dedn INTO
                                   p_earn_data(i).row_id
                                  ,p_earn_data(i).element_name
                                  ,p_earn_data(i).element_type_id
                                  ,p_earn_data(i).classification_id
                                  ,p_earn_data(i).element_information10
                                  ,p_earn_data(i).element_information11
                                  ,p_earn_data(i).element_information12
                                  ,p_earn_data(i).element_information14
                                  ,p_earn_data(i).ptd
                                  ,p_earn_data(i).month
                                  ,p_earn_data(i).qtd
                                  ,p_earn_data(i).ytd;
                   EXIT WHEN csr_element_assact_info_dedn%NOTFOUND;
                   i:=i+1;
                END LOOP;
                CLOSE csr_element_assact_info_dedn;
             else
                OPEN  csr_element_assact_info;
                LOOP
                   FETCH csr_element_assact_info INTO
                                   p_earn_data(i).row_id
                                  ,p_earn_data(i).element_name
                                  ,p_earn_data(i).element_type_id
                                  ,p_earn_data(i).classification_id
                                  ,p_earn_data(i).element_information10
                                  ,p_earn_data(i).element_information11
                                  ,p_earn_data(i).element_information12
                                  ,p_earn_data(i).element_information14
                                  ,p_earn_data(i).ptd
                                  ,p_earn_data(i).month
                                  ,p_earn_data(i).qtd
                                  ,p_earn_data(i).ytd;
                   EXIT WHEN csr_element_assact_info%NOTFOUND;
                   i:=i+1;
                END LOOP;
                CLOSE csr_element_assact_info;

             end if; -- if (UPPER(p_classification_name) = 'PRE-TAX DEDUCTIONS'
          ELSE  -- Balances are invalid
             i:=0;
             hr_utility.set_location(l_package||l_procedure, 20);
             hr_utility.set_location('Balances Invalid ASG/PER level balances', 60); -- delete
             OPEN   csr_element_assact_runs;
             LOOP
                FETCH  csr_element_assact_runs
                 INTO  p_earn_data(i).row_id
                      ,p_earn_data(i).element_name
                      ,p_earn_data(i).element_type_id
                      ,p_earn_data(i).classification_id
                      ,p_earn_data(i).element_information10
                      ,p_earn_data(i).element_information11
                      ,p_earn_data(i).element_information12
                      ,p_earn_data(i).element_information14
                      ,p_earn_data(i).ptd
                      ,p_earn_data(i).month
                      ,p_earn_data(i).qtd
                      ,p_earn_data(i).ytd;
                EXIT WHEN  csr_element_assact_runs%NOTFOUND;
                i:=i+1;
             END LOOP;
             CLOSE csr_element_assact_runs;
          END IF; --Balance Validity check

          IF UPPER(p_classification_name) IN ('INVOLUNTARY DEDUCTIONS' ,
	                                      'VOLUNTARY DEDUCTIONS',
					      'PRE-TAX DEDUCTIONS') THEN
             get_dedn_info(p_earn_data,p_dedn_data);
             p_earn_data.delete();
             I:=P_DEDN_DATA.COUNT;

             FOR I IN 0 .. P_DEDN_DATA.COUNt-1
             LOOP
                p_dedn_data_temp(i).accrued :=get_balance_name(p_dedn_data(i).element_information11);
                p_dedn_data_temp(i).arrears :=get_balance_name(p_dedn_data(i).element_information12);
                p_dedn_data_temp(i).tobond :=get_balance_name(p_dedn_data(i).element_information14);
             END LOOP;

             FOR I IN 0 .. P_DEDN_DATA.COUNt-1
             LOOP
                p_dedn_data(i).accrued := PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM
                                          (UPPER(p_dedn_data_temp(i).accrued) ,
                                           'ASG_GRE_ITD' ,
                                           p_assignment_action_id ,
                                           NULL,
                                           NULL ,
                                           p_tax_unit_id,
                                           p_business_group_id ,
                                           NULL) ;
                p_dedn_data(i).arrears := PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM
                                          (UPPER(p_dedn_data_temp(i).arrears) ,
                                           'ASG_GRE_ITD' ,
                                           p_assignment_action_id ,
                                           NULL,
                                           NULL ,
                                           p_tax_unit_id,
                                           p_business_group_id ,
                                           NULL) ;
                p_dedn_data(i).tobond := PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM
                                          (UPPER(p_dedn_data_temp(i).tobond) ,
                                           'ASG_GRE_ITD' ,
                                           p_assignment_action_id ,
                                           NULL,
                                           NULL ,
                                           p_tax_unit_id,
                                           p_business_group_id ,
                                           NULL) ;
             END LOOP;
             p_dedn_data_temp.delete();
          END IF;

       ELSE --Assignment Mode
          i:=0;
          OPEN  c_get_element_runs;
          LOOP
             FETCH c_get_element_runs
              INTO p_earn_data(i).row_id
                   ,p_earn_data(i).element_name
                   ,p_earn_data(i).element_type_id
                   ,p_earn_data(i).classification_id
                   ,p_earn_data(i).element_information10
                   ,p_earn_data(i).element_information11
                   ,p_earn_data(i).element_information12
                   ,p_earn_data(i).element_information14;
             EXIT WHEN c_get_element_runs %NOTFOUND;
     	     i:=i+1;
          END LOOP;
          CLOSE c_get_element_runs;
          IF p_element_type_id IS NOT NULL and p_earn_data.COUNT>0 THEN
             st_cnt  := p_earn_data.first;
             end_cnt := p_earn_data.last;

             hr_utility.set_location(l_package||l_procedure, 60);

             FOR i IN st_cnt..end_cnt LOOP
                IF p_earn_data.exists(i) THEN
                   IF p_element_type_id=p_earn_data(i).element_type_id THEN
                      p_flag :='Y';
                      j:=i;
                      p_element_type_id :=j;
                      exit;
                   END IF;
                END IF;
             END LOOP;

             hr_utility.set_location(l_package||l_procedure, 70);

          END IF;

          -- Fetch the balance for the classification and populate the corresponding
          -- PLSQL table to be used by form
          IF UPPER(p_classification_name) IN ('ALIEN/EXPAT EARNINGS',
                                              'EARNINGS',
                                              'SUPPLEMENTAL EARNINGS',
                                              'IMPUTED EARNINGS',
                                              'EMPLOYER LIABILITIES',
                                              'NON-PAYROLL PAYMENTS') THEN
             hr_utility.set_location(l_package||l_procedure, 80);

             IF p_flag='Y' THEN
                IF p_balance_level='ASG' THEN
                   p_earn_data(j).ptd  :=get_defined_bal(p_earn_data(j).element_information10,p_asg_ptd);
                   p_earn_data(j).month:=get_defined_bal(p_earn_data(j).element_information10,p_asg_month);
                   p_earn_data(j).qtd  :=get_defined_bal(p_earn_data(j).element_information10,p_asg_qtd);
                   p_earn_data(j).ytd  :=get_defined_bal(p_earn_data(j).element_information10,p_asg_ytd);
                ELSE
                   p_earn_data(j).month:=get_defined_bal(p_earn_data(j).element_information10,p_per_month);
                   p_earn_data(j).qtd  :=get_defined_bal(p_earn_data(j).element_information10,p_per_qtd);
                   p_earn_data(j).ytd  :=get_defined_bal(p_earn_data(j).element_information10,p_per_ytd);
                END IF;

                hr_utility.set_location(l_package||l_procedure, 90);

                IF p_balance_level='ASG' THEN
                   p_earn_data(j).ptd  :=get_bal(p_earn_data(j).ptd,p_earn_data(j).element_information10);
                END IF;
                p_earn_data(j).month:=get_bal(p_earn_data(j).month,p_earn_data(j).element_information10);
                p_earn_data(j).qtd  :=get_bal(p_earn_data(j).qtd,p_earn_data(j).element_information10);
                p_earn_data(j).ytd  :=get_bal(p_earn_data(j).ytd,p_earn_data(j).element_information10);

                hr_utility.set_location(l_package||l_procedure, 100);
             END IF; -- End of p_flag

             IF p_element_type_id IS  NULL THEN
                -- start of fetching balance values for earnings when
                -- element type id is not passed
                -- get DEFINED BALANCE IDS for asg/person for different time dimensions
                hr_utility.set_location(l_package||l_procedure, 110);

                IF p_earn_data.COUNT>0 THEN

                   hr_utility.set_location(l_package||l_procedure, 120);

                   st_cnt  := p_earn_data.first;
                   end_cnt := p_earn_data.last;

                   FOR i IN st_cnt..end_cnt LOOP
                      IF p_earn_data.exists(i) THEN
                         IF p_balance_level='ASG' THEN
                            p_earn_data(i).ptd  :=get_defined_bal(p_earn_data(i).element_information10,p_asg_ptd);
                            p_earn_data(i).month:=get_defined_bal(p_earn_data(i).element_information10,p_asg_month);
                            p_earn_data(i).qtd  :=get_defined_bal(p_earn_data(i).element_information10,p_asg_qtd);
  	                    p_earn_data(i).ytd  :=get_defined_bal(p_earn_data(i).element_information10,p_asg_ytd);
                         ELSE
                            p_earn_data(i).month:=get_defined_bal(p_earn_data(i).element_information10,p_per_month);
                            p_earn_data(i).qtd  :=get_defined_bal(p_earn_data(i).element_information10,p_per_qtd);
                            p_earn_data(i).ytd  :=get_defined_bal(p_earn_data(i).element_information10,p_per_ytd);
                         END IF;
                      END IF;
                   END LOOP;
                   hr_utility.set_location(l_package||l_procedure, 130);
                END IF;

                -- end of fetching defined balance ids

                hr_utility.set_location(l_package||l_procedure, 140);

                -- get BALANCE values stored for asg/person for different time dimensions

                IF p_earn_data.COUNT>0 THEN
                   st_cnt  :=p_earn_data.first;
                   end_cnt :=p_earn_data.last;

                   hr_utility.set_location(l_package||l_procedure, 150);

                   FOR i IN st_cnt..end_cnt LOOP
                      IF p_earn_data.exists(i) THEN
                         IF p_balance_level='ASG' THEN
                            p_earn_data(i).ptd  :=get_bal(p_earn_data(i).ptd,p_earn_data(i).element_information10);
                         END IF;
                         p_earn_data(i).month:=get_bal(p_earn_data(i).month,p_earn_data(i).element_information10);
                         p_earn_data(i).qtd  :=get_bal(p_earn_data(i).qtd,p_earn_data(i).element_information10);
                         p_earn_data(i).ytd  :=get_bal(p_earn_data(i).ytd,p_earn_data(i).element_information10);
                      END IF;
                   END LOOP;

                   hr_utility.set_location(l_package||l_procedure, 160);

                END IF;
                -- End of fetching balance values for earnings.
                hr_utility.set_location(l_package||l_procedure, 170);
             END IF;
             -- End of fetching all balance values for earnings
             -- when element_type_id is not passed

          ELSE  -- get the values  for deduction elements

             hr_utility.set_location(l_package||l_procedure, 180);

             -- copy element information in the earning table to the deductions table
             get_dedn_info(p_earn_data,p_dedn_data);
             p_earn_data.delete;

             IF p_flag='Y' THEN
                IF p_balance_level='ASG' THEN
                   p_dedn_data(j).ptd      := get_defined_bal(p_dedn_data(j).element_information10,p_asg_ptd);
                   p_dedn_data(j).month    := get_defined_bal(p_dedn_data(j).element_information10,p_asg_month);
                   p_dedn_data(j).qtd      := get_defined_bal(p_dedn_data(j).element_information10,p_asg_qtd);
                   p_dedn_data(j).ytd      := get_defined_bal(p_dedn_data(j).element_information10,p_asg_ytd);
                ELSE
                   p_dedn_data(j).month    := get_defined_bal(p_dedn_data(j).element_information10,p_per_month);
                   p_dedn_data(j).qtd      := get_defined_bal(p_dedn_data(j).element_information10,p_per_qtd);
                   p_dedn_data(j).ytd      := get_defined_bal(p_dedn_data(j).element_information10,p_per_ytd);
                END IF;
                p_dedn_data(j).accrued  := get_defined_bal(p_dedn_data(j).element_information11,p_asg_itd);
                p_dedn_data(j).arrears  := get_defined_bal(p_dedn_data(j).element_information12,p_asg_itd);
                p_dedn_data(j).tobond   := get_defined_bal(p_dedn_data(j).element_information14,p_asg_itd);

                hr_utility.set_location(l_package||l_procedure, 190);

                IF p_balance_level='ASG' THEN
                   p_dedn_data(j).ptd  :=get_bal(p_dedn_data(j).ptd,p_dedn_data(j).element_information10);
                END IF;
                p_dedn_data(j).month    :=get_bal(p_dedn_data(j).month,p_dedn_data(j).element_information10);
                p_dedn_data(j).qtd      :=get_bal(p_dedn_data(j).qtd,p_dedn_data(j).element_information10);
                p_dedn_data(j).ytd      :=get_bal(p_dedn_data(j).ytd,p_dedn_data(j).element_information10 );
                p_dedn_data(j).accrued  :=get_bal(p_dedn_data(j).accrued,p_dedn_data(j).element_information11);
                p_dedn_data(j).arrears  :=get_bal(p_dedn_data(j).arrears,p_dedn_data(j).element_information12);
                p_dedn_data(j).tobond   :=get_bal(p_dedn_data(j).tobond,p_dedn_data(j).element_information14);

                hr_utility.set_location(l_package||l_procedure, 200);
             END IF;--End of fetching balance values when p_flag is 'Y'

             --start of code when element_type_id is not passed for deductions.
             --So  all balance values are to be retrieved
             IF p_element_type_id IS  NULL THEN
                -- fetch defined balance ids
                IF p_dedn_data.COUNT>0 THEN
                   st_cnt  :=p_dedn_data.first;
                   end_cnt :=p_dedn_data.last;

                   hr_utility.set_location(l_package||l_procedure, 210);

                   FOR i IN st_cnt..end_cnt LOOP
                      IF p_dedn_data.exists(i) THEN
                         IF p_balance_level='ASG' THEN
                            p_dedn_data(i).ptd   := get_defined_bal(p_dedn_data(i).element_information10,p_asg_ptd);
                            p_dedn_data(i).month := get_defined_bal(p_dedn_data(i).element_information10,p_asg_month);
                            p_dedn_data(i).qtd   := get_defined_bal(p_dedn_data(i).element_information10,p_asg_qtd);
                            p_dedn_data(i).ytd   := get_defined_bal(p_dedn_data(i).element_information10,p_asg_ytd);
                         ELSE
                            p_dedn_data(i).month := get_defined_bal(p_dedn_data(i).element_information10,p_per_month);
                            p_dedn_data(i).qtd   := get_defined_bal(p_dedn_data(i).element_information10,p_per_qtd);
                            p_dedn_data(i).ytd   := get_defined_bal(p_dedn_data(i).element_information10,p_per_ytd);
                         END IF;
                         p_dedn_data(i).accrued  := get_defined_bal(p_dedn_data(i).element_information11,p_asg_itd);
                         p_dedn_data(i).arrears  := get_defined_bal(p_dedn_data(i).element_information12,p_asg_itd);
                         p_dedn_data(i).tobond   := get_defined_bal(p_dedn_data(i).element_information14,p_asg_itd);
                      END IF;
                   END LOOP;
                   hr_utility.set_location(l_package||l_procedure, 220);

                END IF;

                hr_utility.set_location(l_package||l_procedure, 230);

                -- get the balance values.
                IF p_dedn_data.COUNT>0 THEN
                   st_cnt  :=p_dedn_data.first;
                   end_cnt :=p_dedn_data.last;

                   hr_utility.set_location(l_package||l_procedure, 240);

                   FOR i IN st_cnt..end_cnt LOOP

                      IF p_dedn_data.exists(i) THEN
                         IF p_balance_level='ASG' THEN
                            p_dedn_data(i).ptd  :=get_bal(p_dedn_data(i).ptd,p_dedn_data(i).element_information10);
                         END IF;
                         p_dedn_data(i).month	 :=get_bal(p_dedn_data(i).month,p_dedn_data(i).element_information10);
                         p_dedn_data(i).qtd     :=get_bal(p_dedn_data(i).qtd,p_dedn_data(i).element_information10);
                         p_dedn_data(i).ytd     :=get_bal(p_dedn_data(i).ytd,p_dedn_data(i).element_information10 );
                         p_dedn_data(i).accrued :=get_bal(p_dedn_data(i).accrued,p_dedn_data(i).element_information11);
                         p_dedn_data(i).arrears :=get_bal(p_dedn_data(i).arrears,p_dedn_data(i).element_information12);
                         p_dedn_data(i).tobond	 :=get_bal(p_dedn_data(i).tobond,p_dedn_data(i).element_information14);
                      END IF;

                   END LOOP;
                   hr_utility.set_location(l_package||l_procedure, 250);

                END IF; -- End of fetching balance values

                hr_utility.set_location(l_package||l_procedure, 260);

             END IF; -- End of fetching balances when p_element_type_id  is null;
             hr_utility.set_location(l_package||l_procedure, 270);
          END IF; --end earnings/deduction elements

       END IF; --End Assignmentaction/assignment mode

       hr_utility.set_location(l_package||l_procedure, 30);

    ELSIF l_type='I' THEN

       hr_utility.set_location(l_package||l_procedure, 40);

       I:=0;
       get_asg_date; -- Get the correct assignment id and date
       hr_utility.set_location('Balance Initialization ASG/PER level balances', 300);
       OPEN  c_element_asg_balances;
       LOOP
          FETCH c_element_asg_balances INTO
                 p_earn_data(i).row_id
                 ,p_earn_data(i).element_name
                 ,p_earn_data(i).element_type_id
                 ,p_earn_data(i).classification_id
                 ,p_earn_data(i).element_information10
                 ,p_earn_data(i).element_information11
                 ,p_earn_data(i).element_information12
                 ,p_earn_data(i).element_information14
                 ,p_earn_data(i).ptd
                 ,p_earn_data(i).month
                 ,p_earn_data(i).qtd
                 ,p_earn_data(i).ytd;
          EXIT WHEN c_element_asg_balances%NOTFOUND;
          i:=i+1;
       END LOOP;
       CLOSE c_element_asg_balances;

       IF UPPER(p_classification_name) IN ('INVOLUNTARY DEDUCTIONS',
                                           'VOLUNTARY DEDUCTIONS',
                                           'PRE-TAX DEDUCTIONS') THEN
          get_dedn_info(p_earn_data,p_dedn_data);
          p_earn_data.delete();
          I:=P_DEDN_DATA.COUNT;
          FOR I IN 0 .. P_DEDN_DATA.COUNt-1 LOOP
             p_dedn_data_temp(i).accrued :=get_balance_name(p_dedn_data(i).element_information11);
             p_dedn_data_temp(i).arrears :=get_balance_name(p_dedn_data(i).element_information12);
             p_dedn_data_temp(i).tobond :=get_balance_name(p_dedn_data(i).element_information14);
          END LOOP;

          FOR I IN 0 .. P_DEDN_DATA.COUNt-1 LOOP
              p_dedn_data(i).accrued := PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM
                                         (UPPER(p_dedn_data_temp(i).accrued) ,
                                          'ASG_GRE_ITD' ,
                                          NULL ,
                                          l_temp_assignment_id,
                                          l_date ,
                                          p_tax_unit_id,
                                          p_business_group_id ,
                                          NULL) ;
                p_dedn_data(i).arrears := PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM
                                         (UPPER(p_dedn_data_temp(i).arrears) ,
                                          'ASG_GRE_ITD' ,
                                          NULL ,
                                          l_temp_assignment_id,
                                          l_date ,
                                          p_tax_unit_id,
                                          p_business_group_id ,
                                          NULL) ;
                p_dedn_data(i).tobond := PAY_US_TAXBAL_VIEW_PKG.US_NAMED_BALANCE_VM
                                         (UPPER(p_dedn_data_temp(i).tobond) ,
                                          'ASG_GRE_ITD' ,
                                          NULL ,
                                          l_temp_assignment_id,
                                          l_date ,
                                          p_tax_unit_id,
                                          p_business_group_id ,
                                          NULL) ;
             END LOOP;
             p_dedn_data_temp.delete();
          END IF;
       hr_utility.set_location(l_package||l_procedure, 50);
    END IF;  -- l_type check

    IF p_element_type_id IS NOT NULL  and p_assignment_action_id <> -1 THEN
       IF UPPER(p_classification_name) IN ('INVOLUNTARY DEDUCTIONS' ,
                                           'VOLUNTARY DEDUCTIONS',
                                           'PRE-TAX DEDUCTIONS') THEN
          IF p_dedn_data.count>0 THEN
             st_cnt  := p_dedn_data.first;
             end_cnt := p_dedn_data.last;

             hr_utility.set_location(l_package||l_procedure, 60);

             FOR i IN st_cnt..end_cnt LOOP
                IF p_dedn_data.exists(i) THEN
                   IF p_element_type_id=p_dedn_data(i).element_type_id THEN
                      p_flag :='Y';
                      j:=i;
                      p_element_type_id :=j;
                      exit;
                   END IF;
                END IF;
             END LOOP;
          END IF;
       ELSE -- Earnings
          IF p_earn_data.count>0 THEN
             st_cnt  := p_earn_data.first;
             end_cnt := p_earn_data.last;

             hr_utility.set_location(l_package||l_procedure, 60);

             FOR i IN st_cnt..end_cnt LOOP
                IF p_earn_data.exists(i) THEN
                   IF p_element_type_id=p_earn_data(i).element_type_id THEN
                      p_flag :='Y';
                      j:=i;
                      p_element_type_id :=j;
                      exit;
                   END IF;
                END IF;
             END LOOP;
          END IF;
          hr_utility.set_location(l_package||l_procedure, 70);
       END IF; --Earnings/Deduction
    END IF; -- ELEMENT_TYPE_ID is not null
    -- Fetch the balance for the classification and populate the corresponding
    -- PLSQL table to be used by form

 EXCEPTION
 WHEN others THEN
    hr_utility.set_location(l_package||l_procedure, 280);
    raise_application_error(-20101, 'Error in '||l_package||l_procedure || ' - ' || sqlerrm);
 END;
END pay_us_employee_balances;


/
