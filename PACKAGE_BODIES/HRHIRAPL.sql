--------------------------------------------------------
--  DDL for Package Body HRHIRAPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRHIRAPL" AS
/* $Header: pehirapl.pkb 120.27.12010000.7 2009/05/06 06:56:13 skura ship $ */

--
------------------------- BEGIN: employ_applicant --------------------
PROCEDURE employ_applicant (p_person_id IN INTEGER
                                 ,p_business_group_id IN INTEGER
                                 ,p_legislation_code IN VARCHAR2
                                 ,p_new_primary_id IN INTEGER
                                 ,p_assignment_status_type_id IN INTEGER
                                 ,p_user_id IN INTEGER
                                 ,p_login_id IN INTEGER
                                 ,p_start_date IN DATE
                                 ,p_end_of_time IN DATE
                                 ,p_current_date IN DATE
                                 ,p_update_primary_flag VARCHAR2
                                 ,p_employee_number VARCHAR2
                                 ,p_set_of_books_id IN INTEGER
                                 ,p_emp_apl VARCHAR2
                                 ,p_adjusted_svc_date IN DATE
                                 ,p_session_date IN DATE -- Bug 3564129
                                 -- #2264569
                                 ,p_table IN HR_EMPLOYEE_APPLICANT_API.t_ApplTable
                                 ) IS
/*
  NAME
    employ_applicant
  DESCRIPTION
    Procedures fired when applicant is hired.
    PARAMETERS
    p_business_group_id   : Current business group.
    p_legislation_code    : Legislation code.
    p_new_primary_id      : Id of new primary assignment.
    p_assignment_status_type_id: Current assignment status id.
    p_user_id             : user id
    p_login_id            : Login id of user.
    p_start_date          : Start date.
    p_end_of_time         : Maximum date that can be held by an Oracle system.
    p_current_date        : Today's Date
    p_update_primary_flag : Flag whether to update the primary assignment or not
    p_set_of_books_id : Current set of books_id
    p_emp_apl             : Whether EMP_APL or APL.
    p_session_date        : Session Date -- Bug 3564129
    -- #2264569
    p_table               : PL/SQL table that has information about the type of
                            processing performed to the appl assignment.

*/
--
v_period_of_service_id INTEGER;
p_assignment_id INTEGER;
v_tabrows varchar2(4000); -- Bug 3214063
l_return_code number;        -- #2433154
l_return_text varchar2(240); -- #2433154
l_delete_warn boolean;  -- #2933750
 --fix for bug 7119614 starts here.
cursor c_pgp_segments(l_pg_id number) is
     select segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment17,
            segment18,
            segment19,
            segment20,
            segment21,
            segment22,
            segment23,
            segment24,
            segment25,
            segment26,
            segment27,
            segment28,
            segment29,
            segment30
     from   pay_people_groups
     where  people_group_id = l_pg_id;
 l_pgp_segment1               varchar2(60) ;
 l_pgp_segment2               varchar2(60) ;
 l_pgp_segment3               varchar2(60) ;
 l_pgp_segment4               varchar2(60) ;
 l_pgp_segment5               varchar2(60) ;
 l_pgp_segment6               varchar2(60) ;
 l_pgp_segment7               varchar2(60) ;
 l_pgp_segment8               varchar2(60) ;
 l_pgp_segment9               varchar2(60) ;
 l_pgp_segment10              varchar2(60) ;
 l_pgp_segment11              varchar2(60) ;
 l_pgp_segment12              varchar2(60) ;
 l_pgp_segment13              varchar2(60) ;
 l_pgp_segment14              varchar2(60) ;
 l_pgp_segment15              varchar2(60) ;
 l_pgp_segment16              varchar2(60) ;
 l_pgp_segment17              varchar2(60) ;
 l_pgp_segment18              varchar2(60) ;
 l_pgp_segment19              varchar2(60) ;
 l_pgp_segment20              varchar2(60) ;
 l_pgp_segment21              varchar2(60) ;
 l_pgp_segment22              varchar2(60) ;
 l_pgp_segment23              varchar2(60) ;
 l_pgp_segment24              varchar2(60) ;
 l_pgp_segment25              varchar2(60) ;
 l_pgp_segment26              varchar2(60) ;
 l_pgp_segment27              varchar2(60) ;
 l_pgp_segment28              varchar2(60) ;
 l_pgp_segment29              varchar2(60) ;
 l_pgp_segment30              varchar2(60) ;
 --fix for bug 7119614 ends here.
--

function table_contents return varchar2 is
  l_appls varchar2(4000); -- Bug 3214063
  l_max number;
BEGIN
  hr_utility.set_location('IN hrhirapl.table_contents',490);
  l_max := p_table.COUNT;
  hr_utility.trace('table rows : '||to_char(l_max));
  for v_index in 1..l_max loop

     l_appls := l_appls||' ('||to_char(p_table(v_index).id)||')'
                  ||p_table(v_index).process_flag;

  END LOOP;
  hr_utility.set_location('OUT hrhirapl.table_contents',495);
  return(l_appls);
END;
--
--
FUNCTION get_period_of_service (p_business_group_id IN INTEGER
                                ,p_person_id IN INTEGER
                                ,p_legislation_code IN VARCHAR2
                                 ,p_emp_apl IN VARCHAR2
                                ) return INTEGER is
--
-- Get new or existing period of service.
--
--
v_dummy INTEGER;
--
-- START WWBUG fix for 1390173
--
l_old   ben_pps_ler.g_pps_ler_rec;
  l_new   ben_pps_ler.g_pps_ler_rec;
--
-- END WWBUG fix for 1390173
--
--
begin
  hr_utility.set_location('hr_person.get_period_of_service',1);
--
  if p_emp_apl ='Y' then
    begin
      select pps.period_of_service_id
      into   v_dummy
      from   per_periods_of_service pps
      where  p_start_date between pps.date_start
      and    nvl(pps.ACTUAL_TERMINATION_DATE,p_end_of_time)
      and    pps.person_id = p_person_id
      and    pps.business_group_id  + 0 = p_business_group_id;
--
      return v_dummy;
--
    exception
      when no_data_found then
        hr_utility.set_message(801,'HR_6346_EMP_ASS_NO_POS');
        hr_utility.raise_error;
     when others then
        null;
    end;
  else
  hr_utility.set_location('hr_person.get_period_of_service',2);
    begin
     select per_periods_of_service_s.nextval
     into   v_dummy
     from   sys.dual;
     exception
       when no_data_found then
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','get_period_of_service');
         hr_utility.set_message_token('STEP',1);
         hr_utility.raise_error;
       when others then null;
     end;
--
  hr_utility.set_location('hr_person.get_period_of_service',3);
     begin
       insert into per_periods_of_service
       (period_of_service_id
        ,business_group_id
        ,person_id
        ,date_start
        ,last_update_date
        ,last_update_login
        ,last_updated_by
        ,created_by
        ,creation_date
        ,adjusted_svc_date)
        values
        (v_dummy
        ,p_business_group_id
        ,p_person_id
        ,p_start_date
        ,null
        ,null
        ,null
        ,null
        ,null
        ,p_adjusted_svc_date
);
--
-- Bug No 4457579 Moved this check above call to ben_pps_ler.ler_chk
--
      if SQL%ROWCOUNT < 1 then
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','get_period_of_service');
         hr_utility.set_message_token('STEP',2);
         hr_utility.raise_error;
      end if;
  hr_utility.set_location('hr_person.get_period_of_service',4);
--
-- START WWBUG fix for 1390173
--
  l_new.PERSON_ID := p_person_id;
  l_new.BUSINESS_GROUP_ID := p_business_group_id;
  l_new.DATE_START := p_start_date;
  l_new.ACTUAL_TERMINATION_DATE := null;
  l_new.LEAVING_REASON := null;
  l_new.ADJUSTED_SVC_DATE := null;
  l_new.ATTRIBUTE1 := null;
  l_new.ATTRIBUTE2 := null;
  l_new.ATTRIBUTE3 := null;
  l_new.ATTRIBUTE4 := null;
  l_new.ATTRIBUTE5 := null;
  l_new.final_process_date := null;
  --
  ben_pps_ler.ler_chk(p_old            => l_old
                     ,p_new            => l_new
                     ,p_event          => 'INSERTING'
                     ,p_effective_date => p_start_date);
--
-- END WWBUG fix for 1390173
--
--
        return v_dummy;
--
        end;
  end if;
--
end get_period_of_service;
--
--
PROCEDURE update_primary_assignment(p_business_group_id IN INTEGER
                                   ,p_person_id IN INTEGER
                                   ,p_start_date IN DATE
                                   ,p_current_date IN DATE
                                   ,p_user_id IN INTEGER
                                   ,p_login_id IN INTEGER
                                   ) is
--
-- Date effectively end the current primary assignment
--
--
begin
--
  hr_utility.set_location('hr_person.update_primary_assignment',1);
--
insert into per_assignments_f
(assignment_id
,effective_start_date
,effective_end_date
,business_group_id
,grade_id
,position_id
,job_id
,assignment_status_type_id
,payroll_id
,location_id
,person_id
,organization_id
,people_group_id
,soft_coding_keyflex_id
,vacancy_id
,assignment_sequence
,assignment_type
,manager_flag
,primary_flag
,application_id
,assignment_number
,change_reason
,comment_id
,date_probation_end
,default_code_comb_id
,frequency
,internal_address_line
,normal_hours
,period_of_service_id
,probation_period
,probation_unit
,recruiter_id
,set_of_books_id
,special_ceiling_step_id
,supervisor_id
,time_normal_finish
,time_normal_start
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
,last_update_date
,last_updated_by
,last_update_login
,created_by
,creation_date
,pay_basis_id
,person_referred_by_id
,recruitment_activity_id
,source_organization_id
,source_type
,employment_category            /* columns added Bug 978981 */
,perf_review_period
,perf_review_period_frequency
,sal_review_period
,sal_review_period_frequency
,bargaining_unit_code
,labour_union_member_flag
,hourly_salaried_code
,title
,supervisor_assignment_id   --- #Added for fix of 4053244
,EMPLOYEE_CATEGORY          -- Added for fix of 4212826
,COLLECTIVE_AGREEMENT_ID
,CAGR_ID_FLEX_NUM
,CAGR_GRADE_DEF_ID
,GRADE_LADDER_PGM_ID)
select pa.assignment_id
,pa.effective_start_date
,p_start_date - 1
,pa.business_group_id
,pa.grade_id
,pa.position_id
,pa.job_id
,pa.assignment_status_type_id
,pa.payroll_id
,pa.location_id
,pa.person_id
,pa.organization_id
,pa.people_group_id
,pa.soft_coding_keyflex_id
,pa.vacancy_id
,pa.assignment_sequence
,pa.assignment_type
,pa.manager_flag
,pa.primary_flag
,pa.application_id
,pa.assignment_number
,pa.change_reason
,pa.comment_id
,pa.date_probation_end
,pa.default_code_comb_id
,pa.frequency
,pa.internal_address_line
,pa.normal_hours
,pa.period_of_service_id
,pa.probation_period
,pa.probation_unit
,pa.recruiter_id
,pa.set_of_books_id
,pa.special_ceiling_step_id
,pa.supervisor_id
,pa.time_normal_finish
,pa.time_normal_start
,pa.request_id
,pa.program_application_id
,pa.program_id
,pa.program_update_date
,pa.ass_attribute_category
,pa.ass_attribute1
,pa.ass_attribute2
,pa.ass_attribute3
,pa.ass_attribute4
,pa.ass_attribute5
,pa.ass_attribute6
,pa.ass_attribute7
,pa.ass_attribute8
,pa.ass_attribute9
,pa.ass_attribute10
,pa.ass_attribute11
,pa.ass_attribute12
,pa.ass_attribute13
,pa.ass_attribute14
,pa.ass_attribute15
,pa.ass_attribute16
,pa.ass_attribute17
,pa.ass_attribute18
,pa.ass_attribute19
,pa.ass_attribute20
,pa.ass_attribute21
,pa.ass_attribute22
,pa.ass_attribute23
,pa.ass_attribute24
,pa.ass_attribute25
,pa.ass_attribute26
,pa.ass_attribute27
,pa.ass_attribute28
,pa.ass_attribute29
,pa.ass_attribute30
,p_current_date
,p_user_id
,p_login_id
,pa.created_by
,pa.creation_date
,pa.pay_basis_id
,pa.person_referred_by_id
,pa.recruitment_activity_id
,pa.source_organization_id
,pa.source_type
,employment_category            /* columns added Bug 978981 */
,perf_review_period
,perf_review_period_frequency
,sal_review_period
,sal_review_period_frequency
,bargaining_unit_code
,labour_union_member_flag
,hourly_salaried_code
,title
,pa.supervisor_assignment_id     --- #Added for fix of 4053244
,pa.EMPLOYEE_CATEGORY            -- Added for fix of 4212826
,pa.COLLECTIVE_AGREEMENT_ID
,pa.CAGR_ID_FLEX_NUM
,pa.CAGR_GRADE_DEF_ID
,pa.GRADE_LADDER_PGM_ID -- fix of bug 5513751
from per_assignments_f pa
where pa.person_id = p_person_id
and   pa.business_group_id + 0 = p_business_group_id
and   pa.primary_flag = 'Y'
and   p_start_date between pa.effective_start_date
and   pa.effective_end_date
and   p_start_date > pa.effective_start_date; -- #1981550
--
-- Previous statement could fail when the hire date is the same as the
-- effective start date of the current assignment.(#1981550)
--
--
--if SQL%ROWCOUNT < 1 THEN
--     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
--     hr_utility.set_message_token('PROCEDURE','update_primary_assignment');
--     hr_utility.set_message_token('STEP','1');
--     hr_utility.raise_error;
--end if;
--
end update_primary_assignment;
-- +-----------------------------------------------------------------------+
-- --------------------BEGIN: make_secondary ------------------------------+
-- +-----------------------------------------------------------------------+
PROCEDURE make_secondary(p_business_group_id IN INTEGER
                        ,p_person_id IN INTEGER
                        ,p_legislation_code IN VARCHAR2
                        ,p_assignment_status_type_id IN INTEGER
                        ,p_update_primary_flag IN VARCHAR2
                        ,p_new_primary_id IN INTEGER
                        ,p_user_id IN INTEGER
                        ,p_login_id IN INTEGER
                        ,p_start_date IN DATE
                        ,p_end_of_time IN DATE
                        ,p_employee_number IN VARCHAR2
                        ,p_set_of_books_id IN INTEGER
                        ,p_current_date IN DATE
                        ) is
--
-- Make other accepted assignment rows secondary
-- as long as the user does not want to keep them in the system
-- i.e. (R)etain value exists in p_table
--
-- counter to hold number of assignments inserted
-- used to check that all are updated.
v_count INTEGER;
--
l_chk_assg_end_dated varchar2(1); -- bug6310975
p_assignment_number VARCHAR2(30);
p_assignment_sequence INTEGER;
p_rowid ROWID;
--
l_dummy VARCHAR2(1);
--
-- Start of bug 3564129
l_asg_status_id  irc_assignment_statuses.assignment_status_id%type;
l_asg_status_ovn irc_assignment_statuses.object_version_number%type;
-- End of bug 3564129
--
-- Bug 518669. Increased length of l_col_name from 30 to 200, so it matches
-- the max len of the column in the DB. Pashun. 16-Sep-97.
--
l_col_name VARCHAR2(200);
cursor get_flex_def is
select default_context_field_name
from fnd_descriptive_flexs
where application_id = 800 -- bug 5469726
and descriptive_flexfield_name = 'PER_ASSIGNMENTS';
--
-- #2264569
--
  l_asg_rec per_assignments_f%ROWTYPE;
--
  cursor ass_cur is
     select pa.*
      from  per_assignments_f pa
      ,     per_assignment_status_types past
      where nvl(past.business_group_id,p_business_group_id) = pa.business_group_id + 0
      and   nvl(past.legislation_code, p_legislation_code)
                   = p_legislation_code
      and  past.per_system_status   = 'ACCEPTED'
      and    pa.assignment_type     = 'A'
      and    pa.business_group_id   + 0 = p_business_group_id
      and    pa.person_id           = p_person_id
      and    past.assignment_status_type_id = pa.assignment_status_type_id
           and  ((p_update_primary_flag in ('Y','V')
      	          and pa.assignment_id <> p_new_primary_id
                  )
      	or (p_update_primary_flag not in ('Y','V')
           )
      	)
           and   p_start_date between pa.effective_start_date
           and   pa.effective_end_date
           order by decode(pa.assignment_id,p_new_primary_id,1,0) desc --added for bug  5589928
           for update of pa.assignment_status_type_id;
--
--
/*fix for the bug 5498344 starts here
 cursor csr_ass_cur_for_primary is
     select pa.*
      from  per_assignments_f pa
      ,     per_assignment_status_types past
      where nvl(past.business_group_id,p_business_group_id) = pa.business_group_id + 0
      and   nvl(past.legislation_code, p_legislation_code)
                   = p_legislation_code
      and  past.per_system_status   = 'ACCEPTED'
      and    pa.assignment_type     = 'A'
      and    pa.business_group_id   + 0 = p_business_group_id
      and    pa.person_id           = p_person_id
      and    past.assignment_status_type_id = pa.assignment_status_type_id
           and  ((p_update_primary_flag in ('Y','V')
      	          and pa.assignment_id <> p_new_primary_id
                  )
      	or (p_update_primary_flag not in ('Y','V')
           )
      	)
           and   p_start_date between pa.effective_start_date
           and   pa.effective_end_date
           and   pa.assignment_id = p_new_primary_id
           for update of pa.assignment_status_type_id;
--

cursor csr_ass_cur_for_nonprimary is
     select pa.*
      from  per_assignments_f pa
      ,     per_assignment_status_types past
      where nvl(past.business_group_id,p_business_group_id) = pa.business_group_id + 0
      and   nvl(past.legislation_code, p_legislation_code)
                   = p_legislation_code
      and  past.per_system_status   = 'ACCEPTED'
      and    pa.assignment_type     = 'A'
      and    pa.business_group_id   + 0 = p_business_group_id
      and    pa.person_id           = p_person_id
      and    past.assignment_status_type_id = pa.assignment_status_type_id
           and  ((p_update_primary_flag in ('Y','V')
      	          and pa.assignment_id <> p_new_primary_id
                  )
      	or (p_update_primary_flag not in ('Y','V')
           )
      	)
           and   p_start_date between pa.effective_start_date
           and   pa.effective_end_date
           and   pa.assignment_id <> p_new_primary_id
           for update of pa.assignment_status_type_id;
--
--
 end of fix 5498344*/

--
-- Bug 1248710 incxreased variable length to 150

  l_app_col_name VARCHAR2(30);
  l_ass_attribute1 VARCHAR2(150);
  l_ass_attribute2 VARCHAR2(150);
  l_ass_attribute3 VARCHAR2(150);
  l_ass_attribute4 VARCHAR2(150);
  l_ass_attribute5 VARCHAR2(150);
  l_ass_attribute6 VARCHAR2(150);
  l_ass_attribute7 VARCHAR2(150);
  l_ass_attribute8 VARCHAR2(150);
  l_ass_attribute9 VARCHAR2(150);
  l_ass_attribute10 VARCHAR2(150);
  l_ass_attribute11 VARCHAR2(150);
  l_ass_attribute12 VARCHAR2(150);
  l_ass_attribute13 VARCHAR2(150);
  l_ass_attribute14 VARCHAR2(150);
  l_ass_attribute15 VARCHAR2(150);
  l_ass_attribute16 VARCHAR2(150);
  l_ass_attribute17 VARCHAR2(150);
  l_ass_attribute18 VARCHAR2(150);
  l_ass_attribute19 VARCHAR2(150);
  l_ass_attribute20 VARCHAR2(150);
  l_ass_attribute21 VARCHAR2(150);
  l_ass_attribute22 VARCHAR2(150);
  l_ass_attribute23 VARCHAR2(150);
  l_ass_attribute24 VARCHAR2(150);
  l_ass_attribute25 VARCHAR2(150);
  l_ass_attribute26 VARCHAR2(150);
  l_ass_attribute27 VARCHAR2(150);
  l_ass_attribute28 VARCHAR2(150);
  l_ass_attribute29 VARCHAR2(150);
  l_ass_attribute30 VARCHAR2(150);
--
--
-- Bug 401669 Created cursor to fetch non global columns
--		Cursor to fetch record from per_assignments_f
--
  cursor get_application_column_name is
  select application_column_name
  from   fnd_descr_flex_column_usages fdfcu,
         fnd_descr_flex_contexts fdfc
  where  fdfcu.descriptive_flexfield_name = 'PER_ASSIGNMENTS'
  and    fdfcu.descriptive_flexfield_name = fdfc.descriptive_flexfield_name
  and    fdfcu.descriptive_flex_context_code = fdfc.descriptive_flex_context_code
  and    fdfcu.application_id = fdfc.application_id --- bug 5469726
  and    fdfc.application_id = 800 --- bug 5469726
  and    fdfc.global_flag 		= 'N'
  and    l_col_name 			= 'ASSIGNMENT_TYPE';


--added by amigarg for bug 4882512 start

   cursor get_pay_proposal(ass_id per_all_assignments_f.assignment_id%type) is
    select pay_proposal_id,object_version_number,proposed_salary_n, change_date
    from per_pay_proposals
    where assignment_id=ass_id
    and   approved = 'N'
    order by change_date desc;
    l_pay_pspl_id     per_pay_proposals.pay_proposal_id%TYPE;
    l_pay_obj_number  per_pay_proposals.object_version_number%TYPE;
    l_proposed_sal_n  per_pay_proposals.proposed_salary_n%TYPE;
    l_dummy_change_date per_pay_proposals.change_date%TYPE;
    l_inv_next_sal_date_warning  boolean := false;
    l_proposed_salary_warning  boolean := false;
    l_approved_warning  boolean := false;
    l_payroll_warning  boolean := false;

--added by amigarg for bug 4882512 end
--
--
-- # end 2264569
-- +--------------------------------------------------------------------------+
-- +---------------------- main make secondary -------------------------------+
-- +--------------------------------------------------------------------------+
begin
-- # 2366672
-- Application needs to be end dated before the apl asg get updated.
--
  hr_utility.set_location('hrhirapl.make_secondary',1);
-- +-----------------------------------------------------------------------+
-- +------------------------ End Application  -----------------------------+
-- +-----------------------------------------------------------------------+
-- Does the Retain value exist in the table ?
  if not hr_employee_applicant_api.retain_exists(p_table)
  then
      -- we are "double-checking" that previous updates were successfull
      -- that is why where clause checks for accepted and unaccepted, despite
      -- the fact the table does not have stored a retain value .
      --
      hr_utility.set_location('hrhiapl.make_secondary',2);
      --
      update per_applications pap
      set date_end = p_start_date -1,
          successful_flag = 'Y'
      where pap.person_id = p_person_id -- added for bug 5469726
      and   exists (select '1'
      from per_assignments_f pa,
      per_assignment_status_types past
      where nvl(past.business_group_id,p_business_group_id) = pa.business_group_id + 0
      and   nvl(past.legislation_code, p_legislation_code)
                   = p_legislation_code
      and  past.per_system_status   = 'ACCEPTED'
      and    pa.assignment_type     = 'A'
      and    pa.business_group_id   + 0 = p_business_group_id
      and    pa.person_id           = p_person_id
      and    pa.person_id           = pap.person_id
      and    past.assignment_status_type_id = pa.assignment_status_type_id
      and   p_start_date between pap.date_received and nvl(pap.date_end,p_start_date)
      and   p_start_date between pa.effective_start_date
      and   pa.effective_end_date)
      and not  exists (select '1'
      from per_assignments_f pa,
           per_assignment_status_types past
      where nvl(past.business_group_id,p_business_group_id) = pa.business_group_id + 0
      and   nvl(past.legislation_code, p_legislation_code)
                   = p_legislation_code
      and  past.per_system_status  <> 'ACCEPTED'
      and  pa.assignment_type     = 'A'
      and  pa.business_group_id   + 0 = p_business_group_id
      and  pa.person_id           = p_person_id
      and  pa.person_id           = pap.person_id
      and  past.assignment_status_type_id = pa.assignment_status_type_id
      and  p_start_date between pa.effective_start_date
      and  pa.effective_end_date);

      if SQL%NOTFOUND then
      -- could not update the application
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','make_secondary ');
             hr_utility.set_message_token('STEP','5');
             hr_utility.raise_error;
      end if;
  end if; -- retain value in table?
--

  open get_flex_def;
  fetch get_flex_def into l_col_name;
  close get_flex_def;
--
  hr_utility.set_location('hrhirapl.make_secondary',2);
--
-- Update all accepted assignments making them all
-- secondary (also end dates the assignment type 'A'
-- Unless the update primary_flag is set, in which case
-- update all save the chosen assignment.
--
/* fix for the bug 5498344
hr_utility.set_location('p_update_primary_flag  '||p_update_primary_flag,2);
if p_update_primary_flag not in ('C','N') then commented for bug  5589928*/

  open ass_cur;
  loop
  fetch ass_cur into l_asg_rec; --#2119831
  exit when ass_cur%NOTFOUND;
  --
   -- #2483319
    p_assignment_id := l_asg_rec.assignment_id;
   --
   --
    -- Ensure (R)etain or (E)nd date flags have not been set
    if hr_employee_applicant_api.is_convert(p_table
                                       ,l_asg_rec.assignment_id)
    then
      hr_utility.set_location('hrhirapl.make_secondary',333);
      hr_utility.trace('    asg id     = '||to_char(l_asg_rec.assignment_id));
      hr_utility.trace('    start date = '||to_char(l_asg_rec.effective_start_date,'dd/mm/yy'));

      -- +--------------------------------------------------+
      -- +--- End Date assignment type 'A' -----------------+
      -- +--------------------------------------------------+
      begin
        insert into per_assignments_f
        (assignment_id
        ,effective_start_date
        ,effective_end_date
        ,business_group_id
        ,grade_id
        ,position_id
        ,job_id
        ,assignment_status_type_id
        ,payroll_id
        ,location_id
        ,person_id
        ,organization_id
        ,people_group_id
        ,soft_coding_keyflex_id
        ,vacancy_id
        ,assignment_sequence
        ,assignment_type
        ,manager_flag
        ,primary_flag
        ,application_id
        ,assignment_number
        ,change_reason
        ,comment_id
        ,date_probation_end
        ,default_code_comb_id
        ,frequency
        ,internal_address_line
        ,normal_hours
        ,period_of_service_id
        ,probation_period
        ,probation_unit
        ,recruiter_id
        ,set_of_books_id
        ,special_ceiling_step_id
        ,supervisor_id
        ,time_normal_finish
        ,time_normal_start
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
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,created_by
        ,creation_date
        ,pay_basis_id
        ,person_referred_by_id
        ,recruitment_activity_id
        ,source_organization_id
        ,source_type
        ,employment_category            /* columns added Bug 978981 */
        ,perf_review_period
        ,perf_review_period_frequency
        ,sal_review_period
        ,sal_review_period_frequency
        ,bargaining_unit_code
        ,labour_union_member_flag
        ,hourly_salaried_code
        ,title
        ,job_post_source_name   -- added for 4486233
	,supervisor_assignment_id) ---#4053244
         values
        (l_asg_rec.assignment_id
        ,l_asg_rec.effective_start_date
        ,p_start_date - 1
        ,l_asg_rec.business_group_id
        ,l_asg_rec.grade_id
        ,l_asg_rec.position_id
        ,l_asg_rec.job_id
        ,l_asg_rec.assignment_status_type_id
        ,l_asg_rec.payroll_id
        ,l_asg_rec.location_id
        ,l_asg_rec.person_id
        ,l_asg_rec.organization_id
        ,l_asg_rec.people_group_id
        ,l_asg_rec.soft_coding_keyflex_id
        ,l_asg_rec.vacancy_id
        ,l_asg_rec.assignment_sequence
        ,l_asg_rec.assignment_type
        ,l_asg_rec.manager_flag
        ,l_asg_rec.primary_flag
        ,l_asg_rec.application_id
        ,l_asg_rec.assignment_number
        ,l_asg_rec.change_reason
        ,l_asg_rec.comment_id
        ,l_asg_rec.date_probation_end
        ,l_asg_rec.default_code_comb_id
        ,l_asg_rec.frequency
        ,l_asg_rec.internal_address_line
        ,l_asg_rec.normal_hours
        ,l_asg_rec.period_of_service_id
        ,l_asg_rec.probation_period
        ,l_asg_rec.probation_unit
        ,l_asg_rec.recruiter_id
        ,l_asg_rec.set_of_books_id
        ,l_asg_rec.special_ceiling_step_id
        ,l_asg_rec.supervisor_id
        ,l_asg_rec.time_normal_finish
        ,l_asg_rec.time_normal_start
        ,l_asg_rec.request_id
        ,l_asg_rec.program_application_id
        ,l_asg_rec.program_id
        ,l_asg_rec.program_update_date
        ,l_asg_rec.ass_attribute_category
        ,l_asg_rec.ass_attribute1
        ,l_asg_rec.ass_attribute2
        ,l_asg_rec.ass_attribute3
        ,l_asg_rec.ass_attribute4
        ,l_asg_rec.ass_attribute5
        ,l_asg_rec.ass_attribute6
        ,l_asg_rec.ass_attribute7
        ,l_asg_rec.ass_attribute8
        ,l_asg_rec.ass_attribute9
        ,l_asg_rec.ass_attribute10
        ,l_asg_rec.ass_attribute11
        ,l_asg_rec.ass_attribute12
        ,l_asg_rec.ass_attribute13
        ,l_asg_rec.ass_attribute14
        ,l_asg_rec.ass_attribute15
        ,l_asg_rec.ass_attribute16
        ,l_asg_rec.ass_attribute17
        ,l_asg_rec.ass_attribute18
        ,l_asg_rec.ass_attribute19
        ,l_asg_rec.ass_attribute20
        ,l_asg_rec.ass_attribute21
        ,l_asg_rec.ass_attribute22
        ,l_asg_rec.ass_attribute23
        ,l_asg_rec.ass_attribute24
        ,l_asg_rec.ass_attribute25
        ,l_asg_rec.ass_attribute26
        ,l_asg_rec.ass_attribute27
        ,l_asg_rec.ass_attribute28
        ,l_asg_rec.ass_attribute29
        ,l_asg_rec.ass_attribute30
        ,p_current_date
        ,p_user_id
        ,p_login_id
        ,l_asg_rec.created_by
        ,l_asg_rec.creation_date
        ,l_asg_rec.pay_basis_id
        ,l_asg_rec.person_referred_by_id
        ,l_asg_rec.recruitment_activity_id
        ,l_asg_rec.source_organization_id
        ,l_asg_rec.source_type
        ,l_asg_rec.employment_category            /* columns added Bug 978981 */
        ,l_asg_rec.perf_review_period
        ,l_asg_rec.perf_review_period_frequency
        ,l_asg_rec.sal_review_period
        ,l_asg_rec.sal_review_period_frequency
        ,l_asg_rec.bargaining_unit_code
        ,l_asg_rec.labour_union_member_flag
        ,l_asg_rec.hourly_salaried_code
        ,l_asg_rec.title
        ,l_asg_rec.job_post_source_name   -- added for 4486233
	,l_asg_rec.supervisor_assignment_id); ---#4053244
      exception
        when others then
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','make_secondary => ASGID: '
                                            ||to_char(l_asg_rec.assignment_id));
             hr_utility.set_message_token('STEP','2');
             hr_utility.raise_error;

      end;
      -- +----------- END end date of assignment -----------+
      -- +--------------------------------------------------+
      --
      -- +--------------------------------------------------+
      -- +--- Convert assignment into secondary ------------+
      -- +--------------------------------------------------+
      -- # 2582838
      -- Bug - 401669
      -- select all ass_attribute columns
      --
        l_ass_attribute1  := l_asg_rec.ass_attribute1;
        l_ass_attribute2  := l_asg_rec.ass_attribute2;
        l_ass_attribute3  := l_asg_rec.ass_attribute3;
        l_ass_attribute4  := l_asg_rec.ass_attribute4;
        l_ass_attribute5  := l_asg_rec.ass_attribute5;
        l_ass_attribute6  := l_asg_rec.ass_attribute6;
        l_ass_attribute7  := l_asg_rec.ass_attribute7;
        l_ass_attribute8  := l_asg_rec.ass_attribute8;
        l_ass_attribute9  := l_asg_rec.ass_attribute9;
        l_ass_attribute10 := l_asg_rec.ass_attribute10;
        l_ass_attribute11 := l_asg_rec.ass_attribute11;
        l_ass_attribute12 := l_asg_rec.ass_attribute12;
        l_ass_attribute13 := l_asg_rec.ass_attribute13;
        l_ass_attribute14 := l_asg_rec.ass_attribute14;
        l_ass_attribute15 := l_asg_rec.ass_attribute15;
        l_ass_attribute16 := l_asg_rec.ass_attribute16;
        l_ass_attribute17 := l_asg_rec.ass_attribute17;
        l_ass_attribute18 := l_asg_rec.ass_attribute18;
        l_ass_attribute19 := l_asg_rec.ass_attribute19;
        l_ass_attribute20 := l_asg_rec.ass_attribute20;
        l_ass_attribute21 := l_asg_rec.ass_attribute21;
        l_ass_attribute22 := l_asg_rec.ass_attribute22;
        l_ass_attribute23 := l_asg_rec.ass_attribute23;
        l_ass_attribute24 := l_asg_rec.ass_attribute24;
        l_ass_attribute25 := l_asg_rec.ass_attribute25;
        l_ass_attribute26 := l_asg_rec.ass_attribute26;
        l_ass_attribute27 := l_asg_rec.ass_attribute27;
        l_ass_attribute28 := l_asg_rec.ass_attribute28;
        l_ass_attribute29 := l_asg_rec.ass_attribute29;
        l_ass_attribute30 := l_asg_rec.ass_attribute30;

      open get_application_column_name;
      loop
      fetch get_application_column_name into l_app_col_name;
      exit when get_application_column_name%NOTFOUND;
        --
        if l_app_col_name = 'ASS_ATTRIBUTE1' then
        l_ass_attribute1 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE2' then
        l_ass_attribute2 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE3' then
        l_ass_attribute3 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE4' then
        l_ass_attribute4 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE5' then
        l_ass_attribute5 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE6' then
        l_ass_attribute6 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE7' then
        l_ass_attribute7 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE8' then
        l_ass_attribute8 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE9' then
        l_ass_attribute9 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE10' then
        l_ass_attribute10 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE11' then
        l_ass_attribute11 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE12' then
        l_ass_attribute12 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE13' then
        l_ass_attribute13 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE14' then
        l_ass_attribute14 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE15' then
        l_ass_attribute15 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE16' then
        l_ass_attribute16 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE17' then
        l_ass_attribute17 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE18' then
        l_ass_attribute18 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE19' then
        l_ass_attribute19 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE20' then
        l_ass_attribute20 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE21' then
        l_ass_attribute21 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE22' then
        l_ass_attribute22 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE23' then
        l_ass_attribute23 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE24' then
        l_ass_attribute24 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE25' then
        l_ass_attribute25 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE26' then
        l_ass_attribute26 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE27' then
        l_ass_attribute27 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE28' then
        l_ass_attribute28 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE29' then
        l_ass_attribute29 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE30' then
        l_ass_attribute30 := NULL;
        end if;
      end loop;
      --
      close get_application_column_name;
      -- +-----------------------------------------------------+
      --
      hrentmnt.check_payroll_changes_asg(p_assignment_id
                                  ,NULL
                                  ,'INSERT'
                                  ,p_start_date
                                  ,p_end_of_time);
      --
      -- Before doing the update make sure that what we are doing is valid
      -- especially for positions.
      --
      per_asg_bus1.chk_frozen_single_pos
        (p_assignment_id  => p_assignment_id,
         p_position_id    => l_asg_rec.position_id,
         p_effective_date => p_start_date,
	 p_assignment_type => l_asg_rec.assignment_type);
      --
      --
      hr_assignment.gen_new_ass_sequence
                          ( p_person_id
                          , 'E'
                          , p_assignment_sequence
                          );
      --
      hr_assignment.gen_new_ass_number
                          (p_assignment_id
                          ,p_business_group_id
                          ,p_employee_number
                          ,p_assignment_sequence
                          ,p_assignment_number);
    --
      hr_utility.set_location('hrhirapl.make_secondary',3);
--
-- fix for 7120387
declare

l_date_probation_end date;
   l_proj_hire_date date;


cursor appl_rec_det(l_appl_id number) is
   select projected_hire_date
   from per_applications
   where application_id =l_appl_id;



begin

   open appl_rec_det(l_asg_rec.application_id) ;
   fetch appl_rec_det into l_proj_hire_date;
   close appl_rec_det;

   hr_utility.set_location('l_asg_rec .assignment_id :'||l_asg_rec.assignment_id,20);
   hr_utility.set_location('l_proj_hire_date :'||l_proj_hire_date,20);
   hr_utility.set_location('make secondary proj end details ',20);
   hr_utility.set_location('l_proj_hire_date :'||l_proj_hire_date,20);

  if l_proj_hire_date is null then

        if ( l_asg_rec.probation_period is not null)
           and
           (l_asg_rec.probation_unit is not null ) then


          hr_utility.set_location('p_start_date :'||p_start_date,11);
          hr_utility.set_location('l_asg_rec.assignment_id :'||l_asg_rec.assignment_id,11);
          hr_utility.set_location('l_asg_probation_det.probation_period :'||l_asg_rec.probation_period,12);
          hr_utility.set_location('l_asg_probation_det.probation_unit :'||l_asg_rec.probation_unit,15);
                l_date_probation_end :=NULL;
           hr_assignment.gen_probation_end
        (p_assignment_id      => l_asg_rec.assignment_id
        ,p_probation_period   => l_asg_rec.probation_period
        ,p_probation_unit     => l_asg_rec.probation_unit
        ,p_start_date         => p_start_date
        ,p_date_probation_end => l_date_probation_end
        );
      hr_utility.set_location('l_date_probation_end :'||l_date_probation_end,10);
      l_asg_rec.date_probation_end :=l_date_probation_end;
    end if;
  end if; -- proj hire end

end;
-- fix for 7120387
      --
      begin
      update per_assignments_f pa
      set    pa.assignment_status_type_id = p_assignment_status_type_id
      ,      pa.assignment_type           = 'E'
      ,      pa.effective_start_date      = p_start_date
      ,      pa.effective_end_date        = p_end_of_time
      ,      pa.period_of_service_id      = v_period_of_service_id
      ,      pa.primary_flag              = 'N'
      ,      pa.assignment_number         = p_assignment_number
      ,      pa.assignment_sequence       = p_assignment_sequence
      ,      pa.last_update_date          = p_current_date
      ,      pa.last_updated_by           = p_user_id
      ,      pa.last_update_login         = p_login_id
      ,      pa.set_of_books_id           = p_set_of_books_id
      ,      pa.ass_attribute_category    = decode(l_col_name,'ASSIGNMENT_TYPE','E'
                                 ,pa.ass_attribute_category)
          ,	pa.ass_attribute1	= l_ass_attribute1
          ,	pa.ass_attribute2	= l_ass_attribute2
          ,	pa.ass_attribute3	= l_ass_attribute3
          ,	pa.ass_attribute4	= l_ass_attribute4
          ,	pa.ass_attribute5	= l_ass_attribute5
          ,	pa.ass_attribute6	= l_ass_attribute6
          ,	pa.ass_attribute7	= l_ass_attribute7
          ,	pa.ass_attribute8	= l_ass_attribute8
          ,	pa.ass_attribute9	= l_ass_attribute9
          ,	pa.ass_attribute10	= l_ass_attribute10
          ,	pa.ass_attribute11	= l_ass_attribute11
          ,	pa.ass_attribute12	= l_ass_attribute12
          ,	pa.ass_attribute13	= l_ass_attribute13
          ,	pa.ass_attribute14	= l_ass_attribute14
          ,	pa.ass_attribute15	= l_ass_attribute15
          ,	pa.ass_attribute16	= l_ass_attribute16
          ,	pa.ass_attribute17	= l_ass_attribute17
          ,	pa.ass_attribute18	= l_ass_attribute18
          ,	pa.ass_attribute19	= l_ass_attribute19
          ,	pa.ass_attribute20	= l_ass_attribute20
          ,	pa.ass_attribute21	= l_ass_attribute21
          ,	pa.ass_attribute22	= l_ass_attribute22
          ,	pa.ass_attribute23	= l_ass_attribute23
          ,	pa.ass_attribute24	= l_ass_attribute24
          ,	pa.ass_attribute25	= l_ass_attribute25
          ,	pa.ass_attribute26	= l_ass_attribute26
          ,	pa.ass_attribute27	= l_ass_attribute27
          ,	pa.ass_attribute28	= l_ass_attribute28
          ,	pa.ass_attribute29	= l_ass_attribute29
          ,	pa.ass_attribute30	= l_ass_attribute30
	  , pa.date_probation_end	=l_asg_rec.date_probation_end --7120387
      where current of ass_cur;  -- pa.rowid = p_rowid;
      exception
        when others then
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','make_secondary => ASGID: '
                                            ||to_char(l_asg_rec.assignment_id));
             hr_utility.set_message_token('STEP','3');
             hr_utility.raise_error;

      end;
      -- Start of fix 3564129
      if l_asg_rec.vacancy_id is not null then --fix for bug8488222
      IRC_ASG_STATUS_API.create_irc_asg_status
                (p_assignment_id             => p_assignment_id
                ,p_assignment_status_type_id => p_assignment_status_type_id
                ,p_status_change_date        => p_session_date
                ,p_assignment_status_id      => l_asg_status_id
                ,p_object_version_number     => l_asg_status_ovn);
      end if;
      -- End of fix 3564129
      -- Start of fix 7289811
      IRC_OFFERS_API.close_offer
       ( p_validate                   => false
        ,p_effective_date             => p_start_date-1
        ,p_applicant_assignment_id    => p_assignment_id
        ,p_change_reason              => 'APL_HIRED'-- Fix for bug 7540870
       );
      -- End of fix 7289811
      -- Bug 401669
      --
      hr_utility.set_location('hrhirapl.make_secondary',4);
      --
      hr_assignment.load_budget_values(p_assignment_id
                                      ,p_business_group_id
                                      ,p_user_id
                                      ,p_login_id
      		                          ,p_start_date
      		                          ,p_end_of_time
                                       );
      --
      hrentmnt.maintain_entries_asg(p_assignment_id
                               ,p_business_group_id
                               ,'HIRE_APPL'     --,'ASG_CRITERIA' for bug 5547271
                               ,NULL
                               ,NULL
                               ,NULL
                               ,'INSERT'
                               ,p_start_date
                               ,p_end_of_time);
      -- set assignment number back to null;
      p_assignment_number := NULL;
      -- +--------------------------------------------------+
      -- +--- END Convert assignment into secondary --------+
      -- +--------------------------------------------------+
      --
    -- Did user explicity choose END Date ?
    l_chk_assg_end_dated :='N'; -- bug 6310975
    elsif hr_employee_applicant_api.end_date_exists(p_table
                                           ,l_asg_rec.assignment_id) = 1
    then
      -- +--------------------------------------------------+
      -- +--- End Date assignment --------------------------+
      -- +--------------------------------------------------+
      --
      hr_utility.set_location('hrhirapl.make_secondary',5);
      l_chk_assg_end_dated := 'Y'; -- bug 6310975
      begin
        update per_assignments_f
          set effective_end_date = p_start_date -1
         where current of ass_cur;
      exception
        when others then
             hr_utility.set_location('hrhirapl.make_secondary ASGID : '||
                                        to_char(l_asg_rec.assignment_id),66);
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','make_secondary ');
             hr_utility.set_message_token('STEP','4');
             hr_utility.raise_error;
      end;
    end if; -- convert flag is set.
  --

  --added by amigarg for bug 4882512 start
 /*
   OPEN get_pay_proposal(l_asg_rec.assignment_id);
         FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date;
         if get_pay_proposal%found then
            close get_pay_proposal;
            hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                          p_validate                   => false,
                          p_pay_proposal_id            => l_pay_pspl_id ,
                          p_object_version_number      => l_pay_obj_number,
                          p_change_date                => p_start_date,
                          p_approved                   => 'Y',
                          p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                          p_proposed_salary_warning    => l_proposed_salary_warning,
                          p_approved_warning           => l_approved_warning,
                          p_payroll_warning            => l_payroll_warning,
                          p_proposed_salary_n          => l_proposed_sal_n,
                          p_business_group_id          => p_business_group_id);

         else
            close get_pay_proposal;
       end if;
  */
  --
  --bug fix 6310975

   hr_utility.set_location('hrhirapl.make_secondary',500);
  IF l_chk_assg_end_dated <> 'Y' THEN


   OPEN get_pay_proposal(l_asg_rec.assignment_id);
         FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date;
         if get_pay_proposal%found then
            close get_pay_proposal;
            hr_utility.set_location('hrhirapl.make_secondary',501);
	    hr_utility.set_location('hrhirapl.make_secondary  '||l_asg_rec.assignment_id,502);
	    hr_utility.set_location(' make_secondary.l_dummy_change_date  '||l_dummy_change_date,502);
            hr_utility.set_location(' make_secondary.l_pay_pspl_id  '||l_pay_pspl_id,502);
	    hr_utility.set_location(' make_secondary.l_proposed_sal_n  '|| l_proposed_sal_n,502);

           -- fix for the bug 7636109  passing the value as null as requested by sal admin team.
            l_pay_pspl_id:=null;
	     l_pay_obj_number:=null;

            hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                          p_validate                   => false,
                          p_pay_proposal_id            => l_pay_pspl_id ,
                          p_object_version_number      => l_pay_obj_number,
                         p_change_date                => p_start_date,
			 p_assignment_id              => l_asg_rec.assignment_id, -- fix for the bug 7636109

                          p_approved                   => 'Y',
                          p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                          p_proposed_salary_warning    => l_proposed_salary_warning,
                          p_approved_warning           => l_approved_warning,
                          p_payroll_warning            => l_payroll_warning,
                          p_proposed_salary_n          => l_proposed_sal_n,
                          p_business_group_id          => p_business_group_id);

         else
            close get_pay_proposal;
       end if;

    ELSE

        OPEN get_pay_proposal(l_asg_rec.assignment_id);
         FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date;
         if get_pay_proposal%found then
            close get_pay_proposal;
            hr_utility.set_location('hrhirapl.make_secondary',521);
            hr_utility.set_location('hrhirapl.make_secondary  '||l_asg_rec.assignment_id,502);

            hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                          p_validate                   => false,
                          p_pay_proposal_id            => l_pay_pspl_id ,
                          p_object_version_number      => l_pay_obj_number,
                         -- p_change_date                => p_start_date,
                        --  p_approved                   => 'Y',
                            p_date_to                => p_start_date -1,
                          p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                          p_proposed_salary_warning    => l_proposed_salary_warning,
                          p_approved_warning           => l_approved_warning,
                          p_payroll_warning            => l_payroll_warning,
                          p_proposed_salary_n          => l_proposed_sal_n,
                          p_business_group_id          => p_business_group_id);
   hr_utility.set_location('hrhirapl.make_secondary',522);
             else
                close get_pay_proposal;
             end if;

end if;
 hr_utility.set_location('hrhirapl.make_secondary',524);

  --
    --bug fix 6310975
  --added by amigarg for bug 4882512 end
  --
  end loop;
--
  close ass_cur;
--
/*else
-- fix for the bug
-- first process the primary assignment id so that the assignment number is
-- correclty generated
hr_utility.set_location('hrhirapl.make_secondary',400);
 open csr_ass_cur_for_primary;
 loop
 fetch csr_ass_cur_for_primary into l_asg_rec; --#2119831
 exit when csr_ass_cur_for_primary%NOTFOUND;
  --
   -- #2483319
    p_assignment_id := l_asg_rec.assignment_id;
   --
   --
    -- Ensure (R)etain or (E)nd date flags have not been set
    if hr_employee_applicant_api.is_convert(p_table
                                       ,l_asg_rec.assignment_id)
    then
      hr_utility.set_location('hrhirapl.make_secondary',401);
      hr_utility.trace('    asg id     = '||to_char(l_asg_rec.assignment_id));
      hr_utility.trace('    start date = '||to_char(l_asg_rec.effective_start_date,'dd/mm/yy'));

      -- +--------------------------------------------------+
      -- +--- End Date assignment type 'A' -----------------+
      -- +--------------------------------------------------+
      begin
        insert into per_assignments_f
        (assignment_id
        ,effective_start_date
        ,effective_end_date
        ,business_group_id
        ,grade_id
        ,position_id
        ,job_id
        ,assignment_status_type_id
        ,payroll_id
        ,location_id
        ,person_id
        ,organization_id
        ,people_group_id
        ,soft_coding_keyflex_id
        ,vacancy_id
        ,assignment_sequence
        ,assignment_type
        ,manager_flag
        ,primary_flag
        ,application_id
        ,assignment_number
        ,change_reason
        ,comment_id
        ,date_probation_end
        ,default_code_comb_id
        ,frequency
        ,internal_address_line
        ,normal_hours
        ,period_of_service_id
        ,probation_period
        ,probation_unit
        ,recruiter_id
        ,set_of_books_id
        ,special_ceiling_step_id
        ,supervisor_id
        ,time_normal_finish
        ,time_normal_start
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
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,created_by
        ,creation_date
        ,pay_basis_id
        ,person_referred_by_id
        ,recruitment_activity_id
        ,source_organization_id
        ,source_type
        ,employment_category            --columns added Bug 978981
        ,perf_review_period
        ,perf_review_period_frequency
        ,sal_review_period
        ,sal_review_period_frequency
        ,bargaining_unit_code
        ,labour_union_member_flag
        ,hourly_salaried_code
        ,title
        ,job_post_source_name   -- added for 4486233
	,supervisor_assignment_id) ---#4053244
         values
        (l_asg_rec.assignment_id
        ,l_asg_rec.effective_start_date
        ,p_start_date - 1
        ,l_asg_rec.business_group_id
        ,l_asg_rec.grade_id
        ,l_asg_rec.position_id
        ,l_asg_rec.job_id
        ,l_asg_rec.assignment_status_type_id
        ,l_asg_rec.payroll_id
        ,l_asg_rec.location_id
        ,l_asg_rec.person_id
        ,l_asg_rec.organization_id
        ,l_asg_rec.people_group_id
        ,l_asg_rec.soft_coding_keyflex_id
        ,l_asg_rec.vacancy_id
        ,l_asg_rec.assignment_sequence
        ,l_asg_rec.assignment_type
        ,l_asg_rec.manager_flag
        ,l_asg_rec.primary_flag
        ,l_asg_rec.application_id
        ,l_asg_rec.assignment_number
        ,l_asg_rec.change_reason
        ,l_asg_rec.comment_id
        ,l_asg_rec.date_probation_end
        ,l_asg_rec.default_code_comb_id
        ,l_asg_rec.frequency
        ,l_asg_rec.internal_address_line
        ,l_asg_rec.normal_hours
        ,l_asg_rec.period_of_service_id
        ,l_asg_rec.probation_period
        ,l_asg_rec.probation_unit
        ,l_asg_rec.recruiter_id
        ,l_asg_rec.set_of_books_id
        ,l_asg_rec.special_ceiling_step_id
        ,l_asg_rec.supervisor_id
        ,l_asg_rec.time_normal_finish
        ,l_asg_rec.time_normal_start
        ,l_asg_rec.request_id
        ,l_asg_rec.program_application_id
        ,l_asg_rec.program_id
        ,l_asg_rec.program_update_date
        ,l_asg_rec.ass_attribute_category
        ,l_asg_rec.ass_attribute1
        ,l_asg_rec.ass_attribute2
        ,l_asg_rec.ass_attribute3
        ,l_asg_rec.ass_attribute4
        ,l_asg_rec.ass_attribute5
        ,l_asg_rec.ass_attribute6
        ,l_asg_rec.ass_attribute7
        ,l_asg_rec.ass_attribute8
        ,l_asg_rec.ass_attribute9
        ,l_asg_rec.ass_attribute10
        ,l_asg_rec.ass_attribute11
        ,l_asg_rec.ass_attribute12
        ,l_asg_rec.ass_attribute13
        ,l_asg_rec.ass_attribute14
        ,l_asg_rec.ass_attribute15
        ,l_asg_rec.ass_attribute16
        ,l_asg_rec.ass_attribute17
        ,l_asg_rec.ass_attribute18
        ,l_asg_rec.ass_attribute19
        ,l_asg_rec.ass_attribute20
        ,l_asg_rec.ass_attribute21
        ,l_asg_rec.ass_attribute22
        ,l_asg_rec.ass_attribute23
        ,l_asg_rec.ass_attribute24
        ,l_asg_rec.ass_attribute25
        ,l_asg_rec.ass_attribute26
        ,l_asg_rec.ass_attribute27
        ,l_asg_rec.ass_attribute28
        ,l_asg_rec.ass_attribute29
        ,l_asg_rec.ass_attribute30
        ,p_current_date
        ,p_user_id
        ,p_login_id
        ,l_asg_rec.created_by
        ,l_asg_rec.creation_date
        ,l_asg_rec.pay_basis_id
        ,l_asg_rec.person_referred_by_id
        ,l_asg_rec.recruitment_activity_id
        ,l_asg_rec.source_organization_id
        ,l_asg_rec.source_type
        ,l_asg_rec.employment_category            -- columns added Bug 978981
        ,l_asg_rec.perf_review_period
        ,l_asg_rec.perf_review_period_frequency
        ,l_asg_rec.sal_review_period
        ,l_asg_rec.sal_review_period_frequency
        ,l_asg_rec.bargaining_unit_code
        ,l_asg_rec.labour_union_member_flag
        ,l_asg_rec.hourly_salaried_code
        ,l_asg_rec.title
        ,l_asg_rec.job_post_source_name   -- added for 4486233
	,l_asg_rec.supervisor_assignment_id); ---#4053244
      exception
        when others then
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','make_secondary => ASGID: '
                                            ||to_char(l_asg_rec.assignment_id));
             hr_utility.set_message_token('STEP','2');
             hr_utility.raise_error;

      end;
      -- +----------- END end date of assignment -----------+
      -- +--------------------------------------------------+
      --
      -- +--------------------------------------------------+
      -- +--- Convert assignment into secondary ------------+
      -- +--------------------------------------------------+
      -- # 2582838
      -- Bug - 401669
      -- select all ass_attribute columns
      --
        l_ass_attribute1  := l_asg_rec.ass_attribute1;
        l_ass_attribute2  := l_asg_rec.ass_attribute2;
        l_ass_attribute3  := l_asg_rec.ass_attribute3;
        l_ass_attribute4  := l_asg_rec.ass_attribute4;
        l_ass_attribute5  := l_asg_rec.ass_attribute5;
        l_ass_attribute6  := l_asg_rec.ass_attribute6;
        l_ass_attribute7  := l_asg_rec.ass_attribute7;
        l_ass_attribute8  := l_asg_rec.ass_attribute8;
        l_ass_attribute9  := l_asg_rec.ass_attribute9;
        l_ass_attribute10 := l_asg_rec.ass_attribute10;
        l_ass_attribute11 := l_asg_rec.ass_attribute11;
        l_ass_attribute12 := l_asg_rec.ass_attribute12;
        l_ass_attribute13 := l_asg_rec.ass_attribute13;
        l_ass_attribute14 := l_asg_rec.ass_attribute14;
        l_ass_attribute15 := l_asg_rec.ass_attribute15;
        l_ass_attribute16 := l_asg_rec.ass_attribute16;
        l_ass_attribute17 := l_asg_rec.ass_attribute17;
        l_ass_attribute18 := l_asg_rec.ass_attribute18;
        l_ass_attribute19 := l_asg_rec.ass_attribute19;
        l_ass_attribute20 := l_asg_rec.ass_attribute20;
        l_ass_attribute21 := l_asg_rec.ass_attribute21;
        l_ass_attribute22 := l_asg_rec.ass_attribute22;
        l_ass_attribute23 := l_asg_rec.ass_attribute23;
        l_ass_attribute24 := l_asg_rec.ass_attribute24;
        l_ass_attribute25 := l_asg_rec.ass_attribute25;
        l_ass_attribute26 := l_asg_rec.ass_attribute26;
        l_ass_attribute27 := l_asg_rec.ass_attribute27;
        l_ass_attribute28 := l_asg_rec.ass_attribute28;
        l_ass_attribute29 := l_asg_rec.ass_attribute29;
        l_ass_attribute30 := l_asg_rec.ass_attribute30;

      open get_application_column_name;
      loop
      fetch get_application_column_name into l_app_col_name;
      exit when get_application_column_name%NOTFOUND;
        --
        if l_app_col_name = 'ASS_ATTRIBUTE1' then
        l_ass_attribute1 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE2' then
        l_ass_attribute2 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE3' then
        l_ass_attribute3 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE4' then
        l_ass_attribute4 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE5' then
        l_ass_attribute5 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE6' then
        l_ass_attribute6 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE7' then
        l_ass_attribute7 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE8' then
        l_ass_attribute8 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE9' then
        l_ass_attribute9 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE10' then
        l_ass_attribute10 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE11' then
        l_ass_attribute11 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE12' then
        l_ass_attribute12 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE13' then
        l_ass_attribute13 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE14' then
        l_ass_attribute14 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE15' then
        l_ass_attribute15 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE16' then
        l_ass_attribute16 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE17' then
        l_ass_attribute17 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE18' then
        l_ass_attribute18 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE19' then
        l_ass_attribute19 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE20' then
        l_ass_attribute20 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE21' then
        l_ass_attribute21 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE22' then
        l_ass_attribute22 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE23' then
        l_ass_attribute23 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE24' then
        l_ass_attribute24 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE25' then
        l_ass_attribute25 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE26' then
        l_ass_attribute26 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE27' then
        l_ass_attribute27 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE28' then
        l_ass_attribute28 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE29' then
        l_ass_attribute29 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE30' then
        l_ass_attribute30 := NULL;
        end if;
      end loop;
      --
      close get_application_column_name;
      -- +-----------------------------------------------------+
      --
      hrentmnt.check_payroll_changes_asg(p_assignment_id
                                  ,NULL
                                  ,'INSERT'
                                  ,p_start_date
                                  ,p_end_of_time);
      --
      -- Before doing the update make sure that what we are doing is valid
      -- especially for positions.
      --
      per_asg_bus1.chk_frozen_single_pos
        (p_assignment_id  => p_assignment_id,
         p_position_id    => l_asg_rec.position_id,
         p_effective_date => p_start_date);
      --
      --
      hr_assignment.gen_new_ass_sequence
                          ( p_person_id
                          , 'E'
                          , p_assignment_sequence
                          );
      --
      hr_assignment.gen_new_ass_number
                          (p_assignment_id
                          ,p_business_group_id
                          ,p_employee_number
                          ,p_assignment_sequence
                          ,p_assignment_number);
    --
      hr_utility.set_location('hrhirapl.make_secondary',402);
      begin
      update per_assignments_f pa
      set    pa.assignment_status_type_id = p_assignment_status_type_id
      ,      pa.assignment_type           = 'E'
      ,      pa.effective_start_date      = p_start_date
      ,      pa.effective_end_date        = p_end_of_time
      ,      pa.period_of_service_id      = v_period_of_service_id
      ,      pa.primary_flag              = 'N'
      ,      pa.assignment_number         = p_assignment_number
      ,      pa.assignment_sequence       = p_assignment_sequence
      ,      pa.last_update_date          = p_current_date
      ,      pa.last_updated_by           = p_user_id
      ,      pa.last_update_login         = p_login_id
      ,      pa.set_of_books_id           = p_set_of_books_id
      ,      pa.ass_attribute_category    = decode(l_col_name,'ASSIGNMENT_TYPE','E'
                                 ,pa.ass_attribute_category)
          ,	pa.ass_attribute1	= l_ass_attribute1
          ,	pa.ass_attribute2	= l_ass_attribute2
          ,	pa.ass_attribute3	= l_ass_attribute3
          ,	pa.ass_attribute4	= l_ass_attribute4
          ,	pa.ass_attribute5	= l_ass_attribute5
          ,	pa.ass_attribute6	= l_ass_attribute6
          ,	pa.ass_attribute7	= l_ass_attribute7
          ,	pa.ass_attribute8	= l_ass_attribute8
          ,	pa.ass_attribute9	= l_ass_attribute9
          ,	pa.ass_attribute10	= l_ass_attribute10
          ,	pa.ass_attribute11	= l_ass_attribute11
          ,	pa.ass_attribute12	= l_ass_attribute12
          ,	pa.ass_attribute13	= l_ass_attribute13
          ,	pa.ass_attribute14	= l_ass_attribute14
          ,	pa.ass_attribute15	= l_ass_attribute15
          ,	pa.ass_attribute16	= l_ass_attribute16
          ,	pa.ass_attribute17	= l_ass_attribute17
          ,	pa.ass_attribute18	= l_ass_attribute18
          ,	pa.ass_attribute19	= l_ass_attribute19
          ,	pa.ass_attribute20	= l_ass_attribute20
          ,	pa.ass_attribute21	= l_ass_attribute21
          ,	pa.ass_attribute22	= l_ass_attribute22
          ,	pa.ass_attribute23	= l_ass_attribute23
          ,	pa.ass_attribute24	= l_ass_attribute24
          ,	pa.ass_attribute25	= l_ass_attribute25
          ,	pa.ass_attribute26	= l_ass_attribute26
          ,	pa.ass_attribute27	= l_ass_attribute27
          ,	pa.ass_attribute28	= l_ass_attribute28
          ,	pa.ass_attribute29	= l_ass_attribute29
          ,	pa.ass_attribute30	= l_ass_attribute30
      where current of csr_ass_cur_for_primary;  -- pa.rowid = p_rowid;
      exception
        when others then
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','make_secondary => ASGID: '
                                            ||to_char(l_asg_rec.assignment_id));
             hr_utility.set_message_token('STEP','3');
             hr_utility.raise_error;

      end;
      -- Start of fix 3564129
       if l_asg_rec.vacancy_id is not null then --fix for bug8488222
      IRC_ASG_STATUS_API.create_irc_asg_status
                (p_assignment_id             => p_assignment_id
                ,p_assignment_status_type_id => p_assignment_status_type_id
                ,p_status_change_date        => p_session_date
                ,p_assignment_status_id      => l_asg_status_id
                ,p_object_version_number     => l_asg_status_ovn);
       end if;
      -- End of fix 3564129
      -- Bug 401669
      --
      hr_utility.set_location('hrhirapl.make_secondary',4);
      --
      hr_assignment.load_budget_values(p_assignment_id
                                      ,p_business_group_id
                                      ,p_user_id
                                      ,p_login_id
      		                          ,p_start_date
      		                          ,p_end_of_time
                                       );
      --
      hrentmnt.maintain_entries_asg(p_assignment_id
                               ,p_business_group_id
                               ,'HIRE_APPL'  -- ,'ASG_CRITERIA' for bug 5547271
                               ,NULL
                               ,NULL
                               ,NULL
                               ,'INSERT'
                               ,p_start_date
                               ,p_end_of_time);
      -- set assignment number back to null;
      p_assignment_number := NULL;
      -- +--------------------------------------------------+
      -- +--- END Convert assignment into secondary --------+
      -- +--------------------------------------------------+
      --
    -- Did user explicity choose END Date ?
    elsif hr_employee_applicant_api.end_date_exists(p_table
                                           ,l_asg_rec.assignment_id) = 1
    then
      -- +--------------------------------------------------+
      -- +--- End Date assignment --------------------------+
      -- +--------------------------------------------------+
      --
      hr_utility.set_location('hrhirapl.make_secondary',5);
      begin
        update per_assignments_f
          set effective_end_date = p_start_date -1
         where current of csr_ass_cur_for_primary;
      exception
        when others then
             hr_utility.set_location('hrhirapl.make_secondary ASGID : '||
                                        to_char(l_asg_rec.assignment_id),66);
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','make_secondary ');
             hr_utility.set_message_token('STEP','4');
             hr_utility.raise_error;
      end;
    end if; -- convert flag is set.
  --

  --added by amigarg for bug 4882512 start

   OPEN get_pay_proposal(l_asg_rec.assignment_id);
         FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date;
         if get_pay_proposal%found then
            close get_pay_proposal;
            hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                          p_validate                   => false,
                          p_pay_proposal_id            => l_pay_pspl_id ,
                          p_object_version_number      => l_pay_obj_number,
                          p_change_date                => p_start_date,
                          p_approved                   => 'Y',
                          p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                          p_proposed_salary_warning    => l_proposed_salary_warning,
                          p_approved_warning           => l_approved_warning,
                          p_payroll_warning            => l_payroll_warning,
                          p_proposed_salary_n          => l_proposed_sal_n,
                          p_business_group_id          => p_business_group_id);

         else
            close get_pay_proposal;
       end if;

  --added by amigarg for bug 4882512 end

  end loop;
--
  close csr_ass_cur_for_primary;

-- now process all seconday or non primary assignments


hr_utility.set_location('hrhirapl.make_secondary',403);
 open csr_ass_cur_for_nonprimary;
 loop
 fetch csr_ass_cur_for_nonprimary into l_asg_rec; --#2119831
 exit when csr_ass_cur_for_nonprimary%NOTFOUND;
  --
   -- #2483319
    p_assignment_id := l_asg_rec.assignment_id;
   --
   --
    -- Ensure (R)etain or (E)nd date flags have not been set
    if hr_employee_applicant_api.is_convert(p_table
                                       ,l_asg_rec.assignment_id)
    then
      hr_utility.set_location('hrhirapl.make_secondary',404);
      hr_utility.trace('    asg id     = '||to_char(l_asg_rec.assignment_id));
      hr_utility.trace('    start date = '||to_char(l_asg_rec.effective_start_date,'dd/mm/yy'));

      -- +--------------------------------------------------+
      -- +--- End Date assignment type 'A' -----------------+
      -- +--------------------------------------------------+
      begin
        insert into per_assignments_f
        (assignment_id
        ,effective_start_date
        ,effective_end_date
        ,business_group_id
        ,grade_id
        ,position_id
        ,job_id
        ,assignment_status_type_id
        ,payroll_id
        ,location_id
        ,person_id
        ,organization_id
        ,people_group_id
        ,soft_coding_keyflex_id
        ,vacancy_id
        ,assignment_sequence
        ,assignment_type
        ,manager_flag
        ,primary_flag
        ,application_id
        ,assignment_number
        ,change_reason
        ,comment_id
        ,date_probation_end
        ,default_code_comb_id
        ,frequency
        ,internal_address_line
        ,normal_hours
        ,period_of_service_id
        ,probation_period
        ,probation_unit
        ,recruiter_id
        ,set_of_books_id
        ,special_ceiling_step_id
        ,supervisor_id
        ,time_normal_finish
        ,time_normal_start
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
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,created_by
        ,creation_date
        ,pay_basis_id
        ,person_referred_by_id
        ,recruitment_activity_id
        ,source_organization_id
        ,source_type
        ,employment_category            -- columns added Bug 978981
        ,perf_review_period
        ,perf_review_period_frequency
        ,sal_review_period
        ,sal_review_period_frequency
        ,bargaining_unit_code
        ,labour_union_member_flag
        ,hourly_salaried_code
        ,title
        ,job_post_source_name   -- added for 4486233
	,supervisor_assignment_id) ---#4053244
         values
        (l_asg_rec.assignment_id
        ,l_asg_rec.effective_start_date
        ,p_start_date - 1
        ,l_asg_rec.business_group_id
        ,l_asg_rec.grade_id
        ,l_asg_rec.position_id
        ,l_asg_rec.job_id
        ,l_asg_rec.assignment_status_type_id
        ,l_asg_rec.payroll_id
        ,l_asg_rec.location_id
        ,l_asg_rec.person_id
        ,l_asg_rec.organization_id
        ,l_asg_rec.people_group_id
        ,l_asg_rec.soft_coding_keyflex_id
        ,l_asg_rec.vacancy_id
        ,l_asg_rec.assignment_sequence
        ,l_asg_rec.assignment_type
        ,l_asg_rec.manager_flag
        ,l_asg_rec.primary_flag
        ,l_asg_rec.application_id
        ,l_asg_rec.assignment_number
        ,l_asg_rec.change_reason
        ,l_asg_rec.comment_id
        ,l_asg_rec.date_probation_end
        ,l_asg_rec.default_code_comb_id
        ,l_asg_rec.frequency
        ,l_asg_rec.internal_address_line
        ,l_asg_rec.normal_hours
        ,l_asg_rec.period_of_service_id
        ,l_asg_rec.probation_period
        ,l_asg_rec.probation_unit
        ,l_asg_rec.recruiter_id
        ,l_asg_rec.set_of_books_id
        ,l_asg_rec.special_ceiling_step_id
        ,l_asg_rec.supervisor_id
        ,l_asg_rec.time_normal_finish
        ,l_asg_rec.time_normal_start
        ,l_asg_rec.request_id
        ,l_asg_rec.program_application_id
        ,l_asg_rec.program_id
        ,l_asg_rec.program_update_date
        ,l_asg_rec.ass_attribute_category
        ,l_asg_rec.ass_attribute1
        ,l_asg_rec.ass_attribute2
        ,l_asg_rec.ass_attribute3
        ,l_asg_rec.ass_attribute4
        ,l_asg_rec.ass_attribute5
        ,l_asg_rec.ass_attribute6
        ,l_asg_rec.ass_attribute7
        ,l_asg_rec.ass_attribute8
        ,l_asg_rec.ass_attribute9
        ,l_asg_rec.ass_attribute10
        ,l_asg_rec.ass_attribute11
        ,l_asg_rec.ass_attribute12
        ,l_asg_rec.ass_attribute13
        ,l_asg_rec.ass_attribute14
        ,l_asg_rec.ass_attribute15
        ,l_asg_rec.ass_attribute16
        ,l_asg_rec.ass_attribute17
        ,l_asg_rec.ass_attribute18
        ,l_asg_rec.ass_attribute19
        ,l_asg_rec.ass_attribute20
        ,l_asg_rec.ass_attribute21
        ,l_asg_rec.ass_attribute22
        ,l_asg_rec.ass_attribute23
        ,l_asg_rec.ass_attribute24
        ,l_asg_rec.ass_attribute25
        ,l_asg_rec.ass_attribute26
        ,l_asg_rec.ass_attribute27
        ,l_asg_rec.ass_attribute28
        ,l_asg_rec.ass_attribute29
        ,l_asg_rec.ass_attribute30
        ,p_current_date
        ,p_user_id
        ,p_login_id
        ,l_asg_rec.created_by
        ,l_asg_rec.creation_date
        ,l_asg_rec.pay_basis_id
        ,l_asg_rec.person_referred_by_id
        ,l_asg_rec.recruitment_activity_id
        ,l_asg_rec.source_organization_id
        ,l_asg_rec.source_type
        ,l_asg_rec.employment_category        -- columns added Bug 978981
        ,l_asg_rec.perf_review_period
        ,l_asg_rec.perf_review_period_frequency
        ,l_asg_rec.sal_review_period
        ,l_asg_rec.sal_review_period_frequency
        ,l_asg_rec.bargaining_unit_code
        ,l_asg_rec.labour_union_member_flag
        ,l_asg_rec.hourly_salaried_code
        ,l_asg_rec.title
        ,l_asg_rec.job_post_source_name   -- added for 4486233
	,l_asg_rec.supervisor_assignment_id); ---#4053244
      exception
        when others then
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','make_secondary => ASGID: '
                                            ||to_char(l_asg_rec.assignment_id));
             hr_utility.set_message_token('STEP','2');
             hr_utility.raise_error;

      end;
      -- +----------- END end date of assignment -----------+
      -- +--------------------------------------------------+
      --
      -- +--------------------------------------------------+
      -- +--- Convert assignment into secondary ------------+
      -- +--------------------------------------------------+
      -- # 2582838
      -- Bug - 401669
      -- select all ass_attribute columns
      --
        l_ass_attribute1  := l_asg_rec.ass_attribute1;
        l_ass_attribute2  := l_asg_rec.ass_attribute2;
        l_ass_attribute3  := l_asg_rec.ass_attribute3;
        l_ass_attribute4  := l_asg_rec.ass_attribute4;
        l_ass_attribute5  := l_asg_rec.ass_attribute5;
        l_ass_attribute6  := l_asg_rec.ass_attribute6;
        l_ass_attribute7  := l_asg_rec.ass_attribute7;
        l_ass_attribute8  := l_asg_rec.ass_attribute8;
        l_ass_attribute9  := l_asg_rec.ass_attribute9;
        l_ass_attribute10 := l_asg_rec.ass_attribute10;
        l_ass_attribute11 := l_asg_rec.ass_attribute11;
        l_ass_attribute12 := l_asg_rec.ass_attribute12;
        l_ass_attribute13 := l_asg_rec.ass_attribute13;
        l_ass_attribute14 := l_asg_rec.ass_attribute14;
        l_ass_attribute15 := l_asg_rec.ass_attribute15;
        l_ass_attribute16 := l_asg_rec.ass_attribute16;
        l_ass_attribute17 := l_asg_rec.ass_attribute17;
        l_ass_attribute18 := l_asg_rec.ass_attribute18;
        l_ass_attribute19 := l_asg_rec.ass_attribute19;
        l_ass_attribute20 := l_asg_rec.ass_attribute20;
        l_ass_attribute21 := l_asg_rec.ass_attribute21;
        l_ass_attribute22 := l_asg_rec.ass_attribute22;
        l_ass_attribute23 := l_asg_rec.ass_attribute23;
        l_ass_attribute24 := l_asg_rec.ass_attribute24;
        l_ass_attribute25 := l_asg_rec.ass_attribute25;
        l_ass_attribute26 := l_asg_rec.ass_attribute26;
        l_ass_attribute27 := l_asg_rec.ass_attribute27;
        l_ass_attribute28 := l_asg_rec.ass_attribute28;
        l_ass_attribute29 := l_asg_rec.ass_attribute29;
        l_ass_attribute30 := l_asg_rec.ass_attribute30;

      open get_application_column_name;
      loop
      fetch get_application_column_name into l_app_col_name;
      exit when get_application_column_name%NOTFOUND;
        --
        if l_app_col_name = 'ASS_ATTRIBUTE1' then
        l_ass_attribute1 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE2' then
        l_ass_attribute2 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE3' then
        l_ass_attribute3 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE4' then
        l_ass_attribute4 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE5' then
        l_ass_attribute5 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE6' then
        l_ass_attribute6 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE7' then
        l_ass_attribute7 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE8' then
        l_ass_attribute8 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE9' then
        l_ass_attribute9 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE10' then
        l_ass_attribute10 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE11' then
        l_ass_attribute11 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE12' then
        l_ass_attribute12 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE13' then
        l_ass_attribute13 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE14' then
        l_ass_attribute14 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE15' then
        l_ass_attribute15 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE16' then
        l_ass_attribute16 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE17' then
        l_ass_attribute17 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE18' then
        l_ass_attribute18 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE19' then
        l_ass_attribute19 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE20' then
        l_ass_attribute20 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE21' then
        l_ass_attribute21 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE22' then
        l_ass_attribute22 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE23' then
        l_ass_attribute23 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE24' then
        l_ass_attribute24 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE25' then
        l_ass_attribute25 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE26' then
        l_ass_attribute26 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE27' then
        l_ass_attribute27 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE28' then
        l_ass_attribute28 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE29' then
        l_ass_attribute29 := NULL;
        end if;
        if l_app_col_name = 'ASS_ATTRIBUTE30' then
        l_ass_attribute30 := NULL;
        end if;
      end loop;
      --
      close get_application_column_name;
      -- +-----------------------------------------------------+
      --
      hrentmnt.check_payroll_changes_asg(p_assignment_id
                                  ,NULL
                                  ,'INSERT'
                                  ,p_start_date
                                  ,p_end_of_time);
      --
      -- Before doing the update make sure that what we are doing is valid
      -- especially for positions.
      --
      per_asg_bus1.chk_frozen_single_pos
        (p_assignment_id  => p_assignment_id,
         p_position_id    => l_asg_rec.position_id,
         p_effective_date => p_start_date);
      --
      --
      hr_assignment.gen_new_ass_sequence
                          ( p_person_id
                          , 'E'
                          , p_assignment_sequence
                          );
      --
      hr_assignment.gen_new_ass_number
                          (p_assignment_id
                          ,p_business_group_id
                          ,p_employee_number
                          ,p_assignment_sequence
                          ,p_assignment_number);
    --
      hr_utility.set_location('hrhirapl.make_secondary',405);
      begin
      update per_assignments_f pa
      set    pa.assignment_status_type_id = p_assignment_status_type_id
      ,      pa.assignment_type           = 'E'
      ,      pa.effective_start_date      = p_start_date
      ,      pa.effective_end_date        = p_end_of_time
      ,      pa.period_of_service_id      = v_period_of_service_id
      ,      pa.primary_flag              = 'N'
      ,      pa.assignment_number         = p_assignment_number
      ,      pa.assignment_sequence       = p_assignment_sequence
      ,      pa.last_update_date          = p_current_date
      ,      pa.last_updated_by           = p_user_id
      ,      pa.last_update_login         = p_login_id
      ,      pa.set_of_books_id           = p_set_of_books_id
      ,      pa.ass_attribute_category    = decode(l_col_name,'ASSIGNMENT_TYPE','E'
                                 ,pa.ass_attribute_category)
          ,	pa.ass_attribute1	= l_ass_attribute1
          ,	pa.ass_attribute2	= l_ass_attribute2
          ,	pa.ass_attribute3	= l_ass_attribute3
          ,	pa.ass_attribute4	= l_ass_attribute4
          ,	pa.ass_attribute5	= l_ass_attribute5
          ,	pa.ass_attribute6	= l_ass_attribute6
          ,	pa.ass_attribute7	= l_ass_attribute7
          ,	pa.ass_attribute8	= l_ass_attribute8
          ,	pa.ass_attribute9	= l_ass_attribute9
          ,	pa.ass_attribute10	= l_ass_attribute10
          ,	pa.ass_attribute11	= l_ass_attribute11
          ,	pa.ass_attribute12	= l_ass_attribute12
          ,	pa.ass_attribute13	= l_ass_attribute13
          ,	pa.ass_attribute14	= l_ass_attribute14
          ,	pa.ass_attribute15	= l_ass_attribute15
          ,	pa.ass_attribute16	= l_ass_attribute16
          ,	pa.ass_attribute17	= l_ass_attribute17
          ,	pa.ass_attribute18	= l_ass_attribute18
          ,	pa.ass_attribute19	= l_ass_attribute19
          ,	pa.ass_attribute20	= l_ass_attribute20
          ,	pa.ass_attribute21	= l_ass_attribute21
          ,	pa.ass_attribute22	= l_ass_attribute22
          ,	pa.ass_attribute23	= l_ass_attribute23
          ,	pa.ass_attribute24	= l_ass_attribute24
          ,	pa.ass_attribute25	= l_ass_attribute25
          ,	pa.ass_attribute26	= l_ass_attribute26
          ,	pa.ass_attribute27	= l_ass_attribute27
          ,	pa.ass_attribute28	= l_ass_attribute28
          ,	pa.ass_attribute29	= l_ass_attribute29
          ,	pa.ass_attribute30	= l_ass_attribute30
      where current of csr_ass_cur_for_nonprimary;  -- pa.rowid = p_rowid;
      exception
        when others then
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','make_secondary => ASGID: '
                                            ||to_char(l_asg_rec.assignment_id));
             hr_utility.set_message_token('STEP','3');
             hr_utility.raise_error;

      end;
      -- Start of fix 3564129
      IRC_ASG_STATUS_API.create_irc_asg_status
                (p_assignment_id             => p_assignment_id
                ,p_assignment_status_type_id => p_assignment_status_type_id
                ,p_status_change_date        => p_session_date
                ,p_assignment_status_id      => l_asg_status_id
                ,p_object_version_number     => l_asg_status_ovn);
      -- End of fix 3564129
      -- Bug 401669
      --
      hr_utility.set_location('hrhirapl.make_secondary',406);
      --
      hr_assignment.load_budget_values(p_assignment_id
                                      ,p_business_group_id
                                      ,p_user_id
                                      ,p_login_id
      		                          ,p_start_date
      		                          ,p_end_of_time
                                       );
      --
      hrentmnt.maintain_entries_asg(p_assignment_id
                               ,p_business_group_id
                               ,'HIRE_APPL'  --,'ASG_CRITERIA' for bug 5547271
                               ,NULL
                               ,NULL
                               ,NULL
                               ,'INSERT'
                               ,p_start_date
                               ,p_end_of_time);
      -- set assignment number back to null;
      p_assignment_number := NULL;
      -- +--------------------------------------------------+
      -- +--- END Convert assignment into secondary --------+
      -- +--------------------------------------------------+
      --
    -- Did user explicity choose END Date ?
    elsif hr_employee_applicant_api.end_date_exists(p_table
                                           ,l_asg_rec.assignment_id) = 1
    then
      -- +--------------------------------------------------+
      -- +--- End Date assignment --------------------------+
      -- +--------------------------------------------------+
      --
      hr_utility.set_location('hrhirapl.make_secondary',407);
      begin
        update per_assignments_f
          set effective_end_date = p_start_date -1
         where current of csr_ass_cur_for_nonprimary;
      exception
        when others then
             hr_utility.set_location('hrhirapl.make_secondary ASGID : '||
                                        to_char(l_asg_rec.assignment_id),408);
             hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
             hr_utility.set_message_token('PROCEDURE','make_secondary ');
             hr_utility.set_message_token('STEP','4');
             hr_utility.raise_error;
      end;
    end if; -- convert flag is set.
  --

  --added by amigarg for bug 4882512 start

   OPEN get_pay_proposal(l_asg_rec.assignment_id);
         FETCH get_pay_proposal INTO l_pay_pspl_id,l_pay_obj_number,l_proposed_sal_n, l_dummy_change_date;
         if get_pay_proposal%found then
            close get_pay_proposal;
            hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                          p_validate                   => false,
                          p_pay_proposal_id            => l_pay_pspl_id ,
                          p_object_version_number      => l_pay_obj_number,
                          p_change_date                => p_start_date,
                          p_approved                   => 'Y',
                          p_inv_next_sal_date_warning  => l_inv_next_sal_date_warning,
                          p_proposed_salary_warning    => l_proposed_salary_warning,
                          p_approved_warning           => l_approved_warning,
                          p_payroll_warning            => l_payroll_warning,
                          p_proposed_salary_n          => l_proposed_sal_n,
                          p_business_group_id          => p_business_group_id);

         else
            close get_pay_proposal;
       end if;

  --added by amigarg for bug 4882512 end

  end loop;
--
  close csr_ass_cur_for_nonprimary;
hr_utility.set_location('hrhirapl.make_secondary',409);
end if;
hr_utility.set_location('hrhirapl.make_secondary',410);
-- end of bug 5498344
 commented for bug  5589928*/
--
-- add condition: number of updates should be the same as number
-- of inserts
/*
if ass_cur%ROWCOUNT > v_count  then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','make_secondary');
     hr_utility.set_message_token('STEP','2');
     hr_utility.raise_error;
end if;
*/
--
--
end make_secondary;
-- +-----------------------------------------------------------------------+
-- # 1769702
-- When deleting future assignments, need to verify this action
-- will not affect the element eligibility
-- nor pending assignments actions exist.

  procedure Verify_future_assignments(p_business_group_id IN INTEGER
                                     ,p_person_id IN INTEGER
                                     ,p_start_date IN DATE
                                     ) is
  --
     cursor fut_asg is
       select rowid, assignment_id, effective_start_date, effective_end_date
         from per_assignments_f
        where   primary_flag      = 'Y'
          and   business_group_id  + 0 = p_business_group_id
          and   person_id          = p_person_id
          and   assignment_type    = 'E'
          and   effective_start_date > p_start_date
        for update of effective_start_date;

    l_rowid ROWID;
    l_future_asg_id number;
    l_asg_start_date date;
    l_asg_end_date date;

  begin
    hr_utility.set_location('IN Verify future assignments',901);
    open fut_asg;
    loop
    fetch fut_asg into l_rowid, l_future_asg_id,l_asg_start_date, l_asg_end_date
;
    exit when fut_asg%NOTFOUND;

     begin

      hrentmnt.check_payroll_changes_asg(l_future_asg_id
                                      ,NULL
                                      ,'DELETE'
                                      ,l_asg_start_date
                                      ,l_asg_end_date);
            --
      hrentmnt.maintain_entries_asg(l_future_asg_id
                                   ,p_business_group_id
                                   ,'HIRE_APPL' -- ,'ASG_CRITERIA' for bug 5547271
                                   ,NULL
                                   ,NULL
                                   ,NULL
                                   ,'DELETE'
                                   ,l_asg_start_date
                                   ,l_asg_end_date);

     exception
       when others then
          close fut_asg;
          --
          -- Show any errors raised by previous routines
          --
          hr_utility.raise_error;
     end;
    end loop;
    close fut_asg;
    hr_utility.set_location('OUT Verify future assignments',903);
  end Verify_future_assignments;
--
--
-- +-----------------------------------------------------------------------+
PROCEDURE create_primary_assignment (p_business_group_id IN INTEGER
                                    ,p_person_id IN INTEGER
                                    ,p_new_primary_id IN INTEGER
                                    ,p_start_date IN DATE
                                    ,p_end_of_time IN DATE
                                    ,p_login_id IN INTEGER
                                    ,p_user_id IN INTEGER
                                    ,p_update_primary_flag IN VARCHAR2
                                    ,p_employee_number IN VARCHAR2
                                    ,p_set_of_books_id  IN INTEGER
                                    ,p_emp_apl IN VARCHAR2
                                    ) is
--
--  Create a new primary assignment.
--
--
p_assignment_number VARCHAR2(30);
p_assignment_sequence INTEGER;
p_rowid ROWID;
-- # 1769702
l_asg_end_date   date;
l_future_asg_id  number;
l_fut_start_date date;
l_fut_end_date   date;
--
l_grades_notequal varchar2(1) :='N'; -- bug 4736269
-- Bug 518669. Increased length of l_col_name from 30 to 200, so it matches
-- the max len of the column in the DB. Pashun. 16-Sep-97.
--
l_col_name VARCHAR2(200);
cursor get_flex_def is
select default_context_field_name
from fnd_descriptive_flexs
where application_id = 800 -- bug 5469726
and descriptive_flexfield_name = 'PER_ASSIGNMENTS';
--
-- VT 06/14/00
apl_asg_rec PER_ALL_ASSIGNMENTS_F%ROWTYPE;
emp_asg_rec PER_ALL_ASSIGNMENTS_F%ROWTYPE;
--
cursor cur_apl_asg is
select * from per_all_assignments_f paf
where paf.assignment_id = p_new_primary_id
 and paf.business_group_id +0 = p_business_group_id
 and p_start_date between paf.effective_start_date
 and paf.effective_end_date;
--
cursor cur_emp_asg is
select * from per_all_assignments_f paf
where paf.person_id = p_person_id
 and paf.business_group_id +0 = p_business_group_id
 -- #1981550
 and paf.primary_flag = 'Y'
 and paf.assignment_type = 'E'
 and p_start_date between paf.effective_start_date
 -- #1981550
 and paf.effective_end_date;

-- Added for the bug 6497082 starts here

l_assignment_status_type_id number;
l_assignment_status_id  irc_assignment_statuses.assignment_status_id%type;
l_asg_status_ovn irc_assignment_statuses.object_version_number%type;

-- Added for the bug 6497082 Ends here


 -- Added for the bug 6512520 starts here

    cursor get_pay_proposal(ass_id per_all_assignments_f.assignment_id%type) is
    select pay_proposal_id,object_version_number,proposed_salary_n, change_date
    from per_pay_proposals
    where assignment_id=ass_id
    and   approved = 'N'
    order by change_date desc;

    cursor get_pay_proposal_emp(ass_id per_all_assignments_f.assignment_id%type) is
    select pay_proposal_id,object_version_number,proposed_salary_n, change_date
    from per_pay_proposals
    where assignment_id=ass_id
    and   approved = 'N'
    order by change_date desc;

    l_apl_pay_pspl_id     per_pay_proposals.pay_proposal_id%TYPE;
    l_apl_pay_obj_number  per_pay_proposals.object_version_number%TYPE;
    l_apl_proposed_sal_n  per_pay_proposals.proposed_salary_n%TYPE;
    l_apl_dummy_change_date per_pay_proposals.change_date%TYPE;
    l_emp_pay_pspl_id     per_pay_proposals.pay_proposal_id%TYPE;
    l_emp_pay_obj_number  per_pay_proposals.object_version_number%TYPE;
    l_emp_proposed_sal_n  per_pay_proposals.proposed_salary_n%TYPE;
    l_emp_dummy_change_date per_pay_proposals.change_date%TYPE;
    l_emp_next_sal_date_warning  boolean := false;
    l_emp_proposed_salary_warning  boolean := false;
    l_emp_approved_warning  boolean := false;
    l_emp_payroll_warning  boolean := false;

 -- Added for the bug 6512520 ends here

--
-- # 1769702
-- These future dated assignments get deleted when updating
-- EMP primary assignment with APL details or converting the
-- APL assignment into primary.
--
  procedure Delete_future_assignments is
  --
     cursor fut_asg is
       select rowid, assignment_id, effective_start_date, effective_end_date
         from per_assignments_f
        where   primary_flag      = 'Y'
          and   business_group_id  + 0 = p_business_group_id
          and   person_id          = p_person_id
          and   assignment_type    = 'E'
          and   effective_start_date > p_start_date
        for update of effective_start_date;

    l_rowid ROWID;
    l_future_asg_id number;
    l_asg_start_date date;
    l_asg_end_date date;

  begin
    hr_utility.set_location('IN Delete future assignments',201);
    open fut_asg;
    loop
    fetch fut_asg into l_rowid, l_future_asg_id,l_asg_start_date, l_asg_end_date
;
    exit when fut_asg%NOTFOUND;

     begin

      delete from per_assignments_f
       where rowid = l_rowid;

     exception
       when others then
          close fut_asg;
          hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE','Delete_future_assignments');
          hr_utility.set_message_token('STEP','911');
          hr_utility.raise_error;
     end;
    end loop;
    close fut_asg;
    hr_utility.set_location('OUT Delete future assignments',203);
  end Delete_future_assignments;
--
--
begin
--
  hr_utility.set_location('hrhirapl.create_primary_assignment',1);
--
-- VT 06/14/00
open  cur_apl_asg;
fetch cur_apl_asg into apl_asg_rec;
close cur_apl_asg;
--
open  cur_emp_asg;
fetch cur_emp_asg into emp_asg_rec;
close cur_emp_asg;
--
  if p_update_primary_flag not in ('Y','V') then
    if p_emp_apl = 'Y' then
      begin
      -- #1769702
      Delete_future_assignments;
      --
      update per_assignments_f pa
      set pa.primary_flag = 'N'
      ,   pa.effective_start_date =p_start_date
      ,   pa.effective_end_date   = p_end_of_time
      ,   pa.last_update_login    = p_login_id
      ,   pa.last_updated_by      = p_user_id
      ,   pa.last_update_date     = p_start_date
      where pa.primary_flag       = 'Y'
      and   pa.business_group_id  + 0 = p_business_group_id
      and   pa.person_id          = p_person_id
      and   p_start_date between pa.effective_start_date
      and   pa.effective_end_date;
--
      if SQL%ROWCOUNT <1 then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','create_primary_assignment');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
      end if;
    end;
   end if;
--
  hr_utility.set_location('hrhirapl.create_primary_assignment',2);
--
    begin
--
--
hrentmnt.check_payroll_changes_asg(p_new_primary_id
                              ,NULL
                              ,'INSERT'
                              ,p_start_date
                              ,p_end_of_time);
--
  --
  -- Start of Fix for WWBUG 1485666.
  --
  -- Before doing the update make sure that what we are doing is valid
  -- especially for positions.
  --
  per_asg_bus1.chk_frozen_single_pos
    (p_assignment_id  => p_new_primary_id,
     p_position_id    => apl_asg_rec.position_id,
     p_effective_date => p_start_date,
     p_assignment_type => apl_asg_rec.assignment_type); -- 6356978
  --
  -- End of fix for WWBUG 1485666
  --
  -- Change Reason set to null since applicant change reason based on
  -- lookup APL_ASSIGN_REASON whereas employee change reason based on
  -- lookup EMP_CHANGE_REASON. The Two are not always compatible.
  -- WWBUG 1727576.
  -- Added clause pa.change_reason = null
  --
  -- Changed the value for set_of_books_if from p_set_of_books_id to
  -- emp_asg_rec.set_of_books_id bug #2398327

      update per_all_assignments_f pa
      set    pa.primary_flag = 'Y'
      ,      pa.effective_start_date = p_start_date
      ,      pa.effective_end_date = p_end_of_time
      ,      pa.set_of_books_id    = emp_asg_rec.set_of_books_id
      ,      pa.change_reason = null
      where  pa.business_group_id + 0 = p_business_group_id
      and    pa.assignment_id     = p_new_primary_id
      and    p_start_date between pa.effective_start_date
      and    pa.effective_end_date;
--
--
      if SQL%ROWCOUNT <1 then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','create_primary_assignment');
       hr_utility.set_message_token('STEP','2');
       hr_utility.raise_error;
      end if;
--
-- Bug #4462906 Moved the hrutility call
-- after SQL%ROWCOUNT check
--
     hr_utility.set_location('hrhirapl.employ_applicant',99);
--
hrentmnt.maintain_entries_asg(p_new_primary_id
                         ,p_business_group_id
                         ,'HIRE_APPL' -- ,'ASG_CRITERIA' for bug 5547271
                         ,NULL
                         ,NULL
                         ,NULL
                         ,'INSERT'
                         ,p_start_date
                         ,p_end_of_time);
    end;
  else
--
  hr_utility.set_location('hrhirapl.create_primary_assignment',3);
--

declare
--
-- 7120387

l_proj_hire_date date;
l_date_probation_end date;

cursor appl_rec_det1(l_appl_id number) is
   select projected_hire_date
   from per_applications
   where application_id =l_appl_id;

--7120387
--
  cursor ass_cur is
     select assignment_id
     ,      rowid
     ,      effective_end_date -- #1769702
     from   per_assignments_f pa
     where pa.primary_flag='Y'
     and   pa.person_id = p_person_id
     and   pa.business_group_id + 0 = p_business_group_id
     and   p_start_date between pa.effective_start_date
     and   pa.effective_end_date
     for update of pa.organization_id;

  -- variables l_prev_location_id, p_old_assignment_id, l_assignment_type added by sneelapa for bug 6409982
  l_prev_location_id    per_all_assignments_f.location_id%type;
  p_old_assignment_id   per_all_assignments_f.assignment_id%type;
  l_assignment_type     per_all_assignments_f.assignment_type%type;

  -- cursor cur_asg_type is declared by sneelapa for bug 6409982
  cursor cur_asg_type is
    select assignment_type
    from per_all_assignments_f paf
    where paf.assignment_id = p_old_assignment_id;

  --
  -- #1769702
  -- Need to update the future dated assignments
  --
  cursor future_ass_cur is
     select assignment_id
     ,      rowid
     ,      effective_start_date
     ,      effective_end_date
      from  per_assignments_f pa
     where  pa.primary_flag       = 'Y'
       and  pa.business_group_id  + 0 = p_business_group_id
       and  pa.person_id          = p_person_id
       and  pa.assignment_type    = 'E'
       and  pa.effective_start_date > p_start_date
     for update of pa.organization_id;
   --
 begin

 -- variable l_prev_location_id is added by sneelapa for bug 6409982
 l_prev_location_id	:= emp_asg_rec.location_id;

  open  get_flex_def;
  fetch get_flex_def into l_col_name;
  close get_flex_def;
  --
  open ass_cur;
  loop
  fetch ass_cur into p_assignment_id,p_rowid, l_asg_end_date; --#1769702
  exit when ass_cur%NOTFOUND;
  --
--
--
  -- VT 06/14/00
  if p_update_primary_flag = 'Y' then

       hr_utility.set_location('primary_flag =  Y',480);
       hr_utility.trace('    p_start_date  = '||to_char(p_start_date,'dd-MON-yyyy'));
       hr_utility.trace('    p_end_of_time = '||to_char(p_end_of_time,'dd-MON-yyyy'));
       hr_utility.trace('    assignment_id = '||to_char(p_assignment_id));
       hr_utility.trace('   l_asg_end_date = '||to_char(l_asg_end_date,'dd-MON-yyyy'));
     --
     -- Start of BEN Call
     -- Bug 3506363
     hr_utility.set_location('OAB Call',485);
     ben_dt_trgr_handle.assignment
	        (p_rowid                   => p_rowid
	        ,p_assignment_id           => p_assignment_id
	        ,p_business_group_id       => p_business_group_id
	 	    ,p_person_id               => p_person_id
	 	    ,p_effective_start_date    => p_start_date
	 	    ,p_effective_end_date      => p_end_of_time
	 	    ,p_assignment_status_type_id  => apl_asg_rec.assignment_status_type_id
	 	    ,p_assignment_type         => apl_asg_rec.assignment_type
	 	    ,p_organization_id         => apl_asg_rec.organization_id
	 	    ,p_primary_flag            => apl_asg_rec.primary_flag
	 	    ,p_change_reason           => apl_asg_rec.change_reason
	 	    ,p_employment_category     => apl_asg_rec.employment_category
	 	    ,p_frequency               => apl_asg_rec.frequency
	 	    ,p_grade_id                => apl_asg_rec.grade_id
	 	    ,p_job_id                  => apl_asg_rec.job_id
	 	    ,p_position_id             => apl_asg_rec.position_id
	 	    ,p_location_id             => apl_asg_rec.location_id
	 	    ,p_normal_hours            => apl_asg_rec.normal_hours
	 	    ,p_payroll_id              => apl_asg_rec.payroll_id
	 	    ,p_pay_basis_id            => apl_asg_rec.pay_basis_id
	 	    ,p_bargaining_unit_code    => apl_asg_rec.bargaining_unit_code
	 	    ,p_labour_union_member_flag => apl_asg_rec.labour_union_member_flag
	        ,p_hourly_salaried_code    => apl_asg_rec.hourly_salaried_code
	        ,p_people_group_id    => apl_asg_rec.people_group_id
	 	    ,p_ass_attribute1 => apl_asg_rec.ass_attribute1
	 	    ,p_ass_attribute2 => apl_asg_rec.ass_attribute2
	 	    ,p_ass_attribute3 => apl_asg_rec.ass_attribute3
	 	    ,p_ass_attribute4 => apl_asg_rec.ass_attribute4
	 	    ,p_ass_attribute5 => apl_asg_rec.ass_attribute5
	 	    ,p_ass_attribute6 => apl_asg_rec.ass_attribute6
	 	    ,p_ass_attribute7 => apl_asg_rec.ass_attribute7
	 	    ,p_ass_attribute8 => apl_asg_rec.ass_attribute8
	 	    ,p_ass_attribute9 => apl_asg_rec.ass_attribute9
	 	    ,p_ass_attribute10 => apl_asg_rec.ass_attribute10
	 	    ,p_ass_attribute11 => apl_asg_rec.ass_attribute11
	 	    ,p_ass_attribute12 => apl_asg_rec.ass_attribute12
	 	    ,p_ass_attribute13 => apl_asg_rec.ass_attribute13
	 	    ,p_ass_attribute14 => apl_asg_rec.ass_attribute14
	 	    ,p_ass_attribute15 => apl_asg_rec.ass_attribute15
	 	    ,p_ass_attribute16 => apl_asg_rec.ass_attribute16
	 	    ,p_ass_attribute17 => apl_asg_rec.ass_attribute17
	 	    ,p_ass_attribute18 => apl_asg_rec.ass_attribute18
	 	    ,p_ass_attribute19 => apl_asg_rec.ass_attribute19
	 	    ,p_ass_attribute20 => apl_asg_rec.ass_attribute20
	 	    ,p_ass_attribute21 => apl_asg_rec.ass_attribute21
	 	    ,p_ass_attribute22 => apl_asg_rec.ass_attribute22
	 	    ,p_ass_attribute23 => apl_asg_rec.ass_attribute23
	 	    ,p_ass_attribute24 => apl_asg_rec.ass_attribute24
	 	    ,p_ass_attribute25 => apl_asg_rec.ass_attribute25
	 	    ,p_ass_attribute26 => apl_asg_rec.ass_attribute26
	 	    ,p_ass_attribute27 => apl_asg_rec.ass_attribute27
	 	    ,p_ass_attribute28 => apl_asg_rec.ass_attribute28
	 	    ,p_ass_attribute29 => apl_asg_rec.ass_attribute29
	 	    ,p_ass_attribute30 => apl_asg_rec.ass_attribute30
            );
        hr_utility.set_location('After OAB Call',490);
     -- End of Bug 3506363
     -- End of BEN Call
      -- 7120387
  open appl_rec_det1(apl_asg_rec.application_id);
  fetch appl_rec_det1 into l_proj_hire_date;
  close appl_rec_det1;

   hr_utility.set_location('l_asg_probation_det.assignment_id :'|| apl_asg_rec.assignment_id,10);
   hr_utility.set_location('l_proj_hire_date :'||l_proj_hire_date,10);
   hr_utility.set_location('l_proj_hire_date :'||l_proj_hire_date,10);

   if l_proj_hire_date is null then -- proj hire date

        if ( apl_asg_rec.probation_period is not null)
           and
           (apl_asg_rec.probation_unit is not null ) then

           hr_utility.set_location('p_start_date :'||p_start_date,10);
          hr_utility.set_location('l_asg_probation_det.assignment_id :'||apl_asg_rec.assignment_id,10);
          hr_utility.set_location('l_asg_probation_det.probation_period :'||apl_asg_rec.probation_period,10);
          hr_utility.set_location('l_asg_probation_det.probation_unit :'||apl_asg_rec.probation_unit,10);
                l_date_probation_end :=NULL;
           hr_assignment.gen_probation_end
        (p_assignment_id      => apl_asg_rec.assignment_id
        ,p_probation_period   => apl_asg_rec.probation_period
        ,p_probation_unit     => apl_asg_rec.probation_unit
        ,p_start_date         => p_start_date
        ,p_date_probation_end => l_date_probation_end
        );
      hr_utility.set_location('l_date_probation_end :'||l_date_probation_end,10);
     apl_asg_rec.date_probation_end :=l_date_probation_end;

     end if;
   end if; --proj hire date

--7120387
--

       update per_assignments_f pa
       set pa.organization_id = apl_asg_rec.organization_id
       ,pa.effective_start_date = p_start_date
       ,pa.effective_end_date = p_end_of_time
       ,pa.recruiter_id = apl_asg_rec.recruiter_id
       ,pa.grade_id = apl_asg_rec.grade_id
       ,pa.position_id = apl_asg_rec.position_id
       ,pa.job_id = apl_asg_rec.job_id
       ,pa.payroll_id = apl_asg_rec.payroll_id
       ,pa.location_id = apl_asg_rec.location_id
       ,pa.person_referred_by_id = apl_asg_rec.person_referred_by_id
       ,pa.supervisor_id = apl_asg_rec.supervisor_id
       ,pa.supervisor_assignment_id = apl_asg_rec.supervisor_assignment_id -- #4053244
       ,pa.special_ceiling_step_id = apl_asg_rec.special_ceiling_step_id
       ,pa.recruitment_activity_id = apl_asg_rec.recruitment_activity_id
       ,pa.source_organization_id = apl_asg_rec.source_organization_id
       ,pa.people_group_id = apl_asg_rec.people_group_id
       ,pa.soft_coding_keyflex_id = apl_asg_rec.soft_coding_keyflex_id
       ,pa.vacancy_id = apl_asg_rec.vacancy_id
       ,pa.application_id = apl_asg_rec.application_id
       ,pa.comment_id = apl_asg_rec.comment_id
       ,pa.date_probation_end = apl_asg_rec.date_probation_end
       ,pa.default_code_comb_id = apl_asg_rec.default_code_comb_id
       ,pa.employment_category = apl_asg_rec.employment_category
       ,pa.frequency = apl_asg_rec.frequency
       ,pa.internal_address_line = apl_asg_rec.internal_address_line
       ,pa.manager_flag = apl_asg_rec.manager_flag
       ,pa.normal_hours = apl_asg_rec.normal_hours
       ,pa.probation_period = apl_asg_rec.probation_period
       ,pa.probation_unit = apl_asg_rec.probation_unit
       ,pa.set_of_books_id = p_set_of_books_id
       ,pa.source_type = apl_asg_rec.source_type
       ,pa.time_normal_finish = apl_asg_rec.time_normal_finish
       ,pa.time_normal_start = apl_asg_rec.time_normal_start
       ,pa.pay_basis_id = apl_asg_rec.pay_basis_id
       ,pa.ass_attribute_category = decode(l_col_name,'ASSIGNMENT_TYPE','E',pa.ass_attribute_category)
       ,pa.ass_attribute1 = apl_asg_rec.ass_attribute1
       ,pa.ass_attribute2 = apl_asg_rec.ass_attribute2
       ,pa.ass_attribute3 = apl_asg_rec.ass_attribute3
       ,pa.ass_attribute4 = apl_asg_rec.ass_attribute4
       ,pa.ass_attribute5 = apl_asg_rec.ass_attribute5
       ,pa.ass_attribute6 = apl_asg_rec.ass_attribute6
       ,pa.ass_attribute7 = apl_asg_rec.ass_attribute7
       ,pa.ass_attribute8 = apl_asg_rec.ass_attribute8
       ,pa.ass_attribute9 = apl_asg_rec.ass_attribute9
       ,pa.ass_attribute10 = apl_asg_rec.ass_attribute10
       ,pa.ass_attribute11 = apl_asg_rec.ass_attribute11
       ,pa.ass_attribute12 = apl_asg_rec.ass_attribute12
       ,pa.ass_attribute13 = apl_asg_rec.ass_attribute13
       ,pa.ass_attribute14 = apl_asg_rec.ass_attribute14
       ,pa.ass_attribute15 = apl_asg_rec.ass_attribute15
       ,pa.ass_attribute16 = apl_asg_rec.ass_attribute16
       ,pa.ass_attribute17 = apl_asg_rec.ass_attribute17
       ,pa.ass_attribute18 = apl_asg_rec.ass_attribute18
       ,pa.ass_attribute19 = apl_asg_rec.ass_attribute19
       ,pa.ass_attribute20 = apl_asg_rec.ass_attribute20
       ,pa.ass_attribute21 = apl_asg_rec.ass_attribute21
       ,pa.ass_attribute22 = apl_asg_rec.ass_attribute22
       ,pa.ass_attribute23 = apl_asg_rec.ass_attribute23
       ,pa.ass_attribute24 = apl_asg_rec.ass_attribute24
       ,pa.ass_attribute25 = apl_asg_rec.ass_attribute25
       ,pa.ass_attribute26 = apl_asg_rec.ass_attribute26
       ,pa.ass_attribute27 = apl_asg_rec.ass_attribute27
       ,pa.ass_attribute28 = apl_asg_rec.ass_attribute28
       ,pa.ass_attribute29 = apl_asg_rec.ass_attribute29
       ,pa.ass_attribute30 = apl_asg_rec.ass_attribute30
       ,pa.GRADE_LADDER_PGM_ID=apl_asg_rec.GRADE_LADDER_PGM_ID-- added for bug 5513751
       ,pa.EMPLOYEE_CATEGORY=apl_asg_rec.EMPLOYEE_CATEGORY--added for bug 5513751
       ,pa.COLLECTIVE_AGREEMENT_id=apl_asg_rec.COLLECTIVE_AGREEMENT_id-- added for bug 5513751
       where pa.rowid = p_rowid;
       --
-- Added for the bug 6497082 starts here

       hr_utility.set_location('### 3: hrhirapl.create_primary_assignment ',3979);
       hr_utility.set_location('### 3: hrhirapl.create_primary_assignment '||apl_asg_rec.assignment_status_type_id,3989);
       per_people3_pkg.get_default_person_type
      (p_required_type     => 'ACTIVE_ASSIGN'
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_person_type       => l_assignment_status_type_id
      );
      hr_utility.set_location('### 3: hrhirapl.create_primary_assignment '||l_assignment_status_type_id,3999);

-- Fix For Bug # 7046591 Starts. Added If Clause ---
if emp_asg_rec.vacancy_id is not null then
       IRC_ASG_STATUS_API.create_irc_asg_status
      (p_assignment_id             => emp_asg_rec.assignment_id
      ,p_assignment_status_type_id => l_assignment_status_type_id
      ,p_status_change_date        => p_start_date
      ,p_assignment_status_id      => l_assignment_status_id
      ,p_object_version_number     => l_asg_status_ovn);
end if;
-- Fix For Bug # 7046591 Ends. Added If Clause ---

-- Added for the bug 6497082 Ends here


       hr_utility.set_location('Updated EMP assignment',11);
       -- # 1769702

       --  add the  sal admin  call here
       -- Code for the bug 6512520 starts here
         OPEN get_pay_proposal(apl_asg_rec.assignment_id);
         FETCH get_pay_proposal
         INTO l_apl_pay_pspl_id,l_apl_pay_obj_number,l_apl_proposed_sal_n, l_apl_dummy_change_date;
         if get_pay_proposal%found then
--       close get_pay_proposal;

           OPEN  get_pay_proposal_emp(p_assignment_id);
           FETCH get_pay_proposal_emp
           INTO l_emp_pay_pspl_id,l_emp_pay_obj_number,l_emp_proposed_sal_n,
               l_emp_dummy_change_date;
               if get_pay_proposal_emp%found then
               close get_pay_proposal_emp ;

      -- fix for the bug 7636109  passing the value as null as requested by sal admin team.
            l_emp_pay_pspl_id:=null;
	     l_emp_pay_obj_number:=null;

	       hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                          p_validate                   => false,
                          p_pay_proposal_id            => l_emp_pay_pspl_id ,
                          p_object_version_number      => l_emp_pay_obj_number,
                           p_change_date                => p_start_date,
			 p_assignment_id              => p_assignment_id, -- bug 7636109

                          p_approved                   => 'Y',
                          p_inv_next_sal_date_warning  => l_emp_next_sal_date_warning,
                          p_proposed_salary_warning    => l_emp_proposed_salary_warning,
                          p_approved_warning           => l_emp_approved_warning,
                          p_payroll_warning            => l_emp_payroll_warning,
                          p_proposed_salary_n          => l_apl_proposed_sal_n,
                          p_business_group_id          => p_business_group_id);
           else
	      close get_pay_proposal_emp;
	      l_apl_pay_pspl_id:=null;
	      l_apl_pay_obj_number:=null;
              hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_apl_pay_pspl_id,
                        p_assignment_id              => p_assignment_id,
                        p_object_version_number      => l_apl_pay_obj_number,
                        p_change_date                => p_start_date,
                        p_approved                   => 'Y',
                        p_inv_next_sal_date_warning  => l_emp_next_sal_date_warning,
                        p_proposed_salary_warning    => l_emp_proposed_salary_warning,
                        p_approved_warning           => l_emp_approved_warning,
                        p_payroll_warning            => l_emp_payroll_warning,
                        p_proposed_salary_n          => l_apl_proposed_sal_n,
                        p_business_group_id          => p_business_group_id);
	  end if ;

	end if;
	close get_pay_proposal;
 -- Code for the bug 6512520 ends here
       Delete_future_assignments;
       --
  -- VT 06/14/00
  elsif p_update_primary_flag = 'V' then
    hr_utility.set_location('Overwrite EMP assignment',15);
    -- overwrite some columns from applicant assignment
    if apl_asg_rec.organization_id is not null then
      emp_asg_rec.organization_id := apl_asg_rec.organization_id;
    end if;
    if apl_asg_rec.recruiter_id is not null then
      emp_asg_rec.recruiter_id := apl_asg_rec.recruiter_id;
    end if;

    if apl_asg_rec.grade_id is not null then
       if (emp_asg_rec.grade_id is not null) and (apl_asg_rec.grade_id <> emp_asg_rec.grade_id) then
              l_grades_notequal:='Y';
	 end if; -- bug 4736269
      emp_asg_rec.grade_id := apl_asg_rec.grade_id;
    end if;
    if apl_asg_rec.position_id is not null then
      emp_asg_rec.position_id := apl_asg_rec.position_id;
    end if;
    if apl_asg_rec.job_id is not null then
      emp_asg_rec.job_id := apl_asg_rec.job_id;
    end if;
    if apl_asg_rec.payroll_id is not null then
      emp_asg_rec.payroll_id := apl_asg_rec.payroll_id;
    end if;
    if apl_asg_rec.location_id is not null then
      emp_asg_rec.location_id := apl_asg_rec.location_id;
    end if;
    if apl_asg_rec.person_referred_by_id is not null then
      emp_asg_rec.person_referred_by_id := apl_asg_rec.person_referred_by_id;
    end if;
    if apl_asg_rec.supervisor_id is not null then
      emp_asg_rec.supervisor_id := apl_asg_rec.supervisor_id;
    end if;
--- Fix of #4053244 start
    if apl_asg_rec.supervisor_assignment_id is not null then
      emp_asg_rec.supervisor_assignment_id := apl_asg_rec.supervisor_assignment_id;
    end if;
--- Fix of #4053244 end
    if apl_asg_rec.special_ceiling_step_id is not null then
      emp_asg_rec.special_ceiling_step_id := apl_asg_rec.special_ceiling_step_id;
    end if;
    if apl_asg_rec.recruitment_activity_id is not null then
      emp_asg_rec.recruitment_activity_id  := apl_asg_rec.recruitment_activity_id;
    end if;
    if apl_asg_rec.source_organization_id is not null then
      emp_asg_rec.source_organization_id := apl_asg_rec.source_organization_id;
    end if;
    --fix for bug 7119614 starts here.
    open c_pgp_segments(apl_asg_rec.people_group_id);
      fetch c_pgp_segments into l_pgp_segment1,
                                l_pgp_segment2,
                                l_pgp_segment3,
                                l_pgp_segment4,
                                l_pgp_segment5,
                                l_pgp_segment6,
                                l_pgp_segment7,
                                l_pgp_segment8,
                                l_pgp_segment9,
                                l_pgp_segment10,
                                l_pgp_segment11,
                                l_pgp_segment12,
                                l_pgp_segment13,
                                l_pgp_segment14,
                                l_pgp_segment15,
                                l_pgp_segment16,
                                l_pgp_segment17,
                                l_pgp_segment18,
                                l_pgp_segment19,
                                l_pgp_segment20,
                                l_pgp_segment21,
                                l_pgp_segment22,
                                l_pgp_segment23,
                                l_pgp_segment24,
                                l_pgp_segment25,
                                l_pgp_segment26,
                                l_pgp_segment27,
                                l_pgp_segment28,
                                l_pgp_segment29,
                                l_pgp_segment30;
    close c_pgp_segments;

    if apl_asg_rec.people_group_id is not null
       and (l_pgp_segment1 is not null
       or l_pgp_segment2  is not null
       or l_pgp_segment3  is not null
       or l_pgp_segment4  is not null
       or l_pgp_segment5  is not null
       or l_pgp_segment6  is not null
       or l_pgp_segment7  is not null
       or l_pgp_segment8  is not null
       or l_pgp_segment9  is not null
       or l_pgp_segment10 is not null
       or l_pgp_segment11 is not null
       or l_pgp_segment12 is not null
       or l_pgp_segment13 is not null
       or l_pgp_segment14 is not null
       or l_pgp_segment15 is not null
       or l_pgp_segment16 is not null
       or l_pgp_segment17 is not null
       or l_pgp_segment18 is not null
       or l_pgp_segment19 is not null
       or l_pgp_segment20 is not null
       or l_pgp_segment21 is not null
       or l_pgp_segment22 is not null
       or l_pgp_segment23 is not null
       or l_pgp_segment24 is not null
       or l_pgp_segment25 is not null
       or l_pgp_segment26 is not null
       or l_pgp_segment27 is not null
       or l_pgp_segment28 is not null
       or l_pgp_segment29 is not null
       or l_pgp_segment30 is not null)then

      emp_asg_rec.people_group_id := apl_asg_rec.people_group_id;
    end if;
    --fix for bug 7119614 ends here.
    if apl_asg_rec.soft_coding_keyflex_id is not null then
      emp_asg_rec.soft_coding_keyflex_id := apl_asg_rec.soft_coding_keyflex_id;
    end if;
    if apl_asg_rec.vacancy_id is not null then
      emp_asg_rec.vacancy_id := apl_asg_rec.vacancy_id;
    end if;
    if apl_asg_rec.application_id is not null then
      emp_asg_rec.application_id := apl_asg_rec.application_id;
    end if;
    if apl_asg_rec.comment_id is not null then
      emp_asg_rec.comment_id := apl_asg_rec.comment_id;
    end if;
    if apl_asg_rec.date_probation_end is not null then
      emp_asg_rec.date_probation_end  := apl_asg_rec.date_probation_end;
    end if;
    if apl_asg_rec.default_code_comb_id is not null then
      emp_asg_rec.default_code_comb_id := apl_asg_rec.default_code_comb_id;
    end if;
    if apl_asg_rec.employment_category is not null then
      emp_asg_rec.employment_category := apl_asg_rec.employment_category;
    end if;
    if apl_asg_rec.frequency is not null then
      emp_asg_rec.frequency := apl_asg_rec.frequency;
    end if;
    if apl_asg_rec.internal_address_line is not null then
      emp_asg_rec.internal_address_line := apl_asg_rec.internal_address_line;
    end if;
    if apl_asg_rec.manager_flag is not null then
      emp_asg_rec.manager_flag := apl_asg_rec.manager_flag;
    end if;
    if apl_asg_rec.normal_hours is not null then
      emp_asg_rec.normal_hours  := apl_asg_rec.normal_hours;
    end if;
    if apl_asg_rec.probation_period is not null then
      emp_asg_rec.probation_period := apl_asg_rec.probation_period;
    end if;
    if apl_asg_rec.probation_unit is not null then
      emp_asg_rec.probation_unit := apl_asg_rec.probation_unit;
    end if;
    if apl_asg_rec.source_type is not null then
      emp_asg_rec.source_type := apl_asg_rec.source_type;
    end if;
    if apl_asg_rec.time_normal_finish is not null then
      emp_asg_rec.time_normal_finish := apl_asg_rec.time_normal_finish;
    end if;
    if apl_asg_rec.time_normal_start is not null then
      emp_asg_rec.time_normal_start := apl_asg_rec.time_normal_start;
    end if;
    if apl_asg_rec.pay_basis_id is not null then
      emp_asg_rec.pay_basis_id := apl_asg_rec.pay_basis_id;
    end if;
    -- fix for the bug 5513751
     if apl_asg_rec.GRADE_LADDER_PGM_ID is not null then
      emp_asg_rec.GRADE_LADDER_PGM_ID := apl_asg_rec.GRADE_LADDER_PGM_ID;
    end if;
       if apl_asg_rec.EMPLOYEE_CATEGORY is not null then
      emp_asg_rec.EMPLOYEE_CATEGORY := apl_asg_rec.EMPLOYEE_CATEGORY;
    end if;
       if apl_asg_rec.COLLECTIVE_AGREEMENT_id is not null then
       hr_utility.set_location('Updated EMP assignment',90);
      emp_asg_rec.COLLECTIVE_AGREEMENT_id := apl_asg_rec.COLLECTIVE_AGREEMENT_id;
    end if;
    --  fix for the bug 5513751
    --
     -- 7120387
     --
  open appl_rec_det1(apl_asg_rec.application_id);
  fetch appl_rec_det1 into l_proj_hire_date;
  close appl_rec_det1;

   hr_utility.set_location('l_asg_probation_det.assignment_id :'|| apl_asg_rec.assignment_id,10);
   hr_utility.set_location('l_proj_hire_date :'||l_proj_hire_date,10);
   hr_utility.set_location('l_proj_hire_date :'||l_proj_hire_date,10);

   if l_proj_hire_date is null then -- proj hire date

        if ( apl_asg_rec.probation_period is not null)
           and
           (apl_asg_rec.probation_unit is not null ) then

           hr_utility.set_location('p_start_date :'||p_start_date,10);
          hr_utility.set_location('l_asg_probation_det.assignment_id :'||apl_asg_rec.assignment_id,10);
          hr_utility.set_location('l_asg_probation_det.probation_period :'||apl_asg_rec.probation_period,10);
          hr_utility.set_location('l_asg_probation_det.probation_unit :'||apl_asg_rec.probation_unit,10);
                l_date_probation_end :=NULL;
           hr_assignment.gen_probation_end
        (p_assignment_id      => apl_asg_rec.assignment_id
        ,p_probation_period   => apl_asg_rec.probation_period
        ,p_probation_unit     => apl_asg_rec.probation_unit
        ,p_start_date         => p_start_date
        ,p_date_probation_end => l_date_probation_end
        );
      hr_utility.set_location('l_date_probation_end :'||l_date_probation_end,10);
     apl_asg_rec.date_probation_end :=l_date_probation_end;
     emp_asg_rec.date_probation_end  := apl_asg_rec.date_probation_end;
     end if;
   end if; --proj hire date

  -- 7120387
  --
    -- # 2582838
    emp_asg_rec.ass_attribute1  := nvl(apl_asg_rec.ass_attribute1,emp_asg_rec.ass_attribute1);
    emp_asg_rec.ass_attribute2  := nvl(apl_asg_rec.ass_attribute2,emp_asg_rec.ass_attribute2);
    emp_asg_rec.ass_attribute3  := nvl(apl_asg_rec.ass_attribute3,emp_asg_rec.ass_attribute3);
    emp_asg_rec.ass_attribute4  := nvl(apl_asg_rec.ass_attribute4,emp_asg_rec.ass_attribute4);
    emp_asg_rec.ass_attribute5  := nvl(apl_asg_rec.ass_attribute5,emp_asg_rec.ass_attribute5);
    emp_asg_rec.ass_attribute6  := nvl(apl_asg_rec.ass_attribute6,emp_asg_rec.ass_attribute6);
    emp_asg_rec.ass_attribute7  := nvl(apl_asg_rec.ass_attribute7,emp_asg_rec.ass_attribute7);
    emp_asg_rec.ass_attribute8  := nvl(apl_asg_rec.ass_attribute8,emp_asg_rec.ass_attribute8);
    emp_asg_rec.ass_attribute9  := nvl(apl_asg_rec.ass_attribute9,emp_asg_rec.ass_attribute9);
    emp_asg_rec.ass_attribute10 := nvl(apl_asg_rec.ass_attribute10,emp_asg_rec.ass_attribute10);
    emp_asg_rec.ass_attribute11 := nvl(apl_asg_rec.ass_attribute11,emp_asg_rec.ass_attribute11);
    emp_asg_rec.ass_attribute12 := nvl(apl_asg_rec.ass_attribute12,emp_asg_rec.ass_attribute12);
    emp_asg_rec.ass_attribute13 := nvl(apl_asg_rec.ass_attribute13,emp_asg_rec.ass_attribute13);
    emp_asg_rec.ass_attribute14 := nvl(emp_asg_rec.ass_attribute14,apl_asg_rec.ass_attribute14);
    emp_asg_rec.ass_attribute15 := nvl(apl_asg_rec.ass_attribute15,emp_asg_rec.ass_attribute15);
    emp_asg_rec.ass_attribute16 := nvl(apl_asg_rec.ass_attribute16,emp_asg_rec.ass_attribute16);
    emp_asg_rec.ass_attribute17 := nvl(apl_asg_rec.ass_attribute17,emp_asg_rec.ass_attribute17);
    emp_asg_rec.ass_attribute18 := nvl(apl_asg_rec.ass_attribute18,emp_asg_rec.ass_attribute18);
    emp_asg_rec.ass_attribute19 := nvl(apl_asg_rec.ass_attribute19,emp_asg_rec.ass_attribute19);
    emp_asg_rec.ass_attribute20 := nvl(apl_asg_rec.ass_attribute20,emp_asg_rec.ass_attribute20);
    emp_asg_rec.ass_attribute21 := nvl(apl_asg_rec.ass_attribute21,emp_asg_rec.ass_attribute21);
    emp_asg_rec.ass_attribute22 := nvl(apl_asg_rec.ass_attribute22,emp_asg_rec.ass_attribute22);
    emp_asg_rec.ass_attribute23 := nvl(apl_asg_rec.ass_attribute23,emp_asg_rec.ass_attribute23);
    emp_asg_rec.ass_attribute24 := nvl(apl_asg_rec.ass_attribute24,emp_asg_rec.ass_attribute24);
    emp_asg_rec.ass_attribute25 := nvl(apl_asg_rec.ass_attribute25,emp_asg_rec.ass_attribute25);
    emp_asg_rec.ass_attribute26 := nvl(apl_asg_rec.ass_attribute26,emp_asg_rec.ass_attribute26);
    emp_asg_rec.ass_attribute27 := nvl(apl_asg_rec.ass_attribute27,emp_asg_rec.ass_attribute27);
    emp_asg_rec.ass_attribute28 := nvl(apl_asg_rec.ass_attribute28,emp_asg_rec.ass_attribute28);
    emp_asg_rec.ass_attribute29 := nvl(apl_asg_rec.ass_attribute29,emp_asg_rec.ass_attribute29);
    emp_asg_rec.ass_attribute30 := nvl(apl_asg_rec.ass_attribute30,emp_asg_rec.ass_attribute30);
    -- End # 2582838


	     -- Start of BEN Call
         -- Bug 3506363
		    hr_utility.set_location('Start OAB Call',487);
		     ben_dt_trgr_handle.assignment
			        (p_rowid                   => p_rowid
			        ,p_assignment_id           => p_assignment_id
			        ,p_business_group_id       => p_business_group_id
			 	    ,p_person_id               => p_person_id
			 	    ,p_effective_start_date    => p_start_date
			 	    ,p_effective_end_date      => p_end_of_time
			 	    ,p_assignment_status_type_id  => emp_asg_rec.assignment_status_type_id
			 	    ,p_assignment_type         => emp_asg_rec.assignment_type
			 	    ,p_organization_id         => emp_asg_rec.organization_id
			 	    ,p_primary_flag            => emp_asg_rec.primary_flag
			 	    ,p_change_reason           => emp_asg_rec.change_reason
			 	    ,p_employment_category     => emp_asg_rec.employment_category
			 	    ,p_frequency               => emp_asg_rec.frequency
			 	    ,p_grade_id                => emp_asg_rec.grade_id
			 	    ,p_job_id                  => emp_asg_rec.job_id
			 	    ,p_position_id             => emp_asg_rec.position_id
			 	    ,p_location_id             => emp_asg_rec.location_id
			 	    ,p_normal_hours            => emp_asg_rec.normal_hours
			 	    ,p_payroll_id              => emp_asg_rec.payroll_id
			 	    ,p_pay_basis_id            => emp_asg_rec.pay_basis_id
			 	    ,p_bargaining_unit_code    => emp_asg_rec.bargaining_unit_code
			 	    ,p_labour_union_member_flag => emp_asg_rec.labour_union_member_flag
			        ,p_hourly_salaried_code    => emp_asg_rec.hourly_salaried_code
			        ,p_people_group_id    => emp_asg_rec.people_group_id
			 	    ,p_ass_attribute1 => emp_asg_rec.ass_attribute1
			 	    ,p_ass_attribute2 => emp_asg_rec.ass_attribute2
			 	    ,p_ass_attribute3 => emp_asg_rec.ass_attribute3
			 	    ,p_ass_attribute4 => emp_asg_rec.ass_attribute4
			 	    ,p_ass_attribute5 => emp_asg_rec.ass_attribute5
			 	    ,p_ass_attribute6 => emp_asg_rec.ass_attribute6
			 	    ,p_ass_attribute7 => emp_asg_rec.ass_attribute7
			 	    ,p_ass_attribute8 => emp_asg_rec.ass_attribute8
			 	    ,p_ass_attribute9 => emp_asg_rec.ass_attribute9
			 	    ,p_ass_attribute10 => emp_asg_rec.ass_attribute10
			 	    ,p_ass_attribute11 => emp_asg_rec.ass_attribute11
			 	    ,p_ass_attribute12 => emp_asg_rec.ass_attribute12
			 	    ,p_ass_attribute13 => emp_asg_rec.ass_attribute13
			 	    ,p_ass_attribute14 => emp_asg_rec.ass_attribute14
			 	    ,p_ass_attribute15 => emp_asg_rec.ass_attribute15
			 	    ,p_ass_attribute16 => emp_asg_rec.ass_attribute16
			 	    ,p_ass_attribute17 => emp_asg_rec.ass_attribute17
			 	    ,p_ass_attribute18 => emp_asg_rec.ass_attribute18
			 	    ,p_ass_attribute19 => emp_asg_rec.ass_attribute19
			 	    ,p_ass_attribute20 => emp_asg_rec.ass_attribute20
			 	    ,p_ass_attribute21 => emp_asg_rec.ass_attribute21
			 	    ,p_ass_attribute22 => emp_asg_rec.ass_attribute22
			 	    ,p_ass_attribute23 => emp_asg_rec.ass_attribute23
			 	    ,p_ass_attribute24 => emp_asg_rec.ass_attribute24
			 	    ,p_ass_attribute25 => emp_asg_rec.ass_attribute25
			 	    ,p_ass_attribute26 => emp_asg_rec.ass_attribute26
			 	    ,p_ass_attribute27 => emp_asg_rec.ass_attribute27
			 	    ,p_ass_attribute28 => emp_asg_rec.ass_attribute28
			 	    ,p_ass_attribute29 => emp_asg_rec.ass_attribute29
			 	    ,p_ass_attribute30 => emp_asg_rec.ass_attribute30
		            );
        hr_utility.set_location('End of OAB Call',489);
     -- End of Bug 3506363
     -- End of BEN Call

    --
     hr_utility.set_location('hrhirapl.create_primary_assignment',10);

      --
  -- Changed the value for set_of_books_if from p_set_of_books_id to
  -- emp_asg_rec.set_of_books_id bug #2398327

       update per_assignments_f pa
       set pa.organization_id = emp_asg_rec.organization_id
       ,pa.effective_start_date = p_start_date
       --,pa.effective_end_date = p_end_of_time -- #1769702 what if future asg exist?
       ,pa.recruiter_id = emp_asg_rec.recruiter_id
       ,pa.grade_id = emp_asg_rec.grade_id
       ,pa.position_id = emp_asg_rec.position_id
       ,pa.job_id = emp_asg_rec.job_id
       ,pa.payroll_id = emp_asg_rec.payroll_id
       ,pa.location_id = emp_asg_rec.location_id
       ,pa.person_referred_by_id = emp_asg_rec.person_referred_by_id
       ,pa.supervisor_id = emp_asg_rec.supervisor_id
       ,pa.supervisor_assignment_id = emp_asg_rec.supervisor_assignment_id -- #4053244
       ,pa.special_ceiling_step_id = emp_asg_rec.special_ceiling_step_id
       ,pa.recruitment_activity_id = emp_asg_rec.recruitment_activity_id
       ,pa.source_organization_id = emp_asg_rec.source_organization_id
       ,pa.people_group_id = emp_asg_rec.people_group_id
       ,pa.soft_coding_keyflex_id = emp_asg_rec.soft_coding_keyflex_id
       ,pa.vacancy_id = emp_asg_rec.vacancy_id
       ,pa.application_id = emp_asg_rec.application_id
       ,pa.comment_id = emp_asg_rec.comment_id
       ,pa.date_probation_end = emp_asg_rec.date_probation_end
       ,pa.default_code_comb_id = emp_asg_rec.default_code_comb_id
       ,pa.employment_category = emp_asg_rec.employment_category
       ,pa.frequency = emp_asg_rec.frequency
       ,pa.internal_address_line = emp_asg_rec.internal_address_line
       ,pa.manager_flag = emp_asg_rec.manager_flag
       ,pa.normal_hours = emp_asg_rec.normal_hours
       ,pa.probation_period = emp_asg_rec.probation_period
       ,pa.probation_unit = emp_asg_rec.probation_unit
       ,pa.set_of_books_id = emp_asg_rec.set_of_books_id
       ,pa.source_type = emp_asg_rec.source_type
       ,pa.time_normal_finish = emp_asg_rec.time_normal_finish
       ,pa.time_normal_start = emp_asg_rec.time_normal_start
       ,pa.pay_basis_id = emp_asg_rec.pay_basis_id
       ,pa.ass_attribute_category = decode(l_col_name,'ASSIGNMENT_TYPE','E',pa.ass_attribute_category)
       ,pa.ass_attribute1 = emp_asg_rec.ass_attribute1
       ,pa.ass_attribute2 = emp_asg_rec.ass_attribute2
       ,pa.ass_attribute3 = emp_asg_rec.ass_attribute3
       ,pa.ass_attribute4 = emp_asg_rec.ass_attribute4
       ,pa.ass_attribute5 = emp_asg_rec.ass_attribute5
       ,pa.ass_attribute6 = emp_asg_rec.ass_attribute6
       ,pa.ass_attribute7 = emp_asg_rec.ass_attribute7
       ,pa.ass_attribute8 = emp_asg_rec.ass_attribute8
       ,pa.ass_attribute9 = emp_asg_rec.ass_attribute9
       ,pa.ass_attribute10 = emp_asg_rec.ass_attribute10
       ,pa.ass_attribute11 = emp_asg_rec.ass_attribute11
       ,pa.ass_attribute12 = emp_asg_rec.ass_attribute12
       ,pa.ass_attribute13 = emp_asg_rec.ass_attribute13
       ,pa.ass_attribute14 = emp_asg_rec.ass_attribute14
       ,pa.ass_attribute15 = emp_asg_rec.ass_attribute15
       ,pa.ass_attribute16 = emp_asg_rec.ass_attribute16
       ,pa.ass_attribute17 = emp_asg_rec.ass_attribute17
       ,pa.ass_attribute18 = emp_asg_rec.ass_attribute18
       ,pa.ass_attribute19 = emp_asg_rec.ass_attribute19
       ,pa.ass_attribute20 = emp_asg_rec.ass_attribute20
       ,pa.ass_attribute21 = emp_asg_rec.ass_attribute21
       ,pa.ass_attribute22 = emp_asg_rec.ass_attribute22
       ,pa.ass_attribute23 = emp_asg_rec.ass_attribute23
       ,pa.ass_attribute24 = emp_asg_rec.ass_attribute24
       ,pa.ass_attribute25 = emp_asg_rec.ass_attribute25
       ,pa.ass_attribute26 = emp_asg_rec.ass_attribute26
       ,pa.ass_attribute27 = emp_asg_rec.ass_attribute27
       ,pa.ass_attribute28 = emp_asg_rec.ass_attribute28
       ,pa.ass_attribute29 = emp_asg_rec.ass_attribute29
       ,pa.ass_attribute30 = emp_asg_rec.ass_attribute30
       ,pa.GRADE_LADDER_PGM_ID= emp_asg_rec.GRADE_LADDER_PGM_ID --  5513751
       ,pa.EMPLOYEE_CATEGORY= emp_asg_rec.EMPLOYEE_CATEGORY -- 5513751
       ,pa.COLLECTIVE_AGREEMENT_id= emp_asg_rec.COLLECTIVE_AGREEMENT_id  -- 5513751
       where pa.rowid = p_rowid;
       --
-- Added for the bug 6497082 starts here

       hr_utility.set_location('### 4: hrhirapl.create_primary_assignment',3981);
       hr_utility.set_location('### 4: hrhirapl.create_primary_assignment'||emp_asg_rec.assignment_status_type_id,3991);
       per_people3_pkg.get_default_person_type
      (p_required_type     => 'ACTIVE_ASSIGN'
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_person_type       => l_assignment_status_type_id
      );

-- Fix For Bug # 7046591 Starts. Added If Clause ---
if emp_asg_rec.vacancy_id is not null then
       IRC_ASG_STATUS_API.create_irc_asg_status
      (p_assignment_id             => emp_asg_rec.assignment_id
      ,p_assignment_status_type_id => l_assignment_status_type_id
      ,p_status_change_date        => p_start_date
      ,p_assignment_status_id      => l_assignment_status_id
      ,p_object_version_number     => l_asg_status_ovn);
end if;
-- Fix For Bug # 7046591 Ends. Added If Clause ---

-- Added for the bug 6497082 Ends here

       -- #1769702

       -- Code for the bug 6512520 starts here
         OPEN get_pay_proposal(apl_asg_rec.assignment_id);
         FETCH get_pay_proposal
         INTO l_apl_pay_pspl_id,l_apl_pay_obj_number,l_apl_proposed_sal_n, l_apl_dummy_change_date;
         if get_pay_proposal%found then
--       close get_pay_proposal;

           OPEN  get_pay_proposal_emp(p_assignment_id);
           FETCH get_pay_proposal_emp
           INTO l_emp_pay_pspl_id,l_emp_pay_obj_number,l_emp_proposed_sal_n,
               l_emp_dummy_change_date;
               if get_pay_proposal_emp%found then
               close get_pay_proposal_emp ;


      -- fix for the bug 7636109  passing the value as null as requested by sal admin team.
            l_emp_pay_pspl_id:=null;
	     l_emp_pay_obj_number:=null;

	       hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                          p_validate                   => false,
                          p_pay_proposal_id            => l_emp_pay_pspl_id ,
                          p_object_version_number      => l_emp_pay_obj_number,
			  p_assignment_id              => p_assignment_id, -- bug7636109
                          p_change_date                => p_start_date,
			  p_approved                   => 'Y',
                          p_inv_next_sal_date_warning  => l_emp_next_sal_date_warning,
                          p_proposed_salary_warning    => l_emp_proposed_salary_warning,
                          p_approved_warning           => l_emp_approved_warning,
                          p_payroll_warning            => l_emp_payroll_warning,
                          p_proposed_salary_n          => l_apl_proposed_sal_n,
                          p_business_group_id          => p_business_group_id);
           else
	      close get_pay_proposal_emp;
	      l_apl_pay_pspl_id:=null;
	      l_apl_pay_obj_number:=null;
              hr_maintain_proposal_api.cre_or_upd_salary_proposal(
                        p_validate                   => false,
                        p_pay_proposal_id            => l_apl_pay_pspl_id,
                        p_assignment_id              => p_assignment_id,
                        p_object_version_number      => l_apl_pay_obj_number,
                        p_change_date                => p_start_date,
                        p_approved                   => 'Y',
                        p_inv_next_sal_date_warning  => l_emp_next_sal_date_warning,
                        p_proposed_salary_warning    => l_emp_proposed_salary_warning,
                        p_approved_warning           => l_emp_approved_warning,
                        p_payroll_warning            => l_emp_payroll_warning,
                        p_proposed_salary_n          => l_apl_proposed_sal_n,
                        p_business_group_id          => p_business_group_id);
	  end if ;

	end if;
	close get_pay_proposal;
 -- Code for the bug 6512520 ends here

       -- All future dated assignments should get ovewritten.
       --
       hr_utility.set_location('IN Overwrite future dated assignments',14);
         open future_ass_cur;
         loop
         fetch future_ass_cur into l_future_asg_id,p_rowid
                                  ,l_fut_start_date, l_fut_end_date;
         exit when future_ass_cur%NOTFOUND;

  -- Changed the value for set_of_books_if from p_set_of_books_id to
  -- emp_asg_rec.set_of_books_id bug #2398327

           update per_assignments_f pa
           set pa.organization_id = emp_asg_rec.organization_id
           ,pa.recruiter_id = emp_asg_rec.recruiter_id
           ,pa.grade_id = emp_asg_rec.grade_id
           ,pa.position_id = emp_asg_rec.position_id
           ,pa.job_id = emp_asg_rec.job_id
           ,pa.payroll_id = emp_asg_rec.payroll_id
           ,pa.location_id = emp_asg_rec.location_id
           ,pa.person_referred_by_id = emp_asg_rec.person_referred_by_id
           ,pa.supervisor_id = emp_asg_rec.supervisor_id
	   ,pa.supervisor_assignment_id = emp_asg_rec.supervisor_assignment_id -- #4053244
           ,pa.special_ceiling_step_id = emp_asg_rec.special_ceiling_step_id
           ,pa.recruitment_activity_id = emp_asg_rec.recruitment_activity_id
           ,pa.source_organization_id = emp_asg_rec.source_organization_id
           ,pa.people_group_id = emp_asg_rec.people_group_id
           ,pa.soft_coding_keyflex_id = emp_asg_rec.soft_coding_keyflex_id
           ,pa.vacancy_id = emp_asg_rec.vacancy_id
           ,pa.application_id = emp_asg_rec.application_id
           ,pa.comment_id = emp_asg_rec.comment_id
           ,pa.date_probation_end = emp_asg_rec.date_probation_end
           ,pa.default_code_comb_id = emp_asg_rec.default_code_comb_id
           ,pa.employment_category = emp_asg_rec.employment_category
           ,pa.frequency = emp_asg_rec.frequency
           ,pa.internal_address_line = emp_asg_rec.internal_address_line
           ,pa.manager_flag = emp_asg_rec.manager_flag
           ,pa.normal_hours = emp_asg_rec.normal_hours
           ,pa.probation_period = emp_asg_rec.probation_period
           ,pa.probation_unit = emp_asg_rec.probation_unit
           ,pa.set_of_books_id = emp_asg_rec.set_of_books_id
           ,pa.source_type = emp_asg_rec.source_type
           ,pa.time_normal_finish = emp_asg_rec.time_normal_finish
           ,pa.time_normal_start = emp_asg_rec.time_normal_start
           ,pa.pay_basis_id = emp_asg_rec.pay_basis_id
           ,pa.ass_attribute_category = decode(l_col_name,'ASSIGNMENT_TYPE','E',pa.ass_attribute_category)
           ,pa.ass_attribute1 = emp_asg_rec.ass_attribute1
           ,pa.ass_attribute2 = emp_asg_rec.ass_attribute2
           ,pa.ass_attribute3 = emp_asg_rec.ass_attribute3
           ,pa.ass_attribute4 = emp_asg_rec.ass_attribute4
           ,pa.ass_attribute5 = emp_asg_rec.ass_attribute5
           ,pa.ass_attribute6 = emp_asg_rec.ass_attribute6
           ,pa.ass_attribute7 = emp_asg_rec.ass_attribute7
           ,pa.ass_attribute8 = emp_asg_rec.ass_attribute8
           ,pa.ass_attribute9 = emp_asg_rec.ass_attribute9
           ,pa.ass_attribute10 = emp_asg_rec.ass_attribute10
           ,pa.ass_attribute11 = emp_asg_rec.ass_attribute11
           ,pa.ass_attribute12 = emp_asg_rec.ass_attribute12
           ,pa.ass_attribute13 = emp_asg_rec.ass_attribute13
           ,pa.ass_attribute14 = emp_asg_rec.ass_attribute14
           ,pa.ass_attribute15 = emp_asg_rec.ass_attribute15
           ,pa.ass_attribute16 = emp_asg_rec.ass_attribute16
           ,pa.ass_attribute17 = emp_asg_rec.ass_attribute17
           ,pa.ass_attribute18 = emp_asg_rec.ass_attribute18
           ,pa.ass_attribute19 = emp_asg_rec.ass_attribute19
           ,pa.ass_attribute20 = emp_asg_rec.ass_attribute20
           ,pa.ass_attribute21 = emp_asg_rec.ass_attribute21
           ,pa.ass_attribute22 = emp_asg_rec.ass_attribute22
           ,pa.ass_attribute23 = emp_asg_rec.ass_attribute23
           ,pa.ass_attribute24 = emp_asg_rec.ass_attribute24
           ,pa.ass_attribute25 = emp_asg_rec.ass_attribute25
           ,pa.ass_attribute26 = emp_asg_rec.ass_attribute26
           ,pa.ass_attribute27 = emp_asg_rec.ass_attribute27
           ,pa.ass_attribute28 = emp_asg_rec.ass_attribute28
           ,pa.ass_attribute29 = emp_asg_rec.ass_attribute29
           ,pa.ass_attribute30 = emp_asg_rec.ass_attribute30
	   ,pa.GRADE_LADDER_PGM_ID= emp_asg_rec.GRADE_LADDER_PGM_ID --  5513751
           ,pa.EMPLOYEE_CATEGORY= emp_asg_rec.EMPLOYEE_CATEGORY -- 5513751
           ,pa.COLLECTIVE_AGREEMENT_id= emp_asg_rec.COLLECTIVE_AGREEMENT_id  -- 5513751
           where pa.rowid = p_rowid;
           --
           hrentmnt.check_payroll_changes_asg(l_future_asg_id
                                             ,NULL
                                             ,'INSERT'
                                             ,l_fut_start_date
                                             ,l_fut_end_date);
            --
            hrentmnt.maintain_entries_asg(l_future_asg_id
                                         ,p_business_group_id
                                         ,'HIRE_APPL' -- ,'ASG_CRITERIA' for bug 5547271
                                         ,NULL
                                         ,NULL
                                         ,NULL
                                         ,'INSERT'
                                         ,l_fut_start_date
                                         ,l_fut_end_date);
            -- #2433154
            -- US Leg: Tax records might need to be updated
            --

            -- and l_prev_location_id <> apl_asg_rec.location_id condition
            --      added by sneelapa for bug 6409982.

            if p_legislation_code = 'US'
		and l_prev_location_id <> apl_asg_rec.location_id then

               hr_utility.set_location('Updating tax records..',16);

		 -- code added by sneelapa for bug 6409982 starts
                p_old_assignment_id := l_future_asg_id;

                open  cur_asg_type;
                fetch cur_asg_type into l_assignment_type;
                close cur_asg_type;

                if l_assignment_type <> 'B' then
                -- code added by sneelapa for bug 6409982 ends

		       pay_us_emp_dt_tax_rules.default_tax_with_validation
			      (p_assignment_id        => l_future_asg_id
			      ,p_person_id            => p_person_id
			      ,p_effective_start_date => l_fut_start_date
			      ,p_effective_end_date   => l_fut_end_date
			      ,p_session_date         => l_fut_start_date
			      ,p_business_group_id    => p_business_group_id
			      ,p_from_form            => 'Assignment'
			      ,p_mode                 => 'UPDATE'
			      ,p_location_id          => emp_asg_rec.location_id
			      ,p_return_code          => l_return_code
			      ,p_return_text          => l_return_text
			       );
		       hr_utility.set_location('END Updating tax records..',17);
		end if;
            end if; -- leg=US
            -- end 2433154
            --
         end loop; -- updating future dated assignments
         close future_ass_cur; -- fix for bug#3057451
         -- # 1769702
       hr_utility.set_location('OUT Overwrite future dated assignments',18);
  else
    null;
  end if;
-- Start of bug fix 2933750
-- Start of bug 3631834
  if (apl_asg_rec.grade_id <> emp_asg_rec.grade_id) or
     (apl_asg_rec.grade_id is null and emp_asg_rec.grade_id is not null)
      or (l_grades_notequal='Y') then -- bug 4736269
-- End of bug 3631834
     hr_assignment_internal.maintain_spp_asg(
                            p_assignment_id         => p_assignment_id,
                            p_datetrack_mode        => hr_api.g_update,
                            p_validation_start_date => p_start_date,
                            p_validation_end_date   => p_end_of_time,
                            p_grade_id              => apl_asg_rec.grade_id,
                            p_spp_delete_warning    => l_delete_warn);
  end if;
--
-- End of fix 2933750
--
        hrentmnt.check_payroll_changes_asg(p_assignment_id
                              ,NULL
                              ,'INSERT'
                              ,p_start_date
                              ,l_asg_end_date); -- #1769702
--
  --
  -- Before doing the update make sure that what we are doing is valid
  -- especially for positions.
  --
  per_asg_bus1.chk_frozen_single_pos
    (p_assignment_id  => p_assignment_id,
     p_position_id    => apl_asg_rec.position_id,
     p_effective_date => p_start_date,
     p_assignment_type => emp_asg_rec.assignment_type); -- 7348032
     --p_assignment_type => apl_asg_rec.assignment_type); -- 6356978
  --
        hrentmnt.maintain_entries_asg(p_assignment_id
                                 ,p_business_group_id
                                 ,'HIRE_APPL'  --,'ASG_CRITERIA' for bug 5547271
                                 ,NULL
                                 ,NULL
                                 ,NULL
                                 ,'INSERT'
                                 ,p_start_date
                                 ,l_asg_end_date); -- #1769702
       -- #2433154
       -- US Leg: Tax records might need to be updated
       --

       -- and l_prev_location_id <> apl_asg_rec.location_id condition
       --   added by sneelapa for bug 6409982.

         if p_legislation_code = 'US'
		and l_prev_location_id <> apl_asg_rec.location_id then

                -- code added by sneelapa for bug 6409982 starts
                p_old_assignment_id := p_assignment_id;

                open  cur_asg_type;
                fetch cur_asg_type into l_assignment_type;
                close cur_asg_type;

                if l_assignment_type <> 'B' then
                -- code added by sneelapa for bug 6409982 ends

		    pay_us_emp_dt_tax_rules.default_tax_with_validation
			      (p_assignment_id        => p_assignment_id
			      ,p_person_id            => p_person_id
			      ,p_effective_start_date => p_start_date
			      ,p_effective_end_date   => l_asg_end_date
			      ,p_session_date         => p_start_date
			      ,p_business_group_id    => p_business_group_id
			      ,p_from_form            => 'Assignment'
			      ,p_mode                 => 'UPDATE'
			      ,p_location_id          => emp_asg_rec.location_id
			      ,p_return_code          => l_return_code
			      ,p_return_text          => l_return_text
			       );
		end if;
         end if; -- leg=US
       -- end 2433154
end loop;
--
    if ass_cur%ROWCOUNT <1 then
       hr_utility.set_location('hrhirapl.create_primary_assignment',33);
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','create_primary_assignment');
       hr_utility.set_message_token('STEP','3');
       hr_utility.raise_error;
    end if;
close ass_cur;
   -- +---- End Date chosen APL primary assignment id ------+
   begin
     declare cursor app_cur is
     select pa.rowid
     from per_assignments_f pa
     where pa.assignment_id = p_new_primary_id
     and   p_start_date between pa.effective_start_date
                        and pa.effective_end_date
     for update of pa.effective_end_date;
    begin
      hr_utility.set_location('hrhirapl.create_primary_assignment',22);
      hr_utility.trace('    Update APL asg id => '||to_char(p_new_primary_id));
      open app_cur;
   loop
      fetch app_cur into p_rowid;
      exit when app_cur%notfound;
       hr_utility.set_location('hrhirapl.create_primary_assignment',23);
       update per_assignments_f
       set effective_end_date = p_start_date - 1
       where rowid = p_rowid;
       end loop;
    if app_cur%ROWCOUNT <1 then
       hr_utility.set_location('hrhirapl.create_primary_assignment',44);
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','create_primary_assignment');
       hr_utility.set_message_token('STEP','4');
       hr_utility.raise_error;
    end if;
      close app_cur;
    end;
  end;
   end;
  end if;
--

--start changes for bug 6598795
  hr_assignment.update_assgn_context_value (p_business_group_id,
					   p_person_id,
					   p_assignment_id,
					   p_start_date);
--start changes for bug 6598795
--start changes for bug 7289811
      IRC_OFFERS_API.close_offer
       ( p_validate                   => false
        ,p_effective_date             => p_start_date-1
        ,p_applicant_assignment_id    => apl_asg_rec.assignment_id
        ,p_change_reason              => 'APL_HIRED'-- Fix for bug 7540870
       );
--end changes for bug 7289811

end create_primary_assignment;
--
--
--
-- *** MAIN employ_applicant ***
begin
--
-- hr_utility.trace_on;
  hr_utility.set_location('hr_person.employ_applicant',1);
--
  v_tabrows := table_contents; -- #2264569
  hr_utility.trace(' ***** Table ==> '||v_tabrows);
--
-- Get new or existing period of service.
--
  v_period_of_service_id := get_period_of_service(p_business_group_id
                                ,p_person_id
                                ,p_legislation_code
                                ,p_emp_apl);
--
--
 if p_emp_apl = 'Y' then
   if p_update_primary_flag in ('Y','C','V') then
--
  hr_utility.set_location('hr_person.employ_applicant',2);
--
--
-- Date effectively end the current primary assignment
--
   if p_new_primary_id is not null then
      update_primary_assignment(p_business_group_id
                               ,p_person_id
                               ,p_start_date
                               ,p_current_date
                               ,p_user_id
                               ,p_login_id
                               );
   end if;
--
  hr_utility.set_location('hr_person.employ_applicant',3);
--
--
-- Make other accepted rows secondary
--
       make_secondary(p_business_group_id
                   ,p_person_id
                   ,p_legislation_code
                   ,p_assignment_status_type_id
                   ,p_update_primary_flag
                   ,p_new_primary_id
                   ,p_user_id
                   ,p_login_id
                   ,p_start_date
                   ,p_end_of_time
                   ,p_employee_number
                   ,p_set_of_books_id
                   ,p_current_date);
--
  hr_utility.set_location('hr_person.employ_applicant',4);
--
--
--  Make a new primary assignment.
--
   if p_new_primary_id is not null then
     create_primary_assignment(p_business_group_id
                              ,p_person_id
                              ,p_new_primary_id
                              ,p_start_date
                              ,p_end_of_time
                              ,p_login_id
                              ,p_user_id
                              ,p_update_primary_flag
                              ,p_employee_number
                              ,p_set_of_books_id
                              ,p_emp_apl
                              );
   end if;
   else -- update_primary_flag = 'N'
--
  hr_utility.set_location('hr_person.employ_applicant',5);
--
--
-- Create the accepted assignments as secondary assignments
--
     make_secondary(p_business_group_id
                 ,p_person_id
                 ,p_legislation_code
                 ,p_assignment_status_type_id
                 ,p_update_primary_flag
                 ,p_new_primary_id
                 ,p_user_id
                 ,p_login_id
                 ,p_start_date
                 ,p_end_of_time
                 ,p_employee_number
                 ,p_set_of_books_id
                 ,p_current_date);
   end if;

 else -- employing an applicant; update_primary_flag = 'N'
--
  hr_utility.set_location('hr_person.employ_applicant',6);
--
--
-- Create the accepted as secondary but make the chosen a primary.
--
        make_secondary(p_business_group_id
                     ,p_person_id
                     ,p_legislation_code
                     ,p_assignment_status_type_id
                     ,p_update_primary_flag
                     ,p_new_primary_id
                     ,p_user_id
                     ,p_login_id
                     ,p_start_date
                     ,p_end_of_time
                     ,p_employee_number
                     ,p_set_of_books_id
                     ,p_current_date);
--
--
  hr_utility.set_location('hr_person.employ_applicant',7);
--
   create_primary_assignment(p_business_group_id
                            ,p_person_id
                            ,p_new_primary_id
                            ,p_start_date
                            ,p_end_of_time
                            ,p_login_id
                            ,p_user_id
                            ,p_update_primary_flag
                            ,p_employee_number
                            ,p_set_of_books_id
                            ,p_emp_apl
                            );

--
-- 115.50 (START)
--
   --
   -- Handle potentially overlapping PDS due to rehire before FPD
   --
   hr_employee_api.manage_rehire_primary_asgs
      (p_person_id   => p_person_id
      ,p_rehire_date => p_start_date
      ,p_cancel      => 'N'
      );
--
-- 115.50 (END)
--

 end if;
--
-- hr_utility.trace_off;
  --
  --start WWBUG 2130950 hrwf synchronization --tpapired
  --
  declare
    l_asg_rec                per_all_assignments_f%rowtype;
    cursor asg_cur is select *
      from per_all_assignments_f
      where primary_flag          ='Y'
      and   assignment_type       = 'E'
      and   person_id             = p_person_id
      and   business_group_id + 0 = p_business_group_id
      and   p_start_date between effective_start_date
      and   effective_end_date;
  begin
    open asg_cur;
    fetch asg_cur into l_asg_rec;
    close asg_cur;
    per_hrwf_synch.per_asg_wf(
                     p_rec       => l_asg_rec,
                     p_action    => 'INSERT');
  --
  end;
  --
  --End WWBUG 2130950 for hrwf synchronization -tpapired
  --
  -- fix 7120387
  if p_emp_apl <> 'Y' then  -- handling only for Apl case as there are many probabilities
   -- which can cause regression if handled for emp.apl case and may also need Project Management
   -- approval

   declare

 l_asg_probation_det                per_all_assignments_f%rowtype;
    cursor asg_cur is select *
      from per_all_assignments_f
      where
           assignment_type       = 'E'
      and   person_id             = p_person_id
      and   business_group_id + 0 = p_business_group_id
      and   p_start_date between effective_start_date
      and   effective_end_date;

   cursor appl_rec_det(l_appl_id number) is
   select projected_hire_date
   from per_applications
   where application_id =l_appl_id;

   l_date_probation_end date;
   l_proj_hire_date date;

begin

   open asg_cur;
    loop
    fetch asg_cur into l_asg_probation_det;
    exit when asg_cur%notfound;

   open appl_rec_det(l_asg_probation_det.application_id) ;
   fetch appl_rec_det into l_proj_hire_date;
   close appl_rec_det;

   hr_utility.set_location('l_asg_probation_det.assignment_id :'||l_asg_probation_det.assignment_id,7);
   hr_utility.set_location('l_proj_hire_date :'||l_proj_hire_date,10);
   hr_utility.set_location('l_proj_hire_date :'||l_proj_hire_date,10);

 if l_proj_hire_date is null then

        if ( l_asg_probation_det.probation_period is not null)
           and
           (l_asg_probation_det.probation_unit is not null ) then


          hr_utility.set_location('p_start_date :'||p_start_date,10);
          hr_utility.set_location('l_asg_probation_det.assignment_id :'||l_asg_probation_det.assignment_id,10);
          hr_utility.set_location('l_asg_probation_det.probation_period :'||l_asg_probation_det.probation_period,10);
          hr_utility.set_location('l_asg_probation_det.probation_unit :'||l_asg_probation_det.probation_unit,10);
                l_date_probation_end :=NULL;
           hr_assignment.gen_probation_end
        (p_assignment_id      => l_asg_probation_det.assignment_id
        ,p_probation_period   => l_asg_probation_det.probation_period
        ,p_probation_unit     => l_asg_probation_det.probation_unit
        ,p_start_date         => p_start_date
        ,p_date_probation_end => l_date_probation_end
        );
      hr_utility.set_location('l_date_probation_end :'||l_date_probation_end,10);


      update per_all_assignments_f
      set date_probation_end =l_date_probation_end
      where
      assignment_type       = 'E'
      and   person_id             = p_person_id
      and   business_group_id + 0 = p_business_group_id
      and   p_start_date between effective_start_date
      and   effective_end_date
      and assignment_id = l_asg_probation_det.assignment_id;


      end if;



 end if;

 end loop;
 close asg_cur;
end;

end if;
  -- end of date probation end
   -- fix 7120387
  -- Re-evaluate security access for the person.
  --
  hr_utility.set_location('hr_person.employ_applicant',8);
  --
  -- Bug 2534026
  -- Hard-code p_emp and p_apl as 'Y'. This will cause both employee and
  -- applicant assignments to beincluded when security access is re-evaluated
  --
  ins_per_list(p_person_id => p_person_id
                      ,p_business_group_id => p_business_group_id
                      ,p_legislation_code  => p_legislation_code
                      ,p_start_date        => p_start_date
                      ,p_apl               => 'Y'
                      ,p_emp               => 'Y');
end employ_applicant;
--------------------------- END: employ_applicant --------------------
procedure ins_per_list(p_person_id IN number
                      ,p_business_group_id IN  number
                      ,p_legislation_code IN VARCHAR2
                      ,p_start_date in date
                      ,p_apl IN VARCHAR2
                      ,p_emp IN VARCHAR2 ) is
--
l_dummy number;
p_organization_id number;
p_position_id number;
p_payroll_id number;
--
-- Bug 605034. This cursor which gets run after the person list entries
-- have been deleted must select from the base table rather than secure
-- view
--
cursor ass_cur is
select pa.assignment_id
,      pa.effective_start_date
from   per_all_assignments_f pa
,     per_assignment_status_types past
where nvl(past.business_group_id,p_business_group_id) = pa.business_group_id + 0
and   pa.person_id               = p_person_id
and   pa.business_group_id + 0   = p_business_group_id
   and
      (( p_apl           = 'Y'
      and  nvl(past.legislation_code, p_legislation_code) = p_legislation_code
      and  past.per_system_status   = 'ACCEPTED'
      and    pa.assignment_type     = 'A'
      and    past.assignment_status_type_id = pa.assignment_status_type_id
      and   p_start_date between pa.effective_start_date
              and   pa.effective_end_date
      )
--if this is a current employee, no need to check legislation code,or
--system status.
   or
      (p_emp            =  'Y'
      and    pa.assignment_type     =  'E'
      and    p_start_date between pa.effective_start_date
                              and pa.effective_end_date
      and    past.assignment_status_type_id = pa.assignment_status_type_id));

--
cursor check_past_pds is
  select 1
  from per_periods_of_service pps
  where pps.person_id =p_person_id
  and date_start <= (select effective_date
                     from   fnd_sessions
                     where  session_id =
                     userenv('sessionid'));
cursor check_pds is
  select 1
  from per_periods_of_service pps
  where pps.person_id =p_person_id;

begin
  hr_utility.set_location('Entering : hr_person.ins_per_list',5);
  open check_past_pds;
  fetch check_past_pds into l_dummy;
  if check_past_pds%FOUND then
    close check_past_pds;
    hr_utility.set_location('hr_person.ins_per_list',10);
    hr_security_internal.clear_from_person_list(p_person_id);
  else
    close check_past_pds;
    open check_pds;
    fetch check_pds into l_dummy;
    if check_pds%notfound then
      close check_pds;
      hr_utility.set_location('hr_person.ins_per_list',15);
      hr_security_internal.clear_from_person_list(p_person_id);
    else
      close check_pds;
    end if;
  end if;
  --
  hr_utility.set_location('hr_person.ins_per_list',20);
  --
  for asg_rec in ass_cur loop
    hr_security_internal.add_to_person_list
      (p_assignment_id  => asg_rec.assignment_id
      ,p_effective_date => asg_rec.effective_start_date);
  end loop;
  --
  hr_utility.set_location('Leaving : hr_person.ins_per_list',30);
  --
end ins_per_list;
-- +------------------END:  ins_per_list ----------------------------------+
--
-- +-----------------------------------------------------------------------+
-- +------------------ BEGIN: end_unaccepted_app_assign -------------------+
-- +-----------------------------------------------------------------------+
procedure end_unaccepted_app_assign(p_person_id IN INTEGER
                                           ,p_business_group_id IN INTEGER
                                           ,p_legislation_code IN VARCHAR2
                                           ,p_end_date IN DATE
                                           -- #2264569
                                           ,p_table IN HR_EMPLOYEE_APPLICANT_API.t_ApplTable
                                           ) IS

/*
  NAME
   end_unaccepted_app_assign
  DESCRIPTION
   End all Unaccepted assignments. ~~~ End CHOSEN unaccepted assignments
  PARAMETERS
   p_business_group_id : Current business group.
   p_legislation_code  : Current Operating Legislation.
   p_end_date : Date the applicant hired.
*/
l_end_date DATE; -- Day before hire.
--
-- # 2264569
--
  l_asgid per_assignments_f.assignment_id%TYPE;
--
  cursor unacc_cur is
   select pa.assignment_id
    from per_assignments_f pa
    where  pa.person_id = p_person_id
    and    pa.business_group_id + 0 = p_business_group_id
    and    pa.assignment_type = 'A'
    and p_end_date between pa.effective_start_date
                    and pa.effective_end_date -- fix for bug 6036285
    and    pa.assignment_status_type_id IN (
                       select past.assignment_status_type_id
                       from   per_assignment_status_types past
                       ,      per_ass_status_type_amends pasa
                       where  pasa.assignment_status_type_id(+)=
                              past.assignment_status_type_id
                       and    pasa.business_group_id(+) + 0 = p_business_group_id
                       and    nvl(past.business_group_id,p_business_group_id) =
                               p_business_group_id
                       and    nvl(past.legislation_code, p_legislation_code) =
                              p_legislation_code
                       and    nvl(pasa.per_system_status,past.per_system_status) <>
                              'ACCEPTED'
                                          )
      for update of pa.effective_end_date;
--
  l_rowcount number;

--fix for bug 6036285 Starts here.
l_assignment_status_type_id number;
l_asg_status_id  irc_assignment_statuses.assignment_status_id%type;
l_asg_status_ovn irc_assignment_statuses.object_version_number%type;

--fix for bug 6036285 ends here.

--
begin
--
  l_end_date := p_end_date -1;
--
-- #2264569
--
  hr_utility.set_location('IN hrhirapl.end_unaccepted_app_assign',303);
  open unacc_cur;
  loop
     fetch unacc_cur into l_asgid;
     exit when unacc_cur%NOTFOUND;
     begin
       if hr_employee_applicant_api.end_date_exists(p_table,l_asgid) <> 2 then
          hr_utility.set_location('hrhirapl.end_unaccepted_app_assign',305);
          hr_utility.trace(' **** Asg ID : '||to_char(l_asgid));

          update per_assignments pa
          set    pa.effective_end_date = l_end_date
          where current of unacc_cur;
--Fix for bug 6514078 starts here
   --fix for bug 6036285 Starts here.
    per_people3_pkg.get_default_person_type
      (p_required_type     => 'TERM_APL'
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_person_type       => l_assignment_status_type_id
      );

    IRC_ASG_STATUS_API.create_irc_asg_status
      (p_assignment_id             => l_asgid
      ,p_assignment_status_type_id => l_assignment_status_type_id
      ,p_status_change_date        => p_end_date
      ,p_assignment_status_id      => l_asg_status_id
      ,p_object_version_number     => l_asg_status_ovn);
  --fix for bug 6036285 ends here.
--Fix for bug 6514078 ends here
--Fix for bug 7289811 starts here
    IRC_OFFERS_API.close_offer
       ( p_validate                   => false
        ,p_effective_date             => l_end_date
        ,p_applicant_assignment_id    => l_asgid
        ,p_change_reason              => 'MANUAL_CLOSURE'
       );
--Fix for bug 7289811 end here
       end if;
     exception
       when others then
       close unacc_cur;
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','end_unaccepted_app_assign');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
     end;
  end loop;
  close unacc_cur;
  hr_utility.set_location('OUT hrhirapl.end_unaccepted_app_assign',310);

end end_unaccepted_app_assign;
--
-- +----------------------END: end_unaccepted_app_assign -------------+
--
-- +--------------------------BEGIN: end_bookings --------------------+
procedure end_bookings(p_person_id number
                       ,p_business_group_id number
                       ,p_start_date DATE) is
--
l_event_id number;
l_booking_id number;
l_no_of_rows number;
l_final_no number;
--
cursor events is
select pe.event_id
from  per_events pe
,     per_assignments_f a
where pe.business_group_id  +0 = a.business_group_id
and   a.business_group_id      = p_business_group_id
and   pe.assignment_id         = a.assignment_id
and   pe.date_start >=p_start_date
and   a.person_id              = p_person_id
and   p_start_date between a.effective_start_date
and   a.effective_end_date
and   pe.event_or_interview = 'E'
for   update of event_id;
--
cursor bookings is
select booking_id
from   per_bookings pb
where   pb.event_id           = l_event_id
for update of booking_id;
--
begin
  --
  -- Lock the Events and bookings.
  --
  open events;
  loop
    fetch events into l_event_id;
    exit when events%NOTFOUND;
    open bookings;
    loop
      fetch bookings into l_booking_id;
      exit when bookings%notfound;
    end loop;
    close bookings;
  end loop;
  l_no_of_rows := events%rowcount; -- get the number of events locked.
  close events;
  --
  -- delete the bookings.
  --
  l_final_no := l_no_of_rows; -- set counter same.
  open events;
  loop
   fetch events into l_event_id;
   exit when events%NOTFOUND;
   --
   delete from per_bookings pb
   where pb.event_id = l_event_id;
   --
   end loop;
   close events;
  --
  -- Delete the events.
  --
  open events;
  loop
   fetch events into l_event_id;
   exit when events%NOTFOUND;
   --
   delete from per_events
   where event_id = l_event_id;
   l_final_no := l_final_no - sql%rowcount;
  end loop;
  if l_final_no <> 0 then
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','end_bookings');
       hr_utility.set_message_token('STEP','10');
       hr_utility.raise_error;
  end if;
  --
end end_bookings;
----------------------------END: end_bookings --------------------
end hrhirapl;

/
