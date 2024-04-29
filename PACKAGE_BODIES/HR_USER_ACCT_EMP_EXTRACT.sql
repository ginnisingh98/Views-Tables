--------------------------------------------------------
--  DDL for Package Body HR_USER_ACCT_EMP_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_USER_ACCT_EMP_EXTRACT" AS
/* $Header: hrempext.pkb 120.3.12010000.3 2009/09/24 07:23:30 pthoonig ship $*/
--
--
-- |--------------------------------------------------------------------------|
-- |--< PRIVATE GLOBAL VARIABLES >--------------------------------------------|
-- |--------------------------------------------------------------------------|
  g_data_pump_create_user    constant varchar2(30) := 'hrdpp_create_user_acct';
  g_data_pump_upd_user       constant varchar2(30) := 'hrdpp_update_user_acct';
  g_commit_limit             constant number := 20;
  l_commit_count             number default 0;
  g_package                  constant varchar2(72) :='hr_user_acct_emp_extract';
  g_dp_str                   constant varchar2(15) :='~!@UAEEP@!~';
  g_dp_ins_str               constant varchar2(25) := 'SS_' || g_dp_str || '_INS';
  g_dp_upd_str               constant varchar2(25) := 'SS_' || g_dp_str || '_UPD';


--
/*
||===========================================================================
|| PROCEDURE: run_process
||----------------------------------------------------------------------------
||
|| Description:
||     This procedure is invoked by Concurrent Manager to extract
||     employees based on input parameters passed.
||
|| Pre-Conditions:
||     Employee Data must exist on the database.
||
|| Input Parameters:
||
|| Output Parameters:
||
|| In out nocopy Parameters:
||
|| Post Success:
||      Selected employees are written to hr_pump_batch_lines table.
||
|| Post Failure:
||     Raise exception.
||
|| Access Status:
||     Public
||
||=============================================================================
*/
  PROCEDURE run_process (
     errbuf                     out nocopy varchar2
    ,retcode                    out nocopy number
    ,p_batch_name               in hr_pump_batch_headers.batch_name%TYPE
    ,p_date_from                in varchar2 default null
    ,p_date_to                  in varchar2 default null
    ,p_business_group_id        in per_all_people_f.business_group_id%type
    ,p_single_org_id            in per_organization_units.organization_id%type
                                   default null
    ,p_organization_structure_id in
                   per_organization_structures.organization_structure_id%type
                                   default null
    ,p_org_structure_version_id in
                   per_org_structure_versions.org_structure_version_id%type
                                   default null
    ,p_parent_org_id            in per_organization_units.organization_id%type
                                   default null
    ,p_run_type                 in varchar2
  )
  IS
--
--
  CURSOR lc_check_if_batch_name_used
  IS
  SELECT  'Y'
  FROM    hr_pump_batch_headers
  WHERE   upper(batch_name) = upper(p_batch_name);
--

  CURSOR lc_get_bg_name
  IS
  SELECT name
  FROM   hr_all_organization_units
  WHERE  business_group_id = p_business_group_id
  AND    organization_id = p_business_group_id;
--
  CURSOR      lc_get_org_id
  IS
  SELECT      organization_id_child
  FROM        per_org_structure_elements
  CONNECT BY  organization_id_parent = prior organization_id_child
  AND         org_structure_version_id = prior org_structure_version_id
  START WITH  organization_id_parent = p_parent_org_id
  AND         org_structure_version_id = p_org_structure_version_id
  UNION
  SELECT      p_parent_org_id
  FROM        SYS.DUAL;
--

CURSOR      lc_get_ex_emp_per_type_id
  IS
  SELECT      person_type_id
  FROM        per_person_types
  WHERE       business_group_id = p_business_group_id
  AND        SYSTEM_PERSON_TYPE IN ( 'EMP','EMP_APL')
  AND         active_flag = 'Y';

--
  CURSOR      lc_get_emp_per_type_id
  IS
  SELECT      person_type_id
  FROM        per_person_types
  WHERE       business_group_id = p_business_group_id
  AND         (SYSTEM_PERSON_TYPE = 'EMP'
               OR
               SYSTEM_PERSON_TYPE = 'EMP_APL')
  AND         active_flag = 'Y';
--
  CURSOR      lc_get_asg_status_type_id (p_per_sys_status  in varchar2)
  IS
  SELECT      ast.assignment_status_type_id
  FROM        per_assignment_status_types    ast
  WHERE       nvl(ast.business_group_id, p_business_group_id)
              = p_business_group_id
  AND         ast.active_flag = 'Y'
  AND         ast.per_system_status = p_per_sys_status;


  l_proc      varchar2(2000) := 'hr_user_acct_emp_extract.run_process';
  l_batch_name_found         varchar2(1) default null;
  l_data_pump_pkg_name1      varchar2(30) default null;
  l_data_pump_pkg_name2      varchar2(30) default null;
  l_date_from                date default null;
  l_date_from_char                varchar2(2000) default null;
  l_date_to                  date default null;
  l_date_to_char                  varchar2(2000) default null;
  l_basic_sql_clause         varchar2(2000) default null;
  l_org_matching             varchar2(5000) default null;
  l_new_hires_matching       varchar2(10000) default null;
  l_terminated_ee_matching   varchar2(10000) default null;
  l_all_ee_matching          varchar2(10000) default null;
  l_sql_clause               varchar2(32000) default null;
  l_group_by_clause          varchar2(500) default null;
  l_order_by_clause          varchar2(200) default null;
  l_inactivate_user_sql_clause  varchar2(32000) default null;
  l_temp                     number default null;
  l_date_temp                date default null;
  l_batch_id                 number default null;
  l_dynamic_cursor_id        integer := 0;
  l_index                    integer :=0;
  l_rows                     integer :=0;
  l_new_user_count           number :=0;
  l_inactivate_user_count    number :=0;
  l_person_id                number default null;
  l_effective_start_date     date default null;
  l_effective_end_date       date default null;
  l_hire_date                date default null;
  l_term_date                date default null;
  l_bg_name                  hr_all_organization_units.name%type default null;
  l_commit_count             number default 0;
  l_org_id_list              varchar2(32000);
  l_per_type_id_list         varchar2(2000);
  l_asg_status_type_id       number;
  l_asg_status_type_clause   varchar2(200);
  l_msg                      varchar2(2000) default null;
  l_asg_eff_start_date       date default null;
  l_asg_eff_end_date         date default null;
  l_asg_id                   number default null;

  l_prev_per_id              number default null;
  l_prev_eff_start_date      date default null;
  l_prev_eff_end_date        date default null;
  l_prev_asg_id              number default null;
  l_prev_asg_eff_start_date  date default null;
  l_prev_asg_eff_end_date    date default null;
  l_prev_hire_date           date default null;
  l_prev_term_date           date default null;
  l_asg_status_type_id_list  varchar2(2000);

  l_unique_str               varchar2(200);
--
BEGIN
  --
 hr_utility.set_location('Entering ' || l_proc, 10);

  IF p_batch_name is NULL
  THEN
     fnd_message.set_name('PER', 'HR_BATCH_NAME_NOT_SPECIFIED');
     fnd_message.raise_error;
  ELSE
     OPEN lc_check_if_batch_name_used;
     FETCH lc_check_if_batch_name_used into l_batch_name_found;
     IF lc_check_if_batch_name_used%NOTFOUND
     THEN
        CLOSE lc_check_if_batch_name_used;
     ELSE
        CLOSE lc_check_if_batch_name_used;
        fnd_message.set_name('PER', 'HR_BATCH_NAME_ALREADY_EXISTS');
        fnd_message.raise_error;
     END IF;
  END IF;
  --
  hr_utility.set_location('run_type=' || p_run_type, 20);

  -- Check run type
  -----------------------------------------------------------------------------
  -- NOTE:
  -- When p_run_type is g_cr_user_new_hires, g_cr_user_all_emp,
  -- l_data_pump_pkg_name1 contains a value, l_data_pump_pkg_name2 will be
  -- null.
  -- When p_run_type is gv_inactivate_user , then l_data_pump_pkg_name2
  -- contains a value, l_data_pump_pkg_name1 will be null.
  -- When p_run_type is gv_cr_n_inact_user, then both l_data_pump_pkg_name1
  -- and l_data_pump_pkg_name2 contain a value.
  -----------------------------------------------------------------------------
  IF p_run_type = hr_user_acct_utility.g_cr_user_new_hires OR
     p_run_type = hr_user_acct_utility.g_cr_user_all_emp
  THEN
     l_data_pump_pkg_name1 := g_data_pump_create_user;
  ELSIF p_run_type = hr_user_acct_utility.g_inactivate_user
  THEN
     l_data_pump_pkg_name2 := g_data_pump_upd_user;
  ELSE  -- create and inactivate user accounts
     l_data_pump_pkg_name1 := g_data_pump_create_user;
     l_data_pump_pkg_name2 := g_data_pump_upd_user;
  END IF;

--Get bg name
  OPEN lc_get_bg_name;
  FETCH lc_get_bg_name into l_bg_name;
  IF lc_get_bg_name%NOTFOUND
  THEN
     close lc_get_bg_name;
     l_bg_name := null;
  ELSE
     close lc_get_bg_name;
  END IF;
--
  -- Convert varchar2 dates to date datatype
  -- 1) Convert format
  -- 2) Remove time component
  IF p_date_from is NOT NULL
  THEN
	-- For R11.5, the FND date format is 'YYYY/MM/DD HH24:MI:SS'.
     l_date_from := to_date(p_date_from, fnd_date.canonical_dt_mask);
     l_date_from := trunc(l_date_from);
  ELSE
     l_date_from := trunc(sysdate);
  END IF;
  --
  IF p_date_to is NOT NULL
  THEN
     l_date_to   := to_date(p_date_to, fnd_date.canonical_dt_mask);
     l_date_to   := trunc(l_date_to);
  ELSE
     -- Default date_to to end of time so that we can allow future date
     -- execution.  For example, date_from is a future date with respective to
     -- sysdate.  Hence, setting date_to to sysdate in this case will cause
     -- date_to smaller than the date_from.
     l_date_to := trunc(hr_api.g_eot);
  END IF;
  --
  -- Check if Date_from is greater than date_to
  IF l_date_to < l_date_from
  THEN
     fnd_message.set_name('PER', 'PER_7003_ALL_DATE_FROM_TO');
     fnd_message.raise_error;
  END IF;
--
  -- Now, convert the date to varchar2 format for use in dynamic sql statement.
  -- In R11.5, use the FND standard date format, which is 'YYYY/MM/DD'
  l_date_from_char := to_char(l_date_from, fnd_date.canonical_mask);
  l_date_to_char := to_char(l_date_to, fnd_date.canonical_mask);
--
-------------------------------------------------------------------------------
-- NOTE: If users enter Organization Hierarchy and Version, then the
--       p_single_org_id is ignored.  Organization Hierarchy and Single Org
--       are mutually exclusive.
-------------------------------------------------------------------------------
  IF p_org_structure_version_id IS NOT NULL AND
     p_parent_org_id IS NOT NULL
  THEN
     FOR get_hierarchy_org_id in lc_get_org_id
     LOOP
        l_org_id_list := l_org_id_list ||
                         get_hierarchy_org_id.organization_id_child || ',';
     END LOOP;
     --
     -- Remove the last comma, -1 in the instr function means to scan from
     -- right to left for the 1st occurrence of the comma.
     l_org_id_list := substr(l_org_id_list, 1,
                                instr(l_org_id_list, ',', -1, 1) - 1);
     --
     l_org_matching :=
       ' AND     paf.organization_id  in (' ||
       l_org_id_list || ')';
  ELSIF
     p_parent_org_id IS NOT NULL
  THEN
     l_org_matching :=
       ' AND     paf.organization_id = ' ||
        to_char(p_parent_org_id);
  --
  ELSIF p_single_org_id IS NOT NULL
  THEN
     l_org_matching :=
       ' AND     paf.organization_id = ' ||
        to_char(p_single_org_id);
  END IF;
--
--
-- Build a list for ACTIVE assignment status type id.
  IF upper(p_run_type) = hr_user_acct_utility.g_cr_user_new_hires OR
     upper(p_run_type) = hr_user_acct_utility.g_cr_n_inact_user OR
     upper(p_run_type) = hr_user_acct_utility.g_cr_user_all_emp
  THEN
     FOR get_asg_status_type_id in lc_get_asg_status_type_id
                             (p_per_sys_status => 'ACTIVE_ASSIGN')
     LOOP
        l_asg_status_type_id_list := l_asg_status_type_id_list ||
          get_asg_status_type_id.assignment_status_type_id || ',';
     END LOOP;

     -- Remove the last comma, -1 in the instr function means to scan from
     -- right to left for the 1st occurrence of the comma.
     l_asg_status_type_id_list := substr(l_asg_status_type_id_list, 1,
                              instr(l_asg_status_type_id_list, ',', -1, 1) - 1);
  END IF;
  --
  --

  IF upper(p_run_type) = hr_user_acct_utility.g_cr_user_new_hires OR
     upper(p_run_type) = hr_user_acct_utility.g_cr_n_inact_user
  THEN
     l_asg_status_type_clause := ' AND paf.assignment_status_type_id in ( ' ||
                                l_asg_status_type_id_list || ')';
     --
     l_basic_sql_clause :=
        'SELECT  DISTINCT ppf.person_id
                ,ppf.effective_start_date
                ,ppf.effective_end_date
                ,paf.assignment_id
                ,paf.effective_start_date
                ,paf.effective_end_date
                ,ppos.date_start    hire_date
         FROM    per_periods_of_service  ppos
                ,per_people_f            ppf
                ,per_assignments_f       paf
         WHERE   ppf.person_id = paf.person_id
         and      paf.primary_flag = ''Y''
         AND     ppf.business_group_id + 0 = ' ||
                 to_char(p_business_group_id);


     -- Select those new hires whose per_periods_of_service.date_start is
     -- between the p_date_from and p_date_to dates
     l_new_hires_matching :=
       ' AND (ppf.effective_start_date >= to_date(''' ||
            l_date_from_char ||
            ''', ''' || fnd_date.canonical_mask || ''')' ||
            ' and ppf.effective_start_date <= to_date(''' ||
            l_date_to_char ||
            ''', ''' || fnd_date.canonical_mask || ''')' ||
            ' and ppf.effective_end_date >= to_date(''' ||
            l_date_to_char ||
            ''', ''' || fnd_date.canonical_mask || '''))' ||
       ' AND (paf.effective_start_date >= to_date(''' ||
            l_date_from_char ||
            ''', ''' || fnd_date.canonical_mask || ''')' ||
            ' and paf.effective_end_date >= to_date(''' ||
            l_date_to_char ||
            ''', ''' || fnd_date.canonical_mask || '''))' ||
       ' AND  ((ppos.date_start >= to_date(''' ||
        l_date_from_char || ''', ''' ||
         fnd_date.canonical_mask || ''')' ||
       ' AND ppos.date_start <= to_date(''' ||
        l_date_to_char || ''', ''' ||
         fnd_date.canonical_mask || '''))' ||
--
-- ---------------------------------------------------------------------------
--  The following is commented out.  If we need to change the termination_date
--  comparison, we can re-evaluate the comparsion.
     ' AND nvl(ppos.actual_termination_date, to_date(''' ||
      l_date_to_char || ''', ''' ||
       fnd_date.canonical_mask || '''))' ||
     ' <= to_date(''' || l_date_to_char ||
     ''', ''' || fnd_date.canonical_mask || '''))' ||
-- ---------------------------------------------------------------------------
--
--       ' AND ppos.actual_termination_date IS NULL)' ||
       ' AND ppos.person_id = ppf.person_id ' ||
       ' and paf.period_of_service_id = ppos.period_of_service_id ' ||
       ' AND paf.assignment_type = ''E'' ' ||         -- 4142819
       ' AND ppos.business_group_id + 0 = ' || to_char(p_business_group_id);

     l_sql_clause := l_basic_sql_clause || l_asg_status_type_clause;
     l_sql_clause := l_sql_clause || l_org_matching;
     l_sql_clause := l_sql_clause || l_new_hires_matching;
     l_order_by_clause := ' order BY ppf.person_id ,ppf.effective_start_date,'
			|| 'ppf.effective_end_date,paf.assignment_id';
    l_sql_clause := l_sql_clause ||l_order_by_clause;

  END IF;
--
  IF upper(p_run_type) = hr_user_acct_utility.g_cr_user_all_emp
  THEN
     -- For all employees, we want to select ppf.effective_start_date <=
     -- p_date_to and ppf.effective_end_date >= p_date_to.  This conforms to
     -- the selection logic in person search for "all employees"
     -- (see hrprresw.pkb process_search logic).
     --
     --        |             |             |
     --        |  <----------------> PerA  |
     --        |             |             |
     --        |       <-----------------------> PerB
     --        |             |             |
     --        | <----> PerC |             |
     --        |             |             |
     --        |             |   <----------------> PerD
     --        |             |             |
     --        X             Y             Z
     --                    date_from     date_to
     -- PerB and PerD will be selected but not PerA or PerC.
     --
     FOR get_emp_per_type_id_list in lc_get_emp_per_type_id
     LOOP
         l_per_type_id_list := l_per_type_id_list ||
                               get_emp_per_type_id_list.person_type_id || ',';
     END LOOP;
     --
     -- Remove the last comma, -1 in the instr function means to scan from
     -- right to left for the 1st occurrence of the comma.
     l_per_type_id_list := substr(l_per_type_id_list, 1,
                                instr(l_per_type_id_list, ',', -1, 1) - 1);
     --
     l_basic_sql_clause :=
        'SELECT  DISTINCT ppf.person_id
                ,ppf.effective_start_date
                ,ppf.effective_end_date
                ,paf.assignment_id
                ,paf.effective_start_date
                ,paf.effective_end_date
                ,ppos.date_start    hire_date
         FROM    per_periods_of_service  ppos
                ,per_people_f            ppf
                ,per_assignments_f       paf
         WHERE   ppf.person_id = paf.person_id
         and      paf.primary_flag = ''Y''
         and      paf.assignment_type=''E''
         AND     ppf.business_group_id + 0 = ' ||
                 to_char(p_business_group_id);
     --

     l_all_ee_matching :=
       ' AND ppf.person_type_id in (' || l_per_type_id_list || ')' ||
       ' AND (ppf.effective_start_date <= to_date(''' ||
            l_date_to_char ||
            ''', ''' || fnd_date.canonical_mask || ''')' ||
            ' and ppf.effective_end_date >= to_date(''' ||
            l_date_to_char ||
            ''', ''' || fnd_date.canonical_mask || '''))' ||
       ' AND (paf.effective_start_date <= to_date(''' ||
            l_date_to_char ||
            ''', ''' || fnd_date.canonical_mask || ''')' ||
            ' and paf.effective_end_date >= to_date(''' ||
            l_date_to_char ||
            ''', ''' || fnd_date.canonical_mask || '''))' ||
       ' AND  (ppos.date_start <= to_date(''' ||
        l_date_to_char || ''', ''' ||  fnd_date.canonical_mask || ''')' ||
       ' AND nvl(ppos.actual_termination_date, to_date(''' ||
        l_date_to_char || ''', ''' ||  fnd_date.canonical_mask || '''))' ||
       ' >= to_date(''' || l_date_to_char ||
       ''', ''' || fnd_date.canonical_mask || '''))' ||
       ' AND ppos.person_id = ppf.person_id ' ||
       ' and paf.period_of_service_id = ppos.period_of_service_id ' ||
       ' AND ppos.business_group_id + 0 =  ' || to_char(p_business_group_id);
     --
     l_sql_clause := l_basic_sql_clause || l_asg_status_type_clause;
     l_sql_clause := l_sql_clause || l_org_matching;
     l_sql_clause := l_sql_clause || l_all_ee_matching;
  END IF;
--
  IF upper(p_run_type) = hr_user_acct_utility.g_inactivate_user OR
     upper(p_run_type) = hr_user_acct_utility.g_cr_n_inact_user
     -- For terminated ee, we want to select ppos.actual_termination_date 1 day
     -- before the per_all_people_f.effective_start_date where
     -- ppf.effective_start_date >= p_date_from and ppf.effective_end_date >=
     -- p_date_to and ppf.person_type_id in system_person_type of 'EX_EMP' or
     -- 'EX_EMP_APL'.
     --
     --        |             |             |
     --        |  <----------------> PerA  |
     --        |             |             |
     --        |             |<-----> PerB |
     --        |             |             |
     --        | <----> PerC |             |
     --        |             |             |
     --        X             Y             Z
     --                    date_from     date_to
     -- PerA and PerB will be selected but not PerC.
     --
     -- We want to select the max(actual_termination_date) to cover cases
     -- where an employee has multiple periods of service like the following:
     --
     --    PERSON_ID  DATE_STAR ACTUAL_TERM_DATE
     --    ---------- --------- ----------------
     --          2525 06-FEB-00        08-FEB-00
     --          2525 27-AUG-99        20-JAN-00
     --
     -- If the selection date range is 01-Jan-1999 and 10-Feb-2000, then we
     -- want the latest termination date record 08-Feb-00 to be returned. Hence,
     -- we want to drive off from the max(actual_termination_date) of the
     -- per_periods_of_service.
     --
     -- We also need to join to per_people_f.person_type_id where the
     -- person_type_id has a system_person_type of either 'EX_EMP' or
     -- 'EX_EMP_APL'.  Otherwise, we'll get 2 records returned with the same
     -- person_id as in the following example:
     --
     --  PERSON_ID PPF EFF START PPF EFF END PERSON_TYPE_ID
     --  --------- ------------- ----------- --------------
     --       2525     27-AUG-99   20-JAN-00 72 (EMP)
     --       2525     21-JAN-00   05-FEB-00 75 (EX_EMP)
     --       2525     06-FEB-00   08-FEB-00 72 (EMP, rehired)
     --       2525     09-FEB-00   31-DEC-12 75 (EX_EMP)
     --
     --  We need to compare the ppf.effective_start_date >= date_range_low_end
     --  and ppf.effective_end_date >= date_range_high_end (this is NOT a
     --  mistake as you can see from the 4th record in the above that the
     --  person record for an EX_EMP has the end-of-time in the effective_end
     --  date), we want to select the latest EX_EMP person record.
     --
     --  In R11.5, for assignments, the assignment status type varies depending
     --  on whether the Actual Termination Date and Final Process Date are the
     --  same or not.
     --  If the Actual Termination Date and Final Process Date are the same
     --  same,then no period as TERM_ASSIGN is present in the assignments table.
     --  If the Actual Termination Date and Final Process Date are different,
     --  then the assignment has a status of TERM_ASSIGN in the period between
     --  Actual Termination Date and Final Process Date are.
     --  For example:
     --      Date From = 01-Jan-2000
     --      Date To: 31-May-2000
     --      Run Type: Inactivate User Account
     --      Actual Termination Date = 18-Apr-2000
     --      Final Process Date = 18-Apr-2000
     --
     --  1) PER_ALL_ASSIGNMENTS_F:
     --     select assignment_id, effective_start_date, effective_end_date,
     --            assignment_status_type_id, assignment_type
     --     from   per_all_assignments_f
     --     where  person_id = 3;
     --
     --     ASSIGNMENT_ID EFF START EFF END   ASG_STATUS_TYPE_ID ASG_TYPE
     --     ------------- --------- --------- ------------------ --------
     --                 2 01-JAN-90 18-APR-00  1 (ACTIVE_ASSIGN) E (employee)
     --              3432 19-APR-00 31-DEC-12  1 (ACTIVE_ASSIGN) B (benefits)
     --
     --  2) PER_PERIODS_OF_SERVICE
     --     select date_start, actual_termination_date, final_process_date
     --     from   per_periods_of_service
     --     where  person_id = 3;
     --
     --     DATE_STAR ACTUAL_TE FINAL_PRO
     --     --------- --------- ---------
     --     01-JAN-90 18-APR-00 18-APR-00
     --
     -- So, there won't be a 'TERM_ASSIGN' status if ACTUAL_TERMINATION_DATE and
     -- FINAL_PROCESS_DATE are the same.  However, if the FINAL_PROCESS_DATE is
     -- null or different from the ACTUAL_TERMINATION_DATE, then there will be
     -- a 'TERM_ASSIGN' status between the period of ACTUAL_TERMINATION_DATE and
     -- FINAL_PROCESS_DATE.
     -- Hence, we need to select the assignment record which has an
     -- effective_end_date = to the ppos.actual_termination_date.  Since there
     -- can only be 1 record for any given day, we don't need to compare the
     -- effective_start_date and we don't want to limit the query to
     -- assignment_status_type_id = 'ACTIVE_ASSIGN' because an employee can
     -- be in a 'SUSPEND_ASSIGN' status before he got terminated.
     -- But, we want to select only the primary assignment.
     --------------------------------------------------------------------------
  THEN
     l_basic_sql_clause :=
        'SELECT  ppf.person_id
                ,ppf.effective_start_date
                ,ppf.effective_end_date
                ,paf.assignment_id
                ,paf.effective_start_date
                ,paf.effective_end_date
                ,MAX(ppos.actual_termination_date) term_date
         FROM    per_periods_of_service  ppos
                ,per_people_f            ppf
                ,per_assignments_f       paf
         WHERE   ppf.person_id = paf.person_id
         AND     paf.person_id = ppos.person_id
         AND     ppf.business_group_id + 0 = ' ||
                 to_char(p_business_group_id) ||
       ' AND     ppf.effective_end_date BETWEEN to_date(''' ||
                 l_date_from_char || ''', ''' ||  fnd_date.canonical_mask
			  || ''')'||
       ' AND  to_date(''' ||
                 l_date_to_char || ''', ''' ||  fnd_date.canonical_mask
			  || ''')' ||
       ' AND     paf.primary_flag = ''Y''';

     --

     FOR get_ex_emp_per_type_id_list in lc_get_ex_emp_per_type_id
     LOOP
         l_per_type_id_list := l_per_type_id_list ||
                              get_ex_emp_per_type_id_list.person_type_id || ',';
     END LOOP;
     --
     -- Remove the last comma, -1 in the instr function means to scan from
     -- right to left for the 1st occurrence of the comma.
     l_per_type_id_list := substr(l_per_type_id_list, 1,
                                instr(l_per_type_id_list, ',', -1, 1) - 1);
     --

   l_terminated_ee_matching :=
       ' AND ppf.person_type_id in (' || l_per_type_id_list || ')' ||
       ' AND ppos.actual_termination_date = ppf.effective_end_date ' ||
       ' AND ppos.person_id = ppf.person_id ' ||
       ' AND ppos.business_group_id + 0 = ' || to_char(p_business_group_id) ||
       ' AND paf.assignment_type = ''E'' ' || -- 4411293
       ' AND paf.effective_end_date = ppos.actual_termination_date ' ||
       ' AND ppos.actual_termination_date = '||
       ' (select max(actual_termination_date) from '||
       ' per_periods_of_service b '||
       ' where b.person_id=ppf.person_id '||
       ' and business_group_id + 0 = ' || to_char(p_business_group_id) ||
       ' and ppos.person_id= paf.person_id '||
       ' and b.actual_termination_date BETWEEN to_date(''' ||
                 l_date_from_char || ''', ''' ||  fnd_date.canonical_mask
			  || ''')'||
       ' AND  to_date(''' ||
                 l_date_to_char || ''', ''' ||  fnd_date.canonical_mask
			  || ''')' ||
     ' ) AND ppf.person_id not in( '||
     ' select a.person_id from per_all_people_f a,'||
     ' per_periods_of_service b'||
     ' where a.effective_start_date= b.date_start'||
     ' and a.person_id=b.person_id'||
     ' and a.business_group_id = b.business_group_id'||
     ' and b.actual_termination_date IS NULL '||
     ' and a.person_type_id in('||
     ' SELECT person_type_id'||
     ' FROM per_person_types'||
     ' WHERE business_group_id = ' || to_char(p_business_group_id) ||
     ' AND system_person_type IN (''EMP'',''EMP_APL'' )' ||
     ' AND active_flag = ''Y'' ))' ;
     --
     l_inactivate_user_sql_clause := l_basic_sql_clause;
     l_inactivate_user_sql_clause := l_inactivate_user_sql_clause ||
                                     l_org_matching;
     --
     l_group_by_clause := ' GROUP BY ppf.person_id, ppf.effective_start_date' ||
                          ', ppf.effective_end_date' ||
                          ', paf.assignment_id, paf.effective_start_date' ||
                          ', paf.effective_end_date';
     l_inactivate_user_sql_clause := l_inactivate_user_sql_clause ||
                                     l_terminated_ee_matching ||
                                     l_group_by_clause;
  END IF;
--
  -- Dynamic sql steps:
  -- ==================
  -- 1. Open dynamic sql cursor
  -- 2. Parse dynamic sql
  -- 3. Bind variables
  -- 4. Define the returning column
  -- 5. Execute sql
  -- 6. Fetch 1 row in buffer
  -- 7. Get 1 row from buffer
  -- 8. Close dynamic cursor
  --
  l_dynamic_cursor_id := dbms_sql.open_cursor;                        -- Step 1

  IF upper(p_run_type) = hr_user_acct_utility.g_cr_user_new_hires OR
     upper(p_run_type) = hr_user_acct_utility.g_cr_n_inact_user OR
     upper(p_run_type) = hr_user_acct_utility.g_cr_user_all_emp
  THEN
     BEGIN
     hr_utility.set_location('In executing create user dynamic sql..', 35);

     dbms_sql.parse(l_dynamic_cursor_id, l_sql_clause, dbms_sql.v7); -- Step 2
     -- ************************************************************************
     -- NOTE:If we retrieve extra column,need to set the l_index accordingly.
     -- ************************************************************************
     --
     l_index := 1;
     --
     -- Define the Person ID column
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_temp);
     --
     -- Now define Person record Effective Start Date
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_date_temp);
     --
     -- Now define Person record Effective End Date
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_date_temp);
     --
     -- Define the Assignment ID column
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_temp);
     --
     -- Now define Assignment record Effective Start Date
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_date_temp);
     --
     -- Now define Assignment record Effective End Date
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_date_temp);
     --
     -- Now define the Hire Date column
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_date_temp);
     --
     --
     EXCEPTION
       WHEN OTHERS THEN
         null;
     END;
     --
     l_new_user_count := 0;
     l_rows := dbms_sql.execute(l_dynamic_cursor_id);               -- Step 5
     --
     -- Initialize the prev fields before entering the loop
     l_prev_per_id := null;
     l_prev_eff_start_date := null;
     l_prev_eff_end_date := null;
     l_prev_asg_id := null;
     l_prev_asg_eff_start_date := null;
     l_prev_asg_eff_end_date := null;
     l_prev_hire_date := null;

     WHILE dbms_sql.fetch_rows(l_dynamic_cursor_id) > 0 LOOP         -- Step 6
       dbms_sql.column_value(l_dynamic_cursor_id, 1, l_person_id);
       dbms_sql.column_value(l_dynamic_cursor_id, 2, l_effective_start_date);
       dbms_sql.column_value(l_dynamic_cursor_id, 3, l_effective_end_date);
       dbms_sql.column_value(l_dynamic_cursor_id, 4, l_asg_id);
       dbms_sql.column_value(l_dynamic_cursor_id, 5, l_asg_eff_start_date);
       dbms_sql.column_value(l_dynamic_cursor_id, 6, l_asg_eff_end_date);
       dbms_sql.column_value(l_dynamic_cursor_id, 7, l_hire_date);
       --
       -- We only want to create the batch header when there is record retreived
       -- from the dynamic sql statement.  Otherwise, we won't create a header.
       IF l_batch_id IS NOT NULL
       THEN
          null;
       ELSE
          l_batch_id := hr_pump_utils.create_batch_header
                          (p_batch_name          => p_batch_name
                          ,p_business_group_name => l_bg_name);
       END IF;
       --
       -----------------------------------------------------------------------
       -- NOTE:
       --    Business Group Id is derived from the business group name saved in
       --    the hrdpp_pump_batch_headers table.  We do not need to pass
       --    p_business_group_id when inserting to batch lines record.
       -----------------------------------------------------------------------

       -----------------------------------------------------------------------
       -- NOTE:
       --  Need to compare the current extracted record with the previous
       --  one to prevent 1 person being written twice to hr_pump_batch_lines
       --  due to a future dated assignment changes.
       --  For example:
       --   Run Type = Create and Inactivate User Accounts
       --   Date From = 01-Jan-1999
       --   Date To = 08-May-2000
       --   Organization Hierarchy = XXXX Org Hierarchy
       --   Parent Organization = Marketing
       --   Organization ID covered in the hierarchy = 2,3,4,1025, 1026, 1027
       --
       --   Extracted records in hr_pump_batch_lines are:
       --
       --  PerID Per Start  Per End    Hire Dt    Asg ID Asg Start  Asg End
       --  ----- ---------- ---------- ---------- ------ ---------- ---------
       --  1182  2000/03/29 4712/12/31 2000/03/29 1222   2000/04/27 2000/10/26
       --  1182  2000/03/29 4712/12/31 2000/03/29 1222   2000/10/27 4712/12/31
       --
       --  The person and assignment info. are as follows:
       --                            Per  ASG                       ORG ASG
       --  PerID Per Start Per End   Type ID    Asg Start Asg End   ID  Stat
       --  ----- --------- --------- ---- ----- --------- --------- --- ----
       --  1182  29-MAR-00 31-DEC-12 26   1222  29-MAR-00 26-APR-00 4   1
       --  1182  29-MAR-00 31-DEC-12 26   1222  27-APR-00 31-DEC-12 4   1
       --
       --  From the above record information, two batch line records were
       --  written due to a future dated assignment change.
       --  Hence, we need to eliminate the 2nd extracted rec if the person_id,
       --  person effective_start_date, person effective_end_date and person
       --  type id are the same but only the assignment effective date are
       --  different.
       --
       -----------------------------------------------------------------------
       --
       IF l_person_id = l_prev_per_id AND
          l_effective_start_date = l_prev_eff_start_date AND
          l_effective_end_date = l_prev_eff_end_date AND
          l_asg_id = l_prev_asg_id
       THEN
          -- future dated assignment change exists, do not include this record
          goto create_next;
       END IF;
       -- Fix 3332698.
        l_unique_str := g_dp_ins_str || l_person_id || '_' || l_batch_id;

        hr_pump_utils.add_user_key(
                                 p_user_key_value  =>l_unique_str
                                 ,p_unique_key_id  =>l_person_id
                                  );

       -- not the same person, write this to the batch record
       hrdpp_create_user_acct.insert_batch_lines
         (p_batch_id              => l_batch_id
         ,p_user_sequence         => null
         ,p_link_value            => null
         ,p_person_user_key       => l_unique_str
         ,p_date_from             => l_date_from
         ,p_date_to               => l_date_to
         ,p_org_structure_id      => p_organization_structure_id
         ,p_org_structure_vers_id => p_org_structure_version_id
         ,p_parent_org_id         => p_parent_org_id
         ,p_single_org_id         => p_single_org_id
         ,p_run_type              => p_run_type
         ,p_per_effective_start_date  => l_effective_start_date
         ,p_per_effective_end_date    => l_effective_end_date
         ,p_assignment_id         => l_asg_id
         ,p_asg_effective_start_date  => l_asg_eff_start_date
         ,p_asg_effective_end_date    => l_asg_eff_end_date
         ,p_hire_date             => l_hire_date);

       -- Increment the count
       l_new_user_count := l_new_user_count + 1;

       l_commit_count := l_commit_count + 1;
       IF l_commit_count = g_commit_limit
       THEN
          -- commit after so many employees
          commit;
          l_commit_count := 0;
       END IF;

       -- Move the current record to previous record
       l_prev_per_id := l_person_id;
       l_prev_eff_start_date := l_effective_start_date;
       l_prev_eff_end_date := l_effective_end_date;
       l_prev_asg_id := l_asg_id;
       l_prev_asg_eff_start_date := l_asg_eff_start_date;
       l_prev_asg_eff_end_date := l_asg_eff_end_date;
       l_prev_hire_date := l_hire_date;

       <<create_next>>
       null;

     END LOOP;
  END IF;

  IF upper(p_run_type) = hr_user_acct_utility.g_cr_n_inact_user OR
     upper(p_run_type) = hr_user_acct_utility.g_inactivate_user
  THEN
     l_dynamic_cursor_id := 0;
     l_dynamic_cursor_id := dbms_sql.open_cursor;                  -- Step 1

     BEGIN

     hr_utility.set_location('In executing inactivate user dynamic sql..', 37);

     dbms_sql.parse(l_dynamic_cursor_id, l_inactivate_user_sql_clause
                   ,dbms_sql.v7);                                   -- Step 2
     -- ************************************************************************
     -- NOTE:If we retrieve extra column,need to set the l_index accordingly.
     -- ************************************************************************
     --
     l_index := 1;
     --
     -- Define the Person Id column
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_temp);
     --
     -- Now define Person record Effective Start Date
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_date_temp);
     --
     -- Now define Person record Effective End Date
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_date_temp);
     --
     -- Define the Assignment Id column
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_temp);
     --
     -- Now define Assignment record Effective Start Date
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_date_temp);
     --
     -- Now define Assignment record Effective End Date
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_date_temp);
     --
     -- Now define the Term Date column
     l_index := l_index + 1;
     dbms_sql.define_column(l_dynamic_cursor_id, l_index, l_date_temp);
     --
     EXCEPTION
       WHEN OTHERS THEN
         null;
     END;
     --
     l_inactivate_user_count := 0;
     l_rows := dbms_sql.execute(l_dynamic_cursor_id);               -- Step 5
     --
     WHILE dbms_sql.fetch_rows(l_dynamic_cursor_id) > 0 LOOP         -- Step 6
       dbms_sql.column_value(l_dynamic_cursor_id, 1, l_person_id);
       dbms_sql.column_value(l_dynamic_cursor_id, 2, l_effective_start_date);
       dbms_sql.column_value(l_dynamic_cursor_id, 3, l_effective_end_date);
       dbms_sql.column_value(l_dynamic_cursor_id, 4, l_asg_id);
       dbms_sql.column_value(l_dynamic_cursor_id, 5, l_asg_eff_start_date);
       dbms_sql.column_value(l_dynamic_cursor_id, 6, l_asg_eff_end_date);
       dbms_sql.column_value(l_dynamic_cursor_id, 7, l_term_date);
       --
       -- We only want to create the batch header when there is record retreived
       -- from the dynamic sql statement.  Otherwise, we won't create a header.
       IF l_batch_id IS NOT NULL
       THEN
          null;
       ELSE
          l_batch_id := hr_pump_utils.create_batch_header
                          (p_batch_name          => p_batch_name
                          ,p_business_group_name => l_bg_name);
       END IF;
       --
       -----------------------------------------------------------------------
       -- NOTE:
       --    Business Group Id is derived from the business group name saved in
       --    the hrdpp_pump_batch_headers table.  We do not need to pass
       --    p_business_group_id when inserting to batch lines record.
       -----------------------------------------------------------------------
       -- Do the prev fields check for the same reason in create_user
       -- above.
       IF l_person_id = l_prev_per_id AND
          l_effective_start_date = l_prev_eff_start_date AND
          l_effective_end_date = l_prev_eff_end_date AND
          l_asg_id = l_prev_asg_id
       THEN
          -- future dated assignment change exists, do not include this record
          goto update_next;
       END IF;
        -- Fix 3332698.
        l_unique_str := g_dp_upd_str || l_person_id || '_' || l_batch_id;

        hr_pump_utils.add_user_key(
                                p_user_key_value  =>l_unique_str
                                ,p_unique_key_id  =>l_person_id
                                 );

       hrdpp_update_user_acct.insert_batch_lines
         (p_batch_id              => l_batch_id
         ,p_user_sequence         => null
         ,p_link_value            => null
         ,p_person_user_key       => l_unique_str
         ,p_date_from             => l_date_from
         ,p_date_to               => l_date_to
         ,p_org_structure_id      => p_organization_structure_id
         ,p_org_structure_vers_id => p_org_structure_version_id
         ,p_parent_org_id         => p_parent_org_id
         ,p_single_org_id         => p_single_org_id
         ,p_run_type              => p_run_type
         ,p_per_effective_start_date  => l_effective_start_date
         ,p_per_effective_end_date    => l_effective_end_date
         ,p_assignment_id         => l_asg_id
         ,p_asg_effective_start_date  => l_asg_eff_start_date
         ,p_asg_effective_end_date    => l_asg_eff_end_date
         ,p_inactivate_date       => l_term_date);

       -- Increment the counter
       l_inactivate_user_count := l_inactivate_user_count + 1;

       -- Move the current record to previous record
       l_prev_per_id := l_person_id;
       l_prev_eff_start_date := l_effective_start_date;
       l_prev_eff_end_date := l_effective_end_date;
       l_prev_asg_id := l_asg_id;
       l_prev_asg_eff_start_date := l_asg_eff_start_date;
       l_prev_asg_eff_end_date := l_asg_eff_end_date;
       l_prev_term_date := l_term_date;

       <<update_next>>
       null;

     END LOOP;
  END IF;
--

  IF p_run_type = hr_user_acct_utility.g_cr_user_new_hires OR
     p_run_type = hr_user_acct_utility.g_cr_user_all_emp
  THEN
     fnd_message.set_name('PER', 'HR_CREATE_USER_ACCT_COUNT');
     l_msg := fnd_message.get || to_char(l_new_user_count);
     fnd_file.put_line(FND_FILE.LOG, l_msg);
  ELSIF p_run_type = hr_user_acct_utility.g_inactivate_user
  THEN
     fnd_message.set_name('PER','HR_INACTIVATE_USER_ACCT_COUNT');
     l_msg := fnd_message.get || to_char(l_inactivate_user_count);
     fnd_file.put_line(FND_FILE.LOG, l_msg);
  ELSIF p_run_type = hr_user_acct_utility.g_cr_n_inact_user
  THEN
     -- Now print the create user account count
     fnd_message.set_name('PER', 'HR_CREATE_USER_ACCT_COUNT');
     l_msg := fnd_message.get || to_char(l_new_user_count);
     fnd_file.put_line(FND_FILE.LOG, l_msg);

     -- Now print the inactivate user account count
     fnd_message.set_name('PER','HR_INACTIVATE_USER_ACCT_COUNT');
     l_msg := fnd_message.get || to_char(l_inactivate_user_count);
     fnd_file.put_line(FND_FILE.LOG, l_msg);
  END IF;
--
  retcode := 0;

  hr_utility.set_location('Leaving ' || l_proc, 10);

  return;
--
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace ('Error in the '|| l_proc ||' - ORA '||
                        to_char(SQLCODE));
      errbuf := sqlerrm;
      retcode := 2;
      rollback;
--
END run_process;
--
--
END HR_USER_ACCT_EMP_EXTRACT;

/
