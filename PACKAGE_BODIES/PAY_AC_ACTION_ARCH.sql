--------------------------------------------------------
--  DDL for Package Body PAY_AC_ACTION_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AC_ACTION_ARCH" AS
/* $Header: pyacxfrp.pkb 120.26.12010000.20 2010/03/03 13:47:05 mikarthi ship $ */
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
   *  500 Oracle Parkway, Redwood City, US, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_ac_action_arch

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    03-Feb-2010  mikarthi    115.112 8688998  Added the Overloaded version
					    of procedure get_last_xfr_info.
					    Modified cursor c_last_xft_elements
    18-Dec-2009 nkjaladi    115.111 9207953  Reverted the changes done for bug 8688998 in
                                             order to remove dependency.
    18-Dec-2009 nkjaladi    115.110 9207953  Modified the cursor get_run_action_id in procedure
                                             get_current_elements such that payroll process with
                                             seperate check are not picked.
    19-Oct-2009 kagangul   115.109 8688998  Added the Overloaded version
					    of procedure get_last_xfr_info.

    20-Aug-2009 asgugupt   115.108 8324157  Added hint to improve
                                            performance of process
    30-Jan-2009 sudedas    115.107 8211926  Changed get_current_elements
    22-Jan-2009 sudedas    115.106 7661112  Changed archive_retro_element
                                           ,get_current_element for perf.
    12-DEC-2008 tclewis     115.105         Added SDI1 EE.
    04-DEC-2008 tclewis     115.105         Added SUI1 EE.
    19-NOV-2008 sudedas    115.104 7580440  Changed get_current_elements
                                           ,Archive_retro_element procs.
    16-SEP-2008 sudedas    115.103 7348767  Modified get_xfr_elements,
                                   7348838  get_missing_xfr_info to
                                            populate action_info24
    11-SEP-2008 asgugupt   115.102 7197824  Changed get_run_results and
                                            get_run_results_rate cursors
                                            in Proc Archive_addnl_elements
    23-JUN-2008 sudedas    115.101 7197824  Changed get_current_element
                                            ,archive_retro_element
                                            ,archive_addnl_element
                                            for Work at Home Condition
    02-JUN-2008 sapalani   115.100 7120430  Used fnd_number.canonical_to_number
                                            in procedure populate_summary.
                                            Removed trace_off at the end of
                                            procedure populate_hours_x_rate.
    14-APR-2008 asgugupt   115.99  6950970  Modified get_current_elements
    29-FEB-2008 sudedas    115.98  6663135  Changed other similar cursors
    20-FEB-2008 sudedas    115.97  6831411  Kept Code for Canada intact
                                            before US California OT Enh
                                            Changed Cursors in get_current
                                            _elements
    23-DEC-2007 sudedas    115.96  6702864  Reverted Back Changes of 115.95
                                            Changed get_current_elements,
                                            Archive_retro_element
                                            populate_elements Changed.
                                            Changes on Top of 115.94
    20-DEC-2007 sudedas    115.95           Changed get_current_elements,
                                            Archive_retro_element,
                                            Archive_addnl_elements
    03-DEC-2007 tclewis    115.94  6663135  Removed the code processing cursor
                                            retro_parent_check_flag and use check_retro
                                            instead as its identical code.
    22-SEP-2007 sausingh   115.93  5635335  Cahnged to archive ) value in case the YTD
                                            value is null .
    22-SEP-2007 Ahanda     115.92  5635335  Made changes in the to get the the
                                            orignating date when offset date was
                                            mentioned.
    15-sep-2007 sausingh   115.91  5635335  Added nvl condition
    13-sep-2007 sausingh   115.90  5635335  Added nvl condition while archiving ytd and
                                            current amount in case of earnings and
                                            deduction ( withelds)
    5-Sep-2007  sausingh   115.88  6392875  Archiving rate through balance call
                                            in populate_elements
    03-Aug-2007 sausingh   115.87  5635335  Changes Archive_addnl_elements to calculate
                                            ytd values from balance call
    30-Aug-2007 sudedas    115.86           Changes Incorporated for Issues
                                            found by Rick on Aug 24, 2007
    23-Aug-2007 sudedas    115.82           Closing Cursors as per requirement.
    21-AUG-2007 sausingh   115.81           Added action information24 to archive                                               display name for deductions
    17-Aug-2007 sausingh   115.80  5635335  Added two procedures Archive_retro_element
                                            and Archive_addnl_elements to archive retro
                                            elements in separate rows depending upon the
                                            element_entry_id
    30-Jul-2007 sausingh   115.79  5635335  Added cursors to archive Rate*Multiple
                                            in a new segment Action_information22
    06-Jun-2007 sausingh   115.78  5635335  Changed get_current_elements
                                            to archive Original Date Earned.
    15-NOV-2006 ahanda     115.77           Changed sql statement to
                                            use base table instead secure
                                            views.
    27-OCT-2006 ahanda     115.76  5582224  Checking PL/SQL table count > 0
                                            before starting loop.
    12-OCT-2006 ppanda     115.75  5599167  Cursor c_check_baladj  changed by
                                            adding hint leading(PPA)
                                            index(PPA,PAY_PAYROLL_ACTIONS_N51)
                                            index(PAA,PAY_ASSIGNMENT_ACTIONS_N51)
                                            Cursor c_prev_elements modified by
                                            adding hint
                                            ORDERED  use_nl(PAA, PPA, PPF)
    19-SEP-2006 sodhingr   115.74  5549032  Added ORDERED hint to c_prev_elements
    11-JUL-2006 ppanda     115.73           Changed cursor c_prev_ytd_action_elements
                                            for fixing R12 performance bug 5042715
    13-APR-2006 ahanda     115.72           Changed populate_hours_x_rate
                                            to use amount returned by
                                            pay_hours_by_rate_v
    08-Mar-2006 vpandya    115.71           Changed populate_hours_x_rate
                                            procedure to fix retro issue
                                            for Canada.
    14-OCT-2005 ahanda     115.70           Changed the prev_ytd .. cursors
                                            to not do a trunc on year but
                                            pass it as a parameter.
    06-OCT-2005 ahanda     115.69  4552807  Added process_baladj_elements
    28-JUL-2005 ahanda     115.68  4507782  Changed cursor
                                            c_multi_asg_prev_information
    29-DEC-2004 ahanda     115.67  4069477  Changed procedure populate_elements
                                            to remove special logic for
                                            Non Payroll Payments
    06-OCT-2004 ahanda     115.66  3940380  Added parameter p_xfr_action_id
                                            to get_last_xfr_info and check
                                            in cursor.
    30-JUL-2004 ssattini   115.65  3498653  Added p_action_type parameter
                                            to get_current_elements and
                                            populate_elements procedures,
                                            also added logic to archive
                                            reversals and balance adjustments
                                            in populate_elements procedure.
    28-JUL-2004 vpandya    115.64  3780256  Added ORDERED hint to
                                            c_prev_ytd_action_elem_rbr cursor.
                                            Changed cursor c_last_xfr_elements
                                            in get_xfr_element procedure to
                                            get jurisdiction_code from previous
                                            archived value.
    19-JUL-2004 ahanda     115.63  3770899  Changed c_prev_ytd_action_elements
                                            and c_prev_ytd_action_elem_rbr
                                            to pick up elements processed from
                                            1st and the passed date.
    16-JUL-2004 ahanda     115.62  3767301  Added rpad and ltrim for state code
                                            as JD in run balances might just
                                            have a space.
    16-JUL-2004 ahanda     115.61  3767301  Changed the run balance cursor
                                            to do a substr on jurisdiction code
                                            to ensure correct distinct JDs are
                                            fetched. The table has JD values
                                            like 05, 05-, 05-000-, 05-000-0.
    20-MAY-2004 rsethupa   115.60  3639249  procedure process_additional_elements
                                            set the balance context 'TAX_UNIT_ID'
					    to p_tax_unit_id in the beginning.
    10-MAY-2004 ahanda     115.59  3567107  Changed get_xfr_elements procedure
                                            to check if element is still valid
                                            before archiving.
    03-MAY-2004 kvsankar   115.58  3585754  Added a new cursor
                                            'c_prev_ytd_action_elem_rbr'
                                            which uses run balances to
                                            retrieve the elements. This
                                            cursor has to be executed instead
                                            of 'c_prev_ytd_action_elements'
                                            if Balance Initialization elements
                                            are to be archived.
    26-APR-2004 rsethupa   115.57  3559626  Removed code at the end of the
                                            file that was used to initialize
                                            the global variable
                                            gv_correspondence_language of the
					    package pyempxfrp.pkb to get the
					    Accrual Information based on
					    Correspondance language.
    16-APR-2004 rsethupa   115.56  3311866  US SS Payslip currency Format Enh.
                                            Changed code to archive currency
                                            in canonical format for the action
                                            info categories 'AC EARNINGS',
                                            'AC DEDUCTIONS', 'AC SUMMARY YTD'
                                            and 'AC SUMMARY CURRENT'.
    29-JAN-2004 rsethupa   115.55  3370112  11.5.10 Performance Changes
                                            Modified cursor c_cur_action_elements
                                            by removing the 'and exists' clause
    28-JAN-2004 rsethupa   115.54  3370112  11.5.10 Performance Changes
    14-JAN-2003 RMONGE     115.53  3360805  Remove hr. from pay_action_information
    25-NOV-2003 vpandya    115.52  3280589  Changed get_xfr_elements:
                                            modified cursor c_last_per_xfr_run.
    07-NOV-2003 vpandya    115.51  3225286  Changed c_prev_ytd_action_elements
                                            cursor and added condition for
                                            Bal Adj (B) for action_type.
    06-NOV-2003 vpandya    115.50  3239376  Changed get_xfr_elements:
                                            Retreving action_information12
                                            (ytd_hours) and initializing
                                            variable ln_ytd_hours.
    04-NOV-2003 vpandya    115.49  3228457  Changed c_last_per_xfr_run cursor:
                                            Remove extra table
                                            pay_action_information.
    20-OCT-2003 vpandya    115.48  3119792  Changed process_additional_elements:
                                            calling populate_summary to archive
                                            summary for YTD.
    04-OCT-2003 ahanda     115.47  3107166  Added date joins when getting
                                            data from pay_element_types_f
    10-Sep-2003 ekim       115.46  3119792  1) Added procedure
                                   2880047  - process_additional_elements
                                            2) Moved c_prev_ytd_action_elements
                                               to be global.
                                            3) Added following in
                                               get_last_xfr_info procedure.
                                               Cursor:
                                               - c_multi_asg_prev_information
                                               - c_multi_asg_prev_nonsepchk
                                               Parameter:
                                               - p_sepchk_flag
    26-JUN-2003 vpandya    115.45  2950628  Changed populate_summary to archive
                                            labels for CURRENT and YTD based on
                                            correspondence language of an
                                            employee. Also added cursor
                                            c_arch_labels.
    19-JUN-2003 ahanda     115.44  3018135  Changed populate_summary to populate
                                            values for Alien/Expat Earnings.
    19-JUN-2003 ahanda     115.43  3016946  Changed cursor to do an nvl
                                            reporting_name and element_name.
    11-Apr-2003 vpandya    115.42           Changed get_xfr_elements:
                                            Removed Multi GRE cond. which was
                                            with Multi Asg and SepChk cond.
    25-Mar-2003 vpandya    115.41           Changed populate_hours_x_rate:
                                            Taken out 'Exit' from GRE loop
                                            and put it at common place so that
                                            it works for GRE and Tax Group.
    17-Mar-2003 ekim       115.40           Added index hint in
                                            c_last_payment_info cursor.
    14-Mar-2003 ekim      115.39  2851780  Added c_last_per_xfr_run in
                                            get_xfr_elements.
    07-Mar-2003 vpandya   115.38  2834674  Changed populate_hours_x_rate:
                                            Divided hours_by_rate cursor into
                                            c_run_aa_id and c_hbr cursor.
    24-Feb-2003 vpandya   115.37           Changed get_current_elements:
                                            added cursor c_ytd_action_seq and
                                            changed cursor c_cur_action_elements
                                            to get sep check elements.
                                            Changed get_xfr_elements:
                                            archive all elements of previous
                                            xfr run when gv_multi_gre_payment
                                            is 'N'.
    06-Feb-2003 ekim      115.36  2315822  changed get_xfr_elements:
                                            Added logic to get YTD for
                                            the elements in the previous run
                                            for the given assignment when
                                            Multi-Asg is 'Y' and SEPCHK = 'Y'
    06-FEB-2003 vpandya    115.35  2657464  Changed to get translated name of
                                            an element. Changed all cursors
                                            wherever reporting name is taken
                                            from pay_element_types_f, now it is
                                            taking from pay_element_types_f_tl.
                                            Also changed populate_hours_x_rate.
    02-DEC-2002 ahanda     115.34           Changed package to fix GSCC warning
    19-NOV-2002 vpandya    115.33           Calling set_error_message function
                                            of pay_emp_action_arch from all
                                            exceptions to get error message
                                            Remote Procedure Calls(RPC or Sub
                                            program)
    13-NOV-2002 ahanda     115.32  2667749  Changed get_missing_xfr_info
                                            to set the JD for Tax Deduction
                                            and insert value only if non Zero
    01-NOV-2002 ahanda     115.31           Changed error handling.
    25-OCT-2002 ahanda     115.30           - Changed code to set up
                                              hours_bal_id
                                              only for earnings and
                                   2503094  - Resetting the category in
                                              get_missing_xfr_info.
    15-OCT-2002 tmehra     115.29           Added code to archive PQP
                                            (Alien) Earnings.
    09-SEP-2002 ahanda     115.26  2558228  Modified code to only set the
                                            Jurisdiction for Tax Deduction.
    06-SEP-2002 ahanda     115.25           Added stmts for GSCC warnings.
    27-JUL-2002 ahanda     115.24           Added code to get the primary
                                            balance if it is null. This will
                                            happen only to existing US
                                            customers for Tax Deduction.
    12-JUL-2002 ahanda     115.23           Setting JD Balance only for US
    10-JUL-2002 vpandya    115.22  2455729  Modified populate_elements,
                                            put condition like don't assign
                                            hours to pl/sql table if ytd and
                                            payment amounts are zero.
    17-JUN-2002 ahanda     115.21  2365908  Changed package to populate tax
                                            deductions if location has changed.
    13-JUN-2002 vpandya    115.20           Added populate_hours_x_rate proc.
                                            to populate Hours by Rate(HBR)
                                            element.
                                            Changed check_hours_by_rate to
                                            check whether HBR element exists in
                                            PL/SQL table. Setting context for
                                            'Tax Group' if reporting level is
                                            'TAXGRP'(Canadian Req.)
    15-MAY-2002 ahanda     115.19  2339387  Changed get_xfr_elements to reset
                                            the variable for category.
                                            Added procedures
                                              - get_last_xfr_info
                                              - get_last_pymt_info
    07-MAY-2002 vpandya    115.18           Modified populate_summanry,
                                            Added 'Taxable Benefits' in it for
                                            AC SUMMARY CURRENT, AC CURRENT YTD
    24-APR-2002 ahanda     115.17           Changed get_current_elements for
                                            performance.
    08-APR-2002 ahanda     115.16           Changed
                                               - get_missing_xfr_info
                                               - get_current_elements
                                               - first_time_process
                                            to pass NULL for hours if the
                                            classification is of type Dedutions
    18-MAR-2002 ahanda     115.15  2264358  Changed cursor
                                            c_prev_ytd_action_elements
                                            Fixed archiving for Bal Adj for
                                            which Pre Pay flag is checked.
    22-JAN-2002 ahanda     115.14           Moved get_multi_assignment_flag
                                            to global package (pyempxfr.pkb)
    26-JAN-2002 ahanda     115.13           Added dbdrv commands.
    22-JAN-2002 ahanda     115.12           Changed package to take care
                                            of Multi Assignment Processing.
    01-NOV-2001 asasthan   115.10           2034976
    30-OCT-2001 asasthan   115.9            YTD Hours BUg
    26-OCT-2001 asasthan   115.8            Fix for Bug 2080689
    03-OCT-2001 asasthan   115.7            Fix for Bug 2028415
    03-OCT-2001 asasthan   115.6            Fix for Bug 2028415
    02-OCT-2001 vpandya    115.5            canada Changes
    21-SEP-2001 asasthan   115.4            Removed check for 'Fees' from
                                            get_current_elements etc.
    31-AUG-2001 asasthan   115.3            Modified populate_delta_earnings
    29-AUG-2001 asasthan   115.2            Modified ytd balance calls.
    17-JUL-2001 vpandya    115.1            Added 'Taxable Benefits'
                                            classification and 'Hours by Rate'
                                            for CA.
    25-JUL-2001 asasthan   115.0            Created.

  *******************************************************************/

  /******************************************************************
  ** Package Local Variables
  ******************************************************************/
  gv_package         VARCHAR2(100) := 'pay_ac_action_arch';

  gv_dim_asg_tg_ytd     VARCHAR2(100) := '_ASG_TG_YTD';
  gv_dim_asg_gre_ytd    VARCHAR2(100) := '_ASG_GRE_YTD';
  gv_dim_asg_jd_gre_ytd VARCHAR2(100) := '_ASG_JD_GRE_YTD';
  gv_ytd_amount         number(20,2)  := 0;
  gv_ytd_hour           number(20,2)  := 0;

  cursor c_element_info(cp_element_type_id in number
                       ,cp_effective_date  in date) is
    select pet.element_information10 primary_balance,
           pet.element_information12 hours_balance
      from pay_element_types_f pet
     where pet.element_type_id  = cp_element_type_id
       and cp_effective_date between pet.effective_start_date
                                 and pet.effective_end_date;

  cursor c_prev_ytd_action_elements(cp_assignment_id  in number
                                   ,cp_curr_eff_date  in date
                                   ,cp_start_eff_date in date
                                   ,cp_action_type1   in varchar2
                                   ,cp_action_type2   in varchar2
                                   ,cp_action_type3   in varchar2
                                 ) is
      select /*+ ORDERED use_nl(PAA,PPA,PPF)
                      INDEX (paa PAY_ASSIGNMENT_ACTIONS_N51)
                      INDEX(ppa  PAY_PAYROLL_ACTIONS_PK)
                      INDEX(prr   PAY_RUN_RESULTS_N50)
                      INDEX(pcc  PAY_ELEMENT_CLASSIFICATION_UK2) */
             distinct
             pec.classification_name,
             pet.processing_priority,
             nvl(decode(pec.classification_name,
                       'Tax Deductions', petl.reporting_name || ' Withheld',
                       petl.reporting_name),pet.element_name) reporting_name,
             --pet.element_name,
             decode(pec.classification_name,
                       'Tax Deductions', null,
                       prr.element_type_id) element_type_id,
             --prr.element_type_id,
             nvl(decode(pec.classification_name,
                           'Tax Deductions', prr.jurisdiction_code,
                           'Earnings',prr.jurisdiction_code), '00-000-0000'),
             pet.element_information10,
             pet.element_information12
        from pay_assignment_actions      paa,
                pay_payroll_actions            ppa,
                pay_run_results                  prr,
                pay_element_types_f          pet,
                pay_element_classifications pec,
                pay_element_types_f_tl       petl
       where prr.assignment_action_id = paa.assignment_action_id
         and paa.assignment_id = cp_assignment_id
         and ppa.payroll_action_id = paa.payroll_action_id
         and ppa.action_type in (cp_action_type1, cp_action_type2, cp_action_type3)
         and ppa.effective_date >= cp_start_eff_date
         and ppa.effective_date <= cp_curr_eff_date
         and pet.element_type_id = prr.element_type_id
         and pet.element_information10 is not null
         and ppa.effective_date between pet.effective_start_date
                                    and pet.effective_end_date
         and petl.element_type_id  = pet.element_type_id
         and petl.language         = gv_person_lang
         and pec.classification_id = pet.classification_id
         and pec.business_group_id is NULL
         and pec.legislation_code = 'US'
         and pec.classification_name in ('Earnings',
                                         'Alien/Expat Earnings',
                                         'Supplemental Earnings',
                                         'Imputed Earnings',
                                         'Taxable Benefits',
                                         'Pre-Tax Deductions',
                                         'Involuntary Deductions',
                                         'Voluntary Deductions',
                                         'Non-payroll Payments',
                                         'Tax Deductions')
         and pet.element_name not like '%Calculator'
         and pet.element_name not like '%Special Inputs'
         and pet.element_name not like '%Special Features'
         and pet.element_name not like '%Special Features 2'
         and pet.element_name not like '%Verifier'
         and pet.element_name not like '%Priority'
       order by 1, 3, 4;
      --pec.classification_name, reporting_name, pet.element_name;

-- Bug 3585754
  cursor c_prev_ytd_action_elem_rbr(cp_assignment_id  in number
                                   ,cp_curr_eff_date  in date
                                   ,cp_start_eff_date in date
                                   ) is
     select /*+ ORDERED INDEX(PRB PAY_RUN_BALANCES_N1
                             ,PDB PAY_DEFINED_BALANCES_PK
                             ,PBT PAY_BALANCE_TYPES_PK,
                             ,PET PAY_ELEMENT_TYPES_F_PK
                             ,PEC PAY_ELEMENT_CLASSIFICATION_PK
                             ,PETL PAY_ELEMENT_TYPES_F_TL_PK)
                USE_NL(PRB, PDB, PBT, PET, PEC, PETL) */
            distinct pec.classification_name,
            pet.processing_priority,
            nvl(decode(pec.classification_name,
                  'Tax Deductions', petl.reporting_name || ' Withheld',
                  petl.reporting_name), pet.element_name) reporting_name,
            decode(pec.classification_name, 'Tax Deductions', null,
                                            pet.element_type_id) element_type_id,
            nvl(decode(pec.classification_name,
                                'Tax Deductions',
                  decode(pec.legislation_code,
                            'CA', substr(jurisdiction_code,1,2),
                            decode(to_char(length(replace(jurisdiction_code, '-'))),
                                    '7', jurisdiction_code,
                              rpad(nvl(substr(rtrim(ltrim(jurisdiction_code)),1,2),'0')
                                  ,2,'0') || '-'||
                              rpad(nvl(substr(rtrim(ltrim(jurisdiction_code)),4,3),'0')
                                  ,3,'0') ||'-' ||
                              rpad(nvl(substr(rtrim(ltrim(jurisdiction_code)),8,4),'0')
                                  ,4,'0')))), '00-000-0000') jurisdiction_code,
            pet.element_information10,
            pet.element_information12
       from pay_run_balances prb
           ,pay_defined_balances pdb
           ,pay_balance_types pbt
           ,pay_element_types_f pet
           ,pay_element_classifications pec
           ,pay_element_types_f_tl petl
      where prb.effective_date >= cp_start_eff_date
        and prb.effective_date <= cp_curr_eff_date
        and prb.assignment_id = cp_assignment_id
        and pet.element_information10 is not null
        and pet.element_information10 = pbt.balance_type_id
        and pbt.balance_type_id = pdb.balance_type_id
        and pdb.defined_balance_id = prb.defined_balance_id
        and prb.effective_date between pet.effective_start_date and pet.
                                        effective_end_date
        and petl.element_type_id  = pet.element_type_id
        and petl.language = gv_person_lang
        and pec.classification_id = pet.classification_id
        and pec.classification_name in ('Earnings',
                                        'Alien/Expat Earnings',
                                        'Supplemental Earnings',
                                        'Imputed Earnings',
                                        'Taxable Benefits',
                                        'Pre-Tax Deductions',
                                        'Involuntary Deductions',
                                        'Voluntary Deductions',
                                        'Non-payroll Payments',
                                        'Tax Deductions')
        and pet.element_name not like '%Calculator'
        and pet.element_name not like '%Special Inputs'
        and pet.element_name not like '%Special Features'
        and pet.element_name not like '%Special Features 2'
        and pet.element_name not like '%Verifier'
        and pet.element_name not like '%Priority'
      order by 1, 3, 4;

  /******************************************************************
   Name      : initialization_process
   Purpose   : The procedure initializes the PL/SQL table -
                 pay_ac_action_arch.lrr_act_tab
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE initialization_process
  IS
     lv_procedure_name VARCHAR2(100) := '.initialization_process';

     lv_error_message  VARCHAR2(200);
     ln_step           NUMBER;
     i                 NUMBER := 0; -- used for label counter

     cursor c_arch_labels is
       select language, lookup_code, meaning
       from   fnd_lookup_values
       where  lookup_type = 'CA_CHEQUE_LABELS'
       and    lookup_code in ('CURRENT', 'YTD');


  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;

     if pay_ac_action_arch.lrr_act_tab.count > 0 then
        for i in pay_ac_action_arch.lrr_act_tab.first ..
                 pay_ac_action_arch.lrr_act_tab.last loop
            pay_ac_action_arch.lrr_act_tab(i).action_context_id := null;
            pay_ac_action_arch.lrr_act_tab(i).action_context_type := null;
            pay_ac_action_arch.lrr_act_tab(i).action_info_category := null;
            pay_ac_action_arch.lrr_act_tab(i).jurisdiction_code := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info1 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info2 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info3 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info4 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info5 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info6 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info7 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info8 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info9 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info10 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info11 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info12 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info13 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info14 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info15 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info16 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info17 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info18 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info19 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info20 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info21 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info22 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info23 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info24 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info25 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info26 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info27 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info28 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info29 := null;
            pay_ac_action_arch.lrr_act_tab(i).act_info30 := null;
        end loop;
     end if;

     ln_step := 5;
     pay_ac_action_arch.lrr_act_tab.delete;
     pay_ac_action_arch.emp_state_jd.delete;
     pay_ac_action_arch.emp_city_jd.delete;
     pay_ac_action_arch.emp_county_jd.delete;
     pay_ac_action_arch.emp_school_jd.delete;
     pay_ac_action_arch.emp_elements_tab.delete;
     pay_ac_action_arch.lrr_act_tab.delete;

     if gv_reporting_level = 'TAXGRP' then
        gv_ytd_balance_dimension := gv_dim_asg_tg_ytd;
     else
        gv_ytd_balance_dimension := gv_dim_asg_gre_ytd;
     end if;

     if pay_ac_action_arch.ltr_summary_labels.count = 0 then

        i := 0;

        for lbl in c_arch_labels loop

           pay_ac_action_arch.ltr_summary_labels(i).language    := lbl.language;
           pay_ac_action_arch.ltr_summary_labels(i).lookup_code := lbl.lookup_code;
           pay_ac_action_arch.ltr_summary_labels(i).meaning     := lbl.meaning;

           hr_utility.trace(pay_ac_action_arch.ltr_summary_labels(i).language);
           hr_utility.trace(pay_ac_action_arch.ltr_summary_labels(i).lookup_code);
           hr_utility.trace(pay_ac_action_arch.ltr_summary_labels(i).meaning);

           i := i + 1;

        end loop;

     end if;

     hr_utility.trace('pay_ac_action_arch.lrr_act_tab.count = ' ||
                        pay_ac_action_arch.lrr_act_tab.count);
     hr_utility.set_location(gv_package || lv_procedure_name, 50);
     ln_step := 10;

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

  END initialization_process;


  /******************************************************************
   Name      : get_last_xfr_info
   Purpose   : This returns the date and action_id of the last
               External Process Archive run.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE get_last_xfr_info(p_assignment_id        in        number
                             ,p_curr_effective_date  in        date
                             ,p_action_info_category in        varchar2
                             ,p_xfr_action_id        in        number
                             ,p_sepchk_flag          in        varchar2
                             ,p_last_xfr_eff_date   out nocopy date
                             ,p_last_xfr_action_id  out nocopy number
                             )
  IS

    cursor c_prev_run_information(cp_assignment_id        in number
                                 ,cp_action_info_category in varchar2
                                 ,cp_xfr_action_id        in number
                                 ,cp_effective_date       in date) is
      select pai.effective_date,
             pai.action_context_id
        from pay_action_information pai
       where pai.action_context_type = 'AAP'
         and pai.assignment_id = cp_assignment_id
         and pai.action_information_category = cp_action_info_category
         and pai.action_context_id <> cp_xfr_action_id
         and pai.effective_date <= cp_effective_date
         order by pai.effective_date desc
                 ,pai.action_context_id desc;

    cursor c_multi_asg_prev_information(
                  cp_assignment_id        in number
                 ,cp_action_info_category in varchar2
                 ,cp_xfr_action_id        in number
                 ,cp_effective_date       in date) is
      select /*+ index(PAI PAY_ACTION_INFORMATION_N5) */ pai.effective_date,
             pai.action_context_id
        from per_all_assignments_f paf2
            ,per_all_assignments_f paf
            ,pay_action_information pai
       where paf2.assignment_id = cp_assignment_id
         and paf.person_id = paf2.person_id
         and pai.assignment_id = paf.assignment_id
         and pai.action_context_type = 'AAP'
         and pai.action_information_category = cp_action_info_category
         and pai.effective_date <= cp_effective_date
         and pai.effective_date >= trunc(cp_effective_date, 'Y')
         and pai.action_context_id <> cp_xfr_action_id
      order by pai.effective_date desc
              ,pai.action_context_id desc;

    ld_last_xfr_eff_date   DATE;
    ln_last_xfr_action_id  NUMBER;
    lv_procedure_name      VARCHAR2(100) := '.get_last_xfr_info';

    lv_error_message       VARCHAR2(200);
    ln_step                NUMBER;

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;
     if pay_emp_action_arch.gv_multi_payroll_pymt = 'Y' then
        open c_multi_asg_prev_information(p_assignment_id,
                                          p_action_info_category,
                                          p_xfr_action_id,
                                          p_curr_effective_date);
        fetch c_multi_asg_prev_information into ld_last_xfr_eff_date
                                              ,ln_last_xfr_action_id;
        if c_multi_asg_prev_information%notfound then
           hr_utility.trace('This process has not been run earlier');
        end if;
        close c_multi_asg_prev_information;

     else

        open c_prev_run_information(p_assignment_id,
                                    p_action_info_category,
                                    p_xfr_action_id,
                                    p_curr_effective_date);
        fetch c_prev_run_information into ld_last_xfr_eff_date
                                         ,ln_last_xfr_action_id;
        if c_prev_run_information%notfound then
           hr_utility.trace('This process has not been run earlier');
        end if;
        close c_prev_run_information ;
     end if;

     ln_step := 5;
     if ld_last_xfr_eff_date is not null then
        if trunc(ld_last_xfr_eff_date,'Y') < trunc(p_curr_effective_date,'Y')
        then
           ld_last_xfr_eff_date   := null;
           ln_last_xfr_action_id  := null;
        end if;
     end if;
     hr_utility.trace('ld_last_xfr_eff_date '||to_char(ld_last_xfr_eff_date));
     hr_utility.trace('ln_last_xfr_action_id '|| ln_last_xfr_action_id);

     p_last_xfr_eff_date  := ld_last_xfr_eff_date;
     p_last_xfr_action_id := ln_last_xfr_action_id;

     hr_utility.set_location(gv_package || lv_procedure_name, 50);
     ln_step := 10;

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

  END get_last_xfr_info;

/* Start : Bug 8688998 */
/******************************************************************
   Name      : get_last_xfr_info (Overloaded version)
   Purpose   : This returns the date and action_id of the last
               External Process Archive run.
   Arguments : Added the following extract parameters :
               1. p_arch_bal_info
	       2. p_legislation_code
   Notes     : The only difference with the base version is the usage
	       of cursor c_prev_run_information/c_multi_asg_prev_information.
	       In base version, cursor c_multi_asg_prev_information is
	       used when pay_emp_action_arch.gv_multi_payroll_pymt = 'Y'
	       otherwise cursor c_prev_run_information get called.
	       However, in the overloaded version for US legislation
	       cursor c_multi_asg_prev_information is used when
	       pay_emp_action_arch.gv_multi_payroll_pymt = 'Y' AND
	       p_arch_bal_info = 'Y' otherwise
	       cursor c_prev_run_information get called. For other
	       legislations, the cursor usage is like base version only.
  ******************************************************************/
  PROCEDURE get_last_xfr_info(p_assignment_id        in        number
                             ,p_curr_effective_date  in        date
                             ,p_action_info_category in        varchar2
                             ,p_xfr_action_id        in        number
                             ,p_sepchk_flag          in        varchar2
                             ,p_last_xfr_eff_date   out nocopy date
                             ,p_last_xfr_action_id  out nocopy number
			     ,p_arch_bal_info	     in        varchar2
			     ,p_legislation_code     in        varchar2
                             )
  IS

    cursor c_prev_run_information(cp_assignment_id        in number
                                 ,cp_action_info_category in varchar2
                                 ,cp_xfr_action_id        in number
                                 ,cp_effective_date       in date) is
      select pai.effective_date,
             pai.action_context_id
        from pay_action_information pai
       where pai.action_context_type = 'AAP'
         and pai.assignment_id = cp_assignment_id
         and pai.action_information_category = cp_action_info_category
         and pai.action_context_id <> cp_xfr_action_id
         and pai.effective_date <= cp_effective_date
         order by pai.effective_date desc
                 ,pai.action_context_id desc;

    cursor c_multi_asg_prev_information(
                  cp_assignment_id        in number
                 ,cp_action_info_category in varchar2
                 ,cp_xfr_action_id        in number
                 ,cp_effective_date       in date) is
      select /*+ index(PAI PAY_ACTION_INFORMATION_N5) */ pai.effective_date,
             pai.action_context_id
        from per_all_assignments_f paf2
            ,per_all_assignments_f paf
            ,pay_action_information pai
       where paf2.assignment_id = cp_assignment_id
         and paf.person_id = paf2.person_id
         and pai.assignment_id = paf.assignment_id
         and pai.action_context_type = 'AAP'
         and pai.action_information_category = cp_action_info_category
         and pai.effective_date <= cp_effective_date
         and pai.effective_date >= trunc(cp_effective_date, 'Y')
         and pai.action_context_id <> cp_xfr_action_id
      order by pai.effective_date desc
              ,pai.action_context_id desc;

    ld_last_xfr_eff_date   DATE;
    ln_last_xfr_action_id  NUMBER;
    lv_procedure_name      VARCHAR2(100) := '.get_last_xfr_info';

    lv_error_message       VARCHAR2(200);
    ln_step                NUMBER;

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;

     IF p_legislation_code = 'US' THEN

        if pay_emp_action_arch.gv_multi_payroll_pymt = 'Y' AND p_arch_bal_info = 'Y' then
           open c_multi_asg_prev_information(p_assignment_id,
                                             p_action_info_category,
                                             p_xfr_action_id,
                                             p_curr_effective_date);
           fetch c_multi_asg_prev_information into ld_last_xfr_eff_date
                                              ,ln_last_xfr_action_id;
           if c_multi_asg_prev_information%notfound then
              hr_utility.trace('This process has not been run earlier');
           end if;
           close c_multi_asg_prev_information;

        else

           open c_prev_run_information(p_assignment_id,
                                       p_action_info_category,
                                       p_xfr_action_id,
                                       p_curr_effective_date);
           fetch c_prev_run_information into ld_last_xfr_eff_date
                                            ,ln_last_xfr_action_id;
           if c_prev_run_information%notfound then
              hr_utility.trace('This process has not been run earlier');
           end if;
           close c_prev_run_information ;
         end if;

     ELSE

	 if pay_emp_action_arch.gv_multi_payroll_pymt = 'Y' then
            open c_multi_asg_prev_information(p_assignment_id,
                                              p_action_info_category,
                                              p_xfr_action_id,
                                              p_curr_effective_date);
            fetch c_multi_asg_prev_information into ld_last_xfr_eff_date
                                               ,ln_last_xfr_action_id;
            if c_multi_asg_prev_information%notfound then
               hr_utility.trace('This process has not been run earlier');
            end if;
            close c_multi_asg_prev_information;

         else

            open c_prev_run_information(p_assignment_id,
                                        p_action_info_category,
                                        p_xfr_action_id,
                                        p_curr_effective_date);
            fetch c_prev_run_information into ld_last_xfr_eff_date
                                             ,ln_last_xfr_action_id;
            if c_prev_run_information%notfound then
               hr_utility.trace('This process has not been run earlier');
            end if;
            close c_prev_run_information ;
         end if;

     END IF;
     ln_step := 5;
     if ld_last_xfr_eff_date is not null then
        if trunc(ld_last_xfr_eff_date,'Y') < trunc(p_curr_effective_date,'Y')
        then
           ld_last_xfr_eff_date   := null;
           ln_last_xfr_action_id  := null;
        end if;
     end if;
     hr_utility.trace('ld_last_xfr_eff_date '||to_char(ld_last_xfr_eff_date));
     hr_utility.trace('ln_last_xfr_action_id '|| ln_last_xfr_action_id);

     p_last_xfr_eff_date  := ld_last_xfr_eff_date;
     p_last_xfr_action_id := ln_last_xfr_action_id;

     hr_utility.set_location(gv_package || lv_procedure_name, 50);
     ln_step := 10;

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

  END get_last_xfr_info;

  /* End : Bug 8688998 */

  /******************************************************************
   Name      : get_last_pymt_info
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE get_last_pymt_info(p_assignment_id        in        number
                              ,p_curr_pymt_eff_date   in        date
                              ,p_last_pymt_eff_date  out nocopy date
                              ,p_last_pymt_action_id out nocopy number
                              )
  IS
    cursor c_last_payment_info(cp_assignment_id     in number
                              ,cp_curr_pymt_eff_date in date) is

      select ppa.effective_date, paa.assignment_action_id
        from pay_payroll_actions ppa,
             pay_assignment_actions paa
       where paa.assignment_id = p_assignment_id
         and ppa.payroll_action_id = paa.payroll_action_id
         and ppa.action_type in ('R','Q')
         and ppa.effective_date < p_curr_pymt_eff_date
         and ppa.effective_date in
             ( select  /*+ index(ppa1, pay_payroll_Actions_pk) */
                      max(ppa1.effective_date)
                 from pay_payroll_actions ppa1,
                      pay_assignment_actions paa1
                where ppa1.payroll_action_id = paa1.payroll_action_id
                  and ppa1.action_type in ('R','Q')
                  and paa1.assignment_id = p_assignment_id
                  and ppa1.effective_date < p_curr_pymt_eff_date);

    ld_last_pymt_eff_date  DATE;
    ln_last_pymt_action_id NUMBER;
    lv_procedure_name      VARCHAR2(100) := '.get_last_pymt_info';
    lv_error_message       VARCHAR2(200);
    ln_step                NUMBER;

  BEGIN
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;
     open c_last_payment_info(p_assignment_id,p_curr_pymt_eff_date);
     fetch c_last_payment_info into ld_last_pymt_eff_date,
                                    ln_last_pymt_action_id ;
     close c_last_payment_info ;

     ln_step := 5;
     p_last_pymt_eff_date  := ld_last_pymt_eff_date;
     p_last_pymt_action_id := ln_last_pymt_action_id;

     hr_utility.set_location(gv_package || lv_procedure_name, 100);
     ln_step := 10;

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

  END get_last_pymt_info;


  /******************************************************************
   Name      : check_hours_by_rate
   Purpose   : The procedure checks whether element has already been
               archived or not (Canadian Requirement).
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE check_hours_by_rate(
                    p_xfr_action_id               in number
                   ,p_puv_assignment_action_id    in number
                   ,p_element_classification_name in varchar2
                   ,p_reporting_name              in varchar2
                   ,p_element_type_id             in number
                   ,p_primary_balance_id          in number
                   ,p_processing_priority         in number
                   ,p_tax_unit_id                 in number
                   ,p_pymt_eff_date               in date
                   ,p_ytd_balcall_aaid            in number
                   ,p_ytd_defined_balance_id      in number
                   ,p_ytd_hours_balance_id        in number
                   ,p_rate_exists                out nocopy varchar2
                   )

  IS
    lv_procedure_name VARCHAR2(100) := '.check_hours_by_rate';
    lv_error_message  VARCHAR2(200);
    ln_step           NUMBER;

  BEGIN
      ln_step := 1;
      p_rate_exists := 'N';

      hr_utility.set_location(gv_package || lv_procedure_name, 10);
      if pay_ac_action_arch.lrr_act_tab.count > 0 then
         for i in  pay_ac_action_arch.lrr_act_tab.first..
                   pay_ac_action_arch.lrr_act_tab.last
         loop
            if ( ( pay_ac_action_arch.lrr_act_tab(i).action_context_id =
                   p_xfr_action_id ) and
                 ( pay_ac_action_arch.lrr_act_tab(i).act_info2 =
                   p_element_type_id ) )
            then
               p_rate_exists := 'Y';
               exit;
            end if;
         end loop;
      end if;
      hr_utility.trace('p_rate_exists = '     || p_rate_exists);

      hr_utility.set_location(gv_package || lv_procedure_name, 20);
      ln_step := 10;

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

  END check_hours_by_rate;


  /******************************************************************
   Name      : populate_elements
   Purpose   :
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE populate_elements(p_xfr_action_id             in number
                             ,p_pymt_assignment_action_id in number
                             ,p_pymt_eff_date               in date
                             ,p_element_type_id             in number
                             ,p_primary_balance_id          in number
                             ,p_hours_balance_id            in number
                             ,p_processing_priority         in number
                             ,p_element_classification_name in varchar2
                             ,p_reporting_name              in varchar2
                             ,p_tax_unit_id                 in number
                             ,p_ytd_balcall_aaid            in number
                             ,p_pymt_balcall_aaid           in number
                             ,p_jurisdiction_code           in varchar2
                                                            default null
                             ,p_legislation_code            in varchar2
                             ,p_sepchk_flag                 in varchar2
                             ,p_sepchk_run_type_id          in number
                             ,p_action_type          in varchar2
                                                            default null
                             ,p_original_date_earned        in varchar2
                                                            default null
                             ,p_effective_start_date        in varchar2
                                                            default null
                             ,p_effective_end_date          in varchar2
                                                            default null
                              ,p_category                    in varchar2
                                                            default null

                              ,p_el_jurisdiction_code            in varchar2
                                                            default null
                              ,p_final_rate                  in number
                                                             default null
                              ,p_ytd_flag                    in varchar2
                              )
  IS

    cursor c_non_sep_check(cp_pymt_assignment_action_id in number
                          ,cp_sepchk_run_type_id        in number) is
      select paa.assignment_action_id
        from pay_action_interlocks pai,
             pay_assignment_actions paa,
             pay_payroll_actions ppa
       where pai.locking_action_id = cp_pymt_assignment_action_id
         and paa.assignment_action_id = pai.locked_action_id
         and paa.payroll_action_id = ppa.payroll_action_id
         and ppa.action_type in ('Q','R')
         and ((nvl(paa.run_type_id, ppa.run_type_id) is null and
               source_action_id is null) or
              (nvl(paa.run_type_id, ppa.run_type_id) is not null and
               source_action_id is not null and
               paa.run_type_id <> cp_sepchk_run_type_id));


    ln_current_hours           NUMBER(15,2);
    ln_payments_amount         NUMBER(15,2);
    ln_ytd_hours               NUMBER(15,2);
    ln_ytd_amount              NUMBER(17,2);

    ln_pymt_defined_balance_id NUMBER;
    ln_pymt_hours_balance_id   NUMBER;
    ln_ytd_defined_balance_id  NUMBER;
    ln_ytd_hours_balance_id    NUMBER;

    lv_rate_exists             VARCHAR2(1) := 'N';
    ln_nonpayroll_balcall_aaid NUMBER;

    ln_index                   NUMBER ;
    lv_action_category         VARCHAR2(50) := 'AC DEDUCTIONS';
    lv_procedure_name          VARCHAR2(100):= '.populate_elements';
    lv_error_message           VARCHAR2(200);

    ln_step                    NUMBER;

  BEGIN
      ln_step := 1;
      hr_utility.set_location(gv_package || lv_procedure_name, 10);
      hr_utility.trace('p_pymt_assignment_action_id '
                     ||to_char(p_pymt_assignment_action_id));
      hr_utility.trace('p_pymt_eff_date      ='||to_char(p_pymt_eff_date));
      hr_utility.trace('p_element_type_id    ='||to_char(p_element_type_id));
      hr_utility.trace('p_primary_balance_id ='||to_char(p_primary_balance_id));
      hr_utility.trace('p_processing_priority='||to_char(p_processing_priority));
      hr_utility.trace('p_reporting_name     ='||p_reporting_name);
      hr_utility.trace('p_ytd_balcall_aaid   ='||to_char(p_ytd_balcall_aaid));
      hr_utility.trace('p_pymt_balcall_aaid  ='||to_char(p_pymt_balcall_aaid));
      hr_utility.trace('p_legislation_code   ='||p_legislation_code);
      hr_utility.trace('p_hours_balance_id   ='||to_char(p_hours_balance_id));

      if pay_emp_action_arch.gv_multi_leg_rule is null then
         pay_emp_action_arch.gv_multi_leg_rule
               := pay_emp_action_arch.get_multi_legislative_rule(
                                                  p_legislation_code);
      end if;

      ln_step := 2;
      if p_jurisdiction_code <> '00-000-0000' then
         pay_balance_pkg.set_context('JURISDICTION_CODE', p_jurisdiction_code);
         gv_ytd_balance_dimension := gv_dim_asg_jd_gre_ytd;
      else
         pay_balance_pkg.set_context('JURISDICTION_CODE', p_jurisdiction_code);
         if gv_reporting_level = 'TAXGRP' then
            gv_ytd_balance_dimension := gv_dim_asg_tg_ytd;
         else
            gv_ytd_balance_dimension := gv_dim_asg_gre_ytd;
         end if;
      end if;


      ln_step := 3;
      /*********************************************************
      ** Get the defined balance_id for YTD call as it will be
      ** same for all classification types.
      *********************************************************/
      ln_ytd_defined_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                             p_primary_balance_id,
                                             gv_ytd_balance_dimension,
                                             p_legislation_code);

      hr_utility.trace('ln_ytd_defined_balance_id = ' ||
                          ln_ytd_defined_balance_id);

      ln_step := 4;
      if p_hours_balance_id is not null then
         hr_utility.set_location(gv_package || lv_procedure_name, 20);
         ln_ytd_hours_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                            p_hours_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);

           hr_utility.trace('ln_ytd_hours_balance_id = ' ||
                             ln_ytd_hours_balance_id);

      end if;

      ln_step := 5;
      if p_legislation_code <> 'US' then
         hr_utility.set_location(gv_package || lv_procedure_name, 30);
         ln_step := 6;
         check_hours_by_rate(
                 p_xfr_action_id               => p_xfr_action_id
                ,p_puv_assignment_action_id    => p_pymt_assignment_action_id
                ,p_element_classification_name => p_element_classification_name
                ,p_reporting_name              => p_reporting_name
                ,p_element_type_id             => p_element_type_id
                ,p_primary_balance_id          => p_primary_balance_id
                ,p_processing_priority         => p_processing_priority
                ,p_tax_unit_id                 => p_tax_unit_id
                ,p_pymt_eff_date               => p_pymt_eff_date
                ,p_ytd_balcall_aaid            => p_ytd_balcall_aaid
                ,p_ytd_defined_balance_id      => ln_ytd_defined_balance_id
                ,p_ytd_hours_balance_id        => ln_ytd_hours_balance_id
                ,p_rate_exists                 => lv_rate_exists
                );
      end if;

      hr_utility.trace('lv_rate_exists = ' || lv_rate_exists);

      if lv_rate_exists = 'N' then
         ln_step := 7;
         hr_utility.set_location(gv_package || lv_procedure_name, 40);
         if ln_ytd_defined_balance_id is not null then
            ln_ytd_amount := nvl(pay_balance_pkg.get_value(
                                      ln_ytd_defined_balance_id,
                                      p_ytd_balcall_aaid),0);
         end if;

         if p_hours_balance_id is not null then
            hr_utility.set_location(gv_package || lv_procedure_name, 50);
            if ln_ytd_hours_balance_id is not null then
               ln_ytd_hours := nvl(pay_balance_pkg.get_value(
                                      ln_ytd_hours_balance_id,
                                      p_ytd_balcall_aaid),0);
               hr_utility.set_location(gv_package || lv_procedure_name, 60);
            end if;
         end if; --Hours

         ln_step := 8;
         if p_pymt_balcall_aaid is not null then
            ln_step := 10;
            /* Added dimension _ASG_GRE_RUN for reversals and Balance
               Adjustments for Canada. Bug#3498653 */
            if p_action_type in ('B','V') then
               ln_pymt_defined_balance_id
                    := pay_emp_action_arch.get_defined_balance_id(
                                                 p_primary_balance_id,
                                                 '_ASG_GRE_RUN',
                                                 p_legislation_code);
            else
               if pay_emp_action_arch.gv_multi_leg_rule = 'Y' then
                  ln_pymt_defined_balance_id
                     := pay_emp_action_arch.get_defined_balance_id(
                                                 p_primary_balance_id,
                                                 '_ASG_PAYMENTS',
                                                 p_legislation_code);
               else
                  ln_pymt_defined_balance_id
                     := pay_emp_action_arch.get_defined_balance_id(
                                                 p_primary_balance_id,
                                                 '_PAYMENTS',
                                                 p_legislation_code);
               end if;
            end if; -- p_action_type in ('B','V')
            /* end of addition for Reversals and bal adjustments */
            hr_utility.trace('ln_pymt_defined_balance_id ' ||
                              ln_pymt_defined_balance_id);

            if ln_pymt_defined_balance_id is not null then
               ln_payments_amount := nvl(pay_balance_pkg.get_value(
                                               ln_pymt_defined_balance_id,
                                               p_pymt_balcall_aaid),0);
               hr_utility.trace('ln_payments_amount = ' ||ln_payments_amount);
            end if;

            if p_hours_balance_id is not null then
               /* Added dimension _ASG_GRE_RUN for reversals and Balance
                  Adjustments for Canada. Bug#3498653 */
               if p_action_type in ('B','V') then
                  ln_pymt_hours_balance_id
                        := pay_emp_action_arch.get_defined_balance_id(
                                                   p_hours_balance_id
                                                   ,'_ASG_GRE_RUN'
                                                   ,p_legislation_code);
               else
                  if pay_emp_action_arch.gv_multi_leg_rule = 'Y' then
                     ln_pymt_hours_balance_id
                        := pay_emp_action_arch.get_defined_balance_id(
                                                   p_hours_balance_id
                                                   ,'_ASG_PAYMENTS'
                                                   ,p_legislation_code);
                  else
                     ln_pymt_hours_balance_id
                        := pay_emp_action_arch.get_defined_balance_id(
                                                   p_hours_balance_id
                                                   ,'_PAYMENTS'
                                                   ,p_legislation_code);
                  end if;
               end if; -- p_action_type in ('B','V')
               /* end of addition for reversals and bal adjustments */
               hr_utility.trace('ln_pymt_hours_balance_id ' ||
                                 ln_pymt_hours_balance_id);

               if ln_pymt_hours_balance_id is not null then
                  ln_current_hours   := nvl(pay_balance_pkg.get_value(
                                                ln_pymt_hours_balance_id,
                                                p_pymt_balcall_aaid),0);
               end if;
               hr_utility.set_location(gv_package || lv_procedure_name, 120);
            end if; --Hours
         end if; -- p_pymt_balcall_aaid is not null

         ln_step := 15;
         if nvl(ln_ytd_amount, 0) <> 0 or nvl(ln_payments_amount, 0) <> 0 then
            ln_index := pay_ac_action_arch.lrr_act_tab.count;
            if p_element_classification_name in ('Earnings',
                                                 'Supplemental Earnings',
                                                 'Taxable Benefits',
                                                 'Imputed Earnings',
                                                 'Non-payroll Payments',
                                                 'Alien/Expat Earnings') then
               hr_utility.set_location(gv_package || lv_procedure_name, 125);
               lv_action_category := 'AC EARNINGS';
/* bug 6702864 We are not subtracting the Retro amount from the base element  so added the if condition */
/*               pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                         := fnd_number.number_to_canonical(ln_current_hours);
*/
               IF p_ytd_flag = 'N' then
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                         := fnd_number.number_to_canonical(ln_current_hours);
               ELSE
                      pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                         := fnd_number.number_to_canonical((ln_current_hours) - gv_ytd_hour);
               END IF;

	         IF ln_current_hours <> 0 AND ln_payments_amount <> 0 THEN
                   pay_ac_action_arch.lrr_act_tab(ln_index).act_info22
                   := ln_payments_amount/ln_current_hours;/*Bug 3311866*/

               ELSE
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info22 := null;
               END IF;

               IF p_ytd_flag = 'N' then
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                         := fnd_number.number_to_canonical(ln_ytd_hours);
               ELSE
                      pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                         := fnd_number.number_to_canonical((ln_ytd_hours) - gv_ytd_hour);
               END IF;
            end if;

            hr_utility.set_location(gv_package || lv_procedure_name, 130);
            /* Insert this into the plsql table if Current or YTD
               amount is not Zero */
             pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                    := lv_action_category;
             pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                   := nvl(p_jurisdiction_code, '00-000-0000');
             pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                   := p_xfr_action_id;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                   := p_element_classification_name;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                   := p_element_type_id;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                   := p_primary_balance_id;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                   := p_processing_priority;
/* bug 6702864 We are not subtracting the Retro amount from the base element  so added the if condition */
/*             pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                   := fnd_number.number_to_canonical(nvl(ln_payments_amount,0));
*/

             IF p_ytd_flag = 'N' then
                  pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                   := fnd_number.number_to_canonical(nvl(ln_payments_amount,0));
             ELSE
                  pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                   := fnd_number.number_to_canonical(nvl(ln_payments_amount,0) - gv_ytd_amount);
             END IF;

             hr_utility.trace('ln_amount := '||fnd_number.number_to_canonical(nvl(ln_payments_amount,0)));

             IF p_ytd_flag = 'N' then
                  pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                      := fnd_number.number_to_canonical(nvl(ln_ytd_amount,0));
             ELSE
                  pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                      := fnd_number.number_to_canonical((ln_ytd_amount) - gv_ytd_amount);
             END IF;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                   := p_reporting_name;
             IF lv_action_category = 'AC DEDUCTIONS' THEN
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info24
                   := p_reporting_name;
             END IF;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info17
                   := p_original_date_earned;
                                  hr_utility.trace('p_original_date_earned :=' || p_original_date_earned );
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info18
                   := p_effective_start_date;
                   hr_utility.trace('p_effective_start_date := ' || p_effective_start_date );
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info19
                   := p_effective_end_date ;
                  hr_utility.trace('p_effective_end_date:= ' || p_effective_end_date );
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info20
                   := p_category;
                   hr_utility.trace('p_category ' || p_category );
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info21
                   := p_el_jurisdiction_code;

         end if;

         end if; -- lv_rate_exists = 'N'



      hr_utility.set_location(gv_package || lv_procedure_name, 150);
      ln_step := 20;

  EXCEPTION
     when others then
      hr_utility.set_location(gv_package || lv_procedure_name, 200);
      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_elements;

  /******************************************************************
   Name      : populate_hours_x_rate
   Purpose   : The procedure gets all 'Hours by Rate' elements which
               have been processed in a given pre-payment.
               This also gets current and YTD amount,
               stores the values in a PL/SQL table.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE populate_hours_x_rate(p_xfr_action_id        in number
                                 ,p_curr_pymt_action_id  in number
                                 ,p_curr_pymt_eff_date   in date
                                 ,p_assignment_id        in number
                                 ,p_tax_unit_id          in number
                                 ,p_sepchk_run_type_id   in number
                                 ,p_sepchk_flag          in varchar2
                                 ,p_pymt_balcall_aaid    in number
                                 ,p_ytd_balcall_aaid     in number
                                 ,p_legislation_code     in varchar2
                                 )

  IS

    cursor c_run_aa_id(cp_pymt_action_id in number
                      ,cp_assignment_id  in number ) is
    select paa.assignment_action_id
          ,paa.run_type_id
    from   pay_assignment_actions paa,
           pay_action_interlocks pai
    where  pai.locking_action_id = cp_pymt_action_id
    and    paa.assignment_action_id = pai.locked_action_id
    and    paa.assignment_id = cp_assignment_id
    and    paa.run_type_id is not null
    and    not exists ( select 1
                        from   pay_run_types_f prt
                        where  prt.legislation_code = 'CA'
                        and    prt.run_type_id = paa.run_type_id
                        and    prt.run_method  = 'C' );

    cursor c_hbr(cp_assignment_action_id in number) is
       select hours.element_type_id,
              hours.element_name,
              hours.processing_priority,
              hours.rate,
              hours.multiple,
              hours.hours,
              hours.amount,
              hours.assignment_action_id
         from pay_hours_by_rate_v hours
        where hours.assignment_action_id = cp_assignment_action_id
          and legislation_code in ('US', 'CA') -- Bug 3370112
	  and hours.element_type_id >= 0  -- Bug 3370112
        order by hours.processing_priority,hours.element_type_id;

    cursor c_reporting_name(cp_element_type_id in number
                           ,cp_language in varchar2) is
      select nvl(reporting_name, element_name)
        from pay_element_types_f_tl
       where element_type_id = cp_element_type_id
         and language        = cp_language;

    cursor c_classification(cp_element_type_id in number ) is
      select pec.classification_name,
             pet.element_information10 primary_balance_id,
             pet.element_information12 hours_balance_id
        from pay_element_types_f pet,
             pay_element_classifications pec
       where pet.element_type_id   = cp_element_type_id
         and p_curr_pymt_eff_date between pet.effective_start_date
                                      and pet.effective_end_date
         and pec.classification_id = pet.classification_id;

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
    lv_element_name        VARCHAR2(150);
    ln_processing_priority NUMBER;

    ln_rate            NUMBER;
    ln_multiple        NUMBER;
    ln_hours           NUMBER;
    ln_amount          NUMBER;

    lv_reporting_name      VARCHAR2(150);
    lv_classification_name VARCHAR2(150);
    ln_primary_balance_id  NUMBER;
    ln_hours_balance_id    NUMBER;

    ln_payments_amount NUMBER(15,2);
    ln_ytd_hours       NUMBER(15,2) := 0;
    ln_ytd_amount      NUMBER(15,2) := 0;

    ln_tot_pymt_amt    NUMBER(15,2);
    ln_pymt_def_bal_id NUMBER;
    ln_pymt_bal_amt    NUMBER(15,2);

    ln_index           NUMBER ;

    prev_element_type_id  NUMBER := -1;
    prev_run_asg_act_id   NUMBER := -1;

    ln_gre_ytd_defined_bal_id   NUMBER;
    ln_tg_ytd_defined_bal_id    NUMBER;
    ln_hours_ytd_defined_bal_id NUMBER;
    lv_procedure_name           VARCHAR2(100) := '.populate_hours_x_rate';
    lv_error_message            VARCHAR2(200);
    ln_step                     NUMBER;

    ln_assignment_action_id     NUMBER;
    ln_run_type_id              NUMBER;

    ln_retro_rate          NUMBER(15,5);
    ln_retro_multiple      NUMBER(15,5);
    ln_retro_hours         NUMBER(15,5);
    ln_retro_payvalue      NUMBER(15,5);
    ln_retro_element_entry NUMBER;

    i  NUMBER := 0;

    hbr  pay_ac_action_arch.hbr_table;

  BEGIN


      ln_step := 1;
      hr_utility.set_location(gv_package || lv_procedure_name, 10);
      hr_utility.trace('HBR p_curr_pymt_action_id : ' || p_curr_pymt_action_id);
      hr_utility.trace('HBR p_assignment_id : ' || p_assignment_id);

      hbr.delete;
      ln_tot_pymt_amt := 0;

      open c_run_aa_id(p_curr_pymt_action_id, p_assignment_id);
      loop
         fetch c_run_aa_id into ln_assignment_action_id
                               ,ln_run_type_id;
         exit when c_run_aa_id%notfound;

         hr_utility.trace('HBR ln_assignment_action_id : ' ||
                               ln_assignment_action_id);

         ln_step := 2;

         open  c_hbr(ln_assignment_action_id);
         loop
            fetch c_hbr into hbr(i);

            exit when c_hbr%notfound;

            i := i + 1;
         end loop;
         close c_hbr;

      end loop;
      close c_run_aa_id;

      if hbr.count > 0 then
      hr_utility.trace(' I came in first if ');

         for j in hbr.first..hbr.last + 1
         loop

            if ( j <> i ) then
              hr_utility.trace(' It came here one');
               ln_element_type_id      := hbr(j).element_type_id;
               lv_element_name         := hbr(j).element_name;
               ln_processing_priority  := hbr(j).processing_priority;
               ln_rate                 := hbr(j).rate;
               ln_multiple             := hbr(j).multiple;
               ln_hours                := hbr(j).hours;
               ln_amount               := hbr(j).amount;
                 hr_utility.trace('element_type_id'||hbr(j).element_type_id);
                 hr_utility.trace('element_name'||hbr(j).element_name);
                 hr_utility.trace('hbr(j).rate'||hbr(j).rate);
            end if;

            ln_step := 3;

            if ( ( ln_element_type_id <> prev_element_type_id and
                   prev_element_type_id <> -1 ) or
                 ( j = i )
                ) then

                hr_utility.trace('I came here two');

               ln_step := 5;
               if gv_reporting_level = 'TAXGRP' then
                     ln_tg_ytd_defined_bal_id
                         := pay_emp_action_arch.get_defined_balance_id
                                           (ln_primary_balance_id,
                                            gv_dim_asg_tg_ytd,
                                            p_legislation_code);
                     ln_hours_ytd_defined_bal_id
                         := pay_emp_action_arch.get_defined_balance_id
                                           (ln_hours_balance_id,
                                            gv_dim_asg_tg_ytd,
                                            p_legislation_code);
                     if ln_tg_ytd_defined_bal_id is not null then
                        ln_ytd_amount := nvl(pay_balance_pkg.get_value(
                                               ln_tg_ytd_defined_bal_id,
                                               p_ytd_balcall_aaid),0);
                     end if;
                     if ln_hours_ytd_defined_bal_id is not null then
                        ln_ytd_hours  := nvl(pay_balance_pkg.get_value(
                                                ln_hours_ytd_defined_bal_id,
                                                p_ytd_balcall_aaid),0);
                     end if;
               else
                     ln_step := 10;
                     ln_gre_ytd_defined_bal_id
                         := pay_emp_action_arch.get_defined_balance_id
                                           (ln_primary_balance_id,
                                            gv_dim_asg_gre_ytd,
                                            p_legislation_code);
                     ln_hours_ytd_defined_bal_id
                         := pay_emp_action_arch.get_defined_balance_id
                                           (ln_hours_balance_id,
                                            gv_dim_asg_gre_ytd,
                                            p_legislation_code);
                     if ln_gre_ytd_defined_bal_id is not null then
                        ln_ytd_amount := nvl(pay_balance_pkg.get_value(
                                               ln_gre_ytd_defined_bal_id,
                                               p_ytd_balcall_aaid),0);
                     end if;
                     if ln_hours_ytd_defined_bal_id is not null then
                        ln_ytd_hours  := nvl(pay_balance_pkg.get_value(
                                               ln_hours_ytd_defined_bal_id,
                                               p_ytd_balcall_aaid),0);
                     end if;
               end if;

               hr_utility.trace('ytd balance = ' || ln_ytd_amount);
               hr_utility.trace('ytd hours = '   || ln_ytd_hours);
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                      := ln_ytd_amount;
               pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                      := ln_ytd_hours;

               ln_ytd_amount := 0;
               ln_ytd_hours  := 0;

               ln_pymt_def_bal_id
                         := pay_emp_action_arch.get_defined_balance_id
                                           (ln_primary_balance_id,
                                            '_ASG_PAYMENTS',
                                            p_legislation_code);

               ln_pymt_bal_amt := nvl(pay_balance_pkg.get_value(
                                               ln_pymt_def_bal_id,
                                               p_pymt_balcall_aaid),0);

               hr_utility.trace('ln_pymt_bal_amt : '||ln_pymt_bal_amt);
               hr_utility.trace('ln_tot_pymt_amt : '||ln_tot_pymt_amt);
               hr_utility.trace('prev_element_type_id: '||prev_element_type_id);
               hr_utility.trace('prev_run_asg_act_id : '||prev_run_asg_act_id);

               IF ( ln_tot_pymt_amt <> ln_pymt_bal_amt ) THEN

               hr_utility.trace('i came here third');

                  OPEN c_retro(prev_run_asg_act_id, prev_element_type_id);
                  LOOP
                    hr_utility.set_location(gv_package || lv_procedure_name,55);
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

                    IF nvl(ln_retro_multiple,0) = 0 THEN
                       ln_retro_multiple := 1;
                    END IF;

                    ln_index := pay_ac_action_arch.lrr_act_tab.count;
                    hr_utility.trace('ln_index = ' || ln_index);


                    ln_step := 20;
                    pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                          := 'AC EARNINGS';

                    pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                          := '00-000-0000';
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                          := lv_classification_name;
                    hr_utility.trace('action_info_category' || lv_classification_name);
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                          := prev_element_type_id;
                    hr_utility.trace('act_info2' || prev_element_type_id);
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                          := ln_primary_balance_id;
                    hr_utility.trace('act_info6' || ln_primary_balance_id);
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                          := ln_processing_priority;
                    hr_utility.trace('act_info7' || ln_processing_priority);
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                          := fnd_number.number_to_canonical(ln_retro_payvalue);
                    hr_utility.trace('act_info8' || fnd_number.number_to_canonical(ln_retro_payvalue));
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                          := 0;
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                          := lv_reporting_name;
                    hr_utility.trace('act_info10' || lv_reporting_name);
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                          := fnd_number.number_to_canonical(ln_retro_hours);
                    hr_utility.trace('act_info11' || fnd_number.number_to_canonical(ln_retro_hours));
                    pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                          := p_xfr_action_id;
                    hr_utility.trace('action_context_id' || p_xfr_action_id);

                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info13
                          := fnd_number.number_to_canonical(ln_retro_rate * ln_retro_multiple);
                    hr_utility.trace('act_info13' || fnd_number.number_to_canonical(ln_retro_rate * ln_retro_multiple));
                  END LOOP;
                  CLOSE c_retro;
                  hr_utility.set_location(gv_package || lv_procedure_name, 77);

               END IF;

               ln_tot_pymt_amt := 0;
               ln_pymt_bal_amt := 0;

               if ( j = i ) then
                  exit;
               end if;
            end if;

            hr_utility.trace('lv_element_name = ' || lv_element_name);
            hr_utility.trace('ln_rate = '     || ln_rate);
            hr_utility.trace('ln_amount = '   || ln_amount);
            hr_utility.trace('ln_multiple = ' || ln_multiple);
            hr_utility.trace('ln_hours = '    || ln_hours);

            lv_reporting_name := lv_element_name;

            ln_step := 15;

            open  c_reporting_name(ln_element_type_id,
                                   gv_person_lang);
            fetch c_reporting_name into lv_reporting_name;
            if ( c_reporting_name%notfound ) then
               lv_reporting_name := lv_element_name;
            end if;
            close c_reporting_name;

            open  c_classification(ln_element_type_id);
            fetch c_classification into lv_classification_name
                                       ,ln_primary_balance_id
                                       ,ln_hours_balance_id;
            close c_classification;

            ln_payments_amount := ln_amount;
            ln_tot_pymt_amt   := ln_tot_pymt_amt + ln_payments_amount;

            /*Insert this into the plsql table */

            hr_utility.set_location(gv_package || lv_procedure_name, 40);
            ln_index := pay_ac_action_arch.lrr_act_tab.count;
            hr_utility.trace('ln_index = ' || ln_index);


            ln_step := 20;
            pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                  := 'AC EARNINGS';
            pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                  := '00-000-0000';
            pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                  := lv_classification_name;
            hr_utility.trace('action_info_category2' || lv_classification_name);
            pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                  := ln_element_type_id;
            hr_utility.trace('act_info22' || prev_element_type_id);
            pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                  := ln_primary_balance_id;
            hr_utility.trace('act_info62' || ln_primary_balance_id);
            pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                  := ln_processing_priority;
            hr_utility.trace('act_info72' || ln_processing_priority);
            pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                  := fnd_number.number_to_canonical(ln_payments_amount);
            hr_utility.trace('act_info82' || fnd_number.number_to_canonical(ln_retro_payvalue)); /* Bug 3311866*/
            pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                  := fnd_number.number_to_canonical(ln_ytd_amount);

            pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                  := lv_reporting_name;
                  hr_utility.trace('act_info102' || lv_reporting_name);
            pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                  := fnd_number.number_to_canonical(ln_hours);
            hr_utility.trace('act_info112' || fnd_number.number_to_canonical(ln_retro_hours));
            pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                  := p_xfr_action_id;
--         pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
--                := fnd_number.number_to_canonical(ln_ytd_hours);
            pay_ac_action_arch.lrr_act_tab(ln_index).act_info13
                  := fnd_number.number_to_canonical(ln_rate * nvl(ln_multiple,1));
            hr_utility.trace('act_info13' || fnd_number.number_to_canonical(ln_retro_rate * ln_retro_multiple));
            prev_element_type_id := ln_element_type_id;
            prev_run_asg_act_id  := hbr(j).run_asg_act_id;
         end loop;
      end if;

      hr_utility.set_location(gv_package || lv_procedure_name, 40);
      ln_step := 25;
 --hr_utility.trace_off;

  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_hours_x_rate;


  /******************************************************************
   Name      : get_current_elements
   Purpose   : The procedure gets all the elements which have
               been processed in a given pre-payment.
               It also calls the populate_elements procedure
               which calls the Current and YTD balances and
               stores the values in a PL/SQL table.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE get_current_elements(p_xfr_action_id        in number
                                ,p_curr_pymt_action_id  in number
                                ,p_curr_pymt_eff_date   in date
                                ,p_assignment_id        in number
                                ,p_tax_unit_id          in number
                                ,p_sepchk_run_type_id   in number
                                ,p_sepchk_flag          in varchar2
                                ,p_pymt_balcall_aaid    in number
                                ,p_ytd_balcall_aaid     in number
                                ,p_legislation_code     in varchar2
                                ,p_action_type     in varchar2 default null
                                )

  IS


CURSOR get_run_action_id(cp_pre_as_action_id  in number
                        ,cp_assignment_id     in number
                        ,cp_sepchk_run_type_id in number
                              ) IS
SELECT paa_run.assignment_action_id
  FROM pay_action_interlocks pai
      ,pay_assignment_actions paa_run
      ,pay_payroll_actions ppa_run
 WHERE pai.locking_action_id = cp_pre_as_action_id
   AND pai.locked_action_id = paa_run.assignment_action_id
   AND paa_run.assignment_id =  cp_assignment_id
   AND paa_run.payroll_action_id = ppa_run.payroll_action_id
   /* Added for Bug# 7580440 */
   AND ppa_run.action_type IN ('R', 'Q')
   AND ((nvl(paa_run.run_type_id, ppa_run.run_type_id) is null
         and paa_run.source_action_id is null) or
        (nvl(paa_run.run_type_id, ppa_run.run_type_id) is not null
         and paa_run.source_action_id is not null
         and paa_run.run_type_id <> cp_sepchk_run_type_id))
   /* Added for Bug#9207953 */
   AND NOT EXISTS
             ( SELECT 1
               FROM pay_assignment_actions paa_run2
               WHERE paa_run2.run_type_id is not null
                AND paa_run2.source_action_id is not null
                AND paa_run2.source_action_id = paa_run.source_action_id
                AND paa_run2.run_type_id = cp_sepchk_run_type_id
              );


 Cursor get_element_entry_id( cp_run_action_id in number ,
                              cp_assignment_id in number ,
                              cp_element_type_id in number ) IS
 SELECT distinct peef.element_entry_id
 FROM pay_element_entries_f peef,
                pay_assignment_actions paa,
                pay_payroll_actions ppa,
                per_time_periods ptp
                WHERE paa.assignment_action_id = cp_run_action_id
            AND ppa.payroll_action_id = paa.payroll_action_id
            AND ptp.payroll_id = ppa.payroll_id
            AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date
            AND peef.assignment_id = cp_assignment_id
            AND peef.element_type_id = cp_element_type_id

            /* Commenting as Ele Entry Eff Start / End Date may not match the following
            AND peef.effective_start_date BETWEEN ptp.start_date AND ptp.end_date
            AND peef.effective_end_date BETWEEN ptp.start_date AND ptp.end_date
            End of Comment */

            AND NVL(ppa.date_earned, ppa.effective_date) BETWEEN peef.effective_start_date AND peef.effective_end_date ;

  Cursor check_retro( cp_run_action_id in number ,
                              cp_assignment_id in number ,
                              cp_element_type_id in number ) IS
 SELECT distinct 'Y'
 FROM pay_element_entries_f peef,
                pay_assignment_actions paa,
                pay_payroll_actions ppa,
                per_time_periods ptp
                WHERE paa.assignment_action_id = cp_run_action_id
            AND ppa.payroll_action_id = paa.payroll_action_id
            AND ptp.payroll_id = ppa.payroll_id
            AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date
            AND peef.assignment_id = cp_assignment_id
            AND peef.element_type_id = cp_element_type_id
            AND peef.creator_type IN ('R', 'EE', 'RR', 'NR', 'PR') -- Changed 25.08.2007


            /* Commenting as Ele Entry Eff Start / End Date may not match the following
            AND peef.effective_start_date BETWEEN ptp.start_date AND ptp.end_date
            AND peef.effective_end_date BETWEEN ptp.start_date AND ptp.end_date
            End of Comment*/

            AND NVL(ppa.date_earned, ppa.effective_date) BETWEEN peef.effective_start_date AND peef.effective_end_date ;

   CURSOR retro_parent_check_flag ( cp_run_action_id in number ,
                              cp_assignment_id in number ,
                              cp_element_type_id in number ) IS
    SELECT DISTINCT 'Y'
           FROM pay_element_entries_f peef,
                pay_assignment_actions paa,
                pay_payroll_actions ppa,
                per_time_periods ptp
          WHERE paa.assignment_action_id = cp_run_action_id
            AND ppa.payroll_action_id = paa.payroll_action_id
            AND ptp.payroll_id = ppa.payroll_id
            AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date
            AND peef.assignment_id = cp_assignment_id
            AND peef.element_type_id = cp_element_type_id
            AND peef.creator_type NOT IN ('R', 'EE', 'RR', 'NR', 'PR') -- Changed on 25.08.2007

            /* Commenting as Ele Entry Eff Start / End Date may not match the following
            AND peef.effective_start_date BETWEEN ptp.start_date AND ptp.end_date
            AND peef.effective_end_date BETWEEN ptp.start_date AND ptp.end_date
            End of Comment */

            AND NVL(ppa.date_earned, ppa.effective_date) BETWEEN peef.effective_start_date AND peef.effective_end_date ;


CURSOR archive_non_retro_elements ( cp_original_date_paid in varchar2,
                                    cp_element_entry_id in number,
                                    cp_run_assignment_action_id in number ) IS

          select fnd_date.date_to_canonical(ptp.start_date),
                 fnd_date.date_to_canonical(ptp.end_date),
                hr_general.decode_lookup
                            (DECODE (UPPER (ec.classification_name),
                                     'EARNINGS', 'US_EARNINGS',
                                     'SUPPLEMENTAL EARNINGS', 'US_SUPPLEMENTAL_EARNINGS',
                                     'IMPUTED EARNINGS', 'US_IMPUTED_EARNINGS',
                                     'NON-PAYROLL PAYMENTS', 'US_PAYMENT',
                                     'ALIEN/EXPAT EARNINGS', 'PER_US_INCOME_TYPES',
                                     NULL
                                    ),
                             et.element_information1
                            ) CATEGORY
from pay_assignment_actions paa,
     pay_payroll_actions ppa,
     per_time_periods ptp,
     pay_element_entries_f peef,
     pay_element_classifications ec,
     pay_element_types et
where paa.assignment_action_id = cp_run_assignment_action_id
and   paa.payroll_action_id   = ppa.payroll_action_id
and   ptp.payroll_id = ppa.payroll_id
and   cp_original_date_paid between  ptp.start_date AND ptp.end_date
and   peef.element_entry_id = cp_element_entry_id
and   et.element_type_id = peef.element_type_id
and   et.classification_id = ec.classification_id;

CURSOR get_application_column_name IS

/* Modifying cursor for performance issue
   replacing table with FND_DESCR_FLEX_COLUMN_USAGES
   translation should not be an issue for US leg

  SELECT application_column_name
    FROM FND_DESCR_FLEX_COL_USAGE_VL
   WHERE end_user_column_name = 'Originating Pay Period'
   AND upper(descriptive_flexfield_name) = upper('PAY_ELEMENT_ENTRIES')
     AND upper(descriptive_flex_context_code) = 'US EARNINGS';
*/

SELECT fnd_flex.application_column_name
FROM fnd_application fnd_appl
    ,fnd_descr_flex_column_usages fnd_flex
 WHERE fnd_appl.application_short_name = 'PAY'
 AND   fnd_appl.application_id = fnd_flex.application_id
 AND   fnd_flex.descriptive_flexfield_name = 'PAY_ELEMENT_ENTRIES'
 AND   UPPER(fnd_flex.descriptive_flex_context_code) = 'US EARNINGS'
 and   fnd_flex.end_user_column_name = 'Originating Pay Period';

 CURSOR get_num_addnl_elements ( cp_run_action_id    IN NUMBER,
                                 cp_assignment_id    IN NUMBER,
                                 cp_element_type_id  IN NUMBER) IS

       SELECT COUNT (*)
           FROM pay_element_entries_f peef,
                pay_assignment_actions paa,
                pay_payroll_actions ppa,
                per_time_periods ptp
          WHERE paa.assignment_action_id = cp_run_action_id
            AND ppa.payroll_action_id = paa.payroll_action_id
            AND ptp.payroll_id = ppa.payroll_id
            AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date
            AND peef.assignment_id = cp_assignment_id
            AND peef.element_type_id = cp_element_type_id
            AND peef.creator_type NOT IN ('R', 'EE', 'RR', 'NR', 'PR')

            /* Commenting as Ele Entry Eff Start / End Date may not match the following
            AND peef.effective_start_date BETWEEN ptp.start_date AND ptp.end_date
            AND peef.effective_end_date BETWEEN ptp.start_date AND ptp.end_date
            End of Comment */

            AND NVL(ppa.date_earned, ppa.effective_date) BETWEEN peef.effective_start_date AND peef.effective_end_date ;

-- Added For Work At Home Condition

    CURSOR c_cur_get_wrkathome(cp_assignment_id IN NUMBER) IS
      SELECT NVL(paf.work_at_home, 'N')
            ,ppf.person_id
            ,ppf.business_group_id
      FROM per_assignments_f paf
          ,per_all_people_f ppf
      WHERE paf.assignment_id = cp_assignment_id
      AND   paf.person_id = ppf.person_id;

    CURSOR c_cur_home_state_jd(cp_person_id IN NUMBER
                              ,cp_bg_id     IN NUMBER) IS
      SELECT pus.state_code || '-000-0000'
      FROM per_addresses pa
          ,pay_us_states pus
      WHERE pa.person_id = cp_person_id
      AND   pa.primary_flag = 'Y'
      AND   p_curr_pymt_eff_date between pa.date_from AND NVL(pa.date_to, hr_general.END_OF_TIME)
      AND   pa.business_group_id = cp_bg_id
      AND   pa.region_2 = pus.state_abbrev
      AND   pa.style = p_legislation_code;

    cursor c_cur_sp_action_elements(cp_pymt_action_id   in number
                                   ,cp_assignment_id    in number
                                   ,cp_sepchk_run_type  in number
                                   ,cp_sepchk_flag      in varchar2
                                ) is
      select distinct prr.element_type_id,
             pec.classification_name,
             nvl(petl.reporting_name, petl.element_name),
             pet.element_information10,
             pet.element_information12,
             pet.processing_priority
        from pay_assignment_actions paa,
             pay_payroll_actions ppa,
             pay_run_results prr,
             pay_element_types_f pet,
             pay_element_classifications pec,
             pay_element_types_f_tl petl
      where paa.assignment_id = cp_assignment_id
        and prr.assignment_action_id = paa.assignment_action_id
        and cp_sepchk_flag = 'Y'
        and paa.assignment_action_id = cp_pymt_action_id
        and nvl(paa.run_type_id, cp_sepchk_run_type) = cp_sepchk_run_type
        and ppa.payroll_action_id = paa.payroll_action_id
        and pet.element_type_id = prr.element_type_id
        and pet.element_information10 is not null
        and ppa.effective_date between pet.effective_start_date
                                   and pet.effective_end_date
        and petl.element_type_id  = pet.element_type_id
        and petl.language         = gv_person_lang
        and pec.classification_id = pet.classification_id
        and pec.classification_name in ('Earnings',
                                        'Alien/Expat Earnings',
                                        'Supplemental Earnings',
                                        'Imputed Earnings',
                                        'Taxable Benefits',
                                        'Pre-Tax Deductions',
                                        'Involuntary Deductions',
                                        'Voluntary Deductions',
                                        'Non-payroll Payments'
                                         )
        and pet.element_name not like '%Calculator'
        and pet.element_name not like '%Special Inputs'
        and pet.element_name not like '%Special Features'
        and pet.element_name not like '%Special Features 2'
        and pet.element_name not like '%Verifier'
        and pet.element_name not like '%Priority'
      order by pec.classification_name;

    cursor c_cur_action_elements(cp_pymt_action_id   in number
                                ,cp_assignment_id    in number
                                ,cp_sepchk_run_type  in number
                                ,cp_sepchk_flag      in varchar2
                                ,cp_ytd_act_sequence in number
                                ) is
      select distinct pet.element_type_id,
             pec.classification_name,
             nvl(petl.reporting_name, petl.element_name),
             pet.element_information10,
             pet.element_information12,
             pet.processing_priority
        from pay_action_interlocks pai,
             pay_assignment_actions paa,
             pay_payroll_actions ppa,
             pay_all_payrolls_f ppf,
             pay_run_results prr,
             pay_element_types_f pet,
             pay_element_classifications pec,
             pay_element_types_f_tl petl
      where paa.assignment_id = cp_assignment_id
        and prr.assignment_action_id = paa.assignment_action_id
        and cp_sepchk_flag = 'N'
        and pai.locking_action_id = cp_pymt_action_id
        and paa.assignment_action_id = pai.locked_action_id
        and paa.action_sequence <= cp_ytd_act_sequence
        and ppa.payroll_action_id = paa.payroll_action_id
        and pet.element_type_id = prr.element_type_id
        and pet.element_information10 is not null
        and ppa.effective_date between pet.effective_start_date
                                   and pet.effective_end_date
        and ppa.payroll_id = ppf.payroll_id  -- Bug 3370112
        and ppf.payroll_id >= 0
        and ppa.effective_date between ppf.effective_start_date
            and ppf.effective_end_date
        and petl.element_type_id  = pet.element_type_id
        and petl.language         = gv_person_lang
        and pec.classification_id = pet.classification_id
        and pec.classification_name in ('Earnings',
                                        'Alien/Expat Earnings',
                                        'Supplemental Earnings',
                                        'Imputed Earnings',
                                        'Taxable Benefits',
                                        'Pre-Tax Deductions',
                                        'Involuntary Deductions',
                                        'Voluntary Deductions',
                                        'Non-payroll Payments'
                                         )
        and pet.element_name not like '%Calculator'
        and pet.element_name not like '%Special Inputs'
        and pet.element_name not like '%Special Features'
        and pet.element_name not like '%Special Features 2'
        and pet.element_name not like '%Verifier'
        and pet.element_name not like '%Priority'
      order by pec.classification_name;

  cursor c_ytd_action_seq(cp_asg_act_id in number) is
    select  paa.action_sequence
    from    pay_assignment_actions paa
    where   paa.assignment_action_id = cp_asg_act_id;
--Bug 6950970 starts here
  CURSOR get_payroll_date_earned(cp_run_action_id    IN NUMBER) IS
        SELECT
        TO_CHAR(TRUNC(fnd_date.canonical_to_date(fnd_date.date_to_canonical(ppa.date_earned))),'DD-MON-YYYY')
         FROM pay_assignment_actions paa,
                 pay_payroll_actions ppa
           WHERE paa.assignment_action_id = cp_run_action_id
            AND ppa.payroll_action_id = paa.payroll_action_id;
l_date_earned                       VARCHAR2(100);
--Bug 6950970 ends here
    ln_element_type_id             NUMBER;
    lv_element_classification_name VARCHAR2(80);
    lv_reporting_name              VARCHAR2(80);
    ln_primary_balance_id          NUMBER;
    ln_hours_balance_id            NUMBER;
    ln_processing_priority         NUMBER;
    ln_ytd_action_sequence         NUMBER;

    ln_element_index               NUMBER ;
    lv_procedure_name              VARCHAR2(100) := '.get_current_elements';
    lv_error_message               VARCHAR2(200);
    ln_step                        NUMBER;
    lv_original_date_earned        VARCHAR2(100);
    lv_effective_start_date        VARCHAR2(100);
    lv_effective_end_date          VARCHAR2(100);
    lv_category                    VARCHAR2(100);
    ln_run_assignment_action_id    NUMBER;
    ln_element_entry_id            NUMBER;
    lv_original_date_paid          VARCHAR2(100);
    lv_application_column_name     VARCHAR2(100);
    lv_sqlstr                      varchar2(300);
    ld_original_date_paid          date;
    ln_flag                        number;
    lv_jurisdiction_flag           varchar2(20);
    ln_rate                        number := null ;
    ln_final_rate                  number := null ;
    lv_retro_flag                  varchar2(100) :='N';
    ln_multiple                    number ;
    ln_addnl_ele_num               number ;
    lv_retro_parent_flag           varchar2(10) := 'N';
    lv_sqlstr1                     varchar2(2000);
    lv_curr_pymt_eff_date          VARCHAR2(100);
-- Added For Work At Home Condition
    lv_wrk_at_home                 per_assignments_f.work_at_home%TYPE;
    ln_person_id                   per_people_f.person_id%TYPE;
    ln_bg_id                       per_people_f.business_group_id%TYPE;

  BEGIN
      ln_flag := 0;
      ln_step := 1;
      hr_utility.set_location(gv_package || lv_procedure_name, 10);
      hr_utility.trace('p_xfr_action_id = ' || p_xfr_action_id);
      hr_utility.trace('p_assignment_id '   || p_assignment_id);
      hr_utility.trace('p_tax_unit_id '     || p_tax_unit_id);
      hr_utility.trace('p_sepchk_flag '     || p_sepchk_flag);
      hr_utility.trace('p_legislation_code '|| p_legislation_code);
      hr_utility.trace('p_curr_pymt_action_id  '
                     ||to_char(p_curr_pymt_action_id ));
      hr_utility.trace('p_ytd_balcall_aaid '  || p_ytd_balcall_aaid);
      hr_utility.trace('p_pymt_balcall_aaid ' ||p_pymt_balcall_aaid);
      hr_utility.trace('p_sepchk_run_type_id '|| p_sepchk_run_type_id);
      hr_utility.trace('p_curr_pymt_eff_date '||TO_CHAR(p_curr_pymt_eff_date,'DD-MON-YYYY'));

      hr_utility.set_location(gv_package || lv_procedure_name, 20);

      if p_legislation_code <> 'US' then
         ln_step := 5;
         populate_hours_x_rate(p_xfr_action_id        => p_xfr_action_id
                              ,p_curr_pymt_action_id  => p_curr_pymt_action_id
                              ,p_curr_pymt_eff_date   => p_curr_pymt_eff_date
                              ,p_assignment_id        => p_assignment_id
                              ,p_tax_unit_id          => p_tax_unit_id
                              ,p_sepchk_run_type_id   => p_sepchk_run_type_id
                              ,p_sepchk_flag          => p_sepchk_flag
                              ,p_pymt_balcall_aaid    => p_pymt_balcall_aaid
                              ,p_ytd_balcall_aaid     => p_ytd_balcall_aaid
                              ,p_legislation_code     => p_legislation_code);
      end if;

      ln_step := 6;
      open  c_ytd_action_seq(p_ytd_balcall_aaid);
      fetch c_ytd_action_seq into ln_ytd_action_sequence;
      close c_ytd_action_seq;

      ln_step := 10;
      if p_sepchk_flag = 'Y' then
         open c_cur_sp_action_elements(p_curr_pymt_action_id ,
                                       p_assignment_id,
                                       p_sepchk_run_type_id,
                                       p_sepchk_flag);

      elsif p_sepchk_flag = 'N' then
         open c_cur_action_elements(p_curr_pymt_action_id ,
                                    p_assignment_id,
                                    p_sepchk_run_type_id,
                                    p_sepchk_flag,
                                    ln_ytd_action_sequence);
      end if;

      loop
         if p_sepchk_flag = 'Y' then
            fetch c_cur_sp_action_elements into
                              ln_element_type_id,
                              lv_element_classification_name,
                              lv_reporting_name,
                              ln_primary_balance_id,
                              ln_hours_balance_id,
                              ln_processing_priority;
           if c_cur_sp_action_elements%notfound then
               hr_utility.set_location(gv_package || lv_procedure_name, 30);
               exit;
             end if;

             elsif p_sepchk_flag = 'N' then
            fetch c_cur_action_elements into
                              ln_element_type_id,
                              lv_element_classification_name,
                              lv_reporting_name,
                              ln_primary_balance_id,
                              ln_hours_balance_id,
                              ln_processing_priority;
           --- here one thing can be added
            if c_cur_action_elements%notfound then
               hr_utility.set_location(gv_package || lv_procedure_name, 35);
               exit;
             end if;

         end if;
      --  loop with the first coursor (if not found then exit )
      --  if the parameters from second cursor not null then exit loop else move in loop completly

       hr_utility.trace('Element_type_id in get_current_elements = ' || ln_element_type_id);

        if p_legislation_code <> 'US' then
           lv_retro_flag := 'N' ;
           lv_retro_parent_flag := 'N';
           gv_ytd_amount := 0;
           gv_ytd_hour   := 0;
           lv_original_date_earned := NULL;
           lv_effective_start_date := NULL;
           lv_effective_end_date := NULL;
           lv_category           := NULL;
           lv_jurisdiction_flag := NULL;
           lv_original_date_paid:= NULL;
        end if;

       IF p_legislation_code = 'US' THEN
         /* Added for Bug# 7580440 */
         IF p_sepchk_flag = 'Y' THEN
            ln_run_assignment_action_id := p_curr_pymt_action_id;
         ELSE
           OPEN get_run_action_id(p_curr_pymt_action_id
                                  ,p_assignment_id
                                  ,p_sepchk_run_type_id);
           /* Should NOT be needed */
           --LOOP -- For Each Run Assignment Action ID

           FETCH get_run_action_id INTO ln_run_assignment_action_id;
              /*
              IF get_run_action_id%NOTFOUND THEN
                 CLOSE get_run_action_id ;
                 EXIT;
              END IF;
              */
              CLOSE get_run_action_id ;
         END IF; -- p_sepchk_flag = 'Y'
         ln_step := 99;
         --
	   -- Following to Check IF Additional element Entry DFF Configured for the Client
	   -- This would be configured in case Client Does NOT use Retropay Functionality

            ln_step := 100;

            ln_flag := 1;

            OPEN get_application_column_name ;
            FETCH get_application_column_name INTO lv_application_column_name;
            CLOSE get_application_column_name;

            IF  lv_application_column_name IS NULL THEN
                ln_flag :=1;
            ELSE
                ln_flag :=0; -- Addl Ele DFF Info Configured
            END IF;

            hr_utility.trace('Step 100: ln_flag before entering into Ele Entry LOOP : '||ln_flag);

            -- Following Code May Need revise
	    -- Here we are NOT Looping Through the Ele Entries
	    -- But Getting ele Entry ID so that we Can Check if Addl Ele Entry Configured
	    --
            -- Check if there is any Ele Entry that is NOT created by Retro

            OPEN get_element_entry_id (ln_run_assignment_action_id,
                                       p_assignment_id ,
                                       ln_element_type_id);


            FETCH get_element_entry_id INTO ln_element_entry_id;
            IF get_element_entry_id%found THEN
                CLOSE get_element_entry_id;
                hr_utility.trace('Ele Entry Found. ln_element_entry_id := '||ln_element_entry_id);

                IF ln_flag = 0 then -- Addl Ele DFF Info Configured
                    hr_utility.trace('Addl Ele DFF Info Configured.');

		    SELECT TO_CHAR(TRUNC(fnd_date.canonical_to_date(fnd_date.date_to_canonical(p_curr_pymt_eff_date))),'DD-MON-YYYY')
		    INTO lv_curr_pymt_eff_date
		    FROM DUAL;
--bug no 6950970 starts here
	            OPEN get_payroll_date_earned (ln_run_assignment_action_id);
		    FETCH get_payroll_date_earned INTO l_date_earned;
	            CLOSE get_payroll_date_earned;
--bug no 6950970 ends here
		    hr_utility.trace('lv_curr_pymt_eff_date := '|| lv_curr_pymt_eff_date);
	            hr_utility.trace('l_date_earned := '|| l_date_earned);
                    lv_sqlstr := 'select  nvl(' || lv_application_column_name ||
                                           ',''AAA'') from pay_element_entries_f where element_entry_id = ' || ln_element_entry_id
					   ||'  AND  '
					   ||' TO_DATE('''
--bug no 6950970 starts here
--					   || lv_curr_pymt_eff_date
					   || l_date_earned
--bug no 6950970 ends here
					   ||''', ''DD-MON-YYYY'') '
					   ||' BETWEEN effective_start_date AND effective_end_date ';

		     hr_utility.trace('Query := '|| lv_sqlstr);
--bug no 6950970 starts here
begin
--bug no 6950970 ends here
		     EXECUTE IMMEDIATE lv_sqlstr INTO  lv_original_date_paid ;
                     lv_original_date_earned := lv_original_date_paid ;

                     hr_utility.trace('lv_original_date_earned := '||lv_original_date_earned);

                -- Possibility of Malformed SQL (Added Spaces between)

                     lv_sqlstr1 := 'select count(peef.' || lv_application_column_name
                               ||') FROM pay_element_entries_f peef, pay_assignment_actions paa, pay_payroll_actions ppa,per_time_periods ptp WHERE paa.assignment_action_id = '
                               || ln_run_assignment_action_id
                               || ' AND ppa.payroll_action_id = paa.payroll_action_id AND ptp.payroll_id = ppa.payroll_id AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date AND peef.assignment_id = '
                               || p_assignment_id
                               ||' AND peef.element_type_id = '
                               || ln_element_type_id
                               || ' AND NVL(ppa.date_earned, ppa.effective_date) BETWEEN peef.effective_start_date AND peef.effective_end_date AND peef.'
                               || lv_application_column_name
                               || ' is not null '  ;

                    EXECUTE IMMEDIATE lv_sqlstr1 into  ln_addnl_ele_num;
                    hr_utility.trace('ln_addnl_ele_num' || ln_addnl_ele_num);
                    hr_utility.trace('p_curr_pymt_eff_date '|| p_curr_pymt_eff_date);
--bug no 6950970 starts here
exception
    when no_data_found then
        ln_addnl_ele_num:=0;
end;
--bug no 6950970 ends here
                 END IF; -- Addl Ele DFF Info Configured
                 -- Code to be Revised Again

                 -- IF there is Element Entry for which Addl Ele Entry DFF Configured
		 -- AND Originating Date Earned Field Populated
		 --


                 IF  (( lv_original_date_paid <> 'AAA' and ln_flag =0) OR (ln_addnl_ele_num > 0))THEN

		     hr_utility.trace('(( lv_original_date_paid <> AAA and ln_flag =0) OR (ln_addnl_ele_num > 0)');

		     IF ln_addnl_ele_num > 0 THEN
                        hr_utility.trace('ln_addnl_ele_num > 0');
                        Archive_addnl_elements(
                               p_application_column_name         => lv_application_column_name
                                ,p_xfr_action_id               => p_xfr_action_id
                               ,p_assignment_id               => p_assignment_id
                               ,p_pymt_assignment_action_id   => p_curr_pymt_action_id
                               ,p_pymt_eff_date               => p_curr_pymt_eff_date
                               ,p_element_type_id             => ln_element_type_id
                               ,p_primary_balance_id          => ln_primary_balance_id
                               ,p_hours_balance_id            => ln_hours_balance_id
                               ,p_processing_priority         => ln_processing_priority
                               ,p_element_classification_name => lv_element_classification_name
                               ,p_reporting_name              => lv_reporting_name
                               ,p_tax_unit_id                 => p_tax_unit_id
                               ,p_ytd_balcall_aaid            => p_ytd_balcall_aaid
                               ,p_pymt_balcall_aaid           =>  p_pymt_balcall_aaid
                               ,p_legislation_code            => p_legislation_code
                               ,p_sepchk_flag                 => p_sepchk_flag
                               ,p_sepchk_run_type_id          => p_sepchk_run_type_id
                               ,p_action_type                 => p_action_type
                               ,p_run_assignment_action_id    => ln_run_assignment_action_id
                               ,p_multiple                    => ln_multiple
                               ,p_rate                        => ln_final_rate);
                       lv_retro_flag := 'Y' ;
		       -- As Base + Addl Ele DFF Config Non-Retro Entry Both Handled above
		       lv_retro_parent_flag := 'N';
                    ELSE -- May Need to be Revised

                       hr_utility.trace('ln_addnl_ele_num <= 0');
                       open archive_non_retro_elements( ld_original_date_paid,
                                                        ln_element_entry_id,
                                                        ln_run_assignment_action_id ) ;
                       fetch archive_non_retro_elements
                            into lv_effective_start_date,
                                 lv_effective_end_date,
                                 lv_category;
                        close archive_non_retro_elements ;
                        close get_run_action_id;

                        -- Added For Work At Home Condition
                        OPEN c_cur_get_wrkathome(p_assignment_id);
                        FETCH c_cur_get_wrkathome INTO lv_wrk_at_home
                                                      ,ln_person_id
                                                      ,ln_bg_id;
                        CLOSE c_cur_get_wrkathome;

                        IF lv_wrk_at_home = 'Y' THEN
                                OPEN c_cur_home_state_jd(ln_person_id
                                                   ,ln_bg_id);
                                FETCH c_cur_home_state_jd INTO lv_jurisdiction_flag;
                                CLOSE c_cur_home_state_jd;
                        ELSE
                                select nvl((select peevf.screen_entry_value  jurisdiction_code
                                from pay_input_values_f pivf,
                                     pay_element_entry_values_f peevf
                                where pivf.element_type_id = ln_element_type_id
                                AND pivf.NAME = 'Jurisdiction'
                                AND peevf.element_entry_id =  ln_element_entry_id
                                AND pivf.input_value_id = peevf.input_value_id),(SELECT   distinct pus.state_code
                                   || '-'
                                   || puc.county_code
                                   || '-'
                                   || punc.city_code jurisdiction_code
                                   FROM per_all_assignments_f peaf,
                                   hr_locations_all hla,
                                   pay_us_states pus,
                                   pay_us_counties puc,
                                   pay_us_city_names punc,
                                   pay_assignment_actions paa,
                                   pay_payroll_actions ppa
                                WHERE peaf.assignment_id = p_assignment_id
                                AND paa.assignment_action_id = ln_run_assignment_action_id
                                AND peaf.location_id = hla.location_id
                                AND hla.region_2 = pus.state_abbrev
                                AND pus.state_code = puc.state_code
                                AND hla.region_1 = puc.county_name
                                AND hla.town_or_city = punc.city_name
                                AND pus.state_code = punc.state_code
                                AND puc.county_code = punc.county_code
                                AND ppa.payroll_action_id = paa.payroll_action_id
                                AND ppa.effective_date between peaf.effective_start_date and peaf.effective_end_date
                                ))
                                into lv_jurisdiction_flag
                                from dual;
                       END IF; -- Work At Home 'N'

                    END IF; -- ln_addnl_ele_num > 0
                    /* Commented for Bug# 8211926
                    EXIT;
                    */
                  END IF; -- lv_original_date_paid <> 'AAA' and ln_flag =0

               hr_utility.trace('Before Checking Retro.');

               -- Start Handling Retro Cases
	       -- Checking IF Retro

	       OPEN check_retro ( ln_run_assignment_action_id,
                                    p_assignment_id,
                                    ln_element_type_id) ;
                FETCH check_retro into lv_retro_flag ;
                IF check_retro%FOUND THEN
                     --
		     -- In Case of Retro Checking IF it is Base + Retro Case
		     --
		     OPEN retro_parent_check_flag(ln_run_assignment_action_id,
					p_assignment_id,
					ln_element_type_id) ;
		     FETCH retro_parent_check_flag INTO lv_retro_parent_flag;
		     CLOSE retro_parent_check_flag ;
                     IF lv_retro_parent_flag IS NULL THEN
		        lv_retro_parent_flag := 'N';
		     END IF;
		     --
                     -- Archiving ONLY Retro Entries NOT Retrp Base
		     --
                     Archive_retro_element( p_xfr_action_id               => p_xfr_action_id
                                           ,p_assignment_id               => p_assignment_id
                                           ,p_pymt_assignment_action_id   => p_curr_pymt_action_id
                                           ,p_pymt_eff_date               => p_curr_pymt_eff_date
                                           ,p_element_type_id             => ln_element_type_id
                                           ,p_primary_balance_id          => ln_primary_balance_id
                                           ,p_hours_balance_id            => ln_hours_balance_id
                                           ,p_processing_priority         => ln_processing_priority
                                           ,p_element_classification_name => lv_element_classification_name
                                           ,p_reporting_name              => lv_reporting_name
                                           ,p_tax_unit_id                 => p_tax_unit_id
                                           ,p_ytd_balcall_aaid            => p_ytd_balcall_aaid
                                           ,p_pymt_balcall_aaid           => p_pymt_balcall_aaid
                                           ,p_legislation_code            => p_legislation_code
                                           ,p_sepchk_flag                 => p_sepchk_flag
                                           ,p_sepchk_run_type_id          => p_sepchk_run_type_id
                                           ,p_action_type                 => p_action_type
                                           ,p_run_assignment_action_id    => ln_run_assignment_action_id
                                           ,p_multiple                    => ln_multiple
                                           ,p_rate                        => ln_final_rate
					   ,p_retro_base                  => lv_retro_parent_flag);
                 END IF; -- check_retro%FOUND

                CLOSE check_retro; -- Added
            ELSE
                IF check_retro%ISOPEN THEN
                   CLOSE check_retro;
                END IF;
                IF get_element_entry_id%ISOPEN THEN
                    CLOSE get_element_entry_id;
                END IF;
            END IF; -- get_element_entry_id%found
        /* NOT Needed
        END LOOP; -- For Each Run Assignment Action ID
        */

	    IF get_run_action_id%ISOPEN THEN
             CLOSE get_run_action_id;
          END IF;
        END IF; -- Legislation US

        hr_utility.set_location(gv_package  || lv_procedure_name, 40);
        hr_utility.trace('Ele type id = '   || ln_element_type_id);
        hr_utility.trace('Primary Bal id = '|| ln_primary_balance_id);
        hr_utility.trace('Ele Class = '     || lv_element_classification_name);

         if lv_element_classification_name like '% Deductions' then
            ln_hours_balance_id := null;
         end if;
         ln_step := 15;
         ln_element_index := pay_ac_action_arch.emp_elements_tab.count;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_type_id
                  := ln_element_type_id;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_classfn
                  := lv_element_classification_name;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_primary_balance_id
                  := ln_primary_balance_id;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_processing_priority
                  := ln_processing_priority;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_reporting_name
                  := lv_reporting_name;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_hours_balance_id
                  := ln_hours_balance_id;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).jurisdiction_code
                  := '00-000-0000';

         hr_utility.set_location(gv_package  || lv_procedure_name, 50);
         ln_step := 20;
         IF ((lv_retro_flag = 'N' ) OR (lv_retro_parent_flag = 'Y')) THEN
             IF lv_original_date_earned = 'AAA' THEN
                lv_original_date_earned := null;
             END IF;
         populate_elements(p_xfr_action_id             => p_xfr_action_id
                          ,p_pymt_assignment_action_id => p_curr_pymt_action_id
                          ,p_pymt_eff_date             => p_curr_pymt_eff_date
                          ,p_element_type_id           => ln_element_type_id
                          ,p_primary_balance_id        => ln_primary_balance_id
                          ,p_hours_balance_id          => ln_hours_balance_id
                          ,p_processing_priority       => ln_processing_priority
                          ,p_element_classification_name
                                                       => lv_element_classification_name
                          ,p_reporting_name            => lv_reporting_name
                          ,p_tax_unit_id               => p_tax_unit_id
                          ,p_pymt_balcall_aaid         => p_pymt_balcall_aaid
                          ,p_ytd_balcall_aaid          => p_ytd_balcall_aaid
                          ,p_legislation_code          => p_legislation_code
                          ,p_sepchk_flag               => p_sepchk_flag
                          ,p_sepchk_run_type_id        => p_sepchk_run_type_id
                          ,p_action_type               => p_action_type
                          ,p_original_date_earned      => lv_original_date_earned
                          ,p_effective_start_date      => lv_effective_start_date
                          ,p_effective_end_date        => lv_effective_end_date
                          ,p_category                  => lv_category
                          ,p_el_jurisdiction_code      => lv_jurisdiction_flag
                          ,p_final_rate                => ln_final_rate
                          ,p_ytd_flag                  => lv_retro_parent_flag
                          );

                          lv_original_date_earned := NULL;
                          lv_effective_start_date := NULL;
                          lv_effective_end_date := NULL;
                          lv_category           := NULL;
                          lv_jurisdiction_flag := NULL;
                          lv_original_date_paid:= NULL;

       END IF;

       lv_retro_flag := 'N' ;
       lv_retro_parent_flag := 'N';
       gv_ytd_amount := 0;
       gv_ytd_hour   := 0;

       end loop; -- End Loop of c_cur_action_elements OR c_cur_sp_action_elements

       if p_sepchk_flag = 'Y' then
         close c_cur_sp_action_elements;
         elsif p_sepchk_flag = 'N' then
         close c_cur_action_elements;
       end if;
       hr_utility.set_location(gv_package  || lv_procedure_name, 60);
       ln_step := 25;

  EXCEPTION
   when others then
      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_current_elements;

  /******************************************************************
   Name      : get_xfr_elements
   Purpose   : Check the elements archived in the previous record with
               the given assignment and if the element is not archived
               in this current run, get YTD for the element found.
   Arguments : p_xfr_action_id      => Current xfr action id
               p_last_xfr_action_id => Previous xfr action id retrieved
                                       from get_last_xfr_info procedure
               p_ytd_balcall_aaid   => aaid for YTD balance call.
               p_pymt_eff_date      => Current pymt eff date.
               p_legislation_code   => Legislation code.
               p_sepchk_flag        => Separate Check flag.
               p_assignment_id      => Current assignment id that is being
                                       processed.
   Notes     : If multi assignment is enabled and is a sepchk, then check
               the last xfr run for the given person not assignment.
  ******************************************************************/
  PROCEDURE get_xfr_elements(p_xfr_action_id       in number
                            ,p_last_xfr_action_id  in number
                            ,p_ytd_balcall_aaid    in number
                            ,p_pymt_eff_date       in date
                            ,p_legislation_code    in varchar2
                            ,p_sepchk_flag         in varchar2
                            ,p_assignment_id       in number
                            )

  IS
    cursor c_last_xfr_elements(cp_xfr_action_id    in number
                              ,cp_legislation_code in varchar2) is
      select assignment_id, action_information_category,
             action_information1  classification_name,
             action_information2  element_type_id,
             decode(cp_legislation_code,
                   'CA', jurisdiction_code,
                   'US', decode(jurisdiction_code, NULL, NULL,
                         decode(to_char(length(replace(jurisdiction_code,'-')))
                                    ,'7', jurisdiction_code,
                                rpad(nvl(substr(rtrim(ltrim(jurisdiction_code))
                                     ,1,2),'0'),2,'0') || '-'||
                                rpad(nvl(substr(rtrim(ltrim(jurisdiction_code))
                                     ,4,3),'0'),3,'0') ||'-' ||
                                rpad(nvl(substr(rtrim(ltrim(jurisdiction_code))
                                     ,8,4),'0'),4,'0')))) jurisdiction_code,
             action_information6  primary_balance_id,
             action_information7  processing_priority,
             action_information9  ytd_amount,
             action_information10 reporting_name,
             effective_date       effective_date,
             action_information12 ytd_hours,
						 action_information24 display_name
        from pay_action_information
       where action_information_category in ('AC EARNINGS', 'AC DEDUCTIONS')
         and action_context_id = cp_xfr_action_id;


    cursor c_get_balance (cp_balance_name  in varchar2
                         ,cp_legislation_code in varchar2) is
      select balance_type_id
        from pay_balance_types
       where legislation_code = cp_legislation_code
         and balance_name = cp_balance_name;

    ln_element_type_id             NUMBER;
    lv_element_classfication_name  VARCHAR2(80);
    lv_jurisdiction_code           VARCHAR2(80);
    ln_primary_balance_id          NUMBER;
    ln_processing_priority         NUMBER;
    lv_reporting_name              VARCHAR2(150);
    ld_effective_date              DATE;
    ln_hours_balance_id            NUMBER;

    ln_t_primary_balance_id        NUMBER;
    lv_t_reporting_name            VARCHAR2(150);

    ln_ele_primary_balance_id      NUMBER;
    ln_ele_hours_balance_id        NUMBER;

    ln_ytd_defined_balance_id NUMBER;
    ln_ytd_hours_balance_id   NUMBER;
    ln_payments_amount        NUMBER;
    ln_ytd_hours              NUMBER;
    ln_ytd_amount             NUMBER;

    ln_index                  NUMBER := 0;
    lv_element_archived       VARCHAR2(1) := 'N';
    lv_action_info_category   VARCHAR2(30) := 'AC DEDUCTIONS';
    lv_procedure_name         VARCHAR2(100) := '.get_xfr_elements';
    lv_error_message          VARCHAR2(200);
    ln_step                   NUMBER;
    ln_assignment_id          NUMBER;

lv_display_name 		VARCHAR2(100);

  BEGIN
     ln_step:= 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_xfr_action_id = '||p_xfr_action_id);
     hr_utility.trace('p_last_xfr_action_id = '|| p_last_xfr_action_id );
     hr_utility.trace('p_assignment_id = '|| p_assignment_id );
     hr_utility.trace('gv_multi_payroll_pymt = '||
                          pay_emp_action_arch.gv_multi_payroll_pymt);
     hr_utility.trace('p_sepchk_flag = '||p_sepchk_flag);

     open c_last_xfr_elements(p_last_xfr_action_id, p_legislation_code);
     loop
        fetch c_last_xfr_elements into ln_assignment_id,
                                       lv_action_info_category,
                                       lv_element_classfication_name,
                                       ln_element_type_id,
                                       lv_jurisdiction_code,
                                       ln_primary_balance_id,
                                       ln_processing_priority,
                                       ln_ytd_amount,
                                       lv_reporting_name,
                                       ld_effective_date,
                                       ln_ytd_hours,
                                       lv_display_name;

        hr_utility.set_location(gv_package || lv_procedure_name, 20);
        if c_last_xfr_elements%notfound then
           hr_utility.set_location(gv_package || lv_procedure_name, 30);
           exit;
        end if;

        ln_step := 5;
        if ln_primary_balance_id is null then
           if lv_reporting_name = 'SDI Withheld' then
              lv_t_reporting_name := 'SDI EE Withheld';
           elsif lv_reporting_name = 'SUI Withheld' then
              lv_t_reporting_name := 'SUI EE Withheld';
           elsif lv_reporting_name = 'SUI1 Withheld' then
              lv_t_reporting_name := 'SUI1 EE Withheld';
           elsif lv_reporting_name = 'SDI1 Withheld' then
              lv_t_reporting_name := 'SDI1 EE Withheld';
           else
              lv_t_reporting_name := lv_reporting_name;
           end if;

           open c_get_balance(lv_t_reporting_name, p_legislation_code);
           fetch c_get_balance into ln_t_primary_balance_id;
           close c_get_balance;
           ln_primary_balance_id := ln_t_primary_balance_id;
        end if;

        hr_utility.trace('Element type id =' || ln_element_type_id);
        hr_utility.trace('Reporting Name  =' || lv_reporting_name);
        hr_utility.trace('JD Code         =' || lv_jurisdiction_code);
        hr_utility.trace('Ele Class       =' || lv_element_classfication_name);

        ln_step := 6;

        hr_utility.trace('p_assignment_id (current) = '||p_assignment_id);
        hr_utility.trace('ln_assignment_id (prev) = '||ln_assignment_id);

        if pay_emp_action_arch.gv_multi_payroll_pymt = 'Y' and
           p_sepchk_flag = 'Y' and
           ln_assignment_id <> p_assignment_id then

           hr_utility.trace('action_info_category = ' ||lv_action_info_category);
           hr_utility.trace('ln_element_type_id = '   ||ln_element_type_id);
           hr_utility.trace('ln_primary_balance_id = '||ln_primary_balance_id);
           hr_utility.trace('ln_ytd_amount = '        ||ln_ytd_amount);

           ln_index := pay_ac_action_arch.lrr_act_tab.count;

           pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                     := lv_action_info_category;
           pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                     := lv_jurisdiction_code;
           pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                     := p_xfr_action_id;
           pay_ac_action_arch.lrr_act_tab(ln_index).assignment_id
                     := ln_assignment_id;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                     := lv_element_classfication_name;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                     := ln_element_type_id;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                     := ln_primary_balance_id;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                     := ln_processing_priority;
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                     := fnd_number.number_to_canonical(nvl(ln_ytd_amount,0));
           pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                     := lv_reporting_name;
           if lv_action_info_category = 'AC EARNINGS' then
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                       := fnd_number.number_to_canonical(ln_ytd_hours);
           end if;

           -- Added for Bug# 7348767, Bug# 7348838
           if lv_action_info_category = 'AC DEDUCTIONS' THEN
	   --Bug 8688998
              --pay_ac_action_arch.lrr_act_tab(ln_index).act_info24 := lv_reporting_name;
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info24 := lv_display_name;
           end if;
        end if;

        if ln_assignment_id = p_assignment_id then
           if pay_ac_action_arch.emp_elements_tab.count > 0 then
              for i in pay_ac_action_arch.emp_elements_tab.first..
                       pay_ac_action_arch.emp_elements_tab.last LOOP
                  if pay_ac_action_arch.emp_elements_tab(i).element_primary_balance_id
                          = ln_primary_balance_id and
                     pay_ac_action_arch.emp_elements_tab(i).jurisdiction_code
                          = lv_jurisdiction_code then
                     lv_element_archived := 'Y';
                     exit;
                  end if;
              end loop;
           end if;

           ln_step := 10;
           if lv_element_archived = 'N' then
              hr_utility.set_location(gv_package || lv_procedure_name, 50);
              /**************************************************************
              ** Bug 3567107: Check to see if the element is still effective
              **              the primary balance is there before archiving
              **              the value when picking elements which have
              **              already been archived.
              ** Note: This will take care of the issue when clients migrate
              **       to a new element and only want one entry to be archived
              **       and show up in checks, payslip and depsoit advice
              **************************************************************/
              if lv_element_classfication_name <> 'Tax Deductions' then
                 open c_element_info(ln_element_type_id, ld_effective_date);
                 fetch c_element_info into ln_ele_primary_balance_id,
                                           ln_ele_hours_balance_id;
                 if c_element_info%notfound or
                    ln_ele_primary_balance_id is null then
                    lv_element_archived := 'Y';
                 end if;

                 close c_element_info;

                 if lv_element_classfication_name not like '% Deductions' then
                    ln_hours_balance_id := ln_ele_hours_balance_id;
                 end if;
              end if;
           end if;

           if lv_element_archived = 'N' then
              /* populate the extra element table */
              ln_index := pay_ac_action_arch.emp_elements_tab.count;
              pay_ac_action_arch.emp_elements_tab(ln_index).element_type_id
                   := ln_element_type_id;
              pay_ac_action_arch.emp_elements_tab(ln_index).element_classfn
                   := lv_element_classfication_name;
              pay_ac_action_arch.emp_elements_tab(ln_index).jurisdiction_code
                   := lv_jurisdiction_code;
              pay_ac_action_arch.emp_elements_tab(ln_index).element_primary_balance_id
                   := ln_primary_balance_id;
              pay_ac_action_arch.emp_elements_tab(ln_index).element_processing_priority
                   := ln_processing_priority;
              pay_ac_action_arch.emp_elements_tab(ln_index).element_reporting_name
                   := lv_reporting_name;
              pay_ac_action_arch.emp_elements_tab(ln_index).element_hours_balance_id
                   := ln_hours_balance_id;

              if lv_jurisdiction_code <> '00-000-0000' then
                 pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
                 gv_ytd_balance_dimension := gv_dim_asg_jd_gre_ytd;
              else
                 pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
                 if gv_reporting_level = 'TAXGRP' then
                    gv_ytd_balance_dimension := gv_dim_asg_tg_ytd;
                 else
                    gv_ytd_balance_dimension := gv_dim_asg_gre_ytd;
                 end if;
              end if;

              ln_step := 15;
              ln_ytd_defined_balance_id
                  := pay_emp_action_arch.get_defined_balance_id
                                          (ln_primary_balance_id,
                                           gv_ytd_balance_dimension,
                                           p_legislation_code);
              hr_utility.set_location(gv_package || lv_procedure_name, 60);
              if ln_ytd_defined_balance_id is not null then
                 ln_ytd_amount := nvl(pay_balance_pkg.get_value(
                                        ln_ytd_defined_balance_id,
                                        p_ytd_balcall_aaid),0);
              end if;
              hr_utility.set_location(gv_package || lv_procedure_name, 70);
              if ln_hours_balance_id is not null then
                 ln_ytd_hours_balance_id
                    := pay_emp_action_arch.get_defined_balance_id
                                           (ln_hours_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);
                 hr_utility.set_location(gv_package || lv_procedure_name, 80);
                 if ln_ytd_hours_balance_id is not null then
                    ln_ytd_hours := nvl(pay_balance_pkg.get_value(
                                         ln_ytd_hours_balance_id,
                                         p_ytd_balcall_aaid),0);
                    hr_utility.set_location(gv_package || lv_procedure_name, 90);
                 end if;
              end if;

              hr_utility.trace('ln_ytd_amount = '||ln_ytd_amount);
              hr_utility.trace('ln_ytd_hours = '||ln_ytd_hours);

              if (( nvl(ln_ytd_amount, 0) + nvl(ln_payments_amount, 0) <> 0 ) or
                  ( pay_ac_action_arch.gv_multi_gre_payment = 'N' ) ) then

                 hr_utility.set_location(gv_package || lv_procedure_name, 100);
                 ln_index := pay_ac_action_arch.lrr_act_tab.count;
                 hr_utility.trace('ln_index = ' || ln_index);
                 ln_step := 20;
                 if lv_element_classfication_name in ('Earnings',
                                                      'Alien/Expat Earnings',
                                                      'Supplemental Earnings',
                                                      'Taxable Benefits',
                                                      'Imputed Earnings',
                                                      'Non-payroll Payments') then
                    lv_action_info_category := 'AC EARNINGS';
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                         := fnd_number.number_to_canonical(ln_ytd_hours);
                 end if;

                 pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                         := lv_action_info_category;
                 pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                         := lv_jurisdiction_code;
                 pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                         := p_xfr_action_id;
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                         := lv_element_classfication_name;
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                         := ln_element_type_id;
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                         := ln_primary_balance_id;
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                         := ln_processing_priority;
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                         := fnd_number.number_to_canonical(nvl(ln_payments_amount,0));
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                         := fnd_number.number_to_canonical(ln_ytd_amount);
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                         := lv_reporting_name;
                 -- Added for Bug# 7348767, Bug# 7348838
                 if lv_action_info_category = 'AC DEDUCTIONS' THEN
--Bug 8688998
--              pay_ac_action_arch.lrr_act_tab(ln_index).act_info24 := lv_reporting_name;
                    pay_ac_action_arch.lrr_act_tab(ln_index).act_info24 := lv_display_name;
                 end if;

              end if;
           end if;

           lv_element_archived := 'N';
           lv_action_info_category := 'AC DEDUCTIONS';
           lv_element_classfication_name := null;
           ln_element_type_id      := null;
           lv_jurisdiction_code    := null;
           ln_primary_balance_id   := null;
           ln_processing_priority  := null;
           lv_reporting_name       := null;
           ln_hours_balance_id     := null;
           ln_ytd_amount           := null;
           ln_ytd_hours            := null;

        end if;
     end loop;
     close c_last_xfr_elements;

     hr_utility.set_location(gv_package || lv_procedure_name, 50);
     ln_step := 25;



  EXCEPTION
   when others then
      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_xfr_elements;



  /******************************************************************
   Name      : get_missing_xfr_info
   Purpose   : The procedure gets the elements which have been
               processed for a given Payment Action. This procedure
               is only called if the archiver has not been run for
               all pre-payment actions.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE get_missing_xfr_info(p_xfr_action_id        in number
                                ,p_tax_unit_id          in number
                                ,p_assignment_id        in number
                                ,p_last_pymt_action_id  in number
                                ,p_last_pymt_eff_date   in date
                                ,p_last_xfr_eff_date    in date
                                ,p_ytd_balcall_aaid     in number
                                ,p_pymt_eff_date        in date
                                ,p_legislation_code     in varchar2
                                )

   IS

     cursor c_prev_elements(cp_assignment_id      in number
                           ,cp_pymt_eff_date in date
                           ,cp_last_xfr_eff_date  in date) is
       SELECT /*+ ORDERED  use_nl(PAA,PPA,PPF) */
       DISTINCT
             pec.classification_name,
             pet.processing_priority,
             decode(pec.classification_name,
                         'Tax Deductions',
                         nvl(petl.reporting_name, petl.element_name) || ' Withheld',
                         nvl(petl.reporting_name, petl.element_name)) reporting_name,
                         decode(pec.classification_name,
                                     'Tax Deductions', null,
                                     prr.element_type_id) element_type_id,
                         nvl(decode(pec.classification_name,
                                     'Tax Deductions', prr.jurisdiction_code), '00-000-0000'),
             pet.element_information10,
             pet.element_information12
         from  PAY_ASSIGNMENT_ACTIONS             PAA,
                  PAY_PAYROLL_ACTIONS                   PPA,
                  PAY_PAYROLLS_F                               PPF,
                  PAY_RUN_RESULTS                             PRR,
                  PAY_ELEMENT_TYPES_F                    PET ,
                  PAY_ELEMENT_CLASSIFICATIONS   PEC,
                  PAY_ELEMENT_TYPES_F_TL             PETL
            /*changing the order for bug 5549032
              pay_run_results prr,
              pay_element_types_f pet ,
              pay_element_classifications pec,
              pay_assignment_actions paa,
              pay_payroll_actions ppa,
              pay_element_types_f_tl petl,
              pay_all_payrolls_f ppf */ -- Bug 3370112
        where ppa.action_type in ('R', 'Q', 'B')
            and ppa.effective_date > cp_last_xfr_eff_date
            and ppa.effective_date <= cp_pymt_eff_date
            and ppa.payroll_id = ppf.payroll_id
            and ppf.payroll_id >= 0
            and ppa.effective_date between ppf.effective_start_date
                                                      and ppf.effective_end_date
            and paa.payroll_action_id         = ppa.payroll_action_id
            and paa.assignment_id             = cp_assignment_id
            and paa.assignment_action_id  = prr.assignment_action_id
            and pet.element_type_id          = prr.element_type_id
            and pet.element_information10 is not null
            and ppa.effective_date   between pet.effective_start_date
                                                        and pet.effective_end_date
            and petl.element_type_id          = pet.element_type_id
            and petl.language                     = gv_person_lang
            and pec.classification_id           = pet.classification_id
            and pec.classification_name in ('Earnings',
                                                           'Alien/Expat Earnings',
                                                           'Supplemental Earnings',
                                                           'Imputed Earnings',
                                                           'Taxable Benefits',
                                                           'Pre-Tax Deductions',
                                                           'Involuntary Deductions',
                                                           'Voluntary Deductions',
                                                           'Non-payroll Payments',
                                                           'Tax Deductions'
                                                          )
          and pet.element_name not like '%Calculator'
          and pet.element_name not like '%Special Inputs'
          and pet.element_name not like '%Special Features'
          and pet.element_name not like '%Special Features 2'
          and pet.element_name not like '%Verifier'
          and pet.element_name not like '%Priority'
       order by 1, 3, 4;

    lv_element_classfication_name   VARCHAR2(80);
    ln_primary_balance_id           NUMBER;
    ln_processing_priority          NUMBER;
    lv_reporting_name               VARCHAR2(80);
    ln_element_type_id              NUMBER;
    lv_jurisdiction_code            VARCHAR2(80);
    ln_hours_balance_id             NUMBER;

    ln_ytd_hours_balance_id         NUMBER;
    ln_ytd_defined_balance_id       NUMBER;
    ln_payments_amount              NUMBER;
    ln_ytd_hours                    NUMBER;
    ln_ytd_amount                   NUMBER(17,2);
    lv_action_info_category         VARCHAR2(30) := 'AC DEDUCTIONS';

    ln_index                        NUMBER ;
    lv_element_archived             VARCHAR2(1) := 'N';
    lv_procedure_name               VARCHAR2(100) := '.get_missing_xfr_info';
    lv_error_message                VARCHAR2(200);
    ln_step                         NUMBER;

  BEGIN
     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     hr_utility.trace('p_xfr_action_id       = '|| p_xfr_action_id);
     hr_utility.trace('p_tax_unit_id         = '|| p_tax_unit_id);
     hr_utility.trace('p_last_pymt_action_id = '|| p_last_pymt_action_id );
     hr_utility.trace('p_last_pymt_eff_date  = '|| p_last_pymt_eff_date);
     hr_utility.trace('p_last_xfr_eff_date   = '|| p_last_xfr_eff_date);
     hr_utility.trace('p_pymt_eff_date       = '|| p_pymt_eff_date);

     open c_prev_elements(p_assignment_id,
                          p_pymt_eff_date,
                          p_last_xfr_eff_date);
     loop
        fetch c_prev_elements into lv_element_classfication_name,
                                   ln_processing_priority,
                                   lv_reporting_name,
                                   ln_element_type_id,
                                   lv_jurisdiction_code,
                                   ln_primary_balance_id,
                                   ln_hours_balance_id;
        if c_prev_elements%notfound then
           hr_utility.set_location(gv_package || lv_procedure_name, 20);
           exit;
        end if;
        hr_utility.set_location(gv_package || lv_procedure_name, 30);

        if lv_element_classfication_name like '% Deductions' then
           ln_hours_balance_id := null;
        end if;

        ln_step := 5;
        if pay_ac_action_arch.emp_elements_tab.count > 0 then
           for i in pay_ac_action_arch.emp_elements_tab.first..
                    pay_ac_action_arch.emp_elements_tab.last LOOP
               if pay_ac_action_arch.emp_elements_tab(i).element_primary_balance_id
                       = ln_primary_balance_id and
                  pay_ac_action_arch.emp_elements_tab(i).jurisdiction_code
                        = lv_jurisdiction_code then
                  lv_element_archived := 'Y';
                  exit;
               end if;
           end loop;
        end if;

        if lv_element_archived = 'N' then
           /* populate the extra element table */
           ln_step := 10;
           ln_index := pay_ac_action_arch.emp_elements_tab.count;
           pay_ac_action_arch.emp_elements_tab(ln_index).element_type_id
                := ln_element_type_id;
           pay_ac_action_arch.emp_elements_tab(ln_index).element_classfn
                := lv_element_classfication_name;
           pay_ac_action_arch.emp_elements_tab(ln_index).element_primary_balance_id
                := ln_primary_balance_id;
           pay_ac_action_arch.emp_elements_tab(ln_index).element_processing_priority
                := ln_processing_priority;
           pay_ac_action_arch.emp_elements_tab(ln_index).element_reporting_name
                := lv_reporting_name;
           pay_ac_action_arch.emp_elements_tab(ln_index).element_hours_balance_id
                := ln_hours_balance_id;
           pay_ac_action_arch.emp_elements_tab(ln_index).jurisdiction_code
                := lv_jurisdiction_code;

           if lv_jurisdiction_code <> '00-000-0000' then
              pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
              gv_ytd_balance_dimension := gv_dim_asg_jd_gre_ytd;
           else
              pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
              if gv_reporting_level = 'TAXGRP' then
                 gv_ytd_balance_dimension := gv_dim_asg_tg_ytd;
              else
                 gv_ytd_balance_dimension := gv_dim_asg_gre_ytd;
              end if;
           end if;

           ln_step := 15;
           ln_ytd_defined_balance_id :=
                  pay_emp_action_arch.get_defined_balance_id
                                           (ln_primary_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);
           hr_utility.set_location(gv_package || lv_procedure_name, 60);
           if ln_ytd_defined_balance_id is not null then
              ln_ytd_amount := nvl(pay_balance_pkg.get_value(
                                   ln_ytd_defined_balance_id,
                                   p_ytd_balcall_aaid),0);
              hr_utility.set_location(gv_package || lv_procedure_name, 70);
           end if;
           if ln_hours_balance_id is not null then
              ln_ytd_hours_balance_id :=
                     pay_emp_action_arch.get_defined_balance_id
                                             (ln_hours_balance_id,
                                              gv_ytd_balance_dimension,
                                              p_legislation_code);
              hr_utility.set_location(gv_package || lv_procedure_name, 80);
              if ln_ytd_hours_balance_id is not null then
                 ln_ytd_hours := nvl(pay_balance_pkg.get_value(
                                         ln_ytd_hours_balance_id,
                                         p_ytd_balcall_aaid),0);
                 hr_utility.set_location(gv_package || lv_procedure_name, 90);
              end if;
           end if;

           hr_utility.set_location(gv_package || lv_procedure_name, 100);
           if nvl(ln_ytd_amount, 0) <> 0 or nvl(ln_payments_amount, 0) <> 0 then
              ln_index := pay_ac_action_arch.lrr_act_tab.count;
              hr_utility.trace('ln_index = ' || ln_index);
              if lv_element_classfication_name in ('Earnings',
                                                   'Alien/Expat Earnings',
                                                   'Supplemental Earnings',
                                                   'Taxable Benefits',
                                                   'Imputed Earnings',
                                                   'Non-payroll Payments') then
                 lv_action_info_category := 'AC EARNINGS';
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                      := fnd_number.number_to_canonical(ln_ytd_hours);  /* Bug 3311866*/
              end if;

              ln_step := 20;
              pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                      := lv_action_info_category;
              pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                      := lv_jurisdiction_code;
              pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                      := p_xfr_action_id ;
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                      := lv_element_classfication_name;
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                      := ln_element_type_id;
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                      := ln_primary_balance_id;
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                      := ln_processing_priority;
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                      := fnd_number.number_to_canonical(nvl(ln_payments_amount,0));
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                      := fnd_number.number_to_canonical(nvl(ln_ytd_amount,0));
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                      := lv_reporting_name;
              -- Added for Bug# 7348767, Bug# 7348838
              if lv_action_info_category = 'AC DEDUCTIONS' THEN
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info24 := lv_reporting_name;
              end if;
           end if;
        end if;
        lv_element_archived := 'N';
        lv_action_info_category := 'AC DEDUCTIONS';
        lv_element_classfication_name := null;
        ln_element_type_id      := null;
        lv_jurisdiction_code    := null;
        ln_primary_balance_id   := null;
        ln_processing_priority  := null;
        lv_reporting_name       := null;
        ln_hours_balance_id     := null;
     end loop;
     close c_prev_elements;
     hr_utility.set_location(gv_package || lv_procedure_name, 150);

     ln_step := 30;


  EXCEPTION
    when others then

      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_missing_xfr_info;


  FUNCTION check_run_balance_status(p_assignment_id      in number
                                   ,p_curr_pymt_eff_date in date
                                   ,p_legislation_code   in varchar2
                                   )
  RETURN VARCHAR2
  IS

   lv_business_grp_id             NUMBER;
   lv_rb_status              VARCHAR2(1);

   cursor c_business_grp_id is
      select distinct business_group_id
        from per_all_assignments_f
       where assignment_id = p_assignment_id;

  BEGIN

     -- Populating the PL/SQL table run_bal_stat_tab with the validity status
     -- of various attributes. If already populated, we use that to check the
     -- validity
     if run_bal_stat.COUNT > 0 then
        for i in run_bal_stat.first .. run_bal_stat.last loop
            if run_bal_stat(i).valid_status = 'N' then
               lv_rb_status := 'N';
               exit;
            end if;
        end loop;
     else
        open c_business_grp_id;
        fetch c_business_grp_id into lv_business_grp_id;
        close c_business_grp_id;
        if p_legislation_code = 'US' then
           run_bal_stat(1).attribute_name := 'PAY_US_EARNINGS_AMTS';
           run_bal_stat(2).attribute_name := 'PAY_US_PRE_TAX_DEDUCTIONS';
           run_bal_stat(3).attribute_name := 'PAY_US_AFTER_TAX_DEDUCTIONS';
           run_bal_stat(4).attribute_name := 'PAY_US_TAX_DEDUCTIONS';
        else
           run_bal_stat(1).attribute_name := 'PAY_CA_EARNINGS';
           run_bal_stat(2).attribute_name := 'PAY_CA_DEDUCTIONS';
        end if;

        for i in run_bal_stat.first .. run_bal_stat.last loop
            run_bal_stat(i).valid_status := pay_us_payroll_utils.check_balance_status(
                                                     p_curr_pymt_eff_date,
                                                     lv_business_grp_id,
                                                     run_bal_stat(i).attribute_name,
                                                     p_legislation_code);
            if (lv_rb_status is NULL and run_bal_stat(i).valid_status = 'N') then
               lv_rb_status := 'N';
            end if;
         end loop;
      end if;

      if lv_rb_status is NULL then
         lv_rb_status := 'Y';
      end if;

      return (lv_rb_status);

  END check_run_balance_status;


  PROCEDURE get_prev_ytd_elements(p_assignment_id       in number
                                 ,p_xfr_action_id       in number
                                 ,p_curr_pymt_action_id in number
                                 ,p_curr_pymt_eff_date  in date
                                 ,p_start_eff_date      in date
                                 ,p_tax_unit_id         in number
                                 ,p_ytd_balcall_aaid    in number
                                 ,p_sepchk_flag         in varchar2
                                 ,p_sepchk_run_type_id  in number
                                 ,p_legislation_code    in varchar2
                                 ,p_action_type1        in varchar2
                                 ,p_action_type2        in varchar2
                                 ,p_action_type3        in varchar2
                                 )
  IS

    lv_element_classification_name VARCHAR2(80);
    ln_processing_priority         NUMBER;
    lv_reporting_name              VARCHAR2(80);
    ln_element_type_id             NUMBER;
    lv_jurisdiction_code           VARCHAR2(80);
    ln_primary_balance_id          NUMBER;
    ln_hours_balance_id            NUMBER;

    ln_element_index               NUMBER ;
    lv_element_archived            VARCHAR2(1);
    lv_procedure_name              VARCHAR2(100);
    lv_error_message               VARCHAR2(200);
    ln_step                        NUMBER;
    lv_run_bal_status              VARCHAR2(1);

  BEGIN
    ln_step := 1;
    lv_run_bal_status := NULL;
    lv_element_archived := 'N';
    lv_procedure_name := '.get_prev_ytd_elements';

    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    hr_utility.trace('p_xfr_action_id' || p_xfr_action_id);
    hr_utility.trace('p_assignment_id '|| p_assignment_id);
    hr_utility.trace('p_tax_unit_id '  || p_tax_unit_id);
    hr_utility.trace('p_sepchk_flag '  || p_sepchk_flag);
    hr_utility.trace('p_curr_pymt_eff_date '|| p_curr_pymt_eff_date);
    hr_utility.trace('p_start_eff_date     '|| p_start_eff_date);
    hr_utility.trace('p_legislation_code '  || p_legislation_code);
    hr_utility.trace('p_sepchk_run_type_id '|| p_sepchk_run_type_id);
    hr_utility.trace('p_ytd_balcall_aaid '  || p_ytd_balcall_aaid);
    hr_utility.trace('p_curr_pymt_action_id  '
                     ||to_char(p_curr_pymt_action_id ));


    lv_run_bal_status := check_run_balance_status(
                              p_assignment_id      => p_assignment_id
                             ,p_curr_pymt_eff_date => p_curr_pymt_eff_date
                             ,p_legislation_code   => p_legislation_code);

    if lv_run_bal_status = 'Y' then
       open c_prev_ytd_action_elem_rbr(p_assignment_id,
                                       p_curr_pymt_eff_date,
                                       p_start_eff_date);
    else
       open c_prev_ytd_action_elements(p_assignment_id
                                      ,p_curr_pymt_eff_date
                                      ,p_start_eff_date
                                      ,p_action_type1
                                      ,p_action_type2
                                      ,p_action_type3);
    end if;

    loop
       if lv_run_bal_status = 'Y' then
          fetch c_prev_ytd_action_elem_rbr into
                               lv_element_classification_name,
                               ln_processing_priority,
                               lv_reporting_name,
                               --lv_element_name,
                               ln_element_type_id,
                               lv_jurisdiction_code,
                               ln_primary_balance_id,
                               ln_hours_balance_id;
          if c_prev_ytd_action_elem_rbr%notfound then
             hr_utility.set_location(gv_package || lv_procedure_name, 40);
             exit;
          end if;
       else
          fetch c_prev_ytd_action_elements into
                               lv_element_classification_name,
                               ln_processing_priority,
                               lv_reporting_name,
                               --lv_element_name,
                               ln_element_type_id,
                               lv_jurisdiction_code,
                               ln_primary_balance_id,
                               ln_hours_balance_id;
          if c_prev_ytd_action_elements%notfound then
             hr_utility.set_location(gv_package || lv_procedure_name, 45);
             exit;
          end if;
       end if;

       hr_utility.set_location(gv_package  || lv_procedure_name, 50);
       hr_utility.trace('Ele type id = '   || ln_element_type_id);
       hr_utility.trace('Reporting Name = '|| lv_reporting_name);
       hr_utility.trace('Primary Bal id = '|| ln_primary_balance_id);
       hr_utility.trace('JD Code = '       || lv_jurisdiction_code);
       hr_utility.trace('Ele Class = '     || lv_element_classification_name);

       if lv_element_classification_name like '% Deductions' then
          ln_step := 10;
          ln_hours_balance_id := null;
       end if;

       /**********************************************************
       ** check whether the element has already been archived
       ** when archiving the Current Action. If it has been archived
       ** skip the element
       **********************************************************/
       ln_step := 15;
       if pay_ac_action_arch.emp_elements_tab.count > 0 then
          for i in pay_ac_action_arch.emp_elements_tab.first ..
                   pay_ac_action_arch.emp_elements_tab.last loop

              if pay_ac_action_arch.emp_elements_tab(i).element_primary_balance_id
                           = ln_primary_balance_id and
                 pay_ac_action_arch.emp_elements_tab(i).jurisdiction_code
                            = lv_jurisdiction_code then

                 hr_utility.set_location(gv_package  || lv_procedure_name, 65);
                 lv_element_archived := 'Y';
                 exit;
              end if;
          end loop;
       end if;

       if lv_element_archived = 'N' then
          ln_step := 20;
          hr_utility.set_location(gv_package  || lv_procedure_name, 70);
          ln_element_index := pay_ac_action_arch.emp_elements_tab.count;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_type_id
                         := ln_element_type_id;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_classfn
                         := lv_element_classification_name;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_reporting_name
                         := lv_reporting_name;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_primary_balance_id
                         := ln_primary_balance_id;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_processing_priority
                         := ln_processing_priority;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_hours_balance_id
                         := ln_hours_balance_id;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).jurisdiction_code
                         := lv_jurisdiction_code;

          /*****************************************************************
          ** The Payment Assignemnt Action is not passed to this procedure
          ** as we do not want to call the Payment Balance.
          *****************************************************************/
          hr_utility.set_location(gv_package || lv_procedure_name, 80);

          ln_step := 25;
          populate_elements(p_xfr_action_id             => p_xfr_action_id
                           ,p_pymt_assignment_action_id => p_curr_pymt_action_id
                           ,p_pymt_eff_date             => p_curr_pymt_eff_date
                           ,p_element_type_id           => ln_element_type_id
                           ,p_primary_balance_id        => ln_primary_balance_id
                           ,p_hours_balance_id          => ln_hours_balance_id
                           ,p_processing_priority       => ln_processing_priority
                           ,p_element_classification_name
                                                => lv_element_classification_name
                           ,p_reporting_name            => lv_reporting_name
                           ,p_tax_unit_id               => p_tax_unit_id
                           ,p_pymt_balcall_aaid         => null
                           ,p_ytd_balcall_aaid          => p_ytd_balcall_aaid
                           ,p_jurisdiction_code         => lv_jurisdiction_code
                           ,p_legislation_code          => p_legislation_code
                           ,p_sepchk_flag               => p_sepchk_flag
                           ,p_sepchk_run_type_id        => p_sepchk_run_type_id
                           ,p_original_date_earned      => null
                           ,p_effective_start_date      => null
                           ,p_effective_end_date        => null
                           ,p_final_rate               => null
                           ,p_ytd_flag                 => 'N'
                           );
       end if;
       lv_element_archived := 'N'; -- Initilializing the variable back
                                   -- to N for the next element
       lv_element_classification_name := null;
       ln_element_type_id      := null;
       lv_jurisdiction_code    := null;
       ln_primary_balance_id   := null;
       ln_processing_priority  := null;
       lv_reporting_name       := null;
       ln_hours_balance_id     := null;
    end loop;

    -- Bug 3585754
    if lv_run_bal_status = 'Y' then
       close c_prev_ytd_action_elem_rbr;
    else
       close c_prev_ytd_action_elements;
    end if;

    hr_utility.set_location(gv_package || lv_procedure_name, 90);


    ln_step := 30;
    if pay_ac_action_arch.lrr_act_tab.count > 0 then
       for i in pay_ac_action_arch.lrr_act_tab.first ..
                pay_ac_action_arch.lrr_act_tab.last loop

           hr_utility.trace('after populate_elements ftp' ||
                 ' action_context_id is '                   ||
                 to_char(pay_ac_action_arch.lrr_act_tab(i).action_context_id));
           hr_utility.trace('action_info_category '       ||
                  pay_ac_action_arch.lrr_act_tab(i).action_info_category);
           hr_utility.trace('act_info1 is '              ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info1);
           hr_utility.trace('act_info10 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info10);
           hr_utility.trace('act_info3 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info3);
           hr_utility.trace('act_info4 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info4);
           hr_utility.trace('act_info5 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info5);
           hr_utility.trace('act_info6 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info6);
           hr_utility.trace('act_info7 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info7);
           hr_utility.trace('act_info8 '                 ||
                  pay_ac_action_arch.lrr_act_tab(i).act_info8);

       end loop;
    end if;

    hr_utility.set_location(gv_package  || lv_procedure_name, 110);

    ln_step := 35;
    if pay_ac_action_arch.emp_elements_tab.count > 0 then
       for j in pay_ac_action_arch.emp_elements_tab.first ..
                pay_ac_action_arch.emp_elements_tab.last loop

           hr_utility.trace('EMP_ELEMENTS_TAB.element_type '   ||
             to_char(pay_ac_action_arch.emp_elements_tab(j).element_type_id));
       end loop;
    end if;

    hr_utility.set_location(gv_package  || lv_procedure_name, 200);

   EXCEPTION
    when others then

      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_prev_ytd_elements;


  /******************************************************************
   Name      : first_time_process
   Purpose   : This procedure is called only if the archiver is run
               for the first time for an assignment. It gets all the
               elements which have been processed within a given
               calendar year till current payment date i.e. the
               end date of the Archiver run.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE first_time_process(p_assignment_id       in number
                              ,p_xfr_action_id       in number
                              ,p_curr_pymt_action_id in number
                              ,p_curr_pymt_eff_date  in date
                              ,p_curr_eff_date       in date
                              ,p_tax_unit_id         in number
                              ,p_sepchk_run_type_id  in number
                              ,p_ytd_balcall_aaid    in number
                              ,p_pymt_balcall_aaid   in number
                              ,p_sepchk_flag         in varchar2
                              ,p_legislation_code    in varchar2
                              )

  IS

   lv_procedure_name              VARCHAR2(100);
   lv_error_message               VARCHAR2(200);
   ln_step                        NUMBER;

  BEGIN
      ln_step := 1;
      lv_procedure_name := '.first_time_process';

      hr_utility.set_location(gv_package || lv_procedure_name, 10);
      hr_utility.trace('p_xfr_action_id' || p_xfr_action_id);
      hr_utility.trace('p_assignment_id '|| p_assignment_id);
      hr_utility.trace('p_curr_eff_date '|| p_curr_eff_date);
      hr_utility.trace('p_tax_unit_id '  || p_tax_unit_id);
      hr_utility.trace('p_sepchk_flag '  || p_sepchk_flag);
      hr_utility.trace('p_legislation_code '  || p_legislation_code);
      hr_utility.trace('p_sepchk_run_type_id '|| p_sepchk_run_type_id);
      hr_utility.trace('p_ytd_balcall_aaid '  || p_ytd_balcall_aaid);
      hr_utility.trace('p_pymt_balcall_aaid ' || p_pymt_balcall_aaid);
      hr_utility.trace('p_curr_pymt_action_id  '
                     ||to_char(p_curr_pymt_action_id ));

      hr_utility.set_location(gv_package || lv_procedure_name, 20);
      ln_step := 10;
      get_current_elements(p_xfr_action_id        => p_xfr_action_id
                          ,p_curr_pymt_action_id  => p_curr_pymt_action_id
                          ,p_curr_pymt_eff_date   => p_curr_pymt_eff_date
                          ,p_assignment_id        => p_assignment_id
                          ,p_tax_unit_id          => p_tax_unit_id
                          ,p_sepchk_run_type_id   => p_sepchk_run_type_id
                          ,p_sepchk_flag          => p_sepchk_flag
                          ,p_pymt_balcall_aaid    => p_pymt_balcall_aaid
                          ,p_ytd_balcall_aaid     => p_ytd_balcall_aaid
                          ,p_legislation_code     => p_legislation_code);
      hr_utility.set_location(gv_package  || lv_procedure_name, 30);

      ln_step := 20;
      get_prev_ytd_elements(p_assignment_id       => p_assignment_id
                           ,p_xfr_action_id       => p_xfr_action_id
                           ,p_curr_pymt_action_id => p_curr_pymt_action_id
                           ,p_curr_pymt_eff_date  => p_curr_pymt_eff_date
                           ,p_start_eff_date      => trunc(p_curr_pymt_eff_date, 'Y')
                           ,p_tax_unit_id         => p_tax_unit_id
                           ,p_ytd_balcall_aaid    => p_ytd_balcall_aaid
                           ,p_sepchk_flag         => p_sepchk_flag
                           ,p_sepchk_run_type_id  => p_sepchk_run_type_id
                           ,p_legislation_code    => p_legislation_code
                           ,p_action_type1        => 'R'
                           ,p_action_type2        => 'Q'
                           ,p_action_type3        => 'B');

      ln_step := 30;
      hr_utility.set_location(gv_package  || lv_procedure_name, 200);

   EXCEPTION
    when others then

      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END first_time_process;


  /******************************************************************
   Name      : populate_summary
   Purpose   : This procedure add the values for different
               classifications and inserts two rows for CURRENT and
               YTD Summary.
   Arguments :
   Notes     :
  ******************************************************************/
  PROCEDURE populate_summary(p_xfr_action_id in number)
  IS
    lv_earnings                    VARCHAR2(80):= 0;
    lv_supplemental_earnings       VARCHAR2(80):= 0;
    lv_imputed_Earnings            VARCHAR2(80):= 0;
    lv_non_payroll_payments        VARCHAR2(80):= 0;
    lv_pre_tax_deductions          VARCHAR2(80):= 0;
    lv_involuntary_deductions      VARCHAR2(80):= 0;
    lv_voluntary_deductions        VARCHAR2(80):= 0;
    lv_tax_deductions              VARCHAR2(80):= 0;
    lv_taxable_benefits            VARCHAR2(80):= 0;
    lv_alien_expat_earnings        VARCHAR2(80):= 0;

    lv_ytd_earnings                VARCHAR2(80):= 0;
    lv_ytd_supplemental_earnings   VARCHAR2(80):= 0;
    lv_ytd_imputed_Earnings        VARCHAR2(80):= 0;
    lv_ytd_non_payroll_payments    VARCHAR2(80):= 0;
    lv_ytd_pre_tax_deductions      VARCHAR2(80):= 0;
    lv_ytd_involuntary_deductions  VARCHAR2(80):= 0;
    lv_ytd_voluntary_deductions    VARCHAR2(80):= 0;
    lv_ytd_tax_deductions          VARCHAR2(80):= 0;
    lv_ytd_taxable_benefits        VARCHAR2(80):= 0;
    lv_ytd_alien_expat_earnings    VARCHAR2(80):= 0;

    ln_index                       NUMBER;
    lv_procedure_name              VARCHAR2(100) := '.populate_summary';
    lv_error_message               VARCHAR2(200);
    ln_step                        NUMBER;

    lv_current_label               VARCHAR2(100);
    lv_ytd_label                   VARCHAR2(100);
    j                              NUMBER := 0;

  BEGIN
       ln_step := 1;
       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       if pay_ac_action_arch.lrr_act_tab.count > 0 then
          hr_utility.set_location(gv_package || lv_procedure_name, 20);

          ln_step := 2;
          for i in pay_ac_action_arch.lrr_act_tab.first ..
                   pay_ac_action_arch.lrr_act_tab.last loop

              if pay_ac_action_arch.lrr_act_tab(i).action_context_id
                          = p_xfr_action_id then
                 if pay_ac_action_arch.lrr_act_tab(i).action_info_category
                            = 'AC EARNINGS' then
                    if pay_ac_action_arch.lrr_act_tab(i).act_info1
                               = 'Earnings' then
                       hr_utility.set_location(gv_package || lv_procedure_name, 30);
                       ln_step := 3;
                       lv_earnings
                          := lv_earnings +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info8),0);
                       lv_ytd_earnings
                          := lv_ytd_earnings +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info9),0);
                    elsif pay_ac_action_arch.lrr_act_tab(i).act_info1
                               = 'Supplemental Earnings' then
                       hr_utility.set_location(gv_package || lv_procedure_name, 40);
                       ln_step := 4;
                       lv_supplemental_earnings
                          := lv_supplemental_earnings +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info8),0);
                       lv_ytd_supplemental_earnings
                          := lv_ytd_supplemental_earnings +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info9),0);
                    elsif pay_ac_action_arch.lrr_act_tab(i).act_info1
                               = 'Imputed Earnings' then
                       hr_utility.set_location(gv_package || lv_procedure_name, 50);
                       ln_step := 5;
                       lv_imputed_earnings
                          := lv_imputed_earnings +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info8),0);
                       lv_ytd_imputed_earnings
                          := lv_ytd_imputed_earnings +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info9),0);
                    elsif pay_ac_action_arch.lrr_act_tab(i).act_info1
                               = 'Non-payroll Payments' then
                       hr_utility.set_location(gv_package || lv_procedure_name, 50);
                       ln_step := 6;
                       lv_non_payroll_payments
                          := lv_non_payroll_payments +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info8),0);
                       lv_ytd_non_payroll_payments
                          := lv_ytd_non_payroll_payments +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info9),0);
                    elsif pay_ac_action_arch.lrr_act_tab(i).act_info1
                               = 'Taxable Benefits' then
                       hr_utility.set_location(gv_package || lv_procedure_name, 55);
                       ln_step := 7;
                       lv_taxable_benefits
                          := lv_taxable_benefits +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info8),0);
                       lv_ytd_taxable_benefits
                          := lv_ytd_taxable_benefits +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info9),0);
                    elsif pay_ac_action_arch.lrr_act_tab(i).act_info1
                               = 'Alien/Expat Earnings' then
                       hr_utility.set_location(gv_package || lv_procedure_name, 56);
                       ln_step := 8;
                       lv_alien_expat_earnings
                          := lv_alien_expat_earnings +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info8),0);
                       lv_ytd_alien_expat_earnings
                          := lv_ytd_alien_expat_earnings +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info9),0);
                    end if;

                 elsif pay_ac_action_arch.lrr_act_tab(i).action_info_category
                            = 'AC DEDUCTIONS' then
                    if pay_ac_action_arch.lrr_act_tab(i).act_info1
                            = 'Pre-Tax Deductions' then
                       hr_utility.set_location(gv_package || lv_procedure_name, 60);
                       ln_step := 15;
                       lv_pre_tax_deductions
                          := lv_pre_tax_deductions +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info8),0);
                       lv_ytd_pre_tax_deductions
                          := lv_ytd_pre_tax_deductions +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info9),0);
                    elsif pay_ac_action_arch.lrr_act_tab(i).act_info1
                                   = 'Involuntary Deductions' then
                       hr_utility.set_location(gv_package || lv_procedure_name, 70);
                       ln_step := 16;
                       lv_involuntary_deductions
                          := lv_involuntary_deductions +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info8),0);
                       lv_ytd_involuntary_deductions
                          := lv_ytd_involuntary_deductions +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info9),0);
                    elsif pay_ac_action_arch.lrr_act_tab(i).act_info1
                                   = 'Voluntary Deductions' then
                       hr_utility.set_location(gv_package || lv_procedure_name, 80);
                       ln_step := 17;
                       lv_voluntary_deductions
                          := lv_voluntary_deductions +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info8),0);
                       lv_ytd_voluntary_deductions
                          := lv_ytd_voluntary_deductions +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info9),0);
                    elsif pay_ac_action_arch.lrr_act_tab(i).act_info1
                                   = 'Tax Deductions' then
                       hr_utility.set_location(gv_package || lv_procedure_name, 90);
                       ln_step := 18;
                       lv_tax_deductions
                          := lv_tax_deductions +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info8),0);
                       lv_ytd_tax_deductions
                          := lv_ytd_tax_deductions +
                             nvl(fnd_number.canonical_to_number(pay_ac_action_arch.lrr_act_tab(i).act_info9),0);
                    end if;
                 end if;
              end if;
          end loop;
       end if;

       hr_utility.set_location(gv_package || lv_procedure_name, 95);
       ln_step := 24;
       j := 0;
       if pay_ac_action_arch.ltr_summary_labels.count > 0 then
          for j in pay_ac_action_arch.ltr_summary_labels.first..
                   pay_ac_action_arch.ltr_summary_labels.last loop
              if pay_ac_action_arch.ltr_summary_labels(j).language
                      = pay_ac_action_arch.gv_person_lang and
                 pay_ac_action_arch.ltr_summary_labels(j).lookup_code = 'CURRENT' then
                 lv_current_label := pay_ac_action_arch.ltr_summary_labels(j).meaning;
              end if;

              if pay_ac_action_arch.ltr_summary_labels(j).language
                      = pay_ac_action_arch.gv_person_lang and
                 pay_ac_action_arch.ltr_summary_labels(j).lookup_code = 'YTD' then
                 lv_ytd_label := pay_ac_action_arch.ltr_summary_labels(j).meaning;
              end if;
          end loop;
        end if;

       hr_utility.set_location(gv_package || lv_procedure_name, 100);
       /* Insert one row for CURRENT and one for YTD */
       if pay_ac_action_arch.lrr_act_tab.count > 0 then
          ln_step := 25;
          -- CURRENT
          ln_index := pay_ac_action_arch.lrr_act_tab.count;
          hr_utility.trace('ln_index = ' || ln_index);
          pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                := 'AC SUMMARY CURRENT';
          pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                := '00-000-0000';
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info4
                := fnd_number.number_to_canonical(lv_earnings);  /*Bug 3311866*/
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info5
                := fnd_number.number_to_canonical(lv_supplemental_earnings) ;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                := fnd_number.number_to_canonical(lv_imputed_earnings);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                := fnd_number.number_to_canonical(lv_pre_tax_deductions) ;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                := fnd_number.number_to_canonical(lv_involuntary_deductions);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                := fnd_number.number_to_canonical(lv_voluntary_deductions) ;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                := fnd_number.number_to_canonical(lv_tax_deductions) ;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                := fnd_number.number_to_canonical(lv_taxable_benefits);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                := fnd_number.number_to_canonical(lv_alien_expat_earnings);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info13
                := fnd_number.number_to_canonical(lv_non_payroll_payments);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info14
                := lv_current_label;

          hr_utility.set_location(gv_package || lv_procedure_name, 120);
          -- YTD
          ln_index := pay_ac_action_arch.lrr_act_tab.count;
          hr_utility.trace('ln_index = ' || ln_index);
          pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                := 'AC SUMMARY YTD';
          pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                := '00-000-0000';
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info4
                := fnd_number.number_to_canonical(lv_ytd_earnings);  /*Bug 3311866*/
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info5
                := fnd_number.number_to_canonical(lv_ytd_supplemental_earnings) ;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                := fnd_number.number_to_canonical(lv_ytd_imputed_earnings);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                := fnd_number.number_to_canonical(lv_ytd_pre_tax_deductions) ;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                := fnd_number.number_to_canonical(lv_ytd_involuntary_deductions);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                := fnd_number.number_to_canonical(lv_ytd_voluntary_deductions) ;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                := fnd_number.number_to_canonical(lv_ytd_tax_deductions) ;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                := fnd_number.number_to_canonical(lv_ytd_taxable_benefits);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                := fnd_number.number_to_canonical(lv_ytd_alien_expat_earnings);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info13
                := fnd_number.number_to_canonical(lv_ytd_non_payroll_payments);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info14
                := lv_ytd_label;
       end if;

       hr_utility.set_location(gv_package || lv_procedure_name, 200);
       ln_step := 15;

  EXCEPTION
    when others then

      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END populate_summary;

  /******************************************************************
   Name      : process_additional_elements
   Purpose   : Retrieve the elements processed in the given assignment
               and insert YTD balance to pl/sql table.
   Arguments : p_assignment_id        => Terminated Assignment Id
               p_assignment_action_id => Max assignment action id
                                         of given assignment
               p_curr_eff_date        => Current effective date
               p_xfr_action_id        => Current XFR action id.
   Notes     : This process is used to retrieve elements processed
               in terminated assignments which is not picked up by
               the archiver.
  ******************************************************************/
  PROCEDURE process_additional_elements(p_assignment_id in number
                                  ,p_assignment_action_id in number
                                  ,p_curr_eff_date in date
                                  ,p_xfr_action_id in number
                                  ,p_legislation_code in varchar2
                                  ,p_tax_unit_id in number)
  IS

    lv_procedure_name           VARCHAR2(50) := '.process_additional_elements';
    lv_element_classification_name     VARCHAR2(80);
    ln_processing_priority         NUMBER;
    lv_reporting_name              VARCHAR2(80);
    ln_element_type_id             NUMBER;
    lv_jurisdiction_code           VARCHAR2(80);
    ln_primary_balance_id          NUMBER;
    ln_hours_balance_id            NUMBER;
    ln_element_index               NUMBER;
    lv_action_category             VARCHAR2(50) := 'AC DEDUCTIONS';
    ln_ytd_defined_balance_id      NUMBER;
    ln_ytd_amount                  NUMBER(15,2) := 0;
    ln_ytd_hours_balance_id        NUMBER;
    ln_ytd_hours                   NUMBER(15,2);
    ln_current_hours               NUMBER(15,2) := 0;
    ln_payments_amount             NUMBER(15,2) := 0;
    ln_index                       NUMBER;
    ln_check_count                 number;
    ln_check_count2                number;
    ln_step                        NUMBER;
    lv_error_message               VARCHAR2(200);

  BEGIN
    hr_utility.set_location(gv_package || lv_procedure_name, 10);

    ln_step := 10;
    pay_balance_pkg.set_context('TAX_UNIT_ID',p_tax_unit_id); -- Bug 3639249
    OPEN c_prev_ytd_action_elements(p_assignment_id
                                   ,p_curr_eff_date
                                   ,trunc(p_curr_eff_date, 'Y')
                                   ,'R', 'Q', 'B');
    LOOP
       FETCH c_prev_ytd_action_elements into lv_element_classification_name,
                                             ln_processing_priority,
                                             lv_reporting_name,
                                             ln_element_type_id,
                                             lv_jurisdiction_code,
                                             ln_primary_balance_id,
                                             ln_hours_balance_id;
       IF c_prev_ytd_action_elements%NOTFOUND then
          hr_utility.set_location(gv_package || lv_procedure_name, 15);
          exit;
       END IF;

       ln_step := 20;
       hr_utility.set_location(gv_package || lv_procedure_name, 20);
       hr_utility.trace('================= Fetched Element ==================');
       hr_utility.trace('ele classification = '||lv_element_classification_name);
       hr_utility.trace('ele type id = ' || ln_element_type_id);
       hr_utility.trace('reporting name = ' || lv_reporting_name);
       hr_utility.trace('primary balance id = ' || ln_primary_balance_id);
       hr_utility.trace('hours balance id = ' || ln_hours_balance_id);

       if lv_jurisdiction_code <> '00-000-0000' then
          pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
          gv_ytd_balance_dimension := gv_dim_asg_jd_gre_ytd;
       else
          pay_balance_pkg.set_context('JURISDICTION_CODE', lv_jurisdiction_code);
          if gv_reporting_level = 'TAXGRP' then
             gv_ytd_balance_dimension := gv_dim_asg_tg_ytd;
          else
             gv_ytd_balance_dimension := gv_dim_asg_gre_ytd;
          end if;
       end if;

       if lv_element_classification_name like '% Deductions' then
          ln_hours_balance_id := null;
       end if;

       if ln_hours_balance_id is not null then
          ln_step := 30;
          hr_utility.set_location(gv_package || lv_procedure_name, 22);
          ln_ytd_hours_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                            ln_hours_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);
          hr_utility.trace('ln_ytd_hours_balance_id = '||
                             ln_ytd_hours_balance_id);
          hr_utility.set_location(gv_package || lv_procedure_name, 24);

          ln_step := 40;
          if ln_ytd_hours_balance_id is not null then
               ln_ytd_hours := nvl(pay_balance_pkg.get_value(
                                      ln_ytd_hours_balance_id,
                                      p_assignment_action_id),0);
               hr_utility.trace('ln_ytd_hours = '||ln_ytd_hours);
               hr_utility.set_location(gv_package || lv_procedure_name, 26);
          end if;
       end if; --Hours

       ln_step := 50;
       ln_ytd_defined_balance_id
                  := pay_emp_action_arch.get_defined_balance_id
                                          (ln_primary_balance_id,
                                           gv_ytd_balance_dimension,
                                           p_legislation_code);
       hr_utility.trace('ln_ytd_defined_balance_id = '||
                         ln_ytd_defined_balance_id);
       hr_utility.set_location(gv_package || lv_procedure_name, 30);
       if ln_ytd_defined_balance_id is not null then
          ln_step := 60;
          ln_ytd_amount := nvl(pay_balance_pkg.get_value(
                                     ln_ytd_defined_balance_id,
                                     p_assignment_action_id),0);
          hr_utility.trace('ln_ytd_amount = '||ln_ytd_amount);
       end if;
       hr_utility.set_location(gv_package || lv_procedure_name, 40);


       if nvl(ln_ytd_amount, 0) <> 0 then
          ln_step := 70;
          ln_element_index := pay_ac_action_arch.emp_elements_tab.count;

          hr_utility.trace('ln_element_index = '||ln_element_index);

          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_type_id
                        := ln_element_type_id;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_classfn
                        := lv_element_classification_name;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_reporting_name
                        := lv_reporting_name;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_primary_balance_id
                        := ln_primary_balance_id;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_processing_priority
                        := ln_processing_priority;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).element_hours_balance_id
                        := ln_hours_balance_id;
          pay_ac_action_arch.emp_elements_tab(ln_element_index).jurisdiction_code
                        := lv_jurisdiction_code;


          ln_index := pay_ac_action_arch.lrr_act_tab.count;
          hr_utility.trace('ln_index = '||ln_index);
          if lv_element_classification_name in ('Earnings',
                                               'Supplemental Earnings',
                                               'Taxable Benefits',
                                               'Imputed Earnings',
                                               'Non-payroll Payments',
                                               'Alien/Expat Earnings') then
              hr_utility.set_location(gv_package || lv_procedure_name, 50);
              lv_action_category := 'AC EARNINGS';
              hr_utility.trace('ln_current_hours = '||ln_current_hours);
              hr_utility.trace('ln_ytd_hours = '||ln_ytd_hours);
              ln_step := 80;
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                     := fnd_number.number_to_canonical(ln_current_hours); /*Bug 3311866*/
              pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                     := fnd_number.number_to_canonical(ln_ytd_hours);
          else
              lv_action_category := 'AC DEDUCTIONS';
          end if;
          hr_utility.set_location(gv_package || lv_procedure_name, 60);
          hr_utility.trace('lv_action_category = '||lv_action_category);
          hr_utility.trace('ln_ytd_amount = '||ln_ytd_amount);
          hr_utility.trace('lv_reporting_name = '||lv_reporting_name);
          hr_utility.trace('p_xfr_action_id = '||p_xfr_action_id);
          ln_step := 90;

          pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                    := lv_action_category;
          pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                   := nvl(lv_jurisdiction_code, '00-000-0000');
          pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                   := p_xfr_action_id;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                   := lv_element_classification_name;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                   := ln_element_type_id;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                   := ln_primary_balance_id;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                   := ln_processing_priority;
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                   := fnd_number.number_to_canonical(ln_payments_amount); /*Bug 3311866*/
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                   := fnd_number.number_to_canonical(ln_ytd_amount);
          pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                   := lv_reporting_name;

      end if;
      hr_utility.set_location(gv_package || lv_procedure_name, 100);

    END LOOP;
    CLOSE c_prev_ytd_action_elements;

    ln_step := 110;
    hr_utility.trace('------------Looping to see pl/sql table --------');
    ln_check_count := pay_ac_action_arch.emp_elements_tab.count;
    ln_check_count2 := pay_ac_action_arch.lrr_act_tab.count;

    hr_utility.trace('ln_check_count = '||ln_check_count);
    hr_utility.trace('ln_check_count2 = '||ln_check_count2);
    hr_utility.trace('============= End of Processing '||p_assignment_id||
                     '=============');
    hr_utility.set_location(gv_package || lv_procedure_name,150);

  EXCEPTION
    when others then

      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END process_additional_elements;

  /******************************************************************
   Name      : process_balance_adjustment_elements
   Purpose   : Retrieve the elements processed in the given assignment
               and insert YTD balance to pl/sql table.
   Arguments : p_assignment_id        => Assignment Id
   Notes     : This process is used to retrieve elements processed
               in balance adjustment but have never been processed in
               payroll run.
  ******************************************************************/
  PROCEDURE process_baladj_elements(
                               p_assignment_id        in number
                              ,p_xfr_action_id        in number
                              ,p_last_xfr_action_id   in number
                              ,p_curr_pymt_action_id  in number
                              ,p_curr_pymt_eff_date   in date
                              ,p_ytd_balcall_aaid     in number
                              ,p_sepchk_flag          in varchar2
                              ,p_sepchk_run_type_id   in number
                              ,p_payroll_id           in number
                              ,p_consolidation_set_id in number
                              ,p_legislation_code     in varchar2
                              ,p_tax_unit_id          in number)
  IS
    cursor c_check_baladj(cp_assignment_id in number
                                     ,cp_xfr_action_id in number
                                     ,cp_tax_unit_id   in number
                                     ,cp_payroll_id    in number
                                     ,cp_consolidation_set_id in number
                                     ,cp_curr_eff_date in date) is
      select  /*+ leading(PPA) index(PPA, PAY_PAYROLL_ACTIONS_N51)
                                           index(PAA, PAY_ASSIGNMENT_ACTIONS_N51) */
                min(ppa.effective_date)
        from pay_payroll_actions        ppa
	       ,pay_assignment_actions paa
       where ppa.action_type                 = 'B'
           and paa.payroll_action_id         = ppa.payroll_action_id
           and paa.action_status               = 'C'
           and paa.assignment_action_id   > cp_xfr_action_id
           and paa.assignment_id             = cp_assignment_id
           and paa.tax_unit_id                  = cp_tax_unit_id
           and ppa.effective_date             >= trunc(cp_curr_eff_date, 'Y')
           and ppa.effective_date             <= cp_curr_eff_date
           and ppa.payroll_id                    = cp_payroll_id
           and ppa.consolidation_set_id     = cp_consolidation_set_id;

    ld_baladj_date    DATE;
    ln_step           NUMBER;
    lv_error_message  VARCHAR2(200);
    lv_procedure_name VARCHAR2(50);

  BEGIN
    ln_step := 1;
    lv_procedure_name := '.process_baladj_elements';
    hr_utility.set_location(gv_package || lv_procedure_name, 10);

    open c_check_baladj(p_assignment_id
                       ,p_last_xfr_action_id
                       ,p_tax_unit_id
                       ,p_payroll_id
                       ,p_consolidation_set_id
                       ,p_curr_pymt_eff_date);
    fetch c_check_baladj into ld_baladj_date;
    hr_utility.set_location(gv_package || lv_procedure_name, 20);
    ln_step := 10;
    if c_check_baladj%found then
       -- There is atleast one balance adjustment done since the last archive
       -- run, so, need to find out the element and process it
       hr_utility.set_location(gv_package || lv_procedure_name, 30);
       get_prev_ytd_elements(p_assignment_id       => p_assignment_id
                            ,p_xfr_action_id       => p_xfr_action_id
                            ,p_curr_pymt_action_id => p_curr_pymt_action_id
                            ,p_curr_pymt_eff_date  => p_curr_pymt_eff_date
                            ,p_start_eff_date      => ld_baladj_date
                            ,p_tax_unit_id         => p_tax_unit_id
                            ,p_ytd_balcall_aaid    => p_ytd_balcall_aaid
                            ,p_sepchk_flag         => p_sepchk_flag
                            ,p_sepchk_run_type_id  => p_sepchk_run_type_id
                            ,p_legislation_code    => p_legislation_code
                            ,p_action_type1        => 'B'
                            ,p_action_type2        => ''
                            ,p_action_type3        => '');
    end if;
    close c_check_baladj;
    hr_utility.set_location(gv_package || lv_procedure_name, 50);
    ln_step := 20;

   EXCEPTION
    when others then

      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || sqlerrm);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END process_baladj_elements;

  Procedure Archive_retro_element  (
                                     p_xfr_action_id               in  number
                                    ,p_assignment_id               in number
                                    ,p_pymt_assignment_action_id   in number
                                    ,p_pymt_eff_date               in date
                                    ,p_element_type_id             in number
                                    ,p_primary_balance_id          in number
                                    ,p_hours_balance_id            in number
                                    ,p_processing_priority         in number
                                    ,p_element_classification_name in varchar2
                                    ,p_reporting_name              in varchar2
                                    ,p_tax_unit_id                 in number
                                    ,p_ytd_balcall_aaid            in number
                                    ,p_pymt_balcall_aaid           in number
                                    ,p_legislation_code            in varchar2
                                    ,p_sepchk_flag                 in varchar2
                                    ,p_sepchk_run_type_id          in number
                                    ,p_action_type                 in varchar2
                                    ,p_run_assignment_action_id    in number
                                    ,p_multiple                    in number
                                    ,p_rate                        in number
				    ,p_retro_base                  IN VARCHAR2 DEFAULT 'N'
                                    )
 IS
 /*
 TYPE retro_rec_typ IS RECORD(original_dt_earned DATE
                             ,original_st_dt DATE
                             ,original_end_dt DATE
                             ,category VARCHAR2(100)
                             ,jurisdiction VARCHAR2(20)
                             ,hours  NUMBER
                             ,ytd_hrs NUMBER
                             ,amount NUMBER
                             ,ytd_amt NUMBER
                             );
 TYPE retro_tab_typ IS TABLE OF retro_rec_typ INDEX BY BINARY_INTEGER;
 */
 CURSOR archive_retro_elements ( cp_element_entry_id in number ,
                                  cp_run_assignment_action_id in number ) IS

        select fnd_date.date_to_canonical(pay_paywsmee_pkg.get_original_date_earned(cp_element_entry_id)) ,
       fnd_date.date_to_canonical(ptp.start_date),
                 fnd_date.date_to_canonical(ptp.end_date),
                hr_general.decode_lookup
                            (DECODE (UPPER (ec.classification_name),
                                     'EARNINGS', 'US_EARNINGS',
                                     'SUPPLEMENTAL EARNINGS', 'US_SUPPLEMENTAL_EARNINGS',
                                     'IMPUTED EARNINGS', 'US_IMPUTED_EARNINGS',
                                     'NON-PAYROLL PAYMENTS', 'US_PAYMENT',
                                     'ALIEN/EXPAT EARNINGS', 'PER_US_INCOME_TYPES',
                                     NULL
                                    ),
                             et.element_information1
                            ) CATEGORY
 from pay_element_entries_f peef,
      per_time_periods ptp,
      pay_payroll_actions ppa,
      pay_assignment_actions paa,
      pay_element_types_f et,
      pay_element_classifications ec
where peef.element_entry_id = cp_element_entry_id
  AND peef.creator_type IN ('EE', 'NR', 'PR', 'R', 'RR')
  AND et.element_type_id = peef.element_type_id
  AND et.classification_id = ec.classification_id
  AND paa.assignment_action_id = cp_run_assignment_action_id
  AND ppa.payroll_action_id = paa.payroll_action_id
  AND ptp.payroll_id = ppa.payroll_id
  AND pay_paywsmee_pkg.get_original_date_earned(cp_element_entry_id)
                   BETWEEN ptp.start_date
                       AND ptp.end_date ;

  CURSOR get_element_entry_id(cp_run_action_id in number ,
                              cp_assignment_id in number ,
                              cp_element_type_id in number ) IS
           SELECT peef.element_entry_id,
                  peef.creator_type,
                  peef.source_start_date
           FROM pay_element_entries_f peef,
                pay_assignment_actions paa,
                pay_payroll_actions ppa,
                per_time_periods ptp
            WHERE paa.assignment_action_id = cp_run_action_id
            AND ppa.payroll_action_id = paa.payroll_action_id
            AND ptp.payroll_id = ppa.payroll_id
            AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date
            AND peef.assignment_id = cp_assignment_id
            AND peef.creator_id is NOT NULL
            /* Following Added for Bug# 7580440 */
            AND peef.creator_type IN ('EE', 'NR', 'PR', 'R', 'RR')
            AND peef.element_type_id = cp_element_type_id

            /* Commenting as Ele Entry Eff Start / End Date may not match the following
            AND peef.effective_start_date BETWEEN ptp.start_date AND ptp.end_date
            AND peef.effective_end_date BETWEEN ptp.start_date AND ptp.end_date
            End of Comment */

            AND NVL(ppa.date_earned, ppa.effective_date) BETWEEN peef.effective_start_date AND peef.effective_end_date

            ORDER BY 3;

-- Changed for performance issue Bug# 7661112
--
CURSOR get_run_results (cp_run_assignment_action_id IN NUMBER
                       ,cp_element_entry_id IN NUMBER) IS
SELECT   to_number(prrv.result_value), pivf.NAME
    FROM pay_run_results prr,
         pay_run_result_values prrv,
         pay_input_values_f pivf
   WHERE prr.assignment_action_id = cp_run_assignment_action_id
     AND prr.element_entry_id = cp_element_entry_id
     AND prrv.run_result_id = prr.run_result_id
     AND prrv.input_value_id = pivf.input_value_id
     AND pivf.NAME IN ('Pay Value', 'Hours')
ORDER BY 2 ;

-- Introducing This Cussor in case Hours and Pay Values Both zero
--
-- Changed for performance issue Bug# 7661112
--
CURSOR get_run_results_rate(cp_run_assignment_action_id IN NUMBER
                           ,cp_element_entry_id IN NUMBER) IS
SELECT   to_number(prrv.result_value)
    FROM pay_run_results prr,
         pay_run_result_values prrv,
         pay_input_values_f pivf
   WHERE prr.assignment_action_id = cp_run_assignment_action_id
     AND prr.element_entry_id = cp_element_entry_id
     AND prrv.run_result_id = prr.run_result_id
     AND prrv.input_value_id = pivf.input_value_id
     AND pivf.NAME IN ('Rate');

-- Added For Work At Home Condition

    CURSOR c_cur_get_wrkathome(cp_assignment_id IN NUMBER) IS
      SELECT NVL(paf.work_at_home, 'N')
            ,ppf.person_id
            ,ppf.business_group_id
      FROM per_assignments_f paf
          ,per_all_people_f ppf
      WHERE paf.assignment_id = cp_assignment_id
      AND   paf.person_id = ppf.person_id;

    CURSOR c_cur_home_state_jd(cp_person_id IN NUMBER
                              ,cp_bg_id     IN NUMBER) IS
      SELECT pus.state_code || '-000-0000'
      FROM per_addresses pa
          ,pay_us_states pus
      WHERE pa.person_id = cp_person_id
      AND   pa.primary_flag = 'Y'
      AND   p_pymt_eff_date between pa.date_from AND NVL(pa.date_to, hr_general.END_OF_TIME)
      AND   pa.business_group_id = cp_bg_id
      AND   pa.region_2 = pus.state_abbrev
      AND   pa.style = p_legislation_code;

 --retro_tab                       retro_tab_typ;
 --retro_refined_tab               retro_tab_typ;
 --cnt                             NUMBER;
 --k                               NUMBER;
 --k_match_cnt                     NUMBER;
 lv_original_date_earned         varchar2(100);
 lv_effective_start_date         varchar2(100);
 lv_effective_end_date           varchar2(100);
 lv_category                     varchar2(100);
 lv_el_jurisdiction_code         varchar2(100);
 ln_final_rate                   number;
 ln_element_entry_id             number;
 lv_creator_type                 varchar2(100);
 lv_jurisdiction_flag            varchar2(20);
 ln_element_index                number;
 ln_multiple                     number;
 ln_rate                         number(10,2);
 ln_current_hours           NUMBER(15,5);
 ln_payments_amount         NUMBER(15,5);
 ln_ytd_hours               NUMBER(15,5) := 0;
 ln_ytd_amount              NUMBER(17,5) := 0;

 ln_pymt_defined_balance_id NUMBER;
 ln_pymt_hours_balance_id   NUMBER;
 ln_ytd_defined_balance_id  NUMBER;
 ln_ytd_hours_balance_id    NUMBER;

 lv_rate_exists             VARCHAR2(1) := 'N';
 ln_nonpayroll_balcall_aaid NUMBER;

 ln_index                   NUMBER ;
 lv_procedure_name          VARCHAR2(100):= '.Archive_retro_element';
 lv_error_message           VARCHAR2(200);

 ln_step                    NUMBER;
 ln_final_ytd_value         NUMBER(15,5);
 ld_source_start_date       DATE;
 lv_action_category         varchar2(100);
 lv_pay_value_name          varchar2(100);
 ln_pay_value               number (15,5);
 ln_hours                   number(15,5) ;
 ln_amount                  number(15,5);
-- Added For Work At Home Condition
 lv_wrk_at_home                 per_assignments_f.work_at_home%TYPE;
 ln_person_id                   per_people_f.person_id%TYPE;
 ln_bg_id                       per_people_f.business_group_id%TYPE;

 BEGIN

 hr_utility.trace('Entering in package Archive_retro_element');
 hr_utility.trace('Run_assifnment_action_id = ' || p_run_assignment_action_id) ;
 OPEN get_element_entry_id ( p_run_assignment_action_id,
                             p_assignment_id,
                             p_element_type_id);
 ln_step := 50;

       ln_ytd_hours := 0;
       ln_ytd_amount := 0;
       ln_hours := 0;
       ln_amount := 0;
-- cnt := 0;
 LOOP -- For Each Ele Entry created by Retro

       FETCH get_element_entry_id INTO ln_element_entry_id,
                                       lv_creator_type,
                                       ld_source_start_date;

       IF  get_element_entry_id%NOTFOUND THEN
           close get_element_entry_id;
           EXIT;
       END IF;
       hr_utility.trace('Step 50 : ln_element_entry_id := '||ln_element_entry_id);
       hr_utility.trace('Step 50 : lv_creator_type := '||lv_creator_type);
       hr_utility.trace('Step 50 : ld_source_start_date := '||ld_source_start_date);

       OPEN get_run_results (p_run_assignment_action_id
                            ,ln_element_entry_id);
       LOOP
           ln_step := 49;
           FETCH get_run_results INTO ln_pay_value ,
                                      lv_pay_value_name;
           IF get_run_results%FOUND THEN
              IF lv_pay_value_name = 'Hours' THEN
                 ln_ytd_hours := ln_ytd_hours + nvl(ln_pay_value,0) ;
                 ln_hours := nvl(ln_pay_value,0);
                 hr_utility.trace('ln_hours := '||ln_hours);
                 hr_utility.trace('ln_ytd_hours  is '|| ln_ytd_hours );

              END IF ;

              IF lv_pay_value_name = 'Pay Value' THEN
                 ln_ytd_amount := ln_ytd_amount + nvl(ln_pay_value,0) ;
                 ln_amount := nvl(ln_pay_value,0) ;
                 hr_utility.trace('ln_amount := '||ln_amount);
                 hr_utility.trace('ln_ytd_amount  is '|| ln_ytd_amount );
              END IF;
            ELSE
                EXIT;
            END IF;
       END LOOP; -- Run Results

       ln_step := 48;

       IF get_run_results%ISOPEN THEN
        CLOSE get_run_results ;
       END IF;

       IF ln_hours = 0 THEN
          IF ln_amount = 0 THEN
             OPEN get_run_results_rate(p_run_assignment_action_id
                                      ,ln_element_entry_id);
             FETCH get_run_results_rate INTO ln_rate;
             CLOSE get_run_results_rate;
          ELSE
             ln_rate := NULL;
          END IF;
       ELSE
           ln_rate := ln_amount/ln_hours;
       END IF;

       hr_utility.trace('Before Opening Cursor archive_retro_elements');
       OPEN archive_retro_elements ( ln_element_entry_id ,
                                     p_run_assignment_action_id );
       FETCH archive_retro_elements INTO  lv_original_date_earned
                                         ,lv_effective_start_date
                                         ,lv_effective_end_date
                                         ,lv_category;
       CLOSE archive_retro_elements ;
       hr_utility.trace('After Closing Cursor archive_retro_elements');
       hr_utility.trace('lv_original_date_earned := '||lv_original_date_earned);
       hr_utility.trace('lv_effective_start_date := '||lv_effective_start_date);
       hr_utility.trace('lv_effective_end_date := '||lv_effective_end_date);
       hr_utility.trace('lv_category := '||lv_category);

       -- Added For Work At Home Condition
       OPEN c_cur_get_wrkathome(p_assignment_id);
       FETCH c_cur_get_wrkathome INTO lv_wrk_at_home
                                      ,ln_person_id
                                      ,ln_bg_id;
       CLOSE c_cur_get_wrkathome;

       IF lv_wrk_at_home = 'Y' THEN
               OPEN c_cur_home_state_jd(ln_person_id
                                  ,ln_bg_id);
               FETCH c_cur_home_state_jd INTO lv_jurisdiction_flag;
               CLOSE c_cur_home_state_jd;
       ELSE

          SELECT nvl((select peevf.screen_entry_value  jurisdiction_code
                    from pay_input_values_f pivf,
                         pay_element_entry_values_f peevf
                    where pivf.element_type_id = p_element_type_id
                    AND pivf.NAME = 'Jurisdiction'
                    AND peevf.element_entry_id =  ln_element_entry_id
                    AND pivf.input_value_id = peevf.input_value_id),(SELECT   distinct pus.state_code
               || '-'
               || puc.county_code
               || '-'
               || punc.city_code jurisdiction_code
               FROM per_all_assignments_f peaf,
               hr_locations_all hla,
               pay_us_states pus,
               pay_us_counties puc,
               pay_us_city_names punc,
               pay_assignment_actions paa,
               pay_payroll_actions ppa
         WHERE peaf.assignment_id = p_assignment_id
           AND paa.assignment_action_id = p_run_assignment_action_id
           AND peaf.location_id = hla.location_id
           AND hla.region_2 = pus.state_abbrev
           AND pus.state_code = puc.state_code
           AND hla.region_1 = puc.county_name
           AND hla.town_or_city = punc.city_name
           AND pus.state_code = punc.state_code
           AND puc.county_code = punc.county_code
           AND ppa.payroll_action_id = paa.payroll_action_id
           AND ppa.effective_date between peaf.effective_start_date and peaf.effective_end_date
           ))
           into lv_jurisdiction_flag
           from dual;
      END IF; -- Work At Home 'N'

           -- populating temporary plsql table
           --
           hr_utility.trace('lv_jurisdiction_flag := '||lv_jurisdiction_flag);
-- Comment Starts From Here
-- Comment Till Here

           lv_action_category := 'AC DEDUCTIONS';

           ln_step := 15;
           ln_index := pay_ac_action_arch.lrr_act_tab.count;

	   if p_element_classification_name in ('Earnings',
                                                 'Supplemental Earnings',
                                                 'Taxable Benefits',
                                                 'Imputed Earnings',
                                                 'Non-payroll Payments',
                                                 'Alien/Expat Earnings') then

	     lv_action_category := 'AC EARNINGS';

	     pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                     := fnd_number.number_to_canonical(ln_hours);


	     -- YTD Hours
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info22
                   := ln_rate;

             pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
                         := fnd_number.number_to_canonical(0);

	     end if; -- Classification Earnings

	     hr_utility.set_location(gv_package || lv_procedure_name, 130);

	    /* Insert this into the plsql table if Current or YTD
              amount is not Zero */

	     ln_step :=21;
             pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                    := lv_action_category;
              ln_step :=22;
             pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                   :=  '00-000-0000' ;
              ln_step :=23;
             pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                   := p_xfr_action_id;
              ln_step :=24;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                   := p_element_classification_name;
              ln_step :=25;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                   := p_element_type_id;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                   := p_primary_balance_id;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                   := p_processing_priority;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                   := fnd_number.number_to_canonical(nvl(ln_amount,0));

	     hr_utility.trace('ln_amount := '||fnd_number.number_to_canonical(nvl(ln_amount,0)));

	     pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                   := p_reporting_name;
             IF lv_action_category = 'AC DEDUCTIONS' THEN
                 pay_ac_action_arch.lrr_act_tab(ln_index).act_info24
                   := p_reporting_name;
             END IF;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info17
                   := lv_original_date_earned;
                   hr_utility.trace('lv_original_date_earned :=' || lv_original_date_earned );
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info18
                   := lv_effective_start_date;
                   hr_utility.trace('lv_effective_start_date := ' || lv_effective_start_date );
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info19
                   := lv_effective_end_date ;
                  hr_utility.trace('lv_effective_end_date:= ' || lv_effective_end_date );
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info20
                   := lv_category;
                   hr_utility.trace('lv_category ' || lv_category );
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info21
                   := lv_jurisdiction_flag;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                           := fnd_number.number_to_canonical(0);

      hr_utility.set_location(gv_package || lv_procedure_name, 150);

      ln_step := 20;
      end loop;
   --
   -- If For this Element ONLY Retro Entries Exist
   -- OR It is Retro + Base Case

   IF p_retro_base = 'N' THEN

       /* Code added for doing balance call for YTD
          This is a Case where Element DOES NOT have Base Entry
	  BUT ONLY Retro Entries */

      if pay_emp_action_arch.gv_multi_leg_rule is null then
         pay_emp_action_arch.gv_multi_leg_rule
               := pay_emp_action_arch.get_multi_legislative_rule(
                                                  p_legislation_code);
      end if;

      pay_balance_pkg.set_context('JURISDICTION_CODE', NULL);

	 if gv_reporting_level = 'TAXGRP' then
            gv_ytd_balance_dimension := gv_dim_asg_tg_ytd;
         else
            gv_ytd_balance_dimension := gv_dim_asg_gre_ytd;
         end if;


      ln_ytd_defined_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                             p_primary_balance_id,
                                             gv_ytd_balance_dimension,
                                             p_legislation_code);

      hr_utility.trace('ln_ytd_defined_balance_id = ' ||
                          ln_ytd_defined_balance_id);

         if ln_ytd_defined_balance_id is not null then
            ln_ytd_amount := nvl(pay_balance_pkg.get_value(
                                      ln_ytd_defined_balance_id,
                                      p_ytd_balcall_aaid),0);
         end if;
     if p_hours_balance_id is not null then
         hr_utility.set_location(gv_package || lv_procedure_name, 20);
         ln_ytd_hours_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                            p_hours_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);

           hr_utility.trace('ln_ytd_hours_balance_id = ' ||
                             ln_ytd_hours_balance_id);

            if ln_ytd_hours_balance_id is not null then
               ln_ytd_hours := nvl(pay_balance_pkg.get_value(
                                      ln_ytd_hours_balance_id,
                                      p_ytd_balcall_aaid),0);
               hr_utility.set_location(gv_package || lv_procedure_name, 60);
            end if;
      end if;

      pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
          := fnd_number.number_to_canonical(nvl(ln_ytd_amount,0));
      hr_utility.trace('ln_ytd_amount' || ln_ytd_amount);

      if pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
         = 'AC EARNINGS' then

        pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
	  := fnd_number.number_to_canonical(ln_ytd_hours);
        hr_utility.trace('ln_ytd_hours' || ln_ytd_hours);

      end if;
       -- End Addition
    ELSE
       -- Global Variable Setting Needed Here
       -- That Can be Subtracted during Base Population
       --
	pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
	   := fnd_number.number_to_canonical(nvl(ln_ytd_amount,0));
	hr_utility.trace('ln_ytd_amount' || ln_ytd_amount);
	gv_ytd_amount := ln_ytd_amount ;

	pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
	   := fnd_number.number_to_canonical(ln_ytd_hours);
	gv_ytd_hour := ln_ytd_hours ;

	hr_utility.trace('ln_ytd_hours' || ln_ytd_hours);

    END IF; -- p_retro_base 'Y'

   EXCEPTION
    when others then
    hr_utility.trace(' Error In archive_retro_elements procedure');
    hr_utility.trace('error occured at step ' || ln_step );

 END  Archive_retro_element;

  Procedure Archive_addnl_elements  (p_application_column_name     in varchar2
                                    ,p_xfr_action_id               in  number
                                    ,p_assignment_id               in number
                                    ,p_pymt_assignment_action_id   in number
                                    ,p_pymt_eff_date               in date
                                    ,p_element_type_id             in number
                                    ,p_primary_balance_id          in number
                                    ,p_hours_balance_id            in number
                                    ,p_processing_priority         in number
                                    ,p_element_classification_name in varchar2
                                    ,p_reporting_name              in varchar2
                                    ,p_tax_unit_id                 in number
                                    ,p_ytd_balcall_aaid            in number
                                    ,p_pymt_balcall_aaid           in number
                                    ,p_legislation_code            in varchar2
                                    ,p_sepchk_flag                 in varchar2
                                    ,p_sepchk_run_type_id          in number
                                    ,p_action_type                 in varchar2
                                    ,p_run_assignment_action_id    in number
                                    ,p_multiple                    in number
                                    ,p_rate                        in number
                                    )
 IS
 CURSOR archive_non_retro_elements ( cp_original_date_paid in varchar2,
                                    cp_element_entry_id in number,
                                    cp_run_assignment_action_id in number ) IS

          select fnd_date.date_to_canonical(ptp.start_date),
                 fnd_date.date_to_canonical(ptp.end_date),
                hr_general.decode_lookup
                            (DECODE (UPPER (ec.classification_name),
                                     'EARNINGS', 'US_EARNINGS',
                                     'SUPPLEMENTAL EARNINGS', 'US_SUPPLEMENTAL_EARNINGS',
                                     'IMPUTED EARNINGS', 'US_IMPUTED_EARNINGS',
                                     'NON-PAYROLL PAYMENTS', 'US_PAYMENT',
                                     'ALIEN/EXPAT EARNINGS', 'PER_US_INCOME_TYPES',
                                     NULL
                                    ),
                             et.element_information1
                            ) CATEGORY
from pay_assignment_actions paa,
     pay_payroll_actions ppa,
     per_time_periods ptp,
     pay_element_entries_f peef,
     pay_element_classifications ec,
     pay_element_types et
where paa.assignment_action_id = cp_run_assignment_action_id
and   paa.payroll_action_id   = ppa.payroll_action_id
and   ptp.payroll_id = ppa.payroll_id
and   nvl(cp_original_date_paid,ptp.start_date) between  ptp.start_date AND ptp.end_date
and   peef.element_entry_id = cp_element_entry_id
and   et.element_type_id = peef.element_type_id
and   et.classification_id = ec.classification_id;

  Cursor get_element_entry_id( cp_run_action_id in number ,
                              cp_assignment_id in number ,
                              cp_element_type_id in number ) IS
           select peef.element_entry_id,
                  peef.creator_type,
                  peef.source_start_date
 FROM pay_element_entries_f peef,
                pay_assignment_actions paa,
                pay_payroll_actions ppa,
                per_time_periods ptp
                WHERE paa.assignment_action_id = cp_run_action_id
            AND ppa.payroll_action_id = paa.payroll_action_id
            AND ptp.payroll_id = ppa.payroll_id
            AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date
            AND peef.assignment_id = cp_assignment_id
            AND peef.element_type_id = cp_element_type_id

            /* Commenting as Ele Entry Eff Start / End Date may not match the following
            AND peef.effective_start_date BETWEEN ptp.start_date AND ptp.end_date
            AND peef.effective_end_date BETWEEN ptp.start_date AND ptp.end_date
            End of Comment */

            AND NVL(ppa.date_earned, ppa.effective_date) BETWEEN peef.effective_start_date AND peef.effective_end_date

            --ORDER BY 3;
            ORDER BY nvl(peef.attribute_category,'Z'), peef.element_entry_id ;

--bug 7373188
--CURSOR get_run_results ( cp_element_entry_id in number ) IS
CURSOR get_run_results ( cp_run_action_id in number ,cp_element_entry_id in number ) IS
--bug 7373188
SELECT   to_number(prrv.result_value), pivf.NAME
    FROM pay_run_results prr,
         pay_run_result_values prrv,
         pay_input_values_f pivf
   WHERE prr.element_entry_id = cp_element_entry_id
--bug 7373188
     and prr.assignment_action_id = cp_run_action_id
--bug 7373188
     AND prrv.run_result_id = prr.run_result_id
     AND prrv.input_value_id = pivf.input_value_id
     AND pivf.NAME IN ('Pay Value', 'Hours')
ORDER BY 2 ;
-- Introducing This Cussor in case Hours and Pay Values Both zero
--
--bug 7373188
--CURSOR get_run_results_rate( cp_element_entry_id in number ) IS
CURSOR get_run_results_rate( cp_run_action_id in number , cp_element_entry_id in number ) IS
--bug 7373188
SELECT   to_number(prrv.result_value)
    FROM pay_run_results prr,
         pay_run_result_values prrv,
         pay_input_values_f pivf
   WHERE prr.element_entry_id = cp_element_entry_id
--bug 7373188
        and prr.assignment_action_id = cp_run_action_id
--bug 7373188
     AND prrv.run_result_id = prr.run_result_id
     AND prrv.input_value_id = pivf.input_value_id
     AND pivf.NAME IN ('Rate');

-- Added For Work At Home Condition

    CURSOR c_cur_get_wrkathome(cp_assignment_id IN NUMBER) IS
      SELECT NVL(paf.work_at_home, 'N')
            ,ppf.person_id
            ,ppf.business_group_id
      FROM per_assignments_f paf
          ,per_all_people_f ppf
      WHERE paf.assignment_id = cp_assignment_id
      AND   paf.person_id = ppf.person_id;

    CURSOR c_cur_home_state_jd(cp_person_id IN NUMBER
                              ,cp_bg_id     IN NUMBER) IS
      SELECT pus.state_code || '-000-0000'
      FROM per_addresses pa
          ,pay_us_states pus
      WHERE pa.person_id = cp_person_id
      AND   pa.primary_flag = 'Y'
      AND   p_pymt_eff_date between pa.date_from AND NVL(pa.date_to, hr_general.END_OF_TIME)
      AND   pa.business_group_id = cp_bg_id
      AND   pa.region_2 = pus.state_abbrev
      AND   pa.style = p_legislation_code;

 lv_original_date_earned         varchar2(100);
 lv_effective_start_date         varchar2(100);
 lv_effective_end_date           varchar2(100);
 lv_category                     varchar2(100);
 lv_el_jurisdiction_code         varchar2(100);
 ln_final_rate                   number;
 ln_element_entry_id             number;
 lv_creator_type                 varchar2(100);
 lv_jurisdiction_flag            varchar2(20);
 ln_element_index                number;
 ln_multiple                     number;
 ln_rate                         number(10,2);
 ln_current_hours           NUMBER(15,5);
 ln_payments_amount         NUMBER(15,5);
 ln_ytd_hours               NUMBER(15,5) := 0;
 ln_ytd_amount              NUMBER(17,5) := 0;

 ln_pymt_defined_balance_id NUMBER;
 ln_pymt_hours_balance_id   NUMBER;
 ln_ytd_defined_balance_id  NUMBER;
 ln_ytd_hours_balance_id    NUMBER;

 lv_rate_exists             VARCHAR2(1) := 'N';
 ln_nonpayroll_balcall_aaid NUMBER;

 ln_index                   NUMBER ;
 lv_procedure_name          VARCHAR2(100):= '.Archive_addnl_elements';
 lv_error_message           VARCHAR2(200);

 ln_step                    NUMBER;
 ln_final_ytd_value         NUMBER(15,5);
 ld_source_start_date       DATE;
 lv_action_category         varchar2(100);
 lv_pay_value_name          varchar2(100);
 ln_pay_value               number (15,5);
 ln_hours                   number(15,5) ;
 ln_amount                  number(15,5);
 ld_original_date_paid      date;
 count_j                    number := null;
 result                     number := 0;
 lv_sqlstr                  varchar2(500);
 lv_check_date              varchar2(100);
 ld_check_date              date;
 lv_sqlstr1                 varchar2(2500);
 lv_temp_AAA                varchar2(100) :='BBB';
 lv_sqlstr2                 varchar2(2500);
 lv_sqlstr3                 varchar2(2500);
 lv_sqlstr4                 varchar2(2500);
 lv_sqlstr_final            varchar2(2500);

-- Added For Work At Home Condition
 lv_wrk_at_home                 per_assignments_f.work_at_home%TYPE;
 ln_person_id                   per_people_f.person_id%TYPE;
 ln_bg_id                       per_people_f.business_group_id%TYPE;

BEGIN

 hr_utility.trace('Entering in package Archive_addnl_elements');
 hr_utility.trace('Run_assifnment_action_id = ' || p_run_assignment_action_id) ;
 hr_utility.trace('Element Type Id in Non retro Archiver ' || p_element_type_id);
 OPEN get_element_entry_id ( p_run_assignment_action_id,
                             p_assignment_id,
                             p_element_type_id);
 ln_step := 50;

       ln_ytd_hours := 0;
       ln_amount := 0;

       lv_sqlstr1 := 'select max(nvl(peef.' || p_application_column_name ||', ptp.start_date)) FROM pay_element_entries_f peef, pay_assignment_actions paa, pay_payroll_actions ppa,per_time_periods ptp WHERE paa.assignment_action_id =' ;
       lv_sqlstr2 := p_run_assignment_action_id ;
       lv_sqlstr3 :='AND ppa.payroll_action_id = paa.payroll_action_id AND ptp.payroll_id = ppa.payroll_id AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date AND peef.assignment_id =' || p_assignment_id ||'AND peef.element_type_id =' ;
       lv_sqlstr4 := p_element_type_id ||' AND NVL(ppa.date_earned, ppa.effective_date) BETWEEN peef.effective_start_date AND peef.effective_end_date AND peef.' || p_application_column_name || ' is not null '  ;
       lv_sqlstr_final := lv_sqlstr1 || lv_sqlstr2 || lv_sqlstr3 || lv_sqlstr4 ;

       execute immediate lv_sqlstr_final into  lv_check_date ;
 ln_step :=51;
 hr_utility.trace('lv_check_date  == ' || lv_check_date);
 LOOP

       FETCH get_element_entry_id INTO ln_element_entry_id,
                                       lv_creator_type,
                                       ld_source_start_date;
     ln_step :=52;
       IF  get_element_entry_id%NOTFOUND THEN
           close get_element_entry_id;
           ln_step :=53;
           EXIT;
       END IF;
                    ln_step :=53;
                    lv_sqlstr := 'select  nvl(' || p_application_column_name ||
                               ',''AAA'') from pay_element_entries_f where element_entry_id = ' || ln_element_entry_id;
            execute immediate lv_sqlstr
            into  lv_original_date_earned ;

             IF  lv_original_date_earned = 'AAA' THEN
                 lv_original_date_earned := fnd_date.date_to_canonical( p_pymt_eff_date);
                 lv_temp_AAA:= 'AAA' ;
             END IF;
            lv_original_date_earned := nvl(lv_original_date_earned ,p_pymt_eff_date);


            hr_utility.trace('lv_original_date_earned in step 53 is' || lv_original_date_earned) ;

           ld_original_date_paid := fnd_date.canonical_to_date(lv_original_date_earned);

       ln_step :=54;
       ln_hours := 0;
       ln_amount := 0;
--bug 7373188
--       OPEN get_run_results ( ln_element_entry_id );
       OPEN get_run_results ( p_run_assignment_action_id,ln_element_entry_id );
--bug 7373188
       LOOP
       ln_step := 49;
       FETCH get_run_results INTO ln_pay_value ,
                                  lv_pay_value_name;
       IF get_run_results%FOUND THEN
          IF lv_pay_value_name = 'Hours' THEN
             ln_hours := ln_hours + ln_pay_value;
             hr_utility.trace('ln_ytd_hours  is '|| ln_ytd_hours );
          END IF ;

          IF lv_pay_value_name = 'Pay Value' THEN
             ln_amount := ln_amount + ln_pay_value ;
             hr_utility.trace('ln_ytd_amount  is '|| ln_ytd_amount );
          END IF;
       ELSE
            EXIT;
       END IF;
       END LOOP;

       ln_step := 48;
       IF get_run_results%ISOPEN then
       CLOSE get_run_results ;
       END IF;

       IF ln_hours = 0 THEN
          IF ln_amount = 0 THEN
--bug 7373188
--             OPEN get_run_results_rate(ln_element_entry_id);
             OPEN get_run_results_rate(p_run_assignment_action_id,ln_element_entry_id);
--bug 7373188
             FETCH get_run_results_rate INTO ln_rate;
             CLOSE get_run_results_rate;
          ELSE
             ln_rate := NULL;
          END IF;
       ELSE
           ln_rate := ln_amount/ln_hours;
       END IF;

       hr_utility.trace('ld_original_date_paid := '||ld_original_date_paid);
       hr_utility.trace('ln_element_entry_id := '||ln_element_entry_id);
       hr_utility.trace('p_run_assignment_action_id := '||p_run_assignment_action_id);

       OPEN archive_non_retro_elements ( ld_original_date_paid,
                                         ln_element_entry_id ,
                                     p_run_assignment_action_id );
       FETCH archive_non_retro_elements INTO lv_effective_start_date
                                         ,lv_effective_end_date
                                         ,lv_category;
       CLOSE archive_non_retro_elements ;
       hr_utility.trace('lv_effective_start_date := '||lv_effective_start_date);
       hr_utility.trace('lv_effective_end_date := '||lv_effective_end_date);
       hr_utility.trace('lv_category := '||lv_category);

       -- Added For Work At Home Condition
       OPEN c_cur_get_wrkathome(p_assignment_id);
       FETCH c_cur_get_wrkathome INTO lv_wrk_at_home
                                     ,ln_person_id
                                     ,ln_bg_id;
       CLOSE c_cur_get_wrkathome;
       IF lv_wrk_at_home = 'Y' THEN
               OPEN c_cur_home_state_jd(ln_person_id
                                  ,ln_bg_id);
               FETCH c_cur_home_state_jd INTO lv_jurisdiction_flag;
               CLOSE c_cur_home_state_jd;
       ELSE

          SELECT nvl((select peevf.screen_entry_value  jurisdiction_code
                    from pay_input_values_f pivf,
                         pay_element_entry_values_f peevf
                    where pivf.element_type_id = p_element_type_id
                    AND pivf.NAME = 'Jurisdiction'
                    AND peevf.element_entry_id =  ln_element_entry_id
                    AND pivf.input_value_id = peevf.input_value_id),(SELECT   distinct pus.state_code
               || '-'
               || puc.county_code
               || '-'
               || punc.city_code jurisdiction_code
               FROM per_all_assignments_f peaf,
               hr_locations_all hla,
               pay_us_states pus,
               pay_us_counties puc,
               pay_us_city_names punc,
               pay_assignment_actions paa,
               pay_payroll_actions ppa
         WHERE peaf.assignment_id = p_assignment_id
           AND paa.assignment_action_id = p_run_assignment_action_id
           AND peaf.location_id = hla.location_id
           AND hla.region_2 = pus.state_abbrev
           AND pus.state_code = puc.state_code
           AND hla.region_1 = puc.county_name
           AND hla.town_or_city = punc.city_name
           AND pus.state_code = punc.state_code
           AND puc.county_code = punc.county_code
           AND ppa.payroll_action_id = paa.payroll_action_id
           AND ppa.effective_date between peaf.effective_start_date and peaf.effective_end_date
           ))
           into lv_jurisdiction_flag
           from dual;
      END IF; -- Work at Home 'N'

           hr_utility.trace('lv_jurisdiction_flag := '||lv_jurisdiction_flag);
           lv_action_category := 'AC EARNINGS';
           ln_step := 15;
           ln_index := pay_ac_action_arch.lrr_act_tab.count;

              pay_ac_action_arch.lrr_act_tab(ln_index).act_info11
                     := fnd_number.number_to_canonical(ln_hours);
              hr_utility.trace('pay_ac_action_arch.lrr_act_tab(ln_index).act_info11' || pay_ac_action_arch.lrr_act_tab(ln_index).act_info11 );/*Bug 3311866*/
             hr_utility.set_location(gv_package || lv_procedure_name, 130);
            /* Insert this into the plsql table if Current or YTD
               amount is not Zero */
              ln_step :=21;
             pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
                    := lv_action_category;
              ln_step :=22;
             pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
                   :=  '00-000-0000' ;
              ln_step :=23;
             pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
                   := p_xfr_action_id;
              ln_step :=24;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
                   := p_element_classification_name;
              ln_step :=25;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info2
                   := p_element_type_id;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
                   := p_primary_balance_id;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
                   := p_processing_priority;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
                   := fnd_number.number_to_canonical(nvl(ln_amount,0));
                   pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
                           := fnd_number.number_to_canonical(0);

   hr_utility.trace('ln_amount := '||fnd_number.number_to_canonical(nvl(ln_amount,0)));
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
                   := p_reporting_name;

         IF lv_temp_AAA <> 'AAA' THEN
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info17
                   := lv_original_date_earned;
                   hr_utility.trace('lv_original_date_earned :=' || lv_original_date_earned );

               IF lv_check_date = nvl(lv_original_date_earned,p_pymt_eff_date) THEN
                  count_j := ln_index;
               END IF;
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info18
                   := lv_effective_start_date;
                   hr_utility.trace('lv_effective_start_date := ' || lv_effective_start_date );
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info19
                   := lv_effective_end_date ;
                  hr_utility.trace('lv_effective_end_date:= ' || lv_effective_end_date );
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info20
                   := lv_category;
                   hr_utility.trace('lv_category ' || lv_category );
             pay_ac_action_arch.lrr_act_tab(ln_index).act_info21
                   := lv_jurisdiction_flag;
         END IF;

              pay_ac_action_arch.lrr_act_tab(ln_index).act_info22
                   := ln_rate;
             /*
             IF pay_ac_action_arch.lrr_act_tab(ln_index).act_info22 IS NULL THEN
                pay_ac_action_arch.lrr_act_tab(ln_index).act_info22 := 'N/A';
             END IF;
             */

      hr_utility.set_location(gv_package || lv_procedure_name, 150);
      ln_step := 20;
      lv_temp_AAA := 'BBB' ;
       end loop;

       /* Code added for doing balance call for YTD */
                if pay_emp_action_arch.gv_multi_leg_rule is null then
         pay_emp_action_arch.gv_multi_leg_rule
               := pay_emp_action_arch.get_multi_legislative_rule(
                                                  p_legislation_code);
      end if;

      pay_balance_pkg.set_context('JURISDICTION_CODE', null);
         if gv_reporting_level = 'TAXGRP' then
            gv_ytd_balance_dimension := gv_dim_asg_tg_ytd;
         else
            gv_ytd_balance_dimension := gv_dim_asg_gre_ytd;
         end if;

            /*********************************************************
      ** Get the defined balance_id for YTD call as it will be
      ** same for all classification types.
      *********************************************************/
      ln_ytd_defined_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                             p_primary_balance_id,
                                             gv_ytd_balance_dimension,
                                             p_legislation_code);

      hr_utility.trace('ln_ytd_defined_balance_id = ' ||
                          ln_ytd_defined_balance_id);

      ln_step := 4;
      if p_hours_balance_id is not null then
         hr_utility.set_location(gv_package || lv_procedure_name, 20);
         ln_ytd_hours_balance_id
                := pay_emp_action_arch.get_defined_balance_id(
                                            p_hours_balance_id,
                                            gv_ytd_balance_dimension,
                                            p_legislation_code);

           hr_utility.trace('ln_ytd_hours_balance_id = ' ||
                             ln_ytd_hours_balance_id);

      end if;

      ln_step := 5;
      hr_utility.set_location(gv_package || lv_procedure_name, 40);
         if ln_ytd_defined_balance_id is not null then
            ln_ytd_amount := nvl(pay_balance_pkg.get_value(
                                      ln_ytd_defined_balance_id,
                                      p_ytd_balcall_aaid),0);
         end if;

         if p_hours_balance_id is not null then
            hr_utility.set_location(gv_package || lv_procedure_name, 50);
            if ln_ytd_hours_balance_id is not null then
               ln_ytd_hours := nvl(pay_balance_pkg.get_value(
                                      ln_ytd_hours_balance_id,
                                      p_ytd_balcall_aaid),0);
               hr_utility.set_location(gv_package || lv_procedure_name, 60);
            end if;
         end if; --Hours

         ln_step := 8;
         if p_pymt_balcall_aaid is not null then
            ln_step := 10;
            /* Added dimension _ASG_GRE_RUN for reversals and Balance
               Adjustments for Canada. Bug#3498653 */
            if p_action_type in ('B','V') then
               ln_pymt_defined_balance_id
                    := pay_emp_action_arch.get_defined_balance_id(
                                                 p_primary_balance_id,
                                                 '_ASG_GRE_RUN',
                                                 p_legislation_code);
            else
               if pay_emp_action_arch.gv_multi_leg_rule = 'Y' then
                  ln_pymt_defined_balance_id
                     := pay_emp_action_arch.get_defined_balance_id(
                                                 p_primary_balance_id,
                                                 '_ASG_PAYMENTS',
                                                 p_legislation_code);
               else
                  ln_pymt_defined_balance_id
                     := pay_emp_action_arch.get_defined_balance_id(
                                                 p_primary_balance_id,
                                                 '_PAYMENTS',
                                                 p_legislation_code);
               end if;
            end if; -- p_action_type in ('B','V')
            /* end of addition for Reversals and bal adjustments */
            hr_utility.trace('ln_pymt_defined_balance_id ' ||
                              ln_pymt_defined_balance_id);

            if ln_pymt_defined_balance_id is not null then
               ln_payments_amount := nvl(pay_balance_pkg.get_value(
                                               ln_pymt_defined_balance_id,
                                               p_pymt_balcall_aaid),0);
               hr_utility.trace('ln_payments_amount = ' ||ln_payments_amount);
            end if;

            if p_hours_balance_id is not null then
               /* Added dimension _ASG_GRE_RUN for reversals and Balance
                  Adjustments for Canada. Bug#3498653 */
               if p_action_type in ('B','V') then
                  ln_pymt_hours_balance_id
                        := pay_emp_action_arch.get_defined_balance_id(
                                                   p_hours_balance_id
                                                   ,'_ASG_GRE_RUN'
                                                   ,p_legislation_code);
               else
                  if pay_emp_action_arch.gv_multi_leg_rule = 'Y' then
                     ln_pymt_hours_balance_id
                        := pay_emp_action_arch.get_defined_balance_id(
                                                   p_hours_balance_id
                                                   ,'_ASG_PAYMENTS'
                                                   ,p_legislation_code);
                  else
                     ln_pymt_hours_balance_id
                        := pay_emp_action_arch.get_defined_balance_id(
                                                   p_hours_balance_id
                                                   ,'_PAYMENTS'
                                                   ,p_legislation_code);
                  end if;
               end if; -- p_action_type in ('B','V')
               /* end of addition for reversals and bal adjustments */
               hr_utility.trace('ln_pymt_hours_balance_id ' ||
                                 ln_pymt_hours_balance_id);

                    hr_utility.set_location(gv_package || lv_procedure_name, 120);
            end if; --Hours
         end if; -- p_pymt_balcall_aaid is not null

         ln_step := 15;

	 pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
	   := fnd_number.number_to_canonical(ln_ytd_amount);
	   hr_utility.trace('ln_ytd_amount' || nvl(ln_ytd_amount,0));

	 pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
		 := fnd_number.number_to_canonical(ln_ytd_hours);
	    hr_utility.trace('ln_ytd_hours' || ln_ytd_hours);

         /* Following later to be re-valuated IF worth doing wrt Cost

	    IF count_j is null THEN
		   pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
		   := fnd_number.number_to_canonical(nvl(ln_ytd_amount,0));
		  hr_utility.trace('ln_ytd_amount' || ln_ytd_amount);
		    pay_ac_action_arch.lrr_act_tab(ln_index).act_info12
		    := fnd_number.number_to_canonical(ln_ytd_hours);
		  hr_utility.trace('ln_ytd_hours' || ln_ytd_hours);
	   END IF;
	 */

   EXCEPTION
    when others then
    hr_utility.trace(' Error In archive_addnl_elements procedure');
    hr_utility.trace('error occured at step ' || ln_step );

 END  Archive_addnl_elements;

END pay_ac_action_arch;

/
