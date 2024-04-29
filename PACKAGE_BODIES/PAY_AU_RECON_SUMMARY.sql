--------------------------------------------------------
--  DDL for Package Body PAY_AU_RECON_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_RECON_SUMMARY" as
/*  $Header: pyauprec.pkb 120.18.12010000.16 2010/01/13 09:24:58 pmatamsr ship $*/

/*
*** ------------------------------------------------------------------------+
*** Program:     pay_au_recon_summary (Package Body)
***
*** Change History
***
*** Date       Changed By  Version  Description of Change
*** ---------  ----------  -------  ----------------------------------------+
*** 07 APR 03  apunekar    1.1      Initial version
*** 05 MAY 03  apunekar    1.2      Bug2855658 - Fixed for Retro Allowances
*** 20 May 03  Ragovind    1.8      Bug#2819479 - ETP Pre/Post Enhancement.
***                                 Flag to check whether this function called by Termination FOrm.
*** 29 May 2003 apunekar   1.9      Bug2920725   Corrected base tables to support security model
*** 10 Jun 2003 Ragovind   1.10     Bug#2972687 - Modified the cursor Get_Allowance_Balances for Performance
*** 18 Jun 2003 Ragovind   1.11     Bug#3004966 - Added functions for performance improvement of Reconciliation Report.
*** 20 Jun 03  Ragovind    1.12     Bug#3004966 - Fix for Performance Improvement
*** 20 Jun 03  Ragovind    1.13     Bug#3004966 - Added check g_asg_ids_t.exists(p_assignment_id) to function check_asgid
*** 21 Jul 03  Apunekar    1.14     Bug#3034792 - Copied fixes from branch 115.8.11511.5 into mainline. Added all payment summary fixes.
                                    Base tables used instead of secured views to sync with archive code.
*** 23 Jul 03  Nanuradh    1.15     Bug#2984390 - Added an extra parameter to the function call etp_prepost_ratios - ETP Pre/post Enhancement
*** 13 Aug 03  Nanuradh    1.16     Bug#3095923 - Modified the function Total_Lump_Sum_E_Payments to get the value of g_lump_sum_e
***                                 If single Lump sum E payment is less than 400, then the amount is subtracted from Lump sum E.
*** 21 Aug 03  punmehta    115.18   Bug#3095923 - Modified the Cursor c_get_pay_earned_date to fetch effective_date instead of date_earned
*** 22-AUG-03  punmehta    115.19   Bug#3095923 - Modified the Cursor name c_get_pay_earned_date
***                                 to c_get_pay_effective_date and variable name of date_earned to effective_date
*** 09-OCT-03  Ragvoind    115.20   Bug#3034189 - Removed the usage of index INDEX(rppa pay_payroll_actions_pk) from cursor c_asgids.
*** 20-OCT-03  punmehta    115.21   Bug#3193479 - Implemented Batch Balance Retrieval. for that created new function to populate
***                                 global plsql table and other functions gets the balance value from this function.
*** 21-OCT-03  punmehta    115.22   Bug#3193479 - Added check for g_debug before tracing
*** 21-OCT-03  punmehta    115.23   Bug#3193479 - Modified OUT with OUT NOCOPY
*** 23-OCT-03  punmehta    115.24   Bug#3213539 - Modified the function get_total_fbt
*** 27-OCT-03  avenkatk    115.25   Bug#3215789 - Modified function Total_Tax_deductions
*** 27-OCT-03  vgsriniv    115.26   Bug#3215982 - Removed the global declaration of g_index and also
***                                 removed initialization of g_index from the procedure get_value_bbr
*** 22-Nov-03  punmehta    115.27   Bug#3263659 - Modified c_asg_ids cursor to check for terminated date in last year.
*** 06-Feb-04  punmehta    115.28   Bug#3245909 - Modified c_get_pay_effective_date cursor to fetch Dates for only master assignment action.
*** 10-Feb-04  punmehta    115.29   Bug#3098367 - Added check to set a flag as 'NO' if all balances are zero.
*** 11-Feb-04  punmehta    115.30   Bug#3098367 - Added default value for flag.
*** 23-Mar-04  Ragovind    115.31   Bug#3525563 - Added IF condition to call pay_balance_pkg.get_value when l_max_asg_action_id is not null
*** 28-Mar-04  srrajago    115.32   Bug#3186840 - Introduced a parameter 'l_le_level' in 'populate_bal_ids' so that it can populate
***                                 defined_bal_ids of '_ASG_LE_YTD' or '_ASG_YTD' depending on the parameter value passed.
***                                 Introduced procedures 'populate_group_def_bal_ids','get_group_values_bbr',
***                                 'get_assgt_curr_term_values_bbr' and 'get_group_assgt_values_bbr'.New procedures will be used by the
***                                 report PYAURECP-Pay Rec Payment Summary report.
*** 29-Mar-04  srrajago    115.33   Bug#3186840 - Removed the procedure 'get_group_assgt_values_bbr'.
*** 31-Mar-04  srrajago    115.34   Bug#3186840 - Procedure 'populate_group_def_bal_ids' modified to include balances 'Earnings_Total',
***                                 'Leave Payments Marginal','CDEP' and 'Other Income'. Procedure 'get_group_assgt_values_bbr' modified
***                                 to fetch the above mentioned group level balances. References to these balances at assignment level
***                                 have been removed in 'get_assgt_curr_term_values_bbr'.
*** 11-Jun-04  punmehta    115.38   Bug#3686549 - Added a new parameter and logic to take more then 1 yrs term employees
*** 11-Jun-04  punmehta    115.39   Bug#3686549 - Modified for GSCC warnings
*** 21-Jun-04  punmehta    115.40   Bug#3693034 - Modified the max assignmtn_aciotn cursor in fbt procedure
*** 28-Jun-04  srrajago    115.41   Bug#3603495 - Performance Fix - Cursors 'c_get_pay_effective_date' and 'c_max_asg_action_id'
***                                 modified.
*** 01-Jul-04  punmehta    115.42   Bug#3728357 - Performance Fix
*** 03-Jul-04  srrajago    115.44   Reverted back the fix in 115.43. Also, modified the cursor 'Get_Allowances_Balances' to be in sink
***                                 with the one in the Payment Summary archive package.(ie)Bug#2972687 fix removed.
*** 07-Jul-04  punmehta    115.45   Bug#3749530 - Added archival model to archive assignment_actions for performance
*** 09-Jul-04  punmehta    115.46   Bug#3749530 - Added a new cursor to handle single assignment
*** 09-Aug-04  abhkumar    115.47   Bug#2610141 - Legal Employer enhancement changes.
*** 13-Aug-04  abhkumar    115.48   Bug#2610141 - Modified code to calculate correct lump sum e if there are two runs in the same period
*** 22-Nov-04  avenkatk    115.49   Bug#4015571 -  Function get_total_fbt - Modified cursor c_max_asg_action_id.
*** 22-Nov-04  avenkatk    115.50   Bug#4015571 -  Resolved GSCC Errors
*** 24-Nov-04  srrajago    115.51   Bug#3872211 - Modified cursors 'c_asgids' and 'c_asgid_only' to handle Payrolls Updation. (This is the same fix
***                                 made for Payment Summary - Refer Bug: 3815301)
*** 30-Dec-04  avenkatk    115.52   Bug#3899641 - Added Functional Dependancy Comment
*** 13-Jan-05  avenkatk    115.53   Bug#4116833 - Set the No of copies for report to be read from the Archive Request.
*** 18-Jan-05  hnainani     115.54   Bug#4015082   Workplace Giving Deductions
*** 07-Feb-05  ksingla      115.56   Bug#4161460   Modified the cursor get_allowance_balances
*** 09-Feb-05  ksingla      115.57   Bug#4173809   Modified the cursor c_eit_updated for Manual PS issues.
*** 12 Feb 05 abhargav      115.58   bug#4174037   Modified the cursor get_allowance_balances to avoid the unnecessary get_value() call.
*** 17 Feb 05 abhkumar      115.59   Bug#4161460   Rolled back the changes made in version 115.56.
*** 05 Apr 05 ksingla       115.60   Bug#4256486   Modified the etp_code for performance.
*** 12 Apr 05 avenkatk      115.61   Bug#4256506   Changed c_max_asg_action_id in procedure get_total_fbt for performance.
*** 18 Apr 05 ksingla       115.62   Bug#4278272   Changed the cursor get_allowance_balances for performance issues.
*** 19 Apr 05 ksingla       115.63   Bug#4278407   Changed the cursor c_get_details to improve performance.
*** 22 Apr 05 ksingla       115.64   Bug#4177679   Added a new paramter to the function call etp_prepost_ratios.
*** 25 Apr 05 ksingla       115.65   Bug#4278272   Rolled back the changes done in version 115.62.
*** 05 May 05 abhkumar      115.66   Bug#4377367   Added join in the cursor c_asgids to archive the end-dated employees.
*** 09 JUl 05 abhargav      115.67   Bug#4363057   Changes due to Retro Tax enhancement.
*** 2 AUG 05 hnainani      115.68   Bug#4478752    Added quotes to -999 to allow for Character values in flexfield.
*** 02-OCT-05 abhkumar     115.70   Bug#4688800   Modified assignment action code to pick those employees who do have payroll attached
                                                  at start of the financial year but not at the end of financial year.
*** 02-DEC-05 abhkumar     115.71   Bug#4701566   Modified the cursor get_allowance_balances to get allowance value for end-dated
                                                  employees and also improve the performance of the query.
*** 06-DEC-05 abhkumar     115.72   Bug#4863149   Modified the code to raise error message when there is no defined balance id for the allowance balance.
*** 09-DEC-05 ksingla      115.73   Bug#4872594   Removed round from Pre and post Jul values.
*** 15-DEC-05 ksingla      115.74   Bug#4872594   Put round off upto 2 decimal places.
*** 15-DEC-05 ksingla      115.75   Bug#4888097   Inititalise allowance variables to prevent picking value for previous employees when the current employee
***                                               being processed doesn't has a allowance.
*** 20-JUL-06 priupadh     115.76  Bug#5397790    In Cursor etp_code added a join of period_of_service_id
*** 19-Dec-06 ksingla      115.77  Bug#5708255   Added code to get value of global FBT_THRESHOLD
*** 27-Dec-06 ksingla      115.78  Bug#5708255   Added to_number to all occurrences of  g_fbt_threshold
*** 8-Jan-06 ksingla       115.79  Bug#5743196   Added nvl to cursor c_allowance_balance
*** 13-Feb-06 priupadh     115.80  N/A       Version for restoring Triple Maintanence between 11i-->R12(Branch) -->R12(MainLine)
*** 24-May-06 priupadh     115.81  Bug#6069614   Removed the if conditions which checks the death benefit type other then 'Dependent'
*** 06-Jun-06 priupadh     115.82  Bug#6112527   Added the condition removed for Bug#6069614 with check that only archive termination type death/dependent if Fin Year is 2007/2008 or greater.
*** 20-Mar-08 avenkatk     115.84  Bug#6839263   Added changes for support of XML migrated reports in R12.1
**  21-Mar-08 avenkatk     115.85  Bug#6839263   Added Logic to set the OPP Template options for PDF output
*** 26-May-08 bkeshary     115.86  Bug#7030285   Modified the calculation for Assessable Income
*** 26-May-08 bkeshary     115.87  Bug#7030285   Added File Change History
*** 18-Jun-08 avenkatk     115.88  Bug#7138494   Added Changes for RANGE_PERSON_ID
*** 18-Jun-08 avenkatk     115.89  Bug#7138494   Modified Allowance Cursor for peformance
*** 01-Jul-08 avenkatk     115.90  Bug#7138494   Modified Allowance Cursor - Added ORDERED HINT
*** 02-Dec-08 skshin       115.91  Bug#7571001   Enabled Group Level Dimension for Allowances
*** 20-JAN-09 skshin       115.92  Bug#7571001   Modified cursors as suggested by comments in bug 7571001 and added comments
*** 28-Apr-09 pmatamsr     115.93  Bug#8441044   Cursor c_get_pay_effective_date is modified to consider Lump Sum E payments for payment summary gross calculation
***                                              for action types 'B' and 'I'.
*** 23-Jun-09 pmatamsr     115.94  Bug#8587013   Added changes to support archival of balances 'Reportable Employer Superannuation Contributions' and
***                                              'Exempt Foreign Employment Income' introduced as part of PS changes 2009 and removed the reporting of Other Income balance.
*** 07-Sep-09 pmatamsr     115.95  Bug#8769345   Modified functions populate_bal_ids ,etp_details and procedure get_assgt_curr_term_values_bbr to support ETP Taxable and Tax Free
***                                              balances introduced as part of statutory changes to super rollover.
*** 19-Nov-09 skshin       115.98  Bug#8711855   Modified Total_Lump_Sum_E_Payments procedure to call get_lumpsumE_value function and changed g_input_term_details_table index ids
*** 15-Dec-09 pmatamsr     115.99  Bug#9190980   Added a new argument v_adj_lump_sum_pre_tax in call to get_lumpsumE_value function.
*** 13-Jan-09 pmatamsr     115.100 Bug#9226023   Added logic to support the calculation of ETP taxable and Tax Free components for terminated employees processed
***                                              before applying the patch 8769345.
*/

   g_debug boolean; --Bug#3193479
   g_pre01jul1983_value number;
   g_post30jun1983_value number;
   g_etp_gross number;
   g_etp_tax number;
   g_assessable number;
   g_lump_sum_e number;
   g_total_cdep number;
   g_total_allowance number;
   g_total_fbt number;
   g_total_gross number;
 /* Begin 8587013 - Package variables declared to hold the totals of RESC and Exempt Foreign Employment Income balances*/
   g_total_resc number;
   g_total_foreign_income number;
 /* End 8587013 */
   g_business_group_id hr_organization_units.organization_id%type;
   x number;
   g_total_workplace number; /*4015082 */
   g_balance_type_tab            g_bal_type_tab;
   g_fbt_threshold ff_globals_f.global_value%TYPE ; /* Bug 5708255 */


  /*Bug 8587013 - Removed Other Income balance from Gross Calculation*/
   Function total_gross
   return number is
   l_total_earnings_asg_ytd number;
   l_allowance_total number;
   l_cdep_asg_ytd number;
   l_other_income_asg_ytd number;
   l_lump_sum_e_payments_asg_ytd number;
   l_total_gross number;

   begin

      -- Bug: 3186840 Check against the global Dimension level value included to return the correct value.
      IF (g_bal_dim_level = 'N') THEN
         l_total_earnings_asg_ytd:= get_bal_value_new(g_db_id_et) + get_bal_value_new(g_db_id_lpm);
                --   Bug# 3193479
      END IF;
   l_total_gross:=l_total_earnings_asg_ytd-greatest(g_total_allowance,0)-g_total_cdep
                  -g_lump_sum_e + g_total_workplace; /*4015082 */
   g_total_gross := l_total_gross;
   return l_total_gross;

   end total_gross;


/**************
bug 7571001 : new function - adjust_retro_group_allowances
This is called from get_total_allowances function for group level calculation to adjust allowance
Very similar to pay_au_payment_summary.adjust_retro_allowances excpet for an individual assignment
**************/

  function adjust_retro_group_allowances(t_allowance_balance IN OUT NOCOPY pay_au_payment_summary.t_allowance_balance%type
     ,p_year_start              in   DATE
     ,p_year_end                in   DATE
     ,p_registered_employer     in   NUMBER --2610141
     )
  return number  is

/* This cursor is similar to Get_retro_Entry_ids cursor in pay_au_payment_summary.adjust_retro_allowances
    except paa.assignment_id        = c_assignment_id
*/
  CURSOR Get_retro_Entry_ids(c_year_start DATE,
                         c_year_end   DATE)
  IS
  SELECT  /*+ INDEX(ppa pay_payroll_actions_pk)
              INDEX(pps per_periods_of_service_pk) */
          pee.element_entry_id element_entry_id,
          ppa.date_earned date_earned,
          pee.assignment_id assignment_id,
          pac.tax_unit_id,
          pdb.balance_type_id
FROM    per_all_assignments_f  paa
       ,per_periods_of_service pps
       ,pay_assignment_actions pac
       ,pay_payroll_actions    ppa
       ,pay_element_entries_f pee
       ,pay_run_results        prr
       ,pay_element_types_f    pet
       , PAY_BAL_ATTRIBUTE_DEFINITIONS pbad
       , PAY_BALANCE_ATTRIBUTES pba
       ,pay_defined_balances pdb
       ,pay_balance_dimensions pbd
       ,PAY_BALANCE_FEEDS_F pbf
       ,pay_input_values_f piv
     WHERE pbad.attribute_name = 'AU_EOY_ALLOWANCE'
     AND pbad.attribute_id = pba.attribute_id
     AND pba.defined_balance_id = pdb.defined_balance_id
     AND pbd.balance_dimension_id = pdb.balance_dimension_id
     AND pbd.dimension_name = '_ASG_LE_YTD'
     and   pbd.legislation_code = 'AU'
     AND pdb.balance_type_id = pbf.balance_type_id
     AND pbf.input_value_id = piv.input_value_id
     AND piv.element_type_id = pet.element_type_id
     AND   pps.PERIOD_OF_SERVICE_ID = paa.PERIOD_OF_SERVICE_ID
     AND   NVL(pps.actual_termination_date,c_year_end)
           BETWEEN paa.effective_start_date AND paa.effective_end_date
     AND   pac.payroll_action_id = ppa.payroll_Action_id
     AND   pac.assignment_id = paa.assignment_id
     AND   pac.tax_unit_id   = p_registered_employer
     AND   ppa.effective_date BETWEEN c_year_start AND c_year_end
     AND   pac.assignment_Action_id = prr.assignment_Action_id
     AND   prr.element_type_id=pet.element_type_id
     AND   pee.element_entry_id=prr.source_id
     AND   pee.creator_type in ('EE','RR')
     AND   pee.assignment_id = paa.assignment_id
     AND   ppa.action_status='C'
     AND   pac.action_status='C'
     AND   ppa.date_earned between pee.effective_start_date and pee.effective_end_date
     AND   ppa.date_earned BETWEEN pet.effective_start_date AND  pet.effective_end_date
     AND   ppa.date_earned between pbf.effective_start_date and pbf.effective_end_date
     AND   ppa.date_earned between piv.effective_start_date and piv.effective_end_date
     ;


       Cursor Get_Retro_allowances(c_element_entry_id  pay_element_entries_f.element_entry_id%type,
                                                                c_balance_type_id pay_defined_balances.defined_balance_id%type)
       IS
        select  NVL(pbt.reporting_name,pbt.balance_name)  balance_name  /* Bug 5743196 Added nvl */
                     ,prv.result_value balance_value
        from
        pay_element_entries_f pee,
        pay_run_results prr,
        pay_run_result_values prv,
        pay_element_types_f    pet,
        pay_balance_types      pbt
       ,PAY_BALANCE_FEEDS_F pbf
       ,pay_input_values_f piv
        where
        pee.element_entry_id=c_element_entry_id
        and prv.run_result_id=prr.run_result_id
        AND pee.element_entry_id=prr.source_id
        AND prr.element_type_id=pet.element_type_id
        AND pbt.balance_type_id = c_balance_type_id
        AND pbt.balance_type_id = pbf.balance_type_id
        AND pbf.input_value_id = piv.input_value_id
        AND piv.element_type_id = pet.element_type_id
        AND pee.effective_start_date between pet.effective_start_date and pet.effective_end_date
        AND pee.effective_start_date between pbf.effective_start_date and pbf.effective_end_date
        AND pee.effective_start_date between piv.effective_start_date and piv.effective_end_date
        ;

        CURSOR get_legislation_rule
        IS
        SELECT plr.rule_mode
        FROM   pay_legislation_rules plr
        WHERE  plr.legislation_code = 'AU'
        AND    plr.rule_type ='ADVANCED_RETRO';

       rec_retro_Allowances Get_retro_Allowances%ROWTYPE;
       TYPE r_ret_allowances IS RECORD(balance_name  pay_balance_types.balance_name%TYPE,
                                                                         balance_value Number);
       TYPE tab_ret_allowances IS TABLE OF r_ret_allowances INDEX BY BINARY_INTEGER;
       t_ret_allowances tab_ret_allowances;

       rec_ret_entry_ids Get_retro_Entry_ids%ROWTYPE;


     ret_counter Number;
     retro_start date;
     retro_end date;
     x number;
     orig_eff_date date;
     retro_eff_date date;
     time_span varchar2(10);
     retro_type varchar2(50);
     l_adv_retro_flag pay_legislation_rules.rule_mode%TYPE;

     Begin
       g_debug := hr_utility.debug_enabled;
       ret_counter := 1;

     OPEN get_legislation_rule;
     FETCH get_legislation_rule INTO l_adv_retro_flag;
     IF  get_legislation_rule%NOTFOUND THEN
        l_adv_retro_flag := 'N';
     END IF;
     CLOSE get_legislation_rule;

     /* Retropay by element - logic for Retropay By Element is used */

    IF l_adv_retro_flag <> 'Y'
    THEN

       OPEN Get_retro_Entry_ids(p_year_start,p_year_end);
       LOOP
       FETCH Get_retro_Entry_ids INTO rec_ret_entry_ids;
       IF Get_retro_Entry_ids%NOTFOUND Then
          IF g_debug THEN
          hr_utility.set_location('Get_retro_Entry_Id: not found',1);
      END if;
      Exit;
       End If;
      IF g_debug THEN
        hr_utility.set_location('Calling Get Retro Periods',2);
      END if;

       x:=pay_au_paye_ff.get_retro_period(rec_ret_entry_ids.element_entry_id,
                                          rec_ret_entry_ids.date_earned,
                                          p_registered_employer, /*Bug 4418107*/
                                          retro_start,
                                          retro_end);

      IF g_debug THEN
      hr_utility.set_location('Back from call to Get Retro Periods',3);
      END if;

       IF months_between(rec_ret_entry_ids.date_earned,retro_end) > 12 then
          IF g_debug THEN
                  hr_utility.set_location('Getting Retro Allowance  Greater than 12 months',4);
          END if;

          OPEN  Get_retro_Allowances(rec_ret_entry_ids.element_entry_id, rec_ret_entry_ids.balance_type_id);
          FETCH Get_retro_Allowances INTO rec_retro_Allowances;
          CLOSE Get_retro_Allowances;


           If NVL(rec_retro_Allowances.balance_value,0) > 0 Then

              t_ret_allowances(ret_counter).balance_name   := rec_retro_Allowances.balance_name;
              t_ret_allowances(ret_counter).balance_value  := rec_retro_Allowances.balance_value;
              ret_counter := ret_counter+1;
           End If;

      END IF;
    END LOOP;

    CLOSE Get_retro_Entry_ids;


   if t_ret_allowances.count > 0 then
    For i in 1..t_ret_allowances.last
    LOOP
        For j in 1..t_allowance_balance.last
        LOOP
          if t_ret_allowances(i).balance_name = t_allowance_balance(j).balance_name then
          t_allowance_balance(j).balance_value := t_allowance_balance(j).balance_value - t_ret_allowances(i).balance_value;
          exit;
           end if;
        END LOOP;
    END LOOP;
   end if;

  t_ret_allowances.delete;

/*Enh Retro    If Retrospective Payment Greater than 12 months then it is deducted from total allowance*/

 ELSE
 OPEN Get_retro_Entry_ids(p_year_start,p_year_end);
     LOOP
     FETCH Get_retro_Entry_ids INTO rec_ret_entry_ids;
      IF Get_retro_Entry_ids%NOTFOUND Then
          IF g_debug THEN
          hr_utility.set_location('Get_retro_Entry_Id: not found',1);
          END if;
       Exit;
      End If;
      IF g_debug THEN
        hr_utility.set_location('Calling Get Retro Time Span',2);
      END if;

       x:= pay_au_paye_ff.get_retro_time_span(rec_ret_entry_ids.element_entry_id,
                                          rec_ret_entry_ids.date_earned,
                                          rec_ret_entry_ids.tax_unit_id,
                                          retro_start,
                                          retro_end,
                                          orig_eff_date,
                                          retro_eff_date,
                                          time_span,
                                          retro_type);
      IF g_debug THEN
      hr_utility.set_location('Back from call to Get Retro Time Span',3);
      END if;
      IF time_span ='GT12' then
          IF g_debug THEN
                  hr_utility.set_location('Getting Retro Allowance  Greater than 12 months',4);
          END if;
          OPEN  Get_retro_Allowances(rec_ret_entry_ids.element_entry_id, rec_ret_entry_ids.balance_type_id);
          FETCH Get_retro_Allowances INTO rec_retro_Allowances;
          CLOSE Get_retro_Allowances;

           If NVL(rec_retro_Allowances.balance_value,0) > 0 Then
              t_ret_allowances(ret_counter).balance_name   := rec_retro_Allowances.balance_name;
              t_ret_allowances(ret_counter).balance_value  := rec_retro_Allowances.balance_value;
              ret_counter := ret_counter+1;

           End If;
      END IF;
    END LOOP;

    CLOSE Get_retro_Entry_ids;

   if t_ret_allowances.count > 0 then
    For i in 1..t_ret_allowances.last
    LOOP
        For j in 1..t_allowance_balance.last
        LOOP

          if t_ret_allowances(i).balance_name = t_allowance_balance(j).balance_name then
          t_allowance_balance(j).balance_value := t_allowance_balance(j).balance_value - t_ret_allowances(i).balance_value;

          exit;
          end if;
        END LOOP;
    END LOOP;
   end if;

  t_ret_allowances.delete;

END IF;
   return 1;

   End adjust_retro_group_allowances;

/***************
bug 7571001 - get_total_allowances function is entirely changed to enable group level reporting
                            pay_balance_pkg.get_value is called with different input values based on g_bal_dim_level
                            then pay_au_payment_summary.adjust_retro_allowances is called for 'N' dimension level or
                            adjust_retro_group_allowances is called for 'G'.
***************/
 Function get_total_allowances ( p_year_start           DATE,
                                                            p_year_end             DATE,
                                                            p_assignment_id        pay_assignment_actions.assignment_id%type,
                                                            p_assignment_action_id pay_assignment_actions.assignment_id%type,
                                                            p_tax_unit_id          hr_all_organization_units.organization_id%type)
 return number is

CURSOR get_alw_balance_name (p_def_bal_id pay_defined_balances.defined_balance_id%type) IS
select NVL(pbt.reporting_name,pbt.balance_name)
from pay_balance_types pbt, pay_defined_balances pdb
where pdb.defined_balance_id = p_def_bal_id
and pdb.balance_type_id = pbt.balance_type_id
;

t_allowance_balance pay_au_payment_summary.t_allowance_balance%type;
l_balance_name pay_balance_types.balance_name%type;
cnt number := 1;
counter number := 1;
i number;

begin

    g_debug :=hr_utility.debug_enabled ;

     if g_debug then
     hr_utility.set_location('Entering get_total_allowances for assingment_id '||p_assignment_id, 0);
     end if;

IF (g_bal_dim_level = 'N') THEN

        IF g_input_alw_table.count > 0 THEN

              g_result_alw_table.delete;
              t_allowance_balance.delete;

              pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
              p_defined_balance_lst=>g_input_alw_table,
              p_context_lst =>g_context_table,
              p_output_table=>g_result_alw_table);

            FOR i in g_result_alw_table.first .. g_result_alw_table.last LOOP

              IF g_result_alw_table.exists(i) THEN
                  if nvl(g_result_alw_table(i).balance_value,0) >0 then

                      open get_alw_balance_name(g_result_alw_table(i).defined_balance_id);
                      fetch get_alw_balance_name into l_balance_name;
                      close get_alw_balance_name;

                   t_allowance_balance(cnt).balance_name  := l_balance_name;
                   t_allowance_balance(cnt).balance_value := g_result_alw_table(i).balance_value;

                    if g_debug then
                      hr_utility.trace('N t_allowance_ balance name ('||cnt||') = '|| t_allowance_balance(cnt).balance_name);
                      hr_utility.trace('N t_allowance_balance value ('||cnt||') = '||t_allowance_balance(cnt).balance_value);
                    end if;

                    cnt := cnt + 1;

                end if;
              END IF;

            END LOOP;

            IF t_allowance_balance.count >0 THEN

                    i := pay_au_payment_summary.adjust_retro_allowances
                         (t_allowance_balance
                         ,p_year_start
                         ,p_year_end
                         ,p_assignment_id
                         ,p_tax_unit_id --2610141
                         );


                      For i in t_allowance_balance.first .. t_allowance_balance.last LOOP
                          If t_allowance_balance.EXISTS(i) Then
                              g_total_allowance:=g_total_allowance+nvl(t_allowance_balance(i).balance_value,0);
                                      if g_debug then
                                      hr_utility.trace('N1 t_allowance_ balance name ('||cnt||') = '|| t_allowance_balance(i).balance_name);
                                      hr_utility.trace('N1 t_allowance_balance value ('||cnt||') = '||t_allowance_balance(i).balance_value);
                                      end if;
                          End If;
                      END LOOP;
            ELSE
                g_total_allowance := 0;
            END IF;
         END IF;

ELSIF (g_bal_dim_level = 'G') THEN


            IF g_input_group_alw_table.count > 0 THEN

                     g_result_group_alw_table.delete;
                     t_allowance_balance.delete;

                     pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
                                         p_defined_balance_lst  => g_input_group_alw_table,
                                         p_context_lst          => g_context_table,
                                         p_output_table         => g_result_group_alw_table);

                      FOR i in g_result_group_alw_table.first .. g_result_group_alw_table.last LOOP

                        IF g_result_group_alw_table.exists(i) THEN
                            if nvl(g_result_group_alw_table(i).balance_value,0) >0 then

                                open get_alw_balance_name(g_result_group_alw_table(i).defined_balance_id);
                                fetch get_alw_balance_name into l_balance_name;
                                close get_alw_balance_name;

                             t_allowance_balance(counter).balance_name  := l_balance_name;
                             t_allowance_balance(counter).balance_value := g_result_group_alw_table(i).balance_value;

                              if g_debug then
                                 hr_utility.trace('G t_allowance_ balance name ('||counter||') = '|| t_allowance_balance(counter).balance_name);
                                hr_utility.trace('G t_allowance_balance value ('||counter||') = '||t_allowance_balance(counter).balance_value);
                              end if;

                              counter := counter + 1;

                          end if;
                        END IF;

                      END LOOP;

                      IF t_allowance_balance.count >0 THEN
                        i := adjust_retro_group_allowances
                             (t_allowance_balance
                             ,p_year_start
                             ,p_year_end
                             ,p_tax_unit_id --2610141
                             );


                          For i in t_allowance_balance.first .. t_allowance_balance.last LOOP
                              If t_allowance_balance.EXISTS(i) Then
                                  g_total_allowance:=g_total_allowance+nvl(t_allowance_balance(i).balance_value,0);
                                      if g_debug then
                                      hr_utility.trace('G1 t_allowance_ balance name ('||cnt||') = '|| t_allowance_balance(i).balance_name);
                                      hr_utility.trace('G1 t_allowance_balance value ('||cnt||') = '||t_allowance_balance(i).balance_value);
                                      end if;
                              End If;
                          END LOOP;
                      ELSE
                          g_total_allowance := 0;
                      END IF;

          END IF;

END IF;

return nvl(g_total_allowance,0);

     if g_debug then
     hr_utility.set_location('Returned g_total_allowace : '||nvl(g_total_allowance,0), 888);
     hr_utility.set_location('Leaving get_total_allowances for assingment_id '||p_assignment_id, 999);
     end if;

end get_total_allowances;



  Function get_total_fbt(c_year_start             DATE,
                          c_assignment_id        pay_assignment_actions.assignment_id%type,
              p_tax_unit_id hr_all_organization_units.organization_id%TYPE,
                          c_fbt_rate ff_globals_f.global_value%TYPE,
                          c_ml_rate ff_globals_f.global_value%TYPE,
              p_termination VARCHAR2)
   return number is

   l_total_fbt number;
   l_reporting_amt number;
   l_fbt_rate number;
   l_medicare_levy number;
   l_fbt_ratio number;
   l_max_asg_action_id       pay_assignment_actions.assignment_action_id%type;

   /* Bug: 3603495 - Performance Fix - Introduced per_assignments_f and its joins in the following cursor */
   /* Bug: 4015571 - Modified cursor c_max_asg_action_id - Modified action_type join in sub query
                      to restrict the max action_sequence fetch to types 'Q','R','B','I'
      Bug: 4256506 - Changed cursor c_max_asg_action_id. Merged sub query to fetch max action sequemce in main query. Done for
                     better performance.
   */
   cursor c_max_asg_action_id (c_assignment_id      per_all_assignments_f.assignment_id%TYPE,
                  c_business_group_id  hr_all_organization_units.organization_id%TYPE,
                  c_tax_unit_id        hr_all_organization_units.organization_id%TYPE,
                  c_year_start     date,
                  c_year_end       date ) is
 select    to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) assignment_action_id
    from     pay_assignment_actions      paa
           , pay_payroll_actions         ppa
           , per_assignments_f           paf
    where   paa.assignment_id          = paf.assignment_id
            and paf.assignment_id      = c_assignment_id
            and ppa.payroll_action_id  = paa.payroll_action_id
            and ppa.effective_date      between c_year_start and c_year_end
            and ppa.payroll_id         =  paf.payroll_id
            and ppa.action_type        in ('R', 'Q', 'I', 'V', 'B')
            and ppa.effective_date between paf.effective_start_date and paf.effective_end_date
            and paa.action_status='C'
            AND paa.tax_unit_id = c_tax_unit_id;


   /* Bug 5708255 */
  -------------------------------------------
  -- Added cursor to get value of global FBT_THRESHOLD
  --------------------------------------------
CURSOR  c_get_fbt_global(c_year_end DATE)
       IS
   SELECT  global_value
   FROM   ff_globals_f
    WHERE  global_name = 'FBT_THRESHOLD'
    AND    legislation_code = 'AU'
    AND    c_year_end BETWEEN effective_start_date
                          AND effective_end_date ;


   begin


   --- Bug#3213539-------------------------------------------
    IF p_termination IS NULL THEN
        open c_max_asg_action_id (    c_assignment_id,    --Bug# 3193479
                          g_business_group_id,
                          p_tax_unit_id,
                          add_months(c_year_start,-3),
                          add_months(c_year_start,9)-1);  --Bug3693034 - Modified to fetch action upto 31-Mar
        fetch c_max_asg_action_id into l_max_asg_action_id;
        close c_max_asg_action_id;
    ELSE
        open c_max_asg_action_id (    c_assignment_id,    --Bug# 3193479
                          g_business_group_id,
                          p_tax_unit_id,
                          add_months(c_year_start,-3),
                          (c_year_start-1));
        fetch c_max_asg_action_id into l_max_asg_action_id;
        close c_max_asg_action_id;
    END IF;

      /* Bug#3525563 - Added IF condition to call pay_balance_pkg.get_value when l_max_asg_action_id is not null. */
       IF l_max_asg_action_id is not null then
          l_total_fbt := pay_balance_pkg.get_value(g_fbt_defined_balance_id,
                               l_max_asg_action_id,p_tax_unit_id, null,null,null,null);
       ELSE
          l_total_fbt := 0;
       END IF;
       /* End of Bug#3525563 */

  /* Bug 5708255 */
open c_get_fbt_global (add_months(add_months(c_year_start,9)-1,-3));  /* Add_months included for bug 5333143 */
fetch c_get_fbt_global into g_fbt_threshold;
 close c_get_fbt_global;


       ------------End of Bug#3213539 ---------------------
       IF l_total_fbt <= to_number(g_fbt_threshold) THEN  /* Bug 5708255 */
        l_total_fbt := 0;
       END IF;

       l_fbt_rate := to_number(c_fbt_rate);
       l_medicare_levy :=to_number(c_ml_rate);

       l_fbt_ratio:=1-(l_fbt_rate+l_medicare_levy);

       if l_fbt_ratio <> 0 then
       l_reporting_amt := l_total_fbt/l_fbt_ratio;
       else
       l_reporting_amt := 0;
       end if;

       l_reporting_amt := round(l_reporting_amt,2);

       g_total_fbt := nvl(l_reporting_amt,0);
       return g_total_fbt;
   end get_total_fbt;





   function get_total_cdep
   return number is
   begin

      -- Bug: 3186840 Check against the global Dimension level value included to return the correct value.

      IF (g_bal_dim_level = 'N') THEN
         g_total_cdep := get_bal_value_new(g_db_id_cdep);--Bug# 3193479
      ELSIF (g_bal_dim_level = 'G') THEN
         g_total_cdep := g_result_group_details_table(10).balance_value;
      END IF;
   return g_total_cdep;

   end get_total_cdep;

/* 4015082 */
  function get_total_workplace
   return number is
   begin

      -- Bug: 3186840 Check against the global Dimension level value included to return the correct value.

      IF (g_bal_dim_level = 'N') THEN
         g_total_workplace := get_bal_value_new(g_db_id_wgd);
      ELSIF (g_bal_dim_level = 'G') THEN
         g_total_workplace := g_result_group_details_table(12).balance_value;
      END IF;
   return g_total_workplace;

   end get_total_workplace;

   function Total_Lump_Sum_A_Payments
   return number is
   l_lump_sum_a number;
   begin

      -- Bug: 3186840 Check against the global Dimension level value included to return the correct value.

      IF (g_bal_dim_level = 'N') THEN
         l_lump_sum_a :=get_bal_value_new(g_db_id_lsap);--Bug# 3193479
      ELSIF (g_bal_dim_level = 'G') THEN
         l_lump_sum_a := g_result_group_details_table(1).balance_value;
      END IF;

      return l_lump_sum_a;
   end Total_Lump_Sum_A_Payments;


   function Total_Lump_Sum_B_Payments
   return number is
   l_lump_sum_b number;
   begin

      -- Bug: 3186840 Check against the global Dimension level value included to return the correct value.

      IF (g_bal_dim_level = 'N') THEN
         l_lump_sum_b := get_bal_value_new(g_db_id_lsbp);--Bug# 3193479
      ELSIF (g_bal_dim_level = 'G') THEN
         l_lump_sum_b := g_result_group_details_table(2).balance_value;
      END IF;

      return l_lump_sum_b;
   end Total_Lump_Sum_B_Payments;


   function Total_Lump_Sum_D_Payments
   return number is
   l_lump_sum_d number;
   begin

      -- Bug: 3186840 Check against the global Dimension level value included to return the correct value.

      IF (g_bal_dim_level = 'N') THEN
         l_lump_sum_d:= get_bal_value_new(g_db_id_lsdp);--Bug# 3193479
      ELSIF (g_bal_dim_level = 'G') THEN
         l_lump_sum_d := g_result_group_details_table(3).balance_value;
      END IF;

      return l_lump_sum_d;

   end Total_Lump_Sum_D_Payments;


/*bug8711855 - p_assignment_action_id parameter is added to call pay_au_payment_summary.get_retro_lumpsumE_value function */
   function Total_Lump_Sum_E_Payments(c_year_end             DATE,
                                      c_assignment_id        pay_assignment_actions.assignment_id%type,
                                      c_registered_employer  NUMBER) --2610141
   return number is

   /*bug8711855 - Fetching Defined_Balance_Ids of Lump Sum E balances_PTD*/
   CURSOR  c_single_lumpsum_E_payment  IS
   SELECT decode(pbt.balance_name,
                              'Lump Sum E Payments', 1
                             ,'Retro Earnings Leave Loading GT 12 Mths Amount', 2
                             ,'Retro Earnings Spread GT 12 Mths Amount', 3
                             ,'Retro Pre Tax GT 12 Mths Amount', 4) sort_index
               , pdb.defined_balance_id defined_balance_id
   FROM  pay_balance_types      pbt,
         pay_defined_balances   pdb,
         pay_balance_dimensions pbd
   WHERE pbt.legislation_code = 'AU'
   AND  pbt.balance_name in ( 'Lump Sum E Payments'
                             ,'Retro Earnings Leave Loading GT 12 Mths Amount'
                             ,'Retro Earnings Spread GT 12 Mths Amount'
                             ,'Retro Pre Tax GT 12 Mths Amount')
   AND  pbt.balance_type_id = pdb.balance_type_id
   AND  pbd.balance_dimension_id = pdb.balance_dimension_id
   AND  pbd.dimension_name = '_ASG_LE_PTD'
   order by sort_index;

    v_lump_sum_E_ptd number;
    v_effective_date date;  /* Bug#3095923 */
    c_year_start     date;
    l_assignment_action_id number; --2610141
    v_adj_lump_sum_E_ptd     number;  --bug8711855
    p_lump_sum_E_ptd_tab pay_balance_pkg.t_balance_value_tab; --bug8711855
    v_adj_lump_sum_pre_tax number; /* Bug 9190980 */

   begin
   c_year_start := to_date('01-07-'||to_char(to_number(to_char(c_year_end,'YYYY'))-1),'DD-MM-YYYY');

   IF (g_bal_dim_level = 'N') THEN
      g_lump_sum_e := get_bal_value_new(g_db_id_lsep) + get_bal_value_new(g_db_id_rll)
                      + get_bal_value_new(g_db_id_res) - get_bal_value_new(g_db_id_rpt) ; --bug8711855
   ELSIF (g_bal_dim_level = 'T') THEN
      g_lump_sum_e := g_result_term_details_table(1).balance_value + g_result_term_details_table(2).balance_value
                      + g_result_term_details_table(3).balance_value - g_result_term_details_table(4).balance_value; --bug8711855
   END IF;

   p_lump_sum_E_ptd_tab.delete;
   for csr_rec in c_single_lumpsum_E_payment loop
     p_lump_sum_E_ptd_tab(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;
   end loop;

         /* bug8711855 - To adjust Lump Sum E with single lump sum e payments less than 400*/
	 /* Bug 9190980 - Added argument in call to get_lumpsumE_value function */
         if g_lump_sum_e <> 0 then

               g_lump_sum_e := pay_au_payment_summary.get_lumpsumE_value(c_registered_employer, c_assignment_id, c_year_start,
                                                           c_year_end, p_lump_sum_E_ptd_tab, g_lump_sum_e, v_adj_lump_sum_E_ptd,v_adj_lump_sum_pre_tax); -- Bug 9190980

         end if;

   return g_lump_sum_e;

   end Total_Lump_Sum_E_Payments;


   function Total_Union_fees
   return number is
   l_union_fees number;
   begin

      -- Bug: 3186840 Check against the global Dimension level value included to return the correct value.

      IF (g_bal_dim_level = 'N') THEN
         l_union_fees:=get_bal_value_new(g_db_id_uf);--Bug# 3193479
      ELSIF (g_bal_dim_level = 'G') THEN
         l_union_fees := g_result_group_details_table(4).balance_value;
      END IF;

      return l_union_fees;

   end Total_Union_fees;

   /* Bug#3004966 - Modified the Logic for the function
      for performance improvement. */
   function Total_Tax_deductions
   return number is

   l_total_tax_ded number := 0;
   i number;
   l_temp number;

   BEGIN --Bug# 3193479 -- Bug #3215789

      -- Bug: 3186840 Check against the global Dimension level value included to return the correct value.

      IF (g_bal_dim_level = 'N') THEN
         l_total_tax_ded := get_bal_value_new(g_db_id_lscd) * (-1) + get_bal_value_new(g_db_id_td) + get_bal_value_new(g_db_id_ttd);
      ELSIF (g_bal_dim_level = 'G') THEN
         l_total_tax_ded := g_result_group_details_table(5).balance_value * (-1) + g_result_group_details_table(6).balance_value +
                            g_result_group_details_table(7).balance_value;
      END IF;

      return l_total_tax_ded;

   end Total_Tax_deductions;

   /* End of Bug#3004966 */

   /* Begin 8587013 - Added functions Total_RESC and Total_Foreign_Income for total values calculation of
                      RESC and Exempt Foreign Employment Income balances */
   function Total_RESC
   return number is
   begin

      IF (g_bal_dim_level = 'N') THEN
         g_total_resc:=get_bal_value_new(g_db_id_resc);--Bug# 3193479
      ELSIF (g_bal_dim_level = 'G') THEN
         g_total_resc := g_result_group_details_table(11).balance_value;
      END IF;

      return g_total_resc;

   end Total_RESC;

   function Total_Foreign_Income
   return number is
   begin

      IF (g_bal_dim_level = 'N') THEN
         g_total_foreign_income:=get_bal_value_new(g_db_id_efei);--Bug# 3193479
      ELSIF (g_bal_dim_level = 'G') THEN
         g_total_foreign_income := g_result_group_details_table(13).balance_value;
      END IF;

      return g_total_foreign_income;

   end Total_Foreign_Income;

  /* End 8587013 */

   function Total_Invalidity_Payments
   return number is
   l_total_invalidity_payments number;
   begin

      -- Bug: 3186840 Check against the global Dimension level value included to return the correct value.

      IF (g_bal_dim_level = 'N') THEN
         l_total_invalidity_payments:=get_bal_value_new(g_db_id_ip);--Bug# 3193479
      ELSIF (g_bal_dim_level = 'T') THEN
         l_total_invalidity_payments := g_result_term_details_table(6).balance_value;
      END IF;

      return l_total_invalidity_payments;

   end Total_Invalidity_Payments;

   --Bug#3749530 - Function modified to set globals parmaters
   function populate_bal_ids(p_le_level IN varchar2 DEFAULT NULL,
                             p_business_group_id hr_organization_units.organization_id%type,
                             p_lst_yr_term VARCHAR2 DEFAULT NULL )  return number
   is

   /* Bug#3004966 - Added two Balances 'Termination Deductions', 'Total_Tax_Deductions'*/
   /* Bug 8587013 - Added two balances 'Reportable Employer Superannuation Contributions' and 'Exempt Foreign Employment Income'
                    and removed 'Other Income' balance */
   /* Bug 8769345 - Added ETP Taxable and Tax Free balances to the cursor */
   CURSOR c_bal_id (c_dimension_name pay_balance_dimensions.dimension_name%TYPE) IS
      SELECT pbt.balance_name,pbt.balance_type_id,pdb.defined_balance_id
            from pay_balance_types       pbt,
             pay_defined_balances         pdb,  --Bug# 3193479
         pay_balance_dimensions       pbd
                 where  pbt.legislation_code = 'AU'
                 and   pbt.balance_name in
                                            ('CDEP','Earnings_Total','Lump Sum A Deductions',
                                              'Lump Sum A Payments','Lump Sum B Deductions','Lump Sum B Payments',
                                              'Lump Sum D Payments','Lump Sum E Payments','Total_Tax_Deductions',
                                              'Union Fees','Invalidity Payments','Lump Sum C Payments',
                                              'Lump Sum C Deductions','Leave Payments Marginal','Termination Deductions'
                                                , 'Workplace Giving Deductions'  /* 4015082 */
                        , 'Reportable Employer Superannuation Contributions' /* 8587013 */
                        , 'Exempt Foreign Employment Income' /* 8587013 */
                        , 'ETP Tax Free Payments Transitional Not Part of Prev Term' /* Start 8769345 */
                                                , 'ETP Taxable Payments Transitional Not Part of Prev Term'
                                                , 'ETP Tax Free Payments Transitional Part of Prev Term'
                        , 'ETP Taxable Payments Transitional Part of Prev Term'
                                                , 'ETP Tax Free Payments Life Benefit Not Part of Prev Term'
                                                , 'ETP Taxable Payments Life Benefit Not Part of Prev Term'
                        , 'ETP Tax Free Payments Life Benefit Part of Prev Term'
                                                , 'ETP Taxable Payments Life Benefit Part of Prev Term' /* End 8769345 */
                                                , 'Retro Earnings Leave Loading GT 12 Mths Amount' --bug8711855
                                                , 'Retro Earnings Spread GT 12 Mths Amount'
                                                , 'Retro Pre Tax GT 12 Mths Amount'
                                            )
         AND    pdb.balance_type_id            = pbt.balance_type_id
         AND    pdb.balance_dimension_id       = pbd.balance_dimension_id
         AND    pbd.legislation_code           = 'AU'
         AND    pdb.legislation_code           = 'AU'
         AND    pbd.dimension_name             = c_dimension_name;

/* start bug 7571001 - new cursor c_alw_bal_id is added */
CURSOR c_alw_bal_id  IS
  select  pbt.balance_name
            , pdb.defined_balance_id
  from  PAY_BAL_ATTRIBUTE_DEFINITIONS pbad
            ,pay_balance_attributes pba
            ,pay_defined_balances        pdb
            ,pay_balance_types           pbt
            ,pay_balance_dimensions pbd
  where  pbad.attribute_name = 'AU_EOY_ALLOWANCE'
     and   pba.attribute_id = pbad.attribute_id
     and   pba.defined_balance_id = pdb.defined_balance_id
     and   pdb.balance_type_id = pbt.balance_type_id
     and   pdb.business_group_id = p_business_group_id
     and   pbd.balance_dimension_id = pdb.balance_dimension_id
     and   pbd.dimension_name = '_ASG_LE_YTD'
     and  pbd.legislation_code = 'AU'
     ;

   l_alw_bal_name pay_balance_types.balance_name%type;
   l_alw_def_bal_id     pay_defined_balances.defined_balance_id%TYPE;
   cnt number := 1;
/* end bug 7571001 - new cursor c_alw_bal_id is added */

   i number;
   l_bal_name pay_balance_types.balance_name%type;
   l_bal_id pay_balance_types.balance_type_id%type;
   l_def_bal_id     pay_defined_balances.defined_balance_id%TYPE;   --Bug# 3193479
   c_dimension_name     pay_balance_dimensions.dimension_name%TYPE; -- Bug: 3186840
   g_debug              boolean;

    Cursor c_fbt_balance IS --Bug#3749530
      select        pdb.defined_balance_id
      from          pay_balance_types            pbt,
                    pay_defined_balances         pdb,
                    pay_balance_dimensions       pbd
      where  pbt.balance_name               ='Fringe Benefits'
      and  pbt.balance_type_id            = pdb.balance_type_id
      and  pdb.balance_dimension_id       = pbd.balance_dimension_id
      and  pbd.legislation_code           ='AU'
      and  pbd.dimension_name             ='_ASG_LE_FBT_YTD' --2610141
      and  pbd.legislation_code = pbt.legislation_code
      and  pbd.legislation_code = pdb.legislation_code;

   BEGIN
      g_debug := hr_utility.debug_enabled;

      ---Start of Bug#3749530------------------
      g_business_group_id := p_business_group_id;
      g_lst_yr_term := NVL(p_lst_yr_term,'Y'); --Bug3693034

     -- Added for bug 3034189
       If g_fbt_defined_balance_id = 0 OR  g_fbt_defined_balance_id IS null Then
           Open  c_fbt_balance;
           Fetch c_fbt_balance into  g_fbt_defined_balance_id;
           Close c_fbt_balance;
       End if;
    -- End of Bug#3749530-----------------

   /* Start of Bug: 3186840 */

      IF (p_le_level = 'Y') THEN
         c_dimension_name := '_ASG_LE_YTD';
      ELSE
         c_dimension_name := '_ASG_YTD';
      END IF;

      IF g_debug THEN
         hr_utility.trace('Parameter p_le_level value => ' || p_le_level);
         hr_utility.trace('Dimension is => ' || c_dimension_name);
      END IF;

   /* End of Bug: 3186840 */

       i:=1;
       OPEN c_bal_id(c_dimension_name); -- Bug: 3186840
       LOOP
           FETCH c_bal_id INTO l_bal_name,l_bal_id,l_def_bal_id; --Bug# 3193479
           EXIT WHEN c_bal_id%NOTFOUND;

           IF l_bal_name = 'CDEP' THEN
               g_db_id_cdep := l_def_bal_id;
           ELSIF l_bal_name = 'Earnings_Total' THEN
               g_db_id_et := l_def_bal_id;
           ELSIF l_bal_name = 'Lump Sum A Deductions' THEN
               g_db_id_lsad := l_def_bal_id;
           ELSIF l_bal_name = 'Lump Sum A Payments' THEN
               g_db_id_lsap := l_def_bal_id;
           ELSIF l_bal_name = 'Lump Sum B Deductions' THEN
               g_db_id_lsbd := l_def_bal_id;
           ELSIF l_bal_name = 'Lump Sum B Payments' THEN
               g_db_id_lsbp := l_def_bal_id;
           ELSIF l_bal_name = 'Lump Sum D Payments' THEN
               g_db_id_lsdp := l_def_bal_id;
           ELSIF l_bal_name = 'Lump Sum E Payments' THEN
               g_db_id_lsep := l_def_bal_id;
           ELSIF l_bal_name = 'Total_Tax_Deductions' THEN
               g_db_id_ttd := l_def_bal_id;
           ELSIF l_bal_name = 'Union Fees' THEN
               g_db_id_uf := l_def_bal_id;
           ELSIF l_bal_name = 'Invalidity Payments' THEN
               g_db_id_ip := l_def_bal_id;
           ELSIF l_bal_name = 'Lump Sum C Payments' THEN
               g_db_id_lscp := l_def_bal_id;
           ELSIF l_bal_name = 'Lump Sum C Deductions' THEN
               g_db_id_lscd := l_def_bal_id;
           ELSIF l_bal_name = 'Leave Payments Marginal' THEN
               g_db_id_lpm := l_def_bal_id;
           ELSIF l_bal_name = 'Termination Deductions' THEN
               g_db_id_td  := l_def_bal_id;
           ELSIF l_bal_name = 'Workplace Giving Deductions' THEN  /* 4015082 */
               g_db_id_wgd  := l_def_bal_id;
           /* Begin 8587013 - Logic added for getting the defined_balance_id of two new balances */
           ELSIF l_bal_name = 'Reportable Employer Superannuation Contributions' THEN
               g_db_id_resc := l_def_bal_id;
           ELSIF l_bal_name = 'Exempt Foreign Employment Income' THEN
               g_db_id_efei := l_def_bal_id;
           /* End 8587013 */
       /* Start 8769345 - Added code for holding the defined balance ids of ETP Taxable and Tax Free balances in global variables*/
           ELSIF l_bal_name = 'ETP Tax Free Payments Transitional Not Part of Prev Term' THEN
               g_db_id_tftn := l_def_bal_id;
           ELSIF l_bal_name = 'ETP Taxable Payments Transitional Not Part of Prev Term' THEN
               g_db_id_ttn := l_def_bal_id;
       ELSIF l_bal_name = 'ETP Tax Free Payments Transitional Part of Prev Term' THEN
               g_db_id_tftp := l_def_bal_id;
           ELSIF l_bal_name = 'ETP Taxable Payments Transitional Part of Prev Term' THEN
               g_db_id_ttp := l_def_bal_id;
       ELSIF l_bal_name = 'ETP Tax Free Payments Life Benefit Not Part of Prev Term' THEN
               g_db_id_tfln := l_def_bal_id;
           ELSIF l_bal_name = 'ETP Taxable Payments Life Benefit Not Part of Prev Term' THEN
               g_db_id_tln := l_def_bal_id;
           ELSIF l_bal_name = 'ETP Tax Free Payments Life Benefit Part of Prev Term' THEN
               g_db_id_tflp := l_def_bal_id;
           ELSIF l_bal_name = 'ETP Taxable Payments Life Benefit Part of Prev Term' THEN
               g_db_id_tlp := l_def_bal_id;
       /* End 8769345 */
       /* Start 8711855 - Adeed code for holiding the defined balance ids of Retro GT12 balances (Lump Sum E)*/
           ELSIF l_bal_name = 'Retro Earnings Leave Loading GT 12 Mths Amount' THEN
               g_db_id_rll := l_def_bal_id;
           ELSIF l_bal_name = 'Retro Earnings Spread GT 12 Mths Amount' THEN
               g_db_id_res := l_def_bal_id;
           ELSIF l_bal_name = 'Retro Pre Tax GT 12 Mths Amount' THEN
               g_db_id_rpt := l_def_bal_id;
       /* End 8711855 */
           END IF;

           g_input_table(i).defined_balance_id  :=l_def_bal_id;--Bug# 3193479
           g_input_table(i).balance_value := NULL;

                   IF g_debug THEN
                     hr_utility.trace(i || ' Defined Balance id of ' || l_bal_name || '=> ' || g_input_table(i).defined_balance_id);
                   END IF;

           i:=i+1;
       END LOOP;
       CLOSE c_bal_id;

/* bug 7571001 - populating defined_balance_id for allowances */
     g_input_alw_table.delete;
     OPEN c_alw_bal_id;
     LOOP
        FETCH c_alw_bal_id into l_alw_bal_name, l_alw_def_bal_id;
        EXIT WHEN c_alw_bal_id%NOTFOUND;

            g_input_alw_table(cnt).defined_balance_id := l_alw_def_bal_id;
            g_input_alw_table(cnt).balance_value := NULL;

                   IF g_debug THEN
                     hr_utility.trace( ' Defined Balance id of ' || l_alw_bal_name || ' => ' || g_input_alw_table(cnt).defined_balance_id);
                   END IF;
            cnt := cnt + 1;
     END LOOP;

       ---Except Tax-Unit_id other Context table values are not required
       g_context_table(1).jurisdiction_code := NULL;
       g_context_table(1).source_id := NULL;
       g_context_table(1).source_text := NULL;
       g_context_table(1).source_number := NULL;
       g_context_table(1).source_text2 := NULL;

       RETURN 1;
   END populate_bal_ids;

   function etp_details
     (
       p_assignment_id           in   pay_assignment_actions.ASSIGNMENT_ID%type
      ,p_year_start             in   pay_payroll_Actions.effective_date%type
      ,p_year_end               in   pay_payroll_Actions.effective_date%type)
    return number     is

      e_prepost_error                EXCEPTION;

      l_etp_payment                  NUMBER;
      l_pre01jul1983_days            NUMBER;
      l_post30jun1983_days           NUMBER;
      l_pre01jul1983_ratio           NUMBER;
      l_post30jun1983_ratio          NUMBER;
      l_pre01jul1983_value           NUMBER;
      l_post30jun1983_value          NUMBER;
      l_result                       NUMBER;
      l_etp_service_date             date;   /* Bug# 2984390 */
      l_le_etp_service_date          date;   /* Bug 4177679 */
      l_current_employee_flag       per_all_people_f.current_employee_flag%type;
      l_actual_termination_date     per_periods_of_service.actual_termination_date%TYPE;
      l_date_start                  per_periods_of_service.date_start%TYPE;
      l_death_benefit_type          varchar2(100);
      l_lst_yr_start        date;
      l_etp_new_bal_total            NUMBER ; /* Bug 9226023 - Variable declared to store the sum of Taxable and Tax Free portions of ETP balances
                                                               introduced as part of patch 8769345*/


      CURSOR etp_code(c_assignment_id     in pay_assignment_actions.assignment_id%type,
                      c_lst_year_start    in pay_payroll_actions.effective_date%type,
                      c_year_start        in pay_payroll_actions.effective_date%type,
                      c_year_end          in pay_payroll_actions.effective_date%type
                      )is
        SELECT  distinct nvl(current_employee_flag,'N') current_employee_flag
                 ,actual_termination_date
                 ,date_start
                 ,pps.pds_information2
           from  per_all_people_f          p,
                 per_all_assignments_f     a,
                 per_periods_of_service    pps
          where  a.person_id = p.person_id
            and  pps.person_id = p.person_id
        and pps.period_of_service_id=a.period_of_service_id /*Bug 5397790 */
            and ( pps.actual_termination_date between c_lst_year_start  --bug 3686549
                                          and  c_year_end )  --Bug 3263659
            and  a.assignment_id = c_assignment_id
            and  p.effective_start_date = (SELECT  max(pp.effective_start_date)
                                             from  per_all_people_f pp
                                           where  p.person_id = pp.person_id )
            and  a.effective_start_date = (SELECT  max(aa.effective_start_date)
                                             from  per_all_assignments_f aa
                                           where  aa.assignment_id = c_assignment_id);  /*Bug 4256486 */

  begin
   if g_debug then
    hr_utility.set_location('Start of archive_prepost_details',15);
   END if;
-- Added for bug 3686549
  l_current_employee_flag := 'Y';
  IF (g_lst_yr_term = 'N') THEN
     l_lst_yr_start :=  to_date('01/01/1900','DD/MM/YYYY');
  ELSE
     l_lst_yr_start :=  add_months(p_year_start,-12);
  END IF;
------------------------------------------

    OPEN etp_code(p_assignment_id,
          l_lst_yr_start,  --bug 3686549
                  p_year_start,
                  p_year_end
                  );
           FETCH etp_code into l_current_employee_flag,
                            l_actual_termination_date,
                            l_date_start,
                            l_death_benefit_type;

           CLOSE etp_code;


     /*Bug 6112527 For death benefit type 'Dependent' ETP amount is taxable eff 01-Jul-2007 */

      if ((l_death_benefit_type <>'D' or to_number(to_char(p_year_start,'YYYY')) >= 2007) or l_death_benefit_type is NULL) then



      -- Bug: 3186840 Check against the global Dimension level value included to return the correct value.
     /* Start 8679345 - The pre 83 and post 83 components of ETP are computed by using the
                        ETP Taxable and Tax Free balances */
    --------------------------------------------------------------------------------+
    -- this procedure gets the ratios to calculate prejul83 balance and postjun83 balance
    --------------------------------------------------------------------------------+
      if g_debug then
         hr_utility.set_location('calling pay_au_terminations.etp_prepost_ratios ',15);
      END if;

      l_result :=pay_au_terminations.etp_prepost_ratios(
                                 p_assignment_id               -- number                  in
                                ,l_date_start                  -- date                    in
                                ,l_actual_termination_date     -- date                    in
                ,'N' -- Bug#2819479 Flag to check whether this function called by Termination Form.
                                ,l_pre01jul1983_days           -- number                  out
                                ,l_post30jun1983_days          -- number                  out
                                ,l_pre01jul1983_ratio          -- number                  out
                                ,l_post30jun1983_ratio         -- number                  out
                                ,l_etp_service_date            -- date                    out  /* Bug# 2984390 */
                    ,l_le_etp_service_date
                                 );          -- date                    out  /* Bug# 4177679 */

     /* Start 9226023 - Logic modified to support the calculation of Taxable and Tax Free portions of ETP for the
                        terminated employees processed before applying the patch 8768345 */
      IF (g_bal_dim_level = 'N') THEN
        l_etp_payment := get_bal_value_new(g_db_id_lscp); --Bug# 3193479

        l_etp_new_bal_total := get_bal_value_new(g_db_id_tftn) + get_bal_value_new(g_db_id_tftp) +
                               get_bal_value_new(g_db_id_tfln) + get_bal_value_new(g_db_id_tflp) +
                               get_bal_value_new(g_db_id_ttn) + get_bal_value_new(g_db_id_ttp) +
                               get_bal_value_new(g_db_id_tln) + get_bal_value_new(g_db_id_tlp);

       IF (l_etp_new_bal_total > 0) THEN
         IF (l_etp_payment - l_etp_new_bal_total = 0) THEN

	   l_pre01jul1983_value := get_bal_value_new(g_db_id_tftn) + get_bal_value_new(g_db_id_tftp) +
                                   get_bal_value_new(g_db_id_tfln) + get_bal_value_new(g_db_id_tflp);

           l_post30jun1983_value := get_bal_value_new(g_db_id_ttn) + get_bal_value_new(g_db_id_ttp) +
                                    get_bal_value_new(g_db_id_tln) + get_bal_value_new(g_db_id_tlp);

         ELSIF (l_etp_payment - l_etp_new_bal_total > 0) THEN

 	   l_pre01jul1983_value := ((l_etp_payment - l_etp_new_bal_total) * l_pre01jul1983_ratio) +
	                            get_bal_value_new(g_db_id_tftn) + get_bal_value_new(g_db_id_tftp) +
                                    get_bal_value_new(g_db_id_tfln) + get_bal_value_new(g_db_id_tflp);

           l_post30jun1983_value := ((l_etp_payment - l_etp_new_bal_total) * l_post30jun1983_ratio) +
	                             get_bal_value_new(g_db_id_ttn) + get_bal_value_new(g_db_id_ttp) +
                                     get_bal_value_new(g_db_id_tln) + get_bal_value_new(g_db_id_tlp);

         END IF;
       ELSE
           l_pre01jul1983_value := l_etp_payment * l_pre01jul1983_ratio;
	   l_post30jun1983_value := l_etp_payment * l_post30jun1983_ratio;
       END IF;

      ELSIF (g_bal_dim_level = 'T') THEN
         l_etp_payment := g_result_term_details_table(5).balance_value;

         l_etp_new_bal_total := g_result_term_details_table(8).balance_value + g_result_term_details_table(9).balance_value +
                                g_result_term_details_table(10).balance_value + g_result_term_details_table(11).balance_value +
			        g_result_term_details_table(12).balance_value + g_result_term_details_table(13).balance_value +
                                g_result_term_details_table(14).balance_value + g_result_term_details_table(15).balance_value ;

       IF (l_etp_new_bal_total > 0) THEN
         IF (l_etp_payment - l_etp_new_bal_total = 0) THEN

	  l_pre01jul1983_value := g_result_term_details_table(8).balance_value +
                                  g_result_term_details_table(9).balance_value +
                                  g_result_term_details_table(10).balance_value +
                                  g_result_term_details_table(11).balance_value ;

          l_post30jun1983_value := g_result_term_details_table(12).balance_value +
                                   g_result_term_details_table(13).balance_value +
                                   g_result_term_details_table(14).balance_value +
                                   g_result_term_details_table(15).balance_value ;

         ELSIF (l_etp_payment - l_etp_new_bal_total > 0) THEN

	  l_pre01jul1983_value := ((l_etp_payment - l_etp_new_bal_total) * l_pre01jul1983_ratio) +
                                   g_result_term_details_table(8).balance_value +
                                   g_result_term_details_table(9).balance_value +
                                   g_result_term_details_table(10).balance_value +
                                   g_result_term_details_table(11).balance_value ;

          l_post30jun1983_value := ((l_etp_payment - l_etp_new_bal_total) * l_post30jun1983_ratio) +
                                    g_result_term_details_table(12).balance_value +
                                    g_result_term_details_table(13).balance_value +
                                    g_result_term_details_table(14).balance_value +
                                    g_result_term_details_table(15).balance_value ;
         END IF;
       ELSE
          l_pre01jul1983_value := l_etp_payment * l_pre01jul1983_ratio;
	  l_post30jun1983_value := l_etp_payment * l_post30jun1983_ratio;
       END IF;
      END IF;
     /* End 9226023 */
     /* End 8679345 */
      if l_result = 0 then
        raise e_prepost_error;

      else

/* Start 8769345 - The pre 83 and post 83 components of ETP are computed by making of ETP Tax Free and Taxable balances */

      g_pre01jul1983_value  :=round(l_pre01jul1983_value,2);    /* Bug 4872594 - Changed to Round upto 2 decimals*/
      g_post30jun1983_value :=round(l_post30jun1983_value,2);   /* Bug 4872594 - Changed to Round upto 2 decimals*/
/* End 8769345 */

      end if;
     if g_debug then
        hr_utility.set_location('End of archive_prepost_details',14);
     END if;
    g_etp_gross:=g_pre01jul1983_value+g_post30jun1983_value+Total_Invalidity_Payments;
    g_assessable:= round(g_post30jun1983_value,2);  /* Bug 4872594 - Changed to Round upto 2 decimals */
                                                    /* Bug No : 7030285 - Assessable Income modified */
    -- Bug: 3186840 Check against the global Dimension level value included to return the correct value.

    IF (g_bal_dim_level = 'N') THEN
       g_etp_tax:=get_bal_value_new(g_db_id_lscd);  --Bug# 3193479
    ELSIF (g_bal_dim_level = 'T') THEN
       g_etp_tax := g_result_term_details_table(7).balance_value;
    END IF;


    else
    g_etp_gross:=0;
    g_assessable:=0;
    g_etp_tax:=0;
    end if;

    return g_pre01jul1983_value;


   exception
   when e_prepost_error then
    if g_debug then
        hr_utility.set_location('error from pay_au_terminations.etp_prepost_ratios',20);
    END if;
   when others then
     if g_debug then
    hr_utility.set_location('error in function_prepost_details',21);
     END if;
    raise;
   end etp_details;


   function post30jun1983_value return number is
   begin
   return g_post30jun1983_value;
   end post30jun1983_value;


   function etp_gross  return number is
   begin
   return g_etp_gross;
   end etp_gross;

   function assessable_income return number is
   begin
   return g_assessable;
   end assessable_income;

   function etp_tax return number is
   begin
   return g_etp_tax;
   end etp_tax;

--------------------Bug# 3193479-----------------------------------------------------------------
   function get_bal_value_new(p_defined_balance_id     pay_defined_balances.defined_balance_id%TYPE)
    return number is
   begin
    for i in 1..g_result_table.last
    loop
        if g_result_table.exists(i) then
           if g_result_table(i).defined_balance_id =p_defined_balance_id then
            RETURN g_result_table(i).balance_value;
           end if;
        end if;
    end loop;
    RETURN 0;
   end;


   PROCEDURE get_value_bbr(c_year_start           DATE,
              c_year_end             DATE,
                          c_assignment_id        pay_assignment_actions.assignment_id%type,
                          c_fbt_rate         ff_globals_f.global_value%TYPE,
                      c_ml_rate      ff_globals_f.global_value%TYPE,
              p_assignment_action_id pay_assignment_actions.assignment_id%type,
              p_tax_unit_id          hr_all_organization_units.organization_id%TYPE,
              p_termination_date     DATE,          --Bug 3098367
              p_display_flag     OUT NOCOPY VARCHAR2,   --Bug 3098367
              p_output_tab       OUT NOCOPY bal_tab
              ) IS

   l_net_balance NUMBER := 0; -- 3098353

   begin

    g_pre01jul1983_value :=0;
    g_post30jun1983_value :=0;
    g_etp_gross :=0;
    g_etp_tax :=0;
    g_assessable :=0;
    g_lump_sum_e :=0;
    g_total_cdep :=0;
    g_total_allowance :=0;
    g_total_fbt :=0;
    g_total_gross :=0;
  g_total_workplace :=0; /* 4015082 */
  /* Begin 8587013 - Initialize package variables of RESC and Exempt Foreign Employment Income balances */
    g_total_resc :=0;
    g_total_foreign_income := 0;
  /* End 8587013 */
    g_result_table.delete;
    g_context_table.delete;
    bal_id.delete;
    p_display_flag := 'YES';
    g_context_table(1).tax_unit_id := p_tax_unit_id;

    pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
    p_defined_balance_lst=>g_input_table,
    p_context_lst =>g_context_table,
    p_output_table=>g_result_table);

        g_bal_dim_level := 'N'; -- Bug: 3186840
/* Bug 8587013 - Addded code for RESC and Exempt Foreign Employment Income balances.
                 The Other Income balance is removed and the value is set to zero */
      bal_id(1).balance_value := get_total_allowances(c_year_start, c_year_end, c_assignment_id, p_assignment_action_id, p_tax_unit_id);  -- bug 7571001
    bal_id(2).balance_value := get_total_fbt(c_year_start,c_assignment_id,p_tax_unit_id,c_fbt_rate,c_ml_rate,null); --Bug#3213539
    bal_id(3).balance_value := get_total_cdep;
    bal_id(4).balance_value := Total_Lump_Sum_A_Payments;
    bal_id(5).balance_value := Total_Lump_Sum_B_Payments;
    bal_id(6).balance_value := Total_Lump_Sum_D_Payments;
    bal_id(7).balance_value := Total_Lump_Sum_E_Payments(c_year_end,c_assignment_id,p_tax_unit_id) ; --2610141
    bal_id(8).balance_value := Total_Union_fees;
    bal_id(9).balance_value := Total_Tax_deductions;
    bal_id(10).balance_value := 0; /* 8587013 */
    bal_id(18).balance_value := get_total_workplace; /* 4015082 */
    bal_id(11).balance_value :=  total_gross;
    bal_id(12).balance_value := ETP_DETAILS(c_assignment_id,c_year_start,c_year_end);
    bal_id(13).balance_value := POST30JUN1983_VALUE;
    bal_id(14).balance_value := TOTAL_INVALIDITY_PAYMENTS;
    bal_id(15).balance_value := ETP_GROSS;
    bal_id(16).balance_value := ETP_TAX;
    bal_id(17).balance_value := assessable_income;
/* Begin 8587013 */
    bal_id(19).balance_value := Total_RESC;
    bal_id(20).balance_value := Total_Foreign_Income;
/* End 8587013 */

    /*--------------Bug 3098367-------------
    If employee is terminated in last year then assignment details will be displayed
    only if sum of balance values is greater than 0 otherwise employee will not be displayed */
       IF p_termination_date < c_year_start THEN
           For i IN 1..bal_id.COUNT
        LOOP
            l_net_balance := l_net_balance + bal_id(i).balance_value;
           END LOOP;
        IF l_net_balance = 0 THEN
            p_display_flag := 'NO';
        END IF;
       END IF;
    -------End of --Bug 3098367----------------------------------------------------
    p_output_tab := bal_id;

end;
---------------End of Bug# 3193479-----------------------------------------------------------

   function get_exclusion_info(flag varchar2,p_assignment_id number)
   return varchar2 is

   i number;

   begin

   if exc_tab1.count>0 then

   for i in 0..exc_tab1.last

   loop

      if exc_tab1(i).assignment_id=p_assignment_id then
        if flag='name' then
                return exc_tab1(i).employee_name;
        end if;
     end if;

       if exc_tab1(i).assignment_id=p_assignment_id   then
           if flag='assignment' then
                return exc_tab1(i).assignment_number;
           end if;
        end if;

       if exc_tab1(i).assignment_id=p_assignment_id then
           if flag='reason' then
                return exc_tab1(i).reason;
            end if;
       end if;
   end loop;


   end if;

   end get_exclusion_info;


   function get_assignment_id(p_assignment_id number) return number is
    i number;
    begin

   if exc_tab1.count>0 then
    for i in 0..exc_tab1.last
    loop
           if exc_tab1.exists(i) then
         if exc_tab1(i).assignment_id=p_assignment_id
            then
            return 1;
         end if;
       end if;
    end loop;
   end if;
   return 0;
   end get_assignment_id;

   function populate_exclusion_table(p_assignment_id per_all_assignments_f.assignment_id%type,
                                     p_financial_year varchar2,
                                     p_financial_year_end date,
                     p_tax_unit_id number --2610141
                                    )
   return number is

   Cursor c_ps_issued(c_assignment_id  per_all_assignments_f.assignment_id%type,
                      c_financial_year varchar2)
   is
   SELECT  distinct paat.assignment_id
   from  pay_action_interlocks  pail,
   pay_assignment_actions paat,
   pay_payroll_actions paas
   where paat.assignment_id   = c_assignment_id
   and paas.action_type     ='X'
   and paas.action_status   ='C'
   and paas.report_type     ='AU_PAYMENT_SUMMARY_REPORT'
   and pail.locking_action_id  = paat.assignment_action_id
   and paat.payroll_action_id = paas.payroll_action_id
   and pay_core_utils.get_parameter('FINANCIAL_YEAR',paas.legislative_parameters) = c_financial_year
   and pay_core_utils.get_parameter('REGISTERED_EMPLOYER',paas.legislative_parameters) = p_tax_unit_id; --2610141


   CURSOR c_get_details(c_assignment_id per_all_assignments_f.assignment_id%type,
                        c_financial_yr_end date)
   is
   SELECT pap.last_name,
          paa.assignment_number
   from per_all_people_f pap,per_all_assignments_f paa
   where pap.person_id=paa.person_id
   and  paa.assignment_id=c_assignment_id
   and  paa.effective_start_date = (SELECT max(paa1.effective_start_date)
                            from per_all_assignments_f paa1
                                where paa1.assignment_id = c_assignment_id)   /* Bug 4278407*/
   and  pap.effective_start_date = (SELECT max(ppf.effective_start_date)
                                     from per_all_people_f ppf
                             where pap.person_id = ppf.person_id);

   CURSOR c_eit_updated(c_assignment_id  per_all_assignments_f.assignment_id%type,
                        c_financial_year varchar2)
   is
   SELECT  assignment_id
   from  per_assignment_extra_info,
   hr_lookups
   where  assignment_id        = c_assignment_id
   and  aei_information1     is not null
   and  aei_information1     = lookup_code
   and   nvl(aei_information2,p_tax_unit_id) = decode(aei_information2,'-999',aei_information2,p_tax_unit_id)  --Bug 4173809
   and lookup_type ='AU_PS_FINANCIAL_YEAR'
   and meaning = c_financial_year;

/*Bug 4173809 - Cursor updated so that the assignment is reported in the exception section when Manual PS
  is issued against 'All' legal employers or a particular legal employer
  If the Manual PS is issued for 'All' the legal employers the aei_information2 would be -999*/

   l_assignment_id per_all_assignments_f.assignment_id%type;
   l_assignment_number per_all_assignments_f.assignment_number%type;
   l_employee_name per_all_people_f.last_name%type;
   l_reason fnd_new_messages.message_text%type;


   begin


   OPEN c_ps_issued(p_assignment_id,p_financial_year);
   FETCH c_ps_issued into l_assignment_id;
   if c_ps_issued%found then
        OPEN c_get_details(l_assignment_id,p_financial_year_end);
        FETCH c_get_details into l_employee_name
                                ,l_assignment_number;

         exc_tab1(g_index).employee_name:=l_employee_name;
         exc_tab1(g_index).assignment_number:=l_assignment_number;
         exc_tab1(g_index).assignment_id:=l_assignment_id;
         l_reason:=fnd_message.get_string('PER','HR_AU_SELF_PRINTED_PS_ISSUED');
         exc_tab1(g_index).reason:=l_reason;

     g_index:=g_index+1;
         CLOSE c_get_details;
         CLOSE c_ps_issued;
         return l_assignment_id;
   end if;


         CLOSE c_ps_issued;

   OPEN c_eit_updated(p_assignment_id,p_financial_year);
   FETCH c_eit_updated into l_assignment_id;
   if c_eit_updated%found then
        OPEN c_get_details(l_assignment_id,p_financial_year_end);
        FETCH c_get_details into l_employee_name
                                ,l_assignment_number;

         exc_tab1(g_index).employee_name:=l_employee_name;
         exc_tab1(g_index).assignment_number:=l_assignment_number;
         exc_tab1(g_index).assignment_id:=l_assignment_id;
         l_reason:=fnd_message.get_string('PER','HR_AU_MANUAL_PS_ISSUED');
         exc_tab1(g_index).reason:=l_reason;

     g_index:=g_index+1;
         CLOSE c_get_details;
         CLOSE c_eit_updated;
         return g_index-1;
   end if;


         CLOSE c_eit_updated;

   return 0;
 end populate_exclusion_table;

   /* Start of Bug : 3186840 */
/* Bug 8587013 - Added balances 'Reportable Employer Superannuation Contributions' and 'Exempt Foreign Employment Income'
                 and removed Other Income balance */
PROCEDURE populate_group_def_bal_ids(p_dimension_name pay_balance_dimensions.dimension_name%TYPE
                                                                              ,p_business_group_id per_business_groups.business_group_id%TYPE)
       IS

   CURSOR csr_group_def_bal_ids IS
   SELECT decode(pbt.balance_name,'Lump Sum A Payments',1,'Lump Sum B Payments',2,
                 'Lump Sum D Payments',3,'Union Fees',4,'Lump Sum C Deductions',5,
                 'Termination Deductions',6,'Total_Tax_Deductions',7,'Earnings_Total',8,'Leave Payments Marginal',9,
                 'CDEP',10,'Reportable Employer Superannuation Contributions', 11 ,'Workplace Giving Deductions', 12 ,
           'Exempt Foreign Employment Income' ,13) sort_index  /*4015082 , 8587013*/
        , pdb.defined_balance_id
     FROM pay_balance_types       pbt
        , pay_defined_balances    pdb
        , pay_balance_dimensions  pbd
    WHERE pbt.legislation_code       = 'AU'
      AND pbt.balance_name in
          ('Lump Sum A Payments','Lump Sum B Payments','Lump Sum D Payments',
           'Union Fees','Lump Sum C Deductions','Termination Deductions',
           'Total_Tax_Deductions','Earnings_Total','Leave Payments Marginal','CDEP',
             'Workplace Giving Deductions','Reportable Employer Superannuation Contributions','Exempt Foreign Employment Income')  /* 4015082 , 8587013*/
      AND pdb.balance_type_id        = pbt.balance_type_id
      AND pdb.balance_dimension_id   = pbd.balance_dimension_id
      AND pbd.legislation_code       = 'AU'
      AND pdb.legislation_code       = 'AU'
      AND pbd.dimension_name         = p_dimension_name
 ORDER BY sort_index;

   l_sort_index   number;
   l_def_bal_id   pay_defined_balances.defined_balance_id%TYPE;

/* bug 7571001 - added csr_group_alw_def_bal_ids cursor for allowance balances */
CURSOR csr_group_alw_def_bal_ids IS
select pbt.balance_name
            ,pdb.defined_balance_id
  from pay_balance_types pbt
            ,pay_defined_balances pdb
            ,pay_balance_dimensions pbd
where  pdb.balance_type_id        = pbt.balance_type_id
      AND pdb.balance_dimension_id   = pbd.balance_dimension_id
      AND pbd.dimension_name         = p_dimension_name
      AND pdb.business_group_id = p_business_group_id
      AND pbd.legislation_code = 'AU'
 AND exists (
                            select  null
                            from  PAY_BAL_ATTRIBUTE_DEFINITIONS pbad
                                      ,pay_balance_attributes pba
                                      ,pay_defined_balances        pdb2
                                      ,pay_balance_dimensions pbd2
                            where  pbad.attribute_name = 'AU_EOY_ALLOWANCE'
                               and   pba.attribute_id = pbad.attribute_id
                               and   pba.defined_balance_id = pdb2.defined_balance_id
                               and   pdb2.business_group_id = p_business_group_id
                               and   pbt.balance_type_id = pdb2.balance_type_id
                               and   pbd2.balance_dimension_id = pdb2.balance_dimension_id
                               and   pbd2.dimension_name = '_ASG_LE_YTD'
                                and  pbd2.legislation_code = 'AU'
                              ) ;

  cnt number := 1;

BEGIN

   g_debug := hr_utility.debug_enabled;

   g_dimension_name := p_dimension_name;

   IF g_debug THEN
      hr_utility.trace('Dimension is ' || p_dimension_name);
   END IF;

   /* Group Level Defined Balance IDs get stored in the PL/SQL table with the following order.

   ---------------------------------------------------------
       Location ID        Group Level Balance Name
                        '_LE_YTD' or '_PAY_LE_YTD'
   ---------------------------------------------------------
           1              Lump Sum A Payments
           2              Lump Sum B Payments
           3              Lump Sum D Payments
           4              Union Fees
           5              Lump Sum C Deductions
           6              Termination Deduction
           7              Total_Tax_Deductions

       Bug: 3186840 - Four more Balances included for GROUP LEVEL functionality

           8              Earnings_Total
           9              Leave Payments Marginal
          10              CDEP
      11              Reportable Employer Superannuation Contributions
      12              Workplace Giving Deductions
      13              Exempt Foreign Employment Income
   ---------------------------------------------------------  */

   FOR csr_rec IN csr_group_def_bal_ids
   LOOP
      g_input_group_details_table(csr_rec.sort_index).defined_balance_id := csr_rec.defined_balance_id;

      IF g_debug THEN
         hr_utility.trace(csr_rec.sort_index || ' ' || g_input_group_details_table(csr_rec.sort_index).defined_balance_id);
      END IF;

   END LOOP;



  /* bug 7571001 - populating defined_defined_balance_id of _LE_YTD for allowance balances */
  g_input_group_alw_table.delete;
   FOR csr_rec IN csr_group_alw_def_bal_ids  LOOP
      g_input_group_alw_table(cnt).defined_balance_id := csr_rec.defined_balance_id;

      IF g_debug THEN
         hr_utility.trace( ' Defined Balance id of ' || csr_rec.balance_name || ' => ' || g_input_group_alw_table(cnt).defined_balance_id);
      END IF;

      cnt := cnt + 1;
   END LOOP;


   --Except Tax-Unit_id other Context table values are not required

   g_context_table(1).jurisdiction_code := NULL;
   g_context_table(1).source_id         := NULL;
   g_context_table(1).source_text       := NULL;
   g_context_table(1).source_number     := NULL;
   g_context_table(1).source_text2      := NULL;

END populate_group_def_bal_ids;

PROCEDURE get_group_values_bbr
            (p_year_start           DATE
            ,p_year_end             DATE
           ,p_assignment_action_id  IN  pay_assignment_actions.assignment_action_id%TYPE  DEFAULT NULL
          , p_date_earned           IN  date
          , p_tax_unit_id           IN  pay_assignment_actions.tax_unit_id%TYPE
          , p_group_output_tab      OUT NOCOPY   bal_tab ) IS


BEGIN

   g_total_allowance :=0;
   bal_id.delete;
   g_result_group_details_table.delete;

   g_context_table(1).tax_unit_id := p_tax_unit_id;

   IF (g_dimension_name = '_LE_YTD') THEN
      pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(p_date_earned));
   END IF;

   pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id,
                             p_defined_balance_lst  => g_input_group_details_table,
                             p_context_lst          => g_context_table,
                             p_output_table         => g_result_group_details_table);


  IF g_debug THEN
      FOR i IN 1..g_result_group_details_table.last
      LOOP
         IF g_result_group_details_table.exists(i) THEN
            hr_utility.trace('Balance Value ' || i || g_result_group_details_table(i).balance_value);
         END IF;
      END LOOP;
   END IF;


   g_bal_dim_level := 'G';

   /* Bug 8587013 - Added code for RESC and Exempt Foreign Employment Income balances.
                    The Other Income balance is removed and the value is set to zero */
   bal_id(1).balance_value  := Total_Lump_Sum_A_Payments;
   bal_id(2).balance_value  := Total_Lump_Sum_B_Payments;
   bal_id(3).balance_value  := Total_Lump_Sum_D_Payments;
   bal_id(4).balance_value  := Total_Union_fees;
   bal_id(5).balance_value  := Total_Tax_deductions;

   /* Bug: 3186840 - Included 4 more group level balances retrieval */
   bal_id(7).balance_value  := g_result_group_details_table(9).balance_value;  -- Leave Payments Marginal
   bal_id(8).balance_value  := get_total_cdep; -- CDEP
   bal_id(9).balance_value  := 0; -- Other Income 8587013
   bal_id(10).balance_value  := get_total_workplace; -- Workplace Giving Deductions  /* 4015082 */
   bal_id(6).balance_value  := g_result_group_details_table(8).balance_value ;  -- Earnings_Total

   bal_id(11).balance_value  :=get_total_allowances(p_year_start, p_year_end, null, null, p_tax_unit_id);  -- bug 7571001
  /* Begin 8587013 */
   bal_id(12).balance_value  := Total_RESC; -- Reportable Employer Superannuation Contributions
   bal_id(13).balance_value  := Total_Foreign_Income; -- Exempt Foreign Employment Income
  /* End 8587013 */

   p_group_output_tab := bal_id;

END get_group_values_bbr;

PROCEDURE get_assgt_curr_term_values_bbr
          ( p_year_start             IN date
          , p_year_end               IN date
          , p_assignment_id          IN pay_assignment_actions.assignment_id%type
          , p_fbt_rate               IN ff_globals_f.global_value%TYPE
          , p_ml_rate                IN ff_globals_f.global_value%TYPE
          , p_assignment_action_id   IN pay_assignment_actions.assignment_action_id%type
          , p_tax_unit_id            IN hr_all_organization_units.organization_id%TYPE
          , p_emp_type               IN varchar2
          , p_term_output_tab        OUT NOCOPY bal_tab) IS

   g_debug boolean;

BEGIN

   g_debug := hr_utility.debug_enabled;

   g_pre01jul1983_value  :=0;
   g_post30jun1983_value :=0;
   g_etp_gross           :=0;
   g_etp_tax             :=0;
   g_assessable          :=0;
     g_total_allowance :=0; /*Bug 4888097*/
   g_total_fbt := 0; /*Bug 4888097*/
   g_lump_sum_e := 0; /*Bug 4888097*/

   g_context_table.delete;
   g_context_table(1).tax_unit_id := p_tax_unit_id;

   bal_id.delete;
   g_result_term_details_table.delete;

   /*  ---------------------------------------------------------
       Location ID        Group Level Balance Name
                              '_ASG_LE_YTD'
   ---------------------------------------------------------
    For all Employees (Current and Terminated):
   --------------------------------------------
           1              Lump Sum E Payments

    For Terminated Employees only:
   -------------------------------

           2              Lump Sum C Payments
           3              Invalidity Payments
           4              Lump Sum C Deductions
   ---------------------------------------------------------  */

   g_input_term_details_table(1).defined_balance_id := g_db_id_lsep;
   /* bug8711855 - Added new defined balance ids for Lump Sum E */
   g_input_term_details_table(2).defined_balance_id := g_db_id_rll;
   g_input_term_details_table(3).defined_balance_id := g_db_id_res;
   g_input_term_details_table(4).defined_balance_id := g_db_id_rpt;

/* Bug 8769345 - Added code to hold the defined balance ids of ETP Taxable and Tax Free balances in pl/sql table */
/* bug8711855 - Modified g_input_term_details_table index ids */
   IF (p_emp_type = 'T') THEN

      g_input_term_details_table(5).defined_balance_id := g_db_id_lscp;
      g_input_term_details_table(6).defined_balance_id := g_db_id_ip;
      g_input_term_details_table(7).defined_balance_id := g_db_id_lscd;
      g_input_term_details_table(8).defined_balance_id := g_db_id_tftn; /* Start 8769345 */
      g_input_term_details_table(9).defined_balance_id := g_db_id_ttn;
      g_input_term_details_table(10).defined_balance_id := g_db_id_tftp;
      g_input_term_details_table(11).defined_balance_id := g_db_id_ttp;
      g_input_term_details_table(12).defined_balance_id := g_db_id_tfln;
      g_input_term_details_table(13).defined_balance_id := g_db_id_tln;
      g_input_term_details_table(14).defined_balance_id := g_db_id_tflp;
      g_input_term_details_table(15).defined_balance_id := g_db_id_tlp; /* End 8769345 */

   END IF;

   FOR i IN 1..g_input_term_details_table.last
   LOOP
      IF g_input_term_details_table.exists(i) THEN
         IF g_debug THEN
            hr_utility.trace(i || ' ' || g_input_term_details_table(i).defined_balance_id);
         END IF;
      END IF;
   END LOOP;

   pay_balance_pkg.get_value
                   ( p_assignment_action_id => p_assignment_action_id
                   , p_defined_balance_lst  => g_input_term_details_table
                   , p_context_lst          => g_context_table
                   , p_output_table         => g_result_term_details_table);

   IF g_debug THEN
      FOR i IN 1..g_result_term_details_table.last
      LOOP
         IF g_result_term_details_table.exists(i) THEN
            hr_utility.trace('Balance Value ' || i || g_result_term_details_table(i).balance_value);
         END IF;
      END LOOP;
   END IF;

   g_bal_dim_level := 'T';

     /* bug 7571001 - Removed the code to get allowance as it moved to get_group_values_bbr for group level reporting */
      bal_id(1).balance_value := get_total_fbt(p_year_start,p_assignment_id,p_tax_unit_id,p_fbt_rate,p_ml_rate,null);
      bal_id(2).balance_value := Total_Lump_Sum_E_Payments(p_year_end,p_assignment_id,p_tax_unit_id)  ; --2610141

      IF (p_emp_type = 'T') THEN

         bal_id(3).balance_value  := ETP_DETAILS(p_assignment_id,p_year_start,p_year_end);
         bal_id(4).balance_value  := POST30JUN1983_VALUE;
         bal_id(5).balance_value  := TOTAL_INVALIDITY_PAYMENTS;
         bal_id(6).balance_value  := ETP_GROSS;
         bal_id(7).balance_value  := ETP_TAX;
         bal_id(8).balance_value  := assessable_income;

      END IF;

      IF g_debug THEN
         FOR i IN 1..bal_id.last
         LOOP
            IF bal_id.exists(i) THEN
               hr_utility.trace('Output Balance Value ' || i || bal_id(i).balance_value);
            END IF;
         END LOOP;
      END IF;

      p_term_output_tab := bal_id;

END get_assgt_curr_term_values_bbr;


 ------------ --Bug#3749530 All the procedures added below are for archival model------
 -- On Submitting payrec-PS reuqest first archival proceudres are called

  --------------------------------------------------------------------
  -- These are PUBLIC procedures are required by the Archive process.
  -- There names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
  -- the archive process knows what code to execute for each step of
  -- the archive.
  --------------------------------------------------------------------

  --------------------------------------------------------------------
  -- This procedure returns a sql string to select a range
  -- of assignments eligible for archival.
  --------------------------------------------------------------------

  procedure range_code
    (p_payroll_action_id   in pay_payroll_actions.payroll_action_id%type,
     p_sql                out nocopy varchar2) is
  begin
      g_debug := hr_utility.debug_enabled;
      IF g_debug THEN
         hr_utility.set_location('Start of range_code',1);
     END if;
    p_sql := ' select distinct p.person_id'                                       ||
             ' from   per_people_f p,'                                        ||
                    ' pay_payroll_actions pa'                                     ||
             ' where  pa.payroll_action_id = :payroll_action_id'                  ||
             ' and    p.business_group_id = pa.business_group_id'                 ||
             ' order by p.person_id';
      IF g_debug THEN
        hr_utility.set_location('End of range_code',2);
      END if;
  end range_code;


  --------------------------------------------------------------------
  -- This procedure is used to set global contexts
  -- however in current case it is a dummy procedure. In case this
  -- procedure is not present then archiver assumes that
  -- no archival is required.
  --------------------------------------------------------------------

  procedure initialization_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type) is
  begin
    NULL;
  END;

/*
    Bug 7138494 - Added Function range_person_on
--------------------------------------------------------------------
    Name  : range_person_on
    Type  : Function
    Access: Private
    Description: Checks if RANGE_PERSON_ID is enabled for
                 Archive process.
  --------------------------------------------------------------------
*/

FUNCTION range_person_on
RETURN BOOLEAN
IS

 CURSOR csr_action_parameter is
  select parameter_value
  from pay_action_parameters
  where parameter_name = 'RANGE_PERSON_ID';

 CURSOR csr_range_format_param is
  select par.parameter_value
  from   pay_report_format_parameters par,
         pay_report_format_mappings_f map
  where  map.report_format_mapping_id = par.report_format_mapping_id
  and    map.report_type = 'AU_REC_PS_ARCHIVE'
  and    map.report_format = 'AU_REC_PS_ARCHIVE'
  and    map.report_qualifier = 'AU'
  and    par.parameter_name = 'RANGE_PERSON_ID'; -- Bug fix 5567246

  l_return boolean;
  l_action_param_val varchar2(30);
  l_report_param_val varchar2(30);

BEGIN

    g_debug := hr_utility.debug_enabled;

    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',10);
    END IF;

  BEGIN

    open csr_action_parameter;
    fetch csr_action_parameter into l_action_param_val;
    close csr_action_parameter;

    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',20);
    END IF;

    open csr_range_format_param;
    fetch csr_range_format_param into l_report_param_val;
    close csr_range_format_param;
    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',30);
    END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN
     l_return := FALSE;
  END;
  --
    IF g_debug
    THEN
        hr_utility.set_location('range_person_on',40);
    END IF;

  IF l_action_param_val = 'Y' AND l_report_param_val = 'Y' THEN
     l_return := TRUE;
     hr_utility.trace('Range Person = True');
  ELSE
     l_return := FALSE;
  END IF;
--
 RETURN l_return;
--
END range_person_on;

  --------------------------------------------------------------------
  -- This procedure further restricts the assignment_id's
  -- returned by range_code
  -- It inserts the record in pay_assignment_Actions
  -- Which are then used in main report query to get assignment_ids
  --------------------------------------------------------------------
  procedure assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_start_person_id    in per_all_people_f.person_id%type,
     p_end_person_id      in per_all_people_f.person_id%type,
     p_chunk              in number)    is


   l_asgid per_assignments_f.assignment_id%type;
   l_next_action_id  pay_assignment_actions.assignment_action_id%type;


   l_lst_yr_start date;
   l_lst_fbt_yr_start date;
   l_assignment_id        varchar2(50);
   l_business_group_id hr_organization_units.organization_id%type;
   l_legal_employer        varchar2(50);
   l_employee_type varchar2(2);
   l_payroll_id        varchar2(50);
   l_fin_year_start date;
   l_fin_year_end  date;
   l_fbt_year_start date;
   l_fbt_year_end  date;
   l_lst_yr_term VARCHAR2(2);


  cursor   get_params(c_payroll_action_id  per_all_assignments_f.assignment_id%type)
   is
  select  to_date('01-07-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY')
         Financial_year_start
        ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),6,4),'DD-MM-YYYY')
         Financial_year_end
        ,to_date('01-04-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY')
         FBT_year_start
        ,to_date('30-06-'||substr(pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters),1,4),'DD-MM-YYYY')
         FBT_year_end
        ,decode(pay_core_utils.get_parameter('EMPLOYEE_TYPE',legislative_parameters),'C','Y','T','N','B','%')
         Employee_type
        ,pay_core_utils.get_parameter('REGISTERED_EMPLOYER',legislative_parameters) Registered_Employer
        ,decode(pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters),null,'%',  pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters)) Assignment_id
        ,decode(pay_core_utils.get_parameter('PAYROLL_ID',legislative_parameters),null,'%',pay_core_utils.get_parameter('PAYROLL_ID',legislative_parameters)) payroll_id
        ,pay_core_utils.get_parameter('LST_YR_TERM',legislative_parameters) lst_yr_term                  /*Bug3661230*/
        ,pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters) Business_group_id
    from     pay_payroll_actions
    where    payroll_action_id =c_payroll_Action_id;

  cursor   next_action_id is
  select   pay_assignment_actions_s.nextval
  from   dual;

   cursor c_asgids(p_assignment_id varchar2,
                  p_business_group_id hr_organization_units.organization_id%type,
                  p_legal_employer varchar2,
                  p_employee_type varchar2,
                  p_payroll_id varchar2,
                  p_fin_year_start date,
                  p_fin_year_end  date,
                  p_lst_fbt_yr_start date,
                  p_fbt_year_start date,
                  p_fbt_year_end  date,
                  p_lst_year_start  date
   )
   is
  SELECT /*+ INDEX(pap per_people_f_pk)
             INDEX(rppa pay_payroll_actions_pk)
             INDEX(paa per_assignments_f_N12)
             INDEX(pps per_periods_of_service_pk)
        */        paa.assignment_id
   from           per_people_f              pap
                 ,per_assignments_f         paa
                 ,pay_payroll_actions           rppa
                 ,per_periods_of_service        pps
   where  rppa.payroll_action_id       = p_payroll_action_id
   and   pap.person_id                between p_start_person_id and p_end_person_id
   and   pap.person_id                = paa.person_id
   and decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (p_fin_year_end)),1,'Y','N')) LIKE p_employee_type
   and  pps.period_of_service_id = paa.period_of_service_id
   and  pap.person_id         = pps.person_id
   and  rppa.business_group_id=paa.business_group_id
   and  nvl(pps.actual_termination_date, p_lst_year_start) >= p_lst_year_start
   and  p_fin_year_end between pap.effective_start_date and pap.effective_end_date
   /* Start of Bug: 3872211 */
   and   paa.effective_end_date = (SELECT MAX(effective_end_date) /*4377367*/
                                   FROM  per_assignments_f iipaf
                                   WHERE iipaf.assignment_id  = paa.assignment_id
                                   AND iipaf.effective_end_date >= p_fbt_year_start
                                   AND iipaf.effective_start_date <= p_fin_year_end
                                   AND iipaf.payroll_id IS NOT NULL) /* Bug#4688800 */
   and  paa.payroll_id like p_payroll_id
   /* End of Bug: 3872211 */
   AND EXISTS  (SELECT  /*+ INDEX(rpac PAY_ASSIGNMENT_ACTIONS_N51)
                            INDEX(rpac pay_assignment_actions_n1)
                            INDEX(rppa  PAY_PAYROLL_ACTIONS_N51)
                            INDEX(rppa  PAY_PAYROLL_ACTIONS_PK) */''
           FROM
                 pay_payroll_actions           rppa
                ,pay_assignment_actions        rpac
                ,per_assignments_f             paaf -- Bug: 3872211
           where (rppa.effective_date      between  p_fin_year_start and p_fin_year_end   /*Bug3048962 */
                  or ( pps.actual_termination_date between p_lst_fbt_yr_start and p_fbt_year_end /*Bug3263659 */
                        and rppa.effective_date between p_fbt_year_start and p_fbt_year_end
                        and  pay_balance_pkg.get_value(g_fbt_defined_balance_id, rpac.assignment_action_id
                                        + decode(rppa.payroll_id,  0, 0, 0),p_legal_employer,null,null,null,null) > to_number(g_fbt_threshold))
                    )
           and rppa.action_type            in ('R','Q','B','I')
           and rpac.tax_unit_id = p_legal_employer
           and rppa.payroll_action_id = rpac.payroll_action_id
           and rpac.action_status = 'C'
           /* Start of Bug: 3872211 */
           and rpac.assignment_id              = paaf.assignment_id
           and rppa.payroll_id                 = paaf.payroll_id
           and paaf.assignment_id              = paa.assignment_id
           and rppa.effective_date between paaf.effective_start_date and paaf.effective_end_date);
           /* End of Bug: 3872211 */

/*
   Bug 7138494 - Added Cursor for Range Person
               - Uses person_id in pay_population_ranges
  --------------------------------------------------------------------+
  -- Cursor      : c_range_asgids
  -- Description : Fetches assignments For Recconciling Payment Summary
  --               Returns DISTINCT assignment_id
  --               Used when RANGE_PERSON_ID feature is enabled
  --------------------------------------------------------------------+
*/

   CURSOR c_range_asgids
                 (p_assignment_id varchar2,
                  p_business_group_id hr_organization_units.organization_id%type,
                  p_legal_employer varchar2,
                  p_employee_type varchar2,
                  p_payroll_id varchar2,
                  p_fin_year_start date,
                  p_fin_year_end  date,
                  p_lst_fbt_yr_start date,
                  p_fbt_year_start date,
                  p_fbt_year_end  date,
                  p_lst_year_start  date
                  )
   IS
  SELECT /*+ INDEX(pap per_people_f_pk)
             INDEX(rppa pay_payroll_actions_pk)
             INDEX(ppr PAY_POPULATION_RANGES_N4)
             INDEX(paa per_assignments_f_N12)
             INDEX(pps per_periods_of_service_PK)
        */        paa.assignment_id
   from           per_people_f              pap
                 ,per_assignments_f         paa
                 ,pay_payroll_actions           rppa
                 ,per_periods_of_service        pps
                 ,pay_population_ranges         ppr
   where  rppa.payroll_action_id       = p_payroll_action_id
   and    rppa.payroll_action_id       = ppr.payroll_action_id
   and    ppr.chunk_number             = p_chunk
   and    ppr.person_id                = pap.person_id
   and    pap.person_id                = paa.person_id
   and    decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (p_fin_year_end)),1,'Y','N')) LIKE p_employee_type
   and    pps.period_of_service_id = paa.period_of_service_id
   and    pap.person_id         = pps.person_id
   and    rppa.business_group_id=paa.business_group_id
   and    nvl(pps.actual_termination_date, p_lst_year_start) >= p_lst_year_start
   and    p_fin_year_end between pap.effective_start_date and pap.effective_end_date
   /* Start of Bug: 3872211 */
   and   paa.effective_end_date = (SELECT MAX(effective_end_date) /*4377367*/
                                   FROM  per_assignments_f iipaf
                                   WHERE iipaf.assignment_id  = paa.assignment_id
                                   AND iipaf.effective_end_date >= p_fbt_year_start
                                   AND iipaf.effective_start_date <= p_fin_year_end
                                   AND iipaf.payroll_id IS NOT NULL) /* Bug#4688800 */
   and  paa.payroll_id like p_payroll_id
   /* End of Bug: 3872211 */
   AND EXISTS  (SELECT  /*+ INDEX(rpac PAY_ASSIGNMENT_ACTIONS_N51)
                            INDEX(rppa  PAY_PAYROLL_ACTIONS_N51)
                            INDEX(rppa  PAY_PAYROLL_ACTIONS_PK)
                         */''
           FROM
                 pay_payroll_actions           rppa
                ,pay_assignment_actions        rpac
                ,per_assignments_f             paaf -- Bug: 3872211
           where (rppa.effective_date      between  p_fin_year_start and p_fin_year_end   /*Bug3048962 */
                  or ( pps.actual_termination_date between p_lst_fbt_yr_start and p_fbt_year_end /*Bug3263659 */
                        and rppa.effective_date between p_fbt_year_start and p_fbt_year_end
                        and  pay_balance_pkg.get_value(g_fbt_defined_balance_id, rpac.assignment_action_id
                                        + decode(rppa.payroll_id,  0, 0, 0),p_legal_employer,null,null,null,null) > to_number(g_fbt_threshold))
                    )
           and rppa.action_type            in ('R','Q','B','I')
           and rpac.tax_unit_id = p_legal_employer
           and rppa.payroll_action_id = rpac.payroll_action_id
          and rpac.action_status = 'C'
           /* Start of Bug: 3872211 */
           and rpac.assignment_id              = paaf.assignment_id
           and rppa.payroll_id                 = paaf.payroll_id
           and paaf.assignment_id              = paa.assignment_id
           and rppa.effective_date between paaf.effective_start_date and paaf.effective_end_date);
           /* End of Bug: 3872211 */



   cursor c_asgid_only(p_assignment_id varchar2,
                  p_business_group_id hr_organization_units.organization_id%type,
                  p_legal_employer varchar2,
                  p_employee_type varchar2,
              p_payroll_id varchar2,
                  p_fin_year_start date,
                  p_fin_year_end  date,
                  p_lst_fbt_yr_start date,
                  p_fbt_year_start date,
                  p_fbt_year_end  date,
                  p_lst_year_start  date
   )
   is
  SELECT /*+ INDEX(pap per_people_f_pk)
            INDEX(paa per_assignments_f_fk1)
        INDEX(paa per_assignments_f_N12)
            INDEX(rppa pay_payroll_actions_pk)
            INDEX(pps per_periods_of_service_n3)
        */      distinct paa.assignment_id
   from           per_people_f              pap
                 ,per_assignments_f         paa
                 ,pay_payroll_actions           rppa
                 ,per_periods_of_service        pps
   where  rppa.payroll_action_id       = p_payroll_action_id
   and   pap.person_id                between p_start_person_id and p_end_person_id
   and   pap.person_id                = paa.person_id
   and decode(pps.actual_termination_date,null,'Y',decode(sign(pps.actual_termination_date - (p_fin_year_end)),1,'Y','N')) LIKE p_employee_type
   and  pps.period_of_service_id = paa.period_of_service_id
   and   paa.assignment_id      = p_assignment_id
   and  pap.person_id         = pps.person_id
   and  rppa.business_group_id=paa.business_group_id
   and  nvl(pps.actual_termination_date, p_lst_year_start) >= p_lst_year_start
   and  p_fin_year_end between pap.effective_start_date and pap.effective_end_date
--   and  least(nvl(pps.actual_termination_date,p_fin_year_end),p_fin_year_end) between paa.effective_start_date and paa.effective_end_date
   and   paa.effective_end_date = (select max(effective_end_date) /*4377367*/
                           From  per_assignments_f iipaf
                           WHERE iipaf.assignment_id  = paa.assignment_id
                             and iipaf.effective_end_date >= p_fbt_year_start
                     and iipaf.effective_start_date <= p_fin_year_end
                 AND iipaf.payroll_id IS NOT NULL) /* Bug#4688800 */
   and  paa.payroll_id like p_payroll_id
   AND EXISTS  (SELECT  /*+ INDEX(rpac PAY_ASSIGNMENT_ACTIONS_N51)
                INDEX(rpac pay_assignment_actions_n1)
                INDEX(rppa  PAY_PAYROLL_ACTIONS_N51)
                    INDEX(rppa  PAY_PAYROLL_ACTIONS_PK) */''
           FROM
                 pay_payroll_actions           rppa
                ,pay_assignment_actions        rpac
                ,per_assignments_f             paaf -- Bug: 3872211
           where (rppa.effective_date      between  p_fin_year_start and p_fin_year_end   /*Bug3048962 */
                  or ( pps.actual_termination_date between p_lst_fbt_yr_start and p_fbt_year_end /*Bug3263659 */
            and rppa.effective_date between p_fbt_year_start and p_fbt_year_end
                        and  pay_balance_pkg.get_value(g_fbt_defined_balance_id, rpac.assignment_action_id
                                        + decode(rppa.payroll_id,  0, 0, 0),p_legal_employer,null,null,null,null) > to_number(g_fbt_threshold) ) --2610141 /* Bug 5708255 */
                    )
           and rppa.action_type            in ('R','Q','B','I')
           and rpac.tax_unit_id = p_legal_employer
           and rppa.payroll_action_id = rpac.payroll_action_id
           and rpac.action_status = 'C'
           /* Start of Bug: 3872211 */
           and  rpac.assignment_id              = paaf.assignment_id
           and  rppa.payroll_id                 = paaf.payroll_id
           and  paaf.assignment_id              = p_assignment_id
           and  rppa.effective_date between paaf.effective_start_date and paaf.effective_end_date);
           /* End of Bug: 3872211 */


Cursor c_fbt_balance is
  select        pdb.defined_balance_id
  from          pay_balance_types            pbt,
                pay_defined_balances         pdb,
                pay_balance_dimensions       pbd
  where  pbt.balance_name               ='Fringe Benefits'
  and  pbt.balance_type_id            = pdb.balance_type_id
  and  pdb.balance_dimension_id       = pbd.balance_dimension_id
  and  pbd.legislation_code           ='AU'
  and  pbd.dimension_name             ='_ASG_LE_FBT_YTD' --2610141
  and  pbd.legislation_code = pbt.legislation_code
  and  pbd.legislation_code = pdb.legislation_code;

/* Bug 5708255 */
  -------------------------------------------
  -- Added cursor to get value of global FBT_THRESHOLD
  --------------------------------------------
CURSOR  c_get_fbt_global(c_year_end DATE)
       IS
   SELECT  global_value
   FROM   ff_globals_f
    WHERE  global_name = 'FBT_THRESHOLD'
    AND    legislation_code = 'AU'
    AND    c_year_end BETWEEN effective_start_date
                          AND effective_end_date ;



begin

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
      hr_utility.set_location('Start of assignment_action_code',1);
  END IF;
  -------------------------------------------------------------
  -- get the paramters for archival process
  -------------------------------------------------------------
   open   get_params(p_payroll_action_id);
   fetch  get_params
    into  l_fin_year_start
         ,l_fin_year_end
         ,l_fbt_year_start
         ,l_fbt_year_end
         ,l_employee_type
         ,l_legal_employer
         ,l_assignment_id
         ,l_payroll_id
         ,l_lst_yr_term
         ,l_business_group_id ;
   close get_params;

 if g_debug then
   hr_utility.trace('p_assignment_id :'||l_assignment_id);
   hr_utility.trace('p_business_group_id :'||l_business_group_id);
   hr_utility.trace('p_legal_employer :' ||l_legal_employer);
   hr_utility.trace('p_employee_type :'||l_employee_type);
   hr_utility.trace('p_payroll_id :'|| l_payroll_id);
   hr_utility.trace('p_fin_year_start :' ||l_fin_year_start);
   hr_utility.trace('p_fin_year_end :' ||l_fin_year_end);
   hr_utility.trace('p_fbt_year_start :' ||l_fbt_year_start);
   hr_utility.trace('p_fbt_year_end :' ||l_fbt_year_end);
 END if;

  IF (l_lst_yr_term = 'N') THEN
     l_lst_yr_start :=  to_date('01/01/1900','DD/MM/YYYY');
     l_lst_fbt_yr_start :=  to_date('01/01/1900','DD/MM/YYYY');
  ELSE
     l_lst_yr_start :=  add_months(l_fin_year_start,-12);
     l_lst_fbt_yr_start := l_fbt_year_start;
  END IF;
------------------------------------------

    /* Bug 5708255 */
open c_get_fbt_global (add_months(l_fin_year_end,-3));  /* Add_months included for bug 5333143 */
fetch c_get_fbt_global into g_fbt_threshold;
 close c_get_fbt_global;

-- Added for bug 3034189
   If g_fbt_defined_balance_id = 0 OR g_fbt_defined_balance_id IS NULL Then
       Open  c_fbt_balance;
       Fetch c_fbt_balance into  g_fbt_defined_balance_id;
       Close c_fbt_balance;
   End if;



   IF l_assignment_id = '%' THEN   -- For multiple Assignments

   /* Bug 7138494 - Added Changes for Range Person
       - Call Cursor using pay_population_ranges if Range Person Enabled
         Else call Old Cursor
   */
    IF range_person_on
    THEN

        IF g_debug
        THEN
            hr_utility.set_location('Range Peron set - Use range cursor',1000);
        END IF;
        FOR csr_rec IN c_range_asgids(l_assignment_id ,
                                      l_business_group_id ,
                                      l_legal_employer ,
                                      l_employee_type ,
                                      l_payroll_id ,
                                      l_fin_year_start ,
                                      l_fin_year_end  ,
                                      l_lst_fbt_yr_start,
                                      l_fbt_year_start ,
                                      l_fbt_year_end,
                                      l_lst_yr_start)
        LOOP

             IF g_debug THEN
                hr_utility.set_location('Calling hr_nonrun_asact.insact for assignment id :'||l_asgid,2);
             END if;

             OPEN next_action_id;
             FETCH next_action_id INTO l_next_action_id;
             CLOSE next_action_id;

             hr_nonrun_asact.insact(l_next_action_id,csr_rec.assignment_id,p_payroll_action_id,p_chunk,null);

             IF g_debug THEN
                hr_utility.set_location('After calling hr_nonrun_asact.insact',3);
             END if;

        END LOOP;

    ELSE /* Use Old Logic - No Range Person */

       OPEN  c_asgids(l_assignment_id ,
              l_business_group_id ,
              l_legal_employer ,
              l_employee_type ,
              l_payroll_id ,
              l_fin_year_start ,
              l_fin_year_end  ,
              l_lst_fbt_yr_start,
              l_fbt_year_start ,
              l_fbt_year_end,
              l_lst_yr_start);
       LOOP
           FETCH c_asgids INTO l_asgid;
           IF c_asgids%NOTFOUND THEN
              close c_asgids;
              exit;
           ELSE
             IF g_debug THEN
                hr_utility.set_location('Calling hr_nonrun_asact.insact for assignment id :'||l_asgid,2);
             END if;
             OPEN next_action_id;
             FETCH next_action_id INTO l_next_action_id;
             CLOSE next_action_id;
             hr_nonrun_asact.insact(l_next_action_id,l_asgid,p_payroll_action_id,p_chunk,null);

             IF g_debug THEN
                hr_utility.set_location('After calling hr_nonrun_asact.insact',3);
             END if;
           END IF;
       END LOOP;
    END IF; /* Range Person Check */

   ELSE -- only for Single Assignment
          hr_utility.trace('before open');
       OPEN  c_asgid_only(l_assignment_id ,
              l_business_group_id ,
              l_legal_employer ,
              l_employee_type ,
              l_payroll_id ,
              l_fin_year_start ,
              l_fin_year_end  ,
              l_lst_fbt_yr_start,
              l_fbt_year_start ,
              l_fbt_year_end,
              l_lst_yr_start);
       LOOP
                 hr_utility.trace('in loop');
           FETCH c_asgid_only INTO l_asgid;
           IF c_asgid_only%NOTFOUND THEN
              CLOSE c_asgid_only;
              EXIT;
           ELSE
             IF g_debug THEN
                hr_utility.set_location('Calling hr_nonrun_asact.insact for assignment id :'||l_asgid,2);
             END IF;
             OPEN next_action_id;
             FETCH next_action_id INTO l_next_action_id;
             CLOSE next_action_id;
             hr_nonrun_asact.insact(l_next_action_id,l_asgid,p_payroll_action_id,p_chunk,NULL);

             IF g_debug THEN
                hr_utility.set_location('After calling hr_nonrun_asact.insact',3);
             END if;
           END IF;
       END LOOP;
   END IF;
   IF g_debug THEN
      hr_utility.set_location('End of assignment_action_code',4);
   END if;

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
        hr_utility.set_location('error raised in assignment_action_code procedure ',5);
        hr_utility.trace(sqlerrm);
    END if;
    raise;
END;

  --------------------------------------------------------------------
  -- This procedure is actually used to archive data . It
  -- internally calls private procedures to archive balances ,
  -- employee details, employer details and supplier details .
  --------------------------------------------------------------------
  procedure archive_code
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_effective_date        in date)is
  begin
    NULL;
  END;


  --------------------------------------------------------------------
  -- This procedure is called during de-iniitalization
  -- After inserting assignment_actions this procedure is called
  -- It submits the request for running the report
  -- And the report displays detials for all the archived assignments.
  --------------------------------------------------------------------

  PROCEDURE spawn_ps_report
    (p_payroll_action_id in pay_payroll_actions.payroll_action_id%type) is

     ps_request_id          NUMBER;
     l_payroll_action_id    pay_payroll_actions.payroll_action_id%TYPE;
     l_business_group_id    number;
     l_start_date       date;
     l_end_date         date;
     l_effective_date   date;
     l_legal_employer   number;
     l_FINANCIAL_YEAR_code  varchar2(10);
     l_TEST_EFILE       varchar2(10);
     l_FINANCIAL_YEAR   varchar2(10);
     l_legislative_param    varchar2(200);
     l_count                number;
     l_print_style          VARCHAR2(2);
     l_print_together       VARCHAR2(80);
     l_print_return         BOOLEAN;
     l_procedure         varchar2(50);
         l_short_report_name    VARCHAR2(30);  /* 6839263 */
         l_xml_options          BOOLEAN     ;  /* 6839263 */


  --------------------------------------------------------------------+
  -- Cursor      : csr_params
  -- Description : Fetches User Parameters from Legislative_paramters
  --               column.
  --------------------------------------------------------------------+

   CURSOR csr_report_params(c_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE)
      IS
         select  pay_core_utils.get_parameter('FINANCIAL_YEAR',legislative_parameters) Financial_year
                ,pay_core_utils.get_parameter('EMPLOYEE_TYPE',legislative_parameters)  Employee_type
                ,pay_core_utils.get_parameter('REGISTERED_EMPLOYER',legislative_parameters) legal_employer
                ,pay_core_utils.get_parameter('ASSIGNMENT_ID',legislative_parameters) Assignment_id
                ,pay_core_utils.get_parameter('PAYROLL_ID',legislative_parameters) payroll_id
                ,pay_core_utils.get_parameter('LST_YR_TERM',legislative_parameters) lst_yr_term
                ,pay_core_utils.get_parameter('BUSINESS_GROUP_ID',legislative_parameters) Business_group_id
                ,pay_core_utils.get_parameter('OUTPUT_TYPE',legislative_parameters)p_output_type /* Bug# 6839263 */
        from     pay_payroll_actions
        where    payroll_action_id =c_payroll_Action_id;



 cursor csr_get_print_options(p_payroll_action_id NUMBER) IS
 SELECT printer,
          print_style,
          decode(save_output_flag, 'Y', 'TRUE', 'N', 'FALSE') save_output
      ,number_of_copies /* Bug 4116833 */
    FROM  pay_payroll_actions pact,
          fnd_concurrent_requests fcr
    WHERE fcr.request_id = pact.request_id
    AND   pact.payroll_action_id = p_payroll_action_id;


 rec_print_options  csr_get_print_options%ROWTYPE;

 l_parameters csr_report_params%ROWTYPE;

BEGIN
    g_debug :=hr_utility.debug_enabled ;

    IF g_debug THEN
      hr_utility.set_location('Start of spawn_ps_report',1);
    END if;

    l_count           :=0;
    ps_request_id     :=-1;

-- Set User Parameters for Report.

     OPEN csr_report_params(p_payroll_action_id);
     FETCH csr_report_params INTO l_parameters;
     CLOSE csr_report_params;

         /* Start of 6839263 */
         IF  l_parameters.p_output_type = 'XML_PDF' then
                l_short_report_name := 'PYAURECPR_XML';

                l_xml_options      := fnd_request.add_layout
                                        (template_appl_name => 'PAY',
                                         template_code      => 'PYAURECPR_XML',
                                         template_language  => 'en',
                                         template_territory => 'US',
                                         output_format      => 'PDF');

         ELSE
             l_short_report_name := 'PYAURECPR';
         END IF;
         /* End of 6839263 */

     IF g_debug THEN
               hr_utility.set_location('in BG_ID '||l_parameters.Business_group_id,1);
               hr_utility.set_location('in payroll_parameters.id '||l_parameters.payroll_id,3);
               hr_utility.set_location('in asg_id '||l_parameters.assignment_id,4);
               hr_utility.set_location('in legal employer '||l_parameters.legal_employer,8);
               hr_utility.set_location('in emp_type '||l_parameters.employee_type,14);
               hr_utility.set_location('fin_year'||l_parameters.Financial_year,15);
               hr_utility.set_location('lst_yr_trm'||l_parameters.lst_yr_term,16);
     end if;

     IF g_debug THEN
         hr_utility.set_location('Afer payroll action ' || p_payroll_action_id , 125);
         hr_utility.set_location('Before calling report',24);
     END IF;

     OPEN csr_get_print_options(p_payroll_action_id);
     FETCH csr_get_print_options INTO rec_print_options;
     CLOSE csr_get_print_options;

     l_print_together := nvl(fnd_profile.value('CONC_PRINT_TOGETHER'), 'N');
     --
     -- Set printer options
     l_print_return := fnd_request.set_print_options
                       (printer        => rec_print_options.printer,
                        style          => rec_print_options.print_style,
                        copies         => rec_print_options.number_of_copies, /* Bug 4116833 */
                        save_output    => hr_general.char_to_bool(rec_print_options.save_output),
                        print_together => l_print_together);
     -- Submit report
     IF g_debug THEN
         hr_utility.set_location('payroll_action id    '|| p_payroll_action_id,25);
     END IF;

    ps_request_id := fnd_request.submit_request
    ('PAY',
    l_short_report_name,
     NULL,
     NULL,
     FALSE,
     'P_PAYROLL_ACTION_ID='||p_payroll_action_id,
     'P_ASSIGNMENT_ID='||l_parameters.assignment_id,
     'P_BUSINESS_GROUP_ID='||l_parameters.business_group_id,
     'P_EMPLOYEE_TYPE='||l_parameters.employee_type,
     'P_FINANCIAL_YEAR='||l_parameters.Financial_year,
     'P_LST_YR_TERM='||l_parameters.lst_yr_term,
     'P_PAYROLL_ID='||l_parameters.payroll_id,
     'P_REGISTERED_EMPLOYER='||l_parameters.legal_employer);

  IF g_debug THEN
      hr_utility.set_location('End of spawn_ps_report',4);
  END IF;

EXCEPTION
  WHEN others THEN
    IF g_debug THEN
        hr_utility.set_location('error raised in spawn_ps_report procedure ',5);
    END if;
    RAISE;
 END;




begin
   g_debug := hr_utility.debug_enabled;
   g_pre01jul1983_value :=0;
   g_post30jun1983_value :=0;
   g_etp_gross :=0;
   g_etp_tax :=0;
   g_assessable :=0;
   g_lump_sum_e :=0;
   g_total_gross :=0;
   g_total_workplace :=0; /* 4015082 */
   g_total_cdep :=0;
   g_total_allowance :=0;
   g_total_fbt :=0;
   g_total_gross :=0;
   /*Begin 8587013 - Set the values of variables to zero*/
   g_total_resc :=0;
   g_total_foreign_income :=0;
   /*End 8587013*/

   x :=0;
  g_bal_dim_level := 'N';

end pay_au_recon_summary;

/
