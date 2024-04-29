--------------------------------------------------------
--  DDL for Package Body PAY_US_ELEMENT_ENTRY_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_ELEMENT_ENTRY_HOOK" AS
/* $Header: pyuseehd.pkb 120.2.12010000.3 2010/01/25 08:06:55 emunisek ship $ */
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

    Name        : PAY_US_ELEMENT_ENTRY_HOOK
    File Name   : pyuseehd.pkb

    Description : This package is called from the AFTER INSERT/UPDATE/DELETE
                  User Hooks. The following are the functionalities present
                  in User Hook

                  1. Create/Update/Delete Recurring Element Entries for
                     Augment Elements
                  2. Create Tax Records for the Employee if Jurisdiction
                     code is entered.
                  3. Create/Update/Delete Premium Recalc Element Entries for
                     Premium Elements

    Change List
    -----------
    Name           Date          Version Bug      Text
    -------------- -----------   ------- -------  -----------------------------
    mikarthi       05-Dec-2008   115.14  7269277  Jurisdiction Code Validation
    rdhingra       22-Mar-2006   115.13  5042715  R12 Performance Fixes on cursors
                                                  c_get_nrec_mop_up_dates
						  c_get_rec_mop_up_dates
    sackumar       17-Nov-2005   115.12  4728252  Introduced a check for jurisdiction_code < 11
						  in Create_tax_record procedure.
    kvsankar       20-SEP-2005   115.11  FLSA     Modified
                                                  update_premium_mop_up_element
                                                  and
                                                  create_premium_mop_up_element
                                                  to set the Mulitple input
                                                  value of the Adjustment
                                                  element.
    rdhingra       16-SEP-2005   115.10  FLSA     Correcting the file version in
                                                  history and arcs
    rdhingra       16-SEP-2005   115.9   FLSA     Changed update_premium_mop_up_element
                                                  and create_premium_mop_up_element to
                                                  take of creation/deletion of mopup
                                                  depending on date earned given
                                                  Changed message text in
                                                  create_premium_mop_up_element
    asasthan       06-SEP-2005  115.7   FLSA     Changed c_get_rec_mop_up_dates
    kvsankar       30-AUG-2005   115.6   FLSA     Corrected GSCC Errors
    kvsankar       30-AUG-2005   115.6   FLSA     Added code for creating
                                                  ' for FLSA Period Adjustment'
                                                  Recalc Element Entry
    kvsankar       11-AUG-2005   115.5   FLSA     Modified the Creator Type
                                                  to 'FL'
    kvsankar       28-JUL-2005   115.4   FLSA     Modified CHECK_AUGMENT_ELEM
                                                  procedure
    kvsankar       27-JUL-2005   115.3   FLSA     Removed code giving warning
                                                  message for Payroll change
    kvsankar       27-JUL-2005   115.2   FLSA     Incorporated Changes for
                                                  Penny Issue for Augments.
    kvsankar       20-JUL-2005   115.1            Corrected GSCC errors and
                                                  warnings.
    kvsankar       19-JUL-2005   115.0   FLSA     Created
  *****************************************************************************/

/******************************************************************************
   Name        : GET_DAILY_AMOUNT
   Scope       : LOCAL
   Description : This function is called to get the daily amount that will
                 be entered in the recurring element entry created for the
                 Augment element.
******************************************************************************/
FUNCTION GET_DAILY_AMOUNT(
   p_assignment_id  in number
  ,p_start_date     in date
  ,p_end_date       in date
  ,p_inp_value_name in varchar2
  ,p_inp_value      in number
) RETURN number IS

ln_daily_rate number;
ln_no_of_days number;
BEGIN
   hr_utility.trace('Entering PAY_US_ELEMENT_ENTRY_HOOK.GET_DAILY_AMOUNT');

   -- Initialization Code
   ln_daily_rate := 0;

   -- Get the number of days between Start Date and End Date
   ln_no_of_days := p_end_date - p_start_date + 1;
   ln_daily_rate := round((nvl(p_inp_value,0)/ln_no_of_days),2);

   hr_utility.trace('DAILY AMOUNT = ' || ln_daily_rate);
   hr_utility.trace('Leaving PAY_US_ELEMENT_ENTRY_HOOK.GET_DAILY_AMOUNT');
   return ln_daily_rate ;

EXCEPTION
  WHEN OTHERS THEN
    return NULL;
END GET_DAILY_AMOUNT;

/******************************************************************************
   Name        : CHECK_AUGMENT_ELEM
   Scope       : LOCAL
   Description : This function is called to check whether the element getting
                 added is an Augment element.
******************************************************************************/
FUNCTION CHECK_AUGMENT_ELEM(
   p_assignment_id           in number
  ,p_element_entry_id        in number
  ,p_effective_start_date    in date
  ,p_element_name            out nocopy varchar2
  ,p_business_group_id       out nocopy number
) RETURN boolean IS

-- Cursor to fetch Earned Start and Earned End Date
cursor c_check_aug_entry is
select petf.element_name
      ,petf.business_group_id
      ,pivf.name
      ,peevf.screen_entry_value
  from pay_element_entries_f peef
      ,pay_element_types_f petf
      ,pay_element_entry_values_f peevf
      ,pay_input_values_f pivf
      ,pay_status_processing_rules_f psprf
      ,ff_formulas_f fff
      ,pay_element_classifications pec
 where peef.element_entry_id = p_element_entry_id
   and petf.element_type_id = peef.element_type_id
   and petf.processing_type = 'N'
   and psprf.element_type_id = petf.element_type_id
   and fff.formula_id = psprf.formula_id
   and fff.formula_name like '%_FLAT_AMOUNT_NRRWOSI'
   and peevf.element_entry_id = peef.element_entry_id
   and pivf.element_type_id = peef.element_type_id
   and peevf.input_value_id = pivf.input_value_id
   and upper(pivf.name) in ('EARNED START DATE',
                            'EARNED END DATE')
   and pec.classification_id = petf.classification_id
   and pec.classification_name = 'Supplemental Earnings'
   and pec.legislation_code = 'US'
   and p_effective_start_date between peef.effective_start_date
                                  and peef.effective_end_date
   and p_effective_start_date between petf.effective_start_date
                                  and petf.effective_end_date
   and p_effective_start_date between peevf.effective_start_date
                                  and peevf.effective_end_date
   and p_effective_start_date between pivf.effective_start_date
                                  and pivf.effective_end_date
   and p_effective_start_date between psprf.effective_start_date
                                  and psprf.effective_end_date;

-- Cursor to fetch Assignment Start Date
cursor c_check_assignment_validity(c_assignment_id number
                                  ,c_start_date    date) is
select 1
  from per_assignments_f paf
 where paf.assignment_id = c_assignment_id
   and paf.effective_start_date <= c_start_date;

-- Cursor to get Period Start and End Dates
cursor c_get_period_dates(c_assignment_id        number
                         ,c_effective_start_date date) is
select ptp.start_date
      ,ptp.end_date
  from per_assignments_f paf,
       per_time_periods ptp
 where paf.assignment_id = c_assignment_id
   and ptp.payroll_id = paf.payroll_id
   and c_effective_start_date between paf.effective_start_date
                                  and paf.effective_end_date
   and c_effective_start_date between ptp.start_date
                                  and ptp.end_date;

lv_inp_val_name       VARCHAR2(100);
lv_screen_entry_value VARCHAR2(100);
ln_count              NUMBER;
ln_dummy_var          NUMBER;
lb_aug_flag           BOOLEAN;
ld_rec_ele_start_date DATE;
ld_rec_ele_end_date   DATE;

BEGIN
   hr_utility.trace('Entering PAY_US_ELEMENT_ENTRY_HOOK.CHECK_AUGMENT_ELEM');

   ln_count              := 0;
   ld_rec_ele_end_date   := NULL;
   ld_rec_ele_start_date := NULL;

   open c_check_aug_entry;
   loop
      fetch c_check_aug_entry into p_element_name
                                  ,p_business_group_id
                                  ,lv_inp_val_name
                                  ,lv_screen_entry_value;
      exit when c_check_aug_entry%NOTFOUND;

      hr_utility.trace('Element Name = ' || p_element_name);
      hr_utility.trace('Business Group ID = ' || p_business_group_id);
      hr_utility.trace(lv_inp_val_name || ' = ' || lv_screen_entry_value);

      ln_count := ln_count + 1;

      if (upper(lv_inp_val_name) = 'EARNED START DATE'
          AND lv_screen_entry_value IS NOT NULL) then
         ld_rec_ele_start_date :=
                            fnd_date.canonical_to_date(lv_screen_entry_value);
      elsif (upper(lv_inp_val_name) = 'EARNED END DATE'
          AND lv_screen_entry_value IS NOT NULL) then
         ld_rec_ele_end_date :=
                            fnd_date.canonical_to_date(lv_screen_entry_value);
      end if; -- if (upper(lv_inp_val_name) ....
   end loop;
   close c_check_aug_entry;

   -- Check for Augment Element
   if ln_count < 2 then
      lb_aug_flag := FALSE;
   else
      lb_aug_flag := TRUE;
   end if; -- if ln_count < 2

   if lb_aug_flag then
      -- Checking for all ERROR conditions for the Augment element
      if (ld_rec_ele_start_date IS NULL
          AND ld_rec_ele_end_date IS NOT NULL) then
         hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
         hr_utility.set_message_token('FORMULA_TEXT',
                        'Please specify Earned Start Date');
         hr_utility.raise_error;
      elsif (ld_rec_ele_start_date IS NOT NULL
             AND ld_rec_ele_end_date IS NULL) then
         hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
         hr_utility.set_message_token('FORMULA_TEXT',
                        'Please specify Earned End Date');
         hr_utility.raise_error;
      elsif (ld_rec_ele_start_date IS NOT NULL
             AND ld_rec_ele_end_date IS NOT NULL) then
         if (ld_rec_ele_end_date < ld_rec_ele_start_date) then
            hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
            hr_utility.set_message_token('FORMULA_TEXT',
                'Please specify Earned End Date greater than Earned Start Date');
            hr_utility.raise_error;
         end if;
      else
         -- Both the Start Date and End Date are NULL
         open c_get_period_dates(p_assignment_id
                                ,p_effective_start_date);
         fetch c_get_period_dates into ld_rec_ele_start_date
                                      ,ld_rec_ele_end_date;
         close c_get_period_dates;
         hr_utility.trace('Updating the Element Entry values for the NR Element');
         -- Updating the Start Date to the Payroll Start Date
         update pay_element_entry_values_f peev
            set screen_entry_value = fnd_date.date_to_canonical
                                          (ld_rec_ele_start_date)
          where element_entry_value_id =
                (select distinct peev1.element_entry_value_id
                  from pay_element_entry_values_f peev1,
                       pay_element_entries_f peef,
                       pay_input_values_f pivf
                 where peef.element_entry_id = p_element_entry_id
                   and pivf.element_type_id = peef.element_type_id
                   and upper(pivf.name) = 'EARNED START DATE'
                   and peev1.element_entry_id = peef.element_entry_id
                   and peev1.input_value_id = pivf.input_value_id);

         -- Updating the End Date to the Payroll End Date
         update pay_element_entry_values_f peev
            set screen_entry_value = fnd_date.date_to_canonical
                                          (ld_rec_ele_end_date)
          where element_entry_value_id =
                (select distinct peev1.element_entry_value_id
                  from pay_element_entry_values_f peev1,
                       pay_element_entries_f peef,
                       pay_input_values_f pivf
                 where peef.element_entry_id = p_element_entry_id
                   and pivf.element_type_id = peef.element_type_id
                   and upper(pivf.name) = 'EARNED END DATE'
                   and peev1.element_entry_id = peef.element_entry_id
                   and peev1.input_value_id = pivf.input_value_id);
      end if; -- if (ld_rec_ele_start_date  ....

      -- Raise Error if the assignment is not valid as of Start Date
      open c_check_assignment_validity(p_assignment_id
                                      ,ld_rec_ele_start_date);
      fetch c_check_assignment_validity into ln_dummy_var;
      if c_check_assignment_validity%NOTFOUND then
         close c_check_assignment_validity;
         hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
         hr_utility.set_message_token('FORMULA_TEXT',
                        'Assignment is not valid as of Earned Start Date');
         hr_utility.raise_error;
      end if;
      close c_check_assignment_validity;

      hr_utility.trace('BASE ELEMENT NAME = ' || p_element_name);
      hr_utility.trace('BUSINESS GROUP ID = ' || p_business_group_id);
   end if; -- if lb_aug_flag

   return lb_aug_flag;
END CHECK_AUGMENT_ELEM;

/******************************************************************************
   Name        : CHECK_PREMIUM_ELEM
   Scope       : LOCAL
   Description : This function is used for checking whether the element is a
                 PREMIUM element.
******************************************************************************/
FUNCTION CHECK_PREMIUM_ELEM(
   p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_element_name                 out nocopy varchar2
  ,p_processing_type              out nocopy varchar2
  ,p_business_group_id            out nocopy number
  ) RETURN BOOLEAN IS

cursor c_check_prem_elem(c_element_entry_id number
                        ,c_effective_start_date date) is
select petf.element_name
      ,petf.business_group_id
      ,petf.processing_type
  from pay_element_entries_f peef
      ,pay_element_types_f petf
      ,pay_status_processing_rules_f psprf
      ,ff_formulas_f fff
 where peef.element_entry_id = c_element_entry_id
   and petf.element_type_id = peef.element_type_id
   and psprf.element_type_id = petf.element_type_id
   and fff.formula_id = psprf.formula_id
   and fff.formula_name like '%_PREMIUM'
   and c_effective_start_date between peef.effective_start_date
                                  and peef.effective_end_date
   and c_effective_start_date between petf.effective_start_date
                                  and petf.effective_end_date
   and c_effective_start_date between psprf.effective_start_date
                                  and psprf.effective_end_date;

ln_business_group_id number;
lv_element_name      varchar2(100);
lv_processing_type   varchar2(10);
lb_prem_flag         boolean;

BEGIN

   hr_utility.trace('Inside CHECK_PREMIUM_ELEM');
   lb_prem_flag := FALSE;
   p_element_name      := NULL;
   p_processing_type   := NULL;
   p_business_group_id := NULL;

   -- Check for PREMIUM Element
   open c_check_prem_elem(p_element_entry_id
                         ,p_effective_start_date);
   fetch c_check_prem_elem into lv_element_name
                               ,ln_business_group_id
                               ,lv_processing_type;
   if c_check_prem_elem%FOUND THEN
      hr_utility.trace('Premium Element');
      lb_prem_flag        := TRUE;
      p_element_name      := lv_element_name;
      p_processing_type   := lv_processing_type;
      p_business_group_id := ln_business_group_id;
   end if;
   close c_check_prem_elem;

   return lb_prem_flag;
END CHECK_PREMIUM_ELEM;

/******************************************************************************
   Name        : DELETE_DEPENDENT_ENTRIES
   Scope       : LOCAL
   Description : This procedure is used to delete the element entry dependent
                 on current element entry.
******************************************************************************/
PROCEDURE DELETE_DEPENDENT_ENTRIES(
   p_element_entry_id              in number
  ,p_assignment_id                 in number) IS

-- Cursor to get the Recurring element entry id using
-- Cretor ID
cursor c_get_ele_entry_id(c_element_entry_id  varchar2
                         ,c_assignment_id     number) is
select max(peef.element_entry_id)
      ,min(peef.effective_start_date)
  from pay_element_entries_f peef
 where peef.creator_id = c_element_entry_id
   and peef.assignment_id = c_assignment_id
   and peef.creator_type = 'FL'
group by peef.element_entry_id
order by peef.element_entry_id;

ln_ele_entry_id        NUMBER;
ld_del_start_date      DATE;

BEGIN
   hr_utility.trace('Entering PAY_US_ELEMENT_ENTRY_HOOK.DELETE_DEPENDENT_ENTRIES');
   hr_utility.trace('P_ELEMENT_ENTRY_ID = ' ||p_element_entry_id);
   hr_utility.trace('P_ASSIGNMENT_ID = ' ||   p_assignment_id);

   open c_get_ele_entry_id(p_element_entry_id
                          ,p_assignment_id);
   loop
      -- Loop through all Element Entries and delete them
      fetch c_get_ele_entry_id into ln_ele_entry_id
                                   ,ld_del_start_date;
      exit when c_get_ele_entry_id%NOTFOUND;

      hr_utility.trace('Deleting Element Entry = ' || ln_ele_entry_id);
      hr_utility.trace('Deletion Date = ' ||  ld_del_start_date);
      hr_entry_api.delete_element_entry (
                    p_dt_delete_mode   => 'ZAP',
                    p_session_date     => ld_del_start_date,
                    p_element_entry_id => ln_ele_entry_id);
   end loop;
   close c_get_ele_entry_id;
   hr_utility.trace('Leaving PAY_US_ELEMENT_ENTRY_HOOK.DELETE_DEPENDENT_ENTRIES');
   return;

EXCEPTION
  --
  WHEN others THEN
    raise;
END DELETE_DEPENDENT_ENTRIES;

-----------------------------INSERT SECTION STARTS HERE------------------------

/******************************************************************************
   Name        : POPULATE_ELE_LINK
   Scope       : LOCAL
   Description : This function is called to populate the PL/SQL table with
                 the dates and the element links to be used for creating
                 the recurring element entry.
******************************************************************************/
PROCEDURE POPULATE_ELE_LINK(
   p_assignment_id       in number
  ,p_augment_elem_name   in varchar2
  ,p_start_date          in date
  ,p_end_date            in date
  ,p_business_group_id   in number
  ,p_inp_value_name      in varchar2
  ,p_inp_value           in number
  ,p_rec_element_type_id in number
) IS

-- Cursor to get the Element link details for the assignment
cursor c_get_link_details(c_element_type_id      number
                         ,c_assignment_id        number
                         ,c_effective_start_date date
                         ,c_effective_end_date   date) is
select paf.effective_start_date  Asgt_Start_Date
      ,paf.effective_end_date    Asgt_End_Date
      ,pelf.effective_start_date Link_Start_Date
      ,pelf.effective_end_date   Link_End_Date
      ,pelf.element_link_id      Element_Link_Id
  from pay_element_types_f petf,
       pay_element_links_f pelf,
       per_assignments_f paf
 where petf.element_type_id = c_element_type_id
   and petf.element_type_id = pelf.element_type_id
   and paf.assignment_id = c_assignment_id
   and c_effective_start_date <= paf.effective_end_date
   and c_effective_end_date >= paf.effective_start_date
   and c_effective_start_date <= pelf.effective_end_date
   and c_effective_end_date >= pelf.effective_start_date
   and (
         (pelf.effective_start_date between paf.effective_start_date
                                        and paf.effective_end_date)
         or
         (pelf.effective_end_date between paf.effective_start_date
                                      and paf.effective_end_date)
         or
         (
          pelf.effective_start_date < paf.effective_start_date
          and
          pelf.effective_end_date > paf.effective_end_date
         )
       )
   and (
        (pelf.payroll_id is not null and pelf.payroll_id = paf.payroll_id)
        or
        (pelf.link_to_all_payrolls_flag = 'Y' and paf.payroll_id is not null)
        or
        (pelf.payroll_id is null and pelf.link_to_all_payrolls_flag = 'N')
       )
   and (
        pelf.organization_id = paf.organization_id
        or
        pelf.organization_id is null
       )
   and (
        pelf.position_id = paf.position_id
        or
        pelf.position_id is null
       )
   and (
        pelf.job_id = paf.job_id
        or
        pelf.job_id is null
       )
   and (
        pelf.grade_id = paf.grade_id
        or
        pelf.grade_id is null
       )
   and (
        pelf.location_id = paf.location_id
        or
        pelf.location_id is null
       )
   and (
        pelf.pay_basis_id = paf.pay_basis_id
        or
        pelf.pay_basis_id is null
        )
   and (
        pelf.employment_category = paf.employment_category
        or
        pelf.employment_category is null
       )
   and (
        pelf.people_group_id is null
        or
        exists (
                select 1
                  from pay_assignment_link_usages_f usage
                 where usage.assignment_id = paf.assignment_id
                   and usage.element_link_id = pelf.element_link_id
                )
       )
   order by Asgt_Start_Date, Link_Start_Date;

ln_payroll_count       number;
ln_element_link_id     number;
ln_no_of_days          number;
ln_daily_amount        number;
ld_asgt_eff_start_date date;
ld_asgt_eff_end_date   date;
ld_link_eff_start_date date;
ld_link_eff_end_date   date;
ld_dummy_start_date    date;

BEGIN
   hr_utility.trace('Entering PAY_US_ELEMENT_ENTRY_HOOK.POPULATE_ELE_LINK');
   hr_utility.trace('p_assignment_id       = ' || p_assignment_id);
   hr_utility.trace('p_start_date          = ' || p_start_date);
   hr_utility.trace('p_end_date            = ' || p_end_date);
   hr_utility.trace('p_business_group_id   = ' || p_business_group_id);
   hr_utility.trace('p_inp_value_name      = ' || p_inp_value_name);
   hr_utility.trace('p_inp_value           = ' || p_inp_value);
   hr_utility.trace('p_rec_element_type_id = ' || p_rec_element_type_id);

   ld_dummy_start_date := p_start_date;
   gn_ele_ent_num      := 0;
   ln_element_link_id  := -9999;
   gn_link_id_tbl(0)   := 0;

   -- Find the PER Period value for the recurring element
   gn_daily_amount := GET_DAILY_AMOUNT(
                                   p_assignment_id  => p_assignment_id
                                  ,p_start_date     => p_start_date
                                  ,p_end_date       => p_end_date
                                  ,p_inp_value_name => p_inp_value_name
                                  ,p_inp_value      => p_inp_value);

   open c_get_link_details(p_rec_element_type_id
                          ,p_assignment_id
                          ,p_start_date
                          ,p_end_date);
   --
   loop
      fetch c_get_link_details into ld_asgt_eff_start_date
                                   ,ld_asgt_eff_end_date
                                   ,ld_link_eff_start_date
                                   ,ld_link_eff_end_date
                                   ,ln_element_link_id;
      exit when c_get_link_details%NOTFOUND;

      -- If the assignment itself is not valid on the Start date
      -- then throw an error saying Assignment is not valid on Start Date
      if (gn_ele_ent_num = 0 AND ld_asgt_eff_start_date > p_start_date) then
         close c_get_link_details;
         hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
         hr_utility.set_message_token('FORMULA_TEXT',
                   'Assignment is not Valid as of Earned Start Date');
         hr_utility.raise_error;
      end if; -- if (gn_ele_ent_num = 0 AND ....

      if ln_element_link_id <> gn_link_id_tbl(gn_ele_ent_num) then
         gn_ele_ent_num := gn_ele_ent_num + 1;
         gn_link_id_tbl(gn_ele_ent_num) := ln_element_link_id;
         if ld_asgt_eff_end_date > ld_link_eff_end_date then
            gd_start_date_tbl(gn_ele_ent_num) := ld_dummy_start_date;
            gd_end_date_tbl(gn_ele_ent_num)   := ld_link_eff_end_date;
         else
            gd_start_date_tbl(gn_ele_ent_num) := ld_dummy_start_date;
            gd_end_date_tbl(gn_ele_ent_num)   := ld_asgt_eff_end_date;
         end if; -- if ld_asgt_eff_end_date > ....

         if gd_end_date_tbl(gn_ele_ent_num) > p_end_date then
            gd_end_date_tbl(gn_ele_ent_num) := p_end_date;
         else
            ld_dummy_start_date := gd_end_date_tbl(gn_ele_ent_num) + 1;
         end if; -- if gd_end_date_tbl(gn_ele_ent_num) ....
         hr_utility.trace('gn_ele_ent_num = ' || gn_ele_ent_num);
         hr_utility.trace('Asgt Eff End Date = ' || ld_asgt_eff_end_date);
         hr_utility.trace('Link Eff End Date = ' || ld_link_eff_end_date);
         hr_utility.trace('Global Start Date = ' ||
                                           gd_start_date_tbl(gn_ele_ent_num));
         hr_utility.trace('Global End Date = ' ||
                                           gd_end_date_tbl(gn_ele_ent_num));
         hr_utility.trace('Link ID = ' || gn_link_id_tbl(gn_ele_ent_num));
      else
         if ld_asgt_eff_end_date > ld_link_eff_end_date then
            gd_end_date_tbl(gn_ele_ent_num) := ld_link_eff_end_date;
         else
            gd_end_date_tbl(gn_ele_ent_num) := ld_asgt_eff_end_date;
         end if; -- if ld_asgt_eff_end_date ....

         if gd_end_date_tbl(gn_ele_ent_num) > p_end_date then
            gd_end_date_tbl(gn_ele_ent_num) := p_end_date;
         else
            ld_dummy_start_date := gd_end_date_tbl(gn_ele_ent_num) + 1;
         end if; -- if gd_end_date_tbl(gn_ele_ent_num) ....

         hr_utility.trace('gn_ele_ent_num = ' || gn_ele_ent_num);
         hr_utility.trace('Global Start Date = ' ||
                                           gd_start_date_tbl(gn_ele_ent_num));
         hr_utility.trace('Global End Date = ' ||
                                           gd_end_date_tbl(gn_ele_ent_num));
         hr_utility.trace('Link ID = ' || gn_link_id_tbl(gn_ele_ent_num));
      end if; -- if ln_element_link_id <> ....

   end loop;
   close c_get_link_details;

   if gn_ele_ent_num = 0 then
      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT',
              'The assignment is not eligible for ' ||
              p_augment_elem_name || ' for FLSA Calc.' ||
              ' Please link the element to make it eligible to the assignment.');
      hr_utility.raise_error;
   elsif (gd_end_date_tbl(gn_ele_ent_num) < p_end_date) then
      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT',
              'The assignment is not eligible for ' ||
              p_augment_elem_name || ' for FLSA Calc.' ||
              ' Please link the element to make it eligible to the assignment.');
      hr_utility.raise_error;
   end if; -- if gn_ele_ent_num = 0
   return;
END POPULATE_ELE_LINK;

/******************************************************************************
   Name        : CREATE_RECUR_ELEM_ENTRY
   Scope       : LOCAL
   Description : This function is used for creating the recurring element
                 entry for an Augment element.
******************************************************************************/
PROCEDURE CREATE_RECUR_ELEM_ENTRY(
   p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_assignment_id                in number
  ,p_element_link_id              in number
  ,p_original_entry_id            in number
  ,p_creator_type                 in varchar2
  ,p_entry_type                   in varchar2
  ,p_entry_information_category   in varchar2) IS

-- Cursor to get all input value details
cursor c_get_elem_inp_value_details(c_element_entry_id number
                                   ,c_effective_date   date) is
select pivf.name
      ,peev.screen_entry_value
      ,pivf.lookup_type
  from pay_input_values_f pivf
      ,pay_element_entry_values_f peev
 where peev.element_entry_id = c_element_entry_id
   and peev.input_value_id = pivf.input_value_id
   and c_effective_date between peev.effective_start_date
                            and peev.effective_end_date
   and c_effective_date between pivf.effective_start_date
                            and pivf.effective_end_date
order by pivf.name;

-- Cursor to get Recurring Element inp value details
cursor c_get_rec_elem_inp_val_det(c_element_name varchar2
                                 ,c_business_grp_id number
                                 ,c_efective_start_date date) is
select petf.element_type_id
      ,pivf.input_value_id
      ,pivf.name
 from pay_element_types_f petf
     ,pay_input_values_f pivf
where petf.element_name like c_element_name  || ' for FLSA Calc'
  and petf.business_group_id = c_business_grp_id
  and pivf.element_type_id = petf.element_type_id
  and c_efective_start_date between pivf.effective_start_date
                                and pivf.effective_end_date
  and c_efective_start_date between petf.effective_start_date
                                and petf.effective_end_date;

-- Cursor to check if the Job is FLSA Eligible
cursor c_check_flsa_elig_job(c_assignment_id number
                            ,c_start_date    date
                            ,c_end_date      date) is
select 1
  from per_jobs perj
      ,per_jobs_tl perjtl
      ,per_all_assignments_f paa
 where paa.assignment_id = c_assignment_id
   and c_start_date <= paa.effective_end_date
   and c_end_date >= paa.effective_start_date
   and nvl(perj.job_information3, 'EX') = 'NEX'
   and paa.job_id = perj.job_id
   and paa.job_id = perjtl.job_id
   and userenv('lang') = perjtl.language;

-- Cursor to get Lookup Meaning
cursor c_get_lookup_value(c_lookup_type varchar2,
                          c_lookup_code varchar2) is
select meaning
  from hr_lookups
 where lookup_type = c_lookup_type
   and lookup_code = c_lookup_code
   and application_id = 800;


lv_element_name        VARCHAR2(200);
lv_inp_value_name      VARCHAR2(200);
lv_screen_entry_value  VARCHAR2(200);
lv_lookup_type         VARCHAR2(200);
lv_lookup_meaning      VARCHAR2(200);
lv_inp_value_to_divide VARCHAR2(200);
ln_business_grp_id     NUMBER;
ln_total_value         NUMBER;
ln_per_period_value    NUMBER;
ln_element_entry_id    NUMBER;
ln_original_entry_id   NUMBER;
ln_rec_element_type_id NUMBER;
ln_daily_amt_index     NUMBER;
ln_rec_element_link_id NUMBER;
ln_no_of_days          NUMBER;
ln_dummy_var           NUMBER;
ld_rec_ele_start_date  DATE;
ld_rec_ele_end_date    DATE;
ld_dummy_end_date      DATE;
lb_auth_flag           BOOLEAN;
l_input_value_name_tbl varchar2_table;
l_input_value_id_tbl   hr_entry.number_table;
l_entry_value_tbl      hr_entry.varchar2_table;
lvr                    number; -- loop variable


BEGIN

   hr_utility.trace('Entering PAY_US_ELEMENT_ENTRY_HOOK.CREATE_RECUR_ELEM_ENTRY');
   hr_utility.trace('P_ELEMENT_ENTRY_ID = ' ||p_element_entry_id);
   hr_utility.trace('P_EFFECTIVE_START_DATE = ' ||  p_effective_start_date);
   hr_utility.trace('P_EFFECTIVE_END_DATE = ' ||   p_effective_end_date);
   hr_utility.trace('P_ASSIGNMENT_ID = ' ||   p_assignment_id);
   hr_utility.trace('P_ELEMENT_LINK_ID = ' || p_element_link_id);
   hr_utility.trace('P_ORIGINAL_ENTRY_ID = ' || p_original_entry_id);
   hr_utility.trace('P_CREATOR_TYPE  = ' || p_creator_type);
   hr_utility.trace('P_ENTRY_TYPE = ' || p_entry_type);
   hr_utility.trace('P_ENTRY_INFORMATION_CATEGORY  = ' ||   p_entry_information_category);

   -- Initialization Code
   ln_business_grp_id     := NULL;
   ld_rec_ele_start_date  := NULL;
   ld_rec_ele_end_date    := NULL;
   ln_rec_element_type_id := NULL;
   lvr                    := 0;
   lv_lookup_type         := NULL;
   ln_daily_amt_index     := 0;
   ld_dummy_end_date      := fnd_date.canonical_to_date('4712/12/31');


   -- Check whether this element entry is an augment element.
   -- If not then we need not do anyhting additional
   lb_auth_flag := CHECK_AUGMENT_ELEM(p_assignment_id
                                     ,p_element_entry_id
                                     ,p_effective_start_date
                                     ,lv_element_name
                                     ,ln_business_grp_id);

   if NOT(lb_auth_flag) then
      return;
   end if;

   --  Query the input values of the Recurring Element
   -- and set the corresponding value to NULL
   open c_get_rec_elem_inp_val_det(lv_element_name
                                  ,ln_business_grp_id
                                  ,p_effective_start_date);
   loop
      lvr := lvr + 1;
      fetch c_get_rec_elem_inp_val_det into ln_rec_element_type_id
                                           ,l_input_value_id_tbl(lvr)
                                           ,l_input_value_name_tbl(lvr);
      exit when c_get_rec_elem_inp_val_det%NOTFOUND;
      hr_utility.trace('Rec Input Value Name = ' || l_input_value_name_tbl(lvr));
      if upper(l_input_value_name_tbl(lvr)) = 'DAILY AMOUNT' then
         ln_daily_amt_index := lvr;
      end if;
      l_entry_value_tbl(lvr) := NULL;
   end loop;
   close c_get_rec_elem_inp_val_det;

   -- Fetch the value of all input values and provide the same value to the
   -- corresponding input value of the recurring element
   open c_get_elem_inp_value_details(p_element_entry_id,
                                     p_effective_start_date);
   loop
      fetch c_get_elem_inp_value_details into lv_inp_value_name
                                             ,lv_screen_entry_value
                                             ,lv_lookup_type;
      exit when c_get_elem_inp_value_details%NOTFOUND;
      hr_utility.trace('Input Value Name = ' || lv_inp_value_name);
      hr_utility.trace('Input Value = ' || lv_screen_entry_value);
      hr_utility.trace('Look Up Type = ' || lv_lookup_type);

      if upper(lv_inp_value_name) = 'EARNED START DATE' then
         if lv_screen_entry_value is null then
            ld_rec_ele_start_date := NULL;
            exit;
         else
            ld_rec_ele_start_date :=
                            fnd_date.canonical_to_date(lv_screen_entry_value);
            hr_utility.trace('Start Date = ' || to_char(ld_rec_ele_start_date,'DD-MON-YYYY'));
         end if; -- if lv_screen_entry_value is null
      elsif upper(lv_inp_value_name) = 'EARNED END DATE' then
         if lv_screen_entry_value is null then
            ld_rec_ele_end_date := NULL;
            exit;
         else
            ld_rec_ele_end_date :=
                            fnd_date.canonical_to_date(lv_screen_entry_value);
            hr_utility.trace('End Date = ' || to_char(ld_rec_ele_end_date,'DD-MON-YYYY'));
         end if; -- if lv_screen_entry_value is null
      elsif (upper(lv_inp_value_name) in ('AMOUNT')) THEN
         lv_inp_value_to_divide := lv_inp_value_name;
         ln_total_value := to_number(nvl(lv_screen_entry_value, '0'));
      else
         -- The else logic below is commented as the recurring element
         -- will always have one input value namely 'Daily Amount'
         -- for Augment which needs to be specified.
         -- This code can be reused if we have to copy over values
         -- from the Non recurrning element to Recurring element
         -- in future.
         hr_utility.trace('Commented Else part as not required');
         /*
         for i in l_input_value_name_tbl.first..l_input_value_name_tbl.last
         loop
            if l_input_value_name_tbl(i) = lv_inp_value_name then
               hr_utility.trace('Input Value Found');
               if lv_lookup_type is NOT NULL then
                  open c_get_lookup_value(lv_lookup_type
                                         ,lv_screen_entry_value);
                  fetch c_get_lookup_value into lv_lookup_meaning;
                  close c_get_lookup_value;
                  hr_utility.trace('Lookup Meaning = ' || lv_lookup_meaning);
                  l_entry_value_tbl(i) := lv_lookup_meaning;
                  lv_lookup_type := NULL;
               else
                  l_entry_value_tbl(i) := lv_screen_entry_value;
               end if; -- if lv_lookup_type is NOT NULL
            end if; -- if l_input_value_name_tbl(i) ....
         end loop;
         */
      end if; -- if upper(lv_inp_value_name)
   end loop;
   close c_get_elem_inp_value_details;

   -- If Either the start date or the End date is null, then we should not
   -- create the recurring element entry
   if ((ld_rec_ele_start_date is NULL) or (ld_rec_ele_end_date is NULL)) then
      return;
   end if;

   -- Check whether the person has a FLSA Eligible job between the
   -- Start Date and End Date
   open c_check_flsa_elig_job(p_assignment_id
                             ,ld_rec_ele_start_date
                             ,ld_rec_ele_end_date);
   fetch c_check_flsa_elig_job into ln_dummy_var;
   if c_check_flsa_elig_job%NOTFOUND then
      hr_utility.trace('Job is NOT FLSA Eligible');
      close c_check_flsa_elig_job;
      return;
   end if;
   close c_check_flsa_elig_job;

   POPULATE_ELE_LINK(p_assignment_id       => p_assignment_id
                    ,p_augment_elem_name   => lv_element_name
                    ,p_start_date          => ld_rec_ele_start_date
                    ,p_end_date            => ld_rec_ele_end_date
                    ,p_business_group_id   => ln_business_grp_id
                    ,p_inp_value_name      => lv_inp_value_to_divide
                    ,p_inp_value           => ln_total_value
                    ,p_rec_element_type_id => ln_rec_element_type_id
                    );


   -- Create Recurrin Element Entry
   for lvr in 1..gn_ele_ent_num loop
      hr_utility.trace('Creating Recurring Element Entries');
      hr_utility.trace('Element Start Date = ' || gd_start_date_tbl(lvr));
      hr_utility.trace('Element End Date = ' || gd_end_date_tbl(lvr));
      hr_utility.trace('Entry Daily Amount = ' || gn_daily_amount);

      l_entry_value_tbl(ln_daily_amt_index) := gn_daily_amount;
      ld_dummy_end_date := gd_end_date_tbl(lvr);

      hr_entry_api.insert_element_entry (
         p_effective_start_date        => gd_start_date_tbl(lvr)
        ,p_effective_end_date          => ld_dummy_end_date
        ,p_element_entry_id            => ln_element_entry_id
        ,p_original_entry_id           => ln_original_entry_id
        ,p_assignment_id               => p_assignment_id
        ,p_element_link_id             => gn_link_id_tbl(lvr)
        ,p_creator_type                => 'FL'
        ,p_creator_id                  => p_element_entry_id
        ,p_entry_type                  => 'E' -- Normal Entry
        ,p_entry_information_category  => null
        --
        -- Element Entry Values Table
        --
        ,p_num_entry_values            => l_entry_value_tbl.count()
        ,p_input_value_id_tbl          => l_input_value_id_tbl
        ,p_entry_value_tbl             => l_entry_value_tbl
         );

      -- End dating the element using gd_end_date_tbl(lvr)
      -- as ld_dummy_end_date gets overwritten by the
      -- previous call
      if ld_dummy_end_date <> gd_end_date_tbl(lvr) then
         hr_entry_api.delete_element_entry (
             p_dt_delete_mode   => 'DELETE',
             p_session_date     => gd_end_date_tbl(lvr),
             p_element_entry_id => ln_element_entry_id);
      end if;

      -- Update the last Element Entry for Penny issue if required
      if lvr = gn_ele_ent_num then
         ln_no_of_days := ld_rec_ele_end_date - ld_rec_ele_start_date + 1;
         if ln_total_value <> (ln_no_of_days * gn_daily_amount) then
            l_entry_value_tbl(ln_daily_amt_index) :=
                     ln_total_value - ((ln_no_of_days - 1) * gn_daily_amount);
            if gd_start_date_tbl(lvr) = gd_end_date_tbl(lvr) then
               -- Update the Element Entry values in Date-track mode
               hr_entry_api.update_element_entry
                            (p_dt_update_mode     => 'CORRECTION'
                            ,p_session_date       => gd_end_date_tbl(lvr)
                            ,p_element_entry_id   => ln_element_entry_id
                            ,p_num_entry_values   => l_entry_value_tbl.count()
                            ,p_input_value_id_tbl => l_input_value_id_tbl
                            ,p_entry_value_tbl    => l_entry_value_tbl);
            else
               -- Update the Element Entry values in Date-track mode
               hr_entry_api.update_element_entry
                            (p_dt_update_mode     => 'UPDATE'
                            ,p_session_date       => gd_end_date_tbl(lvr)
                            ,p_element_entry_id   => ln_element_entry_id
                            ,p_num_entry_values   => l_entry_value_tbl.count()
                            ,p_input_value_id_tbl => l_input_value_id_tbl
                            ,p_entry_value_tbl    => l_entry_value_tbl);
            end if; -- if gd_start_date_tbl(lvr)
         end if; -- if ln_total_value <>
      end if; -- if lvr = gn_ele_ent_num
   end loop; --  for lvr in 1..gn_ele_ent_num

   -- Reset Global Variables
   gd_start_date_tbl.delete;
   gd_end_date_tbl.delete;
   gn_link_id_tbl.delete;
   gn_ele_ent_num   := NULL;
   gn_daily_amount  := NULL;
   hr_utility.trace('Leaving PAY_US_ELEMENT_ENTRY_HOOK.CREATE_RECUR_ELEM_ENTRY');
   return;

EXCEPTION
  --
  WHEN others THEN
    raise;
END CREATE_RECUR_ELEM_ENTRY;

/******************************************************************************
   Name        : CREATE_TAX_RECORDS
   Scope       : LOCAL
   Description : This procedure is used for create Tax records for the
                 Jursidiction entered at element entry level.
******************************************************************************/
PROCEDURE CREATE_TAX_RECORDS(
   p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_assignment_id                in number
  ,p_element_link_id              in number
  ,p_original_entry_id            in number
  ,p_creator_type                 in varchar2
  ,p_entry_type                   in varchar2
  ,p_entry_information_category   in varchar2) IS

-- Cursor to get State Code associated with the jurisdiction
-- entered in the element entry
cursor c_get_jursidiction(c_element_entry_id number,
                          c_effective_date   date) is
select rtrim(ltrim(peev.screen_entry_value))
 from pay_element_entry_values_f peev
     ,pay_element_entries_f peef
     ,pay_input_values_f pivf
where peef.element_entry_id = c_element_entry_id
  and pivf.element_type_id = peef.element_type_id
  and upper(pivf.name) = 'JURISDICTION'
  and peev.element_entry_id = peef.element_entry_id
  and peev.input_value_id = pivf.input_value_id
  and c_effective_date between peef.effective_start_date
                           and peef.effective_end_date
  and c_effective_date between pivf.effective_start_date
                           and pivf.effective_end_date
  and c_effective_date between peev.effective_start_date
                           and peev.effective_end_date;

/*Changes for Bug#9270887 */
-- Cursor to check the existence of Default Tax Rules for
-- the assignment.Can check existence of Federal Tax Rule alone for this.
cursor c_default_tax_rule(c_assignment_id number) is
select 1
  from pay_us_emp_fed_tax_rules_f sta
 where sta.assignment_id = c_assignment_id;
/*End Bug#9270887 */

-- Cursor to check the existence of State Tax Rule
-- for a combination of Assignment and State
cursor c_state_tax_rule(c_assignment_id number,
                        c_state_code    varchar2) is
select 1
  from pay_us_emp_state_tax_rules_f sta
 where sta.assignment_id = c_assignment_id
   and sta.state_code = c_state_code;

-- Cursor to check the existence of County Tax Rule
-- for a combination of Assignment, State and County
cursor c_county_tax_rule(c_assignment_id number,
                         c_state_code    varchar2,
                         c_county_code   varchar2) is
select 1
  from pay_us_emp_county_tax_rules_f cnt
 where cnt.assignment_id = c_assignment_id
   and cnt.state_code = c_state_code
   and cnt.county_code = c_county_code;


-- Cursor to check the existence of City Tax Rule
-- for a combination of Assignment, State, County and City
cursor c_city_tax_rule(c_assignment_id number,
                       c_state_code    varchar2,
                       c_county_code   varchar2,
                       c_city_code     varchar2) is
select 1
  from pay_us_emp_city_tax_rules_f cty
 where cty.assignment_id = p_assignment_id
   and cty.state_code = c_state_code
   and cty.county_code = c_county_code
   and cty.city_code = c_city_code;

-- Variable Declaration
lv_jurisdiction_code VARCHAR2(100);
lv_state_code        VARCHAR2(10);
lv_county_code       VARCHAR2(10);
lv_city_code         VARCHAR2(10);
ln_tmp_rule_id       NUMBER;
ln_ovn               NUMBER;
ln_dummy             NUMBER;
ld_eff_start_date    DATE;
ld_eff_end_date      DATE;
l_emp_fed_tax_rule_id pay_us_emp_fed_tax_rules_f.emp_fed_tax_rule_id%TYPE;
l_fed_object_version_number pay_us_emp_fed_tax_rules_f.object_version_number%TYPE;
l_fed_effective_start_date DATE;
l_fed_effective_end_date DATE;

BEGIN
   hr_utility.trace('Entering PAY_US_ELEMENT_ENTRY_HOOK.CREATE_TAX_RECORDS');

   -- Initialization Code
   lv_state_code  := NULL;
   lv_county_code := NULL;
   lv_city_code   := NULL;

   -- Get the State for which we have to create the State Tax Rules
   open c_get_jursidiction(p_element_entry_id
                          ,p_effective_start_date);
   fetch c_get_jursidiction into lv_jurisdiction_code;
   close c_get_jursidiction;

   -- check for school district bug no 4728252
   if length(lv_jurisdiction_code) < 11 then
     return;

   --Bug:7269277 Jurisdiction code length check
   elsif length(lv_jurisdiction_code) > 11 then
     --Jurisdiction code cannot have size more than 11
     pay_cty_shd.constraint_error
     (p_constraint_name => 'PAY_US_EMP_CITY_TAX_RULES_FK3');

   end if;
   -- Check if Jurisdiction is specified
   if lv_jurisdiction_code IS NOT NULL then
      --Bug:7269277 Jurisdiction code format check
      --jurisdiction_code length = 11. Checking only for the format xx-xxx-xxxx
      if instr(lv_jurisdiction_code,'-', 1,1) <> 3
        or instr(lv_jurisdiction_code,'-', 1,2) <> 7 then

            pay_cty_shd.constraint_error
            (p_constraint_name => 'PAY_US_EMP_CITY_TAX_RULES_FK3');
      end if;

      /*Changes for Bug#9270887 */
      --Check if Default Tax Records exist for this Assignment.If not present,
      --Create the Default Tax Records
      open c_default_tax_rule(p_assignment_id);
      fetch c_default_tax_rule into ln_dummy;
      if c_default_tax_rule%NOTFOUND then
       hr_utility.trace('Default Tax Rules not created for Employee.So creating them now');
       pay_us_tax_internal.create_default_tax_rules
		  (p_effective_date                 => p_effective_start_date
		  ,p_assignment_id                  => p_assignment_id
		  ,p_emp_fed_tax_rule_id            => l_emp_fed_tax_rule_id
		  ,p_fed_object_version_number      => l_fed_object_version_number
		  ,p_fed_effective_start_date       => l_fed_effective_start_date
		  ,p_fed_effective_end_date         => l_fed_effective_end_date
  		);
      end if;
      close c_default_tax_rule;
      /*End Bug#9270887 */

      -- Check if Tax Rule exists
      -- Create the State Tax Rule only if it does not exist
      lv_state_code := substr(lv_jurisdiction_code,1,2);
      if lv_state_code <> '00' then
         open c_state_tax_rule(p_assignment_id
                              ,lv_state_code);
         fetch c_state_tax_rule into ln_dummy;
         if c_state_tax_rule%NOTFOUND then
            hr_utility.trace('Creating Tax Rule for State ' || lv_state_code);
            -- Create State Tax Records
            pay_state_tax_rule_api.create_state_tax_rule (
                           p_effective_date         => p_effective_start_date
                          ,p_default_flag           => 'Y'
                          ,p_assignment_id          => p_assignment_id
                          ,p_state_code             => lv_state_code
                          ,p_emp_state_tax_rule_id  => ln_tmp_rule_id
                          ,p_object_version_number  => ln_ovn
                          ,p_effective_start_date   => ld_eff_start_date
                          ,p_effective_end_date     => ld_eff_end_date
                          );
         end if; -- if c_state_tax_rule%NOTFOUND
         close c_state_tax_rule;

         -- Check if County Tax Rule exists
         -- Create the County Tax Rule only if it does not exist
         lv_county_code := substr(lv_jurisdiction_code,4,3);
         if lv_county_code <> '000' then
            open c_county_tax_rule(p_assignment_id
                                  ,lv_state_code
                                  ,lv_county_code);
            fetch c_county_tax_rule into ln_dummy;
            if c_county_tax_rule%NOTFOUND then
               hr_utility.trace('Creating Tax Rule for County  '
                                                   || lv_county_code);
               -- Create County Tax Records
      	    	pay_county_tax_rule_api.create_county_tax_rule (
                   p_effective_date         => p_effective_start_date
                  ,p_assignment_id          => p_assignment_id
                  ,p_state_code             => lv_state_code
                  ,p_county_code            => lv_county_code
                  ,p_additional_wa_rate     => 0
                  ,p_filing_status_code     => '01'
                  ,p_lit_additional_tax     => 0
                  ,p_lit_override_amount    => 0
                  ,p_lit_override_rate      => 0
                  ,p_withholding_allowances => 0
                  ,p_lit_exempt             => 'N'
                  ,p_emp_county_tax_rule_id => ln_tmp_rule_id
                  ,p_object_version_number  => ln_ovn
                  ,p_effective_start_date   => ld_eff_start_date
                  ,p_effective_end_date     => ld_eff_end_date
                  );
            end if; -- if c_county_tax_rule%NOTFOUND
            close c_county_tax_rule;

            -- Check if County Tax Rule exists
            -- Create the County Tax Rule only if it does not exist
            lv_city_code := substr(lv_jurisdiction_code,8,4);
            if lv_city_code <> '0000' then
               open c_city_tax_rule(p_assignment_id
                                   ,lv_state_code
                                   ,lv_county_code
                                   ,lv_city_code);
               fetch c_city_tax_rule into ln_dummy;
               if c_city_tax_rule%NOTFOUND then
                  hr_utility.trace('Creating Tax Rule for City ' ||
                                            lv_city_code);
                  -- Create City Tax Records
                  pay_city_tax_rule_api.create_city_tax_rule (
                      p_effective_date         => p_effective_start_date
                     ,p_assignment_id          => p_assignment_id
                     ,p_state_code             => lv_state_code
                     ,p_county_code            => lv_county_code
                     ,p_city_code              => lv_city_code
                     ,p_additional_wa_rate     => 0
                     ,p_filing_status_code     => '01'
                     ,p_lit_additional_tax     => 0
                     ,p_lit_override_amount    => 0
                     ,p_lit_override_rate      => 0
                     ,p_withholding_allowances => 0
                     ,p_lit_exempt             => 'N'
                     ,p_emp_city_tax_rule_id   => ln_tmp_rule_id
                     ,p_object_version_number  => ln_ovn
                     ,p_effective_start_date   => ld_eff_start_date
                     ,p_effective_end_date     => ld_eff_end_date
                     );
               end if; -- if c_city_tax_rule%NOTFOUND
               close c_city_tax_rule;
            end if; -- if lv_city_code <> '0000'
         end if; -- if lv_county_code <> '000'
      end if; -- if lv_state_code <> '00'
   end if; -- if lv_jurisdiction_code
   hr_utility.trace('Leaving PAY_US_ELEMENT_ENTRY_HOOK.CREATE_TAX_RECORDS');
   return;
END CREATE_TAX_RECORDS;

/******************************************************************************
   Name        : CREATE_PREMIUM_MOP_UP_ELEMENT
   Scope       : LOCAL
   Description : This function is used for creating the MOP UP element
                 for Premium. This procedure creates a MOP UP element
                 only if the FLSA Period crossed over Payroll Period in
                 question
******************************************************************************/
PROCEDURE CREATE_PREMIUM_MOP_UP_ELEMENT(
   p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_assignment_id                in number
  ,p_element_link_id              in number
  ,p_original_entry_id            in number
  ,p_creator_type                 in varchar2
  ,p_entry_type                   in varchar2
  ,p_entry_information_category   in varchar2) IS

-- Get default time definition
cursor c_get_def_time_def_id(c_time_def_name       VARCHAR2
                            ,c_legislation_code    VARCHAR2) is
select time_definition_id
  from pay_time_definitions
 where definition_name = c_time_def_name
   and legislation_code = c_legislation_code
   and business_group_id IS NULL;

cursor c_get_nrec_mop_up_dates(c_assignment_id         NUMBER
                               ,c_effective_start_date DATE
                               ,c_date_earned          DATE
                               ,c_time_def_id          NUMBER) is
select /*+ use_nl(paf ptpp)*/
       ptpp.end_date + 1,
       ptpt.end_date
  from per_assignments_f paf
      ,per_time_periods ptpp
      ,per_time_periods ptpt
where paf.assignment_id = c_assignment_id
  and NVL(c_date_earned,c_effective_start_date) between paf.effective_start_date
                                                    and paf.effective_end_date
  and ptpp.payroll_id = paf.payroll_id
  and NVL(c_date_earned,c_effective_start_date) between ptpp.start_date
                                                    and ptpp.end_date
  and NVL(c_date_earned,ptpp.end_date) between ptpt.start_date
                                           and ptpt.end_date
  and ptpt.time_definition_id = c_time_def_id
  and ptpp.end_date between ptpt.start_date
                        and ptpt.end_date
  and ptpp.end_date <> ptpt.end_date
  and ptpt.time_definition_id is not null
  and ptpt.payroll_id is null
  and ptpp.time_definition_id is null
  and ptpp.payroll_id is not null;

cursor c_get_rec_mop_up_dates(c_assignment_id        NUMBER
                             ,c_element_entry_id     NUMBER
                             ,c_time_def_id          NUMBER) is
select /*+ use_nl(paf ptpp)*/
       ptpp.end_date + 1,
       ptpt.end_date
  from per_assignments_f paf
      ,per_time_periods ptpp
      ,per_time_periods ptpt
where paf.assignment_id = c_assignment_id
  and ptpp.payroll_id = paf.payroll_id
  and ptpp.start_date <= (select max(peef.effective_end_date)
         from pay_element_entries_f peef
        where peef.element_entry_id = c_element_entry_id)
  and ptpp.end_date >= (select max(peef.effective_end_date)
         from pay_element_entries_f peef
        where peef.element_entry_id = c_element_entry_id)
  and ptpt.time_definition_id = c_time_def_id
  and ptpp.end_date between ptpt.start_date
                        and ptpt.end_date
  and ptpp.end_date <> ptpt.end_date
  and NOT(ptpt.start_date between ptpp.start_date
                              and ptpp.end_date
          AND
          ptpt.end_date between ptpp.start_date
                            and ptpp.end_date)
  and ptpt.time_definition_id is not null
  and ptpt.payroll_id is null
  and ptpp.time_definition_id is null
  and ptpp.payroll_id is not null;

cursor c_get_rate_entry_count(c_element_entry_id number
                             ,c_effective_date   date) is
select count(peev.screen_entry_value)
 from pay_element_entries_f peef,
      pay_input_values_f pivf,
      pay_element_entry_values_f peev
where peef.element_entry_id = c_element_entry_id
  and pivf.element_type_id = peef.element_type_id
  and pivf.name in ('Rate', 'Rate Code')
  and peev.element_entry_id = peef.element_entry_id
  and peev.input_value_id = pivf.input_value_id
  and c_effective_date between peef.effective_start_date
                           and peef.effective_end_date
  and c_effective_date between pivf.effective_start_date
                           and pivf.effective_end_date
  and c_effective_date between pivf.effective_start_date
                           and pivf.effective_end_date
  and peev.screen_entry_value is not null;

cursor c_get_elem_type_id(c_element_name      varchar2
                         ,c_business_group_id number) is
select petf.element_type_id
  from pay_element_types_f petf
 where petf.element_name = c_element_name
   and petf.business_group_id = c_business_group_id;

-- Cursor to get the Element link details for the assignment
cursor c_get_link_details(c_element_type_id      number
                         ,c_assignment_id        number
                         ,c_effective_start_date date
                         ,c_effective_end_date   date) is
select paf.effective_start_date  Asgt_Start_Date
      ,paf.effective_end_date    Asgt_End_Date
      ,pelf.effective_start_date Link_Start_Date
      ,pelf.effective_end_date   Link_End_Date
      ,pelf.element_link_id      Element_Link_Id
  from pay_element_types_f petf,
       pay_element_links_f pelf,
       per_assignments_f paf
 where petf.element_type_id = c_element_type_id
   and petf.element_type_id = pelf.element_type_id
   and paf.assignment_id = c_assignment_id
   and c_effective_start_date <= paf.effective_end_date
   and c_effective_end_date >= paf.effective_start_date
   and c_effective_start_date <= pelf.effective_end_date
   and c_effective_end_date >= pelf.effective_start_date
   and (
         (pelf.effective_start_date between paf.effective_start_date
                                        and paf.effective_end_date)
         or
         (pelf.effective_end_date between paf.effective_start_date
                                      and paf.effective_end_date)
         or
         (
          pelf.effective_start_date < paf.effective_start_date
          and
          pelf.effective_end_date > paf.effective_end_date
         )
       )
   and (
        (pelf.payroll_id is not null and pelf.payroll_id = paf.payroll_id)
        or
        (pelf.link_to_all_payrolls_flag = 'Y' and paf.payroll_id is not null)
        or
        (pelf.payroll_id is null and pelf.link_to_all_payrolls_flag = 'N')
       )
   and (
        pelf.organization_id = paf.organization_id
        or
        pelf.organization_id is null
       )
   and (
        pelf.position_id = paf.position_id
        or
        pelf.position_id is null
       )
   and (
        pelf.job_id = paf.job_id
        or
        pelf.job_id is null
       )
   and (
        pelf.grade_id = paf.grade_id
        or
        pelf.grade_id is null
       )
   and (
        pelf.location_id = paf.location_id
        or
        pelf.location_id is null
       )
   and (
        pelf.pay_basis_id = paf.pay_basis_id
        or
        pelf.pay_basis_id is null
        )
   and (
        pelf.employment_category = paf.employment_category
        or
        pelf.employment_category is null
       )
   and (
        pelf.people_group_id is null
        or
        exists (
                select 1
                  from pay_assignment_link_usages_f usage
                 where usage.assignment_id = paf.assignment_id
                   and usage.element_link_id = pelf.element_link_id
                )
       )
   order by Asgt_Start_Date, Link_Start_Date;

-- Get date_earned of element_entry
CURSOR c_get_date_earned(c_element_entry_id number
          ) IS
  SELECT date_earned
    FROM pay_element_entries_f
   WHERE element_entry_id = c_element_entry_id;

-- Get the screen entry value
cursor c_get_scr_entry_value(c_element_entry_id number,
                             c_inp_value_name   varchar2,
                             c_effective_date   date) is
select peev.screen_entry_value
  from pay_element_entry_values_f peev
      ,pay_element_entries_f peef
      ,pay_input_values_f pivf
 where peef.element_entry_id = c_element_entry_id
   and peev.element_entry_id = peef.element_entry_id
   and pivf.element_type_id = peef.element_type_id
   and upper(pivf.name) = upper(c_inp_value_name)
   and peev.input_value_id = pivf.input_value_id
   and c_effective_date between peef.effective_start_date
                            and peef.effective_end_date
   and c_effective_date between peev.effective_start_date
                            and peev.effective_end_date
   and c_effective_date between pivf.effective_start_date
                            and pivf.effective_end_date;

cursor c_get_inp_val_id(c_element_name      varchar2
                        ,c_inp_val_name       varchar2
                        ,c_business_group_id number) is
select distinct
       pivf.input_value_id
  from pay_element_types_f petf
      ,pay_input_values_f pivf
 where petf.element_name = c_element_name
   and petf.business_group_id = c_business_group_id
   and pivf.element_type_id = petf.element_type_id
   and pivf.name = c_inp_val_name;

ln_business_group_id      number;
ln_time_definition_id     number;
ln_def_time_definition_id number;
ln_mop_up_ele_type_id     number;
ln_ele_link_id            number;
ln_ele_ent_num            number;
ln_element_entry_id       number;
ln_original_entry_id      number;
ln_count                  number;
ln_inp_value_id           number;
lvr                       number;
lv_processing_type        varchar2(10);
lv_element_name           varchar2(200);
ln_screen_entry_value     varchar2(1000);
ld_mop_up_start_date      date;
ld_mop_up_end_date        date;
ld_asgt_eff_start_date    date;
ld_asgt_eff_end_date      date;
ld_link_eff_start_date    date;
ld_link_eff_end_date      date;
ld_dummy_start_date       date;
ld_dummy_end_date         date;
ld_date_earned            date;
lb_prem_flag              boolean;
lb_mop_up_flag            boolean;
ld_start_date_tbl         date_table;
ld_end_date_tbl           date_table;
ln_link_id_tbl            number_table;
ln_input_value_id_tbl     hr_entry.number_table;
lv_entry_value_tbl        hr_entry.varchar2_table;

BEGIN

   lb_mop_up_flag        := FALSE;
   lb_prem_flag          := FALSE;
   ln_ele_ent_num        := 0;
   ln_link_id_tbl(0)     := 0;
   ln_count              := 0;

   -- Check For Premium Element
   hr_utility.trace('Entering CREATE_PREMIUM_MOP_UP_ELEMENT');
   lb_prem_flag := CHECK_PREMIUM_ELEM(p_element_entry_id
                                     ,p_effective_start_date
                                     ,lv_element_name
                                     ,lv_processing_type
                                     ,ln_business_group_id);

   if lb_prem_flag then
      hr_utility.trace('Getting Time Definition ID');
      -- Get the Default Time Definition ID
      open c_get_def_time_def_id('Non Allocated Time Definition'
                                           ,'US');
      fetch c_get_def_time_def_id into ln_def_time_definition_id;
      close c_get_def_time_def_id;

      hr_utility.trace('Element Entry ID ' || p_element_entry_id);
      hr_utility.trace('Assignment ID ' || p_assignment_id);
      hr_utility.trace('Business Group ID ' || ln_business_group_id);
      hr_utility.trace('Eff Start Date ' || p_effective_start_date);

      -- Get the Time Definition associated with the Assignment as of
      -- Premium Element Entry Start Date
      ln_time_definition_id  :=
              pay_us_rules.get_time_def_for_entry_func(
                           p_element_entry_id     => p_element_entry_id
                          ,p_assignment_id        => p_assignment_id
                          ,p_assignment_action_id => NULL
                          ,p_business_group_id    => ln_business_group_id
                          ,p_time_def_date        => p_effective_start_date);

      if ln_time_definition_id = ln_def_time_definition_id then
         hr_utility.trace('Default Time Definition ID');
         lb_prem_flag := FALSE;
      end if;
   end if;


   -- For Premium Element based on the Time Definition
   -- we have to create a MOP UP element.
   if lb_prem_flag then
      -- Check whether it is a Non Recurring Premium or Recurring
      if upper(lv_processing_type) = 'N' then
         hr_utility.trace('Non Recurring Premium Element');

         open c_get_rate_entry_count(p_element_entry_id
                                    ,p_effective_start_date);
         fetch c_get_rate_entry_count into ln_count;
         close c_get_rate_entry_count;

         -- Get the Re Calc Element Entry dates only if
         -- Rate/Rate Code is not specified
         if ln_count = 0 then

            open c_get_date_earned (p_element_entry_id);
            fetch c_get_date_earned into ld_date_earned;
            IF c_get_date_earned%NOTFOUND THEN
               ld_date_earned := NULL;
            END IF;
            close c_get_date_earned;

            open c_get_nrec_mop_up_dates(p_assignment_id
                                        ,p_effective_start_date
                                        ,ld_date_earned
                                        ,ln_time_definition_id);
            fetch c_get_nrec_mop_up_dates into ld_mop_up_start_date
                                              ,ld_mop_up_end_date;
            if c_get_nrec_mop_up_dates%FOUND then
               lb_mop_up_flag := TRUE;
            end if;
            close c_get_nrec_mop_up_dates;
         end if; -- if ln_count > 0
      else
         hr_utility.trace('Recurring Premium Element');
         open c_get_rec_mop_up_dates(p_assignment_id
                                    ,p_element_entry_id
                                    ,ln_time_definition_id);
         fetch c_get_rec_mop_up_dates into ld_mop_up_start_date
                                          ,ld_mop_up_end_date;
         if c_get_rec_mop_up_dates%FOUND then
            lb_mop_up_flag := TRUE;
         end if;
         close c_get_rec_mop_up_dates;
      end if; -- if upper(lv_processing_type)

      if lb_mop_up_flag then
         -- Get the input value id 'Multiple' for the Adjustment element
         ln_inp_value_id := NULL;
         open c_get_inp_val_id(lv_element_name ||
                                 ' for FLSA Period Adjustment'
                               ,'Multiple'
                               ,ln_business_group_id);
         fetch c_get_inp_val_id into ln_inp_value_id;
         if c_get_inp_val_id%FOUND then
            ln_input_value_id_tbl(1) := ln_inp_value_id;
         end if;
         close c_get_inp_val_id;

         if ln_inp_value_id is NOT NULL then
            -- Get the value for the input value MULTIPLE specified
            -- for the Premium element. This value needs to be paased
            -- to the Adjustment element
            open c_get_scr_entry_value(p_element_entry_id
                                      ,'Multiple'
                                      ,p_effective_start_date);
            fetch c_get_scr_entry_value into ln_screen_entry_value;
            if c_get_scr_entry_value%FOUND then
               lv_entry_value_tbl(1) := ln_screen_entry_value;
            else
               lv_entry_value_tbl(1) := NULL;
            end if; -- if c_get_scr_entry_value%FOUND
            close c_get_scr_entry_value;
         end if; -- if ln_inp_value_id is NOT NULL


         hr_utility.trace('Getting Mop UP ID');
         open c_get_elem_type_id(lv_element_name || ' for FLSA Period Adjustment'
                                ,ln_business_group_id);
         fetch c_get_elem_type_id into ln_mop_up_ele_type_id;
         close c_get_elem_type_id;
         hr_utility.trace('Mop Up ID : ' || ln_mop_up_ele_type_id);

         ld_dummy_start_date := ld_mop_up_start_date;

         open c_get_link_details(ln_mop_up_ele_type_id
                                ,p_assignment_id
                                ,ld_mop_up_start_date
                                ,ld_mop_up_end_date);
         loop
            fetch c_get_link_details into ld_asgt_eff_start_date
                                         ,ld_asgt_eff_end_date
                                         ,ld_link_eff_start_date
                                         ,ld_link_eff_end_date
                                         ,ln_ele_link_id;
            exit when c_get_link_details%NOTFOUND;

            if ln_ele_link_id <> ln_link_id_tbl(ln_ele_ent_num) then
               ln_ele_ent_num := ln_ele_ent_num + 1;
               ln_link_id_tbl(ln_ele_ent_num) := ln_ele_link_id;
               if ld_asgt_eff_end_date > ld_link_eff_end_date then
                  ld_start_date_tbl(ln_ele_ent_num) := ld_dummy_start_date;
                  ld_end_date_tbl(ln_ele_ent_num)   := ld_link_eff_end_date;
               else
                  ld_start_date_tbl(ln_ele_ent_num) := ld_dummy_start_date;
                  ld_end_date_tbl(ln_ele_ent_num)   := ld_asgt_eff_end_date;
               end if; -- if ld_asgt_eff_end_date > ....

               if ld_end_date_tbl(ln_ele_ent_num) > ld_mop_up_end_date then
                  ld_end_date_tbl(ln_ele_ent_num) := ld_mop_up_end_date;
               else
                  ld_dummy_start_date := ld_end_date_tbl(ln_ele_ent_num) + 1;
               end if; -- if ld_end_date_tbl(ln_ele_ent_num) ....

               hr_utility.trace('ln_ele_ent_num = ' || ln_ele_ent_num);
               hr_utility.trace('Asgt Eff End Date = ' ||
                                            ld_asgt_eff_end_date);
               hr_utility.trace('Link Eff End Date = ' ||
                                            ld_link_eff_end_date);
               hr_utility.trace('Global Start Date = ' ||
                                            ld_start_date_tbl(ln_ele_ent_num));
               hr_utility.trace('Global End Date = ' ||
                                            ld_end_date_tbl(ln_ele_ent_num));
               hr_utility.trace('Link ID = ' ||
                                            ln_link_id_tbl(ln_ele_ent_num));
            else
               if ld_asgt_eff_end_date > ld_link_eff_end_date then
                  ld_end_date_tbl(ln_ele_ent_num) := ld_link_eff_end_date;
               else
                  ld_end_date_tbl(ln_ele_ent_num) := ld_asgt_eff_end_date;
               end if; -- if ld_asgt_eff_end_date ....

               if ld_end_date_tbl(ln_ele_ent_num) > ld_mop_up_end_date then
                  ld_end_date_tbl(ln_ele_ent_num) := ld_mop_up_end_date;
               else
                  ld_dummy_start_date := ld_end_date_tbl(ln_ele_ent_num) + 1;
               end if; -- if ld_end_date_tbl(ln_ele_ent_num) ....

               hr_utility.trace('ln_ele_ent_num = ' || ln_ele_ent_num);
               hr_utility.trace('Global Start Date = ' ||
                                            ld_start_date_tbl(ln_ele_ent_num));
               hr_utility.trace('Global End Date = ' ||
                                            ld_end_date_tbl(ln_ele_ent_num));
               hr_utility.trace('Link ID = ' ||
                                            ln_link_id_tbl(ln_ele_ent_num));
            end if; -- if ln_ele_link_id <> ....
         end loop;
         close c_get_link_details;

         if ln_ele_ent_num = 0 then
            hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
            hr_utility.set_message_token('FORMULA_TEXT',
                       'The assignment is not eligible for ' ||
                       lv_element_name || ' for FLSA Period Adjustment. ' ||
                       'Please link the element to make it eligible ' ||
                       'for the assignment.');
            hr_utility.raise_error;
         elsif (ld_end_date_tbl(ln_ele_ent_num) < ld_mop_up_end_date) then
            hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
            hr_utility.set_message_token('FORMULA_TEXT',
                       'The assignment is not eligible for ' ||
                       lv_element_name || ' for FLSA Period Adjustment. ' ||
                       'Please link the element to make it eligible ' ||
                       'for the assignment.');
            hr_utility.raise_error;
         end if; -- if gn_ele_ent_num = 0

         for lvr in 1..ln_ele_ent_num loop
            hr_utility.trace('Creating Recurring Element Entries');
            hr_utility.trace('Element Start Date = ' || ld_start_date_tbl(lvr));
            hr_utility.trace('Element End Date = ' || ld_end_date_tbl(lvr));

            ld_dummy_end_date := ld_end_date_tbl(lvr);

            hr_entry_api.insert_element_entry (
               p_effective_start_date        => ld_start_date_tbl(lvr)
              ,p_effective_end_date          => ld_dummy_end_date
              ,p_element_entry_id            => ln_element_entry_id
              ,p_original_entry_id           => ln_original_entry_id
              ,p_assignment_id               => p_assignment_id
              ,p_element_link_id             => ln_link_id_tbl(lvr)
              ,p_creator_type                => 'FL'
              ,p_creator_id                  => p_element_entry_id
              ,p_entry_type                  => 'E' -- Normal Entry
              ,p_entry_information_category  => null
              --
              -- Element Entry Values Table
              --
              ,p_num_entry_values            => lv_entry_value_tbl.count()
              ,p_input_value_id_tbl          => ln_input_value_id_tbl
              ,p_entry_value_tbl             => lv_entry_value_tbl
               );

            -- End dating the element using ld_end_date_tbl(lvr)
            -- as ld_dummy_end_date gets overwritten by the
            -- previous call
            if ld_dummy_end_date <> ld_end_date_tbl(lvr) then
               hr_utility.trace('End dating the Element Entry Created');
               hr_entry_api.delete_element_entry (
                   p_dt_delete_mode   => 'DELETE',
                   p_session_date     => ld_end_date_tbl(lvr),
                   p_element_entry_id => ln_element_entry_id);
            end if; -- if ld_dummy_end_date

            /*
             * Through the API call above, the Original Entry ID could not be
             * set as it requires that the Orignal Entry ID be a recurring
             * Element. In our case we can have the Original Entry ID to
             * be Non-Recurring.
             */
            update pay_element_entries_f
               set original_entry_id = p_element_entry_id
             where element_entry_id = ln_element_entry_id;
         end loop; -- for lvr in 1..
      end if; -- if lb_mop_up_flag
   end if; -- if lb_prem_flag

   return;

END CREATE_PREMIUM_MOP_UP_ELEMENT;

/******************************************************************************
   Name        : INSERT_USER_HOOK
   Scope       : GLOBAL
   Description : This procedure is called by AFTER INSERT Row Level handler
                 User Hook.
******************************************************************************/
PROCEDURE INSERT_USER_HOOK(
   p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_assignment_id                in number
  ,p_element_link_id              in number
  ,p_original_entry_id            in number
  ,p_creator_type                 in varchar2
  ,p_entry_type                   in varchar2
  ,p_entry_information_category   in varchar2) IS
BEGIN

   hr_utility.trace('Entering PAY_US_ELEMENT_ENTRY_HOOK.INSERT_USER_HOOK');
   -- Call CREATE_RECUR_ELEM_ENTRY
   -- The package has the check built in for identifying Augment Elements
   CREATE_RECUR_ELEM_ENTRY(p_element_entry_id
                          ,p_effective_start_date
                          ,p_effective_end_date
                          ,p_assignment_id
                          ,p_element_link_id
                          ,p_original_entry_id
                          ,p_creator_type
                          ,p_entry_type
                          ,p_entry_information_category);
   -- Call CREATE_TAX_REACORDS
   -- We need to create TAX RECORDS if JURSIDICTION input value is specified
   -- for the employee and the employee does not have any tax records for
   -- that state.
   CREATE_TAX_RECORDS(p_element_entry_id
                     ,p_effective_start_date
                     ,p_effective_end_date
                     ,p_assignment_id
                     ,p_element_link_id
                     ,p_original_entry_id
                     ,p_creator_type
                     ,p_entry_type
                     ,p_entry_information_category);

   CREATE_PREMIUM_MOP_UP_ELEMENT(p_element_entry_id
                                ,p_effective_start_date
                                ,p_effective_end_date
                                ,p_assignment_id
                                ,p_element_link_id
                                ,p_original_entry_id
                                ,p_creator_type
                                ,p_entry_type
                                ,p_entry_information_category);
   hr_utility.trace('Leaving PAY_US_ELEMENT_ENTRY_HOOK.INSERT_USER_HOOK');
   return;
END INSERT_USER_HOOK;

-----------------------------INSERT SECTION ENDS HERE--------------------------

/******************************************************************************
   Name        : UPDATE_RECUR_ELEM_ENTRY
   Scope       : LOCAL
   Description : This procedure is used to Update the Recurring Element Entry
                 associated with Non recurring Augment element.
******************************************************************************/
PROCEDURE UPDATE_RECUR_ELEM_ENTRY(
   p_element_entry_id               in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_assignment_id_o                in number
  ,p_element_link_id_o              in number
  ,p_original_entry_id_o            in number
  ,p_creator_type_o                 in varchar2
  ,p_entry_type_o                   in varchar2
  ,p_entry_information_category_o   in varchar2) IS

-- Cursor to get the Recurring Element entries
-- using the Creator ID
cursor c_get_rec_elem_details(c_element_entry_id number
                             ,c_assignment_id    number) is
select distinct
       peef.element_entry_id
      ,peef.effective_start_date
      ,peef.effective_end_date
      ,peev.screen_entry_value
  from pay_element_entries_f peef,
       pay_element_entry_values_f peev,
       pay_input_values_f pivf
 where peef.creator_id = c_element_entry_id
   and peef.assignment_id = c_assignment_id
   and peef.creator_type = 'FL'
   and peev.element_entry_id = peef.element_entry_id
   and pivf.element_type_id = peef.element_type_id
   and upper(pivf.name) = 'DAILY AMOUNT'
   and peev.input_value_id = pivf.input_value_id
   and peev.effective_start_date between peef.effective_start_date
                                      and peef.effective_end_date
order by peef.effective_start_date;

-- Cursor to get the Non-recurring element details for updating the
-- corresponding recurring element entry
cursor c_get_aug_entry_details(c_element_entry_id     number
                              ,c_effective_start_date date) is
select pivf.name
      ,peevf.screen_entry_value
  from pay_element_entries_f peef
      ,pay_element_entry_values_f peevf
      ,pay_input_values_f pivf
 where peef.element_entry_id = c_element_entry_id
   and peevf.element_entry_id = peef.element_entry_id
   and pivf.element_type_id = peef.element_type_id
   and peevf.input_value_id = pivf.input_value_id
   and upper(pivf.name) in ('EARNED START DATE',
                            'EARNED END DATE',
                            'AMOUNT')
   and c_effective_start_date between peef.effective_start_date
                                  and peef.effective_end_date
   and c_effective_start_date between peevf.effective_start_date
                                  and peevf.effective_end_date
   and c_effective_start_date between pivf.effective_start_date
                                  and pivf.effective_end_date;

-- Cursor to get Input value id for the Input value 'Daily Amount'
cursor c_get_inp_value_id (c_element_name      varchar2
                          ,c_business_group_id number) is
select pivf.input_value_id
  from pay_element_types_f petf,
       pay_input_values_f pivf
 where petf.element_name = c_element_name || ' for FLSA Calc'
   and petf.business_group_id = c_business_group_id
   and pivf.element_type_id = petf.element_type_id
   and upper(pivf.name) = 'DAILY AMOUNT';

ln_ele_entry_id           number;
ln_no_of_days             number;
lvar                      number;
ln_daily_amount           number;
ln_total_amount           number;
ln_business_grp_id        number;
lv_inp_val_name           varchar2(100);
lv_screen_entry_value     varchar2(100);
lv_old_screen_entry_value varchar2(100);
lv_element_name           varchar2(100);
lv_penny_issue_bu         varchar2(100);
lv_penny_issue_au         varchar2(100);
ld_eff_start_date         date;
ld_eff_end_date           date;
ld_rec_ele_start_date     date;
ld_rec_ele_end_date       date;
ld_new_rec_ele_start_date date;
ld_new_rec_ele_end_date   date;
lb_aug_flag               boolean;
l_elem_entry_id_tbl       number_table;
l_del_start_date_tbl      date_table;
l_input_value_id_tbl      hr_entry.number_table;
l_entry_value_tbl         hr_entry.varchar2_table;

BEGIN

   hr_utility.trace('Entering PAY_US_ELEMENT_ENTRY_HOOK.UPDATE_RECUR_ELEM_ENTRY');

   -- Initialization
   ld_rec_ele_start_date := hr_api.g_date;
   ld_rec_ele_end_date   := hr_api.g_date;
   lvar                  := 0;
   ln_total_amount       := 0;
   lv_penny_issue_bu     := 'N';
   lv_penny_issue_au     := 'N';

   -- Check whether this element entry is an augment element.
   -- If not then we need not do anyhting additional
   lb_aug_flag := CHECK_AUGMENT_ELEM(p_assignment_id_o
                                    ,p_element_entry_id
                                    ,p_effective_start_date
                                    ,lv_element_name
                                    ,ln_business_grp_id);
   if NOT(lb_aug_flag) then
      return;
   end if;

   -- Get the Start Date and End Date of the Recurring Element entry
   -- before the update was made.
   open c_get_rec_elem_details(p_element_entry_id
                              ,p_assignment_id_o);
   loop
      fetch c_get_rec_elem_details into ln_ele_entry_id
                                       ,ld_eff_start_date
                                       ,ld_eff_end_date
                                       ,lv_screen_entry_value;
      exit when c_get_rec_elem_details%NOTFOUND;

      if lvar = 0 then
         ld_rec_ele_start_date := ld_eff_start_date;
         lv_old_screen_entry_value := lv_screen_entry_value;
         l_elem_entry_id_tbl(lvar) := ln_ele_entry_id;
         l_del_start_date_tbl(lvar) := ld_eff_start_date;
         lvar := lvar + 1;
      else
         if l_elem_entry_id_tbl(lvar-1) <> ln_ele_entry_id then
            l_elem_entry_id_tbl(lvar) := ln_ele_entry_id;
            l_del_start_date_tbl(lvar) := ld_eff_start_date;
            lvar := lvar + 1;
         end if;
      end if; -- if lvar = 0

      -- Checking if Penny Issue existed before Update
      if lv_old_screen_entry_value <> lv_screen_entry_value then
         lv_penny_issue_bu := 'Y';
      end if;

      ld_rec_ele_end_date := ld_eff_end_date;
   end loop;
   close c_get_rec_elem_details;

   hr_utility.trace('Previous Start Date = ' || ld_rec_ele_start_date);
   hr_utility.trace('Previous End Date = ' || ld_rec_ele_end_date);

   -- Get the Start Date, End Date and Amount specified in the
   -- Non-recurring augment element
   open c_get_aug_entry_details(p_element_entry_id
                               ,p_effective_start_date);
   loop
      fetch c_get_aug_entry_details into lv_inp_val_name
                                        ,lv_screen_entry_value;
      exit when c_get_aug_entry_details%NOTFOUND;

      if upper(lv_inp_val_name) = 'EARNED START DATE' then
         ld_new_rec_ele_start_date :=
                            fnd_date.canonical_to_date(lv_screen_entry_value);
         hr_utility.trace('New Start Date = ' || ld_new_rec_ele_start_date);
      elsif upper(lv_inp_val_name) = 'EARNED END DATE' then
         ld_new_rec_ele_end_date :=
                            fnd_date.canonical_to_date(lv_screen_entry_value);
         hr_utility.trace('New End Date = ' || ld_new_rec_ele_end_date);
      elsif upper(lv_inp_val_name) = 'AMOUNT' then
         ln_total_amount := to_number(nvl(lv_screen_entry_value,0));
         hr_utility.trace('New Amount = ' || ln_total_amount);
      end if; -- if upper(lv_inp_val_name) = 'START DATE'
   end loop;
   close c_get_aug_entry_details;

   ln_no_of_days := ld_new_rec_ele_end_date - ld_new_rec_ele_start_date + 1;

   -- Getting daily Amount in the New scenario.
   -- This value is later used to fine id we need to just update the
   -- Element entries or delete and re-create them.
   ln_daily_amount := GET_DAILY_AMOUNT(p_assignment_id_o
                                   ,ld_new_rec_ele_start_date
                                   ,ld_new_rec_ele_end_date
                                   ,'Amount'
                                   ,ln_total_amount);

   -- Check if Penny issue will exist After Update
   if ln_total_amount <> ln_daily_amount * ln_no_of_days then
      lv_penny_issue_au := 'Y';
   end if;

   -- If the dates have been modified then we have to delete the Old
   -- element entries created for the Recurring element and create
   -- a New recurring element entry.
   -- We also need to recreate the Recurring Element entries in cases
   -- where Penny isssue exists in only one of the cases
   -- i.e either Before the Update or After the Update
   if (ld_rec_ele_start_date <> ld_new_rec_ele_start_date OR
       ld_rec_ele_end_date <> ld_new_rec_ele_end_date OR
       lv_penny_issue_au <> lv_penny_issue_bu) then
      -- Deleting the Recurring element entries previously created
      hr_utility.trace('Deleting Old Recurring Element Entries');
      if l_elem_entry_id_tbl.count() > 0 then
         for lvar in l_elem_entry_id_tbl.first..l_elem_entry_id_tbl.last loop
            hr_entry_api.delete_element_entry (
                         p_dt_delete_mode   => 'ZAP',
                         p_session_date     => l_del_start_date_tbl(lvar),
                         p_element_entry_id => l_elem_entry_id_tbl(lvar));
         end loop; -- for lvar in l_elem_entry_id_tbl
      end if; -- if l_elem_entry_id_tbl.count()

      -- Recreating New recurring element entries
      hr_utility.trace('Creating New Recurring Element Entries');
      PAY_US_ELEMENT_ENTRY_HOOK.CREATE_RECUR_ELEM_ENTRY(
                                       p_element_entry_id
                                      ,p_effective_start_date
                                      ,p_effective_end_date
                                      ,p_assignment_id_o
                                      ,p_element_link_id_o
                                      ,p_original_entry_id_o
                                      ,p_creator_type_o
                                      ,p_entry_type_o
                                      ,p_entry_information_category_o);
   else
      hr_utility.trace('Updating Recurring Amount Values');
      -- No changes have been made to Start Date and End Date
      hr_utility.trace('New Daily Amount = ' || ln_daily_amount);

      -- Get the Input Value ID to be changed
      open c_get_inp_value_id(lv_element_name
                             ,ln_business_grp_id);
      fetch c_get_inp_value_id into l_input_value_id_tbl(1);
      if c_get_inp_value_id%NOTFOUND then
         hr_utility.trace('No Input Value to be modified');
         return;
      end if;
      close c_get_inp_value_id;

      -- Updating Recurring Element Entry values
      if l_elem_entry_id_tbl.count() > 0 then
         for lvar in l_elem_entry_id_tbl.first..l_elem_entry_id_tbl.last loop
            -- Set the Daily Amount for the last Element Entry to solve the
            -- Penny issue
            if lvar = l_elem_entry_id_tbl.last then
               l_entry_value_tbl(1) := ln_total_amount -
                                      ((ln_no_of_days-1) * ln_daily_amount);
             else
               l_entry_value_tbl(1) := to_char(ln_daily_amount);
            end if;
            hr_entry_api.update_element_entry
                         (p_dt_update_mode     => 'CORRECTION'
                         ,p_session_date       => l_del_start_date_tbl(lvar)
                         ,p_element_entry_id   => l_elem_entry_id_tbl(lvar)
                         ,p_num_entry_values   => 1
                         ,p_input_value_id_tbl => l_input_value_id_tbl
                         ,p_entry_value_tbl    => l_entry_value_tbl);
         end loop; -- for lvar in l_elem_entry_id_tb
      end if; -- if l_elem_entry_id_tbl.count()
   end if; -- if (ld_rec_ele_start_date <>

   hr_utility.trace('Leaving PAY_US_ELEMENT_ENTRY_HOOK.UPDATE_RECUR_ELEM_ENTRY');
   return;
EXCEPTION
  --
  WHEN others THEN
    raise;
END UPDATE_RECUR_ELEM_ENTRY;

/******************************************************************************
   Name        : UPDATE_PREMIUM_MOP_UP_ELEMENT
   Scope       : LOCAL
   Description : This function is used for updating the MOP UP element
                 for Premium. This procedure creates a MOP UP element
                 only if the FLSA Period crossed over Payroll Period in
                 question and the input values Rate/Rate Code both are not
                 specified.
******************************************************************************/
PROCEDURE UPDATE_PREMIUM_MOP_UP_ELEMENT(
   p_element_entry_id               in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_assignment_id                 in number
  ,p_element_link_id               in number
  ,p_original_entry_id             in number
  ,p_creator_type                  in varchar2
  ,p_entry_type                    in varchar2
  ,p_entry_information_category    in varchar2) IS


cursor c_get_rate_entry_count(c_element_entry_id number
                             ,c_effective_date   date) is
select count(peev.screen_entry_value)
 from pay_element_entries_f peef,
      pay_input_values_f pivf,
      pay_element_entry_values_f peev
where peef.element_entry_id = c_element_entry_id
  and pivf.element_type_id = peef.element_type_id
  and pivf.name in ('Rate', 'Rate Code')
  and peev.element_entry_id = peef.element_entry_id
  and peev.input_value_id = pivf.input_value_id
  and c_effective_date between peef.effective_start_date
                           and peef.effective_end_date
  and c_effective_date between pivf.effective_start_date
                           and pivf.effective_end_date
  and c_effective_date between peev.effective_start_date
                           and peev.effective_end_date
  and peev.screen_entry_value is not null;

cursor c_check_mop_up_exists(c_element_entry_id number
                            ,c_assignment_id    number) is
select 'Exist'
  from pay_element_entries_f peef
 where peef.creator_id = c_element_entry_id
   and peef.assignment_id = c_assignment_id
   and peef.creator_type = 'FL';

-- Get the End date of the recurring element.
cursor c_get_entry_end_date(c_element_entry_id number
                           ,c_assignment_id    number) is
select nvl(max(peef.effective_end_date),
           fnd_date.canonical_to_date('4712/12/31'))
  from pay_element_entries_f peef
 where peef.element_entry_id = c_element_entry_id
   and peef.assignment_id = c_assignment_id;

-- Get date_earned of element_entry
CURSOR c_get_date_earned(c_element_entry_id number
          ) IS
  SELECT date_earned
    FROM pay_element_entries_f
   WHERE element_entry_id = c_element_entry_id;

-- Get dates in which mop-up should exist of element_entry
cursor c_get_nrec_mop_up_dates(c_assignment_id         NUMBER
                               ,c_effective_start_date DATE
                               ,c_date_earned          DATE
                               ,c_time_def_id          NUMBER) is
select /*+ use_nl(paf ptpp)*/
       ptpp.end_date + 1,
       ptpt.end_date
  from per_assignments_f paf
      ,per_time_periods ptpp
      ,per_time_periods ptpt
where paf.assignment_id = c_assignment_id
  and NVL(c_date_earned,c_effective_start_date) between paf.effective_start_date
                                                    and paf.effective_end_date
  and ptpp.payroll_id = paf.payroll_id
  and NVL(c_date_earned,c_effective_start_date) between ptpp.start_date
                                                    and ptpp.end_date
  and NVL(c_date_earned,ptpp.end_date) between ptpt.start_date
                                           and ptpt.end_date
  and ptpt.time_definition_id = c_time_def_id
  and ptpp.end_date between ptpt.start_date
                        and ptpt.end_date
  and ptpp.end_date <> ptpt.end_date
  and ptpt.time_definition_id is not null
  and ptpt.payroll_id is null
  and ptpp.time_definition_id is null
  and ptpp.payroll_id is not null;

-- Get the screen entry value
cursor c_get_scr_entry_value(c_element_entry_id number,
                             c_inp_value_name   varchar2,
                             c_effective_date   date) is
select peev.screen_entry_value
  from pay_element_entry_values_f peev
      ,pay_element_entries_f peef
      ,pay_input_values_f pivf
 where peef.element_entry_id = c_element_entry_id
   and peev.element_entry_id = peef.element_entry_id
   and pivf.element_type_id = peef.element_type_id
   and upper(pivf.name) = upper(c_inp_value_name)
   and peev.input_value_id = pivf.input_value_id
   and c_effective_date between peef.effective_start_date
                            and peef.effective_end_date
   and c_effective_date between peev.effective_start_date
                            and peev.effective_end_date
   and c_effective_date between pivf.effective_start_date
                            and pivf.effective_end_date;

-- Cursot to fetch the recurring element to be updates
cursor c_get_rec_elem_details(c_element_entry_id number
                             ,c_assignment_id    number) is
select distinct
       peef.element_entry_id
      ,peef.effective_start_date
  from pay_element_entries_f peef
 where peef.creator_id = c_element_entry_id
   and peef.assignment_id = c_assignment_id
   and peef.creator_type = 'FL'
order by peef.effective_start_date;

cursor c_get_inp_val_id(c_element_name      varchar2
                        ,c_inp_val_name       varchar2
                        ,c_business_group_id number) is
select distinct
       pivf.input_value_id
  from pay_element_types_f petf
      ,pay_input_values_f pivf
 where petf.element_name = c_element_name
   and petf.business_group_id = c_business_group_id
   and pivf.element_type_id = petf.element_type_id
   and pivf.name = c_inp_val_name;

ln_count                  number;
ln_business_group_id      number;
ln_time_definition_id     number;
ln_inp_value_id           number;
ln_ele_entry_id           number;
lvar                      number;
ln_screen_entry_value     varchar2(1000);
lv_element_name           varchar2(200);
lv_processing_type        varchar2(10);
lv_exist                  varchar2(20);
ld_entry_end_date         date;
ld_date_earned            date;
ld_mop_up_start_date      date;
ld_mop_up_end_date        date;
ld_eff_start_date         date;
lb_prem_flag              boolean;
lb_mop_up_flag            boolean;
lb_delete_mopup           boolean;
l_elem_entry_id_tbl       number_table;
l_del_start_date_tbl      date_table;
l_input_value_id_tbl      hr_entry.number_table;
l_entry_value_tbl         hr_entry.varchar2_table;

BEGIN

   hr_utility.trace('Entering PAY_US_ELEMENT_ENTRY_HOOK.UPDATE_PREMIUM_MOP_UP_ELEMENT');

   ln_count        := 0;
   lvar            := 0;
   lb_mop_up_flag  := FALSE;
   lb_delete_mopup := FALSE;

   -- Check for Premium Element
   lb_prem_flag := CHECK_PREMIUM_ELEM(p_element_entry_id
                                     ,p_effective_start_date
                                     ,lv_element_name
                                     ,lv_processing_type
                                     ,ln_business_group_id);

   -- Get the Time Definition associated with the Assignment as of
   -- Premium Element Entry Start Date
   ln_time_definition_id  :=
           pay_us_rules.get_time_def_for_entry_func(
                        p_element_entry_id     => p_element_entry_id
                       ,p_assignment_id        => p_assignment_id
                       ,p_assignment_action_id => NULL
                       ,p_business_group_id    => ln_business_group_id
                       ,p_time_def_date        => p_effective_start_date);

   if lb_prem_flag then
      open c_get_entry_end_date(p_element_entry_id
                               ,p_assignment_id);
      fetch c_get_entry_end_date into ld_entry_end_date;
      close c_get_entry_end_date;
      hr_utility.trace('Element End Date = ' || ld_entry_end_date);

      if lv_processing_type = 'N' then
         hr_utility.trace('Non Recurring Element');
         open c_get_rate_entry_count(p_element_entry_id
                                    ,p_effective_start_date);
         fetch c_get_rate_entry_count into ln_count;
         close c_get_rate_entry_count;

         /*Code to see if date earned demands a mopup to exist or not*/
         open c_get_date_earned (p_element_entry_id);
         fetch c_get_date_earned into ld_date_earned;
         IF c_get_date_earned%NOTFOUND THEN
            ld_date_earned := NULL;
         END IF;
         close c_get_date_earned;

         open c_get_nrec_mop_up_dates(p_assignment_id
                                     ,p_effective_start_date
                                     ,ld_date_earned
                                     ,ln_time_definition_id);
         fetch c_get_nrec_mop_up_dates into ld_mop_up_start_date
                                           ,ld_mop_up_end_date;
         if c_get_nrec_mop_up_dates%FOUND then
            lb_delete_mopup := FALSE;
         else
            lb_delete_mopup := TRUE;
         end if;
         close c_get_nrec_mop_up_dates;
         /*End of Code to see if date earned demands a mopup to exist or not*/

      else
         hr_utility.trace('Recurring Element');
         open c_get_rate_entry_count(p_element_entry_id
                                    ,ld_entry_end_date);
         fetch c_get_rate_entry_count into ln_count;
         close c_get_rate_entry_count;
      end if; -- if lv_processing_type =

      open c_check_mop_up_exists(p_element_entry_id
                                ,p_assignment_id);
      fetch c_check_mop_up_exists into lv_exist;
      if c_check_mop_up_exists%FOUND then
         if ((ln_count > 0) OR (lb_delete_mopup)) then
            -- Delete the Mop up as we do not require it now
            hr_utility.trace('Deleting Mop Up Element');
            DELETE_DEPENDENT_ENTRIES(p_element_entry_id
                                    ,p_assignment_id);
         else
            -- Get the input value id 'Multiple' for the Adjustment element
            ln_inp_value_id := NULL;
            open c_get_inp_val_id(lv_element_name ||
                                    ' for FLSA Period Adjustment'
                                  ,'Multiple'
                                  ,ln_business_group_id);
            fetch c_get_inp_val_id into ln_inp_value_id;
            if c_get_inp_val_id%FOUND then
               l_input_value_id_tbl(1) := ln_inp_value_id;
            end if;
            close c_get_inp_val_id;

            if ln_inp_value_id is NOT NULL then
               -- Get the value for the input value MULTIPLE specified
               -- for the Premium element. This value needs to be paased
               -- to the Adjustment element
               open c_get_scr_entry_value(p_element_entry_id
                                         ,'Multiple'
                                         ,ld_entry_end_date);
               fetch c_get_scr_entry_value into ln_screen_entry_value;
               if c_get_scr_entry_value%FOUND then
                  l_entry_value_tbl(1) := ln_screen_entry_value;
               else
                  l_entry_value_tbl(1) := NULL;
               end if; -- if c_get_scr_entry_value%FOUND
               close c_get_scr_entry_value;
            end if; -- if ln_inp_value_id is NOT NULL

            -- Get the Element ENtgry ID details fo the recurring elements
            lvar := 0;
            open c_get_rec_elem_details(p_element_entry_id
                                       ,p_assignment_id);
            loop
               fetch c_get_rec_elem_details into ln_ele_entry_id
                                                ,ld_eff_start_date;
               exit when c_get_rec_elem_details%NOTFOUND;
               l_elem_entry_id_tbl(lvar) := ln_ele_entry_id;
               l_del_start_date_tbl(lvar) := ld_eff_start_date;
               lvar := lvar + 1;
            end loop;

            for lvar in l_elem_entry_id_tbl.first..l_elem_entry_id_tbl.last
            loop
               hr_entry_api.update_element_entry
                            (p_dt_update_mode     => 'CORRECTION'
                            ,p_session_date       => l_del_start_date_tbl(lvar)
                            ,p_element_entry_id   => l_elem_entry_id_tbl(lvar)
                            ,p_num_entry_values   => l_entry_value_tbl.count()
                            ,p_input_value_id_tbl => l_input_value_id_tbl
                            ,p_entry_value_tbl    => l_entry_value_tbl);
            end loop; -- for lvar in 1..
         end if; -- if ln_count > 0
      else
         if ln_count = 0 then
            -- Create the Mop up as it does not exist
            hr_utility.trace('Creating Mop Up Element');
            CREATE_PREMIUM_MOP_UP_ELEMENT(
                              p_element_entry_id
                             ,p_effective_start_date
                             ,p_effective_end_date
                             ,p_assignment_id
                             ,p_element_link_id
                             ,p_original_entry_id
                             ,p_creator_type
                             ,p_entry_type
                             ,p_entry_information_category);
         end if; -- if ln_count = 0
      end if; -- if c_check_mop_up_exists%FOUND

   end if;

   hr_utility.trace('Leaving PAY_US_ELEMENT_ENTRY_HOOK.UPDATE_PREMIUM_MOP_UP_ELEMENT');
   return;

END UPDATE_PREMIUM_MOP_UP_ELEMENT;


/******************************************************************************
   Name        : UPDATE_USER_HOOK
   Scope       : GLOBAL
   Description : This procedure is called by AFTER UPDATE Row Level handler
                 User Hook.
******************************************************************************/
PROCEDURE UPDATE_USER_HOOK(
   p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_assignment_id_o              in number
  ,p_element_link_id_o            in number
  ,p_original_entry_id_o          in number
  ,p_creator_type_o               in varchar2
  ,p_entry_type_o                 in varchar2
  ,p_entry_information_category_o in varchar2) IS
BEGIN
   hr_utility.trace('Entering PAY_US_ELEMENT_ENTRY_HOOK.UPDATE_USER_HOOK');

   -- Update the Recurring Element Entry associated with
   -- the Augment element
   UPDATE_RECUR_ELEM_ENTRY(p_element_entry_id
                          ,p_effective_start_date
                          ,p_effective_end_date
                          ,p_assignment_id_o
                          ,p_element_link_id_o
                          ,p_original_entry_id_o
                          ,p_creator_type_o
                          ,p_entry_type_o
                          ,p_entry_information_category_o);

   -- Update the Mop Up Element Entry associated with
   -- the Premium element
   UPDATE_PREMIUM_MOP_UP_ELEMENT(p_element_entry_id
                                ,p_effective_start_date
                                ,p_effective_end_date
                                ,p_assignment_id_o
                                ,p_element_link_id_o
                                ,p_original_entry_id_o
                                ,p_creator_type_o
                                ,p_entry_type_o
                                ,p_entry_information_category_o);

   -- Call CREATE_TAX_REACORDS
   -- We need to create TAX RECORDS if JURSIDICTION input value is updated
   -- for the employee and the employee does not have any tax records for
   -- that state.
   CREATE_TAX_RECORDS(p_element_entry_id
                     ,p_effective_start_date
                     ,p_effective_end_date
                     ,p_assignment_id_o
                     ,p_element_link_id_o
                     ,p_original_entry_id_o
                     ,p_creator_type_o
                     ,p_entry_type_o
                     ,p_entry_information_category_o);

   hr_utility.trace('Leaving PAY_US_ELEMENT_ENTRY_HOOK.UPDATE_USER_HOOK');
   return;
END UPDATE_USER_HOOK;

-----------------------------UPDATE SECTION ENDS HERE--------------------------

-----------------------------DELETE SECTION BEGINS HERE------------------------

/******************************************************************************
   Name        : DELETE_DEPENDENT_ENTRIES
   Scope       : LOCAL
   Description : This procedure is called by AFTER DELETE Row Level handler
                 User Hook.
******************************************************************************/
PROCEDURE DELETE_PREM_MOP_UP_ELE_ENTRY(
   p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_assignment_id                in number
  ,p_element_link_id              in number
  ,p_original_entry_id            in number
  ,p_creator_type                 in varchar2
  ,p_entry_type                   in varchar2
  ,p_entry_information_category   in varchar2) IS

-- Get the End date of the recurring element.
cursor c_get_entry_end_date(c_element_entry_id number
                           ,c_assignment_id    number) is
select max(peef.effective_end_date)
  from pay_element_entries_f peef
 where peef.element_entry_id = c_element_entry_id
   and peef.assignment_id = c_assignment_id;

ln_business_group_id number;
lv_element_name      varchar2(200);
lv_processing_type   varchar2(10);
ld_entry_end_date    date;
ld_end_of_time       date;
lb_prem_flag         boolean;

BEGIN
   hr_utility.trace
         ('Entering PAY_US_ELEMENT_ENTRY_HOOK.DELETE_PREM_MOP_UP_ELE_ENTRY');

   ld_end_of_time := fnd_date.canonical_to_date('4712/12/31');

   lb_prem_flag := CHECK_PREMIUM_ELEM(p_element_entry_id
                                     ,p_effective_start_date
                                     ,lv_element_name
                                     ,lv_processing_type
                                     ,ln_business_group_id);

   if lb_prem_flag then
      open c_get_entry_end_date(p_element_entry_id
                               ,p_assignment_id);
      fetch c_get_entry_end_date into ld_entry_end_date;
      if c_get_entry_end_date%NOTFOUND then
         hr_utility.trace('Deleting Mop Up Element Entry');
         -- Delete the Recurring Element Entry associated with
         -- the Augment element
         DELETE_DEPENDENT_ENTRIES(p_element_entry_id
                                 ,p_assignment_id);
      elsif ld_entry_end_date <> ld_end_of_time then
            -- Create the Mop up as it does not exist
            hr_utility.trace('Creating Mop Up Element');
            CREATE_PREMIUM_MOP_UP_ELEMENT(
                              p_element_entry_id
                             ,p_effective_start_date
                             ,p_effective_end_date
                             ,p_assignment_id
                             ,p_element_link_id
                             ,p_original_entry_id
                             ,p_creator_type
                             ,p_entry_type
                             ,p_entry_information_category);
      end if; -- if c_get_entry_end_date
      close c_get_entry_end_date;
   end if; -- if lb_prem_flag

   hr_utility.trace
         ('Leaving PAY_US_ELEMENT_ENTRY_HOOK.DELETE_PREM_MOP_UP_ELE_ENTRY');
   return;
END DELETE_PREM_MOP_UP_ELE_ENTRY;

/******************************************************************************
   Name        : DELETE_USER_HOOK
   Scope       : GLOBAL
   Description : This procedure is called by AFTER DELETE Row Level handler
                 User Hook.
******************************************************************************/
PROCEDURE DELETE_USER_HOOK(
   p_element_entry_id             in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_assignment_id_o              in number
  ,p_element_link_id_o            in number
  ,p_original_entry_id_o          in number
  ,p_creator_type_o               in varchar2
  ,p_entry_type_o                 in varchar2
  ,p_entry_information_category_o in varchar2) IS

-- Check if the element entry Exists
cursor c_chk_elem_entry_exists(c_element_entry_id number) is
select 'Exist'
  from pay_element_entries_f
 where element_entry_id = c_element_entry_id;

lv_exists varchar2(10);

BEGIN
   hr_utility.trace('Entering PAY_US_ELEMENT_ENTRY_HOOK.DELETE_USER_HOOK');

   -- Check if the Element Entry was Purged. If yes delete the associated
   -- 'FL' creator type elements.
   -- We do not have any way to check the type of element once it is deleted
   open c_chk_elem_entry_exists(p_element_entry_id);
   fetch c_chk_elem_entry_exists into lv_exists;
   if c_chk_elem_entry_exists%NOTFOUND then
      -- Delete the Element Entry associated with base element entry
      DELETE_DEPENDENT_ENTRIES(p_element_entry_id
                              ,p_assignment_id_o);
   else
      -- Delete the Mop Up Element Entry associated with
      -- the Premium element
      DELETE_PREM_MOP_UP_ELE_ENTRY(p_element_entry_id
                                  ,p_effective_start_date
                                  ,p_effective_end_date
                                  ,p_assignment_id_o
                                  ,p_element_link_id_o
                                  ,p_original_entry_id_o
                                  ,p_creator_type_o
                                  ,p_entry_type_o
                                  ,p_entry_information_category_o);

   end if; -- if c_chk_elem_entry_exists%NOTFOUND
   close c_chk_elem_entry_exists;

   hr_utility.trace('Leaving PAY_US_ELEMENT_ENTRY_HOOK.DELETE_USER_HOOK');
   return;
END DELETE_USER_HOOK;

-----------------------------DELETE SECTION ENDS HERE--------------------------

END PAY_US_ELEMENT_ENTRY_HOOK;

/
