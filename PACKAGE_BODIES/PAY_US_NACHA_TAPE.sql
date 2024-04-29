--------------------------------------------------------
--  DDL for Package Body PAY_US_NACHA_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_NACHA_TAPE" as
/* $Header: pytapnac.pkb 120.2.12010000.6 2009/11/20 10:31:48 mikarthi ship $ */
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

    Name        : pay_us_nacha_tape

    Description : This package holds building blocks used in the generation
                  of nacha Tape.

    Uses        : hr_utility

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    JUL-23-1993 RMAMGAIN      1.0                Created with following proc.
                                                  . run_formula

    NOV-01-1993 RMAMGAIN      2.0                Included Exception handling
    JUN-28-1995 NBRISTOW      40.2               Package now uses PL/SQL
                                                 tables to interface with
                                                 the C process.
    JUN-30-1995 NBRISTOW      40.3               NACHA_FILE_CONTROL parameters
                                                 were setup as context rules.
    JUL-25-1995 AMILLS        40.3               Changed tokenised error
						 message 'HR_13103_SCL_FLEX_
						 NOT_FOUND' to hard coded
						 'HR_7711_SCL_FLEX_NOT_FOUND'

    APR-12-1996 ALLEE                            Changed g_company_entry_date
                                                 to default to 'SALARY'
						 Added padding functionality
                                                 Added extra parameter for
                                                 Trace Number.

    APR-19-1996 ALLEE                            Added Tax_unit_id context to
                                                 the Entry Description

    APR-23-1996 ALLEE                            Passed the Transfer_pad_count
                                                 to the NACHA_FILE_HEADER
                                                 formula

    APR-29-1996 ALLEE                            Removed the show errors
						 at the end.

    JUL-25-1996 ALLEE                            Added the org_pay_meth cursor.
                                                 Included the Org_pay_entry_detail
						 and the org_pay_dummy formulas.

    MAY-17-2000 DSCULLY				 Added support for child care
						 addenda records.  Rewrote cursors

    JUN-17-2000 DSCULLY				 Fixed error where seq. number for
						 entry detail records was being incremented
						 when addenda record was present.  We now
						 increment g_addenda_count for addenda
                                                 records instead of g_count.
                                                 g_addenda_count is added to the record
                                                 total for block/padding purposes

    ***************************************************************************************
     Due to extensive changes in the 11.0 version, and little difference between the
     previous 11.0 version and the 11.5 version, we are taking the modified 11.0 version
     and redoing the changes made in earlier revisions of the 11.5 version
    ***************************************************************************************
    JUN-17-2000 DSCULLY		115.4		Modified 11.0 version and arcs into 11.5
                                                codetree
    OCT-10-2000 DSCULLY		115.6		Added contexts for NACHA_FILE_CONTROL
                                                formula
    MAY-01-2001 DGARG           115.7  1732778  Added code to set parameter value of
                                                FILE_ID_MODIFIER as specified by
                                                the user instead of defaulting it to 0.
    MAY-08-2001 ahanda          115.8           Changed package to set the value of
                                                g_file_id_modifier to 0.
    JUL-10-2001 meshah          115.9  1167074  Created procedures for each formula.
    JUL-19-2001 MESHAH          110.5  1357404  Changed write_batch_header,
                                                write_org_entry_detail to set and reset the
                                                flags and the fetch in the cursor
                                                csr_assignments to get the rowid. Flags are
                                                used to indicated if batch header should
                                                be printed again along with all other records
                                                following it. Also checking on the limit of
                                                99,999,999.99 to indicate if the batch header
                                                should be printed again.

   JUL-27-2001 MESHAH           115.11          New parameter in legislative parameters,
                                                TEST FILE. This parameter is passed to the
                                                formula ENTRY DETAIL and ORG_PAY_ENTRY...
                                                TEST_FILE is added to NACHA_ADDENDA also.
   JUL-31-2001 MESHAH           115.12          New parameter of THIRD_PARTY for
                                                NACHA_BATCH_HEADER.
   DEC-20-2002 MESHAH           115.14          made nocopy and dbdrv changes.
   FEB-18-2004 kvsankar         115.15 3331019  Bug fix as part of 10G certification.
                                                Changes made to make use of RULE hint
                                                only if db version is less than 10.0.
   JUL-04-2004 ahanda           115.16          Fixes bugs 3715300, 3712003, 3711912,
                                                           3711907, 3704992
   JUL-07-2004 ahanda           115.17          Fixed gscc warning.
   OCT-21-2004 jgoswami         115.18 3962987  Change the length of v_attach_number to 50
   NOV-21-2004 ahanda           115.19          Added NVL for reference/attachment number
   MAR-09-2006 saurgupt         115.20 5019804  Set the message to error out process if
                                                payment is greater than 99999999.99 .
   JUL-23-2006 djoshi		115.21 5397759    Changed the logic to check for individual
                                                employee and not the batch
   Nov-07-2008 sudedas        115.22 7510559    Changed procedure get_third_party_details
                                                to show correct Attachment Number and
                                                Amount to show against Wage Attach Elements.
   Nov-11-2008 sudedas        115.23            Changed the logic of determining Wage
                                                Attachment Architecture.
   Aug-05-2009 kagangul       115.24            Added function f_get_batch_transact_ident
						for supporting the EFT reconciliation.
   Aug-08-2009 mikarthi       115.15	        Modifications for Nacha IAT enhancement
  */
--
-------------------------- run_formula -------------------------------------
 /*
 NAME
   run_formula
 DESCRIPTION
   Setup contexts and parameter for the formula. Setup next formula to call
   so that Magtape ('C' process) could call appropriate formula
 NOTES
   C process 'pymx' uses parameters and contexts set by this procedure
   to setup the interface for the formula and to call the formula.

   begin
     if g_business_group_id is null then
     {
   	initialize global variables
        open csr_org_flex_info
        put all Org. payment info in Parameters
        close csr_org_flex_info
        Setup contexts and params for NACHA_FILE_HEADER formula
        open csr_nacha_leg_comp
     }
     else
     {
	 if g_addenda_write = 'Y'
	 {
	    set g_addenda_write = 'N'
	    setup NACHA_ADDENDA formula params and contexts
	 }

	 elsif g_batch_control_write = 'Y'
	 {
	    set g_batch_control_write = 'N'
	    setup NACHA_BATCH_CONTROL formula params and contexts
         }

         elsif csr_assignment is open then
         {
            fetch csr_assignments
            if FOUND
            then
            {
              setup NACHA_ENTRY_DETAIL formula params and Contexts
	      if payment of type third party, set g_addenda_write to 'Y'
            }
            else
            {
	      set g_batch_control_write 'Y'
              setup context and params for NACHA_ORG_PAY_ENTRY_DETAIL formula
	    }
            end if;
         }
         else -- (csr_nacha_batch is open)
         {
            fetch csr_nacha_batch
            if FOUND
            then
            {
              open csr_assignment;
              setup NACHA_BATCH_HEADER formula;
            }
            else
            {
              if pad_count = -1
              then
              {
                initialize pad count
                setup context and params for NACHA_FILE_CONTROL Formula
              }
              else if pad_count > 0 then
              {
                setup context and params for NACHA_PADDING Formula

                if pad_count = 1 then
                  close csr_nacha_leg_comp
                 end if;
              }
              end if

            end if
            }
     }
     end if

   end
 */
--
PROCEDURE run_formula IS
--
-- Local Variable
   v_prepayment_id		 number := null;
   v_amount                      number := null;
   v_block_count                 number := null;
   v_fips_code			 varchar2(10);
   v_med_ind			 varchar2(1);
   v_payment_date		 date;
   v_attach_number		 varchar2(50);

/***************************** Local Functions *******************/
/* ****************************************************************
   NAME
       get_third_party_details
   DESCRIPTION
       Gets element entry details for third party child care deductions.
   NOTES
       Local function.
********************************************************************/

PROCEDURE get_third_party_details(p_amount number,
				  p_ppm_id number,
				  p_payment_date  out nocopy date,
				  p_ref_no        out nocopy varchar2,
				  p_fips_code     out nocopy varchar2,
				  p_med_ind       out nocopy varchar2)
IS
-- Following cursor is commented for Bug# 7510559
-- Instead introduced 2 cursors one for Old another for New
-- Wage Attachment Architecture Elements
-- Cursor csr_ele_details_old_arch for Old Wage Attach Arch
-- Cursor csr_ele_details_new_arch for New Wage Attach Arch

/*
	CURSOR csr_ele_details is
           select nvl(peev.screen_entry_value,'NULL') ref_no
                 ,nvl(peef.entry_information2,'NONE')  -- FIPS code
                 ,nvl(peef.entry_information1,'N')     -- Medical Indicator
                 ,ppa.effective_date    payment_date
                 ,prr.run_result_id
            from pay_element_entry_values_f peev,
                 pay_input_values_f         piv_att,
                 pay_element_entries_f      peef,
                 pay_run_results            prr,
                 pay_payroll_actions        ppa,
                 pay_assignment_actions     paa,
                 pay_action_interlocks      pai,
                 pay_pre_payments           ppp
           WHERE ppp.value = p_amount
             and ppp.pre_payment_id = p_ppm_id
             and ppp.assignment_action_id = pai.locking_action_id
             and pai.locked_action_id = paa.assignment_action_id
             and ppa.payroll_action_id = paa.payroll_action_id
             and ppa.action_type in ('R', 'Q')
             and ((paa.source_action_id is not null and ppa.run_type_id is not null) or
                  (paa.source_action_id is null and ppa.run_type_id is null))
             and ppp.personal_payment_method_id = peef.personal_payment_method_id
             and peef.assignment_id = paa.assignment_id
             and ppa.date_earned between peev.effective_start_date
                                     and peev.effective_end_date
             and ppa.date_earned between peef.effective_start_date
                                     and peef.effective_end_date
             and piv_att.input_value_id  = peev.input_value_id
             and upper(piv_att.name) = 'ATTACHMENT NUMBER'
             and ppa.effective_Date between piv_att.effective_start_date
                                        and piv_att.effective_end_date
             and peef.element_entry_id   = peev.element_entry_id
             and paa.assignment_Action_id = prr.assignment_Action_id
             and prr.element_type_id = peef.element_type_id
	   order by prr.run_result_id;
*/

      -- Check if the Business Group is already upgraded
      -- into New Wage Attach Architecture using 'Generic Upgrade Mechanism'

      CURSOR csr_garn_arch IS
          select distinct 'Y'
            from pay_upgrade_definitions pud
                ,pay_upgrade_status pus
           where pud.short_name = 'US_INV_DEDN_UPGRADE'
             and pud.legislation_code = 'US'
             and pud.upgrade_definition_id = pus.upgrade_definition_id
             and pus.status = 'C'
             and pus.business_group_id = g_business_group_id;

      -- Check Action Parameter Settings
      -- Parameter Value 'Y' indicates New WA Arch
      -- This parameter value will be used in conjunction
      -- with value returned by cursor csr_garn_arch to determine
      -- What Wage Attachment Architecture is in use

      CURSOR csr_action_param IS
           select parameter_value
             from pay_action_parameters
            where parameter_name = 'US_ADVANCED_WAGE_ATTACHMENT';

      -- Fetch data for Old Arch Garn Elements
      -- Query should return Correct Amount and Attachment Number
      -- associated to Garnishment Elements

      CURSOR csr_ele_details_old_arch IS
          select nvl(peev.screen_entry_value,'NULL') ref_no
                 ,nvl(peef.entry_information2,'NONE')  -- FIPS code
                 ,nvl(peef.entry_information1,'N')     -- Medical Indicator
                 ,ppa.effective_date    payment_date
                 ,prr_pay.run_result_id
            from pay_element_entry_values_f peev,
                 pay_element_entry_values_f peev_pay,
                 pay_input_values_f         piv_att,
                 pay_element_entries_f      peef,
                 pay_run_results            prr_att,
                 pay_run_results            prr_pay,
                 pay_payroll_actions        ppa,
                 pay_assignment_actions     paa,
                 pay_action_interlocks      pai,
                 pay_pre_payments           ppp,
                 pay_input_values_f         piv_pay,
                 pay_run_result_values      prrv_att,
                 pay_run_result_values      prrv_pay
           WHERE ppp.value = p_amount
             and ppp.pre_payment_id = p_ppm_id
             and ppp.assignment_action_id = pai.locking_action_id
             and pai.locked_action_id = paa.assignment_action_id
             and ppa.payroll_action_id = paa.payroll_action_id
             and ppa.action_type in ('R', 'Q')
             and ((paa.source_action_id is not null and ppa.run_type_id is not null) or
                  (paa.source_action_id is null and ppa.run_type_id is null))
             and ppp.personal_payment_method_id = peef.personal_payment_method_id
             and peef.assignment_id = paa.assignment_id
             and ppa.date_earned between peev.effective_start_date
                                     and peev.effective_end_date
             and ppa.date_earned between peef.effective_start_date
                                     and peef.effective_end_date
             and piv_att.input_value_id  = peev.input_value_id
             and upper(piv_att.name) = 'ATTACHMENT NUMBER'
             and ppa.effective_Date between piv_att.effective_start_date
                                        and piv_att.effective_end_date
             and piv_att.input_value_id = prrv_att.input_value_id
             and prrv_att.result_value = peev.screen_entry_value
             and piv_pay.input_value_id = peev_pay.input_value_id
             and ppa.effective_date between piv_pay.effective_start_date
                                       and piv_pay.effective_end_date
             and ppa.date_earned between peev_pay.effective_start_date
                                     and peev_pay.effective_end_date
             and piv_pay.input_value_id = prrv_pay.input_value_id
             and upper(piv_pay.name) = 'PAY VALUE'
             and fnd_number.number_to_canonical(ppp.value) = prrv_pay.result_value
             and peef.element_entry_id = peev.element_entry_id
             and peef.element_entry_id = peev_pay.element_entry_id
             and paa.assignment_Action_id = prr_att.assignment_Action_id
             and prr_att.run_result_id = prrv_att.run_result_id
             and paa.assignment_action_id = prr_pay.assignment_action_id
             and prr_pay.run_result_id = prrv_pay.run_result_id
             and prr_att.element_type_id = peef.element_type_id
             and prr_pay.element_type_id = peef.element_type_id
       order by prr_pay.run_result_id;

      -- Fetch data for New Arch Garn Elements
      -- Query should return Correct Amount and Attachment Number
      -- associated to Garnishment Elements

      CURSOR csr_ele_details_new_arch IS
           select nvl(peev.screen_entry_value,'NULL') ref_no
                 ,nvl(peef.entry_information2,'NONE')  -- FIPS code
                 ,nvl(peef.entry_information1,'N')     -- Medical Indicator
                 ,ppa.effective_date    payment_date
                 ,prr_att.run_result_id
            from pay_element_entry_values_f peev,
                 pay_input_values_f         piv_att,
                 pay_element_entries_f      peef,
                 pay_run_results            prr_att,
                 pay_run_results            prr_pay,
                 pay_payroll_actions        ppa,
                 pay_assignment_actions     paa,
                 pay_action_interlocks      pai,
                 pay_pre_payments           ppp,
                 pay_input_values_f         piv_pay,
                 pay_run_result_values      prrv_att,
                 pay_run_result_values      prrv_pay,
                 pay_element_types_f        pet,
                 pay_element_types_f        pet_calc,
                 pay_element_classifications pec
           WHERE ppp.value = p_amount
             and ppp.pre_payment_id = p_ppm_id
             and ppp.assignment_action_id = pai.locking_action_id
             and pai.locked_action_id = paa.assignment_action_id
             and ppa.payroll_action_id = paa.payroll_action_id
             and ppa.action_type in ('R', 'Q')
             and ((paa.source_action_id is not null and ppa.run_type_id is not null) or
                  (paa.source_action_id is null and ppa.run_type_id is null))
             and ppp.personal_payment_method_id = peef.personal_payment_method_id
             and peef.assignment_id = paa.assignment_id
             and ppa.date_earned between peev.effective_start_date
                                     and peev.effective_end_date
             and ppa.date_earned between peef.effective_start_date
                                     and peef.effective_end_date
             and piv_att.input_value_id  = peev.input_value_id
             and upper(piv_att.name) = 'ATTACHMENT NUMBER'
             and ppa.effective_Date between piv_att.effective_start_date
                                        and piv_att.effective_end_date
             and piv_att.input_value_id = prrv_att.input_value_id
             and prrv_att.result_value = peev.screen_entry_value
             and prrv_att.run_result_id = prr_att.run_result_id
             and paa.assignment_Action_id = prr_att.assignment_Action_id
             and prr_att.element_type_id = peef.element_type_id
             and peef.element_type_id = pet.element_type_id
             and pet.classification_id = pec.classification_id
             and pec.classification_name = 'Involuntary Deductions'
             and pec.legislation_code = 'US'
             and pec.business_group_id IS NULL
             and fnd_number.canonical_to_number(pet.element_information5) = pet_calc.element_type_id
             and pet_calc.element_name like pet.element_name || '%Calculator'
             and pet_calc.element_type_id = piv_pay.element_type_id
             and NVL(ppa.date_earned, ppa.effective_date) between piv_pay.effective_start_date and piv_pay.effective_end_date
             and piv_pay.input_value_id = prrv_pay.input_value_id
             and upper(piv_pay.name) = 'PAY VALUE'
             and fnd_number.number_to_canonical(ppp.value) = prrv_pay.result_value
             and prr_pay.run_result_id = prrv_pay.run_result_id
             and prr_pay.assignment_action_id = paa.assignment_action_id
             and prr_pay.element_type_id = pet_calc.element_type_id
             order by prr_att.run_result_id;

	lv_ref_no        VARCHAR2(50);
	lv_fips_code     VARCHAR2(10);
	lv_med_ind       VARCHAR2(1);
	ld_payment_date  DATE;
	ln_run_result_id NUMBER;
      lv_garn_arch     VARCHAR2(10);
      lv_act_param     pay_action_parameters.parameter_value%TYPE;
      lb_use_new_arch  BOOLEAN ;

begin
	hr_utility.trace('Entering pay_nacha_tape.get_third_party_details');
	hr_utility.trace('p_amount = ' || p_amount);
	hr_utility.trace('p_ppm_id = ' || p_ppm_id);
      hr_utility.trace('g_business_group_id := ' || g_business_group_id);

      open csr_garn_arch;
      fetch csr_garn_arch into lv_garn_arch;
      if csr_garn_arch%NOTFOUND then
         lv_garn_arch := 'X';
      end if;
      close csr_garn_arch;
      hr_utility.trace('lv_garn_arch := ' || lv_garn_arch);

      open csr_action_param;
      fetch csr_action_param into lv_act_param;
      if csr_action_param%NOTFOUND then
         lv_act_param := 'X';
      end if;
      hr_utility.trace('lv_act_param := ' || lv_act_param);

      /* Following is the logic to determine what WA Arch is in use
         BG Upgraded + Action Param 'Y' = New WA Arch
         BG Upgraded + Action Param 'N' = New WA Arch
         BG Upgraded + NO Action Param  = New WA Arch
         BG Not Upgraded + Action Param 'Y' = New WA Arch
         BG Not Upgraded + Action Param 'N' = Old WA Arch
         BG Not Upgraded + NO Action Param  = New WA Arch
      */

      lb_use_new_arch := FALSE;

      if ( NVL(lv_garn_arch, 'X') = 'Y'
        or NVL(lv_act_param, 'X') = 'Y'
        or ( NVL(lv_garn_arch, 'X') = 'X' AND NVL(lv_act_param, 'X') = 'X' ) ) then

         lb_use_new_arch := TRUE;
      else
         lb_use_new_arch := FALSE;
      end if;

      if lb_use_new_arch then
	   open csr_ele_details_new_arch;
      else
         open csr_ele_details_old_arch;
      end if;

	hr_utility.trace('Open cursor csr_ele_details');

	LOOP
            if lb_use_new_arch then

               fetch csr_ele_details_new_arch into
                                    lv_ref_no,
                                    lv_fips_code,
                                    lv_med_ind,
                                    ld_payment_date,
                                    ln_run_result_id;

                  hr_utility.trace('After fetch csr_ele_details_new_arch');
                  hr_utility.trace('lv_ref_no := ' || lv_ref_no);
                  hr_utility.trace('lv_fips_code := ' || lv_fips_code);
                  hr_utility.trace('lv_med_ind := ' || lv_med_ind);
                  hr_utility.trace('ld_payment_date := ' || TO_CHAR(ld_payment_date));
                  hr_utility.trace('ln_run_result_id := ' || ln_run_result_id);

                  if csr_ele_details_new_arch%notfound then
                     hr_utility.trace('Not Found csr_ele_details_new_arch');
                     exit;
                  end if;
            else

               fetch csr_ele_details_old_arch into
                                    lv_ref_no,
                                    lv_fips_code,
                                    lv_med_ind,
                                    ld_payment_date,
                                    ln_run_result_id;

                  hr_utility.trace('After fetch csr_ele_details_old_arch');
                  hr_utility.trace('lv_ref_no := ' || lv_ref_no);
                  hr_utility.trace('lv_fips_code := ' || lv_fips_code);
                  hr_utility.trace('lv_med_ind := ' || lv_med_ind);
                  hr_utility.trace('ld_payment_date := ' || TO_CHAR(ld_payment_date));
                  hr_utility.trace('ln_run_result_id := ' || ln_run_result_id);

                  if csr_ele_details_old_arch%notfound then
                     hr_utility.trace('Not Found csr_ele_details_old_arch');
                     exit;
                  end if;
            end if;

            if not (g_used_results_tab.EXISTS(ln_run_result_id))  then

             hr_utility.trace('g_used_results_tab.EXISTS for := ' || ln_run_result_id);

	       g_used_results_tab(ln_run_result_id) := p_amount;
	       p_payment_date := ld_payment_date;
	       p_ref_no       := lv_ref_no;
             p_fips_code    := lv_fips_code;
             p_med_ind      := lv_med_ind;

            if lb_use_new_arch then
               close csr_ele_details_new_arch;
            else
               close csr_ele_details_old_arch;
            end if;

	       --close csr_ele_details;
	       hr_utility.trace('Exiting pay_nacha_tape.get_third_party_details - success');
	       return;
	   end if;

	end LOOP;

	--close csr_ele_details;
      if lb_use_new_arch then
         if csr_ele_details_new_arch%ISOPEN then
            close csr_ele_details_new_arch;
         end if;
      else
         if csr_ele_details_old_arch%ISOPEN then
            close csr_ele_details_old_arch;
         end if;
      end if;

	-- if we got here then we did not find a element that matches our needs
	hr_utility.trace('Exiting pay_nacha_tape.get_third_part_details - error');
	hr_utility.set_message(801,'PAY_GARNISH_ELE_NOT_FOUND');
	hr_utility.raise_error;

end get_third_party_details;

/* ****************************************************************
   NAME
       get_formula_id
   DESCRIPTION
       Gets Formula id for a given formula name
   NOTES
       Local function.
********************************************************************/

   FUNCTION get_formula_id (p_formula_name    varchar2)
            RETURN varchar2 IS
     ff_formula_id  varchar2(9);
   BEGIN
    hr_utility.set_location('pay_us_nacha_tape.get_formula_id',1);
--
    select TO_CHAR(FORMULA_ID) INTO ff_formula_id
    from   FF_FORMULAS_F
    where  g_effective_date between EFFECTIVE_START_DATE and
                                    EFFECTIVE_END_DATE
    and    FORMULA_NAME     = p_formula_name;
--
     hr_utility.trace('Formula ID : '||ff_formula_id);
     RETURN ff_formula_id;
     exception
       when no_data_found then
            hr_utility.set_message(801,'FFX37_FORMULA_NOT_FOUND');
            hr_utility.set_message_token('1',p_formula_name);
            hr_utility.raise_error;
   END get_formula_id;
----
----
  --.
/* ***************************************************************
     NAME
       get_transfer_param
     DESCRIPTION
       Gets value for the named parameter
     NOTES
       Local function.
       *** TEMP need to change when arrays are available.
   *********************************************************************/

   FUNCTION get_transfer_param ( p_param_name varchar2 )
            RETURN Number IS
     param_value   number;
   BEGIN
    hr_utility.set_location('pay_us_nacha_tape.get_effective_date',20);
    IF pay_mag_tape.internal_prm_names(3) = p_param_name
    THEN
      param_value  := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(3));
    ELSIF pay_mag_tape.internal_prm_names(4) = p_param_name
    THEN
      param_value  := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(4));
    ELSIF pay_mag_tape.internal_prm_names(5) = p_param_name
    THEN
      param_value  := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(5));
    ELSIF pay_mag_tape.internal_prm_names(6) = p_param_name
    THEN
      param_value  := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(6));
    ELSIF pay_mag_tape.internal_prm_names(7) = p_param_name
    THEN
      param_value  := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(7));
    ELSIF pay_mag_tape.internal_prm_names(8) = p_param_name
    THEN
      param_value  := fnd_number.canonical_to_number(pay_mag_tape.internal_prm_values(8));
    END IF;
    RETURN param_value;
   END get_transfer_param;
  --

/******************************************************************
   NAME
       write_file_header
   DESCRIPTION
       Writes the File Header Record .
   NOTES
       Local function.
********************************************************************/


PROCEDURE write_file_header IS

BEGIN

   hr_utility.trace('Writing File Header');
   hr_utility.trace('.... Writing File Header Context');

   pay_mag_tape.internal_cxt_values(1)  := '3';
   pay_mag_tape.internal_cxt_names(2)   := 'ORG_PAY_METHOD_ID';
   pay_mag_tape.internal_cxt_values(2)  := g_org_payment_method_id;
   pay_mag_tape.internal_cxt_names(3)   := 'DATE_EARNED';
   pay_mag_tape.internal_cxt_values(3)  := fnd_date.date_to_canonical(g_effective_date);
--
   hr_utility.trace('.... Writing File Header Parameters');

   pay_mag_tape.internal_prm_values(1)  := '6';
   pay_mag_tape.internal_prm_values(2)  := g_file_header;
   pay_mag_tape.internal_prm_names(3)   := 'TRANSFER_THIRD_PARTY';
   pay_mag_tape.internal_prm_values(3)  := g_csr_org_pay_third_party;
   pay_mag_tape.internal_prm_names(4)   := 'FILE_ID_MODIFIER';
   pay_mag_tape.internal_prm_values(4)  := g_file_id_modifier;
   pay_mag_tape.internal_prm_names(5)   := 'CREATION_DATE';
   pay_mag_tape.internal_prm_values(5)  := g_date;
   pay_mag_tape.internal_prm_names(6)   := 'CREATION_TIME';
   pay_mag_tape.internal_prm_values(6)  := g_time;

   hr_utility.trace('Leaving File Header');

   hr_utility.set_location('run_formula.File_head',6);

END; /* end write_file_header */

 /******************************************************************
 * NAME
 *     write_batch_header
 * DESCRIPTION
 *     Writes the Batch Header Record .
 * NOTES
 *     Local function.
 *******************************************************************/
 PROCEDURE write_batch_header
 IS

 BEGIN
   hr_utility.trace('Writing Batch Header');

   g_overflow_batch := 'N';
   hr_utility.trace('.... g_overflow_batch is : '|| g_overflow_batch);

   -- Bug 3331019
   if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
      OPEN csr_assignments (g_legal_company_id,
                            g_payroll_action_id,
                            g_csr_org_pay_meth_id,
                            g_rowid );
   else
      OPEN csr_assignments_no_rule (g_legal_company_id,
                                    g_payroll_action_id,
                                    g_csr_org_pay_meth_id,
                                    g_rowid );
   end if;

   g_temp_count        := 0;
   g_batch_number      := g_batch_number + 1;

   -- Context for NACHA_BATCH_HEADER
   -- first context is number of contexts
   hr_utility.trace('.... Writing Batch Header Context');

   pay_mag_tape.internal_cxt_values(1) := '4';
   pay_mag_tape.internal_cxt_names(2)  := 'TAX_UNIT_ID';
   pay_mag_tape.internal_cxt_values(2) := TO_CHAR(g_legal_company_id);
   pay_mag_tape.internal_cxt_names(3)  := 'DATE_EARNED';
   pay_mag_tape.internal_cxt_values(3) := fnd_date.date_to_canonical(g_effective_date);
   pay_mag_tape.internal_cxt_names(4)  := 'ORG_PAY_METHOD_ID';
   pay_mag_tape.internal_cxt_values(4) := g_org_payment_method_id;

   -- Parameters for NACHA_BATCH_HEADER
   -- first parameter is number of parameters
   -- second parameter is formula is
   hr_utility.trace('.... Writing Batch Header Parameters');

   pay_mag_tape.internal_prm_values(1) := '8';
   pay_mag_tape.internal_prm_values(2) := g_batch_header;

   -- 3 TRANSFER_THIRD_PARTY
--   pay_mag_tape.internal_prm_names(8)  := 'TRANSFER_THIRD_PARTY';
--   pay_mag_tape.internal_prm_values(8) := g_csr_org_pay_third_party;

   pay_mag_tape.internal_prm_names(5)  := 'COMPANY_DESCRIPTIVE_DATE';
   pay_mag_tape.internal_prm_values(5) := g_descriptive_date;
   pay_mag_tape.internal_prm_names(6)  := 'EFFECTIVE_ENTRY_DATE';
   pay_mag_tape.internal_prm_values(6) := nvl(g_direct_dep_date,
                                             TO_CHAR(g_effective_date,'YYMMDD'));
   pay_mag_tape.internal_prm_names(7)  := 'BATCH_NUMBER';
   pay_mag_tape.internal_prm_values(7) := TO_CHAR(g_batch_number);

   pay_mag_tape.internal_prm_names(4)  := 'COMPANY_ENTRY_DESCRIPTION';
   pay_mag_tape.internal_prm_names(8)  := 'FORMAT_TYPE';

   -- the format type depends on whether the opm is third party or not
   if g_csr_org_pay_third_party = 'Y' then
      pay_mag_tape.internal_prm_values(4) := 'CHILD SUPP';
      pay_mag_tape.internal_prm_values(8) := 'CCD';
   else
      pay_mag_tape.internal_prm_values(4) := g_company_entry_desc;
      pay_mag_tape.internal_prm_values(8) := 'PPD';
   end if;


   hr_utility.trace('Leaving Batch Header');

END; /* write_batch_header */

/******************************************************************
   NAME
       write_entry_detail
   DESCRIPTION
       Writes the Entry Detail Record .
   NOTES
       Local function.
********************************************************************/


PROCEDURE write_entry_detail IS

BEGIN

   hr_utility.trace('Writing Entry Detail');

   hr_utility.trace('.... Writing Entry Detail Context');
   g_count  := g_count  + 1;

   -- Context Setup for NACHA_ENTRY_DETAIL
   -- First context value is number of contexts
   pay_mag_tape.internal_cxt_values(1)  := '7';
   pay_mag_tape.internal_cxt_names(2)   := 'ASSIGNMENT_ID';
   pay_mag_tape.internal_cxt_values(2)  := TO_CHAR(g_assignment_id);
   pay_mag_tape.internal_cxt_names(3)   := 'ASSIGNMENT_ACTION_ID';
   pay_mag_tape.internal_cxt_values(3)  := TO_CHAR(g_assignment_action_id);
   pay_mag_tape.internal_cxt_names(4)   := 'DATE_EARNED';
   pay_mag_tape.internal_cxt_values(4)  := fnd_date.date_to_canonical(g_effective_date);
   pay_mag_tape.internal_cxt_names(5)   := 'PER_PAY_METHOD_ID';
   pay_mag_tape.internal_cxt_values(5)  := to_char(g_personal_payment_method_id);
   pay_mag_tape.internal_cxt_names(6)   := 'ORG_PAY_METHOD_ID';
   pay_mag_tape.internal_cxt_values(6)  := g_org_payment_method_id;
   pay_mag_tape.internal_cxt_names(7)   := 'TAX_UNIT_ID';
   pay_mag_tape.internal_cxt_values(7)  := TO_CHAR(g_legal_company_id);

   -- Parameter Setup for NACHA_ENTRY_DETAIL
   -- First parameter value is number of parameters
   -- second parameter value is formula id

   hr_utility.trace('.... Writing Entry Detail Parameters');

   pay_mag_tape.internal_prm_values(1)    := '11';
   pay_mag_tape.internal_prm_values(2)    := g_entry_detail;

   -- Parameters 3-6 are transferred from previous formula
   -- 3 - TRANSFER_THIRD_PARTY
   -- 4 - TRANSFER_ENTRY_COUNT
   -- 5 - TRANSFER_ENTRY_HASH
   -- 6 - TRANSFER_CREDIT_AMOUNT
   pay_mag_tape.internal_prm_names(7)     := 'TRANSFER_PAY_VALUE';
   pay_mag_tape.internal_prm_values(7)    := fnd_number.number_to_canonical(v_amount);

   pay_mag_tape.internal_prm_names(8)     := 'TRANSFER_PREPAYMENT_ID';
   pay_mag_tape.internal_prm_values(8)    := TO_CHAR(v_prepayment_id);

   -- Parameter 9 is transferred from previous formula - TRANSFER_ORG_PAY_TOT

   pay_mag_tape.internal_prm_names(10)     := 'TRACE_SEQUENCE_NUMBER';
   pay_mag_tape.internal_prm_values(10)    := TO_CHAR(g_count);

   pay_mag_tape.internal_prm_names(11)    := 'TEST_FILE';
   pay_mag_tape.internal_prm_values(11)   := g_test_file;

   hr_utility.set_location('run_formula.Assignment',7);
   IF g_temp_count = 0 THEN
      -- If this is the first entry detail of a batch, reset these
      -- parameters.
      pay_mag_tape.internal_prm_names(4)     := 'TRANSFER_ENTRY_COUNT';
      pay_mag_tape.internal_prm_values(4)    := '0';
      pay_mag_tape.internal_prm_names(5)     := 'TRANSFER_ENTRY_HASH';
      pay_mag_tape.internal_prm_values(5)    := '0';
      pay_mag_tape.internal_prm_names(6)     := 'TRANSFER_CREDIT_AMOUNT';
      pay_mag_tape.internal_prm_values(6)    := '0';
      pay_mag_tape.internal_prm_names(9)     := 'TRANSFER_ORG_PAY_TOT';
      pay_mag_tape.internal_prm_values(9)    := '0';

      g_temp_count      := 1;
      hr_utility.set_location('run_formula.Assignment',8);
   END IF;

   IF g_csr_org_pay_third_party = 'Y' THEN
      g_addenda_write := 'Y';
   ELSE
      g_addenda_write := 'N';
   END IF;

   -- Update PRENOTE Date
   if v_amount = 0 then
      update PAY_EXTERNAL_ACCOUNTS a
      set    a.PRENOTE_DATE = nvl(to_date(g_direct_dep_date,'YYMMDD'),
                                        g_effective_date)
      where  a.PRENOTE_DATE is null
      and    a.EXTERNAL_ACCOUNT_ID =
                  ( select b.EXTERNAL_ACCOUNT_ID
                    from   PAY_PERSONAL_PAYMENT_METHODS_F b
                    where  b.PERSONAL_PAYMENT_METHOD_ID =
                                        g_personal_payment_method_id
                     and    g_effective_date between b.EFFECTIVE_START_DATE
                                                 and b.EFFECTIVE_END_DATE);
   end if;


   hr_utility.trace('Leaving Entry Detail');

END; /* write_entry_detail */

/******************************************************************
   NAME
       write_addenda
   DESCRIPTION
       Writes the Addenda Record .
   NOTES
       Local function.
********************************************************************/


PROCEDURE write_addenda IS

BEGIN

   hr_utility.trace('Writing Addenda');

   g_addenda_write := 'N';

   get_third_party_details(
       fnd_number.canonical_to_number(get_transfer_param('TRANSFER_PAY_VALUE')),
       fnd_number.canonical_to_number(get_transfer_param('TRANSFER_PREPAYMENT_ID')),
       v_payment_date,
       v_attach_number,
       v_fips_code,
       v_med_ind);

   hr_utility.trace('.... Writing Addenda Context');

   -- Context Setup for NACHA_ADDENDA
   -- First context value is number of Context Values

   pay_mag_tape.internal_cxt_values(1)  := '7';
   pay_mag_tape.internal_cxt_names(2)   := 'ASSIGNMENT_ID';
   pay_mag_tape.internal_cxt_values(2)  := TO_CHAR(g_assignment_id);
   pay_mag_tape.internal_cxt_names(3)   := 'ASSIGNMENT_ACTION_ID';
   pay_mag_tape.internal_cxt_values(3)  := TO_CHAR(g_assignment_action_id);
   pay_mag_tape.internal_cxt_names(4)   := 'DATE_EARNED';
   pay_mag_tape.internal_cxt_values(4)  := fnd_date.date_to_canonical(g_effective_date);
   pay_mag_tape.internal_cxt_names(5)   := 'PER_PAY_METHOD_ID';
   pay_mag_tape.internal_cxt_values(5)  := to_char(g_personal_payment_method_id);
   pay_mag_tape.internal_cxt_names(6)   := 'ORG_PAY_METHOD_ID';
   pay_mag_tape.internal_cxt_values(6)  := g_org_payment_method_id;
   pay_mag_tape.internal_cxt_names(7)   := 'TAX_UNIT_ID';
   pay_mag_tape.internal_cxt_values(7)  := TO_CHAR(g_legal_company_id);

   hr_utility.trace('.... Writing Addenda Parameters');

   -- Parameter Setup for NACHA_ADDENDA
   -- First Parameter Value is number of parameters
   pay_mag_tape.internal_prm_values(1)  := '14';
   -- second is formula id
   pay_mag_tape.internal_prm_values(2)  := g_addenda;

   -- Parameters 3-6 are transferred from previous formula
   -- 3 - TRANSFER_THIRD_PARTY
   -- 4 - TRANSFER_ENTRY_COUNT
   -- 5 - TRANSFER_ENTRY_HASH
   -- 6 - TRANSFER_CREDIT_AMOUNT

   pay_mag_tape.internal_prm_names(8)   := 'TRACE_SEQUENCE_NUMBER';
   pay_mag_tape.internal_prm_values(8)  := TO_CHAR(g_count);

   -- Parameter 9 is transferred from previous formula - TRANSFER_ORG_PAY_TOT

   pay_mag_tape.internal_prm_names(10)   := 'FIPS_CODE';
   pay_mag_tape.internal_prm_values(10)  := v_fips_code;
   pay_mag_tape.internal_prm_names(11)  := 'MEDICAL_INDICATOR';
   pay_mag_tape.internal_prm_values(11) := v_med_ind;
   pay_mag_tape.internal_prm_names(12)  := 'REFERENCE_NUMBER';
   pay_mag_tape.internal_prm_values(12) := v_attach_number;
   pay_mag_tape.internal_prm_names(13)  := 'PAY_DATE';
   pay_mag_tape.internal_prm_values(13) := to_char(v_payment_date,'YYMMDD');

   pay_mag_tape.internal_prm_names(14)  := 'TEST_FILE';
   pay_mag_tape.internal_prm_values(14) := g_test_file;


   -- we do not change the count till after so we can have the same trace number
   -- in both entry detail and addenda rec

   g_addenda_count := g_addenda_count + 1;
   hr_utility.trace('Leaving Addenda');

END; /* write_addenda */

/******************************************************************
   NAME
       write_org_entry_detail
   DESCRIPTION
       Writes the Org Entry Detail Record .
   NOTES
       Local function.
********************************************************************/


PROCEDURE write_org_entry_detail IS

BEGIN

   hr_utility.trace('Writing Org Entry Detail');

   If g_nacha_balance_flag = 'Y' then

      g_count  := g_count  + 1;

   end if;
   g_batch_control_write := 'Y';

   if g_overflow_flag = 'Y' then
      g_overflow_flag := 'N';
      g_overflow_batch := 'Y';
   end if;

   -- Context Setup for NACHA_ORG_PAY_ENTRY_DETAIL
   -- first context is number of context values
   hr_utility.trace('.... Writing Org Entry Detail Context');

   pay_mag_tape.internal_cxt_values(1)  := '3';
   pay_mag_tape.internal_cxt_names(2)   := 'ORG_PAY_METHOD_ID';
   pay_mag_tape.internal_cxt_values(2)  := g_csr_org_pay_meth_id;
   pay_mag_tape.internal_cxt_names(3)   := 'DATE_EARNED';
   pay_mag_tape.internal_cxt_values(3)  := fnd_date.date_to_canonical(g_effective_date);

  -- Parameter Setup for NACHA_ORG_PAY_ENTRY_DETAIL
  -- first parameter is number of parameters
  -- second parameter is formula is
   hr_utility.trace('.... Writing Org Entry Detail Parameters');

  pay_mag_tape.internal_prm_values(1)   := '10';
  pay_mag_tape.internal_prm_values(2)   := g_org_pay_entry_detail;

  -- Parameters 3-6 are transferred from previous formula
  -- 3 - TRANSFER_THIRD_PARTY
  -- 4 - TRANSFER_ENTRY_COUNT
  -- 5 - TRANSFER_ENTRY_HASH
  -- 6 - TRANSFER_CREDIT_AMOUNT

  pay_mag_tape.internal_prm_names(8)    := 'TRACE_SEQUENCE_NUMBER';
  pay_mag_tape.internal_prm_values(8)   := TO_CHAR(g_count);

  -- Parameter 9 is transferred from previous formula - TRANSFER_ORG_PAY_TOT

   pay_mag_tape.internal_prm_names(10)   := 'TEST_FILE';
   pay_mag_tape.internal_prm_values(10)  := g_test_file;


-- Bug 3331019
   if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
      CLOSE csr_assignments;
   else
      CLOSE csr_assignments_no_rule;
   end if;
  hr_utility.set_location('run_formula.org_pay_entry_detail',9);

  hr_utility.trace('Leaving Org Entry Detail');

END; /* write_org_entry_detail */


/******************************************************************
   NAME
       write_batch_control
   DESCRIPTION
       Writes the Batch Control Record .
   NOTES
       Local function.
********************************************************************/


PROCEDURE write_batch_control IS

BEGIN
   hr_utility.trace('Writing Batch Control');

   g_batch_control_write := 'N';

   g_hash   := g_hash   + get_transfer_param ('TRANSFER_ENTRY_HASH');
   g_amount := g_amount + get_transfer_param ('TRANSFER_CREDIT_AMOUNT');

   -- Context Setup for NACHA_BATCH_CONTROL
   -- First context value is number of context values

  hr_utility.trace('.... Writing Batch Control Context');

  pay_mag_tape.internal_cxt_values(1)    := '4';
  pay_mag_tape.internal_cxt_names(2)     := 'TAX_UNIT_ID';
  pay_mag_tape.internal_cxt_values(2)    := TO_CHAR(g_legal_company_id);
  pay_mag_tape.internal_cxt_names(3)     := 'DATE_EARNED';
  pay_mag_tape.internal_cxt_values(3)    := fnd_date.date_to_canonical(g_effective_date);
  pay_mag_tape.internal_cxt_names(4)     := 'ORG_PAY_METHOD_ID';
  pay_mag_tape.internal_cxt_values(4)    := g_org_payment_method_id;

  -- Parameter Setup for NACHA_BATCH_CONTROL
  -- First parameter value is number of parameters

   hr_utility.trace('.... Writing Batch Control Parameters');

  pay_mag_tape.internal_prm_values(1)    := '7';
  pay_mag_tape.internal_prm_values(2)    := g_batch_control;

  -- Parameters 4-7 are transferred from previous formula
  -- 3 - TRANSFER_ENTRY_COUNT
  -- 4 - TRANSFER_ENTRY_HASH
  -- 5 - TRANSFER_CREDIT_AMOUNT
  -- 6 - TRANSFER_THIRD_PARTY

  pay_mag_tape.internal_prm_names(7)     := 'BATCH_NUMBER';
  pay_mag_tape.internal_prm_values(7)    := TO_CHAR(g_batch_number);

  hr_utility.set_location('run_formula.Batch_ctrl',9);

  hr_utility.trace('Leaving Batch Control');

END; /* write_batch_control */


/******************************************************************
   NAME
       write_file_control
   DESCRIPTION
       Writes the File Control Record .
   NOTES
       Local function.
********************************************************************/

PROCEDURE write_file_control IS

BEGIN

   hr_utility.trace('Writing File Control');

   v_block_count := CEIL(((2 * g_batch_number ) +
                           g_count + g_addenda_count + 2)/10);
   g_pad_count   := (v_block_count * 10) -
                    ((2 * g_batch_number ) +
                     g_count + g_addenda_count + 2);

   hr_utility.trace('.... Writing File Control Context');

   -- dscully - added contexts for NACHA_BALANCED_NACHA_FILE DBI
   pay_mag_tape.internal_cxt_values(1)  := '3';
   pay_mag_tape.internal_cxt_names(2)   := 'ORG_PAY_METHOD_ID';
   pay_mag_tape.internal_cxt_values(2)  := g_org_payment_method_id;
   pay_mag_tape.internal_cxt_names(3)   := 'DATE_EARNED';
   pay_mag_tape.internal_cxt_values(3)  := fnd_date.date_to_canonical(g_effective_date);

   hr_utility.trace('.... Writing File Control Parameters');

   pay_mag_tape.internal_prm_values(1)  := '8';
   pay_mag_tape.internal_prm_values(2)  := g_file_control;
   pay_mag_tape.internal_prm_names(3)   := 'BATCH_NUMBER';
   pay_mag_tape.internal_prm_values(3)  := TO_CHAR(g_batch_number);
   pay_mag_tape.internal_prm_names(4)   := 'BLOCK_COUNT';
   pay_mag_tape.internal_prm_values(4)  := TO_CHAR(v_block_count);
   pay_mag_tape.internal_prm_names(5)   := 'FILE_ENTRY_COUNT';
   pay_mag_tape.internal_prm_values(5)  := TO_CHAR(g_count + g_addenda_count);
   pay_mag_tape.internal_prm_names(6)   := 'FILE_ENTRY_HASH';
   pay_mag_tape.internal_prm_values(6)  := TO_CHAR(g_hash);
   pay_mag_tape.internal_prm_names(7)   := 'FILE_CREDIT_AMOUNT';
   pay_mag_tape.internal_prm_values(7)  := fnd_number.number_to_canonical(g_amount);
   pay_mag_tape.internal_prm_names(8)   := 'TRANSFER_PAD_COUNT';
   pay_mag_tape.internal_prm_values(8)  := TO_CHAR(g_pad_count);
--
   hr_utility.set_location('run_formula.File_Control',11);
   hr_utility.trace('Leaving File Control');

END; /* write_file_control */


/******************************************************************
   NAME
       write_padding
   DESCRIPTION
       Writes the Padding Record .
   NOTES
       Local function.
********************************************************************/
PROCEDURE write_padding IS

BEGIN

   hr_utility.trace('Writing Padding');

   hr_utility.trace('.... Writing Padding Context');
   pay_mag_tape.internal_cxt_values(1)   := '1';

   hr_utility.trace('.... Writing Padding Parameters');

   pay_mag_tape.internal_prm_values(1)   := '3';
   pay_mag_tape.internal_prm_values(2)   := g_padding;
   pay_mag_tape.internal_prm_names(3)    := 'TRANSFER_PAD_COUNT';
   pay_mag_tape.internal_prm_values(3)   := TO_CHAR(g_pad_count);

   hr_utility.set_location('run_formula.padding',12);
   IF g_pad_count = 1 THEN
      CLOSE csr_nacha_batch;
   ELSE
      g_pad_count := g_pad_count - 1;
   END IF;

   hr_utility.trace('Leaving Padding');

END; /* write_padding */

/*****************************END of Local Functions ****************/


BEGIN
   hr_utility.trace('Entering pay_us_nacha_tape.run_formula');
   pay_mag_tape.internal_prm_names(1)    := 'NO_OF_PARAMETERS';
   pay_mag_tape.internal_prm_names(2)    := 'NEW_FORMULA_ID';
   pay_mag_tape.internal_prm_values(1)   := '2';

   pay_mag_tape.internal_cxt_names(1)  := 'NUMBER_OF_CONTEXT';
   pay_mag_tape.internal_cxt_values(1) := '1';
   hr_utility.set_location('pay_us_nacha_tape.run_formula',1);

   hr_utility.set_location ('run_formula loop',1);

--Checking If the transaction is IAT
		IF g_foreign_transact = 'Y' then
			--Call the new package for IAT
								pay_us_nacha_iat_tape.run_formula (g_business_group_id,
													   g_effective_date,
                                                       g_direct_dep_date,
                                                       g_org_payment_method_id,
                                                       g_csr_org_pay_third_party,
                                                       g_file_id_modifier,
                                                       g_test_file,
																											 g_payroll_id);
		ELSE

   /****************Level 1.1 The first major if clause ***************/
   IF NOT csr_nacha_batch%ISOPEN and g_business_group_id is NULL THEN
   /* main */

      hr_utility.set_location('run_formula.Init',5);
      g_payroll_action_id := fnd_number.canonical_to_number(
                                 pay_mag_tape.internal_prm_values(3));

      /* Select all the relevent information using payroll action id */
      select ppa.business_group_id,
             ppa.effective_date,
             to_char(ppa.overriding_dd_date,'YYMMDD'),
             ppa.org_payment_method_id,
             ppa.legislative_parameters,
             decode(nvl(to_char(opm.defined_balance_id),'Y'),'Y','Y','N'),
						 ppa.payroll_id
        into g_business_group_id,
             g_effective_date,
             g_direct_dep_date,
             g_org_payment_method_id,
             g_legislative_parameters,
             g_csr_org_pay_third_party,
						 g_payroll_id
        from pay_payroll_actions ppa,
             pay_org_payment_methods_f opm
       where ppa.payroll_action_id = g_payroll_action_id
         and opm.ORG_PAYMENT_METHOD_ID = ppa.org_payment_method_id
         and ppa.effective_date between opm.EFFECTIVE_START_DATE
                                    and opm.EFFECTIVE_END_DATE;
      if SQL%NOTFOUND then
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','pay_us_nacha_tape');
         hr_utility.set_message_token('STEP','1');
         hr_utility.raise_error;
      end if;

      /* Set The default to Zero */
      g_file_id_modifier      := '0';
      if g_legislative_parameters is not null then

         -- get the FILE_ID_MODIFIER
         if INSTR(g_legislative_parameters,'FILE_ID_MODIFIER=') <> 0  then
            g_file_id_modifier := SUBSTR(g_legislative_parameters,
                                      INSTR(g_legislative_parameters,
                                            'FILE_ID_MODIFIER=')
                                       + Length('FILE_ID_MODIFIER='), 1 );
         end if;

         -- Get the Test File indicator.
         if INSTR(g_legislative_parameters,'TEST_FILE=') <> 0  then
            g_test_file := SUBSTR(g_legislative_parameters,
                                    INSTR(g_legislative_parameters,
                                            'TEST_FILE=')
                                       + Length('TEST_FILE='), 1 );
         end if;


				 if INSTR(g_legislative_parameters,'FOREIGN_TRANSACT=') <> 0  then
            g_foreign_transact := SUBSTR(g_legislative_parameters,
                                    INSTR(g_legislative_parameters,
                                            'FOREIGN_TRANSACT=')
                                       + Length('FOREIGN_TRANSACT='), 1 );
         end if;

      end if;

			hr_utility.trace('g_foreign_transact: ' || g_foreign_transact);

            --Checking If the transaction is IAT
 			IF g_foreign_transact = 'Y' then
                --Call the new package for IAT
					pay_us_nacha_iat_tape.run_formula (g_business_group_id,
													   g_effective_date,
                                                       g_direct_dep_date,
                                                       g_org_payment_method_id,
                                                       g_csr_org_pay_third_party,
                                                       g_file_id_modifier,
                                                       g_test_file,
																											 g_payroll_id);
			ELSE
      g_company_entry_desc    := 'SALARY';
      g_descriptive_date      := g_date;


      -- Intialize global varibles
      g_temp_count := 0;  /* Flag to initialize batch running totals */
      g_pad_count := -1;  /* Number of times the padding formula called */


      -- Get all the formula id's in the global variable.
      g_file_header           := get_formula_id('NACHA_FILE_HEADER');
      g_batch_header          := get_formula_id('NACHA_BATCH_HEADER');
      g_entry_detail          := get_formula_id('NACHA_ENTRY_DETAIL');
      g_addenda		     := get_formula_id('NACHA_ADDENDA');
      g_org_pay_entry_detail  := get_formula_id('NACHA_ORG_PAY_ENTRY_DETAIL');
      g_batch_control         := get_formula_id('NACHA_BATCH_CONTROL');
      g_file_control          := get_formula_id('NACHA_FILE_CONTROL');
      g_padding               := get_formula_id('NACHA_PADDING');


      -- If Org payment method is supplied then use it for getting SCL FLEX
      -- information otherwise use business group for to get the information.
      --
      IF g_org_payment_method_id is null THEN
         OPEN csr_org_flex_info (g_business_group_id,
                                 g_payroll_action_id);
         FETCH csr_org_flex_info INTO g_org_payment_method_id,
                                      g_csr_org_pay_third_party;
         CLOSE csr_org_flex_info;
      END IF;

      IF g_org_payment_method_id is not null THEN
         hr_utility.trace('g_org_payment_method_id = '   ||
                                   g_org_payment_method_id);
         hr_utility.trace('g_csr_org_pay_third_party = ' ||
                                   g_csr_org_pay_third_party);
         write_file_header;
      ELSE
         hr_utility.set_message(801, 'HR_7711_SCL_FLEX_NOT_FOUND');
         hr_utility.raise_error;
      END IF;

      OPEN csr_nacha_batch(g_business_group_id,g_payroll_action_id);

			END IF;

/****************Level 1.2 The second major else if clause ***************/
   ELSE /* main */

     hr_utility.set_location ('run_formula loop',2);

     IF g_addenda_write = 'Y' THEN

        write_addenda;

     ELSIF g_batch_control_write = 'Y' THEN

           write_batch_control;

-- Bug 3331019
     ELSIF (csr_assignments%ISOPEN OR csr_assignments_no_rule%ISOPEN) THEN
       if (nvl(hr_general2.get_oracle_db_version, 0) < 10.0) then
          FETCH csr_assignments INTO g_assignment_id,g_assignment_action_id,
                                     v_amount, g_personal_payment_method_id,
                                     v_prepayment_id,g_rowid;
          IF csr_assignments%FOUND THEN


            IF v_amount > 99999999.99 THEN
                hr_utility.set_message(801,'PAY_US_PAYMENT_OVERFLOW');
                pay_core_utils.push_message(801,'PAY_US_PAYMENT_OVERFLOW','P');
                pay_core_utils.push_token('ASSIGNMENT_NO',g_assignment_id);
                raise_application_error(-20101, 'Error in pay_us_nacha_tape.run_formula');

             END IF ;


             g_overflow_amount := g_overflow_amount + v_amount;

             hr_utility.trace('G_OVERFLOW_AMOUNT is : '|| g_overflow_amount);
             hr_utility.trace('G_ROWID value is : '|| g_rowid);

             if g_overflow_amount > 99999999.99 then
                g_overflow_amount := 0;
                g_overflow_flag := 'Y';
                write_org_entry_detail;
             else
                write_entry_detail;
             end if;

          ELSE   /* setup context and params for NACHA_ORG_PAY_ENTRY_DETAIL */

            write_org_entry_detail;

          END IF;
       else
          FETCH csr_assignments_no_rule INTO g_assignment_id,g_assignment_action_id,
                                             v_amount, g_personal_payment_method_id,
                                             v_prepayment_id,g_rowid;
          IF csr_assignments_no_rule%FOUND THEN

             g_overflow_amount := g_overflow_amount + v_amount;

             IF  v_amount > 99999999.99 THEN
                hr_utility.set_message(801,'PAY_US_PAYMENT_OVERFLOW');
                pay_core_utils.push_message(801,'PAY_US_PAYMENT_OVERFLOW','P');
                pay_core_utils.push_token('ASSIGNMENT_NO',g_assignment_id);
                raise_application_error(-20101, 'Error in pay_us_nacha_tape.run_formula');
             END IF;

             hr_utility.trace('G_OVERFLOW_AMOUNT is : '|| g_overflow_amount);
             hr_utility.trace('G_ROWID value is : '|| g_rowid);

             if g_overflow_amount > 99999999.99 then
                g_overflow_amount := 0;
                g_overflow_flag := 'Y';
                write_org_entry_detail;
             else
                write_entry_detail;
             end if;

          ELSE   /* setup context and params for NACHA_ORG_PAY_ENTRY_DETAIL */

            write_org_entry_detail;

          END IF;
       end if; /* nvl(hr_general2.get_oracle_db_version, 0) < 10.0 */

/****************Level 1.3 The third  major else if clause ***************/

     ELSE /* g_addenda_write = 'Y' */

        hr_utility.trace('g_overflow_batch flag is : '|| g_overflow_batch);

        IF g_overflow_batch = 'Y' then
           write_batch_header;
        ELSE /* g_overflow_batch */

           FETCH csr_nacha_batch INTO g_csr_org_pay_meth_id,
                                      g_csr_org_pay_third_party,
				      g_legal_company_id,
                                      g_nacha_balance_flag;
           IF csr_nacha_batch %FOUND THEN

              /* to reset rowid when GRE changes. Bug 1967949 */
              hr_utility.trace('b4 g_legal_company_id is : ' || g_legal_company_id);
              hr_utility.trace('b4 g_reset_greid is : ' || g_reset_greid);
              hr_utility.trace('b4 g_rowid is : ' || g_rowid);

              IF g_reset_greid <> g_legal_company_id then

                 g_rowid := null;
                 g_reset_greid := g_legal_company_id;

              END IF;

              hr_utility.trace('a4 g_legal_company_id is : ' || g_legal_company_id);
              hr_utility.trace('a4 g_reset_greid is : ' || g_reset_greid);
              hr_utility.trace('a4 g_rowid is : ' || g_rowid);

              /* to reset rowid when GRE changes. Bug 1967949 */


              write_batch_header;

           ELSE  /* We'll kick off the Nacha_file_control stuff */

              IF g_pad_count = -1 THEN

                 write_file_control;

              ELSIF g_pad_count > 0 THEN

                 write_padding;

              END IF;
           END IF; /* csr_nacha_batch %FOUND */
       END IF; /* g_overflow_batch */
     END IF; /* g_addenda_write = 'Y' */
   END IF;  /* main */
END IF;

END run_formula;
/* Bug 5098064 : Added for supporting EFT reconciliation */

FUNCTION f_get_batch_transact_ident(p_effective_date	DATE,
					   p_identifier_name		VARCHAR2,
					   p_payroll_action_id		NUMBER,
					   p_payment_type_id		NUMBER,
					   p_org_payment_method_id	NUMBER,
					   p_personal_payment_method_id	NUMBER,
					   p_assignment_action_id	NUMBER,
					   p_pre_payment_id		NUMBER,
					   p_delimiter_string   	VARCHAR2)
RETURN VARCHAR2
IS

CURSOR csr_get_payee_bank_details IS
SELECT pea.segment1,pea.segment3,pea.segment5,pea.segment6
FROM   pay_external_accounts pea, pay_personal_payment_methods_f ppm,
       pay_payroll_actions ppa
WHERE  ppa.payroll_action_id = p_payroll_action_id
AND    ppm.personal_payment_method_id = p_personal_payment_method_id
AND    ppa.effective_date BETWEEN ppm.effective_start_date AND ppm.effective_end_date
AND    pea.external_account_id (+) = ppm.external_account_id;

lr_bank_detail_rec	csr_get_payee_bank_details%ROWTYPE;

CURSOR csr_get_transact_date IS
SELECT to_char(ppa.effective_date,'YYYY/MM/DD') effective_date,
       to_char(ppa.overriding_dd_date,'YYYY/MM/DD') overriding_dd_date
FROM   pay_payroll_actions ppa, pay_org_payment_methods_f opm, pay_assignment_actions paa
WHERE  ppa.payroll_action_id = p_payroll_action_id
AND    opm.org_payment_method_id = ppa.org_payment_method_id
AND    opm.org_payment_method_id = p_org_payment_method_id
AND    ppa.effective_date BETWEEN opm.effective_start_date AND opm.effective_end_date
AND    ppa.payroll_action_id = paa.payroll_action_id
AND    paa.assignment_action_id = p_assignment_action_id;

lr_transact_date_rec	csr_get_transact_date%ROWTYPE;

CURSOR csr_get_batch_no IS
SELECT ppp.org_payment_method_id, hou.organization_id, paa.assignment_action_id
FROM   pay_pre_payments ppp, pay_org_payment_methods_f opm,
       hr_organization_units hou, hr_organization_information hoi,
       pay_payroll_actions ppa, pay_assignment_actions paa
WHERE  opm.org_payment_method_id = ppp.org_payment_method_id
AND    opm.org_payment_method_id = ppa.org_payment_method_id
AND    opm.org_payment_method_id = p_org_payment_method_id
AND    ppa.payroll_action_id = p_payroll_action_id
AND    ppa.effective_date BETWEEN opm.effective_start_date AND opm.effective_end_date
AND    hou.business_group_id = ppa.business_group_id
AND    opm.business_group_id = ppa.business_group_id
AND    hou.organization_id = hoi.organization_id
AND    hoi.org_information_context = 'CLASS'
AND    hoi.org_information1 = 'HR_LEGAL'
AND    hoi.org_information2 = 'Y'
AND    paa.payroll_action_id = ppa.payroll_action_id
AND    paa.tax_unit_id = hou.organization_id
AND    paa.pre_payment_id = ppp.pre_payment_id
AND    EXISTS
       ( SELECT 1
         FROM  per_assignments_f paf
         WHERE paf.assignment_id = paa.assignment_id
         AND   ppa.effective_date BETWEEN paf.effective_start_date and paf.effective_end_date
       )
ORDER BY ppp.org_payment_method_id, hou.organization_id;

lr_batch_no		csr_get_batch_no%ROWTYPE;

CURSOR csr_get_conc_ident IS
SELECT flv.meaning
FROM fnd_lookup_types flt, fnd_lookup_values flv
WHERE flt.lookup_type = 'PAYMENT_TRX_CONC_IDENTS'
AND flt.application_id = (SELECT application_id FROM fnd_application
				WHERE application_short_name = 'PAY')
AND flt.lookup_type = flv.lookup_type
AND flv.lookup_code = 'NACHA'
AND flv.language = 'US'
AND flv.enabled_flag = 'Y'
AND sysdate between flv.start_date_active and nvl(flv.end_date_active, sysdate);

lr_conc_ident		csr_get_conc_ident%ROWTYPE;

ln_org_pay_method_id	pay_pre_payments.org_payment_method_id%TYPE := -1;
ln_org_id		hr_organization_units.organization_id%TYPE  := -1;
ln_batch_number		NUMBER(5) := 0;
lv_return_value		VARCHAR2(80) := NULL;

TYPE lt_identifier_rec_type IS RECORD (ident_name fnd_lookup_values.meaning%TYPE,
				       ident_position NUMBER);
lt_identifier_rec	lt_identifier_rec_type;

TYPE lt_identifier_rec_table IS TABLE OF lt_identifier_rec_type INDEX BY BINARY_INTEGER;
lt_identifier_table	lt_identifier_rec_table;

counter			NUMBER(5) := 1;

CURSOR csr_get_conc_ident_values IS
SELECT opm.pmeth_information3, hoi.org_information4
FROM pay_org_payment_methods_f opm, pay_payroll_actions ppa,
     pay_assignment_actions paa, hr_organization_information hoi
WHERE ppa.payroll_action_id = p_payroll_action_id
AND ppa.effective_date BETWEEN opm.effective_start_date AND opm.effective_end_date
AND ppa.org_payment_method_id = opm.org_payment_method_id
AND ppa.payment_type_id = opm.payment_type_id
and ppa.payroll_action_id = paa.payroll_action_id
and paa.assignment_action_id = p_assignment_action_id
and paa.tax_unit_id = hoi.organization_id
and hoi.org_information_context = 'NACHA Rules';

lr_conc_ident_values	csr_get_conc_ident_values%ROWTYPE;
lb_add_delimiter	BOOLEAN := FALSE;

BEGIN

   IF UPPER(p_identifier_name) IN ('PAYEE_BANK_BRANCH','PAYEE_BANK_NAME',
				   'PAYEE_BANK_ACCOUNT_NAME', 'PAYEE_BANK_ACCOUNT_NUMBER') THEN

      OPEN csr_get_payee_bank_details;
      FETCH csr_get_payee_bank_details INTO lr_bank_detail_rec;

      IF csr_get_payee_bank_details%FOUND THEN
         IF UPPER(p_identifier_name) = 'PAYEE_BANK_BRANCH' THEN
            lv_return_value := substr(lr_bank_detail_rec.segment6,1,80);
	 ELSIF UPPER(p_identifier_name) = 'PAYEE_BANK_NAME' THEN
            lv_return_value := substr(lr_bank_detail_rec.segment5,1,80);
         ELSIF UPPER(p_identifier_name) = 'PAYEE_BANK_ACCOUNT_NAME' THEN
            lv_return_value := substr(lr_bank_detail_rec.segment1,1,80);
         ELSIF UPPER(p_identifier_name) = 'PAYEE_BANK_ACCOUNT_NUMBER' THEN
            lv_return_value := substr(lr_bank_detail_rec.segment3,1,80);
         END IF;
       ELSE
          lv_return_value := NULL;
       END IF;

       CLOSE csr_get_payee_bank_details;

   ELSIF UPPER(p_identifier_name) = 'TRANSACTION_DATE' THEN

      OPEN csr_get_transact_date;
      FETCH csr_get_transact_date INTO lr_transact_date_rec;

      IF csr_get_transact_date%FOUND THEN
         lv_return_value := NVL(lr_transact_date_rec.overriding_dd_date,
						lr_transact_date_rec.effective_date);
      ELSE
          lv_return_value := NULL;
      END IF;

      CLOSE csr_get_transact_date;

   ELSIF UPPER(p_identifier_name) = 'TRANSACTION_GROUP' THEN

      OPEN csr_get_batch_no;
      LOOP
         FETCH csr_get_batch_no INTO lr_batch_no;
	 EXIT WHEN csr_get_batch_no%NOTFOUND;

	 IF ( (lr_batch_no.org_payment_method_id <> ln_org_pay_method_id) OR
						(lr_batch_no.organization_id <> ln_org_id) ) THEN

	    ln_org_pay_method_id := lr_batch_no.org_payment_method_id;
	    ln_org_id := lr_batch_no.organization_id;
	    ln_batch_number := ln_batch_number + 1;

	 END IF;

	 IF (lr_batch_no.assignment_action_id = p_assignment_action_id) THEN
	    EXIT;
	 END IF;

      END LOOP;

      IF (lr_batch_no.assignment_action_id = p_assignment_action_id) THEN
         lv_return_value := TO_CHAR((p_payroll_action_id * 1000000000) + TO_NUMBER(RPAD(ln_batch_number,6,'0')));
      END IF;

      CLOSE csr_get_batch_no;

   ELSIF UPPER(p_identifier_name) = 'CONCATENATED_IDENTIFIERS' THEN

      OPEN csr_get_conc_ident;
      FETCH csr_get_conc_ident INTO lr_conc_ident;
      CLOSE csr_get_conc_ident;

      lt_identifier_table(counter).ident_name := 'File Id';
      lt_identifier_table(counter).ident_position := counter;

      counter := counter + 1;

      lt_identifier_table(counter).ident_name := 'Company Id';
      lt_identifier_table(counter).ident_position := counter;

      FOR counter IN lt_identifier_table.FIRST..lt_identifier_table.LAST
      LOOP
         lt_identifier_table(counter).ident_position := INSTR(lr_conc_ident.meaning,
								lt_identifier_table(counter).ident_name);
      END LOOP;

      FOR counter IN 1..lt_identifier_table.COUNT
      LOOP
         FOR i IN lt_identifier_table.FIRST..(lt_identifier_table.LAST-1)
	 LOOP
	    IF lt_identifier_table(i).ident_position > lt_identifier_table(i+1).ident_position THEN
	       lt_identifier_rec := lt_identifier_table(i);
	       lt_identifier_table(i) := lt_identifier_table(i+1);
	       lt_identifier_table(i+1) := lt_identifier_rec;
	    END IF;

	 END LOOP;

      END LOOP;

      FOR counter IN lt_identifier_table.FIRST..lt_identifier_table.LAST
      LOOP
	IF lt_identifier_table(counter).ident_name = 'File Id' THEN

	   OPEN csr_get_conc_ident_values;
	   FETCH csr_get_conc_ident_values INTO lr_conc_ident_values;
	   CLOSE csr_get_conc_ident_values;

	   IF lb_add_delimiter THEN
	      lv_return_value := lv_return_value || p_delimiter_string || UPPER(LPAD(lr_conc_ident_values.pmeth_information3,10,' '));
	   ELSE
	      lv_return_value := UPPER(LPAD(lr_conc_ident_values.pmeth_information3,10,' '));
	   END IF;

	   lb_add_delimiter := TRUE;

	ELSIF lt_identifier_table(counter).ident_name = 'Company Id' THEN

	   OPEN csr_get_conc_ident_values;
	   FETCH csr_get_conc_ident_values INTO lr_conc_ident_values;
	   CLOSE csr_get_conc_ident_values;

	   IF lb_add_delimiter THEN
	      lv_return_value := lv_return_value || p_delimiter_string || UPPER(RPAD(lr_conc_ident_values.org_information4,10,' '));
	   ELSE
	      lv_return_value := UPPER(RPAD(lr_conc_ident_values.org_information4,10,' '));
	   END IF;

	   lb_add_delimiter := TRUE;

	END IF;

      END LOOP;

   END IF;

RETURN lv_return_value;

END f_get_batch_transact_ident;

--BEGIN
--  hr_utility.trace_on(null, 'NACHA');
END pay_us_nacha_tape;

/
