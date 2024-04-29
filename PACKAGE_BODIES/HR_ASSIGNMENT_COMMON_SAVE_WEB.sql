--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_COMMON_SAVE_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_COMMON_SAVE_WEB" AS
/* $Header: hrascmsw.pkb 120.1 2005/09/23 13:51:17 svittal noship $*/
g_package      constant varchar2(75):='hr_assignment_common_save_web.';
g_person_id             per_all_people_f.person_id%TYPE;
--
-- --------------------------------------------------------------------------
-- -----------------------< validate_assignment >----------------------------
-- --------------------------------------------------------------------------
--
/* This is the procedure to validate and apply the assignment data, including
   the People Group and Soft Coded Key Flexfields
*/
procedure validate_assignment
(p_validate                 in     boolean
,p_assignment_id            in     number
,p_object_version_number    in     number
,p_effective_date           in     date
,p_datetrack_update_mode    in     varchar2
,p_organization_id          in     number
,p_position_id              in     number   default null
,p_job_id                   in     number   default null
,p_grade_id                 in     number   default null
,p_location_id              in     number   default null
,p_employment_category      in     varchar2 default null
--
,p_supervisor_id            in     number   default null
,p_manager_flag             in     varchar2 default null
,p_normal_hours             in     number   default null
,p_frequency                in     varchar2 default null
,p_time_normal_finish       in     varchar2 default null
,p_time_normal_start        in     varchar2 default null
,p_assignment_status_type_id in    number   default null
,p_change_reason            in     varchar2 default null
,p_ass_attribute_category   in     varchar2 default null
,p_ass_attribute1           in     varchar2 default null
,p_ass_attribute2           in     varchar2 default null
,p_ass_attribute3           in     varchar2 default null
,p_ass_attribute4           in     varchar2 default null
,p_ass_attribute5           in     varchar2 default null
,p_ass_attribute6           in     varchar2 default null
,p_ass_attribute7           in     varchar2 default null
,p_ass_attribute8           in     varchar2 default null
,p_ass_attribute9           in     varchar2 default null
,p_ass_attribute10          in     varchar2 default null
,p_ass_attribute11          in     varchar2 default null
,p_ass_attribute12          in     varchar2 default null
,p_ass_attribute13          in     varchar2 default null
,p_ass_attribute14          in     varchar2 default null
,p_ass_attribute15          in     varchar2 default null
,p_ass_attribute16          in     varchar2 default null
,p_ass_attribute17          in     varchar2 default null
,p_ass_attribute18          in     varchar2 default null
,p_ass_attribute19          in     varchar2 default null
,p_ass_attribute20          in     varchar2 default null
,p_ass_attribute21          in     varchar2 default null
,p_ass_attribute22          in     varchar2 default null
,p_ass_attribute23          in     varchar2 default null
,p_ass_attribute24          in     varchar2 default null
,p_ass_attribute25          in     varchar2 default null
,p_ass_attribute26          in     varchar2 default null
,p_ass_attribute27          in     varchar2 default null
,p_ass_attribute28          in     varchar2 default null
,p_ass_attribute29          in     varchar2 default null
,p_ass_attribute30          in     varchar2 default null
,p_scl_segment1             in     varchar2 default null
,p_scl_segment2             in     varchar2 default null
,p_scl_segment3             in     varchar2 default null
,p_scl_segment4             in     varchar2 default null
,p_scl_segment5             in     varchar2 default null
,p_scl_segment6             in     varchar2 default null
,p_scl_segment7             in     varchar2 default null
,p_scl_segment8             in     varchar2 default null
,p_scl_segment9             in     varchar2 default null
,p_scl_segment10            in     varchar2 default null
,p_scl_segment11            in     varchar2 default null
,p_scl_segment12            in     varchar2 default null
,p_scl_segment13            in     varchar2 default null
,p_scl_segment14            in     varchar2 default null
,p_scl_segment15            in     varchar2 default null
,p_scl_segment16            in     varchar2 default null
,p_scl_segment17            in     varchar2 default null
,p_scl_segment18            in     varchar2 default null
,p_scl_segment19            in     varchar2 default null
,p_scl_segment20            in     varchar2 default null
,p_scl_segment21            in     varchar2 default null
,p_scl_segment22            in     varchar2 default null
,p_scl_segment23            in     varchar2 default null
,p_scl_segment24            in     varchar2 default null
,p_scl_segment25            in     varchar2 default null
,p_scl_segment26            in     varchar2 default null
,p_scl_segment27            in     varchar2 default null
,p_scl_segment28            in     varchar2 default null
,p_scl_segment29            in     varchar2 default null
,p_scl_segment30            in     varchar2 default null
,p_pgp_segment1             in     varchar2 default null
,p_pgp_segment2             in     varchar2 default null
,p_pgp_segment3             in     varchar2 default null
,p_pgp_segment4             in     varchar2 default null
,p_pgp_segment5             in     varchar2 default null
,p_pgp_segment6             in     varchar2 default null
,p_pgp_segment7             in     varchar2 default null
,p_pgp_segment8             in     varchar2 default null
,p_pgp_segment9             in     varchar2 default null
,p_pgp_segment10            in     varchar2 default null
,p_pgp_segment11            in     varchar2 default null
,p_pgp_segment12            in     varchar2 default null
,p_pgp_segment13            in     varchar2 default null
,p_pgp_segment14            in     varchar2 default null
,p_pgp_segment15            in     varchar2 default null
,p_pgp_segment16            in     varchar2 default null
,p_pgp_segment17            in     varchar2 default null
,p_pgp_segment18            in     varchar2 default null
,p_pgp_segment19            in     varchar2 default null
,p_pgp_segment20            in     varchar2 default null
,p_pgp_segment21            in     varchar2 default null
,p_pgp_segment22            in     varchar2 default null
,p_pgp_segment23            in     varchar2 default null
,p_pgp_segment24            in     varchar2 default null
,p_pgp_segment25            in     varchar2 default null
,p_pgp_segment26            in     varchar2 default null
,p_pgp_segment27            in     varchar2 default null
,p_pgp_segment28            in     varchar2 default null
,p_pgp_segment29            in     varchar2 default null
,p_pgp_segment30            in     varchar2 default null
--
,p_business_group_id        in     per_all_assignments_f.business_group_id%TYPE
,p_assignment_type          in     per_all_assignments_f.assignment_type%TYPE
,p_vacancy_id               in     per_all_assignments_f.vacancy_id%TYPE
,p_special_ceiling_step_id  in out nocopy per_all_assignments_f.special_ceiling_step_id%TYPE
,p_primary_flag             in     per_all_assignments_f.primary_flag%TYPE
,p_person_id                in     per_all_assignments_f.person_id%TYPE
,p_effective_start_date        out nocopy date
,p_effective_end_date          out nocopy date
,p_element_warning          in     boolean
,p_element_changed          in out nocopy varchar2
,p_email_id                 in     varchar2 default null
) is
--

l_effective_date             date;
l_object_version_number      per_all_assignments_f.object_version_number%TYPE;
l_effective_start_date       date;
l_effective_end_date         date;
l_people_group_id            per_all_assignments_f.people_group_id%TYPE;
l_group_name                 VARCHAR2(2000);
l_org_now_no_manager_warning boolean;
l_other_manager_warning      boolean;
l_spp_delete_warning         boolean;
l_entries_changed_warning    VARCHAR2(30);
l_tax_district_changed_warning boolean;
l_soft_coding_keyflex_id     per_all_assignments_f.soft_coding_keyflex_id%TYPE;
l_comment_id                 per_all_assignments_f.comment_id%TYPE;
l_concatenated_segments      VARCHAR2(2000);
l_validation_start_date      per_assignments_f.effective_start_date%TYPE;
l_validation_end_date        per_assignments_f.effective_end_date%TYPE;
l_inv_pos_grade_warning      boolean;
l_org_error                  boolean default false;
l_job_error                  boolean default false;
l_pos_error                  boolean default false;
l_old_wc_code                number;
l_old_job_id                 number;
l_new_wc_code                number;
l_assignment_status_type     varchar2(30);
l_element_changed	     varchar2(2000);
l_special_ceiling_step_id    per_all_assignments_f.special_ceiling_step_id%TYPE;
--
cursor current_job_id is
select job_id
from per_all_assignments_f
where assignment_id=p_assignment_id
and l_effective_date between effective_start_date and effective_end_date;
--
cursor status_type is
select per_system_status
from per_assignment_status_types
where assignment_status_type_id=p_assignment_status_type_id;
--
begin
--
-- since we are calling chk_ procedures, we must trunc the date.
--
    l_effective_date :=trunc(p_effective_date);
--
-- get the current job_id for wc_validation
--
  open current_job_id;
  fetch current_job_id into l_old_job_id;
  if current_job_id%found then
    close current_job_id;
  else
    close current_job_id;
  end if;
--
-- since we are calling more than one api, we must issue our own
-- savepoint and manage the rollback ourselves.
--
savepoint validate_assignment;
--
l_object_version_number:=p_object_version_number;
-- Remember IN OUT parameters.
l_element_changed      := p_element_changed;
l_special_ceiling_step_id := p_special_ceiling_step_id;
--
-- perform field level validation first to obtain as much error information
-- as possible
--
-- lock the record and get the validation dates
per_asg_shd.lck
(p_effective_date        => l_effective_date
,p_datetrack_mode        => p_datetrack_update_mode
,p_assignment_id         => p_assignment_id
,p_object_version_number => l_object_version_number
,p_validation_start_date => l_validation_start_date
,p_validation_end_date   => l_validation_end_date
);
--
-- check the organization_id
--
begin
  per_asg_bus1.chk_organization_id
    (p_assignment_id               =>  p_assignment_id
    ,p_primary_flag                =>  p_primary_flag
    ,p_organization_id             =>  p_organization_id
    ,p_business_group_id           =>  p_business_group_id
    ,p_assignment_type             =>  p_assignment_type
    ,p_vacancy_id                  =>  p_vacancy_id
    ,p_validation_start_date       =>  l_validation_start_date
    ,p_validation_end_date         =>  l_validation_end_date
    ,p_effective_date              =>  l_effective_date
    ,p_object_version_number       =>  l_object_version_number
    ,p_manager_flag                =>  p_manager_flag
    ,p_org_now_no_manager_warning  =>  l_org_now_no_manager_warning
    ,p_other_manager_warning       =>  l_other_manager_warning
    );
exception
when others then
--
  l_org_error:=TRUE;
  hr_message.provide_error;
--
-- look for the possible messages raised by the organization check to add
-- them to the organization field
--
  if (hr_message.last_message_name ='HR_7389_ASG_INVALID_ORG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_ORGANIZATION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7376_ASG_INVALID_BG_ORG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_ORGANIZATION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51277_ASG_INV_HR_ORG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_ORGANIZATION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51042_ASG_INVALID_VAC_ORG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_ORGANIZATION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  ELSE  -- Bug #1313212 Fix
     hr_errors_api.addErrorToTable
      (p_errorfield => 'P_ORGANIZATION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  end if;
end;
--
-- check the position_id
--
begin
  per_asg_bus2.chk_position_id
    (p_assignment_id          =>  p_assignment_id
     ,p_position_id           =>  p_position_id
     ,p_business_group_id     =>  p_business_group_id
     ,p_assignment_type       =>  p_assignment_type
     ,p_vacancy_id            =>  p_vacancy_id
     ,p_validation_start_date =>  l_validation_start_date
     ,p_validation_end_date   =>  l_validation_end_date
     ,p_effective_date        =>  l_effective_date
     ,p_object_version_number =>  l_object_version_number
    );
exception
when others then
--
  l_pos_error:=TRUE;
  hr_message.provide_error;
--
-- look for the possible messages raised by the position check to add
-- them to the position field
--
  if (hr_message.last_message_name ='HR_51000_ASG_INVALID_POS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_POSITION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51009_ASG_INVALID_BG_POS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_POSITION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51040_ASG_INVALID_VAC_POS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_POSITION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  ELSE  -- Bug #1313212 Fix
      hr_errors_api.addErrorToTable
      (p_errorfield => 'P_POSITION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  end if;
end;
--
-- check the job_id
begin
  --
  per_asg_bus1.chk_job_id
    (p_assignment_id         =>  p_assignment_id
    ,p_business_group_id     =>  p_business_group_id
    ,p_assignment_type       =>  p_assignment_type
    ,p_job_id                =>  p_job_id
    ,p_vacancy_id            =>  p_vacancy_id
    ,p_effective_date        =>  l_effective_date
    ,p_validation_start_date =>  l_validation_start_date
    ,p_validation_end_date   =>  l_validation_end_date
    ,p_object_version_number =>  l_object_version_number
    );
exception
when others then
--
  l_job_error:=TRUE;
  hr_message.provide_error;
--
-- look for the possible messages raised by the job check to add
-- them to the job field
--
  if (hr_message.last_message_name ='HR_51172_ASG_INV_DT_JOB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_JOB_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51173_ASG_INV_DT_JOB_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_JOB_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51293_ASG_INV_VAC_JOB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_JOB_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  ELSE  -- Bug #1313212 Fix
      hr_errors_api.addErrorToTable
      (p_errorfield => 'P_JOB_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);

  end if;
end;
--
if (NOT l_pos_error) and (NOT l_job_error) then
-- check the job position combination if nether job nor position raised
-- an error
--
begin
  --
  per_asg_bus2.chk_position_id_job_id
    (p_assignment_id          =>  p_assignment_id
     ,p_position_id           =>  p_position_id
     ,p_job_id                =>  p_job_id
     ,p_validation_start_date =>  l_validation_start_date
     ,p_validation_end_date   =>  l_validation_end_date
     ,p_effective_date        =>  l_effective_date
     ,p_object_version_number =>  l_object_version_number
    );
exception
when others then
--
  hr_message.provide_error;
--
-- look for the possible messages raised by the job/pos check to add
-- them to the appropriate field
--
  if (hr_message.last_message_name ='HR_51056_ASG_INV_POS_JOB_COMB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51057_ASG_JOB_NULL_VALUE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_JOB_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  ELSE  -- Bug #1313212 Fix
      hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  end if;
end;
end if;
--
-- check the grade_id
--
begin
  --
  per_asg_bus1.chk_grade_id
    (p_assignment_id            =>  p_assignment_id
    ,p_business_group_id        =>  p_business_group_id
    ,p_assignment_type          =>  p_assignment_type
    ,p_grade_id                 =>  p_grade_id
    ,p_vacancy_id               =>  p_vacancy_id
    ,p_special_ceiling_step_id  =>  p_special_ceiling_step_id
    ,p_effective_date           =>  l_effective_date
    ,p_validation_start_date    =>  l_validation_start_date
    ,p_validation_end_date      =>  l_validation_end_date
    ,p_object_version_number    =>  l_object_version_number
    );
exception
when others then
--
  hr_message.provide_error;
--
-- look for the possible messages raised by the grade check to add
-- them to the grade field
--
  if (hr_message.last_message_name ='HR_7393_ASG_INVALID_GRADE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_GRADE_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7371_ASG_INVALID_BG_GRADE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_GRADE_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
   elsif (hr_message.last_message_name ='HR_7434_ASG_GRADE_REQUIRED')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_GRADE_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51291_ASG_INV_VAC_GRADE')
       then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_GRADE_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  ELSE  -- Bug #1313212 Fix
      hr_errors_api.addErrorToTable
      (p_errorfield => 'P_GRADE_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  end if;
end;
--
-- check the supervisor id
--
begin
   --
  per_asg_bus2.chk_supervisor_id
    (p_assignment_id          =>  p_assignment_id
    ,p_supervisor_id          =>  p_supervisor_id
    ,p_person_id              =>  p_person_id
    ,p_business_group_id      =>  p_business_group_id
    ,p_validation_start_date  =>  l_validation_start_date
    ,p_effective_date         =>  l_effective_date
    ,p_object_version_number  =>  l_object_version_number
    );
exception
when others then
--
  hr_message.provide_error;
--
-- look for the possible messages raised by the supervisor check to add
-- them to the supervisor field
--
  if (hr_message.last_message_name ='HR_51143_ASG_EMP_EQUAL_SUP')
      then hr_errors_api.addErrorToTable
      -- As of 11.5.2, P_SUPERVISOR_NAME field is not displayed on the
      -- Assignment page yet.  Thus, we need to set the error field to null.
      -- When P_SUPERVISOR_NAME is displayed on the assignment page, uncomment
      -- out the error field statement to point to the proper field.
      -- (p_errorfield => 'P_SUPERVISOR_NAME'
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PAY_7599_SYS_SUP_DT_OUTDATE')
      then hr_errors_api.addErrorToTable
      -- (p_errorfield => 'P_SUPERVISOR_NAME'
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51145_ASG_SUP_BG_NE_EMP_BG')
      then hr_errors_api.addErrorToTable
      -- (p_errorfield => 'P_SUPERVISOR_NAME'
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51346_ASG_SUP_NOT_EMP')
      then hr_errors_api.addErrorToTable
      -- (p_errorfield => 'P_SUPERVISOR_NAME'
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  ELSE  -- Bug #1313212 Fix
      hr_errors_api.addErrorToTable
      -- (p_errorfield => 'P_SUPERVISOR_NAME'
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);

 end if;
end;
--
if (NOT l_pos_error) and (NOT l_org_error) then
-- check the pos org combination if neither pos nor org have raised an error
--
begin
  --
  per_asg_bus2.chk_position_id_org_id
    (p_assignment_id          =>  p_assignment_id
     ,p_position_id           =>  p_position_id
     ,p_organization_id       =>  p_organization_id
     ,p_validation_start_date =>  l_validation_start_date
     ,p_validation_end_date   =>  l_validation_end_date
     ,p_effective_date        =>  l_effective_date
     ,p_object_version_number =>  l_object_version_number
    );
exception
when others then
--
  hr_message.provide_error;
  if (hr_message.last_message_name ='HR_51055_ASG_INV_POS_ORG_COMB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  ELSE  -- Bug #1313212 Fix
      hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
 end if;
end;
end if;
--
-- check the location_id
--
begin
  per_asg_bus1.chk_location_id
    (p_assignment_id          =>  p_assignment_id
     ,p_location_id           =>  p_location_id
     ,p_assignment_type       =>  p_assignment_type
     ,p_vacancy_id            =>  p_vacancy_id
     ,p_validation_start_date =>  l_validation_start_date
     ,p_validation_end_date   =>  l_validation_end_date
     ,p_effective_date        =>  l_effective_date
     ,p_object_version_number =>  l_object_version_number
    );
exception
when others then
--
  hr_message.provide_error;
--
-- look for the possible messages raised by the location check to add
-- them to the location field
--
  if (hr_message.last_message_name ='HR_7382_ASG_NON_EXIST_LOCATION')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_LOCATION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51215_ASG_INACT_LOCATION')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_LOCATION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
   elsif (hr_message.last_message_name ='HR_51041_ASG_INVALID_VAC_LOC')
      then hr_errors_api.addErrorToTable
      (p_errorfield => 'P_LOCATION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
   ELSE  -- Bug #1313212 Fix
      hr_errors_api.addErrorToTable
      (p_errorfield => 'P_LOCATION_NAME'
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
 end if;
end;
--
--
if not hr_errors_api.errorExists then
--
-- call the assignment criteria api
-- this enters all of the data which have element link dependencies
--
  hr_assignment_api.update_emp_asg_criteria
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_object_version_number
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      ,p_location_id                  => p_location_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_organization_id              => p_organization_id
      ,p_employment_category          => p_employment_category
      ,p_segment1                     => p_pgp_segment1
      ,p_segment2                     => p_pgp_segment2
      ,p_segment3                     => p_pgp_segment3
      ,p_segment4                     => p_pgp_segment4
      ,p_segment5                     => p_pgp_segment5
      ,p_segment6                     => p_pgp_segment6
      ,p_segment7                     => p_pgp_segment7
      ,p_segment8                     => p_pgp_segment8
      ,p_segment9                     => p_pgp_segment9
      ,p_segment10                    => p_pgp_segment10
      ,p_segment11                    => p_pgp_segment11
      ,p_segment12                    => p_pgp_segment12
      ,p_segment13                    => p_pgp_segment13
      ,p_segment14                    => p_pgp_segment14
      ,p_segment15                    => p_pgp_segment15
      ,p_segment16                    => p_pgp_segment16
      ,p_segment17                    => p_pgp_segment17
      ,p_segment18                    => p_pgp_segment18
      ,p_segment19                    => p_pgp_segment19
      ,p_segment20                    => p_pgp_segment20
      ,p_segment21                    => p_pgp_segment21
      ,p_segment22                    => p_pgp_segment22
      ,p_segment23                    => p_pgp_segment23
      ,p_segment24                    => p_pgp_segment24
      ,p_segment25                    => p_pgp_segment25
      ,p_segment26                    => p_pgp_segment26
      ,p_segment27                    => p_pgp_segment27
      ,p_segment28                    => p_pgp_segment28
      ,p_segment29                    => p_pgp_segment29
      ,p_segment30                    => p_pgp_segment30
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_people_group_id              => l_people_group_id
      ,p_group_name                   => l_group_name
      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_spp_delete_warning           => l_spp_delete_warning
      ,p_entries_changed_warning      => l_entries_changed_warning
      ,p_tax_district_changed_warning => l_tax_district_changed_warning
      );
--
-- look to see if the elements have changed
--
  if (l_entries_changed_warning<>'N') then
  --
  -- if the elements have changed, look to see if we want a
  -- warning or an error
  --
    if p_element_warning then
    --
    -- we want a warning, so look to see if the warning has already been
    -- raised and this is the second time through the process
    --
      if p_element_changed is null then
      --
      -- since p_element_changed is null, the warning has not already been
      -- raised, so raise it
      --
        p_element_changed:='W';
        hr_errors_api.addErrorToTable
        (p_errorfield   => null
        ,p_errorcode    => to_char(SQLCODE)
        ,p_errormsg     => hr_util_misc_web.return_msg_text
                           (p_message_name =>'HR_ELEMENT_CHANGED_WARNING_WEB'
                           ,p_application_id => 'PER')
        ,p_warningflag  => true
        );
      else
        --
        -- p_element_changed is not null, so the warning has already been raised
        -- so clear it so that the user can continue this time.
        --
        p_element_changed:=null;
      end if;
    --
    else
      --
      -- we want an error , so raise one.
      --
      hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => to_char(SQLCODE)
      ,p_errormsg   => hr_util_misc_web.return_msg_text
                       (p_message_name   => 'HR_ELEMENT_CHANGED_WEB'
                       ,p_application_id => 'PER')
      ,p_email_id   => p_email_id
      ,p_email_msg  => hr_util_misc_web.return_msg_text
                       (p_message_name => 'HR_ELEMENT_CHANGE_EMAILTXT_WEB'
                       ,p_application_id => 'PER')
      );
    end if;
  end if;

--
-- if there is no manager in the organization now then raise a warning
--
 if p_validate=TRUE then
  if(l_org_now_no_manager_warning) then
    fnd_message.set_name('PER','HR_51124_MMV_NO_MGR_EXIST_ORG');
    hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errormsg   => fnd_message.get
      ,p_warningflag => TRUE);
  end if;
--
-- if there are other managers then raise a warning
--
  if(l_other_manager_warning) then
    fnd_message.set_name('PER','HR_51125_MMV_MRE_MRG_EXIST_ORG');
    hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errormsg   => fnd_message.get
      ,p_warningflag => TRUE);
  end if;
 end if;
end if;
--
  if not hr_errors_api.errorExists then
--
-- if there are no errors from the previous api call then call the
-- assignment information api.
-- This is always called in CORRECTION mode because once we have made an UPDATE
-- to the row to make another change to it will be a correction.
--
    hr_assignment_api.update_emp_asg
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => 'CORRECTION'
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => l_object_version_number
      ,p_supervisor_id                => p_supervisor_id
      ,p_change_reason                => p_change_reason
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_frequency                    => p_frequency
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_ass_attribute_category       => p_ass_attribute_category
      ,p_ass_attribute1               => p_ass_attribute1
      ,p_ass_attribute2               => p_ass_attribute2
      ,p_ass_attribute3               => p_ass_attribute3
      ,p_ass_attribute4               => p_ass_attribute4
      ,p_ass_attribute5               => p_ass_attribute5
      ,p_ass_attribute6               => p_ass_attribute6
      ,p_ass_attribute7               => p_ass_attribute7
      ,p_ass_attribute8               => p_ass_attribute8
      ,p_ass_attribute9               => p_ass_attribute9
      ,p_ass_attribute10              => p_ass_attribute10
      ,p_ass_attribute11              => p_ass_attribute11
      ,p_ass_attribute12              => p_ass_attribute12
      ,p_ass_attribute13              => p_ass_attribute13
      ,p_ass_attribute14              => p_ass_attribute14
      ,p_ass_attribute15              => p_ass_attribute15
      ,p_ass_attribute16              => p_ass_attribute16
      ,p_ass_attribute17              => p_ass_attribute17
      ,p_ass_attribute18              => p_ass_attribute18
      ,p_ass_attribute19              => p_ass_attribute19
      ,p_ass_attribute20              => p_ass_attribute20
      ,p_ass_attribute21              => p_ass_attribute21
      ,p_ass_attribute22              => p_ass_attribute22
      ,p_ass_attribute23              => p_ass_attribute23
      ,p_ass_attribute24              => p_ass_attribute24
      ,p_ass_attribute25              => p_ass_attribute25
      ,p_ass_attribute26              => p_ass_attribute26
      ,p_ass_attribute27              => p_ass_attribute27
      ,p_ass_attribute28              => p_ass_attribute28
      ,p_ass_attribute29              => p_ass_attribute29
      ,p_ass_attribute30              => p_ass_attribute30
      ,p_segment1                     => p_scl_segment1
      ,p_segment2                     => p_scl_segment2
      ,p_segment3                     => p_scl_segment3
      ,p_segment4                     => p_scl_segment4
      ,p_segment5                     => p_scl_segment5
      ,p_segment6                     => p_scl_segment6
      ,p_segment7                     => p_scl_segment7
      ,p_segment8                     => p_scl_segment8
      ,p_segment9                     => p_scl_segment9
      ,p_segment10                    => p_scl_segment10
      ,p_segment11                    => p_scl_segment11
      ,p_segment12                    => p_scl_segment12
      ,p_segment13                    => p_scl_segment13
      ,p_segment14                    => p_scl_segment14
      ,p_segment15                    => p_scl_segment15
      ,p_segment16                    => p_scl_segment16
      ,p_segment17                    => p_scl_segment17
      ,p_segment18                    => p_scl_segment18
      ,p_segment19                    => p_scl_segment19
      ,p_segment20                    => p_scl_segment20
      ,p_segment21                    => p_scl_segment21
      ,p_segment22                    => p_scl_segment22
      ,p_segment23                    => p_scl_segment23
      ,p_segment24                    => p_scl_segment24
      ,p_segment25                    => p_scl_segment25
      ,p_segment26                    => p_scl_segment26
      ,p_segment27                    => p_scl_segment27
      ,p_segment28                    => p_scl_segment28
      ,p_segment29                    => p_scl_segment29
      ,p_segment30                    => p_scl_segment30
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_no_managers_warning          => l_org_now_no_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning
      );
--
-- check the warning flags again
--
  if p_validate=TRUE then
    if(l_org_now_no_manager_warning) then
      fnd_message.set_name('PER','HR_51124_MMV_NO_MGR_EXIST_ORG');
      hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errormsg   => fnd_message.get
      ,p_warningflag => TRUE);
    end if;
    if(l_other_manager_warning) then
      fnd_message.set_name('PER','HR_51125_MMV_MRE_MRG_EXIST_ORG');
      hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errormsg   => fnd_message.get
      ,p_warningflag => TRUE);
    end if;
  end if;
    --
    -- update the assignment status type
    --
    --
    -- chack to see what type of status the new id corresponds to.
    --
    open status_type;
    fetch status_type into l_assignment_status_type;
    if status_type%notfound then
      close status_type;
    else
      close status_type;
      --
      -- if we have an active assignment type then use the activate_emp_asg api
      if l_assignment_status_type='ACTIVE_ASSIGN' then
      --
      -- if we have an active assignment type then use the activate_emp_asg api
      --
        hr_assignment_api.activate_emp_asg
        (p_effective_date               => l_effective_date
        ,p_datetrack_update_mode        => 'CORRECTION'
        ,p_assignment_id                => p_assignment_id
        ,p_change_reason                => p_change_reason
        ,p_object_version_number        => l_object_version_number
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date);
      elsif l_assignment_status_type='SUSP_ASSIGN' then
      --
      -- if we have an active assignment type then use the suspend_emp_asg api
      --
        hr_assignment_api.suspend_emp_asg
        (p_effective_date               => l_effective_date
        ,p_datetrack_update_mode        => 'CORRECTION'
        ,p_assignment_id                => p_assignment_id
        ,p_change_reason                => p_change_reason
        ,p_object_version_number        => l_object_version_number
        ,p_assignment_status_type_id    => p_assignment_status_type_id
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date);
      end if;
    end if;
    --
    p_effective_start_date:=l_effective_start_date;
    p_effective_end_date:=l_effective_end_date;
--
  end if;
  --
  -- if we are in validate only mode, rollback
  --
  if p_validate=TRUE
  or hr_errors_api.errorExists then
    rollback to validate_assignment;
  end if;

--
-- handle any errors that are raised.
--
exception
when others then
--
-- rollback because there were errors
--
  rollback to validate_assignment;

-- Reset IN OUT and set OUT parameters.
   p_element_changed      := l_element_changed;
   p_special_ceiling_step_id := l_special_ceiling_step_id;
   p_effective_start_date  := null;
   p_effective_end_date    := null;

  hr_message.provide_error;
--
-- add the error message without changing it
--
  hr_errors_api.addErrorToTable
  (p_errorfield => null
  ,p_errorcode  => hr_message.last_message_number
  ,p_errormsg   => hr_message.get_message_text);

--
-- we do not check every error message individually because they are all passed
-- up without changing the error message at them moment, but they remain in the
-- code commented out so that if any of the error messages need to be
-- replaced, the code can easily be retrieved from this section.
--
/*  if (hr_message.last_message_name ='HR_6153_ALL_PROCEDURE_FAIL')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_6434_EMP_ASS_PER_CLOSED')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7155_OBJECT_INVALID')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7165_OBJECT_LOCKED')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7202_COMMENT_TEXT_NOT_EXIST')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7215_DT_CHILD_EXISTS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7216_DT_UPD_INTEGRITY_ERR')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7220_INVALID_PRIMARY_KEY')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7371_ASG_INVALID_BG_GRADE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7376_ASG_INVALID_BG_ORG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7370_ASG_INVALID_PAYROLL')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7372_ASG_INV_BG_ASS_STATUS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7373_ASG_INVALID_BG_PAYROLL')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7374_ASG_INVALID_BG_PERSON')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7375_ASG_INV_BG_SP_CLG_STEP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7378_ASG_NO_DATE_OF_BIRTH')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7379_ASG_INV_SPEC_CEIL_STEP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7380_ASG_STEP_INV_FOR_GRADE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7381_ASG_CEIL_STEP_TOO_HIGH')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7382_ASG_NON_EXIST_LOCATION')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7383_ASG_INV_KEYFLEX')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7385_ASG_INV_PEOPLE_GROUP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7386_ASG_INV_PEOP_GRP_LINK')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7387_ASG_NORMAL_HOURS_REQD')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7388_ASG_INVALID_FREQUENCY')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7389_ASG_INVALID_ORG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7390_ASG_NO_EMP_NO')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7391_ASG_INV_PERIOD_OF_SERV')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7392_ASG_INV_DEL_OF_ASS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7393_ASG_INVALID_GRADE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7396_ASG_FREQUENCY_REQD')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7399_ASG_NO_DEL_NON_PRIM')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7400_ASG_NO_DEL_ASS_EVENTS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7401_ASG_NO_DEL_ASS_LET_REQ')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7402_ASG_NO_DEL_COST_ALLOCS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7403_ASG_NO_DEL_PAYROLL_ACT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7404_ASG_NO_DEL_PER_PAY_MET')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7405_ASG_NO_DEL_COB_COV_ENR')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7406_ASG_NO_DEL_COB_COV_BEN')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7407_ASG_NO_DEL_ASS_STATUS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7409_ASG_NO_DEL_EXTR_INFO')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7410_ASG_NO_DEL_ASS_SET_AMD')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7412_ASG_ASS_TERM_IN_FUTURE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7427_ASG_INVALID_ASS_TYPE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7428_ASG_INV_PRIMARY_FLAG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7429_ASG_INV_MANAGER_FLAG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7434_ASG_GRADE_REQUIRED')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7435_ASG_PRIM_ASS_EXISTS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7436_ASG_NO_PRIM_ASS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7441_API_ARG_NOT_SET')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PAY_7599_SYS_SUP_DT_OUTDATE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7877_API_INVALID_CONSTRAINT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7915_ASG_INV_STAT_UPD_DATE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7917_ASG_INV_STAT_TYPE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7940_ASG_INV_ASG_STAT_TYPE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7941_ASG_INV_STAT_NOT_ACT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7942_ASG_INV_STAT_NOT_TERM')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7946_ASG_INV_TERM_ASS_UPD')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7949_ASG_DIF_SYSTEM_TYPES')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7964_ASG_INV_BUS_ATT_LEG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7969_ASG_INV_PAYROLL_PPMS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_7975_ASG_INV_FUTURE_ASA')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51000_ASG_INVALID_POS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51009_ASG_INVALID_BG_POS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51017_ASG_NUM_NULL_FOR_APL')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51028_ASG_INV_EMP_CATEGORY')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51040_ASG_INVALID_VAC_POS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51041_ASG_INVALID_VAC_LOC')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51042_ASG_INVALID_VAC_ORG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51148_ASG_INV_DEF_COD_COM')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51055_ASG_INV_POS_ORG_COMB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51056_ASG_INV_POS_JOB_COMB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51057_ASG_JOB_NULL_VALUE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51143_ASG_EMP_EQUAL_SUP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51145_ASG_SUP_BG_NE_EMP_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51147_ASG_DPE_BEF_MIN_ESD')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51149_ASG_INV_PRP_FREQ')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51151_ASG_INV_PROB_UNIT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51160_ASG_INV_SET_OF_BOOKS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51162_ASG_INV_SOURCE_TYPE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51163_ASG_INV_PRPF_PRP_COMB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51164_ASG_INV_SRP_FREQ')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51165_ASG_INV_SRPF_SRP_COMB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51166_ASG_INV_PU_PP_COMB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51167_ASG_PB_PD_OUT_OF_RAN')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51168_ASG_INV_PAY_BASIS_ID')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51169_ASG_INV_PAY_BAS_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51171_ASG_INV_PB_PP_CD')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51172_ASG_INV_DT_JOB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51173_ASG_INV_DT_JOB_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51175_ASG_INV_ASG_TYP_SOB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51176_ASG_INV_ASG_TYP_PBS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51177_ASG_INV_ASG_TYP_DCC')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51178_ASG_INV_ASG_TYP_PRPF')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51179_ASG_INV_ASG_TYP_PRP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51180_ASG_INV_ASG_TYP_SRP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51181_ASG_INV_ASG_TYP_SRPF')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51198_ASG_INV_APL_ASG_PF')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51203_ASG_INV_ASG_TYP_PDS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51206_ASG_INV_AST_ACT_FLG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51207_ASG_INV_AST_BUS_GRP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51210_ASG_INV_APL')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51211_ASG_INV_E_ASG_APL_ID')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51212_ASG_INV_APL_ASG_APL')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51213_ASG_INV_UPD_APL')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51214_ASG_INV_APL_BUS_GRP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51215_ASG_INACT_LOCATION')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51216_ASG_INV_ASG_TYP_REC')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51217_ASG_INV_ASG_TYP_ECAT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51219_ASG_INV_EASG_I_SORG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51220_ASG_INV_EASG_U_SORG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51221_ASG_INV_EASG_I_VAC')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51222_ASG_INV_EASG_U_VAC')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51223_ASG_INV_ASG_TYP_RCAT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51224_ASG_INV_ASG_TYP_PRB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51225_ASG_INV_ASG_TYP_SCS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51226_ASG_INV_ASG_TYP_PAY')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51227_ASG_INV_ASG_TYP_SCF')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51228_ASG_INV_EASG_CH_REAS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51229_ASG_INV_AASG_CH_REAS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51230_ASG_INV_ASG_TYP_IAL')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51232_ASG_INV_AASG_AST')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51252_ASG_INV_PGP_ENBD_FLAG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51275_ASG_INV_F_DT_AST_PSS')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51277_ASG_INV_HR_ORG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51280_ASG_INV_RECRUIT_ID')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51281_ASG_INV_VAC_REC')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51284_ASG_INV_RECRUIT_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51289_ASG_APL_EQUAL_RECRUIT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51290_ASG_RECRUIT_NOT_EMP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51291_ASG_INV_VAC_GRADE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51293_ASG_INV_VAC_JOB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51294_ASG_INV_AASG_PET')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51296_ASG_INV_VAC_PEO_GRP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51297_ASG_INV_VACANCY')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51300_ASG_INV_VAC_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51302_ASG_INV_PER_REF_BY')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51303_ASG_INV_PER_REF_BY_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51304_ASG_APL_EQUAL_PRB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51305_ASG_PER_RB_NOT_EMP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51306_ASG_INV_REC_ACT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51307_ASG_INV_REC_ACT_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51308_ASG_INV_SOURCE_ORG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51309_ASG_INV_SOURCE_ORG_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51316_ASG_INV_FSP_SOB_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51320_ASG_INV_PDS_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51323_ASG_INV_PRIM_ASG_EED')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51325_ASG_INV_SOU_TYP_RAT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51329_ASG_INV_EASG_PET')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51346_ASG_SUP_NOT_EMP')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_51375_ASG_INV_APL_NOT_1_ASG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_52217_DUP_APL_VACANCY')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_52990_ASG_PRADD_NE_PAY')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74800_CAGR_STRUCT_GRADE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74801_GRADE_NOT_STRUCT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74802_INVALID_CAGR_GRADE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74803_CAGR_ONLY_SELECT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74804_INVALID_STRUCTURE')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74806_INVALID_CONTRACT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74807_CONTRACT_PERSON')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74808_CONTRACT_IN_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74809_CONTRACT_AFTER_ASG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74810_COLLECTIVE_AGREEMENT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74811_COLLECTIVE_NOT_IN_BG')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='PER_74812_INVALID_ESTAB')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
   elsif (hr_message.last_message_name ='FLEX-NULL SEGMENT')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='FLEX-VALUE NOT FOUND')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  elsif (hr_message.last_message_name ='HR_FLEX_VALUE_INVALID')
      then hr_errors_api.addErrorToTable
      (p_errorfield => null
      ,p_errorcode  => hr_message.last_message_number
      ,p_errormsg   => hr_message.get_message_text);
  else
    null;
  end if;*/

end validate_assignment;
--
--
procedure get_asg_from_tt
          (p_transaction_step_id in     number
          ,p_assignment_rec         out nocopy per_all_assignments_f%rowtype
) is
/* this procedure gets all of the assignment data from the transaction tables
*/
l_assignment_id  per_all_assignments_f.assignment_id%TYPE;
l_effective_date date;

begin
--
  l_assignment_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_ID');
--
  l_effective_date:=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EFFECTIVE_DATE');
--
-- first of all get all of the old values
--
  get_asg_from_asg(p_assignment_id     => l_assignment_id
                  ,p_effective_date    => l_effective_date
                  ,p_assignment_rec    => p_assignment_rec);
--
-- then replace the new values that were written to the transaction table
--
  p_assignment_rec.object_version_number:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER');
--
  p_assignment_rec.organization_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ORGANIZATION_ID');
--
  p_assignment_rec.position_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_POSITION_ID');
--
  p_assignment_rec.job_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_JOB_ID');
--
  p_assignment_rec.grade_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_GRADE_ID');
--
  p_assignment_rec.location_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_LOCATION_ID');
--
  p_assignment_rec.employment_category:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_EMPLOYMENT_CATEGORY');
--
  p_assignment_rec.supervisor_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SUPERVISOR_ID');
--
  p_assignment_rec.manager_flag:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_MANAGER_FLAG');
--
  p_assignment_rec.normal_hours:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_NORMAL_HOURS');
--
  p_assignment_rec.frequency:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_FREQUENCY');
--
  p_assignment_rec.time_normal_finish:=
    substr(hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TIME_NORMAL_FINISH'),0,5);
--
  p_assignment_rec.time_normal_start:=
    substr(hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TIME_NORMAL_START'),0,5);
--
  p_assignment_rec.special_ceiling_step_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SPECIAL_CEILING_STEP_ID');
--
  p_assignment_rec.assignment_status_type_id:=
    hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASSIGNMENT_STATUS_TYPE_ID');
--
  p_assignment_rec.ass_attribute_category:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE_CATEGORY');
--
  p_assignment_rec.change_reason:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CHANGE_REASON');
--
  p_assignment_rec.ass_attribute1:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE1');
--
  p_assignment_rec.ass_attribute2:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE2');
--
  p_assignment_rec.ass_attribute3:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE3');
--
  p_assignment_rec.ass_attribute4:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE4');
--
  p_assignment_rec.ass_attribute5:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE5');
--
  p_assignment_rec.ass_attribute6:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE6');
--
  p_assignment_rec.ass_attribute7:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE7');
--
  p_assignment_rec.ass_attribute8:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE8');
--
  p_assignment_rec.ass_attribute9:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE9');
--
  p_assignment_rec.ass_attribute10:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE10');
--
  p_assignment_rec.ass_attribute11:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE11');
--
  p_assignment_rec.ass_attribute12:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE12');
--
  p_assignment_rec.ass_attribute13:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE13');
--
  p_assignment_rec.ass_attribute14:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE14');
--
  p_assignment_rec.ass_attribute15:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE15');
--
  p_assignment_rec.ass_attribute16:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE16');
--
  p_assignment_rec.ass_attribute17:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE17');
--
  p_assignment_rec.ass_attribute18:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE18');
--
  p_assignment_rec.ass_attribute19:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE19');
--
  p_assignment_rec.ass_attribute20:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE20');
--
  p_assignment_rec.ass_attribute21:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE21');
--
  p_assignment_rec.ass_attribute22:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE22');
--
  p_assignment_rec.ass_attribute23:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE23');
--
  p_assignment_rec.ass_attribute24:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE24');
--
  p_assignment_rec.ass_attribute25:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE25');
--
  p_assignment_rec.ass_attribute26:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE26');
--
  p_assignment_rec.ass_attribute27:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE27');
--
  p_assignment_rec.ass_attribute28:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE28');
--
  p_assignment_rec.ass_attribute29:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE29');
--
  p_assignment_rec.ass_attribute30:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ASS_ATTRIBUTE30');
--
end get_asg_from_tt;
--
procedure get_pgp_from_tt
          (p_transaction_step_id in     number
          ,p_pgp_rec         out nocopy pay_people_groups%rowtype
) is
/* this procedure gets all of the people group data from the transaction tables
*/
begin
--
  p_pgp_rec.segment1:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT1');
--
  p_pgp_rec.segment2:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT2');
--
  p_pgp_rec.segment3:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT3');
--
  p_pgp_rec.segment4:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT4');
--
  p_pgp_rec.segment5:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT5');
--
  p_pgp_rec.segment6:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT6');
--
  p_pgp_rec.segment7:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT7');
--
  p_pgp_rec.segment8:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT8');
--
  p_pgp_rec.segment9:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT9');
--
  p_pgp_rec.segment10:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT10');
--
  p_pgp_rec.segment11:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT11');
--
  p_pgp_rec.segment12:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT12');
--
  p_pgp_rec.segment13:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT13');
--
  p_pgp_rec.segment14:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT14');
--
  p_pgp_rec.segment15:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT15');
--
  p_pgp_rec.segment16:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT16');
--
  p_pgp_rec.segment17:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT17');
--
  p_pgp_rec.segment18:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT18');
--
  p_pgp_rec.segment19:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT19');
--
  p_pgp_rec.segment20:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT20');
--
  p_pgp_rec.segment21:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT21');
--
  p_pgp_rec.segment22:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT22');
--
  p_pgp_rec.segment23:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT23');
--
  p_pgp_rec.segment24:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT24');
--
  p_pgp_rec.segment25:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT25');
--
  p_pgp_rec.segment26:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT26');
--
  p_pgp_rec.segment27:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT27');
--
  p_pgp_rec.segment28:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT28');
--
  p_pgp_rec.segment29:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT29');
--
  p_pgp_rec.segment30:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PGP_SEGMENT30');
--
end get_pgp_from_tt;
--
--
procedure get_scl_from_tt
          (p_transaction_step_id in     number
          ,p_scl_rec         out nocopy hr_soft_coding_keyflex%rowtype
) is
/* this procedure gets all of the SCL data from the transaction tables
*/
begin
--
  p_scl_rec.segment1:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT1');
--
  p_scl_rec.segment2:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT2');
--
  p_scl_rec.segment3:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT3');
--
  p_scl_rec.segment4:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT4');
--
  p_scl_rec.segment5:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT5');
--
  p_scl_rec.segment6:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT6');
--
  p_scl_rec.segment7:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT7');
--
  p_scl_rec.segment8:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT8');
--
  p_scl_rec.segment9:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT9');
--
  p_scl_rec.segment10:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT10');
--
  p_scl_rec.segment11:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT11');
--
  p_scl_rec.segment12:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT12');
--
  p_scl_rec.segment13:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT13');
--
  p_scl_rec.segment14:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT14');
--
  p_scl_rec.segment15:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT15');
--
  p_scl_rec.segment16:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT16');
--
  p_scl_rec.segment17:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT17');
--
  p_scl_rec.segment18:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT18');
--
  p_scl_rec.segment19:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT19');
--
  p_scl_rec.segment20:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT20');
--
  p_scl_rec.segment21:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT21');
--
  p_scl_rec.segment22:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT22');
--
  p_scl_rec.segment23:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT23');
--
  p_scl_rec.segment24:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT24');
--
  p_scl_rec.segment25:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT25');
--
  p_scl_rec.segment26:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT26');
--
  p_scl_rec.segment27:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT27');
--
  p_scl_rec.segment28:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT28');
--
  p_scl_rec.segment29:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT29');
--
  p_scl_rec.segment30:=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_SCL_SEGMENT30');
--
end get_scl_from_tt;
--
procedure get_asg_from_asg(p_assignment_id  in     number
                          ,p_effective_date in     date
                          ,p_assignment_rec    out nocopy per_all_assignments_f%rowtype)
is
/* This procedure gets all of the assignment data from the online tables
*/
cursor csr_get_asg is
select *
from per_all_assignments_f
where assignment_id=p_assignment_id
and p_effective_date between effective_start_date and effective_end_date;
--
begin
--
  open csr_get_asg;
  fetch csr_get_asg into p_assignment_rec;
  if csr_get_asg%notfound then
    close csr_get_asg;
--
-- The primary key is invalid therefore we must error
--
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.raise_error;
--
  else
    close csr_get_asg;
  end if;
--
end get_asg_from_asg;
--
procedure get_pgp_from_pgp(p_people_group_id  in     number
                          ,p_pgp_rec    out nocopy pay_people_groups%rowtype)
is
/* This procedure gets all of the People Group data from the online tables
*/
--
cursor csr_get_pgp is
select *
from pay_people_groups
where people_group_id=p_people_group_id;
--
begin
  if p_people_group_id is not null then
    open csr_get_pgp;
    fetch csr_get_pgp into p_pgp_rec;
    if csr_get_pgp%notfound then
      close csr_get_pgp;
    --
    -- The primary key is invalid therefore we must error
    --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
          --
    else
      close csr_get_pgp;
    end if;
  end if;
end get_pgp_from_pgp;
--
procedure get_scl_from_scl(p_soft_coding_keyflex_id  in     number
                          ,p_scl_rec                    out nocopy hr_soft_coding_keyflex%rowtype)
is
/* This procedure gets all of the SCL data from the online tables
*/
--
cursor csr_get_scl is
select *
from hr_soft_coding_keyflex
where soft_coding_keyflex_id=p_soft_coding_keyflex_id;
--
begin
  if p_soft_coding_keyflex_id is not null then
    open csr_get_scl;
    fetch csr_get_scl into p_scl_rec;
    if csr_get_scl%notfound then
      close csr_get_scl;
    --
    -- The primary key is invalid therefore we must error
    --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
          --
    else
      close csr_get_scl;
    end if;
  end if;
--
end get_scl_from_scl;
--
procedure get_asg(
     p_item_type                in     wf_items.item_type%TYPE
    ,p_item_key                 in     wf_items.item_key%TYPE
    ,p_assignment_id            in     per_all_assignments_f.assignment_id%type
    ,p_effective_date           in     date
    ,p_assignment_rec              out nocopy per_all_assignments_f%rowtype) is
/* This procedure gets all of the assignment data from the transaction tables
   or the online tables if no processing step exists, based in a given item type
   and item key
*/
--
l_transaction_step_id number;
l_transaction_id      number;
--
begin
  get_step(p_item_type           => p_item_type
          ,p_item_key            => p_item_key
          ,p_api_name            => g_package || 'process_api'
          ,p_transaction_step_id => l_transaction_step_id
          ,p_transaction_id      => l_transaction_id);
  if l_transaction_step_id is not null then
    --
    get_asg_from_tt(p_transaction_step_id =>l_transaction_step_id
                   ,p_assignment_rec      => p_assignment_rec);
  else
    get_asg_from_asg(p_assignment_id      => p_assignment_id
                    ,p_effective_date     => p_effective_date
                    ,p_assignment_rec     => p_assignment_rec);
  end if;
end get_asg;
--
procedure get_step(
     p_item_type                in     wf_items.item_type%TYPE
    ,p_item_key                 in     wf_items.item_key%TYPE
    ,p_api_name                 in     varchar2
    ,p_transaction_step_id         out nocopy number
    ,p_transaction_id              out nocopy number) is
/* This procedure gets the transaction_step_id based on a given item_type and
   item_key
*/
--
cursor transaction_step is
select transaction_step_id
,      transaction_id
from hr_api_transaction_steps
where item_type=p_item_type
and   item_key=p_item_key
and   api_name=p_api_name;
--
begin
  open transaction_step;
  fetch transaction_step into p_transaction_step_id,p_transaction_id;
  if transaction_step%FOUND then
    close transaction_step;
  else
    close transaction_step;
  end if;
end get_step;
--
function step_open(
     p_item_type                in     wf_items.item_type%TYPE
    ,p_item_key                 in     wf_items.item_key%TYPE
    ,p_api_name                 in     varchar2) return boolean is
/* This procedure looks to see if a transaction step is open for a given
   item type, item key and api name
*/
--
l_transaction_step_id          number;
l_transaction_id               number;
--
begin
  get_step(p_item_type           => p_item_type
          ,p_item_key            => p_item_key
          ,p_api_name            => p_api_name
          ,p_transaction_step_id => l_transaction_step_id
          ,p_transaction_id      => l_transaction_id);
  if l_transaction_step_id is null then
    return FALSE;
  else
    return TRUE;
  end if;
end step_open;
--
end hr_assignment_common_save_web;

/
