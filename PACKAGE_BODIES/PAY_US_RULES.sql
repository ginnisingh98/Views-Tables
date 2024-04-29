--------------------------------------------------------
--  DDL for Package Body PAY_US_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_RULES" AS
/* $Header: pyusrule.pkb 120.24.12010000.13 2010/03/23 05:30:37 sjawid ship $ */
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

   Change History
   ---------------------

   Date        Name       Vers    Bug No   Description
   ----------- ---------- ------  -------  ------------------------------------
   19-Mar-2010 sjawid     115.53  9488426  Reverted back the changes made for Third party
					   payments of bug 9382065 as this issue is now
					   handling in pay_xml_extract_pkg.
   03-Mar-2010 sjawid     115.51  9439388  Added cursor get_net_pay_dstr_details at add
                                           _custom_xml procedure to get
                                           employee net pay distribution details for US PDF
					   payslip.
   24-Feb-2010 sjawid     115.50  9382065  Added cursor get_tp_check_num at add
                                           _custom_xml procedure to get
                                           Third party check number for US PDF
					   payslip.
   16-Feb-2010 sjawid     115.48  9382065  Modified add_custom_xml procedure for
                                           US pdf payslip enhancement.
   17-Apr-2009 sudedas    115.47  8414024  Added IN OUT parameter to function
                                           work_schedule_total_hours
   16-Mar-2009 sudedas    115.46  7660565  get_payslip_sort_order2 modified,
                                           Added ORGANIZATION_NAME.
                          115.45  7583387  Added NOCOPY hint for OUT variable.
   21-Jan-2009 sudedas    115.44  7583387  Changed Function DAxml_range_cursor
                                           to Procedure.
   15-Jan-2009 sudedas    115.43  7583387  Added 3 functions for DA(XML) -
                                           get_payslip_sort_order1
                                           get_payslip_sort_order2
                                           get_payslip_sort_order3
                                           Added payslip_range_cursor.
   28-Aug-2008 sudedas    115.42  7269477  Modified cursor get_depoadvice_deatils
                                           and get_check_depoad_details.
                                           Added effective_date Join Condition.
   5-Sep-2007  sausingh   115.41  6392875  Modified the cursor get_check_num_for_depad
   31-JUL-2007 sausingh   115.40  5635335  Added cursor to capture check details if
                                           deposit advice is run after check-writer for an
                                           assignment.
   05-JUL-2007 sausingh   115.39  5635335  Added cursors
                                            get_check_depoad_details
                                            get_preassact_id
                                            get_depoadvice_deatils
                                            To get Employer's account detail and
                                            deposit advice number in the XML
   26-JUN-2007 sausingh   115.38  5635335  Added <Chech_Amount> Tag to get the Check
                                           Amount in check writer.
   26-Jun-2007 sudedas    115.36  5635335  Modified add_custom_xml to print
                                           Check Number and Amount. Added
                                           procedure get_token_names.
   24-May-2007 sausingh   115.33  5635335  Added procedure add_custom_xml
                                           and some functions to display
                                           Net Pay Amount in Words in Archive
                                           Check Writer/Deposit Advice.
   13-MAR-2007 kvsankar   115.33   FLSA    For some scenarios, the function
                                           get_time_def_for_entry and
                                           get_time_def_for_entry_func was
                                           associating custom Time Definitions
                                           with seeded 'Regular Salary' and
                                           'Regular Wages'.
                                           Also the caching logic was
                                           modified so that it does not return
                                           seeded Time Definition(if FLSA Time
                                           Definitionis is specified) for other
                                           elements if 'Regular Salary' or
                                           'Regular Wages' happens  to be the
                                           first element to be processed.
   18-FEB-2007 kvsankar   115.32  5876883  Modified element_template_pre_process
                                  5696187  and element_template_post_process
                                           for the new template names
                                           'US FLSA <Classification Name>'
                                           and
                                           'US <Classification Name>'
   20-OCT-2006 asasthan   115.31  5610376  Regular Salary and Regular
                                           Wages should not be associated
                                           with FLSA Time Definitions as
                                           these elements should not be
                                           allocated.Code has been modified
                                           to ensure that these seeded
                                           elements do not inherit the time def
                                           set at Payroll. Modified caching
                                           so that seeded elements do not
                                           blindly inherit time def set
                                           by reduce regular element.

   18-APR-2006 saikrish   115.30  5161974  Creating Commission balance feeds.
   13-APR-2006 ahanda     115.29           Added a formula result rule to the
                                           seeded Hours by Rate element
                                            TEMPLATE_EARNING -> Pay Value
   20-SEP-2005 rdhingra   115.28  FLSA2    Priority for Reduce Regular has to
                                           be set to 1526. Updating
                                           element_template_upd_user_stru
   15-SEP-2005 rdhingra   115.27  FLSA2    Changed reporting name of FLSA Adjust
                                           FROM: Retro <element name>
                                             TO: <element name> Adjustment
   15-SEP-2005 rdhingra   115.26  FLSA2    Added an AND clause in
                                           CURSOR: get_payroll_time_definition_id
                                           FUNCTION: get_time_def_for_entry_func
                                           to take time_definition id as of
                                           payroll_period end date
   02-SEP-2005 asasthan   115.25  FLSA2    Attached Proration Event to
                                           FLSA Period Adjustment Element
   31-AUG-2005 rdhingra   115.24  FLSA2    Changes for FLSA Phase 2
                                           Premium Adjutment
   11-AUG-2005 kvsankar   115.23  FLSA2    Created a new function
                                           get_time_def_for_entry_func
                                           which is called by the procedure
                                           get_time_def_for_entry
   10-AUG-2005 rdhingra   115.22  FLSA2    Exclusion rule added for Overtime
                                           and Premium categories.
                                  4542621  element_information_category updated
                                           from US_IMPUTED_EARNINGS
                                           to US_IMPUTED EARNINGS
   08-AUG-2005 rdhingra   115.21  FLSA2    Added default retro component
                                           for "Entry Changes"
   02-AUG-2005 rdhingra   115.20  FLSA2    Added retro group "Entry Changes"
                                           to all FLSA Calc elements in Post
                                           Process
   27-JUL-2005 rdhingra   115.19  FLSA2    Modified element_template_pre_process
                                           to remove the exclusion rules for
                                           HXR when calculation_rule = 'US Earnings'
                                           Added details pertaining to Augments
                                           Added procedures delete_pre_process
                                           and delete_post_process
   09-JUN-2005 kvsankar   115.18  4420211  Modified the
                                           element_template_post_process
                                           to set the Mandatory Flag for
                                           'Deduction Processing' to 'N'
                                           for 'Non-payroll Payments'
   24-MAY-2005 kvsankar   115.17   FLSA    Modified the
                                           element_template_upd_user_stru
                                           to set the Processing priority
                                           depending on whether Reduce
                                           Regular checkbox is checked
                                           or not.
   23-MAY-2005 asasthn    115.15   FLSA    Modified defaulting of JOB CODE
   23-MAY-2005 rdhingra   115.14   FLSA    Modified get_time_def_for_entry
                                           Problem in cursor call.
   21-MAY-2005 rdhingra   115.13   FLSA    Added code to get the default
                                           time_definition_id in procedure
                                           get_time_def_for_entry
   05-MAY-2005 kvsankar   115.12   FLSA    Modified the
                                           element_template_post_process to set
                                           the Time Definition Type of
                                           Base element to 'G' if the element
                                           has FLSA Earnings checked
   05-MAY-2005 kvsankar   115.11   FLSA    is created using US FLSA template
   04-MAY-2005 ahanda     115.10   FLSA    Modified get_time_def_for_entry
   29-APR-2005 kvsankar   115.9    FLSA    Modified the
                                           element_template_post_process to set
                                           the Time Definition Type of only the
                                           Base element to 'G' if the element
                                           is created using US FLSA template
   29-APR-2005 rdhingra   115.8    FLSA    Added Procedure call for
                                           get_time_def_for_entry
   28-APR-2005 sodhingr   115.7            Added the function work_schedule
                                           _total_hours used by new work
                                           schedule functionality
   27-APR-2005 kvsankar   115.6    FLSA    Modified the Element Template PRE
                                           Process to not to create Special
                                           Inputs element, if 'FLSA Hours' or
                                           'Overtime Base' checkboxes are
                                           checked. This check is only for
                                           'US FLSA' template.
   27-APR-2005 kvsankar   115.5    FLSA    Modified the Element Template PRE,
                                           UPDATE and the POST Process for
                                           incluing the new template created
                                           for FLSA
   17-APR-2005 rdhingra   115.3            Changed for Global Element
                                           Template Migration. Added defi-
                                           nitions for user exit calls
                                           Pre-Process, upd_user_stru and
                                           Post-Process made from Global
                                           Element Template. Also added
                                           definition of get_obj_id
                                           function.
   23-AUG-2004 kvsankar   115.2   3840248  Modified the IF condition to
                                           correctly set END IF
   12-MAY-2004 sdahiya    115.1            Modified phase to plb
   25-APR-2004 sdahiya    115.0   3622290  Created.

****************************************************************************/



/****************************************************************************
    Name        : GET_DEFAULT_JUSRIDICTION
    Description : This function returns the default jurisdiction code which is
                  used for involuntary deduction elements if the end user does
                  not specify jurisdiction input value.
  *****************************************************************************/

PROCEDURE get_default_jurisdiction(p_asg_act_id number,
                                   p_ee_id number,
                                   p_jurisdiction in out nocopy varchar2) IS

    -- Cursor to get classification of elements.
    cursor csr_ele_classification is
    select classification_name
      from pay_element_classifications pec,
           pay_element_types_f pet,
           pay_element_entries_f pee
     where pec.classification_id = pet.classification_id
       and pet.element_type_id = pee.element_type_id
       and pee.element_entry_id = p_ee_id;

    -- Cursor to get 'Work At Home' flag of current assignment.
    cursor csr_wrk_at_home is
    select assign.work_at_home
    from   per_all_assignments_f assign,
           pay_assignment_actions paa
    where  paa.assignment_id = assign.assignment_id
      and  paa.assignment_action_id = p_asg_act_id
      and  assign.effective_start_date = (select max(paf.effective_start_date)
                                          from per_all_assignments_f paf
                                          where paf.assignment_id = assign.assignment_id);

    -- Cursor to get address information for the case when
    -- person is working at home.
    cursor csr_per_regions is
    select nvl(addr.add_information17,addr.region_2),
           nvl(addr.add_information19,addr.region_1),
           nvl(addr.add_information18,addr.town_or_city),
           nvl(addr.add_information20,addr.postal_code)
    from   per_addresses addr,
           per_all_assignments_f assign,
           pay_assignment_actions paa
    where  paa.assignment_id = assign.assignment_id
      and  paa.assignment_action_id = p_asg_act_id
      and  addr.person_id = assign.person_id
      and  addr.primary_flag   = 'Y'
      and  assign.effective_start_date
                      between nvl(addr.date_from, assign.effective_start_date)
                          and nvl(addr.date_to,assign.effective_start_date)
      and  assign.effective_start_date = (select max(paf.effective_start_date)
                                          from per_all_assignments_f paf
                                          where paf.assignment_id = assign.assignment_id);


    -- Cursor to get address information for the case when
    -- person is NOT working at home.
    cursor csr_loc_regions is
    select nvl(hrloc.loc_information17,hrloc.region_2),
           nvl(hrloc.loc_information19,hrloc.region_1),
           nvl(hrloc.loc_information18,hrloc.town_or_city),
           nvl(hrloc.loc_information20,hrloc.postal_code)
      from hr_locations hrloc,
           hr_soft_coding_keyflex hrsckf,
           per_all_assignments_f assign,
           pay_assignment_actions paa
     where paa.assignment_id = assign.assignment_id
       and paa.assignment_action_id = p_asg_act_id
       and assign.soft_coding_keyflex_id = hrsckf.soft_coding_keyflex_id
       and nvl(hrsckf.segment18,assign.location_id) = hrloc.location_id
       and  assign.effective_start_date = (select max(paf.effective_start_date)
                                           from per_all_assignments_f paf
                                           where paf.assignment_id = assign.assignment_id);

    l_asg_wrk_at_home varchar2(1);
    l_ele_classification pay_element_classifications.classification_name%type;
    l_proc_name varchar2(50);

    l_override_adr_region_2 per_addresses.add_information17%type;
    l_override_adr_region_1 per_addresses.add_information17%type;
    l_override_adr_city per_addresses.add_information17%type;
    l_override_adr_postal_code per_addresses.add_information17%type;

BEGIN
    l_pkg_name := 'pay_us_rules.';
    l_proc_name := l_pkg_name||'default_jurisdiction';
    hr_utility.trace('Entering '||l_proc_name);

    open csr_ele_classification;
        fetch csr_ele_classification into l_ele_classification;
    close csr_ele_classification;

    hr_utility.trace('Classification of element entry id '|| p_ee_id ||' is '||l_ele_classification);

    if l_ele_classification = 'Involuntary Deductions' then
        open csr_wrk_at_home;
             fetch csr_wrk_at_home into l_asg_wrk_at_home;
        close csr_wrk_at_home;

        if l_asg_wrk_at_home = 'Y'then
            open csr_per_regions;
                fetch csr_per_regions into l_override_adr_region_2,l_override_adr_region_1,
                                           l_override_adr_city, l_override_adr_postal_code;
            close csr_per_regions;
        else
            open csr_loc_regions;
                fetch csr_loc_regions into l_override_adr_region_2, l_override_adr_region_1,
                                           l_override_adr_city, l_override_adr_postal_code;
            close csr_loc_regions;
        end if;

        p_jurisdiction := hr_us_ff_udfs.addr_val (l_override_adr_region_2,
                                                  l_override_adr_region_1,
                                                  l_override_adr_city,
                                                  l_override_adr_postal_code);
        hr_utility.trace('Default jurisdiction code is '||p_jurisdiction);
    end if;
    hr_utility.trace('Leaving '||l_proc_name);
END get_default_jurisdiction;


/****************************************************************************/
/*               FUNCTION element_template_pre_process                      */
/****************************************************************************/

FUNCTION element_template_pre_process (p_rec IN pay_ele_tmplt_obj)
   RETURN pay_ele_tmplt_obj IS
BEGIN
   hr_utility.TRACE ('Entering pay_us_rules.element_template_pre_process');
   hr_utility.TRACE ('Legislation Code ' || lrec.legislation_code);
-- INITIALIZING THE GLOBAL VARIABLE
   lrec := NULL;
-- DEFAULTING TO input VARIABLE
   lrec := p_rec;




   IF (lrec.calculation_rule =  'US ' || lrec.element_classification) THEN

   -------------------------
   -- Determine the priority
   -------------------------
   -- variable lrec.configuration_information22 controls the exclusion rules
      IF (lrec.element_classification = 'Earnings') THEN
         lrec.preference_information11 := -249;                 --l_si_rel_priority
         lrec.preference_information9  := 250;                  --l_sf_rel_priority
         lrec.preference_information7  := 'US_EARNINGS';
         lrec.preference_information12 := NULL;                 --l_skip_formula
      ELSIF (lrec.element_classification = 'Supplemental Earnings') THEN
         lrec.preference_information11 := -499;                 --l_si_rel_priority
         lrec.preference_information9  := 500;                  --l_sf_rel_priority
         lrec.preference_information7  := 'US_SUPPLEMENTAL EARNINGS';
         lrec.configuration_information22 := 'N';               --l_ele_type_usages
         lrec.preference_information12 := NULL;                 --l_skip_formula
      ELSIF (lrec.element_classification = 'Imputed Earnings') THEN
         lrec.preference_information11 := -249;                 --l_si_rel_priority
         lrec.preference_information9  := 250;                  --l_sf_rel_priority
         lrec.preference_information7  := 'US_IMPUTED EARNINGS';
         lrec.preference_information12 := NULL;                 --l_skip_formula
      ELSIF (lrec.element_classification = 'Non-payroll Payments') THEN
         lrec.preference_information11 := -249;                 --l_si_rel_priority
         lrec.preference_information9  := 250;                  --l_sf_rel_priority
         lrec.preference_information7  := 'US_NON-PAYROLL PAYMENTS';
         lrec.preference_information12 := NULL;                 --l_skip_formula
         lrec.configuration_information22 := 'N';               --l_ele_type_usages
      END IF;

      --------------------------------------------
      -- set the appropriate exclusion rules
      --------------------------------------------
      -- The Configuration Flex segments for the Exclusion Rules are as follows:
      -- {Do not match the config numbers with variables used below}
      -- CONFIGURATION_INFORMATION1  - Xclude SI and SF elements
      --                               IF ele_processing_type='N'
      -- CONFIGURATION_INFORMATION2  - Flat Amount/Percentage
      -- CONFIGURATION_INFORMATION7  - Xclude objects IF overtime base is
      --                               not checked
      -- CONFIGURATION_INFORMATION8  - Excl rule for special features elements
      -- CONFIGURATION_INFORMATION9  - Excl rule for input value location in
      --                               case of special features elements.
      -- CONFIGURATION_INFORMATION10 - Excl rule for student earnings
      -- CONFIGURATION_INFORMATION11 - Excl rule for Regular Earning to decide
      --                               401k feed.
      -- CONFIGURATION_INFORMATION12 - Excl rule for Supplemental Earning
      -- Config14 - Excl rule for Overtime and Premium Categories
      -- Config15 - Excl rule for formula for flat amount non recurring
      -- Config16 - Excl rule for formula for flat amount recurring
      -- Config17 - Excl rule for formula for percentage non-recurring
      -- Config18 - Excl rule for formula for percentage recurring
      -- Config19 -
      -- Config20 -
      -- Config21 - Excl rule for Stop Reach Rule
      -- Config22 - Element type usages exlusion rule.
                --dont enter anyting for supplemental earning element
      -- Config23 - Processing type, recurring/non recur
      -- Config24 - Extra Input Values for Augments

      --Added for bug 5161974
      lrec.configuration_information19 := 'N';


      IF (lrec.configuration_info_category = 'REG') THEN
         lrec.configuration_information11 := 'Y';               -- l_reg_earning_flag
      END IF;

      lrec.configuration_information14 := 'N';                  -- Overtime or Premium Category
      -- For Overtime or Premium Category
      IF ((lrec.element_classification = 'Earnings') AND
          ((lrec.configuration_info_category = 'OT') OR
           (lrec.configuration_info_category = 'P')
          )
         ) THEN
         lrec.configuration_information14 := 'Y';
      END IF;

      IF (lrec.element_classification = 'Supplemental Earnings') THEN
         lrec.configuration_information12 := 'Y';               --l_supp_earn_flag
         lrec.configuration_information22 := 'N';               --l_ele_type_usages
	 ----Added for bug 5161974
	 IF (lrec.configuration_info_category = 'CM') THEN   --Tax category Commissions
            lrec.configuration_information19 := 'Y';
	 ELSE
            lrec.configuration_information19 := 'N';
	 END IF;
	 --End changes for bug 5161974
      END IF;

      IF (SUBSTR (lrec.preference_information1, 1, 11) = 'FLAT_AMOUNT') THEN
                                                                --p_ele_calc_ff_name
         lrec.configuration_information2 := 'FLAT';                --l_config2_amt
      -- This is not getting used anywhere so I have commented it
      --  l_calc_type    := 'FLAT_AMOUNT';
      ELSIF (SUBSTR (lrec.preference_information1, 1, 26) =
                                                       'PERCENTAGE_OF_REG_EARNINGS'
            ) THEN                                              --p_ele_calc_ff_name
         lrec.configuration_information2 := 'PCT';                --l_config3_perc
      --   l_calc_type    := 'PERCENTAGE';
      END IF;

      lrec.configuration_information1 := 'Y';                   --l_si_flag

      IF (   (lrec.processing_type = 'N'
      -- AND p_termination_rule <> 'L'
             )
          OR lrec.preference_information14 = 'N'                --p_special_input_flag
         ) THEN
         lrec.configuration_information1 := 'N';                --l_si_flag
      END IF;

      IF (lrec.preference_information3 = 'Y') THEN              --p_special_feature_flag
         lrec.configuration_information8 := 'Y';                --l_sf_flag
         lrec.configuration_information9 := 'N';                --l_sf_iv_flag
      ELSE
         lrec.configuration_information8 := 'N';                --l_sf_flag
         lrec.configuration_information9 := 'Y';                --l_sf_iv_flag
      END IF;

      lrec.configuration_information10 := 'N';                  --l_se_iv_flag
      lrec.configuration_information21 := 'N';                  --l_stop_reach_flag

      IF (lrec.preference_information2 = 'Y') THEN              --p_student_earning
         lrec.configuration_information8 := 'Y';                --l_sf_flag
         lrec.configuration_information10 := 'Y';               --l_se_iv_flag
         lrec.configuration_information9 := 'N';                --l_sf_iv_flag
         lrec.configuration_information21 := 'Y';               --l_stop_reach_flag
      --    l_multiple_entries :='N';
      END IF;

      IF (lrec.preference_information15 = 'Y') THEN             --p_stop_reach_rule
         lrec.configuration_information21 := 'Y';               --l_stop_reach_flag
      END IF;

      lrec.configuration_information15 := 'N';                  --l_config2_NR_amt
      lrec.configuration_information16 := 'N';                  --l_config2_RSI_amt
      lrec.configuration_information17 := 'N';                  --l_config3_NR_perc
      lrec.configuration_information18 := 'N';                  --l_config3_RSI_perc

      IF (lrec.configuration_information1 = 'Y') THEN           --l_si_flag
         IF (lrec.configuration_information2 = 'FLAT') THEN        --l_config2_amt
            lrec.configuration_information16 := 'Y';            --l_config2_RSI_amt
         ELSIF (lrec.configuration_information2 = 'PCT') THEN     --l_config3_perc
            lrec.configuration_information18 := 'Y';            --l_config3_RSI_perc
         END IF;
      ELSE
         IF (lrec.configuration_information2 = 'FLAT') THEN        --l_config2_amt
            lrec.configuration_information15 := 'Y';            --l_config2_NR_amt
         ELSIF (lrec.configuration_information2 = 'PCT') THEN     --l_config3_perc
            lrec.configuration_information17 := 'Y';            --l_config3_NR_perc
         END IF;
      END IF;

      lrec.configuration_information24 := 'N';
      IF (SUBSTR (lrec.preference_information1, 1, 11) = 'FLAT_AMOUNT' AND
          lrec.element_classification = 'Supplemental Earnings' AND
          lrec.processing_type = 'N' AND
          lrec.configuration_information7 = 'Y'
         ) THEN
         lrec.configuration_information24 := 'Y';
        /*
          For Augments configuration_information7 is made 'N' so that the
          base element does not feed FLSA Earnings and FLSA Allocated Earnings
          balances. Will change it back to Y in element_template_upd_user_stru
          such that it reflects on the earnings form.
        */
         lrec.configuration_information7  := 'N';
      END IF;


   ELSE

      -- FLSA Earning Elements
      -- Exclusion Rules are
      -- CONFIGURATION_INFORMATION1  => Special Feature Element
      -- CONFIGURATION_INFORMATION2  => Student Earnings
      -- CONFIGURATION_INFORMATION3  => Regular Category Check
      -- CONFIGURATION_INFORMATION4  => STOP Reach rule
      -- CONFIGURATION_INFORMATION5  => Reduce Regular Checkbox
      -- CONFIGURATION_INFORMATION6  => FLSA Hours
      -- CONFIGURATION_INFORMATION7  => Overtime Base
      -- CONFIGURATION_INFORMATION8  => Processing Type
      -- CONFIGURATION_INFORMATION9  => Supplemental Element Check
      -- CONFIGURATION_INFORMATION10 => Special Input Element
      -- CONFIGURATION_INFORMATION11 => Supplemental Element Check For SI
      -- CONFIGURATION_INFORMATION12 => Hours * Rate Formula
      -- CONFIGURATION_INFORMATION13 => Premium Formula
      -- CONFIGURATION_INFORMATION14 => Overtime and Premium Categories
      -- CONFIGURATION_INFORMATION15 => Regular Element

      -- Initialize various Exclusion variables
      -- CONFIGURATION_INFORMATION5 (Reduce Regular) and
      -- CONFIGURATION_INFORMATION6 (FLSA Hours) and
      -- CONFIGURATION_INFORMATION7 (Overtime Base)
      -- CONFIGURATION_INFORMATION8 (Processing Tyep) are not initialized
      -- as they are properly intialized in the call
      lrec.configuration_information1  := 'N';  -- Special Feature Element
      lrec.configuration_information2  := 'N';  -- Student Earnings
      lrec.configuration_information3  := 'N';  -- Regular Category Check
      lrec.configuration_information4  := 'N';  -- STOP Reach rule
      lrec.configuration_information9  := 'NONSUPP'; -- Create Ele Type Usages
      lrec.configuration_information10 := 'N';  -- Special Input Element
      lrec.configuration_information11 := 'N';  -- Create Ele Type Usage for SI
      lrec.configuration_information12 := 'N';  -- Hours * Rate Formula
      lrec.configuration_information13 := 'N';  -- Premium Formula
      lrec.configuration_information14 := 'N';  -- Overtime and Premium Category

      -- If the element is Reduce Regular, then set configuration_information15
      -- to 'N' so that Reduce Regular input values are not creted
      -- Else set to 'Y' so that they are created for Regular Elements
      if lrec.configuration_information5 = 'Y' then
         lrec.configuration_information15 := 'N';
      else
         lrec.configuration_information15 := 'Y';
      end if; -- if lrec.configuration_information5

      -- Setting the Preference Information values
      IF (lrec.element_classification = 'Earnings') THEN
         lrec.preference_information11 := -249;         -- SI Priority
         lrec.preference_information9 := 250;           -- SF Priority
         lrec.preference_information7 := 'US_EARNINGS'; -- Ele Info Cat
         lrec.preference_information12 := NULL;         -- Skip Formula
         lrec.configuration_information9 := 'NONSUPP';  -- Ele Type Usage
         lrec.configuration_information11 := 'Y';       -- Ele Type For SI
      ELSIF (lrec.element_classification = 'Supplemental Earnings') THEN
         lrec.preference_information11 := -499;         -- SI Priority
         lrec.preference_information9  := 500;          -- SF Priority
         lrec.preference_information7  := 'US_SUPPLEMENTAL EARNINGS';
                                                        -- Ele Info Cat
         lrec.preference_information12 := NULL;         -- Skip Formula
         lrec.configuration_information9 := 'SUPP';     -- No Ele Type Usage
         lrec.configuration_information11 := 'N';       -- No Ele Type For SI
      ELSIF (lrec.element_classification = 'Imputed Earnings') THEN
         lrec.preference_information11 := -249;         -- SI Priority
         lrec.preference_information9  := 250;          -- SF Priority
         lrec.preference_information7  := 'US_IMPUTED EARNINGS';
                                                        -- Ele Info Cat
         lrec.preference_information12 := NULL;         -- Skip Formula
         lrec.configuration_information9  := 'NONSUPP'; -- Ele Type Usage
         lrec.configuration_information11 := 'N';       -- No Ele Type For SI
      ELSIF (lrec.element_classification = 'Non-payroll Payments') THEN
         lrec.preference_information11 := -249;         -- SI Priority
         lrec.preference_information9  := 250;          -- SF Priority
         lrec.preference_information7  := 'US_NON-PAYROLL PAYMENTS';
                                                        -- Ele Info Cat
         lrec.preference_information12 := NULL;         -- Skip Formula
         lrec.configuration_information9  := 'SUPP';    -- Ele Type Usage
         lrec.configuration_information11 := 'Y';       -- Ele Type For SI
      END IF;

      -- CONFIGURATION_INFORMATION1 is used for Special Features
      IF (lrec.preference_information3 = 'Y') THEN
         lrec.configuration_information1 := 'Y';
      ELSE
         lrec.configuration_information1 := 'N';
      END IF; /* IF (lrec.preference_information3 = 'Y') */

      -- CONFIGURATION_INFORMATION10 ==> Special Feature Element
      -- CONFIGURATION_INFORMATION11 ==> Ele Type Usage for Special
      --                                 Feature Element
      IF (lrec.processing_type = 'N'
          OR lrec.preference_information14 = 'N') THEN
         lrec.configuration_information10 := 'N'; -- No SI Element
         lrec.configuration_information11 := 'N'; -- No Ele Type For SI
      ELSE
         lrec.configuration_information10 := 'Y'; -- SI Element
      END IF;

      IF (lrec.preference_information2 = 'Y') THEN
         -- Student Earnings
         lrec.configuration_information1 := 'Y'; -- Special Fetures
         lrec.configuration_information2 := 'Y'; -- Student Earnings
         lrec.configuration_information4 := 'Y'; -- STOP Reach rule
         lrec.configuration_information15:= 'N'; -- No Red Reg Input Values
         lrec.configuration_information5 := 'N'; -- Exclude Red Reg Feeds
      END IF; /* (lrec.preference_information2 = 'Y') */

      IF (lrec.configuration_info_category = 'REG') THEN
         -- Regular Earnings check to feed 401K balance
         lrec.configuration_information3 := 'Y';
      END IF; /* IF (lrec.configuration_info_category = 'REG') */

      IF (lrec.preference_information15 = 'Y') THEN
         -- Total Stop Reach Rule Checkbox
         lrec.configuration_information4 := 'Y'; -- STOP Reach rule
      END IF; /* IF (lrec.preference_information15 = 'Y') */

      IF (SUBSTR (lrec.preference_information1, 1, 12) = 'HOURS_X_RATE') THEN
         IF (lrec.configuration_information6 = 'Y' OR
             lrec.configuration_information7 = 'Y' OR
             lrec.configuration_information10 = 'N') THEN
            lrec.configuration_information12 := 'Y'; -- Hour * Rate formula
            -- No SI if any of the FLSA Hours or Overtime Base is checked
            lrec.configuration_information10 := 'N';
         END IF;
      ELSIF (SUBSTR (lrec.preference_information1, 1, 7) = 'PREMIUM') THEN
         lrec.configuration_information13 := 'Y'; -- Premium Formula
         lrec.configuration_information10 := 'N'; -- No SI Element
         lrec.configuration_information11 := 'N'; -- No Ele Type For SI
      END IF; /* IF (SUBSTR (lrec.preference_information1... */

      -- No Special Input Element
      -- If Special Input element is created, then we should use
      -- Hours * Rate formula with SI and not the one set above
      IF (lrec.configuration_information10 = 'N') THEN
         lrec.configuration_information11 := 'N'; -- No Ele Type Usage For SI
      ELSE
         lrec.configuration_information12 := 'N'; -- Hour * Rate formula
         lrec.configuration_information13 := 'N'; -- Premium Formula
      END IF;

      -- For Overtime or Premium Category
      IF ((lrec.element_classification = 'Earnings') AND
          ((lrec.configuration_info_category = 'OT') OR
           (lrec.configuration_info_category = 'P')
          )
         ) THEN
         lrec.configuration_information14 := 'Y';
      END IF;

      hr_utility.trace('CONFIG1  = ' || lrec.configuration_information1);
      hr_utility.trace('CONFIG2  = ' || lrec.configuration_information2);
      hr_utility.trace('CONFIG3  = ' || lrec.configuration_information3);
      hr_utility.trace('CONFIG4  = ' || lrec.configuration_information4);
      hr_utility.trace('CONFIG5  = ' || lrec.configuration_information5);
      hr_utility.trace('CONFIG6  = ' || lrec.configuration_information6);
      hr_utility.trace('CONFIG7  = ' || lrec.configuration_information7);
      hr_utility.trace('CONFIG8  = ' || lrec.configuration_information8);
      hr_utility.trace('CONFIG9  = ' || lrec.configuration_information9);
      hr_utility.trace('CONFIG10 = ' || lrec.configuration_information10);
      hr_utility.trace('CONFIG11 = ' || lrec.configuration_information11);
      hr_utility.trace('CONFIG12 = ' || lrec.configuration_information12);
      hr_utility.trace('CONFIG13 = ' || lrec.configuration_information13);
      hr_utility.trace('CONFIG14 = ' || lrec.configuration_information14);
      hr_utility.trace('CONFIG15 = ' || lrec.configuration_information15);
      hr_utility.trace('Priority = ' || lrec.processing_priority);

--      hr_utility.trace_off();

   END IF; /* IF (lrec.calculation_rule = 'US Earnings') */

-----------------------------------------------------------------
-- Used in Update Base shadow Element with user-specified details
-----------------------------------------------------------------
   IF lrec.processing_type = 'N' THEN
      lrec.multiple_entries_allowed := 'Y';
   END IF;
-----------------------------------------------------------------
-- Change the process mode to S for earnings element
-----------------------------------------------------------------

   IF lrec.process_mode = 'N' THEN-- value sent as N for earnings
      lrec.process_mode := 'S';
   END IF;

   hr_utility.TRACE ('Leaving pay_us_rules.element_template_pre_process');
   RETURN lrec;
END element_template_pre_process;

/****************************************************************************/
/*         PROCEDURE element_template_upd_user_stru                         */
/****************************************************************************/

PROCEDURE element_template_upd_user_stru (p_element_template_id IN NUMBER) IS
   l_template_name        VARCHAR2 (240);
   l_element_type_id      NUMBER;
   l_ovn                  NUMBER;

   --
   -- cursor to fetch the new element type id
   --
   CURSOR c_element (p_ele_name VARCHAR2, p_template_id NUMBER) IS
      SELECT element_type_id, object_version_number
        FROM pay_shadow_element_types
       WHERE element_name = p_ele_name AND template_id = p_template_id;

   --
   -- cursor to get the template id
   --
   CURSOR c_template (p_template_name VARCHAR2, p_legislation_code VARCHAR2) IS
      SELECT template_id
        FROM pay_element_templates
       WHERE template_name = p_template_name
         AND legislation_code = p_legislation_code;

   lv_reduce_regular        VARCHAR2(10);
   lv_special_feat          VARCHAR2(10);
   lv_special_inp           VARCHAR2(10);
   lv_flsa_calc_name        VARCHAR2(100);
   lv_prem_adjust_name      VARCHAR2(100);
   ln_base_process_priority NUMBER(9);
   ln_si_process_priority   NUMBER(9);
   ln_sf_process_priority   NUMBER(9);
   ln_fc_process_priority   NUMBER(9);
   ln_fpa_process_priority   NUMBER(9);
BEGIN
   hr_utility.TRACE ('Entering pay_us_rules.element_template_upd_user_stru');
   hr_utility.TRACE ('p_element_template_id ' || p_element_template_id);

-----------------------------------------------------------
-- Update Base shadow Element with user-specified details
-----------------------------------------------------------
   FOR c_rec IN c_element (lrec.element_name, p_element_template_id)
   LOOP
      l_element_type_id := c_rec.element_type_id;
      l_ovn := c_rec.object_version_number;
   END LOOP;

   -- FLSA Changes
   IF (lrec.calculation_rule = 'US ' || lrec.element_classification) THEN
      lv_reduce_regular := lrec.configuration_information13; -- Reduce Regular
      lv_special_feat   := lrec.configuration_information8;  -- Special Features
      lv_special_inp    := lrec.configuration_information1;  -- Special Input
   ELSE
      lv_special_feat   := lrec.configuration_information1;  -- Special Features
      lv_reduce_regular := lrec.configuration_information5;  -- Reduce Regular
      lv_special_inp    := lrec.configuration_information10; -- Special Input
   END IF;

   /*For Augments configuration_information7 was made 'N' so that the
     base element does not feed FLSA Earnings and FLSA Allocated Earnings
     balances. Changin it back to Y such that it reflects on the earnings
     form.
  */
   IF ((lrec.calculation_rule = 'US ' || lrec.element_classification) AND lrec.configuration_information24 = 'Y') THEN
        lrec.configuration_information7 := 'Y';
   END IF;

   ----------------------------------------------------------------------------
   -- Modify the Base elements priorty to 1526 if Reduce Regular is checked.
   -- The template has the Base elements priority set to 1750. We need to
   -- offset that by relative priority of -224 for Reduce Regular elements
   ----------------------------------------------------------------------------
   IF lv_reduce_regular = 'Y' THEN
      ln_base_process_priority := 0;
      ln_sf_process_priority   := ln_base_process_priority - 249;
      ln_si_process_priority   := ln_base_process_priority + 250;
      ln_fc_process_priority   := 0;
      ln_fpa_process_priority  := ln_base_process_priority + 10;
   ELSE
      ln_base_process_priority := 0;
      ln_sf_process_priority   := lrec.preference_information9;
      ln_si_process_priority   := lrec.preference_information11;
      ln_fc_process_priority   := 0;
      ln_fpa_process_priority  := ln_base_process_priority + 10;
   END IF;
   -- FLSA Changes
   pay_shadow_element_api.update_shadow_element
      (p_validate                      => FALSE
      ,p_effective_date                => lrec.effective_date
      ,p_element_type_id               => l_element_type_id
      ,p_element_name                  => lrec.element_name
      ,p_skip_formula                  => lrec.preference_information12
      ,p_element_information_category  => lrec.preference_information7
       -- p_ele_category
      ,p_element_information1          => NVL(lrec.configuration_info_category,
                                              hr_api.g_varchar2)
       --p_ele_ot_base
      ,p_element_information8          => NVL(lrec.configuration_information7,
                                              hr_api.g_varchar2)
       --p_flsa_hours
      ,p_element_information11         => NVL(lrec.configuration_information6,
                                              hr_api.g_varchar2)
       --p_reduce_regular
      ,p_element_information13         => NVL(lv_reduce_regular,
                                              hr_api.g_varchar2)
       --p_special_input_flag
      ,p_element_information14         => NVL(lrec.preference_information14,
                                               hr_api.g_varchar2)
       --p_stop_reach_rule
      ,p_element_information15         => NVL(lrec.preference_information15,
                                              hr_api.g_varchar2)
      ,p_relative_processing_priority  => ln_base_process_priority
      ,p_object_version_number         => l_ovn
      );

-------------------------------------------------------------------
-- Update user-specified details on Special Features Element.
-------------------------------------------------------------------
-- FLSA Changes
   IF (lv_special_feat = 'Y') THEN --l_sf_flag
      FOR c1_rec IN c_element (lrec.element_name || ' Special Features',
                               p_element_template_id
                              )
      LOOP
         l_element_type_id := c1_rec.element_type_id;
         l_ovn := c1_rec.object_version_number;
         pay_shadow_element_api.update_shadow_element
            (p_validate                      => FALSE
            ,p_reporting_name                => lrec.reporting_name || ' SF'
            ,p_classification_name           => lrec.element_classification
            ,p_effective_date                => lrec.effective_date
            ,p_element_type_id               => l_element_type_id
            ,p_description                   => 'Special Features element for '
                                                || lrec.element_name
             --l_sf_rel_priority
            ,p_relative_processing_priority  => ln_sf_process_priority
            ,p_element_information_category  => lrec.preference_information7
             --p_ele_category
            ,p_element_information1          => NVL(lrec.configuration_info_category,
                                                    hr_api.g_varchar2)
             --p_ele_ot_base
            ,p_element_information8          => NVL(lrec.configuration_information7,
                                                    hr_api.g_varchar2)
            ,p_object_version_number         => l_ovn
            );
      END LOOP;
   END IF;

--------------------------------------------------------------------
-- Update user-specified Classification Special Inputs IF it exists.
--------------------------------------------------------------------
-- FLSA Changes
   IF (lv_special_inp = 'Y') THEN --l_si_flag
      FOR c1_rec IN c_element (lrec.element_name || ' Special Inputs',
                               p_element_template_id
                              )
      LOOP
         l_element_type_id := c1_rec.element_type_id;
         l_ovn := c1_rec.object_version_number;
      END LOOP;

      pay_shadow_element_api.update_shadow_element
         (p_validate                      => FALSE
         ,p_reporting_name                => lrec.reporting_name || ' SI'
         ,p_classification_name           => lrec.element_classification
         ,p_effective_date                => lrec.effective_date
         ,p_element_type_id               => l_element_type_id
         ,p_description                   => 'Special Inputs element for '
                                             || lrec.element_name
          --l_si_rel_priority
         ,p_relative_processing_priority  => ln_si_process_priority
         ,p_element_information_category  => lrec.preference_information7
          --p_ele_category
         ,p_element_information1          => NVL(lrec.configuration_info_category,
                                                  hr_api.g_varchar2)
          --p_ele_ot_base
         ,p_element_information8          => NVL(lrec.configuration_information7,
                                                  hr_api.g_varchar2)
         ,p_object_version_number         => l_ovn
         );
   END IF;

-----------------------------------------------------------
-- Update user-specified details on FC element
-----------------------------------------------------------
   IF ((lrec.calculation_rule = 'US ' || lrec.element_classification) AND lrec.configuration_information24 = 'Y') THEN
      lv_flsa_calc_name := lrec.element_name || ' for FLSA Calc';
      FOR c_rec IN c_element (lv_flsa_calc_name, p_element_template_id)
      LOOP
         l_element_type_id := c_rec.element_type_id;
         l_ovn := c_rec.object_version_number;
      END LOOP;
      pay_shadow_element_api.update_shadow_element
         (p_validate                      => FALSE
         ,p_effective_date                => lrec.effective_date
         ,p_element_type_id               => l_element_type_id
         ,p_element_name                  => lv_flsa_calc_name
         ,p_reporting_name                => lrec.reporting_name || ' FC'
         ,p_classification_name           => 'Information'
         ,p_description                   => 'FLSA Calc element for '
                                              || lrec.element_name
         ,p_skip_formula                  => lrec.preference_information12
         ,p_element_information_category  => 'US_INFORMATION'
          -- p_ele_category
         ,p_element_information1          => NULL
          --p_ele_ot_base
         ,p_element_information8          => NVL(lrec.configuration_information7,
                                                 hr_api.g_varchar2)
         ,p_relative_processing_priority  => ln_fc_process_priority
         ,p_object_version_number         => l_ovn
         );
   END IF;

-------------------------------------------------------------------------
-- Update user-specified details on ' for FLSA Period Adjustment' element
-------------------------------------------------------------------------
   IF ((lrec.calculation_rule = 'US FLSA ' || lrec.element_classification) AND lrec.configuration_information13 = 'Y') THEN
      lv_prem_adjust_name := lrec.element_name || ' for FLSA Period Adjustment';
      FOR c_rec IN c_element (lv_prem_adjust_name, p_element_template_id)
      LOOP
         l_element_type_id := c_rec.element_type_id;
         l_ovn := c_rec.object_version_number;
      END LOOP;
      pay_shadow_element_api.update_shadow_element
         (p_validate                      => FALSE
         ,p_effective_date                => lrec.effective_date
         ,p_element_type_id               => l_element_type_id
         ,p_element_name                  => lv_prem_adjust_name
         ,p_reporting_name                => lrec.reporting_name || ' Adjustment'
         ,p_classification_name           => lrec.element_classification
         ,p_description                   => 'FLSA Period Adjust element for '
                                              || lrec.element_name
         ,p_skip_formula                  => lrec.preference_information12
         ,p_element_information_category  => lrec.preference_information7
          -- p_ele_category
         ,p_element_information1          => NVL(lrec.configuration_info_category,
                                              hr_api.g_varchar2)
          --p_ele_ot_base
         ,p_element_information8          => NVL(lrec.configuration_information7,
                                                 hr_api.g_varchar2)
         ,p_post_termination_rule         => NVL(lrec.termination_rule,
                                                 hr_api.g_varchar2)
         ,p_relative_processing_priority  => ln_fpa_process_priority
         ,p_object_version_number         => l_ovn
         );
   END IF;

   hr_utility.TRACE ('Leaving pay_us_rules.element_template_upd_user_stru');
END element_template_upd_user_stru;

/****************************************************************************/
/*         PROCEDURE element_template_post_process                          */
/****************************************************************************/

PROCEDURE element_template_post_process (p_element_template_id IN NUMBER) IS
   TYPE typeidnumber IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE typeidchar IS TABLE OF VARCHAR2 (10)
      INDEX BY BINARY_INTEGER;

   TYPE tinputvalrec IS RECORD
   (
    vname            pay_input_values_f.name%TYPE,
    vresultname      pay_formula_result_rules_f.result_name%TYPE,
    vresultruletype  pay_formula_result_rules_f.result_rule_type%TYPE,
    vinputvalid      pay_input_values_f.input_value_id%TYPE
   );
   TYPE tinputvalrectab IS TABLE OF tinputvalrec
         INDEX BY BINARY_INTEGER;
   tinputdetails tinputvalrectab;


   i                          NUMBER;
   t_form_id                  typeidnumber;
   t_ipv_id                   typeidnumber;
   t_def_val                  typeidchar;
   t_we_flag                  typeidchar;
   l_asg_gre_run_dim_id       pay_balance_dimensions.balance_dimension_id%TYPE;
   ln_business_group_id       NUMBER;
   lv_legislation_code        VARCHAR2 (240);
   lv_currency_code           VARCHAR2 (240);
   l_pri_bal_id               NUMBER;
   l_addl_bal_id              NUMBER;
   l_repl_bal_id              NUMBER;
   l_hours_bal_id             NUMBER;
   l_si_ele_type_id           NUMBER;
   l_sf_ele_type_id           NUMBER;
   l_hr_ele_id                NUMBER;
   l_hr_iv_id                 NUMBER;
   l_stat_proc_rule_id        NUMBER;
   l_rr_id                    NUMBER;
   lv_hoursXrate              VARCHAR2(10);
   lv_hoursXratemul           VARCHAR2(10);
   l_fc_bal_id                NUMBER;
   l_fc_ele_type_id           NUMBER;
   l_fc_stat_proc_rule_id     NUMBER;
   l_fc_eff_start_date        DATE;
   l_fc_eff_end_date          DATE;
   l_fc_obj_ver_num           NUMBER;
   l_for_mismatch_warn        BOOLEAN;
   l_fc_formula_name          ff_formulas_f.formula_name%TYPE;
   l_fc_formula_id            ff_formulas_f.formula_id%TYPE;
   l_fc_totamnt_iv_id         NUMBER;
   l_fc_formula_res_rul_id    NUMBER;
   ln_proration_group_name    pay_event_groups.event_group_name%TYPE;
   ln_proration_group_id      pay_event_groups.event_group_id%TYPE;
   ln_retro_comp_usge_id      NUMBER;
   ln_retro_comp_ovn          NUMBER;
   ln_retro_comp_id           NUMBER;
   ln_comp_name               pay_retro_components.component_name%TYPE;
   ln_retro_type              pay_retro_components.retro_type%TYPE;
   l_fpa_formula_name         ff_formulas_f.formula_name%TYPE;
   l_fpa_formula_id           ff_formulas_f.formula_id%TYPE;
   l_fpa_ele_type_id          NUMBER;
   l_fpa_stat_proc_rule_id    NUMBER;
   l_fpa_eff_start_date       DATE;
   l_fpa_eff_end_date         DATE;
   l_fpa_obj_ver_num          NUMBER;
   l_fpa_payval_iv_id         NUMBER;
   l_fpa_formula_res_rul_id   NUMBER;
   l_fpa_bal_id               NUMBER;
   l_fpa_hrs_bal_id           NUMBER;
   l_fpa_req_id               NUMBER;





   CURSOR get_busgrp_info (cp_business_group_name VARCHAR2) IS
      SELECT business_group_id, legislation_code
        FROM per_business_groups
       WHERE NAME = cp_business_group_name;

   CURSOR get_asg_gre_run_dim_id IS
      SELECT balance_dimension_id
        FROM pay_balance_dimensions
       WHERE dimension_name =
                            'Assignment within Government Reporting Entity Run'
         AND legislation_code = 'US';

   CURSOR c_ele (p_element_name IN VARCHAR2) IS
      SELECT element_type_id
        FROM pay_element_types_f
       WHERE UPPER (element_name) = UPPER (p_element_name)
         AND legislation_code = 'US';

   CURSOR c_inp_val(p_input_val_name IN VARCHAR2, p_element_type_id IN NUMBER)
   IS
      SELECT input_value_id
        FROM pay_input_values_f
       WHERE element_type_id = p_element_type_id
         AND UPPER (NAME) = UPPER (p_input_val_name);

   CURSOR c_pspr (
      p_element_type_id   IN   NUMBER,
      p_bg_id             IN   NUMBER,
      p_assgn_status_id   IN   NUMBER
   ) IS
      SELECT status_processing_rule_id
        FROM pay_status_processing_rules_f
       WHERE element_type_id = p_element_type_id
       AND business_group_id = p_bg_id;

   CURSOR c_formula_id (
      p_formula_name     IN   VARCHAR2,
      p_legislation_code IN   VARCHAR2
   ) IS
      SELECT formula_id
        FROM ff_formulas_f
       WHERE formula_name = p_formula_name
         AND legislation_code = p_legislation_code;

   -- Get Formula Name
   CURSOR get_formula_name( l_element_type_id NUMBER,
                            l_processing_rule VARCHAR2,
                            l_business_group_id NUMBER
                          ) IS
     SELECT FF.formula_name
       FROM pay_status_processing_rules_f PSP,
            ff_formulas_f FF
      WHERE PSP.element_type_id = l_element_type_id
        AND PSP.processing_rule = l_processing_rule
        AND FF.formula_id = PSP.formula_id
        AND PSP.business_group_id = l_business_group_id
        AND FF.business_group_id = l_business_group_id;


    -- Get Proration Group ID
    CURSOR get_proration_group_id( l_proration_group_name VARCHAR2
                                  ,l_bg_id NUMBER
                                  ,l_legislation_code VARCHAR2) IS
      SELECT event_group_id
        FROM pay_event_groups
       WHERE event_group_name = l_proration_group_name
         AND ((business_group_id IS NULL and legislation_code IS NULL) OR
               (business_group_id IS NULL and legislation_code = l_legislation_code) OR
               (business_group_id = l_bg_id and legislation_code IS NULL)
             );

     -- Get Retro Component Id
     CURSOR get_retro_comp_id( l_comp_name VARCHAR2
                              ,l_retro_type VARCHAR2
                              ,l_legislation_code VARCHAR2
                             ) IS
       SELECT retro_component_id
         FROM pay_retro_components
        WHERE component_name = l_comp_name
          AND retro_type = l_retro_type
          AND legislation_code = l_legislation_code;/*For seeded retro component, US
                                                      legislation_code will be present
                                                    */

BEGIN
   hr_utility.TRACE ('Entering pay_us_rules.element_template_post_process');
   hr_utility.TRACE ('p_element_template_id ' || p_element_template_id);

   -- FLSA Changes
   IF (lrec.calculation_rule = 'US ' || lrec.element_classification) THEN
      lv_hoursXrate    := 'N'; --lrec.configuration_information4;
      lv_hoursXratemul := 'N'; --lrec.configuration_information5;
   ELSE
      lv_hoursXrate    := 'Y';
      lv_hoursXratemul := 'Y';
   END IF;

   OPEN get_busgrp_info (lrec.business_group_name);

   FETCH get_busgrp_info
    INTO ln_business_group_id, lv_legislation_code;

   CLOSE get_busgrp_info;

-------------------------------------------------------------------
-- Get Element and Balance Id's to update the Further Information
-------------------------------------------------------------------
   l_pri_bal_id :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'BAL',
                  lrec.element_name
                 );
   l_addl_bal_id :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'BAL',
                  lrec.element_name || ' Additional'
                 );
   l_repl_bal_id :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'BAL',
                  lrec.element_name || ' Replacement'
                 );
   l_hours_bal_id :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'BAL',
                  lrec.element_name || ' Hours'
                 );
   pay_us_earn_templ_wrapper.g_ele_type_id :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'ELE',
                  lrec.element_name
                 );
   l_si_ele_type_id :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'ELE',
                  lrec.element_name || ' Special Inputs'
                 );
   l_sf_ele_type_id :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'ELE',
                  lrec.element_name || ' Special Features'
                 );

   UPDATE pay_element_types_f
      SET element_name = lrec.element_name,
          element_information10 = l_pri_bal_id,
          element_information12 = l_hours_bal_id
    WHERE element_type_id = pay_us_earn_templ_wrapper.g_ele_type_id
      AND business_group_id = ln_business_group_id;

-------------------------------------------------------------------
-- Get Element and Balance Id to update the FLSA Calc Element
-------------------------------------------------------------------
   IF ((lrec.calculation_rule = 'US ' || lrec.element_classification) AND lrec.configuration_information24 = 'Y') THEN
/*
      l_fc_bal_id :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'BAL',
                  lrec.element_name || ' for FLSA Calc'
                 );
*/
      l_fc_ele_type_id :=
         get_obj_id (ln_business_group_id,
                     lv_legislation_code,
                     'ELE',
                     lrec.element_name || ' for FLSA Calc'
                    );
/*
      UPDATE pay_element_types_f
         SET element_information10 = l_fc_bal_id
       WHERE element_type_id = l_fc_ele_type_id
         AND business_group_id = ln_business_group_id;
*/
   END IF;

-------------------------------------------------------------------
-- Get Element Type Id of ' for Premium Re Calc'
-------------------------------------------------------------------
   IF ((lrec.calculation_rule = 'US FLSA ' || lrec.element_classification) AND lrec.configuration_information13 = 'Y') THEN

      l_fpa_ele_type_id :=
         get_obj_id (ln_business_group_id,
                     lv_legislation_code,
                     'ELE',
                     lrec.element_name || ' for FLSA Period Adjustment'
                    );

      l_fpa_bal_id :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'BAL',
                  lrec.element_name || ' for FLSA Period Adjustment'
                 );

      l_fpa_hrs_bal_id :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'BAL',
                  lrec.element_name || ' for FLSA Period Adjustment Hours'
                 );
       /* Attach a proration group and event
          with FLSA Period Adjustment Element */

        ln_proration_group_name := 'Entry Changes for Proration';

        OPEN get_proration_group_id(ln_proration_group_name,NULL,NULL);
        FETCH get_proration_group_id INTO ln_proration_group_id;
        CLOSE get_proration_group_id;

      UPDATE pay_element_types_f
         SET element_information10 = l_fpa_bal_id,
             element_information12 = l_fpa_hrs_bal_id,
             proration_group_id = ln_proration_group_id
       WHERE element_type_id = l_fpa_ele_type_id
         AND business_group_id = ln_business_group_id;

   END IF;

-------------------------------------------------------------------
  -- Update Input values with default values, validation formula etc.
-------------------------------------------------------------------
   t_ipv_id (1) :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'IPV',
                  'Deduction Processing',
                  pay_us_earn_templ_wrapper.g_ele_type_id
                 );
   t_form_id (1) := NULL;
   t_we_flag (1) := NULL;
   t_def_val (1) := lrec.preference_information6;
   t_ipv_id (2) :=
      get_obj_id (ln_business_group_id,
                  lv_legislation_code,
                  'IPV',
                  'Separate Check',
                  pay_us_earn_templ_wrapper.g_ele_type_id
                 );
   t_form_id (2) := NULL;
   t_we_flag (2) := NULL;
   t_def_val (2) := lrec.preference_information8;

   --
   FOR i IN 1 .. 2
   LOOP
      UPDATE pay_input_values_f
         SET formula_id = t_form_id (i),
             warning_or_error = t_we_flag (i),
             DEFAULT_VALUE = t_def_val (i)
       WHERE input_value_id = t_ipv_id (i);

      -- Bug 4420211
      -- Set the Mandatory Flag to 'N' for input value 'Deduction Processing'
      -- if the classification is 'Non-payroll Payments'
      IF (lrec.element_classification = 'Non-payroll Payments' and i = 1) THEN
         UPDATE pay_input_values_f
            SET mandatory_flag = 'N'
          WHERE input_value_id = t_ipv_id (i);
      END IF;
   END LOOP;

------------------------------------
-- Get the _ASG_GRE_RUN dimension id
------------------------------------
   FOR crec IN get_asg_gre_run_dim_id
   LOOP
      l_asg_gre_run_dim_id := crec.balance_dimension_id;
   END LOOP;

   --
   FOR c_rec IN c_ele ('Hours by Rate')
   LOOP
      l_hr_ele_id := c_rec.element_type_id;
   END LOOP;

   FOR c_rec IN c_inp_val ('Element Type Id', l_hr_ele_id)
   LOOP
      l_hr_iv_id := c_rec.input_value_id;
   END LOOP;

   -- FLSA Changes
   IF (lv_hoursXrate = 'Y') THEN --l_config4_hr
      FOR c_rec IN
         c_pspr
            (p_element_type_id => pay_us_earn_templ_wrapper.g_ele_type_id,
             p_bg_id           => ln_business_group_id,
             p_assgn_status_id => NULL
            )
      LOOP
         l_stat_proc_rule_id := c_rec.status_processing_rule_id;
      END LOOP;

      l_rr_id :=
         pay_formula_results.ins_form_res_rule
             (p_business_group_id            => ln_business_group_id,
              p_legislation_code             => NULL,
              p_effective_start_date         => lrec.effective_date,
              p_effective_end_date           => NULL,
              p_status_processing_rule_id    => l_stat_proc_rule_id,
              p_element_type_id              => l_hr_ele_id,
              p_input_value_id               => l_hr_iv_id,
              p_result_name                  => 'ELEMENT_TYPE_ID_PASSED',
              p_result_rule_type             => 'I',
              p_severity_level               => NULL
             );

      FOR c_rec IN c_inp_val ('Hours', l_hr_ele_id)
      LOOP
         l_hr_iv_id := c_rec.input_value_id;
      END LOOP;

      l_rr_id :=
         pay_formula_results.ins_form_res_rule
              (p_business_group_id            => ln_business_group_id,
               p_legislation_code             => NULL,
               p_effective_start_date         => lrec.effective_date,
               p_effective_end_date           => NULL,
               p_status_processing_rule_id    => l_stat_proc_rule_id,
               p_element_type_id              => l_hr_ele_id,
               p_input_value_id               => l_hr_iv_id,
               p_result_name                  => 'HOURS_PASSED',
               p_result_rule_type             => 'I',
               p_severity_level               => NULL
              );

      -- FLSA Changes
      IF (lv_hoursXratemul = 'Y') THEN --l_config5_hrm
         FOR c_rec IN c_inp_val ('Multiple', l_hr_ele_id)
         LOOP
            l_hr_iv_id := c_rec.input_value_id;
         END LOOP;

         l_rr_id :=
            pay_formula_results.ins_form_res_rule
              (p_business_group_id            => ln_business_group_id,
               p_legislation_code             => NULL,
               p_effective_start_date         => lrec.effective_date,
               p_effective_end_date           => NULL,
               p_status_processing_rule_id    => l_stat_proc_rule_id,
               p_element_type_id              => l_hr_ele_id,
               p_input_value_id               => l_hr_iv_id,
               p_result_name                  => 'MULTIPLE_PASSED',
               p_result_rule_type             => 'I',
               p_severity_level               => NULL
              );
      END IF;

      FOR c_rec IN c_inp_val ('Rate', l_hr_ele_id)
      LOOP
         l_hr_iv_id := c_rec.input_value_id;
      END LOOP;

      l_rr_id :=
         pay_formula_results.ins_form_res_rule
              (p_business_group_id            => ln_business_group_id,
               p_legislation_code             => NULL,
               p_effective_start_date         => lrec.effective_date,
               p_effective_end_date           => NULL,
               p_status_processing_rule_id    => l_stat_proc_rule_id,
               p_element_type_id              => l_hr_ele_id,
               p_input_value_id               => l_hr_iv_id,
               p_result_name                  => 'RATE_PASSED',
               p_result_rule_type             => 'I',
               p_severity_level               => NULL
              );

      FOR c_rec IN c_inp_val ('Pay Value', l_hr_ele_id)
      LOOP
         l_hr_iv_id := c_rec.input_value_id;
      END LOOP;

      l_rr_id :=
         pay_formula_results.ins_form_res_rule
              (p_business_group_id            => ln_business_group_id,
               p_legislation_code             => NULL,
               p_effective_start_date         => lrec.effective_date,
               p_effective_end_date           => NULL,
               p_status_processing_rule_id    => l_stat_proc_rule_id,
               p_element_type_id              => l_hr_ele_id,
               p_input_value_id               => l_hr_iv_id,
               p_result_name                  => 'TEMPLATE_EARNING',
               p_result_rule_type             => 'I',
               p_severity_level               => NULL
              );

   END IF;
-------------------------------------------------------------------
-- Update status_processing_rules for FLSA Calc Element
-- Add formula result rule for FLSA Calc Element
-- Add Entry Changes for Proration event group to FLSA Calc Element
-------------------------------------------------------------------
   IF ((lrec.calculation_rule = 'US ' || lrec.element_classification) AND lrec.configuration_information24 = 'Y') THEN

        /*Updating status_processing_rules*/
        l_fc_formula_name := 'FLSA_PREMIUM_AMOUNT_CALCULATION';

        OPEN c_formula_id (l_fc_formula_name,'US');
        FETCH c_formula_id INTO l_fc_formula_id;

        IF c_formula_id%FOUND THEN
          pay_status_processing_rule_api.create_status_process_rule
          (
            p_validate                     => FALSE
           ,p_effective_date               => lrec.effective_date
           ,p_element_type_id              => l_fc_ele_type_id
           ,p_business_group_id            => ln_business_group_id
           ,p_legislation_code             => NULL
           ,p_formula_id                   => l_fc_formula_id
           ,p_status_processing_rule_id    => l_fc_stat_proc_rule_id
           ,p_effective_start_date         => l_fc_eff_start_date
           ,p_effective_end_date           => l_fc_eff_end_date
           ,p_object_version_number        => l_fc_obj_ver_num
           ,p_formula_mismatch_warning     => l_for_mismatch_warn
          );

          FOR c_rec IN c_inp_val ('Total Amount', l_fc_ele_type_id)
          LOOP
                l_fc_totamnt_iv_id := c_rec.input_value_id;
          END LOOP;

          pay_formula_result_rule_api.create_formula_result_rule
                (
                 p_validate                      => FALSE
                ,p_effective_date                => lrec.effective_date
                ,p_status_processing_rule_id     => l_fc_stat_proc_rule_id
                ,p_result_name                   => 'TEMPLATE_EARNING'
                ,p_result_rule_type              => 'D'
                ,p_business_group_id             => ln_business_group_id
                ,p_legislation_code              => NULL
                ,p_element_type_id               => l_fc_ele_type_id
                ,p_severity_level                => NULL
                ,p_input_value_id                => l_fc_totamnt_iv_id
                ,p_formula_result_rule_id        => l_fc_formula_res_rul_id
                ,p_effective_start_date          => l_fc_eff_start_date
                ,p_effective_end_date            => l_fc_eff_end_date
                ,p_object_version_number         => l_fc_obj_ver_num
                );
        ELSE
                hr_utility.TRACE ('Error in pay_us_rules.element_template_post_process');
                hr_utility.TRACE ('Error in fetching formula id for FLSA_PREMIUM_AMOUNT_CALCULATION');
        END IF;/*End of c_formula_id%FOUND*/

        CLOSE c_formula_id;

        ln_proration_group_name := 'Entry Changes for Proration';
        OPEN get_proration_group_id(ln_proration_group_name,NULL,NULL);
        FETCH get_proration_group_id INTO ln_proration_group_id;
        IF get_proration_group_id%FOUND THEN
           /*Updating for FLSA Calc Element with proration group id*/
           UPDATE pay_element_types_f
              SET proration_group_id = ln_proration_group_id
           WHERE business_group_id = ln_business_group_id
              AND element_type_id = l_fc_ele_type_id;
        ELSE
           hr_utility.TRACE ('Error in pay_us_rules.element_template_post_process');
           hr_utility.TRACE ('Error in fetching proration group id for Entry Changes for Proration');
        END IF;
        CLOSE get_proration_group_id;


        ln_proration_group_name := 'Entry Changes';
        OPEN get_proration_group_id(ln_proration_group_name,NULL,NULL);
        FETCH get_proration_group_id INTO ln_proration_group_id;
        IF get_proration_group_id%FOUND THEN
           /*Updating for FLSA Calc Element with retro group id*/
           UPDATE pay_element_types_f
              SET recalc_event_group_id = ln_proration_group_id
           WHERE business_group_id = ln_business_group_id
              AND element_type_id = l_fc_ele_type_id;

           /*Adding default retro component*/
           ln_comp_name  := 'Retropay';
           ln_retro_type := 'F';
           OPEN get_retro_comp_id(ln_comp_name,ln_retro_type,'US');
           FETCH get_retro_comp_id INTO ln_retro_comp_id;
           IF get_retro_comp_id%FOUND THEN
              pay_rcu_ins.ins
              (p_effective_date               => lrec.effective_date
              ,p_retro_component_id           => ln_retro_comp_id
              ,p_creator_id                   => l_fc_ele_type_id
              ,p_creator_type                 => 'ET'
              ,p_default_component            => 'Y'
              ,p_reprocess_type               => 'R'
              ,p_business_group_id            => ln_business_group_id
              ,p_legislation_code             => NULL
              ,p_retro_component_usage_id     => ln_retro_comp_usge_id
              ,p_object_version_number        => ln_retro_comp_ovn
              ,p_replace_run_flag             => 'N'
              ,p_use_override_dates           => 'N'
              );
           ELSE
              hr_utility.TRACE ('Error in pay_us_rules.element_template_post_process');
              hr_utility.TRACE ('Error in fetching retro component id');
           END IF;
           CLOSE get_retro_comp_id;
        ELSE
           hr_utility.TRACE ('Error in pay_us_rules.element_template_post_process');
           hr_utility.TRACE ('Error in fetching retro group id for Entry Changes');
        END IF;
        CLOSE get_proration_group_id;



   END IF;/* End of lrec.calculation_rule = 'US Earnings' AND lrec.configuration_information24 = 'Y'*/

-------------------------------------------------------------------
-- Update status_processing_rules for 'for Premium Re Calc' Element
-- Add formula result rule for 'for Premium Re Calc' Element
-------------------------------------------------------------------
   IF ((lrec.calculation_rule = 'US FLSA ' || lrec.element_classification) AND lrec.configuration_information13 = 'Y') THEN


      FOR c_rec IN
         c_pspr
            (p_element_type_id => l_fpa_ele_type_id,
             p_bg_id           => ln_business_group_id,
             p_assgn_status_id => NULL
            )
      LOOP
         l_fpa_stat_proc_rule_id := c_rec.status_processing_rule_id;
      END LOOP;

      FOR c_rec IN c_ele ('Hours by Rate')
      LOOP
         l_hr_ele_id := c_rec.element_type_id;
      END LOOP;


      i := 1;
      tinputdetails(i).vname           := 'Element Type Id';
      tinputdetails(i).vresultname     := 'ELEMENT_TYPE_ID_PASSED';
      tinputdetails(i).vresultruletype := 'I';


      i := i + 1;
      tinputdetails(i).vname           := 'Hours';
      tinputdetails(i).vresultname     := 'HOURS_PASSED';
      tinputdetails(i).vresultruletype := 'I';

      i := i + 1;
      tinputdetails(i).vname           := 'Rate';
      tinputdetails(i).vresultname     := 'RATE_PASSED';
      tinputdetails(i).vresultruletype := 'I';

      i := i + 1;
      tinputdetails(i).vname           := 'Multiple';
      tinputdetails(i).vresultname     := 'MULTIPLE_PASSED';
      tinputdetails(i).vresultruletype := 'I';

      i := i + 1;
      tinputdetails(i).vname           := 'Pay Value';
      tinputdetails(i).vresultname     := 'TEMPLATE_EARNINGS';
      tinputdetails(i).vresultruletype := 'I';

      --
      FOR x IN tinputdetails.FIRST .. tinputdetails.LAST
      LOOP
            FOR c_rec IN c_inp_val (tinputdetails(x).vname, l_hr_ele_id)
            LOOP
               tinputdetails(x).vinputvalid := c_rec.input_value_id;
            END LOOP;

            l_rr_id :=
                       pay_formula_results.ins_form_res_rule
                        (p_business_group_id      => ln_business_group_id,
                         p_legislation_code       => NULL,
                         p_effective_start_date   => lrec.effective_date,
                         p_effective_end_date     => NULL,
                         p_status_processing_rule_id  => l_fpa_stat_proc_rule_id,
                         p_element_type_id        => l_hr_ele_id,
                         p_input_value_id         => tinputdetails(x).vinputvalid,
                         p_result_name            => tinputdetails(x).vresultname,
                         p_result_rule_type       => tinputdetails(x).vresultruletype,
                         p_severity_level         => NULL
              );

      END LOOP;

   END IF;/* End of lrec.calculation_rule = 'US FLSA' AND lrec.configuration_information13 = 'Y'*/

   -- FLSA Changes
   -- Modifying the TIME_DEFINTION_TYPE for FLSA elements to 'G'
   -- if the elements are created using FLSA template or the
   -- element has FLSA Earnings checked
   hr_utility.trace('Calc Rule = ' || lrec.calculation_rule);
   hr_utility.trace('Ele Class = ' || lrec.element_classification);
   hr_utility.trace('CONFIG10 = ' || lrec.configuration_information10);
   IF (lrec.calculation_rule = 'US FLSA ' || lrec.element_classification) THEN
      IF (lrec.configuration_information10 = 'N') then
         hr_utility.trace('1. Updating Time Definition Type to G');
         UPDATE pay_element_types_f
            SET time_definition_type = 'G'
          WHERE business_group_id = ln_business_group_id
            AND element_type_id in ( pay_us_earn_templ_wrapper.g_ele_type_id
                                    ,l_fpa_ele_type_id);
      END IF;
   ELSIF lrec.configuration_information7 = 'Y' THEN
      hr_utility.trace('2. Updating Time Definition Type to G');
      UPDATE pay_element_types_f
         SET time_definition_type = 'G'
       WHERE business_group_id = ln_business_group_id
         AND element_type_id = pay_us_earn_templ_wrapper.g_ele_type_id;
   END IF;

   -- Modifying the TIME_DEFINTION_TYPE for Augment elements to 'G'
   IF ((lrec.calculation_rule = 'US ' || lrec.element_classification) AND lrec.configuration_information24 = 'Y') THEN
      hr_utility.trace('2. Updating Time Definition Type to G');
      UPDATE pay_element_types_f
         SET time_definition_type = 'G'
       WHERE business_group_id = ln_business_group_id
         AND element_type_id = l_fc_ele_type_id;
   END IF;


   hr_utility.TRACE ('Leaving pay_us_rules.element_template_post_process');
END element_template_post_process;

/****************************************************************************/
/*               PROCEDURE delete_pre_process                               */
/****************************************************************************/

PROCEDURE delete_pre_process(p_element_template_id IN NUMBER) IS

   i                       NUMBER;
   lv_ele_name             pay_element_types_f.element_name%TYPE;
   lv_business_group_id    NUMBER;
   lv_legislation_code     VARCHAR2 (240);
   l_shadow_ele_type_id    NUMBER;
   l_spr_id                NUMBER;
   l_spr_obj_ver_num       NUMBER;
   l_spr_eff_start_date    DATE;
   l_frr_id                NUMBER;
   l_frr_obj_ver_num       NUMBER;
   l_frr_eff_start_date    DATE;
   l_eff_start_date        DATE;
   l_eff_end_date          DATE;

  TYPE ushadowrec IS RECORD
  (
   v_shadow_ele_name pay_element_types_f.element_name%TYPE
  );

  TYPE ushadowrectab IS TABLE OF ushadowrec
       INDEX BY BINARY_INTEGER;
  tshadoweledetails    ushadowrectab;


   CURSOR c_ele_name (p_element_type_id IN NUMBER) IS
      SELECT  element_name
            , business_group_id
            , legislation_code
        FROM pay_element_types_f
       WHERE element_type_id = p_element_type_id;

   CURSOR c_stat_proc_rule ( p_element_type_id IN NUMBER
                            ,p_business_group_id IN NUMBER
                            ,p_legislation_code IN NUMBER
                           ) IS
      SELECT  status_processing_rule_id
            , effective_start_date
            , object_version_number
        FROM pay_status_processing_rules_f
       WHERE element_type_id = p_element_type_id
         AND ((business_group_id = p_business_group_id AND
              legislation_code IS NULL) OR
              (business_group_id IS NULL AND
              legislation_code = p_legislation_code)
             );

   CURSOR c_for_res_rule ( p_status_processing_rule_id IN NUMBER
                          ,p_business_group_id IN NUMBER
                          ,p_legislation_code IN NUMBER
                           ) IS
      SELECT  formula_result_rule_id
            , effective_start_date
            , object_version_number
         FROM pay_formula_result_rules_f
        WHERE status_processing_rule_id = p_status_processing_rule_id
         AND ((business_group_id = p_business_group_id AND
              legislation_code IS NULL) OR
              (business_group_id IS NULL AND
              legislation_code = p_legislation_code)
             );


BEGIN

   hr_utility.TRACE ('Entering pay_us_rules.delete_pre_process');

   OPEN c_ele_name(pay_us_earn_templ_wrapper.g_ele_type_id);
   FETCH c_ele_name INTO  lv_ele_name
                        , lv_business_group_id
                        , lv_legislation_code;

   IF c_ele_name%FOUND THEN
      i := 1;
      tshadoweledetails (i).v_shadow_ele_name := lv_ele_name || ' for FLSA Calc';

      i := i + 1;
      tshadoweledetails (i).v_shadow_ele_name := lv_ele_name || ' for FLSA Period Adjustment';

        FOR x IN tshadoweledetails.FIRST .. tshadoweledetails.LAST
        --
        LOOP
            l_shadow_ele_type_id :=
            get_obj_id (lv_business_group_id,
                        lv_legislation_code,
                        'ELE',
                        tshadoweledetails (x).v_shadow_ele_name
                       );
            IF l_shadow_ele_type_id IS NOT NULL THEN

               OPEN c_stat_proc_rule(l_shadow_ele_type_id
                                    ,lv_business_group_id
                                    ,lv_legislation_code
                                    );
               FETCH c_stat_proc_rule INTO l_spr_id
                                          ,l_spr_eff_start_date
                                          ,l_spr_obj_ver_num;
               IF c_stat_proc_rule%FOUND THEN

                  OPEN c_for_res_rule(l_spr_id
                                    ,lv_business_group_id
                                    ,lv_legislation_code
                                 );
                  FETCH c_for_res_rule INTO  l_frr_id
                                            ,l_frr_eff_start_date
                                            ,l_frr_obj_ver_num;
                  IF c_for_res_rule%FOUND THEN
                     NULL;
                     pay_formula_result_rule_api.DELETE_FORMULA_RESULT_RULE
                          (p_validate                    => FALSE
                          ,p_effective_date              => l_frr_eff_start_date
                          ,p_datetrack_delete_mode       => 'ZAP'
                          ,p_formula_result_rule_id      => l_frr_id
                          ,p_object_version_number       => l_frr_obj_ver_num
                          ,p_effective_start_date        => l_eff_start_date
                          ,p_effective_end_date          => l_eff_end_date
                          );
                  ELSE
                     hr_utility.TRACE ('pay_formula_result_rules_f does not return any row');
                  END IF;/*c_for_res_rule%FOUND*/
                  CLOSE c_for_res_rule;

                  pay_status_processing_rule_api.delete_status_process_rule
                    (p_validate                       => FALSE
                    ,p_effective_date                 => l_spr_eff_start_date
                    ,p_datetrack_mode                 => 'ZAP'
                    ,p_status_processing_rule_id      => l_spr_id
                    ,p_object_version_number          => l_spr_obj_ver_num
                    ,p_effective_start_date           => l_eff_start_date
                    ,p_effective_end_date             => l_eff_end_date
                    );
               ELSE
                  hr_utility.TRACE ('pay_status_processing_rules_f does not return any row');
               END IF;/*c_stat_proc_rule%FOUND*/
               CLOSE c_stat_proc_rule;

            END IF;/*l_shadow_ele_type_id IS NOT NULL*/
        END LOOP;/*tshadoweledetails.FIRST .. tshadoweledetails.LAST*/

   ELSE
      hr_utility.TRACE ('Error in pay_us_rules.delete_pre_process');
      hr_utility.TRACE ('Element Type Id passed does not have a row in pay_element_types_f');
   END IF;/*c_ele_name%FOUND*/
   CLOSE c_ele_name;

   hr_utility.TRACE ('Leaving pay_us_rules.delete_pre_process');
END delete_pre_process;

/****************************************************************************/
/*               PROCEDURE delete_post_process                               */
/****************************************************************************/

PROCEDURE delete_post_process(p_element_template_id IN NUMBER) IS
BEGIN
   hr_utility.TRACE ('Entering pay_us_rules.delete_post_process');
        NULL;
   hr_utility.TRACE ('Leaving pay_us_rules.delete_post_process');
END delete_post_process;


--=======================================================================
--                FUNCTION GET_OBJ_ID
--=======================================================================

FUNCTION get_obj_id (
   p_business_group_id   IN   NUMBER,
   p_legislation_code    IN   VARCHAR2,
   p_object_type         IN   VARCHAR2,
   p_object_name         IN   VARCHAR2,
   p_object_id           IN   NUMBER DEFAULT NULL
)
   RETURN NUMBER IS
   --
   l_object_id   NUMBER        := NULL;
   l_proc        VARCHAR2 (60);

   --
   CURSOR c_element IS                              -- Gets the element type id
      SELECT element_type_id
        FROM pay_element_types_f
       WHERE element_name = p_object_name
         AND business_group_id = p_business_group_id;

   --
   CURSOR c_get_ipv_id IS                             -- Gets the input value id
      SELECT piv.input_value_id
        FROM pay_input_values_f piv
       WHERE piv.NAME = p_object_name
         AND piv.element_type_id = p_object_id
         AND piv.business_group_id = p_business_group_id;

   --
   CURSOR c_get_bal_id IS                            -- Gets the Balance type id
      SELECT balance_type_id
        FROM pay_balance_types pbt
       WHERE pbt.balance_name = p_object_name
        AND NVL (pbt.business_group_id, p_business_group_id) =
                                                            p_business_group_id
        AND NVL (pbt.legislation_code, p_legislation_code) = p_legislation_code;
--
BEGIN
   hr_utility.set_location ('Entering: ' || l_proc, 10);
   l_proc := 'pay_us_earnings_template.get_obj_id';
   --
   IF p_object_type = 'ELE' THEN
      FOR c_rec IN c_element
      LOOP
         l_object_id := c_rec.element_type_id;                    -- element id
      END LOOP;
   ELSIF p_object_type = 'BAL' THEN
      FOR c_rec IN c_get_bal_id
      LOOP
         l_object_id := c_rec.balance_type_id;                    -- balance id
      END LOOP;
   ELSIF p_object_type = 'IPV' THEN
      FOR c_rec IN c_get_ipv_id
      LOOP
         l_object_id := c_rec.input_value_id;                 -- input value id
      END LOOP;
   END IF;

   hr_utility.set_location ('Leaving: ' || l_proc, 50);
   --
   RETURN l_object_id;
END get_obj_id;
--
--
FUNCTION work_schedule_total_hours(
                assignment_action_id  IN NUMBER   --Context
               ,assignment_id         IN NUMBER   --Context
               ,p_bg_id		          in NUMBER   -- Context
               ,element_entry_id      IN NUMBER   --Context
               ,date_earned           IN DATE
     		   ,p_range_start	      IN DATE
      	   ,p_range_end           IN DATE
               ,p_wk_sch_found   IN OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

  -- local constants
  c_ws_tab_name	  VARCHAR2(80);

  -- local variables
  v_total_hours	  NUMBER(15,7);
  v_range_start   DATE;
  v_range_end     DATE;
  v_curr_date     DATE;
  v_curr_day      VARCHAR2(3);	-- 3 char abbrev for day of wk.
  v_ws_name       VARCHAR2(80);	-- Work Schedule Name.
  v_gtv_hours     VARCHAR2(80);	-- get_table_value returns varchar2
  v_fnd_sess_row  VARCHAR2(1);
  l_exists        VARCHAR2(1);
  v_day_no        NUMBER;
  p_ws_name       VARCHAR2(80);	-- Work Schedule Name from SCL
  l_id_flex_num   NUMBER;

  CURSOR get_id_flex_num IS
    SELECT rule_mode
      FROM pay_legislation_rules
     WHERE legislation_code = 'US'
       and rule_type = 'S';

  Cursor get_ws_name (p_id_flex_num number,
                      p_date_earned date,
                      p_assignment_id number) IS
    SELECT target.SEGMENT4
      FROM /* route for SCL keyflex - assignment level */
           hr_soft_coding_keyflex target,
           per_all_assignments_f  ASSIGN
     WHERE p_date_earned BETWEEN ASSIGN.effective_start_date
                             AND ASSIGN.effective_end_date
       AND ASSIGN.assignment_id           = p_assignment_id
       AND target.soft_coding_keyflex_id  = ASSIGN.soft_coding_keyflex_id
       AND target.enabled_flag            = 'Y'
       AND target.id_flex_num             = p_id_flex_num;


BEGIN -- work_schedule_total_hours
  /* Init */
  v_total_hours  := 0;
  c_ws_tab_name  := 'COMPANY WORK SCHEDULES';

  /* get ID FLEX NUM */
  --IF pay_us_rules.g_id_flex_num IS NULL THEN
  hr_utility.trace('Getting ID_FLEX_NUM for US legislation  ');
  OPEN get_id_flex_num;
  FETCH get_id_flex_num INTO l_id_flex_num;
  -- pay_us_rules.g_id_flex_num := l_id_flex_num;
  CLOSE get_id_flex_num;
  --END IF;

  -- hr_utility.trace('pay_us_rules.g_id_flex_num '||pay_us_rules.g_id_flex_num);
  hr_utility.trace('l_id_flex_num '||l_id_flex_num);
  hr_utility.trace('assignment_action_id=' || assignment_action_id);
  hr_utility.trace('assignment_id='        || assignment_id);
  hr_utility.trace('business_group_id='    || p_bg_id);
  hr_utility.trace('p_range_start='        || p_range_start);
  hr_utility.trace('p_range_end='          || p_range_end);
  hr_utility.trace('element_entry_id='     || element_entry_id);
  hr_utility.trace('date_earned '          || date_earned);

  /* get work schedule_name */
  --IF pay_us_rules.g_id_flex_num IS NOT NULL THEN
  IF l_id_flex_num IS NOT NULL THEN
     hr_utility.trace('getting work schedule name  ');
     OPEN  get_ws_name (l_id_flex_num,--pay_us_rules.g_id_flex_num,
                        date_earned,
                        assignment_id);
     FETCH get_ws_name INTO p_ws_name;
     CLOSE get_ws_name;
  END IF;

  IF p_ws_name IS NULL THEN
     hr_utility.trace('Work Schedule not found ');
     p_wk_sch_found := 'FALSE';
     return 0;
  END IF;

  hr_utility.trace('Work Schedule '||p_ws_name);

  --changed to select the work schedule defined
  --at the business group level instead of
  --hardcoding the default work schedule
  --(COMPANY WORK SCHEDULES ) to the
  --variable  c_ws_tab_name

  begin
    select put.user_table_name
      into c_ws_tab_name
      from hr_organization_information hoi
          ,pay_user_tables put
     where  hoi.organization_id = p_bg_id
       and hoi.org_information_context ='Work Schedule'
       and hoi.org_information1 = put.user_table_id ;

  EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
  end;

  -- Set range to a single week if no dates are entered:
  -- IF (p_range_start IS NULL) AND (p_range_end IS NULL) THEN
  --
  v_range_start := NVL(p_range_start, sysdate);
  v_range_end	:= NVL(p_range_end, sysdate + 6);
  --
  -- END IF;

  -- Check for valid range
  IF v_range_start > v_range_end THEN
  --
     p_wk_sch_found := 'FALSE';
     RETURN v_total_hours;
     --  hr_utility.set_message(801,'PAY_xxxx_INVALID_DATE_RANGE');
     --  hr_utility.raise_error;
     --
  END IF;

  -- Get_Table_Value requires row in FND_SESSIONS.  We must insert this
  -- record if one doe not already exist.
  SELECT DECODE(COUNT(session_id), 0, 'N', 'Y')
    INTO v_fnd_sess_row
    FROM fnd_sessions
   WHERE session_id = userenv('sessionid');

  IF v_fnd_sess_row = 'N' THEN
     dt_fndate.set_effective_date(trunc(sysdate));
  END IF;

  --
  -- Track range dates:
  --
  -- Check if the work schedule is an id or a name.  If the work
  -- schedule does not exist, then return 0.
  --
  BEGIN
    select 'Y'
      into l_exists
      from pay_user_tables PUT,
           pay_user_columns PUC
     where PUC.USER_COLUMN_NAME = p_ws_name
       and NVL(PUC.business_group_id, p_bg_id) = p_bg_id
       and NVL(PUC.legislation_code,'US') = 'US'
       and PUC.user_table_id = PUT.user_table_id
       and PUT.user_table_name = c_ws_tab_name;


  EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
  END;

  if l_exists = 'Y' then
     v_ws_name := p_ws_name;
  else
     BEGIN
        select PUC.USER_COLUMN_NAME
        into v_ws_name
        from  pay_user_tables PUT,
              pay_user_columns PUC
        where PUC.USER_COLUMN_ID = p_ws_name
          and NVL(PUC.business_group_id, p_bg_id) = p_bg_id
          and NVL(PUC.legislation_code,'US') = 'US'
          and PUC.user_table_id = PUT.user_table_id
          and PUT.user_table_name = c_ws_tab_name;

     EXCEPTION WHEN NO_DATA_FOUND THEN
        p_wk_sch_found := 'FALSE';
        RETURN v_total_hours;
     END;
  end if;

  v_curr_date := v_range_start;

  LOOP

    v_day_no := TO_CHAR(v_curr_date, 'D');


    SELECT decode(v_day_no,1,'SUN',2,'MON',3,'TUE',
                           4,'WED',5,'THU',6,'FRI',7,'SAT')
    INTO v_curr_day
    FROM DUAL;

    v_total_hours := v_total_hours +
                     FND_NUMBER.CANONICAL_TO_NUMBER(
                                 hruserdt.get_table_value(p_bg_id,
                                                          c_ws_tab_name,
                                                          v_ws_name,
                                                          v_curr_day));
    v_curr_date := v_curr_date + 1;


    EXIT WHEN v_curr_date > v_range_end;

  END LOOP;

  p_wk_sch_found := 'TRUE';
  RETURN v_total_hours;

END work_schedule_total_hours;

/****************************************************************************/
/*               PROCEDURE get_time_def_for_entry                           */
/****************************************************************************/
PROCEDURE get_time_def_for_entry (
   p_element_entry_id                     NUMBER,
   p_assignment_id                        NUMBER,
   p_assignment_action_id                 NUMBER,
   p_business_group_id                    NUMBER,
   p_time_definition_id   IN OUT NOCOPY   VARCHAR2
) IS

   /*  Get Date_Earned of the payroll action */
 CURSOR get_date_earned(cp_assignment_action_id NUMBER) IS
    SELECT NVL(ppa.date_earned,ppa.effective_date)
      FROM pay_assignment_actions paa
         , pay_payroll_actions ppa
     WHERE paa.assignment_action_id = cp_assignment_action_id
       AND paa.payroll_action_id = ppa.payroll_action_id;


 CURSOR chk_regsal_regwag  (cp_element_entry NUMBER
                           ,cp_bus_grp NUMBER
                           ,cp_date DATE
                           ) IS
    SELECT element_name
     FROM pay_element_types_f pet,
          pay_element_entries_f pee
    WHERE pee.element_entry_id  = cp_element_entry
      AND pee.element_type_id = pet.element_type_id
      AND ((pet.legislation_code = 'US' and pet.business_group_id is null)
           or (pet.legislation_code is null and pet.business_group_id = cp_bus_grp))
      AND cp_date BETWEEN pee.effective_start_date
                      AND pee.effective_end_date
      AND cp_date BETWEEN pet.effective_start_date
                      AND pet.effective_end_date;


 CURSOR get_default_time_definition_id(
      p_time_def_name       VARCHAR2,
      p_legislation_code    VARCHAR2
   )
   IS
      SELECT time_definition_id
        FROM pay_time_definitions
       WHERE definition_name = p_time_def_name
         AND legislation_code = p_legislation_code
         AND business_group_id IS NULL;

l_date_earned        date;
l_time_definition_id number;
lv_element_name      varchar2(80);
ln_def_time_def      number;

BEGIN

  --hr_utility.trace_on(null, 'TIME');
  hr_utility.trace('Entering PAY_US_RULES.get_time_def_for_entry');
  hr_utility.trace('p_assignment_id='       || p_assignment_id);
  hr_utility.trace('p_assignment_action_id='|| p_assignment_action_id);
  hr_utility.trace('p_business_group_id='   || p_business_group_id);
  hr_utility.trace('p_element_entry_id='    || p_element_entry_id);

  -- Check if it is the same assignment id, return the value already stored

  if g_current_asg_id = p_assignment_id then

     -- Check whether assignment has either Regular Salary or Regular Wages
     -- entry. In this case we will not use the cached time definition (set by
     -- reduce regular). The seeded Non Allocated Time Definition will
     -- be assigned for Regular Salary or Regular Element

      open get_date_earned (p_assignment_action_id);
      fetch get_date_earned into l_date_earned;
      close get_date_earned;

      open chk_regsal_regwag  (p_element_entry_id
                             ,p_business_group_id
                             ,l_date_earned);
      fetch chk_regsal_regwag into lv_element_name;
      close chk_regsal_regwag;

      if lv_element_name = 'Regular Salary' or
         lv_element_name = 'Regular Wages' then

         -- Get value for Non Allocated Time Definition Id
         open get_default_time_definition_id('Non Allocated Time Definition'
                                            ,'US');
         fetch get_default_time_definition_id into l_time_definition_id;
         close get_default_time_definition_id;
         p_time_definition_id := l_time_definition_id;
      elsif g_get_time_def_flag then
        l_time_definition_id :=
             get_time_def_for_entry_func(p_element_entry_id
                                        ,p_assignment_id
                                        ,p_assignment_action_id
                                        ,p_business_group_id
                                        ,l_date_earned);
        g_current_time_def_id := l_time_definition_id;
        p_time_definition_id  := g_current_time_def_id;
        g_get_time_def_flag := FALSE;
      else
        p_time_definition_id := g_current_time_def_id;
      end if;
  else
      hr_utility.trace('Finding Time Definition ID');
     -- find the Date Earned of the payroll period
     open get_date_earned (p_assignment_action_id);
     fetch get_date_earned into l_date_earned;
     close get_date_earned;

     open chk_regsal_regwag  (p_element_entry_id
                             ,p_business_group_id
                             ,l_date_earned);
     fetch chk_regsal_regwag into lv_element_name;
     close chk_regsal_regwag;

     if lv_element_name = 'Regular Salary' or
        lv_element_name = 'Regular Wages' then
         open get_default_time_definition_id('Non Allocated Time Definition'
                                            ,'US');
         fetch get_default_time_definition_id into l_time_definition_id;
         close get_default_time_definition_id;
         g_get_time_def_flag := TRUE;
     else
         l_time_definition_id :=
                get_time_def_for_entry_func(p_element_entry_id
                                           ,p_assignment_id
                                           ,p_assignment_action_id
                                           ,p_business_group_id
                                           ,l_date_earned);
         g_get_time_def_flag := FALSE;
     end if;

     g_current_time_def_id := l_time_definition_id;
     p_time_definition_id  := l_time_definition_id;
     g_current_asg_id := p_assignment_id;
  end if;

  hr_utility.trace('p_time_definition_id = ' || p_time_definition_id);
  hr_utility.trace('Leaving PAY_US_RULES.get_time_def_for_entry');
  return;
END;


/*****************************************************************************
 *               PROCEDURE get_time_def_for_entry_func                       *
 * This procedure has to maintain purity and not write into global variables *
 * or insert data into any database tables. No calls to hr_utility.trace     *
 * should be made.                                                           *
/****************************************************************************/
FUNCTION get_time_def_for_entry_func(
   p_element_entry_id                     NUMBER,
   p_assignment_id                        NUMBER,
   p_assignment_action_id                 NUMBER,
   p_business_group_id                    NUMBER,
   p_time_def_date                        DATE
) RETURN NUMBER IS

 /* Check if employee is flsa eligible */
 CURSOR get_jobs_us_flsa_code(cp_date_earned   DATE
                             ,cp_assignment_id NUMBER) IS
   SELECT nvl(perj.JOB_INFORMATION3, 'EX')
     FROM per_jobs perj,
          per_jobs_tl perjtl,
          per_all_assignments_f paa
    WHERE cp_date_earned BETWEEN paa.effective_start_date AND paa.effective_end_date
      AND paa.assignment_id = cp_assignment_id
      AND paa.job_id = perj.job_id
      AND paa.job_id = perjtl.job_id
      AND userenv('LANG') = perjtl.language;

 /*  Get time_definition_id from information element */
 CURSOR get_info_time_def_id (cp_ele_name      VARCHAR2
                             ,cp_inp_val_name  VARCHAR2
                             ,cp_assignment_id NUMBER
                             ,cp_date          DATE
     ) IS
   SELECT peev.screen_entry_value
     FROM pay_element_types_f pet,
          pay_input_values_f piv,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
    WHERE pet.element_name = cp_ele_name
      AND pet.business_group_id is NULL
      AND peef.element_type_id = pet.element_type_id
      AND pet.element_type_id = piv.element_type_id
      AND pet.legislation_code = 'US'
      AND piv.business_group_id is NULL
      AND piv.legislation_code = 'US'
      AND piv.NAME = cp_inp_val_name
      AND peev.element_entry_id = peef.element_entry_id
      AND peev.input_value_id = piv.input_value_id
      AND peef.assignment_id = cp_assignment_id
      AND cp_date BETWEEN piv.effective_start_date
                      AND piv.effective_end_date
      AND cp_date BETWEEN peef.effective_start_date
                      AND peef.effective_end_date
      AND cp_date BETWEEN pet.effective_start_date
                      AND pet.effective_end_date
      AND cp_date BETWEEN peev.effective_start_date
                      AND peev.effective_end_date;

 /* Get person id and payroll id for the assignment/business
    group id provided */
 CURSOR get_assignment_info(cp_assignment_id NUMBER
                           ,cp_date          DATE) IS
    SELECT person_id, payroll_id
      FROM per_all_assignments_f
     WHERE assignment_id = cp_assignment_id
       AND cp_date BETWEEN effective_start_date AND effective_end_date;

 -- Get time_definition_id corresponding to Overtime Week Id
 CURSOR get_time_from_week (cp_otl_recurring_period VARCHAR2) IS
    SELECT time_definition_id
      FROM pay_time_definitions
     WHERE creator_id = cp_otl_recurring_period AND creator_type = 'OTL_W';

 -- Get time definition id defined at payroll level
 CURSOR get_payroll_time_definition_id (cp_payroll_id NUMBER
                                       ,cp_date DATE
                                       ) IS
    SELECT pap.prl_information10
      FROM pay_all_payrolls_f pap
     WHERE pap.payroll_id = cp_payroll_id
       AND cp_date BETWEEN pap.effective_start_date
                       AND pap.effective_end_date;

 -- Get default time definition
 CURSOR get_default_time_definition_id(
      p_time_def_name       VARCHAR2,
      p_legislation_code    VARCHAR2
   )
   IS
      SELECT time_definition_id
        FROM pay_time_definitions
       WHERE definition_name = p_time_def_name
         AND legislation_code = p_legislation_code
         AND business_group_id IS NULL;

 CURSOR chk_seeded_elements(cp_element_entry NUMBER
                           ,cp_bus_grp NUMBER
                           ,cp_date DATE
                           ) IS
    SELECT element_name
     FROM pay_element_types_f pet,
          pay_element_entries_f pee
    WHERE pee.element_entry_id  = cp_element_entry
      AND pee.element_type_id = pet.element_type_id
      AND ((pet.legislation_code = 'US' and pet.business_group_id is null)
           or (pet.legislation_code is null and pet.business_group_id = cp_bus_grp))
      AND cp_date BETWEEN pee.effective_start_date
                      AND pee.effective_end_date
      AND cp_date BETWEEN pet.effective_start_date
                      AND pet.effective_end_date;


 l_time_def_id                  NUMBER;
 l_otlr_pref                    VARCHAR2 (30);
 l_ot_period_segment            NUMBER;
 l_otl_recurring_period         VARCHAR2 (120);
 l_person_id                    NUMBER;
 l_payroll_id                   NUMBER;
 l_jobs_us_flsa_code            VARCHAR2(150);
 no_otl_package_function        EXCEPTION;
 l_otl_text                     VARCHAR2(10000);
 l_default_time_def_name        pay_time_definitions.definition_name%TYPE;
 l_legislation_code             pay_time_definitions.legislation_code%TYPE;
 l_time_definition_id           NUMBER;
 l_time_def_date                DATE;
 l_element_name                 VARCHAR2(80);

 PRAGMA EXCEPTION_INIT (no_otl_package_function, -6550);

BEGIN

  -- OTL constants
  l_otlr_pref           := 'TC_W_RULES_EVALUATION';
  l_ot_period_segment   := 3;

  -- Default time definition name
  l_default_time_def_name := 'Non Allocated Time Definition';
  l_legislation_code      := 'US';

  l_time_def_id := NULL;
  l_time_def_date := p_time_def_date;

  /* Check if employee is flsa eligible */
  open get_jobs_us_flsa_code (l_time_def_date, p_assignment_id);
  fetch get_jobs_us_flsa_code into l_jobs_us_flsa_code;
  if get_jobs_us_flsa_code%NOTFOUND then
     l_jobs_us_flsa_code := 'EX';
  end if;
  close get_jobs_us_flsa_code;

  if l_jobs_us_flsa_code <> 'EX' then
     /* Cursor which checks if time_definition_id can be gathered
        from FLSA Time Definition element */
     open get_info_time_def_id ('FLSA Time Definition'
                               ,'Time Definition'
                               ,p_assignment_id
                               ,l_time_def_date );
     fetch get_info_time_def_id into l_time_def_id;
     if get_info_time_def_id%notfound or l_time_def_id is null then
        open get_assignment_info (p_assignment_id, l_time_def_date);
        fetch get_assignment_info into l_person_id, l_payroll_id;
        close get_assignment_info;

        -- Getting Overtime week id from OTL
/*         BEGIN
          v := 'BEGIN
                 :l_otl_recurring_period := hxc_preference_evaluation.resource_preferences ('
                   || 'p_resource_id     => :l_person_id ,'
                   || 'p_pref_code       => :l_otlr_pref ,'
                   || 'p_attribute_n     => :l_ot_period_segment ,'
                   || 'p_evaluation_date => :l_time_def_date '
                   || '); end;';

          EXECUTE IMMEDIATE v
                      USING  OUT l_otl_recurring_period,
                             IN l_person_id,
                             IN l_otlr_pref,
                             IN l_ot_period_segment,
                             IN l_time_def_date;
        EXCEPTION
           WHEN no_otl_package_function THEN
                l_otl_recurring_period := NULL ;
        END;
*/
        -- Get time_definition_id corresponding to Overtime Week Id
        l_otl_recurring_period := NULL ;

        if l_otl_recurring_period IS NOT NULL then
           open get_time_from_week (l_otl_recurring_period);
           fetch get_time_from_week into l_time_def_id;
           close get_time_from_week;
        end if;

         if l_time_def_id is null then
           -- Get time_definition_id corresponding to Overtime Week Id
           open get_payroll_time_definition_id (l_payroll_id,l_time_def_date);
           fetch get_payroll_time_definition_id into l_time_def_id;
           close get_payroll_time_definition_id;
        end if;
     end if;
     close get_info_time_def_id;

     open chk_seeded_elements(p_element_entry_id
                            ,p_business_group_id
                            ,p_time_def_date);
     fetch chk_seeded_elements into l_element_name;

     close chk_seeded_elements;

  end if;

  /*If time_definition_id is still null till this point we assign
    it the default time_definition
  */
  IF (l_time_def_id IS NULL) or
     (l_time_def_id is not null and l_element_name = 'Regular Salary') or
     (l_time_def_id is not null and l_element_name = 'Regular Wages') THEN
     open get_default_time_definition_id(l_default_time_def_name
                                        ,l_legislation_code);
     fetch get_default_time_definition_id into l_time_def_id;
     close get_default_time_definition_id;
  END IF;

  l_time_definition_id := l_time_def_id;

  return l_time_definition_id;
END get_time_def_for_entry_func;

-- Procedures / Functions Added for (Archived) Check Writer Process

 PROCEDURE add_custom_xml(P_ASSIGNMENT_ACTION_ID IN NUMBER ,
                          P_ACTION_INFORMATION_CATEGORY IN VARCHAR2,
                          P_DOCUMENT_TYPE IN VARCHAR2)  IS

   CURSOR get_net_pay(CP_ASSIGNMENT_ACTION_ID IN NUMBER) IS
       SELECT net_pay
        FROM  PAY_AC_EMP_SUM_ACTION_INFO_V
       WHERE  action_context_id = cp_assignment_action_id
         AND  action_information_category = 'AC SUMMARY CURRENT';

   CURSOR get_net_pay_ytd(CP_ASSIGNMENT_ACTION_ID IN NUMBER) is
       SELECT net_pay
       FROM PAY_AC_EMP_SUM_ACTION_INFO_V
       WHERE action_context_id = cp_assignment_action_id
       AND ACTION_INFORMATION_CATEGORY = 'AC SUMMARY YTD';

CURSOR get_check_depoad_details ( arch_assact_id in number ,
                                  chk_assact_id  in number) IS

SELECT pai.action_information16, ppt.CATEGORY, pai.action_information5,
       pai.action_information6, pai.action_information7,
       pai.action_information8, pai.action_information9,
       pai.action_information10, paa.serial_number
  FROM pay_action_information pai,
       pay_org_payment_methods_f popmf,
       pay_payment_types ppt,
       pay_assignment_actions paa
 WHERE pai.action_context_id = arch_assact_id
   AND pai.action_information_category = 'EMPLOYEE NET PAY DISTRIBUTION'
   AND paa.assignment_action_id = chk_assact_id
   AND popmf.org_payment_method_id = pai.action_information1
   AND popmf.payment_type_id = ppt.payment_type_id
   AND paa.pre_payment_id = pai.action_information15
   AND pai.effective_date BETWEEN popmf.effective_start_date AND popmf.effective_end_date;

CURSOR get_preassact_id ( arch_assact_id in number) IS
SELECT locked_action_id
  FROM pay_action_interlocks
 WHERE locking_action_id = arch_assact_id;

CURSOR get_depoadvice_deatils ( arch_assact_id in number) IS
SELECT pai.action_information5,
       DECODE (pai.action_information6,
               'C', 'Checking Account',
               'Savings Account'
              ),
       pai.action_information7, pai.action_information8,
       pai.action_information9, pai.action_information10,
       pai.action_information17, pai.action_information16
  FROM pay_action_information pai,
       pay_org_payment_methods_f popmf,
       pay_payment_types ppt
 WHERE pai.action_information_category = 'EMPLOYEE NET PAY DISTRIBUTION'
   AND pai.action_context_id = arch_assact_id
   AND pai.action_information1 = popmf.org_payment_method_id
   AND popmf.payment_type_id = ppt.payment_type_id
   AND ppt.CATEGORY = 'MT'
   AND pai.effective_date BETWEEN popmf.effective_start_date AND popmf.effective_end_date ;

 CURSOR get_check_num_for_depad ( cp_assignment_action_id in number ) IS
 SELECT paa.serial_number, pain.action_information16 ,
        pain.action_information9 ,
        DECODE (pain.action_information6,
               'C', 'Checking Account',
               'Savings Account'
              ),
        pain.action_information7
  FROM pay_action_interlocks pai,
       pay_assignment_actions paa,
       pay_payroll_actions ppa,
       pay_action_interlocks pai1,
       pay_action_information pain
 WHERE pai.locking_action_id = cp_assignment_action_id
   AND pai.locked_action_id = pai1.locked_action_id
   AND pai.locking_action_id <> pai1.locking_action_id
   AND pai1.locking_action_id = paa.assignment_action_id
   AND paa.payroll_action_id = ppa.payroll_action_id
   AND ppa.action_type = 'H'
   AND pain.action_information15 = paa.pre_payment_id
   AND pain.action_context_id = pai.locking_action_id
   AND pain.action_information_category = 'EMPLOYEE NET PAY DISTRIBUTION' ;


CURSOR get_business_group_dtls ( cp_assignment_action_id in number ) IS
select ppa.business_group_id,
       pai.tax_unit_id,
       pai.action_information2,
       pai.effective_date,
       ppa.payroll_action_id
from
      pay_action_information pai,
      pay_payroll_actions ppa
where pai.action_context_id=cp_assignment_action_id
AND ppa.payroll_action_id= (select payroll_action_id
                              from pay_assignment_actions
                              where assignment_action_id = cp_assignment_action_id)
and   pai.action_context_type = 'AAP'
AND   pai.action_information_category = 'EMPLOYEE DETAILS' ;

 CURSOR get_us_employer_addr ( cp_organization_id in number,cp_payroll_action_id in number ) IS
 SELECT
      DISTINCT
      action_information5,
      action_information6,
      action_information7,
      action_information8,
    --  action_information9,
      action_information10,
      action_information12,
      action_information13
    FROM
      pay_action_information pai,
      pay_payroll_actions ppa
    WHERE action_context_type = 'PA'
      AND action_context_id=ppa.payroll_action_id
      AND action_information_category = 'ADDRESS DETAILS'
      AND action_information14 = 'Employer Address'
      AND action_context_id=cp_payroll_action_id
      AND pai.action_information1 = cp_organization_id;

  CURSOR get_net_pay_dstr_details ( cp_assignment_action_id in number) IS
  SELECT check_deposit_number,
         segment5,
         segment2,
         segment3,
         value from
  pay_emp_net_dist_action_info_v
  WHERE action_context_id=cp_assignment_action_id;

 ln_amount                    number;
 lv_amount_in_word            varchar2(200);
 ln_net_pay_ytd               number;
 ln_deposit_advice_number     number ;
 lv_check_number              varchar2(200);
 ln_check_value               number ;
 lv_account_name              varchar2(200);
 lv_account_type              varchar2(200);
 ln_account_number            varchar2(200);
 lv_transit_code              varchar2(200);
 lv_bank_name                 varchar2(200);
 lv_bank_branch               varchar2(200);
 ln_depoad_num                number ;
 lv_category                  varchar2(200) := 'DA';
 ln_account_number1           number ;
 ln_business_group_id         number;
 ln_tax_unit_id               number;
 ln_organization_id           number;
 ld_effective_date            date;
 ln_payroll_action_id         number;

 /*employer address 9382065 */
lv_employer_address1 pay_action_information.action_information5%type;
lv_employer_address2  pay_action_information.action_information6%type;
lv_employer_address3  pay_action_information.action_information7%type;
lv_employer_city pay_action_information.action_information8%type;
lv_employer_state pay_action_information.action_information10%type;
lv_employer_zip_code pay_action_information.action_information12%type;
lv_employer_country  pay_action_information.action_information13%type;

 BEGIN
   hr_utility.trace ('Entering '|| 'pay_us_rules. _xml');
   hr_utility.trace('p_assignment_action_id '|| p_assignment_action_id);
   hr_utility.trace('p_action_information_category '|| p_action_information_category);
   hr_utility.trace('p_document_type '|| p_document_type);

/* Added the code for US pdf payslip enhancement bug:9382065 */
   IF p_document_type = 'PAYSLIP'
     AND p_action_information_category IS NULL THEN


     OPEN get_business_group_dtls(p_assignment_action_id);
     FETCH get_business_group_dtls into ln_business_group_id,ln_tax_unit_id,ln_organization_id,ld_effective_date,ln_payroll_action_id;
     CLOSE get_business_group_dtls;

     ln_organization_id := pay_payslip_util.get_id_for_employer_address(ln_business_group_id
                                                                                  ,ln_tax_unit_id
                                                                                  ,ln_organization_id
                                                                                  ,ld_effective_date);

     /* Ref Bug: 9382065: Following code added to get Employer address based on Self Service preferences segment
        'Payslip Employer Address' at BG level if this value is 'G' then Getting GRE address as employer address
	otherwise the Employer address by default organization address

     */
     OPEN get_us_employer_addr(ln_organization_id,ln_payroll_action_id);
      FETCH get_us_employer_addr INTO  lv_employer_address1,
                                       lv_employer_address2,
                                       lv_employer_address3,
                                       lv_employer_city,
                                       lv_employer_state,
                                       lv_employer_zip_code,
                                      lv_employer_country ;
      CLOSE get_us_employer_addr;

            pay_payroll_xml_extract_pkg.load_xml_data('CS','US_EMPLOYER_ADDRESS',null);
            pay_payroll_xml_extract_pkg.load_xml_data('D','ORGANIZATION_ID',ln_organization_id);
            pay_payroll_xml_extract_pkg.load_xml_data('D','ADDRESS_TYPE','US Employer Address');
            pay_payroll_xml_extract_pkg.load_xml_data('D','ADDRESS1',lv_employer_address1);
            pay_payroll_xml_extract_pkg.load_xml_data('D','ADDRESS2',lv_employer_address2);
            pay_payroll_xml_extract_pkg.load_xml_data('D','ADDRESS3',lv_employer_address3);
            pay_payroll_xml_extract_pkg.load_xml_data('D','CITY',lv_employer_city);
            pay_payroll_xml_extract_pkg.load_xml_data('D','STATE',lv_employer_state);
            pay_payroll_xml_extract_pkg.load_xml_data('D','ZIP_CODE',lv_employer_zip_code);
            pay_payroll_xml_extract_pkg.load_xml_data('D','COUNTRY',lv_employer_country);
            pay_payroll_xml_extract_pkg.load_xml_data('CE','US_EMPLOYER_ADDRESS',null);

/*Bug:9439388: Added the code to display net pay distribution section on pdf payslip
  it appends net pay distribution details with new context US_EMPLOYEE_NET_PAY_DISTRIBUTION */

           OPEN get_net_pay_dstr_details (P_ASSIGNMENT_ACTION_ID);
           LOOP
           FETCH get_net_pay_dstr_details INTO lv_check_number,
                                             lv_bank_name,
                                             lv_account_type,
                                             ln_account_number,
                                             ln_check_value;
             IF get_net_pay_dstr_details%NOTFOUND THEN
             close get_net_pay_dstr_details;
             EXIT;
              ELSE
              pay_payroll_xml_extract_pkg.load_xml_data('CS','US_EMPLOYEE_NET_PAY_DISTRIBUTION',null);
              pay_payroll_xml_extract_pkg.load_xml_data('D','CHECK_DEPOSIT_NUMBER',lv_check_number);
              pay_payroll_xml_extract_pkg.load_xml_data('D','VALUE',ln_check_value);
              pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_TYPE',lv_account_type);
              pay_payroll_xml_extract_pkg.load_xml_data('D','BANK_NAME',lv_bank_name);
              pay_payroll_xml_extract_pkg.load_xml_data('D','MASK_ACCOUNT_NUMBER',HR_GENERAL2.mask_characters(ln_account_number));
              pay_payroll_xml_extract_pkg.load_xml_data('CE','US_EMPLOYEE_NET_PAY_DISTRIBUTION',null);

              END IF;
              END LOOP;

      END IF;

    /* Bug:9382065: Following code not needed for US payslip so added check to skip */

    IF p_action_information_category = 'EMPLOYEE DETAILS' AND  p_document_type <> 'PAYSLIP' THEN

      OPEN get_check_depoad_details(P_ASSIGNMENT_ACTION_ID,
                                    pay_archive_chequewriter.g_chq_asg_action_id);
      FETCH get_check_depoad_details INTO ln_check_value,
                                        lv_category,
                                        lv_account_name,
                                        lv_account_type,
                                        ln_account_number,
                                        lv_transit_code,
                                        lv_bank_name ,
                                        lv_bank_branch,
                                        lv_check_number ;
      CLOSE get_check_depoad_details;
      IF lv_category = 'CH' THEN
        pay_payroll_xml_extract_pkg.load_xml_data('D','CHECK_NUMBER',lv_check_number);
        lv_amount_in_word := CF_word_amountFormula(ln_check_value);
        pay_payroll_xml_extract_pkg.load_xml_data('D','AMOUNT_IN_WORDS',lv_amount_in_word);
        pay_payroll_xml_extract_pkg.load_xml_data('D','CHECK_AMOUNT',ln_check_value);
        pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_NAME',lv_account_name);
        pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_TYPE',lv_account_type);
        pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_NUMBER',ln_account_number);
        pay_payroll_xml_extract_pkg.load_xml_data('D','TRANSIT_CODE',lv_transit_code);
        pay_payroll_xml_extract_pkg.load_xml_data('D','BANK_NAME',lv_bank_name);
        pay_payroll_xml_extract_pkg.load_xml_data('D','BANK_BRANCH',lv_bank_branch);

       ELSE
         OPEN get_preassact_id (P_ASSIGNMENT_ACTION_ID);
         FETCH get_preassact_id INTO ln_deposit_advice_number ;
         CLOSE get_preassact_id ;
         pay_payroll_xml_extract_pkg.load_xml_data('D','DEPOSIT_FINAL_ADNUM',ln_deposit_advice_number);
         OPEN get_depoadvice_deatils(P_ASSIGNMENT_ACTION_ID);
         LOOP
         FETCH get_depoadvice_deatils INTO lv_account_name,
                                      lv_account_type,
                                      ln_account_number,
                                      lv_transit_code,
                                      lv_bank_name ,
                                      lv_bank_branch,
                                      ln_depoad_num ,
                                      ln_check_value ;
         IF get_depoadvice_deatils%NOTFOUND THEN
           close get_depoadvice_deatils ;
           exit;
         ELSE
            pay_payroll_xml_extract_pkg.load_xml_data('CS','CHECK_DETAILS',null);
            pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_NAME',lv_account_name);
            pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_TYPE',lv_account_type);
            pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_NUMBER',ln_account_number);
            pay_payroll_xml_extract_pkg.load_xml_data('D','TRANSIT_CODE',lv_transit_code);
            pay_payroll_xml_extract_pkg.load_xml_data('D','BANK_NAME',lv_bank_name);
            pay_payroll_xml_extract_pkg.load_xml_data('D','BANK_BRANCH',lv_bank_branch);
            pay_payroll_xml_extract_pkg.load_xml_data('D','DEPOSIT_ADVICE_NUMBER',ln_depoad_num);
            pay_payroll_xml_extract_pkg.load_xml_data('D','DEPOSIT_ADVICE_VALUE',ln_check_value);
            pay_payroll_xml_extract_pkg.load_xml_data('CE','CHECK_DETAILS',null);
        END IF;
        END LOOP;
    END IF;

   IF lv_category <> 'CH' THEN
           OPEN get_check_num_for_depad (P_ASSIGNMENT_ACTION_ID);
          LOOP
          FETCH get_check_num_for_depad INTO ln_account_number,
                                             ln_check_value,
                                             lv_bank_name,
                                             lv_account_type,
                                             ln_account_number1;
             IF get_check_num_for_depad%NOTFOUND THEN
             close get_check_num_for_depad;
             EXIT;
              ELSE
              pay_payroll_xml_extract_pkg.load_xml_data('CS','CHECK_DETAILS',null);
              pay_payroll_xml_extract_pkg.load_xml_data('D','DEPOSIT_ADVICE_NUMBER',ln_account_number);
              pay_payroll_xml_extract_pkg.load_xml_data('D','DEPOSIT_ADVICE_VALUE',ln_check_value);
              pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_TYPE',lv_account_type);
              pay_payroll_xml_extract_pkg.load_xml_data('D','BANK_NAME',lv_bank_name);
              pay_payroll_xml_extract_pkg.load_xml_data('D','ACCOUNT_NUMBER',ln_account_number1);
              pay_payroll_xml_extract_pkg.load_xml_data('CE','CHECK_DETAILS',null);


  END IF;
  END LOOP;
  END IF;
  END IF;

 IF p_action_information_category = 'AC SUMMARY YTD' THEN

    OPEN get_net_pay_ytd(p_assignment_action_id);
    FETCH get_net_pay_ytd INTO ln_net_pay_ytd;
    pay_payroll_xml_extract_pkg.load_xml_data('D','NET_PAY_YTD',ln_net_pay_ytd );
    CLOSE get_net_pay_ytd;

  END IF;

  IF p_action_information_category = 'AC SUMMARY CURRENT'  THEN

      OPEN get_net_pay(p_assignment_action_id);
      FETCH get_net_pay into ln_amount;
      CLOSE get_net_pay;

      pay_payroll_xml_extract_pkg.load_xml_data('D','NET_PAY',ln_amount);

  END IF;
    hr_utility.trace('exiting PAY_US_RULES.add_custom_xml');
  END add_custom_xml;

  FUNCTION CF_word_amountFormula(CP_LN_AMOUNT IN NUMBER) RETURN VARCHAR2 IS

      l_word_text varchar2(240);
      l_width number := 73;  -- Width of word amount field
  BEGIN
  l_word_text := get_word_value(cp_ln_amount);

  -- Format the output to have asterisks on right-hand side
  IF NVL(LENGTH(l_word_text), 0) <= l_width THEN
    l_word_text := rpad(l_word_text,l_width,'*');

  ELSIF NVL(LENGTH(l_word_text), 0) <= l_width*2 THEN
    -- Allow for word wrapping
    l_word_text := rpad(l_word_text,l_width*2 -
	                   (l_width-instr(substr(l_word_text,1,l_width+1),' ',-1)),'*');
  ELSIF NVL(LENGTH(l_word_text), 0) <= l_width*3 THEN

    l_word_text := rpad(l_word_text,l_width*3,'*');
  END IF;
  RETURN(l_word_text);
END CF_word_amountFormula ;

FUNCTION get_word_value (P_AMOUNT NUMBER) RETURN VARCHAR2 IS

  l_word_amount varchar2(240) := convert_number(trunc(p_amount));
  l_currency_word varchar2(240);
  l_log integer;
  l_unit_ratio number := 100;  --ie. the number of subunits(cents) in a unit(dollar)
  l_unit_singular       varchar2(6) := 'Dollar';
  l_unit_plural         varchar2(7) := 'Dollars';
  l_sub_unit_singular   varchar2(4) := 'Cent';
  l_sub_unit_plural     varchar2(5) := 'Cents';

  /* This is a workaround until bug #165793 is fixed */
  FUNCTION my_log (a integer, b integer) RETURN NUMBER IS
    BEGIN
      IF a <> 10 THEN RETURN(NULL);
      ELSIF b > 0 AND b <= 10 THEN RETURN(1);
      ELSIF b > 10 AND b <= 100 THEN RETURN(2);
      ELSIF b > 100 AND b <= 1000 THEN RETURN(3);
      ELSE RETURN(NULL);
      END IF;
    RETURN NULL;
  END my_log;

BEGIN
  l_log := my_log(10,l_unit_ratio);

  select  initcap(lower(
                l_word_amount||' '||
                decode(trunc(p_amount),
                      1,l_unit_singular,
                        l_unit_plural)||' And '||
                lpad(to_char(trunc((p_amount-trunc(p_amount))*l_unit_ratio)),
                      ceil(l_log),'0')||' '||
                decode(trunc((p_amount-trunc(p_amount))*l_unit_ratio),
                      1,l_sub_unit_singular,
                        l_sub_unit_plural)
              ))
  into    l_currency_word
  from    dual;

  RETURN(l_currency_word);
END get_word_value;

FUNCTION convert_number(IN_NUMERAL INTEGER := 0) RETURN VARCHAR2  IS

  number_too_large    exception;
  numeral             integer := abs(in_numeral);
  max_digit           integer := 9;  -- for numbers less than a (US) billion
  number_text         varchar2(240) := '';
  current_segment     varchar2(80);
  b_zero              varchar2(25) := 'Zero';
  b_thousand          varchar2(25) := ' Thousand ';
  thousand            number      := power(10,3);
  b_million           varchar2(25) := ' Million ';
  million             number      := power(10,6);

  FUNCTION convert_number (segment number) RETURN VARCHAR2 IS
    value_text  varchar2(80);
  BEGIN
    value_text := to_char( to_date(segment,'YYYY'),'Yyyysp');
    RETURN(value_text);
  END;

BEGIN

  IF numeral >= power(10,max_digit) THEN
     RAISE number_too_large;
  END IF;

  IF numeral = 0 THEN
     RETURN(b_zero);
  END IF;

  current_segment := trunc(numeral/million);
  numeral := numeral - (current_segment * million);
  IF current_segment <> 0 THEN
     number_text := number_text||convert_number(current_segment)||b_million;
  END IF;

  current_segment := trunc(numeral/thousand);
  numeral := numeral - (current_segment * thousand);
  IF current_segment <> 0 THEN
     number_text := number_text||convert_number(current_segment)||b_thousand;
  END IF;

  IF numeral <> 0 THEN
     number_text := number_text||convert_number(numeral);
  END IF;

  number_text := substr(number_text,1,1) ||
                 rtrim(lower(substr(number_text,2,NVL(length(number_text), 0))));

  RETURN(number_text);

EXCEPTION
  WHEN number_too_large THEN
        RETURN(null);
  WHEN OTHERS THEN
        RETURN(null);
END convert_number ;
--
--
-- Added this procedure to be used by Global Payslip Printing Solution for US
PROCEDURE get_token_names(p_pa_token OUT NOCOPY varchar2
                         ,p_cs_token OUT NOCOPY varchar2) IS
BEGIN

p_pa_token := 'TRANSFER_PAYROLL_ID';
p_cs_token := 'TRANSFER_CONSOLIDATION_SET_ID';

END get_token_names;
--
--
--
--
FUNCTION get_payslip_sort_order1 RETURN VARCHAR2 IS
BEGIN
  return NULL;
END get_payslip_sort_order1;
--
FUNCTION get_payslip_sort_order2 RETURN VARCHAR2 IS
lv_sort_order2   varchar2(50);
BEGIN
  lv_sort_order2 := 'ORGANIZATION_NAME';
  return lv_sort_order2;
END get_payslip_sort_order2;
--
FUNCTION get_payslip_sort_order3 RETURN VARCHAR2 IS
  lv_sort_order3  varchar2(50);
BEGIN
  lv_sort_order3 := 'LAST_NAME';
  return lv_sort_order3;
END get_payslip_sort_order3;
--
--
--
PROCEDURE payslip_range_cursor(p_pactid in number
                              ,p_sqlstr out NOCOPY varchar2) IS

lv_sqlstr VARCHAR2(32000);

BEGIN
    hr_utility.trace('Entering pay_us_rules.payslip_range_cursor');
    lv_sqlstr := NULL;
    pay_us_deposit_advice_pkg.DAxml_range_cursor(pactid => p_pactid
                                                ,psqlstr => lv_sqlstr);
    hr_utility.trace('Returning lv_sqlstr := ' || lv_sqlstr);

    p_sqlstr := lv_sqlstr;

END payslip_range_cursor;
--
--
END PAY_US_RULES;


/
