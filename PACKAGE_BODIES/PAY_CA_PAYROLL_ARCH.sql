--------------------------------------------------------
--  DDL for Package Body PAY_CA_PAYROLL_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_PAYROLL_ARCH" AS
/* $Header: pycapyar.pkb 120.5.12010000.1 2008/07/27 22:15:21 appldev ship $ */
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

    Name        : pay_ca_payroll_arch

    Description : Generate

    Uses        :

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    15-Aug-2001 vpandya    115.0            Created.
                                            Currently the balances are
                                            first written to a local pl/sql
                                            table and then the api is called to
                                            write to pay_act_info.
                                            Later procedures could be written
                                            to make this part more readable.

                                            One balance adjustment results in
                                            nearly 10 payroll_actions and 10
                                            assignment action currently.

                                            Run Resullts maybe written for
                                            only some of these assignment
                                            actions. Currently the prog
                                            loops for all 10 actions.
                                            This can later be reduced.
    02-Oct-2001 vpandya    115.1            Replace 'S' with 'STANDARD' in
                                            c_asg_run_actions cursor.
    05-Oct-2001 vpandya    115.2            Changed 'order by' clause in
                                            c_asg_run_actions cursor.
    25-Oct-2001 vpandya    115.3            Bug# 2077373, print 'Quebec Tax'
                                            instead of 'PROV Withheld(QC)'.
                                            changed populate_tax_balance,
                                            printing lv_soe_short_name now
                                            instead of lv_reporting_name.
    30-Oct-2001 vpandya    115.4            Bug# 2085775, ln_prev_standard_aaid
                                            was not getting initialize in
                                            asg. act. creation. Now it has been
                                            initialized in declare section and
                                            after 'end loop' with zero'0'.
    22-Jan-2002 vpandya    115.5            Changed package to take care of
                                            Multi Assignment Processing.
                                            action_creation and archive_data
                                            procedures have been modified.
                                            process_actions has been introduced.
                                            Added dbdrv lines to meet new std.
    24-Jan-2002 vpandya    115.6            Get rid of procedures
                                            populate_summary, get_emp_residence
                                            , insret_rows_thro_api_process,
                                            get_multi_assignment_flag,
                                            get_withholding_info and
                                            update_ytd_withheld
                                            Modified py_archive_date and
                                            py_action_creation. Calling
                                            get_multi_assignment_flag of
                                            pay_ac_action_arch and
                                            arch_pay_action_level_data of
                                            pay_emp_action_arch.
    19-FEB-2002 vpandya    115.7            Changed global variable name for
                                            Multiple Assignment Payments.
    12-Jun-2002 vpandya    115.8            Added
                                            - procedure populate_fed_prov_bal
                                            - get_context_value
                                            Modified py_archinit, populating
                                            PL/SQL table for defined balance id
                                            for Tax Balances.
                                            Modified py_archive_data,
                                            added cursor cur_taxgrp to get
                                            Tax Group Id and cursor cur_language
                                            to get correspondance language of
                                            person.
    12-Jun-2002 vpandya    115.9            Modified populate_fed_prov_bal
                                            archive jurisdiction_code as
                                            '00-000-0000'
    13-Jun-2002 vpandya    115.10           Modified get_context_value return
                                            '-1' when 'No Tax Group' found.
    24-Jun-2002 vpandya    115.11           Modified py_archinit to populate
                                            PL/SQL table for all jurisdiction.
                                            Also modified populate_fed_prov_bal
                                            to archive taxes for all juris. Now
                                            storing tax group id in the variable
                                            gn_taxgrp_gre_id(static variable).
    23-Jul-2002 vpandya    115.12  2476693  Setting context Tax Unit Id
                                            for Non-Payroll Payment element.
    20-NOV-2002 vpandya    115.14           Calling set_error_message function
                                            of pay_emp_action_arch from all
                                            exceptions to get error message
                                            Remote Procedure Calls(RPC or Sub
                                            program). Added exceptions in
                                            all procedures and functions.
    06-FEB-2003 vpandya    115.15  2657464  Changed for translation.
                                   2705741  Getting base_language. If person's
                                   2683634  correspondence language is not
                                            US or FRC, or it is null then
                                            setting base language as default.
    10-FEB-2003 vpandya    115.16           Added two input paramters to
                                            get_xfr_elements.
    18-FEB-2003 vpandya    115.17           Added nocopy for gscc.
    24-FEB-2003 vpandya    115.18           Added procedure
                                            create_chld_act_for_multi_gre for
                                            assignment action creation for
                                            multi gre.
    07-Mar-2003 vpandya    115.19           Changed procedure
                                            create_chld_act_for_multi_gre, added
                                            condition exit from the loop if
                                            c_mst_prepay_act%notfound.
    12-Mar-2003 vpandya    115.20           Changed proc create_child_actions
                                            and create_chld_act_for_multi_gre:
                                            added pay_org_payment_methods_f
                                            to avoid to get pay_pre_payments of
                                            'Third Party Payments'
    02-Apr-2003 vpandya    115.21  2879620  Changed process_action:
                                            Modified cursor c_time_period.
    11-Apr-2003 vpandya    115.22           Changed archive_data:
                                            create_child_actions_for_gre and
                                            create_child_act_for_taxgrp.
                                            Using view pay_payment_information_v
                                            to archive assignments whether
                                            it has zero and non zero payment.If
                                            zero payment, then atleast earning
                                            element has been processed.
    28-Jul-2003 vpandya    115.23  3053917  Passing parameter
                                            p_ytd_balcall_aaid to
                                            get_personal_information.
    10-Sep-2003 vpandya    115.24           Passing p_seperate_check_flag to
                                            get_last_xfr_info as per teminated
                                            asg changes done by ekim.
    18-Sep-2003 vpandya    115.25           Changed range cursor to fix gscc
                                            error on date conversion. Using
                                            fnd_date.date_to_canonical instead
                                            to_char and canonical_to_date
                                            instead of to_date.
    19-Jan-2004 vpandya    115.26  3356401  The SQL ID:  6194306 is for the
                                            cursor c_prev_run_information, which
                                            was in get_last_xfr_info procedure.
                                            This procedure has been removed from
                                            this package and same procedure of
                                            pay_ac_action_arch is being called.
    17-Apr-2004 rsethupa   115.27  3311866  SS Payslip Currency Format Enhancement
                                            Current Amount and Ytd Amount for
					    category 'AC DEDUCTIONS' will be
					    archived in canonical format.
    26-Apr-2004 rsethupa   115.28  3559626  In procedure process_actions,
                                            assigned lv_person_lang to variable
					    pay_emp_action_arch.gv_correspondence_language
					    also.(For fetching Accrual Information
					    in the corresponding language)
    02-Aug-2004 SSattini   115.29  3498653  Added functionality to archive
                                            Balance adjustments and Reversals
                                            for Canada legislation.
    18-Oct-2004 SSattini   115.30  3940380  Added p_xfr_action_id parameter
                                            to get_last_xfr_info procedure call
                                            from process actions, part of fix
                                            for bug#3940380.
    26-Oct-2004 SSattini   115.31  3960157  Bugfix 3960157
    02-Sep-2005 Saurgupt   115.33  4566656  Modified proc populate_fed_prov_bal.
                                            Added 'PPIP EE Withheld' along with
                                            QPP balances. Modified cur_def_bal,
                                            added 'PPIP EE Withheld' in query.
    26-APR-2006 ahanda     115.34  4675938  Changed priority for tax elements.
    13-DEC-2006 meshah     115.36  5655448  changed action_creation, cursor
                                            c_get_xfr_emp added a INDEX hint
                                            and removed nvl for
                                            consolidation_set.
    18-JUL-2007 pganguly   115.37  6169715  Change the cursor cur_language,
                                            added the missing date join with
                                            per_people_f.

  *******************************************************************/

  /******************************************************************
  ** Package Local Variables
  ******************************************************************/
   gv_package    varchar2(100) := 'pay_ca_payroll_arch';
   gn_taxgrp_gre_id  NUMBER;
   dbt def_bal_tbl;
   tax tax_tbl;

  /******************************************************************
   Name      : get_context_val
   Purpose   : This returns the conext value of given assignment action id
               information for Canadian Payroll Archiver.
   Arguments : p_context_name      - Context Name
               p_assignment_id     - Assignment Id
               p_asg_act_id        - Assignment Action Id
  ******************************************************************/
  FUNCTION get_context_val( p_context_name in varchar2,
                            p_assignment_id in number,
                            p_asg_act_id in number)
  RETURN varchar2 is
  cursor cur_context is
  select context_value
  from   pay_action_contexts pac,
         ff_contexts fc
  where  pac.assignment_action_id = p_asg_act_id
  and    pac.assignment_id        = p_assignment_id
  and    pac.context_id           = fc.context_id
  and    fc.context_name          = p_context_name;

  lv_context_value varchar2(80);

  lv_error_message          VARCHAR2(500);
  lv_procedure_name         VARCHAR2(100);
  ln_step                   NUMBER;

  begin
    lv_context_value := '-1';
    ln_step := 1;
    lv_procedure_name := '.get_context_value';
    hr_utility.set_location(gv_package || lv_procedure_name, 10);

    open  cur_context;
    fetch cur_context into lv_context_value;
    close cur_context;

    hr_utility.set_location(gv_package || lv_procedure_name, 20);
    ln_step := 2;
    if lv_context_value = 'No Tax Group' then
       lv_context_value := '-1';
    end if;
    return(lv_context_value);

  EXCEPTION
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
      return(lv_context_value);

  end get_context_val;


  /******************************************************************
   Name      : get_taxgroup_val (Added new function to fix bug#3498653)
   Purpose   : This returns the tax group conext value for a given
               assignment_id, assignment action id.  If tax group
               context value is not found for the assignment then
               it gets the value from the GRE definition based on
               the tax_unit_id passed.
   Arguments : p_tax_unit_id      -  Tax Unit Id
               p_assignment_id     - Assignment Id
               p_asg_act_id        - Assignment Action Id
  ******************************************************************/
  FUNCTION get_taxgroup_val( p_tax_unit_id in number,
                            p_assignment_id in number,
                            p_asg_act_id in number)
  RETURN number is
  cursor cur_taxgrp is
      select org_information4
      from   hr_organization_information hoi
      where  hoi.org_information_context = 'Canada Employer Identification'
      and    hoi.organization_id = p_tax_unit_id;

  ln_taxgrp_gre_id number;

  Begin

     ln_taxgrp_gre_id := -1;
        ln_taxgrp_gre_id := get_context_val(
                              p_context_name  => 'TAX_GROUP'
                            , p_assignment_id => p_assignment_id
                            , p_asg_act_id    => p_asg_act_id);

        if ( ln_taxgrp_gre_id = -1 or ln_taxgrp_gre_id is null ) then
           open  cur_taxgrp;
           fetch cur_taxgrp into ln_taxgrp_gre_id;
           close cur_taxgrp;
        end if;

     return ln_taxgrp_gre_id;

  End get_taxgroup_val;


  /******************************************************************
   Name      : get_payroll_action_info
   Purpose   : This returns the Payroll Action level
               information for Canadian Payroll Archiver.
   Arguments : p_payroll_action_id - Payroll_Action_id of archiver
               p_start_date        - Start date of Archiver
               p_end_date          - End date of Archiver
               p_business_group_id - Business Group ID
               p_cons_set_id       - Consolidation Set when submitting Archiver
               p_payroll_id        - Payroll ID when submitting Archiver
  ******************************************************************/
   PROCEDURE get_payroll_action_info( p_payroll_action_id    in  number
                                     ,p_end_date             out nocopy date
                                     ,p_start_date           out nocopy date
                                     ,p_business_group_id    out nocopy number
                                     ,p_cons_set_id          out nocopy number
                                     ,p_payroll_id           out nocopy number
                                    )

   IS
      cursor c_payroll_action_info
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

    lv_error_message          VARCHAR2(500);
    lv_procedure_name         VARCHAR2(100);
    ln_step                   NUMBER;

  BEGIN

       ln_step := 1;
       lv_procedure_name := '.get_payroll_action_info';
       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       open c_payroll_action_info(p_payroll_action_id);
       fetch c_payroll_action_info into ld_end_date,
                                        ld_start_date,
                                        ln_business_group_id,
                                        ln_cons_set_id,
                                        ln_payroll_id;
       close c_payroll_action_info;

       ln_step := 2;
       hr_utility.set_location(gv_package || lv_procedure_name, 30);
       p_end_date          := ld_end_date;
       p_start_date        := ld_start_date;
       p_business_group_id := ln_business_group_id;
       p_cons_set_id       := ln_cons_set_id;
       p_payroll_id        := ln_payroll_id;
       hr_utility.set_location(gv_package || lv_procedure_name, 50);

  EXCEPTION
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

  END get_payroll_action_info;


  PROCEDURE populate_fed_prov_bal( p_xfr_action_id        in number
                                  ,p_assignment_id        in number
                                  ,p_pymt_balcall_aaid    in number
                                  ,p_tax_unit_id          in number
                                  ,p_action_type          in varchar2
                                  ,p_pymt_eff_date        in date
                                  ,p_start_date           in date
                                  ,p_end_date             in date
                                  ,p_ytd_balcall_aaid     in number
                                  )
  IS

  ln_pymt_amount    number;
  ln_ytd_amount     number;
  lv_reporting_name varchar2(150);
  lv_lookup_code    varchar2(150);

  i number;
  j number;

  ln_index number;
  ln_element_index number;

  lv_error_message          VARCHAR2(500);
  lv_procedure_name         VARCHAR2(100);
  ln_step                   NUMBER;

  BEGIN
    ln_step := 1;
    lv_procedure_name       := '.populate_fed_prov_bal';
    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    i := 0;
    j := 0;

    if pay_ac_action_arch.gv_reporting_level = 'TAXGRP' then
      pay_balance_pkg.set_context('TAX_GROUP', gn_taxgrp_gre_id);
    else
      pay_balance_pkg.set_context('TAX_UNIT_ID', gn_taxgrp_gre_id);
    end if;

    hr_utility.set_location(gv_package || lv_procedure_name, 20);
    ln_step := 2;
    for i in dbt.first..dbt.last loop

      ln_pymt_amount := 0;
      ln_ytd_amount  := 0;

      if dbt(i).bal_name in ('PROV Withheld', 'QPP EE Withheld' , 'PPIP EE Withheld') -- 4566656
      then
         ln_step := 3;
         pay_balance_pkg.set_context('JURISDICTION_CODE'
                                     ,dbt(i).jurisdiction_cd);
         lv_lookup_code := upper(dbt(i).bal_name|| '(' ||
                           dbt(i).jurisdiction_cd || ')');
      else
         ln_step := 4;
         lv_lookup_code := upper(dbt(i).bal_name);
      end if;

      /* Added this extra validation for reversals in Canada
         if action_type is 'V' then the run_def_bal_id should
         be used to get ln_pymt_amount, otherwise the pymt_def_bal_id
         should be used to get ln_pymt_amount. Bug#3498653 */
      if p_action_type in ('V','B') then
       if dbt(i).run_def_bal_id is not null then
         ln_step := 5;
         ln_pymt_amount := nvl(pay_balance_pkg.get_value(
                                    dbt(i).run_def_bal_id,
                                    p_pymt_balcall_aaid),0);
       end if;
      else
       /* old code before adding run_def_bal_id */
       if dbt(i).pymt_def_bal_id is not null then
         ln_step := 5;
         ln_pymt_amount := nvl(pay_balance_pkg.get_value(
                                    dbt(i).pymt_def_bal_id,
                                    p_pymt_balcall_aaid),0);
       end if;
      end if; -- p_action_type = 'V'

      if pay_ac_action_arch.gv_reporting_level = 'TAXGRP' then
         ln_step := 6;
         ln_ytd_amount := nvl(pay_balance_pkg.get_value(
                                  dbt(i).tg_ytd_def_bal_id,
                                  p_ytd_balcall_aaid),0);
      else
         ln_step := 7;
         ln_ytd_amount := nvl(pay_balance_pkg.get_value(
                                  dbt(i).gre_ytd_def_bal_id,
                                  p_ytd_balcall_aaid),0);
      end if;

      hr_utility.set_location(gv_package || lv_procedure_name, 30);
      ln_step := 8;
      if ( ln_pymt_amount + ln_ytd_amount <> 0 ) then


        hr_utility.trace('lv_lookup_code : '||lv_lookup_code);
        hr_utility.set_location(gv_package || lv_procedure_name, 40);

        ln_step := 9;
        j := 0;
        for j in tax.first..tax.last loop
            if tax(j).language = pay_ac_action_arch.gv_person_lang and
               tax(j).lookup_code = lv_lookup_code
            then
               lv_reporting_name := tax(j).meaning;
               exit;
            end if;
        end loop;

        /*Insert this into the plsql table */
        hr_utility.trace('Tax Balance Name : '|| dbt(i).bal_name );
        hr_utility.trace('lv_reporting_name : '||lv_reporting_name);
        hr_utility.set_location(gv_package || lv_procedure_name, 50);

        ln_step := 10;
        ln_index := pay_ac_action_arch.lrr_act_tab.count;

        hr_utility.trace('ln_index is '
           || pay_ac_action_arch.lrr_act_tab.count);

        pay_ac_action_arch.lrr_act_tab(ln_index).action_info_category
          := 'AC DEDUCTIONS';
        pay_ac_action_arch.lrr_act_tab(ln_index).jurisdiction_code
          := dbt(i).jurisdiction_cd;
--        pay_ac_action_arch.lrr_act_tab(ln_index).effective_date
--        := p_pymt_eff_date;
        --pay_ac_action_arch.lrr_act_tab(ln_index).act_info4
        --:= p_element_type_id;
        pay_ac_action_arch.lrr_act_tab(ln_index).action_context_id
          := p_xfr_action_id;
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info1
          := 'Tax Deductions';
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info6
        := dbt(i).bal_type_id;
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info7
          := dbt(i).disp_sequence;
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info8
          := fnd_number.number_to_canonical(ln_pymt_amount);  /*Bug 3311866*/
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info9
          := fnd_number.number_to_canonical(ln_ytd_amount);
        pay_ac_action_arch.lrr_act_tab(ln_index).act_info10
          := lv_reporting_name; --lv_reporting_name bug#2077373;

        hr_utility.set_location(gv_package || lv_procedure_name, 60);

         ln_step := 11;
         ln_element_index := pay_ac_action_arch.emp_elements_tab.count;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_classfn
                  := 'Tax Deductions';
         pay_ac_action_arch.emp_elements_tab(ln_element_index).jurisdiction_code
                  := dbt(i).jurisdiction_cd;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_reporting_name
                  := dbt(i).bal_name;
         pay_ac_action_arch.emp_elements_tab(ln_element_index).element_primary_balance_id
                  := dbt(i).bal_type_id;

        hr_utility.set_location(gv_package || lv_procedure_name, 70);


      end if;

    end loop;

    hr_utility.set_location(gv_package || lv_procedure_name, 80);

  EXCEPTION
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

  END populate_fed_prov_bal;

  --payslip

   PROCEDURE get_last_pymt_info(p_assignment_id in number
                               ,p_curr_pymt_eff_date in date
                               ,p_last_pymt_eff_date out nocopy date
                               ,p_last_pymt_ass_act_id out nocopy number
                                )


   IS

      cursor c_last_payment_info(cp_assignment_id     in number
                                ,cp_curr_pymt_eff_date in date) is

        select ppa.effective_date, paa.assignment_action_id
          from pay_payroll_actions ppa,
               pay_assignment_actions paa
         where paa.assignment_id = p_assignment_id
           and ppa.payroll_action_id = paa.payroll_action_id
           and ppa.action_type in ('U','P')
           and ppa.effective_date < p_curr_pymt_eff_date
           and ppa.effective_date in
            ( select max(ppa1.effective_date)
                from pay_payroll_actions ppa1,
                     pay_assignment_actions paa1
               where ppa1.payroll_action_id = paa1.payroll_action_id
                 and ppa1.action_type in ('U','P')
                 and paa1.assignment_id = p_assignment_id
                 and ppa1.effective_date < p_curr_pymt_eff_date);


           ld_last_pymt_eff_date            date;
           ln_last_pymt_ass_act_id          number;

           lv_error_message          VARCHAR2(500);
           lv_procedure_name         VARCHAR2(100);
           ln_step                   NUMBER;

   BEGIN

       hr_utility.trace('Entering get_last_pymt_info');
       lv_procedure_name := '.get_last_pymt_info';

       ln_step := 1;
       open c_last_payment_info(p_assignment_id,p_curr_pymt_eff_date);

       fetch c_last_payment_info INTO ld_last_pymt_eff_date,
                                      ln_last_pymt_ass_act_id ;

            if c_last_payment_info%NOTFOUND then

            hr_utility.trace('This process has not been run earlier');

            end if;
       close c_last_payment_info ;


      p_last_pymt_eff_date    := ld_last_pymt_eff_date;
      p_last_pymt_ass_act_id  := ln_last_pymt_ass_act_id;

      hr_utility.trace('Leaving get_last_pymt_info');

  EXCEPTION
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

   END get_last_pymt_info;


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
                            ,p_tax_unit_id           in number
                            ,p_curr_pymt_eff_date    in date
                            ,p_xfr_start_date        in date
                            ,p_xfr_end_date          in date
                            ,p_ppp_source_action_id  in number default null
                            ,p_archive_balance_info  in varchar2 default 'Y'  -- Bug 3960157
                            )
  IS

    /* Modified c_ytd_aaid because when we run the balance_adjustments
       with pre-payments to pickup balance adjustments 'B',
       in this case source_action_id will be null.  The balance adjustments
       should be archived when the pre-payments is ran or when pre-payments
       is not ran. Bug#3498653 */
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
          and not exists ( select 1
                           from   pay_run_types_f prt
                           where  prt.legislation_code = 'CA'
                           and    prt.run_type_id = nvl(paa.run_type_id,0)
                           and    prt.run_method  = 'C' )
          and ((paa.source_action_id is not null) OR
              (ppa.action_type = 'B' and paa.source_action_id is null))
          /* and paa.source_action_id is not null -- old code */
      order by paa.action_sequence desc;

    cursor c_ytd_aaid_for_gre(cp_prepayment_action_id in number
                             ,cp_assignment_id   in number
                             ,cp_tax_unit_id     in number
                             ,cp_sepchk_run_type in number) is
      select paa.assignment_action_id
        from pay_assignment_actions paa,
             pay_action_interlocks pai,
             pay_payroll_actions   ppa
        where pai.locking_action_id =  cp_prepayment_action_id
          and paa.assignment_action_id = pai.locked_action_id
          and paa.assignment_id = cp_assignment_id
          and paa.tax_unit_id   = cp_tax_unit_id
          and ppa.payroll_action_id = paa.payroll_action_id
          and nvl(paa.run_type_id,0) <> cp_sepchk_run_type
          and not exists ( select 1
                           from   pay_run_types_f prt
                           where  prt.legislation_code = 'CA'
                           and    prt.run_type_id = nvl(paa.run_type_id,0)
                           and    prt.run_method  = 'C' )
          and paa.source_action_id is not null
      order by paa.action_sequence desc;

    cursor c_time_period(cp_run_assignment_action in number) is
      select ptp.time_period_id,
             ppa.date_earned,
             ppa.effective_date
       from pay_assignment_actions paa,
            pay_payroll_actions ppa,
            per_time_periods ptp
      where paa.assignment_action_id = cp_run_assignment_action
        and ppa.payroll_action_id = paa.payroll_action_id
        and ptp.payroll_id = ppa.payroll_id
        and ppa.date_earned between ptp.start_date and ptp.end_date;

    cursor cur_language is
      select ppf.correspondence_language  person_language
      from   per_assignments_f    paf
           , per_people_f         ppf
      where  paf.assignment_id    = p_assignment_id
      and    p_curr_pymt_eff_date between paf.effective_start_date
                                      and paf.effective_end_date
      and    ppf.person_id        = paf.person_id
      and    p_curr_pymt_eff_date between ppf.effective_start_date
                                      and ppf.effective_end_date;

    cursor cur_taxgrp is
      select org_information4
      from   hr_organization_information hoi
      where  hoi.org_information_context = 'Canada Employer Identification'
      and    hoi.organization_id = p_tax_unit_id;

    cursor cur_get_base_lang is
      select language_code
      from   fnd_languages
      where  installed_flag = 'B';

    ln_ytd_balcall_aaid       NUMBER;
    ld_run_date_earned        DATE;
    ld_run_effective_date     DATE;

    ld_last_xfr_eff_date      DATE;
    ln_last_xfr_action_id     NUMBER;
    ld_last_pymt_eff_date     DATE;
    ln_last_pymt_action_id    NUMBER;

    ln_time_period_id         NUMBER;

    ln_taxgrp_gre_id          number;
    lv_person_lang            varchar2(30);

    lv_base_lang              varchar2(30);

    lv_error_message          VARCHAR2(500);
    lv_procedure_name         VARCHAR2(100);
    ln_step                   NUMBER;

  BEGIN
     lv_procedure_name := '.process_actions';
     lv_person_lang := 'US';
     ln_taxgrp_gre_id := -1;

     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;

     /****************************************************************
     ** For Seperate Check we do the YTD balance calls with the Run
     ** Action ID. So, we do not need to get the max. action which is
     ** not seperate Check.
     ** Also, p_ppp_source_action_id is set to null as we want to get
     ** all records from pay_pre_payments where source_action_id is
     ** is null.
     ****************************************************************/
     ln_ytd_balcall_aaid := p_payment_action_id;
     if p_action_type in ('U', 'P') then

       if p_seperate_check_flag = 'N' and p_archive_balance_info <> 'N' then

--          if pay_ac_action_arch.gv_reporting_level = 'GRE' then
--
--             hr_utility.set_location(gv_package || lv_procedure_name, 40);
--             ln_step := 2;
--             open c_ytd_aaid_for_gre(p_rqp_action_id,
--                                     p_assignment_id,
--                                     p_tax_unit_id,
--                                     p_sepcheck_run_type_id);
--             fetch c_ytd_aaid_for_gre into ln_ytd_balcall_aaid;
--             if c_ytd_aaid_for_gre%notfound then
--                hr_utility.set_location(gv_package || lv_procedure_name, 50);
--                hr_utility.raise_error;
--             end if;
--             close c_ytd_aaid_for_gre;
--
--          else

             hr_utility.set_location(gv_package || lv_procedure_name, 40);
             ln_step := 2;
             open c_ytd_aaid(p_rqp_action_id,
                             p_assignment_id,
                             p_sepcheck_run_type_id);
             fetch c_ytd_aaid into ln_ytd_balcall_aaid;
             --if c_ytd_aaid%notfound then
             --   hr_utility.set_location(gv_package || lv_procedure_name, 50);
             --   hr_utility.raise_error;
             --end if;
             close c_ytd_aaid;

--          end if;

       end if;

     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 60);

     ln_step := 3;
--       if p_seperate_check_flag = 'N' and p_archive_balance_info <> 'N' then
   open c_time_period(ln_ytd_balcall_aaid);
     fetch c_time_period into ln_time_period_id,
                              ld_run_date_earned,
                              ld_run_effective_date;
    close c_time_period;

     hr_utility.set_location(gv_package || lv_procedure_name, 70);
--   end if;
     open  cur_get_base_lang;
     fetch cur_get_base_lang into lv_base_lang;
     close cur_get_base_lang;

     ln_step := 4;
     open  cur_language;
     fetch cur_language into lv_person_lang;
     if cur_language%notfound then
        lv_person_lang := lv_base_lang;
     end if;
     close cur_language;

     if ( ( lv_person_lang not in ( 'US', 'FRC' ) ) or
          ( lv_person_lang is null ) ) then

        lv_person_lang := lv_base_lang;

     end if;

     pay_ac_action_arch.gv_person_lang := lv_person_lang;
     /* Bug 3559626 */
     pay_emp_action_arch.gv_correspondence_language := lv_person_lang;

     hr_utility.trace('Correspondance Lang: '|| pay_ac_action_arch.gv_person_lang);
     hr_utility.trace('ln_ytd_balcall_aaid: '|| ln_ytd_balcall_aaid);

--    if p_seperate_check_flag = 'N' and p_archive_balance_info <> 'N' then
     if pay_ac_action_arch.gv_reporting_level = 'TAXGRP' then
        ln_step := 5;
        /* removed old code to use the get_taxgroup_val function bug#3498653*/

        ln_taxgrp_gre_id := get_taxgroup_val(
                                  p_tax_unit_id => p_tax_unit_id,
                                  p_assignment_id => p_assignment_id,
                                  p_asg_act_id    => ln_ytd_balcall_aaid);
     else
        ln_taxgrp_gre_id := p_tax_unit_id;
     end if;

     gn_taxgrp_gre_id := ln_taxgrp_gre_id;

     hr_utility.trace('Reporting Level : '|| pay_ac_action_arch.gv_reporting_level);
     hr_utility.trace('gv_taxgrp_gre_id : '|| gn_taxgrp_gre_id);

     ln_step := 7;
     gv_jurisdiction_cd := get_context_val(
                           p_context_name  => 'JURISDICTION_CODE'
                         , p_assignment_id => p_assignment_id
                         , p_asg_act_id    => ln_ytd_balcall_aaid);

     hr_utility.trace('gv_jurisdiction_cd : ' || gv_jurisdiction_cd);

     ln_step := 8;

--    end if;
     -- Added p_xfr_action_id parameter part of fix for bug#3940380
     pay_ac_action_arch.get_last_xfr_info(
                       p_assignment_id       => p_assignment_id
                      ,p_curr_effective_date => p_xfr_end_date
                      ,p_action_info_category=> 'EMPLOYEE DETAILS'
                      ,p_xfr_action_id => p_xfr_action_id
                      ,p_sepchk_flag         => p_seperate_check_flag
                      ,p_last_xfr_eff_date   => ld_last_xfr_eff_date
                      ,p_last_xfr_action_id  => ln_last_xfr_action_id
                      );

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

     ln_step := 9;
     pay_ac_action_arch.initialization_process;

     ln_step := 10;

     if p_archive_balance_info = 'Y' then   -- Bug 3960157
      populate_fed_prov_bal( p_xfr_action_id     => p_xfr_action_id
                           ,p_assignment_id     => p_assignment_id
                           ,p_pymt_balcall_aaid => p_payment_action_id
                           ,p_tax_unit_id       => p_tax_unit_id
                           ,p_action_type       => p_action_type
                           ,p_pymt_eff_date     => p_curr_pymt_eff_date
                           ,p_start_date        => p_xfr_start_date
                           ,p_end_date          => p_xfr_end_date
                           ,p_ytd_balcall_aaid  => ln_ytd_balcall_aaid
                         );

    ln_step := 11;
    if pay_ac_action_arch.gv_reporting_level = 'TAXGRP' then
       /****************************************************
       ** Need to set Tax Unit Id context for Non-Payroll
       ** Payment element has been processed when Reporting
       ** Level is Tax Group.
       ****************************************************/
       pay_balance_pkg.set_context('TAX_UNIT_ID', p_tax_unit_id);
    end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 90);

     /******************************************************************
     ** For seperate check cases, the ld_last_xfr_eff_date is never null
     ** as the master is always processed before the child actions. The
     ** master data is already in the archive table and as it is in the
     ** same session the process will always go to the else statement
     ******************************************************************/
     ln_step := 12;
--    if p_seperate_check_flag = 'N' and p_archive_balance_info <> 'N' then
     if ld_last_xfr_eff_date is null then
        hr_utility.set_location(gv_package || lv_procedure_name, 100);
        ln_step := 13;
        pay_ac_action_arch.first_time_process(
               p_xfr_action_id       => p_xfr_action_id
              ,p_assignment_id       => p_assignment_id
              ,p_curr_pymt_action_id => p_rqp_action_id    --PP
              ,p_curr_pymt_eff_date  => p_curr_pymt_eff_date
              ,p_curr_eff_date       => p_xfr_end_date
              ,p_tax_unit_id         => p_tax_unit_id
              ,p_pymt_balcall_aaid   => p_payment_action_id --SM
              ,p_ytd_balcall_aaid    => ln_ytd_balcall_aaid --MM
              ,p_sepchk_run_type_id  => p_sepcheck_run_type_id
              ,p_sepchk_flag         => p_seperate_check_flag
              ,p_legislation_code    => p_legislation_code
              );

     else
        ln_step := 14;
        get_last_pymt_info(p_assignment_id,
                           p_curr_pymt_eff_date,
                           ld_last_pymt_eff_date,
                           ln_last_pymt_action_id
                           );

        ln_step := 15;
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

        ln_step := 16;
        pay_ac_action_arch.get_xfr_elements(
               p_xfr_action_id      => p_xfr_action_id
              ,p_last_xfr_action_id => ln_last_xfr_action_id
              ,p_ytd_balcall_aaid   => ln_ytd_balcall_aaid
              ,p_pymt_eff_date      => p_curr_pymt_eff_date
              ,p_legislation_code   => p_legislation_code
              ,p_sepchk_flag        => p_seperate_check_flag
              ,p_assignment_id      => p_assignment_id);

        if ld_last_pymt_eff_date <> p_curr_pymt_eff_date then
           ln_step := 17;
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

     end if;
--   end if;
     ln_step := 19;
     pay_ac_action_arch.populate_summary(
                  p_xfr_action_id => p_xfr_action_id);

 end if;


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

     pay_emp_action_arch.insert_rows_thro_api_process(
                  p_action_context_id  => p_xfr_action_id
                 ,p_action_context_type=> 'AAP'
                 ,p_assignment_id      => p_assignment_id
                 ,p_tax_unit_id        => p_tax_unit_id
                 ,p_curr_pymt_eff_date => p_curr_pymt_eff_date
                 ,p_tab_rec_data       => pay_ac_action_arch.lrr_act_tab
                 );

  EXCEPTION
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

  END process_actions;

  /************************************************************
   Name      : create_child_act_for_taxgrp
   Purpose   : This function creates child assignment actions.
               These action would be created for normal cheques
               as well as separate cheques for Single GRE/
               Multi Assignment / Multi GRE when Payroll
               Aerchiver Level is set to 'TAXGRP' and this
               also creates locking records
   Arguments :
   Notes     :
  ************************************************************/
  PROCEDURE create_child_act_for_taxgrp(
                    p_xfr_payroll_action_id   in number
                   ,p_master_xfr_action_id    in number
                   ,p_master_prepay_action_id in number
                   ,p_master_action_type      in varchar2
                   ,p_sepchk_run_type_id      in number
                   ,p_legislation_code        in varchar2
                   ,p_assignment_id           in number
                   ,p_tax_unit_id             in number
                   ,p_curr_pymt_eff_date      in date
                   ,p_xfr_start_date          in date
                   ,p_xfr_end_date            in date
                   ,p_chunk                   in number
                   )
  IS

  cursor c_payment_info(cp_prepay_action_id number) is
    select distinct assignment_id
          ,nvl(source_action_id,-999)
    from  pay_payment_information_v
    where assignment_action_id = cp_prepay_action_id
    order by 2,1;

  cursor c_get_pp_actid_of_multigre(cp_prepay_action_id number
                                   ,cp_assignment_id    number
                                   ,cp_tax_unit_id      number) is
    select assignment_action_id
    from   pay_assignment_actions
    where  source_action_id = cp_prepay_action_id
    and    assignment_id    = cp_assignment_id
    and    tax_unit_id      = cp_tax_unit_id;

  cursor c_get_pp_actid_of_sepchk(cp_source_action_id number) is
    select paa.assignment_action_id
    from   pay_action_interlocks pai
          ,pay_assignment_actions paa
          ,pay_payroll_actions ppa
    where pai.locked_action_id = cp_source_action_id
    and   paa.assignment_action_id = pai.locking_action_id
    and   paa.source_action_id is not null
    and   ppa.payroll_action_id = paa.payroll_action_id
    and   ppa.action_type in ( 'P', 'U' );

  /* Modified to avoid reversals to be picked up based on
     pre-payment assignment action id, 'V'. Bug#3498653 */
  cursor c_run_master_aa_id(cp_pp_asg_act_id number
                           ,cp_assignment_id number) is
    select paa.assignment_action_id,ppa_run.action_type
    from   pay_assignment_actions paa
          ,pay_action_interlocks pai
          ,pay_payroll_actions ppa_run
    where  pai.locking_action_id    = cp_pp_asg_act_id
    and    paa.assignment_action_id = pai.locked_action_id
    and    paa.assignment_id        = cp_assignment_id
    and    paa.source_action_id is null
    /* Added these two line to avoid reversals 'V' */
    and    ppa_run.payroll_action_id = paa.payroll_action_id
    and    ppa_run.action_type <> 'V';

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
                         where  prt.legislation_code = 'CA'
                         and    prt.run_type_id = nvl(paa.run_type_id,0)
                         and    prt.run_method  = 'C' );

    ln_assignment_id          NUMBER;
    ln_tax_unit_id            NUMBER;
    ln_source_action_id       NUMBER;

    prev_assignment_id          NUMBER;
    prev_tax_unit_id            NUMBER;
    prev_source_action_id       NUMBER;

    ln_prepay_asg_act_id        NUMBER;
    lv_seperate_check_flag      VARCHAR2(1);
    ln_child_xfr_action_id      NUMBER;
    lv_serial_number            VARCHAR2(500);
    ln_rqp_action_id            NUMBER;
    ln_ppp_source_action_id     NUMBER;

    ln_run_aa_id                NUMBER;
    ln_run_source_aa_id         NUMBER;
    ln_master_run_aa_id         NUMBER;

    ln_gross_earn_bal           NUMBER;
    ln_assignment_action_id     NUMBER;

    lv_error_message          VARCHAR2(500);
    lv_procedure_name         VARCHAR2(100);
    ln_step                   NUMBER;
    /* New variable added for Bal Adj's, bug#3498653 */
    lv_run_action_type        VARCHAR2(30);


  BEGIN

    lv_procedure_name := '.create_child_act_for_taxgrp';
    hr_utility.set_location('Entering create_child_act_for_taxgrp ', 10 );
    hr_utility.trace('GRE p_master_prepay_action_id : ' ||
                          p_master_prepay_action_id);

    /* Initialising local variables to avoid GSCC warnings */
    ln_step := 1;
    prev_assignment_id     := 0;
    prev_tax_unit_id       := 0;
    prev_source_action_id  := 0;
    ln_prepay_asg_act_id   := 0;
    lv_seperate_check_flag := 'N';
    ln_child_xfr_action_id := 0;
    ln_rqp_action_id       := 0;
    ln_run_aa_id           := 0;
    ln_run_source_aa_id    := 0;
    ln_master_run_aa_id    := 0;

    /*************************************************************
    ** The c_payment_info cursor will give the count, how many
    ** no. of cheques will be printed.
    *************************************************************/

    open c_payment_info(p_master_prepay_action_id);
    loop

      fetch c_payment_info into ln_assignment_id
                               ,ln_source_action_id;
      exit when c_payment_info%notfound;

      if ln_source_action_id = -999 then

         lv_seperate_check_flag := 'N';
         ln_prepay_asg_act_id := p_master_prepay_action_id;

         ln_step := 6;

         /********************************************************
         ** Getting Run Assignment Action Id for normal cheque.
         ********************************************************/
         open  c_run_master_aa_id(ln_prepay_asg_act_id
                                 ,ln_assignment_id);
         fetch c_run_master_aa_id into ln_master_run_aa_id,lv_run_action_type;
         /* Added this to archive Bal Adj's 'B' current amounts with
            pre-payments for Tax Group reporting. Bug#3498653 */

          if c_run_master_aa_id%found then
             hr_utility.trace('c_run_master_aa_id ran, ln_master_run_aa_id = '||to_char(ln_master_run_aa_id));

             if lv_run_action_type = 'B' then
                ln_master_run_aa_id := ln_prepay_asg_act_id;
             end if;
          end if;
         /* End of addition bug#3498653 */
         close c_run_master_aa_id;

         hr_utility.trace('TAXGRP ln_master_run_aa_id = ' ||
                                  ln_master_run_aa_id);

         ln_rqp_action_id         := ln_prepay_asg_act_id;
         ln_ppp_source_action_id  := NULL;

      else

         lv_seperate_check_flag := 'Y';

         /*****************************************************
         ** To get prepayment assignment action id for Separate
         ** Cheque for locking.
         ** Single Asg + Single GRE -> Master PP Asg Act ID
         ** Single Asg + Multi GRE -> Master or Child PP AAID
         ** Multi Asg + Single GRE -> Child PP AAID
         ** Following cursor returns corrent PP AAID for  any
         ** above case. If not found then set master PP AAID
         ** which is nothing but zero net pay.
         ******************************************************/

         open c_get_pp_actid_of_sepchk(ln_source_action_id);
         fetch c_get_pp_actid_of_sepchk into ln_prepay_asg_act_id;

         if c_get_pp_actid_of_sepchk%notfound then
            ln_prepay_asg_act_id := p_master_prepay_action_id;
         end if;
         close c_get_pp_actid_of_sepchk;

         ln_master_run_aa_id      := ln_source_action_id; -- Sep Chk
         ln_rqp_action_id         := ln_source_action_id; -- Sep Chk
         ln_ppp_source_action_id  := ln_source_action_id; -- Sep Chk

      end if;

      hr_utility.set_location(gv_package || lv_procedure_name, 20);
      hr_utility.trace('TAXGRP ln_prepay_asg_act_id : '||ln_prepay_asg_act_id);
      hr_utility.trace('TAXGRP ln_assignment_id : ' || ln_assignment_id);
      hr_utility.trace('TAXGRP ln_source_action_id : ' || ln_source_action_id);
      hr_utility.trace('TAXGRP lv_seperate_check_flag : ' ||
                                lv_seperate_check_flag);

      ln_step := 2;


      /****************************************************************
      ** Create Child Assignment Action
      ** When Source Action Id is -999 i.e. Normal Cheque
      ** When Source Action Id is not -999 i.e. Separate Cheque
      ** Below condition will create only one assignment action
      ** id when Multi Assignment payment is enabled for diff assignments
      *******************************************************************/

      if ( ln_source_action_id <> prev_source_action_id ) then

         select pay_assignment_actions_s.nextval
           into ln_child_xfr_action_id
           from dual;

         hr_utility.set_location(gv_package || lv_procedure_name, 30);

         -- insert into pay_assignment_actions.

         ln_step := 3;

         hr_nonrun_asact.insact(ln_child_xfr_action_id,
                                ln_assignment_id,
                                p_xfr_payroll_action_id,
                                p_chunk,
                                p_tax_unit_id,
                                null,
                                'C',
                                p_master_xfr_action_id);

         hr_utility.set_location(gv_package || lv_procedure_name, 40);

         hr_utility.trace('GRE Locking Action = ' || ln_child_xfr_action_id);
         hr_utility.trace('GRE Locked Action = '  || ln_prepay_asg_act_id);

         -- insert an interlock to this action

         ln_step := 4;

         hr_nonrun_asact.insint(ln_child_xfr_action_id,
                                ln_prepay_asg_act_id);

         if ln_source_action_id = -999 then
            lv_serial_number := p_master_action_type ||
                                lv_seperate_check_flag || ln_prepay_asg_act_id;
         else
            lv_serial_number := p_master_action_type ||
                                lv_seperate_check_flag || ln_source_action_id;
         end if;

         ln_step := 5;

         update pay_assignment_actions
            set serial_number = lv_serial_number
          where assignment_action_id = ln_child_xfr_action_id;

         hr_utility.trace('Processing Child action for Master for Multi GRE ' ||
                          p_master_xfr_action_id);


      end if;

      hr_utility.trace('GRE ln_master_run_aa_id = ' ||
                            ln_master_run_aa_id);
      hr_utility.trace('GRE B4 Calling Process Actions ln_prepay_asg_act_id : '
                       || ln_prepay_asg_act_id);

      /****************************************************************
      ** Archive the data for the Child Action
      ****************************************************************/

      hr_utility.set_location(gv_package || lv_procedure_name, 50);
      ln_step := 7;

      process_actions(p_xfr_payroll_action_id => p_xfr_payroll_action_id
                     ,p_xfr_action_id         => ln_child_xfr_action_id
                     ,p_pre_pay_action_id     => ln_prepay_asg_act_id
                     ,p_payment_action_id     => ln_master_run_aa_id
                     ,p_rqp_action_id         => ln_rqp_action_id
                     ,p_seperate_check_flag   => lv_seperate_check_flag
                     ,p_sepcheck_run_type_id  => p_sepchk_run_type_id
                     ,p_action_type           => p_master_action_type
                     ,p_legislation_code      => p_legislation_code
                     ,p_assignment_id         => ln_assignment_id
                     ,p_tax_unit_id           => p_tax_unit_id
                     ,p_curr_pymt_eff_date    => p_curr_pymt_eff_date
                     ,p_xfr_start_date        => p_xfr_start_date
                     ,p_xfr_end_date          => p_xfr_end_date
                     ,p_ppp_source_action_id  => ln_ppp_source_action_id
                     );

      prev_source_action_id := ln_source_action_id;

    end loop; -- c_payment_info

    close c_payment_info;

    hr_utility.set_location('Leaving create_child_act_for_taxgrp ',60 );

  EXCEPTION
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


  END create_child_act_for_taxgrp;


  /************************************************************
   Name      : create_child_actions_for_gre
   Purpose   : This function creates child assignment actions.
               These action would be created for normal cheques
               as well as separate cheques for Single GRE/
               Multi Assignment / Multi GRE when Payroll
               Aerchiver Level is set to 'GRE' and this
               also creates locking records
   Arguments :
   Notes     :
  ************************************************************/
  PROCEDURE create_child_actions_for_gre(
                    p_xfr_payroll_action_id   in number
                   ,p_master_xfr_action_id    in number
                   ,p_master_prepay_action_id in number
                   ,p_master_action_type      in varchar2
                   ,p_sepchk_run_type_id      in number
                   ,p_legislation_code        in varchar2
                   ,p_assignment_id           in number
                   ,p_curr_pymt_eff_date      in date
                   ,p_xfr_start_date          in date
                   ,p_xfr_end_date            in date
                   ,p_chunk                   in number
                   )
  IS

  cursor c_payment_info(cp_prepay_action_id number) is
    select assignment_id
          ,tax_unit_id
          ,nvl(source_action_id,-999)
    from  pay_payment_information_v
    where assignment_action_id = cp_prepay_action_id
    order by 3,1,2;

  cursor c_get_pp_actid_of_multigre(cp_prepay_action_id number
                                   ,cp_assignment_id    number
                                   ,cp_tax_unit_id      number) is
    select assignment_action_id
    from   pay_assignment_actions
    where  source_action_id = cp_prepay_action_id
    and    assignment_id    = cp_assignment_id
    and    tax_unit_id      = cp_tax_unit_id;

  cursor c_get_pp_actid_of_sepchk(cp_source_action_id number) is
    select paa.assignment_action_id
    from   pay_action_interlocks pai
          ,pay_assignment_actions paa
          ,pay_payroll_actions ppa
    where pai.locked_action_id = cp_source_action_id
    and   paa.assignment_action_id = pai.locking_action_id
    and   paa.source_action_id is not null
    and   ppa.payroll_action_id = paa.payroll_action_id
    and   ppa.action_type in ( 'P', 'U' );

  cursor c_run_aa_id(cp_pp_asg_act_id number
                    ,cp_assignment_id number
                    ,cp_tax_unit_id   number) is
    select paa.assignment_action_id, paa.source_action_id
    from   pay_assignment_actions paa
          ,pay_action_interlocks pai
    where  pai.locking_action_id    = cp_pp_asg_act_id
    and    paa.assignment_action_id = pai.locked_action_id
    and    paa.assignment_id        = cp_assignment_id
    and    paa.tax_unit_id          = cp_tax_unit_id
    and    paa.source_action_id is not null
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
                         where  prt.legislation_code = 'CA'
                         and    prt.run_type_id = nvl(paa.run_type_id,0)
                         and    prt.run_method  = 'C' );

    ln_assignment_id          NUMBER;
    ln_tax_unit_id            NUMBER;
    ln_source_action_id       NUMBER;

    prev_assignment_id          NUMBER;
    prev_tax_unit_id            NUMBER;
    prev_source_action_id       NUMBER;

    ln_prepay_asg_act_id        NUMBER;
    lv_seperate_check_flag      VARCHAR2(1);
    ln_child_xfr_action_id      NUMBER;
    lv_serial_number            VARCHAR2(500);
    ln_rqp_action_id            NUMBER;
    ln_ppp_source_action_id     NUMBER;

    ln_run_aa_id                NUMBER;
    ln_run_source_aa_id         NUMBER;
    ln_master_run_aa_id         NUMBER;

    ln_gross_earn_bal           NUMBER;
    ln_assignment_action_id     NUMBER;

    lv_error_message          VARCHAR2(500);
    lv_procedure_name         VARCHAR2(100);
    ln_step                   NUMBER;
    lv_archive_balance_info  VARCHAR2(1) := 'Y';  -- Bug 3960157


  BEGIN

--  hr_utility.trace_on (null, 'PYARCH');
    lv_procedure_name := '.create_child_actions_for_gre';
    hr_utility.set_location('Entering create_child_actions_for_gre ', 10 );
    hr_utility.trace('GRE p_master_prepay_action_id : ' ||
                          p_master_prepay_action_id);

    ln_step := 1;
    /* Initialising local variables to avoid GSCC warnings */
    prev_assignment_id       := 0;
    prev_tax_unit_id         := 0;
    prev_source_action_id    := 0;
    ln_prepay_asg_act_id     := 0;
    lv_seperate_check_flag   := 'N';
    ln_child_xfr_action_id   := 0;
    ln_rqp_action_id         := 0;
    ln_run_aa_id             := 0;
    ln_run_source_aa_id      := 0;
    ln_master_run_aa_id      := 0;

    /*************************************************************
    ** The c_payment_info cursor will give the count, how many
    ** no. of cheques will be printed.
    *************************************************************/

    open c_payment_info(p_master_prepay_action_id);
    loop

      fetch c_payment_info into ln_assignment_id
                               ,ln_tax_unit_id
                               ,ln_source_action_id;
      exit when c_payment_info%notfound;

      ln_gross_earn_bal      := 0;

      if ln_source_action_id = -999 then

         lv_seperate_check_flag := 'N';

         /**************************************************
         ** gv_multi_gre_payment = 'N' means, Multi GRE is
         ** enabled. To get prepayment assignment action id
         ** of particular GRE. If no data found then use the
         ** master prepayment assignment action id.
         *****************************************************/

         if pay_ac_action_arch.gv_multi_gre_payment = 'N' then

            if (pay_emp_action_arch.gv_multi_payroll_pymt = 'N' or
                pay_emp_action_arch.gv_multi_payroll_pymt is null) then

                open  c_get_pp_actid_of_multigre(p_master_prepay_action_id
                                                ,ln_assignment_id
                                                ,ln_tax_unit_id);

                fetch c_get_pp_actid_of_multigre into ln_prepay_asg_act_id;

                if c_get_pp_actid_of_multigre%notfound then
                   ln_prepay_asg_act_id := p_master_prepay_action_id;
                end if;

                close c_get_pp_actid_of_multigre;

            else
                   /************************************************
                   ** Multi GRE and Multi Asg of one GRE
                   *************************************************/
                   ln_prepay_asg_act_id := p_master_prepay_action_id;

            end if;

         else

            /***************************************************
            ** For Multi Assignment or Single Assignment payroll.
            *****************************************************/

            ln_prepay_asg_act_id := p_master_prepay_action_id;

         end if;

         ln_step := 6;

         /********************************************************
         ** Getting Run Assignment Action Id for normal cheque.
         ********************************************************/
         open  c_run_aa_id(ln_prepay_asg_act_id
                          ,ln_assignment_id
                          ,ln_tax_unit_id);
         fetch c_run_aa_id into ln_run_aa_id
                               ,ln_run_source_aa_id;
         hr_utility.trace('GRE ln_run_aa_id = ' || ln_run_aa_id);
         hr_utility.trace('GRE ln_run_source_aa_id = '  || ln_run_source_aa_id);         /* Balance Adjustments source_action_id is null, even if we
            correct the c_run_aa_id cursor, it will pass the balance
            adjustment run asg_act_id for balance calls to archive.
            But ASG_PAYMENTS will not return any value with balance
            adjustments run asg_act_id, we have to pass the balance
            adjustments pre-payment asg_act_id to get the correct
            balance values archived using ASG_PAYMENTS dimension.'B'.
            so added c_run_aa_id is not found then ln_master_run_aa_id
            will be assigned the ln_prepay_asg_act_id that is nothing
            but balance adjustment pre-payment asg_act_id. Bug#3498653 */

            if c_run_aa_id%NOTFOUND then
               hr_utility.trace('Procedure name: '||lv_procedure_name);
               hr_utility.trace('c_run_aa_id%NOT FOUND satisfied with action type B');
               ln_master_run_aa_id := ln_prepay_asg_act_id;
               hr_utility.trace('ln_master_run_aa_id :'||to_char(ln_master_run_aa_id));
            else
              if pay_ac_action_arch.gv_multi_gre_payment = 'N' then
               hr_utility.trace('Procedure name: '||lv_procedure_name);
               hr_utility.trace('gv_multi_gre_payment = N satisfied');

               ln_master_run_aa_id := ln_run_aa_id; -- Sub Master for Multi GRE
               hr_utility.trace('ln_master_run_aa_id :'||to_char(ln_master_run_aa_id));
              else
               hr_utility.trace('gv_multi_gre_payment = N did not satisfied');
               ln_master_run_aa_id := ln_run_source_aa_id; -- Main Master
               hr_utility.trace('ln_master_run_aa_id :'||to_char(ln_master_run_aa_id));
              end if;
            end if; -- c_run_aa_id%NOTFOUND
         close c_run_aa_id;

        /* Old code before bug#3498653 fix
         hr_utility.trace('GRE ln_run_aa_id = ' || ln_run_aa_id);
         hr_utility.trace('GRE ln_run_source_aa_id = '  || ln_run_source_aa_id);

         if pay_ac_action_arch.gv_multi_gre_payment = 'N' then
            ln_master_run_aa_id := ln_run_aa_id; -- Sub Master for Multi GRE
         else
            ln_master_run_aa_id := ln_run_source_aa_id; -- Main Master
         end if;
         */

         ln_rqp_action_id         := ln_prepay_asg_act_id;
         ln_ppp_source_action_id  := NULL;

         /***************************************************************
         ** The following process is checked whether any earning
         ** element has been processed for normal run (also check net pay
         ** zero) if yes then create assignment action and archive
         ** otherwise don't create assignment action and don't
         ** archive too.
         ****************************************************************/

         if gn_gross_earn_def_bal_id + gn_payments_def_bal_id <> 0 then
            open  c_all_runs(p_master_prepay_action_id,
                             ln_assignment_id,
                             ln_tax_unit_id,
                             p_sepchk_run_type_id);
            loop
               fetch c_all_runs into ln_assignment_action_id;
               if c_all_runs%notfound then
                  exit;
               end if;

               ln_gross_earn_bal := nvl(pay_balance_pkg.get_value(
                                  gn_gross_earn_def_bal_id,
                                  ln_assignment_action_id),0);

               /**************************************************
               ** For Non-payroll Payments element is processed
               ** alone, the gross earning balance returns zero.
               ** In this case check payment.
               **************************************************/

               if ln_gross_earn_bal = 0 then

                  ln_gross_earn_bal := nvl(pay_balance_pkg.get_value(
                                     gn_payments_def_bal_id,
                                     ln_assignment_action_id),0);

               end if;

               if ln_gross_earn_bal <> 0 then
                  exit;
               end if;

            end loop;
            close c_all_runs;
         end if;

      else

         lv_seperate_check_flag := 'Y';
         ln_gross_earn_bal      := 1;

         /*****************************************************
         ** To get prepayment assignment action id for Separate
         ** Cheque for locking.
         ** Single Asg + Single GRE -> Master PP Asg Act ID
         ** Single Asg + Multi GRE -> Master or Child PP AAID
         ** Multi Asg + Single GRE -> Child PP AAID
         ** Following cursor returns corrent PP AAID for  any
         ** above case. If not found then set master PP AAID
         ** which is nothing but zero net pay.
         ******************************************************/

         open c_get_pp_actid_of_sepchk(ln_source_action_id);
         fetch c_get_pp_actid_of_sepchk into ln_prepay_asg_act_id;

         if c_get_pp_actid_of_sepchk%notfound then
            ln_prepay_asg_act_id := p_master_prepay_action_id;
         end if;
         close c_get_pp_actid_of_sepchk;

         ln_master_run_aa_id      := ln_source_action_id; -- Sep Chk
         ln_rqp_action_id         := ln_source_action_id; -- Sep Chk
         ln_ppp_source_action_id  := ln_source_action_id; -- Sep Chk

      end if;

         /*  Bug 3960157 */
          if ln_gross_earn_bal = 0 and
             p_assignment_id = ln_assignment_id and
             pay_emp_action_arch.gv_multi_payroll_pymt = 'Y' then
             ln_gross_earn_bal := 1;
             lv_archive_balance_info := 'N';
          else
             lv_archive_balance_info := 'Y';
          end if;
          /*  Bug 3960157 */

      hr_utility.set_location(gv_package || lv_procedure_name, 20);
      hr_utility.trace('GRE ln_prepay_asg_act_id : ' || ln_prepay_asg_act_id);
      hr_utility.trace('GRE ln_tax_unit_id : ' || ln_tax_unit_id);
      hr_utility.trace('GRE ln_assignment_id : ' || ln_assignment_id);
      hr_utility.trace('GRE ln_source_action_id : ' || ln_source_action_id);
      hr_utility.trace('GRE lv_seperate_check_flag : ' ||
                            lv_seperate_check_flag);

      ln_step := 2;

      if ln_gross_earn_bal <> 0 then

      /****************************************************************
      ** Create Child Assignment Action
      ** When Source Action Id is -999 i.e. Normal Cheque
      **     Multi GRE same assignment but diff tax unit id
      ** When Source Action Id is not -999 i.e. Separate Cheque
      ** Below condition will create only one assignment action
      ** id when Multi Assignment payment is enabled for diff assignments
      *******************************************************************/

      if ( ( ln_source_action_id <> prev_source_action_id ) or
           ( ln_tax_unit_id <> prev_tax_unit_id ) ) then

         select pay_assignment_actions_s.nextval
           into ln_child_xfr_action_id
           from dual;

         hr_utility.set_location(gv_package || lv_procedure_name, 30);

         -- insert into pay_assignment_actions.

         ln_step := 3;

         hr_nonrun_asact.insact(ln_child_xfr_action_id,
                                ln_assignment_id,
                                p_xfr_payroll_action_id,
                                p_chunk,
                                ln_tax_unit_id,
                                null,
                                'C',
                                p_master_xfr_action_id);

         hr_utility.set_location(gv_package || lv_procedure_name, 40);

         hr_utility.trace('GRE Locking Action = ' || ln_child_xfr_action_id);
         hr_utility.trace('GRE Locked Action = '  || ln_prepay_asg_act_id);

         -- insert an interlock to this action

         ln_step := 4;

         hr_nonrun_asact.insint(ln_child_xfr_action_id,
                                ln_prepay_asg_act_id);

         if ln_source_action_id = -999 then
            lv_serial_number := p_master_action_type ||
                                lv_seperate_check_flag || ln_prepay_asg_act_id;
         else
            lv_serial_number := p_master_action_type ||
                                lv_seperate_check_flag || ln_source_action_id;
         end if;

         ln_step := 5;

         update pay_assignment_actions
            set serial_number = lv_serial_number
          where assignment_action_id = ln_child_xfr_action_id;

         hr_utility.trace('Processing Child action for Master for Multi GRE ' ||
                          p_master_xfr_action_id);


      end if;

      hr_utility.trace('GRE ln_master_run_aa_id = ' ||
                            ln_master_run_aa_id);
      hr_utility.trace('GRE B4 Calling Process Actions ln_prepay_asg_act_id : '
                       || ln_prepay_asg_act_id);

      /****************************************************************
      ** Archive the data for the Child Action
      ****************************************************************/

      hr_utility.set_location(gv_package || lv_procedure_name, 50);
      ln_step := 7;
     end if;


      if ln_gross_earn_bal <> 0 then
       if ln_child_xfr_action_id = 0 then
         ln_child_xfr_action_id := p_master_xfr_action_id;
       end if;
       process_actions(p_xfr_payroll_action_id => p_xfr_payroll_action_id
                      ,p_xfr_action_id         => ln_child_xfr_action_id
                      ,p_pre_pay_action_id     => ln_prepay_asg_act_id
                      ,p_payment_action_id     => ln_master_run_aa_id
                      ,p_rqp_action_id         => ln_rqp_action_id
                      ,p_seperate_check_flag   => lv_seperate_check_flag
                      ,p_sepcheck_run_type_id  => p_sepchk_run_type_id
                      ,p_action_type           => p_master_action_type
                      ,p_legislation_code      => p_legislation_code
                      ,p_assignment_id         => ln_assignment_id
                      ,p_tax_unit_id           => ln_tax_unit_id
                      ,p_curr_pymt_eff_date    => p_curr_pymt_eff_date
                      ,p_xfr_start_date        => p_xfr_start_date
                      ,p_xfr_end_date          => p_xfr_end_date
                      ,p_ppp_source_action_id  => ln_ppp_source_action_id
                      ,p_archive_balance_info  => lv_archive_balance_info  -- Bug 3960157
                      );

      end if;

      prev_source_action_id := ln_source_action_id;
      prev_tax_unit_id := ln_tax_unit_id;

    end loop; -- c_payment_info

    close c_payment_info;

    hr_utility.set_location('Leaving create_child_actions_for_gre ',60 );

  EXCEPTION
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


  END create_child_actions_for_gre;

  /************************************************************
   Name      : create_child_actions
   Purpose   : This function creates child assignment actions.
               These action would be created for the seperate check
               case(s) only and also create locking records
   Arguments :
   Notes     :
  ************************************************************/
  PROCEDURE create_chld_act_for_multi_gre(
                    p_xfr_payroll_action_id   in number
                   ,p_master_xfr_action_id    in number
                   ,p_master_prepay_action_id in number
                   ,p_master_action_type      in varchar2
                   ,p_sepchk_run_type_id      in number
                   ,p_legislation_code        in varchar2
                   ,p_assignment_id           in number
                   ,p_curr_pymt_eff_date      in date
                   ,p_xfr_start_date          in date
                   ,p_xfr_end_date            in date
                   ,p_chunk                   in number
                   )
  IS

  cursor c_prepay_act(cp_master_prepay_act_id number,
                      cp_curr_pymt_eff_date   date) is
    select distinct
           paa.assignment_action_id
          ,paa.tax_unit_id
    from   pay_assignment_actions paa
          ,pay_pre_payments ppp
          ,pay_org_payment_methods popm
    where paa.source_action_id     = cp_master_prepay_act_id
    and   ppp.assignment_action_id = paa.assignment_action_id
    and   ppp.source_action_id is null
    and   nvl(ppp.value,0) <> 0
    and   ppp.org_payment_method_id = popm.org_payment_method_id
    and   popm.defined_balance_id is not null
    and   cp_curr_pymt_eff_date between popm.effective_start_date
                                    and popm.effective_end_date;


  cursor c_mst_prepay_act(cp_master_prepay_act_id number,
                          cp_curr_pymt_eff_date   date) is
    select distinct
           paa.assignment_action_id
          ,paa.tax_unit_id
    from   pay_assignment_actions paa
          ,pay_pre_payments ppp
          ,pay_org_payment_methods popm
    where paa.assignment_action_id = cp_master_prepay_act_id
    and   ppp.assignment_action_id = paa.assignment_action_id
    and   ppp.source_action_id is null
    and   nvl(ppp.value,0) <> 0
    and   ppp.org_payment_method_id = popm.org_payment_method_id
    and   popm.defined_balance_id is not null
    and   p_curr_pymt_eff_date between popm.effective_start_date
                                   and popm.effective_end_date;

  cursor c_tax_unit(cp_pp_asg_act_id number) is
    select distinct paa.tax_unit_id
    from   pay_assignment_actions paa
          ,pay_action_interlocks pai
    where  pai.locking_action_id = cp_pp_asg_act_id
    and    paa.assignment_action_id = pai.locked_action_id
    and    paa.tax_unit_id is not null;

  cursor c_run_aa_id(cp_pp_asg_act_id number) is
    select paa.assignment_action_id, paa.source_action_id
    from   pay_assignment_actions paa
          ,pay_action_interlocks pai
    where  pai.locking_action_id = cp_pp_asg_act_id
    and    paa.assignment_action_id = pai.locked_action_id
    and    paa.source_action_id is not null
    order by paa.action_sequence desc;

    ln_pp_asg_act_id number;
    ln_tax_unit_id   number;

    ln_child_xfr_action_id   number;

    ln_run_aa_id             number;
    ln_source_aa_id          number;
    ln_master_run_aa_id      number;

    lv_serial_number          VARCHAR2(500);

    lv_error_message          VARCHAR2(500);
    lv_procedure_name         VARCHAR2(100);
    ln_step                   NUMBER;

    ln_child_aa_count         NUMBER;

  BEGIN

    lv_procedure_name := '.create_chld_act_for_multi_gre';
    hr_utility.set_location('Entering create_chld_act_for_multi_gre ', 10 );
    hr_utility.trace('MG p_master_prepay_action_id : ' ||
                         p_master_prepay_action_id);

    ln_step := 1;
    ln_child_aa_count := 0;
    open c_prepay_act(p_master_prepay_action_id
                     ,p_curr_pymt_eff_date);

    loop

      fetch c_prepay_act into ln_pp_asg_act_id
                             ,ln_tax_unit_id;
      if c_prepay_act%notfound then
         if ln_child_aa_count <> 0 then
            exit;
         else
            open c_mst_prepay_act(p_master_prepay_action_id
                                 ,p_curr_pymt_eff_date);
            fetch c_mst_prepay_act into ln_pp_asg_act_id
                                       ,ln_tax_unit_id;
            if c_mst_prepay_act%notfound then
               close c_mst_prepay_act;
               exit;
            end if;

            close c_mst_prepay_act;
         end if;
      end if;

      ln_child_aa_count := ln_child_aa_count + 1;

      ln_step := 2;
      hr_utility.set_location(gv_package || lv_procedure_name, 20);

      if ln_tax_unit_id is null then
         open  c_tax_unit(ln_pp_asg_act_id);
         fetch c_tax_unit into ln_tax_unit_id;
         close c_tax_unit;
      end if;

      hr_utility.trace('MG ln_pp_asg_act_id : ' || ln_pp_asg_act_id);
      hr_utility.trace('MG ln_tax_unit_id : ' || ln_tax_unit_id);

      select pay_assignment_actions_s.nextval
        into ln_child_xfr_action_id
        from dual;

       hr_utility.set_location(gv_package || lv_procedure_name, 30);

       -- insert into pay_assignment_actions.

       ln_step := 3;

       hr_nonrun_asact.insact(ln_child_xfr_action_id,
                              p_assignment_id,
                              p_xfr_payroll_action_id,
                              p_chunk,
                              ln_tax_unit_id,
                              null,
                              'C',
                              p_master_xfr_action_id);

       hr_utility.set_location(gv_package || lv_procedure_name, 40);

       hr_utility.trace('MG Locking Action = ' || ln_child_xfr_action_id);
       hr_utility.trace('MG Locked Action = '  || ln_pp_asg_act_id);

       -- insert an interlock to this action

       ln_step := 4;

       hr_nonrun_asact.insint(ln_child_xfr_action_id,
                              ln_pp_asg_act_id);

       lv_serial_number := p_master_action_type || 'N' || ln_pp_asg_act_id;

       ln_step := 5;

       update pay_assignment_actions
          set serial_number = lv_serial_number
        where assignment_action_id = ln_child_xfr_action_id;

       hr_utility.trace('Processing Child action for Master for Multi GRE ' ||
                        p_master_xfr_action_id);

       ln_step := 6;

       open  c_run_aa_id(ln_pp_asg_act_id);
       fetch c_run_aa_id into ln_run_aa_id
                             ,ln_source_aa_id;
       close c_run_aa_id;

       hr_utility.trace('MG ln_run_aa_id = ' || ln_run_aa_id);
       hr_utility.trace('MG ln_source_aa_id = '  || ln_source_aa_id);

       if pay_ac_action_arch.gv_multi_gre_payment = 'N' then
          ln_master_run_aa_id := ln_run_aa_id;
       else
          ln_master_run_aa_id := ln_source_aa_id;
       end if;

       --ln_sub_master_run_aa_id := ln_run_aa_id;

       --ln_master_run_aa_id := ln_pp_asg_act_id;

       hr_utility.trace('MG ln_master_run_aa_id = ' ||
                            ln_master_run_aa_id);

       /****************************************************************
       ** Archive the data for the Child Action
       ****************************************************************/

       hr_utility.set_location(gv_package || lv_procedure_name, 50);
       ln_step := 7;

       process_actions(p_xfr_payroll_action_id => p_xfr_payroll_action_id
                      ,p_xfr_action_id         => ln_child_xfr_action_id
                      ,p_pre_pay_action_id     => ln_pp_asg_act_id
                      ,p_payment_action_id     => ln_master_run_aa_id
                      ,p_rqp_action_id         => ln_pp_asg_act_id
                      ,p_seperate_check_flag   => 'N'
                      ,p_sepcheck_run_type_id  => p_sepchk_run_type_id
                      ,p_action_type           => p_master_action_type
                      ,p_legislation_code      => p_legislation_code
                      ,p_assignment_id         => p_assignment_id
                      ,p_tax_unit_id           => ln_tax_unit_id
                      ,p_curr_pymt_eff_date    => p_curr_pymt_eff_date
                      ,p_xfr_start_date        => p_xfr_start_date
                      ,p_xfr_end_date          => p_xfr_end_date
                      );

    end loop;

    close c_prepay_act;

    hr_utility.set_location('Leaving create_chld_act_for_multi_gre ',60 );

  EXCEPTION
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

  END create_chld_act_for_multi_gre;

  /************************************************************
   Name      : create_child_actions
   Purpose   : This function creates child assignment actions.
               These action would be created for the seperate check
               case(s) only and also create locking records
   Arguments :
   Notes     :
  ************************************************************/
  PROCEDURE create_child_actions (
                 p_xfr_payroll_action_id   in number
                ,p_master_xfr_action_id    in number
                ,p_master_prepay_action_id in number
                ,p_master_action_type      in varchar2
                ,p_curr_pymt_eff_date      in date
                ,p_sepchk_run_type_id      in number
                ,p_legislation_code        in varchar2
                ,p_chunk                   in number)
  IS

    cursor c_multi_asg_child_action(
                 cp_master_prepay_action_id in number
                ,cp_cons_set_id             in number
                ,cp_payroll_id              in number
                ,cp_business_group_id       in number
                ,cp_start_date              in date
                ,cp_end_date                in date
                ,cp_curr_pymt_eff_date      in date
                ) is
     select distinct
            paa.assignment_id,
            paa.tax_unit_id,
            paa.assignment_action_id,
            ppp.source_action_id
       from pay_payroll_actions ppa
           ,pay_assignment_actions paa
           ,pay_pre_payments ppp
           ,pay_org_payment_methods popm
     where ppa.consolidation_set_id
              = nvl(cp_cons_set_id,ppa.consolidation_set_id)
       and paa.action_status = 'C'
       and ppa.payroll_id = cp_payroll_id
       and ppa.payroll_action_id = paa.payroll_action_id
       and ppa.business_group_id  = cp_business_group_id
       and ppa.action_status = 'C'
       and ppa.effective_date between cp_start_date
                                  and cp_end_date
       and ppa.action_type in ('U','P')
       and nvl(paa.source_action_id,paa.assignment_action_id)
                                    = cp_master_prepay_action_id
       and ppp.assignment_action_id = paa.assignment_action_id
       and ppp.source_action_id is not null
       and nvl(ppp.value,0) <> 0
       and ppp.org_payment_method_id = popm.org_payment_method_id
       and popm.defined_balance_id is not null
       and cp_curr_pymt_eff_date between popm.effective_start_date
                                     and popm.effective_end_date
      order by 1,2,3,4;

    cursor c_asg_child_action (cp_prepayment_action_id number
                              ,cp_curr_pymt_eff_date   date) is
      select distinct
             paa.assignment_id,
             paa.tax_unit_id,
             paa.assignment_action_id,
             ppp.source_action_id
        from pay_pre_payments ppp
            ,pay_assignment_actions paa
            ,pay_org_payment_methods popm
      where paa.assignment_action_id = cp_prepayment_action_id
        and ppp.assignment_action_id = paa.assignment_action_id
        and nvl(ppp.value,0) <> 0
        and ppp.source_action_id is not null
        and ppp.org_payment_method_id = popm.org_payment_method_id
        and popm.defined_balance_id is not null
        and cp_curr_pymt_eff_date between popm.effective_start_date
                                      and popm.effective_end_date
        order by ppp.source_action_id;

    cursor c_pre_pay_run_action
           (cp_master_prepay_action_id in number
           ,cp_sepchk_run_type_id      in number) is
     select pai.locked_action_id
       from pay_action_interlocks pai,
            pay_assignment_actions paa
      where pai.locking_action_id = cp_master_prepay_action_id
        and paa.assignment_action_id = pai.locked_action_id
        and paa.source_action_id is not null
        and paa.run_type_id = cp_sepchk_run_type_id;

  cursor c_tax_unit(cp_source_action_id number) is
    select paa.tax_unit_id
    from   pay_assignment_actions paa
    where  paa.assignment_action_id = cp_source_action_id;

    ln_assignment_id        NUMBER;
    ln_tax_unit_id          NUMBER;
    ln_asg_action_id        NUMBER;

    ld_end_date             DATE;
    ld_start_date           DATE;
    ln_business_group_id    NUMBER;
    ln_cons_set_id          NUMBER;
    ln_payroll_id           NUMBER;

    ln_child_xfr_action_id  NUMBER;
    ln_run_action_id        NUMBER(10);

    lv_serial_number        VARCHAR2(20);

    lv_error_message          VARCHAR2(500);
    lv_procedure_name         VARCHAR2(100);
    ln_step                   NUMBER;

  BEGIN
     lv_procedure_name := '.create_child_actions';
     hr_utility.set_location('Entering create_child_actions ', 10 );

     ln_step := 1;
     -- Initialising local variables to avoid GSCC warnings
     ln_assignment_id := 0;
     ln_tax_unit_id   := 0;
     ln_asg_action_id := 0;

     get_payroll_action_info(p_payroll_action_id => p_xfr_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_cons_set_id       => ln_cons_set_id
                            ,p_payroll_id        => ln_payroll_id);
     hr_utility.set_location(gv_package || lv_procedure_name, 20);

    ln_step := 2;
    pay_emp_action_arch.gv_multi_payroll_pymt
          := pay_emp_action_arch.get_multi_assignment_flag(
                              p_payroll_id       => ln_payroll_id
                             ,p_effective_date   => ld_end_date);

    hr_utility.trace('pay_emp_action_arch.gv_multi_payroll_pymt = ' ||
                      pay_emp_action_arch.gv_multi_payroll_pymt);
    ln_step := 3;
    if ((pay_emp_action_arch.gv_multi_payroll_pymt = 'N' or
         pay_emp_action_arch.gv_multi_payroll_pymt is null) and
         pay_ac_action_arch.gv_multi_gre_payment = 'Y' ) then

       hr_utility.set_location(gv_package || lv_procedure_name, 30);
       hr_utility.trace('ln_master_prepay_action_id ' ||
                         p_master_prepay_action_id);
       ln_step := 4;
       open c_asg_child_action(p_master_prepay_action_id
                              ,p_curr_pymt_eff_date);
    else
       hr_utility.set_location(gv_package || lv_procedure_name, 40);
       ln_step := 5;
       open c_multi_asg_child_action(
                      p_master_prepay_action_id
                     ,ln_cons_set_id
                     ,ln_payroll_id
                     ,ln_business_group_id
                     ,ld_start_date
                     ,ld_end_date
                     ,p_curr_pymt_eff_date);
    end if;
    hr_utility.set_location(gv_package || lv_procedure_name, 50);

    ln_step := 6;
    loop
      if ((pay_emp_action_arch.gv_multi_payroll_pymt = 'N' or
           pay_emp_action_arch.gv_multi_payroll_pymt is null) and
           pay_ac_action_arch.gv_multi_gre_payment = 'Y' ) then

          hr_utility.set_location(gv_package || lv_procedure_name, 60);
          ln_step := 7;
          fetch c_asg_child_action into ln_assignment_id,
                                        ln_tax_unit_id,
                                        ln_asg_action_id,
                                        ln_run_action_id;
          exit when c_asg_child_action%notfound;
       else
          ln_step := 8;
          hr_utility.set_location(gv_package || lv_procedure_name, 70);
          fetch c_multi_asg_child_action into ln_assignment_id,
                                              ln_tax_unit_id,
                                              ln_asg_action_id,
                                              ln_run_action_id;
          exit when c_multi_asg_child_action%notfound;
       end if;
       hr_utility.set_location(gv_package || lv_procedure_name, 80);

       if ln_tax_unit_id is null then
          ln_step := 81;
          open c_tax_unit(ln_run_action_id);
          fetch c_tax_unit into ln_tax_unit_id;
          close c_tax_unit;
       end if;

       -- create child assignment action
       ln_step := 9;
       select pay_assignment_actions_s.nextval
         into ln_child_xfr_action_id
         from dual;

       hr_utility.set_location(gv_package || lv_procedure_name, 90);
       -- insert into pay_assignment_actions.
       ln_step := 10;
       hr_nonrun_asact.insact(ln_child_xfr_action_id,
                              ln_assignment_id,
                              p_xfr_payroll_action_id,
                              p_chunk,
                              ln_tax_unit_id,
                              null,
                              'C',
                              p_master_xfr_action_id);
       hr_utility.set_location(gv_package || lv_procedure_name, 100);
       hr_utility.trace('Locking Action = ' || ln_child_xfr_action_id);
       hr_utility.trace('Locked Action = '  || ln_asg_action_id);
       -- insert an interlock to this action
       ln_step := 11;
       hr_nonrun_asact.insint(ln_child_xfr_action_id,
                              ln_asg_action_id);

       hr_utility.set_location(gv_package || lv_procedure_name, 110);
--       if pay_ac_action_arch.gv_multi_asg_enabled = 'Y' then
--          open c_pre_pay_run_action (ln_asg_action_id, p_sepchk_run_type_id);
--          fetch c_pre_pay_run_action into ln_run_action_id;
--          close c_pre_pay_run_action;
--       end if;

       lv_serial_number := p_master_action_type || 'Y' || ln_run_action_id;

       ln_step := 12;
       update pay_assignment_actions
          set serial_number = lv_serial_number
        where assignment_action_id = ln_child_xfr_action_id;

       hr_utility.trace('Processing Child action for Master ' ||
                        p_master_xfr_action_id);

       /****************************************************************
       ** Archive the data for the Child Action
       ****************************************************************/
       ln_step := 13;
       process_actions(p_xfr_payroll_action_id => p_xfr_payroll_action_id
                      ,p_xfr_action_id         => ln_child_xfr_action_id
                      ,p_pre_pay_action_id     => ln_asg_action_id
                      ,p_payment_action_id     => ln_run_action_id
                      ,p_rqp_action_id         => ln_run_action_id
                      ,p_seperate_check_flag   => 'Y'
                      ,p_sepcheck_run_type_id  => p_sepchk_run_type_id
                      ,p_action_type           => p_master_action_type
                      ,p_legislation_code      => p_legislation_code
                      ,p_assignment_id         => ln_assignment_id
                      ,p_tax_unit_id           => ln_tax_unit_id
                      ,p_curr_pymt_eff_date    => p_curr_pymt_eff_date
                      ,p_xfr_start_date        => ld_start_date
                      ,p_xfr_end_date          => ld_end_date
                      ,p_ppp_source_action_id  => ln_run_action_id
                      );

     end loop;
     hr_utility.set_location(gv_package || lv_procedure_name, 120);

     ln_step := 14;
     if ((pay_emp_action_arch.gv_multi_payroll_pymt = 'N' or
          pay_emp_action_arch.gv_multi_payroll_pymt is null) and
          pay_ac_action_arch.gv_multi_gre_payment = 'Y' ) then
        close c_asg_child_action;
     else
        close c_multi_asg_child_action;
     end if;
     hr_utility.set_location('Leaving create_child_actions ',130 );

  EXCEPTION
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

  END create_child_actions;

  /************************************************************
   Name      : py_achive_data
   Purpose   : This performs the CA specific employee context
               setting for the Tax Remittance Archiver and
               for the payslip,check writer and
               Deposit Advice modules.
   Arguments :
   Notes     :
  ************************************************************/
  PROCEDURE py_archive_data( p_xfr_action_id  in number
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

   cursor c_sepchk_run_type is
   select prt.run_type_id
    from pay_run_types_f prt
   where prt.shortname = 'SEP_PAY'
     and prt.legislation_code = 'CA';

    cursor c_assignment_run (cp_prepayment_action_id in number) is
      select distinct paa.assignment_id
        from pay_action_interlocks pai,
             pay_assignment_actions paa,
             pay_payroll_actions ppa
       where pai.locking_action_id = cp_prepayment_action_id
         and paa.assignment_action_id = pai.locked_action_id
         and ppa.payroll_action_id = paa.payroll_action_id
         and ppa.action_type in ('R', 'Q', 'B')
         and ((ppa.run_type_id is null and
               paa.source_action_id is null) or
              (ppa.run_type_id is not null and
               paa.source_action_id is not null))
         and ppa.action_status = 'C';

    cursor c_master_run_action(
                      cp_prepayment_action_id in number,
                      cp_assignment_id        in number) is
      select paa.assignment_action_id, paa.payroll_action_id,
             ppa.action_type
        from pay_payroll_actions ppa,
             pay_assignment_actions paa,
             pay_action_interlocks pai
        where pai.locking_action_Id =  cp_prepayment_action_id
          and pai.locked_action_id = paa.assignment_action_id
          and paa.assignment_id = cp_assignment_id
          and paa.source_action_id is null
          and ppa.payroll_action_id = paa.payroll_action_id
        order by paa.assignment_action_id desc;

    cursor c_pymt_eff_date(cp_prepayment_action_id in number) is
      select effective_date
        from pay_payroll_actions ppa,
             pay_assignment_actions paa
       where ppa.payroll_action_id = paa.payroll_action_id
         and paa.assignment_action_id = cp_prepayment_action_id;

    cursor c_check_pay_action( cp_payroll_action_id in number) is
      select count(*)
        from pay_action_information
       where action_context_id = cp_payroll_action_id
         and action_context_type = 'PA';

    /* Added new cursor to archive multiple balance adjustments done
       with same effective date, 'B'.  Bug#3498653 */

       cursor c_get_emp_adjbal(cp_xfr_action_id number) IS
       select locked_action_id
       from pay_action_interlocks
       where locking_action_id = cp_xfr_action_id;

    /* Added this cursor to get the run action type, so that
       if it is reversals 'V' then we will not call the
       create_child_action procedures, to avoid creating
       unnecessary child actions.  Bug#3498653  */

      cursor c_master_run_action_type(
                      cp_prepayment_action_id in number,
                      cp_assignment_id        in number) is
      select distinct ppa.action_type
        from pay_payroll_actions ppa,
             pay_assignment_actions paa,
             pay_action_interlocks pai
        where pai.locking_action_Id =  cp_prepayment_action_id
          and pai.locked_action_id = paa.assignment_action_id
          and paa.assignment_id = cp_assignment_id
          and paa.source_action_id is null
          and ppa.payroll_action_id = paa.payroll_action_id
          and ppa.action_type <> 'V';

    ld_curr_pymt_eff_date     DATE;
    ln_sepchk_run_type_id     NUMBER;
    lv_legislation_code       VARCHAR2(2);

    ln_xfr_master_action_id   NUMBER;

    ln_tax_unit_id            NUMBER;
    ln_xfr_payroll_action_id  NUMBER; /* of current xfr */
    ln_assignment_id          NUMBER;
    ln_chunk_number           NUMBER;

    lv_xfr_master_serial_number  VARCHAR2(30);

    lv_master_action_type     VARCHAR2(1);
    lv_master_sepcheck_flag   VARCHAR2(1);
    ln_asg_action_id          NUMBER;

    ln_master_run_action_id   NUMBER;
    ln_master_run_pact_id     NUMBER;
    lv_master_run_action_type VARCHAR2(1);

    ln_pymt_balcall_aaid       NUMBER;
    ln_pay_action_count        NUMBER;

    ld_start_date             DATE;
    ld_end_date               DATE; /* End date of current xfr from ppa */
    ln_business_group_id      NUMBER;
    ln_cons_set_id       NUMBER;
    ln_payroll_id        NUMBER;

    lv_error_message          VARCHAR2(500);
    lv_procedure_name         VARCHAR2(100);
    ln_step                   NUMBER;
    ln_tax_group_id           NUMBER;
    ln_tax_unit_id_context    NUMBER;
    lv_run_action_type        VARCHAR2(10);

  BEGIN

     lv_procedure_name := '.action_archive_data';
     pay_emp_action_arch.gv_error_message := NULL;
     hr_utility.trace('Entered py_archive_data');
     hr_utility.trace('p_xfr_action_id '||to_char(p_xfr_action_id));
     hr_utility.trace('Cursor c_xfr_info');

     ln_step := 1;
     open c_xfr_info (p_xfr_action_id);
     fetch c_xfr_info into ln_xfr_payroll_action_id,
                           ln_xfr_master_action_id,
                           ln_assignment_id,
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

    ln_step := 200;
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
     open c_sepchk_run_type;
     fetch  c_sepchk_run_type into ln_sepchk_run_type_id;
     if c_sepchk_run_type%notfound then
        hr_utility.set_location(gv_package || lv_procedure_name, 20);
        hr_utility.raise_error;
     end if;
     close c_sepchk_run_type;

     ln_step := 5;
     -- process the master_action
     lv_master_action_type   := substr(lv_xfr_master_serial_number,1,1);
     -- Always N for Master Assignment Action
     lv_master_sepcheck_flag := substr(lv_xfr_master_serial_number,2,1);
     -- Assignment Action of Quick Pay Pre Payment, Pre Payment, Reversal
     ln_asg_action_id := substr(lv_xfr_master_serial_number,3);

     ln_step := 6;
     open c_pymt_eff_date(ln_asg_action_id);
     fetch c_pymt_eff_date into ld_curr_pymt_eff_date;
     if c_pymt_eff_date%notfound then
        hr_utility.trace('PayrollAction for InterfaceProcess NotFound');
        hr_utility.raise_error;
     end if;
     close c_pymt_eff_date;

     ln_step := 7;
     hr_utility.trace('End Date=' || to_char(ld_end_date, 'dd-mon-yyyy'));
     hr_utility.trace('Start Date='||to_char(ld_start_date, 'dd-mon-yyyy'));
     hr_utility.trace('Business Group Id='||to_char(ln_business_group_id));
     hr_utility.trace('Serial Number='||lv_xfr_master_serial_number);
     hr_utility.trace('ln_xfr_payroll_action_id ='||
                       to_char(ln_xfr_payroll_action_id));

     if lv_master_action_type in ( 'P','U') then
        /************************************************************
        ** For Master Pre Payment Action of Multi GRE
        ** Archive the data seperately for all different GREs.
        *************************************************************/
           lv_run_action_type := Null;
           open c_master_run_action_type(ln_asg_action_id,ln_assignment_id);
           fetch c_master_run_action_type into lv_run_action_type;
             hr_utility.trace('lv_run_action_type ='||lv_run_action_type);

        if pay_ac_action_arch.gv_reporting_level = 'TAXGRP' then
           /* Added this validation to avoid creating child assignment actions,
              when reversals to be picked up based on Pre-payments. Reversals
              are archived directly based on run actions. Bug#3498653 */

           if c_master_run_action_type%found then

              create_child_act_for_taxgrp(
                  p_xfr_payroll_action_id    => ln_xfr_payroll_action_id
                  ,p_master_xfr_action_id    => p_xfr_action_id
                  ,p_master_prepay_action_id => ln_asg_action_id
                  ,p_master_action_type      => lv_master_action_type
                  ,p_sepchk_run_type_id      => ln_sepchk_run_type_id
                  ,p_legislation_code        => lv_legislation_code
                  ,p_assignment_id           => ln_assignment_id
                  ,p_tax_unit_id             => ln_tax_unit_id -- TXUNTID
                  ,p_curr_pymt_eff_date      => ld_curr_pymt_eff_date
                  ,p_xfr_start_date          => ld_start_date
                  ,p_xfr_end_date            => ld_end_date
                  ,p_chunk                   => ln_chunk_number
                  );
           else
              hr_utility.trace('Dont create child actions for Reversals: '||
                                'py_archive_date Tax Gruop level');
              null;

           end if; -- c_master_run_action_type%found
           close c_master_run_action_type;

        else
           /* Added this validation to avoid creating child assignment actions
              when reversals to be picked up based on Pre-payments. Reversals
              are archived directly based on run actions. Bug#3498653 */
            if c_master_run_action_type%found then

               create_child_actions_for_gre(
                  p_xfr_payroll_action_id    => ln_xfr_payroll_action_id
                  ,p_master_xfr_action_id    => p_xfr_action_id
                  ,p_master_prepay_action_id => ln_asg_action_id
                  ,p_master_action_type      => lv_master_action_type
                  ,p_sepchk_run_type_id      => ln_sepchk_run_type_id
                  ,p_legislation_code        => lv_legislation_code
                  ,p_assignment_id           => ln_assignment_id
                  ,p_curr_pymt_eff_date      => ld_curr_pymt_eff_date
                  ,p_xfr_start_date          => ld_start_date
                  ,p_xfr_end_date            => ld_end_date
                  ,p_chunk                   => ln_chunk_number
                  );
            else
              hr_utility.trace('Dont create child actions for Reversals: '||
                                'py_archive_date GRE level');
              null;
            end if; -- c_master_run_action_type%found
            close c_master_run_action_type;

        end if; -- gv_reporting_level = 'TAXGRP'

--        if ( ( pay_ac_action_arch.gv_multi_gre_payment = 'N' ) and
--             ( pay_emp_action_arch.gv_multi_payroll_pymt = 'N' or
--               pay_emp_action_arch.gv_multi_payroll_pymt is null ) ) then

--           create_chld_act_for_multi_gre(
--                  p_xfr_payroll_action_id    => ln_xfr_payroll_action_id
--                  ,p_master_xfr_action_id    => p_xfr_action_id
--                  ,p_master_prepay_action_id => ln_asg_action_id
--                  ,p_master_action_type      => lv_master_action_type
--                  ,p_sepchk_run_type_id      => ln_sepchk_run_type_id
--                  ,p_legislation_code        => lv_legislation_code
--                  ,p_assignment_id           => ln_assignment_id
--                  ,p_curr_pymt_eff_date      => ld_curr_pymt_eff_date
--                  ,p_xfr_start_date          => ld_start_date
--                  ,p_xfr_end_date            => ld_end_date
--                  ,p_chunk                   => ln_chunk_number
--                  );


--        else
--           /************************************************************
--           ** For Master Pre Payment Action get the distinct
--           ** Assignment_ID's and archive the data seperately for
--           ** all the assigments.
--           *************************************************************/
--           ln_step := 8;
--           open c_assignment_run(ln_asg_action_id);
--           loop
--              fetch c_assignment_run into ln_assignment_id;
--              if c_assignment_run%notfound then
--                 exit;
--              end if;
--
--              ln_step := 9;
--              open c_master_run_action(ln_asg_action_id,
--                                       ln_assignment_id);
--              fetch c_master_run_action into ln_master_run_action_id,
--                                             ln_master_run_pact_id,
--                                             lv_master_run_action_type;
--              if c_master_run_action%notfound then
--                 hr_utility.raise_error;
--              end if;
--              close c_master_run_action;
--
--              ln_step := 10;
--              if lv_master_run_action_type in ('R', 'Q') then
--                 ln_pymt_balcall_aaid := ln_master_run_action_id;
--              else
--                 ln_pymt_balcall_aaid := ln_asg_action_id;
--              end if;

              -- call fuction to process the actions
--              ln_step := 11;
--              process_actions(
--                          p_xfr_payroll_action_id => ln_xfr_payroll_action_id
--                         ,p_xfr_action_id         => p_xfr_action_id
--                         ,p_pre_pay_action_id     => ln_asg_action_id
--                         ,p_payment_action_id     => ln_pymt_balcall_aaid
--                         ,p_rqp_action_id         => ln_asg_action_id
--                         ,p_seperate_check_flag   => lv_master_sepcheck_flag
--                         ,p_sepcheck_run_type_id  => ln_sepchk_run_type_id
--                         ,p_action_type           => lv_master_action_type
--                         ,p_legislation_code      => lv_legislation_code
--                         ,p_assignment_id         => ln_assignment_id
--                         ,p_tax_unit_id           => ln_tax_unit_id
--                         ,p_curr_pymt_eff_date    => ld_curr_pymt_eff_date
--                         ,p_xfr_start_date        => ld_start_date
--                         ,p_xfr_end_date          => ld_end_date
--                         );
--           end loop;
--           close c_assignment_run;

--        end if;

--        /************************************************************
--        ** If Action is Pre Payment, then create child records for
--        ** Seperate Check Runs.
--        *************************************************************/
--        ln_step := 12;
--        create_child_actions(
--                 p_xfr_payroll_action_id   => ln_xfr_payroll_action_id
--                ,p_master_xfr_action_id    => ln_xfr_master_action_id
--                ,p_master_prepay_action_id => ln_asg_action_id
--                ,p_master_action_type      => lv_master_action_type
--                ,p_curr_pymt_eff_date      => ld_curr_pymt_eff_date
--                ,p_sepchk_run_type_id      => ln_sepchk_run_type_id
--                ,p_legislation_code        => lv_legislation_code
--                ,p_chunk                   => ln_chunk_number);

     end if;

     ln_step := 13;
     if lv_master_action_type  = 'V' then
        /* ln_asg_action_id is nothing but reversal run action id */
        ln_pymt_balcall_aaid := ln_asg_action_id ;
        hr_utility.trace('Reversal ln_pymt_balcall_aaid'
               ||to_char(ln_pymt_balcall_aaid));
        /* Added this code to archive the tax balances and other elements
           for reversals in Canada. Bug#3498653 */
         ln_step := 14;
         pay_ac_action_arch.initialization_process;

         hr_utility.trace('Populating Tax Balances for Reversals');
         hr_utility.trace('ln_tax_unit_id : '||to_char(ln_tax_unit_id));
         hr_utility.trace('ln_pymt_balcall_aaid :'||to_char(ln_pymt_balcall_aaid));
         hr_utility.trace('ld_curr_pymt_eff_date :'||to_char(ld_curr_pymt_eff_date,'DD-MON-YYYY'));
         hr_utility.trace('ln_assignment_id :'||to_char(ln_assignment_id));

         /* Added this to support tax group level reporting for
            Reversals.  Need to set both contexts for
            Tax Group reporting because for current amounts we
            use GRE context and for YTD amounts we use Tax_Group
            context */
         if pay_ac_action_arch.gv_reporting_level = 'TAXGRP' then
            ln_tax_group_id := get_taxgroup_val(
                                        p_tax_unit_id   => ln_tax_unit_id,
                                        p_assignment_id => ln_assignment_id,
                                        p_asg_act_id    =>ln_pymt_balcall_aaid);
            pay_balance_pkg.set_context('TAX_GROUP', ln_tax_group_id);
            gn_taxgrp_gre_id := ln_tax_group_id;

            ln_tax_unit_id_context := -1;
            ln_tax_unit_id_context := get_context_val(
                              p_context_name  => 'TAX_UNIT_ID'
                            , p_assignment_id => ln_assignment_id
                            , p_asg_act_id    => ln_pymt_balcall_aaid);
            if ((ln_tax_unit_id_context = -1) or
                     (ln_tax_unit_id_context is null)) then
               pay_balance_pkg.set_context('TAX_UNIT_ID', ln_tax_unit_id);
            end if;

         elsif pay_ac_action_arch.gv_reporting_level = 'GRE' then
            ln_tax_unit_id_context := -1;
            ln_tax_unit_id_context := get_context_val(
                              p_context_name  => 'TAX_UNIT_ID'
                            , p_assignment_id => ln_assignment_id
                            , p_asg_act_id    => ln_pymt_balcall_aaid);
            gn_taxgrp_gre_id := ln_tax_unit_id_context;

            if ((ln_tax_unit_id_context = -1) or
                     (ln_tax_unit_id_context is null)) then
               pay_balance_pkg.set_context('TAX_UNIT_ID', ln_tax_unit_id);
               gn_taxgrp_gre_id := ln_tax_unit_id;
            end if;
         end if;

         ln_step := 15;
         populate_fed_prov_bal( p_xfr_action_id     => p_xfr_action_id
                           ,p_assignment_id     => ln_assignment_id
                           ,p_pymt_balcall_aaid => ln_pymt_balcall_aaid
                           ,p_tax_unit_id       => ln_tax_unit_id
                           ,p_action_type       => lv_master_action_type
                           ,p_pymt_eff_date     => ld_curr_pymt_eff_date
                           ,p_start_date        => ld_start_date
                           ,p_end_date          => ld_end_date
                           ,p_ytd_balcall_aaid  => ln_pymt_balcall_aaid
                         );

         ln_step := 16;
         hr_utility.trace('Populating Current Elements for Reversals');
         pay_ac_action_arch.get_current_elements(
               p_xfr_action_id       => p_xfr_action_id
              ,p_curr_pymt_action_id => ln_pymt_balcall_aaid
              ,p_curr_pymt_eff_date  => ld_curr_pymt_eff_date
              ,p_assignment_id       => ln_assignment_id
              ,p_tax_unit_id         => ln_tax_unit_id
              ,p_pymt_balcall_aaid   => ln_pymt_balcall_aaid
              ,p_ytd_balcall_aaid    => ln_pymt_balcall_aaid
              ,p_sepchk_run_type_id  => ln_sepchk_run_type_id
              ,p_sepchk_flag         => lv_master_sepcheck_flag
              ,p_legislation_code    => lv_legislation_code
              ,p_action_type         => lv_master_action_type);

         hr_utility.trace('Done Populating Tax Balances for Reversals');
         ln_step := 17;
         pay_emp_action_arch.insert_rows_thro_api_process(
                  p_action_context_id  => p_xfr_action_id
                 ,p_action_context_type=> 'AAP'
                 ,p_assignment_id      => ln_assignment_id
                 ,p_tax_unit_id        => ln_tax_unit_id
                 ,p_curr_pymt_eff_date => ld_curr_pymt_eff_date
                 ,p_tab_rec_data       => pay_ac_action_arch.lrr_act_tab
                 );

     end if; -- lv_master_action_type = 'V'


     /* Added this to archive the Balance Adjustments for the
        Payslip Archiver, this will be useful for historical reporting
        purposes when run_results table is purged. Bug#3498653 */

     if lv_master_action_type  = 'B' then
         hr_utility.trace('Populating Current Elements for Balance Adjustments');
        /* ln_asg_action_id is nothing but Balance Adjustment run action id */
        ln_asg_action_id := -1;
        pay_ac_action_arch.initialization_process;
        open c_get_emp_adjbal(p_xfr_action_id);
        loop
          fetch c_get_emp_adjbal into ln_asg_action_id;
          exit when c_get_emp_adjbal%NOTFOUND;

          ln_pymt_balcall_aaid := ln_asg_action_id ;
          hr_utility.trace('Bal Adjustment ln_pymt_balcall_aaid'
               ||to_char(ln_pymt_balcall_aaid));

          ln_step := 18;

          hr_utility.trace('ln_tax_unit_id : '||to_char(ln_tax_unit_id));
          hr_utility.trace('ln_pymt_balcall_aaid :'||to_char(ln_pymt_balcall_aaid));
          hr_utility.trace('ld_curr_pymt_eff_date :'||to_char(ld_curr_pymt_eff_date,'DD-MON-YYYY'));
          hr_utility.trace('ln_assignment_id :'||to_char(ln_assignment_id));

         /* Added this to support tax group level reporting for
            Balance Adjustments.  Need to set both contexts for
            Tax Group reporting because for current amounts we
            use GRE context and for YTD amounts we use Tax_Group
            context */

          if pay_ac_action_arch.gv_reporting_level = 'TAXGRP' then
            ln_tax_group_id := get_taxgroup_val(
                                        p_tax_unit_id   => ln_tax_unit_id,
                                        p_assignment_id => ln_assignment_id,
                                        p_asg_act_id    =>ln_pymt_balcall_aaid);
            pay_balance_pkg.set_context('TAX_GROUP', ln_tax_group_id);
            gn_taxgrp_gre_id := ln_tax_group_id;

            ln_tax_unit_id_context := -1;
            ln_tax_unit_id_context := get_context_val(
                              p_context_name  => 'TAX_UNIT_ID'
                            , p_assignment_id => ln_assignment_id
                            , p_asg_act_id    => ln_pymt_balcall_aaid);

            if ((ln_tax_unit_id_context = -1) or
                     (ln_tax_unit_id_context is null)) then
               pay_balance_pkg.set_context('TAX_UNIT_ID', ln_tax_unit_id);
            end if;

          elsif pay_ac_action_arch.gv_reporting_level = 'GRE' then
            ln_tax_unit_id_context := -1;
            ln_tax_unit_id_context := get_context_val(
                              p_context_name  => 'TAX_UNIT_ID'
                            , p_assignment_id => ln_assignment_id
                            , p_asg_act_id    => ln_pymt_balcall_aaid);
            gn_taxgrp_gre_id := ln_tax_unit_id_context;

            if ((ln_tax_unit_id_context = -1) or
                     (ln_tax_unit_id_context is null)) then
               pay_balance_pkg.set_context('TAX_UNIT_ID', ln_tax_unit_id);
               gn_taxgrp_gre_id := ln_tax_unit_id;
            end if;
          end if; -- gv_reporting_level = 'TAXGRP'

          /* Need to pass Payslip Archiver Assignment_Action_id to
           p_curr_pymt_action_id because we have to archive Bal Adjustments
           that are not marked for 'Pre-Payment' in canada, Otherwise nothing
           will be archived. */

          if ln_asg_action_id <> -1 and ln_asg_action_id is not null then
             ln_step := 19;
             pay_ac_action_arch.get_current_elements(
               p_xfr_action_id       => p_xfr_action_id
              ,p_curr_pymt_action_id => p_xfr_action_id
              ,p_curr_pymt_eff_date  => ld_curr_pymt_eff_date
              ,p_assignment_id       => ln_assignment_id
              ,p_tax_unit_id         => ln_tax_unit_id
              ,p_pymt_balcall_aaid   => ln_pymt_balcall_aaid
              ,p_ytd_balcall_aaid    => ln_pymt_balcall_aaid
              ,p_sepchk_run_type_id  => ln_sepchk_run_type_id
              ,p_sepchk_flag         => lv_master_sepcheck_flag
              ,p_legislation_code    => lv_legislation_code
              ,p_action_type         => lv_master_action_type);
          end if;
         end loop;
         close c_get_emp_adjbal;

         ln_step := 20;
         pay_emp_action_arch.insert_rows_thro_api_process(
                  p_action_context_id  => p_xfr_action_id
                 ,p_action_context_type=> 'AAP'
                 ,p_assignment_id      => ln_assignment_id
                 ,p_tax_unit_id        => ln_tax_unit_id
                 ,p_curr_pymt_eff_date => ld_curr_pymt_eff_date
                 ,p_tab_rec_data       => pay_ac_action_arch.lrr_act_tab
                 );

     end if; -- master_action_type = 'B'
     /* End of Balance Adjustments archiving Bug#3498653 */

     /****************************************************************
     ** Archive all the payroll action level data once only when
     ** chunk number is 1. Also check if this has not been archived
     ** earlier
     *****************************************************************/
     ln_step := 21;
     hr_utility.set_location(gv_package || lv_procedure_name,210);
     open c_check_pay_action( ln_xfr_payroll_action_id);
     fetch c_check_pay_action into ln_pay_action_count;
     close c_check_pay_action;
     if ln_pay_action_count = 0 then
        hr_utility.set_location(gv_package || lv_procedure_name,215);
        ln_step := 22;
        if ln_chunk_number = 1 then
           pay_emp_action_arch.arch_pay_action_level_data(
                               p_payroll_action_id => ln_xfr_payroll_action_id
                              ,p_payroll_id        => ln_payroll_id
                              ,p_effective_Date    => ld_end_date
                              );
        end if;

     end if;

  EXCEPTION
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

  END py_archive_data;

  /******************************************************************
   Name      : py_range_cursor
   Purpose   : This returns the select statement that is used to created the
               range rows for the Canadian Payroll Archiver.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ******************************************************************/
  PROCEDURE py_range_cursor( p_payroll_action_id in number
                            ,p_sqlstr           out nocopy varchar2)
  IS

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_cons_set_id       NUMBER;
    ln_payroll_id        NUMBER;

    lv_sql_string  VARCHAR2(32000);

    lv_error_message          VARCHAR2(500);
    lv_procedure_name         VARCHAR2(100);
    ln_step                   NUMBER;

  begin

 lv_procedure_name := '.py_range_cursor';
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     pay_emp_action_arch.gv_error_message := NULL;

     ln_step := 1;
     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_cons_set_id       => ln_cons_set_id
                            ,p_payroll_id        => ln_payroll_id);
     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     ln_step := 2;
      /* removed the reversal validation from range cursor SQL STMT
        ''V'', nvl(ppa.future_process_mode, ''Y''). Bug#3498653 */
      lv_sql_string :=
         'select distinct paa.assignment_id
            from pay_assignment_actions paa,
                 pay_payroll_actions ppa
           where ppa.business_group_id  = ''' || ln_business_group_id || '''
             and  ppa.effective_date between fnd_date.canonical_to_date(''' ||
             fnd_date.date_to_canonical(ld_start_date) || ''')
                                         and fnd_date.canonical_to_date(''' ||
             fnd_date.date_to_canonical(ld_end_date) || ''')
             and ppa.action_type in (''U'',''P'',''B'',''V'')
             and decode(ppa.action_type,
                 ''B'', nvl(ppa.future_process_mode, ''Y''),
                 ''N'') = ''N''
             and ppa.action_status =''C''
             and ppa.consolidation_set_id = ''' || ln_cons_set_id || '''
             and ppa.payroll_id  = ''' || ln_payroll_id || '''
             and ppa.payroll_action_id = paa.payroll_action_id
             and paa.action_status = ''C''
             and paa.source_action_id is null
             and not exists
                 (select ''x''
                    from pay_action_interlocks pai,
                         pay_assignment_actions paa1,
                         pay_payroll_actions ppa1
                   where pai.locked_action_id = paa.assignment_action_id
                   and paa1.assignment_action_id = pai.locking_action_id
                   and ppa1.payroll_action_id = paa1.payroll_action_id
                   and ppa1.action_type =''X''
                   and ppa1.report_type = ''PY_ARCHIVER'')
            and :payroll_action_id > 0
          order by paa.assignment_id';

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     ln_step := 3;
     p_sqlstr := lv_sql_string;
     hr_utility.set_location(gv_package || lv_procedure_name, 50);

  EXCEPTION
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

  END py_range_cursor;


  /************************************************************
   Name      : py_action_creation
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the Archiver process.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/

  PROCEDURE py_action_creation(
                    p_payroll_action_id   in number
                   ,p_start_assignment_id in number
                   ,p_end_assignment_id   in number
                   ,p_chunk               in number)
  IS
   /* removed the reversal validation in the decode stmt in cursor
      c_get_xfr_emp  'V', nvl(ppa.future_process_mode, 'Y'). Bug#3498653 */
   cursor c_get_xfr_emp( cp_start_assignment_id   in number
                        ,cp_end_assignment_id     in number
                        ,cp_cons_set_id           in number
                        ,cp_payroll_id            in number
                        ,cp_business_group_id     in number
                        ,cp_start_date            in date
                        ,cp_end_date              in date
                        ) is
     select /*+ INDEX (PAA PAY_ASSIGNMENT_ACTIONS_N50) */
            paa.assignment_id,
            paa.tax_unit_id,
            ppa.effective_date,
            ppa.date_earned,
            ppa.action_type,
            paa.assignment_action_id,
            paa.payroll_action_id
       from pay_payroll_actions ppa,
            pay_assignment_actions paa
     where paa.assignment_id between cp_start_assignment_id
                                 and cp_end_assignment_id
       and ppa.consolidation_set_id = cp_cons_set_id
       and paa.action_status = 'C'
       and ppa.payroll_id = cp_payroll_id
       and ppa.payroll_action_id = paa.payroll_action_id
       and ppa.business_group_id  = cp_business_group_id
       and ppa.action_status = 'C'
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
             and ppa1.report_type = 'PY_ARCHIVER')
      order by 1,2,3,4,5;

   cursor c_master_action(cp_prepayment_action_id number) is
     select max(paa.assignment_action_id)
       from pay_payroll_actions ppa,
            pay_assignment_actions paa,
            pay_action_interlocks pai
      where pai.locking_action_Id =  cp_prepayment_action_id
        and pai.locked_action_id = paa.assignment_action_id
        and paa.source_action_id is null
        and ppa.payroll_action_id = paa.payroll_action_id
        and ppa.action_type in ('R', 'Q');

  cursor c_lock_chld_pp_aa(cp_prepay_master_aa_id number) is
    select paa.assignment_action_id
      from pay_assignment_actions paa
     where paa.source_action_id = cp_prepay_master_aa_id;

    ln_assignment_id        NUMBER;
    ln_tax_unit_id          NUMBER;
    ld_effective_date       DATE;
    ld_date_earned          DATE;
    lv_action_type          VARCHAR2(10);
    ln_asg_action_id        NUMBER;
    ln_payroll_action_id    NUMBER;

    ln_master_action_id     NUMBER;

    ld_end_date             DATE;
    ld_start_date           DATE;
    ln_business_group_id    NUMBER;
    ln_cons_set_id          NUMBER;
    ln_payroll_id           NUMBER;

    ln_prev_asg_action_id   NUMBER;
    ln_prev_assignment_id   NUMBER;
    ln_prev_tax_unit_id     NUMBER;
    ld_prev_effective_date  DATE;

    ln_xfr_action_id        NUMBER;

    lv_serial_number        VARCHAR2(30);

    lv_error_message          VARCHAR2(500);
    lv_procedure_name         VARCHAR2(100);
    ln_step                   NUMBER;

  BEGIN

---     hr_utility.trace_on(null, 'PYARCH');

     lv_procedure_name       := '.py_action_creation';
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     pay_emp_action_arch.gv_error_message := NULL;

     ln_step := 1;
     /* Initialising local variables to avoid GSCC warnings */
     ln_assignment_id      := 0;
     ln_tax_unit_id        := 0;
     ld_effective_date     := to_date('1900/12/31','YYYY/MM/DD');
     ln_asg_action_id      := 0;
     ln_payroll_action_id  := 0;

     ln_master_action_id   := 0;
     ln_prev_asg_action_id := 0;
     ln_prev_assignment_id := 0;
     ln_prev_tax_unit_id   := 0;
     ld_prev_effective_date := to_date('1800/12/31','YYYY/MM/DD');

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_cons_set_id       => ln_cons_set_id
                            ,p_payroll_id        => ln_payroll_id);
     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     hr_utility.trace('ld_start_date '||ld_start_date);
     hr_utility.trace('ld_end_date '||ld_end_date);
     hr_utility.trace('ln_business_group_id '||ln_business_group_id);
     hr_utility.trace('ln_cons_set_id '||ln_cons_set_id);
     hr_utility.trace('ln_payroll_id '||ln_payroll_id);


     ln_step := 2;
     open c_get_xfr_emp( p_start_assignment_id
                        ,p_end_assignment_id
                        ,ln_cons_set_id
                        ,ln_payroll_id
                        ,ln_business_group_id
                        ,ld_start_date
                        ,ld_end_date);

     -- Loop for all rows returned for SQL statement.
     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     loop
        ln_step := 3;
        fetch c_get_xfr_emp into ln_assignment_id,
                                 ln_tax_unit_id,
                                 ld_effective_date,
                                 ld_date_earned,
                                 lv_action_type,
                                 ln_asg_action_id,
                                 ln_payroll_action_id;

        exit when c_get_xfr_emp%notfound;

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
        ln_step := 4;
        if ln_assignment_id = ln_prev_assignment_id and
           ln_tax_unit_id = ln_prev_tax_unit_id and
           ld_effective_date = ld_prev_effective_date and
           lv_action_type = 'B' and
           ln_asg_action_id <> ln_prev_asg_action_id then

           ln_step := 5;
           hr_utility.set_location(gv_package || lv_procedure_name, 50);
           hr_utility.trace('Locking Action = ' || ln_xfr_action_id);
           hr_utility.trace('Locked Action = '  || ln_asg_action_id);
           hr_nonrun_asact.insint(ln_xfr_action_id
                                 ,ln_asg_action_id);
        else
           hr_utility.set_location(gv_package || lv_procedure_name, 60);
           hr_utility.trace('Action_type = '||lv_action_type );

           ln_step := 6;
           select pay_assignment_actions_s.nextval
             into ln_xfr_action_id
             from dual;

           -- insert into pay_assignment_actions.
           ln_step := 7;
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
           ln_step := 8;
           hr_nonrun_asact.insint(ln_xfr_action_id,
                                  ln_asg_action_id);

           hr_utility.set_location(gv_package || lv_procedure_name, 90);

           for lock_pp_aa in c_lock_chld_pp_aa(ln_asg_action_id)
           loop

             hr_utility.trace('Locked Action by Master = '  ||
                               lock_pp_aa.assignment_action_id);
             hr_nonrun_asact.insint(ln_xfr_action_id,
                                    lock_pp_aa.assignment_action_id);

           end loop;

           /********************************************************
           ** For Balance Adj we put only the first assignment action
           ********************************************************/
           lv_serial_number := lv_action_type || 'N' ||
                               ln_asg_action_id;

           ln_step := 9;
           update pay_assignment_actions
              set serial_number = lv_serial_number
            where assignment_action_id = ln_xfr_action_id;

           hr_utility.set_location(gv_package || lv_procedure_name, 100);

        end if ; --ln_assignment_id ...

        ln_step := 10;
        ln_prev_tax_unit_id    := ln_tax_unit_id;
        ld_prev_effective_date := ld_effective_date;
        ln_prev_assignment_id  := ln_assignment_id;
        ln_prev_asg_action_id  := ln_asg_action_id;

     end loop;
     close c_get_xfr_emp;

  EXCEPTION
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

  END py_action_creation;

  /************************************************************
    Name      : py_archinit
    Purpose   : This performs the context initialization.
    Arguments :
    Notes     :
  ************************************************************/

  PROCEDURE py_archinit(p_payroll_action_id in number) is

  cursor cur_reporting_level(p_pactid in number) is
  select org_information1
  from   hr_organization_information hoi,
         pay_payroll_actions ppa
  where  ppa.payroll_action_id       = p_pactid
  and    hoi.organization_id         = ppa.business_group_id
  and    hoi.org_information_context = 'Payroll Archiver Level';

  cursor cur_def_bal is
  select pbt.balance_name,
         decode(pbt.balance_name,
                                  'CPP EE Withheld', 1,
                                  'QPP EE Withheld', 2,
                                  'EI EE Withheld',  3,
				  'PPIP EE Withheld',4,
                                  'FED Withheld',    5,
                                  'PROV Withheld',   6,
                                  7) display_sequence,
         pbt.balance_type_id
  from   pay_balance_types pbt
  where pbt.legislation_code = 'CA'
  and   pbt.balance_name in ( 'FED Withheld',
                              'CPP EE Withheld',
                              'EI EE Withheld',
                              'PROV Withheld',
                              'QPP EE Withheld',
			      'PPIP EE Withheld')
  order by 2;

  cursor cur_tax_name is
  select language, lookup_code, meaning
  from   fnd_lookup_values
  where   lookup_type = 'CA_SOE_SHORT_NAME';

  cursor cur_mg_payment is
    select rule_mode
    from   pay_legislation_rules
    where  legislation_code = 'CA'
    and    rule_type        = 'MULTI_TAX_UNIT_PAYMENT';

  cursor cur_bal_type is
    select balance_name,
           balance_type_id
    from   pay_balance_types
    where  legislation_code = 'CA'
    and    balance_name     in ( 'Gross Earnings', 'Payments' );


  ln_pymt_def_bal_id     number;
  ln_gre_ytd_def_bal_id  number;
  ln_tg_ytd_def_bal_id   number;
  lv_reporting_level     varchar2(30);
  lv_jd_pymt_dimension   varchar2(100);
  lv_pymt_dimension      varchar2(100);
  /* Added new variable for canada reversals. Bug#3498653 */
  ln_run_def_bal_id      number;

  lv_error_message          VARCHAR2(500);
  lv_procedure_name         VARCHAR2(100);
  ln_step                   NUMBER;

  ln_run_bal_type_id     number;
  lv_balance_name        varchar2(100);

  i   number;
  j   number;

  BEGIN
    lv_procedure_name       := '.py_archinit';
    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    pay_emp_action_arch.gv_error_message := NULL;
    lv_reporting_level := Null;
    i := 0;
    j := 0;

    ln_step := 5;
    open  cur_mg_payment;
    fetch cur_mg_payment into pay_ac_action_arch.gv_multi_gre_payment;
    if cur_mg_payment%notfound then
       pay_ac_action_arch.gv_multi_gre_payment := 'N';
    end if;
    close cur_mg_payment;

    ln_step := 6;
    open  cur_bal_type;
    loop
       fetch cur_bal_type into lv_balance_name, ln_run_bal_type_id;
       exit when cur_bal_type%notfound;
       if lv_balance_name = 'Payments' then
          gn_payments_def_bal_id :=
             nvl(pay_emp_action_arch.get_defined_balance_id(
                                             ln_run_bal_type_id,
                                             '_ASG_RUN',
                                             'CA'),-1);
       else
          gn_gross_earn_def_bal_id :=
             nvl(pay_emp_action_arch.get_defined_balance_id(
                                             ln_run_bal_type_id,
                                             '_ASG_RUN',
                                             'CA'),-1);
       end if;
    end loop;
    close cur_bal_type;


    ln_step := 10;
    open  cur_reporting_level(p_payroll_action_id);
    fetch cur_reporting_level into lv_reporting_level;
    if cur_reporting_level%notfound then
       lv_reporting_level := 'GRE';
    end if;
    close cur_reporting_level;

    pay_ac_action_arch.gv_reporting_level := lv_reporting_level;

    ln_step := 20;
    if pay_emp_action_arch.gv_multi_leg_rule is null then
       pay_emp_action_arch.gv_multi_leg_rule
             := pay_emp_action_arch.get_multi_legislative_rule('CA');
    end if;

    hr_utility.trace('lv_reporting_level : '|| lv_reporting_level);
    hr_utility.trace('gv_multi_leg_rule : ' || pay_emp_action_arch.gv_multi_leg_rule);
    hr_utility.set_location(gv_package || lv_procedure_name, 20);

    ln_step := 30;
    if pay_emp_action_arch.gv_multi_leg_rule = 'Y' then
       lv_pymt_dimension      := '_ASG_PAYMENTS';
       lv_jd_pymt_dimension   := '_ASG_PAYMENTS_JD';
    else
       lv_pymt_dimension      := '_PAYMENTS';
       lv_jd_pymt_dimension   := '_PAYMENTS_JD';
    end if;

    ln_step := 40;
    dbt.delete;
    tax.delete;
    i := 0;

    ln_step := 50;
    for c_dbt in cur_def_bal loop

      ln_pymt_def_bal_id     := 0;
      ln_gre_ytd_def_bal_id  := 0;
      ln_tg_ytd_def_bal_id   := 0;
      /* Added to archive reversals 'V', Bug#3498653 */
      ln_run_def_bal_id      := 0;

      if c_dbt.balance_name in ('PROV Withheld', 'QPP EE Withheld' , 'PPIP EE Withheld') -- 4566656
      then

         ln_step := 60;
         ln_pymt_def_bal_id :=
             pay_emp_action_arch.get_defined_balance_id(
                                             c_dbt.balance_type_id,
                                             lv_jd_pymt_dimension,
                                             'CA');

         ln_step := 70;
         ln_gre_ytd_def_bal_id :=
             pay_emp_action_arch.get_defined_balance_id(
                                             c_dbt.balance_type_id,
                                             '_ASG_JD_GRE_YTD',
                                             'CA');

         ln_step := 80;
         ln_tg_ytd_def_bal_id :=
             pay_emp_action_arch.get_defined_balance_id(
                                             c_dbt.balance_type_id,
                                             '_ASG_JD_TG_YTD',
                                             'CA');

         /* Modifying to check for reversals for Canada. Bug#3498653 */
         ln_run_def_bal_id :=
             pay_emp_action_arch.get_defined_balance_id(
                                             c_dbt.balance_type_id,
                                             '_ASG_JD_GRE_RUN',
                                             'CA');

      else
         ln_step := 90;
         ln_pymt_def_bal_id :=
             pay_emp_action_arch.get_defined_balance_id(
                                             c_dbt.balance_type_id,
                                             lv_pymt_dimension,
                                             'CA');

         ln_step := 100;
         ln_gre_ytd_def_bal_id :=
             pay_emp_action_arch.get_defined_balance_id(
                                             c_dbt.balance_type_id,
                                             '_ASG_GRE_YTD',
                                             'CA');

         ln_step := 110;
         ln_tg_ytd_def_bal_id :=
             pay_emp_action_arch.get_defined_balance_id(
                                             c_dbt.balance_type_id,
                                             '_ASG_TG_YTD',
                                             'CA');

         /* Modifying to check for reversals for Canada. Bug#3498653 */
         ln_run_def_bal_id :=
             pay_emp_action_arch.get_defined_balance_id(
                                             c_dbt.balance_type_id,
                                             '_ASG_GRE_RUN',
                                             'CA');

      end if;

      if ( c_dbt.balance_name = 'PROV Withheld' ) then
        ln_step := 120;
        for j in 1..3 loop
          dbt(i).bal_name := c_dbt.balance_name;
          dbt(i).disp_sequence := c_dbt.display_sequence;
          dbt(i).bal_type_id := c_dbt.balance_type_id;
          dbt(i).pymt_def_bal_id := ln_pymt_def_bal_id;
          dbt(i).gre_ytd_def_bal_id := ln_gre_ytd_def_bal_id;
          dbt(i).tg_ytd_def_bal_id := ln_tg_ytd_def_bal_id;
          /* Added run_def_bal_id for reversals in Canada */
          dbt(i).run_def_bal_id := ln_run_def_bal_id;

          if j = 1 then
            dbt(i).jurisdiction_cd := 'NT';
          elsif j = 2 then
            dbt(i).jurisdiction_cd := 'NU';
          else
            dbt(i).jurisdiction_cd := 'QC';
          end if;
          hr_utility.trace(dbt(i).jurisdiction_cd);
          i := i + 1;
        end loop;
      elsif ( c_dbt.balance_name = 'QPP EE Withheld' ) then
        ln_step := 130;
        dbt(i).bal_name := c_dbt.balance_name;
        dbt(i).disp_sequence := c_dbt.display_sequence;
        dbt(i).bal_type_id := c_dbt.balance_type_id;
        dbt(i).pymt_def_bal_id := ln_pymt_def_bal_id;
        dbt(i).gre_ytd_def_bal_id := ln_gre_ytd_def_bal_id;
        dbt(i).tg_ytd_def_bal_id := ln_tg_ytd_def_bal_id;
        /* Added run_def_bal_id for reversals in Canada. Bug#3498653 */
        dbt(i).run_def_bal_id := ln_run_def_bal_id;

        dbt(i).jurisdiction_cd := 'QC';
        i := i + 1;
      elsif ( c_dbt.balance_name = 'PPIP EE Withheld' ) then  -- 4566656: Added the code for PPIP EE Withheld
        ln_step := 140;
        dbt(i).bal_name := c_dbt.balance_name;
        dbt(i).disp_sequence := c_dbt.display_sequence;
        dbt(i).bal_type_id := c_dbt.balance_type_id;
        dbt(i).pymt_def_bal_id := ln_pymt_def_bal_id;
        dbt(i).gre_ytd_def_bal_id := ln_gre_ytd_def_bal_id;
        dbt(i).tg_ytd_def_bal_id := ln_tg_ytd_def_bal_id;
        dbt(i).run_def_bal_id := ln_run_def_bal_id;

        dbt(i).jurisdiction_cd := 'QC';
        i := i + 1;
      else
        ln_step := 150;
        dbt(i).bal_name := c_dbt.balance_name;
        dbt(i).disp_sequence := c_dbt.display_sequence;
        dbt(i).bal_type_id := c_dbt.balance_type_id;
        dbt(i).pymt_def_bal_id := ln_pymt_def_bal_id;
        dbt(i).gre_ytd_def_bal_id := ln_gre_ytd_def_bal_id;
        dbt(i).tg_ytd_def_bal_id := ln_tg_ytd_def_bal_id;
        /* Added run_def_bal_id for reversals in Canada. Bug#3498653 */
        dbt(i).run_def_bal_id := ln_run_def_bal_id;

        dbt(i).jurisdiction_cd := '-1';
        i := i + 1;
      end if;

    end loop;

    hr_utility.set_location(gv_package || lv_procedure_name, 30);
    i := 0;

    ln_step := 160;
    for tax_short_name in cur_tax_name loop

        tax(i).language    := tax_short_name.language;
        tax(i).lookup_code := tax_short_name.lookup_code;
        tax(i).meaning     := tax_short_name.meaning;

        hr_utility.trace(tax(i).language);
        hr_utility.trace(tax(i).lookup_code);
        hr_utility.trace(tax(i).meaning);

        i := i + 1;

    end loop;

    ln_step := 170;
    for i in dbt.first..dbt.last loop
      hr_utility.trace(dbt(i).bal_name);
      hr_utility.trace(dbt(i).disp_sequence);
      hr_utility.trace(dbt(i).bal_type_id);
      hr_utility.trace(dbt(i).pymt_def_bal_id);
      hr_utility.trace(dbt(i).gre_ytd_def_bal_id);
      hr_utility.trace(dbt(i).tg_ytd_def_bal_id);
      -- Added run_def_bal_id for reversals in canada Bug#3498653
      hr_utility.trace(dbt(i).run_def_bal_id);
      hr_utility.trace(dbt(i).jurisdiction_cd);
    end loop;

    hr_utility.set_location(gv_package || lv_procedure_name, 40);

  EXCEPTION
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

  END py_archinit;

--begin
--hr_utility.trace_on (null, 'PYARCH');

end pay_ca_payroll_arch;

/
