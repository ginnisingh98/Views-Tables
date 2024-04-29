--------------------------------------------------------
--  DDL for Package Body PAY_US_SOE_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_SOE_BALANCES_PKG" AS
/* $Header: pyussoeb.pkb 120.9 2008/04/03 17:09:21 sneelapa noship $ */
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

    Description : The package has all the common packages used in
                  US Payroll.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  ------------------------------------
    07-NOV-2003 kaverma     115.0            Created.
    07-NOV-2003 kaverma     115.1  2816363   Corrected populate_earn_balance
                                             when run balances are not valid
    10-NOV-2003 kaverma     115.2  3138331   updated code to consider the termination
                                             of assignments for multiple assignments
    12-NOV-2003 kaverma     115.3  3250653   Corrected populate_local_balance to fetch
                                             school dst correcly. Also modified
					     populate_actions_ids.
    17-NOV-2003 kaverma     115.4  3257504   corrected cursor c_get_max_action_id
    21-NOV-2003 kaverma     115.5  3270646   Added exists check at places where plsql
                                             table is accessed.
    03-DEC-2003 kaverma     115.6  3275404   Modified populate_actions_ids and
                                             populate_earn_bal. Removed
                                             get_phbr_plsql_table,get_earn_plsql_table
                                             and get_dedn_plsql_table. Moved the logic
                                             to corres. plsql populate procedures and
                                             passing the plsql table as out parameter.
    06-JAN-2004 tclewis     115.7  2845480   Modified populate_state_balance.
                                             added code to reverse the sign for
                                             state EIC balances.   Added code to
                                             return STEIC balance as the fed
                                             procedure does.
    04-FEB-2004 ardsouza    115.9  3412605   Replaced table PAY_US_CITY_SCHOOL_DSTS
                                             by the view PAY_US_SCHOOL_DSTS to handle
                                             county level school districts of Kentucky.
    26-FEB-2004 sdahiya     115.10 3464757   Modified cursor c_get_max_action_id
                                             to use nvl(date_earned, effective_date)
                                             instead of effective_date. Created a
                                             branched version (115.6.11510.3) of
                                             this file too.
    31-MAY-2004 kaverma     115.11  3620872  Modified populate_dedn_balances to use
                                             dedution run balance/run result view
    10-JUN-2004 kaverma     115.12  3620872  Added Rule hint to earnings and deduction
                                             queries for quick customer performance fix.
    22-JUN-2004 kaverma     115.13  3620872  Changed the logic to fetch balances for
                                             earnings and deductions.
    06-SEP-2005 rmonge      115.14  3837653  Added a order by clause to the following
                                             cursors in the
                                                  c_get_pay_rb_elements,
                                                  c_get_pre_earn_run_rb,
                                                  c_get_pre_earn_ytd_rb,
                                                  c_get_more_earn_elements
                                             The order by clause matches the
                                             Q_Earnigns order by clause
                                             in order to retrieve the elements by
                                             Earnings by reporting_name,
                                             classification and processing_priority
    24-NOV-2005 kvsankar    115.15  4004796  Modified the cursors
                                                 c_get_more_earn_elements
                                             and c_get_more_dedn_elements
                                             to correct the Date
                                             Effective Joins present in them.
    02-DEC-2004 ahanda      115.16  4004796  Changed Earnings and Deductions query to
                                             not use view if Balances are not valid
                                             instrad check run results.
                                             This will ensure that indirect element
                                             will show up if balances are not valid.
   21-FEB-2005  sackumar   115.17   3334690  Remove a condition in populate earn balance when
			             	     balance status is invalid (<>'Y') which restrict to repeat the code
			   	     	     so current values is not sumed up in case of
			       	      	     Map enabled Multi Assignment

   13-JAN-2006  rmonge      4883110          Changed the order by clause for the Q_Earnings again
                                             to fix problem with customer not able to see all
                                             Earning Elements displayed or printed when the
                                             number of earning Elements is more than 8.
                                             The new order by will display any earning elements
                                             first regardless of their priority.
   23-MAR-2006 saurgupt    115.20   4966938  Changed the cursor c_get_pay_assignment_dtl. Add ppa.effective_date
                                             in the select statement.
                                             Write the new queries for cursors c_get_earn_elements and
                                             c_get_dedn_elements. Removed the table pay_element_entries_f.
                                             Now pay_assignment_actions and pay_payroll_actions are used.
                                             Also, now date_paid is used in place of date_earned. This resolves
                                             the boundary issue if date earned and date paid are in different
                                             years.
   16-MAY-2006 sodhingr   115.20   5228817   changed cursor c_get_dedn_elements and c_get_earn_elements
                                             to refer to ppa.effective_Date
   20-JUN-2006 sjawid     115.22   5210560   Added a condition to the c_get_assignments
                                             to avoid the overstated values in prepay soe
                                             when person with person type both employee and applicant.
   20-JUN-2006 sjawid     115.22   4743188   Changed Order by clause for the c_get_dedn_elements
                                             in order to sort with element name.
                                             Modified the logic in populate_earn_bal and populate_dedn_balance
                                             in order to load p_earn_tab and p_dedn_tab tables in sorting order
                                             when balances are invalid.
   31-JUL-2006 saurgupt   115.23   5332346   Modified the procedure populate_actions_ids. Add p_balance_status to
                                             check balance status. Removed cursor c_get_all_aaid_for_mast as it
                                             does not work for 11.0 data. Instead added two new cursors,
                                             c_get_all_aaid_for_mast_rb and c_get_all_aaid_for_mast_rr.
                                             Modified cursor c_get_dedn_elements and c_get_earn_elements. Removed
                                             the condition and paa1.source_action_id is not null.
   02-AUG-2006 saurgupt   115.24   5332346   Reverse the changes done in populate_actions_ids. Only modified the
                                             cursor c_get_all_aaid_for_mast by removing pay_run_types and instead
                                             added pay_payroll_actions.
   06-FEB-2007 kvsankar   115.25   5865549   Initialized the value of l_asg_action_id
                                             to NULL before using it.
   03-MAR-2008 sneelapa   115.26   6636807   Modified Procedure populate_action_ids
                                             CURSOR c_get_max_action_id
                                             Added 'V' in WHERE Condition for
                                             pay_payroll_actions.action_type column
  *****************************************************************************/

  l_package  VARCHAR2(30) := 'pay_us_soe_balances_pkg.';


 /*****************************************************************************
   Name      : populate_actions_ids
   Purpose   : This procedure populates a PL/SQLTable  with the maximum action id
               and the run action ids by prepayment.
   Note      : The procedure will be called by the SOE in case of prepayment.
               The Run values are the values of the locked run actions and
	       the YTD value is the value of the corresponding element given
	       by the maximum run action ID.
	       IF Multiple Assignments is checked for Payroll
	          Get maximum run actions for all multiple assignments
	       Else
	          Get maximum run action for the assignment in for SOE is viewed
 *****************************************************************************/
 PROCEDURE populate_actions_ids(p_master_action_id  in number,
                                p_assignment_id     in number,
                                p_period_end_date   in date,
				p_asg_multi_flag    in varchar2,
				p_period_start_date in date)
 IS

   CURSOR c_get_all_aaid_for_mast(cp_run_action_id number)
   IS
   select assact.assignment_action_id,
          assact.assignment_id
     from pay_action_interlocks intlk
         ,pay_assignment_actions assact
         ,pay_payroll_actions ppa
    where intlk.locking_action_id  = cp_run_action_id
      and intlk.locked_action_id   =  assact.assignment_action_id
      and assact.payroll_action_id = ppa.payroll_action_id
      and ((ppa.run_type_id is null and assact.source_action_id is null) or
           (ppa.run_type_id is not null and assact.source_action_id is not null))
      and not exists
           (select null
             from pay_payroll_actions rpact
                , pay_assignment_actions rassact
                , pay_action_interlocks rintlk
            where assact.assignment_action_id = rintlk.locked_action_id
              and rintlk.locking_action_id    = rassact.assignment_action_id
              and rpact.payroll_action_id     = rassact.payroll_action_id
              and rpact.action_type           = 'V')
      order by assact.assignment_action_id;
/*
   select assact.assignment_action_id,
          assact.assignment_id,
          prt.shortname,
	  prt.run_type_id
     from pay_action_interlocks intlk
         ,pay_assignment_actions assact
         ,pay_run_types_f prt
    where intlk.locking_action_id  = cp_run_action_id
      and intlk.locked_action_id   =  assact.assignment_action_id
      and assact.source_action_id  is not null
      and assact.run_type_id(+)    = prt.run_type_id
      and not exists
           (select null
             from pay_payroll_actions rpact
                , pay_assignment_actions rassact
                , pay_action_interlocks rintlk
            where assact.assignment_action_id = rintlk.locked_action_id
              and rintlk.locking_action_id    = rassact.assignment_action_id
              and rpact.payroll_action_id     = rassact.payroll_action_id
              and rpact.action_type           = 'V')
      order by assact.assignment_action_id;
*/

   -- Cursor to get all the assignments for the person effective in
   -- the current year for which SOE is being viewed
   CURSOR c_get_assignments (c_assignment_id number,c_period_end_date date)
   IS
   select distinct paa1.assignment_id
     from per_assignments_f paa,
          per_assignments_f paa1,
          per_people_f      ppa
    where paa.assignment_id = c_assignment_id
      and paa.person_id     = ppa.person_id
      and paa1.person_id    = ppa.person_id
      and paa1.ASSIGNMENT_TYPE  <>'A' -- bug5210560
      and paa1.effective_end_date >= to_date('01/01/'||to_char(c_period_end_date,'YYYY'),'DD/MM/YYYY')
      order by paa1.assignment_id;

   -- Cursor to get the maximum Run Action for the Assignment till the current
   -- pay period end date
   CURSOR c_get_max_action_id (c_assignment_id     number,
                               c_period_end_date   date,
			       c_period_start_date date)
   IS
   select assact.assignment_action_id -- Bug 3257504
    from  pay_assignment_actions assact,
          pay_payroll_actions    pac
    where assact.assignment_id      = c_assignment_id
      and assact.payroll_action_id  = pac.payroll_action_id
      and pac.action_type           in ('R','Q','B','I','V')
      -- 'V' action_type is added by sneelapa for bug 6636807
      and nvl(pac.date_earned, pac.effective_date)  <= c_period_end_date -- Bug 3464757
      and nvl(pac.date_earned, pac.effective_date)  >= trunc(c_period_start_date,'Y') -- Bug 3275404, 3464757
      and not exists
           (select null
             from pay_payroll_actions rpact
                , pay_assignment_actions rassact
                , pay_action_interlocks rintlk
            where assact.assignment_action_id = rintlk.locked_action_id
              and rintlk.locking_action_id    = rassact.assignment_action_id
              and rpact.payroll_action_id     = rassact.payroll_action_id
              and rpact.action_type           = 'V')
       order by assact.assignment_action_id desc;


   i               number := 0;
   j               number := 0;
   l_assignment_id number;
   l_asg_action_id number;
   c_aaid          number;
   c_asg_id        number;
   c_run_type      pay_run_types_f.shortname%type;
   c_run_type_id   number;
   l_aaid          number;
   l_procedure     varchar2(20) ;

 BEGIN
    l_procedure      := 'populate_actions_ids';
    hr_utility.set_location(l_package||l_procedure, 10);

    -- delete the plsql tables that stores max run action ids and
    -- locked run action ids by prepayment
    master_actions_tab.delete;
    run_actions_tab.delete;

    hr_utility.set_location(l_package||l_procedure, 20);

    -- Check if the Payroll is Multiple Assignments checked or not
    -- If yes we have to display the Person level balance for YTD field
    -- If no we will display the assignment level YTD values
    IF p_asg_multi_flag = 'Y' THEN
      -- New Logic to get YTD Values
      OPEN c_get_assignments (p_assignment_id , p_period_end_date);

	LOOP
          FETCH c_get_assignments INTO l_assignment_id;
	  EXIT WHEN c_get_assignments%NOTFOUND;

     -- Bug 5865549
     -- Set l_asg_action_id before using it
     l_asg_action_id := NULL;
	  OPEN c_get_max_action_id(l_assignment_id , p_period_end_date,p_period_start_date);
	  FETCH c_get_max_action_id INTO l_asg_action_id;
	  CLOSE c_get_max_action_id ;
            IF l_asg_action_id IS NOT NULL THEN
                  master_actions_tab(j).aaid:=l_asg_action_id;
        	  j := j + 1;
            END IF;
        END LOOP;

      CLOSE c_get_assignments;
    ELSE
      OPEN c_get_max_action_id(p_assignment_id , p_period_end_date, p_period_start_date);
      FETCH c_get_max_action_id INTO master_actions_tab(j).aaid;
      CLOSE c_get_max_action_id ;

    END IF; -- p_asg_multi_flag = 'Y'
    hr_utility.set_location(l_package||l_procedure, 30);

     -- get all locked child actions
     hr_utility.set_location(l_package||l_procedure, 40);

     OPEN c_get_all_aaid_for_mast(p_master_action_id);
       LOOP
         FETCH c_get_all_aaid_for_mast
	 INTO c_aaid, c_asg_id;
	 --INTO c_aaid, c_asg_id, c_run_type, c_run_type_id; -- Bug 5332346
         EXIT WHEN c_get_all_aaid_for_mast%NOTFOUND;
         i := i + 1;
         run_actions_tab(i).asg_id      := c_asg_id;
         run_actions_tab(i).aaid        := c_aaid;
         --run_actions_tab(i).run_type    := c_run_type; -- Bug 5332346
         --run_actions_tab(i).run_type_id := c_run_type_id; -- Bug 5332346
       END LOOP;
     CLOSE c_get_all_aaid_for_mast;

 EXCEPTION
    WHEN others THEN
      hr_utility.set_location(l_package||l_procedure,50);
      raise_application_error(-20101, 'Error in '|| l_package||l_procedure);
      raise;

 END populate_actions_ids;



 /******************************************************************************
 * Name     : get_defined_bal
 * Purpose  : This function is used to get the defined balance ids based on
 *            balance type id and balance dimension id.
 ******************************************************************************/
 FUNCTION get_defined_bal (p_bal_id               in number
                          ,p_dim_id               in number
			  )
 RETURN number IS
 v_defbal_id number;
 l_function  varchar2(16);
 BEGIN
    l_function :='get_defined_bal';
    hr_utility.set_location(l_package||l_function, 10);

    SELECT   defined_balance_id
      INTO   v_defbal_id
      FROM   pay_defined_balances pdb
     WHERE   pdb.balance_type_id = p_bal_id
       AND   pdb.balance_dimension_id = p_dim_id
       AND   nvl(pdb.legislation_code,'US') = 'US';

      hr_utility.set_location(l_package||l_function, 20);

      RETURN v_defbal_id;

 EXCEPTION WHEN NO_DATA_FOUND THEN
        hr_utility.set_location(l_package||l_function, 30);
     	RETURN -1;

 END;



 /*****************************************************************************
   Name      : populate_earn_bal
   Purpose   : This procedure populates a PL/SQL table with all the earnings elements
               for SOE form.
   NOTE      : plsql tables  p_earn_tab will be passed to the
               SOE form for display

  Bug 3275404 : Added p_earn_tab as out parameter and removed use of l_earn_info
                Also removed get_position_id procedure. The rounding issue (Bug 2816363)
                will be fixed by adding the difference to one of the same reporting name
                entries in the Rate Details Block in the Form.

 Bug 3837653  :  Added an order by clause to all cursor in the procedure that retrieve
 rmonge          the earnings elements. The new order by clause will
                 order the elements according to Reporting_name ,Classification,
                 and Processing Priority.
Bug 4883110.  Changed the order by clause again to fix problem with customer
              not able to see all the Earning Elements due to processing
              priority.  The new change allow the Earnings Elements to
              be printed first regardless of the priority.
 *****************************************************************************/
 PROCEDURE populate_earn_bal(p_assignment_action_id in number,
                             p_balance_status       in varchar2,
                             p_action_type          in varchar2,
			     p_earn_tab             out nocopy earn)
 IS

   -- Cursor to fetch the earnings balances when all earnings balances are valid
   CURSOR c_get_pay_rb_elements (c_run_assact_id number)
   IS
   select ytd_val
         ,reporting_name_alt
         ,run_val
         ,hours_run_val
	 ,element_type_id
    from pay_us_earnings_amounts_rbr_v
   where assignment_action_id = c_run_assact_id
   order by decode(reporting_name_alt, 'Regular Pay', 0,
                                       'Regular Salary',0,
                                       'Regular Wages',0,
                                       'Time Entry Wages',1),
            decode(classification_name,
                'Earnings',1,
                'Alien/Expat Earnings',2,
                'Supplemental Earnings', 3,
                'Inputed Earnings',4,
                'Tax Credit',5,
                'Non-payroll Payments',6),
            processing_priority;

   -- Cursor to get the run earnings amounts when the balances are valid
   CURSOR c_get_pre_earn_run_rb(cp_run_action_id number)
   IS
   select reporting_name_alt
         ,run_val
         ,hours_run_val
	 ,element_type_id
     from pay_us_earnings_amounts_rbr_v pt
    where pt.assignment_action_id =  cp_run_action_id
   order by decode( reporting_name_alt, 'Regular Pay', 0,
                                         'Regular Salary',0,
                                         'Regular Wages',0,
                                         'Time Entry Wages',1),
            decode(classification_name,
                         'Earnings',1,
                         'Alien/Expat Earnings',2,
                         'Supplemental Earnings', 3,
                         'Inputed Earnings',4,
                         'Tax Credit',5,
                         'Non-payroll Payments',6),
            processing_priority;

   -- Cursor to get the ytd earnings amounts when the balances are  valid
   CURSOR c_get_pre_earn_ytd_rb(cp_master_action_id number) IS
    select ytd_val
          ,pt.reporting_name_alt
	  ,element_type_id
      from pay_us_earnings_amounts_rbr_v pt
     where pt.assignment_action_id =  cp_master_action_id
    order by decode( reporting_name_alt, 'Regular Pay', 0,
                                         'Regular Salary',0,
                                         'Regular Wages',0,
                                         'Time Entry Wages',1),
             decode(classification_name,
                         'Earnings',1,
                         'Alien/Expat Earnings',2,
                         'Supplemental Earnings', 3,
                         'Inputed Earnings',4,
                         'Tax Credit',5,
                         'Non-payroll Payments',6),
             processing_priority;

   -- Cursor to get balance dimension for run and ytd
   CURSOR c_get_dimension_ids(cp_database_item_suffix varchar2) IS
    select balance_dimension_id
      from pay_balance_dimensions
     where legislation_code = 'US'
       and database_item_suffix = cp_database_item_suffix;

   CURSOR c_get_pay_assignment_dtl(cp_assignment_action_id number) IS
    select paa.assignment_id,
           ppa.date_earned,
	   ppa.effective_date
      from pay_assignment_actions paa,
           pay_payroll_actions  ppa
     where paa.assignment_action_id = cp_assignment_action_id
       and paa.payroll_action_id = ppa.payroll_action_id;

   -- Cursor to get elements processed from the element entries.
   -- rmonge  Added a order by clause  to make sure the earnings are retrieved in
   -- order by Processing priority and type of EArnings.
   -- Bug 4004796.Modified the Date effective joins with
   -- pay_element_entries_f and pay_element_types_f

   -- Bug 4966938
   CURSOR c_get_earn_elements(cp_date_paid   date,
                              cp_assignment_action_id number) IS
     select distinct pet.element_type_id,
            nvl(pet.reporting_name, pet.element_name),
            pet.element_information10,
            pet.element_information12,
            pet.business_group_id,
            pec.classification_name,
            pet.processing_priority
       from pay_assignment_actions paa ,
            pay_assignment_actions paa1 ,
	    pay_payroll_actions ppa ,
            pay_run_results prr ,
	    pay_element_types_f pet ,
            pay_element_classifications pec
      where paa.assignment_action_id = cp_assignment_action_id
        and paa1.assignment_id = paa.assignment_id
        -- and paa1.source_action_id is not null  --for bug 5332346
        and ppa.payroll_action_id = paa1.payroll_action_id
        and ppa.effective_date between trunc(cp_date_paid,'Y') and cp_date_paid
        and prr.assignment_action_id = paa1.assignment_action_id
        and prr.source_type in ( 'E', 'I' )
        and pet.element_type_id   >=  0
        and pet.element_information10 is not null
        and nvl(ppa.date_earned,ppa.effective_date) between pet.effective_start_date and pet.effective_end_date
        and prr.element_type_id + 0   = pet.element_type_id
        and pec.classification_name in ('Earnings',
                                        'Alien/Expat Earnings',
                                        'Non-payroll Payments',
                                        'Imputed Earnings',
       		                        'Supplemental Earnings')
        and pet.classification_id = pec.classification_id
      order by decode(nvl(pet.reporting_name, pet.element_name),
                      'Regular Pay', 0,
                      'Regular Salary',0,
                      'Regular Wages',0,
                      'Time Entry Wages',1),
               decode(pec.classification_name,
                      'Earnings',1,
                      'Alien/Expat Earnings',2,
                      'Supplemental Earnings', 3,
                      'Inputed Earnings',4,
                      'Tax Credit',5,
                      'Non-payroll Payments',6),
               pet.processing_priority;

        /*
 CURSOR c_get_earn_elements(cp_date_earned   date,
                            cp_assignment_id number) IS
     select /*+ ORDERED  distinct
            pet.element_type_id,
            nvl(pet.reporting_name, pet.element_name),
            pet.element_information10,
            pet.element_information12,
            pet.business_group_id,
            pec.classification_name,
            pet.processing_priority
       from pay_element_entries_f pee,
            pay_run_results prr,
            pay_element_types_f pet,
            pay_element_classifications pec
      where pee.assignment_id = cp_assignment_id
        --and pee.effective_end_date >= trunc(cp_date_earned, 'Y')
        and pee.effective_start_date <= cp_date_earned
        and prr.source_id = pee.element_entry_id
        and prr.source_type in ( 'E', 'I' )
        and pec.classification_name in ('Earnings',
                                        'Alien/Expat Earnings',
                                        'Non-payroll Payments',
                                        'Imputed Earnings',
				        'Supplemental Earnings')
        and pet.classification_id = pec.classification_id
        and pet.element_information10 is not null
        and pet.effective_start_date =
                   (select max(pet1.effective_start_date)
                      from pay_element_types_f pet1
                     where pet1.element_type_id = pet.element_type_id
                       and pet1.effective_start_date <= cp_date_earned)
        and prr.element_type_id + 0  = pet.element_type_id
      order by decode(nvl(pet.reporting_name, pet.element_name),
                      'Regular Pay', 0,
                      'Regular Salary',0,
                      'Regular Wages',0,
                      'Time Entry Wages',1),
               decode(pec.classification_name,
                      'Earnings',1,
                      'Alien/Expat Earnings',2,
                      'Supplemental Earnings', 3,
                      'Inputed Earnings',4,
                      'Tax Credit',5,
                      'Non-payroll Payments',6),
               pet.processing_priority;
*/


   l_rep_name      pay_us_earnings_amounts_v.reporting_name_alt%type;
   l_run_val       number;
   l_ytd_val       number;
   l_hours         number;

   l_found1            number:=0;
   l_found             boolean;
   l_pos               number;
   l_procedure         varchar2(21);

   l_element_type_id        pay_element_types_f.element_type_id%type;
   l_element_reporting_name pay_element_types_f.reporting_name%type;
   l_element_information10  pay_element_types_f.element_information10%type;
   l_element_information12  pay_element_types_f.element_information12%type;
   l_assignment_id          pay_assignment_actions.assignment_id%type;
   l_assignment_action_id   pay_assignment_actions.assignment_action_id%type;
   l_tax_unit_id            pay_assignment_actions.tax_unit_id%type;
   l_date_earned            pay_payroll_actions.date_earned%type;
   l_date_paid              pay_payroll_actions.effective_date%type;
   l_business_group_id      pay_element_types_f.business_group_id%type;
   l_classification_name    pay_element_classifications.classification_name%type;
   l_processing_priority    pay_element_types_f.processing_priority%type;


   -- Procedure to get the position of the reporting name in the plsql table
   -- If the element exists it will return the position otherwise will return
   -- new index where new element will be stored. Needed to group the earnings
   -- based on the reporting name
   PROCEDURE get_position_name (
               p_rep_name  in  pay_us_earnings_amounts_rbr_v.reporting_name_alt%type,
               p_found     out nocopy boolean,
               p_index     out nocopy number)
   IS
     st_cnt    number;
     ed_cnt   number;
     p_cnt     number;
   BEGIN
     p_found := FALSE;
     p_index := 0;
     p_cnt :=  p_earn_tab.COUNT;

     IF p_cnt = 0 THEN
        p_found := FALSE;
        p_index := 0;
        return;
     ELSE
        st_cnt := p_earn_tab.FIRST;
        ed_cnt := p_earn_tab.LAST;

	for i in st_cnt.. ed_cnt LOOP
	  IF p_earn_tab.exists(i) THEN
           IF p_rep_name = p_earn_tab(i).rep_name THEN
              p_index := i;
              p_found := TRUE;
              return;
           END IF;
	  END IF;
        END LOOP;
     END IF;
   END get_position_name;

 BEGIN
   --hr_utility.trace_on(null,'SOE');
   l_procedure          := 'populate_earn_bal';
   hr_utility.set_location(l_package||l_procedure,10);

   IF g_run_dimension_id is null THEN
      OPEN c_get_dimension_ids('_ASG_GRE_RUN');
      FETCH c_get_dimension_ids into g_run_dimension_id;
      CLOSE c_get_dimension_ids;

      OPEN c_get_dimension_ids('_ASG_GRE_YTD');
      FETCH c_get_dimension_ids into g_ytd_dimension_id;
      CLOSE c_get_dimension_ids;
   END IF;
   hr_utility.trace('Run Dimension : ' || g_run_dimension_id ||
                    'YTD Dimension : ' || g_ytd_dimension_id);

   -- delete earnings table
   p_earn_tab.delete;
   earnings_elements_tab.delete;
   hr_utility.set_location(l_package||l_procedure,20);

   IF p_action_type in ('P','U') THEN

      IF p_balance_status = 'Y' THEN
         IF run_actions_tab.count > 0 THEN

            hr_utility.set_location(l_package||l_procedure,30);
            -- set the session variable as we are only getting the
            -- RUN Balance
            pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
            pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
            pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
            pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
            pay_us_balance_view_pkg.set_session_var('YTD','FALSE');

	    -- For all the run actions locked by prepayment , get all the
	    -- earnings elements and corresponding run value
	    FOR i IN run_actions_tab.FIRST .. run_actions_tab.LAST LOOP
	        IF run_actions_tab.exists(i) THEN
	           OPEN  c_get_pre_earn_run_rb(run_actions_tab(i).aaid);
	           LOOP
      	              FETCH c_get_pre_earn_run_rb INTO
                            l_rep_name --:EARNINGS.ELE_NAME
                           ,l_run_val  --:EARNINGS.EARN_AMT
                           ,l_hours    --:EARNINGS.EARN_HRS;
		           ,l_element_type_id;
                      EXIT WHEN c_get_pre_earn_run_rb%NOTFOUND;

		      -- Populate Earnings Elements Table
           	      earnings_elements_tab(l_element_type_id).element_reporting_name
                                         := l_rep_name ;
                      earnings_elements_tab(l_element_type_id).element_information10
                                          := null;
                      earnings_elements_tab(l_element_type_id).element_information12
                                          := null;
                      earnings_elements_tab(l_element_type_id).business_group_id
                                          := null;
 	              earnings_elements_tab(l_element_type_id).classification_name
                                          := null;
		      --
        	      -- See if element already exists in plsql table
		      get_position_name(l_rep_name,l_found, l_pos);
                      hr_utility.set_location(l_package||l_procedure,40);
		      IF l_found = FALSE THEN
                         l_pos := p_earn_tab.COUNT + 1;
                         p_earn_tab(l_pos).rep_name := l_rep_name;
                         p_earn_tab(l_pos).hour_val := l_hours;
                         p_earn_tab(l_pos).cur_val  := l_run_val;
		         p_earn_tab(l_pos).ytd_val  :=0;
                      ELSE
                         p_earn_tab(l_pos).hour_val
                                  := p_earn_tab(l_pos).hour_val + l_hours;
                         p_earn_tab(l_pos).cur_val
                                  := p_earn_tab(l_pos).cur_val + l_run_val;
		         p_earn_tab(l_pos).ytd_val:=0;
                      END IF;
	           END LOOP;
	           CLOSE c_get_pre_earn_run_rb;
	           hr_utility.set_location(l_package||l_procedure,50);
	        END IF;
            END LOOP;
            hr_utility.set_location(l_package||l_procedure,60);
         END IF;

         -- Get YTD values for master action
         IF p_earn_tab.COUNT > 0 THEN

            hr_utility.set_location(l_package||l_procedure,70);

	    -- Get the YTD value for the maximum run action stored in the
	    -- master_actions_tab plsql table
	    IF master_actions_tab.count > 0 then

	       hr_utility.set_location(l_package||l_procedure,90);

	       pay_us_balance_view_pkg.set_session_var('RUN','FALSE');
               pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
               pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
               pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
               pay_us_balance_view_pkg.set_session_var('YTD','TRUE');

               FOR i IN master_actions_tab.FIRST .. master_actions_tab.LAST LOOP
                   IF master_actions_tab.exists(i) THEN
                      OPEN c_get_pre_earn_ytd_rb(master_actions_tab(i).aaid);
		      LOOP
                         FETCH c_get_pre_earn_ytd_rb INTO
                               l_ytd_val,l_rep_name,l_element_type_id;
                         EXIT WHEN c_get_pre_earn_ytd_rb%NOTFOUND;
		         hr_utility.set_location(l_package||l_procedure,91);

		         -- Populate Earnings after check
	                 IF earnings_elements_tab.count > 0 THEN
	                    IF earnings_elements_tab.exists(l_element_type_id) THEN
	                       hr_utility.trace('Element already exists in PLSQL table');
	                    ELSE
	                       earnings_elements_tab(l_element_type_id).element_reporting_name
                                     := l_rep_name ;
                               earnings_elements_tab(l_element_type_id).element_information10
                                     := null;
	                       earnings_elements_tab(l_element_type_id).element_information12
                                     := null;
	                       earnings_elements_tab(l_element_type_id).business_group_id
                                     := null;
                               earnings_elements_tab(l_element_type_id).classification_name
                                     := null;
	                    END IF;
		            hr_utility.set_location(l_package||l_procedure,92);
	                 ELSE
	                    earnings_elements_tab(l_element_type_id).element_reporting_name
                                     :=  l_rep_name;
                            earnings_elements_tab(l_element_type_id).element_information10
                                     := null;
                            earnings_elements_tab(l_element_type_id).element_information12
                                     := null;
	                    earnings_elements_tab(l_element_type_id).business_group_id
                                     := null;
 	                    earnings_elements_tab(l_element_type_id).classification_name
                                     := null;
	                 END IF;
		         hr_utility.set_location(l_package||l_procedure,93);

		         -- get the position of the element in the plsql table
                         get_position_name(l_rep_name,l_found, l_pos);
         	         IF l_found = TRUE THEN
                            -- Add the value if element already exists
		            p_earn_tab(l_pos).ytd_val :=p_earn_tab(l_pos).ytd_val+l_ytd_val;
		         ELSE
		            -- Create new index and store ytd value with run values as 0
   		            l_pos := p_earn_tab.count+1;
   		            p_earn_tab(l_pos).rep_name :=l_rep_name;
   		            p_earn_tab(l_pos).cur_val  :=0;
   		            p_earn_tab(l_pos).hour_val :=0;
   		            p_earn_tab(l_pos).ytd_val  :=l_ytd_val;
        	         END IF;
                      END LOOP;
                      hr_utility.set_location(l_package||l_procedure,94);
	              CLOSE c_get_pre_earn_ytd_rb;
                   END IF;
                 END LOOP;

	         hr_utility.set_location(l_package||l_procedure,100);
	      END IF; -- master_actions_tab.count > 0
           END IF;
          hr_utility.set_location(l_package||l_procedure,110);
      end if;

      IF p_balance_status <> 'Y' THEN

         hr_utility.set_location(l_package||l_procedure,120);

         IF run_actions_tab.COUNT >0 THEN
	    pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
            pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
            pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
            pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
            pay_us_balance_view_pkg.set_session_var('YTD','FALSE');

	    -- For all the run actions locked by prepayment , get all the
	    -- earnings elements and corresponding run value
            FOR i IN run_actions_tab.FIRST .. run_actions_tab.LAST LOOP
	        IF run_actions_tab.exists(i) THEN
                  -- 4966938
                   OPEN c_get_pay_assignment_dtl(run_actions_tab(i).aaid);
                   FETCH c_get_pay_assignment_dtl INTO l_assignment_id, l_date_earned, l_date_paid;
                   CLOSE c_get_pay_assignment_dtl;

                   hr_utility.set_location(l_package||l_procedure,210);
	           hr_utility.trace('Run Action ID : ' || run_actions_tab(i).aaid);
	           hr_utility.set_location(l_package||l_procedure,220);
                   -- 4966938
                   OPEN c_get_earn_elements(l_date_paid,run_actions_tab(i).aaid);
                   LOOP
                      FETCH c_get_earn_elements
	                      INTO l_element_type_id
	                          ,l_element_reporting_name
	                          ,l_element_information10
	                          ,l_element_information12
	                          ,l_business_group_id
                                  ,l_classification_name
                                  ,l_processing_priority;
                      EXIT WHEN c_get_earn_elements%NOTFOUND;

--Remove a check from here for Bug 3334690

       	                 earnings_elements_tab(l_element_type_id).element_reporting_name
                                   := l_element_reporting_name ;
                         earnings_elements_tab(l_element_type_id).element_information10
                                   := l_element_information10;
                         earnings_elements_tab(l_element_type_id).element_information12
                                   := l_element_information12;
                         earnings_elements_tab(l_element_type_id).business_group_id
                                   := l_business_group_id;
                         earnings_elements_tab(l_element_type_id).classification_name
                                  := l_classification_name;

                         hr_utility.set_location(l_package||l_procedure,221);
	                 IF l_classification_name = 'Non-payroll Payments' THEN
	                    l_rep_name := l_element_reporting_name;
	                    l_hours    := null;
	                    l_run_val  := pay_balance_pkg.get_value
	                                       (get_defined_bal(l_element_information10,
		    	                                        g_run_dimension_id),
		                                                run_actions_tab(i).aaid);
                         ELSE
                            hr_utility.set_location(l_package||l_procedure,222);
	                    l_rep_name := l_element_reporting_name;
	                    hr_utility.set_location(l_package||l_procedure ,223);

	                    IF l_element_information12 is not null THEN
	                       l_hours    := pay_balance_pkg.get_value
	                                          (get_defined_bal(
                                                      to_number(l_element_information12),
		      	                              g_run_dimension_id),
		                                      run_actions_tab(i).aaid);
	                    ELSE
                               l_hours    := null;
	                    END IF;

                            hr_utility.set_location(l_package||l_procedure,224);
	                    l_run_val  := pay_balance_pkg.get_value
	                                  (get_defined_bal(
                                              to_number(l_element_information10),
		  	                      g_run_dimension_id),
		                              run_actions_tab(i).aaid);
                            hr_utility.set_location(l_package||l_procedure,225);
                         END IF;
	                 hr_utility.trace('Hours Val : ' || l_hours);
	                 hr_utility.trace('Run Val  : ' || l_run_val);

                         get_position_name(l_rep_name,l_found, l_pos);
                         IF l_found = FALSE THEN
                            l_pos := p_earn_tab.COUNT + 1;
                            p_earn_tab(l_pos).rep_name := l_rep_name;
                            p_earn_tab(l_pos).hour_val := l_hours;
                            p_earn_tab(l_pos).cur_val  := l_run_val;
                            p_earn_tab(l_pos).ytd_val  := 0;
                         ELSE
                            p_earn_tab(l_pos).hour_val
                                     := p_earn_tab(l_pos).hour_val + l_hours;
                            p_earn_tab(l_pos).cur_val
                                     := p_earn_tab(l_pos).cur_val + l_run_val;
		            p_earn_tab(l_pos).ytd_val :=0;
                         END IF;

		   END LOOP;
	           CLOSE c_get_earn_elements;
               END IF;
            END LOOP;
         END IF;

         hr_utility.set_location(l_package||l_procedure,226);
         IF earnings_elements_tab.COUNT > 0 THEN

	    IF master_actions_tab.COUNT>0 THEN
	       pay_us_balance_view_pkg.set_session_var('RUN','FALSE');
               pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
               pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
               pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
               pay_us_balance_view_pkg.set_session_var('YTD','TRUE');

	       FOR i IN master_actions_tab.FIRST .. master_actions_tab.LAST LOOP
                   IF master_actions_tab.exists(i) THEN

		      hr_utility.trace('Master Action  : ' || master_actions_tab(i).aaid);
                      hr_utility.set_location(l_package||l_procedure,230);

                      FOR j IN earnings_elements_tab.first..earnings_elements_tab.last LOOP
	 	          IF earnings_elements_tab.exists(j) and
		             earnings_elements_tab(j).element_information10 is not null THEN
	                     hr_utility.set_location(l_package||l_procedure,240);

	                     l_rep_name := earnings_elements_tab(j).element_reporting_name;
	                     l_hours    := null;
                             l_ytd_val  := pay_balance_pkg.get_value
	                                   (get_defined_bal(
                                             to_number(earnings_elements_tab(j).element_information10),
			                     g_ytd_dimension_id),
		                             master_actions_tab(i).aaid);
                             hr_utility.set_location(l_package||l_procedure,254);

	                     get_position_name(l_rep_name,l_found, l_pos);
 	                     IF l_found = TRUE THEN
 	                        p_earn_tab(l_pos).ytd_val := p_earn_tab(l_pos).ytd_val + l_ytd_val;
	                     ELSE
   		                l_pos := p_earn_tab.count+1 ;
		                p_earn_tab(l_pos).rep_name := l_rep_name;
   		                p_earn_tab(l_pos).cur_val  := 0;
   		                p_earn_tab(l_pos).hour_val := 0;
   		                p_earn_tab(l_pos).ytd_val  := l_ytd_val;
 	                    END IF;
		          END IF;
                      END LOOP;
                   END IF;
               END LOOP;
               hr_utility.set_location(l_package||l_procedure,150);
            END IF;
         END IF;
      END IF;

   ELSE    -- SOE for Run is viewed

      IF p_balance_status = 'Y' THEN

         hr_utility.set_location(l_package||l_procedure,160);
         pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
         pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
         pay_us_balance_view_pkg.set_session_var('YTD','TRUE');
         earnings_elements_tab.delete;
         p_earn_tab.delete;

         OPEN c_get_pay_rb_elements(p_assignment_action_id);
         LOOP
            FETCH c_get_pay_rb_elements INTO l_ytd_val
                                            ,l_rep_name
                                            ,l_run_val
                                            ,l_hours
	                                    ,l_element_type_id;
            EXIT WHEN c_get_pay_rb_elements%NOTFOUND;

            earnings_elements_tab(l_element_type_id).element_reporting_name := l_rep_name ;
            earnings_elements_tab(l_element_type_id).element_information10  := null;
            earnings_elements_tab(l_element_type_id).element_information12  := null;
            earnings_elements_tab(l_element_type_id).business_group_id      := null;
 	    earnings_elements_tab(l_element_type_id).classification_name    := null;

	    get_position_name(l_rep_name,l_found, l_pos);

            hr_utility.set_location(l_package||l_procedure,40);
	    IF l_found = FALSE THEN
               l_pos := p_earn_tab.COUNT + 1;
               p_earn_tab(l_pos).rep_name := l_rep_name;
               p_earn_tab(l_pos).hour_val := l_hours;
               p_earn_tab(l_pos).cur_val  := l_run_val;
	       p_earn_tab(l_pos).ytd_val  := l_ytd_val;
            ELSE
               p_earn_tab(l_pos).hour_val := p_earn_tab(l_pos).hour_val + l_hours;
               p_earn_tab(l_pos).cur_val  := p_earn_tab(l_pos).cur_val + l_run_val;
	       p_earn_tab(l_pos).ytd_val  := p_earn_tab(l_pos).ytd_val + l_ytd_val;
            END IF;
         END LOOP;
         CLOSE c_get_pay_rb_elements;
         hr_utility.set_location(l_package||l_procedure,170);
      END IF;

      IF p_balance_status <> 'Y' THEN
         hr_utility.set_location(l_package||l_procedure,200);

         OPEN c_get_pay_action_details(p_assignment_action_id);
         FETCH c_get_pay_action_details INTO l_assignment_id
	                                    ,l_assignment_action_id
	                                    ,l_date_earned
	                                    ,l_tax_unit_id
					    ,l_date_paid;
         CLOSE c_get_pay_action_details;
         hr_utility.set_location(l_package||l_procedure,210);

         OPEN c_get_earn_elements(l_date_paid,l_assignment_action_id); -- Saurabh
         LOOP
            FETCH c_get_earn_elements INTO l_element_type_id
	                                  ,l_element_reporting_name
	                                  ,l_element_information10
	                                  ,l_element_information12
	                                  ,l_business_group_id
                                          ,l_classification_name
                                          ,l_processing_priority;
		  hr_utility.trace(' SG l_element_type_id : ' || l_element_type_id );
		  hr_utility.trace(' SG l_element_reporting_name : ' || l_element_reporting_name );
		  hr_utility.trace(' SG l_element_information10 : ' || l_element_information10 );
		  hr_utility.trace(' SG l_element_information12 : ' || l_element_information12 );
		  hr_utility.trace(' SG l_business_group_id : ' || l_business_group_id );
		  hr_utility.trace(' SG l_classification_name : ' || l_classification_name );
		  hr_utility.trace(' SG l_processing_priority : ' || l_processing_priority );
	    EXIT WHEN c_get_earn_elements%NOTFOUND;
            hr_utility.set_location(l_package||l_procedure,220);
	    IF earnings_elements_tab.count > 0 THEN

	       hr_utility.set_location(l_package||l_procedure,230);
	       IF earnings_elements_tab.exists(l_element_type_id) THEN
	          hr_utility.trace('The element already exists in PLSQL table');
	       ELSE
	          earnings_elements_tab(l_element_type_id).element_reporting_name
                             := l_element_reporting_name ;
                  earnings_elements_tab(l_element_type_id).element_information10
                             := l_element_information10;
	          earnings_elements_tab(l_element_type_id).element_information12
                             := l_element_information12;
	          earnings_elements_tab(l_element_type_id).business_group_id
                             := l_business_group_id;
                  earnings_elements_tab(l_element_type_id).classification_name
                             := l_classification_name;
	        END IF;
	    ELSE
	        earnings_elements_tab(l_element_type_id).element_reporting_name
                             := l_element_reporting_name ;
                earnings_elements_tab(l_element_type_id).element_information10
                             := l_element_information10;
                earnings_elements_tab(l_element_type_id).element_information12
                             := l_element_information12;
	        earnings_elements_tab(l_element_type_id).business_group_id
                             := l_business_group_id;
 	        earnings_elements_tab(l_element_type_id).classification_name
                             := l_classification_name;
	     END IF;
--bugno 4743188
                  IF earnings_elements_tab(l_element_type_id).classification_name
                                                 = 'Non-payroll Payments' THEN
                      hr_utility.set_location(l_package||l_procedure,240);

		      l_rep_name := earnings_elements_tab(l_element_type_id).element_reporting_name;
	              l_hours    := null;
	              l_run_val  := pay_balance_pkg.get_value
	                                   (get_defined_bal(earnings_elements_tab(l_element_type_id).element_information10,
			                    g_run_dimension_id),
		                            p_assignment_action_id);

	              l_ytd_val  := pay_balance_pkg.get_value
	                                   (get_defined_bal(earnings_elements_tab(l_element_type_id).element_information10,
			                    g_ytd_dimension_id),
		                            p_assignment_action_id);
                   ELSE
                      hr_utility.set_location(l_package||l_procedure,250);
	              l_rep_name := earnings_elements_tab(l_element_type_id).element_reporting_name;
	              hr_utility.set_location(l_package||l_procedure ,251);

	              IF earnings_elements_tab(l_element_type_id).element_information12 is not null THEN
	                 hr_utility.trace('Info12 : ' ||
                                          earnings_elements_tab(l_element_type_id).element_information12 ||
		                          'g_run_dimension_id : ' || g_run_dimension_id);
	                 l_hours    := pay_balance_pkg.get_value
	                                      (get_defined_bal(to_number(earnings_elements_tab(l_element_type_id).element_information12),
                                              g_run_dimension_id),
                                              p_assignment_action_id);
	              ELSE
                         l_hours    := null;
	              END IF;

                      hr_utility.set_location(l_package||l_procedure,252);
                      hr_utility.trace('Info10 : ' ||
                                       earnings_elements_tab(l_element_type_id).element_information10 ||
                                       'g_run_dimension_id : ' || g_run_dimension_id);

	              l_run_val  := pay_balance_pkg.get_value
                                           (get_defined_bal(to_number(earnings_elements_tab(l_element_type_id).element_information10),
			                    g_run_dimension_id),
		                            p_assignment_action_id);

                      hr_utility.set_location(l_package||l_procedure,254);
	              l_ytd_val  := pay_balance_pkg.get_value
	                                   (get_defined_bal(to_number(earnings_elements_tab(l_element_type_id).element_information10),
			                    g_ytd_dimension_id),
		                            p_assignment_action_id);
                      hr_utility.set_location(l_package||l_procedure,256);
                   END IF;

	           get_position_name(l_rep_name,l_found, l_pos);

	          IF l_found = TRUE THEN
   	              hr_utility.set_location(l_package||l_procedure,260);
		      p_earn_tab(l_pos).ytd_val  := p_earn_tab(l_pos).ytd_val  + l_ytd_val;
                      p_earn_tab(l_pos).cur_val  := p_earn_tab(l_pos).cur_val  + l_run_val;
                      p_earn_tab(l_pos).hour_val := p_earn_tab(l_pos).hour_val + l_hours;
                   ELSE
   	              hr_utility.set_location(l_package||l_procedure,261);
   	              l_pos := p_earn_tab.count + 1;
		      p_earn_tab(l_pos).rep_name := l_rep_name;
		      p_earn_tab(l_pos).ytd_val  := l_ytd_val;
                      p_earn_tab(l_pos).cur_val  := l_run_val;
                      p_earn_tab(l_pos).hour_val := l_hours;
                   END IF;
       ---bug 4743188


         END LOOP;
         CLOSE c_get_earn_elements;
         hr_utility.set_location(l_package||l_procedure,270);
      /* --comments start bug 4743188
         IF earnings_elements_tab.count > 0 THEN
            FOR i IN earnings_elements_tab.first..earnings_elements_tab.last LOOP
	        IF earnings_elements_tab.exists(i) and
                   earnings_elements_tab(i).element_information10 is not null THEN

	           IF earnings_elements_tab(i).classification_name
                                                 = 'Non-payroll Payments' THEN
	              l_rep_name := earnings_elements_tab(i).element_reporting_name;
	              l_hours    := null;
	              l_run_val  := pay_balance_pkg.get_value
	                                   (get_defined_bal(earnings_elements_tab(i).element_information10,
			                    g_run_dimension_id),
		                            p_assignment_action_id);

	              l_ytd_val  := pay_balance_pkg.get_value
	                                   (get_defined_bal(earnings_elements_tab(i).element_information10,
			                    g_ytd_dimension_id),
		                            p_assignment_action_id);
                   ELSE
                      hr_utility.set_location(l_package||l_procedure,250);
	              l_rep_name := earnings_elements_tab(i).element_reporting_name;
	              hr_utility.set_location(l_package||l_procedure ,251);

	              IF earnings_elements_tab(i).element_information12 is not null THEN
	                 hr_utility.trace('Info12 : ' ||
                                          earnings_elements_tab(i).element_information12 ||
		                          'g_run_dimension_id : ' || g_run_dimension_id);
	                 l_hours    := pay_balance_pkg.get_value
	                                      (get_defined_bal(to_number(earnings_elements_tab(i).element_information12),
                                              g_run_dimension_id),
                                              p_assignment_action_id);
	              ELSE
                         l_hours    := null;
	              END IF;

                      hr_utility.set_location(l_package||l_procedure,252);
                      hr_utility.trace('Info10 : ' ||
                                       earnings_elements_tab(i).element_information10 ||
                                       'g_run_dimension_id : ' || g_run_dimension_id);

	              l_run_val  := pay_balance_pkg.get_value
                                           (get_defined_bal(to_number(earnings_elements_tab(i).element_information10),
			                    g_run_dimension_id),
		                            p_assignment_action_id);

                      hr_utility.set_location(l_package||l_procedure,254);
	              l_ytd_val  := pay_balance_pkg.get_value
	                                   (get_defined_bal(to_number(earnings_elements_tab(i).element_information10),
			                    g_ytd_dimension_id),
		                            p_assignment_action_id);
                      hr_utility.set_location(l_package||l_procedure,256);
                   END IF;

	           get_position_name(l_rep_name,l_found, l_pos);
	           hr_utility.set_location(l_package||l_procedure,260);
	           IF l_found = TRUE THEN
	              p_earn_tab(l_pos).ytd_val  := p_earn_tab(l_pos).ytd_val  + l_ytd_val;
                      p_earn_tab(l_pos).cur_val  := p_earn_tab(l_pos).cur_val  + l_run_val;
                      p_earn_tab(l_pos).hour_val := p_earn_tab(l_pos).hour_val + l_hours;
                   ELSE
   	              l_pos := p_earn_tab.count + 1;
		      p_earn_tab(l_pos).rep_name := l_rep_name;
		      p_earn_tab(l_pos).ytd_val  := l_ytd_val;
                      p_earn_tab(l_pos).cur_val  := l_run_val;
                      p_earn_tab(l_pos).hour_val := l_hours;
                   END IF;
	        END IF;
	    END LOOP;
         END IF; */-- comments end
      END IF;
      hr_utility.set_location(l_package||l_procedure,248);
   END IF;--run/prepayment check

 EXCEPTION
    WHEN others THEN
      hr_utility.set_location(l_package||l_procedure,290);
      raise_application_error(-20101, 'Error in ' || l_package||l_procedure|| ' - ' || sqlerrm);
      raise;
 END populate_earn_bal;



 /*****************************************************************************
   Name      : populate_fed_balance
   Purpose   : This procedure populates a PL/SQL table with all the federal deduction
               elements for SOE form.

 *****************************************************************************/
 PROCEDURE populate_fed_balance(p_assignment_action_id in number,
                                p_balance_status       in varchar2,
                                p_action_type          in varchar2,
				p_eic_curr_val         out nocopy number,
				p_eic_ytd_val          out nocopy number,
				p_dedn_tab             out nocopy dedn)
 IS
   -- Declare Local Variables
   l_count         number;
   l_run_amount    number;
   l_curr_amount   number;
   l_ytd_amount    number;
   l_tax_type      pay_us_fed_taxes_v.tax_type_code%TYPE;

   start_cnt number;
   end_cnt   number;
   i         number :=0;
   j         number :=0;
   k         number :=0;
   l_found   boolean;
   l_pos     number;

   l_rep_name      pay_us_fed_taxes_v.user_reporting_name%TYPE;
   l_run_val       number;
   l_ytd_val       number;
   l_procedure     varchar2(20) ;

   /***
   ** Start Federal Balances Cursors when balances are not valid for eBRA **
   ***/

   -- added cursor  to get federal balances from run results
   CURSOR get_valid_taxes_fed_rr(l_assignment_action_id  number)
   IS
   SELECT user_reporting_name,
 	  run_val,
 	  ytd_val,
	  tax_type_code
     FROM pay_us_fed_taxes_v
    WHERE ee_or_er_code		= 'EE'
     AND  balance_category_code in ('WITHHELD','ADVANCED')
     AND  assignment_action_id = l_assignment_action_id
   ORDER BY  user_reporting_name;

   -- Cursor to get Run Values
   CURSOR c_get_pre_fed_run_rr(cp_run_action_id NUMBER)
   IS
   select pt.user_reporting_name
         ,sum(pt.run_val)
         ,pt.tax_type_code
    from  pay_us_fed_taxes_v pt
   where  pt.ee_or_er_code	   = 'EE'
     and  pt.balance_category_code in ('WITHHELD','ADVANCED')
     and  pt.assignment_action_id  = cp_run_action_id
     group by pt.user_reporting_name,tax_type_code
     order by user_reporting_name;


   -- Cursor to get YTD Value
   CURSOR c_get_pre_fed_ytd_rr(cp_master_action_id NUMBER)
   IS
   select sum(pt.ytd_val) ,
          pt.user_reporting_name,
   	  tax_type_code
    from  pay_us_fed_taxes_v pt
   where  pt.ee_or_er_code	   = 'EE'
     and  pt.balance_category_code in ('WITHHELD','ADVANCED')
     and  pt.assignment_action_id   = cp_master_action_id
     group by pt.user_reporting_name,tax_type_code ;

   /***
   ***End Federal Balances Cursors when balances are not valid for eBRA***
   ***/

   /***
   ***Start Federal Balances Cursors when balances are valid for eBRA***
   ***/

   -- Cursor to get  federal balances from run balances
   CURSOR get_valid_taxes_fed_rb(l_assignment_action_id  number)
   IS
   SELECT user_reporting_name,
 	  run_val,
 	  ytd_val,
	  tax_type_code
     FROM pay_us_fed_taxes_rbr_v
    WHERE ee_or_er_code		= 'EE'
     AND  balance_category_code in ('WITHHELD','ADVANCED')
     AND  assignment_action_id  = l_assignment_action_id
   order by user_reporting_name;

   -- Cursor to get Run Values
   CURSOR c_get_pre_fed_run_rb(cp_run_action_id NUMBER)
   IS
   select pt.user_reporting_name
        , sum(pt.run_val)
         ,pt.tax_type_code
    from  pay_us_fed_taxes_rbr_v pt
   where  pt.ee_or_er_code	   = 'EE'
     and  pt.balance_category_code in ('WITHHELD','ADVANCED')
     and  pt.assignment_action_id  = cp_run_action_id
     group by pt.user_reporting_name,tax_type_code
   order by user_reporting_name;

   -- Cursor to get YTD Value
   CURSOR c_get_pre_fed_ytd_rb(cp_master_action_id NUMBER)
   IS
   select sum(pt.ytd_val) run_val,
   	  pt.user_reporting_name,
          tax_type_code
    from  pay_us_fed_taxes_rbr_v pt
   where  pt.ee_or_er_code	   = 'EE'
     and  pt.balance_category_code in ('WITHHELD','ADVANCED')
     and  pt.assignment_action_id  =  cp_master_action_id
   group by pt.user_reporting_name,tax_type_code
   order by user_reporting_name;

   /***
   ***Start Federal Balances Cursors when balances are valid for eBRA***
   ***/

   l_master_action_id  number;

   -- Procedure to get the position of the federal deductions in the plsql table
   -- If the element exists it will return the position otherwise will return
   -- new index where new element will be stored.
   PROCEDURE get_position_fed (p_rep_name       in pay_us_fed_taxes_v.user_reporting_name%TYPE ,
 		  	       p_tax_type_code  in pay_us_fed_taxes_v.tax_type_code%type,
                               p_found          out nocopy boolean,
                               p_index          out nocopy number)
   IS
     st_cnt    number;
     ed_cnt   number;
     p_cnt     number;

   BEGIN
     p_found := FALSE;
     p_index := 0;

     p_cnt :=  fed_tab.COUNT;

     if p_cnt = 0 then
         p_found := FALSE;
         p_index := 0;
         return;
     else
         st_cnt :=  fed_tab.FIRST;
         ed_cnt :=  fed_tab.LAST;
         FOR i IN st_cnt.. ed_cnt LOOP
           IF fed_tab.exists(i) THEN
            IF p_rep_name = fed_tab(i).rep_name
            and p_tax_type_code=fed_tab(i).tax_type  then
               p_index := i;
               p_found := TRUE;
               return;
             END IF;
	   END IF;
         END LOOP;
     end if;

   END; /* get_position_fed */

 BEGIN

   -- Start the Code : Need to Consider the Secondary Assignments Also--
   -- The code change is part of the eBRA Enhancement of SOE Form-----
   -- Check Balance Status
  l_procedure     := 'populate_fed_balance';

   hr_utility.set_location(l_package||l_procedure,10);
   -- delete the federal and deduction plsql tables
   fed_tab.delete;

   hr_utility.set_location(l_package||l_procedure,20);
   IF p_action_type in ('P','U') THEN

     hr_utility.set_location(l_package||l_procedure,30);
     IF p_balance_status  = 'Y' THEN

      IF run_actions_tab.COUNT>0 THEN
        start_cnt := run_actions_tab.FIRST;
        end_cnt   := run_actions_tab.LAST;
        j := 0;
        pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
        pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
        pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
        pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
 	pay_us_balance_view_pkg.set_session_var('YTD','FALSE');

 	hr_utility.set_location(l_package||l_procedure,40);
	FOR i IN start_cnt..end_cnt LOOP
          IF run_actions_tab.exists(i) THEN
            OPEN c_get_pre_fed_run_rb(run_actions_tab(i).aaid);
 	      LOOP
 	        FETCH c_get_pre_fed_run_rb
                INTO  l_rep_name
                     ,l_run_val
                     ,l_tax_type;
 	        EXIT WHEN c_get_pre_fed_run_rb%NOTFOUND;

		hr_utility.set_location(l_package||l_procedure,50);
 	        get_position_fed(l_rep_name,l_tax_type,l_found, l_pos);

 	        hr_utility.set_location(l_package||l_procedure,60);
 	        IF l_found = FALSE THEN
 		   j := fed_tab.COUNT + 1;
              	   fed_tab(j).rep_name := l_rep_name;
 		   fed_tab(j).tax_type := l_tax_type;
 		   fed_tab(j).cur_val := l_run_val;
 		   fed_tab(j).ytd_val :=0;
 	        ELSE
 		   fed_tab(l_pos).cur_val := fed_tab(l_pos).cur_val + l_run_val;
 		   fed_tab(l_pos).ytd_val := 0;
  	        END IF;
		hr_utility.set_location(l_package||l_procedure,70);
    	      END LOOP;
 	    CLOSE  c_get_pre_fed_run_rb;
     	  END IF;
	  hr_utility.set_location(l_package||l_procedure,80);
        END LOOP;
       END IF;
	hr_utility.set_location(l_package||l_procedure,90);
 	IF fed_tab.COUNT > 0 THEN

         IF master_actions_tab.COUNT>0 THEN
          start_cnt:=master_actions_tab.FIRST;
          end_cnt:=master_actions_tab.LAST;

	  pay_us_balance_view_pkg.set_session_var('RUN','FALSE');
          pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
          pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
          pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
          pay_us_balance_view_pkg.set_session_var('YTD','TRUE');

	  hr_utility.set_location(l_package||l_procedure,100);
          FOR i IN start_cnt..end_cnt LOOP
             IF master_actions_tab.exists(i) THEN
 	      OPEN c_get_pre_fed_ytd_rb(master_actions_tab(i).aaid);
                LOOP
		  FETCH c_get_pre_fed_ytd_rb into l_ytd_val,l_rep_name,l_tax_type;
		  EXIT WHEN c_get_pre_fed_ytd_rb%NOTFOUND;
 	          hr_utility.set_location(l_package||l_procedure,110);
 	          get_position_fed(l_rep_name,l_tax_type,l_found, l_pos);

 	          IF l_found = TRUE THEN
           	    fed_tab(l_pos).ytd_val := fed_tab(l_pos).ytd_val + l_ytd_val;
		  ELSE
   		      k := fed_tab.count+1;
		      fed_tab(k).rep_name :=l_rep_name;
   		      fed_tab(k).cur_val  :=0;
   		      fed_tab(k).ytd_val  :=l_ytd_val;
          	  END IF;
		  hr_utility.set_location(l_package||l_procedure,120);
        	END LOOP;
              CLOSE c_get_pre_fed_ytd_rb;
     	    END IF;

 	 END LOOP;
 	 hr_utility.set_location(l_package||l_procedure,120);
 	 END IF;
 	END IF;

      ELSE

	hr_utility.set_location(l_package||l_procedure,130);
	IF run_actions_tab.count>0 THEN
          start_cnt := run_actions_tab.FIRST;
 	  end_cnt   := run_actions_tab.LAST;

 	  pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
          pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
          pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
          pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
 	  pay_us_balance_view_pkg.set_session_var('YTD','FALSE');

     	  FOR i IN start_cnt..end_cnt LOOP
 	   OPEN c_get_pre_fed_run_rr(run_actions_tab(i).aaid);

	    LOOP
 	     FETCH c_get_pre_fed_run_rr
 	     INTO  l_rep_name
 	          ,l_run_val
 	          ,l_tax_type;
 	     EXIT WHEN c_get_pre_fed_run_rr%NOTFOUND;

	     hr_utility.set_location(l_package||l_procedure,140);
 	     get_position_fed(l_rep_name,l_tax_type,l_found, l_pos);

 	     IF l_found = FALSE THEN
 	       j := fed_tab.COUNT + 1;
 	       fed_tab(j).rep_name := l_rep_name;
 	       fed_tab(j).tax_type := l_tax_type;
 	       fed_tab(j).cur_val := l_run_val;
 	       fed_tab(j).ytd_val :=0;
 	     ELSE
 	       fed_tab(l_pos).cur_val := fed_tab(l_pos).cur_val + l_run_val;
 	       fed_tab(l_pos).ytd_val := 0;
 	     END IF;
	   hr_utility.set_location(l_package||l_procedure,150);
 	   END LOOP;

	   CLOSE  c_get_pre_fed_run_rr;
          END LOOP;
        END IF;

       hr_utility.set_location(l_package||l_procedure,160);
       IF fed_tab.COUNT > 0 THEN
        IF master_actions_tab.COUNT>0 THEN

         start_cnt:= master_actions_tab.FIRST;
 	 end_cnt:=master_actions_tab.LAST;

 	 hr_utility.set_location(l_package||l_procedure,170);
	 pay_us_balance_view_pkg.set_session_var('RUN','FALSE');
         pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
 	 pay_us_balance_view_pkg.set_session_var('YTD','TRUE');

 	 FOR i IN start_cnt..end_cnt LOOP
 	  IF master_actions_tab.exists(i) THEN
       	   OPEN c_get_pre_fed_ytd_rr(master_actions_tab(i).aaid);

	     LOOP
 	       FETCH c_get_pre_fed_ytd_rr into l_ytd_val,l_rep_name,l_tax_type;
 	       EXIT WHEN c_get_pre_fed_ytd_rr%NOTFOUND;

	       hr_utility.set_location(l_package||l_procedure,180);
 	       get_position_fed(l_rep_name,l_tax_type,l_found, l_pos);

	     	IF l_found = TRUE THEN
 	     	  fed_tab(l_pos).ytd_val := fed_tab(l_pos).ytd_val + l_ytd_val;
		ELSE
   		  k := fed_tab.count+1;
		  fed_tab(k).rep_name :=l_rep_name;
   		  fed_tab(k).cur_val  :=0;
   		  fed_tab(k).ytd_val  :=l_ytd_val;
 	     	END IF;

 	     END LOOP;
	     hr_utility.set_location(l_package||l_procedure,190);
 	   CLOSE c_get_pre_fed_ytd_rr;
 	   END IF;
 	 END LOOP;
 	 END IF;
	 hr_utility.set_location(l_package||l_procedure,200);
       END IF;
     END IF;

   ELSE

    hr_utility.set_location(l_package||l_procedure,210);
    pay_us_balance_view_pkg.set_session_var('YTD','TRUE');
    pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
    pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
    pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
    pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');

    hr_utility.set_location(l_package||l_procedure,220);
    -------------Run Federal Taxes Start-------------------------------
    i := 0;
     IF p_balance_status = 'Y' THEN
       hr_utility.set_location(l_package||l_procedure,230);
       OPEN get_valid_taxes_fed_rb(p_assignment_action_id) ;
       LOOP
          FETCH get_valid_taxes_fed_rb
	  INTO  fed_tab(i).rep_name,
	        fed_tab(i).cur_val,
		fed_tab(i).ytd_val,
		fed_tab(i).tax_type;

          EXIT WHEN get_valid_taxes_fed_rb%NOTFOUND;
	  i := i+1;
        END LOOP;
	hr_utility.set_location(l_package||l_procedure,240);
      CLOSE get_valid_taxes_fed_rb;

     ELSE
       hr_utility.set_location(l_package||l_procedure,250);
       OPEN get_valid_taxes_fed_rr(p_assignment_action_id) ;
       LOOP

          FETCH get_valid_taxes_fed_rr
	  INTO  fed_tab(i).rep_name,
	        fed_tab(i).cur_val,
		fed_tab(i).ytd_val,
		fed_tab(i).tax_type;

          EXIT WHEN get_valid_taxes_fed_rr%NOTFOUND;
	  i := i +1 ;
       END LOOP;
       hr_utility.set_location(l_package||l_procedure,260);
       CLOSE get_valid_taxes_fed_rr;
     END IF;
   END IF;

   -- Populate the values in dedn plsql table for SOE Form
   hr_utility.set_location(l_package||l_procedure,270);
   IF fed_tab.count > 0 THEN

     start_cnt := fed_tab.FIRST;
     end_cnt := fed_tab.LAST;

     hr_utility.set_location(l_package||l_procedure,280);
     FOR i IN start_cnt..end_cnt LOOP
       IF fed_tab.exists(i) THEN
	 fed_tab(i).rep_name := REPLACE(fed_tab(i).rep_name, 'EE ', '');

         IF fed_tab(i).tax_type = 'EIC' THEN
	   fed_tab(i).cur_val := -1 * fed_tab(i).cur_val;
	   fed_tab(i).ytd_val := -1 * fed_tab(i).ytd_val;

	   p_eic_curr_val   := fed_tab(i).cur_val;
           -- Bug 1786497
           p_eic_ytd_val    := fed_tab(i).ytd_val;

      	 END IF;
	 hr_utility.set_location(l_package||l_procedure,290);
         p_dedn_tab(i).rep_name := fed_tab(i).rep_name;
         p_dedn_tab(i).cur_val  := fed_tab(i).cur_val;
         p_dedn_tab(i).ytd_val  := fed_tab(i).ytd_val ;
        END IF;
	hr_utility.set_location(l_package||l_procedure,300);
      END LOOP;
   END IF;

 EXCEPTION
    WHEN others THEN
       hr_utility.set_location(l_package||l_procedure,310);
       raise_application_error(-20101, 'Error in ' ||l_package||l_procedure || ' - ' || sqlerrm);
 END populate_fed_balance;




 /*****************************************************************************
   Name      : populate_state_balance
   Purpose   : This procedure populates a PL/SQL table with all the state deductions
               elements for SOE form.
 *****************************************************************************/
 PROCEDURE populate_state_balance(p_assignment_action_id in number,
                                  p_balance_status       in varchar2,
                                  p_action_type          in varchar2,
                                  p_steic_curr_val         out nocopy number,
				                  p_steic_ytd_val          out nocopy number,
				  p_dedn_tab             out nocopy dedn)
 IS

   -- Declare Local Variables
   l_juris_code    pay_us_state_taxes_v.jurisdiction_code%type;

   l_count         number;
   l_run_amount    number;
   l_curr_amount   number;
   l_ytd_amount    number;
   l_tax_type      pay_us_state_taxes_v.tax_type_code%type;

   start_cnt number;
   end_cnt   number;
   i         number := 0;
   j         number := 0;
   k         number := 0;
   l_found boolean;
   l_pos number;

   l_ytd_value         number;
   l_master_action_id  number;
   l_state_abbrev      pay_us_state_taxes_v.state_abbrev%type;

   l_rep_name      pay_us_state_taxes_v.user_reporting_name%TYPE;
   l_run_val       number;
   l_ytd_val       number;
   l_procedure     varchar2(22);

   /***
   ***Start State Balances Cursors when balances are not valid for eBRA***
   ***/

   -- Cursor to get  state balances from run results
   CURSOR get_valid_taxes_state_rr(l_assignment_action_id number)
   IS
   select state_abbrev,
 	  user_reporting_name,
 	  run_val,
 	  tax_type_code,
          jurisdiction_code,
 	  ytd_val
     from pay_us_state_taxes_v
    where ee_or_er_code	       = 'EE'
      and assignment_action_id = l_assignment_action_id
     order by user_reporting_name;

   -- Cursor to get Run Values
   CURSOR c_get_pre_state_run_rr(cp_run_action_id NUMBER)
   IS
   select state_abbrev,
 	  user_reporting_name,
 	  sum(run_val),
 	  tax_type_code
     from pay_us_state_taxes_v pt
    where pt.ee_or_er_code	  = 'EE'
      and pt.assignment_action_id = cp_run_action_id
     group by user_reporting_name, state_abbrev,tax_type_code
     order by user_reporting_name;

   -- Cursor to get YTD Value
   CURSOR c_get_pre_state_ytd_rr(cp_master_action_id NUMBER)
   IS
   select sum(pt.ytd_val),
          user_reporting_name,
          tax_type_code,
   	  state_abbrev
     from pay_us_state_taxes_v pt
    where pt.ee_or_er_code		= 'EE'
      and pt.assignment_action_id = cp_master_action_id
     group by user_reporting_name, state_abbrev,tax_type_code
     order by user_reporting_name;

   /***
   ***End State Balances Cursors when balances are not valid for eBRA***
   ***/


   /***
   ***Start State Balances Cursors when balances are valid for eBRA***
   ***/

   -- Cursor to get  state balances from run balances
   CURSOR get_valid_taxes_state_rb(l_assignment_action_id number)
   IS
   select state_abbrev,
 	  user_reporting_name,
 	  run_val,
 	  tax_type_code,
          jurisdiction_code,
 	  ytd_val
     from pay_us_state_taxes_rbr_v
    where ee_or_er_code	       = 'EE'
      and assignment_action_id = l_assignment_action_id
   order by user_reporting_name;

   --Cursor to get Run Values
   CURSOR c_get_pre_state_run_rb(cp_run_action_id NUMBER)
   IS
   select state_abbrev,
 	  user_reporting_name,
  	  sum(run_val),
  	  tax_type_code
     from pay_us_state_taxes_rbr_v pt
    where pt.ee_or_er_code	  = 'EE'
      and pt.assignment_action_id = cp_run_action_id
      group by user_reporting_name, state_abbrev,tax_type_code
      order by user_reporting_name;

   -- Cursor to get YTD Value
   CURSOR c_get_pre_state_ytd_rb(cp_master_action_id NUMBER)
   IS
   select sum(pt.ytd_val)
         ,user_reporting_name
         ,tax_type_code
  	 ,state_abbrev
    from pay_us_state_taxes_rbr_v pt
   where pt.ee_or_er_code	 = 'EE'
     and pt.assignment_action_id = cp_master_action_id
     group by user_reporting_name, state_abbrev,tax_type_code
     order by user_reporting_name;

   /***
   ***Start State Balances Cursors when balances are valid for eBRA***
   ***/

   -- Procedure to get the position of the state deductions in the plsql table
   -- If the element exists it will return the position otherwise will return
   -- new index where new element will be stored. The reporting name with the
   -- same state name are grouped to get the final deduction value.
   PROCEDURE get_position_state (p_rep_name      in pay_us_state_taxes_v.user_reporting_name%TYPE ,
  	 		         p_tax_type_code in pay_us_state_taxes_v.user_reporting_name%TYPE ,
 			         p_state_abbrev  in pay_us_state_taxes_v.state_abbrev%type,
                                 p_found         out nocopy boolean,
                                 p_index         out nocopy number)
   IS

     st_cnt    number;
     ed_cnt   number;
     p_cnt     number;

   BEGIN
     p_found := FALSE;
     p_index := 0;

     p_cnt :=  state_tab.COUNT;

     IF p_cnt = 0 THEN

         p_found := FALSE;
         p_index := 0;
         return;

     ELSE
         st_cnt :=  state_tab.FIRST;
         ed_cnt :=  state_tab.LAST;
         FOR i in st_cnt.. ed_cnt LOOP
           IF state_tab.exists(i) THEN
            IF p_rep_name = state_tab(i).rep_name
               and p_tax_type_code=state_tab(i).tax_type
               and p_state_abbrev=state_tab(i).state_abbrev  THEN

               p_index := i;
               p_found := TRUE;
               return;

            END IF;
           END IF;
         END LOOP;
      END IF;

   END; /* get_position_state */

 BEGIN

   -- Start the Code : Need to Consider the Secondary Assignments Also--
   -- The code change is part of the eBRA Enhancement of SOE Form-----
   -- Check Balance Status
   l_procedure      := 'populate_state_balance';
   hr_utility.set_location(l_package||l_procedure,10);
   -- Delete the state table
   state_tab.delete;

   IF p_action_type = 'P' OR p_action_type = 'U' THEN

     --------State----------------
     hr_utility.set_location(l_package||l_procedure,20);
     IF p_balance_status  = 'Y' THEN
      IF run_actions_tab.COUNT>0 THEN

       start_cnt := run_actions_tab.FIRST;
       end_cnt   := run_actions_tab.LAST;

       pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
       pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
       pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
       pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
       pay_us_balance_view_pkg.set_session_var('YTD','FALSE');

       hr_utility.set_location(l_package||l_procedure,30);

       FOR i IN start_cnt..end_cnt LOOP
        IF run_actions_tab.exists(i) THEN
         OPEN c_get_pre_state_run_rb(run_actions_tab(i).aaid);
           LOOP
             FETCH c_get_pre_state_run_rb
             INTO  l_state_abbrev,
 	           l_rep_name,
 	   	   l_run_val,
 		   l_tax_type;
    	     EXIT WHEN c_get_pre_state_run_rb%NOTFOUND;

	     hr_utility.set_location(l_package||l_procedure,40);
 	     get_position_state(l_rep_name,l_tax_type,l_state_abbrev,l_found, l_pos);

  	     IF l_found = FALSE THEN
  	       j := state_tab.COUNT + 1;
               state_tab(j).rep_name := l_rep_name;
 	       state_tab(j).tax_type := l_tax_type;
 	       state_tab(j).state_abbrev := l_state_abbrev;
 	       state_tab(j).cur_val := l_run_val;
 	       state_tab(j).ytd_val :=0;
             ELSE
 	       state_tab(l_pos).cur_val := state_tab(l_pos).cur_val + l_run_val;
 	       state_tab(l_pos).ytd_val := 0;
             END IF;
           END LOOP;
	   hr_utility.set_location(l_package||l_procedure,50);
 	 CLOSE  c_get_pre_state_run_rb;
 	 END IF;
       END LOOP;
       END IF;
       hr_utility.set_location(l_package||l_procedure,60);

       IF state_tab.COUNT > 0 THEN
        IF master_actions_tab.COUNT>0 THEN
         start_cnt:=master_actions_tab.FIRST;
 	 end_cnt:=master_actions_tab.LAST;

 	 pay_us_balance_view_pkg.set_session_var('RUN','FALSE');
         pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
 	 pay_us_balance_view_pkg.set_session_var('YTD','TRUE');

 	 hr_utility.set_location(l_package||l_procedure,70);
	 FOR i IN start_cnt..end_cnt LOOP
	  IF master_actions_tab.exists(i) THEN
       	   OPEN c_get_pre_state_ytd_rb(master_actions_tab(i).aaid);
 	     LOOP
 	       FETCH c_get_pre_state_ytd_rb into l_ytd_val,l_rep_name,l_tax_type,l_state_abbrev;
 	       EXIT WHEN c_get_pre_state_ytd_rb%NOTFOUND;

 	       hr_utility.set_location(l_package||l_procedure,80);
	       get_position_state(l_rep_name,l_tax_type,l_state_abbrev,l_found, l_pos);

 	       IF l_found = TRUE THEN
 	    	  state_tab(l_pos).ytd_val := state_tab(l_pos).ytd_val + l_ytd_val;
	       ELSE
   		  k := state_tab.count+1;
		  state_tab(k).rep_name :=l_rep_name;
   		  state_tab(k).cur_val  :=0;
		  state_tab(k).state_abbrev := l_state_abbrev;
		  state_tab(k).tax_type := l_tax_type;
   		  state_tab(k).ytd_val  :=l_ytd_val;
 	       END IF;
 	     END LOOP;
 	   CLOSE c_get_pre_state_ytd_rb;
 	  END IF;
	   hr_utility.set_location(l_package||l_procedure,90);
 	 END LOOP;
       END IF;
       END IF;


     ELSE -- Status Not Valid
      hr_utility.set_location(l_package||l_procedure,100);
      IF run_actions_tab.COUNT>0 THEN
       start_cnt := run_actions_tab.FIRST;
       end_cnt   := run_actions_tab.LAST;

       pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
       pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
       pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
       pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
       pay_us_balance_view_pkg.set_session_var('YTD','FALSE');

       FOR i IN start_cnt..end_cnt LOOP
        IF run_actions_tab.exists(i) THEN
 	 OPEN c_get_pre_state_run_rr(run_actions_tab(i).aaid);
 	   LOOP
 	     FETCH c_get_pre_state_run_rr
 	     INTO  l_state_abbrev,
 	           l_rep_name,
   	    	   l_run_val,
	           l_tax_type;
	     EXIT WHEN c_get_pre_state_run_rr%NOTFOUND;

 	     hr_utility.set_location(l_package||l_procedure,110);
	     get_position_state(l_rep_name,l_tax_type,l_state_abbrev,l_found, l_pos);

             IF l_found = FALSE THEN
 	        j := state_tab.COUNT + 1;
 	  	state_tab(j).rep_name := l_rep_name;
 	  	state_tab(j).tax_type := l_tax_type;
 	  	state_tab(j).state_abbrev := l_state_abbrev;
 	  	state_tab(j).cur_val := l_run_val;
 	  	state_tab(j).ytd_val :=0;
 	     ELSE
 	        state_tab(l_pos).cur_val := state_tab(l_pos).cur_val + l_run_val;
 	  	state_tab(l_pos).ytd_val := 0;
 	     END IF;
 	   END LOOP;
	   hr_utility.set_location(l_package||l_procedure,120);
 	 CLOSE  c_get_pre_state_run_rr;
        END IF;
       END LOOP;
      END IF;
      hr_utility.set_location(l_package||l_procedure,130);

       IF state_tab.COUNT > 0 THEN
 	hr_utility.set_location(l_package||l_procedure,140);
 	IF master_actions_tab.COUNT>0 THEN
         start_cnt:=master_actions_tab.FIRST;
         end_cnt:=master_actions_tab.LAST;

         pay_us_balance_view_pkg.set_session_var('RUN','FALSE');
         pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
         pay_us_balance_view_pkg.set_session_var('YTD','TRUE');

         FOR i IN start_cnt..end_cnt LOOP
          IF master_actions_tab.exists(i) THEN
   	   OPEN c_get_pre_state_ytd_rr(master_actions_tab(i).aaid);
 	    LOOP
 	      FETCH c_get_pre_state_ytd_rr
	      INTO l_ytd_val,
	           l_rep_name,
		   l_tax_type,
		   l_state_abbrev;
 	      EXIT WHEN c_get_pre_state_ytd_rr%NOTFOUND;

	      hr_utility.set_location(l_package||l_procedure,150);
	      get_position_state(l_rep_name,l_tax_type,l_state_abbrev,l_found, l_pos);

              IF l_found = TRUE THEN
 	   	  state_tab(l_pos).ytd_val := state_tab(l_pos).ytd_val + l_ytd_val;
	      ELSE
   	          k := state_tab.count+1;
	          state_tab(k).rep_name :=l_rep_name;
   	          state_tab(k).cur_val  :=0;
	          state_tab(k).state_abbrev := l_state_abbrev;
	          state_tab(k).tax_type := l_tax_type;
   	          state_tab(k).ytd_val  :=l_ytd_val;
 	      END IF;
   	    END LOOP;
 	  CLOSE c_get_pre_state_ytd_rr;
 	  END IF;
 	 END LOOP;
        END IF;

       END IF;

	hr_utility.set_location(l_package||l_procedure,150);
     -- END IF;

     END IF;

   ELSE -- SOE for Run Action

     hr_utility.set_location(l_package||l_procedure,160);
     pay_us_balance_view_pkg.set_session_var('YTD','TRUE');
     pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
     pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
     pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
     pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');

     -------------Start State Run--------------------------------------
     --State taxes
     --Use run Balances
     i := 0;
     hr_utility.set_location(l_package||l_procedure,170);
     IF p_balance_status = 'Y' THEN
       hr_utility.set_location(l_package||l_procedure,180);
       OPEN get_valid_taxes_state_rb(p_assignment_action_id);
       LOOP
          FETCH get_valid_taxes_state_rb
           INTO	 state_tab(i).state_abbrev
       	       , state_tab(i).rep_name
	       , state_tab(i).cur_val
	       , state_tab(i).tax_type
	       , state_tab(i).juris_code
               , state_tab(i).ytd_val;
          EXIT WHEN get_valid_taxes_state_rb%NOTFOUND;

      	i := i + 1;
       END LOOP;
       hr_utility.set_location(l_package||l_procedure,190);
       CLOSE get_valid_taxes_state_rb;

     --Use Run result
     ELSE
       hr_utility.set_location(l_package||l_procedure,200);
       OPEN get_valid_taxes_state_rr(p_assignment_action_id);
       LOOP
          FETCH get_valid_taxes_state_rr
           INTO	 state_tab(i).state_abbrev
       	       , state_tab(i).rep_name
	       , state_tab(i).cur_val
	       , state_tab(i).tax_type
	       , state_tab(i).juris_code
               , state_tab(i).ytd_val;
          EXIT WHEN get_valid_taxes_state_rr%NOTFOUND;
          i := i + 1;
       END LOOP;
       CLOSE get_valid_taxes_state_rr;
       hr_utility.set_location(l_package||l_procedure,210);
     END IF;
   END IF;
   hr_utility.set_location(l_package||l_procedure,220);

   -- Populate State Table of values for SOE form
   IF state_tab.count > 0 THEN
    start_cnt := state_tab.FIRST;
    end_cnt := state_tab.LAST;

    FOR i IN start_cnt..end_cnt LOOP
     IF state_tab.exists(i) THEN
      hr_utility.set_location(l_package||l_procedure,230);
      state_tab(i).rep_name := REPLACE(state_tab(i).rep_name, 'EE ','');
      state_tab(i).rep_name := state_tab(i).rep_name||' ('||state_tab(i).state_abbrev||')';

      IF state_tab(i).tax_type = 'STEIC' THEN

         state_tab(i).cur_val := -1 * state_tab(i).cur_val;
	     state_tab(i).ytd_val := -1 * state_tab(i).ytd_val;

         p_steic_curr_val   := state_tab(i).cur_val;
         p_steic_ytd_val    := state_tab(i).ytd_val;

      END IF;

      p_dedn_tab(i).rep_name := state_tab(i).rep_name;
      p_dedn_tab(i).cur_val  := state_tab(i).cur_val;
      p_dedn_tab(i).ytd_val  := state_tab(i).ytd_val ;
     END IF;
    END LOOP;
   END IF;
   hr_utility.set_location(l_package||l_procedure,230);

 EXCEPTION
    WHEN others THEN
       hr_utility.set_location(l_package||l_procedure,240);
       raise_application_error(-20101, 'Error in '|| l_package||l_procedure || ' - ' || sqlerrm);

 END populate_state_balance;



 /*****************************************************************************
   Name      : populate_local_balance
   Purpose   : This procedure populates a PL/SQL table  with all the local deductions
               elements for SOE form.
 *****************************************************************************/

 PROCEDURE populate_local_balance(p_assignment_action_id in number,
                                 p_balance_status        in varchar2,
                                 p_action_type           in varchar2,
				 p_dedn_tab              out nocopy dedn)
 IS

   l_county_state_code  varchar2(2);
   l_county_code	pay_us_counties.county_code%type;
   l_county_name        pay_us_counties.county_name%type;

   l_school_code	pay_us_school_dsts.school_dst_code%type;
   l_school_name	pay_us_school_dsts.school_dst_name%type;
   l_school_jd	        pay_us_local_taxes_v.jurisdiction_code%type;
   l_juris_code         pay_us_state_taxes_v.jurisdiction_code%type;

   l_count         number;
   l_run_amount    number;
   l_curr_amount   number;
   l_ytd_amount    number;
   l_tax_type      pay_us_local_taxes_v.tax_type_code%type;

   start_cnt number;
   end_cnt   number;
   i         number :=0;
   j         number :=0;
   k         number :=0;
   l_found   boolean;
   l_pos     number;

   l_rep_name      pay_us_local_taxes_v.user_reporting_name%TYPE;
   l_city_name     pay_us_local_taxes_v.city_name%TYPE;
   l_run_val       number;
   l_ytd_val       number;

   l_ytd_value         number;
   l_master_action_id  number;
   l_procedure         varchar2(22) ;

   /***
   ***Start Local Balances Cursors when balances are not valid for eBRA***
   ***/
   -- Cursor to get  local balances from run results
   CURSOR get_valid_taxes_local_rr(l_assignment_action_id number)
   IS
   select city_name ,
 	  jurisdiction_code,
 	  tax_type_code,
	  user_reporting_name,
 	  run_val,
 	  ytd_val
     from pay_us_local_taxes_v
    where ee_or_er_code	       = 'EE'
      and assignment_action_id = l_assignment_action_id
    order by user_reporting_name;


   --Cursor to get Run Values
   CURSOR c_get_pre_local_run_rr(cp_run_action_id number)
   IS
   select city_name,
 	  jurisdiction_code,
 	  tax_type_code,
 	  user_reporting_name,
 	  sum(run_val)
     from pay_us_local_taxes_v pt
    where pt.ee_or_er_code	  = 'EE'
      and pt.assignment_action_id = cp_run_action_id
     group by user_reporting_name, city_name,jurisdiction_code, tax_type_code
     order by user_reporting_name;

   -- Cursor to get YTD Value
   CURSOR c_get_pre_local_ytd_rr(cp_master_action_id number)
   IS
   select city_name,
          sum(pt.ytd_val) ,
          jurisdiction_code,
 	  tax_type_code,
 	  user_reporting_name
     from pay_us_local_taxes_v pt
    where pt.ee_or_er_code	  = 'EE'
      and pt.assignment_action_id = cp_master_action_id
     group by user_reporting_name, city_name,jurisdiction_code, tax_type_code
     order by user_reporting_name;

   /***
   ***End Local Balances Cursors when balances are not valid for eBRA***
   ***/


   /***
   ***Start Local Balances Cursors when balances are valid for eBRA***
   ***/

   -- Cursor to get  local balances from run balances
   CURSOR get_valid_taxes_local_rb(l_assignment_action_id number)
   IS
   select city_name ,
 	  jurisdiction_code,
 	  tax_type_code,
	  user_reporting_name,
 	  run_val,
 	  ytd_val
     FROM pay_us_local_taxes_rbr_v
    WHERE ee_or_er_code	       = 'EE'
      AND assignment_action_id = l_assignment_action_id
   order by user_reporting_name;

   --Cursor to get Run Values
   CURSOR c_get_pre_local_run_rb(cp_run_action_id NUMBER)
   IS
   select city_name,
 	  jurisdiction_code,
 	  tax_type_code,
 	  user_reporting_name,
 	  sum(run_val)
     from pay_us_local_taxes_rbr_v pt
    where pt.ee_or_er_code        = 'EE'
      and pt.assignment_action_id = cp_run_action_id
     group by user_reporting_name, city_name,jurisdiction_code, tax_type_code
     order by user_reporting_name;

   -- Cursor to get YTD Value
   CURSOR c_get_pre_local_ytd_rb(cp_master_action_id NUMBER)
   IS
   select city_name ,
          sum(pt.ytd_val),
          jurisdiction_code,
       	  tax_type_code,
 	  user_reporting_name
     from pay_us_local_taxes_rbr_v pt
    where pt.ee_or_er_code        = 'EE'
      and pt.assignment_action_id = cp_master_action_id
    group by user_reporting_name, city_name,jurisdiction_code, tax_type_code
    order by user_reporting_name;

   /***
   ***End Local Balances Cursors when balances are not valid for eBRA***
   ***/

   -- Procedure to get the position of the local deductions in the plsql table
   -- If the element exists it will return the position otherwise will return
   -- new index where new element will be stored. The reporting name with the
   -- same city , jurisdiction or tax_type are grouped for SOE
   PROCEDURE get_position_local(p_rep_name           in pay_us_local_taxes_v.user_reporting_name%TYPE ,
   			        p_tax_type_code      in pay_us_local_taxes_v.tax_type_code%TYPE ,
 			        p_jurisdiction_code  in pay_us_local_taxes_v.jurisdiction_code%type,
 			        p_city_name          in pay_us_local_taxes_v.city_name%type,
                                p_found              out nocopy boolean,
                                p_index              out nocopy number)
   IS

     st_cnt    number;
     ed_cnt   number;
     p_cnt     number;

   BEGIN
      p_found := FALSE;
      p_index := 0;

      p_cnt :=  local_tab.COUNT;

      IF p_cnt = 0 THEN

         p_found := FALSE;
         p_index := 0;
         return;

      ELSE
         st_cnt :=  local_tab.FIRST;
         ed_cnt :=  local_tab.LAST;
         FOR i in st_cnt.. ed_cnt LOOP
            IF local_tab.exists(i) THEN
              IF p_rep_name = local_tab(i).rep_name
               and p_tax_type_code=local_tab(i).tax_type
               and p_jurisdiction_code=local_tab(i).juris_code
               and p_city_name        =local_tab(i).city_name

              THEN
               p_index := i;
               p_found := TRUE;
               return;

              END IF;
            END IF;
         END LOOP;
      END IF;

   END; /* get_position_local */


 BEGIN
   l_procedure         := 'populate_local_balance';

   hr_utility.set_location(l_package||l_procedure,10);
   -- delete local tables
   local_tab.delete;

   hr_utility.set_location(l_package||l_procedure,20);
   IF p_action_type = 'P' OR p_action_type  = 'U' THEN

     hr_utility.set_location(l_package||l_procedure,30);
     IF p_balance_status  = 'Y' THEN

      IF run_actions_tab.COUNT>0 THEN
       start_cnt := run_actions_tab.FIRST;
       end_cnt   := run_actions_tab.LAST;

       pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
       pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
       pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
       pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
       pay_us_balance_view_pkg.set_session_var('YTD','FALSE');

       FOR i IN start_cnt..end_cnt LOOP
        IF run_actions_tab.exists(i) THEN
         OPEN c_get_pre_local_run_rb(run_actions_tab(i).aaid);
 	   LOOP
 	     FETCH c_get_pre_local_run_rb
 	     INTO  l_city_name
 	          ,l_juris_code
 	          ,l_tax_type
 	  	  ,l_rep_name
 		  ,l_run_val;
	     EXIT WHEN c_get_pre_local_run_rb%NOTFOUND;

 	     hr_utility.set_location(l_package||l_procedure,40);
	     get_position_local(l_rep_name,l_tax_type,l_juris_code,l_city_name,l_found, l_pos);

 	     IF l_found = FALSE THEN
        	j := local_tab.COUNT + 1;
         	local_tab(j).rep_name   := l_rep_name;
 		local_tab(j).tax_type   := l_tax_type;
 		local_tab(j).juris_code := l_juris_code;
 		local_tab(j).cur_val    := l_run_val;
 		local_tab(j).ytd_val    := 0;
 		local_tab(j).city_name  := l_city_name;
 	     ELSE
		local_tab(l_pos).cur_val := local_tab(l_pos).cur_val + l_run_val;
 	        local_tab(l_pos).ytd_val := 0;
             END IF;
  	   END LOOP;
	   hr_utility.set_location(l_package||l_procedure,50);
 	 CLOSE  c_get_pre_local_run_rb;
 	 END IF;
       END LOOP;
       END IF;

       hr_utility.set_location(l_package||l_procedure,60);
       IF local_tab.COUNT > 0 THEN
        IF master_actions_tab.COUNT>0 THEN
	 start_cnt:=master_actions_tab.FIRST;
 	 end_cnt:=master_actions_tab.LAST;

	 pay_us_balance_view_pkg.set_session_var('RUN','FALSE');
         pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
 	 pay_us_balance_view_pkg.set_session_var('YTD','TRUE');

	 hr_utility.set_location(l_package||l_procedure,60);
	 FOR i IN start_cnt..end_cnt LOOP
	  IF master_actions_tab.exists(i) THEN
           OPEN c_get_pre_local_ytd_rb(master_actions_tab(i).aaid);
 	     LOOP
 	       FETCH c_get_pre_local_ytd_rb into l_city_name,l_ytd_val,l_juris_code,l_tax_type,l_rep_name;
 	       EXIT WHEN c_get_pre_local_ytd_rb%NOTFOUND;

 	       hr_utility.set_location(l_package||l_procedure,70);
	       get_position_local(l_rep_name,l_tax_type,l_juris_code,l_city_name,l_found, l_pos);

 	       IF l_found = TRUE THEN
 		  local_tab(l_pos).ytd_val := local_tab(l_pos).ytd_val + l_ytd_val;
	       ELSE
   		  k := local_tab.count+1;
		  local_tab(k).rep_name :=l_rep_name;
   		  local_tab(k).cur_val  :=0;
		  local_tab(k).juris_code := l_juris_code;
		  local_tab(k).tax_type := l_tax_type;
   		  local_tab(k).ytd_val  :=l_ytd_val;
		  local_tab(k).city_name := l_city_name;
	       END IF;
             END LOOP;
	     hr_utility.set_location(l_package||l_procedure,80);
 	   CLOSE c_get_pre_local_ytd_rb;
 	   END IF;
 	 END LOOP;
       END IF;
       END IF;

     ELSE -- Invalid Local Balances for eBRA

      hr_utility.set_location(l_package||l_procedure,90);
      IF run_actions_tab.COUNT>0 THEN
       start_cnt := run_actions_tab.FIRST;
       end_cnt   := run_actions_tab.LAST;

       pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
       pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
       pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
       pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
       pay_us_balance_view_pkg.set_session_var('YTD','FALSE');

       FOR i IN start_cnt..end_cnt LOOP
        IF run_actions_tab.exists(i)THEN
 	  OPEN c_get_pre_local_run_rr(run_actions_tab(i).aaid);
 	    LOOP
 	      FETCH c_get_pre_local_run_rr
 	      INTO  l_city_name
 	           ,l_juris_code
 	           ,l_tax_type
 	           ,l_rep_name
 	     	   ,l_run_val;
    	      EXIT WHEN c_get_pre_local_run_rr%NOTFOUND;

 	      hr_utility.set_location(l_package||l_procedure,100);
	      get_position_local(l_rep_name,l_tax_type,l_juris_code,l_city_name,l_found, l_pos);

    	      IF l_found = FALSE THEN
 	   	 j := local_tab.COUNT + 1;
 	   	 local_tab(j).rep_name := l_rep_name;
 	   	 local_tab(j).tax_type := l_tax_type;
 	   	 local_tab(j).juris_code := l_juris_code;
 	   	 local_tab(j).cur_val := l_run_val;
 	   	 local_tab(j).ytd_val :=0;
                 local_tab(j).city_name :=l_city_name; -- Bug 3138331
 	      ELSE
 	    	 local_tab(l_pos).cur_val := local_tab(l_pos).cur_val + l_run_val;
 	         local_tab(l_pos).ytd_val := 0;
 	      END IF;
 	    END LOOP;
 	  CLOSE  c_get_pre_local_run_rr;
 	 END IF;
        END LOOP;
      END IF;

	hr_utility.set_location(l_package||l_procedure,110);
      IF local_tab.COUNT > 0 THEN
        IF master_actions_tab.COUNT>0 THEN
          start_cnt := master_actions_tab.FIRST;
 	  end_cnt   := master_actions_tab.LAST;

	  pay_us_balance_view_pkg.set_session_var('RUN','FALSE');
          pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
          pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
          pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
 	  pay_us_balance_view_pkg.set_session_var('YTD','TRUE');

 	  hr_utility.set_location(l_package||l_procedure,120);
	  FOR i IN start_cnt..end_cnt LOOP
	   IF  master_actions_tab.exists(i) THEN
   	    OPEN c_get_pre_local_ytd_rr(master_actions_tab(i).aaid);
 	      LOOP
 	     	FETCH c_get_pre_local_ytd_rr into l_city_name,l_ytd_val,l_juris_code,l_tax_type,l_rep_name;
 	     	EXIT WHEN c_get_pre_local_ytd_rr%NOTFOUND;

 	     	hr_utility.set_location(l_package||l_procedure,130);
		get_position_local(l_rep_name,l_tax_type,l_juris_code,l_city_name,l_found, l_pos);

 	        IF l_found = TRUE THEN
 	     	  local_tab(l_pos).ytd_val := local_tab(l_pos).ytd_val + l_ytd_val;
		ELSE
   		  k := local_tab.count+1;
		  local_tab(k).rep_name :=l_rep_name;
   		  local_tab(k).cur_val  :=0;
		  local_tab(k).juris_code := l_juris_code;
		  local_tab(k).tax_type := l_tax_type;
   		  local_tab(k).ytd_val  :=l_ytd_val;
		  local_tab(k).city_name := l_city_name;
    		END IF;
	      END LOOP;
 	   CLOSE c_get_pre_local_ytd_rr;
 	   END IF;
 	 END LOOP;
        END IF;

	 hr_utility.set_location(l_package||l_procedure,140);
       END IF;
     END IF;

   ELSE -- SOE for Run is viewed

     hr_utility.set_location(l_package||l_procedure,150);
     pay_us_balance_view_pkg.set_session_var('YTD','TRUE');
     pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
     pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
     pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
     pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');

     i := 0;

     ------- Start Local Taxes-------------------
     IF p_balance_status ='Y' THEN

       hr_utility.set_location(l_package||l_procedure,160);
       OPEN get_valid_taxes_local_rb(p_assignment_action_id);
         LOOP
           FETCH get_valid_taxes_local_rb
            INTO  local_tab(i).city_name,
	          local_tab(i).juris_code,
		  local_tab(i).tax_type,
		  local_tab(i).rep_name,
		  local_tab(i).cur_val,
		local_tab(i).ytd_val;

            EXIT WHEN get_valid_taxes_local_rb%NOTFOUND;
	    i := i + 1;

          END LOOP;
        CLOSE get_valid_taxes_local_rb;
     ELSE
       hr_utility.set_location(l_package||l_procedure,170);

       OPEN get_valid_taxes_local_rr(p_assignment_action_id);
        LOOP
          FETCH get_valid_taxes_local_rr
          INTO  local_tab(i).city_name,
	        local_tab(i).juris_code,
		local_tab(i).tax_type,
		local_tab(i).rep_name,
		local_tab(i).cur_val,
		local_tab(i).ytd_val;

          EXIT WHEN get_valid_taxes_local_rr%NOTFOUND;
     	 i := i + 1;

        END LOOP;
       hr_utility.set_location(l_package||l_procedure,180);
       CLOSE get_valid_taxes_local_rr;
     END IF;
     hr_utility.set_location(l_package||l_procedure,190);
   END IF;

   hr_utility.set_location(l_package||l_procedure,200);
   -- Populate local deduction table for SOE
   l_county_code := '000';
   l_county_state_code :='00';

   IF local_tab.count > 0 THEN
     hr_utility.set_location(l_package||l_procedure,210);
     start_cnt := local_tab.FIRST;
     end_cnt   := local_tab.LAST;

     FOR i IN start_cnt..end_cnt LOOP
       IF local_tab.exists(i) THEN
         IF local_tab(i).tax_type = 'CITY' OR local_tab(i).tax_type = 'HT' THEN

	   hr_utility.set_location(l_package||l_procedure,220);
	   local_tab(i).rep_name := REPLACE(local_tab(i).rep_name, 'EE ', '');
           local_tab(i).rep_name := local_tab(i).rep_name||' ('||local_tab(i).city_name||')';

            ELSIF local_tab(i).tax_type = 'COUNTY' THEN
	      hr_utility.set_location(l_package||l_procedure,230);
              select county_name into l_county_name
 	        from pay_us_counties
 	       where county_code = substr(local_tab(i).juris_code,4,3)
                 and state_code  = substr(local_tab(i).juris_code,1,2);

 	       local_tab(i).rep_name := REPLACE(local_tab(i).rep_name, 'EE ', '');
 	       local_tab(i).rep_name := local_tab(i).rep_name||' ('||l_county_name||')';

	       -- Bug 3250653
               ELSIF local_tab(i).tax_type = 'SCHOOL' THEN
                hr_utility.set_location(l_package||l_procedure,240);
		select distinct school_dst_name into l_school_name
 	          from pay_us_school_dsts           --Bug 3412605
 	          where school_dst_code = substr(local_tab(i).juris_code,4,5)
                    and state_code      = substr(local_tab(i).juris_code,1,2);

	        l_school_code :=substr(local_tab(i).juris_code,4,5);
    	        l_school_jd   := substr(local_tab(i).juris_code,1,2)||'-'||l_school_code;

 	        local_tab(i).rep_name := REPLACE(local_tab(i).rep_name, 'EE ','');
                local_tab(i).rep_name := local_tab(i).rep_name||' ('||l_school_name||'-'||l_school_code||')';
         END IF;
	 hr_utility.set_location(l_package||l_procedure,240);

         hr_utility.set_location(l_package||l_procedure,250);
	 p_dedn_tab(i).rep_name := local_tab(i).rep_name;
	 p_dedn_tab(i).cur_val  := local_tab(i).cur_val;
	 p_dedn_tab(i).ytd_val  := local_tab(i).ytd_val ;
       END IF;
     END LOOP;
   END IF; -- Prepayment or Quick Pay Prepayment
   hr_utility.set_location(l_package||l_procedure,260);

 EXCEPTION
    WHEN others THEN
       hr_utility.set_location(l_package||l_procedure,270);
       raise_application_error(-20101, 'Error in '||l_package||l_procedure || ' - ' || sqlerrm);

 END populate_local_balance;



 /***************************************************************************
  Name      : populate_dedn_balance
  Purpose   : This procedure populates the plsql table with the Pre-Tax and
              and After Tax Deduction elements for SOE form.
 ***************************************************************************/
 PROCEDURE populate_dedn_balance(p_assignment_action_id in number,
                                 p_pre_balance_status   in varchar2,
				 p_aft_balance_status   in varchar2,
                                 p_action_type          in varchar2,
				 p_dedn_tab             out nocopy dedn)
 IS

   -- Cursor to get tax deduction elements using run balances
   CURSOR c_get_dedn_elements_rb(c_run_assact_id number) IS
   select ytd_val,
          reporting_name_alt,
          run_val,
	  element_type_id
     from pay_us_deductions_rbr_v
    where assignment_action_id = c_run_assact_id
    order by reporting_name_alt;

   -- Cursor to get run values of tax deductions when balances are valid
   CURSOR c_get_dedn_run_rb(cp_run_action_id number) IS
   select reporting_name_alt,
          run_val,
	  element_type_id
     from pay_us_deductions_rbr_v pt
    where pt.assignment_action_id = cp_run_action_id
    order by reporting_name_alt;

   -- Cursor to get ytd values of tax deductions when balances are valid for master action
   CURSOR c_get_dedn_ytd_rb(cp_master_action_id number) IS
   select ytd_val,
          reporting_name_alt,
	  element_type_id
     from pay_us_deductions_rbr_v pt
    where pt.assignment_action_id =  cp_master_action_id;


   -- Cursor to other deduction elements from element entries
   -- Bug 4966938
   CURSOR c_get_dedn_elements(cp_date_paid   date,
                              cp_assignment_action_id number) IS
     select distinct
            pet.element_type_id,
            nvl(pet.reporting_name, pet.element_name),
            pet.element_information10,
            pet.business_group_id,
            pet.processing_priority
       from pay_assignment_actions paa ,
            pay_assignment_actions paa1 ,
	    pay_payroll_actions ppa ,
            pay_run_results prr ,
	    pay_element_types_f pet ,
            pay_element_classifications pec
      where paa.assignment_action_id = cp_assignment_action_id
        and paa1.assignment_id = paa.assignment_id
        -- and paa1.source_action_id is not null --for bug 5332346
        and ppa.payroll_action_id = paa1.payroll_action_id
        and ppa.effective_date between trunc(cp_date_paid,'Y') and cp_date_paid
        and prr.assignment_action_id = paa1.assignment_action_id
        and prr.source_type in ( 'E', 'I' )
        and pet.element_type_id   >=  0
        and pet.element_information10 is not null
        and nvl(ppa.date_earned,ppa.effective_date) between pet.effective_start_date and pet.effective_end_date
        and prr.element_type_id + 0   = pet.element_type_id
        and pec.classification_name IN ('Pre-Tax Deductions',
                                        'Voluntary Deductions',
                                        'Involuntary Deductions')
        and pet.classification_id = pec.classification_id
      order by pet.processing_priority,nvl(pet.reporting_name, pet.element_name);  --bug4743188

/*
   CURSOR c_get_dedn_elements(cp_date_earned   date,
                              cp_assignment_id number) IS
     select /*+ ORDERED  distinct
            pet.element_type_id,
            nvl(pet.reporting_name, pet.element_name),
            pet.element_information10,
            pet.business_group_id,
            pet.processing_priority
       from pay_element_entries_f pee,
            pay_run_results prr,
            pay_element_types_f pet,
            pay_element_classifications pec
      where pee.assignment_id = cp_assignment_id
        and pee.effective_end_date >= trunc(cp_date_earned, 'Y')
        and pee.effective_start_date <= cp_date_earned
        and prr.source_id = pee.element_entry_id
        and prr.source_type in ( 'E', 'I' )
        and pec.classification_name IN ('Pre-Tax Deductions',
                                        'Voluntary Deductions',
                                        'Involuntary Deductions')
        and pet.classification_id = pec.classification_id
        and pet.element_information10 is not null
        and pet.effective_start_date =
                   (select max(pet1.effective_start_date)
                      from pay_element_types_f pet1
                     where pet1.element_type_id = pet.element_type_id
                       and pet1.effective_start_date <= cp_date_earned)
        and prr.element_type_id + 0  = pet.element_type_id
     order by pet.processing_priority;
*/
   l_found1            number :=0;

   l_rep_name      pay_us_deductions_v.reporting_name_alt%type ;
   l_run_val       number;
   l_ytd_val       number;
   l_found         boolean;
   l_pos           number;
   l_procedure     varchar2(21) ;


   l_element_type_id        pay_element_types_f.element_type_id%type;
   l_element_reporting_name pay_element_types_f.reporting_name%type;
   l_element_information10  pay_element_types_f.element_information10%type;
   l_assignment_id          pay_assignment_actions.assignment_id%type;
   l_assignment_action_id   pay_assignment_actions.assignment_action_id%type;
   l_tax_unit_id            pay_assignment_actions.tax_unit_id%type;
   l_date_earned            pay_payroll_actions.date_earned%type;
   l_date_paid              pay_payroll_actions.effective_date%type;
   l_business_group_id      pay_element_types_f.business_group_id%type;
   l_processing_priority    pay_element_types_f.processing_priority%type;


   -- Procedure to get the position of the deductions in the plsql
   -- table. If the element exists it will return the position otherwise will return
   -- new index where new element will be stored. The elements with the  same
   -- reporting name will be grouped for SOE
   PROCEDURE get_position(p_rep_name in pay_us_deductions_v.reporting_name_alt%type,
                          p_found    out nocopy boolean,
                          p_index    out nocopy number,
			  p_dedn_tab in  dedn)
   IS

    st_cnt    number;
    ed_cnt   number;
    p_cnt     number;

   BEGIN
      p_found := FALSE;
      p_index := 0;

      p_cnt  :=  p_dedn_tab.COUNT;

      IF p_cnt = 0 THEN

         p_found := FALSE;
         p_index := 0;
         return;

      ELSE
         st_cnt :=  p_dedn_tab.FIRST;
         ed_cnt :=  p_dedn_tab.LAST;
         FOR i in st_cnt.. ed_cnt LOOP
           IF p_dedn_tab.exists(i) THEN
            IF p_rep_name = p_dedn_tab(i).rep_name THEN

               p_index := i;
               p_found := TRUE;
               return;

            END IF;
           END IF;
         END LOOP;
      END IF;
   END; /* get_position */

 BEGIN
    l_procedure     := 'populate_dedn_balance';
   --hr_utility.trace_on(null,'SOE');
   hr_utility.set_location(l_package||l_procedure,10);
   deduction_elements_tab.delete;
   p_dedn_tab.delete;

   -- SOE for Prepayment/Quick pay prepayment is viewed
   IF p_action_type in ('P', 'U') THEN
      hr_utility.set_location(l_package||l_procedure,20);

      IF p_pre_balance_status = 'Y' and p_aft_balance_status = 'Y' THEN

         IF run_actions_tab.COUNT >0 THEN
            pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
	    pay_us_balance_view_pkg.set_session_var('YTD','FALSE');
            pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
            pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
            pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');

	    hr_utility.set_location(l_package||l_procedure,30);
	    FOR i IN run_actions_tab.FIRST .. run_actions_tab.LAST LOOP
	        IF run_actions_tab.exists(i) THEN
                   OPEN c_get_dedn_run_rb(run_actions_tab(i).aaid);
                   LOOP
                      FETCH c_get_dedn_run_rb INTO l_rep_name
	                                          ,l_run_val
		                                  ,l_element_type_id;
     	              EXIT WHEN c_get_dedn_run_rb%NOTFOUND;

                      -- Populate Deductions Elements Table
                      deduction_elements_tab(l_element_type_id).element_reporting_name
                                 := l_rep_name ;
                      deduction_elements_tab(l_element_type_id).element_information10
                                 := null;

	              hr_utility.set_location(l_package||l_procedure,40);
	              get_position(l_rep_name,l_found, l_pos,p_dedn_tab);

     	              IF l_found = FALSE THEN
                         l_pos := p_dedn_tab.COUNT + 1;
                         p_dedn_tab(l_pos).rep_name := l_rep_name;
	                 p_dedn_tab(l_pos).cur_val  := l_run_val;
   	                 p_dedn_tab(l_pos).ytd_val  := 0;
                      ELSE
   	                 p_dedn_tab(l_pos).cur_val := p_dedn_tab(l_pos).cur_val + l_run_val;
	                 p_dedn_tab(l_pos).ytd_val := 0;
    	              END IF;
                   END LOOP;
                   CLOSE c_get_dedn_run_rb;
                END IF;
            END LOOP;
         END IF;

	 hr_utility.set_location(l_package||l_procedure,50);
	 IF p_dedn_tab.COUNT > 0 THEN
	    hr_utility.set_location(l_package||l_procedure,60);
	    IF master_Actions_tab.COUNT>0 THEN

               pay_us_balance_view_pkg.set_session_var('RUN','FALSE');
               pay_us_balance_view_pkg.set_session_var('YTD','TRUE');
               pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
               pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
               pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');

               FOR i IN master_actions_tab.FIRST .. master_actions_tab.LAST LOOP
                   IF master_actions_tab.exists(i) THEN
                      OPEN  c_get_dedn_ytd_rb(master_actions_tab(i).aaid);
                      LOOP
                         FETCH c_get_dedn_ytd_rb INTO l_ytd_val,
                                                      l_rep_name,
                                                      l_element_type_id;
                         EXIT WHEN c_get_dedn_ytd_rb%NOTFOUND;

		         -- Populate Deductions after check
                         IF deduction_elements_tab.count > 0 THEN

                            IF deduction_elements_tab.exists(l_element_type_id) THEN
                               hr_utility.trace('The element already exists in PLSQL table');
                            ELSE
                               deduction_elements_tab(l_element_type_id).element_reporting_name := l_rep_name ;
                               deduction_elements_tab(l_element_type_id).element_information10  := null;
                            END IF;
                         ELSE
                            deduction_elements_tab(l_element_type_id).element_reporting_name :=  l_rep_name;
                            deduction_elements_tab(l_element_type_id).element_information10  := null;
                         END IF;
		         hr_utility.set_location(l_package||l_procedure,70);
		         get_position(l_rep_name,l_found, l_pos, p_dedn_tab);

                         IF l_found = TRUE THEN
                            p_dedn_tab(l_pos).ytd_val := p_dedn_tab(l_pos).ytd_val + l_ytd_val;
 	                 ELSE
		            -- Create new index and store ytd value with run values as 0
   		            l_pos := p_dedn_tab.count+1;
   		            p_dedn_tab(l_pos).rep_name :=l_rep_name;
   		            p_dedn_tab(l_pos).cur_val  :=0;
   		            p_dedn_tab(l_pos).ytd_val  :=l_ytd_val;
                         END IF;
                      END LOOP;
                      CLOSE c_get_dedn_ytd_rb;
                   END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;

      IF p_pre_balance_status <> 'Y' or p_aft_balance_status <> 'Y' THEN

         hr_utility.set_location(l_package||l_procedure,80);

         IF run_actions_tab.COUNT>0 THEN
	    pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
   	    pay_us_balance_view_pkg.set_session_var('YTD','FALSE');
            pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
            pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
            pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');

   	    FOR i IN run_actions_tab.FIRST .. run_actions_tab.LAST LOOP
       	        IF run_actions_tab.exists(i) THEN

	           hr_utility.set_location(l_package||l_procedure,90);
                   OPEN c_get_pay_action_details(run_actions_tab(i).aaid);
		   -- 4966938
                   FETCH c_get_pay_action_details INTO l_assignment_id
	                                              ,l_assignment_action_id
	                                              ,l_date_earned
                                                      ,l_tax_unit_id
						      ,l_date_paid;
                   CLOSE c_get_pay_action_details;
                   hr_utility.set_location(l_package||l_procedure,210);

	           hr_utility.trace('Run Action ID : ' || run_actions_tab(i).aaid);

	           hr_utility.set_location(l_package||l_procedure,220);
		   -- 4966938
                   OPEN c_get_dedn_elements(l_date_paid,l_assignment_action_id);
                   LOOP
                      FETCH c_get_dedn_elements INTO l_element_type_id
	                                                 ,l_element_reporting_name
	                                                 ,l_element_information10
	                                                 ,l_business_group_id
                                                         ,l_processing_priority;
                      EXIT WHEN c_get_dedn_elements%NOTFOUND;

                      IF deduction_elements_tab.count > 0 THEN
                         FOR i in deduction_elements_tab.first ..
                                  deduction_elements_tab.last LOOP
                             IF deduction_elements_tab.exists(l_element_type_id) THEN
                                l_found1 := 1;
                                hr_utility.trace('Element already fetched from Run Bal');
                                EXIT;
		             ELSE
		                l_found1 := 0;
                             END IF;
                         END LOOP;
                      END IF;

                      IF l_found1 = 0 THEN
                         deduction_elements_tab(l_element_type_id).element_reporting_name
                                      := l_element_reporting_name ;
                         deduction_elements_tab(l_element_type_id).element_information10
                                      := l_element_information10;

		         l_rep_name := l_element_reporting_name;
	                 hr_utility.set_location(l_package||l_procedure ,221);

	                 l_run_val  := pay_balance_pkg.get_value
	                                       (get_defined_bal(to_number(l_element_information10),
		  	                        g_run_dimension_id),
		                                run_actions_tab(i).aaid);
                         hr_utility.set_location(l_package||l_procedure,222);
                         hr_utility.trace('Run Val  : ' || l_run_val);

                         get_position(l_rep_name,l_found, l_pos,p_dedn_tab);
                         IF l_found = FALSE THEN
                            l_pos := p_dedn_tab.COUNT + 1;
                            p_dedn_tab(l_pos).rep_name := l_rep_name;
                            p_dedn_tab(l_pos).cur_val  := l_run_val;
                            p_dedn_tab(l_pos).ytd_val  := 0;
                         ELSE
                            p_dedn_tab(l_pos).cur_val  := p_dedn_tab(l_pos).cur_val + l_run_val;
		            p_dedn_tab(l_pos).ytd_val :=0;
                         END IF;
	              END IF;
	          END LOOP;
	          CLOSE c_get_dedn_elements;
	        END IF;
            END LOOP;
         END IF;

         hr_utility.set_location(l_package||l_procedure,223);
         IF deduction_elements_tab.COUNT > 0 THEN

	    IF master_actions_tab.COUNT>0 THEN

	       pay_us_balance_view_pkg.set_session_var('RUN','FALSE');
               pay_us_balance_view_pkg.set_session_var('YTD','TRUE');
               pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
               pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
               pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');

	       FOR i IN master_actions_tab.FIRST ..  master_actions_tab.LAST LOOP
                   IF master_actions_tab.exists(i) THEN
		      hr_utility.trace('Master Action  : ' || master_actions_tab(i).aaid);
                      hr_utility.set_location(l_package||l_procedure,230);
                      FOR j IN deduction_elements_tab.first ..
                               deduction_elements_tab.last LOOP
	 	          IF deduction_elements_tab.exists(j) and
		             deduction_elements_tab(j).element_information10 is not null THEN
	                     hr_utility.set_location(l_package||l_procedure,240);
	                     l_rep_name := deduction_elements_tab(j).element_reporting_name;
                             l_ytd_val  := pay_balance_pkg.get_value
	                                          (get_defined_bal(to_number(deduction_elements_tab(j).element_information10),
			                           g_ytd_dimension_id),
		                                   master_actions_tab(i).aaid);
                             hr_utility.set_location(l_package||l_procedure,254);
                             get_position(l_rep_name,l_found, l_pos,p_dedn_tab);
 	                     IF l_found = TRUE THEN
 	                        p_dedn_tab(l_pos).ytd_val
                                              := p_dedn_tab(l_pos).ytd_val + l_ytd_val;
	                     ELSE
   		                l_pos := p_dedn_tab.count+1;
		                p_dedn_tab(l_pos).rep_name :=l_rep_name;
   		                p_dedn_tab(l_pos).cur_val  :=0;
   		                p_dedn_tab(l_pos).ytd_val  :=l_ytd_val;
 	                     END IF;
		          END IF;
                      END LOOP;
                   END IF;
               END LOOP;
               hr_utility.set_location(l_package||l_procedure,150);
            END IF;
         END IF;
      END IF;
      hr_utility.set_location(l_package||l_procedure,140);

   ELSE -- SOE for run actions is viewed

      IF p_pre_balance_status = 'Y' and p_aft_balance_status = 'Y' THEN
         hr_utility.set_location(l_package||l_procedure,150);
         pay_us_balance_view_pkg.set_session_var('YTD','TRUE');
         pay_us_balance_view_pkg.set_session_var('RUN','TRUE');
         pay_us_balance_view_pkg.set_session_var('QTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('MTD','FALSE');
         pay_us_balance_view_pkg.set_session_var('PYDATE','FALSE');
         deduction_elements_tab.delete;
         p_dedn_tab.delete;
         hr_utility.set_location(l_package||l_procedure,160);
	 OPEN  c_get_dedn_elements_rb(p_assignment_action_id);
         LOOP
            FETCH c_get_dedn_elements_rb INTO l_ytd_val,
	                                      l_rep_name,
	                                      l_run_val,
		                              l_element_type_id;
	    EXIT WHEN c_get_dedn_elements_rb%NOTFOUND;

	    deduction_elements_tab(l_element_type_id).element_reporting_name := l_rep_name ;
            deduction_elements_tab(l_element_type_id).element_information10  := null;

            get_position(l_rep_name,l_found, l_pos, p_dedn_tab);
            hr_utility.set_location(l_package||l_procedure,40);
            IF l_found = FALSE THEN
               l_pos := p_dedn_tab.COUNT + 1;
               p_dedn_tab(l_pos).rep_name := l_rep_name;
               p_dedn_tab(l_pos).cur_val  := l_run_val;
               p_dedn_tab(l_pos).ytd_val  := l_ytd_val;
            ELSE
               p_dedn_tab(l_pos).cur_val  := p_dedn_tab(l_pos).cur_val + l_run_val;
               p_dedn_tab(l_pos).ytd_val  := p_dedn_tab(l_pos).ytd_val + l_ytd_val;
            END IF;
         END LOOP;
         CLOSE c_get_dedn_elements_rb;
      END IF;

      hr_utility.set_location(l_package||l_procedure,170);

      IF p_pre_balance_status <> 'Y' or p_aft_balance_status <> 'Y' THEN

         OPEN c_get_pay_action_details(p_assignment_action_id);
         FETCH c_get_pay_action_details INTO l_assignment_id
                                            ,l_assignment_action_id
                                            ,l_date_earned
                                            ,l_tax_unit_id
					    ,l_date_paid;
         CLOSE c_get_pay_action_details;
         -- 4966938
         OPEN c_get_dedn_elements(l_date_paid,l_assignment_action_id);
         LOOP
            FETCH c_get_dedn_elements INTO l_element_type_id
	                                  ,l_element_reporting_name
	                                  ,l_element_information10
	                                  ,l_business_group_id
                                          ,l_processing_priority;
            EXIT WHEN c_get_dedn_elements%NOTFOUND;

	    IF deduction_elements_tab.count > 0 THEN
	       IF deduction_elements_tab.exists(l_element_type_id) THEN
	          hr_utility.trace('The element already exists in PLSQL table');
	       ELSE
	          deduction_elements_tab(l_element_type_id).element_reporting_name
                           := l_element_reporting_name ;
                  deduction_elements_tab(l_element_type_id).element_information10
                           := l_element_information10;
	          deduction_elements_tab(l_element_type_id).business_group_id
                           := l_business_group_id;
	       END IF;
 	    ELSE
	       deduction_elements_tab(l_element_type_id).element_reporting_name
                           := l_element_reporting_name ;
               deduction_elements_tab(l_element_type_id).element_information10
                           := l_element_information10;
	       deduction_elements_tab(l_element_type_id).business_group_id
                           := l_business_group_id;
	    END IF;
-- bug 4743188

	           l_rep_name := deduction_elements_tab(l_element_type_id).element_reporting_name;
	           l_run_val  := pay_balance_pkg.get_value
	                             (get_defined_bal(deduction_elements_tab(l_element_type_id).element_information10,
			              g_run_dimension_id),
		                      p_assignment_action_id);

	           l_ytd_val  := pay_balance_pkg.get_value
	                             (get_defined_bal(deduction_elements_tab(l_element_type_id).element_information10,
			              g_ytd_dimension_id),
		                      p_assignment_action_id);

	           get_position(l_rep_name,l_found, l_pos, p_dedn_tab);
	           IF l_found = TRUE THEN
	              p_dedn_tab(l_pos).ytd_val  := p_dedn_tab(l_pos).ytd_val  + l_ytd_val;
                      p_dedn_tab(l_pos).cur_val  := p_dedn_tab(l_pos).cur_val  + l_run_val;
                   ELSE
   	              l_pos := p_dedn_tab.count + 1;
		      p_dedn_tab(l_pos).rep_name := l_rep_name;
		      p_dedn_tab(l_pos).ytd_val  := l_ytd_val;
                      p_dedn_tab(l_pos).cur_val  := l_run_val;
                  END IF;
	  --end

         END LOOP;
         CLOSE c_get_dedn_elements;
--bug 4743188
        /* IF deduction_elements_tab.count > 0 THEN
            FOR i IN deduction_elements_tab.first..deduction_elements_tab.last LOOP
	        IF deduction_elements_tab.exists(i) and
	           deduction_elements_tab(i).element_information10 is not null THEN
	           l_rep_name := deduction_elements_tab(i).element_reporting_name;
	           l_run_val  := pay_balance_pkg.get_value
	                             (get_defined_bal(deduction_elements_tab(i).element_information10,
			              g_run_dimension_id),
		                      p_assignment_action_id);

	           l_ytd_val  := pay_balance_pkg.get_value
	                             (get_defined_bal(deduction_elements_tab(i).element_information10,
			              g_ytd_dimension_id),
		                      p_assignment_action_id);

	           get_position(l_rep_name,l_found, l_pos, p_dedn_tab);
	           IF l_found = TRUE THEN
	              p_dedn_tab(l_pos).ytd_val  := p_dedn_tab(l_pos).ytd_val  + l_ytd_val;
                      p_dedn_tab(l_pos).cur_val  := p_dedn_tab(l_pos).cur_val  + l_run_val;
                   ELSE
   	              l_pos := p_dedn_tab.count + 1;
		      p_dedn_tab(l_pos).rep_name := l_rep_name;
		      p_dedn_tab(l_pos).ytd_val  := l_ytd_val;
                      p_dedn_tab(l_pos).cur_val  := l_run_val;
                  END IF;
	       END IF;
	   END LOOP;
        END IF; */--comments end
     END IF;
  END IF;

 EXCEPTION
    WHEN others THEN
       hr_utility.set_location(l_package||l_procedure,180);
       raise_application_error(-20101, 'Error in '||l_package||l_procedure || ' - ' || sqlerrm);

END populate_dedn_balance;



 /*****************************************************************************
   Name      : get_max_actions_table
   Purpose   : This procedure returns the plsql table of all max actions to the
               SOE form. We will store the max actions in sorted order so that
	       we can take advantage to use the last stored value as the max
	       action for Summary Block Values
 *****************************************************************************/
  PROCEDURE get_max_actions_table(p_max_actions_tab out nocopy master_aaid_tab)
  IS
   cnt_start   number;
   cnt_end     number;
   i           number;
   l_temp      number;
   l_procedure varchar2(21) ;
 BEGIN
   l_procedure  := 'get_max_actions_table';
   hr_utility.set_location(l_package||l_procedure,10);
   IF master_actions_tab.count >0 THEN
    cnt_start  := master_actions_tab.first;
    cnt_end    := master_actions_tab.last;

    hr_utility.set_location(l_package||l_procedure,20);

    -- Sort the table in Ascending Order
    FOR i in cnt_start..(cnt_end-1) LOOP
      IF master_actions_tab.exists(i) THEN
        FOR j in i+1..cnt_end LOOP
          IF master_actions_tab.exists(j) THEN
	     IF master_actions_tab(i).aaid > master_actions_tab(j).aaid THEN
	       l_temp := master_actions_tab(i).aaid;
	       master_actions_tab(i).aaid := master_actions_tab(j).aaid;
	       master_actions_tab(j).aaid := l_temp;
	     END IF;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
    hr_utility.set_location(l_package||l_procedure,30);

    -- Assign the sorted max actions table to the table to be used
    -- by SOE Form

    FOR i in cnt_start..cnt_end
      LOOP
        IF master_actions_tab.exists(i) THEN
          p_max_actions_tab(i).aaid  := master_actions_tab(i).aaid;
        END IF;
      END LOOP;
    END IF;
    hr_utility.set_location(l_package||l_procedure,40);

 EXCEPTION
    WHEN others THEN
       hr_utility.set_location(l_package||l_procedure,50);
       raise_application_error(-20101, 'Error in '||l_package||l_procedure || ' - ' || sqlerrm);
 END;
END pay_us_soe_balances_pkg;

/
