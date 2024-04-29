--------------------------------------------------------
--  DDL for Package Body PER_ASSIGNMENTS_F2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ASSIGNMENTS_F2_PKG" AS
/* $Header: peasg01t.pkb 120.29.12010000.8 2009/12/08 12:33:48 brsinha ship $ */
g_package  varchar2(24) := 'PER_ASSIGNMENTS_F2_PKG.';
g_debug    boolean; -- debug flag
--

-----------------------------------------------------------------------------
--
-- Procedure to get s_* values of items. Called as first step of pre-update
-- and pre-delete.
--
-----------------------------------------------------------------------------
procedure get_save_fields(
   p_row_id    varchar2,
   p_s_pos_id     IN OUT NOCOPY number,
   p_s_ass_num    IN OUT NOCOPY varchar2,
   p_s_org_id     IN OUT NOCOPY number,
   p_s_pg_id      IN OUT NOCOPY number,
   p_s_job_id     IN OUT NOCOPY number,
   p_s_grd_id     IN OUT NOCOPY number,
   p_s_pay_id     IN OUT NOCOPY number,
   p_s_def_code_comb_id IN OUT NOCOPY number,
   p_s_soft_code_kf_id  IN OUT NOCOPY number,
   p_s_per_sys_st    IN OUT NOCOPY varchar2,
   p_s_ass_st_type_id   IN OUT NOCOPY number,
   p_s_prim_flag     IN OUT NOCOPY varchar2,
   p_s_sp_ceil_step_id  IN OUT NOCOPY number,
   p_s_pay_bas    IN OUT NOCOPY varchar2) is
   --
   cursor get_assgt is
      select   ass.position_id,
         ass.assignment_number,
         ass.organization_id,
         ass.people_group_id,
         ass.job_id,
         ass.grade_id,
         ass.payroll_id,
         ass.default_code_comb_id,
         ass.soft_coding_keyflex_id,
         nvl(amd.per_system_status, st.per_system_status),
         ass.assignment_status_type_id,
         ass.primary_flag,
         ass.special_ceiling_step_id,
         pb.pay_basis
      from  per_assignments_f ass,
         per_assignment_status_types st,
         per_ass_status_type_amends amd,
         per_pay_bases pb
      where ass.rowid   = P_ROW_ID
      and   ass.assignment_status_type_id =
            amd.assignment_status_type_id (+)
      and   ass.assignment_status_type_id =
           -- amd.assignment_status_type_id (+) bug 5378516
	    st.assignment_status_type_id (+)
      and   ass.business_group_id + 0  =
            amd.business_group_id (+) + 0
      and   ass.pay_basis_id  = pb.pay_basis_id (+);
--
l_proc            varchar2(15) :=  'get_save_fields';
--
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

   open get_assgt;
   fetch get_assgt into
      p_s_pos_id,
      p_s_ass_num,
      p_s_org_id,
      p_s_pg_id,
      p_s_job_id,
      p_s_grd_id,
      p_s_pay_id,
      p_s_def_code_comb_id,
      p_s_soft_code_kf_id,
      p_s_per_sys_st,
      p_s_ass_st_type_id,
      p_s_prim_flag,
      p_s_sp_ceil_step_id,
      p_s_pay_bas;
   --
   if get_assgt%notfound then
      close get_assgt;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE',
         'PER_ASSIGNMENTS_F2_PKG.GET_SAVE_FIELDS');
      fnd_message.set_token('STEP', '1');
      fnd_message.raise_error;
   end if;
   --
   close get_assgt;
   --
  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 10);
  END IF;

end get_save_fields;
-----------------------------------------------------------------------------
--
-- Procedure to check Personnel-type attributes of assignment record.
-- This is called pre-insert and pre-update into per_assignments_f.
--
procedure iu_non_payroll_checks (
   p_per_id number,
   p_sess_date date,
   p_per_sys_st   varchar2,
   p_s_per_sys_st varchar2,
   p_ass_st_type_id number,
   p_bg_id     number,
   p_leg_code  varchar2,
   p_ass_id number,
        p_emp_num varchar2,
         p_ass_seq   number,
        p_ass_num varchar2) is
   l_null      number;
   l_ass_num   varchar2(30);
   --
   cursor curr_emp is
      select   1
      from  per_people_f p
      where p.person_id = P_PER_ID
      and   P_SESS_DATE between p.effective_start_date
               and   p.effective_end_date;
   --
   cursor asg_type is
      select   1
      from  per_assignment_status_types a,
         per_ass_status_type_amends b
      where b.assignment_status_type_id (+) =
               a.assignment_status_type_id
      and   a.assignment_status_type_id = P_ASS_ST_TYPE_ID
      and   b.business_group_id (+) + 0 = P_BG_ID
      and   nvl(a.business_group_id, P_BG_ID) = P_BG_ID
      and   nvl(a.legislation_code, P_LEG_CODE) = P_LEG_CODE
      and   nvl(b.active_flag, a.active_flag) = 'Y'
      and   nvl(b.per_system_status, a.per_system_status) =
            P_PER_SYS_ST;
begin
   --
   -- CHECK FOR CURRENT EMPLOYEE:
   -- Check database for current_employee flag because another user
   -- may have changed the flag since querying the person
   --
hr_utility.set_location('per_assignments_f2_pkg.iu_non_payroll_checks',1);
   open curr_emp;
   fetch curr_emp into l_null;
   if curr_emp%notfound then
      close curr_emp;
      fnd_message.set_name('PAY', 'HR_6254_EMP_ASS_EMP_ENDED');
      fnd_message.raise_error;
   end if;
   close curr_emp;
   --
   -- CHECK VALID STATUS:
   -- Check that the Status is still active.
   --
hr_utility.set_location('per_assignments_f2_pkg.iu_non_payroll_checks',2);
hr_utility.trace('p_per_sys_st is '||p_per_sys_st);
hr_utility.trace('p_s_per_sys_st is '||p_s_per_sys_st);
hr_utility.trace('P_ASS_ST_TYPE_ID is '|| to_char(P_ASS_ST_TYPE_ID));
   if (p_per_sys_st <> p_s_per_sys_st) or (p_s_per_sys_st is null) then
      open asg_type;
      fetch asg_type into l_null;
      if asg_type%notfound then
         close asg_type;
         fnd_message.set_name('PAY',
               'HR_6073_APP_ASS_INVALID_STATUS');
         fnd_message.raise_error;
      end if;
      close asg_type;
   end if;
   --
   -- Check new assignment number - does not write back to parameter but
   -- a local parameter must be used.
   --
hr_utility.set_location('per_assignments_f2_pkg.iu_non_payroll_checks',3);
   if p_ass_num is not null then
      l_ass_num := p_ass_num;
      hr_assignment.gen_new_ass_number(
         p_ass_id,
         p_bg_id,
         p_emp_num,
         p_ass_seq,
         l_ass_num);
   end if;
   --
   -- Note that a new ass_num is NOT generated here: this needs to be done
   -- only at pre-insert when a new ass_seq is generated.
   --
end iu_non_payroll_checks;
-----------------------------------------------------------------------------
--
-- Initiates assignment, used to initialize PERWSEMA.
--
procedure initiate_assignment(
   p_bus_grp_id                     number,
   p_person_id                      number,
   p_end_of_time                    date,
   p_gl_set_of_books_id             IN OUT NOCOPY number,
   p_leg_code                       varchar2,
   p_sess_date                      date,
   p_period_of_service_id           IN OUT NOCOPY number,
   p_accounting_flexfield_ok_flag   IN OUT NOCOPY varchar2,
   p_no_scl                         IN OUT NOCOPY varchar2,
   p_scl_id_flex_num                IN OUT NOCOPY number,
   p_def_user_st                    IN OUT NOCOPY varchar2,
   p_def_st_id                      IN OUT NOCOPY number,
   p_yes_meaning                    IN OUT NOCOPY varchar2,
   p_no_meaning                     IN OUT NOCOPY varchar2,
   p_pg_struct                      IN OUT NOCOPY varchar2,
   p_valid_pos_flag                 IN OUT NOCOPY varchar2,
   p_valid_job_flag                 IN OUT NOCOPY varchar2,
   p_gl_flex_structure              IN OUT NOCOPY number,
   p_set_of_books_name              IN OUT NOCOPY varchar2,
   p_fsp_table_name                 IN OUT NOCOPY varchar2,
   p_payroll_installed              IN OUT NOCOPY varchar2,
   p_scl_title                      IN OUT NOCOPY varchar2,
   p_terms_required                 OUT NOCOPY varchar2,
   p_person_id2                     IN     number,
   p_assignment_type                IN varchar2 ) is
--
   l_dummy           number;
   l_dummy_dt        date;
   l_sqlap_installed    varchar2(1);
   l_industry        varchar2(1);
   l_sql_text        varchar2(2000);
   l_sql_cursor         number;
   l_rows_fetched       number;
   l_gl_set_of_books_id            number;
   l_gl_set_of_books_id_temp       number;
--
cursor pg_struct is
   select
      l1.meaning,
      l2.meaning,
      bg.people_group_structure
   from
      hr_lookups l1, hr_lookups l2,
      per_business_groups bg
   where l1.lookup_type    = 'YES_NO'
   and   l2.lookup_type    = 'YES_NO'
   and   l1.lookup_code    = 'Y'
   and   l2.lookup_code    = 'N'
   and   bg.business_group_id + 0 = P_BUS_GRP_ID;
--
-- 923011: Ensure user status is in the appropriate language
cursor def_assgt_status is
   select   nvl(btl.user_status,atl.user_status),
         a.assignment_status_type_id
   from     per_assignment_status_types_tl atl,
                per_assignment_status_types a,
            per_ass_status_type_amends_tl btl,
                per_ass_status_type_amends b
   where    atl.assignment_status_type_id = a.assignment_status_type_id
   and      atl.language = userenv('LANG')
   and      btl.ass_status_type_amend_id (+) = b.ass_status_type_amend_id
   and      btl.language (+) = userenv('LANG')
   and      b.assignment_status_type_id (+) = a.assignment_status_type_id
   and      b.business_group_id (+) + 0      = P_BUS_GRP_ID
   and      nvl(a.business_group_id, P_BUS_GRP_ID)    = P_BUS_GRP_ID
   and      nvl(a.legislation_code, P_LEG_CODE)    = P_LEG_CODE
   and      nvl(b.active_flag, a.active_flag)   = 'Y'
   and      nvl(b.default_flag, a.default_flag) = 'Y'
   and      nvl(b.per_system_status, a.per_system_status)
            = 'ACTIVE_ASSIGN';
--
   -- Bug fix 3648612.
   -- Cursor modified to improve performance.

cursor valid_pos_grades is
   select   1
   from  per_valid_grades vg
   where vg.business_group_id   = P_BUS_GRP_ID
   and   vg.position_id    is not null;
--
   -- Bug fix 3648612.
   -- Cursor modified to improve performance.

cursor valid_job_grades is
   select   1
   from  per_valid_grades vg
   where vg.business_group_id   = P_BUS_GRP_ID
   and   vg.job_id      is not null;
--
cursor get_pd_of_ser is
        select  p.date_start date_start, p.period_of_service_id
        from    per_periods_of_service p
        where   p.person_id             = P_PERSON_ID
        and     P_SESS_DATE between
                p.date_start and nvl(p.final_process_date, P_END_OF_TIME)
        union
        select  pdp.date_start date_start, to_number(null)
        from    per_periods_of_placement pdp
        where   pdp.person_id           = P_PERSON_ID
        and     P_SESS_DATE between
                pdp.date_start and nvl(pdp.final_process_date, p_end_of_time)
        order by date_start desc;
--
-- Simplified the following cursor by removing the unnecessary join
-- to fnd_applications. RMF 06-Mar-96.
--
cursor is_ap_installed is
   select   'Y'
   from     fnd_product_installations
   where    application_id    = 200
   and      status      = 'I';
--
-- #345809  Added a cursor to get the set_of_books_id
-- from the financials_system_parameters table, rather than from a
-- client-side profile. See bug 243960 for more details.
--
--      Bug 874343 Query set_of_books id from financial_system_params_all
--
 cursor sob_id is
   select   set_of_books_id
   from  financials_system_parameters
   where business_group_id    = p_bus_grp_id;
--
cursor get_gl_info is
   select   chart_of_accounts_id, name
   from  gl_sets_of_books
   where set_of_books_id   = p_gl_set_of_books_id;
--
-- #345809 Now find out which of the financials_system_parameters tables
-- is available, if any. Options are:
--
-- FINANCIALS_SYSTEM_PARAMS_ALL  (10.6 install)
-- FINANCIALS_SYSTEM_PARAMETERS  (10.5 HR + other apps install)
-- none           (10.5 HR only install)
--
-- The ORDER BY clause ensures we pick up FINANCIALS_SYSTEM_PARAMS_ALL
-- if it's there, ahead of FINANCIALS_SYSTEM_PARAMETERS.
--
--      Bug 874343 - No longer need to query for financial system params tables.
--
--cursor fsp_table_name is
-- select    table_name
-- from   user_catalog
-- where  table_name in ('FINANCIALS_SYSTEM_PARAMS_ALL',
--          'FINANCIALS_SYSTEM_PARAMETERS')
-- order by table_name desc;
--
cursor scl is
    select rule_mode
    from   pay_legislation_rules
    where  legislation_code   = P_LEG_CODE
    and    rule_type          = 'S'
    and    exists
          (select null
           from   fnd_segment_attribute_values
           where  id_flex_num       = rule_mode
           and    application_id    = 800
           and    id_flex_code      = 'SCL'
           and    segment_attribute_type = 'ASSIGNMENT'
           and    attribute_value   = 'Y')
    and    exists
          (select null
           from   pay_legislation_rules
           where  legislation_code     = P_LEG_CODE
           and    rule_type = 'SDL'
           and    rule_mode = 'A') ;

cursor scl_cwk is
    select rule_mode
    from   pay_legislation_rules
    where  legislation_code     = P_LEG_CODE
    and    rule_type            = 'CWK_S'
    and    exists
          (select null
           from   fnd_segment_attribute_values
           where  id_flex_num           = rule_mode
           and    application_id        = 800
           and    id_flex_code          = 'SCL'
           and    segment_attribute_type = 'ASSIGNMENT'
           and    attribute_value       = 'Y')
    and    exists
          (select null
           from   pay_legislation_rules
           where  legislation_code     = P_LEG_CODE
           and    rule_type = 'CWK_SDL'
           and    rule_mode = 'A');

cursor scl_title is
    select id_flex_structure_name
    from   fnd_id_flex_structures_vl
    where  id_flex_num     = P_SCL_ID_FLEX_NUM
    and    application_id  = 800
    and    id_flex_code    = 'SCL';
--
cursor terms is
    select rule_mode
    from   pay_legislative_field_info
    where  legislation_code =  P_LEG_CODE
    and    rule_type        = 'TERMS'
    and    rule_mode        = 'Y';
--
begin
   hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',10);
   --
   --  Get Yes/No, people group structure.
   --
   open pg_struct;
   fetch pg_struct into
      P_YES_MEANING,
      P_NO_MEANING,
      P_PG_STRUCT;
   close pg_struct;
   --
   -- Now get default ACTIVE_ASSIGN user status.
   --
   hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',20);
   open def_assgt_status;
   fetch def_assgt_status into
      P_DEF_USER_ST,
      P_DEF_ST_ID;
   if def_assgt_status%notfound then
      close def_assgt_status;
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE','PER_ASSIGNMENTS_F2_PKG.INITIATE_ASSIGNMENT');
      fnd_message.set_token('STEP', '1');
      fnd_message.raise_error;
   end if;
   close def_assgt_status;
   --
   hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',30);
   open valid_pos_grades;
   fetch valid_pos_grades into l_dummy;
   if valid_pos_grades%found then
      P_VALID_POS_FLAG := 'Y';
   end if;
   close valid_pos_grades;
   --
   hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',40);
   open valid_job_grades;
   fetch valid_job_grades into l_dummy;
   if valid_job_grades%found then
      P_VALID_JOB_FLAG := 'Y';
   end if;
   close valid_job_grades;
   --
   -- Get Person related info. if person id specified.
   --
   hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',50);
   if ( p_person_id is not null ) then
      open get_pd_of_ser;
      fetch get_pd_of_ser into l_dummy_dt, P_PERIOD_OF_SERVICE_ID;
      if get_pd_of_ser%notfound then
          close get_pd_of_ser;
          fnd_message.set_name('PAY', 'HR_6346_EMP_ASS_NO_POS');
          fnd_message.raise_error;
      end if;
      close get_pd_of_ser;
   end if;
   --
   -- Get Set Of Books info if AP is installed. This is required for
   -- the GL flex.
   --
   hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',55);
   open is_ap_installed;
   fetch is_ap_installed into l_sqlap_installed;
   close is_ap_installed;
   hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',60);
   --
   if l_sqlap_installed = 'Y' then
      hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',70);
      --
      -- Clear p_gl_set_of_books_id and p_fsp_table_name before we
      -- start, though they should be null anyway.
      --
      p_gl_set_of_books_id := NULL;
      -- Bug 874343 01/12/01
      -- Can simply query FINANCIAL_SYSTEM_PARAMS_ALL
      --
      p_fsp_table_name := 'FINANCIALS_SYSTEM_PARAMS_ALL';
      --
      open  sob_id;
      fetch sob_id into l_gl_set_of_books_id;
      if sob_id%FOUND then
         hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',80);
         --
         -- Bug 3270409
         --
         -- Even if there is exactly one set_of_books_id for the business group
         -- that should not be defaulted for the assignment
         --
         -- The user must choose the set_of_books explicitly whether the business
         -- group has exactly one set of books or more than that.
         --
         P_ACCOUNTING_FLEXFIELD_OK_FLAG := 'Y';
         P_GL_SET_OF_BOOKS_ID := NULL;
      else
         hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',110);
         --
         -- There's no set of books for the business group.
         -- Set the flex flag to N.
         --
         P_ACCOUNTING_FLEXFIELD_OK_FLAG := 'N';
      end if;
      close sob_id;
   else
      --
      -- AP is not installed.
      --
      P_ACCOUNTING_FLEXFIELD_OK_FLAG := 'N';
       hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',120);
   end if;

   --
   -- Get the soft coded keyflex setup info.
   -- Here we use p_person_id2 because p_person_id is intentionally
   -- nulled under certain conditions.  p_person_id2 is never null.
   --
   -- #3609019 Added the clause of p_assignment_type
   --
   IF ( hr_person_type_usage_info.is_person_of_type
          (p_person_id          => p_person_id2
          ,p_effective_date     => p_sess_date
          ,p_system_person_type => 'EMP')
       and (nvl(p_assignment_type,'E') = 'E')) THEN
      hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',130);
      open scl;
      fetch scl into P_SCL_ID_FLEX_NUM;
      if scl%notfound then
         P_NO_SCL := 'Y';
      end if;
      close scl;
   -- Start of fix 2885212
   ELSIF ( hr_person_type_usage_info.is_person_of_type
            (p_person_id          => p_person_id2
            ,p_effective_date     => p_sess_date
            ,p_system_person_type => 'EX_EMP')
          and (nvl(p_assignment_type,'E') = 'E')) THEN
      hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',135);
      open scl;
      fetch scl into P_SCL_ID_FLEX_NUM;
      if scl%notfound then
         P_NO_SCL := 'Y';
      end if;
      close scl;
   -- End of 2885212
   ELSIF ( hr_person_type_usage_info.is_person_of_type
            (p_person_id          => p_person_id2
            ,p_effective_date     => p_sess_date
            ,p_system_person_type => 'CWK')
         and (nvl(p_assignment_type,'C') = 'C'))THEN
      hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',140);
      open  scl_cwk;
      fetch scl_cwk into P_SCL_ID_FLEX_NUM;
      if scl_cwk%notfound then
         P_NO_SCL := 'Y';
      end if;
      close scl_cwk;
   ELSE
       hr_utility.set_location('per_assignments_f2_pkg.initiate_assignment',150);
       P_NO_SCL := 'Y';
   END IF;

   if not P_NO_SCL = 'Y' then
      open  scl_title;
      fetch scl_title into P_SCL_TITLE;
      close scl_title;
   end if;

   --
   -- Establish whether Payroll has been installed
   --
   if fnd_installation.get(appl_id     => 801
                         ,dep_appl_id => 801
                         ,status      => p_payroll_installed
                         ,industry    => l_industry)then
      null;
   end if;
   --
   -- Establish whether contracts and collective agreements canvas
   -- should be visible to non-french customers.
        --
   P_TERMS_REQUIRED := 'Y';
   --
   if P_LEG_CODE <> 'FR' then
      open terms;
      fetch terms into p_terms_required;
      if terms%notfound then
         p_terms_required := 'N';
      end if;
      close terms;
   end if;
        --
   hr_utility.set_location('Leaving...:per_assignments_f2_pkg.initiate_assignment',200);
--
end initiate_assignment;
-----------------------------------------------------------------------------
procedure real_del_checks(
   p_pd_os_id     number,
   p_ass_id    number,
   p_per_id    number,
   p_del_mode     varchar2,
        p_sess_date     date,
        p_per_sys_st    varchar2,
        p_val_st_date      date,
        p_new_end_date     date,
        p_val_end_date     date,
        p_pay_id     number,
   p_eff_st_date     date,
   p_eff_end_date    date,
   p_grd_id    number,
   p_sp_ceil_st_id      number,
   p_ceil_seq     number,
   p_pay_basis_id number  ) is --fix for bug 4764140
   l_null         number;
   l_new_end_date    date;
   l_warning      varchar2(80);
   l_re_entry_point  number;
--
-- Private proc used pre-delete and key-delrec.
--
-- Perform the real or total delete checks.
--   check that the current assignment is not the first assignment in
--   the employees current period of service;
--   check that assignments will be continuous throughout the employees
--   period of service;
--   perform the referential integrity checks.
--
   cursor pd_os is
      select   1
      from  per_periods_of_service pos
      where pos.period_of_service_id   = P_PD_OS_ID
      and   exists (
         select   null
         from  per_all_assignments_f a
         where a.assignment_id      = P_ASS_ID
         and   a.effective_start_date  = pos.date_start);
   --
   cursor chk_ass is
      select   1
      from  per_all_assignments_f a
      where a.assignment_id      <> P_ASS_ID
      and   a.person_id    = P_PER_ID
      and   a.assignment_type = 'E'
      and   exists (
         select   null
         from  per_periods_of_service pos
         where pos.period_of_service_id = P_PD_OS_ID
         and   pos.date_start = a.effective_start_date);
--
l_proc            varchar2(15) :=  'real_del_checks';
--
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;
   --
   -- Do not allow the user to delete this assignment if this is the only
   -- assignment with a start date that is the same as the period of
   -- service start date.
   --
   open pd_os;
   fetch pd_os into l_null;
   if pd_os%found then
      open chk_ass;
      fetch chk_ass into l_null;
      if chk_ass%notfound then
         close chk_ass;
         close pd_os;
         fnd_message.set_name('PAY',
            'HR_6435_EMP_ASS_DEL_FIRST');
         fnd_message.raise_error;
      end if;
      close chk_ass;
   end if;
   close pd_os;
   --
   -- Perform the referential integrity checks.
   --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 10);
  END IF;
   hr_assignment.del_ref_int_check(
      p_ass_id,
      'ZAP',
      p_val_st_date);
   --
   -- PAYROLL_CHANGE_VALIDATE:
   --
   -- null = p_upd_mode as we want proc to look at p_del_mode.
   --
   l_re_entry_point  := 2;
   l_new_end_date       := p_new_end_date;
   --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 20);
  END IF;
   per_assignments_f3_pkg.update_and_delete_bundle(
      null,
      p_val_st_date,
      p_eff_st_date,
      p_eff_end_date,
      p_pd_os_id,
      p_per_sys_st,
      p_ass_id,
      p_val_end_date,
      null,
      p_del_mode,
      p_sess_date,
      p_pay_id,
      p_grd_id,
      p_sp_ceil_st_id,
      p_ceil_seq,
      l_new_end_date,
      l_warning,
      l_re_entry_point,
      'Y',
         p_pay_basis_id);--fix for bug 4764140
   --
   -- Value of l_new_end_date will not be changed by
   -- update_and_delete_bundle because we are only executing entry
   -- point 2 of the code, not the bit which sets the
   -- l_new_end_date value.
   --
   -- No end warning is returned from this check.
   --
  IF g_debug THEN
    hr_utility.set_location( 'Leaving ' || g_package || l_proc, 30);
  END IF;
end real_del_checks;
-----------------------------------------------------------------------------
--
-- *** Bundled procedures from update/delete to save on network usage
--     for PERWSEMA. ***
--
-----------------------------------------------------------------------------
--
-- Bundled explicit selecta from pre_update to improve performance.
-- Returns p_return_warning as 'Y' if assgt has been ended in future so a
-- warning can be issued on client.
-- Note that first the get_save_fields is run.
--
procedure pre_update_bundle (
   p_pos_id    number,
   p_org_id    number,
   p_ass_id    number,
   p_row_id    varchar2,
   p_eff_st_date     date,
   p_upd_mode     varchar2,
   p_per_sys_st      varchar2,
   p_s_pos_id     IN OUT NOCOPY number,
   p_s_ass_num    IN OUT NOCOPY varchar2,
   p_s_org_id     IN OUT NOCOPY number,
   p_s_pg_id      IN OUT NOCOPY number,
   p_s_job_id     IN OUT NOCOPY number,
   p_s_grd_id     IN OUT NOCOPY number,
   p_s_pay_id     IN OUT NOCOPY number,
   p_s_def_code_comb_id IN OUT NOCOPY number,
   p_s_soft_code_kf_id  IN OUT NOCOPY number,
   p_s_per_sys_st    IN OUT NOCOPY varchar2,
   p_s_ass_st_type_id   IN OUT NOCOPY number,
   p_s_prim_flag     IN OUT NOCOPY varchar2,
   p_s_sp_ceil_step_id  IN OUT NOCOPY number,
   p_s_pay_bas    IN OUT NOCOPY varchar2,
   p_return_warning  IN OUT NOCOPY varchar2,
   p_sess_date    date default null) is
   --
   l_dummy     number;
   l_eot    date := to_date('31124712', 'DDMMYYYY');
   --
        -- Changed 01-Oct-99 SCNair (per_all_positions to hr_all_positions) date track requirement
        --
   cursor consistent_org is
      select   1
      from  hr_all_positions p
      where p.position_id  = P_POS_ID
      and   p.organization_id = P_ORG_ID;
   --
   cursor first_assgt is
      select   1
      from  per_assignments_f a
      where a.assignment_id      = P_ASS_ID
      and   a.rowid        <> P_ROW_ID
      and   a.effective_start_date  < P_EFF_ST_DATE;
   --
   cursor ended_assgt is
         select   1
         from  sys.dual
         where L_EOT > (select   max(effective_end_date)
                from per_assignments_f
                where   assignment_id = P_ASS_ID);
  --
  -- Payroll Object Group functionality. Call to pay_pog_all_assignments_pkg
  -- requires old assignment values, so using cursor to populate record with
  -- the required values.
  --
 -- old_asg_rec per_asg_shd.g_rec_type;
  --
  cursor asg_details(p_asg_id number
                    ,p_eff_date date)
  is
  select assignment_id
  ,effective_start_date
  ,effective_end_date
  ,business_group_id
  ,recruiter_id
  ,grade_id
  ,position_id
  ,job_id
  ,assignment_status_type_id
  ,payroll_id
  ,location_id
  ,person_referred_by_id
  ,supervisor_id
  ,special_ceiling_step_id
  ,person_id
  ,recruitment_activity_id
  ,source_organization_id
  ,organization_id
  ,people_group_id
  ,soft_coding_keyflex_id
  ,vacancy_id
  ,pay_basis_id
  ,assignment_sequence
  ,assignment_type
  ,primary_flag
  ,application_id
  ,assignment_number
  ,change_reason
  ,comment_id
  ,null
  ,date_probation_end
  ,default_code_comb_id
  ,employment_category
  ,frequency
  ,internal_address_line
  ,manager_flag
  ,normal_hours
  ,perf_review_period
  ,perf_review_period_frequency
  ,period_of_service_id
  ,probation_period
  ,probation_unit
  ,sal_review_period
  ,sal_review_period_frequency
  ,set_of_books_id
  ,source_type
  ,time_normal_finish
  ,time_normal_start
  ,bargaining_unit_code
  ,labour_union_member_flag
  ,hourly_salaried_code
  ,request_id
  ,program_application_id
  ,program_id
  ,program_update_date
  ,ass_attribute_category
  ,ass_attribute1
  ,ass_attribute2
  ,ass_attribute3
  ,ass_attribute4
  ,ass_attribute5
  ,ass_attribute6
  ,ass_attribute7
  ,ass_attribute8
  ,ass_attribute9
  ,ass_attribute10
  ,ass_attribute11
  ,ass_attribute12
  ,ass_attribute13
  ,ass_attribute14
  ,ass_attribute15
  ,ass_attribute16
  ,ass_attribute17
  ,ass_attribute18
  ,ass_attribute19
  ,ass_attribute20
  ,ass_attribute21
  ,ass_attribute22
  ,ass_attribute23
  ,ass_attribute24
  ,ass_attribute25
  ,ass_attribute26
  ,ass_attribute27
  ,ass_attribute28
  ,ass_attribute29
  ,ass_attribute30
  ,title
  ,object_version_number
  ,contract_id
  ,establishment_id
  ,collective_agreement_id
  ,cagr_grade_def_id
  ,cagr_id_flex_num
  ,notice_period
  ,notice_period_uom
  ,employee_category
  ,work_at_home
  ,job_post_source_name
  ,posting_content_id
  ,period_of_placement_date_start
  ,vendor_id
  ,vendor_employee_number
  ,vendor_assignment_number
  ,assignment_category
  ,project_title
  ,applicant_rank
  ,grade_ladder_pgm_id
  ,supervisor_assignment_id
  ,vendor_site_id
  ,po_header_id
  ,po_line_id
  ,projected_assignment_end
  from per_all_assignments_f
  where assignment_id = p_asg_id
  and   p_eff_date between effective_start_date
                       and effective_end_date;
  --
--
l_proc            varchar2(17) :=  'pre_update_bundle';
--
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;
   get_save_fields(
      p_row_id,
      p_s_pos_id,
      p_s_ass_num,
      p_s_org_id,
      p_s_pg_id,
      p_s_job_id,
      p_s_grd_id,
      p_s_pay_id,
      p_s_def_code_comb_id,
      p_s_soft_code_kf_id,
      p_s_per_sys_st,
      p_s_ass_st_type_id,
      p_s_prim_flag,
      p_s_sp_ceil_step_id,
      p_s_pay_bas);
   --
   -- Check that "The position is now inconsistent with the new
   -- organization" is not true.
   --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 10);
  END IF;
   if (p_org_id <> p_s_org_id) and (p_pos_id is not null) then
      open consistent_org;
      fetch consistent_org into l_dummy;
      if consistent_org%notfound then
         fnd_message.set_name('PAY',
            'HR_6102_EMP_ASS_ORGANIZATION');
         close consistent_org;
         fnd_message.raise_error;
      end if;
      close consistent_org;
   end if;
   --
   -- Check if the assignment row from Per_assignments_f is the first
   -- for this assignment id. If it is then the status must be
   -- ACTIVE_ASSIGN.
   --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 20);
  END IF;
   if p_upd_mode = 'CORRECTION' and p_per_sys_st not in ('ACTIVE_ASSIGN'
                                                             ,'ACTIVE_CWK') then
      open first_assgt;
      fetch first_assgt into l_dummy;
      if first_assgt%notfound then
         fnd_message.set_name('PAY',
            'HR_7139_EMP_ASS_FIRST_EMP_ASS');
         close first_assgt;
         fnd_message.raise_error;
      end if;
      close first_assgt;
   end if;
   --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 30);
  END IF;
   if p_upd_mode <> 'UPDATE_OVERRIDE' then
      --
      -- Check for "This assignment has been ended in the future...
      -- Continue?".
      --
      open ended_assgt;
      fetch ended_assgt into l_dummy;
      if ended_assgt%found then
         p_return_warning := 'Y';
      end if;
      close ended_assgt;
   end if;
   --
  --
  -- populate POG record with asg values
  --
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 40);
  END IF;
  OPEN asg_details(p_ass_id, p_sess_date);
  FETCH asg_details into g_old_asg_rec;
  IF asg_details%NOTFOUND THEN
    CLOSE asg_details;
    hr_utility.trace('no rows in asg_details');
  ELSE
    CLOSE asg_details;
  END IF;
  --
  IF g_debug THEN
    hr_utility.set_location( 'Leaving ' || g_package || l_proc, 50);
  END IF;
end pre_update_bundle;
-----------------------------------------------------------------------------
procedure key_delrec(
   p_del_mode     varchar2,
   p_val_st_date     date,
   p_eff_st_date     date,
   p_eff_end_date    date,
   p_pd_os_id     number,
   p_per_sys_st      varchar2,
   p_ass_id    number,
   p_grd_id    number,
   p_sp_ceil_st_id      number,
   p_ceil_seq     number,
   p_per_id    number,
   p_sess_date    date,
   p_new_end_date    IN OUT NOCOPY date,
   p_val_end_date    date,
   p_pay_id    number,
   p_pay_basis_id number --fix for bug 4764140
   )is
   l_new_end_date    date;
   l_returned_warning   varchar2(80);
   l_re_entry_point  number;
--
l_proc            varchar2(10) :=  'key_delrec';
--
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

   --
   -- These checks are also included in the FND_PRE_DELETE trigger to
   -- ensure the checks are also done at commit time.
   --
   -- Note that l_new_end_date is ignored, even if it were to be changed
   -- as if the validation fails, we do not want this value to be
   -- changed.
   --
   if p_del_mode in ('FUTURE_CHANGE', 'DELETE_NEXT_CHANGE') then
      --
      -- CHECK_TERM_BY_POS, upd_mode = null
      --
      l_re_entry_point  := 999;
      per_assignments_f3_pkg.update_and_delete_bundle(
         p_del_mode,
         p_val_st_date,
         p_eff_st_date,
         p_eff_end_date,
         p_pd_os_id,
         p_per_sys_st,
         p_ass_id,
         p_val_end_date,
         null,
         p_del_mode,
         p_sess_date,
         p_pay_id,
         p_grd_id,
         p_sp_ceil_st_id,
         p_ceil_seq,
         l_new_end_date,
         l_returned_warning,
         l_re_entry_point,
         'Y',
         p_pay_basis_id);--fix for bug 4764140
      --
      -- CHECK_SPP_AND_CEIL, upd_mode = null
      --
      l_re_entry_point  := 3;
      per_assignments_f3_pkg.update_and_delete_bundle(
         p_del_mode,
         p_val_st_date,
         p_eff_st_date,
         p_eff_end_date,
         p_pd_os_id,
         p_per_sys_st,
         p_ass_id,
         p_val_end_date,
         null,
         p_del_mode,
         p_sess_date,
         p_pay_id,
         p_grd_id,
         p_sp_ceil_st_id,
         p_ceil_seq,
         l_new_end_date,
         l_returned_warning,
         l_re_entry_point,
         'Y',
         p_pay_basis_id);--fix for bug 4764140
      --
   elsif p_del_mode = 'ZAP' then
  IF g_debug THEN
    hr_utility.set_location( g_package || l_proc, 10);
  END IF;
      real_del_checks(
         p_pd_os_id,
         p_ass_id,
         p_per_id,
         p_del_mode,
            p_sess_date,
            p_per_sys_st,
               p_val_st_date,
            p_new_end_date,
            p_val_end_date,
            p_pay_id,
         p_eff_st_date,
         p_eff_end_date,
            p_grd_id,
         p_sp_ceil_st_id,
         p_ceil_seq,
         p_pay_basis_id);--fix for bug 4764140
   end if;
   --
  IF g_debug THEN
    hr_utility.set_location( 'Leaving ' || g_package || l_proc, 10);
  END IF;
end key_delrec;
-----------------------------------------------------------------------------
procedure pre_delete(
   p_del_mode     varchar2,
   p_val_st_date     date,
   p_eff_st_date     date,
   p_eff_end_date    date,
   p_pd_os_id     number,
   p_per_sys_st      varchar2,
   p_ass_id    number,
   p_sess_date    date,
   p_new_end_date    IN OUT NOCOPY date,
   p_val_end_date    date,
   p_pay_id    number,
   p_grd_id    number,
   p_sp_ceil_st_id      number,
   p_ceil_seq     number,
   p_per_id    number,
   p_prim_flag    varchar2,
   p_prim_change_flag   IN OUT NOCOPY varchar2,
   p_new_prim_flag      IN OUT NOCOPY varchar2,
   p_re_entry_point  IN OUT NOCOPY number,
   p_returned_warning   IN OUT NOCOPY varchar2,
   p_cancel_atd      IN OUT NOCOPY date,
        p_cancel_lspd      IN OUT NOCOPY date,
        p_reterm_atd    IN OUT NOCOPY date,
        p_reterm_lspd      IN OUT NOCOPY date,
   p_prim_date_from  IN OUT NOCOPY date,
   p_new_prim_ass_id IN OUT NOCOPY number,
   p_row_id    varchar2,
   p_s_pos_id     IN OUT NOCOPY number,
   p_s_ass_num    IN OUT NOCOPY varchar2,
   p_s_org_id     IN OUT NOCOPY number,
   p_s_pg_id      IN OUT NOCOPY number,
   p_s_job_id     IN OUT NOCOPY number,
   p_s_grd_id     IN OUT NOCOPY number,
   p_s_pay_id     IN OUT NOCOPY number,
   p_s_def_code_comb_id IN OUT NOCOPY number,
   p_s_soft_code_kf_id  IN OUT NOCOPY number,
   p_s_per_sys_st    IN OUT NOCOPY varchar2,
   p_s_ass_st_type_id   IN OUT NOCOPY number,
   p_s_prim_flag     IN OUT NOCOPY varchar2,
   p_s_sp_ceil_step_id  IN OUT NOCOPY number,
   p_s_pay_bas    IN OUT NOCOPY varchar2,
   p_pay_basis_id number ) is --fix for bug 4764140

        --
    -- Start of Fix for Bug 2820230
    --
    -- Declare Cursor.

    cursor csr_grade_step is
          select spp.placement_id, spp.object_version_number ,step_id, spp.effective_end_date
          from per_spinal_point_placements_f  spp
          where spp.assignment_id = p_ass_id
            and p_val_st_date between spp.effective_start_date
                                           and spp.effective_end_date;

    -- Declare Local Variables
        l_placement_id number;
    l_object_version_number number;
    l_step_id number ;
    l_spp_end_date date ;
    l_max_spp_date date ;
    l_datetrack_mode varchar2(30);
    l_effective_start_date date;
    l_effective_end_date date;
    --
    --  End of Fix for bug 2820230
    --
   l_new_end_date    date;
   l_show_cand_prim_assgts varchar2(1);
  --
  -- Payroll Object Group functionality. Call to pay_pog_all_assignments_pkg
  -- requires old assignment values, so using cursor to populate record with
  -- the required values.
  --
  cursor asg_details(p_asg_id number
                    ,p_eff_date date)
  is
  select assignment_id
  ,effective_start_date
  ,effective_end_date
  ,business_group_id
  ,recruiter_id
  ,grade_id
  ,position_id
  ,job_id
  ,assignment_status_type_id
  ,payroll_id
  ,location_id
  ,person_referred_by_id
  ,supervisor_id
  ,special_ceiling_step_id
  ,person_id
  ,recruitment_activity_id
  ,source_organization_id
  ,organization_id
  ,people_group_id
  ,soft_coding_keyflex_id
  ,vacancy_id
  ,pay_basis_id
  ,assignment_sequence
  ,assignment_type
  ,primary_flag
  ,application_id
  ,assignment_number
  ,change_reason
  ,comment_id
  ,null
  ,date_probation_end
  ,default_code_comb_id
  ,employment_category
  ,frequency
  ,internal_address_line
  ,manager_flag
  ,normal_hours
  ,perf_review_period
  ,perf_review_period_frequency
  ,period_of_service_id
  ,probation_period
  ,probation_unit
  ,sal_review_period
  ,sal_review_period_frequency
  ,set_of_books_id
  ,source_type
  ,time_normal_finish
  ,time_normal_start
  ,bargaining_unit_code
  ,labour_union_member_flag
  ,hourly_salaried_code
  ,request_id
  ,program_application_id
  ,program_id
  ,program_update_date
  ,ass_attribute_category
  ,ass_attribute1
  ,ass_attribute2
  ,ass_attribute3
  ,ass_attribute4
  ,ass_attribute5
  ,ass_attribute6
  ,ass_attribute7
  ,ass_attribute8
  ,ass_attribute9
  ,ass_attribute10
  ,ass_attribute11
  ,ass_attribute12
  ,ass_attribute13
  ,ass_attribute14
  ,ass_attribute15
  ,ass_attribute16
  ,ass_attribute17
  ,ass_attribute18
  ,ass_attribute19
  ,ass_attribute20
  ,ass_attribute21
  ,ass_attribute22
  ,ass_attribute23
  ,ass_attribute24
  ,ass_attribute25
  ,ass_attribute26
  ,ass_attribute27
  ,ass_attribute28
  ,ass_attribute29
  ,ass_attribute30
  ,title
  ,object_version_number
  ,contract_id
  ,establishment_id
  ,collective_agreement_id
  ,cagr_grade_def_id
  ,cagr_id_flex_num
  ,notice_period
  ,notice_period_uom
  ,employee_category
  ,work_at_home
  ,job_post_source_name
  ,posting_content_id
  ,period_of_placement_date_start
  ,vendor_id
  ,vendor_employee_number
  ,vendor_assignment_number
  ,assignment_category
  ,project_title
  ,applicant_rank
  ,grade_ladder_pgm_id
  ,supervisor_assignment_id
  ,vendor_site_id
  ,po_header_id
  ,po_line_id
  ,projected_assignment_end
  from per_all_assignments_f
  where assignment_id = p_asg_id
  and   p_eff_date between effective_start_date
                       and effective_end_date;
  --
begin
hr_utility.set_location('per_assignments_f2_pkg.pre_delete',1);
   --
   -- Once again ignore l_new_end_date, even if it changes value, as
   -- the change should not be made if the validation fails (and if it
   -- succeeds then the record will be deleted anyway).
   --
   l_new_end_date := p_new_end_date;
   --
   if p_re_entry_point = -1 then
      goto RE_ENTRY_POINT_MINUS_1;
   end if;
   --
   get_save_fields(
      p_row_id,
      p_s_pos_id,
      p_s_ass_num,
      p_s_org_id,
      p_s_pg_id,
      p_s_job_id,
      p_s_grd_id,
      p_s_pay_id,
      p_s_def_code_comb_id,
      p_s_soft_code_kf_id,
      p_s_per_sys_st,
      p_s_ass_st_type_id,
      p_s_prim_flag,
      p_s_sp_ceil_step_id,
      p_s_pay_bas);
   --
   if p_del_mode in ('FUTURE_CHANGE', 'DELETE_NEXT_CHANGE') then
      --
      -- Call bundle if there is a warning then simply return to
      -- C-S calling routine with warning and code re-entry point.
      -- If warning accepted then re-enter this proc with the
      -- later re-entry point and continue checking further down
      -- update_and_delete_bundle's code.
      --
      -- N.B. This is the only point in whuch the p_new_end_date is
      --      passed as an IN OUT parameter. The value may change
      --      and the new value is required here
      --
 hr_utility.set_location('per_assignments_f2_pkg.pre_delete',2);



      per_assignments_f3_pkg.update_and_delete_bundle(
         p_del_mode,
         p_val_st_date,
         p_eff_st_date,
         p_eff_end_date,
         p_pd_os_id,
         p_per_sys_st,
         p_ass_id,
         p_val_end_date,
         null,
         p_del_mode,
         p_sess_date,
         p_pay_id,
         p_grd_id,
         p_sp_ceil_st_id,
         p_ceil_seq,
         p_new_end_date,
         p_returned_warning,
         p_re_entry_point,
         'N' ,
         p_pay_basis_id);--fix for bug 4764140
      --
      if p_returned_warning is not null then
         return;
      end if;
      --
   elsif p_del_mode = 'ZAP' then
      --
hr_utility.set_location('per_assignments_f2_pkg.pre_delete',20);

      real_del_checks(
         p_pd_os_id,
         p_ass_id,
         p_per_id,
         p_del_mode,
            p_sess_date,
            p_per_sys_st,
               p_val_st_date,
            l_new_end_date,
            p_val_end_date,
            p_pay_id,
                        p_eff_st_date,
                        p_eff_end_date,
                        p_grd_id,
                        p_sp_ceil_st_id,
                        p_ceil_seq,
         p_pay_basis_id);--fix for bug 4764140
   end if;
   --
hr_utility.set_location('per_assignments_f2_pkg.pre_delete',40);
   per_assignments_f3_pkg.check_future_primary(
      p_del_mode,
            p_val_st_date,
         p_prim_flag,
            p_eff_st_date,
         p_s_prim_flag,
         p_prim_change_flag,
            p_new_prim_flag,
            p_ass_id,
            p_eff_end_date,
         p_pd_os_id,
      l_show_cand_prim_assgts,
      p_prim_date_from,
      p_new_prim_ass_id);
   --
hr_utility.trace('Check_Future_Primary Date'||
         to_char(p_prim_date_from,'DD-MON-YYYY'));
--
   if l_show_cand_prim_assgts = 'Y' then
      --
      -- Need to do a show_lov on client so
      -- return special warning to be interpreted
      -- on client.
      --
      p_returned_warning   := 'SHOW_LOV';
      p_re_entry_point  := -1;
      return;
   end if;
   --
<<RE_ENTRY_POINT_MINUS_1>>
hr_utility.set_location('per_assignments_f2_pkg.pre_delete',50);
   --
   -- Now check the changing of term_assign's with relation to it's
   -- impact on element entries (G255).
   --
        per_assignments_f3_pkg.test_for_cancel_term(
                p_ass_id,
                p_val_st_date,
                p_val_end_date,
                p_del_mode,
                p_per_sys_st,
                p_s_per_sys_st,
      p_cancel_atd,
         p_cancel_lspd,
         p_reterm_atd,
         p_reterm_lspd);
   --
   p_re_entry_point  := 0;
        --
        -- For bug 424224. p_returned_warning is set to null on exit, so
        -- LOV is only displayed once.
        --
        p_returned_warning := null;
  --
hr_utility.set_location('per_assignments_f2_pkg.pre_delete',60);
  OPEN asg_details(p_ass_id, p_sess_date);
  FETCH asg_details into g_old_asg_rec;
  IF asg_details%NOTFOUND THEN
    CLOSE asg_details;
    hr_utility.trace('no rows in asg_details');
  ELSE
    CLOSE asg_details;
  END IF;
  --
hr_utility.set_location(' leaving per_assignments_f2_pkg.pre_delete',70);
end pre_delete;
-----------------------------------------------------------------------------
END PER_ASSIGNMENTS_F2_PKG;

/
