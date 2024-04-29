--------------------------------------------------------
--  DDL for Package Body PER_FR_D2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_D2_PKG" AS
/* $Header: pefrd2rp.pkb 120.1 2005/12/20 13:34:05 aparkes noship $ */

cursor csr_get_extra_units(p_effective_date date) is
   select
     max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'BASE_UNIT',CINST.value))) base_unit
    ,max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'X_COT_A',CINST.value))) x_cot_a
    ,max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'X_COT_B',CINST.value))) x_cot_b
    ,max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'X_COT_C',CINST.value))) x_cot_c
    ,max(fnd_number.canonical_to_number(decode(R.row_low_range_or_name,
                               'X_COT_YOUNG_AGE',CINST.value))) x_cot_young_age
    ,max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'X_COT_OLD_AGE',CINST.value))) x_cot_old_age
    ,max(fnd_number.canonical_to_number(decode(R.row_low_range_or_name,
                               'X_COT_AGE_UNITS',CINST.value))) x_cot_age_units
    ,max(fnd_number.canonical_to_number(decode(R.row_low_range_or_name,
                     'X_COT_TRAINING_HOURS',CINST.value))) x_cot_training_hours
    ,max(fnd_number.canonical_to_number(decode(R.row_low_range_or_name,
                     'X_COT_TRAINING_UNITS',CINST.value))) x_cot_training_units
    ,max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'X_COT_AP',CINST.value))) x_cot_ap
    ,max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'X_COT_IMPRO',CINST.value))) x_cot_impro
    ,max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'X_COT_CAT',CINST.value))) x_cot_cat
    ,max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'X_COT_CDTD',CINST.value))) x_cot_cdtd
    ,max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'X_COT_CFP',CINST.value))) x_cot_cfp
    ,max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'X_IPP_LOW_RATE',CINST.value))) x_ipp_low_rate
    ,max(fnd_number.canonical_to_number(decode(R.row_low_range_or_name,
                           'X_IPP_MEDIUM_RATE',CINST.value))) x_ipp_medium_rate
    ,max(fnd_number.canonical_to_number(decode(R.row_low_range_or_name,
                               'X_IPP_HIGH_RATE',CINST.value))) x_ipp_high_rate
    ,max(fnd_number.canonical_to_number(decode(R.row_low_range_or_name,
                               'X_IPP_LOW_UNITS',CINST.value))) x_ipp_low_units
    ,max(fnd_number.canonical_to_number(decode(R.row_low_range_or_name,
                         'X_IPP_MEDIUM_UNITS',CINST.value))) x_ipp_medium_units
    ,max(fnd_number.canonical_to_number(decode(R.row_low_range_or_name,
                             'X_IPP_HIGH_UNITS',CINST.value))) x_ipp_high_units
    ,max(fnd_number.canonical_to_number(decode(
         R.row_low_range_or_name,'X_HIRE_UNITS',CINST.value))) x_hire_units
   from    pay_user_tables                    TAB
   ,       pay_user_rows_f                    R
   ,       pay_user_columns                   C
   ,       pay_user_column_instances_f        CINST
   where   TAB.user_table_name              = 'FR_D2_RATES'
   and     TAB.legislation_code             = 'FR'
   and     TAB.business_group_id           is null
   and     C.user_table_id                  = TAB.user_table_id
   and     C.legislation_code               = 'FR'
   and     C.business_group_id             is null
   and     C.user_column_name               = 'VALUE'
   and     CINST.user_column_id             = C.user_column_id
   and     R.user_table_id                  = TAB.user_table_id
   and     p_effective_date           between R.effective_start_date
                                          and R.effective_end_date
   and     R.business_group_id             is null
   and     R.legislation_code               = 'FR'
   and     CINST.user_row_id                = R.user_row_id
   and     p_effective_date           between CINST.effective_start_date
                                          and CINST.effective_end_date
   and     CINST.business_group_id         is null
   and     CINST.legislation_code           = 'FR';

type t_extra_units is record (
  effective_date  date,
  rec             csr_get_extra_units%ROWTYPE);
g_extra_units     t_extra_units;

function set_headcounts (p_establishment_id in number,
                         p_1jan in date,
                         p_31dec in date,
                         p_headcount_obligation out nocopy number,
                         p_headcount_particular out nocopy number,
                         p_basis_obligation out nocopy number,
                         p_obligation out nocopy number,
                         p_breakdown_particular out nocopy varchar2,
                         p_count_disabled out nocopy varchar2,
                         p_disabled_where_clause out nocopy varchar2)
                         return integer
IS
   pcs_count            table_of_number;
   -- #4068197 new pl/sql table to accomodate pcs codes
   pcs_codes            table_of_varchar;
   -- #4068197
   l_proc               varchar2(50);
   l_return             integer;
   l_employee_count     number;
   l_estab_hours        number;
   l_business_group_id  number;
   l_continue_flag      integer;
   l_formula_id         number;
   l_formula_start_date date;
   previous_block       block_record;
   first_block          boolean;
   block_fired          integer;
   pending_block        integer;
   l_list_disabled      varchar2(32000);
   percent_disabled_obligation number;
   l_blocks             table_of_block;
   i                    binary_integer;
begin
   --Initialising Local Variables
   l_proc       :='set_headcounts';
   hr_utility.set_location('entering '||l_proc,0);
   --
   -- initialize OUT parameters
   l_return := 0;
   p_headcount_obligation := 0;
   p_headcount_particular := 0;
   p_basis_obligation := 0;
   p_obligation := 0;
   p_breakdown_particular := '';
   p_count_disabled := '';
   p_disabled_where_clause := '';
   --
   l_estab_hours := get_estab_hours (p_establishment_id);
   --
   select business_group_id
     into l_business_group_id
     from hr_all_organization_units
     where organization_id = p_establishment_id;
   --
   percent_disabled_obligation :=
     fnd_number.canonical_to_number(hruserdt.get_table_value
        (l_business_group_id,
        'FR_D2_RATES',
        'VALUE',
        'PERCENT_OBLIGATION'
	,p_1jan));
   --
   get_formula_ref (p_31dec, l_business_group_id, l_formula_id, l_formula_start_date);
   --
   hr_utility.set_location(l_proc,5);
   --
   -- work out list of disabled employees (regardless of headcounts)
   --
   l_list_disabled := list_disabled (p_establishment_id, p_1jan, p_31dec);
   --
   -- loop on all employees to work out individual headcounts
   --
   if csr_get_emp_year%isopen then
      close csr_get_emp_year;
   end if;
   --
   for rec_emp_year in csr_get_emp_year (p_establishment_id, p_1jan, p_31dec) loop
      --
      l_employee_count := 0;
      first_block := true;
      --
      -- first populate the PL/SQL table with all the blocks for this employee
      --
      populate_blocks_table (p_establishment_id, p_1jan, p_31dec, rec_emp_year.person_id, l_blocks);
      --
      -- now loop on all blocks for this employee
      --
      i := l_blocks.first;
      block_fired := 0;
      --
      while i is not null loop
         --
         pending_block := i;
         --
         if first_block then
              previous_block := l_blocks(i);
              l_continue_flag := 1;
              first_block := false;
         else
              if relevant_change(previous_block,l_blocks(i)) then
               --
               -- fire formula for the big block
                 --
                 l_continue_flag := contract_prorated (previous_block,
                                                       l_business_group_id,
                                                       l_estab_hours,
                                                       p_31dec,
                                                       l_employee_count,
                                                       l_formula_id,
                                                       l_formula_start_date);
               --
                 previous_block := l_blocks(i);
                 block_fired := i-1;
               --
              else -- enlarge current block
                 previous_block.block_start_date := least(previous_block.block_start_date,
                   l_blocks(i).block_start_date);
                 previous_block.block_end_date := greatest(previous_block.block_end_date,
                   l_blocks(i).block_end_date);
              end if;
         end if;
         --
         exit when l_continue_flag = 0;
         --
         i := l_blocks.next(i);
      end loop;
      --
      if (pending_block<>block_fired) then
         l_continue_flag := contract_prorated (previous_block,
                                               l_business_group_id,
                                               l_estab_hours,
                                               p_31dec,
                                               l_employee_count,
                                               l_formula_id,
                                               l_formula_start_date);
      end if;
      --
      hr_utility.set_location('headcount for '||to_char(rec_emp_year.person_id)||' is '||to_char(l_employee_count),50);
      --
      if l_employee_count > 0 then -- update headcounts
         --
         p_headcount_obligation := p_headcount_obligation + l_employee_count;
         --
         update_particular (p_establishment_id,
                             rec_emp_year.person_id,
                             p_1jan,
                             p_31dec,
                             l_business_group_id,
                             l_employee_count,
                             p_headcount_particular,
                             pcs_count,
                             pcs_codes);
         --
         update_count_disabled (rec_emp_year.person_id, l_list_disabled,
                          l_employee_count, p_count_disabled);
         --
      else -- remove employee from list of disabled (when relevant)
         trunc_list_disabled (rec_emp_year.person_id,l_list_disabled);
      end if;
      --
   end loop;
   --
   if length(l_list_disabled) > 0 then
      p_disabled_where_clause :=
         'and per.person_id in (' || l_list_disabled || ') ';
      -- bug 4219037 b; non-changable parts of this lexical parameter
      -- moved into Q_DISABLED_EMP itself.
   else
      p_disabled_where_clause := 'and 0=1 ';
   end if;
   --
   p_headcount_obligation := floor(p_headcount_obligation);
   p_headcount_particular := floor(p_headcount_particular);
   p_basis_obligation := p_headcount_obligation - p_headcount_particular;
   p_obligation := floor(percent_disabled_obligation * p_basis_obligation /100);
   -- #4068197
   p_breakdown_particular := string_of_particular(pcs_count, pcs_codes);
   -- #4068197
   --
   hr_utility.set_location('leaving '||l_proc,80);
   return l_return;
   --
exception
   when others then
     hr_utility.set_location('SetHeaERR:'||substr(sqlerrm,1,80),90);
     return 1;
end set_headcounts;
--
--
function contract_prorated (p_block in block_record,
                            p_business_group_id in number,
                            p_estab_hours in number,
                            p_31dec in date,
                            p_tmp_total in out nocopy number,
                            p_formula_id in number,
                            p_formula_start_date in date) return integer
is
   l_proc            varchar2(50);
   l_flag            integer:=1;
   l_debug_text      varchar2(50);
   l_emp_cat         varchar2(30);
   l_daily_hours     varchar2(30);
   l_weekly_hours    varchar2(30);
   l_monthly_hours   varchar2(30);
   l_inputs          ff_exec.inputs_t;
   l_outputs         ff_exec.outputs_t;
begin
   -- Initialising Local Variables
   l_proc            :='contract_prorated';
   --
   if include_this_person_type (p_block.person_type_usages,
                                p_business_group_id,
                                p_block.block_start_date)
   then
      if p_block.asg_employment_category is null then
         l_emp_cat := 'U';
      else
         begin -- first get employment category for this assignment
            --Bug #4183533
            if p_block.asg_type = 'C' then
               l_emp_cat := hruserdt.get_table_value (p_business_group_id,
                 'CWK_ASG_CATEGORY', 'FR_D2_CATEGORY',
                 p_block.asg_employment_category, p_block.block_start_date);
            else
               l_emp_cat := hruserdt.get_table_value (p_business_group_id,
                 'EMP_CAT', 'FR_D2_CATEGORY',
                 p_block.asg_employment_category, p_block.block_start_date);
            end if;
            -- Bug #4183533
         exception
            when others then
               l_emp_cat := 'U';
         end;
      end if;
      --
      begin -- now get legal values
         l_daily_hours := hruserdt.get_table_value(p_business_group_id,
                    'FR_LEGISLATIVE_RATES','VALUE','DAILY_HOURS',
                    p_block.block_start_date);
         l_weekly_hours := hruserdt.get_table_value(p_business_group_id,
                   'FR_LEGISLATIVE_RATES','VALUE','WEEKLY_HOURS',
                    p_block.block_start_date);
         l_monthly_hours := hruserdt.get_table_value(p_business_group_id,
                  'FR_LEGISLATIVE_RATES','VALUE','MONTHLY_HOURS',
                  p_block.block_start_date);
      exception
         when others then
            l_daily_hours := '1';
            l_weekly_hours := '1';
            l_monthly_hours := '1';
      end;
      --
      -- Initialize formula
      --
      ff_exec.init_formula (p_formula_id,
                            p_formula_start_date,
                            l_inputs,
                            l_outputs
                           );
      --
      if (l_inputs.first is not null) and (l_inputs.last is not null)
      then
         -- Set up context values for the formula
         for l_in_cnt in
         l_inputs.first..l_inputs.last
         loop
            if l_inputs(l_in_cnt).name='ASSIGNMENT_ID' then
               l_inputs(l_in_cnt).value := p_block.asg_id;
            end if;
            if l_inputs(l_in_cnt).name='DATE_EARNED' then
               l_inputs(l_in_cnt).value :=
                  fnd_date.date_to_canonical(p_block.block_start_date);
            end if;
            if l_inputs(l_in_cnt).name='BLOCK_START_DATE' then
               l_inputs(l_in_cnt).value :=
                  fnd_date.date_to_canonical(p_block.block_start_date);
            end if;
            if l_inputs(l_in_cnt).name='BLOCK_END_DATE' then
               l_inputs(l_in_cnt).value :=
                            fnd_date.date_to_canonical(p_block.block_end_date);
            end if;
            if l_inputs(l_in_cnt).name='ESTABLISHMENT_MONTHLY_HOURS' then
               l_inputs(l_in_cnt).value :=
                                 fnd_number.number_to_canonical(p_estab_hours);
            end if;
            if l_inputs(l_in_cnt).name='RUNNING_TOTAL' then
               l_inputs(l_in_cnt).value :=
                  fnd_number.number_to_canonical(p_tmp_total);
            end if;
            if l_inputs(l_in_cnt).name='END_OF_YEAR' then
               l_inputs(l_in_cnt).value := fnd_date.date_to_canonical(p_31dec);
            end if;
            if l_inputs(l_in_cnt).name='EMPLOYMENT_CATEGORY' then
               l_inputs(l_in_cnt).value := l_emp_cat;
            end if;
            if l_inputs(l_in_cnt).name='LEGAL_DAILY_HOURS' then
               l_inputs(l_in_cnt).value := l_daily_hours;
            end if;
            if l_inputs(l_in_cnt).name='LEGAL_MONTHLY_HOURS' then
               l_inputs(l_in_cnt).value := l_monthly_hours;
            end if;
            if l_inputs(l_in_cnt).name='LEGAL_WEEKLY_HOURS' then
               l_inputs(l_in_cnt).value := l_weekly_hours;
            end if;
         end loop;
      end if;
      --
      -- Run the formula
      --
      ff_exec.run_formula (l_inputs ,
                           l_outputs
                          );
      --
      for l_out_cnt in
      l_outputs.first..l_outputs.last
      loop
         if l_outputs(l_out_cnt).name = 'NEW_TOTAL' then
            p_tmp_total :=
               fnd_number.canonical_to_number(l_outputs(l_out_cnt).value);
         end if;
         if l_outputs(l_out_cnt).name = 'CONTINUE_FLAG' then
            l_flag := l_outputs(l_out_cnt).value;
         end if;
         if l_outputs(l_out_cnt).name = 'DEBUG_TEXT' then
            l_debug_text := l_outputs(l_out_cnt).value;
         end if;
      end loop;
      --
      hr_utility.set_location('leaving ff with debug_text='||l_debug_text,70);
      --
   end if;
   --
   return l_flag;
   --
exception
   when others then
     hr_utility.set_location('ConProERR:'||substr(sqlerrm,1,80),90);
     return 0;
end contract_prorated;
--
--
function get_estab_hours (p_establishment_id in number)
                          return number
is
  l_hours_text hr_organization_information.org_information4%type;
  l_hours      number;
begin
--#3464382 Changed the query to fetch the data from the table and not from the view
select  org_information4
  into  l_hours_text
  from  hr_organization_information
 where  organization_id = p_establishment_id
   and  org_information_context = 'FR_ESTAB_INFO';
     --
     l_hours := fnd_number.canonical_to_number(l_hours_text);
     --
   return l_hours;
exception
   when others then
     return 0;
end get_estab_hours;
--
--
procedure get_pcs_code (p_report_qualifier    in         varchar2
                       ,p_job_id              in         per_jobs.job_id%type default null
		       ,p_job_name            in         per_jobs.name%type   default null
                       ,p_pcs_code            in out nocopy varchar2
                       ,p_effective_date      in         date) is
   l_unused_char    varchar2(240);
   l_unused_date    date;
   l_job_name       per_jobs.name%type;
   l_unused_number  number;

   --To get the message
   l_value          varchar2(240);
   l_proc           varchar2(200);
begin
   --Initialising Local Variables
   l_proc           := 'Update_pcs_code';

   hr_utility.set_location('enter '||l_proc,5);
   --
   --Get the Effective Date
   IF p_report_qualifier = 'DADS' THEN
      l_unused_date := to_date('31-12-2002', 'DD-MM-YYYY');
   ELSE
      l_unused_date := to_date('31-12-2003', 'DD-MM-YYYY');
   END IF;
   hr_utility.set_location('The last date of the old period date is '||l_unused_date,10);
   --
   -- Check for the date
   IF p_effective_date <= l_unused_date THEN
   hr_utility.set_location('In old period '||l_proc,20);
      --The Code should be an old code
      --Check whether the obtained code is new code or not
      IF ascii(substr(p_pcs_code, -1 )) < ascii(0) OR ascii(substr(p_pcs_code, -1)) > ascii(9) THEN
         l_unused_number := 0;
         --Then check whether there is mapping or not
         select count(lookup_code)
	 into   l_unused_number
	 from   fnd_common_lookups
	 where  lookup_type = 'FR_PCS_CODE'
	 and    description = p_pcs_code;
	 IF l_unused_number = 1 THEN
         -- If there is more than one or zero old pcs code for the given new code, then the new code is printed
	 -- No error message is given for this
	    select lookup_code
	    into   p_pcs_code
	    from   fnd_common_lookups
	    where  lookup_type = 'FR_PCS_CODE'
	    and    description = p_pcs_code;
	 END IF;
      END IF; --Ignore when it is a old code
   ELSE
      hr_utility.set_location('In new period '||l_proc,30);
      --The code should be a new code
      --Check whether the obtained code is old code or not
      IF ascii(substr(p_pcs_code, -1 )) >= ascii(0) AND ascii(substr(p_pcs_code, -1)) <= ascii(9) THEN
          --Then check whether there is mapping or not
         select description
	 into   l_unused_char
	 from   fnd_common_lookups
	 where  lookup_type = 'FR_PCS_CODE'
	 and    lookup_code = p_pcs_code;
	 IF l_unused_char IS NULL THEN
	    --Get the job name
	    IF p_job_name is null THEN
   	       select   name
               into     l_job_name
	       from     per_jobs
	       where    job_id = p_job_id;
	    ELSE
	       l_job_name := p_job_name;
	    END IF;
	    --More than one mew code exists for the given new code
            l_value := pay_fr_general.get_payroll_message('PAY_75193_OLD_CODE', null, null, null);
	    fnd_file.put_line(fnd_file.log, l_job_name||l_value);
	    p_pcs_code := NULL;
	 ELSE
            p_pcs_code := l_unused_char;
	 END IF;
      END IF; --Ignore when it is a new code
   END IF;
   hr_utility.set_location('leaving '||l_proc,50);
   --
Exception
when others then
hr_utility.set_location('Error has been created in the package'||l_proc, 60);
hr_utility.set_location('Error is '||sqlerrm, 70);
end get_pcs_code;
--
--
-- overloaded procedure get_job_info 115.15
procedure get_job_info (p_establishment_id in number,
                        p_person_id in number,
                        p_1jan in date,
                        p_31dec in date,
                        p_pcs_code out nocopy varchar2,
                        p_job_title out nocopy varchar2)
is
    cursor csr_last_job
    is
      -- select last job in the year for an employee
     select job_id
     from per_all_assignments_f
     where person_id = p_person_id
     and nvl(establishment_id,-1) = p_establishment_id
     and effective_start_date <= p_31dec
     and effective_end_date >= p_1jan
       order by primary_flag desc, effective_start_date desc;
   --
   lid    per_jobs.job_id%type;
begin
   --
   for rec_job in csr_last_job loop
      lid := rec_job.job_id;
      exit;
   end loop;
   --
   select job_information1, name
     into p_pcs_code, p_job_title
     from per_jobs_v
    where job_id = lid
      and nvl(job_information_category,' ') = 'FR';
   --
   begin -- get pcs-code
      --
      -- Bug No: 3311942
      --get the valid pcs code
      per_fr_d2_pkg. get_pcs_code (p_report_qualifier  => 'D2'
                                  ,p_job_id            => lid
                                  ,p_pcs_code          => p_pcs_code
                                  ,p_effective_date    => p_31dec);
      --
   exception
      when others then
         p_pcs_code := '0';
   end;
   --
exception
   when others then
     p_pcs_code := '0';
     p_job_title := '?';
end get_job_info;
--
procedure get_job_info (p_establishment_id in number,
                        p_person_id in number,
                        p_1jan in date,
                        p_31dec in date,
                        p_year in number,
                        p_pcs_code out nocopy varchar2,
                        p_job_title out nocopy varchar2,
                        p_hours_training out nocopy number,
                        p_hire_year out nocopy number,
                        p_year_became_permanent out nocopy number)
is
  l_date_start date;
begin
   -- call overloaded private proc
   get_job_info (p_establishment_id,
                 p_person_id,
                 p_1jan,
                 p_31dec,
                 p_pcs_code,
                 p_job_title);
   -- get hours training
   --
   select nvl(max(fnd_number.canonical_to_number(pei_information2)),0)
     into p_hours_training
     from per_people_extra_info
     where person_id = p_person_id
     and nvl(pei_information_category,' ') = 'FR_PROF_TRAIN'
     and nvl(pei_information1,' ') = to_char(p_year);
   --
   -- get year of hire / placement (bug 4219037 d)
   --
   select max(date_start)
     into l_date_start
     from (select date_start
           from   per_periods_of_service
           where person_id = p_person_id
           and date_start <= p_31dec
           union all
           select date_start
           from   per_periods_of_placement
           where person_id = p_person_id
           and date_start <= p_31dec);
   p_hire_year := to_number(to_char(l_date_start,'YYYY'));
   --
   -- get p_year_became_permanent for bug 4237723
   -- Will be null where there is no contract e.g. Contingent workers
   --
   select to_number(to_char(min(effective_start_date),'YYYY'))
     into p_year_became_permanent
     from per_contracts_f pcf
    where pcf.effective_start_date    >= l_date_start
      and pcf.person_id                = p_person_id
      and pcf.CTR_INFORMATION_CATEGORY = 'FR'
      and pcf.CTR_INFORMATION2         = 'PERMANENT'
      and pcf.STATUS                like 'A-%';
   --
end get_job_info;
--
--
function list_disabled (p_establishment_id in number,
                        p_1jan in date,
                        p_31dec in date)
                        return varchar2
is
   l_list varchar2(32000);
   first boolean:=true;
begin
   hr_utility.set_location('entering list_disabled',5);
   --
   for rec_disabled in csr_get_disabled (p_establishment_id,p_1jan,p_31dec) loop
      --
      if not first then
         l_list := l_list || ',';
      end if;
      l_list := l_list || to_char(rec_disabled.id);
      first := false;
   end loop;
   --
   hr_utility.set_location('list of disabled ='||l_list,15);
   --
   return l_list;
   --
exception
   when others then
     hr_utility.set_location('LisDisERR:'||substr(sqlerrm,1,80),90);
     return '-1';
end list_disabled;
--
--
procedure trunc_list_disabled (p_person_id in number,
                               p_list in out nocopy varchar2)
is
   l_pos integer;
   l_id_text varchar2(15);
   l_length integer;
begin
   -- p_list is assumed to be like eg. '897,6734,9912'
   if length(p_list) > 0 then
      l_pos := posid_in_list(p_person_id,p_list);
      if l_pos > 0 then
         l_id_text := to_char(p_person_id);
         l_length := length(l_id_text);
         if substr(p_list,l_pos+l_length,1) = ',' then
            l_length := l_length + 1;
         else
            if substr(p_list,l_pos-1,1) = ',' then
               l_pos := l_pos - 1;
               l_length := l_length + 1;
            end if;
         end if;
         p_list := substr(p_list,1,l_pos-1) || substr(p_list,l_pos+l_length);
         hr_utility.set_location('removed '||l_id_text||' from list of disabled',50);
         hr_utility.set_location('new list is '||substr(p_list,1,80),70);
      end if;
   end if;
end trunc_list_disabled;
--
--
procedure update_particular (p_establishment_id in number,
                             p_person_id in number,
                             p_1jan in date,
                             p_31dec in date,
                             p_business_group_id in number,
                             p_employee_count in number,
                             p_headcount_particular in out nocopy number,
                             p_pcs_count in out nocopy table_of_number,
                             p_pcs_codes in out nocopy table_of_Varchar)
is
   l_pcs_code_text   varchar2(30);
   l_pcs_code        number(30):=0;
   l_pcs_particular  varchar2(1);
   l_job_title       per_jobs_v.name%TYPE;
   -- #4068197
   l_exists          varchar2(1);
   l_pcs_code_count  number;
   -- #4068197
begin
      --
      get_job_info (p_establishment_id,
                    p_person_id,
                    p_1jan,
                    p_31dec,
                    l_pcs_code_text,
                    l_job_title);
   --
      hr_utility.set_location('update_particular pcs_code='||l_pcs_code_text,10);
   --
   --
      Begin
         l_pcs_particular := hruserdt.get_table_value (p_business_group_id,
                             'FR_PCS_CODE', 'FR_D2_PARTICULAR', l_pcs_code_text, p_31dec);
      exception
      when no_data_found then
         l_pcs_particular := 'N';
      end;

      Begin
         IF l_pcs_particular = 'N' THEN
            l_pcs_particular := hruserdt.get_table_value (p_business_group_id,
                             'FR_NEW_PCS_CODE', 'FR_D2_PARTICULAR', l_pcs_code_text, p_31dec);
         END IF;
      Exception
      When no_data_found then
         l_pcs_particular := 'N';
      end;
      hr_utility.set_location('update_particular l_pcs_particular = '||l_pcs_particular, 11);
  --
      if l_pcs_particular = 'Y' then
         p_headcount_particular := p_headcount_particular + p_employee_count;
         l_pcs_code_count := p_pcs_count.first;
         if l_pcs_code_count is not null then
            l_exists := 'Y';
         else
            l_exists := 'N';
         end if;
         while l_exists = 'Y'
         loop
            if p_pcs_codes(l_pcs_code_count) = l_pcs_code_text then
               l_exists := 'N';
            else
               l_pcs_code_count := p_pcs_count.next(l_pcs_code_count);
               if l_pcs_code_count is not null then
                  l_exists := 'Y';
               else
                  l_exists := 'N';
               end if;
            end if;
         end loop;
         if l_pcs_code_count is not null then
            p_pcs_count(l_pcs_code_count) := p_pcs_count(l_pcs_code_count) + p_employee_count;
            p_pcs_codes(l_pcs_code_count) := l_pcs_code_text;
         else
            l_pcs_code_count := p_pcs_count.last;
            if l_pcs_code_count is null then
               l_pcs_code_count := 0;
            end if;
            p_pcs_count(l_pcs_code_count+1) := p_employee_count;
            p_pcs_codes(l_pcs_code_count + 1) := l_pcs_code_text;
         end if;
      end if;
   --
exception
   when no_data_found then
     null;
   when others then
     hr_utility.set_location('UpdParERR:'||substr(sqlerrm,1,80),90);
end update_particular;
--
--
function string_of_particular (p_pcs_count in table_of_number,
                               p_pcs_codes in table_of_varchar)
  return varchar2
is
   l_string varchar2(32000);
   i binary_integer;
   first boolean:= true;
begin
   l_string := '';
   --
   hr_utility.set_location('enter string_of_particular',5);
   --
   i := p_pcs_count.first;
   while i is not null loop
      --
      hr_utility.set_location('table of particular not empty',10);
      --
      if not first then
         l_string := l_string || ' union ';
      end if;
      l_string := l_string || 'select ''' || p_pcs_codes(i) || ''' pc, ';
      l_string := l_string || to_char(round(p_pcs_count(i),1)) || ' ph from dual';
      i := p_pcs_count.next(i);
      first := false;
   end loop;
   --
   hr_utility.set_location('string_of_particular is '||l_string,50);
   --
   if l_string is null then
      l_string := 'select 0 pc, 0 ph from dual';
   end if;
   --
   hr_utility.set_location('string_of_particular is '||l_string,55);
   --
   return l_string;
   --
exception
   when others then
     hr_utility.set_location('StrOfParERR:'||substr(sqlerrm,1,80),90);
     return 'select 0 pc, 0 ph from dual';
end string_of_particular;
--
--
procedure update_count_disabled (p_person_id in number,
                           p_list in varchar2,
                           p_employee_count in number,
                           p_count_disabled in out nocopy varchar2)
is
   l_pos integer;
   l_proc varchar2(50);
begin
   -- Initialising Local Variables
   l_proc :='update_count_disabled';
   hr_utility.set_location('enter '||l_proc,5);
   --
   l_pos := posid_in_list(p_person_id,p_list);
   --
   if l_pos > 0 then
      --
      hr_utility.set_location(to_char(p_person_id)||' is disabled',10);
      --
      p_count_disabled := p_count_disabled || to_char(p_person_id) || '=';
      p_count_disabled := p_count_disabled || to_char(round(p_employee_count,2)) || ';';
      --
   end if;
   --
exception
   when others then
     hr_utility.set_location('UpdCouDisERR:'||substr(sqlerrm,1,80),90);
end update_count_disabled;
--
--
procedure get_formula_ref (p_effective_date in date,
                           p_business_group_id in number,
                           p_formula_id out nocopy number,
                           p_formula_start_date out nocopy date)
is
begin
   select formula_id, effective_start_date
     into p_formula_id, p_formula_start_date
     from ff_formulas_f
     where formula_name = 'USER_CONTRACT_PRORATED'
     and business_group_id = nvl(p_business_group_id,-1)
     and p_effective_date between effective_start_date and effective_end_date;
exception
   when no_data_found then
     select formula_id, effective_start_date
     into p_formula_id, p_formula_start_date
     from ff_formulas_f
     where formula_name = 'TEMPLATE_CONTRACT_PRORATED'
     and legislation_code = 'FR'
     and p_effective_date between effective_start_date and effective_end_date;
end get_formula_ref;
--
--
function relevant_change (block1 in block_record,
                          block2 in block_record)
                          return boolean
is
   l_return boolean;
begin
   if block1.asg_id = block2.asg_id
   and block1.asg_status = block2.asg_status
   and block1.asg_primary = block2.asg_primary
   and nvl(block1.asg_employment_category,' ') =
                                        nvl(block2.asg_employment_category,' ')
   and nvl(block1.asg_freq,' ') = nvl(block2.asg_freq,' ')
   and nvl(block1.asg_hours,hr_api.g_number) =
                                          nvl(block2.asg_hours,hr_api.g_number)
   and block1.asg_type = block2.asg_type
   and nvl(block1.ctr_type,' ') = nvl(block2.ctr_type,' ')
   and nvl(block1.ctr_fr_person_replaced,' ') =
                                         nvl(block2.ctr_fr_person_replaced,' ')
   and nvl(block1.ctr_status,' ') = nvl(block2.ctr_status,' ')
   and nvl(block1.ass_employee_category,' ') =
                                          nvl(block2.ass_employee_category,' ')
   and nvl(block1.asg_full_time_freq,' ') = nvl(block2.asg_full_time_freq,' ')
   and nvl(block1.asg_full_time_hours,hr_api.g_number) =
                                nvl(block2.asg_full_time_hours,hr_api.g_number)
   and nvl(block1.asg_fte_value,hr_api.g_number) =
                                      nvl(block2.asg_fte_value,hr_api.g_number)
   and block1.per_type_id = block2.per_type_id
   and block1.person_type_usages = block2.person_type_usages
   then
      l_return := false;
   else
      l_return := true;
   end if;
   --
   return l_return;
end relevant_change;
--
--
function posid_in_list (p_id in number,
                        p_list in varchar2)
                        return integer
is
   l_id_text varchar2(15);
   l_pos integer;
   l_char_before varchar2(1);
   l_char_after varchar2(1);
begin
   l_id_text := to_char(p_id);
   l_pos := instr(p_list,l_id_text);
   if l_pos > 0 then
      if l_pos = 1 then
         l_char_before := 'X';
      else
         l_char_before := nvl(substr(p_list,l_pos-1,1),'X');
      end if;
      if l_pos+length(l_id_text) > length(p_list) then
         l_char_after := 'X';
      else
         l_char_after := nvl(substr(p_list,l_pos+length(l_id_text),1),'X');
      end if;
      if l_char_before in ('0','1','2','3','4','5','6','7','8','9')
        or l_char_after in ('0','1','2','3','4','5','6','7','8','9') then
         l_pos := 0;
         hr_utility.set_location('id-string found in list but not a proper id',50);
      end if;
   end if;
   return l_pos;
end posid_in_list;
--
--
function include_this_person_type (p_user_person_types in varchar2,
                                   p_business_group_id in number,
                                   p_effective_date    in date)
                                   return boolean
is
   l_include boolean := false;
   l_ptu_delim  varchar2(10):=
                      hr_person_type_usage_info.get_user_person_type_separator;
   l_start_pos  number;
   l_end_pos    number;
   --
begin
   l_start_pos := 1;
   while l_start_pos <= length(p_user_person_types) loop
      l_end_pos := instr(p_user_person_types||l_ptu_delim,
                         l_ptu_delim,l_start_pos);
      begin
         if hruserdt.get_table_value(p_business_group_id
                                    ,'FR_USER_PERSON_TYPE', 'INCLUDE_D2'
                                    ,substr(p_user_person_types,l_start_pos,
                                            l_end_pos-l_start_pos)
                                    ,p_effective_date)  = 'Y'
         then
            l_include := true;
            exit;
         end if;
      exception when others then null;
      end;
      l_start_pos := l_end_pos + length(l_ptu_delim);
   end loop;
   --
   return l_include;
end include_this_person_type;
--
--
procedure get_extra_units (p_establishment_id in number,
                           p_effective_date in date,
                           p_base_unit out nocopy number,
                           p_xcot_a out nocopy number,
                           p_xcot_b out nocopy number,
                           p_xcot_c out nocopy number,
                           p_xcot_young_age out nocopy number,
                           p_xcot_old_age out nocopy number,
                           p_xcot_age_units out nocopy number,
                           p_xcot_training_hours out nocopy number,
                           p_xcot_training_units out nocopy number,
                           p_xcot_ap out nocopy number,
                           p_xcot_impro out nocopy number,
                           p_xcot_cat out nocopy number,
                           p_xcot_cdtd out nocopy number,
                           p_xcot_cfp out nocopy number,
                           p_xipp_low_rate out nocopy number,
                           p_xipp_medium_rate out nocopy number,
                           p_xipp_high_rate out nocopy number,
                           p_xipp_low_units out nocopy number,
                           p_xipp_medium_units out nocopy number,
                           p_xipp_high_units out nocopy number,
                           p_hire_units out nocopy number)
is
begin
   if g_extra_units.effective_date is null
   or g_extra_units.effective_date <> p_effective_date
   then
      -- Prime cache
      open csr_get_extra_units(p_effective_date);
      fetch csr_get_extra_units into g_extra_units.rec;
      close csr_get_extra_units;
      g_extra_units.effective_date := p_effective_date;
      -- don't use or cache p_establishment_id as the extra units are seeded.
   end if;
   p_base_unit           := g_extra_units.rec.base_unit;
   p_xcot_a              := g_extra_units.rec.x_cot_a;
   p_xcot_b              := g_extra_units.rec.x_cot_b;
   p_xcot_c              := g_extra_units.rec.x_cot_c;
   p_xcot_young_age      := g_extra_units.rec.x_cot_young_age;
   p_xcot_old_age        := g_extra_units.rec.x_cot_old_age;
   p_xcot_age_units      := g_extra_units.rec.x_cot_age_units;
   p_xcot_training_hours := g_extra_units.rec.x_cot_training_hours;
   p_xcot_training_units := g_extra_units.rec.x_cot_training_units;
   p_xcot_ap             := g_extra_units.rec.x_cot_ap;
   p_xcot_impro          := g_extra_units.rec.x_cot_impro;
   p_xcot_cat            := g_extra_units.rec.x_cot_cat;
   p_xcot_cdtd           := g_extra_units.rec.x_cot_cdtd;
   p_xcot_cfp            := g_extra_units.rec.x_cot_cfp;
   p_xipp_low_rate       := g_extra_units.rec.x_ipp_low_rate;
   p_xipp_medium_rate    := g_extra_units.rec.x_ipp_medium_rate;
   p_xipp_high_rate      := g_extra_units.rec.x_ipp_high_rate;
   p_xipp_low_units      := g_extra_units.rec.x_ipp_low_units;
   p_xipp_medium_units   := g_extra_units.rec.x_ipp_medium_units;
   p_xipp_high_units     := g_extra_units.rec.x_ipp_high_units;
   p_hire_units          := g_extra_units.rec.x_hire_units;
exception
   when others then
     hr_utility.set_location('GetExtUniERR:'||substr(sqlerrm,1,80),90);
end get_extra_units;
--
--
procedure populate_blocks_table (p_establishment_id in number,
                                 p_1jan in date,
                                 p_31dec in date,
                                 p_person_id in number,
                                 p_blocks out nocopy table_of_block)
is
  l_block_start  date;
  l_block_end    date;
  l_period_start date;
  l_period_end   date;
  l_asg_done     boolean;
begin
  --
  -- first clear table
  --
  p_blocks.delete;
  --
  for rec_asg in csr_get_asg_emp (p_establishment_id,
                                  p_1jan,
                                  p_31dec,
                                  p_person_id) loop
    --
    l_period_start := p_1jan;
    l_period_end := p_31dec;
    l_asg_done := false;
    --
    while not l_asg_done loop
      l_block_end := latest_block (rec_asg.asg_id,
                                p_establishment_id,
                                l_period_start,
                                l_period_end);
      --
      if l_block_end = to_date('31124712','DDMMYYYY') then
        l_asg_done := true;
      else
        l_block_start := beginning_of_block(rec_asg.asg_id,l_block_end,p_1jan);
        add_block_row (p_blocks,rec_asg.asg_id,l_block_start,l_block_end);
        l_period_end := l_block_start - 1;
        if l_block_start = p_1jan then
          l_asg_done := true;
        end if;
      end if;
    end loop;
  end loop;
exception
  when others then
    hr_utility.set_location('PopBloTabERR:'||substr(sqlerrm,1,80),90);
end populate_blocks_table;
--
--
function latest_block (p_assignment_id in number,
                           p_establishment_id in number,
                           p_start_period in date,
                           p_end_period in date)
                           return date
is
  l_end_date date;
begin
  --
  select nvl(least(p_end_period,max(a.effective_end_date)),to_date('31124712','DDMMYYYY'))
  into l_end_date
  from per_assignment_status_types t,
       per_all_assignments_f a
  where a.assignment_id = p_assignment_id
  and a.establishment_id = p_establishment_id
  and a.effective_start_date <= p_end_period
  and a.effective_end_date >= p_start_period
  and a.assignment_type in ('E','C')
  and t.assignment_status_type_id = a.assignment_status_type_id
  and nvl(t.per_system_status,'') in ('ACTIVE_ASSIGN','SUSP_ASSIGN'
                                     ,'ACTIVE_CWK','SUSP_CWK_ASG');
  --
  if sql%found then
    return l_end_date;
  else
    return to_date('31124712','DDMMYYYY');
  end if;
exception
  when others then
    hr_utility.set_location('LatBloERR:'||substr(sqlerrm,1,80),90);
end latest_block;
--
--
function beginning_of_block (p_assignment_id in number,
                             p_end_date in date,
                             p_1jan in date)
                             return date
is
  l_start_asg date;
  l_start_ctr date;
  l_start_bud date;
  l_start_per date;
  l_start_ptu date;
begin
  -- get latest change to:
  --    The assignment
  --    The person
  --    The latest assignment row's contract, if any
  --    The latest person type change (there may be multiple concurrent person
  --         types, some of which may end prior to the end of this period).
  --    The latest FTE budget value change, if any (such rows may not be
  --         contiguous and may end prior to the end of this period).
  select a.effective_start_date,
         p.effective_start_date,
         c.effective_start_date,
         max(decode(sign(ptu.effective_end_date-p_end_date),
                    -1,ptu.effective_end_date+1,
                    ptu.effective_start_date)),
         max(decode(sign(b.effective_end_date-p_end_date),
                    -1,b.effective_end_date+1,
                    b.effective_start_date))
  into   l_start_asg,
         l_start_per,
         l_start_ctr,
         l_start_ptu,
         l_start_bud
  from   per_all_assignments_f          a,
         per_all_people_f               p,
         per_contracts_f                c,
         per_person_type_usages_f       ptu,
         per_assignment_budget_values_f b
  where  a.assignment_id            = p_assignment_id
  and    p.person_id                = a.person_id
  and    c.contract_id(+)           = a.contract_id
  and    ptu.person_id              = p.person_id
  and    b.assignment_id(+)         = a.assignment_id
  and    b.unit (+)                 = 'FTE'
  and    p_end_date           between a.effective_start_date
                                  and a.effective_end_date
  and    p_end_date           between p.effective_start_date
                                  and p.effective_end_date
  and    p_end_date           between c.effective_start_date(+)
                                  and c.effective_end_date(+)
  and    ptu.effective_start_date  <= p_end_date
  and    ptu.effective_end_date    >= p.effective_start_date
  and    b.effective_start_date(+) <= p_end_date
  and    b.effective_end_date(+)   >= a.effective_start_date
  group  by a.effective_start_date,
            p.effective_start_date,
            c.effective_start_date;
  --
  return greatest(p_1jan,
                  l_start_asg,
                  l_start_per,
                  nvl(l_start_ctr,l_start_per),
                  l_start_ptu,
                  nvl(l_start_bud,l_start_asg));
  --
exception
  when no_data_found then
    return p_1jan;
  when others then
    hr_utility.set_location('BegOfBloERR:'||substr(sqlerrm,1,80),90);
end beginning_of_block;
--
--
procedure add_block_row (p_block_table in out nocopy table_of_block,
                         p_assignment_id in number,
                         p_start_date in date,
                         p_end_date in date)
is
  i            binary_integer;
  l_person_id  per_all_people_f.person_id%TYPE;
  l_ptu_delim  varchar2(10);
  --
  cursor csr_get_person_type_usages is
  select ppttl.user_person_type
    from per_person_type_usages_f  pptu,
         per_person_types_tl       ppttl
   where pptu.person_id          = l_person_id
     and ppttl.person_type_id    = pptu.person_type_id
     and p_start_date      between pptu.effective_start_date
                               and pptu.effective_end_date
     and ppttl.language          = userenv('LANG');
  --
  l_user_person_type per_person_types_tl.user_person_type%TYPE;
begin
  --
  i := p_block_table.last;
  if i is null then
    i:=1;
  else
    i:=i+1;
  end if;
  --
  p_block_table(i).asg_id := p_assignment_id;
  p_block_table(i).block_start_date := p_start_date;
  p_block_table(i).block_end_date := p_end_date;
  --
  select per.person_type_id,
        asg.assignment_status_type_id,
        asg.primary_flag,
        asg.employment_category,
        asg.frequency,
        asg.normal_hours,
        ctr.type,
        ctr.ctr_information5,
        ctr.status,
        scl.segment2,
        nvl(pos.frequency,nvl(org.ORG_INFORMATION4,bus.ORG_INFORMATION4)),
        nvl(pos.working_hours,
            fnd_number.canonical_to_number(nvl(org.ORG_INFORMATION3,
                                               bus.ORG_INFORMATION3))),
        bud.value,
        asg.assignment_type,
        asg.person_id
  into p_block_table(i).per_type_id,
       p_block_table(i).asg_status,
       p_block_table(i).asg_primary,
       p_block_table(i).asg_employment_category,
       p_block_table(i).asg_freq,
       p_block_table(i).asg_hours,
       p_block_table(i).ctr_type,
       p_block_table(i).ctr_fr_person_replaced,
       p_block_table(i).ctr_status,
       p_block_table(i).ass_employee_category,
       p_block_table(i).asg_full_time_freq,
       p_block_table(i).asg_full_time_hours,
       p_block_table(i).asg_fte_value,
       p_block_table(i).asg_type,
       l_person_id
  from per_all_people_f               per,
       per_contracts_f                ctr,
       hr_soft_coding_keyflex         scl,
       per_all_positions              pos,
       hr_organization_information    org,
       hr_organization_information    bus,
       per_assignment_budget_values_f bud,
       per_all_assignments_f          asg
  where asg.assignment_id                   = p_assignment_id
  and p_start_date                    between asg.effective_start_date
                                          and asg.effective_end_date
  and per.person_id                         = asg.person_id
  and p_start_date                    between per.effective_start_date
                                          and per.effective_end_date
  and ctr.contract_id (+)                   = asg.contract_id
  and ctr.ctr_information_category (+)      = 'FR'
  and p_start_date                    between ctr.effective_start_date (+)
                                          and ctr.effective_end_date (+)
  and scl.soft_coding_keyflex_id (+)        = asg.soft_coding_keyflex_id
  and pos.position_id (+)                   = asg.position_id
  and org.organization_id (+)               = asg.organization_id
  and org.org_information_context (+) || '' = 'Work Day Information'
  and bus.organization_id (+)               = asg.business_group_id
  and bus.org_information_context (+) || '' = 'Work Day Information'
  and bud.assignment_id (+)                 = asg.assignment_id
  and p_start_date                    between bud.effective_start_date (+)
                                          and bud.effective_end_date (+)
  and bud.unit (+)                          = 'FTE';
  --
  open csr_get_person_type_usages;
  fetch csr_get_person_type_usages into p_block_table(i).person_type_usages;
  if csr_get_person_type_usages%FOUND then
    l_ptu_delim := hr_person_type_usage_info.get_user_person_type_separator;
    loop
      fetch csr_get_person_type_usages into l_user_person_type;
      exit when csr_get_person_type_usages%NOTFOUND;
      p_block_table(i).person_type_usages :=
         p_block_table(i).person_type_usages ||
         l_ptu_delim || l_user_person_type;
    end loop;
  end if;
  close csr_get_person_type_usages;
  --
exception
  when others then
    hr_utility.set_location('AddBloRowERR:'||substr(sqlerrm,1,80),90);
end add_block_row;
--
--
END PER_FR_D2_PKG;

/
