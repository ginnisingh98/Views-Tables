--------------------------------------------------------
--  DDL for Package Body HR_GB_PROCESS_P11D_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GB_PROCESS_P11D_ENTRIES_PKG" as
/* $Header: pygbp11d.pkb 120.18.12010000.15 2010/03/12 11:32:51 krreddy ship $ */
    g_package            constant VARCHAR2(33) := '  hr_gb_process_p11d_entries_pkg.';
   procedure  clob_to_blob(p_clob clob,
                           p_blob in out nocopy Blob)
   is
        l_length_clob number;
        l_offset integer;
        l_varchar_buffer varchar2(32000);
        l_raw_buffer raw(32000);
        l_buffer_len number:= 32000;
        l_chunk_len number;
        l_blob blob;
   begin
        l_length_clob := dbms_lob.getlength(p_clob);
        l_offset := 1;
        while l_length_clob > 0 loop
              hr_utility.trace('l_length_clob '|| l_length_clob);
              if l_length_clob < l_buffer_len then
                 l_chunk_len := l_length_clob;
              else
                  l_chunk_len := l_buffer_len;
              end if;
              DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
              l_raw_buffer := utl_raw.cast_to_raw(l_varchar_buffer);
              dbms_lob.write(p_blob,l_chunk_len, l_offset, l_raw_buffer);
              l_offset := l_offset + l_chunk_len;
              l_length_clob := l_length_clob - l_chunk_len;
              hr_utility.trace('l_length_blob '|| dbms_lob.getlength(p_blob));
        end loop;
   end;

   procedure delete_entries(errbuf              out nocopy VARCHAR2,
                            retcode             out nocopy NUMBER,
                            p_element_type_id   in pay_element_types_f.element_type_id%type,
                            p_start_date        in VARCHAR2,
                            p_end_date          in VARCHAR2,
                            p_bus_grp_id        in pay_element_types_f.business_group_id%type,
                            p_assignment_set_id in Number   )
   is
        l_ben_start_date_id           pay_input_values_f.input_value_id%type;
        l_ben_end_date_id             pay_input_values_f.input_value_id%type;
        l_element_name                pay_element_types_f.element_name%type;
        l_count                       NUMBER default 0;
        l_effective_start_date_dummy  DATE;
        l_effective_end_date_dummy    DATE;
        l_del_warning_dummy           BOOLEAN;
        e_p11d_element_err            exception;
        e_p11d_ben_st_dt_err          exception;
        e_p11d_ben_end_dt_err         exception;
        cursor csr_get_element_name(v_element_type_id pay_element_types_f.element_type_id%type)
        is
        select element_name
        from   pay_element_types_f pet
        where  pet.element_type_id = v_element_type_id;

        cursor csr_get_benefit_date_id(v_ben_date_type   VARCHAR2,
                                       v_element_type_id pay_element_types_f.element_type_id%type)
        is
        select input_value_id
        from   pay_input_values_f piv
        where  piv.element_type_id = v_element_type_id
        and    piv.NAME = v_ben_date_type;

        cursor csr_get_del_element_entry_id(v_ben_start_date_id  pay_input_values_f.input_value_id%type,
                                            v_start_date         VARCHAR2,
                                            v_ben_end_date_id    pay_input_values_f.input_value_id%type,
                                            v_end_date           VARCHAR2,
                                            v_bus_grp_id         pay_element_types_f.business_group_id%type,
                                            v_element_type_id    pay_element_types_f.element_type_id%type)
        is
        select /*+ ordered */
              pee.element_entry_id, pee.object_version_number, pee.effective_start_date
        from  pay_element_links_f pel,
              pay_element_entries_f pee,
              pay_element_entry_values_f peev_sd,
              pay_element_entry_values_f peev_ed
        where pel.element_type_id = v_element_type_id
        and   pee.element_link_id = pel.element_link_id
        and   pee.effective_start_date between pel.effective_start_date and pel.effective_end_date
        and   pee.effective_end_date between pel.effective_start_date and pel.effective_end_date
        and   peev_sd.element_entry_id = pee.element_entry_id
        and   peev_ed.element_entry_id = pee.element_entry_id
        and   peev_sd.element_entry_id = peev_ed.element_entry_id
        and   peev_sd.input_value_id = v_ben_start_date_id
        and   peev_sd.screen_entry_value >= v_start_date
        and   peev_ed.input_value_id = v_ben_end_date_id
        and   peev_ed.screen_entry_value <= v_end_date
        and exists( select /*+ no_unnest */
                                   1
                    from  per_all_assignments_f paa
                    where paa.assignment_id = pee.assignment_id
                    and   paa.business_group_id = v_bus_grp_id);

        cursor csr_del_entries_assignset(v_ben_start_date_id pay_input_values_f.input_value_id%type,
                                         v_start_date        VARCHAR2,
                                         v_ben_end_date_id   pay_input_values_f.input_value_id%type,
                                         v_end_date          VARCHAR2,
                                         v_bus_grp_id        pay_element_types_f.business_group_id%type,
                                         v_element_type_id   pay_element_types_f.element_type_id%type,
                                         v_assignment_set_id Number)
        is
        select /*+ ordered */
              pee.element_entry_id, pee.object_version_number, pee.effective_start_date
        from  pay_element_links_f pel,
              pay_element_entries_f pee,
              pay_element_entry_values_f peev_sd,
              pay_element_entry_values_f peev_ed
        where pel.element_type_id = v_element_type_id
        and   pee.element_link_id = pel.element_link_id
        and   pee.effective_start_date between pel.effective_start_date and pel.effective_end_date
        and   pee.effective_end_date between pel.effective_start_date and pel.effective_end_date
        and   peev_sd.element_entry_id = pee.element_entry_id
        and   peev_ed.element_entry_id = pee.element_entry_id
        and   peev_sd.element_entry_id = peev_ed.element_entry_id
        and   peev_sd.input_value_id = v_ben_start_date_id
        and   peev_sd.screen_entry_value >= v_start_date
        and   peev_ed.input_value_id = v_ben_end_date_id
        and   peev_ed.screen_entry_value <= v_end_date
        and exists( select /*+ no_unnest */
                           1
                    from  per_all_assignments_f paa,
                          hr_assignment_sets has,
                          hr_assignment_set_amendments hasa
                    where paa.assignment_id = pee.assignment_id
                    and   paa.business_group_id = v_bus_grp_id
                    and   (    has.assignment_set_id = v_assignment_set_id
                           and nvl(has.payroll_id, paa.payroll_id) = paa.payroll_id
                           and has.assignment_set_id = hasa.assignment_set_id(+)
                           and nvl(hasa.include_or_exclude, 'I') = 'I'
                           and nvl(hasa.assignment_id, paa.assignment_id) = paa.assignment_id));

   -- BEGIN of the procedure delete_entries
   begin
        -- initialize the return code to 0
        retcode := 0;
        -- get the element name
        open csr_get_element_name(p_element_type_id);
        fetch csr_get_element_name into l_element_name;
        if csr_get_element_name%notfound
        then
            close csr_get_element_name;
            hr_utility.TRACE('Incorrect element type id '|| p_element_type_id);
            raise e_p11d_element_err;
        end if;
        close csr_get_element_name;
        hr_utility.TRACE('Value of element name='|| l_element_name);
        -- get the benefit start date id
        open csr_get_benefit_date_id(c_ben_start_date_string, p_element_type_id);
        fetch csr_get_benefit_date_id into l_ben_start_date_id;
        if csr_get_benefit_date_id%notfound
        then
            close csr_get_benefit_date_id;
            hr_utility.TRACE('No Benefit Start date defined for element ');
            raise e_p11d_ben_st_dt_err;
        end if;
        close csr_get_benefit_date_id;
        hr_utility.TRACE('Value of benefit start date id = '|| to_char(l_ben_start_date_id) );
        -- get the benefit END date id;
        open csr_get_benefit_date_id(c_ben_end_date_string, p_element_type_id);
        fetch csr_get_benefit_date_id into l_ben_end_date_id;
        if csr_get_benefit_date_id%notfound
        then
            close csr_get_benefit_date_id;
            hr_utility.TRACE('No Benefit End date defined for element type id ');
            raise e_p11d_ben_end_dt_err;
        end if;
        close csr_get_benefit_date_id;
        hr_utility.TRACE('Value of benefit end date  id ='|| to_char(l_ben_end_date_id) );
        -- get the elementry id WHERE the start date is greater than the p_start_date
        -- AND END date is less than the p_end_date. Only those element entry id's will
        -- be returned WHERE the business group id is p_bus_grp_id
        hr_utility.TRACE('p_start_date '|| p_start_date);
        hr_utility.TRACE('p_end_date '|| p_end_date);
        hr_utility.TRACE('p_bus_grp_id '|| p_bus_grp_id);
        hr_utility.TRACE('p_element_type_id '|| p_element_type_id);
        if p_assignment_set_id is null then
           for del_element_entry in csr_get_del_element_entry_id(
                                      l_ben_start_date_id,
                                      p_start_date,
                                      l_ben_end_date_id,
                                      p_end_date,
                                      p_bus_grp_id,
                                      p_element_type_id)
           loop
               l_count := l_count + 1;
               hr_utility.TRACE('Delete entries for element entry id '|| to_char(del_element_entry.element_entry_id) );
               pay_element_entry_api.delete_element_entry(p_datetrack_delete_mode => 'ZAP',
                                                          p_effective_date        => del_element_entry.effective_start_date,
                                                          p_element_entry_id      => del_element_entry.element_entry_id,
                                                          p_object_version_number => del_element_entry.object_version_number,
                                                          p_effective_start_date  => l_effective_start_date_dummy,
                                                          p_effective_end_date    => l_effective_end_date_dummy,
                                                          p_delete_warning        => l_del_warning_dummy);
               if mod(l_count, c_commit_num) = 0
               then
                   commit;
                   hr_utility.TRACE('Commiting delete, counter = '|| to_char(l_count) );
               end if;
           end loop;
        else
           for del_element_entry in csr_del_entries_assignset(
                                      l_ben_start_date_id,
                                      p_start_date,
                                      l_ben_end_date_id,
                                      p_end_date,
                                      p_bus_grp_id,
                                      p_element_type_id,
                                      p_assignment_set_id)
           loop
               l_count := l_count + 1;
               hr_utility.TRACE('Delete entries for element entry id '|| to_char(del_element_entry.element_entry_id) );
               pay_element_entry_api.delete_element_entry(p_datetrack_delete_mode => 'ZAP',
                                                          p_effective_date        => del_element_entry.effective_start_date,
                                                          p_element_entry_id      => del_element_entry.element_entry_id,
                                                          p_object_version_number => del_element_entry.object_version_number,
                                                          p_effective_start_date  => l_effective_start_date_dummy,
                                                          p_effective_end_date    => l_effective_end_date_dummy,
                                                          p_delete_warning        => l_del_warning_dummy);
               if mod(l_count, c_commit_num) = 0
               then
                   commit;
                   hr_utility.TRACE('Commiting delete, counter = '|| to_char(l_count) );
               end if;
           end loop;
        end if;
        commit;
   exception
     when e_p11d_element_err
     then
         hr_utility.set_message(800, 'HR_78046_GB_P11D_ELEMENT_ERR');
         hr_utility.set_message_token(800, 'ELEMENT', l_element_name);
         errbuf := hr_utility.get_message;
         hr_utility.raise_error;
         retcode := 1;
         rollback;
     when e_p11d_ben_st_dt_err
     then
         hr_utility.set_message(800, 'HR_78047_GB_P11D_BEN_ST_DT_ERR');
         hr_utility.set_message_token(800, 'ELEMENT', l_element_name);
         errbuf := hr_utility.get_message;
         hr_utility.raise_error;
         retcode := 1;
         rollback;
     when e_p11d_ben_end_dt_err
     then
         hr_utility.set_message(800, 'HR_78048_GB_P11D_BEN_ED_DT_ERR');
         hr_utility.set_message_token(800, 'ELEMENT', l_element_name);
         errbuf := hr_utility.get_message;
         hr_utility.raise_error;
         retcode := 1;
         rollback;
     when OTHERS
     then
         if csr_get_element_name%isopen
         then
             close csr_get_element_name;
         end if;
         if csr_get_benefit_date_id%isopen
         then
             close csr_get_benefit_date_id;
         end if;
         if csr_get_del_element_entry_id%isopen
         then
             close csr_get_del_element_entry_id;
         end if;
         hr_utility.set_message(800, 'HR_78045_GB_P11D_DEL_ERR');
         hr_utility.set_message_token(800, 'ERRORMSG', sqlerrm);
         errbuf := hr_utility.get_message;
         hr_utility.raise_error;
         retcode := 1;
         rollback;
   end delete_entries;

   function get_null_error(p_token1 in VARCHAR2,
                           p_token2 in VARCHAR2,
                           p_token3 in VARCHAR2)return VARCHAR2
   is
        l_errmsg                      VARCHAR2(1000);
   begin
        hr_utility.set_message(800, 'HR_78052_GB_P11D_VALUES_NULL');
        hr_utility.set_message_token(800, '1INPUT_VALUE', p_token1);
        hr_utility.set_message_token(800, '2INPUT_VALUE', p_token2);
        -- hr_utility.set_message_token (800, '3INPUT_VALUE', p_token3);
        l_errmsg := hr_utility.get_message;
        return l_errmsg;
   end get_null_error;

   function get_incorrect_val_error(p_token1 in VARCHAR2,
                                    p_token2 in VARCHAR2,
                                    p_token3 in VARCHAR2) return VARCHAR2
   is
        l_errmsg                      VARCHAR2(1000);
   begin
        hr_utility.set_message(800, 'HR_78051_GB_P11D_INCORRECT_VAL');
        hr_utility.set_message_token(800, '1INPUT_VALUE', p_token1);
        hr_utility.set_message_token(800, '2INPUT_VALUE', p_token2);
        hr_utility.set_message_token(800, '3INPUT_VALUE', p_token3);
        l_errmsg := hr_utility.get_message;
        return l_errmsg;
   end get_incorrect_val_error;

   function get_error_message(p_applid in NUMBER,
                              p_message_name in VARCHAR2) return VARCHAR2
   is
        l_errmsg                      VARCHAR2(1000);
   begin
        hr_utility.set_message(p_applid, p_message_name);
        l_errmsg := hr_utility.get_message;
        return l_errmsg;
   end get_error_message;

   function get_loan_amount(p_archive_payroll_action_id in VARCHAR2,
                            p_employers_ref_no          in VARCHAR2,
                            --p_employers_name      IN   VARCHAR2,
                            p_person_id                 in VARCHAR2) return VARCHAR2
   is
        l_loan_amount                 NUMBER;
   begin
        select sum(nvl(pai.action_information7, 0) )
        into  l_loan_amount
        from  pay_action_information pai_comp,
              pay_action_information pai_person,
              pay_action_information pai,
              pay_assignment_actions paa,
              pay_payroll_actions ppa
        where ppa.payroll_action_id = p_archive_payroll_action_id
        and   ppa.payroll_action_id = paa.payroll_action_id
        and   pai_comp.action_context_id = paa.assignment_action_id
        and   pai_comp.action_information_category = 'EMEA PAYROLL INFO'
        and   pai_comp.action_context_type = 'AAP'
        and   pai_comp.action_information6 = p_employers_ref_no
        -- AND pai_comp.action_information7 = p_employers_name
        and   pai_person.action_context_id = paa.assignment_action_id
        and   pai_person.action_information_category = 'ADDRESS DETAILS'
        and   pai_person.action_context_type = 'AAP'
        and   pai_person.action_information14 = 'Employee Address'
        and   pai_person.action_information1 = p_person_id
        and   pai.action_context_id = paa.assignment_action_id
        and   pai.action_context_type = 'AAP'
        and   pai.action_information_category = 'INT FREE AND LOW INT LOANS';
      return to_char(l_loan_amount);
   end get_loan_amount;

   function get_global_value(p_global_name in VARCHAR2,
                             p_benefit_end_date in VARCHAR2 default '0001/01/01 00:00:00') return VARCHAR2
   is
        l_global_value ff_globals_f.global_value%type;
        cursor csr_get_value
        is
        select global_value
        from   ff_globals_f
        where  legislation_code = 'GB'
        and    GLOBAL_NAME = p_global_name
        and    fnd_date.canonical_to_date(p_benefit_end_date)
               between effective_start_date and effective_end_date;
   begin
        hr_utility.TRACE('p_benefit_end_date '|| p_benefit_end_date);
        hr_utility.TRACE('p_global_name '|| p_global_name);
        open csr_get_value;
        fetch csr_get_value into l_global_value;
        close csr_get_value;
        return l_global_value;
   end;

   function sum_and_set_global_var(p_varable_name in VARCHAR2,
                                   p_variable_value in VARCHAR2) return NUMBER
   is
        l_present_val NUMBER;
        l_new_val     NUMBER;
        l_dummy       NUMBER;
   begin
        hr_utility.TRACE(' p_variable_value '|| p_variable_value);
        l_present_val := per_formula_functions.get_number(p_varable_name);
        hr_utility.TRACE(' l_present_val '|| l_present_val);
        if l_present_val is null
        then
            if p_variable_value is null
            then
                l_new_val := null;
            else
                l_new_val := nvl(to_number(p_variable_value), 0);
            end if;
            hr_utility.TRACE('l_new_val '|| l_new_val);
        else
--Added the below logic for the bug fix 8864717.
--
            if ((l_present_val = p_variable_value) and (PAY_GB_P11D_ARCHIVE_SS.g_updated_flag = 'Y'))
            then
                l_new_val := l_present_val ;
            else
                l_new_val := l_present_val + nvl(to_number(p_variable_value), 0);
            end if;
--
            hr_utility.TRACE(' l_new_val '|| l_new_val);
        end if;
        l_dummy := per_formula_functions.set_number(p_varable_name, l_new_val);
        hr_utility.TRACE(' l_dummy '|| l_dummy);
        return l_new_val;
   end;

   function max_and_set_global_var(p_variable_name     in Varchar2,
                                   p_variable_datatype in Varchar2,
                                   p_variable_value    in Varchar2) return varchar2
   is
        l_present_val varchar2(20);
        l_warnmsg     varchar2(20);
        l_dummy       NUMBER;
   begin
        l_warnmsg := '0';
        if p_variable_datatype = 'N' then
           -- we need to store the value st away
           -- rates remain same for a vehicle type
           -- !! the above statm is not true as second assignment (multi)
           -- might not have this benefit type hence it will be zero,
           -- so we don't want to store zero.
           if nvl(per_formula_functions.get_number(p_variable_name),0) < nvl(to_number(p_variable_value),0) then
              l_dummy := per_formula_functions.set_number(p_variable_name, p_variable_value);
           end if;
        end if;
        if p_variable_datatype = 'T' then
           -- we need to store the Y value
           -- as this will be called only when the value is Y
           l_dummy := per_formula_functions.set_text(p_variable_name, p_variable_value);
        end if;
        if p_variable_datatype = 'D' then
           -- this is for date, we need to store the max date
           -- this is used for date free fuel withdrawn
           -- if p_variable_value is null or zero this won't be called
           l_present_val := per_formula_functions.get_text(p_variable_name);
           hr_utility.TRACE(' l_present_val '|| l_present_val);
           if l_present_val is null
           then
               l_dummy := per_formula_functions.set_text(p_variable_name, p_variable_value);
           else
               if fnd_date.canonical_to_date(l_present_val) <>
                  fnd_date.canonical_to_date(p_variable_value)
               then
                   l_warnmsg := '1';
                   if fnd_date.canonical_to_date(l_present_val) <
                      fnd_date.canonical_to_date(p_variable_value)
                   then
                       l_dummy := per_formula_functions.set_text(p_variable_name, p_variable_value);
                   end if;
               end if;
           end if;
        end if;
        return l_warnmsg;
   end;

   function get_lookup_desc (p_lookup_type    varchar2,
                             p_lookup_code    varchar2,
                             p_effective_date varchar2) return varchar2
   is
        l_description varchar2(150);
   begin
        /*Bug No. 3237648*/
        /*Fetching from hr_lookups instead of fnd_lookup_values*/
        select description into l_description
        from  hr_lookups hlu
        where hlu.lookup_type = p_lookup_type
        and  hlu.lookup_code = p_lookup_code
        and  hlu.ENABLED_FLAG = 'Y'
        and  fnd_date.canonical_to_date(p_effective_date) between
                 nvl(hlu.START_DATE_ACTIVE,fnd_date.canonical_to_date(p_effective_date))
             and nvl(hlu.END_DATE_ACTIVE,fnd_date.canonical_to_date(p_effective_date));
        return l_description ;
    exception
    when others then
         l_description  := null;
         return l_description ;
    end;

    function check_desc_and_set_global_var(p_varable_name   in VARCHAR2,
                                           p_variable_value in VARCHAR2,
                                           p_lookup_type    in VARCHAR2 default null,
                                           p_effective_date in VARCHAR2 default null) return NUMBER
    is
         l_present_val VARCHAR2(150);
         l_new_val     VARCHAR2(150);
         l_dummy       NUMBER;
    begin
         hr_utility.TRACE('.. p_varable_name ...'|| p_varable_name);
         hr_utility.TRACE('.. p_variable_value ...'|| p_variable_value);
         l_present_val := per_formula_functions.get_text(p_varable_name);
         hr_utility.TRACE('..l_present_val.. '|| l_present_val);
         if p_lookup_type is null
         then
            if l_present_val is null
            then
                l_new_val := p_variable_value;
                l_dummy := per_formula_functions.set_text(p_varable_name, l_new_val);
            else
                hr_utility.TRACE('..Checking present Value with variable value '|| l_present_val);
                if l_present_val <> nvl(p_variable_value, l_present_val)
                then
                    l_new_val := 'Multiple';
                    l_dummy := per_formula_functions.set_text(p_varable_name, l_new_val);
                end if;
            end if;
         else
            l_new_val := get_lookup_desc (p_lookup_type,
                                          p_variable_value,
                                          p_effective_date || ' 00:00:00'); -- since it accepts date in canonical format
            if l_present_val is null
            then
                hr_utility.trace('New vale ' || l_new_val);
                l_dummy := per_formula_functions.set_text(p_varable_name, l_new_val);
            else
                hr_utility.TRACE('..Checking present Value with variable value '|| l_present_val);
                if l_present_val <> nvl(l_new_val, l_present_val)
                then
                    l_new_val := 'Multiple';
                    l_dummy := per_formula_functions.set_text(p_varable_name, l_new_val);
                end if;
            end if;
         end if;
         return l_dummy;
   end;

   function get_and_push_message(p_application  in VARCHAR2,
                                 p_message      in VARCHAR2,
                                 p_stack_level  in VARCHAR2 default 'A',
                                 p_token_name1  in VARCHAR2 default null,
                                 p_token_value1 in VARCHAR2 default null,
                                 p_token_name2  in VARCHAR2 default null,
                                 p_token_value2 in VARCHAR2 default null,
                                 p_token_name3  in VARCHAR2 default null,
                                 p_token_value3 in VARCHAR2 default null,
                                 p_token_name4  in VARCHAR2 default null,
                                 p_token_value4 in VARCHAR2 default null,
                                 p_token_name5  in VARCHAR2 default null,
                                 p_token_value5 in VARCHAR2 default null) return VARCHAR2
   is
        l_error_str                   VARCHAR2(300);
        l_application_id  Number;
   begin
        --
        -- Keep this code as simple as possible.
        --
        if p_application = 'PER' then
           l_application_id :=  800;
        elsif p_application = 'PAY' then
           l_application_id :=  801;
        else
           select application_id
           into  l_application_id
           from  fnd_application
           where APPLICATION_SHORT_NAME = p_application;
        end if;

        pay_core_utils.push_message(l_application_id, p_message, p_stack_level);
        --
        if p_token_name1 is not null and p_token_value1 is not null
        then
            pay_core_utils.push_token(p_token_name1, p_token_value1);
        end if;
        --
        if  p_token_name2 is not null and p_token_value2 is not null
        then
            pay_core_utils.push_token(p_token_name2, p_token_value2);
        end if;
        --
        if  p_token_name3 is not null and p_token_value3 is not null
        then
            pay_core_utils.push_token(p_token_name3, p_token_value3);
        end if;
        --
        if  p_token_name4 is not null and p_token_value4 is not null
        then
            pay_core_utils.push_token(p_token_name4, p_token_value4);
        end if;
        --
        if  p_token_name5 is not null and p_token_value5 is not null
        then
            pay_core_utils.push_token(p_token_name5, p_token_value5);
        end if;
        --
        -- The above pushed the message into the stack
        -- Now Just return the message to ff : name itself if the text is NULL,
        -- otherwise return the (truncated) message text.
        --
        l_error_str := fffunc.gfm(
                        p_application,
                        p_message,
                        p_token_name1,
                        p_token_value1,
                        p_token_name2,
                        p_token_value2,
                        p_token_name3,
                        p_token_value3,
                        p_token_name4,
                        p_token_value4,
                        p_token_name5,
                        p_token_value5);
        return l_error_str;
   end;

   function get_assignment_number(p_action_id  in number,
                                  p_lowest     in boolean  default false,
                                  p_person_id  in varchar2 default null,
                                  p_emp_ref    in varchar2 default null) return varchar2 is
     l_asg_id  number;
     l_asg_no  varchar2(25);

     cursor asg_id is
     select assignment_id
     from   pay_assignment_actions
     where  assignment_action_id = p_action_id;

     cursor asg_low is
     select min(paa2.assignment_id)
       from pay_assignment_actions paa,
            pay_assignment_actions paa2,
            pay_action_information pai_comp,
            pay_action_information pai_person
      where paa.assignment_action_id = p_action_id
        and paa2.payroll_action_id = paa.payroll_action_id
        and pai_comp.action_context_id = paa2.assignment_action_id
        and pai_comp.action_information_category = 'EMEA PAYROLL INFO'
        and pai_person.action_context_id = paa2.assignment_action_id
        and pai_person.action_information_category = 'ADDRESS DETAILS'
        and pai_person.action_information14 = 'Employee Address'
        and pai_person.action_information1 = p_person_id
        and pai_comp.action_information6 = p_emp_ref;

     cursor asg_no is
     select paa.assignment_number
     from   per_assignments_f paa
     where  paa.assignment_id = l_asg_id
     and    paa.effective_end_date = (select max(paa2.effective_end_date)
                                        from per_assignments_f paa2
                                       where paa2.assignment_id = l_asg_id);

     cursor emp_no is
     select employee_number
     from   per_all_people_f
     where  person_id = p_person_id;

   begin
        if not p_lowest then
           open asg_id;
           fetch asg_id into l_asg_id;
           close asg_id;
        else
           open asg_low;
           fetch asg_low into l_asg_id;
           close asg_low;
        end if;

        open asg_no;
        fetch asg_no into l_asg_no;
        close asg_no;

        if l_asg_no is null then
           open emp_no;
           fetch emp_no into l_asg_no;
           close emp_no;
        end if;
        return l_asg_no;
   end;


   function fetch_p11d_rep_data(p_assignment_action_id NUMBER) return l_typ_p11d_fields_rec
   is
        l_h_ce      VARCHAR2(10);
        l_h_count   NUMBER;
        l_f_count   NUMBER;
        l_pactid    NUMBER;
        l_rep_run   VARCHAR2(10);
        l_p11d_fields l_typ_p11d_fields_rec;
        l_h_sum_max_amt_outstanding  number;

        procedure populate_stored_fields is
        begin
             -- populating the person id
             select action_information1
             into  g_person_id
             from  pay_action_information pai_person
             where pai_person.action_context_id = p_assignment_action_id
             and   pai_person.action_information_category = 'ADDRESS DETAILS'
             and   pai_person.action_context_type = 'AAP'
             and   pai_person.action_information14 = 'Employee Address';

             select action_information6,
                    action_information7
             into  g_emp_ref_no,
                   g_employer_name
             from  pay_action_information pai_comp
             where pai_comp.action_context_id = p_assignment_action_id
             and   pai_comp.action_context_type = 'AAP'
             and   pai_comp.action_information_category = 'EMEA PAYROLL INFO';

             l_p11d_fields.employers_ref_no := g_emp_ref_no;
             l_p11d_fields.employers_name   := replace(g_employer_name,'&','&amp;');
             hr_utility.trace('l_p11d_fields.employers_name' || l_p11d_fields.employers_name);

             select decode(action_information4, 'Y', 'Y', 'N'),
                    action_information8, -- P11D changes 07/08 last_name
                    action_information6, -- P11D changes 07/08 first_name
                    substr(action_information15,9,2) ||
                    substr(action_information15,6,2) ||
                    substr(action_information15,1,4),
                    action_information17
             into  l_p11d_fields.director_flag,
                   l_p11d_fields.sur_name,
                   l_p11d_fields.fore_name,
                   l_p11d_fields.date_of_birth,
                   l_p11d_fields.gender
             from  pay_action_information pai_gb
             where pai_gb.action_context_id = p_assignment_action_id
             and   pai_gb.action_context_type = 'AAP'
             and   pai_gb.action_information_category = 'GB EMPLOYEE DETAILS';
             --
             select action_information1,
                    action_information4,
                    action_information10 -- emp number
                -- action_information14 -- assign num
             into  l_p11d_fields.full_name,
                   l_p11d_fields.national_ins_no,
                   l_p11d_fields.employee_number
             from  pay_action_information pai_emp
             where pai_emp.action_context_id = p_assignment_action_id
             and   pai_emp.action_context_type = 'AAP'
             and   pai_emp.action_information_category = 'EMPLOYEE DETAILS';

             l_p11d_fields.employee_number := get_assignment_number(p_assignment_action_id, true, g_person_id, g_emp_ref_no);

             select payroll_action_id
             into  l_pactid
             from  pay_assignment_actions
             where assignment_action_id = p_assignment_action_id;

             PAY_GB_P11D_ARCHIVE_SS.get_parameters(p_payroll_action_id => l_pactid,
                                                   p_token_name        => 'Rep_Run',
                                                   p_token_value       => l_rep_run);

             if to_number(l_rep_run) < 2005
             then
                 select action_information1,
                        decode(action_information2,'0',null,to_char(to_number(action_information2),'FM999,999,990.00')),
                        decode(action_information2,'0',null,to_char(to_number(action_information3),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information4,'0')),'FM999,999,990.00'),
                        action_information5,
                        to_char(to_number(nvl(action_information6,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information7,'0')),'FM999,999,990.00'),
                        decode(action_information8,'0',null,to_char(to_number(action_information8),'FM999,999,990.00')),
                        decode(action_information8,'0',null,to_char(to_number(action_information9),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information10,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information11,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information12,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information13,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information14,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information15,'0')),'FM999,999,990.00'),
                        decode(action_information16,'0',null,to_char(to_number(action_information16),'FM999,999,990.00')),
                        decode(action_information16,'0',null,to_char(to_number(action_information17),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information18,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information19,'0')),'FM999,999,990.00'),
                        decode(action_information20,'0',null,to_char(to_number(action_information20),'FM999,999,990.00')),
                        decode(action_information20,'0',null,to_char(to_number(action_information21),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information22,'0')),'FM999,999,990.00'),
                        action_information23,
                        decode(action_information24,'0',null,to_char(to_number(action_information24),'FM999,999,990.00')),
                        decode(action_information24,'0',null,to_char(to_number(action_information25),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information26,'0')),'FM999,999,990.00'),
                        decode(action_information27, 'Y', 'Y', 'N'),
                        to_char(to_number(nvl(action_information28,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information29,'0')),'FM999,999,990.00'),
                        action_information30
                 into   l_p11d_fields.a_desc, l_p11d_fields.a_cost, l_p11d_fields.a_amg,
                        l_p11d_fields.a_ce, l_p11d_fields.b_desc, l_p11d_fields.b_ce,
                        l_p11d_fields.b_tnp, l_p11d_fields.c_cost, l_p11d_fields.c_amg,
                        l_p11d_fields.c_ce, l_p11d_fields.d_ce, l_p11d_fields.e_ce,
                        l_p11d_fields.f_tcce, l_p11d_fields.f_tfce, l_p11d_fields.g_ce,
                        l_p11d_fields.i_cost, l_p11d_fields.i_amg, l_p11d_fields.i_ce,
                        l_p11d_fields.j_ce, l_p11d_fields.k_cost, l_p11d_fields.k_amg,
                        l_p11d_fields.k_ce, l_p11d_fields.l_desc, l_p11d_fields.l_cost,
                        l_p11d_fields.l_amg, l_p11d_fields.l_ce, l_p11d_fields.m_shares,
                        l_h_ce, l_h_count, l_f_count
                 from   pay_action_information pai_emp
                 where  pai_emp.action_context_id = p_assignment_action_id
                 and    pai_emp.action_context_type = 'AAP'
                 and    pai_emp.action_information_category = 'GB P11D ASSIGNMENT RESULTA';

                 select action_information1,
                        decode(action_information2,'0',null,to_char(to_number(action_information2),'FM999,999,990.00')),
                        decode(action_information2,'0',null,to_char(to_number(action_information3),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information4,'0')),'FM999,999,990.00'),
                        action_information5,
                        decode(action_information6,'0',null,to_char(to_number(action_information6),'FM999,999,990.00')),
                        decode(action_information6,'0',null,to_char(to_number(action_information7),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information8,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information9,'0')),'FM999,999,990.00'),
                        decode(action_information10,'0',null,to_char(to_number(action_information10),'FM999,999,990.00')),
                        decode(action_information10,'0',null,to_char(to_number(action_information11),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information12,'0')),'FM999,999,990.00'),
                        decode(action_information13,'0',null,to_char(to_number(action_information13),'FM999,999,990.00')),
                        decode(action_information13,'0',null,to_char(to_number(action_information14),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information15,'0')),'FM999,999,990.00'),
                        decode(action_information16, 'Y', 'Y', 'N'),
                        decode(action_information17,'0',null,to_char(to_number(action_information17),'FM999,999,990.00')),
                        decode(action_information17,'0',null,to_char(to_number(action_information18),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information19,'0')),'FM999,999,990.00'),
                        decode(action_information20,'0',null,to_char(to_number(action_information20),'FM999,999,990.00')),
                        decode(action_information20,'0',null,to_char(to_number(action_information21),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information22,'0')),'FM999,999,990.00'),
                        decode(action_information23,'0',null,to_char(to_number(action_information23),'FM999,999,990.00')),
                        decode(action_information23,'0',null,to_char(to_number(action_information24),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information25,'0')),'FM999,999,990.00'),
                        action_information26,
                        decode(action_information27,'0',null,to_char(to_number(action_information27),'FM999,999,990.00')),
                        decode(action_information27,'0',null,to_char(to_number(action_information28),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information29,'0')),'FM999,999,990.00')
                 into   l_p11d_fields.n_desc, l_p11d_fields.n_cost, l_p11d_fields.n_amg,
                        l_p11d_fields.n_ce, l_p11d_fields.na_desc, l_p11d_fields.na_cost,
                        l_p11d_fields.na_amg, l_p11d_fields.na_ce,
                        l_p11d_fields.n_taxpaid, l_p11d_fields.o1_cost,
                        l_p11d_fields.o1_amg, l_p11d_fields.o1_ce, l_p11d_fields.o2_cost,
                        l_p11d_fields.o2_amg, l_p11d_fields.o2_ce,
                        l_p11d_fields.o_toi,
                        l_p11d_fields.o3_cost, l_p11d_fields.o3_amg, l_p11d_fields.o3_ce,
                        l_p11d_fields.o4_cost, l_p11d_fields.o4_amg, l_p11d_fields.o4_ce,
                        l_p11d_fields.o5_cost, l_p11d_fields.o5_amg, l_p11d_fields.o5_ce,
                        l_p11d_fields.o6_desc, l_p11d_fields.o6_cost,
                        l_p11d_fields.o6_amg, l_p11d_fields.o6_ce
                 from   pay_action_information pai_emp
                 where  pai_emp.action_context_id = p_assignment_action_id
                 and    pai_emp.action_context_type = 'AAP'
                 and    pai_emp.action_information_category = 'GB P11D ASSIGNMENT RESULTB';

                 hr_utility.trace('Fetching from Result C');
                 select substr(action_information10,9,2) || ' ' ||
                        substr(action_information10,6,2) || ' ' ||
                        substr(action_information10,1,4) ,
                        decode (action_information11,null,'N','Y'),to_number(nvl(ACTION_INFORMATION23,'0'))
                 into  l_p11d_fields.f_date_free,l_p11d_fields.f_rein_yr,
                       l_h_sum_max_amt_outstanding
                 from  pay_action_information pai_emp
                 where pai_emp.action_context_id = p_assignment_action_id
                 and   pai_emp.action_context_type = 'AAP'
                 and   pai_emp.action_information_category = 'GB P11D ASSIGNMENT RESULTC';

             ELSE  /* For year 04/05 onwards */
                 select action_information1,
                        decode(action_information2,'0',null,to_char(to_number(action_information2),'FM999,999,990.00')),
                        decode(action_information2,'0',null,to_char(to_number(action_information3),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information4,'0')),'FM999,999,990.00'),
                        action_information5,
                        to_char(to_number(nvl(action_information6,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information7,'0')),'FM999,999,990.00'),
                        decode(action_information8,'0',null,to_char(to_number(action_information8),'FM999,999,990.00')),
                        decode(action_information8,'0',null,to_char(to_number(action_information9),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information10,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information11,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information12,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information13,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information14,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information15,'0')),'FM999,999,990.00'),
                        decode(action_information16,'0',null,to_char(to_number(action_information16),'FM999,999,990.00')),
                        decode(action_information16,'0',null,to_char(to_number(action_information17),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information18,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information19,'0')),'FM999,999,990.00'),
                        decode(action_information20,'0',null,to_char(to_number(action_information20),'FM999,999,990.00')),
                        decode(action_information20,'0',null,to_char(to_number(action_information21),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information22,'0')),'FM999,999,990.00'),
                        action_information23,
                        decode(action_information24,'0',null,to_char(to_number(action_information26) + to_number(action_information25),'FM999,999,990.00')), --Changed for bug 8204969
                        decode(action_information24,'0',null,to_char(to_number(action_information25),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information26,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information28,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information29,'0')),'FM999,999,990.00'),
                        action_information30
                 into   l_p11d_fields.a_desc, l_p11d_fields.a_cost, l_p11d_fields.a_amg,
                        l_p11d_fields.a_ce, l_p11d_fields.b_desc, l_p11d_fields.b_ce,
                        l_p11d_fields.b_tnp, l_p11d_fields.c_cost, l_p11d_fields.c_amg,
                        l_p11d_fields.c_ce, l_p11d_fields.d_ce, l_p11d_fields.e_ce,
                        l_p11d_fields.f_tcce, l_p11d_fields.f_tfce, l_p11d_fields.g_ce,
                        l_p11d_fields.i_cost, l_p11d_fields.i_amg, l_p11d_fields.i_ce,
                        l_p11d_fields.j_ce, l_p11d_fields.k_cost, l_p11d_fields.k_amg,
                        l_p11d_fields.k_ce, l_p11d_fields.l_desc, l_p11d_fields.l_cost,
                        l_p11d_fields.l_amg, l_p11d_fields.l_ce,
                        l_h_ce, l_h_count, l_f_count
                 from   pay_action_information pai_emp
                 where  pai_emp.action_context_id = p_assignment_action_id
                 and    pai_emp.action_context_type = 'AAP'
                 and    pai_emp.action_information_category = 'GB P11D ASSIGNMENT RESULTA';

                 select action_information1,
                        decode(action_information2,'0',null,to_char(to_number(action_information2),'FM999,999,990.00')),
                        decode(action_information2,'0',null,to_char(to_number(action_information3),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information4,'0')),'FM999,999,990.00'),
                        action_information5,
                        decode(action_information6,'0',null,to_char(to_number(action_information6),'FM999,999,990.00')),
                        decode(action_information6,'0',null,to_char(to_number(action_information7),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information8,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information9,'0')),'FM999,999,990.00'),
                        decode(action_information10,'0',null,to_char(to_number(action_information10),'FM999,999,990.00')),
                        decode(action_information10,'0',null,to_char(to_number(action_information11),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information12,'0')),'FM999,999,990.00'),
                        decode(action_information13,'0',null,to_char(to_number(action_information13),'FM999,999,990.00')),
                        decode(action_information13,'0',null,to_char(to_number(action_information14),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information15,'0')),'FM999,999,990.00'),
                        decode(action_information16, 'Y', 'Y', 'N'),
                        decode(action_information17,'0',null,to_char(to_number(action_information17),'FM999,999,990.00')),
                        decode(action_information17,'0',null,to_char(to_number(action_information18),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information19,'0')),'FM999,999,990.00'),
                        decode(action_information20,'0',null,to_char(to_number(action_information20),'FM999,999,990.00')),
                        decode(action_information20,'0',null,to_char(to_number(action_information21),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information22,'0')),'FM999,999,990.00'),
                        decode(action_information23,'0',null,to_char(to_number(action_information23),'FM999,999,990.00')),
                        decode(action_information23,'0',null,to_char(to_number(action_information24),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information25,'0')),'FM999,999,990.00'),
                        action_information26,
                        decode(action_information27,'0',null,to_char(to_number(action_information27),'FM999,999,990.00')),
                        decode(action_information27,'0',null,to_char(to_number(action_information28),'FM999,999,990.00')),
                        to_char(to_number(nvl(action_information29,'0')),'FM999,999,990.00'),
                        to_char(to_number(nvl(action_information30,'0')),'FM999,999,990.00') -- P11D changes 07/08
                 into   l_p11d_fields.n_desc, l_p11d_fields.n_cost, l_p11d_fields.n_amg,
                        l_p11d_fields.n_ce, l_p11d_fields.na_desc, l_p11d_fields.na_cost,
                        l_p11d_fields.na_amg, l_p11d_fields.na_ce,
                        l_p11d_fields.n_taxpaid, l_p11d_fields.o1_cost,
                        l_p11d_fields.o1_amg, l_p11d_fields.o1_ce, l_p11d_fields.o2_cost,
                        l_p11d_fields.o2_amg, l_p11d_fields.o2_ce,
                        l_p11d_fields.o_toi,
                        l_p11d_fields.o3_cost, l_p11d_fields.o3_amg, l_p11d_fields.o3_ce,
                        l_p11d_fields.o4_cost, l_p11d_fields.o4_amg, l_p11d_fields.o4_ce,
                        l_p11d_fields.o5_cost, l_p11d_fields.o5_amg, l_p11d_fields.o5_ce,
                        l_p11d_fields.o6_desc, l_p11d_fields.o6_cost,
                        l_p11d_fields.o6_amg, l_p11d_fields.o6_ce, l_p11d_fields.g_cef
                 from   pay_action_information pai_emp
                 where  pai_emp.action_context_id = p_assignment_action_id
                 and    pai_emp.action_context_type = 'AAP'
                 and    pai_emp.action_information_category = 'GB P11D ASSIGNMENT RESULTB';

                 hr_utility.trace('Fetching from Result C');
                 select to_number(nvl(ACTION_INFORMATION23,'0'))
                 into   l_h_sum_max_amt_outstanding
                 from   pay_action_information pai_emp
                 where  pai_emp.action_context_id = p_assignment_action_id
                 and    pai_emp.action_context_type = 'AAP'
                 and    pai_emp.action_information_category = 'GB P11D ASSIGNMENT RESULTC';
             end if;

        end;
        procedure populate_car_fields
        is
             cursor csr_car_benefits(p_pactid    NUMBER,
                                     p_person_id VARCHAR2,
                                     p_emp_ref   VARCHAR2,
                                     p_emp_name  VARCHAR2)
             is
             select
                   substr(pai_emp.action_information3,9,2) || ' ' ||
                   substr(pai_emp.action_information3,6,2) || ' ' ||
                   substr(pai_emp.action_information3,1,4) f_start,
                   substr(pai_emp.action_information4,9,2) || ' ' ||
                   substr(pai_emp.action_information4,6,2) || ' ' ||
                   substr(pai_emp.action_information4,1,4) f_end,
                   pai_emp.action_information6 || ' ' ||
                   pai_emp.action_information7 f_make,
                   substr(pai_emp.action_information8,9,2) || ' ' ||
                   substr(pai_emp.action_information8,6,2) || ' ' ||
                   substr(pai_emp.action_information8,1,4) f_dreg,
                   to_char(to_number(pai_emp.action_information9),'FM999,999,990.00') f_lprice,
                   to_char(to_number(pai_emp.action_information10),'FM999,999,990.00') f_cc,
                   to_char(to_number(pai_emp.action_information11),'FM999,999,990.00') f_fcc,
                   decode( pai_emp.action_information12,'0',null,PAY_GB_P11D_MAGTAPE.get_description(
                           pai_emp.action_information12,'GB_FUEL_TYPE',pai_emp.action_information4)) f_fuel,
                   pai_emp.action_information13 f_efig,
                    /* bug 8277887 checking the flag if co2 emisiion is either zero or null */
                   decode(NVL(pai_emp.action_information13,'0'),'0','Y', 'N') f_nfig,
                   to_char(to_number(pai_emp.action_information15),'FM999,999,990.00') f_oprice,
                   to_char(to_number(pai_emp.action_information16),'FM999,999,990.00') f_cost,
                   to_char(to_number(pai_emp.action_information17),'FM999,999,990.00') f_amg,
                   substr(action_information26,9,2) || ' ' ||
                   substr(action_information26,6,2) || ' ' ||
                   substr(action_information26,1,4) f_date_free,
                   decode(action_information27,'Y','Y','N') f_rein_yr,
                   pai_emp.action_information18 f_esize
             from  pay_action_information pai_emp
             where pai_emp.action_information_category = 'CAR AND CAR FUEL 2003_04'
             and   pai_emp.action_context_type = 'AAP'
             and   pai_emp.action_context_id in( select paa.assignment_action_id
                                                 from  pay_action_information pai_comp,
                                                       pay_action_information pai_person,
                                                       pay_assignment_actions paa,
                                                       pay_payroll_actions ppa
                                                 where ppa.payroll_action_id = p_pactid
                                                 and   paa.payroll_action_id = ppa.payroll_action_id
                                                 and   pai_comp.action_context_id = paa.assignment_action_id
                                                 and   pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                                                 and   pai_comp.action_context_type = 'AAP'
                                                 and   pai_person.action_context_id = paa.assignment_action_id
                                                 and   pai_person.action_information_category = 'ADDRESS DETAILS'
                                                 and   pai_person.action_context_type = 'AAP'
                                                 and   pai_person.action_information14 = 'Employee Address'
                                                 and   pai_person.action_information1 = p_person_id
                                                 and   pai_comp.action_information6 = p_emp_ref
                                                 and   pai_comp.action_information7 = p_emp_name)
             order by pai_emp.action_information3 desc, -- ben st dt
                      pai_emp.action_information4 desc, -- ben end dt
                      pai_emp.action_information10 desc, -- cc for car
                      pai_emp.action_information11 desc, -- cc for fuel
                      pai_emp.action_information1 desc, -- ele entrty id
                      pai_emp.action_information2 desc; -- effec date

             l_rec_count         INTEGER := 0;
             l_tax_year_start    varchar2(10);
             l_tax_year_end      varchar2(10);
             l_ben_start         varchar2(10);
             l_ben_end           varchar2(10);
             l_tax_year          varchar2(4);
             l_date_reg          varchar2(10);
        begin
             hr_utility.trace('l_f_count ' || l_f_count);
             if l_f_count > 0
             then
                 hr_utility.trace('l_payroll_action_id ' || g_payroll_action_id);
                 hr_utility.trace('l_person_id ' || g_person_id);
                 l_tax_year := pay_gb_p11d_magtape.get_parameters(g_payroll_action_id,'Rep_Run');
                 l_tax_year_end := l_tax_year || '0405';
                 l_tax_year_start := to_char(to_number(l_tax_year) - 1) || '0406';
                 for car_benefits in csr_car_benefits(g_payroll_action_id,
                                                      g_person_id,
                                                      g_emp_ref_no,
                                                      g_employer_name)
                 loop
                     l_rec_count := l_rec_count + 1;
                     hr_utility.trace('l_rec_count ' || l_rec_count);
                     l_ben_start := car_benefits.f_start;
                     l_ben_end   := car_benefits.f_end;
                     l_ben_start := substr(l_ben_start,7,4) || substr(l_ben_start,4,2) || substr(l_ben_start,1,2);
                     l_ben_end   := substr(l_ben_end,7,4) || substr(l_ben_end,4,2) || substr(l_ben_end,1,2);
                     l_date_reg  := substr(car_benefits.f_dreg,7,4) || substr(car_benefits.f_dreg,4,2) || substr(car_benefits.f_dreg,1,2);
                     if l_rec_count = 1
                     then
                         hr_utility.trace('car_benefits.f_make ' || car_benefits.f_make);
                         hr_utility.trace('l_rec_count in 1 ' || l_rec_count);
                         if to_number(l_ben_start) > to_number(l_tax_year_start)
                         then
                             l_p11d_fields.f1_start := car_benefits.f_start;
                         else
                             l_p11d_fields.f1_start := ' ';
                         end if;
                         if to_number(l_ben_end) < to_number(l_tax_year_end)
                         then
                             l_p11d_fields.f1_end := car_benefits.f_end;
                         else
                             l_p11d_fields.f1_end := ' ';
                         end if;
                        l_p11d_fields.f1_make := car_benefits.f_make;
                        l_p11d_fields.f1_dreg := car_benefits.f_dreg;
                        l_p11d_fields.f1_lprice := car_benefits.f_lprice;
                        l_p11d_fields.f1_cc := car_benefits.f_cc;
                        l_p11d_fields.f1_fcc  := car_benefits.f_fcc;
                        l_p11d_fields.f1_fuel := car_benefits.f_fuel;
                        /* l_p11d_fields.f1_efig := car_benefits.f_efig; */
			 /* added below if else for bug 8277887 */
                        if to_number(nvl(car_benefits.f_efig,0)) > 0 then
                        l_p11d_fields.f1_efig := car_benefits.f_efig;
                        else
                          l_p11d_fields.f1_efig := ' ';
                        end if;
                        l_p11d_fields.f1_nfig := car_benefits.f_nfig;
                        l_p11d_fields.f1_oprice := car_benefits.f_oprice;
                        -- l_p11d_fields.f1_aprice := car_benefits.f_aprice;
                        l_p11d_fields.f1_cost := car_benefits.f_cost;
                        l_p11d_fields.f1_amg := car_benefits.f_amg;
                        if car_benefits.f_esize = '9999' and
                           to_number(l_date_reg) > 19980101 and
                           to_number(nvl(car_benefits.f_efig,0)) > 0 then
                           l_p11d_fields.f1_esize := ' ';
                         else
                          l_p11d_fields.f1_esize := car_benefits.f_esize;
                        end if;
                        l_p11d_fields.f1_date_free := car_benefits.f_date_free;
                        l_p11d_fields.f1_rein_yr := car_benefits.f_rein_yr;
                     elsif l_rec_count = 2
                     then
                         hr_utility.trace('car_benefits.f_make ' || car_benefits.f_make);
                         hr_utility.trace('l_rec_count in 2' || l_rec_count);
                         if to_number(l_ben_start) > to_number(l_tax_year_start)
                         then
                             l_p11d_fields.f2_start := car_benefits.f_start;
                         else
                             l_p11d_fields.f2_start := ' ';
                         end if;
                         if to_number(l_ben_end) < to_number(l_tax_year_end)
                         then
                             l_p11d_fields.f2_end := car_benefits.f_end;
                         else
                             l_p11d_fields.f2_end := ' ';
                         end if;
                         l_p11d_fields.f2_make := car_benefits.f_make;
                         l_p11d_fields.f2_dreg := car_benefits.f_dreg;
                         l_p11d_fields.f2_lprice := car_benefits.f_lprice;
                         l_p11d_fields.f2_cc := car_benefits.f_cc;
                         l_p11d_fields.f2_fcc := car_benefits.f_fcc;
                         l_p11d_fields.f2_fuel := car_benefits.f_fuel;
                        /* l_p11d_fields.f2_efig := car_benefits.f_efig; */
			/* added below if else for bug 8277887 */
                        if to_number(nvl(car_benefits.f_efig,0)) > 0 then
                         l_p11d_fields.f2_efig := car_benefits.f_efig;
                        else
                        l_p11d_fields.f2_efig := ' ';
                        end if;
                         l_p11d_fields.f2_nfig := car_benefits.f_nfig;
                         l_p11d_fields.f2_oprice := car_benefits.f_oprice;
                         --l_p11d_fields.f2_aprice := car_benefits.f_aprice;
                         l_p11d_fields.f2_cost := car_benefits.f_cost;
                         l_p11d_fields.f2_amg := car_benefits.f_amg;
                         if car_benefits.f_esize = '9999' and
                            to_number(l_date_reg) > 19980101 and
                            to_number(nvl(car_benefits.f_efig,0)) > 0 then
                            l_p11d_fields.f2_esize := ' ';
                         else
                            l_p11d_fields.f2_esize := car_benefits.f_esize;
                         end if;
                         l_p11d_fields.f2_date_free := car_benefits.f_date_free;
                         l_p11d_fields.f2_rein_yr := car_benefits.f_rein_yr;
                         exit;
                     end if;
                end loop;
            end if;
        end;

        procedure populate_interest_fields
        is
             cursor csr_int_benefits(p_pactid    NUMBER,
                                     p_person_id VARCHAR2,
                                     p_emp_ref   VARCHAR2,
                                     p_emp_name  VARCHAR2)
             is
             select
                   pai_emp.action_information5 h_njb,
                   to_char(to_number(pai_emp.action_information6),'FM999,999,990.00') h_ayb,
                   to_char(to_number(pai_emp.action_information7),'FM999,999,990.00') h_mao,
                   decode(pai_emp.action_information8,null,'NIL','0','NIL',to_char(to_number(pai_emp.action_information8),'FM999,999,990.00')) h_ip,
                   substr(pai_emp.action_information9,9,2) || decode(pai_emp.action_information9,null,null,' ') ||
                   substr(pai_emp.action_information9,6,2) || decode(pai_emp.action_information9,null,null,' ') ||
                   substr(pai_emp.action_information9,1,4) h_dlm,
                   substr(pai_emp.action_information10,9,2) ||decode(pai_emp.action_information10,null,null,' ') ||
                   substr(pai_emp.action_information10,6,2) ||decode(pai_emp.action_information10,null,null,' ') ||
                   substr(pai_emp.action_information10,1,4) h_dld,
                   to_char(to_number(nvl(pai_emp.action_information11,'0')),'FM999,999,990.00') h_ce,
                   to_char(to_number(nvl(pai_emp.action_information16,'0')),'FM999,999,990.00') h_aye
             from  pay_action_information pai_emp
             where pai_emp.action_information_category = 'INT FREE AND LOW INT LOANS'
             and   pai_emp.action_context_type = 'AAP'
             and   pai_emp.action_context_id in ( select paa.assignment_action_id
                                                  from   pay_action_information pai_comp,
                                                         pay_action_information pai_person,
                                                         pay_assignment_actions paa,
                                                         pay_payroll_actions ppa
                                                   where ppa.payroll_action_id = p_pactid
                                                   and   paa.payroll_action_id = ppa.payroll_action_id
                                                   and   pai_comp.action_context_id = paa.assignment_action_id
                                                   and   pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                                                   and   pai_comp.action_context_type = 'AAP'
                                                   and   pai_person.action_context_id = paa.assignment_action_id
                                                   and   pai_person.action_information_category = 'ADDRESS DETAILS'
                                                   and   pai_person.action_context_type = 'AAP'
                                                   and   pai_person.action_information14 = 'Employee Address'
                                                   and   pai_person.action_information1 = p_person_id
                                                   and   pai_comp.action_information6 = p_emp_ref
                                                   and   pai_comp.action_information7 = p_emp_name)
             and   to_number(nvl(pai_emp.action_information11,'0')) > 0 -- report only int free lons where CE is greater than 0
             order by pai_emp.action_information3, -- ben st dt
                      pai_emp.action_information4, -- ben end dt
                      pai_emp.action_information9, -- dt loan made
                      pai_emp.action_information10, -- dt loan disc
                      pai_emp.action_information11, -- cc
                      pai_emp.action_information1, -- ele entrty id
                      pai_emp.action_information2; -- effec date
             l_rec_count         INTEGER := 0;
        begin
             hr_utility.trace('l_h_count ' || l_h_count);
             hr_utility.trace('max outstd ' || l_h_sum_max_amt_outstanding);
             if l_h_count > 2  and
             -- Added this extra and condition for 3558538
             -- this will ensure that only int free lons where CE is greater than 0
             -- are reported
                 l_h_sum_max_amt_outstanding > 5000
             then
                 l_p11d_fields.h2_ce := 'See Attached';
                 l_p11d_fields.h1_ce := l_h_ce;
                 hr_utility.trace('See att ' );
             elsif l_h_count > 0  and
             -- Added this extra and condition for 3558538
             -- this will ensure that only int free lons where CE is greater than 0
             -- are reported
                 l_h_sum_max_amt_outstanding > 5000
             then
                 hr_utility.trace('l_payroll_action_id ' || g_payroll_action_id);
                 hr_utility.trace('l_person_id ' || g_person_id);
                 for int_benefits in csr_int_benefits(g_payroll_action_id,
                                                      g_person_id,
                                                      g_emp_ref_no,
                                                      g_employer_name)
                 loop
                     l_rec_count := l_rec_count + 1;
                     hr_utility.trace('l_rec_count ' || l_rec_count);
                     if l_rec_count = 1
                     then
                         hr_utility.trace('int_benefits.h_njb ' || int_benefits.h_njb);
                         l_p11d_fields.h1_njb := int_benefits.h_njb;
                         l_p11d_fields.h1_ayb := int_benefits.h_ayb;
                         l_p11d_fields.h1_mao := int_benefits.h_mao;
                         l_p11d_fields.h1_ip := int_benefits.h_ip;
                         l_p11d_fields.h1_dlm := int_benefits.h_dlm;
                         l_p11d_fields.h1_dld := int_benefits.h_dld;
                         l_p11d_fields.h1_ce := int_benefits.h_ce;
                         l_p11d_fields.h1_aye := int_benefits.h_aye;
                      elsif l_rec_count = 2
                      then
                         hr_utility.trace('int_benefits.h_njb ' || int_benefits.h_njb);
                         l_p11d_fields.h2_njb := int_benefits.h_njb;
                         l_p11d_fields.h2_ayb := int_benefits.h_ayb;
                         l_p11d_fields.h2_mao := int_benefits.h_mao;
                         l_p11d_fields.h2_ip := int_benefits.h_ip;
                         l_p11d_fields.h2_dlm := int_benefits.h_dlm;
                         l_p11d_fields.h2_dld := int_benefits.h_dld;
                         l_p11d_fields.h2_ce := int_benefits.h_ce;
                         l_p11d_fields.h2_aye := int_benefits.h_aye;
                         exit;
                      end if;
                 end loop;
             end if;
        end;
   begin
        hr_utility.trace('Inside fetch p11d rep_data p_assignment_action_id' || p_assignment_action_id);
        select payroll_action_id
        into  g_payroll_action_id
        from  pay_assignment_actions
        where assignment_action_id = p_assignment_action_id;

        hr_utility.trace('g_payroll_action_id ' || g_payroll_action_id);
        populate_stored_fields;
        hr_utility.trace('Calling populate car fields ' );
        populate_car_fields;
        hr_utility.trace('Calling interest fields ' );
        populate_interest_fields;
        return l_p11d_fields;
   end;
--
   function fetch_p11d_rep_data_blob(p_assignment_action_id Number) return BLOB
   is

        l_p11d_fields l_typ_p11d_fields_rec;
        l_xfdf_string varchar2(31000);
        l_xfdf_clob   CLOB;
        l_xfdf_blob   BLOB;
        l_rep_run     VARCHAR2(10);
        l_pactid      NUMBER;

   begin

        hr_utility.trace('p_assignment_action_id ' || p_assignment_action_id);
        l_p11d_fields := fetch_p11d_rep_data(p_assignment_action_id);

        select payroll_action_id
        into   l_pactid
        from   pay_assignment_actions
        where  assignment_action_id = p_assignment_action_id;

        PAY_GB_P11D_ARCHIVE_SS.get_parameters(p_payroll_action_id  => l_pactid,
                                              p_token_name         => 'Rep_Run',
                                              p_token_value        => l_rep_run);

        if to_number(l_rep_run) < 2005
        then
            l_xfdf_string := '<?xml version = "1.0" encoding = "UTF-8"?>
            <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
            <fields> ' ||
            ' <field name="'|| 'DIRECTOR_FLAG'   ||'"><value>' ||    l_p11d_fields.DIRECTOR_FLAG       || '</value></field> ' ||
            ' <field name="'|| 'FULL_NAME'       ||'"><value>' ||    l_p11d_fields.FULL_NAME           || '</value></field> ' ||
            ' <field name="'|| 'EMPLOYEE_NUMBER' ||'"><value>' ||    l_p11d_fields.EMPLOYEE_NUMBER     || '</value></field> ' ||
            ' <field name="'|| 'NATIONAL_INS_NO' ||'"><value>' ||    l_p11d_fields.NATIONAL_INS_NO     || '</value></field> ' ||
            ' <field name="'|| 'EMPLOYERS_REF_NO'||'"><value>' ||    l_p11d_fields.EMPLOYERS_REF_NO    || '</value></field> ' ||
            ' <field name="'|| 'EMPLOYERS_NAME'  ||'"><value>' ||    l_p11d_fields.EMPLOYERS_NAME      || '</value></field> ' ||
            ' <field name="'|| 'A_DESC'          ||'"><value>' ||    l_p11d_fields.A_DESC              || '</value></field> ' ||
            ' <field name="'|| 'A_COST'          ||'"><value>' ||    l_p11d_fields.A_COST              || '</value></field> ' ||
            ' <field name="'|| 'A_AMG'           ||'"><value>' ||    l_p11d_fields.A_AMG               || '</value></field> ' ||
            ' <field name="'|| 'A_CE'            ||'"><value>' ||    l_p11d_fields.A_CE                || '</value></field> ' ||
            ' <field name="'|| 'B_DESC'          ||'"><value>' ||    l_p11d_fields.B_DESC              || '</value></field> ' ||
            ' <field name="'|| 'B_CE'            ||'"><value>' ||    l_p11d_fields.B_CE                || '</value></field> ' ||
            ' <field name="'|| 'B_TNP'           ||'"><value>' ||    l_p11d_fields.B_TNP               || '</value></field> ' ||
            ' <field name="'|| 'C_COST'          ||'"><value>' ||    l_p11d_fields.C_COST              || '</value></field> ' ||
            ' <field name="'|| 'C_AMG'           ||'"><value>' ||    l_p11d_fields.C_AMG               || '</value></field> ' ||
            ' <field name="'|| 'C_CE'            ||'"><value>' ||    l_p11d_fields.C_CE                || '</value></field> ' ||
            ' <field name="'|| 'D_CE'            ||'"><value>' ||    l_p11d_fields.D_CE                || '</value></field> ' ||
            ' <field name="'|| 'E_CE'            ||'"><value>' ||    l_p11d_fields.E_CE                || '</value></field> ' ||
            ' <field name="'|| 'F1_MAKE'         ||'"><value>' ||    l_p11d_fields.F1_MAKE             || '</value></field> ' ||
            ' <field name="'|| 'F1_DREG1'        ||'"><value>' ||   substr(l_p11d_fields.F1_DREG,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'F1_DREG2'        ||'"><value>' ||   substr(l_p11d_fields.F1_DREG,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'F1_DREG3'        ||'"><value>' ||   substr(l_p11d_fields.F1_DREG,7)    || '</value></field> ' ||
            ' <field name="'|| 'F1_EFIG'         ||'"><value>' ||    l_p11d_fields.F1_EFIG             || '</value></field> ' ||
            ' <field name="'|| 'F1_NFIG'         ||'"><value>' ||    l_p11d_fields.F1_NFIG             || '</value></field> ' ||
            ' <field name="'|| 'F1_ESIZE'        ||'"><value>' ||    l_p11d_fields.F1_ESIZE            || '</value></field> ' ||
            ' <field name="'|| 'F1_FUEL'         ||'"><value>' ||    l_p11d_fields.F1_FUEL             || '</value></field> ' ||
            ' <field name="'|| 'F1_START1'       ||'"><value>' ||   substr(l_p11d_fields.F1_START,0,2) || '</value></field> ' ||
            ' <field name="'|| 'F1_START2'       ||'"><value>' ||   substr(l_p11d_fields.F1_START,4,2) || '</value></field> ' ||
            ' <field name="'|| 'F1_START3'       ||'"><value>' ||   substr(l_p11d_fields.F1_START,7)   || '</value></field> ' ||
            ' <field name="'|| 'F1_END1'         ||'"><value>' ||   substr(l_p11d_fields.F1_END,0,2)   || '</value></field> ' ||
            ' <field name="'|| 'F1_END2'         ||'"><value>' ||   substr(l_p11d_fields.F1_END,4,2)   || '</value></field> ' ||
            ' <field name="'|| 'F1_END3'         ||'"><value>' ||   substr(l_p11d_fields.F1_END,7)     || '</value></field> ' ||
            ' <field name="'|| 'F1_LPRICE'       ||'"><value>' ||    l_p11d_fields.F1_LPRICE           || '</value></field> ' ||
            ' <field name="'|| 'F1_OPRICE'       ||'"><value>' ||    l_p11d_fields.F1_OPRICE           || '</value></field> ' ||
       --   ' <field name="'|| 'F1_APRICE'       ||'"><value>' ||    l_p11d_fields.F1_APRICE           || '</value></field> ' ||
            ' <field name="'|| 'F1_COST'         ||'"><value>' ||    l_p11d_fields.F1_COST             || '</value></field> ' ||
            ' <field name="'|| 'F1_AMG'          ||'"><value>' ||    l_p11d_fields.F1_AMG              || '</value></field> ' ||
            ' <field name="'|| 'F1_CC'           ||'"><value>' ||    l_p11d_fields.F1_CC               || '</value></field> ' ||
            ' <field name="'|| 'F1_FCC'          ||'"><value>' ||    l_p11d_fields.F1_FCC              || '</value></field> ' ||
            ' <field name="'|| 'F2_MAKE'         ||'"><value>' ||    l_p11d_fields.F2_MAKE             || '</value></field> ' ||
            ' <field name="'|| 'F2_DREG1'        ||'"><value>' ||   substr(l_p11d_fields.F2_DREG,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'F2_DREG2'        ||'"><value>' ||   substr(l_p11d_fields.F2_DREG,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'F2_DREG3'        ||'"><value>' ||   substr(l_p11d_fields.F2_DREG,7)    || '</value></field> ' ||
            ' <field name="'|| 'F2_EFIG'         ||'"><value>' ||    l_p11d_fields.F2_EFIG             || '</value></field> ' ||
            ' <field name="'|| 'F2_NFIG'         ||'"><value>' ||    l_p11d_fields.F2_NFIG             || '</value></field> ' ||
            ' <field name="'|| 'F2_ESIZE'        ||'"><value>' ||    l_p11d_fields.F2_ESIZE            || '</value></field> ' ||
            ' <field name="'|| 'F2_FUEL'         ||'"><value>' ||    l_p11d_fields.F2_FUEL             || '</value></field> ' ||
            ' <field name="'|| 'F2_START1'       ||'"><value>' ||   substr(l_p11d_fields.F2_START,0,2) || '</value></field> ' ||
            ' <field name="'|| 'F2_START2'       ||'"><value>' ||   substr(l_p11d_fields.F2_START,4,2) || '</value></field> ' ||
            ' <field name="'|| 'F2_START3'       ||'"><value>' ||   substr(l_p11d_fields.F2_START,7)   || '</value></field> ' ||
            ' <field name="'|| 'F2_END1'         ||'"><value>' ||   substr(l_p11d_fields.F2_END,0,2)   || '</value></field> ' ||
            ' <field name="'|| 'F2_END2'         ||'"><value>' ||   substr(l_p11d_fields.F2_END,4,2)   || '</value></field> ' ||
            ' <field name="'|| 'F2_END3'         ||'"><value>' ||   substr(l_p11d_fields.F2_END,7)     || '</value></field> ' ||
            ' <field name="'|| 'F2_LPRICE'       ||'"><value>' ||    l_p11d_fields.F2_LPRICE           || '</value></field> ' ||
            ' <field name="'|| 'F2_OPRICE'       ||'"><value>' ||    l_p11d_fields.F2_OPRICE           || '</value></field> ' ||
            ' <field name="'|| 'F2_APRICE'       ||'"><value>' ||    l_p11d_fields.F2_APRICE           || '</value></field> ' ||
            ' <field name="'|| 'F2_COST'         ||'"><value>' ||    l_p11d_fields.F2_COST             || '</value></field> ' ||
            ' <field name="'|| 'F2_AMG'          ||'"><value>' ||    l_p11d_fields.F2_AMG              || '</value></field> ' ||
            ' <field name="'|| 'F2_CC'           ||'"><value>' ||    l_p11d_fields.F2_CC               || '</value></field> ' ||
            ' <field name="'|| 'F2_FCC'          ||'"><value>' ||    l_p11d_fields.F2_FCC              || '</value></field> ' ||
            ' <field name="'|| 'F_DATE_FREE1'    ||'"><value>' ||    substr(l_p11d_fields.F_DATE_FREE,0,2) || '</value></field> ' ||
            ' <field name="'|| 'F_DATE_FREE2'    ||'"><value>' ||    substr(l_p11d_fields.F_DATE_FREE,4,2) || '</value></field> ' ||
            ' <field name="'|| 'F_DATE_FREE3'    ||'"><value>' ||    substr(l_p11d_fields.F_DATE_FREE,7)   || '</value></field> ' ||
            ' <field name="'|| 'F_REIN_YR'       ||'"><value>' ||    l_p11d_fields.F_REIN_YR           || '</value></field> ' ||
            ' <field name="'|| 'F_TCCE'          ||'"><value>' ||    l_p11d_fields.F_TCCE              || '</value></field> ' ||
            ' <field name="'|| 'F_TFCE'          ||'"><value>' ||    l_p11d_fields.F_TFCE              || '</value></field> ' ||
            ' <field name="'|| 'G_CE'            ||'"><value>' ||    l_p11d_fields.G_CE                || '</value></field> ' ||
            ' <field name="'|| 'H1_NJB'          ||'"><value>' ||    l_p11d_fields.H1_NJB              || '</value></field> ' ||
            ' <field name="'|| 'H1_AYB'          ||'"><value>' ||    l_p11d_fields.H1_AYB              || '</value></field> ' ||
            ' <field name="'|| 'H1_AYE'          ||'"><value>' ||    l_p11d_fields.H1_AYE              || '</value></field> ' ||
            ' <field name="'|| 'H1_MAO'          ||'"><value>' ||    l_p11d_fields.H1_MAO              || '</value></field> ' ||
            ' <field name="'|| 'H1_IP'           ||'"><value>' ||    l_p11d_fields.H1_IP               || '</value></field> ' ||
            ' <field name="'|| 'H1_DLM1'         ||'"><value>' ||    substr(l_p11d_fields.H1_DLM,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLM2'         ||'"><value>' ||    substr(l_p11d_fields.H1_DLM,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLM3'         ||'"><value>' ||    substr(l_p11d_fields.H1_DLM,7)    || '</value></field> ' ||
            ' <field name="'|| 'H1_DLD1'         ||'"><value>' ||    substr(l_p11d_fields.H1_DLD,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLD2'         ||'"><value>' ||    substr(l_p11d_fields.H1_DLD,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLD3'         ||'"><value>' ||    substr(l_p11d_fields.H1_DLD,7)    || '</value></field> ' ||
            ' <field name="'|| 'H1_CE'           ||'"><value>' ||    nvl(l_p11d_fields.H1_CE,'0.00')   || '</value></field> ' ||
            ' <field name="'|| 'H2_NJB'          ||'"><value>' ||    l_p11d_fields.H2_NJB              || '</value></field> ' ||
            ' <field name="'|| 'H2_AYB'          ||'"><value>' ||    l_p11d_fields.H2_AYB              || '</value></field> ' ||
            ' <field name="'|| 'H2_AYE'          ||'"><value>' ||    l_p11d_fields.H2_AYE              || '</value></field> ' ||
            ' <field name="'|| 'H2_MAO'          ||'"><value>' ||    l_p11d_fields.H2_MAO              || '</value></field> ' ||
            ' <field name="'|| 'H2_IP'           ||'"><value>' ||    l_p11d_fields.H2_IP               || '</value></field> ' ||
            ' <field name="'|| 'H2_DLM1'         ||'"><value>' ||    substr(l_p11d_fields.H2_DLM,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLM2'         ||'"><value>' ||    substr(l_p11d_fields.H2_DLM,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLM3'         ||'"><value>' ||    substr(l_p11d_fields.H2_DLM,7)    || '</value></field> ' ||
            ' <field name="'|| 'H2_DLD1'         ||'"><value>' ||    substr(l_p11d_fields.H2_DLD,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLD2'         ||'"><value>' ||    substr(l_p11d_fields.H2_DLD,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLD3'         ||'"><value>' ||    substr(l_p11d_fields.H2_DLD,7)    || '</value></field> ' ||
            ' <field name="'|| 'H2_CE'           ||'"><value>' ||    nvl(l_p11d_fields.H2_CE,'0.00')   || '</value></field> ' ||
            ' <field name="'|| 'I_COST'          ||'"><value>' ||    l_p11d_fields.I_COST              || '</value></field> ' ||
            ' <field name="'|| 'I_AMG'           ||'"><value>' ||    l_p11d_fields.I_AMG               || '</value></field> ' ||
            ' <field name="'|| 'I_CE'            ||'"><value>' ||    l_p11d_fields.I_CE                || '</value></field> ' ||
            ' <field name="'|| 'J_CE'            ||'"><value>' ||    l_p11d_fields.J_CE                || '</value></field> ' ||
            ' <field name="'|| 'K_COST'          ||'"><value>' ||    l_p11d_fields.K_COST              || '</value></field> ' ||
            ' <field name="'|| 'K_AMG'           ||'"><value>' ||    l_p11d_fields.K_AMG               || '</value></field> ' ||
            ' <field name="'|| 'K_CE'            ||'"><value>' ||    l_p11d_fields.K_CE                || '</value></field> ' ||
            ' <field name="'|| 'L_DESC'          ||'"><value>' ||    l_p11d_fields.L_DESC              || '</value></field> ' ||
            ' <field name="'|| 'L_COST'          ||'"><value>' ||    l_p11d_fields.L_COST              || '</value></field> ' ||
            ' <field name="'|| 'L_AMG'           ||'"><value>' ||    l_p11d_fields.L_AMG               || '</value></field> ' ||
            ' <field name="'|| 'L_CE'            ||'"><value>' ||    l_p11d_fields.L_CE                || '</value></field> ' ||
            ' <field name="'|| 'M_SHARES'        ||'"><value>' ||    l_p11d_fields.M_SHARES            || '</value></field> ' ||
            ' <field name="'|| 'N_COST'          ||'"><value>' ||    l_p11d_fields.N_COST              || '</value></field> ' ||
            ' <field name="'|| 'N_AMG'           ||'"><value>' ||    l_p11d_fields.N_AMG               || '</value></field> ' ||
            ' <field name="'|| 'N_CE'            ||'"><value>' ||    l_p11d_fields.N_CE                || '</value></field> ' ||
            ' <field name="'|| 'N_DESC'          ||'"><value>' ||    replace(l_p11d_fields.N_DESC,'&','&amp;')              || '</value></field> ' ||
            ' <field name="'|| 'NA_COST'         ||'"><value>' ||    l_p11d_fields.NA_COST             || '</value></field> ' ||
            ' <field name="'|| 'NA_AMG'          ||'"><value>' ||    l_p11d_fields.NA_AMG              || '</value></field> ' ||
            ' <field name="'|| 'NA_CE'           ||'"><value>' ||    l_p11d_fields.NA_CE               || '</value></field> ' ||
            ' <field name="'|| 'NA_DESC'         ||'"><value>' ||    l_p11d_fields.NA_DESC             || '</value></field> ' ||
            ' <field name="'|| 'N_TAXPAID'       ||'"><value>' ||    l_p11d_fields.N_TAXPAID           || '</value></field> ' ||
            ' <field name="'|| 'O1_COST'         ||'"><value>' ||    l_p11d_fields.O1_COST             || '</value></field> ' ||
            ' <field name="'|| 'O1_AMG'          ||'"><value>' ||    l_p11d_fields.O1_AMG              || '</value></field> ' ||
            ' <field name="'|| 'O1_CE'           ||'"><value>' ||    l_p11d_fields.O1_CE               || '</value></field> ' ||
            ' <field name="'|| 'O2_COST'         ||'"><value>' ||    l_p11d_fields.O2_COST             || '</value></field> ' ||
            ' <field name="'|| 'O2_AMG'          ||'"><value>' ||    l_p11d_fields.O2_AMG              || '</value></field> ' ||
            ' <field name="'|| 'O2_CE'           ||'"><value>' ||    l_p11d_fields.O2_CE               || '</value></field> ' ||
            ' <field name="'|| 'O3_COST'         ||'"><value>' ||    l_p11d_fields.O3_COST             || '</value></field> ' ||
            ' <field name="'|| 'O3_AMG'          ||'"><value>' ||    l_p11d_fields.O3_AMG              || '</value></field> ' ||
            ' <field name="'|| 'O3_CE'           ||'"><value>' ||    l_p11d_fields.O3_CE               || '</value></field> ' ||
            ' <field name="'|| 'O4_COST'         ||'"><value>' ||    l_p11d_fields.O4_COST             || '</value></field> ' ||
            ' <field name="'|| 'O4_AMG'          ||'"><value>' ||    l_p11d_fields.O4_AMG              || '</value></field> ' ||
            ' <field name="'|| 'O4_CE'           ||'"><value>' ||    l_p11d_fields.O4_CE               || '</value></field> ' ||
            ' <field name="'|| 'O5_COST'         ||'"><value>' ||    l_p11d_fields.O5_COST             || '</value></field> ' ||
            ' <field name="'|| 'O5_AMG'          ||'"><value>' ||    l_p11d_fields.O5_AMG              || '</value></field> ' ||
            ' <field name="'|| 'O5_CE'           ||'"><value>' ||    l_p11d_fields.O5_CE               || '</value></field> ' ||
            ' <field name="'|| 'O6_COST'         ||'"><value>' ||    l_p11d_fields.O6_COST             || '</value></field> ' ||
            ' <field name="'|| 'O6_AMG'          ||'"><value>' ||    l_p11d_fields.O6_AMG              || '</value></field> ' ||
            ' <field name="'|| 'O6_CE'           ||'"><value>' ||    l_p11d_fields.O6_CE               || '</value></field> ' ||
            ' <field name="'|| 'O6_DESC'         ||'"><value>' ||    l_p11d_fields.O6_DESC             || '</value></field> ' ||
            ' <field name="'|| 'O_TOI'           ||'"><value>' ||    l_p11d_fields.O_TOI               || '</value></field> ' ||
            '</fields>  </xfdf>';
        elsif to_number(l_rep_run) >= 2005 and to_number(l_rep_run) < 2008 then -- P11D changes 07/08

            l_xfdf_string := '<?xml version = "1.0" encoding = "UTF-8"?>
            <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
            <fields> ' ||
            ' <field name="'|| 'DIRECTOR_FLAG'    ||'"><value>' ||    l_p11d_fields.DIRECTOR_FLAG       || '</value></field> ' ||
            ' <field name="'|| 'FULL_NAME'        ||'"><value>' ||    l_p11d_fields.FULL_NAME           || '</value></field> ' ||
            ' <field name="'|| 'EMPLOYEE_NUMBER'  ||'"><value>' ||    l_p11d_fields.EMPLOYEE_NUMBER     || '</value></field> ' ||
            ' <field name="'|| 'NATIONAL_INS_NO'  ||'"><value>' ||    l_p11d_fields.NATIONAL_INS_NO     || '</value></field> ' ||
            ' <field name="'||'NI_1'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,1,1) || '</value></field> ' ||
            ' <field name="'||'NI_2'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,2,1) || '</value></field> ' ||
            ' <field name="'||'NI_3'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,3,1) || '</value></field> ' ||
            ' <field name="'||'NI_4'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,4,1) || '</value></field> ' ||
            ' <field name="'||'NI_5'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,5,1) || '</value></field> ' ||
            ' <field name="'||'NI_6'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,6,1) || '</value></field> ' ||
            ' <field name="'||'NI_7'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,7,1) || '</value></field> ' ||
            ' <field name="'||'NI_8'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,8,1) || '</value></field> ' ||
            ' <field name="'||'NI_9'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,9)   || '</value></field> ' ||
            ' <field name="'||'GENDER'            ||'"><value>' ||    l_p11d_fields.gender                   || '</value></field> ' ||
            ' <field name="'||'DB1'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,1,1)    || '</value></field> ' ||
            ' <field name="'||'DB2'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,2,1)    || '</value></field> ' ||
            ' <field name="'||'DB3'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,3,1)    || '</value></field> ' ||
            ' <field name="'||'DB4'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,4,1)    || '</value></field> ' ||
            ' <field name="'||'DB5'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,5,1)    || '</value></field> ' ||
            ' <field name="'||'DB6'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,6,1)    || '</value></field> ' ||
            ' <field name="'||'DB7'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,7,1)    || '</value></field> ' ||
            ' <field name="'||'DB8'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,8,1)    || '</value></field> ' ||
            ' <field name="'|| 'EMPLOYERS_REF_NO' ||'"><value>' ||    l_p11d_fields.EMPLOYERS_REF_NO    || '</value></field> ' ||
            ' <field name="'|| 'EMPLOYERS_NAME'   ||'"><value>' ||    l_p11d_fields.EMPLOYERS_NAME      || '</value></field> ' ||
            ' <field name="'|| 'A_DESC'           ||'"><value>' ||    l_p11d_fields.A_DESC              || '</value></field> ' ||
            ' <field name="'|| 'A_COST'           ||'"><value>' ||    l_p11d_fields.A_COST              || '</value></field> ' ||
            ' <field name="'|| 'A_AMG'            ||'"><value>' ||    l_p11d_fields.A_AMG               || '</value></field> ' ||
            ' <field name="'|| 'A_CE'             ||'"><value>' ||    l_p11d_fields.A_CE                || '</value></field> ' ||
            ' <field name="'|| 'B_DESC'           ||'"><value>' ||    l_p11d_fields.B_DESC              || '</value></field> ' ||
            ' <field name="'|| 'B_CE'             ||'"><value>' ||    l_p11d_fields.B_CE                || '</value></field> ' ||
            ' <field name="'|| 'B_TNP'            ||'"><value>' ||    l_p11d_fields.B_TNP               || '</value></field> ' ||
            ' <field name="'|| 'C_COST'           ||'"><value>' ||    l_p11d_fields.C_COST              || '</value></field> ' ||
            ' <field name="'|| 'C_AMG'            ||'"><value>' ||    l_p11d_fields.C_AMG               || '</value></field> ' ||
            ' <field name="'|| 'C_CE'             ||'"><value>' ||    l_p11d_fields.C_CE                || '</value></field> ' ||
            ' <field name="'|| 'D_CE'             ||'"><value>' ||    l_p11d_fields.D_CE                || '</value></field> ' ||
            ' <field name="'|| 'E_CE'             ||'"><value>' ||    l_p11d_fields.E_CE                || '</value></field> ' ||
            ' <field name="'|| 'F1_MAKE'          ||'"><value>' ||    l_p11d_fields.F1_MAKE             || '</value></field> ' ||
            ' <field name="'|| 'F1_DREG1'         ||'"><value>' ||   substr(l_p11d_fields.F1_DREG,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'F1_DREG2'         ||'"><value>' ||   substr(l_p11d_fields.F1_DREG,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'F1_DREG3'         ||'"><value>' ||   substr(l_p11d_fields.F1_DREG,7)    || '</value></field> ' ||
            ' <field name="'|| 'F1_EFIG'          ||'"><value>' ||    l_p11d_fields.F1_EFIG             || '</value></field> ' ||
            ' <field name="'|| 'F1_NFIG'          ||'"><value>' ||    l_p11d_fields.F1_NFIG             || '</value></field> ' ||
            ' <field name="'|| 'F1_ESIZE'         ||'"><value>' ||    l_p11d_fields.F1_ESIZE            || '</value></field> ' ||
            ' <field name="'|| 'F1_FUEL'          ||'"><value>' ||    l_p11d_fields.F1_FUEL             || '</value></field> ' ||
            ' <field name="'|| 'F1_START1'        ||'"><value>' ||   substr(l_p11d_fields.F1_START,0,2) || '</value></field> ' ||
            ' <field name="'|| 'F1_START2'        ||'"><value>' ||   substr(l_p11d_fields.F1_START,4,2) || '</value></field> ' ||
            ' <field name="'|| 'F1_START3'        ||'"><value>' ||   substr(l_p11d_fields.F1_START,7)   || '</value></field> ' ||
            ' <field name="'|| 'F1_END1'          ||'"><value>' ||   substr(l_p11d_fields.F1_END,0,2)   || '</value></field> ' ||
            ' <field name="'|| 'F1_END2'          ||'"><value>' ||   substr(l_p11d_fields.F1_END,4,2)   || '</value></field> ' ||
            ' <field name="'|| 'F1_END3'          ||'"><value>' ||   substr(l_p11d_fields.F1_END,7)     || '</value></field> ' ||
            ' <field name="'|| 'F1_LPRICE'        ||'"><value>' ||    l_p11d_fields.F1_LPRICE           || '</value></field> ' ||
            ' <field name="'|| 'F1_OPRICE'        ||'"><value>' ||    l_p11d_fields.F1_OPRICE           || '</value></field> ' ||
       --   ' <field name="'|| 'F1_APRICE'        ||'"><value>' ||    l_p11d_fields.F1_APRICE           || '</value></field> ' ||
            ' <field name="'|| 'F1_COST'          ||'"><value>' ||    l_p11d_fields.F1_COST             || '</value></field> ' ||
            ' <field name="'|| 'F1_AMG'           ||'"><value>' ||    l_p11d_fields.F1_AMG              || '</value></field> ' ||
            ' <field name="'|| 'F1_DATE_FREE1'    ||'"><value>' ||    substr(l_p11d_fields.F1_DATE_FREE,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'F1_DATE_FREE2'    ||'"><value>' ||    substr(l_p11d_fields.F1_DATE_FREE,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'F1_DATE_FREE3'    ||'"><value>' ||    substr(l_p11d_fields.F1_DATE_FREE,7)    || '</value></field> ' ||
            ' <field name="'|| 'F1_REIN_YR'       ||'"><value>' ||    l_p11d_fields.F1_REIN_YR          || '</value></field> ' ||
            ' <field name="'|| 'F1_CC'            ||'"><value>' ||    l_p11d_fields.F1_CC               || '</value></field> ' ||
            ' <field name="'|| 'F1_FCC'           ||'"><value>' ||    l_p11d_fields.F1_FCC              || '</value></field> ' ||
            ' <field name="'|| 'F2_MAKE'          ||'"><value>' ||    l_p11d_fields.F2_MAKE             || '</value></field> ' ||
            ' <field name="'|| 'F2_DREG1'         ||'"><value>' ||   substr(l_p11d_fields.F2_DREG,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'F2_DREG2'         ||'"><value>' ||   substr(l_p11d_fields.F2_DREG,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'F2_DREG3'         ||'"><value>' ||   substr(l_p11d_fields.F2_DREG,7)    || '</value></field> ' ||
            ' <field name="'|| 'F2_EFIG'          ||'"><value>' ||    l_p11d_fields.F2_EFIG             || '</value></field> ' ||
            ' <field name="'|| 'F2_NFIG'          ||'"><value>' ||    l_p11d_fields.F2_NFIG             || '</value></field> ' ||
            ' <field name="'|| 'F2_ESIZE'         ||'"><value>' ||    l_p11d_fields.F2_ESIZE            || '</value></field> ' ||
            ' <field name="'|| 'F2_FUEL'          ||'"><value>' ||    l_p11d_fields.F2_FUEL             || '</value></field> ' ||
            ' <field name="'|| 'F2_START1'        ||'"><value>' ||   substr(l_p11d_fields.F2_START,0,2) || '</value></field> ' ||
            ' <field name="'|| 'F2_START2'        ||'"><value>' ||   substr(l_p11d_fields.F2_START,4,2) || '</value></field> ' ||
            ' <field name="'|| 'F2_START3'        ||'"><value>' ||   substr(l_p11d_fields.F2_START,7)   || '</value></field> ' ||
            ' <field name="'|| 'F2_END1'          ||'"><value>' ||   substr(l_p11d_fields.F2_END,0,2)   || '</value></field> ' ||
            ' <field name="'|| 'F2_END2'          ||'"><value>' ||   substr(l_p11d_fields.F2_END,4,2)   || '</value></field> ' ||
            ' <field name="'|| 'F2_END3'          ||'"><value>' ||   substr(l_p11d_fields.F2_END,7)     || '</value></field> ' ||
            ' <field name="'|| 'F2_LPRICE'        ||'"><value>' ||    l_p11d_fields.F2_LPRICE           || '</value></field> ' ||
            ' <field name="'|| 'F2_OPRICE'        ||'"><value>' ||    l_p11d_fields.F2_OPRICE           || '</value></field> ' ||
            ' <field name="'|| 'F2_APRICE'        ||'"><value>' ||    l_p11d_fields.F2_APRICE           || '</value></field> ' ||
            ' <field name="'|| 'F2_COST'          ||'"><value>' ||    l_p11d_fields.F2_COST             || '</value></field> ' ||
            ' <field name="'|| 'F2_AMG'           ||'"><value>' ||    l_p11d_fields.F2_AMG              || '</value></field> ' ||
            ' <field name="'|| 'F2_DATE_FREE1'    ||'"><value>' ||    substr(l_p11d_fields.F2_DATE_FREE,0,2) || '</value></field> ' ||
            ' <field name="'|| 'F2_DATE_FREE2'    ||'"><value>' ||    substr(l_p11d_fields.F2_DATE_FREE,4,2) || '</value></field> ' ||
            ' <field name="'|| 'F2_DATE_FREE3'    ||'"><value>' ||    substr(l_p11d_fields.F2_DATE_FREE,7)   || '</value></field> ' ||
            ' <field name="'|| 'F2_REIN_YR'       ||'"><value>' ||    l_p11d_fields.F2_REIN_YR          || '</value></field> ' ||
            ' <field name="'|| 'F2_CC'            ||'"><value>' ||    l_p11d_fields.F2_CC               || '</value></field> ' ||
            ' <field name="'|| 'F2_FCC'           ||'"><value>' ||    l_p11d_fields.F2_FCC              || '</value></field> ' ||
            ' <field name="'|| 'F_TCCE'           ||'"><value>' ||    l_p11d_fields.F_TCCE              || '</value></field> ' ||
            ' <field name="'|| 'F_TFCE'           ||'"><value>' ||    l_p11d_fields.F_TFCE              || '</value></field> ' ||
            ' <field name="'|| 'G_CE'             ||'"><value>' ||    l_p11d_fields.G_CE                || '</value></field> ' ||
            ' <field name="'|| 'H1_NJB'           ||'"><value>' ||    l_p11d_fields.H1_NJB              || '</value></field> ' ||
            ' <field name="'|| 'H1_AYB'           ||'"><value>' ||    l_p11d_fields.H1_AYB              || '</value></field> ' ||
            ' <field name="'|| 'H1_AYE'           ||'"><value>' ||    l_p11d_fields.H1_AYE              || '</value></field> ' ||
            ' <field name="'|| 'H1_MAO'           ||'"><value>' ||    l_p11d_fields.H1_MAO              || '</value></field> ' ||
            ' <field name="'|| 'H1_IP'            ||'"><value>' ||    l_p11d_fields.H1_IP               || '</value></field> ' ||
            ' <field name="'|| 'H1_DLM1'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLM,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLM2'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLM,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLM3'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLM,7)    || '</value></field> ' ||
            ' <field name="'|| 'H1_DLD1'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLD,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLD2'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLD,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLD3'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLD,7)    || '</value></field> ' ||
            ' <field name="'|| 'H1_CE'            ||'"><value>' ||    nvl(l_p11d_fields.H1_CE,'0.00')   || '</value></field> ' ||
            ' <field name="'|| 'H2_NJB'           ||'"><value>' ||    l_p11d_fields.H2_NJB              || '</value></field> ' ||
            ' <field name="'|| 'H2_AYB'           ||'"><value>' ||    l_p11d_fields.H2_AYB              || '</value></field> ' ||
            ' <field name="'|| 'H2_AYE'           ||'"><value>' ||    l_p11d_fields.H2_AYE              || '</value></field> ' ||
            ' <field name="'|| 'H2_MAO'           ||'"><value>' ||    l_p11d_fields.H2_MAO              || '</value></field> ' ||
            ' <field name="'|| 'H2_IP'            ||'"><value>' ||    l_p11d_fields.H2_IP               || '</value></field> ' ||
            ' <field name="'|| 'H2_DLM1'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLM,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLM2'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLM,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLM3'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLM,7)    || '</value></field> ' ||
            ' <field name="'|| 'H2_DLD1'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLD,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLD2'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLD,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLD3'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLD,7)    || '</value></field> ' ||
            ' <field name="'|| 'H2_CE'            ||'"><value>' ||    nvl(l_p11d_fields.H2_CE,'0.00')   || '</value></field> ' ||
            ' <field name="'|| 'I_COST'           ||'"><value>' ||    l_p11d_fields.I_COST              || '</value></field> ' ||
            ' <field name="'|| 'I_AMG'            ||'"><value>' ||    l_p11d_fields.I_AMG               || '</value></field> ' ||
            ' <field name="'|| 'I_CE'             ||'"><value>' ||    l_p11d_fields.I_CE                || '</value></field> ' ||
            ' <field name="'|| 'J_CE'             ||'"><value>' ||    l_p11d_fields.J_CE                || '</value></field> ' ||
            ' <field name="'|| 'K_COST'           ||'"><value>' ||    l_p11d_fields.K_COST              || '</value></field> ' ||
            ' <field name="'|| 'K_AMG'            ||'"><value>' ||    l_p11d_fields.K_AMG               || '</value></field> ' ||
            ' <field name="'|| 'K_CE'             ||'"><value>' ||    l_p11d_fields.K_CE                || '</value></field> ' ||
            ' <field name="'|| 'L_DESC'           ||'"><value>' ||    l_p11d_fields.L_DESC              || '</value></field> ' ||
            ' <field name="'|| 'L_COST'           ||'"><value>' ||    l_p11d_fields.L_COST              || '</value></field> ' ||
            ' <field name="'|| 'L_AMG'            ||'"><value>' ||    l_p11d_fields.L_AMG               || '</value></field> ' ||
            ' <field name="'|| 'L_CE'             ||'"><value>' ||    l_p11d_fields.L_CE                || '</value></field> ' ||
            ' <field name="'|| 'M_COST'           ||'"><value>' ||    l_p11d_fields.N_COST              || '</value></field> ' ||
            ' <field name="'|| 'M_AMG'            ||'"><value>' ||    l_p11d_fields.N_AMG               || '</value></field> ' ||
            ' <field name="'|| 'M_CE'             ||'"><value>' ||    l_p11d_fields.N_CE                || '</value></field> ' ||
            ' <field name="'|| 'M_DESC'           ||'"><value>' ||    replace(l_p11d_fields.N_DESC,'&','&amp;')  || '</value></field> ' ||
            ' <field name="'|| 'MA_COST'          ||'"><value>' ||    l_p11d_fields.NA_COST             || '</value></field> ' ||
            ' <field name="'|| 'MA_AMG'           ||'"><value>' ||    l_p11d_fields.NA_AMG              || '</value></field> ' ||
            ' <field name="'|| 'MA_CE'            ||'"><value>' ||    l_p11d_fields.NA_CE               || '</value></field> ' ||
            ' <field name="'|| 'MA_DESC'          ||'"><value>' ||    l_p11d_fields.NA_DESC             || '</value></field> ' ||
            ' <field name="'|| 'M_TAXPAID'        ||'"><value>' ||    l_p11d_fields.N_TAXPAID           || '</value></field> ' ||
            ' <field name="'|| 'N1_COST'          ||'"><value>' ||    l_p11d_fields.O1_COST             || '</value></field> ' ||
            ' <field name="'|| 'N1_AMG'           ||'"><value>' ||    l_p11d_fields.O1_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N1_CE'            ||'"><value>' ||    l_p11d_fields.O1_CE               || '</value></field> ' ||
            ' <field name="'|| 'N2_COST'          ||'"><value>' ||    l_p11d_fields.O2_COST             || '</value></field> ' ||
            ' <field name="'|| 'N2_AMG'           ||'"><value>' ||    l_p11d_fields.O2_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N2_CE'            ||'"><value>' ||    l_p11d_fields.O2_CE               || '</value></field> ' ||
            ' <field name="'|| 'N3_COST'          ||'"><value>' ||    l_p11d_fields.O3_COST             || '</value></field> ' ||
            ' <field name="'|| 'N3_AMG'           ||'"><value>' ||    l_p11d_fields.O3_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N3_CE'            ||'"><value>' ||    l_p11d_fields.O3_CE               || '</value></field> ' ||
            ' <field name="'|| 'N4_COST'          ||'"><value>' ||    l_p11d_fields.O4_COST             || '</value></field> ' ||
            ' <field name="'|| 'N4_AMG'           ||'"><value>' ||    l_p11d_fields.O4_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N4_CE'            ||'"><value>' ||    l_p11d_fields.O4_CE               || '</value></field> ' ||
            ' <field name="'|| 'N5_COST'          ||'"><value>' ||    l_p11d_fields.O5_COST             || '</value></field> ' ||
            ' <field name="'|| 'N5_AMG'           ||'"><value>' ||    l_p11d_fields.O5_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N5_CE'            ||'"><value>' ||    l_p11d_fields.O5_CE               || '</value></field> ' ||
            ' <field name="'|| 'N6_COST'          ||'"><value>' ||    l_p11d_fields.O6_COST             || '</value></field> ' ||
            ' <field name="'|| 'N6_AMG'           ||'"><value>' ||    l_p11d_fields.O6_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N6_CE'            ||'"><value>' ||    l_p11d_fields.O6_CE               || '</value></field> ' ||
            ' <field name="'|| 'N6_DESC'          ||'"><value>' ||    l_p11d_fields.O6_DESC             || '</value></field> ' ||
            ' <field name="'|| 'N_TOI'            ||'"><value>' ||    l_p11d_fields.O_TOI               || '</value></field> ' ||
            '</fields>  </xfdf>';
          else -- P11d changes 07/08

            l_xfdf_string := '<?xml version = "1.0" encoding = "UTF-8"?>
            <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
            <fields> ' ||
            ' <field name="'|| 'DIRECTOR_FLAG'    ||'"><value>' ||    l_p11d_fields.DIRECTOR_FLAG       || '</value></field> ' ||
            ' <field name="'|| 'SUR_NAME'        ||'"><value>' ||     l_p11d_fields.SUR_NAME           || '</value></field> ' ||
            ' <field name="'|| 'FORE_NAME'        ||'"><value>' ||    l_p11d_fields.FORE_NAME           || '</value></field> ' ||
            ' <field name="'|| 'EMPLOYEE_NUMBER'  ||'"><value>' ||    l_p11d_fields.EMPLOYEE_NUMBER     || '</value></field> ' ||
            ' <field name="'|| 'NATIONAL_INS_NO'  ||'"><value>' ||    l_p11d_fields.NATIONAL_INS_NO     || '</value></field> ' ||
            ' <field name="'||'NI_1'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,1,1) || '</value></field> ' ||
            ' <field name="'||'NI_2'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,2,1) || '</value></field> ' ||
            ' <field name="'||'NI_3'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,3,1) || '</value></field> ' ||
            ' <field name="'||'NI_4'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,4,1) || '</value></field> ' ||
            ' <field name="'||'NI_5'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,5,1) || '</value></field> ' ||
            ' <field name="'||'NI_6'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,6,1) || '</value></field> ' ||
            ' <field name="'||'NI_7'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,7,1) || '</value></field> ' ||
            ' <field name="'||'NI_8'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,8,1) || '</value></field> ' ||
            ' <field name="'||'NI_9'              ||'"><value>' ||substr(l_p11d_fields.NATIONAL_INS_NO ,9)   || '</value></field> ' ||
            ' <field name="'||'GENDER'            ||'"><value>' ||    l_p11d_fields.gender                   || '</value></field> ' ||
            ' <field name="'||'DB1'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,1,1)    || '</value></field> ' ||
            ' <field name="'||'DB2'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,2,1)    || '</value></field> ' ||
            ' <field name="'||'DB3'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,3,1)    || '</value></field> ' ||
            ' <field name="'||'DB4'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,4,1)    || '</value></field> ' ||
            ' <field name="'||'DB5'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,5,1)    || '</value></field> ' ||
            ' <field name="'||'DB6'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,6,1)    || '</value></field> ' ||
            ' <field name="'||'DB7'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,7,1)    || '</value></field> ' ||
            ' <field name="'||'DB8'               ||'"><value>' ||substr(l_p11d_fields.date_of_birth,8,1)    || '</value></field> ' ||
            ' <field name="'|| 'EMPLOYERS_REF_NO' ||'"><value>' ||    l_p11d_fields.EMPLOYERS_REF_NO    || '</value></field> ' ||
            ' <field name="'|| 'EMPLOYERS_NAME'   ||'"><value>' ||    l_p11d_fields.EMPLOYERS_NAME      || '</value></field> ' ||
            ' <field name="'|| 'A_DESC'           ||'"><value>' ||    l_p11d_fields.A_DESC              || '</value></field> ' ||
            ' <field name="'|| 'A_COST'           ||'"><value>' ||    l_p11d_fields.A_COST              || '</value></field> ' ||
            ' <field name="'|| 'A_AMG'            ||'"><value>' ||    l_p11d_fields.A_AMG               || '</value></field> ' ||
            ' <field name="'|| 'A_CE'             ||'"><value>' ||    l_p11d_fields.A_CE                || '</value></field> ' ||
            ' <field name="'|| 'B_DESC'           ||'"><value>' ||    l_p11d_fields.B_DESC              || '</value></field> ' ||
            ' <field name="'|| 'B_CE'             ||'"><value>' ||    l_p11d_fields.B_CE                || '</value></field> ' ||
            ' <field name="'|| 'B_TNP'            ||'"><value>' ||    l_p11d_fields.B_TNP               || '</value></field> ' ||
            ' <field name="'|| 'C_COST'           ||'"><value>' ||    l_p11d_fields.C_COST              || '</value></field> ' ||
            ' <field name="'|| 'C_AMG'            ||'"><value>' ||    l_p11d_fields.C_AMG               || '</value></field> ' ||
            ' <field name="'|| 'C_CE'             ||'"><value>' ||    l_p11d_fields.C_CE                || '</value></field> ' ||
            ' <field name="'|| 'D_CE'             ||'"><value>' ||    l_p11d_fields.D_CE                || '</value></field> ' ||
            ' <field name="'|| 'E_CE'             ||'"><value>' ||    l_p11d_fields.E_CE                || '</value></field> ' ||
            ' <field name="'|| 'F1_MAKE'          ||'"><value>' ||    l_p11d_fields.F1_MAKE             || '</value></field> ' ||
            ' <field name="'|| 'F1_DREG1'         ||'"><value>' ||   substr(l_p11d_fields.F1_DREG,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'F1_DREG2'         ||'"><value>' ||   substr(l_p11d_fields.F1_DREG,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'F1_DREG3'         ||'"><value>' ||   substr(l_p11d_fields.F1_DREG,7)    || '</value></field> ' ||
            ' <field name="'|| 'F1_EFIG'          ||'"><value>' ||    l_p11d_fields.F1_EFIG             || '</value></field> ' ||
            ' <field name="'|| 'F1_NFIG'          ||'"><value>' ||    l_p11d_fields.F1_NFIG             || '</value></field> ' ||
            ' <field name="'|| 'F1_ESIZE'         ||'"><value>' ||    l_p11d_fields.F1_ESIZE            || '</value></field> ' ||
            ' <field name="'|| 'F1_FUEL'          ||'"><value>' ||    l_p11d_fields.F1_FUEL             || '</value></field> ' ||
            ' <field name="'|| 'F1_START1'        ||'"><value>' ||   substr(l_p11d_fields.F1_START,0,2) || '</value></field> ' ||
            ' <field name="'|| 'F1_START2'        ||'"><value>' ||   substr(l_p11d_fields.F1_START,4,2) || '</value></field> ' ||
            ' <field name="'|| 'F1_START3'        ||'"><value>' ||   substr(l_p11d_fields.F1_START,7)   || '</value></field> ' ||
            ' <field name="'|| 'F1_END1'          ||'"><value>' ||   substr(l_p11d_fields.F1_END,0,2)   || '</value></field> ' ||
            ' <field name="'|| 'F1_END2'          ||'"><value>' ||   substr(l_p11d_fields.F1_END,4,2)   || '</value></field> ' ||
            ' <field name="'|| 'F1_END3'          ||'"><value>' ||   substr(l_p11d_fields.F1_END,7)     || '</value></field> ' ||
            ' <field name="'|| 'F1_LPRICE'        ||'"><value>' ||    l_p11d_fields.F1_LPRICE           || '</value></field> ' ||
            ' <field name="'|| 'F1_OPRICE'        ||'"><value>' ||    l_p11d_fields.F1_OPRICE           || '</value></field> ' ||
       --   ' <field name="'|| 'F1_APRICE'        ||'"><value>' ||    l_p11d_fields.F1_APRICE           || '</value></field> ' ||
            ' <field name="'|| 'F1_COST'          ||'"><value>' ||    l_p11d_fields.F1_COST             || '</value></field> ' ||
            ' <field name="'|| 'F1_AMG'           ||'"><value>' ||    l_p11d_fields.F1_AMG              || '</value></field> ' ||
            ' <field name="'|| 'F1_DATE_FREE1'    ||'"><value>' ||    substr(l_p11d_fields.F1_DATE_FREE,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'F1_DATE_FREE2'    ||'"><value>' ||    substr(l_p11d_fields.F1_DATE_FREE,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'F1_DATE_FREE3'    ||'"><value>' ||    substr(l_p11d_fields.F1_DATE_FREE,7)    || '</value></field> ' ||
            ' <field name="'|| 'F1_REIN_YR'       ||'"><value>' ||    l_p11d_fields.F1_REIN_YR          || '</value></field> ' ||
            ' <field name="'|| 'F1_CC'            ||'"><value>' ||    l_p11d_fields.F1_CC               || '</value></field> ' ||
            ' <field name="'|| 'F1_FCC'           ||'"><value>' ||    l_p11d_fields.F1_FCC              || '</value></field> ' ||
            ' <field name="'|| 'F2_MAKE'          ||'"><value>' ||    l_p11d_fields.F2_MAKE             || '</value></field> ' ||
            ' <field name="'|| 'F2_DREG1'         ||'"><value>' ||   substr(l_p11d_fields.F2_DREG,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'F2_DREG2'         ||'"><value>' ||   substr(l_p11d_fields.F2_DREG,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'F2_DREG3'         ||'"><value>' ||   substr(l_p11d_fields.F2_DREG,7)    || '</value></field> ' ||
            ' <field name="'|| 'F2_EFIG'          ||'"><value>' ||    l_p11d_fields.F2_EFIG             || '</value></field> ' ||
            ' <field name="'|| 'F2_NFIG'          ||'"><value>' ||    l_p11d_fields.F2_NFIG             || '</value></field> ' ||
            ' <field name="'|| 'F2_ESIZE'         ||'"><value>' ||    l_p11d_fields.F2_ESIZE            || '</value></field> ' ||
            ' <field name="'|| 'F2_FUEL'          ||'"><value>' ||    l_p11d_fields.F2_FUEL             || '</value></field> ' ||
            ' <field name="'|| 'F2_START1'        ||'"><value>' ||   substr(l_p11d_fields.F2_START,0,2) || '</value></field> ' ||
            ' <field name="'|| 'F2_START2'        ||'"><value>' ||   substr(l_p11d_fields.F2_START,4,2) || '</value></field> ' ||
            ' <field name="'|| 'F2_START3'        ||'"><value>' ||   substr(l_p11d_fields.F2_START,7)   || '</value></field> ' ||
            ' <field name="'|| 'F2_END1'          ||'"><value>' ||   substr(l_p11d_fields.F2_END,0,2)   || '</value></field> ' ||
            ' <field name="'|| 'F2_END2'          ||'"><value>' ||   substr(l_p11d_fields.F2_END,4,2)   || '</value></field> ' ||
            ' <field name="'|| 'F2_END3'          ||'"><value>' ||   substr(l_p11d_fields.F2_END,7)     || '</value></field> ' ||
            ' <field name="'|| 'F2_LPRICE'        ||'"><value>' ||    l_p11d_fields.F2_LPRICE           || '</value></field> ' ||
            ' <field name="'|| 'F2_OPRICE'        ||'"><value>' ||    l_p11d_fields.F2_OPRICE           || '</value></field> ' ||
            ' <field name="'|| 'F2_APRICE'        ||'"><value>' ||    l_p11d_fields.F2_APRICE           || '</value></field> ' ||
            ' <field name="'|| 'F2_COST'          ||'"><value>' ||    l_p11d_fields.F2_COST             || '</value></field> ' ||
            ' <field name="'|| 'F2_AMG'           ||'"><value>' ||    l_p11d_fields.F2_AMG              || '</value></field> ' ||
            ' <field name="'|| 'F2_DATE_FREE1'    ||'"><value>' ||    substr(l_p11d_fields.F2_DATE_FREE,0,2) || '</value></field> ' ||
            ' <field name="'|| 'F2_DATE_FREE2'    ||'"><value>' ||    substr(l_p11d_fields.F2_DATE_FREE,4,2) || '</value></field> ' ||
            ' <field name="'|| 'F2_DATE_FREE3'    ||'"><value>' ||    substr(l_p11d_fields.F2_DATE_FREE,7)   || '</value></field> ' ||
            ' <field name="'|| 'F2_REIN_YR'       ||'"><value>' ||    l_p11d_fields.F2_REIN_YR          || '</value></field> ' ||
            ' <field name="'|| 'F2_CC'            ||'"><value>' ||    l_p11d_fields.F2_CC               || '</value></field> ' ||
            ' <field name="'|| 'F2_FCC'           ||'"><value>' ||    l_p11d_fields.F2_FCC              || '</value></field> ' ||
            ' <field name="'|| 'F_TCCE'           ||'"><value>' ||    l_p11d_fields.F_TCCE              || '</value></field> ' ||
            ' <field name="'|| 'F_TFCE'           ||'"><value>' ||    l_p11d_fields.F_TFCE              || '</value></field> ' ||
            ' <field name="'|| 'G_CE'             ||'"><value>' ||    l_p11d_fields.G_CE                || '</value></field> ' ||
            ' <field name="'|| 'G_CEF'            ||'"><value>' ||    l_p11d_fields.G_CEF               || '</value></field> ' ||
            ' <field name="'|| 'H1_NJB'           ||'"><value>' ||    l_p11d_fields.H1_NJB              || '</value></field> ' ||
            ' <field name="'|| 'H1_AYB'           ||'"><value>' ||    l_p11d_fields.H1_AYB              || '</value></field> ' ||
            ' <field name="'|| 'H1_AYE'           ||'"><value>' ||    l_p11d_fields.H1_AYE              || '</value></field> ' ||
            ' <field name="'|| 'H1_MAO'           ||'"><value>' ||    l_p11d_fields.H1_MAO              || '</value></field> ' ||
            ' <field name="'|| 'H1_IP'            ||'"><value>' ||    l_p11d_fields.H1_IP               || '</value></field> ' ||
            ' <field name="'|| 'H1_DLM1'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLM,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLM2'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLM,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLM3'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLM,7)    || '</value></field> ' ||
            ' <field name="'|| 'H1_DLD1'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLD,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLD2'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLD,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H1_DLD3'          ||'"><value>' ||    substr(l_p11d_fields.H1_DLD,7)    || '</value></field> ' ||
            ' <field name="'|| 'H1_CE'            ||'"><value>' ||    nvl(l_p11d_fields.H1_CE,'0.00')   || '</value></field> ' ||
            ' <field name="'|| 'H2_NJB'           ||'"><value>' ||    l_p11d_fields.H2_NJB              || '</value></field> ' ||
            ' <field name="'|| 'H2_AYB'           ||'"><value>' ||    l_p11d_fields.H2_AYB              || '</value></field> ' ||
            ' <field name="'|| 'H2_AYE'           ||'"><value>' ||    l_p11d_fields.H2_AYE              || '</value></field> ' ||
            ' <field name="'|| 'H2_MAO'           ||'"><value>' ||    l_p11d_fields.H2_MAO              || '</value></field> ' ||
            ' <field name="'|| 'H2_IP'            ||'"><value>' ||    l_p11d_fields.H2_IP               || '</value></field> ' ||
            ' <field name="'|| 'H2_DLM1'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLM,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLM2'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLM,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLM3'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLM,7)    || '</value></field> ' ||
            ' <field name="'|| 'H2_DLD1'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLD,0,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLD2'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLD,4,2)  || '</value></field> ' ||
            ' <field name="'|| 'H2_DLD3'          ||'"><value>' ||    substr(l_p11d_fields.H2_DLD,7)    || '</value></field> ' ||
            ' <field name="'|| 'H2_CE'            ||'"><value>' ||    nvl(l_p11d_fields.H2_CE,'0.00')   || '</value></field> ' ||
            ' <field name="'|| 'I_COST'           ||'"><value>' ||    l_p11d_fields.I_COST              || '</value></field> ' ||
            ' <field name="'|| 'I_AMG'            ||'"><value>' ||    l_p11d_fields.I_AMG               || '</value></field> ' ||
            ' <field name="'|| 'I_CE'             ||'"><value>' ||    l_p11d_fields.I_CE                || '</value></field> ' ||
            ' <field name="'|| 'J_CE'             ||'"><value>' ||    l_p11d_fields.J_CE                || '</value></field> ' ||
            ' <field name="'|| 'K_COST'           ||'"><value>' ||    l_p11d_fields.K_COST              || '</value></field> ' ||
            ' <field name="'|| 'K_AMG'            ||'"><value>' ||    l_p11d_fields.K_AMG               || '</value></field> ' ||
            ' <field name="'|| 'K_CE'             ||'"><value>' ||    l_p11d_fields.K_CE                || '</value></field> ' ||
            ' <field name="'|| 'L_DESC'           ||'"><value>' ||    l_p11d_fields.L_DESC              || '</value></field> ' ||
            ' <field name="'|| 'L_COST'           ||'"><value>' ||    l_p11d_fields.L_COST              || '</value></field> ' ||
            ' <field name="'|| 'L_AMG'            ||'"><value>' ||    l_p11d_fields.L_AMG               || '</value></field> ' ||
            ' <field name="'|| 'L_CE'             ||'"><value>' ||    l_p11d_fields.L_CE                || '</value></field> ' ||
            ' <field name="'|| 'M_COST'           ||'"><value>' ||    l_p11d_fields.N_COST              || '</value></field> ' ||
            ' <field name="'|| 'M_AMG'            ||'"><value>' ||    l_p11d_fields.N_AMG               || '</value></field> ' ||
            ' <field name="'|| 'M_CE'             ||'"><value>' ||    l_p11d_fields.N_CE                || '</value></field> ' ||
            ' <field name="'|| 'M_DESC'           ||'"><value>' ||    replace(l_p11d_fields.N_DESC,'&','&amp;')  || '</value></field> ' ||
            ' <field name="'|| 'MA_COST'          ||'"><value>' ||    l_p11d_fields.NA_COST             || '</value></field> ' ||
            ' <field name="'|| 'MA_AMG'           ||'"><value>' ||    l_p11d_fields.NA_AMG              || '</value></field> ' ||
            ' <field name="'|| 'MA_CE'            ||'"><value>' ||    l_p11d_fields.NA_CE               || '</value></field> ' ||
            ' <field name="'|| 'MA_DESC'          ||'"><value>' ||    l_p11d_fields.NA_DESC             || '</value></field> ' ||
            ' <field name="'|| 'M_TAXPAID'        ||'"><value>' ||    l_p11d_fields.N_TAXPAID           || '</value></field> ' ||
            ' <field name="'|| 'N1_COST'          ||'"><value>' ||    l_p11d_fields.O1_COST             || '</value></field> ' ||
            ' <field name="'|| 'N1_AMG'           ||'"><value>' ||    l_p11d_fields.O1_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N1_CE'            ||'"><value>' ||    l_p11d_fields.O1_CE               || '</value></field> ' ||
            ' <field name="'|| 'N2_COST'          ||'"><value>' ||    l_p11d_fields.O2_COST             || '</value></field> ' ||
            ' <field name="'|| 'N2_AMG'           ||'"><value>' ||    l_p11d_fields.O2_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N2_CE'            ||'"><value>' ||    l_p11d_fields.O2_CE               || '</value></field> ' ||
            ' <field name="'|| 'N3_COST'          ||'"><value>' ||    l_p11d_fields.O3_COST             || '</value></field> ' ||
            ' <field name="'|| 'N3_AMG'           ||'"><value>' ||    l_p11d_fields.O3_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N3_CE'            ||'"><value>' ||    l_p11d_fields.O3_CE               || '</value></field> ' ||
            ' <field name="'|| 'N4_COST'          ||'"><value>' ||    l_p11d_fields.O4_COST             || '</value></field> ' ||
            ' <field name="'|| 'N4_AMG'           ||'"><value>' ||    l_p11d_fields.O4_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N4_CE'            ||'"><value>' ||    l_p11d_fields.O4_CE               || '</value></field> ' ||
            ' <field name="'|| 'N5_COST'          ||'"><value>' ||    l_p11d_fields.O5_COST             || '</value></field> ' ||
            ' <field name="'|| 'N5_AMG'           ||'"><value>' ||    l_p11d_fields.O5_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N5_CE'            ||'"><value>' ||    l_p11d_fields.O5_CE               || '</value></field> ' ||
            ' <field name="'|| 'N6_COST'          ||'"><value>' ||    l_p11d_fields.O6_COST             || '</value></field> ' ||
            ' <field name="'|| 'N6_AMG'           ||'"><value>' ||    l_p11d_fields.O6_AMG              || '</value></field> ' ||
            ' <field name="'|| 'N6_CE'            ||'"><value>' ||    l_p11d_fields.O6_CE               || '</value></field> ' ||
            ' <field name="'|| 'N6_DESC'          ||'"><value>' ||    l_p11d_fields.O6_DESC             || '</value></field> ' ||
            ' <field name="'|| 'N_TOI'            ||'"><value>' ||    l_p11d_fields.O_TOI               || '</value></field> ' ||
            '</fields>  </xfdf>';

        end if;

        dbms_lob.createtemporary(l_xfdf_clob,false,DBMS_LOB.CALL);
        dbms_lob.open(l_xfdf_clob,dbms_lob.lob_readwrite);

--Start of the fix for the EAP bug 9383416
if (validate_display_output(p_assignment_action_id) = 1) then
        dbms_lob.writeAppend( l_xfdf_clob, length(l_xfdf_string ), l_xfdf_string  );
    end if;
--End of the fix for the EAP bug 9383416

        DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,true);
        -- clob_to_blob(l_xfdf_string,l_xfdf_blob);
        clob_to_blob(l_xfdf_clob,l_xfdf_blob);
        -- insert into temp values          (l_xfdf_clob);
        dbms_lob.close(l_xfdf_clob);
        dbms_lob.freetemporary(l_xfdf_clob);
        hr_utility.trace('P11D.......................');
        return l_xfdf_blob;
   exception
   when OTHERS then
          HR_UTILITY.TRACE('sqleerm ' || sqlerrm);
          HR_UTILITY.RAISE_ERROR;
   end;
--
/*------------------------------------------------------------------------
Below validate_display_output function returns 1 if ANY of the following
conditions is true:
1. Emp has INT FREE AND LOW INT LOANS Max Outstanding Value > 5000
2. Emp has MILEAGE ALLOWANCE AND PPAYMENT Cash Equivalant Value > 0
3. Emp has any other element.
------------------------------------------------------------------------*/

--Start of the fix for the EAP bug 9383416
  function validate_display_output(p_assignment_action_id Number) return number
  is

  cursor get_loan_amount (c_emp_ref in varchar2) is
     select /*+ ORDERED use_nl(paa,pai,pai_person)
		           use_index(pai_person,pay_action_information_n2)
			   use_index(pai,pay_action_information_n2) */
    		sum(to_number(nvl(pai.action_information7,0)))
	 from   pay_assignment_actions  paa,
       		pay_action_information  pai,
       		pay_action_information  pai_person
	 where  pai.action_context_id = paa.assignment_action_id
	 and    pai.action_context_type = 'AAP'
	 and    pai.action_information_category = 'INT FREE AND LOW INT LOANS'
	 and    pai_person.action_context_id = paa.assignment_action_id
	 and    paa.assignment_action_id = p_assignment_action_id
	 and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
	 and    upper(pai_person.action_information13) = upper(c_emp_ref)
	 and    pai_person.action_context_type = 'AAP';

    cursor get_ben_value (c_emp_ref in varchar2) is
       select /*+ ORDERED use_nl(paa,pai,pai_a,pai_person)
                    use_index(pai_person,pay_action_information_n2)
                    use_index(pai,pay_action_information_n2)
                    use_index(pai_a,pay_action_information_n2)*/
              pai_a.action_information12
       from   pay_assignment_actions  paa,
              pay_action_information  pai,
              pay_action_information  pai_a,
              pay_action_information  pai_person
       where  paa.assignment_action_id = p_assignment_action_id
       and    pai.action_context_id = paa.assignment_action_id
       and    pai.action_context_type = 'AAP'
       and    pai.action_information_category = pai.action_information_category
       and    pai_person.action_context_id = paa.assignment_action_id
       and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
       and    pai_person.action_context_type = 'AAP'
       and    upper(pai_person.action_information13) = upper(c_emp_ref)
       and    pai_a.action_context_id = paa.assignment_action_id
       and    pai_a.action_context_type = 'AAP'
       and    pai_a.action_information_category = 'GB P11D ASSIGNMENT RESULTA'
       and    pai.action_information_category = 'MILEAGE ALLOWANCE AND PPAYMENT';

    cursor get_threshold_val (c_rep_run in varchar2) is
        select to_number(global_value)
          from ff_globals_f
         where global_name = 'P11D_LOW_INT_LOAN_THRESHOLD'
           and to_date('05-04-' || c_rep_run,'DD-MM-YYYY') between effective_start_date and effective_end_date;

    cursor get_emp_ref is
        select action_information6
          from pay_action_information pai_comp
         where pai_comp.action_context_id = p_assignment_action_id
           and pai_comp.action_information_category = 'EMEA PAYROLL INFO';

    cursor get_pactid is
        select payroll_action_id
          from pay_assignment_actions
         where assignment_action_id = p_assignment_action_id;

    cursor get_other_ben_exists is
        select 1
          from pay_action_information pai
         where pai.action_context_id = p_assignment_action_id
           and pai.action_context_type = 'AAP'
           and pai.action_information_category in ('ASSETS TRANSFERRED',
                            'PAYMENTS MADE FOR EMP',
                            'VOUCHERS OR CREDIT CARDS',
                            'LIVING ACCOMMODATION',
                            'CAR AND CAR FUEL 2003_04',
                            'VANS 2007',
                            'PVT MED TREATMENT OR INSURANCE',
                            'RELOCATION EXPENSES',
                            'SERVICES SUPPLIED',
                            'ASSETS AT EMP DISPOSAL',
                            'OTHER ITEMS',
                            'OTHER ITEMS NON 1A',
                            'EXPENSES PAYMENTS',
                            'MARORS');

         l_h_sum_max_amt_outstanding Number;
         l_loan_threshold Number;
         l_pactid number;
         l_rep_run varchar2(10);
         l_emp_ref varchar2(150);  --fixed for the bug 9450379
         l_ben_value number;
         l_other_ben_exists number;

        begin
            hr_utility.trace('Entering validate_display_output function');
        open get_pactid ;
            fetch get_pactid into l_pactid;
        close get_pactid ;

         PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => l_pactid,
         p_token_name                  => 'Rep_Run',
         p_token_value                 => l_rep_run);

        open get_emp_ref;
            fetch get_emp_ref into l_emp_ref;
        close get_emp_ref;

        open get_loan_amount(l_emp_ref);
            fetch get_loan_amount into l_h_sum_max_amt_outstanding;
        close get_loan_amount;

        open get_threshold_val(l_rep_run);
            fetch get_threshold_val into l_loan_threshold;
        close get_threshold_val;

        open get_ben_value(l_emp_ref);
            fetch get_ben_value into l_ben_value;
        close get_ben_value;

        open get_other_ben_exists;
            fetch get_other_ben_exists into l_other_ben_exists;
        close get_other_ben_exists;

     if ((l_h_sum_max_amt_outstanding > l_loan_threshold)
         or (l_ben_value > 0 ) or (l_other_ben_exists = 1)) then
        return 1;
     else
        return 0;
     end if;
         hr_utility.trace('Leaving validate_display_output function');
    end validate_display_output;
--End of the fix for the EAP bug 9383416

   function get_p11d_year return VARCHAR2
   is
        l_year              VARCHAR2(4);
        l_effective_date    DATE;
        cursor csr_year
        is
        --select to_char(ses.effective_date, 'YYYY'), ses.effective_date
        select to_char(sysdate,'YYYY'), ses.effective_date
        from   fnd_sessions ses
        where  ses.session_id = userenv('sessionid');
   begin
        open csr_year;
        fetch csr_year into l_year, l_effective_date;
        close csr_year;
        /*
        if l_effective_date > to_date('06-04-'|| l_year, 'DD-MM-YYYY')
        then
            null;
        else
            l_year := to_char(to_number(l_year) - 1);
        end if;
        */
        return l_year;
   end;

   function get_ben_start_date return date
   is
        l_year              VARCHAR2(4);
   begin
        l_year := get_p11d_year;
        return to_date('06-04-'|| to_char(to_number(l_year) - 1), 'DD-MM-YYYY');
   end;

   function get_ben_end_date return DATE
   is
        l_year              VARCHAR2(4);
   begin
        l_year := get_p11d_year;
        return to_date('05-04-'|| l_year, 'DD-MM-YYYY');
   end;

   procedure update_leg_process_status(errbuf              out nocopy VARCHAR2,
                                       retcode             out nocopy NUMBER,
                                       p_payroll_action_id in  Number,
                                       p_new_status        in  Varchar2)
   is
        l_param_string VARCHAR2(2000);
        l_param_string_before_val VARCHAR2(2000);
        l_param_string_after_val VARCHAR2(2000);
        Old_Archive exception;
   begin
        retcode := 0;
        select legislative_parameters
        into   l_param_string
        from   pay_payroll_actions
        where  payroll_action_id = p_payroll_action_id;
        -- check if the archiver has Status in it
        -- if not then it is old archiver 2002-2003 archiver.
        -- the one prior to self service being supplied.
        -- so this cannot be run on them, hence we should error it
        if instr(l_param_string,'Status=') = 0
        then
            raise Old_Archive;
        end if;
        l_param_string_before_val := substr(l_param_string,1,instr(l_param_string, ' Status=')-2) ;
        l_param_string_after_val  := substr(l_param_string,instr(l_param_string, 'Status=') + length('Status=')+1) ;
        update pay_payroll_actions
        set  legislative_parameters =l_param_string_before_val ||  p_new_status ||
            ' Status=' || p_new_status || l_param_string_after_val
        where payroll_action_id = p_payroll_action_id; --8875;
   exception
   when Old_Archive then
        retcode := 1;
        hr_utility.set_message(800, 'HR_78078_P11D_STAT_INCOR_ARCH');
        errbuf := hr_utility.get_message;
        hr_utility.raise_error;
   when OTHERS then
        retcode := 1;
        hr_utility.set_message(800, 'HR_78077_P11D_STATUS_CHG_ERR');
        hr_utility.set_message_token(800, 'ERRORMSG', sqlerrm);
        errbuf := hr_utility.get_message;
        hr_utility.raise_error;
   end;

   function get_lookup_meaning(p_lookup_type varchar2,
                               p_lookup_code varchar2,
                               p_effective_date date) return varchar2
   is
        l_meaning varchar2(100);
        /*Bug No. 3237648*/
        /*Fetching from hr_lookups instead of fnd_lookup_values*/
        cursor csr_meaning is
        select meaning
        from   hr_lookups hlu
        where  hlu.lookup_type = p_lookup_type
        and    hlu.lookup_code = p_lookup_code
        and    hlu.enabled_flag='Y'
        and    p_effective_date between
                   nvl( hlu.START_DATE_ACTIVE,p_effective_date)
               and nvl( hlu.END_DATE_ACTIVE , p_effective_date);
   begin
        open csr_meaning;
        fetch csr_meaning into l_meaning;
        close csr_meaning;
        return l_meaning;
   end;

   function fetch_arch_param_details(p_payroll_action_id in  Number) return varchar2
   is
        l_benefit_end_date     VARCHAR2(20);
        l_benefit_start_date   VARCHAR2(20);
        l_payroll_id           NUMBER;
        l_payroll              varchar2(100);
        l_person_id            NUMBER;
        l_person               varchar2(100);
        l_rep_run              varchar2(10);
        l_consolidation_set_id NUMBER;
        l_consolidation_set    varchar2(100);
        l_tax_reference        VARCHAR2(200);
        l_assignment_set_id    NUMBER;
        l_assignment_set       VARCHAR2(200);
        l_run_type_code        varchar2(10);
        l_run_type_meaning     varchar2(20);
        l_status_code          varchar2(10);
        l_status_meaning       varchar2(20);
        l_return_string varchar2(1000);
        cursor csr_payroll(p_effective_date date)
        is
        select PAYROLL_NAME
        from  pay_payrolls_f
        where PAYROLL_ID =  l_payroll_id
        and   p_effective_date between
                  nvl(effective_start_date,p_effective_date)
              and nvl(effective_start_date,p_effective_date);

        cursor csr_person(p_effective_date date)
        is
        select FULL_NAME
        from  per_people_f
        where person_ID =  l_person_id
        and   p_effective_date between
                  nvl(effective_start_date,p_effective_date)
              and nvl(effective_start_date,p_effective_date);

        cursor csr_consolidation_set
        is
        select CONSOLIDATION_SET_NAME
        from   PAY_CONSOLIDATION_SETS
        where  CONSOLIDATION_SET_ID   = l_consolidation_set_id;

        cursor csr_assignment_set is
        select ASSIGNMENT_SET_NAME
        from   HR_ASSIGNMENT_SETS_V
        where  ASSIGNMENT_SET_ID =l_assignment_set_id;

        l_effective_date date;
   begin
        begin
             select effective_date into l_effective_date
             from   fnd_sessions
             where  SESSION_ID = userenv('sessionid');
        exception
        when Others then
             l_effective_date := sysdate;
        end;
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'PAYROLL',
         p_token_value                 => l_payroll_id);
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'PERSON',
         p_token_value                 => l_person_id);
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'CONSOLIDATION_SET',
         p_token_value                 => l_consolidation_set_id);
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'TAX_REFERENCE',
         p_token_value                 => l_tax_reference);
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'ASSIGNMENT_SET_ID',
         p_token_value                 => l_assignment_set_id);
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'BENEFIT_START_DATE',
         p_token_value                 => l_benefit_start_date);
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'BENEFIT_END_DATE',
         p_token_value                 => l_benefit_end_date);
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'Rep_Run',
         p_token_value                 => l_rep_run);
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'Status',
         p_token_value                 => l_status_code);
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'Run_Type',
         p_token_value                 => l_run_type_code);
        l_run_type_meaning := get_lookup_meaning('GB_P11D_RUN_TYPE',
                                                 l_run_type_code,
                                                 fnd_date.canonical_to_date(l_benefit_end_date));
        l_status_meaning := get_lookup_meaning('GB_P11D_LEGISLATIVE_RUN_STATUS',
                                               l_status_code,
                                               fnd_date.canonical_to_date(l_benefit_end_date));
        l_return_string := l_rep_run || '   ' || l_run_type_meaning || '   '  ||
                           l_status_meaning ||  '   ' ||
                           fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_benefit_start_date))||
                           '/' ||
                          fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_benefit_end_date));

        if l_payroll_id is not null
        then
            open csr_payroll(l_effective_date);
            fetch csr_payroll into l_payroll;
            close csr_payroll;
            l_return_string := l_return_string || l_payroll || '/';
        else
            l_return_string := l_return_string || '/';
        end if;

        if l_person_id is not null
        then
            open csr_person(l_effective_date);
            fetch csr_person into l_person;
            close csr_person;
            l_return_string := l_return_string || l_person || '/' ;
        else
            l_return_string := l_return_string || '/';
        end if;

        if l_tax_reference is not null
        then
            l_return_string := l_return_string || l_tax_reference || '/' ;
        else
            l_return_string := l_return_string || '/';
        end if;

        if l_consolidation_set_id is not null
        then
            open csr_consolidation_set;
            fetch csr_consolidation_set into l_consolidation_set;
            close csr_consolidation_set;
            l_return_string := l_return_string || l_consolidation_set || '/' ;
        else
            l_return_string := l_return_string || '/' ;
        end if;

        if l_assignment_set_id is not null
        then
            open csr_assignment_set;
            fetch csr_assignment_set into l_assignment_set;
            close csr_assignment_set;
            l_return_string := l_return_string || l_assignment_set ;
        end if;
        return l_return_string;
   end;

   function fetch_leg_process_status(p_payroll_action_id in  Number) return varchar2
   is
        l_benefit_end_date   VARCHAR2(20);
        l_benefit_start_date VARCHAR2(20);
        l_status_code        varchar2(10);
        l_status_meaning     varchar2(20);
   begin
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'BENEFIT_END_DATE',
         p_token_value                 => l_benefit_end_date);
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'Status',
         p_token_value                 => l_status_code);
        l_status_meaning := get_lookup_meaning('GB_P11D_LEGISLATIVE_RUN_STATUS',
                                               l_status_code,
                                               fnd_date.canonical_to_date(l_benefit_end_date));
        return l_status_meaning;
   end;

   function fetch_leg_process_runtype(p_payroll_action_id in  Number) return varchar2
   is
        l_benefit_end_date            VARCHAR2(20);
        l_run_type_code               varchar2(10);
        l_run_type_meaning            varchar2(20);
   begin
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'BENEFIT_END_DATE',
         p_token_value                 => l_benefit_end_date);
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'Run_Type',
         p_token_value                 => l_run_type_code);
        l_run_type_meaning := get_lookup_meaning('GB_P11D_RUN_TYPE',
                                                 l_run_type_code,
                                                 fnd_date.canonical_to_date(l_benefit_end_date));
        return l_run_type_meaning;
   end;

   function fetch_leg_process_notes(p_payroll_action_id in  Number) return varchar2
   is
        l_notes            VARCHAR2(200);
   begin
        -- we know notes is the last parameter hence we are using simple substr
        -- to fetch it's value
        -- if we add further params then the below would not work!
        select substr(legislative_parameters,
               instr(legislative_parameters, 'NOTES=') + (length('NOTES=')))
        into  l_notes
        from  pay_payroll_actions
        where payroll_action_id = p_payroll_action_id;
        return l_notes;
   exception
   when others then
        l_notes := null;
        return l_notes;
   end;

   function get_pactid(p_assignment_action_id NUmber) return number
   is
        cursor csr_pactid
        is
        select payroll_action_id
        from   pay_assignment_actions
        where  assignment_action_id = p_assignment_action_id;
        l_pactid number;
   begin
        open csr_pactid ;
        fetch csr_pactid into l_pactid;
        close csr_pactid ;
        return l_pactid;
   end;

   function get_person_id (p_assignment_action_id NUmber) return number
   is
        cursor csr_person_id
        is
        select action_information1
        from  pay_action_information pai_person
        where pai_person.action_context_id = p_assignment_action_id
        and   pai_person.action_information_category = 'ADDRESS DETAILS'
        and   pai_person.action_information14 = 'Employee Address';
        l_person_id number;
   begin
        open csr_person_id ;
        fetch csr_person_id into l_person_id;
        close csr_person_id ;
        return l_person_id;
   end;

   procedure get_employer_details(p_assignment_action_id Number,
                                  p_emp_ref_no out nocopy  varchar2,
                                  p_employer_name out nocopy varchar2)
   is
        cursor csr_employer_details
        is
        select action_information6,
               action_information7
        from   pay_action_information pai_comp
        where  pai_comp.action_context_id = p_assignment_action_id
        and    pai_comp.action_information_category = 'EMEA PAYROLL INFO';
   begin
        open  csr_employer_details;
        fetch csr_employer_details into p_emp_ref_no,
                                        p_employer_name;
        close csr_employer_details;
   end;

   --P11D 08/09
   -- Procedure to fetch the sur and fore names
   PROCEDURE get_sur_fore_names(p_assignment_action_id in NUMBER,
                                p_sur_name out nocopy VARCHAR2,
                                p_fore_name out nocopy VARCHAR2) IS

   cursor cur_sur_fore_name(c_assignment_action_id NUMBER) is

   select action_information6,
          action_information8
   from  pay_action_information pai_gb
   where pai_gb.action_context_id = c_assignment_action_id
   and   pai_gb.action_context_type = 'AAP'
   and   pai_gb.action_information_category = 'GB EMPLOYEE DETAILS';

   begin

   open cur_sur_fore_name(p_assignment_action_id);
   fetch  cur_sur_fore_name into p_fore_name,p_sur_name;
   close cur_sur_fore_name;
   END;

   procedure get_employee_details(p_assignment_action_id Number,
                                  p_full_name out nocopy  varchar2,
                                  p_national_ins_no out nocopy  varchar2,
                                  p_employee_number out nocopy varchar2)
   is
        cursor csr_employee_details
        is
        select action_information1,
               action_information4,
               action_information10
        from   pay_action_information pai_emp
        where  pai_emp.action_context_id = p_assignment_action_id
        and    pai_emp.action_information_category = 'EMPLOYEE DETAILS';
   begin
        open  csr_employee_details;
        fetch csr_employee_details into p_full_name,
                                        p_national_ins_no,
                                        p_employee_number;
        close csr_employee_details;
   end;

   function fetch_ws1_ref_cursor (p_assignment_action_id Number,
                                  p_record_num out nocopy NUmber) return ref_cursor_typ
   is
        -- per_gb_xfdftableType is explicitly created type
        -- only modification needed is it could be of type blob
        -- i tried thta but could not access the blob valus in java routine.
        -- can be sorted later
        l_xfdf_str_tab per_gb_xfdftableType := per_gb_xfdftableType( );
        l_xfdf_str varchar2(32000);
        l_ret_ref_cursor ref_cursor_typ;
        l_offset integer;
        l_varchar_buffer varchar2(32000);
        l_raw_buffer raw(32000);
        l_buffer_len number:= 32000;
        l_chunk_len number;

        cursor csr_context_id (p_pactid    NUMBER,
                               p_person_id NUMBER,
                               p_emp_ref   VARCHAR2,
                               p_emp_name  VARCHAR2)
        is
        select /*+ ORDERED use_nl(ppa, paa, pai_comp, pai_person, pai_car)
                           use_index(pai_comp,pay_action_information_n2)
                           use_index(pai_person,pay_action_information_n2)
                           use_index(pai_car,pay_action_information_n2) */
               pai_car.action_context_id
        from   pay_payroll_actions ppa,
               pay_assignment_actions paa,
               pay_action_information pai_comp,
               pay_action_information pai_person,
               pay_action_information pai_car
        where  ppa.payroll_action_id = p_pactid
        and    paa.payroll_action_id = ppa.payroll_action_id
        and    pai_comp.action_context_id = paa.assignment_action_id
        and    pai_comp.action_information_category = 'EMEA PAYROLL INFO'
        and    pai_comp.action_context_type = 'AAP'
        and    pai_person.action_context_id = paa.assignment_action_id
        and    pai_person.action_information_category = 'ADDRESS DETAILS'
        and    pai_person.action_context_type = 'AAP'
        and    pai_person.action_information14 = 'Employee Address'
        and    pai_person.action_information1 = to_char(p_person_id)
        and    pai_comp.action_information6 = p_emp_ref
        and    pai_comp.action_information7 = p_emp_name
        and    pai_car.action_context_id = paa.assignment_action_id
        and    pai_car.action_information_category = 'LIVING ACCOMMODATION'
        and    pai_car.action_context_type = 'AAP'
        group by pai_car.action_context_id;

        cursor csr_living_acco (p_context_id NUMBER)
        is
        select pai_ben.ACTION_INFORMATION5 address,
               decode(months_between(
                fnd_date.canonical_to_date(pai_ben.action_information4)+1,
                fnd_date.canonical_to_date(pai_ben.action_information3)),12,'Y','N') full_year,
               to_char(to_number(nvl(pai_ben.action_information6,0)),'FM999,999,990.00') rent_employer,
               to_char(to_number(nvl(pai_ben.action_information7,0)),'FM999,999,990.00') annual_value,
               to_char(to_number(nvl(pai_ben.action_information18,0)),'FM999,999,990.00')Basic_Charge_Cost,
               to_char(to_number(nvl(pai_ben.action_information9,0)),'FM999,999,990.00') amg,
               to_char(to_number(nvl(pai_ben.action_information19,0)),'FM999,999,990.00')Basic_Charge,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information8,0)),'FM999,999,990.00'),null)gross_amount,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information13,0)),'FM999,999,990.00'),null) emp_share_of_cost,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information20,0)),'FM999,999,990.00'),null) cost_of_acco,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information22,0)),'FM999,999,990.00'),null) excess_of_cost,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information14,0)),'FM999,999,990.00'),null) INTEREST_VALUE,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information21,0)),'FM999,999,990.00'),null) INTEREST_AMOUNT,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information16,0)),'FM999,999,990.00'),null) rent_employee,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information9,0)),'FM999,999,990.00'),null) RENT_IN_AMG,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information17,0)),'FM999,999,990.00'),null) ADDITIONAL_CHARGE,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information19,0)),'FM999,999,990.00'),null) BASIC_CHARGE_2,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information16,0) - nvl(pai_ben.action_information9,0)),'FM999,999,990.00'),null) ACTUAL_RENT,
               decode(sign(pai_ben.action_information22),1,to_char(to_number(
                   nvl(pai_ben.action_information19,0)+nvl(pai_ben.action_information17,0)),'FM999,999,990.00'),null) TOTAL ,
               decode(sign(pai_ben.action_information22),
                      1,decode(months_between(
                        fnd_date.canonical_to_date(pai_ben.action_information4)+1,
                        fnd_date.canonical_to_date(pai_ben.action_information3)),12,null,
                      to_char(to_number(nvl(pai_ben.action_information15,0)))),null) NUMBER_OF_DAYS
        from  pay_action_information pai_ben
        where pai_ben.action_information_category = 'LIVING ACCOMMODATION'
        and   pai_ben.action_context_id = p_context_id
        and   pai_ben.action_context_type = 'AAP';

        l_emp_ref_no varchar2(150);
        l_employer_name varchar2(150);
        l_full_name varchar2(150);
        l_sur_name varchar2(150); -- P11D 08/09
        l_fore_name varchar2(150); -- P11D 08/09
        l_national_ins_no varchar2(150);
        l_employee_number varchar2(150);
        l_pactid number;
        l_person_id number;
        l_loop_count Number;
  begin
        get_employer_details(p_assignment_action_id,
                             l_emp_ref_no,
                             l_employer_name);
        get_employee_details(p_assignment_action_id,
                             l_full_name,
                             l_national_ins_no,
                             l_employee_number);
        -- P11D 08/09
        -- Fetch sur and fore names
        get_sur_fore_names(p_assignment_action_id,
                           l_sur_name,
                           l_fore_name);
        -- P11D 08/09
        l_pactid := get_pactid(p_assignment_action_id);
        l_person_id := get_person_id(p_assignment_action_id );
        l_loop_count := 0;
        for context_rec in csr_context_id(l_pactid,
                                          l_person_id,
                                          l_emp_ref_no,
                                          l_employer_name) loop
        for living_acco in  csr_living_acco(context_rec.action_context_id)
        loop
            l_loop_count := l_loop_count+1;
            l_xfdf_str_tab.extend;
            l_employee_number := get_assignment_number(context_rec.action_context_id);
            l_xfdf_str_tab(l_loop_count) := '<?xml version = "1.0" encoding = "UTF-8"?>
            <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
            <fields> ' ||
           ' <field name="'||'EMPLOYERS_NAME'||'"><value>' ||replace(l_employer_name,'&','&amp;') || '</value></field> ' ||
           ' <field name="'||'FULL_NAME'||'"><value>' ||l_full_name || '</value></field>  ' ||
           -- P11D 08/09
           ' <field name="'|| 'SUR_NAME' ||'"><value>' ||l_sur_name  || '</value></field> ' ||
           ' <field name="'|| 'FORE_NAME'||'"><value>' ||l_fore_name || '</value></field> ' ||
           -- P11D 08/09
           ' <field name="'||'EMPLOYERS_REF_NO'||'"><value>' ||l_emp_ref_no || '</value></field>  ' ||
           ' <field name="'||'EMPLOYEE_NUMBER'||'"><value>' ||l_employee_number || '</value></field>  ' ||
           -- ' <field name="'||'NATIONAL_INS_NO'||'"><value>' ||l_national_ins_no || '</value></field>  ' ||
           ' <field name="'||'NI_1'||'"><value>' ||substr(l_national_ins_no,1,1) || '</value></field>  ' ||
           ' <field name="'||'NI_2'||'"><value>' ||substr(l_national_ins_no,2,1) || '</value></field>  ' ||
           ' <field name="'||'NI_3'||'"><value>' ||substr(l_national_ins_no,3,1) || '</value></field>  ' ||
           ' <field name="'||'NI_4'||'"><value>' ||substr(l_national_ins_no,4,1) || '</value></field>  ' ||
           ' <field name="'||'NI_5'||'"><value>' ||substr(l_national_ins_no,5,1) || '</value></field>  ' ||
           ' <field name="'||'NI_6'||'"><value>' ||substr(l_national_ins_no,6,1) || '</value></field>  ' ||
           ' <field name="'||'NI_7'||'"><value>' ||substr(l_national_ins_no,7,1) || '</value></field>  ' ||
           ' <field name="'||'NI_8'||'"><value>' ||substr(l_national_ins_no,8,1) || '</value></field>  ' ||
           ' <field name="'||'NI_9'||'"><value>' ||substr(l_national_ins_no,9) || '</value></field>  '   ||
           ' <field name="'||'ADDRESS'||'"><value>' ||living_acco.address || '</value></field>  ' ||
           ' <field name="'||'FULL_YEAR'||'"><value>' ||living_acco.full_year || '</value></field>  ' ||
           ' <field name="'||'FULL_YEAR_Y'||'"><value>' ||living_acco.full_year || '</value></field>  ' ||
           ' <field name="'||'FULL_YEAR_N'||'"><value>' ||living_acco.full_year || '</value></field>  ' ||
           ' <field name="'||'RENT_EMPLOYER'||'"><value>' ||living_acco.rent_employer || '</value></field>  ' ||
           ' <field name="'||'ANNUAL_VALUE'||'"><value>' ||living_acco.annual_value || '</value></field>  ' ||
           ' <field name="'||'BASIC_CHARGE_COST'||'"><value>' ||living_acco.Basic_Charge_Cost || '</value></field>  ' ||
           ' <field name="'||'AMG'||'"><value>' ||living_acco.amg || '</value></field>  ' ||
           ' <field name="'||'BASIC_CHARGE'||'"><value>' ||living_acco.Basic_Charge || '</value></field>  ' ||
           ' <field name="'||'GROSS_AMOUNT'||'"><value>' ||living_acco.gross_amount || '</value></field>  ' ||
           ' <field name="'||'EMP_SHARE_OF_COST'||'"><value>' ||living_acco.emp_share_of_cost || '</value></field>  ' ||
           ' <field name="'||'COST_OF_ACCO'||'"><value>' ||living_acco.cost_of_acco || '</value></field>  ' ||
           ' <field name="'||'EXCESS_OF_COST'||'"><value>' ||living_acco.excess_of_cost || '</value></field>  ' ||
           ' <field name="'||'INTEREST_VALUE'||'"><value>' ||living_acco.INTEREST_VALUE || '</value></field>  ' ||
           ' <field name="'||'NUMBER_OF_DAYS'||'"><value>' ||living_acco.NUMBER_OF_DAYS || '</value></field>  ' ||
           ' <field name="'||'INTEREST_AMOUNT'||'"><value>' ||living_acco.INTEREST_AMOUNT || '</value></field>  ' ||
           ' <field name="'||'RENT_EMPLOYEE'||'"><value>' ||living_acco.rent_employee || '</value></field>  ' ||
           ' <field name="'||'RENT_IN_AMG'||'"><value>' ||living_acco.RENT_IN_AMG || '</value></field>  ' ||
           ' <field name="'||'ACTUAL_RENT'||'"><value>' ||living_acco.ACTUAL_RENT || '</value></field>  ' ||
           ' <field name="'||'ADDITIONAL_CHARGE'||'"><value>' ||living_acco.ADDITIONAL_CHARGE || '</value></field>  ' ||
           ' <field name="'||'BASIC_CHARGE_2'||'"><value>' ||living_acco.BASIC_CHARGE_2 || '</value></field>  ' ||
           ' <field name="'||'TOTAL'||'"><value>' ||living_acco.TOTAL || '</value></field>  ' ||
           '</fields>  </xfdf>';
        end loop;
        end loop;
        open l_ret_ref_cursor for
        select *
        from table (cast(l_xfdf_str_tab as per_gb_xfdftableType));
        p_record_num := l_loop_count;
        return l_ret_ref_cursor;
   end ;

-------------------------------------------------------------------------------------------
-- Function: rep_assignment_actions
-- Description: Create a cursor depending on the parameters that are passed in
--              and return the cursor to calling procedure (eg PER_P11d_PAPER_REP)
--              using a Ref Cursor
-------------------------------------------------------------------------------------------
   function rep_assignment_actions(p_payroll_action_id Number,
                                   p_assignment_action_id  Number,
                                   p_organization_id Number,
                                   p_location_code Varchar2,
                                   p_org_hierarchy Number,
                                   p_assignment_set_id Number,
                                   p_sort_order1 Varchar2,
                                   p_sort_order2 Varchar2,
                                   p_chunk_size  Number,
                                   p_chunk_number Number,
                                   p_person_type Varchar2) return ref_cursor_typ
   is
        l_ret_ref_cursor ref_cursor_typ;
        l_select varchar2(500);
        l_from   varchar2(500);
        l_where  varchar2(10000);
        l_group  varchar2(200);
        l_order  varchar2(100);
        l_sql    varchar2(15000);
        l_payroll_action_id Number;
        l_assignment_action_id  Number;
        l_organization_id Number;
        l_location_code Varchar2(100);
        l_org_hierarchy Number;
        l_assignment_set_id Number;
        l_sort_order1 Varchar2(100);
        l_sort_order2 Varchar2(100);
        l_pay_effective_date date;
        l_start    number;
        l_end      number;
        l_person_type Varchar2(20);
       --
        cursor pay_effective_date(c_payroll_action_id in number)
        is
        select pay.effective_date
        from   pay_payroll_actions pay
        where  pay.payroll_action_id = c_payroll_action_id;
     --
   begin
        if p_payroll_action_id = 0
        then
            l_payroll_action_id :=null;
        else
            l_payroll_action_id := p_payroll_action_id;
            --
            open pay_effective_date(l_payroll_action_id);
            fetch pay_effective_date into l_pay_effective_date;
            close pay_effective_date;
        end if;

        if p_assignment_action_id = 0
        then
            l_assignment_action_id := null;
        else
            l_assignment_action_id :=p_assignment_action_id;
        end if;

        if p_location_code = '0'
        then
            l_location_code :=null;
        else
            l_location_code :=p_location_code;
        end if;

        if p_org_hierarchy = 0
        then
            l_org_hierarchy :=null;
        else
            l_org_hierarchy :=p_org_hierarchy;
        end if;

        if p_assignment_set_id = 0
        then
            l_assignment_set_id :=null;
        else
            l_assignment_set_id :=p_assignment_set_id;
        end if;

        if p_sort_order1 = '0'
        then
            l_sort_order1 :=null;
        else
            l_sort_order1 :=p_sort_order1;
        end if;

        if p_sort_order2 = '0'
        then
            l_sort_order2 :=null;
        else
            l_sort_order2 :=p_sort_order2;
        end if;

        if p_person_type = '0'
        then
            l_person_type := null;
        else
            l_person_type := p_person_type;
        end if;

    /* since this query is fired just once in a session,
    instead of using the using clause,
    we are going to create the sql stmt by concatenating the values
    below is the example of it being dynamic
    */
 -- All above Commented out, start proper code here..
 --
        l_select := 'select asg_id
                     from (select asg_id, rownum as row_num
                           from (select /*+ ORDERED use_nl(paa,paf,emp,pai_payroll)
                                            use_index(pai_person,pay_action_information_n2)
                                            use_index(pai,pay_action_information_n2) */
                                        paf.person_id, max(paa.assignment_action_id) as asg_id ';
        l_from   := 'from   pay_assignment_actions paa,
                            per_all_assignments_f  paf,
                            pay_action_information emp,
                            pay_action_information pai_payroll ';
        l_where  := 'where  paa.payroll_action_id = ' || l_payroll_action_id || '
                     and    paa.action_status = ''C''
                     and    paa.assignment_id = paf.assignment_id
                     and    emp.action_information_category = ''EMPLOYEE DETAILS''
                     and    emp.action_context_id = paa.assignment_action_id
                     and    emp.action_context_type = ''AAP''
                     and    pai_payroll.action_information_category = ''GB EMPLOYEE DETAILS''
                     and    pai_payroll.action_context_id = paa.assignment_action_id
                     and    pai_payroll.action_context_type = ''AAP'' ';
        if l_assignment_action_id is not null
        then
            l_where :=  l_where || 'and   paa.assignment_action_id = ' || l_assignment_action_id ;
        end if;

        if l_person_type is not null
        then
            l_from := l_from || ' ,per_all_people_f pap
                                  ,per_person_types ppt ';
            l_where := l_where || 'and    pap.person_id = paf.person_id
                                   and    pap.person_type_id = ppt.person_type_id
                                   and    ppt.system_person_type = ''EX_EMP'' ';
        end if;

        if l_organization_id is not null
        then
            l_where := l_where || ' and   emp.action_information2 = ' || l_organization_id ;
        end if;

        if l_location_code is not null
        then
            l_where := l_where || ' and   nvl(emp.action_information30,''0'')= ''' || l_location_code || ''' ' ;
        end if;

        if l_org_hierarchy is not null
        then
            l_where := l_where || ' and   emp.action_information2 in(select organization_id_child
                                                                     from   per_org_structure_elements
                                                                     where  business_group_id = ' || l_org_hierarchy ||
                                                                   ' union
                                                                     select ' || l_org_hierarchy  || ' from dual)';
        end if;

        if l_assignment_set_id is not null
        then
            l_from := l_from  || ',hr_assignment_sets has
                                  ,hr_assignment_set_amendments hasa ';
            l_where := l_where ||
                        ' and    has.assignment_set_id  = ' || l_assignment_set_id ||
                        ' and    has.assignment_set_id = hasa.assignment_set_id(+)
                          and    ((    has.payroll_id is null
                                   and hasa.include_or_exclude = ''I''
                                   and hasa.assignment_id = paa.assignment_id
                                  )
                                  OR
                                 (     has.payroll_id is not null
                                   and has.payroll_id  = pai_payroll.ACTION_INFORMATION5
                                   and nvl(hasa.include_or_exclude, ''I'') = ''I''
                                   and nvl(hasa.assignment_id, paa.assignment_id) = paa.assignment_id
                                )) ';
        end if;

        l_group  := ' group by paf.person_id, pai_payroll.action_information13 ';

        if l_sort_order1 is not null
        then
            if l_sort_order1 = 'NAME'
            then
                l_order := ' ORDER BY emp.action_information1';
                l_select := l_select || ',emp.action_information1 ';
                l_group  := l_group || ',emp.action_information1 ';
            elsif l_sort_order1 = 'NUMBER'
            then
                l_order := ' ORDER BY emp.action_information10';
                l_select := l_select || ',emp.action_information10 ';
                l_group  := l_group || ',emp.action_information10 ';
            end if;
        else -- sort order 1 is null
            if l_sort_order2 is not null
            then
                if l_sort_order2 = 'NAME'
                then
                    l_order := ' ORDER BY emp.action_information1';
                    l_select := l_select || ',emp.action_information1 ';
                    l_group  := l_group || ',emp.action_information1 ';
                elsif l_sort_order2 = 'NUMBER'
                then
                    l_order := ' ORDER BY emp.action_information10';
                    l_select := l_select || ',emp.action_information10 ';
                    l_group  := l_group || ',emp.action_information10 ';
                end if;
            else -- sort order 2 is also null!
                l_order := ' ORDER BY emp.action_information1';
                l_select := l_select || ',emp.action_information1 ';
                l_group  := l_group || ',emp.action_information1 ';
            end if;
        end if;

        l_start := ((p_chunk_number * p_chunk_size) - p_chunk_size) + 1;
        l_end   := (p_chunk_number * p_chunk_size);
        l_order := l_order || ')) where row_num between ' || l_start || ' and ' || l_end;
        /****************************************************************************/
        l_sql :=  l_select || l_from || l_where || l_group || l_order;

        open l_ret_ref_cursor
        for l_sql;

        return l_ret_ref_cursor;
   --
   end rep_assignment_actions;
--------------------------------------------------------------------------------------------
   function fetch_ws2_ref_cursor (p_assignment_action_id Number,
                                  p_record_num out nocopy NUmber) return ref_cursor_typ
   is
        -- per_gb_xfdftableType is explicitly created type
        -- only modification needed is it could be of type blob
        -- i tried thta but could not access the blob valus in java routine.
        -- can be sorted later
        l_xfdf_str_tab per_gb_xfdftableType := per_gb_xfdftableType( );
        l_xfdf_str varchar2(32000);
        l_ret_ref_cursor ref_cursor_typ;
        l_offset integer;
        l_varchar_buffer varchar2(32000);
        l_raw_buffer raw(32000);
        l_buffer_len number:= 32000;
        l_chunk_len number;
        l_car_max_price number;

        cursor csr_engine_discount(p_size number,
                                   p_date date) is
        select to_number(i.value)
        from   pay_user_tables t,
               pay_user_rows_f r,
               pay_user_columns c,
               pay_user_column_instances_f i
        where  t.user_table_name = 'GB_CC_SCALE'
        and    t.user_table_id = r.user_table_id
        and    t.user_table_id = c.user_table_id
        and    c.user_column_name = 'BEFORE_JAN_1_1998'
        and    i.user_row_id = r.user_row_id
        and    i.user_column_id = c.user_column_id
        and    p_size between to_number(r.row_low_range_or_name) and to_number(r.row_high_range)
        and    p_date between r.effective_start_date and r.effective_end_date
        and    p_date between i.effective_start_date and i.effective_end_date;

        cursor csr_context_id (p_pactid    NUMBER,
                               p_person_id NUMBER,
                               p_emp_ref   VARCHAR2,
                               p_emp_name  VARCHAR2,
                               p_category  VARCHAR2)
        is
        select /*+ ORDERED use_nl(ppa, paa, pai_comp, pai_person, pai_car)
                           use_index(pai_comp,pay_action_information_n2)
                           use_index(pai_person,pay_action_information_n2)
                           use_index(pai_car,pay_action_information_n2) */
               pai_car.action_context_id
        from   pay_payroll_actions ppa,
               pay_assignment_actions paa,
               pay_action_information pai_comp,
               pay_action_information pai_person,
               pay_action_information pai_car
        where  ppa.payroll_action_id = p_pactid
        and    paa.payroll_action_id = ppa.payroll_action_id
        and    pai_comp.action_context_id = paa.assignment_action_id
        and    pai_comp.action_information_category = 'EMEA PAYROLL INFO'
        and    pai_comp.action_context_type = 'AAP'
        and    pai_person.action_context_id = paa.assignment_action_id
        and    pai_person.action_information_category = 'ADDRESS DETAILS'
        and    pai_person.action_context_type = 'AAP'
        and    pai_person.action_information14 = 'Employee Address'
        and    pai_person.action_information1 = to_char(p_person_id)
        and    pai_comp.action_information6 = p_emp_ref
        and    pai_comp.action_information7 = p_emp_name
        and    pai_car.action_context_id = paa.assignment_action_id
        and    pai_car.action_information_category = p_category
        and    pai_car.action_context_type = 'AAP'
        group by pai_car.action_context_id;

        cursor csr_car_entries (p_context_id Number)
        is
        select pai_emp.action_information3 ben_start,
               pai_emp.action_information4 ben_end,
               decode(months_between(
                fnd_date.canonical_to_date(pai_emp.action_information4)+1,
                fnd_date.canonical_to_date(pai_emp.action_information3)),12,'Y','N') FULL_YR_FLAG,
               -- pai_emp.ACTION_INFORMATION5,
               pai_emp.action_information6 make,
               pai_emp.action_information7 model,
               pai_emp.action_information8 date_registered,
               substr(pai_emp.action_information8,9,2) || '/' ||
               substr(pai_emp.action_information8,6,2) || '/' ||
               substr(pai_emp.action_information8,1,4) f_dreg,
               pai_emp.action_information13 CO2,
               substr(pai_emp.action_information3,9,2) || '/' ||
               substr(pai_emp.action_information3,6,2) || '/' ||
               substr(pai_emp.action_information3,1,4) f_start,
               substr(pai_emp.action_information4,9,2) || '/' ||
               substr(pai_emp.action_information4,6,2) || '/' ||
               substr(pai_emp.action_information4,1,4) f_end,
               to_char(to_number(nvl(pai_emp.action_information9,0)),'FM999,999,990.00') f_lprice,
               to_char(to_number(nvl(pai_emp.action_information10,0)),'FM999,999,990.00') f_cc,
               to_char(to_number(nvl(pai_emp.action_information11,0)),'FM999,999,990.00') f_fcc,
               decode( pai_emp.action_information12,'0',null,PAY_GB_P11D_MAGTAPE.get_description(
                     pai_emp.action_information12,'GB_FUEL_TYPE',pai_emp.action_information4)) f_fuel,
               -- DECODE(pai_emp.action_information13, NULL, 'On', 'Off') f_nfig,
               to_char(to_number(nvl(pai_emp.action_information16,0)),'FM999,999,990.00') f_oprice,
               to_char(to_number(nvl(pai_emp.action_information9,0) +nvl(pai_emp.action_information16,0)),
                      'FM999,999,990.00') TOTAL_INIT_PRICE,
               to_char(to_number(nvl(pai_emp.action_information17,0)),'FM999,999,990.00') f_aprice,
               to_char(to_number(nvl(pai_emp.action_information9,0) + nvl(pai_emp.action_information16,0) +
                      nvl(pai_emp.action_information17,0)),'FM999,999,990.00') TOTAL_PRICE,
               to_char(to_number(nvl(pai_emp.action_information18,0)),'FM999,999,990.00') f_cost,
               to_char(to_number(nvl(pai_emp.action_information9,0) + nvl(pai_emp.action_information16,0) +
                      nvl(pai_emp.action_information17,0) + nvl(pai_emp.action_information18,0)),
                      'FM999,999,990.00') FINAL_PRICE,
               to_char(to_number(nvl(pai_emp.action_information19,0)),'FM999,999,990.00') f_amg,
               pai_emp.action_information20 f_esize,
               to_char(to_number(nvl(pai_emp.action_information21,0)),'FM999,999,990.00') benefit_charge,
               to_char(to_number(nvl(pai_emp.action_information22,0)),'FM999,999,990') unavailable,
               to_char(to_number(nvl(pai_emp.action_information23,0)),'FM999,999,990.00') unavailable_value,
               to_char(to_number(nvl(pai_emp.action_information21,0) - nvl(pai_emp.action_information26,0) -
                      nvl(pai_emp.action_information27,0) - nvl(pai_emp.action_information23,0)),
                      'FM999,999,990.00') BENEFIT_AFTER_UNAVAIL,
               nvl(pai_emp.action_information24,'N') FUEL_BENEFIT,
               to_char(to_number(nvl(pai_emp.action_information25,0)),'FM999,999,990') BENEFIT_PERCENT,
               to_char(to_number(nvl(pai_emp.action_information26,0)),'FM999,999,990.00') STD_DISC,
               to_char(to_number(decode(pai_emp.action_information27,0,null,pai_emp.action_information27))
                      ,'FM999,999,990.00') ADD_DISC,
               to_char(to_number(decode(nvl(pai_emp.action_information27,0) +
                      nvl(pai_emp.action_information26,0),0,null, nvl(pai_emp.action_information27,0) +
                      nvl(pai_emp.action_information26,0))),'FM999,999,990.00') FULL_DISC,
               to_char(to_number(pai_emp.action_information28),'FM999,999,990.00') FUEL_SCALE,
               nvl(pai_emp.action_information21,0) ben_charge,
               nvl(pai_emp.action_information26,0) stand_disc,
               nvl(pai_emp.action_information27,0) additional_disc
        from   pay_action_information pai_emp
        where  pai_emp.action_information_category = 'CAR AND CAR FUEL'
        and    pai_emp.action_context_id = p_context_id
        and    pai_emp.action_context_type = 'AAP';

        cursor csr_car_entries_0304 (p_context_id Number)
        is
        select pai_emp.action_information3 ben_start,
               pai_emp.action_information4 ben_end,
               decode(
                  months_between(
                    fnd_date.canonical_to_date(pai_emp.action_information4)+1,
                    fnd_date.canonical_to_date(pai_emp.action_information3)),12,'Y','N') FULL_YR_FLAG,
                  --pai_emp.ACTION_INFORMATION5 co2,
               pai_emp.action_information6 make,
               pai_emp.action_information7 model,
               pai_emp.action_information8 date_registered,
               substr(pai_emp.action_information8,9,2) || ' ' ||
               substr(pai_emp.action_information8,6,2) || ' ' ||
               substr(pai_emp.action_information8,1,4) f_dreg,
               pai_emp.action_information13 co2,
               substr(pai_emp.action_information3,9,2) || ' ' ||
               substr(pai_emp.action_information3,6,2) || ' ' ||
               substr(pai_emp.action_information3,1,4) f_start,
               substr(pai_emp.action_information4,9,2) || ' ' ||
               substr(pai_emp.action_information4,6,2) || ' ' ||
               substr(pai_emp.action_information4,1,4) f_end,
               to_char(to_number(nvl(pai_emp.action_information9,0)),'FM999,999,990.00') f_lprice,
               to_char(to_number(nvl(pai_emp.action_information10,0)),'FM999,999,990.00') f_cc,
               to_char(to_number(nvl(pai_emp.action_information11,0)),'FM999,999,990.00') f_fcc,
               decode(pai_emp.action_information12,'0',null,PAY_GB_P11D_MAGTAPE.get_description(
                      pai_emp.action_information12,'GB_FUEL_TYPE',pai_emp.action_information4)) f_fuel,
               to_char(to_number(nvl(pai_emp.action_information15,0)),'FM999,999,990.00') f_oprice,
               to_char(to_number(nvl(pai_emp.action_information9,0) +
                      nvl(pai_emp.action_information15,0)),'FM999,999,990.00') TOTAL_INIT_PRICE,
               to_char(to_number(nvl(pai_emp.action_information16,0)),'FM999,999,990.00') f_cost,
               to_char(least(l_car_max_price,(to_number(nvl(pai_emp.action_information9,0) +
                       nvl(pai_emp.action_information15,0) -
                       nvl(pai_emp.action_information16,0)))),'FM999,999,990.00') FINAL_PRICE,
               to_char(to_number(nvl(pai_emp.action_information17,0)),'FM999,999,990.00') f_amg,
               pai_emp.action_information18 f_esize,
               to_char(to_number(nvl(pai_emp.action_information19,0)),'FM999,999,990') car_benefit_year,
               to_char(to_number(nvl(pai_emp.action_information20,0)),'FM999,999,990') unavailable,
               to_char(to_number(nvl(pai_emp.action_information21,0)),'FM999,999,990') unavailable_value,
               to_char(to_number(nvl(pai_emp.action_information19,0) -
                      nvl(pai_emp.action_information21,0)),'FM999,999,990.00') CAR_BENEFIT_AVAILABLE,
               to_char(to_number(nvl(pai_emp.action_information22,0)),'FM999,999,990') BENEFIT_PERCENT,
               to_char(to_number(nvl(pai_emp.action_information23,0)),'FM999,999,990') STD_DISC,
               to_char(to_number(nvl(pai_emp.action_information24,0)),'FM999,999,990') ROUND_NORMAL_CO2,
               -- Added substring function to get fuel benefit value from action_information25 (P11D 07/08 changes)
               nvl(substr(pai_emp.action_information25,1,instr(pai_emp.action_information25,':')-1),'N') FUEL_BENEFIT,
               to_char(to_number(pai_emp.action_information29),'FM999,999,990') FUEL_BENEFIT_YEAR,
               to_char(to_number(nvl(pai_emp.action_information23,0) +
                      nvl(pai_emp.action_information24,0)),'FM999,999,990') FULL_DISC,
               to_char(to_number(nvl(pai_emp.action_information22,0) -
                      nvl(pai_emp.action_information23,0) -
                      nvl(pai_emp.action_information24,0)), 'FM999,999,990') TOTAL_BENIFIT,
               to_char(to_number(nvl(pai_emp.action_information22,0) -
                      nvl(pai_emp.action_information23,0)),   'FM999,999,990') TOTAL_BENIFIT_2,
               decode (pai_emp.action_information26,null,null,
                      decode ( pai_emp.action_information27,'Y',null,
                      substr(pai_emp.action_information26,9,2) || ' ' ||
                      substr(pai_emp.action_information26,6,2) || ' ' ||
                      substr(pai_emp.action_information26,1,4))) f_withdraw,
               to_char(to_number(nvl(pai_emp.action_information28,0))) additional_days,
               decode (pai_emp.action_information26,null,to_char(to_number(nvl(pai_emp.action_information20,0))),
                      to_char(to_number(nvl(pai_emp.action_information20,0) +
                      nvl(pai_emp.action_information28,0)) ) ) total_days ,
               to_char(to_number(nvl(pai_emp.action_information30,0)),'FM999,999,990') fuel_unavailable
        from   pay_action_information pai_emp
        where  pai_emp.action_information_category = 'CAR AND CAR FUEL 2003_04'
        and    pai_emp.action_context_id = p_context_id
        and    pai_emp.action_context_type = 'AAP';

        -- car_rec csr_car_entries%rowtype;
        l_BEN_ST_DATE  varchar2(20);
        l_BEN_ED_DATE  varchar2(20);
        l_car_count    number;
        l_ONLY_CAR_FLAG varchar2(5);
        l_FUEL_FLAG varchar2(5);
        l_fuel_scale varchar2(20);
        l_FUEL_BENEFIT_YEAR VARCHAR2 (20);
        l_CAR_NUMBERS  number;
        l_MOD_CO2     number;
        l_PERCENT_1  varchar2(20);
        l_BEN_1      varchar2(20);
        l_PERCENT_2  varchar2(20);
        l_BEN_2 varchar2(20);
        l_PERCENT_3 varchar2(20);
        l_BEN_3 varchar2(20);
        l_PERCENT_4 varchar2(20);
        l_BEN_4 varchar2(20);
        l_BEN_5 varchar2(20);
        l_STD_DISC_1 varchar2(20);
        l_STD_DISC_2 varchar2(20);
        l_STD_DISC_3 varchar2(20);
        l_STD_DISC_4 varchar2(20);
        l_STD_DISC_5 varchar2(20);
        l_full_DISC varchar2(20);
        l_EXTRA_CO2  number;
        l_NORMAL_CO2  number;
        l_ROUND_NORMAL_CO2  number;
        l_CAR_BENEFIT_1  Number;
        l_CAR_BENEFIT_2  Number;
        l_CAR_BENEFIT_3  Number;
        -- ,4,5 can be varchar2 as these are not calc and are just read from benefit
        --charge
        l_CAR_BENEFIT_4  varchar2(20);
        l_CAR_BENEFIT_5  varchar2(20);
        l_CAR_BENEFIT_6  varchar2(20); -- P11D 08/09
        l_emp_ref_no varchar2(150);
        l_employer_name varchar2(150);
        l_full_name varchar2(150);
        l_sur_name varchar2(150); --  P11D 08/09
        l_fore_name varchar2(150); -- P11D 08/09
        l_national_ins_no varchar2(150);
        l_employee_number varchar2(150);
        l_pactid number;
        l_person_id number;
        l_loop_count Number;
        l_esize varchar2(20);
        l_UNAVIALABLE_VAL_2 varchar2(20);
        l_rep_run varchar2(10);
        l_add_days varchar2(10);
        l_tot_days varchar2(10);
        l_unavailble_days varchar2(10);
   begin
        get_employer_details(p_assignment_action_id,
                             l_emp_ref_no,
                             l_employer_name);
        get_employee_details(p_assignment_action_id,
                             l_full_name,
                             l_national_ins_no,
                             l_employee_number);
        -- P11D 08/09
        -- Fetch sur and fore names
        get_sur_fore_names(p_assignment_action_id,
                           l_sur_name,
                           l_fore_name);
        -- P11D 08/09
        l_pactid := get_pactid(p_assignment_action_id);
        l_person_id := get_person_id (p_assignment_action_id );
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => l_pactid,
         p_token_name                  => 'Rep_Run',
         p_token_value                 => l_rep_run);

        select to_number(global_value)
        into  l_car_max_price
        from  ff_globals_f
        where global_name = 'NI_CAR_MAX_PRICE'
        and   to_date('05-04-' || l_rep_run,'DD-MM-YYYY') between effective_start_date and effective_end_date;

        l_loop_count := 0;
        if l_rep_run = '2003'
        then
            for context_rec in csr_context_id(l_pactid,
                                              l_person_id,
                                              l_emp_ref_no,
                                              l_employer_name,
                                              'CAR AND CAR FUEL') loop
            for car_rec in  csr_car_entries(context_rec.action_context_id)
            loop
                l_loop_count := l_loop_count+1;
                -- Initialising the vars to null;
                l_BEN_ST_DATE  := null;
                l_BEN_ED_DATE  := null;
                l_car_count    := null;
                l_ONLY_CAR_FLAG :=null;
                l_FUEL_FLAG :=null;
                l_CAR_NUMBERS  := null;
                l_MOD_CO2     := null;
                l_PERCENT_1  := null;
                l_BEN_1      := null;
                l_PERCENT_2  := null;
                l_BEN_2 := null;
                l_PERCENT_3 := null;
                l_BEN_3 := null;
                l_PERCENT_4 := null;
                l_BEN_4 := null;
                l_BEN_5 := null;
                l_STD_DISC_1 := null;
                l_STD_DISC_2 := null;
                l_STD_DISC_3 := null;
                l_STD_DISC_4 := null;
                l_STD_DISC_5 := null;
                l_full_DISC  := null;
                l_EXTRA_CO2  := null;
                l_NORMAL_CO2  := null;
                l_ROUND_NORMAL_CO2  := null;
                l_CAR_BENEFIT_1  := null;
                l_CAR_BENEFIT_2  := null;
                l_CAR_BENEFIT_3  := null;
                l_CAR_BENEFIT_4  := null;
                l_CAR_BENEFIT_5  := null;
                l_full_DISC := car_rec.FULL_DISC;
                if car_rec.FULL_YR_FLAG = 'Y'
                then
                    l_BEN_ST_DATE := null;
                    l_BEN_ED_DATE := null;
                else
                    l_BEN_ST_DATE := car_rec.f_start;
                    l_BEN_ED_DATE := car_rec.f_end;
                end if;
                hr_utility.trace('A4');
                select action_information30
                into   l_car_count
                from   pay_action_information pai_emp
                where  pai_emp.action_context_id = p_assignment_action_id
                and    pai_emp.action_information_category = 'GB P11D ASSIGNMENT RESULTA';

                hr_utility.trace('A5');
                if l_car_count = 1
                then
                    l_ONLY_CAR_FLAG := 'Y';
                else
                    l_ONLY_CAR_FLAG := 'N';
                    l_CAR_NUMBERS := l_car_count;
                end if   ;
                hr_utility.trace('A6');
                hr_utility.trace('date_registered ' ||car_rec.date_registered);
                -- calculating benefit charge section
                if fnd_date.canonical_to_date( car_rec.date_registered)
                   >= to_date('01-01-1998','dd-mm-yyyy') and car_rec.CO2 is not null
                then
                    hr_utility.trace('A');
                    l_MOD_CO2 := floor(car_rec.CO2/5) * 5;
                    hr_utility.trace('b');
                    if (car_rec.f_fuel = 'B' or car_rec.f_fuel = 'C' or
                        car_rec.f_fuel = 'H' or car_rec.f_fuel = 'L' or
                        car_rec.f_fuel = 'P')
                    then
                        hr_utility.trace('c');
                        l_PERCENT_1 := car_rec.BENEFIT_PERCENT;
                        l_BEN_1 := car_rec.benefit_charge;
                        hr_utility.trace('d');
                    elsif ( car_rec.f_fuel ='D' )
                    then
                        hr_utility.trace('e');
                        l_PERCENT_2 := car_rec.BENEFIT_PERCENT;
                        l_BEN_2 := car_rec.benefit_charge;
                    end if;

                    hr_utility.trace('f');
                    if  car_rec.f_fuel  = 'H'
                    then
                        l_STD_DISC_1   := car_rec.STD_DISC;
                    elsif ( car_rec.f_fuel = 'B' or car_rec.f_fuel = 'C')
                    then
                        l_STD_DISC_2   := car_rec.STD_DISC;
                    end if;
                    hr_utility.trace('g');
                    if l_MOD_CO2 <= 145
                    then
                        l_EXTRA_CO2 := 165 -l_MOD_CO2;
                        l_NORMAL_CO2 := l_EXTRA_CO2/20;
                        l_ROUND_NORMAL_CO2 := floor(l_NORMAL_CO2);
                    end if;
                    hr_utility.trace('h');
                    l_CAR_BENEFIT_1   := car_rec.ben_charge - car_rec.stand_disc - car_rec.additional_disc;
                elsif fnd_date.canonical_to_date( car_rec.date_registered)
                      >= to_date('01-01-1998','dd-mm-yyyy') and car_rec.co2 is null
                then
                    hr_utility.trace('i');
                    if (car_rec.f_fuel = 'B' or car_rec.f_fuel = 'C' or
                        car_rec.f_fuel = 'H' or car_rec.f_fuel = 'L' or
                        car_rec.f_fuel = 'P' )
                    then
                        l_PERCENT_3 := car_rec.BENEFIT_PERCENT;
                        l_BEN_3 := car_rec.benefit_charge;
                    elsif car_rec.f_fuel ='D'
                    then
                        l_PERCENT_4 := car_rec.BENEFIT_PERCENT;
                        l_BEN_4 := car_rec.benefit_charge;
                    elsif car_rec.f_fuel ='E'
                    then
                        l_BEN_5 := car_rec.benefit_charge;
                    end if;

                     if  car_rec.f_fuel  = 'H'
                     then
                        l_STD_DISC_4   := car_rec.STD_DISC;
                    elsif ( car_rec.f_fuel = 'B' or car_rec.f_fuel = 'C')
                    then
                        l_STD_DISC_5   := car_rec.STD_DISC;
                    elsif car_rec.f_fuel = 'E'
                    then
                        l_STD_DISC_3   := car_rec.STD_DISC;
                    end if;
                    hr_utility.trace('j');
                    l_CAR_BENEFIT_2  := car_rec.ben_charge - car_rec.stand_disc      ;
                    l_full_DISC := null;
               elsif fnd_date.canonical_to_date( car_rec.date_registered)
                     < to_date('01-01-1998','dd-mm-yyyy')
               then
                   hr_utility.trace('K');
                   -- hr_utility.trace('car_rec.benefit_charge '|| car_rec.benefit_charge);
                   l_full_disc := null;
                   if car_rec.f_esize <= 1400
                   then
                       l_CAR_BENEFIT_3 :=  car_rec.benefit_charge;
                   elsif car_rec.f_esize <= 2000
                   then
                            l_CAR_BENEFIT_4 :=  car_rec.benefit_charge;
                   elsif car_rec.f_esize > 2000
                    then
                       l_CAR_BENEFIT_5 :=  car_rec.benefit_charge;
                   end if;
               end if;
               hr_utility.trace('k');
               -- fuel benefit
               l_esize := null;
               l_UNAVIALABLE_VAL_2 := null;
               if car_rec.FUEL_BENEFIT = 'Y'
               then
                       l_esize := car_rec.f_esize;
                   l_UNAVIALABLE_VAL_2 := car_rec.unavailable_value;
                   if car_rec.f_fuel = 'P'
                   then
                                   l_FUEL_FLAG := 'P';
                   else
                       l_FUEL_FLAG := 'D';
                   end if;
               end if;
               hr_utility.trace('L');
               l_xfdf_str_tab.extend;
               l_xfdf_str_tab(l_loop_count) := '<?xml version = "1.0" encoding = "UTF-8"?>
                   <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                   <fields> ' ||
                   '<field name="'||'EMPLOYERS_NAME'||'"><value>'||replace(l_employer_name,'&','&amp;')       ||'</value></field>'||
                   '<field name="'||'FULL_NAME'||'"><value>'||l_full_name||'</value></field>'||
                   '<field name="'||'EMPLOYERS_REF_NO'||'"><value>'||l_emp_ref_no||'</value></field>'||
                   '<field name="'||'EMPLOYEE_NUMBER'||'"><value>'||l_employee_number||'</value></field>'||
                   '<field name="'||'NATIONAL_INS_NO'||'"><value>'||l_national_ins_no||'</value></field>'||
                   '<field name="'||'MAKE'||'"><value>'||car_rec.make||'</value></field>'||
                   '<field name="'||'MODEL'||'"><value>'||car_rec.model||'</value></field>'||
                   '<field name="'||'DATE_FIRST_REG'||'"><value>'||car_rec.f_dreg||'</value></field>'||
                   '<field name="'||'CO2'||'"><value>'||car_rec.CO2||'</value></field>'||
                   '<field name="'||'FULL_YR_FLAG'||'"><value>'||car_rec.FULL_YR_FLAG||'</value></field>'||
                   '<field name="'||'BEN_ST_DATE'||'"><value>'||l_BEN_ST_DATE||'</value></field>'||
                   '<field name="'||'BEN_ED_DATE'||'"><value>'||l_BEN_ED_DATE||'</value></field>'||
                   '<field name="'||'UNAVAILABLE'||'"><value>'||car_rec.unavailable||'</value></field>'||
                   '<field name="'||'ONLY_CAR_FLAG'||'"><value>'||l_ONLY_CAR_FLAG||'</value></field>'||
                   '<field name="'||'CAR_NUMBERS'||'"><value>'||l_CAR_NUMBERS||'</value></field>'||
                   '<field name="'||'LIST_PRICE'||'"><value>'||car_rec.f_lprice||'</value></field>'||
                   '<field name="'||'OPTIONAL_EXTRAS'||'"><value>'||car_rec.f_oprice||'</value></field>'||
                   '<field name="'||'TOTAL_INIT_PRICE'||'"><value>'||car_rec.TOTAL_INIT_PRICE||'</value></field>'||
                   '<field name="'||'EXTRAS_LATER'||'"><value>'||car_rec.f_aprice||'</value></field>'||
                   '<field name="'||'TOTAL_PRICE'||'"><value>'||car_rec.TOTAL_PRICE||'</value></field>'||
                   '<field name="'||'CONTRIBUTIONS'||'"><value>'||car_rec.f_cost||'</value></field>'||
                   '<field name="'||'FINAL_PRICE'||'"><value>'||car_rec.FINAL_PRICE||'</value></field>'||
                   '<field name="'||'FINAL_PRICE_DUP'||'"><value>'||car_rec.FINAL_PRICE||'</value></field>'||
                   '<field name="'||'FUEL'||'"><value>'||car_rec.f_fuel||'</value></field>'||
                   '<field name="'||'MOD_CO2'||'"><value>'||l_MOD_CO2||'</value></field>'||
                   '<field name="'||'PERCENT_1'||'"><value>'||l_PERCENT_1||'</value></field>'||
                   '<field name="'||'BEN_1'||'"><value>'||l_BEN_1||'</value></field>'||
                   '<field name="'||'BEN_2'||'"><value>'||l_BEN_2||'</value></field>'||
                   '<field name="'||'PERCENT_2'||'"><value>'||l_PERCENT_2||'</value></field>'||
                   '<field name="'||'STD_DISC_1'||'"><value>'||l_STD_DISC_1||'</value></field>'||
                   '<field name="'||'STD_DISC_2'||'"><value>'||l_STD_DISC_2||'</value></field>'||
                   '<field name="'||'EXTRA_CO2'||'"><value>'||l_EXTRA_CO2||'</value></field>'||
                   '<field name="'||'NORMAL_CO2'||'"><value>'||l_NORMAL_CO2||'</value></field>'||
                   '<field name="'||'ROUND_NORMAL_CO2'||'"><value>'||l_ROUND_NORMAL_CO2||'</value></field>' ||
                   '<field name="'||'ADDITIONAL_DISC'||'"><value>'||car_rec.ADD_DISC||'</value></field>'||
                   '<field name="'||'FULL_DISCOUNT'||'"><value>'||l_FULL_DISC||'</value></field>'||
                   '<field name="'||'CAR_BENEFIT_1'||'"><value>'||to_char(to_number(l_CAR_BENEFIT_1),'FM999,999,990.00')||'</value></field>'||
                   '<field name="'||'PERCENT_3'||'"><value>'||l_PERCENT_3||'</value></field>'||
                   '<field name="'||'PERCENT_4'||'"><value>'||l_PERCENT_4||'</value></field>'||
                   '<field name="'||'BEN_3'||'"><value>'||l_BEN_3||'</value></field>'||
                   '<field name="'||'BEN_4'||'"><value>'||l_BEN_4||'</value></field>'||
                   '<field name="'||'BEN_5'||'"><value>'||l_BEN_5||'</value></field>'||
                   '<field name="'||'STD_DISC_3'||'"><value>'||l_STD_DISC_3||'</value></field>'||
                   '<field name="'||'STD_DISC_4'||'"><value>'||l_STD_DISC_4||'</value></field>'||
                   '<field name="'||'STD_DISC_5'||'"><value>'||l_STD_DISC_5||'</value></field>'||
                   '<field name="'||'CAR_BENEFIT_2'||'"><value>'||to_char(to_number(l_CAR_BENEFIT_2),'FM999,999,990.00')||'</value></field>'||
                   '<field name="'||'CAR_BENEFIT_3'||'"><value>'||l_CAR_BENEFIT_3 ||'</value></field>'||
                   '<field name="'||'CAR_BENEFIT_4'||'"><value>'||l_CAR_BENEFIT_4 ||'</value></field>'||
                   '<field name="'||'CAR_BENEFIT_5'||'"><value>'||l_CAR_BENEFIT_5 ||'</value></field>'||
                   '<field name="'||'UNAVAILABLE_VAL_1'||'"><value>'||car_rec.unavailable_value||'</value></field>'||
                   '<field name="'||'BENEFIT_AFTER_UNAVAIL'||'"><value>'||car_rec.BENEFIT_AFTER_UNAVAIL||'</value></field>'||
                   '<field name="'||'PRIVATE_USE_PAYMENT'||'"><value>'||car_rec.f_amg||'</value></field>'||
                   '<field name="'||'CASH_EQUIVALENT_CAR'||'"><value>'||car_rec.f_cc||'</value></field>'||
                   '<field name="'||'FUEL_FLAG'||'"><value>'||l_FUEL_FLAG||'</value></field>'||
                   '<field name="'||'ENGINE_CC'||'"><value>'||l_esize||'</value></field>'||
                   '<field name="'||'FUEL_SCALE'||'"><value>'||car_rec.FUEL_SCALE||'</value></field>'||
                   '<field name="'||'UNAVIALABLE_VAL_2'||'"><value>'||l_UNAVIALABLE_VAL_2||'</value></field>'||
                   '<field name="'||'FUEL_BENEFIT_CHARGE'||'"><value>'||car_rec.f_fcc||'</value></field>'||
                   '</fields>  </xfdf>';
            end loop;
            end loop;
            /* change from  l_rep_run = '2004' to l_rep_run > 2003 */
        elsif to_number(l_rep_run) < 2007 then
            for context_rec in csr_context_id(l_pactid,
                                              l_person_id,
                                              l_emp_ref_no,
                                              l_employer_name,
                                              'CAR AND CAR FUEL 2003_04') loop
            for car_rec in  csr_car_entries_0304(context_rec.action_context_id)
            loop
                l_employee_number := get_assignment_number(context_rec.action_context_id);
                l_loop_count := l_loop_count+1;
                --Initialising the vars to null;
                l_BEN_ST_DATE  := null;
                l_BEN_ED_DATE  := null;
                l_car_count    := null;
                l_ONLY_CAR_FLAG :=null;
                l_FUEL_FLAG :=null;
                l_CAR_NUMBERS  := null;
                l_MOD_CO2     := null;
                l_PERCENT_1  := null;
                l_BEN_1      := null;
                l_PERCENT_2  := null;
                l_BEN_2 := null;
                l_PERCENT_3 := null;
                l_BEN_3 := null;
                l_PERCENT_4 := null;
                l_BEN_4 := null;
                l_BEN_5 := null;
                l_STD_DISC_1 := null;
                l_STD_DISC_2 := null;
                l_STD_DISC_3 := null;
                l_STD_DISC_4 := null;
                l_STD_DISC_5 := null;
                l_full_DISC  := null;
                l_EXTRA_CO2  := null;
                l_NORMAL_CO2  := null;
                l_ROUND_NORMAL_CO2  := null;
                l_CAR_BENEFIT_1  := null;
                l_CAR_BENEFIT_2  := null;
                l_CAR_BENEFIT_3  := null;
                l_CAR_BENEFIT_4  := null;
                l_CAR_BENEFIT_5  := null;
                l_esize          := null;
                l_add_days       := null;
                l_tot_days       := null;
                l_unavailble_days := null;
                l_FUEL_BENEFIT_YEAR := null;
                /*l_full_DISC := car_rec.FULL_DISC;  */
                if car_rec.FULL_YR_FLAG = 'Y'
                                then
                    l_BEN_ST_DATE := null;
                    l_BEN_ED_DATE := null;
                else
                    l_BEN_ST_DATE := car_rec.f_start;
                    l_BEN_ED_DATE := car_rec.f_end;
                end if;
                -- hr_utility.trace_on(null,'CAR');
                hr_utility.trace('A4');
                select action_information30
                into   l_car_count
                from   pay_action_information pai_emp
                where  pai_emp.action_context_id = p_assignment_action_id
                and    pai_emp.action_information_category = 'GB P11D ASSIGNMENT RESULTA';
                hr_utility.trace('A5');
                if l_car_count = 1
                                then
                    l_ONLY_CAR_FLAG := 'Y';
                else
                    l_ONLY_CAR_FLAG := 'N';
                    l_CAR_NUMBERS := l_car_count;
                end if   ;
                hr_utility.trace('A6');
                hr_utility.trace('date_registered ' ||car_rec.date_registered);
                -- calculating benefit charge section
                if fnd_date.canonical_to_date( car_rec.date_registered)
                   >= to_date('01-01-1998','dd-mm-yyyy') and car_rec.CO2 is not null
                then
                    hr_utility.trace('a');
                    l_MOD_CO2 := floor(car_rec.CO2/5) * 5;
                    hr_utility.trace('b');
                    l_PERCENT_1 := car_rec.BENEFIT_PERCENT;
                    --l_BEN_1 := car_rec.benefit_charge;
                    hr_utility.trace('c');
                    l_STD_DISC_1   := car_rec.STD_DISC;
                    hr_utility.trace('d');
                    if (car_rec.f_fuel = 'B' or car_rec.f_fuel = 'H') -- Bug #4293824
                    then
                                            if car_rec.CO2 <= 120
                                                then
                             l_EXTRA_CO2 := 145 - car_rec.CO2;
                        end if;
                    end if;
                    l_ROUND_NORMAL_CO2 := car_rec.ROUND_NORMAL_CO2;
                    l_full_DISC        := car_rec.FULL_DISC;
                    l_CAR_BENEFIT_1    := car_rec.TOTAL_BENIFIT ;
                elsif fnd_date.canonical_to_date( car_rec.date_registered)
                      >= to_date('01-01-1998','dd-mm-yyyy') and car_rec.CO2 is null
                then
                    hr_utility.trace('e');
                   l_PERCENT_2 := car_rec.BENEFIT_PERCENT;
                   hr_utility.trace('f');
                   l_STD_DISC_2   := car_rec.STD_DISC;
                   l_CAR_BENEFIT_2 := car_rec.TOTAL_BENIFIT_2;
                elsif (fnd_date.canonical_to_date( car_rec.date_registered)<  to_date('01-01-1998','dd-mm-yyyy'))
                                then
                    hr_utility.trace('g');
                    -- hr_utility.trace('car_rec.benefit_charge '|| car_rec.benefit_charge);
                    l_full_disc := null;
                    l_esize := car_rec.f_esize;
                    if car_rec.f_esize <= 1400
                    then
                        l_CAR_BENEFIT_3 :=  15;
                    elsif car_rec.f_esize <= 2000
                    then
                        l_CAR_BENEFIT_3 :=  22;
                    elsif car_rec.f_esize > 2000
                    then
                                                l_CAR_BENEFIT_3 :=  32;
                    else
                                            l_CAR_BENEFIT_3 :=  32;
                    end if;
                end if;
                hr_utility.trace('h');
                -- fuel benefit
                if car_rec.FUEL_BENEFIT = 'Y'
                                then
                    L_FUEL_BENEFIT_YEAR := car_rec.FUEL_BENEFIT_YEAR;
                    l_add_days          := car_rec.additional_days;
                    l_tot_days        := car_rec.total_days;
                    l_unavailble_days   := car_rec.unavailable;
                end if;
                hr_utility.trace('i');
                l_xfdf_str_tab.extend;
                l_xfdf_str_tab(l_loop_count) := '<?xml version = "1.0" encoding = "UTF-8"?>
                    <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                    <fields> ' ||
                    '<field name="'||'EMPLOYERS_NAME'||'"><value>'||replace(l_employer_name,'&','&amp;')       ||'</value></field>'||
                    '<field name="'||'FULL_NAME'||'"><value>'||l_full_name||'</value></field>'||
                    '<field name="'||'EMPLOYERS_REF_NO'||'"><value>'||l_emp_ref_no||'</value></field>'||
                    '<field name="'||'EMPLOYEE_NUMBER'||'"><value>'||l_employee_number||'</value></field>'||
                    -- '<field name="'||'NATIONAL_INS_NO'||'"><value>'||l_national_ins_no||'</value></field>'||
                    '<field name="'||'NI_1'||'"><value>' ||substr(l_national_ins_no,1,1) || '</value></field>  ' ||
                    '<field name="'||'NI_2'||'"><value>' ||substr(l_national_ins_no,2,1) || '</value></field>  ' ||
                    '<field name="'||'NI_3'||'"><value>' ||substr(l_national_ins_no,3,1) || '</value></field>  ' ||
                    '<field name="'||'NI_4'||'"><value>' ||substr(l_national_ins_no,4,1) || '</value></field>  ' ||
                    '<field name="'||'NI_5'||'"><value>' ||substr(l_national_ins_no,5,1) || '</value></field>  ' ||
                    '<field name="'||'NI_6'||'"><value>' ||substr(l_national_ins_no,6,1) || '</value></field>  ' ||
                    '<field name="'||'NI_7'||'"><value>' ||substr(l_national_ins_no,7,1) || '</value></field>  ' ||
                    '<field name="'||'NI_8'||'"><value>' ||substr(l_national_ins_no,8,1) || '</value></field>  ' ||
                    '<field name="'||'NI_9'||'"><value>' ||substr(l_national_ins_no,9) || '</value></field>  '   ||
                    '<field name="'||'MAKE'||'"><value>'||car_rec.make||'</value></field>'||
                    '<field name="'||'MODEL'||'"><value>'||car_rec.model||'</value></field>'||
                    '<field name="'||'DATE_FIRST_REG1'||'"><value>'||substr(car_rec.f_dreg,0,2)||'</value></field>'||
                    '<field name="'||'DATE_FIRST_REG2'||'"><value>'||substr(car_rec.f_dreg,4,2)||'</value></field>'||
                    '<field name="'||'DATE_FIRST_REG3'||'"><value>'||substr(car_rec.f_dreg,7)||'</value></field>'||
                    '<field name="'||'ONLY_CAR_FLAG'||'"><value>'||l_ONLY_CAR_FLAG||'</value></field>'||
                    --'<field name="'||'CO2'||'"><value>'||car_rec.CO2||'</value></field>'||
                    --'<field name="'||'FULL_YR_FLAG'||'"><value>'||car_rec.FULL_YR_FLAG||'</value></field>'||
                    '<field name="'||'CAR_NUMBERS'||'"><value>'||l_CAR_NUMBERS||'</value></field>'||
                    '<field name="'||'LIST_PRICE'||'"><value>'||car_rec.f_lprice||'</value></field>'||
                    '<field name="'||'EXTRAS_LATER'||'"><value>'||car_rec.f_oprice||'</value></field>'||
                    '<field name="'||'TOTAL_INIT_PRICE'||'"><value>'||car_rec.TOTAL_INIT_PRICE||'</value></field>'||
                    /*'<field name="'||'BEN_ST_DATE'||'"><value>'||l_BEN_ST_DATE||'</value></field>'||
                    '<field name="'||'BEN_ED_DATE'||'"><value>'||l_BEN_ED_DATE||'</value></field>'||
                    '<field name="'||'UNAVAILABLE'||'"><value>'||car_rec.unavailable||'</value></field>'||*/
                    '<field name="'||'CONTRIBUTIONS'||'"><value>'||car_rec.f_cost||'</value></field>'||
                    '<field name="'||'FINAL_PRICE'||'"><value>'||car_rec.FINAL_PRICE||'</value></field>'||
                    '<field name="'||'CO2'||'"><value>'||car_rec.co2||'</value></field>'||
                    '<field name="'||'FUEL'||'"><value>'||car_rec.f_fuel||'</value></field>'||
                    '<field name="'||'MOD_CO2'||'"><value>'||l_MOD_CO2||'</value></field>'||
                    '<field name="'||'PERCENT_1'||'"><value>'||l_PERCENT_1||'</value></field>'||
                    '<field name="'||'STD_DISC_1'||'"><value>'||l_STD_DISC_1||'</value></field>'||
                    '<field name="'||'EXTRA_CO2'||'"><value>'||l_EXTRA_CO2||'</value></field>'||
                    '<field name="'||'ROUND_NORMAL_CO2'||'"><value>'||l_ROUND_NORMAL_CO2||'</value></field>' ||
                    '<field name="'||'FULL_DISCOUNT'||'"><value>'||l_full_DISC||'</value></field>'||
                    '<field name="'||'CAR_BENEFIT_1'||'"><value>'||l_CAR_BENEFIT_1||'</value></field>'||
                    '<field name="'||'PERCENT_2'||'"><value>'||l_PERCENT_2||'</value></field>'||
                    '<field name="'||'STD_DISC_2'||'"><value>'||l_STD_DISC_2||'</value></field>'||
                    '<field name="'||'CAR_BENEFIT_2'||'"><value>'||l_CAR_BENEFIT_2||'</value></field>'||
                    '<field name="'||'ENGINE_CC'||'"><value>'||l_esize||'</value></field>'||
                    '<field name="'||'CAR_BENEFIT_3'||'"><value>'||l_CAR_BENEFIT_3||'</value></field>'||
                    '<field name="'||'CAR_BENEFIT_YEAR'||'"><value>'||car_rec.car_benefit_year||'</value></field>'||
                   '<field name="'||'BEN_ST_DATE1'||'"><value>'||substr(l_BEN_ST_DATE,0,2)||'</value></field>'||
                    '<field name="'||'BEN_ST_DATE2'||'"><value>'||substr(l_BEN_ST_DATE,4,2)||'</value></field>'||
                    '<field name="'||'BEN_ST_DATE3'||'"><value>'||substr(l_BEN_ST_DATE,7)||'</value></field>'||
                    '<field name="'||'BEN_ED_DATE1'||'"><value>'||substr(l_BEN_ED_DATE,0,2)||'</value></field>'||
                    '<field name="'||'BEN_ED_DATE2'||'"><value>'||substr(l_BEN_ED_DATE,4,2)||'</value></field>'||
                    '<field name="'||'BEN_ED_DATE3'||'"><value>'||substr(l_BEN_ED_DATE,7)||'</value></field>'||
                    '<field name="'||'UNAVAILABLE'||'"><value>'||car_rec.unavailable||'</value></field>'||
                    '<field name="'||'UNAVAILABLE_VAL_1'||'"><value>'||car_rec.unavailable_value||'</value></field>'||
                    '<field name="'||'CAR_BENEFIT_AVAILABLE'||'"><value>'||car_rec.CAR_BENEFIT_AVAILABLE||'</value></field>'||
                    '<field name="'||'PRIVATE_USE_PAYMENT'||'"><value>'||car_rec.f_amg||'</value></field>'||
                    '<field name="'||'CASH_EQUIVALENT_CAR'||'"><value>'||car_rec.f_cc||'</value></field>'||
                    '<field name="'||'FUEL_BENEFIT_YEAR'||'"><value>'||l_FUEL_BENEFIT_YEAR||'</value></field>'||
                    '<field name="'||'UNAVAILABLE_2'||'"><value>'||l_unavailble_days||'</value></field>'||
                    '<field name="'||'WITHDRAW_DATE1'||'"><value>'||substr(car_rec.f_withdraw,0,2)||'</value></field>'||
                    '<field name="'||'WITHDRAW_DATE2'||'"><value>'||substr(car_rec.f_withdraw,4,2)||'</value></field>'||
                    '<field name="'||'WITHDRAW_DATE3'||'"><value>'||substr(car_rec.f_withdraw,7)||'</value></field>'||
                    '<field name="'||'ADD_DAYS'||'"><value>'||l_add_days||'</value></field>'||
                    '<field name="'||'TOT_DAYS'||'"><value>'||l_tot_days||'</value></field>'||
                    '<field name="'||'UNAVIALABLE_VAL_2'||'"><value>'||car_rec.fuel_unavailable||'</value></field>'||
                    '<field name="'||'FUEL_BENEFIT_CHARGE'||'"><value>'||car_rec.f_fcc||'</value></field>'||
                    '</fields>  </xfdf>';
            end loop;
            end loop;
        else -- for RepRun 2007+
            for context_rec in csr_context_id(l_pactid,
                                              l_person_id,
                                              l_emp_ref_no,
                                              l_employer_name,
                                              'CAR AND CAR FUEL 2003_04') loop
            for car_rec in  csr_car_entries_0304(context_rec.action_context_id)
            loop
                l_employee_number := get_assignment_number(context_rec.action_context_id);
                l_loop_count := l_loop_count+1;
                --Initialising the vars to null;
                l_BEN_ST_DATE  := null;
                l_BEN_ED_DATE  := null;
                l_car_count    := null;
                l_ONLY_CAR_FLAG :=null;
                l_FUEL_FLAG :=null;
                l_CAR_NUMBERS  := null;
                l_MOD_CO2     := null;
                l_PERCENT_1  := null;
                l_BEN_1      := null;
                l_PERCENT_2  := null;
                l_BEN_2 := null;
                l_PERCENT_3 := null;
                l_BEN_3 := null;
                l_PERCENT_4 := null;
                l_BEN_4 := null;
                l_BEN_5 := null;
                l_STD_DISC_1 := null;
                l_STD_DISC_2 := null;
                l_STD_DISC_3 := null;
                l_STD_DISC_4 := null;
                l_STD_DISC_5 := null;
                l_full_DISC  := null;
                l_EXTRA_CO2  := null;
                l_NORMAL_CO2  := null;
                l_ROUND_NORMAL_CO2  := null;
                l_CAR_BENEFIT_1  := null;
                l_CAR_BENEFIT_2  := null;
                l_CAR_BENEFIT_3  := null;
                l_CAR_BENEFIT_4  := null;
                l_CAR_BENEFIT_5  := null;
                l_CAR_BENEFIT_6  := null;
                l_esize          := null;
                l_add_days       := null;
                l_tot_days       := null;
                l_unavailble_days := null;
                l_FUEL_BENEFIT_YEAR := null;
                /*l_full_DISC := car_rec.FULL_DISC;  */
                if car_rec.FULL_YR_FLAG = 'Y'
                                then
                    l_BEN_ST_DATE := null;
                    l_BEN_ED_DATE := null;
                else
                    l_BEN_ST_DATE := car_rec.f_start;
                    l_BEN_ED_DATE := car_rec.f_end;
                end if;
                -- hr_utility.trace_on(null,'CAR');
                hr_utility.trace('A4');
                select action_information30
                into   l_car_count
                from   pay_action_information pai_emp
                where  pai_emp.action_context_id = p_assignment_action_id
                and    pai_emp.action_information_category = 'GB P11D ASSIGNMENT RESULTA';
                hr_utility.trace('A5');
                if l_car_count = 1
                                then
                    l_ONLY_CAR_FLAG := 'Y';
                else
                    l_ONLY_CAR_FLAG := 'N';
                    l_CAR_NUMBERS := l_car_count;
                end if   ;
                hr_utility.trace('A6');
                hr_utility.trace('date_registered ' ||car_rec.date_registered);
                -- calculating benefit charge section
                if (to_number(l_rep_run)) > 2008 then --P11D 08/09
                if fnd_date.canonical_to_date( car_rec.date_registered)
                   >= to_date('01-01-1998','dd-mm-yyyy') and car_rec.CO2 is not null
                   and car_rec.CO2 > 120 -- P11D 08/09
		   --hr_gb_process_p11d_entries_pkg.get_global_value('P11D_QUALEC_CO2_EMISSIONS',l_BEN_ED_DATE)
                then
                    hr_utility.trace('a');
                    l_MOD_CO2 := floor(car_rec.CO2/5) * 5;
                    --P11D 08/09
                    if l_MOD_CO2 < 135 then
                       l_MOD_CO2 := 135;
                    end if;
                    --P11D 08/09
                    hr_utility.trace('b');
                    l_PERCENT_1 := car_rec.BENEFIT_PERCENT;
                    hr_utility.trace('c');
                    l_STD_DISC_1   := car_rec.STD_DISC;
                    l_ROUND_NORMAL_CO2 := car_rec.ROUND_NORMAL_CO2;
                    l_full_DISC        := car_rec.FULL_DISC;
                    l_CAR_BENEFIT_1    := car_rec.TOTAL_BENIFIT ;
                -- P11D 08/09
		/* bug 8277887 car_rec.CO2 is not null to nvl(car_rec.CO2,0) > 0 */
                elsif fnd_date.canonical_to_date(car_rec.date_registered)
                   >= to_date('01-01-1998','dd-mm-yyyy') and nvl(car_rec.CO2,0) > 0
                   and car_rec.CO2 <= 120 -- P11D 08/09
		   -- hr_gb_process_p11d_entries_pkg.get_global_value('P11D_QUALEC_CO2_EMISSIONS',l_BEN_ED_DATE)
                then
                   l_CAR_BENEFIT_6    := car_rec.TOTAL_BENIFIT ;
                -- P11D 08/09
		/* bug 8277887 changed car_rec.co2 is null to nvl(car_rec.CO2,0) = 0 */
               elsif fnd_date.canonical_to_date( car_rec.date_registered)
                      >= to_date('01-01-1998','dd-mm-yyyy') and nvl(car_rec.CO2,0) = 0
                then
                   hr_utility.trace('e');
                   l_PERCENT_2 := car_rec.BENEFIT_PERCENT;
                   hr_utility.trace('f');
                   l_STD_DISC_2   := car_rec.STD_DISC;
                   l_CAR_BENEFIT_2 := car_rec.TOTAL_BENIFIT_2;
                elsif (fnd_date.canonical_to_date( car_rec.date_registered)<  to_date('01-01-1998','dd-mm-yyyy'))
                                then
                    hr_utility.trace('g');
                    -- hr_utility.trace('car_rec.benefit_charge '|| car_rec.benefit_charge);
                    l_full_disc := null;
                    l_esize := car_rec.f_esize;
                    open csr_engine_discount(to_number(l_esize),
                                             fnd_date.canonical_to_date(car_rec.ben_end));
                    fetch csr_engine_discount into l_CAR_BENEFIT_3;
                    close csr_engine_discount;
                end if;

                else

		if fnd_date.canonical_to_date( car_rec.date_registered)
                   >= to_date('01-01-1998','dd-mm-yyyy') and car_rec.CO2 is not null
                then
                    hr_utility.trace('a');
                    l_MOD_CO2 := floor(car_rec.CO2/5) * 5;
                    hr_utility.trace('b');
                    l_PERCENT_1 := car_rec.BENEFIT_PERCENT;
                    hr_utility.trace('c');
                    l_STD_DISC_1   := car_rec.STD_DISC;
                    l_ROUND_NORMAL_CO2 := car_rec.ROUND_NORMAL_CO2;
                    l_full_DISC        := car_rec.FULL_DISC;
                    l_CAR_BENEFIT_1    := car_rec.TOTAL_BENIFIT ;
                elsif fnd_date.canonical_to_date( car_rec.date_registered)
                      >= to_date('01-01-1998','dd-mm-yyyy') and car_rec.CO2 is null
                then
                   hr_utility.trace('e');
                   l_PERCENT_2 := car_rec.BENEFIT_PERCENT;
                   hr_utility.trace('f');
                   l_STD_DISC_2   := car_rec.STD_DISC;
                   l_CAR_BENEFIT_2 := car_rec.TOTAL_BENIFIT_2;
                elsif (fnd_date.canonical_to_date( car_rec.date_registered)<  to_date('01-01-1998','dd-mm-yyyy'))
                                then
                    hr_utility.trace('g');
                    -- hr_utility.trace('car_rec.benefit_charge '|| car_rec.benefit_charge);
                    l_full_disc := null;
                    l_esize := car_rec.f_esize;
                    open csr_engine_discount(to_number(l_esize),
                                             fnd_date.canonical_to_date(car_rec.ben_end));
                    fetch csr_engine_discount into l_CAR_BENEFIT_3;
                    close csr_engine_discount;
                 end if;
		end if;

                hr_utility.trace('h');
                -- fuel benefit
                if car_rec.FUEL_BENEFIT = 'Y'
                                then
                    L_FUEL_BENEFIT_YEAR := car_rec.FUEL_BENEFIT_YEAR;
                    l_add_days          := car_rec.additional_days;
                    l_tot_days        := car_rec.total_days;
                    l_unavailble_days   := car_rec.unavailable;
                end if;
                hr_utility.trace('i');
                l_xfdf_str_tab.extend;
                l_xfdf_str_tab(l_loop_count) := '<?xml version = "1.0" encoding = "UTF-8"?>
                    <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                    <fields> ' ||
                    '<field name="'||'EMPLOYERS_NAME'||'"><value>'||replace(l_employer_name,'&','&amp;')       ||'</value></field>'||
                    '<field name="'||'FULL_NAME'||'"><value>'||l_full_name||'</value></field>'||
                    -- P11D 08/09
                    ' <field name="'|| 'SUR_NAME' ||'"><value>' ||l_sur_name  || '</value></field> ' ||
                    ' <field name="'|| 'FORE_NAME'||'"><value>' ||l_fore_name || '</value></field> ' ||
                    -- P11D 08/09
                    '<field name="'||'EMPLOYERS_REF_NO'||'"><value>'||l_emp_ref_no||'</value></field>'||
                    '<field name="'||'EMPLOYEE_NUMBER'||'"><value>'||l_employee_number||'</value></field>'||
                    -- '<field name="'||'NATIONAL_INS_NO'||'"><value>'||l_national_ins_no||'</value></field>'||
                    '<field name="'||'NI_1'||'"><value>' ||substr(l_national_ins_no,1,1) || '</value></field>  ' ||
                    '<field name="'||'NI_2'||'"><value>' ||substr(l_national_ins_no,2,1) || '</value></field>  ' ||
                    '<field name="'||'NI_3'||'"><value>' ||substr(l_national_ins_no,3,1) || '</value></field>  ' ||
                    '<field name="'||'NI_4'||'"><value>' ||substr(l_national_ins_no,4,1) || '</value></field>  ' ||
                    '<field name="'||'NI_5'||'"><value>' ||substr(l_national_ins_no,5,1) || '</value></field>  ' ||
                    '<field name="'||'NI_6'||'"><value>' ||substr(l_national_ins_no,6,1) || '</value></field>  ' ||
                    '<field name="'||'NI_7'||'"><value>' ||substr(l_national_ins_no,7,1) || '</value></field>  ' ||
                    '<field name="'||'NI_8'||'"><value>' ||substr(l_national_ins_no,8,1) || '</value></field>  ' ||
                    '<field name="'||'NI_9'||'"><value>' ||substr(l_national_ins_no,9) || '</value></field>  '   ||
                    '<field name="'||'MAKE'||'"><value>'||car_rec.make||'</value></field>'||
                    '<field name="'||'MODEL'||'"><value>'||car_rec.model||'</value></field>'||
                    -- P11D changes 07/08 added make_model field
                    '<field name="'||'MAKE_MODEL'||'"><value>'||car_rec.make||' '||car_rec.model||'</value></field>'||
                    '<field name="'||'DATE_FIRST_REG1'||'"><value>'||substr(car_rec.f_dreg,0,2)||'</value></field>'||
                    '<field name="'||'DATE_FIRST_REG2'||'"><value>'||substr(car_rec.f_dreg,4,2)||'</value></field>'||
                    '<field name="'||'DATE_FIRST_REG3'||'"><value>'||substr(car_rec.f_dreg,7)||'</value></field>'||
                    '<field name="'||'ONLY_CAR_FLAG'||'"><value>'||l_ONLY_CAR_FLAG||'</value></field>'||
                    '<field name="'||'ONLY_CAR_FLAG_Y'||'"><value>'||l_ONLY_CAR_FLAG||'</value></field>'||
                    '<field name="'||'ONLY_CAR_FLAG_N'||'"><value>'||l_ONLY_CAR_FLAG||'</value></field>'||
                    --'<field name="'||'CO2'||'"><value>'||car_rec.CO2||'</value></field>'||
                    --'<field name="'||'FULL_YR_FLAG'||'"><value>'||car_rec.FULL_YR_FLAG||'</value></field>'||
                    '<field name="'||'CAR_NUMBERS'||'"><value>'||l_CAR_NUMBERS||'</value></field>'||
                    '<field name="'||'LIST_PRICE'||'"><value>'||car_rec.f_lprice||'</value></field>'||
                    '<field name="'||'EXTRAS_LATER'||'"><value>'||car_rec.f_oprice||'</value></field>'||
                    '<field name="'||'TOTAL_INIT_PRICE'||'"><value>'||car_rec.TOTAL_INIT_PRICE||'</value></field>'||
                    '<field name="'||'CONTRIBUTIONS'||'"><value>'||car_rec.f_cost||'</value></field>'||
                    '<field name="'||'FINAL_PRICE'||'"><value>'||car_rec.FINAL_PRICE||'</value></field>'||
                    '<field name="'||'CO2'||'"><value>'||car_rec.co2||'</value></field>'||
                    '<field name="'||'FUEL'||'"><value>'||car_rec.f_fuel||'</value></field>'||
                    '<field name="'||'MOD_CO2'||'"><value>'||l_MOD_CO2||'</value></field>'||
                    '<field name="'||'PERCENT_1'||'"><value>'||l_PERCENT_1||'</value></field>'||
                    '<field name="'||'STD_DISC_1'||'"><value>'||l_STD_DISC_1||'</value></field>'||
                    '<field name="'||'EXTRA_CO2'||'"><value>'||l_EXTRA_CO2||'</value></field>'||
                    '<field name="'||'ROUND_NORMAL_CO2'||'"><value>'||l_ROUND_NORMAL_CO2||'</value></field>' ||
                    '<field name="'||'FULL_DISCOUNT'||'"><value>'||l_full_DISC||'</value></field>'||
                    '<field name="'||'CAR_BENEFIT_1'||'"><value>'||l_CAR_BENEFIT_1||'</value></field>'||
                    -- P11D 08/09
                    '<field name="'||'CAR_BENEFIT_6'||'"><value>'||l_CAR_BENEFIT_6||'</value></field>'||
                    -- P11D 08/09
                    '<field name="'||'PERCENT_2'||'"><value>'||l_PERCENT_2||'</value></field>'||
                    '<field name="'||'STD_DISC_2'||'"><value>'||l_STD_DISC_2||'</value></field>'||
                    '<field name="'||'CAR_BENEFIT_2'||'"><value>'||l_CAR_BENEFIT_2||'</value></field>'||
                    '<field name="'||'ENGINE_CC'||'"><value>'||l_esize||'</value></field>'||
                    '<field name="'||'CAR_BENEFIT_3'||'"><value>'||l_CAR_BENEFIT_3||'</value></field>'||
                    '<field name="'||'CAR_BENEFIT_YEAR'||'"><value>'||car_rec.car_benefit_year||'</value></field>'||
                   '<field name="'||'BEN_ST_DATE1'||'"><value>'||substr(l_BEN_ST_DATE,0,2)||'</value></field>'||
                    '<field name="'||'BEN_ST_DATE2'||'"><value>'||substr(l_BEN_ST_DATE,4,2)||'</value></field>'||
                    '<field name="'||'BEN_ST_DATE3'||'"><value>'||substr(l_BEN_ST_DATE,7)||'</value></field>'||
                    '<field name="'||'BEN_ED_DATE1'||'"><value>'||substr(l_BEN_ED_DATE,0,2)||'</value></field>'||
                    '<field name="'||'BEN_ED_DATE2'||'"><value>'||substr(l_BEN_ED_DATE,4,2)||'</value></field>'||
                    '<field name="'||'BEN_ED_DATE3'||'"><value>'||substr(l_BEN_ED_DATE,7)||'</value></field>'||
                    '<field name="'||'UNAVAILABLE'||'"><value>'||car_rec.unavailable||'</value></field>'||
                    '<field name="'||'UNAVAILABLE_VAL_1'||'"><value>'||car_rec.unavailable_value||'</value></field>'||
                    '<field name="'||'CAR_BENEFIT_AVAILABLE'||'"><value>'||car_rec.CAR_BENEFIT_AVAILABLE||'</value></field>'||
                    '<field name="'||'PRIVATE_USE_PAYMENT'||'"><value>'||car_rec.f_amg||'</value></field>'||
                    '<field name="'||'CASH_EQUIVALENT_CAR'||'"><value>'||car_rec.f_cc||'</value></field>'||
                    '<field name="'||'FUEL_BENEFIT_YEAR'||'"><value>'||l_FUEL_BENEFIT_YEAR||'</value></field>'||
                    '<field name="'||'UNAVAILABLE_2'||'"><value>'||l_unavailble_days||'</value></field>'||
                    '<field name="'||'WITHDRAW_DATE1'||'"><value>'||substr(car_rec.f_withdraw,0,2)||'</value></field>'||
                    '<field name="'||'WITHDRAW_DATE2'||'"><value>'||substr(car_rec.f_withdraw,4,2)||'</value></field>'||
                    '<field name="'||'WITHDRAW_DATE3'||'"><value>'||substr(car_rec.f_withdraw,7)||'</value></field>'||
                    '<field name="'||'ADD_DAYS'||'"><value>'||l_add_days||'</value></field>'||
                    '<field name="'||'TOT_DAYS'||'"><value>'||l_tot_days||'</value></field>'||
                    '<field name="'||'UNAVIALABLE_VAL_2'||'"><value>'||car_rec.fuel_unavailable||'</value></field>'||
                    '<field name="'||'FUEL_BENEFIT_CHARGE'||'"><value>'||car_rec.f_fcc||'</value></field>'||
                    '</fields>  </xfdf>';
            end loop;
            end loop;
        end if;
        open l_ret_ref_cursor for
        select *
        from table (cast(l_xfdf_str_tab as per_gb_xfdftableType));
        p_record_num := l_loop_count;
        return l_ret_ref_cursor;
   end ;

   function fetch_ws3_ref_cursor (p_assignment_action_id Number,
                                  p_record_num out nocopy NUmber) return ref_cursor_typ
   is
        -- per_gb_xfdftableType is explicitly created type
        -- only modification needed is it could be of type blob
        -- i tried thta but could not access the blob valus in java routine.
        -- can be sorted later
        l_xfdf_str_tab per_gb_xfdftableType := per_gb_xfdftableType( );
        l_xfdf_str varchar2(32000);
        l_ret_ref_cursor ref_cursor_typ;

        cursor csr_vans_entries(p_pactid Number,
                                p_person_id Number,
                                p_emp_ref Varchar2 ,
                                p_emp_name Varchar2)
        is
        -- formatting in the ws is handled by the
        -- format feature in pdf. xdo is now supporting it
        -- but has limittaion where the fields are repating
        -- and hence the format clause is used for STD_UNAVILA_VAL
        select decode(ACTION_INFORMATION6, null,'Y','Y','N','N','Y') exclusive_flag,
               ACTION_INFORMATION7 dreg,
               nvl(ACTION_INFORMATION18,500) standard_charge,
               nvl(ACTION_INFORMATION8,0)  UNAVAILABLE_1,
               nvl(ACTION_INFORMATION9,0)  UNAVAILABLE_2,
               nvl(ACTION_INFORMATION10,0)  UNAVAILABLE_3,
               nvl(ACTION_INFORMATION11,0)  UNAVAILABLE_4,
               nvl(ACTION_INFORMATION12,0) UNAVAILABLE_VAL,
               nvl(ACTION_INFORMATION13,0) NUM_SHARE,
               nvl(ACTION_INFORMATION14,0) PVT_USE_PAYMENT,
               nvl(ACTION_INFORMATION15,0) CASH_EQUIVALENT
        from  pay_action_information
        where action_information_category = 'VANS 2002_03'
        and   action_context_id in (select paa.assignment_action_id
                                    from   pay_action_information pai_comp,
                                           pay_action_information pai_person,
                                           pay_assignment_actions paa,
                                           pay_payroll_actions ppa
                                    where  ppa.payroll_action_id = p_pactid
                                    and    paa.payroll_action_id = ppa.payroll_action_id
                                    and    pai_comp.action_context_id = paa.assignment_action_id
                                    and    pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                                    and    pai_person.action_context_id = paa.assignment_action_id
                                    and    pai_person.action_information_category = 'ADDRESS DETAILS'
                                    and    pai_person.action_information14 = 'Employee Address'
                                    and    pai_person.action_information1 = to_char(p_person_id)
                                    and    pai_comp.action_information6 = p_emp_ref
                                    and    pai_comp.action_information7 = p_emp_name);

        cursor csr_vans_entries_05(p_pactid Number,
                                   p_person_id Number,
                                   p_emp_ref Varchar2 ,
                                   p_emp_name Varchar2)
        is
        select nvl(action_information5,' ') registration_number,
               action_information6          date_registered,
               -- count vans --
               -- number of worksheet --
               nvl(action_information24,0)  van_charged,  -- A
               action_information3          van_from_b,   --
               action_information4          van_to_b,     --
               action_information7          van_unavil_b, -- B
               action_information16         van_from_c,   --
               action_information17         van_to_c,     --
               action_information18         van_unavil_c, -- C
               action_information19         van_from_d,   --
               action_information20         van_to_d,     --
               action_information21         van_unavil_d, -- D
               nvl(action_information8,0)   van_tot_day_unavil, -- E
               nvl(action_information9,0)   van_unavil_value,   -- F
               nvl(action_information10,0)  van_reduce_value,   -- G
               nvl(action_information11,0)  van_sh_pcent_reduc, -- H
               nvl(action_information12,0)  van_sh_reduction,   -- J
               action_information13         van_explanation,    --
               nvl(action_information10,0) -
               nvl(action_information12,0)  van_reduce_share,   -- K
               nvl(action_information14,0)  van_private_uses,   -- L
               nvl(action_information15,0)  van_benefit_charge, -- M
               action_context_id
        from   pay_action_information
        where  action_information_category = 'VANS 2005'
        and    action_context_type = 'AAP'
        and    action_context_id in (select paa.assignment_action_id
                                    from   pay_action_information pai_comp,
                                           pay_action_information pai_person,
                                           pay_assignment_actions paa,
                                           pay_payroll_actions ppa
                                    where  ppa.payroll_action_id = p_pactid
                                    and    paa.payroll_action_id = ppa.payroll_action_id
                                    and    pai_comp.action_context_id = paa.assignment_action_id
                                    and    pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                                    and    pai_comp.action_context_type = 'AAP'
                                    and    pai_person.action_context_id = paa.assignment_action_id
                                    and    pai_person.action_information_category = 'ADDRESS DETAILS'
                                    and    pai_person.action_context_type = 'AAP'
                                    and    pai_person.action_information14 = 'Employee Address'
                                    and    pai_person.action_information1 = to_char(p_person_id)
                                    and    pai_comp.action_information6 = p_emp_ref
                                    and    pai_comp.action_information7 = p_emp_name);

        cursor csr_vans_05_count(p_pactid Number,
                                 p_person_id Number,
                                 p_emp_ref Varchar2 ,
                                 p_emp_name Varchar2)
        is
        select count(*)
        from   pay_action_information
        where  action_information_category = 'VANS 2005'
        and    action_context_type = 'AAP'
        and    action_context_id in (select paa.assignment_action_id
                                    from   pay_action_information pai_comp,
                                           pay_action_information pai_person,
                                           pay_assignment_actions paa,
                                           pay_payroll_actions ppa
                                    where  ppa.payroll_action_id = p_pactid
                                    and    paa.payroll_action_id = ppa.payroll_action_id
                                    and    pai_comp.action_context_id = paa.assignment_action_id
                                    and    pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                                    and    pai_comp.action_context_type = 'AAP'
                                    and    pai_person.action_context_id = paa.assignment_action_id
                                    and    pai_person.action_information_category = 'ADDRESS DETAILS'
                                    and    pai_person.action_context_type = 'AAP'
                                    and    pai_person.action_information14 = 'Employee Address'
                                    and    pai_person.action_information1 = to_char(p_person_id)
                                    and    pai_comp.action_information6 = p_emp_ref
                                    and    pai_comp.action_information7 = p_emp_name);

        -- P11D Changes 07/08
        -- Cursor to fetch the VANS 2007 element details
        cursor csr_vans_entries_07(p_pactid Number,
                                   p_person_id Number,
                                   p_emp_ref Varchar2 ,
                                   p_emp_name Varchar2)
        is
        select nvl(action_information5,' ') registration_number,
               -- count vans --
               -- number of worksheet --
               nvl(action_information24,0)  van_charged,  -- A
               action_information3          van_from_b,   --
               action_information4          van_to_b,     --
               action_information6          van_unavil_b, -- B
               action_information15         van_from_c,   --
               action_information16         van_to_c,     --
               action_information17         van_unavil_c, -- C
               action_information18         van_from_d,   --
               action_information19         van_to_d,     --
               action_information20         van_unavil_d, -- D
               nvl(action_information7,0)   van_tot_day_unavil, -- E
               nvl(action_information8,0)   van_unavil_value,   -- F
               nvl(action_information9,0)  van_reduce_value,   -- G
               nvl(action_information10,0)  van_sh_pcent_reduc, -- H
               nvl(action_information11,0)  van_sh_reduction,   -- J
               action_information12         van_explanation,    --
               nvl(action_information9,0) -
               nvl(action_information11,0)  van_reduce_share,   -- K
               nvl(action_information13,0)  van_private_uses,   -- L
               nvl(action_information14,0)  van_benefit_charge, -- M
               nvl(action_information24,0)  van_benefit_chare_tax, --P
               action_information25         van_fuel_withdrawn, --R date
               nvl(action_information26,0)  van_days_after_fuel_wd, --R
               nvl(action_information27,0)  van_total_days_no_fuel, -- S
               nvl(action_information28,0)  van_reduction, --T
               (nvl(action_information24,0)
               - nvl(action_information28,0)) van_fuel_charge_reduction, --V
               nvl(action_information29,0)    van_reduction_sharing, --W
               nvl(action_information30,0)    van_feul_ben_charge, --X
               action_context_id
        from   pay_action_information
        where  action_information_category = 'VANS 2007'
        and    action_context_type = 'AAP'
        and    action_context_id in (select paa.assignment_action_id
                                    from   pay_action_information pai_comp,
                                           pay_action_information pai_person,
                                           pay_assignment_actions paa,
                                           pay_payroll_actions ppa
                                    where  ppa.payroll_action_id = p_pactid
                                    and    paa.payroll_action_id = ppa.payroll_action_id
                                    and    pai_comp.action_context_id = paa.assignment_action_id
                                    and    pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                                    and    pai_comp.action_context_type = 'AAP'
                                    and    pai_person.action_context_id = paa.assignment_action_id
                                    and    pai_person.action_information_category = 'ADDRESS DETAILS'
                                    and    pai_person.action_context_type = 'AAP'
                                    and    pai_person.action_information14 = 'Employee Address'
                                    and    pai_person.action_information1 = to_char(p_person_id)
                                    and    pai_comp.action_information6 = p_emp_ref
                                    and    pai_comp.action_information7 = p_emp_name);
        -- P11D Changes 07/08
        -- Cursor to count the VANS 2007 element details
        cursor csr_vans_07_count(p_pactid Number,
                                 p_person_id Number,
                                 p_emp_ref Varchar2 ,
                                 p_emp_name Varchar2)
        is
        select count(*)
        from   pay_action_information
        where  action_information_category = 'VANS 2007'
        and    action_context_type = 'AAP'
        and    action_context_id in (select paa.assignment_action_id
                                    from   pay_action_information pai_comp,
                                           pay_action_information pai_person,
                                           pay_assignment_actions paa,
                                           pay_payroll_actions ppa
                                    where  ppa.payroll_action_id = p_pactid
                                    and    paa.payroll_action_id = ppa.payroll_action_id
                                    and    pai_comp.action_context_id = paa.assignment_action_id
                                    and    pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                                    and    pai_comp.action_context_type = 'AAP'
                                    and    pai_person.action_context_id = paa.assignment_action_id
                                    and    pai_person.action_information_category = 'ADDRESS DETAILS'
                                    and    pai_person.action_context_type = 'AAP'
                                    and    pai_person.action_information14 = 'Employee Address'
                                    and    pai_person.action_information1 = to_char(p_person_id)
                                    and    pai_comp.action_information6 = p_emp_ref
                                    and    pai_comp.action_information7 = p_emp_name);


        l_emp_ref_no varchar2(150);
        l_employer_name varchar2(150);
        l_full_name varchar2(150);
        l_sur_name varchar2(150); --  P11D 08/09
        l_fore_name varchar2(150); -- P11D 08/09
        l_national_ins_no varchar2(150);
        l_employee_number varchar2(150);
        l_pactid number;
        l_person_id number;
        l_rep_run varchar2(10);
        l_loop_count number;
        l_vans_count  number;
        l_only_van   varchar2(2);
        l_after_flag varchar2(2);
        l_date_from  varchar2(15);
        l_date_to    varchar2(15);
        l_days_after_fuel_wd varchar2(30);
        l_fuel_charge_reduction varchar2(30);
   begin
        get_employer_details(p_assignment_action_id,
                             l_emp_ref_no,
                             l_employer_name);
        get_employee_details(p_assignment_action_id,
                             l_full_name,
                             l_national_ins_no,
                             l_employee_number);
        -- P11D 08/09
        -- Fetch sur and fore names
        get_sur_fore_names(p_assignment_action_id,
                           l_sur_name,
                           l_fore_name);
        -- P11D 08/09
        l_pactid := get_pactid(p_assignment_action_id);
        l_person_id := get_person_id (p_assignment_action_id );
        l_loop_count := 0;

        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => l_pactid,
         p_token_name                  => 'Rep_Run',
         p_token_value                 => l_rep_run);

        l_date_from := '06-04-' || to_char(to_number(l_rep_run) - 1 );
        l_date_to   := '05-04-' || l_rep_run;

        if to_number(l_rep_run) < '2006'
        then
            for van_entries in  csr_vans_entries(l_pactid,
                                                 l_person_id,
                                                 l_emp_ref_no,
                                                 l_employer_name)
            loop
                l_loop_count := l_loop_count+1;
                hr_utility.trace('a');
                -- l_ws3_info_tab(l_loop_count).l_vans_entries := van_entries;
                l_xfdf_str_tab.extend;
                l_xfdf_str_tab(l_loop_count) := '<?xml version = "1.0" encoding = "UTF-8"?>
                    <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                    <fields> ' ||
                    '<field name="'||'Employer'||'"><value>' ||replace(l_employer_name,'&','&amp;')  || '</value></field> ' ||
                    '<field name="'||'Employee'||'"><value>' ||l_full_name || '</value></field>  ' ||
                    '<field name="'||'PAYE_tax'||'"><value>' ||l_emp_ref_no || '</value></field>  ' ||
                    '<field name="'||'Works_no'||'"><value>' ||l_employee_number || '</value></field>  ' ||
                    -- ' <field name="'||'Nat_Ins_Num'||'"><value>' ||l_national_ins_no || '</value></field>  '  ||
                    '<field name="'||'NI_1'||'"><value>' ||substr(l_national_ins_no,1,1) || '</value></field>  ' ||
                    '<field name="'||'NI_2'||'"><value>' ||substr(l_national_ins_no,2,1) || '</value></field>  ' ||
                    '<field name="'||'NI_3'||'"><value>' ||substr(l_national_ins_no,3,1) || '</value></field>  ' ||
                    '<field name="'||'NI_4'||'"><value>' ||substr(l_national_ins_no,4,1) || '</value></field>  ' ||
                    '<field name="'||'NI_5'||'"><value>' ||substr(l_national_ins_no,5,1) || '</value></field>  ' ||
                    '<field name="'||'NI_6'||'"><value>' ||substr(l_national_ins_no,6,1) || '</value></field>  ' ||
                    '<field name="'||'NI_7'||'"><value>' ||substr(l_national_ins_no,7,1) || '</value></field>  ' ||
                    '<field name="'||'NI_8'||'"><value>' ||substr(l_national_ins_no,8,1) || '</value></field>  ' ||
                    '<field name="'||'NI_9'||'"><value>' ||substr(l_national_ins_no,9)   || '</value></field>  '  ||
                    '<field name="'||'exclusive_flag'||'"><value>' ||van_entries.exclusive_flag || '</value></field>  '  ;
                     hr_utility.trace('aa');
                if van_entries.exclusive_flag = 'Y'
                then -- we fill section 1
                    if fnd_date.canonical_to_date(van_entries.dreg) > to_date('05-04-2000','dd-mm-yyyy')
                    then
                        l_xfdf_str_tab(l_loop_count) := l_xfdf_str_tab(l_loop_count) ||
                        '<field name="'||'date_flag'||'"><value>' ||'Y' || '</value></field>  '  ;
                    else
                        l_xfdf_str_tab(l_loop_count) := l_xfdf_str_tab(l_loop_count)  ||
                        '<field name="'||'date_flag'||'"><value>' ||'N' || '</value></field>  '  ;
                    end if;
                    hr_utility.trace('2');
                    l_xfdf_str_tab(l_loop_count) := l_xfdf_str_tab(l_loop_count)  ||
                        '<field name="'||'standard_charge'||'"><value>' ||van_entries.standard_charge || '</value></field>  '  ||
                        '<field name="'||'UNAVAILABLE_1'  ||'"><value>' ||van_entries.UNAVAILABLE_1   || '</value></field>  '  ||
                        '<field name="'||'UNAVAILABLE_2'  ||'"><value>' ||van_entries.UNAVAILABLE_2   || '</value></field>  '  ||
                        '<field name="'||'UNAVAILABLE_3'  ||'"><value>' ||van_entries.UNAVAILABLE_3   || '</value></field>  '  ||
                        '<field name="'||'UNAVAILABLE_4'  ||'"><value>' ||van_entries.UNAVAILABLE_4   || '</value></field>  '  ||
                        '<field name="'||'TOT_UNAVAILABLE'||'"><value>' ||(nvl(van_entries.UNAVAILABLE_1,0) + nvl(van_entries.UNAVAILABLE_2,0) +
                        nvl(van_entries.UNAVAILABLE_3,0) + nvl(van_entries.UNAVAILABLE_4,0))  || '</value></field>  '  ||
                        '<field name="'||'UNAVAILABLE_VAL'||'"><value>' ||van_entries.UNAVAILABLE_VAL || '</value></field>  '  ||
                        '<field name="'||'STD_RED'        ||'"><value>' || (nvl(van_entries.standard_charge,0) - nvl(van_entries.UNAVAILABLE_VAL,0)) || '</value></field>  ' ||
                        '<field name="'||'PVT_USE_PAYMENT'||'"><value>' ||van_entries.PVT_USE_PAYMENT || '</value></field>  '  ||
                        '<field name="'||'NON_SHARED_BEN' ||'"><value>' ||van_entries.CASH_EQUIVALENT || '</value></field>  '  ||
                        '<field name="'||'CE'             ||'"><value>' ||van_entries.CASH_EQUIVALENT || '</value></field>  '  ;
                    hr_utility.trace('3');
                else -- else of van_entries.exclusive_flag = 'Y'
                    hr_utility.trace('4');
                    if fnd_date.canonical_to_date(van_entries.dreg) > to_date('05-04-2000','dd-mm-yyyy')
                    then
                        l_xfdf_str_tab(l_loop_count) := l_xfdf_str_tab(l_loop_count)  ||
                        '<field name="'||'S_DATE_FLAG'||'"><value>' ||'Y' || '</value></field>  '  ;
                    else
                        l_xfdf_str_tab(l_loop_count) := l_xfdf_str_tab(l_loop_count)  ||
                        '<field name="'||'S_DATE_FLAG'||'"><value>' ||'N' || '</value></field>  '  ;
                    end if;
                    l_xfdf_str_tab(l_loop_count) := l_xfdf_str_tab(l_loop_count)  ||
                    '<field name="'||'S_STANDARD_CHARGE'||'"><value>' ||van_entries.standard_charge || '</value></field>  '  ;
                    hr_utility.trace('5');
                    if nvl(van_entries.UNAVAILABLE_VAL,0) = 0
                    then
                        l_xfdf_str_tab(l_loop_count) := l_xfdf_str_tab(l_loop_count)  ||
                        '<field name="'||'S_FULL_YEAR_FLAG'||'"><value>' ||'Y' || '</value></field>  '  ;
                        hr_utility.trace('7');
                    else
                        hr_utility.trace('6');
                        l_xfdf_str_tab(l_loop_count) := l_xfdf_str_tab(l_loop_count)  ||
                        '<field name="'||'S_FULL_YEAR_FLAG' ||'"><value>' ||'N'                       || '</value></field>  '  ||
                        '<field name="'||'S_UNAVAILABLE_1'  ||'"><value>' ||van_entries.UNAVAILABLE_1 || '</value></field>  '  ||
                        '<field name="'||'S_UNAVAILABLE_2'  ||'"><value>' ||van_entries.UNAVAILABLE_2 || '</value></field>  '  ||
                        '<field name="'||'S_UNAVAILABLE_3'  ||'"><value>' ||van_entries.UNAVAILABLE_3 || '</value></field>  '  ||
                        '<field name="'||'S_UNAVAILABLE_4'  ||'"><value>' ||van_entries.UNAVAILABLE_4 || '</value></field>  '  ||
                        '<field name="'||'S_TOT_UNAVAILABLE'||'"><value>' ||(nvl(van_entries.UNAVAILABLE_1,0) +
                        nvl(van_entries.UNAVAILABLE_2,0) + nvl(van_entries.UNAVAILABLE_3,0) + nvl(van_entries.UNAVAILABLE_4,0))  || '</value></field>  ' ||
                        '<field name="'||'S_UNAVAIL_VAL'    ||'"><value>' ||van_entries.UNAVAILABLE_VAL || '</value></field>  '  ;
                    end if;
                    hr_utility.trace('8');
                    l_xfdf_str_tab(l_loop_count) := l_xfdf_str_tab(l_loop_count)  ||
                    '<field name="'||'S_STD_UNAVAIL'    ||'"><value>' ||
                    to_char(to_number((nvl(van_entries.standard_charge,0) - nvl(van_entries.UNAVAILABLE_VAL,0))),
                                    'FM999,999,990.00') || '</value></field>  '  ||
                    '<field name="'||'S_NUM_SHARE'      ||'"><value>' || van_entries.NUM_SHARE  || '</value></field>  '  ||
                    '<field name="'||'S_CHRG_PER_SHARE' ||'"><value>' ||
                    ((nvl(van_entries.standard_charge,0) - nvl(van_entries.UNAVAILABLE_VAL,0))/van_entries.NUM_SHARE)
                                   || '</value></field>  ' ||
                    '<field name="'||'S_STD_CHARGE'||'"><value>' ||
                    ((nvl(van_entries.standard_charge,0) - nvl(van_entries.UNAVAILABLE_VAL,0))/van_entries.NUM_SHARE)
                                   || '</value></field>  '  ||
                    '<field name="'||'S_PVT_USE_PAYMENT'||'"><value>' ||van_entries.PVT_USE_PAYMENT || '</value></field>  '  ||
                    '<field name="'||'SHARED_BEN'       ||'"><value>' ||van_entries.CASH_EQUIVALENT || '</value></field>  '  ||
                    '<field name="'||'CE'               ||'"><value>' ||van_entries.CASH_EQUIVALENT || '</value></field>  '  ;
                end if; -- end of checking for van_entries.exclusive_flag = 'Y'
                hr_utility.trace('9');
                l_xfdf_str_tab(l_loop_count) := l_xfdf_str_tab(l_loop_count)  || '</fields>  </xfdf>';
            end loop;
        elsif to_number(l_rep_run) >= 2006 and to_number(l_rep_run) < 2008 then -- P11D changes 07/08 -- l_rep_run > 2005, so 2006 onwards.
            open csr_vans_05_count(l_pactid,
                                   l_person_id,
                                   l_emp_ref_no,
                                   l_employer_name);
            fetch csr_vans_05_count into l_vans_count;
            close csr_vans_05_count;

            --l_only_van := 'Y';
            if l_vans_count > 1 then
               l_only_van := 'N';
            else
               l_vans_count := null;
               l_only_van := 'Y';
            end if;

            for vans_entries in  csr_vans_entries_05(l_pactid,
                                                     l_person_id,
                                                     l_emp_ref_no,
                                                     l_employer_name)
            loop
                l_loop_count := l_loop_count+1;
                hr_utility.trace('Vans');
                l_after_flag := 'N';
                if to_number(l_rep_run) < 2007 then
                   if fnd_date.canonical_to_date(vans_entries.date_registered) > to_date('05-04-2002','dd-mm-yyyy')
                   then
                       l_after_flag := 'Y';
                   end if;
                else -- >= 2007
                   if fnd_date.canonical_to_date(vans_entries.date_registered) > to_date('05-04-2003','dd-mm-yyyy')
                   then
                       l_after_flag := 'Y';
                   end if;
                end if;

                /* check date from and date to */
                if fnd_date.canonical_to_date(vans_entries.van_from_b) = to_date(l_date_from,'DD-MM-YYYY') and
                   fnd_date.canonical_to_date(vans_entries.van_to_b)  = to_date(l_date_to,'DD-MM-YYYY')
                then
                    vans_entries.van_from_b := null;
                    vans_entries.van_to_b   := null;
                end if;
                /* end check  */
                l_employee_number := get_assignment_number(vans_entries.action_context_id);

                l_xfdf_str_tab.extend;
                l_xfdf_str_tab(l_loop_count) := '<?xml version = "1.0" encoding = "UTF-8"?>
                    <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                    <fields> ' ||
                    '<field name="'||'Employer'   ||'"><value>' ||replace(l_employer_name,'&','&amp;')      || '</value></field>  ' ||
                    '<field name="'||'Employee'   ||'"><value>' ||l_full_name                               || '</value></field>  ' ||
                    '<field name="'||'PAYE_tax'   ||'"><value>' ||l_emp_ref_no                              || '</value></field>  ' ||
                    '<field name="'||'Works_no'   ||'"><value>' ||l_employee_number                         || '</value></field>  ' ||
                    '<field name="'||'NI_1'       ||'"><value>' ||substr(l_national_ins_no,1,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_2'       ||'"><value>' ||substr(l_national_ins_no,2,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_3'       ||'"><value>' ||substr(l_national_ins_no,3,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_4'       ||'"><value>' ||substr(l_national_ins_no,4,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_5'       ||'"><value>' ||substr(l_national_ins_no,5,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_6'       ||'"><value>' ||substr(l_national_ins_no,6,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_7'       ||'"><value>' ||substr(l_national_ins_no,7,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_8'       ||'"><value>' ||substr(l_national_ins_no,8,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_9'       ||'"><value>' ||substr(l_national_ins_no,9)               || '</value></field>  ' ||
                    '<field name="'||'REG_NO'     ||'"><value>' ||vans_entries.registration_number          || '</value></field>  ' ||
                    '<field name="'||'REG_DAY'    ||'"><value>' ||substr(vans_entries.date_registered,9,2)  || '</value></field>  ' ||
                    '<field name="'||'REG_MONTH'  ||'"><value>' ||substr(vans_entries.date_registered,6,2)  || '</value></field>  ' ||
                    '<field name="'||'REG_YEAR'   ||'"><value>' ||substr(vans_entries.date_registered,1,4)  || '</value></field>  ' ||
                    '<field name="'||'ONLY_VAN'   ||'"><value>' ||l_only_van                                || '</value></field>  ' ||
                    '<field name="'||'ONLY_VAN_Y' ||'"><value>' ||l_only_van                                || '</value></field>  ' ||
                    '<field name="'||'ONLY_VAN_N' ||'"><value>' ||l_only_van                                || '</value></field>  ' ||
                    '<field name="'||'VAN_COUNT'  ||'"><value>' ||l_vans_count                              || '</value></field>  ' ||
                    '<field name="'||'VAN_AFTER'  ||'"><value>' ||l_after_flag                              || '</value></field>  ' ||
                    '<field name="'||'VAN_AFTER_Y'||'"><value>' ||l_after_flag                              || '</value></field>  ' ||
                    '<field name="'||'VAN_AFTER_N'||'"><value>' ||l_after_flag                              || '</value></field>  ' ||
                    '<field name="'||'VAN_A'      ||'"><value>' ||vans_entries.van_charged                  || '</value></field>  ' ||
                    '<field name="'||'VAN_B_FD'   ||'"><value>' ||substr(vans_entries.van_from_b,9,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_B_FM'   ||'"><value>' ||substr(vans_entries.van_from_b,6,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_B_FY'   ||'"><value>' ||substr(vans_entries.van_from_b,1,4)       || '</value></field>  ' ||
                    '<field name="'||'VAN_B_TD'   ||'"><value>' ||substr(vans_entries.van_to_b,9,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_B_TM'   ||'"><value>' ||substr(vans_entries.van_to_b,6,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_B_TY'   ||'"><value>' ||substr(vans_entries.van_to_b,1,4)         || '</value></field>  ' ||
                    '<field name="'||'VAN_B'      ||'"><value>' ||vans_entries.van_unavil_b                 || '</value></field>  ' ||
                    '<field name="'||'VAN_C_FD'   ||'"><value>' ||substr(vans_entries.van_from_c,9,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_C_FM'   ||'"><value>' ||substr(vans_entries.van_from_c,6,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_C_FY'   ||'"><value>' ||substr(vans_entries.van_from_c,1,4)       || '</value></field>  ' ||
                    '<field name="'||'VAN_C_TD'   ||'"><value>' ||substr(vans_entries.van_to_c,9,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_C_TM'   ||'"><value>' ||substr(vans_entries.van_to_c,6,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_C_TY'   ||'"><value>' ||substr(vans_entries.van_to_c,1,4)         || '</value></field>  ' ||
                    '<field name="'||'VAN_C'      ||'"><value>' ||vans_entries.van_unavil_c                 || '</value></field>  ' ||
                    '<field name="'||'VAN_D_FD'   ||'"><value>' ||substr(vans_entries.van_from_d,9,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_D_FM'   ||'"><value>' ||substr(vans_entries.van_from_d,6,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_D_FY'   ||'"><value>' ||substr(vans_entries.van_from_d,1,4)       || '</value></field>  ' ||
                    '<field name="'||'VAN_D_TD'   ||'"><value>' ||substr(vans_entries.van_to_d,9,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_D_TM'   ||'"><value>' ||substr(vans_entries.van_to_d,6,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_D_TY'   ||'"><value>' ||substr(vans_entries.van_to_d,1,4)         || '</value></field>  ' ||
                    '<field name="'||'VAN_D'      ||'"><value>' ||vans_entries.van_unavil_d                 || '</value></field>  ' ||
                    '<field name="'||'VAN_E'      ||'"><value>' ||vans_entries.van_tot_day_unavil           || '</value></field>  ' ||
                    '<field name="'||'VAN_F'      ||'"><value>' ||vans_entries.van_unavil_value             || '</value></field>  ' ||
                    '<field name="'||'VAN_G'      ||'"><value>' ||vans_entries.van_reduce_value             || '</value></field>  ' ||
                    '<field name="'||'VAN_G2'     ||'"><value>' ||vans_entries.van_reduce_value             || '</value></field>  ' ||
                    '<field name="'||'VAN_H'      ||'"><value>' ||vans_entries.van_sh_pcent_reduc           || '</value></field>  ' ||
                    '<field name="'||'VAN_J'      ||'"><value>' ||vans_entries.van_sh_reduction             || '</value></field>  ' ||
                    '<field name="'||'VAN_EXP'    ||'"><value>' ||vans_entries.van_explanation              || '</value></field>  ' ||
                    '<field name="'||'VAN_K'      ||'"><value>' ||vans_entries.van_reduce_share             || '</value></field>  ' ||
                    '<field name="'||'VAN_L'      ||'"><value>' ||vans_entries.van_private_uses             || '</value></field>  ' ||
                    '<field name="'||'VAN_M'      ||'"><value>' ||vans_entries.van_benefit_charge           || '</value></field>  ' ||
                    '</fields>  </xfdf>';
            end loop;
        else -- after 2008 onwords -- P11D changes 07/08
            open csr_vans_07_count(l_pactid,
                                   l_person_id,
                                   l_emp_ref_no,
                                   l_employer_name);
            fetch csr_vans_07_count into l_vans_count;
            close csr_vans_07_count;

            --l_only_van := 'Y';
            if l_vans_count > 1 then
               l_only_van := 'N';
            else
               l_vans_count := null;
               l_only_van := 'Y';
            end if;

            for vans_entries in  csr_vans_entries_07(l_pactid,
                                                     l_person_id,
                                                     l_emp_ref_no,
                                                     l_employer_name)
            loop
                l_loop_count := l_loop_count+1;
                /* bug 7146755  added the below variables to check if the employee receives no fuel benefit
                then display the fields fuel_charge_reduction and days_after_fuel_wd to be null */
                l_fuel_charge_reduction := vans_entries.van_fuel_charge_reduction;
                l_days_after_fuel_wd  :=vans_entries.van_days_after_fuel_wd;

                if (vans_entries.van_feul_ben_charge = '0')
                THEN
                l_fuel_charge_reduction := NULL;
                l_days_after_fuel_wd  :=NULL;
                END IF;
                --end of bug 7146755
                hr_utility.trace('Vans 2007');
                l_after_flag := 'N';
               /* if to_number(l_rep_run) < 2007 then
                   if fnd_date.canonical_to_date(vans_entries.date_registered) > to_date('05-04-2002','dd-mm-yyyy')
                   then
                       l_after_flag := 'Y';
                   end if;
                else -- >= 2007
                   if fnd_date.canonical_to_date(vans_entries.date_registered) > to_date('05-04-2003','dd-mm-yyyy')
                   then
                       l_after_flag := 'Y';
                   end if;
                end if; */

                /* check date from and date to */

                if fnd_date.canonical_to_date(vans_entries.van_from_b) = to_date(l_date_from,'DD-MM-YYYY') and
                   fnd_date.canonical_to_date(vans_entries.van_to_b)  = to_date(l_date_to,'DD-MM-YYYY')
                then
                    vans_entries.van_from_b := null;
                    vans_entries.van_to_b   := null;
                end if;
                /* end check  */
                l_employee_number := get_assignment_number(vans_entries.action_context_id);

                l_xfdf_str_tab.extend;
                /* bug 7146755 reporting the variables l_fuel_charge_reduction and l_ days_after_fuel_wd
                instead of vans_entries.van_fuel_charge_reduction and vans_entries.days_after_fuel_wd */
                l_xfdf_str_tab(l_loop_count) := '<?xml version = "1.0" encoding = "UTF-8"?>
                    <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                    <fields> ' ||
                    '<field name="'||'Employer'   ||'"><value>' ||replace(l_employer_name,'&','&amp;')      || '</value></field>  ' ||
                    '<field name="'||'Employee'   ||'"><value>' ||l_full_name                               || '</value></field>  ' ||
                    -- P11D 08/09
                    ' <field name="'||'SUR_NAME'  ||'"><value>' ||l_sur_name                                || '</value></field> '  ||
                    ' <field name="'||'FORE_NAME' ||'"><value>' ||l_fore_name                               || '</value></field> '  ||
                    -- P11D 08/09
                    '<field name="'||'PAYE_tax'   ||'"><value>' ||l_emp_ref_no                              || '</value></field>  ' ||
                    '<field name="'||'Works_no'   ||'"><value>' ||l_employee_number                         || '</value></field>  ' ||
                    '<field name="'||'NI_1'       ||'"><value>' ||substr(l_national_ins_no,1,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_2'       ||'"><value>' ||substr(l_national_ins_no,2,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_3'       ||'"><value>' ||substr(l_national_ins_no,3,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_4'       ||'"><value>' ||substr(l_national_ins_no,4,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_5'       ||'"><value>' ||substr(l_national_ins_no,5,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_6'       ||'"><value>' ||substr(l_national_ins_no,6,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_7'       ||'"><value>' ||substr(l_national_ins_no,7,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_8'       ||'"><value>' ||substr(l_national_ins_no,8,1)             || '</value></field>  ' ||
                    '<field name="'||'NI_9'       ||'"><value>' ||substr(l_national_ins_no,9)               || '</value></field>  ' ||
                    '<field name="'||'REG_NO'     ||'"><value>' ||vans_entries.registration_number          || '</value></field>  ' ||
                    '<field name="'||'ONLY_VAN'   ||'"><value>' ||l_only_van                                || '</value></field>  ' ||
                    '<field name="'||'ONLY_VAN_Y' ||'"><value>' ||l_only_van                                || '</value></field>  ' ||
                    '<field name="'||'ONLY_VAN_N' ||'"><value>' ||l_only_van                                || '</value></field>  ' ||
                    '<field name="'||'VAN_COUNT'  ||'"><value>' ||l_vans_count                              || '</value></field>  ' ||
                    '<field name="'||'VAN_AFTER'  ||'"><value>' ||l_after_flag                              || '</value></field>  ' ||
                    '<field name="'||'VAN_A'      ||'"><value>' ||vans_entries.van_charged                  || '</value></field>  ' ||
                    '<field name="'||'VAN_B_FD'   ||'"><value>' ||substr(vans_entries.van_from_b,9,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_B_FM'   ||'"><value>' ||substr(vans_entries.van_from_b,6,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_B_FY'   ||'"><value>' ||substr(vans_entries.van_from_b,1,4)       || '</value></field>  ' ||
                    '<field name="'||'VAN_B_TD'   ||'"><value>' ||substr(vans_entries.van_to_b,9,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_B_TM'   ||'"><value>' ||substr(vans_entries.van_to_b,6,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_B_TY'   ||'"><value>' ||substr(vans_entries.van_to_b,1,4)         || '</value></field>  ' ||
                    '<field name="'||'VAN_B'      ||'"><value>' ||vans_entries.van_unavil_b                 || '</value></field>  ' ||
                    '<field name="'||'VAN_C_FD'   ||'"><value>' ||substr(vans_entries.van_from_c,9,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_C_FM'   ||'"><value>' ||substr(vans_entries.van_from_c,6,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_C_FY'   ||'"><value>' ||substr(vans_entries.van_from_c,1,4)       || '</value></field>  ' ||
                    '<field name="'||'VAN_C_TD'   ||'"><value>' ||substr(vans_entries.van_to_c,9,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_C_TM'   ||'"><value>' ||substr(vans_entries.van_to_c,6,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_C_TY'   ||'"><value>' ||substr(vans_entries.van_to_c,1,4)         || '</value></field>  ' ||
                    '<field name="'||'VAN_C'      ||'"><value>' ||vans_entries.van_unavil_c                 || '</value></field>  ' ||
                    '<field name="'||'VAN_D_FD'   ||'"><value>' ||substr(vans_entries.van_from_d,9,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_D_FM'   ||'"><value>' ||substr(vans_entries.van_from_d,6,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_D_FY'   ||'"><value>' ||substr(vans_entries.van_from_d,1,4)       || '</value></field>  ' ||
                    '<field name="'||'VAN_D_TD'   ||'"><value>' ||substr(vans_entries.van_to_d,9,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_D_TM'   ||'"><value>' ||substr(vans_entries.van_to_d,6,2)         || '</value></field>  ' ||
                    '<field name="'||'VAN_D_TY'   ||'"><value>' ||substr(vans_entries.van_to_d,1,4)         || '</value></field>  ' ||
                    '<field name="'||'VAN_D'      ||'"><value>' ||vans_entries.van_unavil_d                 || '</value></field>  ' ||
                    '<field name="'||'VAN_E'      ||'"><value>' ||vans_entries.van_tot_day_unavil           || '</value></field>  ' ||
                    '<field name="'||'VAN_F'      ||'"><value>' ||vans_entries.van_unavil_value             || '</value></field>  ' ||
                    '<field name="'||'VAN_G'      ||'"><value>' ||vans_entries.van_reduce_value             || '</value></field>  ' ||
                    '<field name="'||'VAN_G2'     ||'"><value>' ||vans_entries.van_reduce_value             || '</value></field>  ' ||
                    '<field name="'||'VAN_H'      ||'"><value>' ||vans_entries.van_sh_pcent_reduc           || '</value></field>  ' ||
                    '<field name="'||'VAN_J'      ||'"><value>' ||vans_entries.van_sh_reduction             || '</value></field>  ' ||
                    '<field name="'||'VAN_EXP'    ||'"><value>' ||vans_entries.van_explanation              || '</value></field>  ' ||
                    '<field name="'||'VAN_K'      ||'"><value>' ||vans_entries.van_reduce_share             || '</value></field>  ' ||
                    '<field name="'||'VAN_L'      ||'"><value>' ||vans_entries.van_private_uses             || '</value></field>  ' ||
                    '<field name="'||'VAN_M'      ||'"><value>' ||vans_entries.van_benefit_charge           || '</value></field>  ' ||
                    '<field name="'||'VAN_R_FD'   ||'"><value>' ||substr(vans_entries.van_fuel_withdrawn,9,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_R_FM'   ||'"><value>' ||substr(vans_entries.van_fuel_withdrawn,6,2)       || '</value></field>  ' ||
                    '<field name="'||'VAN_R_FY'   ||'"><value>' ||substr(vans_entries.van_fuel_withdrawn,1,4)       || '</value></field>  ' ||
                    '<field name="'||'VAN_R'      ||'"><value>' ||l_days_after_fuel_wd       || '</value></field>  ' ||
                    '<field name="'||'VAN_S'      ||'"><value>' ||vans_entries.van_total_days_no_fuel       || '</value></field>  ' ||
                    '<field name="'||'VAN_T'      ||'"><value>' ||vans_entries.van_reduction                || '</value></field>  ' ||
                    '<field name="'||'VAN_V'      ||'"><value>' ||l_fuel_charge_reduction    || '</value></field>  ' ||
                    '<field name="'||'VAN_W'      ||'"><value>' ||vans_entries.van_reduction_sharing        || '</value></field>  ' ||
                    '<field name="'||'VAN_X'      ||'"><value>' ||vans_entries.van_feul_ben_charge          || '</value></field>  ' ||
                    '</fields>  </xfdf>';
            end loop;
        end if;

        hr_utility.trace('10');
        open l_ret_ref_cursor for
        select *
        from table (cast(l_xfdf_str_tab as per_gb_xfdftableType));
        p_record_num := l_loop_count;
        return l_ret_ref_cursor;
   end ;

   function fetch_ws4_ref_cursor (p_assignment_action_id Number,
                                  p_record_num out nocopy NUmber) return ref_cursor_typ
   is
        -- per_gb_xfdftableType is explicitly created type
        -- only modification needed is it could be of type blob
        -- i tried thta but could not access the blob valus in java routine.
        -- can be sorted later
        l_xfdf_str_tab per_gb_xfdftableType := per_gb_xfdftableType( );
        l_xfdf_str varchar2(32000);
        l_ret_ref_cursor ref_cursor_typ;
        cursor csr_int_entries (p_pactid Number,
                                p_person_id Number,
                                p_emp_ref Varchar2 ,
                                p_emp_name Varchar2)
        is
        select ACTION_INFORMATION7            Maximum_Amount_Outstanding,
               ' '                            Currency, -- 'GBP'Currency, -- as we currently support just GBP
               to_number(nvl(ACTION_INFORMATION6,'0'))  Amount_Outstanding_at_5th_Apri,
               to_number(nvl(ACTION_INFORMATION16,'0')) Amount_Outstanding_at_Year_End,
               ACTION_INFORMATION18           Official_Rate_of_Interest,
               ACTION_INFORMATION8            Total_Amount_of_Interest_Paid,
               ACTION_INFORMATION11           Cash_Equivalent,
               ACTION_INFORMATION19           Annual_Interest_Value,
               ACTION_INFORMATION20           Interest_Value,
               action_context_id
        from  pay_action_information
        where action_information_category = 'INT FREE AND LOW INT LOANS'
        and   action_context_type = 'AAP'
        and   action_context_id in(select paa.assignment_action_id
                                    from   pay_action_information pai_comp,
                                           pay_action_information pai_person,
                                           pay_assignment_actions paa,
                                           pay_payroll_actions ppa
                                    where  ppa.payroll_action_id = p_pactid
                                    and    paa.payroll_action_id = ppa.payroll_action_id
                                    and    pai_comp.action_context_id = paa.assignment_action_id
                                    and    pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                                    and    pai_comp.action_context_type = 'AAP'
                                    and    pai_person.action_context_id = paa.assignment_action_id
                                    and    pai_person.action_information_category = 'ADDRESS DETAILS'
                                    and    pai_person.action_context_type = 'AAP'
                                    and    pai_person.action_information14 = 'Employee Address'
                                    and    pai_person.action_information1 = to_char(p_person_id)
                                    and    pai_comp.action_information6 = p_emp_ref
                                    and    pai_comp.action_information7 = p_emp_name)
        and   to_number(nvl(ACTION_INFORMATION11,'0')) > 0;

        l_emp_ref_no varchar2(150);
        l_employer_name varchar2(150);
        l_full_name varchar2(150);
        l_sur_name varchar2(150); --  P11D 08/09
        l_fore_name varchar2(150); -- P11D 08/09
        l_national_ins_no varchar2(150);
        l_employee_number varchar2(150);
        l_pactid number;
        l_person_id number;
        l_loop_count Number;
        l_field_num Number;
        l_tab_index Number;
        l_amt_sum Number;
        l_AMT_AS_PER_MTH Number;
        l_int Number;
        l_h_sum_max_amt_outstanding Number;
        l_rep_run varchar2(10);
        l_loan_threshold Number;
   begin
        hr_utility.trace('calling get_employer_details');
        get_employer_details(p_assignment_action_id,
                             l_emp_ref_no,
                             l_employer_name);
        hr_utility.trace('calling get_employee_details');
        get_employee_details(p_assignment_action_id,
                             l_full_name,
                             l_national_ins_no,
                             l_employee_number);
        -- P11D 08/09
        -- Fetch sur and fore names
        get_sur_fore_names(p_assignment_action_id,
                           l_sur_name,
                           l_fore_name);
         -- P11D 08/09
        l_pactid := get_pactid(p_assignment_action_id);
        l_person_id := get_person_id (p_assignment_action_id );
        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => l_pactid,
         p_token_name                  => 'Rep_Run',
         p_token_value                 => l_rep_run);

        l_loop_count := 0;
        hr_utility.trace('l_pactid ' || l_pactid);
        hr_utility.trace('l_person_id '|| l_person_id);
        hr_utility.trace('l_emp_ref_no '|| l_emp_ref_no);
        hr_utility.trace('l_employer_name '|| l_employer_name);
        l_tab_index := 0;

        select to_number(nvl(ACTION_INFORMATION23,'0'))
        into  l_h_sum_max_amt_outstanding
        from  pay_action_information pai_emp
        where pai_emp.action_context_id = p_assignment_action_id
        and   pai_emp.action_information_category = 'GB P11D ASSIGNMENT RESULTC';

        if to_number(l_rep_run) < 2007 then
           l_loan_threshold := 5000;
        else
           -- Fetch the minimum outstanding
           select to_number(global_value)
           into  l_loan_threshold
           from  ff_globals_f
           where global_name = 'P11D_LOW_INT_LOAN_THRESHOLD'
           and   to_date('05-04-' || l_rep_run,'DD-MM-YYYY') between effective_start_date and effective_end_date;
        end if;

        if l_h_sum_max_amt_outstanding > l_loan_threshold
        then
            for int_entries in  csr_int_entries(l_pactid,
                                                l_person_id,
                                                l_emp_ref_no,
                                                l_employer_name)
            loop
                l_employee_number := get_assignment_number(int_entries.action_context_id);
                l_loop_count := l_loop_count+1;
                hr_utility.trace('l_loop_count '  ||l_loop_count);
                --we need 5 records in a single pdf template so if more than 5 exists
                --we need extra pages ceil(l_loop_count/5) will give the index number
                --for the l_ws4_info_tab
                if l_tab_index =ceil(l_loop_count/5)
                then
                    -- means same template input
                      null;
                else -- new template input
                    if l_tab_index <> 0 then
                       -- this will end the first tempalet input.
                       l_xfdf_str_tab(l_tab_index) := l_xfdf_str_tab(l_tab_index) || '</fields>  </xfdf>';
                    end if;
                    -- assign the new index number of the template
                    l_tab_index := ceil(l_loop_count/5);
                    l_xfdf_str_tab.extend;
                    l_xfdf_str_tab(l_tab_index) := '<?xml version = "1.0" encoding = "UTF-8"?>
                        <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                        <fields> ' ||
                        '<field name="'||'EMPLOYERS_NAME'||'"><value>' ||replace(l_employer_name,'&','&amp;')  || '</value></field> ' ||
                        '<field name="'||'FULL_NAME'||'"><value>' ||l_full_name || '</value></field>  ' ||
                         -- P11D 08/09
                        ' <field name="'|| 'SUR_NAME' ||'"><value>' ||l_sur_name  || '</value></field> ' ||
                        ' <field name="'|| 'FORE_NAME'||'"><value>' ||l_fore_name || '</value></field> ' ||
                         -- P11D 08/09
                        '<field name="'||'EMPLOYERS_REF_NO'||'"><value>' ||l_emp_ref_no || '</value></field>  ' ||
                        '<field name="'||'EMPLOYEE_NUMBER'||'"><value>' ||l_employee_number || '</value></field>  ' ||
                        '<field name="'||'NI_1'||'"><value>' ||substr(l_national_ins_no,1,1) || '</value></field>  ' ||
                        '<field name="'||'NI_2'||'"><value>' ||substr(l_national_ins_no,2,1) || '</value></field>  ' ||
                        '<field name="'||'NI_3'||'"><value>' ||substr(l_national_ins_no,3,1) || '</value></field>  ' ||
                        '<field name="'||'NI_4'||'"><value>' ||substr(l_national_ins_no,4,1) || '</value></field>  ' ||
                        '<field name="'||'NI_5'||'"><value>' ||substr(l_national_ins_no,5,1) || '</value></field>  ' ||
                        '<field name="'||'NI_6'||'"><value>' ||substr(l_national_ins_no,6,1) || '</value></field>  ' ||
                        '<field name="'||'NI_7'||'"><value>' ||substr(l_national_ins_no,7,1) || '</value></field>  ' ||
                        '<field name="'||'NI_8'||'"><value>' ||substr(l_national_ins_no,8,1) || '</value></field>  ' ||
                        '<field name="'||'NI_9'||'"><value>' ||substr(l_national_ins_no,9) || '</value></field>  ' ;
                end if;
                hr_utility.trace('l_tab_index '  ||l_tab_index);
                l_field_num := mod(l_loop_count,5);
                if l_field_num = 0
                then
                    l_field_num := 5;
                end if;
                hr_utility.trace('l_field_num '  ||l_field_num);
                l_xfdf_str_tab(l_tab_index) :=  l_xfdf_str_tab(l_tab_index)  ||
                    '<field name="'||'MAX_OUT_'  || l_field_num ||'"><value>' ||int_entries.Maximum_Amount_Outstanding || '</value></field>  ' ||
                    '<field name="'||'CURRENCY_' || l_field_num ||'"><value>' ||int_entries.Currency || '</value></field>  ' ||
                    '<field name="'||'AMT_YRST_' || l_field_num ||'"><value>' ||int_entries.Amount_Outstanding_at_5th_Apri || '</value></field>  ' ||
                    '<field name="'||'AMT_YREND_'|| l_field_num ||'"><value>' ||int_entries.Amount_Outstanding_at_Year_End || '</value></field>  ' ;
                l_amt_sum   :=  nvl(int_entries.Amount_Outstanding_at_5th_Apri,0) +
                                nvl(int_entries.Amount_Outstanding_at_Year_End,0);
                l_xfdf_str_tab(l_tab_index) :=        l_xfdf_str_tab(l_tab_index)  ||
                    '<field name="'||'AMT_SUM_'  || l_field_num ||'"><value>' ||l_amt_sum || '</value></field>  ' ||
                    '<field name="'||'AMT_AVG_'  || l_field_num ||'"><value>' ||(l_amt_sum/2) || '</value></field>  ' ||
                    '<field name="'||'TAX_MTH_'  || l_field_num ||'"><value>' ||(int_entries.Interest_Value) || '</value></field>  ' ;
                l_AMT_AS_PER_MTH := (l_amt_sum/2)*(int_entries.Interest_Value/12);
                l_xfdf_str_tab(l_tab_index) := l_xfdf_str_tab(l_tab_index)  ||
                    '<field name="'||'ACT_MTH_'|| l_field_num ||'"><value>' ||l_AMT_AS_PER_MTH || '</value></field>  ' ||
                    '<field name="'||'RATE_'   || l_field_num ||'"><value>' ||int_entries.Official_Rate_of_Interest || '</value></field>  ' ;
                l_int := round(l_AMT_AS_PER_MTH *int_entries.Official_Rate_of_Interest/100,2);
                l_xfdf_str_tab(l_tab_index) := l_xfdf_str_tab(l_tab_index)  ||
                    '<field name="'||'INT_'     || l_field_num ||'"><value>' ||l_int || '</value></field>  ' ||
                    '<field name="'||'EMP_INT_' || l_field_num ||'"><value>' ||int_entries.Total_Amount_of_Interest_Paid || '</value></field>  ' ||
                    '<field name="'||'CE_'      || l_field_num ||'"><value>' ||int_entries.Cash_Equivalent || '</value></field>  ' ;
            end loop;
        -- this will ensure the xfdf sytring ends with the correct fields
        end if;
        hr_utility.trace('After cursor close');
        hr_utility.trace('l_tab_index' || l_tab_index);
        if l_tab_index <> 0
        then
            l_xfdf_str_tab(l_tab_index) := l_xfdf_str_tab(l_tab_index) || '</fields>  </xfdf>';
        end if;
        open l_ret_ref_cursor for
        select *
        from table (cast(l_xfdf_str_tab as per_gb_xfdftableType));
        p_record_num := l_tab_index;
        return l_ret_ref_cursor;
   end ;

   function fetch_ws5_data_blob (p_assignment_action_id Number) return blob
   is
        l_xfdf_str clob;
        l_xfdf_blob_str blob;
        cursor csr_relocation_entries(p_pactid Number,
                                      p_person_id Number,
                                      p_emp_ref Varchar2 ,
                                      p_emp_name Varchar2)
        is
        select
              to_char(to_number(nvl(pai_ben.action_information9,0)),'FM999,999,990.00') GROSS_AMOUNT,
              to_char(to_number(nvl(pai_ben.action_information10,0)),'FM999,999,990.00') COST,
              to_char(to_number(nvl(pai_ben.action_information11,0)),'FM999,999,990.00') PAID_BY_EMPLOYEE,
              to_char(to_number(nvl(pai_ben.action_information10,0) - nvl(pai_ben.action_information11,0)),'FM999,999,990.00')QUALIFYING_BENEFITS,
              to_char(to_number(nvl(pai_ben.action_information13,0)),'FM999,999,990.00') COST_OF_ACCO,
              to_char(to_number(nvl(pai_ben.action_information9,0) + nvl(pai_ben.action_information13,0) +
              nvl(pai_ben.action_information10,0) - nvl(pai_ben.action_information11,0)),
                    'FM999,999,990.00') TOTAL,
              to_char(to_number(nvl(pai_ben.action_information14,0)),'FM999,999,990.00') EARLIER_YEARS,
              to_char(to_number(nvl(pai_ben.action_information15,0)),'FM999,999,990.00') AMOUNT_EXEMPTED,
              to_char(to_number(nvl(pai_ben.action_information5,0)),'FM999,999,990.00') FINAL_AMOUNT,
              action_context_id
        from  pay_action_information pai_ben
        where pai_ben.action_information_category = 'RELOCATION EXPENSES'
        and   pai_ben.action_context_type = 'AAP'
        and   pai_ben.action_context_id in ( select paa.assignment_action_id
                                             from   pay_action_information pai_comp,
                                                    pay_action_information pai_person,
                                                    pay_assignment_actions paa,
                                                    pay_payroll_actions ppa
                                             where  ppa.payroll_action_id = p_pactid
                                             and    paa.payroll_action_id = ppa.payroll_action_id
                                             and    pai_comp.action_context_id = paa.assignment_action_id
                                             and    pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                                             and    pai_comp.action_context_type = 'AAP'
                                             and    pai_person.action_context_id = paa.assignment_action_id
                                             and    pai_person.action_information_category = 'ADDRESS DETAILS'
                                             and    pai_person.action_context_type = 'AAP'
                                             and    pai_person.action_information14 = 'Employee Address'
                                             and    pai_person.action_information1 = to_char(p_person_id)
                                             and    pai_comp.action_information6 = p_emp_ref
                                             and    pai_comp.action_information7 = p_emp_name);
        l_emp_ref_no varchar2(150);
        l_employer_name varchar2(150);
        l_full_name varchar2(150);
        l_sur_name varchar2(150); --  P11D 08/09
        l_fore_name varchar2(150); -- P11D 08/09
        l_national_ins_no varchar2(150);
        l_employee_number varchar2(150);
        l_pactid number;
        l_person_id number;
        l_loop_count Number;
   begin
        get_employer_details(p_assignment_action_id,
                             l_emp_ref_no,
                             l_employer_name);
        get_employee_details(p_assignment_action_id,
                             l_full_name,
                             l_national_ins_no,
                             l_employee_number);
        -- P11D 08/09
        -- Fetch sur and fore names
        get_sur_fore_names(p_assignment_action_id,
                           l_sur_name,
                           l_fore_name);
         -- P11D 08/09
        l_pactid := get_pactid(p_assignment_action_id);
        l_person_id := get_person_id (p_assignment_action_id );
        l_loop_count := 0;
        dbms_lob.createtemporary(l_xfdf_str,false,DBMS_LOB.CALL);
        dbms_lob.open(l_xfdf_str,dbms_lob.lob_readwrite);
        for relocation_entries in  csr_relocation_entries(l_pactid,
                                                          l_person_id,
                                                          l_emp_ref_no,
                                                          l_employer_name)
        loop
            l_employee_number := get_assignment_number(relocation_entries.action_context_id);
            l_loop_count := l_loop_count+1;
            if l_loop_count = 1
            then
                dbms_lob.writeAppend( l_xfdf_str,
                length(
                '<?xml version = "1.0" encoding = "UTF-8"?>
                 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                 <fields> ' ||
                '<field name="'||'EMPLOYERS_NAME'   ||'"><value>' ||replace(l_employer_name,'&','&amp;')  ||'</value></field> ' ||
                '<field name="'||'FULL_NAME'        ||'"><value>' ||l_full_name                   || '</value></field>  ' ||
                 -- P11D 08/09
                ' <field name="'|| 'SUR_NAME' ||'"><value>' ||l_sur_name  || '</value></field> ' ||
                ' <field name="'|| 'FORE_NAME'||'"><value>' ||l_fore_name || '</value></field> ' ||
                 -- P11D 08/09
                '<field name="'||'EMPLOYERS_REF_NO' ||'"><value>' ||l_emp_ref_no                  || '</value></field>  ' ||
                '<field name="'||'EMPLOYEE_NUMBER'  ||'"><value>' ||l_employee_number             || '</value></field>  ' ||
                '<field name="'||'NI_1'             ||'"><value>' ||substr(l_national_ins_no,1,1) || '</value></field>  ' ||
                '<field name="'||'NI_2'             ||'"><value>' ||substr(l_national_ins_no,2,1) || '</value></field>  ' ||
                '<field name="'||'NI_3'             ||'"><value>' ||substr(l_national_ins_no,3,1) || '</value></field>  ' ||
                '<field name="'||'NI_4'             ||'"><value>' ||substr(l_national_ins_no,4,1) || '</value></field>  ' ||
                '<field name="'||'NI_5'             ||'"><value>' ||substr(l_national_ins_no,5,1) || '</value></field>  ' ||
                '<field name="'||'NI_6'             ||'"><value>' ||substr(l_national_ins_no,6,1) || '</value></field>  ' ||
                '<field name="'||'NI_7'             ||'"><value>' ||substr(l_national_ins_no,7,1) || '</value></field>  ' ||
                '<field name="'||'NI_8'             ||'"><value>' ||substr(l_national_ins_no,8,1) || '</value></field>  ' ||
                '<field name="'||'NI_9'             ||'"><value>' ||substr(l_national_ins_no,9)   || '</value></field>  '),
                '<?xml version = "1.0" encoding = "UTF-8"?>
                 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                 <fields> ' ||
                '<field name="'||'EMPLOYERS_NAME'   ||'"><value>' ||replace(l_employer_name,'&','&amp;')  ||'</value></field> ' ||
                '<field name="'||'FULL_NAME'        ||'"><value>' ||l_full_name                   || '</value></field>  ' ||
                -- P11D 08/09
                ' <field name="'|| 'SUR_NAME' ||'"><value>' ||l_sur_name  || '</value></field> ' ||
                ' <field name="'|| 'FORE_NAME'||'"><value>' ||l_fore_name || '</value></field> ' ||
                 -- P11D 08/09
		'<field name="'||'EMPLOYERS_REF_NO' ||'"><value>' ||l_emp_ref_no                  || '</value></field>  ' ||
                '<field name="'||'EMPLOYEE_NUMBER'  ||'"><value>' ||l_employee_number             || '</value></field>  ' ||
                '<field name="'||'NI_1'             ||'"><value>' ||substr(l_national_ins_no,1,1) || '</value></field>  ' ||
                '<field name="'||'NI_2'             ||'"><value>' ||substr(l_national_ins_no,2,1) || '</value></field>  ' ||
                '<field name="'||'NI_3'             ||'"><value>' ||substr(l_national_ins_no,3,1) || '</value></field>  ' ||
                '<field name="'||'NI_4'             ||'"><value>' ||substr(l_national_ins_no,4,1) || '</value></field>  ' ||
                '<field name="'||'NI_5'             ||'"><value>' ||substr(l_national_ins_no,5,1) || '</value></field>  ' ||
                '<field name="'||'NI_6'             ||'"><value>' ||substr(l_national_ins_no,6,1) || '</value></field>  ' ||
                '<field name="'||'NI_7'             ||'"><value>' ||substr(l_national_ins_no,7,1) || '</value></field>  ' ||
                '<field name="'||'NI_8'             ||'"><value>' ||substr(l_national_ins_no,8,1) || '</value></field>  ' ||
                '<field name="'||'NI_9'             ||'"><value>' ||substr(l_national_ins_no,9)   || '</value></field>  ');
            end if;
            dbms_lob.writeAppend( l_xfdf_str,
            length(
            '<field name="'||'GROSS_AMOUNT'       ||'"><value>' ||relocation_entries.GROSS_AMOUNT        || '</value></field>  ' ||
            '<field name="'||'COST'               ||'"><value>' ||relocation_entries.COST                || '</value></field>  ' ||
            '<field name="'||'PAID_BY_EMPLOYEE'   ||'"><value>' ||relocation_entries.PAID_BY_EMPLOYEE    || '</value></field>  ' ||
            '<field name="'||'QUALIFYING_BENEFITS'||'"><value>' ||relocation_entries.QUALIFYING_BENEFITS || '</value></field>  ' ||
            '<field name="'||'COST_OF_ACCO'       ||'"><value>' ||relocation_entries.COST_OF_ACCO        || '</value></field>  ' ||
            '<field name="'||'TOTAL'              ||'"><value>' ||relocation_entries.TOTAL               || '</value></field>  ' ||
            '<field name="'||'EARLIER_YEARS'      ||'"><value>' ||relocation_entries.EARLIER_YEARS       || '</value></field>  ' ||
            '<field name="'||'AMOUNT_EXEMPTED'    ||'"><value>' ||relocation_entries.AMOUNT_EXEMPTED     || '</value></field>  ' ||
            '<field name="'||'FINAL_AMOUNT'       ||'"><value>' ||relocation_entries.FINAL_AMOUNT        || '</value></field>  '),
            '<field name="'||'GROSS_AMOUNT'       ||'"><value>' ||relocation_entries.GROSS_AMOUNT        || '</value></field>  ' ||
            '<field name="'||'COST'               ||'"><value>' ||relocation_entries.COST                || '</value></field>  ' ||
            '<field name="'||'PAID_BY_EMPLOYEE'   ||'"><value>' ||relocation_entries.PAID_BY_EMPLOYEE    || '</value></field>  ' ||
            '<field name="'||'QUALIFYING_BENEFITS'||'"><value>' ||relocation_entries.QUALIFYING_BENEFITS || '</value></field>  ' ||
            '<field name="'||'COST_OF_ACCO'       ||'"><value>' ||relocation_entries.COST_OF_ACCO        || '</value></field>  ' ||
            '<field name="'||'TOTAL'              ||'"><value>' ||relocation_entries.TOTAL               || '</value></field>  ' ||
            '<field name="'||'EARLIER_YEARS'      ||'"><value>' ||relocation_entries.EARLIER_YEARS       || '</value></field>  ' ||
            '<field name="'||'AMOUNT_EXEMPTED'    ||'"><value>' ||relocation_entries.AMOUNT_EXEMPTED     || '</value></field>  ' ||
            '<field name="'||'FINAL_AMOUNT'       ||'"><value>' ||relocation_entries.FINAL_AMOUNT        || '</value></field>  ');
        end loop;
        if l_loop_count <> 0
        then
            dbms_lob.writeAppend( l_xfdf_str,length('</fields>  </xfdf>'),'</fields>  </xfdf>');
        end if;
        DBMS_LOB.CREATETEMPORARY(l_xfdf_blob_str,true);
        clob_to_blob(l_xfdf_str,l_xfdf_blob_str);
        dbms_lob.close(l_xfdf_str);
        dbms_lob.freetemporary(l_xfdf_str);
        return  l_xfdf_blob_str;
   end;

   function fetch_ws6_ref_cursor (p_assignment_action_id Number,
                                  p_record_num out nocopy NUmber) return ref_cursor_typ
   is
        -- per_gb_xfdftableType is explicitly created type
        -- only modification needed is it could be of type blob
        -- i tried thta but could not access the blob valus in java routine.
        -- can be sorted later
        l_xfdf_str_tab per_gb_xfdftableType := per_gb_xfdftableType( );
        l_xfdf_str varchar2(32000);
        l_ret_ref_cursor ref_cursor_typ;
        l_offset integer;
        l_varchar_buffer varchar2(32000);
        l_raw_buffer raw(32000);
        l_buffer_len number:= 32000;
        l_chunk_len number;

        cursor csr_amap_entries (p_pactid Number,
                                 p_person_id Number,
                                 p_emp_ref Varchar2 ,
                                 p_emp_name Varchar2)
        is
        select nvl(ACTION_INFORMATION12,0)  C_MILEAGE_ALLOW_PAYMENTS,
               nvl(ACTION_INFORMATION13,0)  B_MILEAGE_ALLOW_PAYMENTS,
               nvl(ACTION_INFORMATION14,0)  M_MILEAGE_ALLOW_PAYMENTS,
               nvl(ACTION_INFORMATION16,0)  C_TAX_DEDUCTED_PAYMENTS,
               nvl(ACTION_INFORMATION17,0)  B_TAX_DEDUCTED_PAYMENTS,
               nvl(ACTION_INFORMATION18,0)  M_TAX_DEDUCTED_PAYMENTS,
               (nvl(ACTION_INFORMATION12,0) - nvl(ACTION_INFORMATION16,0)) C_NET_ALLOWANCE,
               (nvl(ACTION_INFORMATION13,0) - nvl(ACTION_INFORMATION17,0)) B_NET_ALLOWANCE,
               (nvl(ACTION_INFORMATION14,0) - nvl(ACTION_INFORMATION18,0)) M_NET_ALLOWANCE,
               nvl(ACTION_INFORMATION1,0)  C_BUSINESS_MILES,
               nvl(ACTION_INFORMATION2,0)  M_BUSINESS_MILES,
               nvl(ACTION_INFORMATION3,0)  B_BUSINESS_MILES,
               nvl(ACTION_INFORMATION4,0) c_reimbursement_rate1,
               nvl(ACTION_INFORMATION6,0) m_reimbursement_rate1,
               nvl(ACTION_INFORMATION8,0) b_reimbursement_rate1,
               nvl(ACTION_INFORMATION5,0) c_reimbursement_rate2,
               nvl(ACTION_INFORMATION7,0) m_reimbursement_rate2,
               nvl(ACTION_INFORMATION9,0) b_reimbursement_rate2,
               nvl(ACTION_INFORMATION19,0) PASSEN_PAYMENTS,
               nvl(ACTION_INFORMATION20,0) PASSEN_BUSINESS_MILES,
               nvl(ACTION_INFORMATION21,0) PASSENGER_BUS_MILES_AMOUNT
        from pay_action_information
        where action_information_category = 'GB P11D ASSIGNMENT RESULTC'
        and   action_context_type = 'AAP'
        and   action_context_id = p_assignment_action_id;/*Removed sub query for assignment action id*/

--Start of the fix for the EAP bug 9383416
cursor get_ben_value (c_emp_ref in varchar2) is

       select /*+ ORDERED use_nl(paa,pai,pai_a,pai_person)
                    use_index(pai_person,pay_action_information_n2)
                    use_index(pai,pay_action_information_n2)
                    use_index(pai_a,pay_action_information_n2)*/
              pai_a.action_information12
       from   pay_assignment_actions  paa,
              pay_action_information  pai,
              pay_action_information  pai_a,
              pay_action_information  pai_person
       where  paa.assignment_action_id = p_assignment_action_id
       and    pai.action_context_id = paa.assignment_action_id
       and    pai.action_context_type = 'AAP'
       and    pai.action_information_category = pai.action_information_category
       and    pai_person.action_context_id = paa.assignment_action_id
       and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
       and    pai_person.action_context_type = 'AAP'
       and    upper(pai_person.action_information13) = upper(c_emp_ref)
       and    pai_a.action_context_id = paa.assignment_action_id
       and    pai_a.action_context_type = 'AAP'
       and    pai_a.action_information_category = 'GB P11D ASSIGNMENT RESULTA'
       and    pai.action_information_category = 'MILEAGE ALLOWANCE AND PPAYMENT';
--End of the fix for the EAP bug 9383416

        l_emp_ref_no varchar2(150);
        l_employer_name varchar2(150);
        l_full_name varchar2(150);
        l_sur_name varchar2(150); --  P11D 08/09
        l_fore_name varchar2(150); -- P11D 08/09
        l_national_ins_no varchar2(150);
        l_employee_number varchar2(150);
        l_pactid number;
        l_rep_run  varchar2(10);
        l_person_id number;
        type ws6_info_rec_typ is record (
          l_net_allowance Varchar2(20),
          l_bus_mile_1_amount Varchar2(20),
          l_bus_mile_2_amount Varchar2(20),
          l_total_tax_payment Varchar2(20),
          l_vehiclecheck      Varchar2(10),
          l_taxable_passen_payment Number,
          l_total_payment    Number,
          l_total_approved_maps Varchar2(20),
          l_business_miles_1 Number,
          l_business_miles_2 Number,
          l_c_mileage_allow_payments Number,
          l_c_tax_deducted_payments Number,
          l_c_business_miles    Number,
          l_c_reimbrs1_rate1   Number,
          l_c_reimbrs2_rate2   Number,
          l_c_net_allowance Number,
          l_passen_payments Number,
          l_passenger_bus_miles_amount  Number,
          l_passen_business_miles   Number);

        type ws6_info_rec_tab_typ is table of ws6_info_rec_typ index by Binary_integer;
        l_ws6_info_tab ws6_info_rec_tab_typ;
        l_loop_count Number;
        l_sum_PASSEN_PAYMENTS Varchar2(15);
        l_sum_PASSEN_BUSINESS_MILES Varchar2(15);
        l_sum_PASS_BUS_MILES_AMOUNT Varchar2(15);
        l_sum_Taxable_passen_payments Varchar2(15);
        l_miles1 Number :=0;
        l_miles2 Number :=0;
        l_mile1_amount Number :=0;
        l_mile2_amount Number :=0;
        l_Carvan  Varchar2(5);
        l_MCycle  Varchar2(5);
        l_BCycle  Varchar2(5);
        l_cnt     Number:=0;
        l_ben_value Number;
   begin
        get_employer_details(p_assignment_action_id,
                             l_emp_ref_no,
                             l_employer_name);
        get_employee_details(p_assignment_action_id,
                             l_full_name,
                             l_national_ins_no,
                             l_employee_number);
        -- P11D 08/09
        -- Fetch sur and fore names
        get_sur_fore_names(p_assignment_action_id,
                           l_sur_name,
                           l_fore_name);
         -- P11D 08/09
        l_pactid := get_pactid(p_assignment_action_id);
        l_person_id := get_person_id (p_assignment_action_id );
        l_employee_number := get_assignment_number(p_assignment_action_id,true,l_person_id,l_emp_ref_no);
        l_loop_count := 0;
        l_sum_PASSEN_PAYMENTS := 0;
        l_sum_PASSEN_BUSINESS_MILES := 0;
        l_sum_PASS_BUS_MILES_AMOUNT := 0;
        l_sum_Taxable_passen_payments:=0;

--Start of the fix for the EAP bug 9383416
        open get_ben_value(l_emp_ref_no);
        fetch get_ben_value into l_ben_value;
        close get_ben_value;
        if (l_ben_value > 0) then
--End of the fix for the EAP bug 9383416

        for amap_entries in  csr_amap_entries(l_pactid,
                                              l_person_id,
                                              l_emp_ref_no,
                                              l_employer_name)
        loop
            l_Carvan := '';
            l_BCycle := '';
            l_MCycle := '';
            l_cnt    := 0;
            if amap_entries.C_BUSINESS_MILES > 0
            then
                l_cnt := l_cnt + 1;
                l_Carvan := 'CAR';
            end if;
            if amap_entries.M_BUSINESS_MILES > 0
            then
                l_cnt := l_cnt + 1;
                l_MCycle := 'MCY';
            end if;
            if amap_entries.B_BUSINESS_MILES > 0
            then
                l_cnt := l_cnt + 1;
                l_BCycle := 'BCY';
            end if;
            for i in 1 .. l_cnt
            loop
                l_loop_count := l_loop_count+1;
                -- l_ws6_info_tab(l_loop_count).l_amap_entries := amap_entries;
                -- hardcoding 10000, as currently this si the fig,
                -- if this changes then we may archve max limit as well.
                HR_UTILITY.TRaCE('A');
                if l_BCycle = 'BCY'
                then
                    l_ws6_info_tab(l_loop_count).l_c_mileage_allow_payments := amap_entries.B_MILEAGE_ALLOW_PAYMENTS;
                    l_ws6_info_tab(l_loop_count).l_c_tax_deducted_payments  := amap_entries.B_TAX_DEDUCTED_PAYMENTS;
                    l_ws6_info_tab(l_loop_count).l_c_net_allowance          := amap_entries.B_NET_ALLOWANCE;
                    l_ws6_info_tab(l_loop_count).l_c_business_miles         := amap_entries.B_BUSINESS_MILES;
                    l_ws6_info_tab(l_loop_count).l_c_reimbrs1_rate1    := amap_entries.b_reimbursement_rate1;
                    l_ws6_info_tab(l_loop_count).l_c_reimbrs2_rate2    := amap_entries.b_reimbursement_rate2;
                    l_ws6_info_tab(l_loop_count).l_vehiclecheck           := 'B';
                    l_BCycle := '';
                elsif l_MCycle = 'MCY'
                then
                    l_ws6_info_tab(l_loop_count).l_c_mileage_allow_payments := amap_entries.M_MILEAGE_ALLOW_PAYMENTS;
                    l_ws6_info_tab(l_loop_count).l_c_tax_deducted_payments  := amap_entries.M_TAX_DEDUCTED_PAYMENTS;
                    l_ws6_info_tab(l_loop_count).l_c_net_allowance          := amap_entries.M_NET_ALLOWANCE;
                    l_ws6_info_tab(l_loop_count).l_c_business_miles       := amap_entries.M_BUSINESS_MILES;
                    l_ws6_info_tab(l_loop_count).l_c_reimbrs1_rate1  := amap_entries.m_reimbursement_rate1;
                    l_ws6_info_tab(l_loop_count).l_c_reimbrs2_rate2    := amap_entries.m_reimbursement_rate2;
                    l_ws6_info_tab(l_loop_count).l_vehiclecheck           := 'M';
                    l_MCycle := '';
                elsif l_Carvan = 'CAR'
                then
                    l_ws6_info_tab(l_loop_count).l_c_mileage_allow_payments := amap_entries.C_MILEAGE_ALLOW_PAYMENTS;
                    l_ws6_info_tab(l_loop_count).l_c_tax_deducted_payments := amap_entries.C_TAX_DEDUCTED_PAYMENTS;
                    l_ws6_info_tab(l_loop_count).l_c_net_allowance       := amap_entries.C_NET_ALLOWANCE;
                    l_ws6_info_tab(l_loop_count).l_c_business_miles      := amap_entries.C_BUSINESS_MILES;
                    l_ws6_info_tab(l_loop_count).l_c_reimbrs1_rate1    := amap_entries.c_reimbursement_rate1;
                    l_ws6_info_tab(l_loop_count).l_c_reimbrs2_rate2    :=  amap_entries.c_reimbursement_rate2;
                    l_ws6_info_tab(l_loop_count).l_vehiclecheck           := 'C';
                    l_Carvan :='';
                end if;
                l_ws6_info_tab(l_loop_count).l_passen_payments := amap_entries.PASSEN_PAYMENTS;
                l_ws6_info_tab(l_loop_count).l_passenger_bus_miles_amount := amap_entries.PASSENGER_BUS_MILES_AMOUNT;
                l_ws6_info_tab(l_loop_count).l_passen_business_miles := amap_entries.PASSEN_BUSINESS_MILES;
                -- l_ws6_info_tab(l_loop_count).l_amap_entries.Taxable_payments := 0;
                l_mile1_amount  :=0;
                l_mile2_amount :=0;
                if l_ws6_info_tab(l_loop_count).l_c_business_miles > 10000
                then
                    l_miles1 := 10000;
                    HR_UTILITY.TRaCE('B');
                    l_miles2 := l_ws6_info_tab(l_loop_count).l_c_business_miles - 10000;
                else
                    HR_UTILITY.TRaCE('C');
                    l_miles1 := l_ws6_info_tab(l_loop_count).l_c_business_miles;
                    l_miles2 := 0;
                end if;
                HR_UTILITY.TRaCE('D');
                l_mile1_amount := l_ws6_info_tab(l_loop_count).l_c_reimbrs1_rate1 * l_miles1;
                l_mile2_amount := l_ws6_info_tab(l_loop_count).l_c_reimbrs2_rate2 * l_miles2;
                l_ws6_info_tab(l_loop_count).l_bus_mile_1_amount:= to_char(to_number(l_mile1_amount),'FM999,999,990.00');
                HR_UTILITY.TRaCE('E');
                l_ws6_info_tab(l_loop_count).l_bus_mile_2_amount:= to_char(to_number(l_mile2_amount),'FM999,999,990.00');
                l_ws6_info_tab(l_loop_count).l_total_approved_maps:= to_char(to_number((l_mile1_amount+l_mile2_amount)),'FM999,999,990.00');
                HR_UTILITY.TRaCE('EE');
                l_ws6_info_tab(l_loop_count).l_total_payment :=
                   greatest(l_ws6_info_tab(l_loop_count).l_c_net_allowance -l_mile1_amount -  l_mile2_amount,0);
                HR_UTILITY.TRaCE('FF');
                l_ws6_info_tab(l_loop_count).l_business_miles_1:= l_miles1;
                l_ws6_info_tab(l_loop_count).l_business_miles_2:= l_miles2;
                --hr_uitility.trace('gg');
                l_ws6_info_tab(l_loop_count).l_taxable_passen_payment :=
                   greatest(l_ws6_info_tab(l_loop_count).l_passen_payments -
                   l_ws6_info_tab(l_loop_count).l_passenger_bus_miles_amount,0);
                l_ws6_info_tab(l_loop_count).l_total_tax_payment:=
                   to_char(to_number((l_ws6_info_tab(l_loop_count).l_total_payment +
                   l_ws6_info_tab(l_loop_count).l_taxable_passen_payment)),'FM999,999,990.00');
            end loop;
        end loop;
end if; --Added end if to fix the EAP bug 9383416


        for i in 1 .. l_loop_count
        loop
            if l_loop_count > 1 and i <> 1
            then
                l_ws6_info_tab(i).l_passen_payments := 0;
                l_ws6_info_tab(i).l_passen_business_miles :=0;
                l_ws6_info_tab(i).l_passenger_bus_miles_amount :=0;
                l_ws6_info_tab(i).l_taxable_passen_payment :=0;
                -- l_ws6_info_tab(i).l_total_tax_payment := to_char(to_number(l_ws6_info_tab(i).l_total_tax_payment ),'FM999,999,990.00');
                l_ws6_info_tab(i).l_total_tax_payment := to_char(to_number(l_ws6_info_tab(l_loop_count).l_total_payment),'FM999,999,990.00');
            end if;
        end loop;


        for i in 1 .. l_loop_count
        loop
            l_xfdf_str_tab.extend;
            l_xfdf_str_tab(i) := '<?xml version = "1.0" encoding = "UTF-8"?>
                <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                <fields> ' ||
                '<field name="'||'Employer'||'"><value>' ||replace(l_employer_name,'&','&amp;')  || '</value></field> ' ||
                '<field name="'||'Employee'||'"><value>' ||l_full_name || '</value></field>  ' ||
                -- P11D 08/09
                '<field name="'|| 'SUR_NAME' ||'"><value>' ||l_sur_name  || '</value></field> ' ||
                '<field name="'|| 'FORE_NAME'||'"><value>' ||l_fore_name || '</value></field> ' ||
                -- P11D 08/09
                '<field name="'||'PAYE_tax'||'"><value>' ||l_emp_ref_no || '</value></field>  ' ||
                '<field name="'||'Works_no'||'"><value>' ||l_employee_number || '</value></field>  ' ||
                --'<field name="'||'Nat_Ins_Num'||'"><value>' ||l_national_ins_no || '</value></field>  ' ||
                '<field name="'||'NI_1'||'"><value>' ||substr(l_national_ins_no,1,1) || '</value></field>  ' ||
                '<field name="'||'NI_2'||'"><value>' ||substr(l_national_ins_no,2,1) || '</value></field>  ' ||
                '<field name="'||'NI_3'||'"><value>' ||substr(l_national_ins_no,3,1) || '</value></field>  ' ||
                '<field name="'||'NI_4'||'"><value>' ||substr(l_national_ins_no,4,1) || '</value></field>  ' ||
                '<field name="'||'NI_5'||'"><value>' ||substr(l_national_ins_no,5,1) || '</value></field>  ' ||
                '<field name="'||'NI_6'||'"><value>' ||substr(l_national_ins_no,6,1) || '</value></field>  ' ||
                '<field name="'||'NI_7'||'"><value>' ||substr(l_national_ins_no,7,1) || '</value></field>  ' ||
                '<field name="'||'NI_8'||'"><value>' ||substr(l_national_ins_no,8,1) || '</value></field>  ' ||
                '<field name="'||'NI_9'||'"><value>' ||substr(l_national_ins_no,9) || '</value></field>  '  ||
                '<field name="'||'Mileage'||'"><value>' ||to_char(to_number(l_ws6_info_tab(i).l_c_mileage_allow_payments),'FM999,999,990.00') || '</value></field>  ' ||
                '<field name="'||'Mileage_2'||'"><value>' ||to_char(to_number(l_ws6_info_tab(i).l_c_tax_deducted_payments),'FM999,999,990.00') || '</value></field>  ' ||
                '<field name="'||'Mileage_3'||'"><value>' ||to_char(to_number(l_ws6_info_tab(i).l_c_net_allowance),'FM999,999,990.00') || '</value></field>  ' ||
                '<field name="'||'VehicleCheck'||'"><value>' || l_ws6_info_tab(i).l_vehiclecheck  || '</value></field>  ' ||
                '<field name="'||'VehicleCheck_C'||'"><value>' || l_ws6_info_tab(i).l_vehiclecheck  || '</value></field>  ' ||
                '<field name="'||'VehicleCheck_M'||'"><value>' || l_ws6_info_tab(i).l_vehiclecheck  || '</value></field>  ' ||
                '<field name="'||'VehicleCheck_B'||'"><value>' || l_ws6_info_tab(i).l_vehiclecheck  || '</value></field>  ' ||
                '<field name="'||'MilesTravelledBox'||'"><value>' ||to_char(to_number(l_ws6_info_tab(i).l_c_business_miles),'FM999,999,990.00')  || '</value></field>  ' ||
                '<field name="'||'Rates'||'"><value>'   || l_ws6_info_tab(i).l_c_reimbrs1_rate1 * 100  || '</value></field>  ' ||
                '<field name="'||'Rates_2'||'"><value>' || l_ws6_info_tab(i).l_c_reimbrs2_rate2 * 100  || '</value></field>  ' ||
                '<field name="'||'Rates_3'||'"><value>' ||to_char(to_number(l_ws6_info_tab(i).l_business_miles_1),'FM999,999,990.00') || '</value></field>  ' ||
                '<field name="'||'Rates_4'||'"><value>' ||to_char(to_number(l_ws6_info_tab(i).l_business_miles_2),'FM999,999,990.00') || '</value></field>  ' ||
                '<field name="'||'4A'||'"><value>' ||l_ws6_info_tab(i).l_bus_mile_1_amount || '</value></field>  ' ||
                '<field name="'||'4B'||'"><value>' ||l_ws6_info_tab(i).l_bus_mile_2_amount || '</value></field>  ' ||
                '<field name="'||'4C'||'"><value>' ||l_ws6_info_tab(i).l_total_approved_maps || '</value></field>  ' ||
                '<field name="'||'Payments'||'"><value>' ||to_char(to_number(l_ws6_info_tab(i).l_passen_payments),'FM999,999,990.00') || '</value></field>  ' ||
                '<field name="'||'Payments_1'||'"><value>' ||to_char(to_number(l_ws6_info_tab(i).l_passen_business_miles),'FM999,999,990.00') || '</value></field>  ' ||
                '<field name="'||'5M'||'"><value>' ||to_char(to_number(l_ws6_info_tab(i).l_passenger_bus_miles_amount),'FM999,999,990.00') || '</value></field>  ' ||
                '<field name="'||'Taxable'||'"><value>' ||to_char(to_number(l_ws6_info_tab(i).l_total_payment),'FM999,999,990.00') || '</value></field>  ' ||
                '<field name="'||'Taxable_1'||'"><value>' ||to_char(to_number(l_ws6_info_tab(i).l_taxable_passen_payment),'FM999,999,990.00') || '</value></field>  ' ||
                '<field name="'||'Taxable_2'||'"><value>' ||l_ws6_info_tab(i).l_total_tax_payment || '</value></field>  ' ||
                '</fields>  </xfdf>';
        end loop;

        open l_ret_ref_cursor for
        select *
        from table (cast(l_xfdf_str_tab as per_gb_xfdftableType));
        p_record_num := l_loop_count;

        return l_ret_ref_cursor;
   end ;

   /*To fetch no. of successful assignments for a payroll run*/
   function fetch_numberof_assignments(p_payroll_action_id Number) return number
   is
        cursor csr_pactid
        is
        select count(1)
        from  pay_assignment_actions
        where payroll_action_id = p_payroll_action_id
        and   action_status='C';

        l_pactid number;
   begin
        open csr_pactid ;
        fetch csr_pactid into l_pactid;
        close csr_pactid ;
        return l_pactid;
   end;

   function fetch_summary_xfdf_blob (p_assignment_action_id Number,
                                     p_print_Style varchar2) return blob --bug 8241399
				     -- p_print style parameter added to suppress additional blank page
   is
        l_xfdf_str clob;
        l_xfdf_blob_str blob;
        l_xfdf_intermetiate_var varchar2(20000);
        g_max_line    constant number := 46;
        g_desc_length constant number := 41;
        g_desc_size   constant number := 0.66;

        cursor csr_summary_entries (p_pactid Number,
                                    p_person_id Number,
                                    p_emp_ref Varchar2 ,
                                    p_emp_name Varchar2)
        is
        select decode(action_information_category,
                      'ASSETS TRANSFERRED','A',
                      'PAYMENTS MADE FOR EMP','B',
                      'VOUCHERS OR CREDIT CARDS','C',
                      'PVT MED TREATMENT OR INSURANCE','I',
                      'SERVICES SUPPLIED','K',
                      'ASSETS AT EMP DISPOSAL','L',
                      'P11D SHARES','M',
                      'OTHER ITEMS','N',
                      'OTHER ITEMS NON 1A','N',
                      'EXPENSES PAYMENTS','0') SECTION_TITLE,
               decode(action_information_category,
                      'ASSETS TRANSFERRED','Assets Transferred',
                      'PAYMENTS MADE FOR EMP','Payments made on behalf of employee',
                      'VOUCHERS OR CREDIT CARDS','Vouchers or credit cards',
                      'PVT MED TREATMENT OR INSURANCE','Private medical treatment or insurance',
                      'SERVICES SUPPLIED','Services Supplied',
                      'ASSETS AT EMP DISPOSAL','Assets placed at employee''s disposal',
                      'P11D SHARES','Shares',
                      'OTHER ITEMS','Other Items',
                      'OTHER ITEMS NON 1A','Other Items Non 1A',
                      'EXPENSES PAYMENTS','Expenses') SECTION_HEADING,
               decode(action_information_category,
                      'ASSETS TRANSFERRED',get_lookup_meaning(
                                           'GB_ASSET_TYPE',ACTION_INFORMATION6,
                                           fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                           || ' ' || ACTION_INFORMATION5,
                      'PAYMENTS MADE FOR EMP',get_lookup_meaning(
                                           'GB_PAYMENTS_MADE',ACTION_INFORMATION6,
                                           fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                           || ' ' || ACTION_INFORMATION5,
                      'VOUCHERS OR CREDIT CARDS',ACTION_INFORMATION5,
                      'PVT MED TREATMENT OR INSURANCE',ACTION_INFORMATION10,
                      'SERVICES SUPPLIED',ACTION_INFORMATION10,
                      'ASSETS AT EMP DISPOSAL',get_lookup_meaning(
                                            'GB_ASSETS',ACTION_INFORMATION5,
                                            fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                            || ' ' || ACTION_INFORMATION6,
                      'P11D SHARES','Share Related Benefits',
                      'OTHER ITEMS',replace(get_lookup_meaning(
                                           'GB_OTHER_ITEMS',ACTION_INFORMATION5,
                                           fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                           || ' ' || ACTION_INFORMATION6,'&','&amp;'),
                      'OTHER ITEMS NON 1A',get_lookup_meaning(
                                           'GB_OTHER_ITEMS_NON_1A',ACTION_INFORMATION5,
                                           fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                           || ' ' || ACTION_INFORMATION6,
                      'EXPENSES PAYMENTS',get_lookup_meaning(
                                           'GB_EXPENSE_TYPE',ACTION_INFORMATION5,
                                           fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                           || ' ' || ACTION_INFORMATION9) LINE_DETAIL,
               decode(action_information_category,
                            'ASSETS TRANSFERRED',ACTION_INFORMATION7,
                            'PAYMENTS MADE FOR EMP',null,
                            'VOUCHERS OR CREDIT CARDS',ACTION_INFORMATION6,
                            'PVT MED TREATMENT OR INSURANCE',ACTION_INFORMATION5,
                            'SERVICES SUPPLIED',ACTION_INFORMATION5,
                            'ASSETS AT EMP DISPOSAL',ACTION_INFORMATION7,
                            'P11D SHARES',null,
                            'OTHER ITEMS',ACTION_INFORMATION7,
                            'OTHER ITEMS NON 1A',ACTION_INFORMATION7,
                            'EXPENSES PAYMENTS',ACTION_INFORMATION6) LINE_COL1,
               decode(action_information_category,
                            'ASSETS TRANSFERRED',ACTION_INFORMATION8,
                            'PAYMENTS MADE FOR EMP',ACTION_INFORMATION7,
                            'VOUCHERS OR CREDIT CARDS',ACTION_INFORMATION7,
                            'PVT MED TREATMENT OR INSURANCE',ACTION_INFORMATION6,
                            'SERVICES SUPPLIED',ACTION_INFORMATION6,
                            'ASSETS AT EMP DISPOSAL',ACTION_INFORMATION8,
                            'P11D SHARES',null,
                            'OTHER ITEMS',ACTION_INFORMATION8,
                            'OTHER ITEMS NON 1A',ACTION_INFORMATION8,
                            'EXPENSES PAYMENTS',ACTION_INFORMATION7) LINE_COL2,
               decode(action_information_category,
                            'ASSETS TRANSFERRED',ACTION_INFORMATION9,
                            'PAYMENTS MADE FOR EMP',ACTION_INFORMATION8,
                            'VOUCHERS OR CREDIT CARDS',ACTION_INFORMATION11,
                            'PVT MED TREATMENT OR INSURANCE',ACTION_INFORMATION7,
                            'SERVICES SUPPLIED',ACTION_INFORMATION7,
                            'ASSETS AT EMP DISPOSAL',ACTION_INFORMATION9,
                            'P11D SHARES',decode(ACTION_INFORMATION5,'Y','Yes'),
                            'OTHER ITEMS',ACTION_INFORMATION9,
                            'OTHER ITEMS NON 1A',ACTION_INFORMATION9,
                            'EXPENSES PAYMENTS',ACTION_INFORMATION8) LINE_COL3,
               to_char(fnd_date.canonical_to_date(ACTION_INFORMATION3),'DD-MON-YYYY') LINE_START_DATE,
               to_char(fnd_date.canonical_to_date(ACTION_INFORMATION4),'DD-MON-YYYY') LINE_END_DATE
        from  pay_action_information
        where action_information_category in(
                            'ASSETS TRANSFERRED',
                            'PAYMENTS MADE FOR EMP',
                            'VOUCHERS OR CREDIT CARDS',
                            'PVT MED TREATMENT OR INSURANCE',
                            'SERVICES SUPPLIED',
                            'ASSETS AT EMP DISPOSAL',
                            'P11D SHARES',
                            'OTHER ITEMS',
                            'OTHER ITEMS NON 1A',
                            'EXPENSES PAYMENTS')
        and action_context_type = 'AAP'
        and action_context_id in ( select paa.assignment_action_id
                                   from  pay_action_information pai_comp,
                                         pay_action_information pai_person,
                                         pay_assignment_actions paa,
                                         pay_payroll_actions ppa
                                   where ppa.payroll_action_id = p_pactid
                                   and   paa.payroll_action_id = ppa.payroll_action_id
                                   and   pai_comp.action_context_id = paa.assignment_action_id
                                   and   pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                                   and   pai_person.action_context_id = paa.assignment_action_id
                                   and   pai_person.action_information_category = 'ADDRESS DETAILS'
                                   and   pai_person.action_information14 = 'Employee Address'
                                   and   pai_person.action_information1 = to_char(p_person_id)
                                   and   pai_comp.action_information6 = p_emp_ref
                                   and   pai_comp.action_information7 = p_emp_name)
        order by decode(action_information_category,
                            'ASSETS TRANSFERRED','A',
                            'PAYMENTS MADE FOR EMP','B',
                            'VOUCHERS OR CREDIT CARDS','C',
                            'PVT MED TREATMENT OR INSURANCE','I',
                            'SERVICES SUPPLIED','K',
                            'ASSETS AT EMP DISPOSAL','L',
                            'P11D SHARES','M',
                            'OTHER ITEMS','N',
                            'OTHER ITEMS NON 1A','N',
                            'EXPENSES PAYMENTS','O') asc,
                 decode(action_information_category,
                            'ASSETS TRANSFERRED','Assets Transferred',
                            'PAYMENTS MADE FOR EMP','Payments made on behalf of employee',
                            'VOUCHERS OR CREDIT CARDS','Vouchers or credit cards',
                            'PVT MED TREATMENT OR INSURANCE','Private medical treatment or insurance',
                            'SERVICES SUPPLIED','Services Supplied',
                            'ASSETS AT EMP DISPOSAL','Assets placed at employee''s disposal',
                            'P11D SHARES','Shares',
                            'OTHER ITEMS','Other Items',
                            'OTHER ITEMS NON 1A','Other Items Non 1A',
                            'EXPENSES PAYMENTS','Expenses') asc ;

        cursor csr_summary_entries_0405 (p_pactid Number,
                                         p_person_id Number,
                                         p_emp_ref Varchar2 ,
                                         p_emp_name Varchar2)
        is
        select decode(action_information_category,
                            'ASSETS TRANSFERRED','A',
                            'PAYMENTS MADE FOR EMP','B',
                            'VOUCHERS OR CREDIT CARDS','C',
                            'PVT MED TREATMENT OR INSURANCE','I',
                            'SERVICES SUPPLIED','K',
                            'ASSETS AT EMP DISPOSAL','L',
                            'OTHER ITEMS','M',
                            'OTHER ITEMS NON 1A','M',
                            'EXPENSES PAYMENTS','N') SECTION_TITLE,
               decode(action_information_category,
                            'ASSETS TRANSFERRED','Assets Transferred',
                            'PAYMENTS MADE FOR EMP','Payments made on behalf of employee',
                            'VOUCHERS OR CREDIT CARDS','Vouchers or credit cards',
                            'PVT MED TREATMENT OR INSURANCE','Private medical treatment or insurance',
                            'SERVICES SUPPLIED','Services Supplied',
                            'ASSETS AT EMP DISPOSAL','Assets placed at employee''s disposal',
                            'OTHER ITEMS','Other Items',
                            'OTHER ITEMS NON 1A','Other Items Non 1A',
                            'EXPENSES PAYMENTS','Expenses') SECTION_HEADING,
               decode(action_information_category,
                            'ASSETS TRANSFERRED',get_lookup_meaning(
                                                'GB_ASSET_TYPE', ACTION_INFORMATION6,
                                                fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                                 || ' ' || ACTION_INFORMATION5,
                            'PAYMENTS MADE FOR EMP',get_lookup_meaning(
                                                'GB_PAYMENTS_MADE', ACTION_INFORMATION6,
                                                fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                                 || ' ' || ACTION_INFORMATION5,
                            'VOUCHERS OR CREDIT CARDS',ACTION_INFORMATION5,
                            'PVT MED TREATMENT OR INSURANCE',ACTION_INFORMATION10,
                            'SERVICES SUPPLIED',ACTION_INFORMATION10,
                            'ASSETS AT EMP DISPOSAL',get_lookup_meaning(
                                                'GB_ASSETS', ACTION_INFORMATION5,
                                                fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                                 || ' ' || ACTION_INFORMATION6,
                            'OTHER ITEMS',replace(get_lookup_meaning(
                                                'GB_OTHER_ITEMS',ACTION_INFORMATION5,
                                                fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                          || ' ' || ACTION_INFORMATION6,'&','&amp;'),
                            'OTHER ITEMS NON 1A',get_lookup_meaning(
                                                'GB_OTHER_ITEMS_NON_1A', ACTION_INFORMATION5,
                                                fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                          || ' ' || ACTION_INFORMATION6,
                            'EXPENSES PAYMENTS',get_lookup_meaning(
                                                'GB_EXPENSE_TYPE',ACTION_INFORMATION5,
                                                fnd_date.canonical_to_date(ACTION_INFORMATION4))
                                          || ' ' || ACTION_INFORMATION9) LINE_DETAIL,
               decode(action_information_category,
                            'ASSETS TRANSFERRED',ACTION_INFORMATION7,
                            'PAYMENTS MADE FOR EMP',null,
                            'VOUCHERS OR CREDIT CARDS',ACTION_INFORMATION6,
                            'PVT MED TREATMENT OR INSURANCE',ACTION_INFORMATION5,
                            'SERVICES SUPPLIED',ACTION_INFORMATION5,
                            'ASSETS AT EMP DISPOSAL',to_char(to_number(ACTION_INFORMATION8)+to_number(ACTION_INFORMATION9)), --Changed for bug 8204969
                            'OTHER ITEMS',ACTION_INFORMATION7,
                            'OTHER ITEMS NON 1A',ACTION_INFORMATION7,
                            'EXPENSES PAYMENTS',ACTION_INFORMATION6) LINE_COL1,
               decode(action_information_category,
                            'ASSETS TRANSFERRED',ACTION_INFORMATION8,
                            'PAYMENTS MADE FOR EMP',ACTION_INFORMATION7,
                            'VOUCHERS OR CREDIT CARDS',ACTION_INFORMATION7,
                            'PVT MED TREATMENT OR INSURANCE',ACTION_INFORMATION6,
                            'SERVICES SUPPLIED',ACTION_INFORMATION6,
                            'ASSETS AT EMP DISPOSAL',ACTION_INFORMATION8,
                            'OTHER ITEMS',ACTION_INFORMATION8,
                            'OTHER ITEMS NON 1A',ACTION_INFORMATION8,
                            'EXPENSES PAYMENTS',ACTION_INFORMATION7) LINE_COL2,
               decode(action_information_category,
                            'ASSETS TRANSFERRED',ACTION_INFORMATION9,
                            'PAYMENTS MADE FOR EMP',ACTION_INFORMATION8,
                            'VOUCHERS OR CREDIT CARDS',ACTION_INFORMATION11,
                            'PVT MED TREATMENT OR INSURANCE',ACTION_INFORMATION7,
                            'SERVICES SUPPLIED',ACTION_INFORMATION7,
                            'ASSETS AT EMP DISPOSAL',ACTION_INFORMATION9,
                            'OTHER ITEMS',ACTION_INFORMATION9,
                            'OTHER ITEMS NON 1A',ACTION_INFORMATION9,
                            'EXPENSES PAYMENTS',ACTION_INFORMATION8) LINE_COL3,
               to_char(fnd_date.canonical_to_date(ACTION_INFORMATION3),'DD-MON-YYYY') LINE_START_DATE,
               to_char(fnd_date.canonical_to_date(ACTION_INFORMATION4),'DD-MON-YYYY') LINE_END_DATE
               from  pay_action_information
               where action_information_category in(
                            'ASSETS TRANSFERRED',
                            'PAYMENTS MADE FOR EMP',
                            'VOUCHERS OR CREDIT CARDS',
                            'PVT MED TREATMENT OR INSURANCE',
                            'SERVICES SUPPLIED',
                            'ASSETS AT EMP DISPOSAL',
                            'OTHER ITEMS',
                            'OTHER ITEMS NON 1A',
                            'EXPENSES PAYMENTS')
               and action_context_type = 'AAP'
               and action_context_id in ( select paa.assignment_action_id
                                          from  pay_action_information pai_comp,
                                                pay_action_information pai_person,
                                                pay_assignment_actions paa,
                                                pay_payroll_actions ppa
                                          where ppa.payroll_action_id = p_pactid
                                          and   paa.payroll_action_id = ppa.payroll_action_id
                                          and   pai_comp.action_context_id = paa.assignment_action_id
                                          and   pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                                          and   pai_person.action_context_id = paa.assignment_action_id
                                          and   pai_person.action_information_category = 'ADDRESS DETAILS'
                                          and   pai_person.action_information14 = 'Employee Address'
                                          and   pai_person.action_information1 = to_char(p_person_id)
                                          and   pai_comp.action_information6 = p_emp_ref
                                          and   pai_comp.action_information7 = p_emp_name)
               order by
                     decode(action_information_category,
                            'ASSETS TRANSFERRED','A',
                            'PAYMENTS MADE FOR EMP','B',
                            'VOUCHERS OR CREDIT CARDS','C',
                            'PVT MED TREATMENT OR INSURANCE','I',
                            'SERVICES SUPPLIED','K',
                            'ASSETS AT EMP DISPOSAL','L',
                            'OTHER ITEMS','M',
                            'OTHER ITEMS NON 1A','M',
                            'EXPENSES PAYMENTS','N') asc,
                    decode(action_information_category,
                            'ASSETS TRANSFERRED','Assets Transferred',
                            'PAYMENTS MADE FOR EMP','Payments made on behalf of employee',
                            'VOUCHERS OR CREDIT CARDS','Vouchers or credit cards',
                            'PVT MED TREATMENT OR INSURANCE','Private medical treatment or insurance',
                            'SERVICES SUPPLIED','Services Supplied',
                            'ASSETS AT EMP DISPOSAL','Assets placed at employee''s disposal',
                            'OTHER ITEMS','Other Items',
                            'OTHER ITEMS NON 1A','Other Items Non 1A',
                            'EXPENSES PAYMENTS','Expenses') asc ;
        l_emp_ref_no varchar2(150);
        l_employer_name varchar2(150);
        l_full_name varchar2(150);
        l_sur_name varchar2(150); --  P11D 08/09
        l_fore_name varchar2(150); -- P11D 08/09
        l_national_ins_no varchar2(150);
        l_employee_number varchar2(150);
        l_pactid number;
        l_person_id number;
        l_loop_count Number;
        l_tot_col1 Number;
        l_tot_col2 Number;
        l_tot_col3 Number;
        l_prev_section  varchar2(150);
        l_rep_run   VARCHAR2(10);
        l_line_count number;
        l_temp       number;
        l_odd_page   boolean;

        function get_desc_line(p_desc varchar2) return number is
           l_length number;
           l_offset number  := 0;
           l_word   varchar2(100);
           x        number := 1;
           l_number number := 0;
           l_count  number := 0;
           l_ret    number := 1;
        begin
           if length(p_desc) < g_desc_length then
              l_ret := 1;
           else
              l_length := length(p_desc);
              loop
                 l_number := l_number+1;
                 l_offset := instr(p_desc, ' ', x, 1);
                 if l_offset > 0 then
                    l_word := substr(p_desc, x, l_offset-x);
                    if length(l_word) < g_desc_length  then
                        if length(l_word) + l_count > g_desc_length then
                           l_count := length(l_word) + 1;
                           l_ret := l_ret + 1;
                        else
                           l_count := l_count + length(l_word) + 1;
                        end if;
                    else
                        l_ret := l_ret + ceil(length(l_word)/g_desc_length);
                        l_count := length(l_word) - floor(length(l_word)/g_desc_length) * g_desc_length + 1;
                    end if;
                 else
                    l_word := substr(p_desc, x);
                    if length(l_word) < g_desc_length  then
                        if length(l_word) + l_count > g_desc_length then
                           l_count := length(l_word) + 1;
                           l_ret := l_ret + 1;
                        else
                           l_count := l_count + length(l_word) + 1;
                        end if;
                    else
                        l_ret := l_ret + ceil(length(l_word)/g_desc_length);
                        l_count := length(l_word) - floor(length(l_word)/g_desc_length) * g_desc_length + 1;
                    end if;
                    exit;
                 end if;
                 x := l_offset+1;
              end loop;
           end if;
           return l_ret;
        end;

        procedure set_line_desc(p_section_heading  varchar2) is
             l_line_desc varchar2(1000);
        begin
             /* Reference to Share can be removed when do work for P11D 05/06 */
             if p_section_heading = 'Shares'
             then
                 -- we need blank line as per spec
                 l_line_desc := ' <field name="'||'COL1_SDATE'||'"><value>' ||'Start Date'|| '</value></field>  ' ||
                 '<field name="'||'COL1_EDATE'||'"><value>' ||'End Date'|| '</value></field>  ' ||
                 '<field name="'||'LINE_DESC'||'"><value>' ||null || '</value></field>  ' ||
                 '<field name="'||'COL1_HEADING'||'"><value>' ||null || '</value></field>  ' ||
                 '<field name="'||'COL2_HEADING'||'"><value>' ||null || '</value></field>  ' ||
                 '<field name="'||'COL3_HEADING'||'"><value>' ||null || '</value></field>  ' ;
             elsif p_section_heading = 'Payments made on behalf of employee' then
                 l_line_desc := ' <field name="'||'COL1_SDATE'||'"><value>' ||'Start Date'|| '</value></field>  ' ||
                 '<field name="'||'COL1_EDATE'||'"><value>' ||'End Date'|| '</value></field>  ' ||
                 '<field name="'||'LINE_DESC'||'"><value>' ||'Description' || '</value></field>  ' ||
                 '<field name="'||'COL1_HEADING'||'"><value>' ||null || '</value></field>  ' ||
                 '<field name="'||'COL2_HEADING'||'"><value>' ||'Value' || '</value></field>  ' ||
                 '<field name="'||'COL3_HEADING'||'"><value>' ||'Tax Notional' || '</value></field>  ' ;
             elsif p_section_heading = 'Other Items Non 1A' then
                 l_line_desc := ' <field name="'||'COL1_SDATE'||'"><value>' ||'Start Date'|| '</value></field>  ' ||
                 '<field name="'||'COL1_EDATE'||'"><value>' ||'End Date'|| '</value></field>  ' ||
                 '<field name="'||'LINE_DESC'||'"><value>' ||'Description Non 1A' || '</value></field>  ' ||
                 '<field name="'||'COL1_HEADING'||'"><value>' ||'Value' || '</value></field>  ' ||
                 '<field name="'||'COL2_HEADING'||'"><value>' ||'Made Good' || '</value></field>  ' ||
                 '<field name="'||'COL3_HEADING'||'"><value>' ||'Benefit' || '</value></field>  ' ;
             elsif p_section_heading = 'Assets placed at employee''s disposal' then
                 l_line_desc := ' <field name="'||'COL1_SDATE'||'"><value>' ||'Start Date'|| '</value></field>  ' ||
                 '<field name="'||'COL1_EDATE'||'"><value>' ||'End Date'|| '</value></field>  ' ||
                 '<field name="'||'LINE_DESC'||'"><value>' ||'Description' || '</value></field>  ' ||
                 '<field name="'||'COL1_HEADING'||'"><value>' ||'Annual Value' || '</value></field>  ' ||
                 '<field name="'||'COL2_HEADING'||'"><value>' ||'Made Good' || '</value></field>  ' ||
                 '<field name="'||'COL3_HEADING'||'"><value>' ||'Benefit' || '</value></field>  ' ;
             else
                 l_line_desc := ' <field name="'||'COL1_SDATE'||'"><value>' ||'Start Date'|| '</value></field>  ' ||
                 '<field name="'||'COL1_EDATE'||'"><value>' ||'End Date'|| '</value></field>  ' ||
                 '<field name="'||'LINE_DESC'||'"><value>' ||'Description' || '</value></field>  ' ||
                 '<field name="'||'COL1_HEADING'||'"><value>' ||'Value' || '</value></field>  ' ||
                 '<field name="'||'COL2_HEADING'||'"><value>' ||'Made Good' || '</value></field>  ' ||
                 '<field name="'||'COL3_HEADING'||'"><value>' ||'Benefit' || '</value></field>  ' ;
             end if;
             dbms_lob.writeAppend( l_xfdf_str, length(l_line_desc) ,l_line_desc );
        end;

        procedure add_total_lines is
        begin
             if  l_prev_section = 'Shares'
             then
                  -- then we do print totals
                 null;
             elsif l_prev_section = 'Payments made on behalf of employee'
             then
                 l_xfdf_intermetiate_var :=
                       '<field name="'||'LINE_TOTAL'||'"><value>' ||'Totals' || '</value></field>  ' ||
                       '<field name="'||'TOT_COL1'||'"><value>' ||l_TOT_COL1 || '</value></field>  ' ||
                       '<field name="'||'TOT_COL2'||'"><value>' ||to_char(to_number(nvl(l_TOT_COL2,0)),'FM999,999,990.00') || '</value></field>  ' ||
                       '<field name="'||'TOT_COL3'||'"><value>' ||to_char(to_number(nvl(l_TOT_COL3,0)),'FM999,999,990.00') || '</value></field>  ' ;
                 dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
             else
                 l_xfdf_intermetiate_var :=
                 ' <field name="'||'LINE_TOTAL'||'"><value>' ||'Totals' || '</value></field>  ' ||
                 ' <field name="'||'TOT_COL1'||'"><value>' ||to_char(to_number(nvl(l_TOT_COL1,0)),'FM999,999,990.00') || '</value></field>  ' ||
                 ' <field name="'||'TOT_COL2'||'"><value>' ||to_char(to_number(nvl(l_TOT_COL2,0)),'FM999,999,990.00') || '</value></field>  ' ||
                 ' <field name="'||'TOT_COL3'||'"><value>' ||to_char(to_number(nvl(l_TOT_COL3,0)),'FM999,999,990.00') || '</value></field>  ' ;
                 dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
             end if;
        end;

        procedure add_detail_line(p_SECTION_HEADING varchar2,
                                  p_LINE_DETAIL varchar2,
                                  p_LINE_COL1 varchar2,
                                  p_LINE_COL2 varchar2,
                                  p_LINE_COL3 varchar2,
                                  p_LINE_SDATE varchar2,
                                  p_LINE_EDATE varchar2) is
        begin
             if p_SECTION_HEADING = 'Payments made on behalf of employee' or
                p_SECTION_HEADING ='Shares'
             then
                 -- no defaulting of values reqd
                 if p_SECTION_HEADING = 'Payments made on behalf of employee'
                 then
                     l_xfdf_intermetiate_var :=
                     '<field name="'||'LINE_START_D'||'"><value>' ||p_LINE_SDATE   || '</value></field>  ' ||
                     '<field name="'||'LINE_END_D'||'"><value>'   ||p_LINE_EDATE   || '</value></field>  ' ||
                     '<field name="'||'LINE_DETAIL'||'"><value>' ||p_LINE_DETAIL || '</value></field>  ' ||
                     '<field name="'||'LINE_COL1'||'"><value>'   ||null   || '</value></field>  ' ||
                     '<field name="'||'LINE_COL2'||'"><value>'   ||to_char(to_number(nvl(p_LINE_COL2,0)),'FM999,999,990.00')   || '</value></field>  ' ||
                     '<field name="'||'LINE_COL3'||'"><value>'   ||to_char(to_number(nvl(p_LINE_COL3,0)),'FM999,999,990.00')   || '</value></field>  ' ;
                     dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                 else -- this mean it is shares entry
                     l_xfdf_intermetiate_var :=
                     '<field name="'||'LINE_START_D'||'"><value>' ||p_LINE_SDATE   || '</value></field>  ' ||
                     '<field name="'||'LINE_END_D'||'"><value>'   ||p_LINE_EDATE   || '</value></field>  ' ||
                     '<field name="'||'LINE_DETAIL'||'"><value>' ||p_LINE_DETAIL || '</value></field>  ' ||
                     '<field name="'||'LINE_COL1'||'"><value>'   ||p_LINE_COL1   || '</value></field>  ' ||
                     '<field name="'||'LINE_COL2'||'"><value>'   ||p_LINE_COL2   || '</value></field>  ' ||
                     '<field name="'||'LINE_COL3'||'"><value>'   ||p_LINE_COL3   || '</value></field>  ' ;
                     dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                 end if;
             else
                 l_xfdf_intermetiate_var :=
                 '<field name="'||'LINE_START_D'||'"><value>' ||p_LINE_SDATE   || '</value></field>  ' ||
                 '<field name="'||'LINE_END_D'||'"><value>'   ||p_LINE_EDATE   || '</value></field>  ' ||
                 '<field name="'||'LINE_DETAIL'||'"><value>' ||p_LINE_DETAIL || '</value></field>  ' ;
                 dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                 if nvl(p_LINE_COL1,nvl(p_LINE_COL3,0)) =  0
                 then
                     l_xfdf_intermetiate_var :=
                     '<field name="'||'LINE_COL1'||'"><value>'||to_char(to_number(nvl(p_LINE_COL3,0)),'FM999,999,990.00') || '</value></field>  ' ;
                     dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                 else
                     l_xfdf_intermetiate_var :=
                     '<field name="'||'LINE_COL1'||'"><value>'   ||to_char(to_number(nvl(p_LINE_COL1,nvl(p_LINE_COL3,0))),'FM999,999,990.00')   || '</value></field>  ' ;
                     dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                 end if;
                 l_xfdf_intermetiate_var :=
                 '<field name="'||'LINE_COL2'||'"><value>'   ||to_char(to_number(nvl(p_LINE_COL2,0)),'FM999,999,990.00')   || '</value></field>  ' ||
                 '<field name="'||'LINE_COL3'||'"><value>'   ||to_char(to_number(nvl(p_LINE_COL3,0)),'FM999,999,990.00')   || '</value></field>  ' ;
                 dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
            end if;
        end;
   begin
        --hr_utility.trace_on(null,'KT');
        hr_utility.trace('calling get_employer_details');
        get_employer_details(p_assignment_action_id,
                             l_emp_ref_no,
                              l_employer_name);
        hr_utility.trace('calling get_employee_details');
        get_employee_details(p_assignment_action_id,
                             l_full_name,
                             l_national_ins_no,
                             l_employee_number);
        -- P11D 08/09
        -- Fetch sur and fore names
        get_sur_fore_names(p_assignment_action_id,
                           l_sur_name,
                           l_fore_name);
        -- P11D 08/09
        l_pactid := get_pactid(p_assignment_action_id);
        l_person_id := get_person_id (p_assignment_action_id );
        l_employee_number := get_assignment_number(p_assignment_action_id, true, l_person_id, l_emp_ref_no);
        l_loop_count := 0;
        -- hr_utility.trace_on(null,'SUMM');
        hr_utility.trace('l_pactid ' || l_pactid);
        hr_utility.trace('l_person_id '|| l_person_id);
        hr_utility.trace('l_emp_ref_no '|| l_emp_ref_no);
        hr_utility.trace('l_employer_name '|| l_employer_name);
        hr_utility.trace('opening the cursor');
        l_tot_col1 := null;
        l_tot_col2 := null;
        l_tot_col3 := null;
        l_prev_section := null;
        hr_utility.trace('l_prev_section ' || l_prev_section);
        dbms_lob.createtemporary(l_xfdf_str,false,DBMS_LOB.CALL);
        dbms_lob.open(l_xfdf_str,dbms_lob.lob_readwrite);


        PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id => l_pactid,
         p_token_name        => 'Rep_Run',
         p_token_value       => l_rep_run);
        l_loop_count := 0;

        l_odd_page := TRUE;
        l_line_count := 0;
        if l_odd_page then
           hr_utility.trace('Current page is odd page');
        else
           hr_utility.trace('Current page is even page');
        end if;
        if to_number(l_rep_run) < 2005
        then
            for summary_entries in  csr_summary_entries(l_pactid,
                                                        l_person_id,
                                                        l_emp_ref_no,
                                                        l_employer_name)
            loop
                l_loop_count := l_loop_count+1;
                if l_loop_count = 1
                then
                    -- setting the emp details page title...
                    l_xfdf_intermetiate_var  := '<?xml version = "1.0" encoding = "UTF-8"?>
                    <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                    <fields> ' ||
                    '<field name="'||'BEN_START_YEAR'||'"><value>' ||(to_number(l_rep_run) - 1) || '</value></field> ' ||
                    '<field name="'||'BEN_END_YEAR'||'"><value>' ||to_number(l_rep_run)  || '</value></field> ' ||
                    '<field name="'||'EMPLOYERS_NAME'||'"><value>' ||replace(l_employer_name,'&','&amp;')       || '</value></field> ' ||
                    '<field name="'||'FULL_NAME'||'"><value>' ||l_full_name || '</value></field>  ' ||
                    '<field name="'||'EMPLOYERS_REF_NO'||'"><value>' ||l_emp_ref_no || '</value></field>  ' ||
                    '<field name="'||'EMPLOYEE_NUMBER'||'"><value>' ||l_employee_number || '</value></field>  ' ||
                    '<field name="'||'NATIONAL_INS_NO'||'"><value>' ||l_national_ins_no || '</value></field>  ' ;
                    dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                    -- add new section heading and section title
                    if summary_entries.SECTION_HEADING = 'Other Items Non 1A'
                    then
                        l_xfdf_intermetiate_var:=
                        '<field name="'||'SECTION_TITLE'||'"><value>' ||summary_entries.SECTION_TITLE || '</value></field>  ' ||
                        '<field name="'||'SECTION_HEADING'||'"><value>' ||'Other Items' || '</value></field>  ' ;
                        dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                    else
                        l_xfdf_intermetiate_var:=
                        '<field name="'||'SECTION_TITLE'||'"><value>' ||summary_entries.SECTION_TITLE || '</value></field>  ' ||
                        '<field name="'||'SECTION_HEADING'||'"><value>' ||summary_entries.SECTION_HEADING || '</value></field>  ' ;
                        dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                    end if;
                    -- add new line desc
                    set_line_desc(summary_entries.SECTION_HEADING);
                    hr_utility.trace('l_loop_count '  ||l_loop_count);
                    l_prev_section := summary_entries.SECTION_HEADING;
                    l_line_count := l_line_count + 2;
                end if;
                hr_utility.trace('l_prev_section ' || l_prev_section);
                hr_utility.trace('summary_entries.SECTION_HEADING ' || summary_entries.SECTION_HEADING);
                if l_prev_section = summary_entries.SECTION_HEADING
                then
                    -- we just add the line details
                    add_detail_line(summary_entries.SECTION_HEADING,
                                    summary_entries.LINE_DETAIL,
                                    summary_entries.LINE_COL1,
                                    summary_entries.LINE_COL2,
                                    summary_entries.LINE_COL3,
                                    summary_entries.LINE_START_DATE,
                                    summary_entries.LINE_END_DATE);
                    l_temp := get_desc_line(summary_entries.LINE_DETAIL);
                    hr_utility.trace(summary_entries.LINE_DETAIL || ' : ' || l_temp);
                    if (l_temp > 1) then
                        l_line_count := l_line_count + (l_temp * g_desc_size);
                    else
                        l_line_count := l_line_count + 1;
                    end if;
                    -- we need to sum the totals
                    if summary_entries.SECTION_HEADING <> 'Shares'
                    then
                        if summary_entries.SECTION_HEADING ='Payments made on behalf of employee'
                        then
                            l_TOT_COL1 := null;
                            l_TOT_COL2 := nvl(l_TOT_COL2,0) + nvl(summary_entries.LINE_COL2,0);
                            l_TOT_COL3 := nvl(l_TOT_COL3,0) + nvl(summary_entries.LINE_COL3,0);
                        else
                            l_TOT_COL1 := nvl(l_TOT_COL1,0) + nvl(summary_entries.LINE_COL1,nvl(summary_entries.LINE_COL3,0));
                            l_TOT_COL2 := nvl(l_TOT_COL2,0) + nvl(summary_entries.LINE_COL2,0);
                            l_TOT_COL3 := nvl(l_TOT_COL3,0) + nvl(summary_entries.LINE_COL3,0);
                        end if;
                    end if;
                else
                    hr_utility.trace('l_loop_count ' || l_loop_count);
                    add_total_lines;
                    l_line_count := l_line_count + 1;
                    hr_utility.trace('adding new section heading and title');
                    -- add new section heading and title
                    -- we do not add heading if the SECTION_HEADING is Other Items Non 1A
                    -- and prev was Other Items
                    if l_prev_section = 'Other Items' and  summary_entries.SECTION_HEADING = 'Other Items Non 1A'
                    then
                        -- we do not add section title and section heading
                        null;
                    else
                        l_xfdf_intermetiate_var  :=
                            '<field name="'||'SECTION_TITLE'||'"><value>' ||summary_entries.SECTION_TITLE || '</value></field>  ' ||
                            '<field name="'||'SECTION_HEADING'||'"><value>' ||summary_entries.SECTION_HEADING || '</value></field>  ' ;
                        dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                        l_line_count := l_line_count + 1;
                    end if;
                    -- add new line desc
                    set_line_desc(summary_entries.SECTION_HEADING);
                    l_line_count := l_line_count + 1;
                    -- add the line details
                    add_detail_line(summary_entries.SECTION_HEADING,
                                    summary_entries.LINE_DETAIL,
                                    summary_entries.LINE_COL1,
                                    summary_entries.LINE_COL2,
                                    summary_entries.LINE_COL3,
                                    summary_entries.LINE_START_DATE,
                                    summary_entries.LINE_END_DATE);
                    l_temp := get_desc_line(summary_entries.LINE_DETAIL);
                    hr_utility.trace(summary_entries.LINE_DETAIL || ' : ' || l_temp);
                    if (l_temp > 1) then
                        l_line_count := l_line_count + (l_temp * g_desc_size);
                    else
                        l_line_count := l_line_count + 1;
                    end if;
                    -- resetting tot cols
                    l_tot_col1 := null;
                    l_tot_col2 := null;
                    l_tot_col3 := null;
                    l_prev_section := summary_entries.SECTION_HEADING;
                    -- we need to sum the totals
                    if summary_entries.SECTION_HEADING <> 'Shares'
                    then
                        if summary_entries.SECTION_HEADING ='Payments made on behalf of employee'
                        then
                            l_TOT_COL1 := null;
                            l_TOT_COL2 := nvl(l_TOT_COL2,0) + nvl(summary_entries.LINE_COL2,0);
                            l_TOT_COL3 := nvl(l_TOT_COL3,0) + nvl(summary_entries.LINE_COL3,0);
                        else
                            l_TOT_COL1 := nvl(l_TOT_COL1,0) +
                                          nvl(summary_entries.LINE_COL1,nvl(summary_entries.LINE_COL3,0));
                            l_TOT_COL2 := nvl(l_TOT_COL2,0) + nvl(summary_entries.LINE_COL2,0);
                            l_TOT_COL3 := nvl(l_TOT_COL3,0) + nvl(summary_entries.LINE_COL3,0);
                        end if;
                    end if;
                end if;
                if l_line_count > g_max_line then
                   l_odd_page := not(l_odd_page);
                   l_line_count := l_line_count - g_max_line;
                end if;
            end loop;
        else
            /* This code is for year 04/05 onwards */
            for summary_entries in  csr_summary_entries_0405(l_pactid,
                                                             l_person_id,
                                                             l_emp_ref_no,
                                                             l_employer_name)
            loop
                l_loop_count := l_loop_count+1;
                if l_loop_count = 1
                then
                    -- setting the emp details page title...
                    l_xfdf_intermetiate_var  := '<?xml version = "1.0" encoding = "UTF-8"?>
                        <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
                        <fields> ' ||
                        '<field name="'||'BEN_START_YEAR'||'"><value>' ||(to_number(l_rep_run) - 1) || '</value></field> ' ||
                        '<field name="'||'BEN_END_YEAR'||'"><value>' ||to_number(l_rep_run)  || '</value></field> ' ||
                        '<field name="'||'EMPLOYERS_NAME'||'"><value>' ||replace(l_employer_name,'&','&amp;')       || '</value></field> ' ||
                        '<field name="'||'FULL_NAME'||'"><value>' ||l_full_name || '</value></field>  ' ||
                        -- P11D 08/09
                        ' <field name="'|| 'SUR_NAME' ||'"><value>' ||l_sur_name  || '</value></field> ' ||
                        ' <field name="'|| 'FORE_NAME'||'"><value>' ||l_fore_name || '</value></field> ' ||
                        -- P11D 08/09
                        '<field name="'||'EMPLOYERS_REF_NO'||'"><value>' ||l_emp_ref_no || '</value></field>  ' ||
                        '<field name="'||'EMPLOYEE_NUMBER'||'"><value>' ||l_employee_number || '</value></field>  ' ||
                        '<field name="'||'NATIONAL_INS_NO'||'"><value>' ||l_national_ins_no || '</value></field>  ' ;
                    dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                    -- add new section heading and section title
                    if summary_entries.SECTION_HEADING = 'Other Items Non 1A'
                    then
                        l_xfdf_intermetiate_var:=
                            '<field name="'||'SECTION_TITLE'||'"><value>' ||summary_entries.SECTION_TITLE || '</value></field>  ' ||
                            '<field name="'||'SECTION_HEADING'||'"><value>' ||'Other Items' || '</value></field>  ' ;
                        dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                    else
                        l_xfdf_intermetiate_var:=
                           '<field name="'||'SECTION_TITLE'||'"><value>' ||summary_entries.SECTION_TITLE || '</value></field>  ' ||
                           '<field name="'||'SECTION_HEADING'||'"><value>' ||summary_entries.SECTION_HEADING || '</value></field>  ' ;
                        dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                    end if;
                    -- add new line desc

                    set_line_desc(summary_entries.SECTION_HEADING);
                    hr_utility.trace('l_loop_count '  ||l_loop_count);
                    l_prev_section := summary_entries.SECTION_HEADING;
                    l_line_count := l_line_count + 2;
                    hr_utility.trace('Writing line_desc + header : ' || l_line_count);
                end if;
                hr_utility.trace('l_prev_section ' || l_prev_section);
                hr_utility.trace('summary_entries.SECTION_HEADING ' || summary_entries.SECTION_HEADING);
                if l_prev_section = summary_entries.SECTION_HEADING
                then
                    -- we just add the line details
                    add_detail_line(summary_entries.SECTION_HEADING,
                                    summary_entries.LINE_DETAIL,
                                    summary_entries.LINE_COL1,
                                    summary_entries.LINE_COL2,
                                    summary_entries.LINE_COL3,
                                    summary_entries.LINE_START_DATE,
                                    summary_entries.LINE_END_DATE);
                    l_temp := get_desc_line(summary_entries.LINE_DETAIL);
                    hr_utility.trace(summary_entries.LINE_DETAIL || ' : ' || l_temp);
                    if (l_temp > 1) then
                        l_line_count := l_line_count + (l_temp * g_desc_size);
                    else
                        l_line_count := l_line_count + 1;
                    end if;
                    hr_utility.trace('Writing line details : ' || l_line_count);
                    -- we need to sum the totals
                    if summary_entries.SECTION_HEADING <> 'Shares'
                    then
                        if summary_entries.SECTION_HEADING ='Payments made on behalf of employee'
                        then
                            l_TOT_COL1 := null;
                            l_TOT_COL2 := nvl(l_TOT_COL2,0) + nvl(summary_entries.LINE_COL2,0);
                            l_TOT_COL3 := nvl(l_TOT_COL3,0) + nvl(summary_entries.LINE_COL3,0);
                        else
                            l_TOT_COL1 := nvl(l_TOT_COL1,0) +
                                nvl(summary_entries.LINE_COL1,nvl(summary_entries.LINE_COL3,0));
                            l_TOT_COL2 := nvl(l_TOT_COL2,0) + nvl(summary_entries.LINE_COL2,0);
                            l_TOT_COL3 := nvl(l_TOT_COL3,0) + nvl(summary_entries.LINE_COL3,0);
                        end if;
                    end if;
                else
                    hr_utility.trace('l_loop_count ' || l_loop_count);
                    add_total_lines;
                    l_line_count := l_line_count + 1;
                    hr_utility.trace('Writing total line : ' || l_line_count);
                    hr_utility.trace('adding new section heading and title');
                    -- add new section heading and title
                    -- we do not add heading if the SECTION_HEADING is Other Items Non 1A
                    -- and prev was Other Items
                    if l_prev_section = 'Other Items' and
                       summary_entries.SECTION_HEADING = 'Other Items Non 1A'
                    then
                        -- we do not add section title and section heading
                        null;
                    else
                        l_xfdf_intermetiate_var  :=
                           '<field name="'||'SECTION_TITLE'||'"><value>' ||summary_entries.SECTION_TITLE || '</value></field>  ' ||
                           '<field name="'||'SECTION_HEADING'||'"><value>' ||summary_entries.SECTION_HEADING || '</value></field>  ' ;
                        dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
                        l_line_count := l_line_count + 1;
                        hr_utility.trace('Writing header : ' || l_line_count);
                    end if;
                    -- add new line desc
                    set_line_desc(summary_entries.SECTION_HEADING);
                    l_line_count := l_line_count + 1;
                    hr_utility.trace('Writing line_desc : ' || l_line_count);
                    -- add the line details
                    add_detail_line(summary_entries.SECTION_HEADING,
                                    summary_entries.LINE_DETAIL,
                                    summary_entries.LINE_COL1,
                                    summary_entries.LINE_COL2,
                                    summary_entries.LINE_COL3,
                                    summary_entries.LINE_START_DATE,
                                    summary_entries.LINE_END_DATE);
                    l_temp := get_desc_line(summary_entries.LINE_DETAIL);
                    hr_utility.trace(summary_entries.LINE_DETAIL || ' : ' || l_temp);
                    if (l_temp > 1) then
                        l_line_count := l_line_count + (l_temp * g_desc_size);
                    else
                        l_line_count := l_line_count + 1;
                    end if;
                    hr_utility.trace('Writing line details : ' || l_line_count);
                    -- resetting tot cols
                    l_tot_col1 := null;
                    l_tot_col2 := null;
                    l_tot_col3 := null;
                    l_prev_section := summary_entries.SECTION_HEADING;
                    -- we need to sum the totals
                    -- no need to check for Shares
                    /* if summary_entries.SECTION_HEADING <> 'Shares' then */
                    if  summary_entries.SECTION_HEADING ='Payments made on behalf of employee'
                    then
                        l_TOT_COL1 := null;
                        l_TOT_COL2 := nvl(l_TOT_COL2,0) + nvl(summary_entries.LINE_COL2,0);
                        l_TOT_COL3 := nvl(l_TOT_COL3,0) + nvl(summary_entries.LINE_COL3,0);
                    else
                        l_TOT_COL1 := nvl(l_TOT_COL1,0) +
                                nvl(summary_entries.LINE_COL1,nvl(summary_entries.LINE_COL3,0));
                        l_TOT_COL2 := nvl(l_TOT_COL2,0) + nvl(summary_entries.LINE_COL2,0);
                        l_TOT_COL3 := nvl(l_TOT_COL3,0) + nvl(summary_entries.LINE_COL3,0);
                    end if;
                   /* end if; */
                end if;
                if l_line_count > g_max_line then
                    hr_utility.trace('Line more than max line : ' || l_line_count);
                    if l_odd_page then
                       hr_utility.trace('Current page is odd page, resetting it to even');
                    else
                       hr_utility.trace('Current page is even page, resetting it to odd');
                    end if;
                   l_odd_page := not(l_odd_page);
                   l_line_count := l_line_count - g_max_line;
                   hr_utility.trace('New line count is : ' || l_line_count);
                end if;
            end loop;
        end if;
       if l_loop_count <> 0
        then
            -- add last total line
            add_total_lines;
            l_line_count := l_line_count + 1;
            hr_utility.trace('Writing total line : ' || l_line_count);
            hr_utility.trace('Final Line : ' || l_line_count);
            if l_odd_page then
               hr_utility.trace('Current page is Odd page');
            else
               hr_utility.trace('Current page is Even page');
            end if;

            if l_line_count > g_max_line then
               hr_utility.trace('Line more than max line : ' || l_line_count);
               if l_odd_page then
                  hr_utility.trace('Current page is odd page, resetting it to even');
               else
                  hr_utility.trace('Current page is even page, resetting it to odd');
               end if;
               l_odd_page := not(l_odd_page);
               l_line_count := l_line_count - g_max_line;
               hr_utility.trace('New line count is : ' || l_line_count);
            end if;

            if l_odd_page and p_print_Style = 'Double Sided Printing' then --bug 8241399
               -- If print option is two sided printing we are appending the dummy XML data
               hr_utility.trace('Current page is Odd page');
               l_temp := ceil((g_max_line - l_line_count)/4) + 1;
               hr_utility.trace('Current line is : ' || l_line_count);
               hr_utility.trace('Writing more record (4 line / record) : ' || l_temp);
               for l_line_count in 0..l_temp loop
                  l_xfdf_intermetiate_var  :=
                      '<field name="'||'SECTION_TITLE'  ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'SECTION_HEADING'||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'COL1_SDATE'     ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'COL1_EDATE'     ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'LINE_DESC'      ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'COL1_HEADING'   ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'COL2_HEADING'   ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'COL3_HEADING'   ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'LINE_START_D'   ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'LINE_END_D'     ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'LINE_DETAIL'    ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'LINE_COL1'      ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'LINE_COL2'      ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'LINE_COL3'      ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'LINE_TOTAL'     ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'TOT_COL1'       ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'TOT_COL2'       ||'"><value>' ||null|| '</value></field>  ' ||
                      '<field name="'||'TOT_COL3'       ||'"><value>' ||null|| '</value></field>  ' ;
                     dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
               end loop;
            end if;
            -- this will ensure the xfdf string ends with the correct fields
            l_xfdf_intermetiate_var  :=  '</fields>  </xfdf>';
            dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
        end if;
        DBMS_LOB.CREATETEMPORARY(l_xfdf_blob_str,true);
        clob_to_blob(l_xfdf_str,l_xfdf_blob_str);
        dbms_lob.close(l_xfdf_str);
        dbms_lob.freetemporary(l_xfdf_str);
        hr_utility.trace('blob length '|| dbms_lob.getlength(l_xfdf_blob_str));
        --   Adding this causes error in xdo so commented this
        --   DBMS_LOB.FREETEMPORARY(l_xfdf_blob_str);
        --hr_utility.trace_off;
        return l_xfdf_blob_str;
   end ;
  /*Added this function to generate pdf report for Address*/
  /*Bug No. 3201848*/
 /* Bug 8571876 - Created function to replace special characters with XML symbols */
 FUNCTION replace_xml_symbols(p_string IN VARCHAR2) RETURN VARCHAR2 AS

 l_string   VARCHAR2(3200);

 BEGIN
	l_string :=  p_string;

	l_string := replace(l_string, '&', '&amp;');
	l_string := replace(l_string, '<', '&#60;');
	l_string := replace(l_string, '>', '&#62;');
      l_string := replace(l_string, '''','&apos;');
	l_string := replace(l_string, '"', '&quot;');

   RETURN l_string;
   EXCEPTION when no_data_found then
     null;
   END replace_xml_symbols;

  function fetch_address_xfdf_blob (p_assignment_action_id Number,
                                    p_print_Style varchar2, --bug 8241399
                         -- p_print style parameter added to suppress additional blank page
				    p_priv_mark varchar2) return blob --bug 8942337
                         --p_priv_mark parameter added to print user defined Data
			 --Privacy Marking on the address page
  is


        cursor csr_address_entries
        is
        select address_line1,
               address_line2,
               address_line3,
               town_or_city,
               postal_code,
               region_1
       from   per_addresses
       where  person_id = (
       select distinct person_id
       from   pay_assignment_actions paa,
              per_all_assignments_f  paf
       where  paa.assignment_action_id = p_assignment_action_id
       and    paf.assignment_id = paa.assignment_id)
       and    primary_flag = 'Y'
       and    sysdate between date_from and nvl(date_to, hr_general.end_of_time);

       cursor csr_person_name
       is
       select emp.action_information1             emp_name
       from   pay_action_information  emp
       where  emp.action_information_category   = 'EMPLOYEE DETAILS'
       and    emp.action_context_id             = p_assignment_action_id
       and    emp.action_context_type           = 'AAP';

        /*
        select emp.action_information1             emp_name
              ,adr.action_information5             adr_adress1
              ,adr.action_information6             adr_adress2
              ,adr.action_information7             adr_adress3
              ,adr.action_information8             adr_town
              ,adr.action_information12           adr_county
              ,adr.action_information9            adr_code
        from   pay_assignment_actions  paa
              ,pay_action_information  emp    -- Employee Details
              ,pay_action_information  adr    -- Address Details
              ,pay_action_information  prl    -- EMEA Payroll Info
        where  paa.assignment_action_id   = p_assignment_action_id
        and    emp.action_information_category   = 'EMPLOYEE DETAILS'
        and    emp.action_context_id             = paa.assignment_action_id
        and    emp.action_context_type           = 'AAP'
--
        and    prl.action_information_category   = 'EMEA PAYROLL INFO'
        and    prl.action_context_id             = paa.assignment_action_id
        and    prl.action_context_type           = 'AAP'
--
        and    adr.action_information_category   = 'ADDRESS DETAILS'
        and    adr.action_context_id             = paa.assignment_action_id
        and    adr.action_context_type           = 'AAP'
        and    adr.action_information14          = 'Employee Address';
        */
--
         cursor csr_lookup(p_code Varchar2)
         is
         select hlu.meaning hlu_meaning
         from   hr_lookups hlu
         where  hlu.lookup_type='GB_COUNTY'
         and    hlu.lookup_code=p_code
         and    hlu.enabled_flag='Y';

        --Cursor Added for bug 8942337
         cursor csr_get_priv_mark
         is
         select meaning
         from   hr_lookups
         where  lookup_type='GB_P11D_PRI_MARKINGS'
         and    lookup_code=p_priv_mark
         and    enabled_flag='Y';

         l_xfdf_str clob;
         l_xfdf_blob_str blob;
         l_xfdf_intermetiate_var varchar2(20000);
         l_adress1 pay_action_information.action_information5%type;
         l_adress2 pay_action_information.action_information6%type;
         l_adress3 pay_action_information.action_information7%type;
         l_town    pay_action_information.action_information8%type;
         l_county  pay_action_information.action_information12%type;
         l_employee_name pay_action_information.action_information1%type;
         l_sur_name varchar2(150); --  P11D 08/09
         l_fore_name varchar2(150); -- P11D 08/09
         l_code pay_action_information.action_information9%type;
         l_meaning hr_lookups.meaning%type;
       --Parameter Added for bug 8942337
         l_priv_mark_meaning     hr_lookups.meaning%type;

   begin

        dbms_lob.createtemporary(l_xfdf_str,false,DBMS_LOB.CALL);
        dbms_lob.open(l_xfdf_str,dbms_lob.lob_readwrite);

        open csr_address_entries;
        fetch csr_address_entries into l_adress1,l_adress2,l_adress3,l_town,l_county,l_code;
        close csr_address_entries;

        open csr_person_name;
        fetch csr_person_name into l_employee_name;
        close csr_person_name;

         -- P11D 08/09
         -- Fetch sur and fore names
         get_sur_fore_names(p_assignment_action_id,
                            l_sur_name,
                            l_fore_name);
         -- P11D 08/09

        if l_code is not null
        then
           open csr_lookup(l_code);
           fetch csr_lookup into l_meaning;
           close csr_lookup;
        end if;

      --For bug 8942337
        open csr_get_priv_mark;
        fetch csr_get_priv_mark into l_priv_mark_meaning;
        close csr_get_priv_mark;

 -- <field name="F_Value"><value>Private and Confidential</value></field>' || -- Added for bug 8723038

	l_xfdf_intermetiate_var  := '<?xml version = "1.0" encoding = "UTF-8"?>
	           <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><fields> '||
		   ' <field name="'||'F_Value'||'"><value>' || l_priv_mark_meaning || '</value></field> ' || --Bug 8942337
                   ' <field name="'||'F_EMP_NAME'||'"><value>' || l_employee_name || '</value></field> ' ||
                   -- P11D 08/09
                   ' <field name="'|| 'SUR_NAME' ||'"><value>' ||l_sur_name  || '</value></field> ' ||
                   ' <field name="'|| 'FORE_NAME'||'"><value>' ||l_fore_name || '</value></field> ' ||
                   -- P11D 08/09
			 --/* Bug 8571876 - Added replace_xml_symbols function in address columns */
                   ' <field name="'||'F_ADDR1'||'"><value>'  || replace_xml_symbols(l_adress1) || '</value></field>  ' ||
                   ' <field name="'||'F_ADDR2'||'"><value>'  || replace_xml_symbols(l_adress2) || '</value></field>  ' ||
                   ' <field name="'||'F_ADDR3'||'"><value>'  || replace_xml_symbols(l_adress3) || '</value></field>  ' ||
                   ' <field name="'||'F_TOWN'||'"><value>'   || replace_xml_symbols(l_town) || '</value></field>  ' ||
                   ' <field name="'||'F_COUNTY'||'"><value>' || replace_xml_symbols(ltrim(l_meaning || ' '|| l_county)) || '</value></field>  ' ||
                   '</fields>';
        If p_print_Style = 'Double Sided Printing' then --bug 8241399
	-- If print option is two sided printing we are appending the dummy XML data
		 l_xfdf_intermetiate_var  := l_xfdf_intermetiate_var || '<fields> ' ||
                   ' <field name="'||'F_EMP_NAME'||'"><value>' || null || '</value></field> ' ||
                   -- P11D 08/09
                   ' <field name="'|| 'SUR_NAME' ||'"><value>' ||null  || '</value></field> ' ||
                   ' <field name="'|| 'FORE_NAME'||'"><value>' ||null || '</value></field> ' ||
                   -- P11D 08/09
                   ' <field name="'||'F_ADDR1'||'"><value>'  || null || '</value></field>  ' ||
                   ' <field name="'||'F_ADDR2'||'"><value>'  || null || '</value></field>  ' ||
                   ' <field name="'||'F_ADDR3'||'"><value>'  || null || '</value></field>  ' ||
                   ' <field name="'||'F_TOWN'||'"><value>'   || null || '</value></field>  ' ||
                   ' <field name="'||'F_COUNTY'||'"><value>' || null || '</value></field>  ' ||
                   '</fields>';
        end if;
	l_xfdf_intermetiate_var := l_xfdf_intermetiate_var ||'</xfdf>';

--Start of the fix for the EAP bug 9383416
if (validate_display_output(p_assignment_action_id) = 1) then
        dbms_lob.writeAppend( l_xfdf_str, length(l_xfdf_intermetiate_var) ,l_xfdf_intermetiate_var );
end if;
--End of the fix for the EAP bug 9383416

        DBMS_LOB.CREATETEMPORARY(l_xfdf_blob_str,true);
        clob_to_blob(l_xfdf_str,l_xfdf_blob_str);
        dbms_lob.close(l_xfdf_str);
        dbms_lob.freetemporary(l_xfdf_str);
        --   Adding this causes error in xdo so commented this
        --   DBMS_LOB.FREETEMPORARY(l_xfdf_blob_str);
        return l_xfdf_blob_str;
   end;

   FUNCTION write_magtape_records (p_arch_payroll_action_id   NUMBER,
                                   p_emp_ref_no               VARCHAR2,
                                   p_person_id                VARCHAR2,
                                   p_assignment_number    OUT NOCOPY VARCHAR2,
                                   p_INT_MAX_AMT_OUTSTANDING OUT NOCOPY VARCHAR2) RETURN NUMBER
   -- return 1 if the record is to be written to magtape file
   -- else 0
   IS
        CURSOR get_assignment_action_id
        IS
        SELECT /*+ ordered  */
               paa.assignment_action_id,
               paf.ASSIGNMENT_TYPE
               --  Added paf.ASSIGNMENT_TYPE as we need to write primary assign number in
               --  magtape if the primary and sec both have the p11d benefits
               -- In case if only secondary have benefits then we may write
               -- any  secondary assignment number in the magtape
        FROM   per_assignments_f paf,
               pay_assignment_actions paa,
               pay_action_information pai_comp
        WHERE  paf.person_id = p_person_id
        AND    paa.assignment_id = paf.assignment_id
        AND    paa.payroll_action_id = p_arch_payroll_action_id
        AND    pai_comp.action_context_id = paa.assignment_action_id
        AND    pai_comp.action_information_category = 'EMEA PAYROLL INFO'
        AND    pai_comp.action_information6 = p_emp_ref_no
        order by paf.ASSIGNMENT_TYPE, paa.assignment_action_id;


        CURSOR sum_marors_values
        IS
        SELECT /*+ ordered  */
              SUM (TO_NUMBER (NVL (pai.action_information7, '0')))
        FROM  per_assignments_f paf,
              pay_assignment_actions paa,
              pay_action_information pai_comp,
              pay_action_information pai
        WHERE paf.person_id = p_person_id
        AND   paa.payroll_action_id = p_arch_payroll_action_id
        AND   paa.assignment_id = paf.assignment_id
        AND   pai_comp.action_context_id = paa.assignment_action_id
        AND   pai_comp.action_information_category = 'EMEA PAYROLL INFO'
        AND   pai_comp.action_information6 = p_emp_ref_no
        AND   pai.action_context_id = paa.assignment_action_id
        AND   pai.action_information_category = 'MARORS'
        AND   pai.action_context_id = pai_comp.action_context_id;

        CURSOR fetch_ben_values (p_assignment_action_id   NUMBER,
                                 p_action_info_catg       VARCHAR2)
        IS
        SELECT *
        FROM   pay_action_information pai
        WHERE  pai.action_context_id = p_assignment_action_id
        AND    pai.action_information_category = p_action_info_catg;

        l_ce_values_a            fetch_ben_values%ROWTYPE;
        l_ce_values_b            fetch_ben_values%ROWTYPE;
        l_ce_values_c            fetch_ben_values%ROWTYPE;
        l_emp_details            fetch_ben_values%ROWTYPE;
        l_assignment_action_id   NUMBER (15);
        l_write_to_magtape       NUMBER  := 0;
        l_marors_ce              NUMBER;
        l_assignment_number      varchar2(30) ;
        l_dummy                  varchar2(30);
        l_rep_run                varchar2(10);

   BEGIN

        PAY_GB_P11D_ARCHIVE_SS.get_parameters(p_payroll_action_id => p_arch_payroll_action_id,
                                              p_token_name        => 'Rep_Run',
                                              p_token_value       => l_rep_run);

        OPEN get_assignment_action_id;
        FETCH get_assignment_action_id INTO l_assignment_action_id,l_dummy ;
        CLOSE get_assignment_action_id;

        OPEN fetch_ben_values (l_assignment_action_id,
                               'GB P11D ASSIGNMENT RESULTA');
        FETCH fetch_ben_values INTO l_ce_values_a;
        CLOSE fetch_ben_values;

        OPEN fetch_ben_values (l_assignment_action_id,
                               'GB P11D ASSIGNMENT RESULTB');
        FETCH fetch_ben_values INTO l_ce_values_b;
        CLOSE fetch_ben_values;

        OPEN fetch_ben_values (l_assignment_action_id,
                               'GB P11D ASSIGNMENT RESULTC');
        FETCH fetch_ben_values INTO l_ce_values_c;
        CLOSE fetch_ben_values;

        OPEN fetch_ben_values (l_assignment_action_id,
                               'EMPLOYEE DETAILS');
        FETCH fetch_ben_values INTO l_emp_details;
        CLOSE fetch_ben_values;

        p_assignment_number :=NVL(UPPER(l_emp_details.action_information14), ' ');

        IF to_number(l_rep_run) < 2005
        THEN
            IF    TO_NUMBER (l_ce_values_a.action_information4) > 0
               OR TO_NUMBER (l_ce_values_a.action_information6) > 0
               OR TO_NUMBER (l_ce_values_a.action_information7) > 0
               OR TO_NUMBER (l_ce_values_a.action_information10) > 0
               OR TO_NUMBER (l_ce_values_a.action_information11) > 0
               OR TO_NUMBER (l_ce_values_a.action_information12) > 0
               OR TO_NUMBER (l_ce_values_a.action_information13) > 0
               OR TO_NUMBER (l_ce_values_a.action_information14) > 0
               OR TO_NUMBER (l_ce_values_a.action_information15) > 0
               OR TO_NUMBER (l_ce_values_a.action_information18) > 0
               OR TO_NUMBER (l_ce_values_a.action_information19) > 0
               OR TO_NUMBER (l_ce_values_a.action_information22) > 0
               OR TO_NUMBER (l_ce_values_a.action_information26) > 0
               OR l_ce_values_a.action_information27 = 'Y'
               -- moving the check for free loans below as it is base don combinaiton
               -- of values
               /* OR TO_NUMBER (l_ce_values_a.action_information28) >= 0 -- this is int
                   -- free loan awaiting direction from IR */
               OR TO_NUMBER (l_ce_values_b.action_information4) > 0
               OR TO_NUMBER (l_ce_values_b.action_information8) > 0
               OR TO_NUMBER (l_ce_values_b.action_information9) > 0
               OR TO_NUMBER (l_ce_values_b.action_information12) > 0
               OR TO_NUMBER (l_ce_values_b.action_information15) > 0
               OR TO_NUMBER (l_ce_values_b.action_information19) > 0
               OR TO_NUMBER (l_ce_values_b.action_information22) > 0
               OR TO_NUMBER (l_ce_values_b.action_information25) > 0
               OR TO_NUMBER (l_ce_values_b.action_information29) > 0
            THEN
                l_write_to_magtape := 1;
            END IF;
            -- chk for marors
            IF TO_NUMBER (nvl(l_ce_values_c.action_information15,'0')) >= 1 and
               TO_NUMBER (nvl(l_ce_values_c.action_information22,'0')) <> 0
            THEN
                l_write_to_magtape := 1;
            END IF;

            if TO_NUMBER (l_ce_values_a.action_information28) > 0 and
               TO_NUMBER (l_ce_values_c.action_information23) > 5000
            then
                l_write_to_magtape := 1;
            end if;
            p_INT_MAX_AMT_OUTSTANDING := nvl(l_ce_values_c.action_information23,'0');
        ELSE
            IF    TO_NUMBER (l_ce_values_a.action_information4) > 0
               OR TO_NUMBER (l_ce_values_a.action_information6) > 0
               OR TO_NUMBER (l_ce_values_a.action_information7) > 0
               OR TO_NUMBER (l_ce_values_a.action_information10) > 0
               OR TO_NUMBER (l_ce_values_a.action_information11) > 0
               OR TO_NUMBER (l_ce_values_a.action_information12) > 0
               OR TO_NUMBER (l_ce_values_a.action_information13) > 0
               OR TO_NUMBER (l_ce_values_a.action_information14) > 0
               OR TO_NUMBER (l_ce_values_a.action_information15) > 0
               OR TO_NUMBER (l_ce_values_a.action_information18) > 0
               OR TO_NUMBER (l_ce_values_a.action_information19) > 0
               OR TO_NUMBER (l_ce_values_a.action_information22) > 0
               OR TO_NUMBER (l_ce_values_a.action_information26) > 0
               -- moving the check for free loans below as it is base don combinaiton
               -- of values
               /* OR TO_NUMBER (l_ce_values_a.action_information28) >= 0 -- this is int
               -- free loan awaiting direction from IR */
               OR TO_NUMBER (l_ce_values_b.action_information4) > 0
               OR TO_NUMBER (l_ce_values_b.action_information8) > 0
               OR TO_NUMBER (l_ce_values_b.action_information9) > 0
               OR TO_NUMBER (l_ce_values_b.action_information12) > 0
               OR TO_NUMBER (l_ce_values_b.action_information15) > 0
               OR TO_NUMBER (l_ce_values_b.action_information19) > 0
               OR TO_NUMBER (l_ce_values_b.action_information22) > 0
               OR TO_NUMBER (l_ce_values_b.action_information25) > 0
               OR TO_NUMBER (l_ce_values_b.action_information29) > 0
            THEN
                l_write_to_magtape := 1;
            END IF;
            -- chk for marors
            IF TO_NUMBER (nvl(l_ce_values_c.action_information13,'0')) >= 1 and
               TO_NUMBER (nvl(l_ce_values_c.action_information20,'0')) <> 0
            THEN
                l_write_to_magtape := 1;
            END IF;

            if TO_NUMBER (l_ce_values_a.action_information27) > 0 and
               TO_NUMBER (l_ce_values_c.action_information21) > 5000
            then
                l_write_to_magtape := 1;
            end if;
            p_INT_MAX_AMT_OUTSTANDING := nvl(l_ce_values_c.action_information21,'0');
        END IF;
        RETURN l_write_to_magtape;
   END;
end hr_gb_process_p11d_entries_pkg;

/
