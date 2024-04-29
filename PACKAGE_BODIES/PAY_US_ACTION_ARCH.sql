--------------------------------------------------------
--  DDL for Package Body PAY_US_ACTION_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_ACTION_ARCH" AS
/* $Header: pyusxfrp.pkb 120.15.12010000.14 2010/03/03 13:51:27 mikarthi ship $ */
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

    Name        : pay_us_action_arch

    Description : This procedure is used by the External Process
                  Archive process to archive the Employee and
                  Employer Balances in pay_action_information table.

    Change List
    -----------
    Date        Name      Vers    Bug No    Description
    ----------- --------- ------  -------   --------------------------
    03-feb-2010 mikarthi  115.124 8688998   Adding two more parameters
                                            1. p_archive_balance_info
                                            2. p_legislation_code
                                            while calling the procedure
                                            pay_ac_action_arch.get_last_xfr_info
    28-Jan-2010 npannamp  115.123 8768738   Removed fix done in 8688998.
    28-Dec-2009 npannamp  115.122 8768738   Added code to update payroll_id column
                                            in pay_payroll_actions table. Procedure
                                            action_archinit modified.
    19-Oct-2009 kagangul  115.121 8688998   Adding two more parameters
					    1. p_archive_balance_info
					    2. p_legislation_code
					    while calling the procedure
					    pay_ac_action_arch.get_last_xfr_info
    24-AUG-2009 rnestor		115.120  8832183 Added Jurst check
	18-AUG-2009 rnestor    115.119  8804636  Added date check to c_emp_state_info
	04-MAY-2009 skpatil   115.118 8433161   To display FIt Exempt and SIT Exempt
							  status at Check writer XML
    31-MAR-2009 sudedas   115.117 3816988   Added proc action_archdeinit
    04-DEC-2008 tclewis   115.115           Added code for SUI 1 EE.
    27-SEP-2008 sudedas   115.114 7418142   Changed cursor c_get_unproc_asg
    05-SEP-2008 asgugupt  115.113 7379102   Changed c_time_period
    03-MAR-2008 sudedas   115.112 6827021   Changed action_archive_data
                                            For Multi Assignment Enabled
                                            Payroll.
    13-09-2007  sausingh  115.111 5635335   Added nvl condition in procedure
                                            update_ytd_withheld for action_info8
                                            and actioninfo9
    21-08-2007  sausingh  115.110           Added Cursor get_display_name
                                            to proc update_ytd_withheld
    26-JUN-2007 asasthan  115.109 5868672   Head Tax info retrieved from
                                            JIT table.
    28-NOV-2006 saikrish  115.108 5683349   Corrected the signature of
                                            pay_get_tax_exists_pkg.
    15-NOV-2006 ahanda    115.107 5264527   Changed select for action_creation
                                            code to add hints.
                                            Also, changed sql statement to
                                            use base table instead secure
                                            views.
    13-APR-2006 ahanda    115.106           Changed HBR code to use amount
                                            from pay_hours_by_rate_v.
    24-MAR-2006 ahanda    115.105  4924263  Changed archive code to not check
                                            if tax exists in a JD for
                                            Bal Adj action types.
    27-FEB-2006 ahanda    115.104  5058507  Changed HBR code to store the
                                            pay value as amount as for Retro,
                                            Hours or Rate could be null.
    27-FEB-2006 ahanda    115.103  5058507  Changed HBR code to check for
                                            Zero Retro Hours.
    12-FEB-2006 ahanda    115.102  5003054  Changed code to archive multiple
                                            retro entries for same element type
    03-FEB-2006 ahanda    115.101  5003054  Added logic to retropay and hrsXrate
    07-OCT-2005 ahanda    115.100  4642121  Changed the logic to archive element
                                            even if Gross and Net Run are zero
                                   4552807  Added call to process_baladj_elements
                                            to archive baladj elements.
                                   4640155  Changed cursor to get distinct JD
    20-JUL-2005 ahanda    115.99   4500097  Added Ordered hint for subquery
    28-JUN-2005 ahanda    115.98   4449712  Changed call to get_last_xfr_info
                                            to pass EMPLOYEE DETAILS.
                                            Changed cursor c_get_jd to not
                                            pick up Federal JD.
    06-JUN-2005 ahanda    115.97            Changed populate_emp_hours_by_rate
                                            Storing Hours and Rate in canonical
                                            format.
    14-MAR-2005 sackumar  115.96  4222032   Change in the Range Cursor removing
                                            use of bind Variable -
                                            :payroll_action_id
    17-MAR-2005 ahanda     115.94  4247361  Changed cursor c_payment_info
                                            to add a distinct to ensure
                                            and assignment is returned
                                            only once.
                                   4212744  Changed cursor c_get_baladj_jd
                                            to remove join to
                                            pay_run_result_values and other
                                            tables.
    05-NOV-2004 ahanda     115.94  3995766  Archiver not archiving
                                            Balance Adjustment and Reversal
    03-NOV-2004 ahanda     115.93  3979501  Added support for RANGE_PERSON_ID
    06-OCT-2004 ahanda     115.92  3940380  Added parameter p_xfr_action_id
                                            to get_last_xfr_info
    06-AUG-2004 ahanda     115.91  3814488  Added populate_emp_hours_by_rate
                                            to archive all elements returned
                                            by pay_hours_by_rate view.
    05-AUG-2004 ahanda     115.90  3814488  Added logic for Hours By Rate
    20-JUL-2004 ahanda     115.89  3780771  Changed order by in the action
                                            creation code
    23-JUN-2004 ahanda     115.88  3711280  Changed the logic for NR/R
                                            Also, balance call for Medicare ER
                                            and SS ER Liability
    14-MAY-2004 rsethupa   115.87  3231253  Added Comments
    13-MAY-2004 rsethupa   115.86  3231253  Added code to archive STEIC Advance
                                            balance in the categories
					    'AC DEDUCTIONS' and 'US STATE'
    30-APR-2004 saurgupt   115.85  3561821  Modified the procedure
                                            update_ytd_withheld
					    to check for current values for
					    the balances along with the YTD
					    values before archiving.
    16-APR-2004 rsethupa   115.84  3311866  US SS Payslip currency Format Enh.
                                            Changed code to archive currency
                                            data in canonical format for the
                                            action info categories 'AC
                                            DEDUCTIONS'and 'US WITHHOLDINGS'.
    12-MAR-2004 rsethupa   115.83  3452149  Modified procedures process_actions
                                            and action_archive_data to
                                            archive Employee and W4 Information
                                            for primary assignment in case
                                            multiple assignments flag is checked
                                            and any assignment other than the
                                            primary is paid.
    16-JAN-2004 kvsankar   115.82  3349855  Modified query for performance
                                            enhancement
    02-JAN-2004 ahanda     115.81           Changed cursor c_get_baladj_jd
                                            to pick up distinct jurisdictions
    04-DEC-2003 vpandya    115.80           Added logic to call
                                            first_time_process
                                            even though the Ext Proc Arch
                                            has already been run for the
                                            current year before.
    25-NOV-2003 vpandya    115.79  3280589  Changed action_archive_data:
                                            populating gv_multi_payroll_pymt.
                                            Changed condition for Termi Asg.
                                            Removed create_child_actions proc.
    17-Nov-2003 vpandya    115.78  3262057  Changed populate_puv_tax_balances:
                                            Added condition in the cursor
                                            c_get_jd in the second select
                                            clause.
    07-Nov-2003 vpandya    115.77  3243503  Changed action_archive_data:
                                            selecting assignment_action_id
                                            in c_payment_info cursor to
                                            get master pp asg act id again in
                                            ln_asg_action_id variable.
    06-Nov-2003 vpandya    115.76  3231337  Changed populate_puv_tax_balances:
                                            Removed cursors c_get_sp_rr_jd and
                                            c_get_rr_jd. Added cursor c_get_jd.
                                            Added function check_tax_exists.
    05-Nov-2003 vpandya    115.75  3237538  Changed action_archive_data:
                                            added cursor c_all_runs.
    31-Oct-2003 vpandya    115.74  3225286  Changed process_actions
                                            Added cursor c_chk_act_type to check
                                            if previous archiver is of balance
                                            adjustement then call first_time..
                                            procedure instead of calling
                                            get_current_elements.
    08-Oct-2003 ahanda     115.73  3181365  Changed -
                                                populate_federal_tax_balances
                                            and update_ytd_withheld
    18-Sep-2003 vpandya    115.72           Changed range cursor to fix gscc
                                            error on date conversion. Using
                                            fnd_date.date_to_canonical instead
                                            to_char and canonical_to_date
                                            instead of to_date.
    10-Sep-2003 ekim       115.71  3119792  Added check for whether the archiver
                                   2880047  is run for a given payroll
                                            in action_archive_data procedure.
                                            This sets variable g_xfr_run_exists.
                                            Added call to
                                               process_additional_elements
                                            Added procedure
                                               change_processing_priority
                                               and called this procedure before
                                               insert_rows_thro_api_process.
                                            Terminated Assignment check:
                                               c_get_term_asg
    06-Aug-2003 vpandya    115.70  3050620  Changed action_action_creation to
                                            create assignment action for
                                            zero net pay using view
                                            pay_payment_information.
    28-Jul-2003 vpandya    115.69  3053917  Passing parameter
                                            p_ytd_balcall_aaid to
                                            get_personal_information.
    13-Jun-2003 ekim       115.68  3005678  Removed call update_federal_values
                                            in between if..else statements
                                            in populate_federal_tax_balances
                                            and left one call at the end of the
                                            procedure.
    02-Apr-2003 ekim       115.67           Removed ppa.action_status='C'
                                            for all queries as paa.action_status
                                            ='C' is the only required.
    28-Mar-2003 ekim       115.66  2875350  Made performance fix on
                                            c_get_rr_jd, c_get_sp_rr_jd,
                                            c_get_baladj_jd
                                            - Added parameter
                                              cp_run_effective_date in cursor.
                                   2874412  Changed c_get_employee_info to
                                            add pre_name_adjunt and suffix.
    18-Mar-2003 ekim       115.65  2855261  Changed default processing
                                            priority in update_ytd_withheld
                                            to 10.
                                            Changed processing priority
                                            for all Tax Deductions.
    06-Feb-2003 ekim       115.64  2315822  Added additional parameter
                                            p_sepchk_flag,p_assignment_id
                                            in get_xfr_elements procedure call.
    31-Jan-2003 ekim       115.63  2752134  Added YTD balance to be archived
                                            for EIC Advance
    02-DEC-2002 ahanda     115.62           Changed package to fix GSCC warnings
    25-NOV-2002 ahanda     115.61  2658611  Changed update_employee_information
                                            to pass assignment_id.
    19-NOV-2002 vpandya    115.60           Calling set_error_message function
                                            of pay_emp_action_arch from all
                                            exceptions to get error message
                                            Remote Procedure Calls(RPC or Sub
                                            program)
    17-NOV-2002 ahanda     115.59           Added function get_balance_value
                                            Balance call done only if def bal id
                                            is not null.
    01-NOV-2002 ahanda     115.58           Changed error handling.
    14-OCT-2002 ahanda     115.57  2500413  Changed calls to update_ytd_withheld
                                            to populate processing_prioirty for
                                            Tax Deductions
                                   2500381  Changed Code to update Employee Name
                                   2562608  Changed range and action creation
                                            cursor to pick up reversals.
    15-OCT-2002 tmehra     115.56           Added code to archive the PQP
                                            (Alien) balances.
    14-OCT-2002 ahanda     115.55           Changed update_ytd_withheld to
                                            populate processing priority.
    23-SEP-2002 ahanda     115.54  2498029  Changed populate_school_tax_balances
                                   2532436  and populate_state_tax_balances
    06-SEP-2002 ahanda     115.53           Fixed GSCC Warnings.
    17-JUN-2002 ahanda     115.52  2447717  Changed package to populate tax
                                   2365908  deductions if location has changed.
    14-MAY-2002 ahanda     115.51           Moved procedures
                                              - get_last_xfr_info
                                              - get_last_pymt_info
                                            to pay_ac_action_arch
    24-APR-2002 ahanda     115.50           Changed c_get_rr_jd for performance.
    18-MAR-2002 ahanda     115.49  2204512  Changed the way we populate NR/R.
                                            Fixed archiving for Bal Adj for
                                            which Pre Pay flag is checked.
    18-FEB-2002 ahanda     115.48  2200748  Changed W4 to archive the Work and
                                            Resident JDs. Changed Adj Bal proc
                                            to pass the bal adj action_id.
    14-FEB-2002 ahanda     115.47  2189810  Changed c_time_period to get the
                                            time_period_id from per_time_periods
    14-FEB-2002 ahanda     115.46           Changed archinit to check for the
                                            new dimension only if multi asgn
                                            is enabled. This removed dependency
                                            on HRGLOBAL for one off patch.
    11-FEB-2002 ahanda     115.45           Changed fetch for cursor
                                            c_get_states_jit in archinit
    05-FEB-2002 ahanda     115.44           Changed package for Bal Adjustments.
    26-JAN-2002 ahanda     115.43           Added dbdrv commands.
    22-JAN-2002 ahanda     115.42           Changed package to take care
                                            of Multi Assignment Processing.

    ****************************************************************************
    25-JAN-2001 asasthan   115.0            Created.

  ******************************************************************************/

  /******************************************************************************
  ** Package Local Variables
  ******************************************************************************/
   gv_package        VARCHAR2(100) := 'pay_us_action_arch';
   gn_gross_earn_def_bal_id  number := 0;
   gn_payments_def_bal_id    number := 0;

  /***************************************************************************
   Name      : change_processing_priority
   Purpose   : Reset the processing priority from the element processing
               priority to the archiver processing priority for Tax Deductions
   **************************************************************************/
   PROCEDURE change_processing_priority IS
   BEGIN
    IF pay_ac_action_arch.lrr_act_tab.count > 0 THEN
     for i in pay_ac_action_arch.lrr_act_tab.first ..
              pay_ac_action_arch.lrr_act_tab.last loop
       if pay_ac_action_arch.lrr_act_tab(i).action_info_category
          = 'AC DEDUCTIONS' then
          if pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'FIT Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '1';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'SS EE Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '2';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'SS Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '2';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'Medicare EE Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '3';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'EIC Advance' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '4';
            if pay_ac_action_arch.lrr_act_tab(i).act_info9 > 0 then
               pay_ac_action_arch.lrr_act_tab(i).act_info9 :=
                  (pay_ac_action_arch.lrr_act_tab(i).act_info9 * -1);
            end if;
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'SIT Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '5';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'County Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '6';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'SDI Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'SDI EE Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
            pay_ac_action_arch.lrr_act_tab(i).act_info10 := 'SDI Withheld';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'SDI1 Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'SDI1 EE Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
            pay_ac_action_arch.lrr_act_tab(i).act_info10 := 'SDI1 Withheld';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'Non W2 FIT Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'SUI Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'SUI EE Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
            pay_ac_action_arch.lrr_act_tab(i).act_info10 := 'SUI Withheld';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'SUI1 Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'SUI1 EE Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
            pay_ac_action_arch.lrr_act_tab(i).act_info10 := 'SUI1 Withheld';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'WC Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'Workers Comp Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
            pay_ac_action_arch.lrr_act_tab(i).act_info10 := 'WC Withheld';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'WC2 Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'Workers Comp2 Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
            pay_ac_action_arch.lrr_act_tab(i).act_info10 := 'WC2 Withheld';
	  elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
	     = 'STEIC Advance' then
	    pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';  /*Bug 3231253*/
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'Head Tax Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'City Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
          elsif pay_ac_action_arch.lrr_act_tab(i).act_info10
             = 'School Withheld' then
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := '10';
          end if;
        end if;
      end loop;
     end if;
   END change_processing_priority;

  /******************************************************************************
   Name      : get_payroll_action_info
   Purpose   : This returns the Payroll Action level
               information for Tax Filing (FLS)/Payslip Archiver.
   Arguments : p_payroll_action_id - Payroll_Action_id of archiver
               p_start_date        - Start date of Archiver
               p_end_date          - End date of Archiver
               p_business_group_id - Business Group ID
               p_cons_set_id       - Consolidation Set when submitting Archiver
               p_payroll_id        - Payroll ID when submitting Archiver
  ******************************************************************************/
  PROCEDURE get_payroll_action_info(p_payroll_action_id     in        number
                                   ,p_end_date             out nocopy date
                                   ,p_start_date           out nocopy date
                                   ,p_business_group_id    out nocopy number
                                   ,p_cons_set_id          out nocopy number
                                   ,p_payroll_id           out nocopy number
                                   )
  IS
    cursor c_payroll_Action_info
              (cp_payroll_action_id in number) is
      select effective_date,
             start_date,
             business_group_id,
             to_number(substr(legislative_parameters,
                instr(legislative_parameters,
                         'TRANSFER_CONSOLIDATION_SET_ID=')
                + length('TRANSFER_CONSOLIDATION_SET_ID='))),
             to_number(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'TRANSFER_PAYROLL_ID=')
                + length('TRANSFER_PAYROLL_ID='),
                (instr(legislative_parameters,
                         'TRANSFER_CONSOLIDATION_SET_ID=') - 1 )
              - (instr(legislative_parameters,
                         'TRANSFER_PAYROLL_ID=')
              + length('TRANSFER_PAYROLL_ID='))))))
        from pay_payroll_actions
       where payroll_action_id = cp_payroll_action_id;

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_cons_set_id       NUMBER;
    ln_payroll_id        NUMBER;
    lv_procedure_name    VARCHAR2(100) := '.get_payroll_action_info';

    lv_error_message     VARCHAR2(200);
    ln_step              NUMBER;

   BEGIN
       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       ln_step := 1;
       open c_payroll_action_info(p_payroll_action_id);
       fetch c_payroll_action_info into ld_end_date,
                                        ld_start_date,
                                        ln_business_group_id,
                                        ln_cons_set_id,
                                        ln_payroll_id;
       close c_payroll_action_info;

       hr_utility.set_location(gv_package || lv_procedure_name, 30);
       p_end_date          := ld_end_date;
       p_start_date        := ld_start_date;
       p_business_group_id := ln_business_group_id;
       p_cons_set_id       := ln_cons_set_id;
       p_payroll_id        := ln_payroll_id;
       hr_utility.set_location(gv_package || lv_procedure_name, 50);
       ln_step := 2;

  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_payroll_action_info;


  /*********************************************************************
   Name      : get_defined_balance_id
   Purpose   : This function returns the defined_balance_id for a given
               Balance Name and Dimension.
               The function is used to get the defined_balance_id
               of the Balance Names stored in the Action Information DF
               flexfield for US Federal, State, County, City and School
               Districts.
   Arguments :
   Notes     :
  *********************************************************************/
  FUNCTION get_defined_balance_id(
                p_business_group_id in number
               ,p_balance_name      in varchar2
               ,p_balance_dimension in varchar2)
  RETURN NUMBER
  IS

    cursor c_get_defined_balance_id (
               cp_business_group_id in number,
               cp_balance_name      in varchar2,
               cp_balance_dimension in varchar2 ) is
       select pdb.defined_balance_id
         from pay_defined_balances pdb,
              pay_balance_dimensions pbd,
              pay_balance_types pbt
        where pbt.balance_name = cp_balance_name
          and pbd.database_item_suffix= cp_balance_dimension
          and pbt.balance_type_id = pdb.balance_type_id
          and pbd.balance_dimension_id = pdb.balance_dimension_id
          and ((pbt.legislation_code = 'US' and
                pbt.business_group_id is null)
            or (pbt.legislation_code is null and
                pbt.business_group_id = cp_business_group_id))
          and ((pdb.legislation_code ='US' and
                pdb.business_group_id is null)
            or (pdb.legislation_code is null and
                pdb.business_group_id = cp_business_group_id));

    ln_defined_balance_id    NUMBER;

  BEGIN
      hr_utility.trace('opened c_get_defined_balance');
      open c_get_defined_balance_id(p_business_group_id,
                                    p_balance_name,
                                    p_balance_dimension);

      fetch c_get_defined_balance_id into ln_defined_balance_id;
      if c_get_defined_balance_id%notfound then
         hr_utility.trace('Defined balance Id not found');
         -- Do not error out if the defined_balance_id does not exist
         -- Pass Null instead.
      end if;
      close c_get_defined_balance_id;
      hr_utility.trace('ln_defined_balance_id = ' ||
                           to_char(ln_defined_balance_id));

      return (ln_defined_balance_id);

  END get_defined_balance_id;


  /******************************************************************
   Name      : action_range_cursor
   Purpose   : This returns the select statement that is
               used to created the range rows for the
               Tax Filing (FLS)/Payslip Archiver.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ******************************************************************/
  PROCEDURE action_range_cursor(
                    p_payroll_action_id in        number
                   ,p_sqlstr           out nocopy varchar2)
  IS

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_cons_set_id       NUMBER;
    ln_payroll_id        NUMBER;

    lv_sql_string        VARCHAR2(32000);
    lv_procedure_name    VARCHAR2(100) := '.action_range_cursor';

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_cons_set_id       => ln_cons_set_id
                            ,p_payroll_id        => ln_payroll_id);
     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     lv_sql_string :=
         'select distinct paf.person_id
            from pay_assignment_actions paa,
                 pay_payroll_actions ppa,
                 per_assignments_f paf
           where ppa.business_group_id  = ''' || ln_business_group_id || '''
             and  ppa.effective_date between fnd_date.canonical_to_date(''' ||
             fnd_date.date_to_canonical(ld_start_date) || ''')
                                         and fnd_date.canonical_to_date(''' ||
             fnd_date.date_to_canonical(ld_end_date) || ''')
             and ppa.action_type in (''U'',''P'',''B'',''V'')
             and decode(ppa.action_type,
                 ''B'', nvl(ppa.future_process_mode, ''Y''),
                 ''N'') = ''N''
             and ppa.consolidation_set_id = ''' || ln_cons_set_id || '''
             and ppa.payroll_id  = ''' || ln_payroll_id || '''
             and ppa.payroll_action_id = paa.payroll_action_id
             and paa.action_status = ''C''
             and paa.source_action_id is null
             and paf.assignment_id = paa.assignment_id
             and ppa.effective_date between paf.effective_start_date
                                        and paf.effective_end_date
             and not exists
                 (select /*+ ORDERED */
                         1
                    from pay_action_interlocks pai,
                         pay_assignment_actions paa1,
                         pay_payroll_actions ppa1
                   where pai.locked_action_id = paa.assignment_action_id
                   and paa1.assignment_action_id = pai.locking_action_id
                   and ppa1.payroll_action_id = paa1.payroll_action_id
                   and ppa1.action_type =''X''
                   and ppa1.report_type = ''XFR_INTERFACE'')
            and :payroll_action_id is not null
          order by paf.person_id';

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     p_sqlstr := lv_sql_string;
     hr_utility.set_location(gv_package || lv_procedure_name, 50);

  END action_range_cursor;


  /************************************************************
   Name      : action_action_creation
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the Archiver process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/
  PROCEDURE action_action_creation(
                 p_payroll_action_id in number
                ,p_start_person_id   in number
                ,p_end_person_id     in number
                ,p_chunk             in number)
  IS

   cursor c_get_xfr_emp( cp_start_person_id     in number
                        ,cp_end_person_id       in number
                        ,cp_cons_set_id         in number
                        ,cp_payroll_id          in number
                        ,cp_business_group_id   in number
                        ,cp_start_date          in date
                        ,cp_end_date            in date
                        ) is
     select /*+ INDEX(PAF PER_ASSIGNMENTS_F_N12)
                INDEX(PPA PAY_PAYROLL_ACTIONS_N50)
                INDEX(PAA PAY_ASSIGNMENT_ACTIONS_N51) */
            paa.assignment_id,
            paa.tax_unit_id,
            ppa.effective_date,
            ppa.date_earned,
            ppa.action_type,
            paa.assignment_action_id,
            paa.payroll_action_id
       from pay_payroll_actions ppa,
            pay_assignment_actions paa,
            per_assignments_f paf
     where paf.person_id between cp_start_person_id
                             and cp_end_person_id
       and paa.assignment_id = paf.assignment_id
       and ppa.effective_date between paf.effective_start_date
                                  and paf.effective_end_date
       and ppa.consolidation_set_id = cp_cons_set_id
       and paa.action_status = 'C'
       and ppa.payroll_id = cp_payroll_id
       and ppa.payroll_action_id = paa.payroll_action_id
       and ppa.business_group_id  = cp_business_group_id
       and ppa.effective_date between cp_start_date
                                  and cp_end_date
       and ppa.action_type in ('U','P','B','V')
       and decode(ppa.action_type,
                 'B', nvl(ppa.future_process_mode, 'Y'),
                 'N') = 'N'
       and paa.source_action_id is null
       and not exists
           (select 'x'
              from pay_action_interlocks pai1,
                   pay_assignment_actions paa1,
                   pay_payroll_actions ppa1
             where pai1.locked_action_id = paa.assignment_action_id
             and paa1.assignment_action_id = pai1.locking_action_id
             and ppa1.payroll_action_id = paa1.payroll_action_id
             and ppa1.action_type ='X'
             and ppa1.report_type = 'XFR_INTERFACE')
      order by 1,2,3,5,6;

   cursor c_get_xfr_range_emp(
                         cp_payroll_action_id   in number
                        ,cp_chunk_number        in number
                        ,cp_cons_set_id         in number
                        ,cp_payroll_id          in number
                        ,cp_business_group_id   in number
                        ,cp_start_date          in date
                        ,cp_end_date            in date
                        ) is
     select /*+ INDEX(PPR PAY_POPULATION_RANGES_N4)
                INDEX(PAF PER_ASSIGNMENTS_F_N12)
                INDEX(PPA PAY_PAYROLL_ACTIONS_N50)
                INDEX(PAA PAY_ASSIGNMENT_ACTIONS_N51) */
            paa.assignment_id,
            paa.tax_unit_id,
            ppa.effective_date,
            ppa.date_earned,
            ppa.action_type,
            paa.assignment_action_id,
            paa.payroll_action_id
       from pay_payroll_actions ppa,
            pay_assignment_actions paa,
            per_assignments_f paf,
            pay_population_ranges ppr
      where ppr.payroll_action_id = cp_payroll_action_id
        and ppr.chunk_number = cp_chunk_number
        and paf.person_id = ppr.person_id
        and ppa.effective_date between paf.effective_start_date
                                   and paf.effective_end_date
        and paa.assignment_id = paf.assignment_id
        and ppa.consolidation_set_id = cp_cons_set_id
        and paa.action_status = 'C'
        and ppa.payroll_id = cp_payroll_id
        and ppa.payroll_action_id = paa.payroll_action_id
        and ppa.business_group_id  = cp_business_group_id
        and ppa.effective_date between cp_start_date
                                   and cp_end_date
        and ppa.action_type in ('U','P','B','V')
        and decode(ppa.action_type,
                  'B', nvl(ppa.future_process_mode, 'Y'),
                  'N') = 'N'
        and paa.source_action_id is null
        and not exists
            (select 'x'
               from pay_action_interlocks pai1,
                    pay_assignment_actions paa1,
                    pay_payroll_actions ppa1
              where pai1.locked_action_id = paa.assignment_action_id
              and paa1.assignment_action_id = pai1.locking_action_id
              and ppa1.payroll_action_id = paa1.payroll_action_id
              and ppa1.action_type ='X'
              and ppa1.report_type = 'XFR_INTERFACE')
      order by 1,2,3,5,6;

   cursor c_master_action(cp_prepayment_action_id number) is
     select max(paa.assignment_action_id)
       from pay_payroll_actions ppa,
            pay_assignment_actions paa,
            pay_action_interlocks pai
      where pai.locking_action_Id =  cp_prepayment_action_id
        and paa.assignment_action_id = pai.locked_action_id
        and paa.source_action_id is null
        and ppa.payroll_action_id = paa.payroll_action_id
        and ppa.action_type in ('R', 'Q');

    ln_assignment_id        NUMBER := 0;
    ln_tax_unit_id          NUMBER := 0;
    ld_effective_date       DATE   := to_date('1900/12/31','YYYY/MM/DD');
    ld_date_earned          DATE;
    lv_action_type          VARCHAR2(10);
    ln_asg_action_id        NUMBER := 0;
    ln_payroll_action_id    NUMBER := 0;

    ln_master_action_id     NUMBER := 0;

    ld_end_date             DATE;
    ld_start_date           DATE;
    ln_business_group_id    NUMBER;
    ln_cons_set_id          NUMBER;
    ln_payroll_id           NUMBER;

    ln_prev_asg_action_id   NUMBER := 0;
    ln_prev_assignment_id   NUMBER := 0;
    ln_prev_tax_unit_id     NUMBER := 0;
    ld_prev_effective_date  DATE   := to_date('1800/12/31','YYYY/MM/DD');

    ln_xfr_action_id        NUMBER;

    lv_serial_number        VARCHAR2(30);
    lv_procedure_name       VARCHAR2(100) := '.action_action_creation';
    lv_error_message        VARCHAR2(200);
    ln_step                 NUMBER;

    lb_range_person         BOOLEAN;

  begin
     ln_step := 1;
     pay_emp_action_arch.gv_error_message := NULL;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_cons_set_id       => ln_cons_set_id
                            ,p_payroll_id        => ln_payroll_id);
     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     lb_range_person := pay_ac_utility.range_person_on(
                           p_report_type      => 'XFR_INTERFACE'
                          ,p_report_format    => 'TAXARCH'
                          ,p_report_qualifier => 'FED'
                          ,p_report_category  => 'RT');

     ln_step := 2;
     if lb_range_person then
        open c_get_xfr_range_emp(p_payroll_action_id
                                ,p_chunk
                                ,ln_cons_set_id
                                ,ln_payroll_id
                                ,ln_business_group_id
                                ,ld_start_date
                                ,ld_end_date);
     else
        open c_get_xfr_emp( p_start_person_id
                           ,p_end_person_id
                           ,ln_cons_set_id
                           ,ln_payroll_id
                           ,ln_business_group_id
                           ,ld_start_date
                           ,ld_end_date);
     end if;

     -- Loop for all rows returned for SQL statement.
     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     loop
        if lb_range_person then
           fetch c_get_xfr_range_emp into ln_assignment_id,
                                          ln_tax_unit_id,
                                          ld_effective_date,
                                          ld_date_earned,
                                          lv_action_type,
                                          ln_asg_action_id,
                                          ln_payroll_action_id;
           exit when c_get_xfr_range_emp%notfound;
        else

           fetch c_get_xfr_emp into ln_assignment_id,
                                    ln_tax_unit_id,
                                    ld_effective_date,
                                    ld_date_earned,
                                    lv_action_type,
                                    ln_asg_action_id,
                                    ln_payroll_action_id;

           exit when c_get_xfr_emp%notfound;
        end if;

        hr_utility.set_location(gv_package || lv_procedure_name, 40);
        hr_utility.trace('ln_assignment_id = ' ||
                             to_char(ln_assignment_id));

        /********************************************************
        ** If Balance Adjustment, only create one assignment
        ** action record. As there could be multiple assignment
        ** actions for Balance Adjustment, we lock all the
        ** balance adj record.
        ** First time the else portion will be executed which
        ** creates the assignment action. If the Assignment ID,
        ** Tax Unit ID and Effective Date is same and Action
        ** Type is Balance Adj only lock the record
        ********************************************************/
        if ln_assignment_id = ln_prev_assignment_id and
           ln_tax_unit_id = ln_prev_tax_unit_id and
           ld_effective_date = ld_prev_effective_date and
           lv_action_type = 'B' and
           ln_asg_action_id <> ln_prev_asg_action_id then

           hr_utility.set_location(gv_package || lv_procedure_name, 50);
           hr_utility.trace('Locking Action = ' || ln_xfr_action_id);
           hr_utility.trace('Locked Action = '  || ln_asg_action_id);
           hr_nonrun_asact.insint(ln_xfr_action_id
                                 ,ln_asg_action_id);
        else
           hr_utility.set_location(gv_package || lv_procedure_name, 60);
           hr_utility.trace('Action_type = '||lv_action_type );

           select pay_assignment_actions_s.nextval
             into ln_xfr_action_id
             from dual;

           -- insert into pay_assignment_actions.
           hr_nonrun_asact.insact(ln_xfr_action_id,
                                  ln_assignment_id,
                                  p_payroll_action_id,
                                  p_chunk,
                                  ln_tax_unit_id,
                                  null,
                                  'U',
                                  null);
           hr_utility.set_location(gv_package || lv_procedure_name, 70);
           hr_utility.trace('ln_asg_action_id = ' || ln_asg_action_id);
           hr_utility.trace('ln_xfr_action_id = ' || ln_xfr_action_id);
           hr_utility.trace('p_payroll_action_id = ' || p_payroll_action_id);
           hr_utility.trace('ln_tax_unit_id = '   || ln_tax_unit_id);
           hr_utility.set_location(gv_package || lv_procedure_name, 80);

           -- insert an interlock to this action
           hr_utility.trace('Locking Action = ' || ln_xfr_action_id);
           hr_utility.trace('Locked Action = '  || ln_asg_action_id);
           hr_nonrun_asact.insint(ln_xfr_action_id,
                                  ln_asg_action_id);

           hr_utility.set_location(gv_package || lv_procedure_name, 90);

           /********************************************************
           ** For Balance Adj we put only the first assignment action
           ********************************************************/
           lv_serial_number := lv_action_type || 'N' ||
                               ln_asg_action_id;

           update pay_assignment_actions
              set serial_number = lv_serial_number
            where assignment_action_id = ln_xfr_action_id;

           hr_utility.set_location(gv_package || lv_procedure_name, 100);

        end if ; --ln_assignment_id ...

        ln_prev_tax_unit_id    := ln_tax_unit_id;
        ld_prev_effective_date := ld_effective_date;
        ln_prev_assignment_id  := ln_assignment_id;
        ln_prev_asg_action_id  :=  ln_asg_action_id;

     end loop;
     if lb_range_person then
        close c_get_xfr_range_emp;
     else
        close c_get_xfr_emp;
     end if;

     ln_step := 5;

  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END action_action_creation;


  /************************************************************
   Name      : action_archinit
   Purpose   : This performs the context initialization.
   Arguments :
   Notes     :
  ************************************************************/
  PROCEDURE action_archinit(
                p_payroll_action_id in number) is

    lv_state_code             VARCHAR2(2);
    lv_sit_exists             VARCHAR2(1);
    lv_sdi_ee_exists          VARCHAR2(1);
    lv_sdi_er_exists          VARCHAR2(1);
    lv_sui_ee_exists          VARCHAR2(1);
    lv_sui_er_exists          VARCHAR2(1);
    ln_index                  NUMBER;

    lv_jurisdiction_code      VARCHAR2(11);
    lv_county_tax_exists      VARCHAR2(1);
    lv_county_sd_tax_exists   VARCHAR2(1);
    lv_county_head_tax_exists VARCHAR2(1);

    ln_fed_count              NUMBER := 0;

    ln_state_count            NUMBER := 0;
-- TCL_SUI1 begin
    ln_state2_count            NUMBER := 0;
-- TCL_SUI1 end

    ln_county_count           NUMBER := 0;
    ln_city_count             NUMBER := 0;
    ln_schdist_count          NUMBER := 0;

    lv_balance_name           VARCHAR2(80);
    ln_balance_type_id        NUMBER;
    lv_balance_dimension      VARCHAR2(80);

    ld_effective_date         DATE;

    lv_pymt_dimension         VARCHAR2(50);
    lv_jd_pymt_dimension      VARCHAR2(50);
    lv_subj_pymt_dimension    VARCHAR2(50);

    ld_end_date               DATE;
    ld_start_date             DATE;
    ln_business_group_id      NUMBER;
    ln_cons_set_id            NUMBER;
    ln_payroll_id             NUMBER;

    lv_error_message          VARCHAR2(500);
    lv_procedure_name         VARCHAR2(100) := '.action_archinit';
    ln_step                   NUMBER;

    cursor c_asg_actions (cp_payroll_action_id in number) is
      select ppa.effective_date
        from pay_payroll_actions ppa
       where ppa.payroll_action_id = cp_payroll_action_id;

    cursor c_get_balance_type_id (cp_balance_name in varchar2) is
      select balance_type_id
        from pay_balance_types
       where balance_name = cp_balance_name
         and legislation_code = 'US';

    cursor c_get_balances (cp_action_context in varchar2) is
      select fdu.form_left_prompt, pbt.balance_type_id
        from fnd_descr_flex_col_usage_tl fdu,
             pay_balance_types pbt,
             fnd_application fa
       where fdu.descriptive_flexfield_name = 'Action Information DF'
         and fdu.language = 'US'
         and pbt.balance_name = fdu.form_left_prompt
         and pbt.legislation_code = 'US'
         and fdu.descriptive_flex_context_code = cp_action_context
         and fdu.form_left_prompt <> 'Resident/Non-Resident Flag'
         and fdu.form_left_prompt <> 'Resident Jurisdiction'
         and fa.application_id = fdu.application_id
         and fa.application_short_name = 'PAY'
      order by fdu.descriptive_flex_context_code, fdu.form_left_prompt;

    cursor c_get_states_jit (cp_effective_date in date) is
      select state_code,
             sit_exists,
             decode(sui_ee_wage_limit, null, 'N', 'Y'),
             decode(sui_er_wage_limit, null, 'N', 'Y'),
             decode(sdi_ee_wage_limit, null, 'N', 'Y'),
             decode(sdi_er_wage_limit, null, 'N', 'Y')
        from pay_us_state_tax_info_f
      where cp_effective_date between effective_start_date
                                  and effective_end_date
        and sta_information_category = 'State tax limit rate info'
      order by 1 ;

    cursor c_get_county_jit (cp_effective_date in date) is
      select jurisdiction_code,
             county_tax,
             head_tax,
             school_tax
        from pay_us_county_tax_info_f
      where cp_effective_date between effective_start_date
                                  and effective_end_date
        and cnty_information_category = 'County tax status info'
      order by 1 ;

    cursor c_get_act_param is
      select parameter_value
      from   pay_action_parameters
      where  parameter_name = 'INIT_PAY_ARCHIVE';

/* Bug 8768738 Fix */
  l_payroll_id NUMBER;
  leg_param    pay_payroll_actions.legislative_parameters%TYPE;
  l_ppa_payroll_id pay_payroll_actions.payroll_id%TYPE;
  l_key varchar2(30) := 'TRANSFER_PAYROLL_ID=';
  l_val pay_payroll_actions.legislative_parameters%TYPE;
/* Bug 8768738 Fix */
  BEGIN
     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 1);
     pay_emp_action_arch.gv_error_message := NULL;

     hr_utility.set_location(gv_package || lv_procedure_name, 2);
     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_cons_set_id       => ln_cons_set_id
                            ,p_payroll_id        => ln_payroll_id);
     hr_utility.set_location(gv_package || lv_procedure_name, 3);

/* Bug Fix 8768738 */
     SELECT legislative_parameters,payroll_id
     INTO leg_param,l_ppa_payroll_id
     FROM pay_payroll_actions
     WHERE payroll_action_id = p_payroll_action_id ;

     if instr(leg_param, l_key) <> 0 then
        l_val := substr(leg_param, instr(leg_param, l_key));
        if instr(l_val, ' ') = 0 then
           l_payroll_id := substr(l_val, length(l_key)+1);
        else
           l_payroll_id := substr(l_val, length(l_key)+1, instr(l_val,' ') - length(l_key));
        end if;
     end if;
   hr_utility.set_location(gv_package || lv_procedure_name, 4);
   -- Update the Payroll Action with the Payroll ID

   IF l_ppa_payroll_id IS NULL THEN

      UPDATE pay_payroll_actions
         SET payroll_id = l_payroll_id
       WHERE payroll_action_id = p_payroll_action_id;

   END IF;
   hr_utility.set_location(gv_package || lv_procedure_name, 5);
/* Bug Fix 8768738 */

     /*********************************************************************
     ** This cursor is used to call first_time_process from process_actions
     ** whenever it is set to either Y or end date of External Process
     ** Archive in YYYY/MM/DD format (canonical format).
     ** In other words, by setting this, it will behave like external
     ** process archiver is being run first time.
     *********************************************************************/

     gv_act_param_val := NULL;

     open  c_get_act_param;
     fetch c_get_act_param into gv_act_param_val;
     close c_get_act_param;

     ln_step := 2;

     if pay_emp_action_arch.gv_multi_leg_rule is null then
        pay_emp_action_arch.gv_multi_leg_rule
              := pay_emp_action_arch.get_multi_legislative_rule('US');
     end if;

     if pay_emp_action_arch.gv_multi_leg_rule = 'Y' then
        lv_pymt_dimension      := '_ASG_PAYMENTS';
        lv_jd_pymt_dimension   := '_ASG_PAYMENTS_JD';
        lv_subj_pymt_dimension := '_SUBJECT_TO_TAX_ASG_PAYMENTS';
     else
        lv_pymt_dimension      := '_PAYMENTS';
        lv_jd_pymt_dimension   := '_PAYMENTS_JD';
        lv_subj_pymt_dimension := '_SUBJECT_TO_TAX_PAYMENTS';
     end if;
     hr_utility.trace('pay_emp_action_arch.gv_multi_leg_rule = ' ||
                       pay_emp_action_arch.gv_multi_leg_rule);
     hr_utility.trace('lv_pymt_dimension = '      || lv_pymt_dimension);
     hr_utility.trace('lv_jd_pymt_dimension = '   || lv_jd_pymt_dimension);
     hr_utility.trace('lv_subj_pymt_dimension = ' || lv_subj_pymt_dimension);

     ln_step := 5;
     open c_asg_actions(p_payroll_action_id);
     fetch c_asg_actions into ld_effective_date;
     if c_asg_actions%notfound then
        hr_utility.set_location(gv_package || lv_procedure_name, 10);
        lv_error_message := 'No Assignment Actions were picked by ' ||
                            'External Archive Process.';

       hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
       hr_utility.set_message_token('FORMULA_TEXT',lv_error_message);
       --hr_utility.raise_error;
     end if;
     close c_asg_actions;

     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     /* Get Federal Balances */
     ln_step := 10;
     open c_get_balances('US FEDERAL');
     loop
        fetch c_get_balances into lv_balance_name, ln_balance_type_id;
        if c_get_balances%NOTFOUND then
           hr_utility.set_location(gv_package || lv_procedure_name, 30);
           exit;
        end if;
        hr_utility.set_location(gv_package || lv_procedure_name, 40);
        hr_utility.trace('lv_balance_name = ' || lv_balance_name);

        ln_fed_count := ln_fed_count + 1;
        hr_utility.trace('ln_fed_count = '||ln_fed_count);

        pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).action_info_category
            := 'US FEDERAL';
        pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).balance_name
            := lv_balance_name;
        pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).balance_type_id
            := ln_balance_type_id;

        if lv_balance_name in ('Supplemental Earnings for FIT',
                               'Supplemental Earnings for NWFIT',
                               'Pre Tax Deductions for FIT',
                               'Supplemental Earnings for SS',
                               'Pre Tax Deductions for SS',
                               'Supplemental Earnings for Medicare',
                               'Pre Tax Deductions for Medicare',
                               'Supplemental Earnings for FUTA',
                               'Pre Tax Deductions for FUTA',
                               'Supplemental Earnings for EIC',
                               'Pre Tax Deductions for EIC') then

           hr_utility.set_location(gv_package || lv_procedure_name, 50);
           pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).payment_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          lv_subj_pymt_dimension);

           pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).asg_run_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_SUBJECT_TO_TAX_ASG_GRE_RUN');

           pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).ytd_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_SUBJECT_TO_TAX_ASG_GRE_YTD');

        else
           hr_utility.set_location(gv_package || lv_procedure_name, 60);
           hr_utility.trace('lv_pymt_dimension = '||lv_pymt_dimension);
           pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).payment_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          lv_pymt_dimension);

           pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).asg_run_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_GRE_RUN');

           pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).ytd_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_GRE_YTD');

        end if;
        hr_utility.set_location(gv_package || lv_procedure_name, 70);
     end loop;

     close c_get_balances;


     /****************************************************************
      Public Sector Payroll changes. The following code has
      been added to display and archive the FIT Alien Balances
     *****************************************************************/
     ln_step := 15;
     hr_utility.set_location(gv_package || lv_procedure_name, 75);

     ln_fed_count := ln_fed_count + 1;

     for c_rec in c_get_balance_type_id ('Non W2 FIT Withheld')
     loop
        ln_balance_type_id := c_rec.balance_type_id;
     end loop;

     hr_utility.trace('ln_fed_count = ' || to_char(ln_fed_count));
     hr_utility.trace('ln_blance_type_id = ' || to_char(ln_balance_type_id));

     pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).action_info_category
            := 'US FEDERAL';
     pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).balance_name
            := 'Non W2 FIT Withheld';
     pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).balance_type_id
            := ln_balance_type_id;

     pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).payment_def_bal_id
                 := get_defined_balance_id(ln_business_group_id,
                                          'Non W2 FIT Withheld',
                                            lv_pymt_dimension);

     pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).asg_run_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          'Non W2 FIT Withheld',
                                          '_ASG_GRE_RUN');

     pay_us_action_arch.ltr_fed_tax_bal(ln_fed_count).ytd_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          'Non W2 FIT Withheld',
                                          '_ASG_GRE_YTD');

     /********************************************************
     ** Getting Defined Balance IDs for
     ** Gross Earnings (which is used for all normal earning
     ** elements) and Payments for Non Payroll Payment element.
     ** In archive_data, the value for an assignment action
     ** with these defined balances are non zero then call
     ** process action.
     ***********************************************************/
     gn_gross_earn_def_bal_id  := nvl(get_defined_balance_id(
                                           ln_business_group_id,
                                           'Gross Earnings',
                                           '_ASG_RUN'),-1);
     gn_payments_def_bal_id    := nvl(get_defined_balance_id(
                                           ln_business_group_id,
                                           'Payments',
                                           '_ASG_RUN'),-1);


     /****************************************************************
      End Public Sector Payroll changes.
     *****************************************************************/

     hr_utility.set_location(gv_package || lv_procedure_name, 80);


     /* Get State Balances */
     ln_step := 20;
     open c_get_balances('US STATE');
     loop
        fetch c_get_balances into lv_balance_name, ln_balance_type_id;
        if c_get_balances%NOTFOUND then
           hr_utility.set_location(gv_package || lv_procedure_name, 90);
           exit;
        end if;
        hr_utility.set_location(gv_package || lv_procedure_name, 95);
        hr_utility.trace('lv_balance_name is '||lv_balance_name);

        ln_state_count := ln_state_count + 1;

        pay_us_action_arch.ltr_state_tax_bal(ln_state_count).action_info_category
            := 'US STATE';
        pay_us_action_arch.ltr_state_tax_bal(ln_state_count).balance_name
            := lv_balance_name;
        pay_us_action_arch.ltr_state_tax_bal(ln_state_count).balance_type_id
            := ln_balance_type_id;

        pay_us_action_arch.ltr_state_tax_bal(ln_state_count).payment_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          lv_jd_pymt_dimension);

        pay_us_action_arch.ltr_state_tax_bal(ln_state_count).asg_run_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_JD_GRE_RUN');

        pay_us_action_arch.ltr_state_tax_bal(ln_state_count).ytd_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_JD_GRE_YTD');

        hr_utility.set_location(gv_package || lv_procedure_name, 97);
     end loop;
     close c_get_balances;


-- TCL_SUI1 begin
/* NOTE The pay_us_action_arch.ltr_state2_tax_bal table is different.
   specifically ltr_state2_tax_bal a table structure for STATE2 */
     /* Get State Balances context 2*/
     ln_step := 23;
     open c_get_balances('US STATE2');
     loop
        fetch c_get_balances into lv_balance_name, ln_balance_type_id;
        if c_get_balances%NOTFOUND then
           hr_utility.set_location(gv_package || lv_procedure_name, 100);
           exit;
        end if;
        hr_utility.set_location(gv_package || lv_procedure_name, 105);
        hr_utility.trace('lv_balance_name is '||lv_balance_name);

        ln_state2_count := ln_state2_count + 1;

        pay_us_action_arch.ltr_state2_tax_bal(ln_state2_count).action_info_category
            := 'US STATE2';
        pay_us_action_arch.ltr_state2_tax_bal(ln_state2_count).balance_name
            := lv_balance_name;
        pay_us_action_arch.ltr_state2_tax_bal(ln_state2_count).balance_type_id
            := ln_balance_type_id;

        pay_us_action_arch.ltr_state2_tax_bal(ln_state2_count).payment_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          lv_jd_pymt_dimension);

        pay_us_action_arch.ltr_state2_tax_bal(ln_state2_count).asg_run_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_JD_GRE_RUN');

        pay_us_action_arch.ltr_state2_tax_bal(ln_state2_count).ytd_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_JD_GRE_YTD');

        hr_utility.set_location(gv_package || lv_procedure_name, 107);
     end loop;
     close c_get_balances;

-- TCL_SUI1 end

     hr_utility.set_location(gv_package || lv_procedure_name, 120);

     /****************************************************************
      Public Sector Payroll changes. The following code has
      been added to display and archive the SIT Alien Balances
     *****************************************************************/
     ln_step := 25;
     hr_utility.set_location(gv_package || lv_procedure_name, 125);

     ln_state_count := ln_state_count + 1;

     for c_rec in c_get_balance_type_id ('SIT Alien Withheld')
     loop
        ln_balance_type_id := c_rec.balance_type_id;
     end loop;

     pay_us_action_arch.ltr_state_tax_bal(ln_state_count).action_info_category
            := 'US STATE';
     pay_us_action_arch.ltr_state_tax_bal(ln_state_count).balance_name
            := 'SIT Alien Withheld';
     pay_us_action_arch.ltr_state_tax_bal(ln_state_count).balance_type_id
            := ln_balance_type_id;

     pay_us_action_arch.ltr_state_tax_bal(ln_state_count).payment_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          'SIT Alien Withheld',
                                          lv_jd_pymt_dimension);

     pay_us_action_arch.ltr_state_tax_bal(ln_state_count).asg_run_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          'SIT Alien Withheld',
                                          '_ASG_JD_GRE_RUN');

     pay_us_action_arch.ltr_state_tax_bal(ln_state_count).ytd_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          'SIT Alien Withheld',
                                          '_ASG_JD_GRE_YTD');

     /****************************************************************
      End Public Sector Payroll changes.
     *****************************************************************/
     hr_utility.set_location(gv_package || lv_procedure_name, 126);


     /* Get County Balances */
     ln_step := 30;
     open c_get_balances('US COUNTY');
     loop
        fetch c_get_balances into lv_balance_name, ln_balance_type_id;
        if c_get_balances%NOTFOUND then
           hr_utility.set_location(gv_package || lv_procedure_name, 130);
           exit;
        end if;
        hr_utility.set_location(gv_package || lv_procedure_name, 140);
        hr_utility.trace('lv_balance_name is '||lv_balance_name);

        ln_county_count := ln_county_count + 1;

        pay_us_action_arch.ltr_county_tax_bal(ln_county_count).action_info_category
            := 'US COUNTY';
        pay_us_action_arch.ltr_county_tax_bal(ln_county_count).balance_name
            := lv_balance_name;
        pay_us_action_arch.ltr_county_tax_bal(ln_county_count).balance_type_id
            := ln_balance_type_id;

        pay_us_action_arch.ltr_county_tax_bal(ln_county_count).payment_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          lv_jd_pymt_dimension);
        pay_us_action_arch.ltr_county_tax_bal(ln_county_count).asg_run_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_JD_GRE_RUN');
        pay_us_action_arch.ltr_county_tax_bal(ln_county_count).ytd_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_JD_GRE_YTD');

        hr_utility.set_location(gv_package || lv_procedure_name, 150);
     end loop;
     close c_get_balances;
     --
     hr_utility.trace('Entering County Loop  ' );
     ln_step := 35;
     for i in pay_us_action_arch.ltr_county_tax_bal.first ..
              pay_us_action_arch.ltr_county_tax_bal.last loop

         hr_utility.trace('Count = ' || to_char(i));
         hr_utility.trace('Category  = ' ||
            pay_us_action_arch.ltr_county_tax_bal(i).action_info_category);
         hr_utility.trace('Balance Name = ' ||
            pay_us_action_arch.ltr_county_tax_bal(i).balance_name);
         hr_utility.trace('pay_def_bal_id  ' ||
            pay_us_action_arch.ltr_county_tax_bal(i).payment_def_bal_id);
         hr_utility.trace('asg_run_def_bal_id  = ' ||
            pay_us_action_arch.ltr_county_tax_bal(i).asg_run_def_bal_id);
         hr_utility.trace('ytd_def_bal_id = ' ||
            pay_us_action_arch.ltr_county_tax_bal(i).ytd_def_bal_id);
     end loop;
     hr_utility.trace('Leaving County Loop  ' );
     --

     hr_utility.set_location(gv_package || lv_procedure_name, 160);
     /* Get City Balances */
     ln_step := 40;
     open c_get_balances('US CITY');
     loop
        fetch c_get_balances into lv_balance_name, ln_balance_type_id;
        if c_get_balances%notfound then
           hr_utility.set_location(gv_package || lv_procedure_name, 170);
           exit;
        end if;
        hr_utility.set_location(gv_package || lv_procedure_name, 180);
        hr_utility.trace('lv_balance_name is '||lv_balance_name);

        ln_city_count := ln_city_count + 1;

        pay_us_action_arch.ltr_city_tax_bal(ln_city_count).action_info_category
            := 'US CITY';
        pay_us_action_arch.ltr_city_tax_bal(ln_city_count).balance_name
            := lv_balance_name;
        pay_us_action_arch.ltr_city_tax_bal(ln_city_count).balance_type_id
            := ln_balance_type_id;

        pay_us_action_arch.ltr_city_tax_bal(ln_city_count).payment_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          lv_jd_pymt_dimension);
        pay_us_action_arch.ltr_city_tax_bal(ln_city_count).asg_run_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_JD_GRE_RUN');
        pay_us_action_arch.ltr_city_tax_bal(ln_city_count).ytd_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_JD_GRE_YTD');

        hr_utility.set_location(gv_package || lv_procedure_name, 190);
     end loop;
     close c_get_balances;

     hr_utility.set_location(gv_package || lv_procedure_name, 200);
     /* Get School District Balances */
     ln_step := 45;
     open c_get_balances('US SCHOOL DISTRICT');
     loop
        fetch c_get_balances into lv_balance_name, ln_balance_type_id;
        if c_get_balances%notfound then
           hr_utility.set_location(gv_package || lv_procedure_name, 210);
           exit;
        end if;
        hr_utility.set_location(gv_package || lv_procedure_name, 220);
        hr_utility.trace('lv_balance_name is '||lv_balance_name);

        ln_schdist_count := ln_schdist_count + 1;

        pay_us_action_arch.ltr_schdist_tax_bal(ln_schdist_count).action_info_category
            := 'US SCHOOL DISTRICT';
        pay_us_action_arch.ltr_schdist_tax_bal(ln_schdist_count).balance_name
            := lv_balance_name;
        pay_us_action_arch.ltr_schdist_tax_bal(ln_schdist_count).balance_type_id
            := ln_balance_type_id;

        pay_us_action_arch.ltr_schdist_tax_bal(ln_schdist_count).payment_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          lv_jd_pymt_dimension);
        pay_us_action_arch.ltr_schdist_tax_bal(ln_schdist_count).asg_run_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_JD_GRE_RUN');
        pay_us_action_arch.ltr_schdist_tax_bal(ln_schdist_count).ytd_def_bal_id
                := get_defined_balance_id(ln_business_group_id,
                                          lv_balance_name,
                                          '_ASG_JD_GRE_YTD');

        hr_utility.set_location(gv_package || lv_procedure_name, 230);
     end loop;
     close c_get_balances;

     hr_utility.set_location(gv_package || lv_procedure_name, 240);
     hr_utility.trace('Fed Balance Loop Count = ' ||
                            pay_us_action_arch.ltr_fed_tax_bal.count);
     hr_utility.trace('State Balance Loop Count = ' ||
                            pay_us_action_arch.ltr_state_tax_bal.count);
     hr_utility.trace('County Balance Loop Count = ' ||
                            pay_us_action_arch.ltr_county_tax_bal.count);
     hr_utility.trace('City Balance Loop Count = ' ||
                            pay_us_action_arch.ltr_city_tax_bal.count);
     hr_utility.trace('School Dsts Balance Loop Count = ' ||
                            pay_us_action_arch.ltr_schdist_tax_bal.count);
     hr_utility.set_location(gv_package || lv_procedure_name, 250);


     /****************************************************
     ** Build a PL/SQL table which has state tax info
     ** for all states
     ****************************************************/
     hr_utility.set_location(gv_package || lv_procedure_name, 300);
     ln_step := 50;
     open c_get_states_jit(ld_effective_date);
     loop
        fetch c_get_states_jit into lv_state_code, lv_sit_exists,
                                lv_sui_ee_exists, lv_sui_er_exists,
                                lv_sdi_ee_exists, lv_sdi_er_exists;
        if c_get_states_jit%notfound then
           hr_utility.set_location(gv_package || lv_procedure_name, 310);
           exit;
        end if;
        hr_utility.set_location(gv_package || lv_procedure_name, 320);
        hr_utility.trace('lv_state_code = ' || lv_state_code);
        hr_utility.trace('lv_sit_exists = ' || lv_sit_exists);
        hr_utility.trace('lv_sui_ee_exists = ' || lv_sui_ee_exists);
        hr_utility.trace('lv_sui_er_exists = ' || lv_sui_er_exists);
        hr_utility.trace('lv_sdi_ee_exists = ' || lv_sdi_ee_exists);
        hr_utility.trace('lv_sdi_er_exists = ' || lv_sdi_er_exists);

        pay_us_action_arch.ltr_state_tax_info(lv_state_code).sit_exists
             := lv_sit_exists;
        pay_us_action_arch.ltr_state_tax_info(lv_state_code).sui_ee_exists
             := lv_sui_ee_exists;
        pay_us_action_arch.ltr_state_tax_info(lv_state_code).sui_er_exists
            := lv_sui_er_exists;
        pay_us_action_arch.ltr_state_tax_info(lv_state_code).sdi_ee_exists
            := lv_sdi_ee_exists;
        pay_us_action_arch.ltr_state_tax_info(lv_state_code).sdi_er_exists
            := lv_sdi_er_exists;

     end loop;
     close c_get_states_jit;

     hr_utility.set_location(gv_package || lv_procedure_name, 350);
     ln_step := 55;
     open c_get_county_jit(ld_effective_date);
     loop
        fetch c_get_county_jit into lv_jurisdiction_code,
                                    lv_county_tax_exists,
                                    lv_county_sd_tax_exists,
                                    lv_county_head_tax_exists;
        if c_get_county_jit%notfound then
           hr_utility.set_location(gv_package || lv_procedure_name, 360);
           exit;
        end if;
        hr_utility.set_location(gv_package || lv_procedure_name, 370);
        hr_utility.trace('lv_jurisdiction_code = ' || lv_jurisdiction_code);

        ln_index := pay_us_action_arch.ltr_county_tax_info.count;

        pay_us_action_arch.ltr_county_tax_info(ln_index).jurisdiction_code
            := lv_jurisdiction_code;
        pay_us_action_arch.ltr_county_tax_info(ln_index).cnty_tax_exists
             := lv_county_tax_exists;
        pay_us_action_arch.ltr_county_tax_info(ln_index).cnty_head_tax_exists
             := lv_county_sd_tax_exists;
        pay_us_action_arch.ltr_county_tax_info(ln_index).cnty_sd_tax_exists
             := lv_county_head_tax_exists;

     end loop;
     close c_get_county_jit;

     hr_utility.set_location(gv_package || lv_procedure_name, 400);
     ln_step := 60;

  exception
    when others then
      hr_utility.set_location(gv_package || lv_procedure_name, 500);
      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;
      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END action_archinit;

  /*********************************************************************
   Name      : action_archdeinit
   Purpose   : This function is the deinitialization routine for XFR_INTERFACE.
   Arguments : IN
                 p_payroll_action_id   number;
   Notes     :
  *********************************************************************/
  PROCEDURE action_archdeinit(p_payroll_action_id IN NUMBER)
  IS

  cursor c_effective_date (cp_payroll_action_id in number) is
     select  effective_date
       from  pay_payroll_actions
       where payroll_action_id = cp_payroll_action_id;

    l_effective_date     DATE;
    lv_error_message     VARCHAR2(200);
    lv_procedure_name    VARCHAR2(100) := '.deinitialization_code';

  begin
     open c_effective_date (p_payroll_action_id);
     fetch c_effective_date into l_effective_date;

     if c_effective_date%notfound then
        hr_utility.trace('Effective Date not found for p_payroll_action_id : ' || p_payroll_action_id);
        hr_utility.raise_error;
     end if;
     close c_effective_date;

    pay_emp_action_arch.arch_pay_action_level_data
      (p_payroll_action_id  => p_payroll_action_id
      ,p_effective_date     => l_effective_date);

  exception
    when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;
  end action_archdeinit;


  /******************************************************************
   Name      : populate_emp_hours_by_rate
   Purpose   : The procedure set the Federal level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE populate_emp_hours_by_rate(p_action_context_id in number
                                      ,p_assignment_id     in number
                                      ,p_run_action_id     in number)
  IS

    cursor c_hbr(cp_run_action_id in number) is
       select hours.element_type_id,
              hours.element_name,
              hours.processing_priority,
              hours.rate,
              nvl(hours.multiple,1),
              hours.hours,
              hours.amount
         from pay_hours_by_rate_v hours
        where hours.assignment_action_id = cp_run_action_id
          and legislation_code = 'US'
          and hours.element_type_id >= 0  -- Bug 3370112
        order by hours.processing_priority,hours.element_type_id;

     cursor c_retro(cp_run_action_id   in number
                   ,cp_element_type_id in number) is
        select pepd.element_entry_id,
               sum(decode(piv.name, 'Pay Value', prrv.result_value)),
               sum(decode(piv.name, 'Hours', prrv.result_value)),
               nvl(sum(decode(piv.name, 'Multiple', prrv.result_value)),1),
               sum(decode(piv.name, 'Rate', prrv.result_value))
          from pay_run_results prr,
               pay_run_result_values prrv,
               pay_input_values_f piv,
               pay_entry_process_details pepd
         where piv.input_value_id = prrv.input_value_id
           and prr.element_type_id = cp_element_type_id
           and prr.run_result_id = prrv.run_result_id
           and prr.assignment_action_id = cp_run_action_id
           and prr.source_type = 'E'
           and pepd.element_entry_id = prr.source_id
           and pepd.source_asg_action_id is not null
           and result_value is not null
         group by pepd.element_entry_id;

    ln_element_type_id     NUMBER;
    lv_element_name        VARCHAR2(100);
    lv_processing_priority VARCHAR2(10);
    ln_rate                NUMBER(15,5);
    ln_multiple            NUMBER(15,5);
    ln_hours               NUMBER(15,5);
    ln_amount              NUMBER(15,5);
    ln_index               NUMBER;

    lv_procedure_name      VARCHAR2(100);
    lv_error_message       VARCHAR2(200);

    ln_hrs_index           NUMBER;
    ltr_hours_x_rate       pay_ac_action_arch.hbr_table;

    ln_retro_rate          NUMBER(15,5);
    ln_retro_multiple      NUMBER(15,5);
    ln_retro_hours         NUMBER(15,5);
    ln_retro_payvalue      NUMBER(15,5);
    ln_retro_element_entry NUMBER;

  BEGIN
    --hr_utility.trace_on(null, 'HBR');
    lv_procedure_name := '.populate_emp_hours_by_rate';
    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    ln_rate     := 0;
    ln_hours    := 0;
    ln_multiple := 1;

    open c_hbr(p_run_action_id);
    loop
       fetch c_hbr into ln_element_type_id
                       ,lv_element_name
                       ,lv_processing_priority
                       ,ln_rate
                       ,ln_multiple
                       ,ln_hours
                       ,ln_amount;
       hr_utility.set_location(gv_package || lv_procedure_name, 20);
       if c_hbr%notfound then
          hr_utility.set_location(gv_package || lv_procedure_name, 25);
          exit;
       end if;

       if c_hbr%found then
          hr_utility.set_location(gv_package || lv_procedure_name, 30);
          ln_index := pay_ac_action_arch.lrr_act_tab.count;
          pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                    := 'EMPLOYEE HOURS BY RATE';
          pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                    := '00-000-0000';
          pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                    := p_action_context_id;
          pay_ac_action_arch.lrr_act_tab(ln_index).assignment_id
                    := p_assignment_id;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                    := ln_element_type_id;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info4
                    := lv_element_name;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info5
                    := fnd_number.number_to_canonical(ln_rate);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                    := fnd_number.number_to_canonical(ln_hours);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                    := lv_processing_priority;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                    := fnd_number.number_to_canonical(ln_multiple);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                    := fnd_number.number_to_canonical(ln_amount);

          /******************************************************
          ** Insert into seperate table
          ******************************************************/
          ln_hrs_index := ltr_hours_x_rate.count;
          if ltr_hours_x_rate.count > 0 then
             for z in ltr_hours_x_rate.first .. ltr_hours_x_rate.last loop
                 if ltr_hours_x_rate(z).element_type_id
                               = ln_element_type_id then
                    ln_hrs_index := z;
                    exit;
                 end if;
             end loop;
          end if;

          ltr_hours_x_rate(ln_hrs_index).element_type_id     := ln_element_type_id;
          ltr_hours_x_rate(ln_hrs_index).element_name        := lv_element_name;
          ltr_hours_x_rate(ln_hrs_index).processing_priority := lv_processing_priority;
          ltr_hours_x_rate(ln_hrs_index).rate                := ln_rate;
          ltr_hours_x_rate(ln_hrs_index).hours
               := nvl(ltr_hours_x_rate(ln_hrs_index).hours,0) + ln_hours;
          ltr_hours_x_rate(ln_hrs_index).amount
               := nvl(ltr_hours_x_rate(ln_hrs_index).amount,0) +
                  ln_amount;

       end if;
    end loop;
    close c_hbr;

    if ltr_hours_x_rate.count > 0 then
       for z in ltr_hours_x_rate.first .. ltr_hours_x_rate.last loop
           hr_utility.trace('*******Element in Hours By Rate *************');
           hr_utility.trace('HBR element name = ' || ltr_hours_x_rate(z).element_name);
           hr_utility.trace('HBR element hour = ' || ltr_hours_x_rate(z).hours);
           hr_utility.trace('HBR element rate = ' || ltr_hours_x_rate(z).rate);
           hr_utility.trace('HBR element payvalue = ' || ltr_hours_x_rate(z).amount);
       end loop;
    end if;

    if ltr_hours_x_rate.count > 0 then
       for z in ltr_hours_x_rate.first .. ltr_hours_x_rate.last loop
           if pay_ac_action_arch.lrr_act_tab.count > 0 then
              for i in  pay_ac_action_arch.lrr_act_tab.first..
                        pay_ac_action_arch.lrr_act_tab.last loop
                  if pay_ac_action_arch.lrr_act_tab(i).action_info_category
                           = 'AC EARNINGS' and
                     pay_ac_action_arch.lrr_act_tab(i).action_context_id
                           = p_action_context_id and
                     pay_ac_action_arch.lrr_act_tab(i).act_info2
                           = ltr_hours_x_rate(z).element_type_id then
                     if ((ltr_hours_x_rate(z).hours <>
                          pay_ac_action_arch.lrr_act_tab(i).act_info11) OR
                         (ltr_hours_x_rate(z).amount <>
                          pay_ac_action_arch.lrr_act_tab(i).act_info8)) then
                        --call function to get the retro data
                        hr_utility.trace('HBR diff ' || ltr_hours_x_rate(z).element_name ||
                                         ' Element ID=' || ltr_hours_x_rate(z).element_type_id ||
                                         ' AC HBR=' ||
                                                  pay_ac_action_arch.lrr_act_tab(i).act_info11 ||
                                         ' HBR Hours=' || ltr_hours_x_rate(z).hours ||
                                         ' p_run_action_id='||p_run_action_id);
                        open c_retro(p_run_action_id, ltr_hours_x_rate(z).element_type_id);
                        loop
                           hr_utility.set_location(gv_package || lv_procedure_name, 57);
                           fetch c_retro into ln_retro_element_entry
                                             ,ln_retro_payvalue
                                             ,ln_retro_hours
                                             ,ln_retro_multiple
                                             ,ln_retro_rate;
                           if c_retro%notfound then
                              exit;
                           end if;

                           hr_utility.trace('HBR Retro Values');
                           hr_utility.trace('Pay Value='|| ln_retro_payvalue);
                           hr_utility.trace('Hours    ='|| ln_retro_hours);
                           hr_utility.trace('Rate     ='|| ln_retro_rate);
                           hr_utility.trace('Multiple ='|| ln_retro_multiple);
                           if ln_retro_multiple = 0 then
                              ln_retro_multiple := 1;
                           end if;

                           ln_index := pay_ac_action_arch.lrr_act_tab.count;
                           pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                                := 'EMPLOYEE HOURS BY RATE';
                           pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                                := '00-000-0000';
                           pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                                := p_action_context_id;
                           pay_ac_action_arch.lrr_act_tab(ln_index).assignment_id
                                := p_assignment_id;
                           pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                                := ltr_hours_x_rate(z).element_type_id;
                           pay_ac_action_arch.lrr_act_tab(ln_index).act_info4
                                := ltr_hours_x_rate(z).element_name;
                           pay_ac_action_arch.lrr_act_tab(ln_index).act_info5
                                := fnd_number.number_to_canonical(ln_retro_rate);
                           pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                                := fnd_number.number_to_canonical(ln_retro_hours);
                           pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                                := ltr_hours_x_rate(z).processing_priority;
                           pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                                := fnd_number.number_to_canonical(nvl(ln_retro_multiple,1));
                           pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                               := fnd_number.number_to_canonical(ln_retro_payvalue);
                           hr_utility.set_location(gv_package || lv_procedure_name, 60);
                        end loop;
                        close c_retro;
                        hr_utility.set_location(gv_package || lv_procedure_name, 70);
                     end if;
                     exit;
                  end if;
              end loop;
           end if;
       end loop;
    end if;

    hr_utility.set_location(gv_package || lv_procedure_name, 100);
    --hr_utility.trace_off;

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_emp_hours_by_rate;


  /**************************************************************
   Name      : update_federal_values
   Purpose   : The procedure set the Federal level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_federal_values(p_balance   in varchar2
                                 ,p_bal_value in number
                                 ,p_index     in number
                                 ,p_category  in varchar2
                                 )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_federal_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('ln_bal_value = ' || p_bal_value);

     pay_ac_action_arch.lrr_act_tab(p_index).action_info_category
            := p_category;
     pay_ac_action_arch.lrr_act_tab(p_index).jurisdiction_code
            := '00-000-0000';

     if p_balance = 'FIT Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info1 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info1,0)
                + p_bal_value ;
     elsif p_balance = 'Regular Earnings' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info2 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info2,0)
                + p_bal_value;
     elsif p_balance = 'Supplemental Earnings for FIT' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info3 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info3,0)
                + p_bal_value;
     elsif p_balance = 'Supplemental Earnings for NWFIT' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info4 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info4,0)
                +  p_bal_value;
     elsif p_balance = 'Pre Tax Deductions' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info5 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info5,0)
                + p_bal_value;
     elsif p_balance = 'Pre Tax Deductions for FIT' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info6 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info6,0)
                + p_bal_value;
     elsif p_balance = 'SS EE Taxable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info7 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info7,0)
                + p_bal_value;
     elsif p_balance = 'SS EE Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info8 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info8,0)
                + p_bal_value;
     elsif p_balance = 'SS ER Liability' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info9 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info9,0)
                 + p_bal_value ;
     elsif p_balance = 'SS ER Taxable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info10 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info10,0)
                + p_bal_value ;
     elsif p_balance = 'Supplemental Earnings for SS' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info11 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info11,0)
                + p_bal_value;
     elsif p_balance = 'Pre Tax Deductions for SS' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info12 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info12,0)
                + p_bal_value;
     elsif p_balance = 'Medicare EE Taxable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info13 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info13,0)
                + p_bal_value;
     elsif p_balance = 'Medicare EE Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info14 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info14,0)
                + p_bal_value;
     elsif p_balance = 'Medicare ER Liability' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info15 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info15,0)
                + p_bal_value ;
     elsif p_balance = 'Medicare ER Taxable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info16 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info16,0)
               + p_bal_value;
     elsif p_balance = 'Supplemental Earnings for Medicare' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info17 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info17,0)
                + p_bal_value;
     elsif p_balance = 'Pre Tax Deductions for Medicare' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info18 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info18,0)
                + p_bal_value;
     elsif p_balance = 'Supplemental Earnings for FUTA' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info19 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info19,0)
                + p_bal_value;
     elsif p_balance = 'Pre Tax Deductions for FUTA' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info20 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info20,0)
                + p_bal_value;
     elsif p_balance = 'FUTA Taxable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info21 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info21,0)
                + p_bal_value;
     elsif p_balance = 'FUTA Liability' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info22 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info22,0)
                + p_bal_value;
     elsif p_balance = 'Gross Earnings' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info23 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info23,0)
                + p_bal_value;
     elsif p_balance = 'Pre Tax Deductions for EIC' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info24 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info24,0)
                + p_bal_value;
     elsif p_balance = 'Supplemental Earnings for EIC' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info25 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info25,0)
                + p_bal_value;
     elsif p_balance = 'EIC Advance' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info26 :=
                nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info26,0)
                + p_bal_value;
     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_federal_values;


  /**************************************************************
   Name      : update_sit_values
   Purpose   : The procedure set the SIT level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_sit_values(p_balance   in varchar2
                             ,p_bal_value in number
                             ,p_index     in number
                             )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_sit_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'SIT Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info1
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info1,0) +
                p_bal_value ;
     elsif p_balance = 'SIT Subj Whable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info2
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info2,0) +
                p_bal_value;
     elsif p_balance = 'SIT Subj NWhable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info3
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info3,0) +
                p_bal_value;
     elsif p_balance = 'SIT Pre Tax Redns' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info4
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info4,0) +
                p_bal_value;
     elsif p_balance = 'SIT Gross' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info17
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info17,0) +
                p_bal_value ;
     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_sit_values;


  /**************************************************************
   Name      : update_sdi_ee_values
   Purpose   : The procedure set the SDI EE level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_sdi_ee_values(p_balance  in varchar2
                                ,p_bal_value in number
                                ,p_index in number
                                )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_sdi_ee_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'SDI EE Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info5
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info5,0) +
                p_bal_value ;
     elsif p_balance = 'SDI EE Taxable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info6
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info6,0) +
                p_bal_value;
     elsif p_balance = 'SDI EE Subj Whable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info7
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info7,0) +
                p_bal_value;
     elsif p_balance = 'SDI EE Pre Tax Redns' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info8
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info8,0) +
                p_bal_value;
     elsif p_balance = 'SDI EE Gross' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info26
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info26,0) +
                p_bal_value ;
     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;


  END update_sdi_ee_values;



  /**************************************************************
   Name      : update_sdi_er_values
   Purpose   : The procedure set the SDI ER level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_sdi_er_values(p_balance    in varchar2
                                ,p_bal_value in number
                                ,p_index     in number
                                )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_sdi_ee_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'SDI ER Liability' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info9
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info9,0) +
                p_bal_value;
     elsif  p_balance = 'SDI ER Taxable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info10
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info10,0) +
                p_bal_value;
     elsif  p_balance = 'SDI ER Subj Whable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info11
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info11,0) +
                p_bal_value;
     elsif p_balance = 'SDI ER Pre Tax Redns' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info12
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info12,0) +
                p_bal_value ;
     elsif p_balance  = 'SDI ER Gross' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info27
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info27,0) +
                p_bal_value;
     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 100);

   EXCEPTION
    when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_sdi_er_values;


  /**************************************************************
   Name      : update_sui_ee_values
   Purpose   : The procedure set the SUI EE level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_sui_ee_values(p_balance   in varchar2
                                ,p_bal_value in number
                                ,p_index     in number
                                 )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_sui_ee_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'SUI EE Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info13
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info13,0) +
                p_bal_value;
     elsif p_balance = 'SUI EE Taxable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info14
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info14,0) +
                p_bal_value;
     elsif p_balance = 'SUI EE Subj Whable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info15
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info15,0) +
                p_bal_value;
     elsif p_balance  = 'SUI EE Pre Tax Redns' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info16
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info16,0) +
                p_bal_value;
     elsif p_balance = 'SUI EE Gross' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info28
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info28,0) +
                p_bal_value;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_sui_ee_values;

--TCL_SUI1 begin

    /**************************************************************
   Name      : update_sui_ee_values
   Purpose   : The procedure set the SUI EE level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :  04-DEC-2008  Only SUI1 EE Withheld maintained
                however, kept all balance's for future need.
  **************************************************************/
  PROCEDURE update_sui1_ee_values(p_balance   in varchar2
                                ,p_bal_value in number
                                ,p_index     in number
                                 )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_sui1_ee_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'SUI1 EE Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info2
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info2,0) +
                p_bal_value;

/* Not used as of 08-dec-08

     elsif p_balance = 'SUI1 EE Taxable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info14
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info14,0) +
                p_bal_value;
     elsif p_balance = 'SUI1 EE Subj Whable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info15
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info15,0) +
                p_bal_value;
     elsif p_balance  = 'SUI1 EE Pre Tax Redns' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info16
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info16,0) +
                p_bal_value;
     elsif p_balance = 'SUI1 EE Gross' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info28
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info28,0) +
                p_bal_value;
*/
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_sui1_ee_values;

    /**************************************************************
   Name      : update_sdi_ee_values
   Purpose   : The procedure set the SDI EE level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :  04-DEC-2008  Only SDI1 EE Withheld maintained
                however, kept all balance's for future need.
  **************************************************************/
  PROCEDURE update_sdi1_ee_values(p_balance   in varchar2
                                ,p_bal_value in number
                                ,p_index     in number
                                 )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_sdi1_ee_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'SDI1 EE Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info1
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info1,0) +
                p_bal_value;

/* Not used as of 08-dec-08

     elsif p_balance = 'SDI1 EE Taxable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info14
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info14,0) +
                p_bal_value;
     elsif p_balance = 'SDI1 EE Subj Whable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info15
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info15,0) +
                p_bal_value;
     elsif p_balance  = 'SDI1 EE Pre Tax Redns' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info16
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info16,0) +
                p_bal_value;
     elsif p_balance = 'SDI1 EE Gross' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info28
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info28,0) +
                p_bal_value;
*/
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_sdi1_ee_values;

--TCL_SUI1 end

  /**************************************************************
   Name      : update_sui_er_values
   Purpose   : The procedure set the SUI ER level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_sui_er_values(p_balance    in varchar2
                                ,p_bal_value in number
                                ,p_index     in number
                                )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_sui_er_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'SUI ER Taxable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info18
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info18,0)
                 + p_bal_value;
     elsif p_balance = 'SUI ER Subj Whable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info19
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info19,0)
                 + p_bal_value;
     elsif p_balance = 'SUI ER Pre Tax Redns' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info20
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info20,0)
                 + p_bal_value;
     elsif p_balance = 'SUI ER Liability' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info21
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info21,0)
                 + p_bal_value;
     elsif p_balance = 'SUI ER Gross' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info29
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info29,0)
                 + p_bal_value;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
    when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_sui_er_values;


  /**************************************************************
   Name      : update_work_comp_values
   Purpose   : The procedure set the Worker's Comp level balance
               value in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_work_comp_values(p_balance    in varchar2
                                   ,p_bal_value in number
                                   ,p_index     in number
                                   )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_work_comp_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance  = 'Workers Comp Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info22
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info22,0) +
                p_bal_value ;
     elsif p_balance  = 'Workers Comp2 Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info23
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info23,0) +
                p_bal_value;
     elsif p_balance = 'Workers Compensation2 ER' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info24
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info24,0) +
                p_bal_value;
     elsif p_balance = 'Workers Compensation3 ER' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info25
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info25,0) +
                p_bal_value;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_work_comp_values;

  /*Bug 3231253*/
  /**************************************************************
   Name      : update_steic_values
   Purpose   : The procedure sets the STEIC Advance balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_steic_values(p_balance   in varchar2
                               ,p_bal_value in number
                               ,p_index     in number
                               )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_steic_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'STEIC Advance' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info30
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info30,0) +
                p_bal_value ;
     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_steic_values;


  /**************************************************************
   Name      : update_county_values
   Purpose   : The procedure set the County level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_county_values(p_balance    in varchar2
                                ,p_bal_value in number
                                ,p_index     in number
                                )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_county_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'County Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index ).act_info1
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info1,0) +
                p_bal_value ;
     elsif p_balance = 'County Subj Whable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info2
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info2,0) +
                p_bal_value;
     elsif p_balance = 'County Subj NWhable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info3
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info3,0) +
                p_bal_value;
     elsif p_balance = 'County Pre Tax Redns' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info4
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info4,0) +
                p_bal_value;
     elsif p_balance = 'County Gross' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info7
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info7,0) +
                p_bal_value ;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_county_values;


  /**************************************************************
   Name      : update_county_head_values
   Purpose   : The procedure set the County Head level balance
               values in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_county_head_values(p_balance    in varchar2
                                     ,p_bal_value in number
                                     ,p_index     in number
                                     )
   IS
    lv_procedure_name VARCHAR2(100) := '.update_county_head_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'Head Tax Liability' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info5
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info5,0) +
                p_bal_value;
     elsif p_balance = 'Head Tax Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info6
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info6,0) +
                p_bal_value;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_county_head_values;


  /**************************************************************
   Name      : update_city_values
   Purpose   : The procedure set the City level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_city_values(p_balance    in varchar2
                              ,p_bal_value in number
                              ,p_index     in number
                              )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_city_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'City Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index ).act_info1
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info1,0) +
                p_bal_value;
     elsif p_balance = 'City Subj Whable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info2
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info2,0) +
                p_bal_value;
     elsif p_balance = 'City Subj NWhable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info3
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info3,0) +
                p_bal_value;
     elsif p_balance = 'City Pre Tax Redns' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info4
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info4,0) +
                p_bal_value;
     elsif p_balance = 'City Gross' then
        pay_ac_action_arch.lrr_act_tab(p_index ).act_info7
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info7,0) +
                p_bal_value;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_city_values;


  /**************************************************************
   Name      : update_city_head_values
   Purpose   : The procedure set the City Head level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_city_head_values(p_balance    in varchar2
                                   ,p_bal_value in number
                                   ,p_index     in number
                                   )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_city_head_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'Head Tax Liability' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info5
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info5,0) +
                p_bal_value;
     elsif p_balance = 'Head Tax Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info6
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info6,0) +
                p_bal_value;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_city_head_values;


  /**************************************************************
   Name      : update_school_values
   Purpose   : The procedure set the School level balance value
               in the PL/SQL table.
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE update_school_values(p_balance    in varchar2
                                ,p_bal_value in number
                                ,p_index     in number
                                )
  IS
    lv_procedure_name VARCHAR2(100) := '.update_school_values';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_index  = '|| pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.trace('p_balance = '|| p_balance);
     hr_utility.trace('p_bal_value = ' || p_bal_value);

     if p_balance = 'School Withheld' then
        pay_ac_action_arch.lrr_act_tab(p_index ).act_info1
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info1,0) +
                p_bal_value ;
     elsif p_balance = 'School Subj Whable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info2
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info2,0) +
                p_bal_value;
     elsif p_balance = 'School Subj NWhable' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info3
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info3,0) +
                 + p_bal_value;
     elsif p_balance = 'School Pre Tax Redns' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info4
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info4,0) +
                p_bal_value;
     elsif p_balance = 'School Gross' then
        pay_ac_action_arch.lrr_act_tab(p_index).act_info5
             := nvl(pay_ac_action_arch.lrr_act_tab(p_index).act_info5,0) +
                p_bal_value;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_school_values;


  /**************************************************************
   Name      : get_city_tax_info
   Purpose   : The procedure gets the City JIT Information
   Arguments :
   Notes     :
  **************************************************************/
  PROCEDURE get_city_tax_info( p_effective_date        in         date
                              ,p_emp_city_jurisdiction in         varchar2
                              ,p_city_tax_exists       out nocopy varchar2
                              ,p_city_head_tax_exists  out nocopy varchar2
                              )
  IS
    lv_city_tax_exists        VARCHAR2(1);
    lv_city_head_tax_exists   VARCHAR2(1);
    lv_procedure_name         VARCHAR2(100) := '.get_city_tax_info';
    lv_error_message          VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     lv_city_tax_exists := pay_us_payroll_utils.get_tax_exists(
                              p_tax_type => 'CITY'
                             ,p_jurisdiction_code => p_emp_city_jurisdiction
                             ,p_effective_date    => p_effective_date) ;

     lv_city_head_tax_exists := pay_us_payroll_utils.get_tax_exists(
                                  p_tax_type => 'HT'
                                 ,p_jurisdiction_code => p_emp_city_jurisdiction
                                 ,p_effective_date    => p_effective_date) ;

     p_city_tax_exists      := lv_city_tax_exists ;
     p_city_head_tax_exists := lv_city_head_tax_exists;
     hr_utility.set_location(gv_package || lv_procedure_name, 20);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_city_tax_info;


  /******************************************************************
   Name      : get_school_parent_jd
   Purpose   : The procedure gets the City/County Jurisdiction for a
               School District Jurisdiction. This information is
               archived as a school distrinct can comparise of multiple
               Cities or Counties.
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_school_parent_jd(p_assignment_id       in number
                               ,p_school_jurisdiction in varchar2
                               ,p_end_date            in date
                               ,p_start_date          in date
                               )
  RETURN VARCHAR2
  IS
    cursor c_get_county_school_district is
      select pcnt.jurisdiction_code
        from pay_us_emp_county_tax_rules_f pcnt
       where pcnt.assignment_id = p_assignment_id
         and pcnt.school_district_code = substr(p_school_jurisdiction,4,5)
         and pcnt.state_code = substr(p_school_jurisdiction,1,2)
         and pcnt.effective_start_date <= p_end_date
         and pcnt.effective_end_date >= p_start_date;

    cursor c_get_city_school_district is
      select pcty.jurisdiction_code
        from pay_us_emp_city_tax_rules_f pcty
       where pcty.assignment_id = p_assignment_id
         and pcty.school_district_code = substr(p_school_jurisdiction,4,5)
         and pcty.state_code = substr(p_school_jurisdiction,1,2)
         and pcty.effective_start_date <= p_end_date
         and pcty.effective_end_date >= p_start_date;

    lv_parent_jurisdiction_code VARCHAR2(11);
    lv_procedure_name           VARCHAR2(100) := '.get_school_parent_jd';
    lv_error_message            VARCHAR2(200);

   BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     open c_get_city_school_district;
     fetch c_get_city_school_district into lv_parent_jurisdiction_code ;
     if c_get_city_school_district%notfound then
        hr_utility.set_location(gv_package || lv_procedure_name, 20);
        open c_get_county_school_district;
        fetch c_get_county_school_district into lv_parent_jurisdiction_code ;
        close c_get_county_school_district;
     end if;
     close c_get_city_school_district;

     hr_utility.trace('lv_parent_jurisdiction_code =  '||
                       lv_parent_jurisdiction_code);
     hr_utility.set_location(gv_package || lv_procedure_name, 50);

     return(lv_parent_jurisdiction_code);
  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_school_parent_jd;


  /******************************************************************
   Name      : get_emp_residence
   Purpose   : The procedure gets the Employee Resident JD
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE get_emp_residence(p_assignment_id        in        number
                             ,p_end_date             in        date
                             ,p_run_effective_date   in        date
                             ,p_resident_state_jd   out nocopy varchar2
                             ,p_resident_county_jd  out nocopy varchar2
                             ,p_resident_city_jd    out nocopy varchar2
                             )

  IS

     cursor c_get_emp_res_dtls(cp_assignment_id  in number
                              ,cp_run_effective_date in date) is
       select nvl(ADDR.add_information19,ADDR.region_1),
              nvl(ADDR.add_information17,ADDR.region_2),
              nvl(addr.add_information18,addr.town_or_city)
        from per_addresses addr
            ,per_all_assignments_f  assign
       where cp_run_effective_date between assign.effective_start_date
                                   and assign.effective_end_date
         and assign.assignment_id = cp_assignment_id
         and addr.person_id       = assign.person_id
         and addr.primary_flag   = 'Y'
         and cp_run_effective_date between addr.date_from
                                   and nvl(addr.date_to,
                                           to_date('31/12/4712', 'DD/MM/YYYY'));

     cursor c_get_emp_res_jd(cp_state_abbrev in varchar2
                            ,cp_county_name  in varchar2
                            ,cp_city_name    in varchar2) is
       select pcn.state_code, pcn.county_code, pcn.city_code
         from pay_us_states pus,
              pay_us_counties puc,
              pay_us_city_names pcn
        where pus.state_abbrev = cp_state_abbrev
          and puc.state_code = pus.state_code
          and puc.county_name = cp_county_name
          and pcn.state_code = puc.state_code
          and pcn.county_code = puc.county_code
          and pcn.city_name = cp_city_name ;

    lv_resident_city_jd  VARCHAR2(11);
    lv_resident_cnty_jd  VARCHAR2(11);
    lv_resident_state_jd VARCHAR2(11);

    lv_resident_city     VARCHAR2(120);
    lv_resident_county   VARCHAR2(120);
    lv_resident_state    VARCHAR2(120);

    lv_procedure_name    VARCHAR2(100) := '.get_emp_residence';
    lv_error_message     VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     /* get the assignments resident city,county,state jurisdictions */
     open c_get_emp_res_dtls(p_assignment_id
                            ,p_run_effective_date);
     fetch c_get_emp_res_dtls into lv_resident_county,
                                   lv_resident_state,
                                   lv_resident_city;
     close c_get_emp_res_dtls;

     open c_get_emp_res_jd(lv_resident_state,
                           lv_resident_county,
                           lv_resident_city);
     fetch c_get_emp_res_jd into lv_resident_state_jd,
                                 lv_resident_cnty_jd,
                                 lv_resident_city_jd;
     close c_get_emp_res_jd;

     p_resident_state_jd  := lv_resident_state_jd;
     p_resident_county_jd := lv_resident_cnty_jd;
     p_resident_city_jd   := lv_resident_city_jd;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_emp_residence;


  /******************************************************************
   Name      : update_ytd_withheld
   Purpose   : This procedure inserts the Witheld Current and YTD
               amounts into the PL/SQL table for Employee Taxes
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE update_ytd_withheld(p_xfr_action_id        in number
                               ,p_balance_name         in varchar2
                               ,p_balance_type_id      in varchar2
                               ,p_processing_priority  in varchar2 default 10
                               ,p_jurisdiction         in varchar2
                               ,p_curr_withheld        in number
                               ,p_ytd_withheld         in number
                               )
  IS

  CURSOR get_display_name ( cp_reporting_name in varchar2 ,
                          cp_jurisdiction_code in varchar2) IS

select decode(length(cp_jurisdiction_code),
          11, decode(cp_jurisdiction_code,
                       '00-000-0000', null,
                       decode(cp_reporting_name,
                                'Head Tax Withheld', null,
                                pay_us_employee_payslip_web.get_jurisdiction_name(
                                       cp_jurisdiction_code) || ' ')),
           8, pay_us_employee_payslip_web.get_jurisdiction_name(
                     substr(cp_jurisdiction_code,1,2)||'-000-0000') || ' ')  ||
      decode(fl.description, '', null,
                nvl(fl.description, cp_reporting_name)) || ' ' ||
      decode(length(cp_jurisdiction_code),
           8, decode(substr(cp_jurisdiction_code,1,2), '36', substr(cp_jurisdiction_code, 4),
                       pay_us_employee_payslip_web.get_jurisdiction_name(cp_jurisdiction_code)),
          11, decode(cp_reporting_name,
                 'Head Tax Withheld', pay_us_employee_payslip_web.get_jurisdiction_name(
                                               cp_jurisdiction_code)))display_name
      from fnd_common_lookups fl
where fl.lookup_type(+) = 'PAY_US_LABELS'
and upper(cp_reporting_name) = fl.lookup_code(+) ;

    lv_display_name   VARCHAR2(50);
    ln_index          NUMBER;
    ln_element_index  NUMBER;
    lv_procedure_name VARCHAR2(100) := '.update_ytd_withheld';
    lv_error_message  VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     if p_curr_withheld <> 0 or p_ytd_withheld <> 0 then  -- Bug 3561821

        ln_index := pay_ac_action_arch.lrr_act_tab.count;
        hr_utility.trace('ln_index = ' || ln_index);

        ln_element_index := pay_ac_action_arch.emp_elements_tab.count;
        pay_ac_action_arch.emp_elements_tab(ln_element_index).element_classfn
                  := 'Tax Deductions';
        pay_ac_action_arch.emp_elements_tab(ln_element_index).jurisdiction_code
                  := p_jurisdiction;
        pay_ac_action_arch.emp_elements_tab(ln_element_index).element_reporting_name
                  := p_balance_name;
        pay_ac_action_arch.emp_elements_tab(ln_element_index).element_primary_balance_id
                  := p_balance_type_id;
        pay_ac_action_arch.emp_elements_tab(ln_element_index).element_processing_priority
                  := p_processing_priority;

        pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                  := 'AC DEDUCTIONS';
        pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                  := p_jurisdiction;
        pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                  := p_xfr_action_id;
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                  := 'Tax Deductions';
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                  := p_balance_type_id ;
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                  := p_processing_priority;
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                  := fnd_number.number_to_canonical(nvl(p_curr_withheld,0));
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                  := fnd_number.number_to_canonical(nvl(p_ytd_withheld,0));
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                  := p_balance_name ;
OPEN get_display_name( p_balance_name ,p_jurisdiction ) ;
FETCH get_display_name INTO lv_display_name ;
IF get_display_name%FOUND THEN
      IF substr(lv_display_name , -7,5) = 'BLANK' THEN
         lv_display_name := substr(lv_display_name , 1, length(lv_display_name)-8);
          hr_utility.trace('get_display_name inside if' || lv_display_name);
      END IF;
ELSE
   lv_display_name := ' ';
END IF;
IF get_display_name%ISOPEN THEN
   close get_display_name;
END IF;
pay_ac_action_arch.lrr_act_tab(ln_index).act_info24
                  := lv_display_name ;
     end if;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_ytd_withheld;


  /******************************************************************
   Name      : get_table_index
   Purpose   : This function gets the index for the PL/SQL table
               for US Tax Balances for a given JD.
               For Bal Adjustments the function will return the same
               index for a given JD as we only archive one record for
               all Bal Adj. done on a given date.
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_table_index (p_jurisdiction_code in varchar2,
                            p_action_info_category in varchar2)
  RETURN NUMBER
  IS
    ln_table_index NUMBER;
    lv_index_flag VARCHAR2(1) := 'N';

  BEGIN
      if pay_ac_action_arch.lrr_act_tab.count > 0 then
         for j in pay_ac_action_arch.lrr_act_tab.first ..
                  pay_ac_action_arch.lrr_act_tab.last loop

             if pay_ac_action_arch.lrr_act_tab(j).jurisdiction_code
                        =  p_jurisdiction_code  THEN

                if p_action_info_category is null
                   and  pay_ac_action_arch.lrr_act_tab(j).action_info_category
                        in ('US FEDERAL',
                            'US COUNTY', 'US CITY',
                            'US SCHOOL DISTRICT') then
                   ln_table_index := j;
                   lv_index_flag := 'Y';
                   exit;
                ELSE IF pay_ac_action_arch.lrr_act_tab(j).action_info_category
                        in ('US STATE', 'US STATE2')
                     AND pay_ac_action_arch.lrr_act_tab(j).action_info_category
                         = p_action_info_category
                     THEN
                        ln_table_index := j;
                        lv_index_flag := 'Y';
                        exit;
                     END IF;

                END if;
             end if;
         end loop;
      end if;

      if lv_index_flag <> 'Y' then
         ln_table_index := pay_ac_action_arch.lrr_act_tab.count;
      end if;
      hr_utility.trace('ln_table_index = '|| ln_table_index);

      return(ln_table_index);

  END get_table_index;


  /******************************************************************
   Name      : get_balance_value
   Purpose   : This procedure calls the get_value function for
               balance calls.
   Arguments :
   Notes     :
  ******************************************************************/
  FUNCTION get_balance_value(
                           p_defined_balance_id in number
                          ,p_balcall_aaid       in number)
  RETURN NUMBER
  IS
     lv_error_message VARCHAR2(200);
     ln_bal_value     NUMBER;

  BEGIN

      if p_defined_balance_id is not null then
         ln_bal_value := fnd_number.number_to_canonical(
                                nvl(pay_balance_pkg.get_value(
                                        p_defined_balance_id,
                                        p_balcall_aaid),0));
      end if;

      return (ln_bal_value);

  EXCEPTION
   when others then
      return (null);

  END get_balance_value;



  /******************************************************************
   Name      : populate_federal_tax_balances
   Purpose   : This procedure gets all the federal level tax balances
               and populates the PL/SQL table.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE populate_federal_tax_balances(
                           p_xfr_action_id     in number
                          ,p_pymt_balcall_aaid in number default null
                          ,p_ytd_balcall_aaid  in number default null
                          ,p_rqp_action_id     in number
                          ,p_action_type       in varchar2)
  IS
    ln_index             NUMBER;
    lv_balance_name      VARCHAR2(80);
    ln_balance_type_id   NUMBER;
    ln_pymt_def_bal_id   NUMBER;
    ln_ytd_def_bal_id    NUMBER;
    ln_run_def_bal_id    NUMBER;

    ln_bal_value         NUMBER(15,2);

    ln_curr_withheld     NUMBER(15,2):=0;
    ln_ytd_withheld      NUMBER(15,2):=0;
    lv_procedure_name    VARCHAR2(100) := '.populate_federal_tax_balances';

    lv_error_message     VARCHAR2(200);
    ln_step              NUMBER;

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;

     ln_index := get_table_index('00-000-0000',
	                              NULL);

     hr_utility.trace('Fed Loop Count = ' || ln_index);
     for i in pay_us_action_arch.ltr_fed_tax_bal.first..
              pay_us_action_arch.ltr_fed_tax_bal.last LOOP

         lv_balance_name
                := pay_us_action_arch.ltr_fed_tax_bal(i).balance_name;
         ln_balance_type_id
                := pay_us_action_arch.ltr_fed_tax_bal(i).balance_type_id;
         ln_pymt_def_bal_id
                := pay_us_action_arch.ltr_fed_tax_bal(i).payment_def_bal_id;
         ln_ytd_def_bal_id
                := pay_us_action_arch.ltr_fed_tax_bal(i).ytd_def_bal_id;
         ln_run_def_bal_id
                := pay_us_action_arch.ltr_fed_tax_bal(i).asg_run_def_bal_id;

         hr_utility.trace('lv_balance_name    = ' || lv_balance_name);
         hr_utility.trace('ln_pymt_def_bal_id = ' || ln_pymt_def_bal_id);
         hr_utility.trace('ln_ytd_def_bal_id  = ' || ln_ytd_def_bal_id);
         hr_utility.trace('ln_run_def_bal_id  = ' || ln_run_def_bal_id);

         ln_step := 5;
         if p_action_type  in  ( 'U', 'P')  then
            if lv_balance_name not in ('SS ER Taxable',
                                       /*'SS ER Liability',
                                       'Medicare ER Liability',*/
                                       'Medicare ER Taxable',
                                       'Non W2 FIT Withheld') then
               hr_utility.set_location(gv_package || lv_procedure_name, 30);

               ln_step := 6;
               ln_bal_value := get_balance_value(
                                   p_defined_balance_id => ln_pymt_def_bal_id
                                  ,p_balcall_aaid       => p_pymt_balcall_aaid);
               if lv_balance_name = 'EIC Advance' then
                  ln_bal_value := -1 * ln_bal_value;
               end if;

            elsif lv_balance_name = 'SS ER Taxable' then
               ln_bal_value
                          := pay_ac_action_arch.lrr_act_tab(ln_index).act_info7;
--            elsif lv_balance_name = 'SS ER Liability' then
--               ln_bal_value
--                          := pay_ac_action_arch.lrr_act_tab(ln_index).act_info8;
            elsif lv_balance_name = 'Medicare ER Taxable' then
                  ln_bal_value
                          := pay_ac_action_arch.lrr_act_tab(ln_index).act_info13;
--            elsif lv_balance_name = 'Medicare ER Liability' then
--               ln_bal_value
--                          := pay_ac_action_arch.lrr_act_tab(ln_index).act_info14;
            end if;

         else
            hr_utility.set_location(gv_package || lv_procedure_name, 50);
            ln_step := 10;
            ln_bal_value := get_balance_value(
                                p_defined_balance_id => ln_run_def_bal_id
                               ,p_balcall_aaid       => p_rqp_action_id);
         end if;

         hr_utility.trace('ln_bal_value is'||to_char(ln_bal_value));
         update_federal_values(p_balance   => lv_balance_name
                              ,p_bal_value => ln_bal_value
                              ,p_index     => ln_index
                              ,p_category  =>  'US FEDERAL');

         hr_utility.set_location(gv_package || lv_procedure_name, 60);

         /*****************************************************************
         ** Insert data for Payslip
         ******************************************************************/
         if lv_balance_name = 'FIT Withheld' then
            ln_step := 12;
            ln_curr_withheld := ln_bal_value;
            ln_ytd_withheld := get_balance_value(
                                    p_defined_balance_id => ln_ytd_def_bal_id
                                   ,p_balcall_aaid       => p_ytd_balcall_aaid);
            update_ytd_withheld(
                        p_xfr_action_id       => p_xfr_action_id
                       ,p_balance_name        => lv_balance_name
                       ,p_balance_type_id     => ln_balance_type_id
                       ,p_processing_priority => 1
                       ,p_jurisdiction        => '00-000-0000'
                       ,p_curr_withheld       => ln_curr_withheld
                       ,p_ytd_withheld        => ln_ytd_withheld);
         elsif lv_balance_name = 'EIC Advance' then
            ln_step := 13;
            ln_curr_withheld := ln_bal_value;
            ln_ytd_withheld := get_balance_value(
                                   p_defined_balance_id => ln_ytd_def_bal_id
                                  ,p_balcall_aaid       => p_ytd_balcall_aaid);
            ln_ytd_withheld := -1 * ln_ytd_withheld;
            update_ytd_withheld(
                        p_xfr_action_id       => p_xfr_action_id
                       ,p_balance_name        => lv_balance_name
                       ,p_balance_type_id     => ln_balance_type_id
                       ,p_processing_priority => 4
                       ,p_jurisdiction        => '00-000-0000'
                       ,p_curr_withheld       => ln_curr_withheld
                       ,p_ytd_withheld        => ln_ytd_withheld);
         elsif lv_balance_name = 'Medicare EE Withheld' then
            ln_step := 14;
            ln_curr_withheld := ln_bal_value ;
            ln_ytd_withheld := get_balance_value(
                                     p_defined_balance_id => ln_ytd_def_bal_id
                                    ,p_balcall_aaid       => p_ytd_balcall_aaid);
            update_ytd_withheld(
                        p_xfr_action_id       => p_xfr_action_id
                       ,p_balance_name        => lv_balance_name
                       ,p_balance_type_id     => ln_balance_type_id
                       ,p_processing_priority => 3
                       ,p_jurisdiction        => '00-000-0000'
                       ,p_curr_withheld       => ln_curr_withheld
                       ,p_ytd_withheld        => ln_ytd_withheld);
         elsif lv_balance_name = 'SS EE Withheld' then
            ln_step := 16;
            ln_curr_withheld := ln_bal_value;
            ln_ytd_withheld := get_balance_value(
                                      p_defined_balance_id => ln_ytd_def_bal_id
                                     ,p_balcall_aaid       => p_ytd_balcall_aaid);
            update_ytd_withheld(
                        p_xfr_action_id       => p_xfr_action_id
                       ,p_balance_name        => lv_balance_name
                       ,p_balance_type_id     => ln_balance_type_id
                       ,p_processing_priority => 2
                       ,p_jurisdiction        => '00-000-0000'
                       ,p_curr_withheld       => ln_curr_withheld
                       ,p_ytd_withheld        => ln_ytd_withheld);
         elsif lv_balance_name = 'Non W2 FIT Withheld' then

            ln_step := 18;
            if check_alien(p_xfr_action_id) = 'TRUE' then
               hr_utility.set_location(gv_package || lv_procedure_name||
                                       ' Chk Alien ', 20);

               ln_bal_value := get_balance_value(
                                   p_defined_balance_id => ln_pymt_def_bal_id
                                  ,p_balcall_aaid       => p_pymt_balcall_aaid);

               ln_curr_withheld := ln_bal_value;

               hr_utility.trace('NonW2FIT Pymt def balid = ' ||
                                    to_char(ln_pymt_def_bal_id));
               hr_utility.trace('NonW2FIT Cur            = ' ||
                                    to_char(ln_curr_withheld));

               ln_ytd_withheld := get_balance_value(
                                      p_defined_balance_id => ln_ytd_def_bal_id
                                     ,p_balcall_aaid       => p_ytd_balcall_aaid);

               hr_utility.trace('NonW2FIT YTD def balid = ' ||
                                    to_char(ln_ytd_def_bal_id));
               hr_utility.trace('NonW2FIT YTD           = ' ||
                                    to_char(ln_ytd_withheld));

               update_ytd_withheld(
                           p_xfr_action_id   => p_xfr_action_id
                          ,p_balance_name    => lv_balance_name
                          ,p_balance_type_id => ln_balance_type_id
                          ,p_jurisdiction    => '00-000-0000'
                          ,p_curr_withheld   => ln_curr_withheld
                          ,p_ytd_withheld    => ln_ytd_withheld);
            end if;
         end if;

     end loop;

     hr_utility.set_location(gv_package || lv_procedure_name, 100);
     ln_step := 20;

  EXCEPTION
   when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_federal_tax_balances;


  /******************************************************************
   Name      : populate_state_tax_balances
   Purpose   : This procedure gets all the state level tax balances
               and populates the PL/SQL table.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE populate_state_tax_balances(
                      p_xfr_action_id     in number
                     ,p_pymt_balcall_aaid in number default null
                     ,p_ytd_balcall_aaid  in number default null
                     ,p_rqp_action_id     in number
                     ,p_action_type       in varchar2
                     ,p_jurisdiction_tab  in pay_ac_action_arch.emp_jd_rec_table)
  IS
    ln_index             NUMBER ;
    lv_balance_name      VARCHAR2(80);
    ln_balance_type_id   NUMBER;
    ln_pymt_def_bal_id   NUMBER;
    ln_ytd_def_bal_id    NUMBER;
    ln_run_def_bal_id    NUMBER;

    lv_state_code        VARCHAR2(10);
    lv_sit_exists        VARCHAR2(1);
    lv_sdi_ee_exists     VARCHAR2(1);
    lv_sdi_er_exists     VARCHAR2(1);
    lv_sui_ee_exists     VARCHAR2(1);
    lv_sui_er_exists     VARCHAR2(1);

    ln_bal_value         NUMBER(15,2);

    ln_curr_withheld     NUMBER(15,2):=0;
    ln_ytd_withheld      NUMBER(15,2):=0;
    lv_procedure_name    VARCHAR2(100) := '.populate_state_tax_balances';
    lv_error_message     VARCHAR2(200);
    ln_step              NUMBER;


  BEGIN
     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     hr_utility.trace('State Balance Loop Count = ' ||
                       p_jurisdiction_tab.count);
     if p_jurisdiction_tab.count > 0 then
        /*(*/
        for i in p_jurisdiction_tab.first..
                 p_jurisdiction_tab.last loop
            if p_action_type = 'B' then
               lv_state_code    := 'Y';
               lv_sit_exists    := 'Y';
               lv_sui_ee_exists := 'Y';
               lv_sui_er_exists := 'Y';
               lv_sdi_ee_exists := 'Y';
               lv_sdi_er_exists := 'Y';
            else
               lv_state_code := substr(p_jurisdiction_tab(i).emp_jd,1,2);
               lv_sit_exists
                     := pay_us_action_arch.ltr_state_tax_info(lv_state_code).sit_exists;
               lv_sui_ee_exists
                     := pay_us_action_arch.ltr_state_tax_info(lv_state_code).sui_ee_exists;
               lv_sui_er_exists
                     := pay_us_action_arch.ltr_state_tax_info(lv_state_code).sui_er_exists;
               lv_sdi_ee_exists
                     := pay_us_action_arch.ltr_state_tax_info(lv_state_code).sdi_ee_exists;
               lv_sdi_er_exists
                     := pay_us_action_arch.ltr_state_tax_info(lv_state_code).sdi_er_exists;
            end if;

            hr_utility.trace('p_action_type = ' || p_action_type);
            hr_utility.trace('lv_sit_exists = ' || lv_sit_exists);
            hr_utility.trace('lv_sui_ee_exists = ' || lv_sui_ee_exists);
            hr_utility.trace('lv_sui_er_exists = ' || lv_sui_er_exists);
            hr_utility.trace('lv_sdi_ee_exists = ' || lv_sdi_ee_exists);
            hr_utility.trace('lv_sdi_er_exists = ' || lv_sdi_er_exists);
            hr_utility.trace('Archiving for Jurisdiction = ' ||
                              p_jurisdiction_tab(i).emp_jd);

            pay_balance_pkg.set_context('JURISDICTION_CODE',
                                        p_jurisdiction_tab(i).emp_jd);

           ln_bal_value     := 0;
           ln_curr_withheld := 0;
           ln_ytd_withheld  := 0;

           ln_step := 2;
           ln_index := get_table_index(p_jurisdiction_tab(i).emp_jd,
                                       'US STATE');
           hr_utility.trace('ln_index for state is '||to_char(ln_index));

           pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
               := 'US STATE';
           pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
               := p_jurisdiction_tab(i).emp_jd;

           if pay_us_action_arch.ltr_state_tax_bal.count > 0 then
              --(
              for j in pay_us_action_arch.ltr_state_tax_bal.first..
                       pay_us_action_arch.ltr_state_tax_bal.last loop
                  lv_balance_name := pay_us_action_arch.ltr_state_tax_bal(j).balance_name;
                  ln_balance_type_id := pay_us_action_arch.ltr_state_tax_bal(j).balance_type_id;
                  ln_pymt_def_bal_id := pay_us_action_arch.ltr_state_tax_bal(j).payment_def_bal_id;
                  ln_ytd_def_bal_id  := pay_us_action_arch.ltr_state_tax_bal(j).ytd_def_bal_id;
                  ln_run_def_bal_id  := pay_us_action_arch.ltr_state_tax_bal(j).asg_run_def_bal_id;

                  hr_utility.trace('lv_balance_name   =' || lv_balance_name);
                  hr_utility.trace('ln_pymt_def_bal_id=' || ln_pymt_def_bal_id);
                  hr_utility.trace('ln_ytd_def_bal_id =' || ln_ytd_def_bal_id);
                  hr_utility.trace('ln_run_def_bal_id =' || ln_run_def_bal_id);

                  --SIT
                  ln_step := 3;
                  if substr(lv_balance_name, 1,3) = 'SIT' then
                  hr_utility.trace('SIT');
                     if lv_sit_exists = 'Y' then
                        hr_utility.set_location(gv_package || lv_procedure_name,
                                                110);
                        if p_action_type in ('U', 'P')  then
                           -- SIT Alien
                           if lv_balance_name = 'SIT Alien Withheld' then
                              ln_step := 4;
                              -- Alien
                              if check_alien (p_xfr_action_id) = 'TRUE' then
                                 ln_bal_value := get_balance_value(
                                   p_defined_balance_id => ln_pymt_def_bal_id
                                  ,p_balcall_aaid       => p_pymt_balcall_aaid);

                                 ln_curr_withheld := ln_bal_value;
                                 hr_utility.trace('NonW2SIT Cur  = ' || ln_curr_withheld);

                                 ln_ytd_withheld := get_balance_value(
                                                     p_defined_balance_id => ln_ytd_def_bal_id
                                                    ,p_balcall_aaid       => p_ytd_balcall_aaid);
                                 hr_utility.trace('NonW2SIT YTD  = ' || ln_ytd_withheld);

                                 update_ytd_withheld(
                                        p_xfr_action_id   => p_xfr_action_id
                                       ,p_balance_name    => lv_balance_name
                                       ,p_balance_type_id => ln_balance_type_id
                                       ,p_jurisdiction    =>
                                            p_jurisdiction_tab(i).emp_jd
                                       ,p_curr_withheld   => ln_curr_withheld
                                       ,p_ytd_withheld    => ln_ytd_withheld);
                              end if;

                           else -- SIT Alien
                              ln_step := 5;
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_pymt_def_bal_id
                                                 ,p_balcall_aaid       => p_pymt_balcall_aaid);

                              if lv_balance_name = 'SIT Withheld' then
                                 ln_step := 6;
                                 ln_curr_withheld := ln_bal_value;
                                 ln_ytd_withheld := get_balance_value(
                                                      p_defined_balance_id => ln_ytd_def_bal_id
                                                     ,p_balcall_aaid       => p_ytd_balcall_aaid);
                                 update_ytd_withheld(
                                        p_xfr_action_id       => p_xfr_action_id
                                       ,p_balance_name        => lv_balance_name
                                       ,p_balance_type_id     => ln_balance_type_id
                                       ,p_processing_priority => 5
                                       ,p_jurisdiction        =>
                                          p_jurisdiction_tab(i).emp_jd
                                       ,p_curr_withheld       => ln_curr_withheld
                                       ,p_ytd_withheld        => ln_ytd_withheld);
                              end if;
                           end if; -- SIT Alien
                        else
                           ln_step := 7;
                           ln_bal_value := get_balance_value(
                                   p_defined_balance_id => ln_run_def_bal_id
                                  ,p_balcall_aaid       => p_rqp_action_id);
                        end if;

                        hr_utility.trace('ln_bal_value = ' || ln_bal_value);
                        ln_step := 8;
                        update_sit_values(p_balance   => lv_balance_name
                                         ,p_bal_value => ln_bal_value
                                         ,p_index     => ln_index);

                     end if; -- sit exists
                  end if;  -- taxtype is SIT

                  --SDI
                  ln_step := 11;
                  if substr(lv_balance_name, 1,3) = 'SDI' then
                  hr_utility.trace('SDI');
                     if substr(lv_balance_name, 5, 2) = 'EE' then
                        if lv_sdi_ee_exists = 'Y' then
                           if p_action_type  in  ( 'U', 'P')  then
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_pymt_def_bal_id
                                                 ,p_balcall_aaid       => p_pymt_balcall_aaid);

                              if lv_balance_name = 'SDI EE Withheld' then
                                 ln_curr_withheld := ln_bal_value;
                                 ln_ytd_withheld := get_balance_value(
                                                      p_defined_balance_id => ln_ytd_def_bal_id
                                                     ,p_balcall_aaid       => p_ytd_balcall_aaid);
                                 update_ytd_withheld(
                                      p_xfr_action_id   => p_xfr_action_id
                                     ,p_balance_name    => 'SDI Withheld'
                                     ,p_balance_type_id => ln_balance_type_id
                                     ,p_jurisdiction    =>
                                       p_jurisdiction_tab(i).emp_jd
                                     ,p_curr_withheld   => ln_curr_withheld
                                     ,p_ytd_withheld    => ln_ytd_withheld);

                              end if;
                           else
                              ln_bal_value := get_balance_value(
                                      p_defined_balance_id => ln_run_def_bal_id
                                     ,p_balcall_aaid       => p_rqp_action_id);
                           end if;

                           update_sdi_ee_values(p_balance   => lv_balance_name
                                               ,p_bal_value => ln_bal_value
                                               ,p_index     => ln_index);

                        end if;
                     elsif substr(lv_balance_name,5,2) = 'ER' then
                        if lv_sdi_er_exists = 'Y' then
                           if p_action_type  in  ( 'U', 'P')  then
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_pymt_def_bal_id
                                                 ,p_balcall_aaid       => p_pymt_balcall_aaid);
                           else
                              ln_bal_value := get_balance_value(
                                      p_defined_balance_id => ln_run_def_bal_id
                                     ,p_balcall_aaid       => p_rqp_action_id);
                           end if;
                           update_sdi_er_values(p_balance   => lv_balance_name
                                               ,p_bal_value => ln_bal_value
                                               ,p_index     => ln_index);

                        end if; -- if SDI ER exists
                     end if; -- if type EE or ER
                  end if; --if taxtype is SDI

                  --SUI
                  ln_step := 15;
                  if substr(lv_balance_name, 1, 3) = 'SUI' then
                  hr_utility.trace('SUI');
                     if substr(lv_balance_name, 5, 2) = 'EE' then
                        if lv_sui_ee_exists = 'Y' then
                           if p_action_type  in  ( 'U', 'P')  then
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_pymt_def_bal_id
                                                 ,p_balcall_aaid       => p_pymt_balcall_aaid);
                              if lv_balance_name = 'SUI EE Withheld' then
                                 ln_curr_withheld := ln_bal_value;
                                 ln_ytd_withheld := get_balance_value(
                                                      p_defined_balance_id => ln_ytd_def_bal_id
                                                     ,p_balcall_aaid       => p_ytd_balcall_aaid);
                                 update_ytd_withheld(
                                      p_xfr_action_id   => p_xfr_action_id
                                     ,p_balance_name    => 'SUI Withheld'
                                     ,p_balance_type_id => ln_balance_type_id
                                     ,p_jurisdiction    =>
                                       p_jurisdiction_tab(i).emp_jd
                                     ,p_curr_withheld   => ln_curr_withheld
                                     ,p_ytd_withheld    => ln_ytd_withheld);
                              end if;
                           else
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_run_def_bal_id
                                                 ,p_balcall_aaid       => p_rqp_action_id);
                           end if;

                           update_sui_ee_values(p_balance   => lv_balance_name
                                               ,p_bal_value => ln_bal_value
                                               ,p_index     => ln_index);

                        end if; -- SUI EE exists

                     elsif substr(lv_balance_name,5,2) = 'ER' then
                        if lv_sui_er_exists = 'Y' then
                           if p_action_type  in  ( 'U', 'P')  then
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_pymt_def_bal_id
                                                 ,p_balcall_aaid       => p_pymt_balcall_aaid);
                           else
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_run_def_bal_id
                                                 ,p_balcall_aaid       => p_rqp_action_id);
                           end if;

                           update_sui_er_values(p_balance   => lv_balance_name
                                               ,p_bal_value => ln_bal_value
                                               ,p_index     => ln_index);
                        end if;
                     end if;
                  end if;  --if taxtype is SUI

                  ln_step := 20;
                  if substr(lv_balance_name, 1, 4) = 'Work' then
                  hr_utility.trace('WORK');
                     if p_action_type  in  ( 'U', 'P')  then
                        ln_bal_value := get_balance_value(
                                            p_defined_balance_id => ln_pymt_def_bal_id
                                           ,p_balcall_aaid       => p_pymt_balcall_aaid);
                        if lv_balance_name = 'Workers Comp Withheld' then
                           ln_curr_withheld := ln_bal_value;
                           ln_ytd_withheld := get_balance_value(
                                                  p_defined_balance_id => ln_ytd_def_bal_id
                                                 ,p_balcall_aaid       => p_ytd_balcall_aaid);
                           update_ytd_withheld(
                                    p_xfr_action_id   => p_xfr_action_id
                                   ,p_balance_name    => 'WC Withheld'
                                   ,p_balance_type_id => ln_balance_type_id
                                   ,p_jurisdiction    =>
                                         p_jurisdiction_tab(i).emp_jd
                                   ,p_processing_priority => 10
                                   ,p_curr_withheld   => ln_curr_withheld
                                   ,p_ytd_withheld    => ln_ytd_withheld);
                        elsif lv_balance_name = 'Workers Comp2 Withheld' then
                           ln_curr_withheld := ln_bal_value;
                           ln_ytd_withheld := get_balance_value(
                                                  p_defined_balance_id => ln_ytd_def_bal_id
                                                 ,p_balcall_aaid       => p_ytd_balcall_aaid);
                           update_ytd_withheld(
                                    p_xfr_action_id   => p_xfr_action_id
                                   ,p_balance_name    => 'WC2 Withheld'
                                   ,p_balance_type_id => ln_balance_type_id
                                   ,p_jurisdiction    =>
                                         p_jurisdiction_tab(i).emp_jd
                                   ,p_processing_priority =>10
                                   ,p_curr_withheld   => ln_curr_withheld
                                   ,p_ytd_withheld    => ln_ytd_withheld);
                        end if;

                     else
                        ln_bal_value := get_balance_value(
                                            p_defined_balance_id => ln_run_def_bal_id
                                           ,p_balcall_aaid       => p_rqp_action_id);
                     end if;
                     hr_utility.trace('State Balance value is '|| ln_bal_value);

                     update_work_comp_values(p_balance   => lv_balance_name
                                            ,p_bal_value => ln_bal_value
                                            ,p_index     => ln_index);
                  end if;  -- taxtype is Workerscomp

                  --STEIC   /*Bug 3231253*/
                  if substr(lv_balance_name, 1, 5) = 'STEIC' then
                  hr_utility.trace('SITEIC');
                     if p_action_type  in  ( 'U', 'P')  then
                        ln_bal_value := get_balance_value(
                                            p_defined_balance_id => ln_pymt_def_bal_id
                                           ,p_balcall_aaid       => p_pymt_balcall_aaid);
                        if lv_balance_name = 'STEIC Advance' then
                           ln_bal_value := -1 * ln_bal_value;
			   ln_curr_withheld := ln_bal_value;
                           ln_ytd_withheld := get_balance_value(
                                                  p_defined_balance_id => ln_ytd_def_bal_id
                                                 ,p_balcall_aaid       => p_ytd_balcall_aaid);

                           ln_ytd_withheld := -1 * ln_ytd_withheld ;
                           update_ytd_withheld(
                                    p_xfr_action_id   => p_xfr_action_id
                                   ,p_balance_name    => 'STEIC Advance'
                                   ,p_balance_type_id => ln_balance_type_id
                                   ,p_jurisdiction    =>
                                         p_jurisdiction_tab(i).emp_jd
                                   ,p_processing_priority => 10
                                   ,p_curr_withheld   => ln_curr_withheld
                                   ,p_ytd_withheld    => ln_ytd_withheld);

                        end if;

                     else
                        ln_bal_value := get_balance_value(
                                            p_defined_balance_id => ln_run_def_bal_id
                                           ,p_balcall_aaid       => p_rqp_action_id);
                     end if;
                     hr_utility.trace('STEIC State Balance value is '|| ln_bal_value);

                     update_steic_values(p_balance   => lv_balance_name
                                        ,p_bal_value => ln_bal_value
                                        ,p_index     => ln_index);
                  end if;  -- taxtype is STEIC Advance

                  hr_utility.trace('Bottom of loop');

                  ln_bal_value     := 0;
                  ln_curr_withheld := 0;
                  ln_ytd_withheld  := 0;
              end loop; -- of ltr_state_tax_bal.taxtype)

              hr_utility.trace('After loop before end if of ltr_state_tax_bal.taxtype');

           end if; -- of ltr_state_tax_bal.taxtype

-- TCL_SUI1 Begin
 --- NEW LOOP HERE

			hr_utility.trace('US STATE2 loop begins here ');

            ln_index := get_table_index(p_jurisdiction_tab(i).emp_jd,
                                       'US STATE2');

 			hr_utility.trace('US STATE2 ln_index = '|| to_char(ln_index));

            pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
               := 'US STATE2';
           pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
               := p_jurisdiction_tab(i).emp_jd;

           if pay_us_action_arch.ltr_state2_tax_bal.count > 0 then
              --(
 			hr_utility.trace('US STATE2 for J... ');

              for j in pay_us_action_arch.ltr_state2_tax_bal.first..
                       pay_us_action_arch.ltr_state2_tax_bal.last loop
                  lv_balance_name := pay_us_action_arch.ltr_state2_tax_bal(j).balance_name;
                  ln_balance_type_id := pay_us_action_arch.ltr_state2_tax_bal(j).balance_type_id;
                  ln_pymt_def_bal_id := pay_us_action_arch.ltr_state2_tax_bal(j).payment_def_bal_id;
                  ln_ytd_def_bal_id  := pay_us_action_arch.ltr_state2_tax_bal(j).ytd_def_bal_id;
                  ln_run_def_bal_id  := pay_us_action_arch.ltr_state2_tax_bal(j).asg_run_def_bal_id;

                  hr_utility.trace('lv_balance_name   =' || lv_balance_name);
                  hr_utility.trace('ln_pymt_def_bal_id=' || ln_pymt_def_bal_id);
                  hr_utility.trace('ln_ytd_def_bal_id =' || ln_ytd_def_bal_id);
                  hr_utility.trace('ln_run_def_bal_id =' || ln_run_def_bal_id);

                  --SDI1
                  ln_step := 24;
                  if substr(lv_balance_name, 1,4) = 'SDI1' then
                  hr_utility.trace('SDI1');
                     if substr(lv_balance_name, 6, 2) = 'EE' then
                        if lv_sdi_ee_exists = 'Y' then
                           if p_action_type  in  ( 'U', 'P')  then
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_pymt_def_bal_id
                                                 ,p_balcall_aaid       => p_pymt_balcall_aaid);

                              if lv_balance_name = 'SDI1 EE Withheld' then
                                 ln_curr_withheld := ln_bal_value;
                                 ln_ytd_withheld := get_balance_value(
                                                      p_defined_balance_id => ln_ytd_def_bal_id
                                                     ,p_balcall_aaid       => p_ytd_balcall_aaid);
                                 update_ytd_withheld(
                                      p_xfr_action_id   => p_xfr_action_id
                                     ,p_balance_name    => 'SDI1 Withheld'
                                     ,p_balance_type_id => ln_balance_type_id
                                     ,p_jurisdiction    =>
                                       p_jurisdiction_tab(i).emp_jd
                                     ,p_curr_withheld   => ln_curr_withheld
                                     ,p_ytd_withheld    => ln_ytd_withheld);

                              end if;
                           else
                              ln_bal_value := get_balance_value(
                                      p_defined_balance_id => ln_run_def_bal_id
                                     ,p_balcall_aaid       => p_rqp_action_id);
                           end if;

                           update_sdi1_ee_values(p_balance   => lv_balance_name
                                               ,p_bal_value => ln_bal_value
                                               ,p_index     => ln_index);

                        end if;
/*                     elsif substr(lv_balance_name,6,2) = 'ER' then
                        if lv_sdi_er_exists = 'Y' then
                           if p_action_type  in  ( 'U', 'P')  then
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_pymt_def_bal_id
                                                 ,p_balcall_aaid       => p_pymt_balcall_aaid);
                           else
                              ln_bal_value := get_balance_value(
                                      p_defined_balance_id => ln_run_def_bal_id
                                     ,p_balcall_aaid       => p_rqp_action_id);
                           end if;
                           update_sdi_er_values(p_balance   => lv_balance_name
                                               ,p_bal_value => ln_bal_value
                                               ,p_index     => ln_index);

                        end if; -- if SDI1 ER exists
*/
                     end if; -- if type EE or ER
                  end if; --if taxtype is SDI1

                  ln_step := 25;
                  if substr(lv_balance_name, 1, 4) = 'SUI1' then  --SUI1 EE Withheld

 			hr_utility.trace('US STATE2 SUI1 ');

                     if substr(lv_balance_name, 6, 2) = 'EE' then

   			hr_utility.trace('US STATE2 SUI1 EE');

                        if lv_sui_ee_exists = 'Y' then
                           if p_action_type  in  ( 'U', 'P')  then
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_pymt_def_bal_id
                                                 ,p_balcall_aaid       => p_pymt_balcall_aaid);
                              if lv_balance_name = 'SUI1 EE Withheld' then

 			hr_utility.trace('US STATE2 lv_balance_name = SUI1 EE Withheld ');

                                 ln_curr_withheld := ln_bal_value;
                                 ln_ytd_withheld := get_balance_value(
                                                      p_defined_balance_id => ln_ytd_def_bal_id
                                                     ,p_balcall_aaid       => p_ytd_balcall_aaid);
 			hr_utility.trace('US STATE2 Before update_ytd_withheld ');

                                 update_ytd_withheld(
                                      p_xfr_action_id   => p_xfr_action_id
                                     ,p_balance_name    => 'SUI1 Withheld'
                                     ,p_balance_type_id => ln_balance_type_id
                                     ,p_jurisdiction    =>
                                       p_jurisdiction_tab(i).emp_jd
                                     ,p_curr_withheld   => ln_curr_withheld
                                     ,p_ytd_withheld    => ln_ytd_withheld);
                              end if;
                           else
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_run_def_bal_id
                                                 ,p_balcall_aaid       => p_rqp_action_id);
                           end if;

 			hr_utility.trace('US STATE2 Before update_sui1_ee_values ');

                           update_sui1_ee_values(p_balance   => lv_balance_name
                                               ,p_bal_value => ln_bal_value
                                               ,p_index     => ln_index);

                        end if; -- SUI1 EE exists

/*                     elsif substr(lv_balance_name,6,2) = 'ER' then
                        if lv_sui_er_exists = 'Y' then
                           if p_action_type  in  ( 'U', 'P')  then
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_pymt_def_bal_id
                                                 ,p_balcall_aaid       => p_pymt_balcall_aaid);
                           else
                              ln_bal_value := get_balance_value(
                                                  p_defined_balance_id => ln_run_def_bal_id
                                                 ,p_balcall_aaid       => p_rqp_action_id);
                           end if;

                           update_sui_er_values(p_balance   => lv_balance_name
                                               ,p_bal_value => ln_bal_value
                                               ,p_index     => ln_index);
                        end if;
*/
                     end if;
                  end if;  --if taxtype is SUI1

-- TCL_SUI1 End


                  ln_bal_value     := 0;
                  ln_curr_withheld := 0;
                  ln_ytd_withheld  := 0;
              end loop; -- of ltr_state2_tax_bal.taxtype)
           end if; -- of ltr_state2_tax_bal.taxtype



        end loop; -- )state jurisdiction loop
     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 150);

  EXCEPTION
   when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_state_tax_balances;


  /******************************************************************
   Name      : populate_county_tax_balances
   Purpose   : This procedure gets all the County level tax balances
               and populates the PL/SQL table.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE populate_county_tax_balances(
                      p_xfr_action_id      in number
                     ,p_pymt_balcall_aaid  in number default null
                     ,p_ytd_balcall_aaid   in number default null
                     ,p_rqp_action_id      in number
                     ,p_action_type        in varchar2
                     ,p_resident_state     in varchar2
                     ,p_resident_county    in varchar2
                     ,p_resident_city      in varchar2
                     ,p_jurisdiction_tab   in pay_ac_action_arch.emp_jd_rec_table)
  IS
    ln_index                  NUMBER ;
    lv_balance_name           VARCHAR2(80);
    ln_balance_type_id        NUMBER;
    ln_pymt_def_bal_id        NUMBER;
    ln_ytd_def_bal_id         NUMBER;
    ln_run_def_bal_id         NUMBER;

    lv_county_tax_exists      VARCHAR2(1);
    lv_county_head_tax_exists VARCHAR2(1);

    ln_bal_value              NUMBER(15,2) := 0;
    ln_curr_withheld          NUMBER(15,2) := 0;
    ln_ytd_withheld           NUMBER(15,2) := 0;

    lv_procedure_name         VARCHAR2(100) := '.populate_county_tax_balances';
    lv_error_message          VARCHAR2(200);
    ln_step                   NUMBER;


  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('County Balance Loop Count = ' ||
                       pay_us_action_arch.ltr_county_tax_bal.count);

     if p_jurisdiction_tab.count > 0 then
        for i in p_jurisdiction_tab.first..
                 p_jurisdiction_tab.last loop

            hr_utility.set_location(gv_package || lv_procedure_name, 160);
            if pay_us_action_arch.ltr_county_tax_info.count > 0 then
               if p_action_type = 'B' then
                  lv_county_tax_exists      := 'Y';
                  lv_county_head_tax_exists := 'Y';
               else
                  for j in pay_us_action_arch.ltr_county_tax_info.first ..
                           pay_us_action_arch.ltr_county_tax_info.last loop
                      if pay_us_action_arch.ltr_county_tax_info(j).jurisdiction_code
                           = p_jurisdiction_tab(i).emp_jd then
                         lv_county_tax_exists
                            := pay_us_action_arch.ltr_county_tax_info(j).cnty_tax_exists;
                         lv_county_head_tax_exists
                            := pay_us_action_arch.ltr_county_tax_info(j).cnty_head_tax_exists;
                         exit;
                      end if;
                  end loop;
               end if;
            end if;

            hr_utility.trace('COUNTY lv_county_tax_exists = ' ||
                              lv_county_tax_exists);
            hr_utility.trace('COUNTY lv_county_head_tax_exists = ' ||
                              lv_county_head_tax_exists);
            hr_utility.trace('COUNTY Archiving for Jurisdiction = ' ||
                              p_jurisdiction_tab(i).emp_jd);

           pay_balance_pkg.set_context('JURISDICTION_CODE',
                                       p_jurisdiction_tab(i).emp_jd);

           ln_index := get_table_index(p_jurisdiction_tab(i).emp_jd,
		                               NULL);

           pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                    := p_jurisdiction_tab(i).emp_jd;
           pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                    := 'US COUNTY';

           if p_jurisdiction_tab(i).emp_jd
               = p_resident_state||'-'||p_resident_county|| '-0000' then
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info30 := 'R';
           else
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info30 := 'NR';
           end if;

           if pay_us_action_arch.ltr_county_tax_bal.count > 0 then
              for k in pay_us_action_arch.ltr_county_tax_bal.first..
                       pay_us_action_arch.ltr_county_tax_bal.last loop
                  lv_balance_name := pay_us_action_arch.ltr_county_tax_bal(k).balance_name;
                  ln_balance_type_id := pay_us_action_arch.ltr_county_tax_bal(k).balance_type_id;
                  ln_pymt_def_bal_id := pay_us_action_arch.ltr_county_tax_bal(k).payment_def_bal_id;
                  ln_ytd_def_bal_id  := pay_us_action_arch.ltr_county_tax_bal(k).ytd_def_bal_id;
                  ln_run_def_bal_id  := pay_us_action_arch.ltr_county_tax_bal(k).asg_run_def_bal_id;

                  hr_utility.trace('lv_balance_name    = '||lv_balance_name);
                  hr_utility.trace('ln_pymt_def_bal_id = '||ln_pymt_def_bal_id);
                  hr_utility.trace('ln_ytd_def_bal_id  = '||ln_ytd_def_bal_id);
                  hr_utility.trace('ln_run_def_bal_id  = '||ln_run_def_bal_id);

                  if substr(lv_balance_name, 1, 6) = 'County' then
                     if lv_county_tax_exists = 'Y' then
                        if p_action_type  in  ( 'U', 'P')  then
                           ln_bal_value := get_balance_value(
                                               p_defined_balance_id => ln_pymt_def_bal_id
                                              ,p_balcall_aaid       => p_pymt_balcall_aaid);

                           if lv_balance_name = 'County Withheld' then
                              ln_curr_withheld := ln_bal_value;
                              ln_ytd_withheld := get_balance_value(
                                                     p_defined_balance_id => ln_ytd_def_bal_id
                                                    ,p_balcall_aaid       => p_ytd_balcall_aaid);
                              update_ytd_withheld(
                                    p_xfr_action_id       => p_xfr_action_id
                                   ,p_balance_name        => 'County Withheld'
                                   ,p_balance_type_id     => ln_balance_type_id
                                   ,p_processing_priority => 6
                                   ,p_jurisdiction        =>
                                      p_jurisdiction_tab(i).emp_jd
                                   ,p_curr_withheld       => ln_curr_withheld
                                   ,p_ytd_withheld        => ln_ytd_withheld);
                           end if;
                        else
                           ln_bal_value := get_balance_value(
                                               p_defined_balance_id => ln_run_def_bal_id
                                              ,p_balcall_aaid       => p_rqp_action_id);
                        end if;

                        update_county_values(p_balance   => lv_balance_name
                                            ,p_bal_value => ln_bal_value
                                            ,p_index     => ln_index);
                     end if; --county tax exists
                  end if; --substr is County

                  if substr(lv_balance_name, 1, 4) = 'Head' then
                     if lv_county_head_tax_exists = 'Y' then
                        if p_action_type  in  ( 'U', 'P')  then
                           ln_bal_value := get_balance_value(
                                               p_defined_balance_id => ln_pymt_def_bal_id
                                              ,p_balcall_aaid       => p_pymt_balcall_aaid);
                           if lv_balance_name = 'Head Tax Withheld'  then
                              ln_curr_withheld := ln_bal_value;
                              ln_ytd_withheld := get_balance_value(
                                                     p_defined_balance_id => ln_ytd_def_bal_id
                                                    ,p_balcall_aaid       => p_ytd_balcall_aaid);

                              update_ytd_withheld(
                                    p_xfr_action_id    => p_xfr_action_id
                                   ,p_balance_name     => 'Head Tax Withheld'
                                   ,p_balance_type_id  => ln_balance_type_id
                                   ,p_jurisdiction     =>
                                      p_jurisdiction_tab(i).emp_jd
                                   ,p_curr_withheld    => ln_curr_withheld
                                   ,p_ytd_withheld     => ln_ytd_withheld);

                          end if;
                        else
                           ln_bal_value := get_balance_value(
                                               p_defined_balance_id => ln_run_def_bal_id
                                              ,p_balcall_aaid       => p_rqp_action_id);
                        end if;

                        update_county_head_values(
                                          p_balance   => lv_balance_name
                                         ,p_bal_value => ln_bal_value
                                         ,p_index     => ln_index);
                     end if; --head tax exists
                  end if; --substr is Head

                  ln_bal_value     := 0;
                  ln_curr_withheld := 0;
                  ln_ytd_withheld  := 0;

              end loop; -- ltr_county_tax_bal
           end if; -- ltr_county_tax_bal

        end loop; -- of jurisdiction)
     end if; -- of jurisdiction)
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;
  END populate_county_tax_balances;


  /******************************************************************
   Name      : populate_city_tax_balances
   Purpose   : This procedure gets all the City level tax balances
               and populates the PL/SQL table.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE populate_city_tax_balances(
                      p_xfr_action_id      in number
                     ,p_pymt_balcall_aaid  in number default null
                     ,p_ytd_balcall_aaid   in number default null
                     ,p_rqp_action_id      in number
                     ,p_action_type        in varchar2
                     ,p_resident_state     in varchar2
                     ,p_resident_county    in varchar2
                     ,p_resident_city      in varchar2
                     ,p_effective_date     in date
                     ,p_jurisdiction_tab   in pay_ac_action_arch.emp_jd_rec_table)
  IS
    ln_index                  NUMBER ;
    lv_balance_name           VARCHAR2(80);
    ln_balance_type_id        NUMBER;
    ln_pymt_def_bal_id        NUMBER;
    ln_ytd_def_bal_id         NUMBER;
    ln_run_def_bal_id         NUMBER;

    lv_city_tax_exists        VARCHAR2(1);
    lv_city_head_tax_exists   VARCHAR2(1);

    ln_bal_value              NUMBER(15,2) := 0;
    ln_curr_withheld          NUMBER(15,2) := 0;
    ln_ytd_withheld           NUMBER(15,2) := 0;

    lv_procedure_name         VARCHAR2(100) := '.populate_city_tax_balances';
    lv_error_message          VARCHAR2(200);
    ln_step                   NUMBER;


  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     if p_jurisdiction_tab.count > 0 then
        for i in p_jurisdiction_tab.first..
                 p_jurisdiction_tab.last loop
            if p_action_type = 'B' then
               lv_city_tax_exists      := 'Y';
               lv_city_head_tax_exists := 'Y';
            else
               get_city_tax_info(p_effective_date,
                                 p_jurisdiction_tab(i).emp_jd,
                                 lv_city_tax_exists,
                                 lv_city_head_tax_exists);
            end if;

            hr_utility.trace('CITY Archiving for Jurisdiction = ' ||
                              p_jurisdiction_tab(i).emp_jd);

            pay_balance_pkg.set_context('JURISDICTION_CODE',
                                        p_jurisdiction_tab(i).emp_jd);

            ln_index := get_table_index(p_jurisdiction_tab(i).emp_jd,
			                            NULL);
            hr_utility.trace('Index = '|| ln_index);

            pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                    := p_jurisdiction_tab(i).emp_jd;
            pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                    := 'US CITY';

            /************************************************************
            ** When comparing the City Jurisdiction for
            ** Resident/Non Resident flag, only check the State and City
            ** Codes i.e. do not check county codes.
            ** This is because a City could span multiple counties.
            ***********************************************************/
            if substr(p_jurisdiction_tab(i).emp_jd,1,2)
                                   || '-000-'
                                   || substr(p_jurisdiction_tab(i).emp_jd,8,4)
                = p_resident_state || '-000-'
                                   || p_resident_city  then
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info30 := 'R';
            else
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info30 := 'NR';
            end if;

            if pay_us_action_arch.ltr_city_tax_bal.count > 0 then
               for k in pay_us_action_arch.ltr_city_tax_bal.first..
                        pay_us_action_arch.ltr_city_tax_bal.last loop

                   lv_balance_name :=
                      pay_us_action_arch.ltr_city_tax_bal(k).balance_name;
                   ln_balance_type_id :=
                      pay_us_action_arch.ltr_city_tax_bal(k).balance_type_id;
                   ln_pymt_def_bal_id :=
                      pay_us_action_arch.ltr_city_tax_bal(k).payment_def_bal_id;
                   ln_ytd_def_bal_id :=
                      pay_us_action_arch.ltr_city_tax_bal(k).ytd_def_bal_id;
                   ln_run_def_bal_id :=
                      pay_us_action_arch.ltr_city_tax_bal(k).asg_run_def_bal_id;

                   hr_utility.trace('lv_balance_name   ='||lv_balance_name);
                   hr_utility.trace('ln_pymt_def_bal_id='||ln_pymt_def_bal_id);
                   hr_utility.trace('ln_ytd_def_bal_id ='||ln_ytd_def_bal_id);
                   hr_utility.trace('ln_run_def_bal_id ='||ln_run_def_bal_id);

                   if substr(lv_balance_name,1,4) = 'City' then
                      if lv_city_tax_exists = 'Y' then
                         if p_action_type in ('U', 'P') then
                            ln_bal_value := get_balance_value(
                                                p_defined_balance_id => ln_pymt_def_bal_id
                                               ,p_balcall_aaid       => p_pymt_balcall_aaid);
                            if lv_balance_name = 'City Withheld' then
                               ln_curr_withheld := ln_bal_value;
                               ln_ytd_withheld := get_balance_value(
                                                      p_defined_balance_id => ln_ytd_def_bal_id
                                                     ,p_balcall_aaid       => p_ytd_balcall_aaid);

                               update_ytd_withheld(
                                     p_xfr_action_id   => p_xfr_action_id
                                    ,p_balance_name    => 'City Withheld'
                                    ,p_balance_type_id => ln_balance_type_id
                                    ,p_jurisdiction    =>
                                        p_jurisdiction_tab(i).emp_jd
                                    ,p_curr_withheld   => ln_curr_withheld
                                    ,p_ytd_withheld    => ln_ytd_withheld);
                            end if;
                         else
                            ln_bal_value := get_balance_value(
                                                p_defined_balance_id => ln_run_def_bal_id
                                               ,p_balcall_aaid       => p_rqp_action_id);
                         end if;
                         hr_utility.trace('ln_bal_value = '|| ln_bal_value);

                         update_city_values(
                                          p_balance   => lv_balance_name
                                         ,p_bal_value => ln_bal_value
                                         ,p_index     => ln_index);

                      end if; --city tax exists
                   end if; --substr is City

                   if substr(lv_balance_name,1,4) = 'Head' then
                      if lv_city_head_tax_exists = 'Y' then
                         if p_action_type  in  ( 'U', 'P')  then
                            ln_bal_value := get_balance_value(
                                                p_defined_balance_id => ln_pymt_def_bal_id
                                               ,p_balcall_aaid       => p_pymt_balcall_aaid);
                            if lv_balance_name = 'Head Tax Withheld' then
                               ln_curr_withheld := ln_bal_value;
                               ln_ytd_withheld := get_balance_value(
                                                      p_defined_balance_id => ln_ytd_def_bal_id
                                                     ,p_balcall_aaid       => p_ytd_balcall_aaid);
                               update_ytd_withheld(
                                     p_xfr_action_id    => p_xfr_action_id
                                    ,p_balance_name     => 'Head Tax Withheld'
                                    ,p_balance_type_id  => ln_balance_type_id
                                    ,p_jurisdiction     =>
                                        p_jurisdiction_tab(i).emp_jd
                                    ,p_curr_withheld    => ln_curr_withheld
                                    ,p_ytd_withheld     => ln_ytd_withheld);
                            end if;
                         else
                            ln_bal_value := get_balance_value(
                                                p_defined_balance_id => ln_run_def_bal_id
                                               ,p_balcall_aaid       => p_rqp_action_id);
                         end if;
                         hr_utility.trace('ln_bal_value = '|| ln_bal_value);

                         update_city_head_values(
                                          p_balance   => lv_balance_name
                                         ,p_bal_value => ln_bal_value
                                         ,p_index     => ln_index);
                      end if; -- city head tax  exists
                   end if; --substr is Head

                   ln_bal_value     := 0;
                   ln_curr_withheld := 0;
                   ln_ytd_withheld  := 0;

               end loop; -- ltr_city_tax_bal
           end if; -- ltr_city_tax_bal
        end loop; -- of city jurisdiction
     end if; -- of city jurisdiction

     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;
  END populate_city_tax_balances;

  /******************************************************************
   Name      : populate_school_tax_balances
   Purpose   : This procedure gets all the School level tax balances
               and populates the PL/SQL table.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE populate_school_tax_balances(
                      p_xfr_action_id     in number
                     ,p_pymt_balcall_aaid in number default null
                     ,p_ytd_balcall_aaid  in number default null
                     ,p_rqp_action_id     in number
                     ,p_action_type       in varchar2
                     ,p_jurisdiction_tab  in pay_ac_action_arch.emp_rec_table)
  IS
    ln_index                  NUMBER ;
    lv_balance_name           VARCHAR2(80);
    ln_balance_type_id        NUMBER;
    ln_pymt_def_bal_id        NUMBER;
    ln_ytd_def_bal_id         NUMBER;
    ln_run_def_bal_id         NUMBER;

    lv_emp_school_jd          VARCHAR2(15);

    ln_bal_value              NUMBER(15,2) := 0;
    ln_curr_withheld          NUMBER(15,2) := 0;
    ln_ytd_withheld           NUMBER(15,2) := 0;

    lv_procedure_name         VARCHAR2(100) := '.populate_school_tax_balances';
    lv_error_message          VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     if p_jurisdiction_tab.count > 0 then
        for j in p_jurisdiction_tab.first..
                 p_jurisdiction_tab.last loop

            hr_utility.trace(' Archiving for School Dist  = ' ||
                 p_jurisdiction_tab(j).emp_jd);
            hr_utility.trace(' Parent JD for School Dist  = ' ||
                 p_jurisdiction_tab(j).emp_parent_jd);

            pay_balance_pkg.set_context('JURISDICTION_CODE',
                                        p_jurisdiction_tab(j).emp_jd);

            lv_emp_school_jd := p_jurisdiction_tab(j).emp_jd;
            ln_index := get_table_index(p_jurisdiction_tab(j).emp_jd,
			                            NULL);

            pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                  := p_jurisdiction_tab(j).emp_jd;
            pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                  := 'US SCHOOL DISTRICT';
            pay_ac_action_arch.lrr_act_tab(ln_index).act_info30
                  := p_jurisdiction_tab(j).emp_parent_jd;

            if pay_us_action_arch.ltr_schdist_tax_bal.count > 0 then
               for k in pay_us_action_arch.ltr_schdist_tax_bal.first..
                        pay_us_action_arch.ltr_schdist_tax_bal.last loop

                   lv_balance_name
                    := pay_us_action_arch.ltr_schdist_tax_bal(k).balance_name;
                   ln_balance_type_id
                    := pay_us_action_arch.ltr_schdist_tax_bal(k).balance_type_id;
                   ln_pymt_def_bal_id
                    := pay_us_action_arch.ltr_schdist_tax_bal(k).payment_def_bal_id;
                   ln_ytd_def_bal_id
                    := pay_us_action_arch.ltr_schdist_tax_bal(k).ytd_def_bal_id;
                   ln_run_def_bal_id
                    := pay_us_action_arch.ltr_schdist_tax_bal(k).asg_run_def_bal_id;

                   hr_utility.trace('lv_balance_name   = '||lv_balance_name);
                   hr_utility.trace('ln_pymt_def_bal_id= '||ln_pymt_def_bal_id);
                   hr_utility.trace('ln_ytd_def_bal_id = '||ln_ytd_def_bal_id);
                   hr_utility.trace('ln_run_def_bal_id = '||ln_run_def_bal_id);

                   if p_action_type  in  ( 'U', 'P')  then
                      ln_bal_value := get_balance_value(
                                          p_defined_balance_id => ln_pymt_def_bal_id
                                         ,p_balcall_aaid       => p_pymt_balcall_aaid);

                      if lv_balance_name = 'School Withheld' then
                         ln_curr_withheld := ln_bal_value;
                         ln_ytd_withheld := get_balance_value(
                                                p_defined_balance_id => ln_ytd_def_bal_id
                                               ,p_balcall_aaid       => p_ytd_balcall_aaid);
                         update_ytd_withheld(
                                   p_xfr_action_id    => p_xfr_action_id
                                  ,p_balance_name     => 'School Withheld'
                                  ,p_balance_type_id  => ln_balance_type_id
                                  ,p_jurisdiction     => lv_emp_school_jd
                                  ,p_curr_withheld    => ln_curr_withheld
                                  ,p_ytd_withheld     => ln_ytd_withheld);
                      end if;
                   else
                      ln_bal_value := get_balance_value(
                                          p_defined_balance_id => ln_run_def_bal_id
                                         ,p_balcall_aaid       => p_rqp_action_id);
                   end if;

                   hr_utility.trace('ln_bal_value for school dist is '||
                                     ln_bal_value);

                   update_school_values(
                                     p_balance   => lv_balance_name
                                    ,p_bal_value => ln_bal_value
                                    ,p_index     => ln_index);

                   ln_bal_value     := 0;
                   ln_curr_withheld := 0;
                   ln_ytd_withheld  := 0;

               end loop; -- ltr_schdist_tax_bal
           end if; -- ltr_schdist_tax_bal
        end loop; -- of sd jurisdiction
     end if; -- of sd jurisdiction
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;
  END populate_school_tax_balances;

  /*********************************************************************
   Name      : check_tax_exists
   Purpose   : This function checks whether does tax exist for given
               assignment_id, tax_unit_id, effective_date, jurisdiction
               for State, County and City.
               This function calls another function
               pay_get_tax_exists_pkg.get_tax_exists
               This function returns a 'Y' or 'N'.
   Arguments : IN
                 p_assignment_id        number;
                 p_tax_unit_id          number;
                 p_run_effective_date   date;
                 p_jurisdiction_code    varchar2;
   Notes     :
  *********************************************************************/
  FUNCTION check_tax_exists(
                 p_assignment_id        number,
                 p_tax_unit_id          number,
                 p_run_effective_date   date,
                 p_jurisdiction_code    varchar2)
  RETURN VARCHAR2
  IS
    cursor c_get_head_tax (cp_jd varchar2
                          ,cp_date date) is
    select nvl(head_tax,'N')
      from pay_us_city_tax_info_f
     where jurisdiction_code = cp_jd
       and cp_date between effective_start_date and effective_end_date;


    lv_tax_exists  varchar2(80) := 'N';

    lv_procedure_name         VARCHAR2(100) :=  '.check_tax_exists';
    lv_error_message          VARCHAR2(200);
    ln_step                   NUMBER;

    TYPE char_tabtype IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
    lv_tax_type char_tabtype;

  BEGIN

    ln_step := 1;
    hr_utility.set_location(gv_package || lv_procedure_name, 10);

    if length(p_jurisdiction_code) > 8 then
       if length(p_jurisdiction_code) = 11 and
          substr(p_jurisdiction_code, 4) = '000-0000' then

          hr_utility.set_location(gv_package || lv_procedure_name, 20);
          ln_step := 2;
          lv_tax_type(1) := 'SIT_WK';
          lv_tax_type(2) := 'SIT_RS';
          lv_tax_type(3) := 'SUI';
          lv_tax_type(4) := 'SDI_EE';

          for i in 1..4 loop

             ln_step := 3;
             lv_tax_exists :=
                pay_get_tax_exists_pkg.get_tax_exists(p_juri_code   => p_jurisdiction_code
                                                     ,p_date_earned => p_run_effective_date
                                                     ,p_tax_unit_id => p_tax_unit_id
                                                     ,p_assign_id   => p_assignment_id
						     ,p_pact_id     => NULL /** 5683349*/
                                                     ,p_type        => lv_tax_type(i)
                                                     ,p_call        => 'P');
             if lv_tax_exists = 'Y' then
                exit;
             end if;

          end loop;

          ln_step := 4;
          return(lv_tax_exists);

       elsif length(p_jurisdiction_code) = 11 and
             substr(p_jurisdiction_code,8) = '0000' and
             substr(p_jurisdiction_code,4,3) <> '000' then

          hr_utility.set_location(gv_package || lv_procedure_name, 30);
          ln_step := 5;
          lv_tax_type(1) := 'COUNTY_WK';
          lv_tax_type(2) := 'COUNTY_RS';

          for i in 1..2 loop

             ln_step := 6;
             lv_tax_exists :=
                pay_get_tax_exists_pkg.get_tax_exists(p_juri_code   => p_jurisdiction_code
                                                     ,p_date_earned => p_run_effective_date
                                                     ,p_tax_unit_id => p_tax_unit_id
                                                     ,p_assign_id   => p_assignment_id
                                                     ,p_pact_id     => NULL /** 5683349*/
                                                     ,p_type        => lv_tax_type(i)
						     ,p_call        => 'P');

	     if lv_tax_exists = 'Y' then
                exit;
             end if;

          end loop;

          ln_step := 7;
          return(lv_tax_exists);

       elsif length(p_jurisdiction_code) = 11 and
             substr(p_jurisdiction_code,8) <> '0000' then

          hr_utility.set_location(gv_package || lv_procedure_name, 40);
          ln_step := 8;
          lv_tax_type(1) := 'CITY_WK';
          lv_tax_type(2) := 'CITY_RS';
          lv_tax_type(3) := 'HT_WK';

          for i in 1..3 loop

             ln_step := 9;
             if i in (1,2) then
             lv_tax_exists :=
                pay_get_tax_exists_pkg.get_tax_exists(p_juri_code   => p_jurisdiction_code
                                                     ,p_date_earned => p_run_effective_date
                                                     ,p_tax_unit_id => p_tax_unit_id
                                                     ,p_assign_id   => p_assignment_id
                                                     ,p_pact_id     => NULL /** 5683349*/
                                                     ,p_type        => lv_tax_type(i)
						     ,p_call        => 'P');

             elsif i = 3 then
                 open c_get_head_tax(p_jurisdiction_code,p_run_effective_date);
                 lv_tax_exists := ' ';
                 fetch c_get_head_tax into lv_tax_exists;
                   if c_get_head_tax%notfound then
                      hr_utility.set_location(gv_package||lv_procedure_name,10);
                      lv_error_message := 'No row in JIT Tables ' ||
                                          'for this Jurisdiction ';
                      lv_tax_exists := 'N';
                      --hr_utility.raise_error;
                   end if;
                 close c_get_head_tax;

             end if;

             if lv_tax_exists = 'Y' then
                exit;
             end if;

          end loop;

          ln_step := 10;
          return(lv_tax_exists);

       end if;

    elsif length(p_jurisdiction_code) = 8 then

       hr_utility.set_location(gv_package || lv_procedure_name, 50);
       ln_step := 11;
       lv_tax_exists := 'Y';
       return(lv_tax_exists);

    end if;

    hr_utility.set_location(gv_package || lv_procedure_name, 60);
    return(lv_tax_exists);

  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END check_tax_exists;

  /******************************************************************
   Name      : populate_puv_tax_balances
   Purpose   : This is the procedure which is called for Quick/
               Pre-Payments and Reversals.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE populate_puv_tax_balances(
               p_xfr_action_id          in number
              ,p_assignment_id          in number
              ,p_tax_unit_id            in number
              ,p_pymt_balcall_aaid      in number
              ,p_ytd_balcall_aaid       in number
              ,p_rqp_action_id          in number
              ,p_action_type            in varchar2
              ,p_start_date             in date
              ,p_end_date               in date
              ,p_run_effective_date     in date
              ,p_sepchk_run_type_id     in number   default null
              ,p_sepchk_flag            in varchar2 default null
              ,p_resident_jurisdiction out nocopy varchar2
              )

  IS

    cursor c_get_jd (cp_assignment_id number
                    ,cp_tax_unit_id   number) is
      select substr(puar.jurisdiction_code,1,2)||'-000-0000'
        from pay_us_asg_reporting puar
       where puar.assignment_id = cp_assignment_id
         and puar.tax_unit_id   = cp_tax_unit_id
      union
      select substr(puar.jurisdiction_code,1,6)||'-0000'
        from pay_us_asg_reporting puar
       where puar.assignment_id = cp_assignment_id
         and puar.tax_unit_id   = cp_tax_unit_id
         and length(puar.jurisdiction_code) <> 8
      union
      select puar.jurisdiction_code
        from pay_us_asg_reporting puar
       where puar.assignment_id = cp_assignment_id
         and puar.tax_unit_id   = cp_tax_unit_id;

    ln_index                  NUMBER ;

    lv_rr_jurisdiction_code   VARCHAR2(11);
    lv_rr_sd_parent_jd        VARCHAR2(11);
    lv_state_code             VARCHAR2(11);

    lv_resident_state         VARCHAR2(11);
    lv_resident_county        VARCHAR2(11);
    lv_resident_city          VARCHAR2(11);

    lv_procedure_name         VARCHAR2(100) :=  '.populate_puv_tax_balances';
    lv_error_message          VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);

     /*****************************************************************
     ** Get Jurisdictions from pay_run_results for all locked actions
     ** actions of the U,P,V case and then populating different PLSQL
     ** tables for State, County, City, School Dist
     *****************************************************************/
     hr_utility.trace('c_get_rr_jd parameters are---------');
     hr_utility.trace('p_rqp_action_id = '||p_rqp_action_id);
     hr_utility.trace('p_assignment_id = '||p_assignment_id);
     hr_utility.trace('p_sepchk_run_type_id = '||p_sepchk_run_type_id);
     hr_utility.trace('p_run_effective_date = '||p_run_effective_date);
     hr_utility.trace('-----------------------------------------');

     open c_get_jd( p_assignment_id
                   ,p_tax_unit_id );

     loop
        fetch c_get_jd into lv_rr_jurisdiction_code;
        exit when c_get_jd%notfound;

        if check_tax_exists(p_assignment_id, p_tax_unit_id,
                            p_run_effective_date, lv_rr_jurisdiction_code) = 'Y'
        then

           hr_utility.trace('lv_rr_jurisdiction_code = '||lv_rr_jurisdiction_code);

           /*************************************************************
           ** Populate the PLSQL table emp_state_jd with this jd
           *************************************************************/
           if length(lv_rr_jurisdiction_code) = 11 and
              lv_rr_jurisdiction_code = '00-000-0000' then
              -- don't do anything as this should never happen. Added this as
              -- a safety check. We don't care about Federal JD
              null;
           elsif length(lv_rr_jurisdiction_code) = 11 and
              substr(lv_rr_jurisdiction_code, 4) = '000-0000' then
              ln_index := pay_ac_action_arch.emp_state_jd.count;
              pay_ac_action_arch.emp_state_jd(ln_index).emp_jd
                        := lv_rr_jurisdiction_code;
           /*************************************************************
           ** Populate the PLSQL table emp_county_jd with this jd
           *************************************************************/
           elsif length(lv_rr_jurisdiction_code) = 11 and
                 substr(lv_rr_jurisdiction_code,8) = '0000' and
                 substr(lv_rr_jurisdiction_code,4,3) <> '000' then
              ln_index := pay_ac_action_arch.emp_county_jd.count;
              pay_ac_action_arch.emp_county_jd(ln_index).emp_jd
                        := lv_rr_jurisdiction_code;
           /*************************************************************
           ** Populate the PLSQL table emp_city_jd with this jd
           *************************************************************/
           elsif length(lv_rr_jurisdiction_code) = 11 and
                 substr(lv_rr_jurisdiction_code,8) <> '0000' then
              ln_index := pay_ac_action_arch.emp_city_jd.count;
              pay_ac_action_arch.emp_city_jd(ln_index).emp_jd := lv_rr_jurisdiction_code;
           /*************************************************************
           ** Populate the PLSQL table emp_school_jd with this jd
           *************************************************************/
           elsif length(lv_rr_jurisdiction_code) = 8 then
              if substr(lv_rr_jurisdiction_code,1,2) = '39' then
                 lv_rr_sd_parent_jd
                        := get_school_parent_jd(
                                p_assignment_id => p_assignment_id
                               ,p_school_jurisdiction => lv_rr_jurisdiction_code
                               ,p_start_date    => p_start_date
                               ,p_end_date      => p_end_date);
              end if;

              ln_index := pay_ac_action_arch.emp_school_jd.count;
              pay_ac_action_arch.emp_school_jd(ln_index).emp_jd
                               := lv_rr_jurisdiction_code;
              pay_ac_action_arch.emp_school_jd(ln_index).emp_parent_jd
                               := lv_rr_sd_parent_jd;
           end if;
        end if;
     end loop;
     close c_get_jd;

     hr_utility.set_location(gv_package || lv_procedure_name, 50);


     /*****************************************************************
     ** Get Employee Resident Jurisdiction
     *****************************************************************/
     get_emp_residence(p_assignment_id      => p_assignment_id
                      ,p_end_date           => p_end_date
                      ,p_run_effective_date => p_run_effective_date
                      ,p_resident_state_jd  => lv_resident_state
                      ,p_resident_county_jd => lv_resident_county
                      ,p_resident_city_jd   => lv_resident_city);

     p_resident_jurisdiction := lv_resident_state  || '-' ||
                                lv_resident_county || '-' ||
                                lv_resident_city;
     /*****************************************************************
     ** Federal Information Archiving
     *****************************************************************/
     populate_federal_tax_balances(p_xfr_action_id     => p_xfr_action_id
                                  ,p_pymt_balcall_aaid => p_pymt_balcall_aaid
                                  ,p_ytd_balcall_aaid  => p_ytd_balcall_aaid
                                  ,p_rqp_action_id     => p_rqp_action_id
                                  ,p_action_type       => p_action_type);
     hr_utility.set_location(gv_package || lv_procedure_name, 60);

     /*****************************************************************
     ** State Information Archiving
     *****************************************************************/
     populate_state_tax_balances(
                      p_xfr_action_id     => p_xfr_action_id
                     ,p_pymt_balcall_aaid => p_pymt_balcall_aaid
                     ,p_ytd_balcall_aaid  => p_ytd_balcall_aaid
                     ,p_rqp_action_id     => p_rqp_action_id
                     ,p_action_type       => p_action_type
                     ,p_jurisdiction_tab  => pay_ac_action_arch.emp_state_jd);
     hr_utility.set_location(gv_package || lv_procedure_name, 70);

     /*****************************************************************
     ** County Information Archiving
     *****************************************************************/
     populate_county_tax_balances(
                      p_xfr_action_id     => p_xfr_action_id
                     ,p_pymt_balcall_aaid => p_pymt_balcall_aaid
                     ,p_ytd_balcall_aaid  => p_ytd_balcall_aaid
                     ,p_rqp_action_id     => p_rqp_action_id
                     ,p_resident_state    => lv_resident_state
                     ,p_resident_county   => lv_resident_county
                     ,p_resident_city     => lv_resident_city
                     ,p_action_type       => p_action_type
                     ,p_jurisdiction_tab  => pay_ac_action_arch.emp_county_jd);

     /*****************************************************************
     ** City Information Archiving
     *****************************************************************/
     populate_city_tax_balances(
                      p_xfr_action_id     => p_xfr_action_id
                     ,p_pymt_balcall_aaid => p_pymt_balcall_aaid
                     ,p_ytd_balcall_aaid  => p_ytd_balcall_aaid
                     ,p_rqp_action_id     => p_rqp_action_id
                     ,p_action_type       => p_action_type
                     ,p_resident_state    => lv_resident_state
                     ,p_resident_county   => lv_resident_county
                     ,p_resident_city     => lv_resident_city
                     ,p_effective_date    => p_end_date
                     ,p_jurisdiction_tab  => pay_ac_action_arch.emp_city_jd);

     /*****************************************************************
     ** School District Information Archiving
     *****************************************************************/
     populate_school_tax_balances(
                      p_xfr_action_id     => p_xfr_action_id
                     ,p_pymt_balcall_aaid => p_pymt_balcall_aaid
                     ,p_ytd_balcall_aaid  => p_ytd_balcall_aaid
                     ,p_rqp_action_id     => p_rqp_action_id
                     ,p_action_type       => p_action_type
                     ,p_jurisdiction_tab  => pay_ac_action_arch.emp_school_jd);


  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_puv_tax_balances;



  /******************************************************************
   Name      : populate_adj_tax_balances
   Purpose   : This is the procedure which is called for Balance
               Adjustments.
   Arguments :
   Notes     : When archiving a balance adjustment, we should not
               check if a tax exists but do the balance calls and
               archive for a non-zero balance value.
  ******************************************************************/
  PROCEDURE populate_adj_tax_balances( p_xfr_action_id        in number
                                      ,p_assignment_id        in number
                                      ,p_tax_unit_id          in number
                                      ,p_action_type          in varchar2
                                      ,p_start_date           in date
                                      ,p_end_date             in date
                                      ,p_run_effective_date   in date
                                      )
  IS

    cursor c_get_emp_adjbal(cp_xfr_action_id number) IS
      select locked_action_id
        from pay_action_interlocks
       where locking_action_id = cp_xfr_action_id;

    cursor c_get_baladj_jd(cp_baladj_action_id number
                          ,cp_run_effective_date in date) is
    select distinct prr.jurisdiction_code
      from pay_run_results prr
     where prr.assignment_action_id = cp_baladj_action_id
       and length(prr.jurisdiction_code) >= 8
       and substr(prr.jurisdiction_code,8,1) <> 'U'
     order by prr.jurisdiction_code;

    ln_index                    NUMBER;
    ln_baladj_action_id         NUMBER;

    lv_baladj_jurisdiction_code VARCHAR2(30);

    lv_resident_city            VARCHAR2(30);
    lv_resident_county          VARCHAR2(30);
    lv_resident_state           VARCHAR2(30);

    lv_rr_sd_parent_jd          VARCHAR2(30);
    lv_procedure_name           VARCHAR2(100) := '.populate_adj_tax_balances';
    lv_error_message            VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);

     open c_get_emp_adjbal(p_xfr_action_id);
     loop
        fetch c_get_emp_adjbal into ln_baladj_action_id;
        if c_get_emp_adjbal%notfound then
           hr_utility.set_location(gv_package || lv_procedure_name, 20);
           exit;
        end if;
        hr_utility.trace('ln_baladj_action_id = '|| ln_baladj_action_id);

        open c_get_baladj_jd(ln_baladj_action_id
                            ,p_run_effective_date);
        loop
           fetch c_get_baladj_jd into lv_baladj_jurisdiction_code;
           if c_get_baladj_jd%notfound or lv_baladj_jurisdiction_code is null then
              hr_utility.set_location(gv_package || '.archive_date', 222);
              exit;
           end if;
           hr_utility.trace('lv_baladj_jurisdiction_code = '||
                             lv_baladj_jurisdiction_code);

           /*************************************************************
           ** Populate the PLSQL table emp_state_jd with this jd
           *************************************************************/
           if length(lv_baladj_jurisdiction_code) = 11 and
              substr(lv_baladj_jurisdiction_code, 4) = '000-0000' then
              ln_index := pay_ac_action_arch.emp_state_jd.count;
              pay_ac_action_arch.emp_state_jd(ln_index).emp_jd
                        := lv_baladj_jurisdiction_code;
           /*************************************************************
           ** Populate the PLSQL table emp_county_jd with this jd
           *************************************************************/
           elsif length(lv_baladj_jurisdiction_code) = 11 and
                 substr(lv_baladj_jurisdiction_code,8) = '0000' and
                 substr(lv_baladj_jurisdiction_code,4,3) <> '000' then
              ln_index := pay_ac_action_arch.emp_county_jd.count;
              pay_ac_action_arch.emp_county_jd(ln_index).emp_jd
                        := lv_baladj_jurisdiction_code;
           /*************************************************************
           ** Populate the PLSQL table emp_city_jd with this jd
           *************************************************************/
           elsif length(lv_baladj_jurisdiction_code) = 11 and
                 substr(lv_baladj_jurisdiction_code,8) <> '0000' then
              ln_index := pay_ac_action_arch.emp_city_jd.count;
              pay_ac_action_arch.emp_city_jd(ln_index).emp_jd := lv_baladj_jurisdiction_code;
           /*************************************************************
           ** Populate the PLSQL table emp_school_jd with this jd
           *************************************************************/
           elsif length(lv_baladj_jurisdiction_code) = 8 then
              if substr(lv_baladj_jurisdiction_code,1,2) = '39' then
                 lv_rr_sd_parent_jd := get_school_parent_jd(
                                          p_assignment_id => p_assignment_id
                                         ,p_school_jurisdiction => lv_baladj_jurisdiction_code
                                         ,p_start_date    => p_start_date
                                         ,p_end_date      => p_end_date);
              end if;

              ln_index := pay_ac_action_arch.emp_school_jd.count;
              pay_ac_action_arch.emp_school_jd(ln_index).emp_jd := lv_baladj_jurisdiction_code;
              pay_ac_action_arch.emp_school_jd(ln_index).emp_parent_jd := lv_rr_sd_parent_jd;
           end if;
        end loop;
        close c_get_baladj_jd;
        hr_utility.set_location(gv_package || lv_procedure_name, 50);

        /*****************************************************************
        ** Get Employee Resident Jurisdiction
        *****************************************************************/
        get_emp_residence(p_assignment_id      => p_assignment_id
                         ,p_end_date           => p_end_date
                         ,p_run_effective_date => p_run_effective_date
                         ,p_resident_state_jd  => lv_resident_state
                         ,p_resident_county_jd => lv_resident_county
                         ,p_resident_city_jd   => lv_resident_city);
        hr_utility.set_location(gv_package || lv_procedure_name, 60);
        hr_utility.trace('lv_resident_state = '  || lv_resident_state);
        hr_utility.trace('lv_resident_county = ' || lv_resident_county);
        hr_utility.trace('lv_resident_city = '   || lv_resident_city);

        /*****************************************************************
        ** Federal Information Archiving
        *****************************************************************/
        populate_federal_tax_balances(p_xfr_action_id     => p_xfr_action_id
                                     ,p_rqp_action_id     => ln_baladj_action_id
                                     ,p_action_type       => p_action_type);
        hr_utility.set_location(gv_package || lv_procedure_name, 70);

        /*****************************************************************
        ** State Information Archiving
        *****************************************************************/
        populate_state_tax_balances(
                      p_xfr_action_id     => p_xfr_action_id
                     ,p_rqp_action_id     => ln_baladj_action_id
                     ,p_action_type       => p_action_type
                     ,p_jurisdiction_tab  => pay_ac_action_arch.emp_state_jd);
        hr_utility.set_location(gv_package || lv_procedure_name, 80);

        /*****************************************************************
        ** County Information Archiving
        *****************************************************************/
        populate_county_tax_balances(
                      p_xfr_action_id     => p_xfr_action_id
                     ,p_rqp_action_id     => ln_baladj_action_id
                     ,p_resident_state    => lv_resident_state
                     ,p_resident_county   => lv_resident_county
                     ,p_resident_city     => lv_resident_city
                     ,p_action_type       => p_action_type
                     ,p_jurisdiction_tab  => pay_ac_action_arch.emp_county_jd);
        hr_utility.set_location(gv_package || lv_procedure_name, 90);

        /*****************************************************************
        ** City Information Archiving
        *****************************************************************/
        populate_city_tax_balances(
                      p_xfr_action_id     => p_xfr_action_id
                     ,p_rqp_action_id     => ln_baladj_action_id
                     ,p_action_type       => p_action_type
                     ,p_resident_state    => lv_resident_state
                     ,p_resident_county   => lv_resident_county
                     ,p_resident_city     => lv_resident_city
                     ,p_effective_date    => p_end_date
                     ,p_jurisdiction_tab  => pay_ac_action_arch.emp_city_jd);
        hr_utility.set_location(gv_package || lv_procedure_name, 100);

        /*****************************************************************
        ** School District Information Archiving
        *****************************************************************/
        populate_school_tax_balances(
                      p_xfr_action_id     => p_xfr_action_id
                     ,p_rqp_action_id     => ln_baladj_action_id
                     ,p_action_type       => p_action_type
                     ,p_jurisdiction_tab  => pay_ac_action_arch.emp_school_jd);
        hr_utility.set_location(gv_package || lv_procedure_name, 110);

        /*****************************************************************
        ** Initialize the PL/SQL tables for State, County, City and School
        *****************************************************************/
        pay_ac_action_arch.emp_state_jd.delete;
        pay_ac_action_arch.emp_city_jd.delete;
        pay_ac_action_arch.emp_county_jd.delete;
        pay_ac_action_arch.emp_school_jd.delete;
        hr_utility.set_location(gv_package || lv_procedure_name, 120);

      end loop;
      close c_get_emp_adjbal;
      hr_utility.set_location(gv_package || lv_procedure_name, 130);

      hr_utility.trace('Leaving populate_adj_tax_balances');

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_adj_tax_balances;


  /*********************************************************************
   Name      : update_employee_information
   Purpose   : This function updates the Employee Information which is
               archived by the global archive procedure.
               The only thing which is updated is employee name. The
               Global package archvies the full name for the employee.
               This procedure will update the name to
                    First Name[space]Middle Initial[.][space]Last Name
   Arguments : IN
                 p_assignment_action_id   number;
   Notes     :
  *********************************************************************/
  PROCEDURE update_employee_information(
                p_action_context_id in number
               ,p_assignment_id     in number)
  IS
   cursor c_get_archive_info(cp_action_context_id in number
                            ,cp_assignment_id     in number) is
     select action_information_id, effective_date,
            object_version_number
       from pay_action_information
      where action_context_id = cp_action_context_id
        and action_context_type = 'AAP'
        and assignment_id = cp_assignment_id
        and action_information_category = 'EMPLOYEE DETAILS';

   cursor c_get_employee_info(cp_assignment_id  in number
                             ,cp_effective_date in date) is
     select ltrim(rtrim(
            first_name || ' ' ||
            decode(nvl(length(ltrim(rtrim(middle_names))),0), 0, null,
                                   upper(substr(middle_names,1,1)) || '. ' ) ||
            pre_name_adjunct || last_name || ' '|| suffix))
       from per_all_people_f ppf
      where ppf.person_id =
                (select person_id from per_all_assignments_f paf
                  where assignment_id = cp_assignment_id
                    and cp_effective_date between paf.effective_start_date
                                              and paf.effective_end_date)
        and cp_effective_date between ppf.effective_start_date
                                  and ppf.effective_end_date;

    ln_action_information_id NUMBER;
    ld_effective_date        DATE;

    lv_employee_name         VARCHAR2(300);

    ln_ovn                   NUMBER;
    lv_procedure_name        VARCHAR2(200) := '.update_employee_information';
    lv_error_message         VARCHAR2(200);


  BEGIN
    hr_utility.trace('Action_Context_ID = ' || p_action_context_id);
    hr_utility.trace('Asg ID            = ' || p_assignment_id);
    open c_get_archive_info(p_action_context_id, p_assignment_id);
    loop
       fetch c_get_archive_info into ln_action_information_id,
                                     ld_effective_date,
                                     ln_ovn;
       if c_get_archive_info%notfound then
          exit;
       end if;

       hr_utility.trace('Action_info_id = ' || ln_action_information_id);
       hr_utility.trace('ld_eff_date    = ' || to_char(ld_effective_date, 'dd-mon-yyyy'));

       open c_get_employee_info(p_assignment_id, ld_effective_date);
       fetch c_get_employee_info into lv_employee_name;
       close c_get_employee_info;

       hr_utility.trace('lv_employee_name = *' || lv_employee_name ||'*');

       pay_action_information_api.update_action_information
           (p_action_information_id     =>  ln_action_information_id
           ,p_object_version_number     =>  ln_ovn
           ,p_action_information1       =>  lv_employee_name
           );

    end loop;
    close c_get_archive_info;

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END update_employee_information;


  /************************************************************
   Name      : get_employee_withholding_info
   Purpose   :
   Arguments :
   Notes     :
  ************************************************************/
  PROCEDURE get_employee_withholding_info(
                      p_assignment_id         in number
                     ,p_run_effective_date    in date
                     ,p_resident_jurisdiction in varchar2
                     )
  IS
    cursor c_emp_fed_info(cp_assignment_id      in number
                         ,cp_run_effective_date in date) is
       select fed.filing_status_code,
              decode(fed.fit_exempt,'Y','Exempt',hl.meaning),  --8433161
              fed.withholding_allowances,
              fed.fit_additional_tax,
              fed.fit_override_amount,
              fed.fit_override_rate
         from pay_us_emp_fed_tax_rules_f fed,
              hr_lookups hl
        where fed.assignment_id = cp_assignment_id
          and hl.lookup_code = fed.filing_status_code
          and hl.lookup_type = 'US_FIT_FILING_STATUS'
          and cp_run_effective_date between effective_start_date
                                        and effective_end_date;

    cursor c_get_asg_work_at_home (cp_assignment_id     in number
                                  ,p_run_effective_date in date) is
       select nvl(paf.work_at_home, 'N')
         from per_all_assignments_f paf
        where paf.assignment_id = cp_assignment_id
          and p_run_effective_date between paf.effective_start_date
                                       and paf.effective_end_date;

     cursor c_emp_state_info(cp_assignment_id     in number
                            ,cp_jurisdiction_code in varchar2
                            ,cp_effective_date in date) is
       select pts.time_in_state,
              pts.state_name,
              pts.jurisdiction_code,
              pts.filing_status_code,
              decode(pst.sit_exempt,'Y','Exempt',pts.meaning),  --8433161
              pts.withholding_allowances,
              pts.sit_additional_tax,
              pts.sit_override_amount,
              pts.sit_override_rate
         from pay_us_emp_time_in_state_v pts,
	          pay_us_emp_state_tax_rules_f pst --8433161
        where pts.assignment_id = cp_assignment_id
          and pts.jurisdiction_code like cp_jurisdiction_code
          and pst.jurisdiction_code = pts.jurisdiction_code --8832183  RLN
	      and pst.assignment_id = pts.assignment_id --8433161
	      and cp_effective_date between pst.effective_start_date
                                        and pst.effective_end_date -- 8804636 RLN
          and cp_effective_date between pts.effective_start_date
                                        and pts.effective_end_date; -- 8804636 RLN

    cursor c_fnd_session is
       select effective_date
         from fnd_sessions fs
        where session_id = userenv('sessionid');

    lv_fit_filing_status_code     VARCHAR2(30);
    lv_fit_filing_status          VARCHAR2(80);
    ln_fit_withholding_allowances NUMBER(3);
    ln_fit_additional_wa_amount   NUMBER(11,2);
    ln_fit_override_amount        NUMBER(11,2);
    ln_fit_override_rate          NUMBER(6,3);

    lv_asg_work_at_home           VARCHAR2(10);

    lv_time_in_state              VARCHAR2(50);
    lv_state_name                 VARCHAR2(50);
    lv_jurisdiction_code          VARCHAR2(11);
    lv_sit_filing_status_code     VARCHAR2(30);
    lv_sit_filing_status          VARCHAR2(80);
    ln_sit_withholding_allowances NUMBER(3);
    ln_sit_additional_wa_amount   NUMBER(11,2);
    ln_sit_override_amount        NUMBER(11,2);
    ln_sit_override_rate          NUMBER(6,3);


    ld_session_date    DATE;
    ln_index           NUMBER;

    lv_procedure_name  VARCHAR2(100) := '.get_employee_withholding_info';
    lv_error_message   VARCHAR2(200);


  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     open c_emp_fed_info(p_assignment_id,
                         p_run_effective_date);
     hr_utility.trace('Opened  c_emp_fed_info cursor of get_withholding_info');
     fetch c_emp_fed_info into lv_fit_filing_status_code,
                               lv_fit_filing_status,
                               ln_fit_withholding_allowances,
                               ln_fit_additional_wa_amount,
                               ln_fit_override_amount,
                               ln_fit_override_rate;
     if c_emp_fed_info%found then
        hr_utility.trace('Going to write get_withholding_info record for fed');

        ln_index := pay_ac_action_arch.lrr_act_tab.count;

        hr_utility.trace('ln_index in get_withholding_info proc is '
                || pay_ac_action_arch.lrr_act_tab.count);

        pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
               := 'US WITHHOLDINGS';
        pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
               := '00-000-0000';
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info4
               := 'Federal';
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info5
               := lv_fit_filing_status;
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
               := ln_fit_withholding_allowances;
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
               := fnd_number.number_to_canonical(
                               ln_fit_additional_wa_amount);
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
               := fnd_number.number_to_canonical(
                               ln_fit_override_amount);
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
               := ln_fit_override_rate;
     end if;
     close c_emp_fed_info;
     hr_utility.set_location(gv_package || lv_procedure_name, 30);


     open c_fnd_session;
     fetch c_fnd_session into ld_session_date;
     if c_fnd_session%notfound then
        insert into fnd_sessions (session_id, effective_date) values
        (userenv('sessionid'), p_run_effective_date);
     else
        if ld_session_date <> p_run_effective_date then
           update fnd_sessions
              set effective_date = p_run_effective_date
            where session_id = userenv('sessionid');
        end if;
     end if;
     close c_fnd_session;

     open c_get_asg_work_at_home(p_assignment_id
                                ,p_run_effective_date);
     fetch c_get_asg_work_at_home into lv_asg_work_at_home;
     close c_get_asg_work_at_home;

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     if lv_asg_work_at_home = 'Y' then
       open c_emp_state_info(p_assignment_id,
                              substr(p_resident_jurisdiction,1,2) || '-000-0000'
                              ,p_run_effective_date); -- 8804636 RLN
     else
        open c_emp_state_info(p_assignment_id, '%',p_run_effective_date); -- 8804636 RLN
     end if;

     loop
        fetch  c_emp_state_info into lv_time_in_state,
                                     lv_state_name,
                                     lv_jurisdiction_code,
                                     lv_sit_filing_status_code,
                                     lv_sit_filing_status,
                                     ln_sit_withholding_allowances,
                                     ln_sit_additional_wa_amount,
                                     ln_sit_override_amount,
                                     ln_sit_override_rate;

        if c_emp_state_info%notfound then
           hr_utility.set_location(gv_package || lv_procedure_name, 40);
           exit;
        end if;

        hr_utility.set_location(gv_package || lv_procedure_name, 50);
        if ((lv_time_in_state > 0) or
            (lv_time_in_state = 0 and
             substr(lv_jurisdiction_code, 1,2) = substr(p_resident_jurisdiction,1,2))) then

           ln_index := pay_ac_action_arch.lrr_act_tab.count;
           hr_utility.trace('ln_index = ' || ln_index);

           pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
               := 'US WITHHOLDINGS';
           pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
               := lv_jurisdiction_code;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info4
               := lv_state_name ;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info5
               := lv_sit_filing_status;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
               := ln_sit_withholding_allowances;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
               := fnd_number.number_to_canonical(
                               ln_sit_additional_wa_amount);
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
               := fnd_number.number_to_canonical(ln_sit_override_amount);
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
               := ln_sit_override_rate;
        end if;
     end loop;
     close c_emp_state_info;

     hr_utility.set_location(gv_package || lv_procedure_name, 100);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_employee_withholding_info;


  /************************************************************
   Name      : process_actions
   Purpose   :
   Arguments : p_rqp_action_id - For Child actions we pass the
                                 Action ID of Run/Quick Pay
                               - For Master we pass the Action ID
                                 of Pre Payment Process.
   Notes     :
  ************************************************************/
  PROCEDURE process_actions( p_xfr_payroll_action_id in number
                            ,p_xfr_action_id         in number
                            ,p_pre_pay_action_id     in number
                            ,p_payment_action_id     in number
                            ,p_rqp_action_id         in number
                            ,p_seperate_check_flag   in varchar2 default 'N'
                            ,p_sepcheck_run_type_id  in number
                            ,p_action_type           in varchar2
                            ,p_legislation_code      in varchar2
                            ,p_assignment_id         in number
                            ,p_payroll_id            in number
                            ,p_consolidation_set_id  in number
                            ,p_tax_unit_id           in number
                            ,p_curr_pymt_eff_date    in date
                            ,p_xfr_start_date        in date
                            ,p_xfr_end_date          in date
                            ,p_ppp_source_action_id  in number default null
                            ,p_archive_balance_info  in varchar2 default 'Y'
                            ,p_last_xfr_eff_date    out nocopy date
                            ,p_last_xfr_action_id   out nocopy number
                            )
  IS

    cursor c_ytd_aaid(cp_prepayment_action_id in number
                     ,cp_assignment_id   in number
                     ,cp_sepchk_run_type in number) is
      select paa.assignment_action_id
        from pay_assignment_actions paa,
             pay_action_interlocks pai,
             pay_payroll_actions   ppa
        where pai.locking_action_id =  cp_prepayment_action_id
          and paa.assignment_action_id = pai.locked_action_id
          and paa.assignment_id = cp_assignment_id
          and ppa.payroll_action_id = paa.payroll_action_id
          and nvl(paa.run_type_id,0) <> cp_sepchk_run_type
      order by paa.assignment_action_id desc;

    cursor c_time_period(cp_run_assignment_action in number) is
      select ptp.time_period_id,
--bug 7379102
--             ppa.date_earned,
               nvl(ppa.date_earned,ppa.effective_date),
--bug 7379102
             ppa.effective_date
       from pay_assignment_actions paa,
            pay_payroll_actions ppa,
            per_time_periods ptp
      where paa.assignment_action_id = cp_run_assignment_action
        and ppa.payroll_action_id = paa.payroll_action_id
        and ptp.payroll_id = ppa.payroll_id
--bug 7379102
--        and ppa.date_earned between ptp.start_date and ptp.end_date;
          and nvl(ppa.date_earned,ppa.effective_date) between ptp.start_date and ptp.end_date;
--bug 7379102

    cursor c_chk_act_type(cp_last_xfr_act_id number) is
      select substr(serial_number,1,1)
      from   pay_assignment_actions paa
      where  paa.assignment_action_id = cp_last_xfr_act_id;

    lv_pre_xfr_act_type       VARCHAR2(80);

    ln_run_action_id          NUMBER;
    ln_ytd_balcall_aaid       NUMBER;
    ld_run_date_earned        DATE;
    ld_run_effective_date     DATE;

    ld_last_xfr_eff_date      DATE;
    ln_last_xfr_action_id     NUMBER;
    ld_last_pymt_eff_date     DATE;
    ln_last_pymt_action_id    NUMBER;

    ln_time_period_id         NUMBER;
    lv_resident_jurisdiction  VARCHAR2(15);

    lv_resident_city          VARCHAR2(30);  -- Bug 3452149
    lv_resident_county        VARCHAR2(30);
    lv_resident_state         VARCHAR2(30);

    lv_procedure_name         VARCHAR2(100) := '.process_actions';
    lv_error_message          VARCHAR2(200);

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);
     /****************************************************************
     ** For Seperate Check we do the YTD balance calls with the Run
     ** Action ID. So, we do not need to get the max. action which is
     ** not seperate Check.
     ** Also, p_ppp_source_action_id is set to null as we want to get
     ** all records from pay_pre_payments where source_action_id is
     ** is null.
     ****************************************************************/
     ln_ytd_balcall_aaid := p_payment_action_id;
     if p_seperate_check_flag = 'N' and
        p_action_type in ('U', 'P') then
        hr_utility.set_location(gv_package || lv_procedure_name, 40);
        open c_ytd_aaid(p_rqp_action_id,
                        p_assignment_id,
                        p_sepcheck_run_type_id);
        fetch c_ytd_aaid into ln_ytd_balcall_aaid;
        if c_ytd_aaid%notfound then
           hr_utility.set_location(gv_package || lv_procedure_name, 50);
           hr_utility.raise_error;
        end if;
        close c_ytd_aaid;
     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 60);

     open c_time_period(p_payment_action_id);
     fetch c_time_period into ln_time_period_id,
                              ld_run_date_earned,
                              ld_run_effective_date;
     close c_time_period;

     hr_utility.set_location(gv_package || lv_procedure_name, 70);
     pay_ac_action_arch.get_last_xfr_info(
                       p_assignment_id        => p_assignment_id
                      ,p_curr_effective_date  => p_xfr_end_date
                      ,p_action_info_category => 'EMPLOYEE DETAILS'
                      ,p_xfr_action_id        => p_xfr_action_id
                      ,p_sepchk_flag          => p_seperate_check_flag
                      ,p_last_xfr_eff_date    => ld_last_xfr_eff_date
                      ,p_last_xfr_action_id   => ln_last_xfr_action_id
                      ,p_arch_bal_info	      => p_archive_balance_info
		      ,p_legislation_code     => p_legislation_code
                      );

     if ld_last_xfr_eff_date is not null then
        if gv_act_param_val is not null  then
           if  gv_act_param_val = 'Y'
           then
              ld_last_xfr_eff_date := NULL;
           elsif fnd_date.canonical_to_date(gv_act_param_val) = p_xfr_end_date
           then
              ld_last_xfr_eff_date := NULL;
           end if;
        end if;
     end if;

     -- This is no longer going to be called as ln_last_xfr_action_id
     -- will never be a archive for balance adjustment
     if ld_last_xfr_eff_date is not null then
        open c_chk_act_type(ln_last_xfr_action_id);
        fetch c_chk_act_type into lv_pre_xfr_act_type;
        close c_chk_act_type;

        if lv_pre_xfr_act_type = 'B' then
           ld_last_xfr_eff_date := NULL;
        end if;
     end if;

     p_last_xfr_eff_date  := ld_last_xfr_eff_date;
     p_last_xfr_action_id := ln_last_xfr_action_id;

     hr_utility.trace('p_xfr_payroll_action_id= '|| p_xfr_payroll_action_id);
     hr_utility.trace('p_xfr_action_id       = ' || p_xfr_action_id);
     hr_utility.trace('p_seperate_check_flag = ' || p_seperate_check_flag);
     hr_utility.trace('p_action_type         = ' || p_action_type);
     hr_utility.trace('p_pre_pay_action_id   = ' || p_pre_pay_action_id);
     hr_utility.trace('p_payment_action_id   = ' || p_payment_action_id);
     hr_utility.trace('p_rqp_action_id       = ' || p_rqp_action_id);
     hr_utility.trace('p_sepcheck_run_type_id = '|| p_sepcheck_run_type_id);
     hr_utility.trace('p_assignment_id       = ' || p_assignment_id);
     hr_utility.trace('p_xfr_start_date      = ' || p_xfr_start_date );
     hr_utility.trace('p_xfr_end_date        = ' || p_xfr_end_date );
     hr_utility.trace('p_curr_pymt_eff_date  = ' || p_curr_pymt_eff_date);
     hr_utility.trace('ld_run_effective_date = ' || ld_run_effective_date);
     hr_utility.trace('ln_ytd_balcall_aaid   = ' || ln_ytd_balcall_aaid);
     hr_utility.trace('p_ppp_source_action_id = '|| p_ppp_source_action_id);
     hr_utility.trace('ld_run_date_earned    = ' || ld_run_date_earned);
     hr_utility.trace('ld_last_xfr_eff_date  = ' || ld_last_xfr_eff_date);
     hr_utility.trace('ln_last_xfr_action_id = ' || ln_last_xfr_action_id);

     pay_ac_action_arch.initialization_process;

     /*********************************************************************
     ** If p_archive_balance_info is not Y then it mean that the assignment
     ** does not have any Gross or Payments in the Run. In this case, we
     ** only archive the employee level information and also move forward
     ** elements from previous archive.
     ** The only issue with the approach is if the first archiver run
     ** for the employee has no Gross or Payments Balance. In this case
     ** any non-recurring processed from 1st Jan till date willl not be
     ** archived.
     *********************************************************************/
     if p_archive_balance_info = 'Y' then
        populate_puv_tax_balances(
               p_xfr_action_id         => p_xfr_action_id
              ,p_assignment_id         => p_assignment_id
              ,p_pymt_balcall_aaid     => p_payment_action_id
              ,p_ytd_balcall_aaid      => ln_ytd_balcall_aaid
              ,p_tax_unit_id           => p_tax_unit_id
              ,p_action_type           => p_action_type
              ,p_rqp_action_id         => p_rqp_action_id
              ,p_start_date            => p_xfr_start_date
              ,p_end_date              => p_xfr_end_date
              ,p_run_effective_date    => ld_run_effective_date
              ,p_sepchk_run_type_id    => p_sepcheck_run_type_id
              ,p_sepchk_flag           => p_seperate_check_flag
              ,p_resident_jurisdiction => lv_resident_jurisdiction
              );
        hr_utility.set_location(gv_package || lv_procedure_name, 90);

        /******************************************************************
        ** For seperate check cases, the ld_last_xfr_eff_date is never null
        ** as the master is always processed before the child actions. The
        ** master data is already in the archive table and as it is in the
        ** same session the process will always go to the else statement
        ******************************************************************/
        if ld_last_xfr_eff_date is null then
           hr_utility.set_location(gv_package || lv_procedure_name, 100);
           pay_ac_action_arch.first_time_process(
                  p_xfr_action_id       => p_xfr_action_id
                 ,p_assignment_id       => p_assignment_id
                 ,p_curr_pymt_action_id => p_rqp_action_id
                 ,p_curr_pymt_eff_date  => p_curr_pymt_eff_date
                 ,p_curr_eff_date       => p_xfr_end_date
                 ,p_tax_unit_id         => p_tax_unit_id
                 ,p_pymt_balcall_aaid   => p_payment_action_id
                 ,p_ytd_balcall_aaid    => ln_ytd_balcall_aaid
                 ,p_sepchk_run_type_id  => p_sepcheck_run_type_id
                 ,p_sepchk_flag         => p_seperate_check_flag
                 ,p_legislation_code    => p_legislation_code
                 );

        else
           hr_utility.set_location(gv_package || lv_procedure_name, 110);
           pay_ac_action_arch.get_current_elements(
                  p_xfr_action_id       => p_xfr_action_id
                 ,p_curr_pymt_action_id => p_rqp_action_id
                 ,p_curr_pymt_eff_date  => p_curr_pymt_eff_date
                 ,p_assignment_id       => p_assignment_id
                 ,p_tax_unit_id         => p_tax_unit_id
                 ,p_pymt_balcall_aaid   => p_payment_action_id
                 ,p_ytd_balcall_aaid    => ln_ytd_balcall_aaid
                 ,p_sepchk_run_type_id  => p_sepcheck_run_type_id
                 ,p_sepchk_flag         => p_seperate_check_flag
                 ,p_legislation_code    => p_legislation_code);

        end if;

        hr_utility.set_location(gv_package || lv_procedure_name, 120);

     else

        /*****************************************************************
        ** Get Employee Resident Jurisdiction seperately as we do not
        ** call populate_puv_tax_balances which returns
        ** lv_resident_jurisdiction. This value is used when archiving
        ** W4 Information.
        *****************************************************************/
        hr_utility.set_location(gv_package || lv_procedure_name, 130);
        get_emp_residence(p_assignment_id      => p_assignment_id
                         ,p_end_date           => p_xfr_end_date
                         ,p_run_effective_date => ld_run_effective_date
                         ,p_resident_state_jd  => lv_resident_state
                         ,p_resident_county_jd => lv_resident_county
                         ,p_resident_city_jd   => lv_resident_city);

        lv_resident_jurisdiction := lv_resident_state  || '-' ||
                                    lv_resident_county || '-' ||
                                    lv_resident_city;

     end if; /* p_archive_balance_info = 'Y' */

     hr_utility.set_location(gv_package || lv_procedure_name, 135);
     pay_ac_action_arch.get_xfr_elements(
                  p_xfr_action_id      => p_xfr_action_id
                 ,p_last_xfr_action_id => ln_last_xfr_action_id
                 ,p_ytd_balcall_aaid   => ln_ytd_balcall_aaid
                 ,p_pymt_eff_date      => p_curr_pymt_eff_date
                 ,p_legislation_code   => p_legislation_code
                 ,p_sepchk_flag        => p_seperate_check_flag
                 ,p_assignment_id      => p_assignment_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 140);
     pay_ac_action_arch.get_last_pymt_info(
                  p_assignment_id       => p_assignment_id
                 ,p_curr_pymt_eff_date  => p_curr_pymt_eff_date
                 ,p_last_pymt_eff_date  => ld_last_pymt_eff_date
                 ,p_last_pymt_action_id => ln_last_pymt_action_id);

     if ld_last_xfr_eff_date <> ld_last_pymt_eff_date then
        hr_utility.set_location(gv_package || lv_procedure_name, 145);
        pay_ac_action_arch.get_missing_xfr_info(
                  p_xfr_action_id       => p_xfr_action_id
                 ,p_tax_unit_id         => p_tax_unit_id
                 ,p_assignment_id       => p_assignment_id
                 ,p_last_pymt_action_id => ln_last_pymt_action_id
                 ,p_last_pymt_eff_date  => ld_last_pymt_eff_date
                 ,p_last_xfr_eff_date   => ld_last_xfr_eff_date
                 ,p_ytd_balcall_aaid    => ln_ytd_balcall_aaid
                 ,p_pymt_eff_date       => p_curr_pymt_eff_date
                 ,p_legislation_code    => p_legislation_code);
     end if;


     hr_utility.set_location(gv_package || lv_procedure_name, 155);
     pay_emp_action_arch.get_personal_information(
                  p_payroll_action_id    => p_xfr_payroll_action_id
                 ,p_assactid             => p_xfr_action_id
                 ,p_assignment_id        => p_assignment_id
                 ,p_curr_pymt_ass_act_id => p_pre_pay_action_id
                 ,p_curr_eff_date        => p_xfr_end_date
                 ,p_date_earned          => ld_run_date_earned
                 ,p_curr_pymt_eff_date   => p_curr_pymt_eff_date
                 ,p_tax_unit_id          => p_tax_unit_id
                 ,p_time_period_id       => ln_time_period_id
                 ,p_ppp_source_action_id => p_ppp_source_action_id
                 ,p_run_action_id        => p_payment_action_id
                 ,p_ytd_balcall_aaid     => ln_ytd_balcall_aaid
                  );

     hr_utility.set_location(gv_package || lv_procedure_name, 160);
     get_employee_withholding_info(
                  p_assignment_id         => p_assignment_id
                 ,p_run_effective_date    => ld_run_effective_date
                 ,p_resident_jurisdiction => lv_resident_jurisdiction);

     if p_seperate_check_flag = 'N' then
        hr_utility.set_location(gv_package || lv_procedure_name, 170);
        -- Archive element processed in balance adjustment. This only
        -- needs to be done for master action as once the element is
        -- in archive, it will be carried forward.
        pay_ac_action_arch.process_baladj_elements(
                  p_assignment_id        => p_assignment_id
                 ,p_xfr_action_id        => p_xfr_action_id
                 ,p_last_xfr_action_id   => ln_last_xfr_action_id
                 ,p_curr_pymt_action_id  => p_rqp_action_id
                 ,p_curr_pymt_eff_date   => p_curr_pymt_eff_date
                 ,p_ytd_balcall_aaid     => ln_ytd_balcall_aaid
                 ,p_sepchk_flag          => p_seperate_check_flag
                 ,p_sepchk_run_type_id   => p_sepcheck_run_type_id
                 ,p_payroll_id           => p_payroll_id
                 ,p_consolidation_set_id => p_consolidation_set_id
                 ,p_legislation_code     => p_legislation_code
                 ,p_tax_unit_id          => p_tax_unit_id);

        hr_utility.set_location(gv_package || lv_procedure_name, 175);

        open c_ytd_aaid(p_rqp_action_id,
                        p_assignment_id,
                        p_sepcheck_run_type_id);
        loop
           fetch c_ytd_aaid into ln_run_action_id;
           if c_ytd_aaid%notfound then
              hr_utility.set_location(gv_package || lv_procedure_name, 180);
              exit;
           end if;

           hr_utility.set_location(gv_package || lv_procedure_name, 190);
           populate_emp_hours_by_rate(
                  p_action_context_id  => p_xfr_action_id
                 ,p_assignment_id      => p_assignment_id
                 ,p_run_action_id      => ln_run_action_id);

        end loop;
        close c_ytd_aaid;
     else
        hr_utility.set_location(gv_package || lv_procedure_name, 200);
        populate_emp_hours_by_rate(
                  p_action_context_id  => p_xfr_action_id
                 ,p_assignment_id      => p_assignment_id
                 ,p_run_action_id      => p_payment_action_id);
     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 205);
     pay_ac_action_arch.populate_summary(
                  p_xfr_action_id => p_xfr_action_id);
     change_processing_priority;

     hr_utility.set_location(gv_package || lv_procedure_name, 210);
     pay_emp_action_arch.insert_rows_thro_api_process(
                  p_action_context_id  => p_xfr_action_id
                 ,p_action_context_type=> 'AAP'
                 ,p_assignment_id      => p_assignment_id
                 ,p_tax_unit_id        => p_tax_unit_id
                 ,p_curr_pymt_eff_date => p_curr_pymt_eff_date
                 ,p_tab_rec_data       => pay_ac_action_arch.lrr_act_tab
                 );

     hr_utility.set_location(gv_package || lv_procedure_name, 220);
     update_employee_information(
                  p_action_context_id  => p_xfr_action_id
                 ,p_assignment_id      => p_assignment_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 250);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END process_actions;

  /************************************************************
   Name      : action_archive_data
   Purpose   : This procedure Archives data which are used in
               Tax Remittance Archiver, Payslip, Check Writer,
               Deposit Advice modules.
   Arguments :
   Notes     :
  ************************************************************/
  PROCEDURE action_archive_data(p_xfr_action_id  in number
                               ,p_effective_date in date)
  IS

    cursor c_xfr_info (cp_assignment_action in number) is
      select paa.payroll_action_id,
             paa.assignment_action_id,
             paa.assignment_id,
             paa.tax_unit_id,
             paa.serial_number,
             paa.chunk_number
        from pay_assignment_actions paa
       where paa.assignment_action_id = cp_assignment_action;

    cursor c_legislation (cp_business_group in number) is
      select org_information9
        from hr_organization_information
       where org_information_context = 'Business Group Information'
         and organization_id = cp_business_group;

    cursor c_sepchk_ryn_type is
      select prt.run_type_id
       from pay_run_types_f prt
      where prt.shortname = 'SEPCHECK'
        and prt.legislation_code = 'US';

    cursor c_assignment_run (cp_prepayment_action_id in number) is
      select distinct paa.assignment_id
        from pay_action_interlocks pai,
             pay_assignment_actions paa,
             pay_payroll_actions ppa
       where pai.locking_action_id = cp_prepayment_action_id
         and paa.assignment_action_id = pai.locked_action_id
         and ppa.payroll_action_id = paa.payroll_action_id
         and ppa.action_type in ('R', 'Q', 'B')
         and ((ppa.run_type_id is null and paa.source_action_id is null) or
              (ppa.run_type_id is not null and paa.source_action_id is not null))
         and paa.action_status = 'C';

    cursor c_master_run_action(
                      cp_prepayment_action_id in number,
                      cp_assignment_id        in number) is
      select paa.assignment_action_id, paa.payroll_action_id,
             ppa.action_type
        from pay_payroll_actions ppa,
             pay_assignment_actions paa,
             pay_action_interlocks pai
        where pai.locking_action_id =  cp_prepayment_action_id
          and pai.locked_action_id = paa.assignment_action_id
          and paa.assignment_id = cp_assignment_id
          and paa.source_action_id is null
          and ppa.payroll_action_id = paa.payroll_action_id
        order by paa.assignment_action_id desc;

    cursor c_pymt_eff_date(cp_prepayment_action_id in number) is
      select ppa.effective_date
        from pay_payroll_actions ppa,
             pay_assignment_actions paa
       where ppa.payroll_action_id = paa.payroll_action_id
         and paa.assignment_action_id = cp_prepayment_action_id;

    cursor c_check_pay_action( cp_payroll_action_id in number) is
      select count(*)
        from pay_action_information
       where action_context_id = cp_payroll_action_id
         and action_context_type = 'PA';

  cursor c_payment_info(cp_prepay_action_id number) is
    select distinct
           assignment_id
          ,tax_unit_id
          ,nvl(source_action_id,-999)
          ,assignment_action_id
    from  pay_payment_information_v
    where assignment_action_id = cp_prepay_action_id
    order by 3,1,2;

  cursor c_run_aa_id(cp_pp_asg_act_id number
                    ,cp_assignment_id number
                    ,cp_tax_unit_id   number) is
    select paa.assignment_action_id
          ,paa.source_action_id
      from pay_assignment_actions paa
          ,pay_action_interlocks pai
     where pai.locking_action_id    = cp_pp_asg_act_id
       and paa.assignment_action_id = pai.locked_action_id
       and paa.assignment_id        = cp_assignment_id
       and paa.tax_unit_id          = cp_tax_unit_id
       and paa.source_action_id is not null
       and not exists ( select 1
                          from pay_run_types_f prt
                         where prt.legislation_code = 'US'
                           and prt.run_type_id = paa.run_type_id
                           and prt.run_method in ('C', 'S'))
    order by paa.action_sequence desc;

   cursor c_get_prepay_aaid_for_sepchk( cp_asg_act_id number,
                                        cp_source_act_id number ) is
     select ppp.assignment_action_id
     from   pay_assignment_actions paa
           ,pay_pre_payments ppp
     where  ( paa.assignment_action_id = cp_asg_act_id OR
              paa.source_action_id     = cp_asg_act_id )
     and    ppp.assignment_action_id = paa.assignment_action_id
     and    ppp.source_action_id     = cp_source_act_id;


    /* Following cursor is changed for performance issue Bug# 7418142 */

    cursor c_get_unproc_asg(cp_assignment_id    in number,
                            cp_effective_date   in date,
                            cp_payroll_id       in number,
                            cp_xfr_action_id    in number,
                            cp_prepay_action_id in number) is
        select /*+ ORDERED */
           paf1.assignment_id,
           paa.assignment_action_id
         from  per_all_assignments_f paf1
              ,pay_assignment_actions paa
              ,pay_payroll_actions ppa
        where paf1.person_id = (select /*+ PUSH_SUBQ */ person_id
                        from per_all_assignments_f START_ASS
                        where START_ASS.assignment_id = cp_assignment_id
                        and rownum = 1)
          and paf1.effective_end_date >= trunc(cp_effective_date,'Y')
          and paf1.effective_start_date <= cp_effective_date
          and paa.assignment_id = paf1.assignment_id
          and paa.payroll_action_id = ppa.payroll_action_id
          and ppa.payroll_id = cp_payroll_id
          and ppa.action_type in ('Q', 'R', 'I','B')
          and not exists (select 'x'
                            from pay_action_information pai
                           where pai.action_context_id = cp_xfr_action_id
                             and pai.assignment_id = paf1.assignment_id)
          and not exists (select 1
                           from pay_payment_information_v ppi
                          where ppi.assignment_action_id = cp_prepay_action_id
                            and ppi.assignment_id = paf1.assignment_id
                            and ppi.source_action_id is null)
       order by paf1.assignment_id,
                paa.action_sequence desc;



    cursor c_prev_run_information(cp_assignment_id        in number
                                 ,cp_xfr_action_id        in number
                                 ,cp_effective_date       in date) is
      select max(pai.effective_date)
        from pay_action_information pai
       where pai.action_context_type = 'AAP'
         and pai.assignment_id = cp_assignment_id
         and pai.action_information_category in ('AC EARNINGS', 'AC DEDUCTIONS')
         and pai.action_context_id <> cp_xfr_action_id
         and pai.effective_date <= cp_effective_date;

  cursor c_run_aa_id_bal_adj(cp_pp_asg_act_id number
                    ,cp_assignment_id number
                    ,cp_tax_unit_id   number) is
    select paa.assignment_action_id
          ,paa.source_action_id
    from   pay_assignment_actions paa
          ,pay_action_interlocks pai
    where  pai.locking_action_id    = cp_pp_asg_act_id
    and    paa.assignment_action_id = pai.locked_action_id
    and    paa.assignment_id        = cp_assignment_id
    and    paa.tax_unit_id          = cp_tax_unit_id
    order by paa.action_sequence desc;

  cursor c_all_runs(cp_pp_asg_act_id   in number
                   ,cp_assignment_id   in number
                   ,cp_tax_unit_id     in number
                   ,cp_sepchk_run_type in number) is
    select paa.assignment_action_id
      from pay_assignment_actions paa,
           pay_action_interlocks pai
      where pai.locking_action_id = cp_pp_asg_act_id
        and paa.assignment_action_id = pai.locked_action_id
        and paa.assignment_id = cp_assignment_id
        and paa.tax_unit_id = cp_tax_unit_id
        and nvl(paa.run_type_id,0) <> cp_sepchk_run_type
        and not exists ( select 1
                         from   pay_run_types_f prt
                         where  prt.legislation_code = 'US'
                         and    prt.run_type_id = nvl(paa.run_type_id,0)
                         and    prt.run_method  = 'C' );

    ld_curr_pymt_eff_date     DATE;
    ln_sepchk_run_type_id     NUMBER;
    lv_legislation_code       VARCHAR2(2);

    ln_xfr_master_action_id   NUMBER;

    ln_tax_unit_id            NUMBER;
    ln_xfr_payroll_action_id  NUMBER; /* of current xfr */
    ln_xfr_assignment_id      NUMBER; -- Bug 3452149
    ln_assignment_id          NUMBER;
    ln_chunk_number           NUMBER;

    lv_xfr_master_serial_number  VARCHAR2(30);
    lv_master_action_type     VARCHAR2(1);
    lv_master_sepcheck_flag   VARCHAR2(1);
    ln_asg_action_id          NUMBER;

    ln_master_run_action_id   NUMBER;
    ln_master_run_pact_id     NUMBER;
    lv_master_run_action_type VARCHAR2(1);

    ln_pymt_balcall_aaid      NUMBER;
    ln_pay_action_count       NUMBER;

    ld_start_date            DATE;
    ld_end_date              DATE;
    ln_business_group_id     NUMBER;
    ln_cons_set_id           NUMBER;
    ln_payroll_id            NUMBER;

    lv_resident_jurisdiction VARCHAR2(30);

    lv_procedure_name        VARCHAR2(100) := '.action_archive_data';
    lv_error_message         VARCHAR2(200);
    ln_step                  NUMBER;

    ln_np_asg_id             NUMBER;
    ln_np_asg_action_id      NUMBER;
    ln_np_prev_asg_id        NUMBER := '-1';
    ld_np_last_xfr_eff_date  DATE;

    ln_source_action_id      NUMBER;
    ln_child_xfr_action_id   NUMBER;
    ln_run_aa_id             NUMBER;
    ln_run_source_action_id  NUMBER;
    ln_rqp_action_id         NUMBER;
    ln_ppp_source_action_id  NUMBER;
    ln_master_run_aa_id      NUMBER;
    ln_earnings              NUMBER;
    lv_serial_number         VARCHAR2(30);

    ln_run_qp_found          NUMBER;
    ln_all_run_asg_act_id    NUMBER;

    lv_archive_balance_info  VARCHAR2(1) := 'Y';  -- Bug 3452149
    ld_last_xfr_eff_date     DATE;
    ln_last_xfr_action_id    NUMBER;

  BEGIN
     pay_emp_action_arch.gv_error_message := NULL;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;
     open c_xfr_info (p_xfr_action_id);
     fetch c_xfr_info into ln_xfr_payroll_action_id,
                           ln_xfr_master_action_id,
                           ln_xfr_assignment_id,
                           ln_tax_unit_id,
                           lv_xfr_master_serial_number,
                           ln_chunk_number;
     close c_xfr_info;

     ln_step := 2;
     get_payroll_action_info(p_payroll_action_id => ln_xfr_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_cons_set_id       => ln_cons_set_id
                            ,p_payroll_id        => ln_payroll_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 15);

     ln_step := 205;
     pay_emp_action_arch.gv_multi_payroll_pymt
          := pay_emp_action_arch.get_multi_assignment_flag(
                              p_payroll_id       => ln_payroll_id
                             ,p_effective_date   => ld_end_date);

     hr_utility.trace('pay_emp_action_arch.gv_multi_payroll_pymt = ' ||
                       pay_emp_action_arch.gv_multi_payroll_pymt);

     ln_step := 3;
     open c_legislation (ln_business_group_id);
     fetch c_legislation into lv_legislation_code ;
     if c_legislation%notfound then
        hr_utility.trace('Business Group for Interface Process Not Found');
        hr_utility.raise_error;
     end if;
     close c_legislation;
     hr_utility.trace('lv_legislation_code '||lv_legislation_code);

     ln_step := 4;
     open c_sepchk_ryn_type;
     fetch  c_sepchk_ryn_type into ln_sepchk_run_type_id;
     if c_sepchk_ryn_type%notfound then
        hr_utility.set_location(gv_package || lv_procedure_name, 20);
        hr_utility.raise_error;
     end if;
     close c_sepchk_ryn_type;

     -- process the master_action
     lv_master_action_type   := substr(lv_xfr_master_serial_number,1,1);
     -- Always N for Master Assignment Action
     lv_master_sepcheck_flag := substr(lv_xfr_master_serial_number,2,1);
     -- Assignment Action of Quick Pay Pre Payment, Pre Payment, Reversal
     ln_asg_action_id := substr(lv_xfr_master_serial_number,3);

     ln_step := 5;
     open c_pymt_eff_date(ln_asg_action_id);
     fetch c_pymt_eff_date into ld_curr_pymt_eff_date;
     if c_pymt_eff_date%notfound then
        hr_utility.trace('PayrollAction for InterfaceProcess NotFound');
        hr_utility.raise_error;
     end if;
     close c_pymt_eff_date;

     hr_utility.trace('End Date=' || to_char(ld_end_date, 'dd-mon-yyyy'));
     hr_utility.trace('Start Date='||to_char(ld_start_date, 'dd-mon-yyyy'));
     hr_utility.trace('Business Group Id='||to_char(ln_business_group_id));
     hr_utility.trace('Serial Number='||lv_xfr_master_serial_number);
     hr_utility.trace('ln_xfr_payroll_action_id ='||to_char(ln_xfr_payroll_action_id));

     ln_step := 6;
     if lv_master_action_type in ( 'P','U') then
        /************************************************************
        ** For Master Pre Payment Action get the distinct
        ** Assignment_ID's and archive the data seperately for
        ** all the assigments.
        *************************************************************/
        ln_step := 7;
        open c_payment_info(ln_asg_action_id);
        loop

           fetch c_payment_info into ln_assignment_id
                                    ,ln_tax_unit_id
                                    ,ln_source_action_id
                                    ,ln_asg_action_id;
           exit when c_payment_info%notfound;

           hr_utility.trace('archive_data:payment_info:ln_asg_action_id    = ' ||
                            ln_asg_action_id );
           hr_utility.trace('archive_data:payment_info:ln_assignment_id    = ' ||
                           ln_assignment_id );
           hr_utility.trace('archive_data:payment_info:ln_tax_unit_id      = ' ||
                           ln_tax_unit_id );
           hr_utility.trace('archive_data:payment_info:ln_source_action_id = ' ||
                           ln_source_action_id );

           ln_step := 8;

           if ln_source_action_id = -999 then
              ln_step := 9;
              lv_master_sepcheck_flag := 'N';
              ln_master_run_aa_id     := NULL;
              ln_master_run_aa_id     := NULL;
              ln_run_qp_found         := 0;


              /********************************************************
              ** Getting Run Assignment Action Id for normal cheque.
              ********************************************************/
              open c_run_aa_id(ln_asg_action_id
                              ,ln_assignment_id
                              ,ln_tax_unit_id);
              fetch c_run_aa_id into ln_run_aa_id, ln_run_source_action_id;
              if c_run_aa_id%found then
                 ln_run_qp_found := 1;
              end if;
              close c_run_aa_id;

              ln_step := 10;
              hr_utility.trace('GRE ln_run_aa_id = ' || ln_run_aa_id);

             if ln_run_source_action_id is not null then
                ln_master_run_aa_id   := ln_run_source_action_id; -- Normal Chk
             else
                if ln_run_qp_found = 0 then
                   /* Balance Adjustment or Reversal */
                   open  c_run_aa_id_bal_adj(ln_asg_action_id
                                            ,ln_assignment_id
                                            ,ln_tax_unit_id);
                   fetch c_run_aa_id_bal_adj into ln_run_aa_id,
                                                  ln_run_source_action_id;
                   close c_run_aa_id_bal_adj;
                   ln_master_run_aa_id   := ln_asg_action_id;
                else
                   ln_master_run_aa_id   := ln_run_aa_id; -- Normal Chk
                end if;
             end if;

             ln_rqp_action_id         := ln_asg_action_id;
             ln_ppp_source_action_id  := NULL;

           else

             ln_step := 11;
             lv_master_sepcheck_flag  := 'Y';
             ln_master_run_aa_id      := ln_source_action_id; -- Sep Chk
             ln_rqp_action_id         := ln_source_action_id; -- Sep Chk
             ln_ppp_source_action_id  := ln_source_action_id; -- Sep Chk
             ln_run_aa_id             := ln_source_action_id; -- Sep Chk

           end if;

           if ln_source_action_id <> -999 then

              open c_get_prepay_aaid_for_sepchk(ln_asg_action_id
                                               ,ln_source_action_id);
              fetch c_get_prepay_aaid_for_sepchk into ln_asg_action_id;
              close c_get_prepay_aaid_for_sepchk;

              ln_step := 12;
              select pay_assignment_actions_s.nextval
                into ln_child_xfr_action_id
                from dual;

              hr_utility.set_location(gv_package || lv_procedure_name, 30);

              -- insert into pay_assignment_actions.
              ln_step := 13;
              hr_nonrun_asact.insact(ln_child_xfr_action_id,
                                     ln_assignment_id,
                                     ln_xfr_payroll_action_id,
                                     ln_chunk_number,
                                     ln_tax_unit_id,
                                     null,
                                     'C',
                                     p_xfr_action_id);

              hr_utility.set_location(gv_package || lv_procedure_name, 40);

              hr_utility.trace('GRE Locking Action = ' ||ln_child_xfr_action_id);
              hr_utility.trace('GRE Locked Action = '  ||ln_asg_action_id);

              -- insert an interlock to this action
              ln_step := 14;
              hr_nonrun_asact.insint(ln_child_xfr_action_id,
                                     ln_asg_action_id);

              ln_step := 15;

              lv_serial_number := lv_master_action_type ||
                                  lv_master_sepcheck_flag || ln_source_action_id;

              ln_step := 16;

              update pay_assignment_actions
                 set serial_number = lv_serial_number
               where assignment_action_id = ln_child_xfr_action_id;

              hr_utility.trace('Processing Child action ' ||
                                p_xfr_action_id);

           else
              ln_step := 17;
              ln_child_xfr_action_id := p_xfr_action_id;
           end if;

           ln_earnings := 0;
           ln_step := 18;

           if gn_gross_earn_def_bal_id + gn_payments_def_bal_id  <> 0 then

              if ln_source_action_id = -999 then

                 ln_step := 19;

                 open c_all_runs(ln_asg_action_id,
                                 ln_assignment_id,
                                 ln_tax_unit_id,
                                 ln_sepchk_run_type_id);
                 loop
                    fetch c_all_runs into ln_all_run_asg_act_id;
                    if c_all_runs%notfound then
                       exit;
                    end if;

                    ln_earnings := nvl(pay_balance_pkg.get_value(
                                       gn_gross_earn_def_bal_id,
                                       ln_all_run_asg_act_id),0);

                    /**************************************************
                    ** For Non-payroll Payments element is processed
                    ** alone, the gross earning balance returns zero.
                    ** In this case check payment.
                    **************************************************/

                   if ln_earnings = 0 then

                      ln_step := 20;
                      ln_earnings := nvl(pay_balance_pkg.get_value(
                                         gn_payments_def_bal_id,
                                         ln_all_run_asg_act_id),0);

                   end if;

                   if ln_earnings <> 0 then
                      exit;
                   end if;

                end loop;
                close c_all_runs;
             else
                ln_earnings := 1;  -- For Separate Check
             end if;

           end if;


           ln_step := 21;
           /*  Bug 3452149 */
           if ln_earnings = 0 and
              pay_emp_action_arch.gv_multi_payroll_pymt = 'Y' then
              ln_earnings := 1;
              lv_archive_balance_info := 'N';
           else
              lv_archive_balance_info := 'Y';
           end if;

           /*  Bug 3452149 */
           hr_utility.trace('archive_data:payment_info: ln_earnings = ' ||
                            ln_earnings);
           hr_utility.trace('archive_data:payment_info: lv_archive_balance_info = ' ||
                            lv_archive_balance_info);
           if ln_earnings <> 0 then
              process_actions(p_xfr_payroll_action_id => ln_xfr_payroll_action_id
                             ,p_xfr_action_id         => ln_child_xfr_action_id
                             ,p_pre_pay_action_id     => ln_asg_action_id
                             ,p_payment_action_id     => ln_master_run_aa_id
                             ,p_rqp_action_id         => ln_rqp_action_id
                             ,p_seperate_check_flag   => lv_master_sepcheck_flag
                             ,p_sepcheck_run_type_id  => ln_sepchk_run_type_id
                             ,p_action_type           => lv_master_action_type
                             ,p_legislation_code      => lv_legislation_code
                             ,p_assignment_id         => ln_assignment_id
                             ,p_payroll_id            => ln_payroll_id
                             ,p_consolidation_set_id  => ln_cons_set_id
                             ,p_tax_unit_id           => ln_tax_unit_id
                             ,p_curr_pymt_eff_date    => ld_curr_pymt_eff_date
                             ,p_xfr_start_date        => ld_start_date
                             ,p_xfr_end_date          => ld_end_date
                             ,p_ppp_source_action_id  => ln_ppp_source_action_id
                             ,p_archive_balance_info  => lv_archive_balance_info
                             ,p_last_xfr_eff_date     => ld_last_xfr_eff_date
                             ,p_last_xfr_action_id    => ln_last_xfr_action_id
                             );

              if pay_emp_action_arch.gv_multi_payroll_pymt = 'Y' and
                 nvl(lv_master_sepcheck_flag, 'N') = 'N' and
                 ld_last_xfr_eff_date is not null then
                 hr_utility.trace('---------Check for un-processed asignments --------');
                 hr_utility.trace('ln_assignment_id = '||ln_assignment_id);
                 hr_utility.trace('ld_curr_pymt_eff_date = '||ld_curr_pymt_eff_date);
                 hr_utility.trace('ln_payroll_id = '||ln_payroll_id);
                 hr_utility.trace('p_xfr_action_id = '||p_xfr_action_id);

                 /***************************************************************
                  Find out if any assignments have been  un-processed.  If so,
                  archive elements processed in the  un-processed assignment
                 ***************************************************************/
                 open c_get_unproc_asg(ln_assignment_id,
                                       ld_curr_pymt_eff_date,
                                       ln_payroll_id,
                                       p_xfr_action_id,
                                       ln_asg_action_id);
                 loop
                    fetch c_get_unproc_asg into ln_np_asg_id, ln_np_asg_action_id;
                    hr_utility.trace('ln_np_asg_id        ='||ln_np_asg_id);
                    hr_utility.trace('ln_np_asg_action_id ='||ln_np_asg_action_id);

                    exit when c_get_unproc_asg%NOTFOUND;

                    -- An assignment only needs to be processed once as that will
                    -- move all elements.
                    if ln_np_asg_id <> ln_np_prev_asg_id then
                       pay_ac_action_arch.emp_elements_tab.delete;
                       pay_ac_action_arch.lrr_act_tab.delete;

                       -- Check if the date of assignment process is the same as
                       -- last archive date. If they are the same, the element just
                       -- needs to be moved forward otherwise we need to get the
                       -- data from run results

                       hr_utility.trace('PrevRun ln_np_asg_id := ' || ln_np_asg_id);
                       hr_utility.trace('PrevRun ln_child_xfr_action_id := ' || ln_child_xfr_action_id);
                       hr_utility.trace('PrevRun ld_curr_pymt_eff_date := ' || ld_curr_pymt_eff_date);

                       open c_prev_run_information(ln_np_asg_id
                                                  ,ln_child_xfr_action_id
                                                  ,ld_curr_pymt_eff_date);
                       fetch c_prev_run_information into ld_np_last_xfr_eff_date;
                       close c_prev_run_information;

                       hr_utility.trace('ld_np_last_xfr_eff_date='||ld_np_last_xfr_eff_date);
                       hr_utility.trace('ld_last_xfr_eff_date   ='||ld_last_xfr_eff_date);

                       if ld_np_last_xfr_eff_date >= ld_last_xfr_eff_date then
                       -- To be Changed
                          pay_ac_action_arch.get_xfr_elements(
                                  p_xfr_action_id      => ln_child_xfr_action_id
                                 ,p_last_xfr_action_id => ln_last_xfr_action_id
                                 ,p_ytd_balcall_aaid   => ln_np_asg_action_id
                                 ,p_pymt_eff_date      => ld_curr_pymt_eff_date
                                 ,p_legislation_code   => lv_legislation_code
                                 ,p_sepchk_flag        => lv_master_sepcheck_flag
                                 ,p_assignment_id      => ln_np_asg_id);
                       else
                          pay_ac_action_arch.process_additional_elements
                                 (p_assignment_id        => ln_np_asg_id,
                                  p_assignment_action_id => ln_np_asg_action_id,
                                  p_curr_eff_date        => ld_curr_pymt_eff_date,
                                  p_xfr_action_id        => ln_child_xfr_action_id,
                                  p_legislation_code     => lv_legislation_code,
                                  p_tax_unit_id          => ln_tax_unit_id);

                          change_processing_priority;
                       end if;

                       pay_ac_action_arch.populate_summary(
                                 p_xfr_action_id => p_xfr_action_id);

                       pay_emp_action_arch.insert_rows_thro_api_process(
                                 p_action_context_id  => ln_child_xfr_action_id
                                ,p_action_context_type=> 'AAP'
                                ,p_assignment_id      => ln_np_asg_id
                                ,p_tax_unit_id        => ln_tax_unit_id
                                ,p_curr_pymt_eff_date => ld_curr_pymt_eff_date
                                ,p_tab_rec_data       => pay_ac_action_arch.lrr_act_tab
                                 );

                    end if;
                    ln_np_prev_asg_id := ln_np_asg_id;

                 end loop;
                 close c_get_unproc_asg;
              end if;

           end if; -- ln_earnings

        end loop;  -- c_payment_info
        close c_payment_info;
        hr_utility.trace('archive_data:payment_info:DONE');

     end if; /* P,U */


     ln_step := 11;
     if lv_master_action_type  = 'V' then
        ln_pymt_balcall_aaid := ln_asg_action_id ;
        hr_utility.trace('Reversal ln_pymt_balcall_aaid'
               ||to_char(ln_pymt_balcall_aaid));
        ln_step := 12;
        pay_ac_action_arch.initialization_process;
        ln_step := 13;
        populate_puv_tax_balances(
                  p_xfr_action_id         => p_xfr_action_id
                 ,p_assignment_id         => ln_xfr_assignment_id
                 ,p_pymt_balcall_aaid     => ln_pymt_balcall_aaid
                 ,p_ytd_balcall_aaid      => null
                 ,p_tax_unit_id           => ln_tax_unit_id
                 ,p_action_type           => lv_master_action_type
                 ,p_rqp_action_id         => ln_asg_action_id
                 ,p_start_date            => ld_start_date
                 ,p_end_date              => ld_end_date
                 ,p_run_effective_date    => ld_curr_pymt_eff_date
                 ,p_resident_jurisdiction => lv_resident_jurisdiction
                 );

        ln_step := 14;
        change_processing_priority;
        pay_emp_action_arch.insert_rows_thro_api_process(
                  p_action_context_id  => p_xfr_action_id
                 ,p_action_context_type=> 'AAP'
                 ,p_assignment_id      => ln_xfr_assignment_id
                 ,p_tax_unit_id        => ln_tax_unit_id
                 ,p_curr_pymt_eff_date => ld_curr_pymt_eff_date
                 ,p_tab_rec_data       => pay_ac_action_arch.lrr_act_tab
                 );

     end if;

     ln_step := 15;
     if lv_master_action_type  = 'B' then
        hr_utility.trace('Reversal ln_pymt_balcall_aaid'
               ||to_char(ln_pymt_balcall_aaid));
        pay_ac_action_arch.initialization_process;
        ln_step := 16;
        populate_adj_tax_balances(
                  p_xfr_action_id        => p_xfr_action_id
                 ,p_assignment_id        => ln_xfr_assignment_id
                 ,p_tax_unit_id          => ln_tax_unit_id
                 ,p_action_type          => lv_master_action_type
                 ,p_start_date           => ld_start_date
                 ,p_end_date             => ld_end_date
                 ,p_run_effective_date   => ld_curr_pymt_eff_date
                 );

        ln_step := 17;
        change_processing_priority;
        pay_emp_action_arch.insert_rows_thro_api_process(
                  p_action_context_id  => p_xfr_action_id
                 ,p_action_context_type=> 'AAP'
                 ,p_assignment_id      => ln_xfr_assignment_id
                 ,p_tax_unit_id        => ln_tax_unit_id
                 ,p_curr_pymt_eff_date => ld_curr_pymt_eff_date
                 ,p_tab_rec_data       => pay_ac_action_arch.lrr_act_tab
                 );

     end if;

     /****************************************************************
     ** Archive all the payroll action level data once only when
     ** chunk number is 1. Also check if this has not been archived
     ** earlier
     *****************************************************************/
     hr_utility.set_location(gv_package || lv_procedure_name,210);
     ln_step := 20;
     open c_check_pay_action(ln_xfr_payroll_action_id);
     fetch c_check_pay_action into ln_pay_action_count;
     close c_check_pay_action;
     if ln_pay_action_count = 0 then
        hr_utility.set_location(gv_package || lv_procedure_name,210);
        if ln_chunk_number = 1 then
           ln_step := 25;
           pay_emp_action_arch.arch_pay_action_level_data(
                               p_payroll_action_id => ln_xfr_payroll_action_id
                              ,p_payroll_id        => ln_payroll_id
                              ,p_effective_Date    => ld_end_date
                              );
       end if;

     end if;

  EXCEPTION
   when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  end action_archive_data;


  /*********************************************************************
   Name      : check_alien
   Purpose   : This function checks if the given assignemnt is ALIEN
               it returns a 'TRUE' or 'FALSE'.
   Arguments : IN
                 p_assignment_action_id   number;
   Notes     :
  *********************************************************************/
  FUNCTION check_alien(
                p_assignment_action_id   in number)
  RETURN VARCHAR2
  IS

    ln_assignment_id number;
    lv_error_message     VARCHAR2(200);
    lv_procedure_name    VARCHAR2(100) := '.check_alien';

    cursor c_get_assignment_id (cp_assignment_action_id in number) is
      select assignment_id
      from   pay_assignment_actions
      where  assignment_action_id = cp_assignment_action_id;

  BEGIN
      hr_utility.trace('opened c_get_assignment_id');

      open c_get_assignment_id(p_assignment_action_id);
      fetch c_get_assignment_id into ln_assignment_id;
      close c_get_assignment_id;

      hr_utility.trace('ln_assignment_id = ' ||
                           to_char(ln_assignment_id));

      return pqp_us_ff_functions.is_windstar(p_assignment_id => ln_assignment_id);

  EXCEPTION
   when others then
      lv_error_message := 'Error in ' ||
                           gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;
  END check_alien;

--begin
--hr_utility.trace_on (null, 'XFR');

end pay_us_action_arch;

/
