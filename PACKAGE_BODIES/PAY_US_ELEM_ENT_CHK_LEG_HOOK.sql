--------------------------------------------------------
--  DDL for Package Body PAY_US_ELEM_ENT_CHK_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_ELEM_ENT_CHK_LEG_HOOK" AS
/* $Header: pyuschee.pkb 120.0 2005/05/29 09:19:15 appldev noship $ */

/*******************************************************************************
    Name    : CHK_ELEM_ENTRY
    Purpose : This procedure is used to make sure that in the element entry
              screen Involuntary deduction elements of same architecture are
              entered. Element of two different architectures are not allowed.

*******************************************************************************/

PROCEDURE CHK_ELEM_ENTRY(
    p_assignment_id number,
    p_effective_start_date date,
    p_element_link_id number
    ) IS

    CURSOR c_get_elem_entries IS
       select pet.element_name,
              pet.element_information4,
              pet.business_group_id
         from pay_element_entries_f pee,
              pay_element_links_f pel,
              pay_element_types_f pet,
              pay_element_classifications pec,
	      per_assignments_f paf,
	      per_time_periods ptp
        where paf.assignment_id = p_assignment_id
          and pee.assignment_id = paf.assignment_id
          and ptp.payroll_id = paf.payroll_id
          and p_effective_start_date between ptp.start_date and ptp.end_date
          and ptp.start_date < pee.effective_end_date
          and pee.element_link_id = pel.element_link_id
          and pel.element_link_id <> p_element_link_id
          and pel.element_type_id = pet.element_type_id
          and pet.classification_id = pec.classification_id
          and pec.classification_name = 'Involuntary Deductions';


    CURSOR c_curr_elem_arch IS
       select pet.element_name,
              pet.element_information4,
              pet.business_group_id
         from pay_element_links_f pel,
              pay_element_types_f pet,
              pay_element_classifications pec
        where pel.element_link_id = p_element_link_id
          and pel.element_type_id = pet.element_type_id
          and pet.classification_id = pec.classification_id
          and pec.classification_name = 'Involuntary Deductions';


    -- Cursor to check the architecture used for the element created
    CURSOR  c_get_template_id(cp_element_name      varchar2,
                              cp_business_group_id number) IS
       select pset.template_id
         from pay_shadow_element_types pset,
              pay_element_templates pet
        where pet.template_id = pset.template_id
          and pet.template_type = 'U'
          and pset.element_name = cp_element_name
          and pet.business_group_id = cp_business_group_id;

    lv_element_name       VARCHAR2(100);
    ln_business_group_id  NUMBER;
    ln_template_id        NUMBER;

    ln_architecture_flag  NUMBER;
    lb_status             BOOLEAN;
    lv_elem_upg           VARCHAR2(50);

    lv_procedure_name     VARCHAR2(100);

BEGIN

    lv_procedure_name := 'PAY_US_ELEM_ENT_CHK_LEG_HOOK.CHK_ELEM_ENTRY';
    hr_utility.trace('Entering '|| lv_procedure_name);
    hr_utility.set_location (lv_procedure_name,10);
    hr_utility.trace('Input parameters....');
    hr_utility.trace('P_ASSIGNMENT_ID = '||P_ASSIGNMENT_ID);
    hr_utility.trace('p_effective_start_date = ' || p_effective_start_date);
    hr_utility.trace('p_element_entry_link_id = '|| p_element_link_id);

    ln_architecture_flag := -1; /* No architecture selected currently */
    lb_status := TRUE;
    lv_element_name := null;
    ln_business_group_id := null;

    -- Code to get the architecture used for creating the element
    -- currently being entered.
    -- If we are able to find a template in the
    -- PAY_SHADOW_ELEMENT_TYPES for the Involuntary Deduction element
    -- being added, then the element was created using the new architecture.
    open c_curr_elem_arch();
    fetch c_curr_elem_arch into lv_element_name,
                                lv_elem_upg,
                                ln_business_group_id;
    if c_curr_elem_arch%NOTFOUND then
       close c_curr_elem_arch;
       return; /* Element does not belong to Involuntary Deductions category */
    end if;

    if c_curr_elem_arch%FOUND then
       if lv_elem_upg is NULL then
          open c_get_template_id(lv_element_name, ln_business_group_id);
          fetch c_get_template_id into ln_template_id;
          if c_get_template_id%FOUND then
             ln_architecture_flag := 1; /* New architecture */
          else
             ln_architecture_flag := 0; /* Old architecture */
          end if;
          close c_get_template_id;
       else
          ln_architecture_flag := 1; /* New architecture */
       end if;
    end if;
    close c_curr_elem_arch;

    -- Below we find the architecture for the element entry.
    -- Check for element entries for the assignment.
    lv_element_name := null;
    ln_business_group_id := null;
    open c_get_elem_entries();
    loop
       fetch c_get_elem_entries into lv_element_name,
                                     lv_elem_upg,
                                     ln_business_group_id;
       exit when c_get_elem_entries%NOTFOUND;

       if lv_elem_upg is not NULL then -- Check for element upgraded Bug 3549298
          if ln_architecture_flag = 0 then
             lb_status := FALSE;
          end if;
       else
          open c_get_template_id(lv_element_name,ln_business_group_id);
          fetch c_get_template_id into ln_template_id;
          if c_get_template_id%FOUND then
             if ln_architecture_flag = 0 then
                lb_status := FALSE;
             end if;
          else
             if ln_architecture_flag = 1 then
                lb_status := FALSE;
             end if;
          end if;
          close c_get_template_id;
       end if;
       exit when lb_status = FALSE;
    end loop;
    close c_get_elem_entries;

    if lb_status then
       hr_utility.set_location (lv_procedure_name,20);
       hr_utility.trace('Leaving '||lv_procedure_name);
       return;
    else
       hr_utility.set_location (lv_procedure_name,30);
       hr_utility.set_message(801,'PAY_US_WAGE_ARCH_DIFF');
       hr_utility.raise_error;
    end if;

END CHK_ELEM_ENTRY;

END PAY_US_ELEM_ENT_CHK_LEG_HOOK;

/
