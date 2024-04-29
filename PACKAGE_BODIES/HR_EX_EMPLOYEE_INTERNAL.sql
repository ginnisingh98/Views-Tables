--------------------------------------------------------
--  DDL for Package Body HR_EX_EMPLOYEE_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EX_EMPLOYEE_INTERNAL" as
/* $Header: peexebsi.pkb 120.5.12010000.2 2008/09/10 08:51:14 ppentapa ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_ex_employee_internal.';
--
-- ----------------------------------------------------------------------------
-- |------------------< terminate_employee (overloaded) >---------------------|
-- ----------------------------------------------------------------------------
--
procedure terminate_employee
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_termination_accepted_person   in     number   default hr_api.g_number
  ,p_accepted_termination_date     in     date     default hr_api.g_date
  ,p_actual_termination_date       in     date     default hr_api.g_date
  ,p_final_process_date            in out nocopy date
  ,p_last_standard_process_date    in out nocopy date
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_notified_termination_date     in     date     default hr_api.g_date
  ,p_projected_termination_date    in     date     default hr_api.g_date
  ,p_adjusted_svc_date             in     date     default hr_api.g_date
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_pds_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_pds_information1              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information2              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information3              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information4              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information5              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information6              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information7              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information8              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information9              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information10             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information11             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information12             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information13             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information14             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information15             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information16             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information17             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information18             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information19             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information20             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information21             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information22             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information23             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information24             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information25             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information26             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information27             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information28             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information29             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information30             in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_warning               out nocopy boolean
  ,p_event_warning                    out nocopy boolean
  ,p_interview_warning                out nocopy boolean
  ,p_review_warning                   out nocopy boolean
  ,p_recruiter_warning                out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  ,p_dod_warning                      out nocopy boolean
  ,p_org_now_no_manager_warning       out nocopy boolean
  ,p_addl_rights_warning              out nocopy boolean  -- fix 1370960
  ) is
--
l_alu_change_warning VARCHAR2(1) := 'N';
--
begin
  terminate_employee
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_period_of_service_id          => p_period_of_service_id
    ,p_object_version_number         => p_object_version_number
    ,p_person_type_id                => p_person_type_id
    ,p_assignment_status_type_id     => p_assignment_status_type_id
    ,p_termination_accepted_person   => p_termination_accepted_person
    ,p_accepted_termination_date     => p_accepted_termination_date
    ,p_actual_termination_date       => p_actual_termination_date
    ,p_final_process_date            => p_final_process_date
    ,p_last_standard_process_date    => p_last_standard_process_date
    ,p_leaving_reason                => p_leaving_reason
    ,p_comments                      => p_comments
    ,p_notified_termination_date     => p_notified_termination_date
    ,p_projected_termination_date    => p_projected_termination_date
    ,p_adjusted_svc_date             => p_adjusted_svc_date
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_pds_information_category      => p_pds_information_category
    ,p_pds_information1              => p_pds_information1
    ,p_pds_information2              => p_pds_information2
    ,p_pds_information3              => p_pds_information3
    ,p_pds_information4              => p_pds_information4
    ,p_pds_information5              => p_pds_information5
    ,p_pds_information6              => p_pds_information6
    ,p_pds_information7              => p_pds_information7
    ,p_pds_information8              => p_pds_information8
    ,p_pds_information9              => p_pds_information9
    ,p_pds_information10             => p_pds_information10
    ,p_pds_information11             => p_pds_information11
    ,p_pds_information12             => p_pds_information12
    ,p_pds_information13             => p_pds_information13
    ,p_pds_information14             => p_pds_information14
    ,p_pds_information15             => p_pds_information15
    ,p_pds_information16             => p_pds_information16
    ,p_pds_information17             => p_pds_information17
    ,p_pds_information18             => p_pds_information18
    ,p_pds_information19             => p_pds_information19
    ,p_pds_information20             => p_pds_information20
    ,p_pds_information21             => p_pds_information21
    ,p_pds_information22             => p_pds_information22
    ,p_pds_information23             => p_pds_information23
    ,p_pds_information24             => p_pds_information24
    ,p_pds_information25             => p_pds_information25
    ,p_pds_information26             => p_pds_information26
    ,p_pds_information27             => p_pds_information27
    ,p_pds_information28             => p_pds_information28
    ,p_pds_information29             => p_pds_information29
    ,p_pds_information30             => p_pds_information30
    ,p_supervisor_warning            => p_supervisor_warning
    ,p_event_warning                 => p_event_warning
    ,p_interview_warning             => p_interview_warning
    ,p_review_warning                => p_review_warning
    ,p_recruiter_warning             => p_recruiter_warning
    ,p_asg_future_changes_warning    => p_asg_future_changes_warning
    ,p_entries_changed_warning       => p_entries_changed_warning
    ,p_pay_proposal_warning          => p_pay_proposal_warning
    ,p_dod_warning                   => p_dod_warning
    ,p_org_now_no_manager_warning    => p_org_now_no_manager_warning
    ,p_addl_rights_warning           => p_addl_rights_warning
    ,p_alu_change_warning            => l_alu_change_warning
    );
end terminate_employee;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< terminate_employee >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure terminate_employee
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_termination_accepted_person   in     number   default hr_api.g_number
  ,p_accepted_termination_date     in     date     default hr_api.g_date
  ,p_actual_termination_date       in     date     default hr_api.g_date
  ,p_final_process_date            in out nocopy date
  ,p_last_standard_process_date    in out nocopy date
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_notified_termination_date     in     date     default hr_api.g_date
  ,p_projected_termination_date    in     date     default hr_api.g_date
  ,p_adjusted_svc_date             in     date     default hr_api.g_date
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_pds_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_pds_information1              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information2              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information3              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information4              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information5              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information6              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information7              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information8              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information9              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information10             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information11             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information12             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information13             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information14             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information15             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information16             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information17             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information18             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information19             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information20             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information21             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information22             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information23             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information24             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information25             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information26             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information27             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information28             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information29             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information30             in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_warning               out nocopy boolean
  ,p_event_warning                    out nocopy boolean
  ,p_interview_warning                out nocopy boolean
  ,p_review_warning                   out nocopy boolean
  ,p_recruiter_warning                out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  ,p_dod_warning                      out nocopy boolean
  ,p_org_now_no_manager_warning       out nocopy boolean
  ,p_addl_rights_warning              out nocopy boolean  -- fix 1370960
--
-- 120.2 (START)
--
  ,p_alu_change_warning               out nocopy varchar2
--
-- 120.2 (END)
--
  ) is

--
-- 120.2 (START)
--
l_alu_change_warning varchar2(1) := 'N';
--
-- 120.2 (END)
--
l_cur_pds ben_pps_ler.g_pps_ler_rec;
l_new_pds ben_pps_ler.g_pps_ler_rec;

l_last_std_process_date_in  date;
l_last_std_process_date_out date;

dummy number := 0; -- fix 1370960
l_proc varchar2(100) := g_package||'.terminate_employee';

--
-- 120.2 (START)
--
l_atd_new  number := 1;
l_lspd_new number := 1;
--
-- 120.2 (END)
--
cursor csr_get_pds_details is
    select person_id
          ,business_group_id
     ,date_start
     ,actual_termination_date
     ,leaving_reason
     ,adjusted_svc_date
     ,attribute1
     ,attribute2
     ,attribute3
     ,attribute4
     ,attribute5
     ,final_process_date
     ,period_of_service_id
      from per_periods_of_service
     where period_of_service_id = p_period_of_service_id;
-- fix 1370960
cursor csr_roles_to_terminate( p_person_id in number ) is
  select
    role_id
  , object_version_number
  , end_date
  from per_roles
  where person_id = p_person_id
  and p_actual_termination_date
  between start_date
  and nvl(end_date, hr_api.g_eot);

cursor csr_chk_addl_rights( p_person_id in number) is
  select role_id
  from per_roles
  where person_id = p_person_id
  and EMP_RIGHTS_FLAG = 'Y'
  and nvl(end_of_rights_date, hr_api.g_eot) > p_actual_termination_date;
-- end fix 1370960

--
--START WWBUG 2130950 HR/WF Synchronization  --tpapired
  l_pds_rec per_periods_of_service%rowtype;
  cursor l_pds_cur is
    select *
    from per_periods_of_service
    where period_of_service_id = p_period_of_service_id;
--END   WWBUG 2130950 HR/WF Synchronization  --tpapired
--
--
-- 120.2 (START)
--
  CURSOR csr_asg_rec (cp_person_id            IN NUMBER,
                      cp_period_of_service_id IN NUMBER,
                      cp_old_fpd              IN DATE) IS
  SELECT assignment_id
  ,      assignment_status_type_id
  ,      business_group_id
  ,      effective_start_date
  ,      effective_end_date
  ,      payroll_id
  ,      object_version_number
  FROM   per_assignments_f asg
  WHERE  asg.person_id = cp_person_id
  AND    asg.period_of_service_id = cp_period_of_service_id
  AND    cp_old_fpd BETWEEN asg.effective_start_date
                        AND asg.effective_end_date;
--
-- 120.2 (END)
--

-- fix for bug6892097
-- added this new cursor to check for future asg changes when atd=fpd.
-- this check has been implemented here because it is complex to handle this in
-- hr_assignment_internal package . (while terminating the person a new record with atd + 1 will be
-- created and then deleted when atd=fpd )
 cursor csr_get_asg_end_date(p_fpd_date1 date) is
  select max(asg.effective_end_date)
  from   per_all_assignments_f asg
  where  asg.period_of_service_id = p_period_of_service_id
  and    asg.effective_start_date > p_fpd_date1;
  l_max_asg_date1 date;
  -- end of bug6892097
  --
begin

  hr_utility.set_location('Entering '||l_proc,10);
  /*
  ** We are processing a termination using the combined internel API. To
  ** enable correct processing of OAB life events we need to mask the
  ** PDS life event processing from the PDS row handler and make a
  ** single call from this internal API.
  */
  g_mask_pds_ler := TRUE;
  /*
  ** We need to get the details currently on the PDS record so that
  ** we know if the person has already been partially or fully terminated.
  ** If partial termination (ATD set but FPD not set) then don't call
  ** actual_termination_emp API. If full termination (ATD and FPD both set)
  ** then don't call either termination API and just update the details.
  */
  open l_pds_cur;
  fetch l_pds_cur into l_pds_rec;
  close l_pds_cur;

  open csr_get_pds_details;
  fetch csr_get_pds_details
   into l_cur_pds;
  close csr_get_pds_details;

  hr_utility.set_location('LSPD '||to_char(p_last_standard_process_date,
                                         'dd-mon-yyyy'),20);
  begin
    /*
    ** Set global variable so that the ATD is available to
    ** localization hooks during validation of flex info. (requested by
    ** FR locz.
    */
    g_actual_termination_date := p_actual_termination_date;
    /*
    ** Save the non-termination related PDS information....
    */
    hr_periods_of_service_api.update_pds_details
       (p_effective_date              => p_effective_date
       ,p_period_of_service_id        => p_period_of_service_id
       ,p_termination_accepted_person => p_termination_accepted_person
       ,p_accepted_termination_date   => p_accepted_termination_date
--
-- 120.2 (START)
--
       ,p_actual_termination_date     => p_actual_termination_date
       ,p_last_standard_process_date  => p_last_standard_process_date
       ,p_final_process_date          => p_final_process_date
--
-- 120.2 (END)
--
       ,p_object_version_number       => p_object_version_number
       ,p_comments                    => p_comments
       ,p_leaving_reason              => p_leaving_reason
       ,p_notified_termination_date   => p_notified_termination_date
       ,p_projected_termination_date  => p_projected_termination_date
       ,p_attribute_category          => p_attribute_category
       ,p_attribute1                  => p_attribute1
       ,p_attribute2                  => p_attribute2
       ,p_attribute3                  => p_attribute3
       ,p_attribute4                  => p_attribute4
       ,p_attribute5                  => p_attribute5
       ,p_attribute6                  => p_attribute6
       ,p_attribute7                  => p_attribute7
       ,p_attribute8                  => p_attribute8
       ,p_attribute9                  => p_attribute9
       ,p_attribute10                 => p_attribute10
       ,p_attribute11                 => p_attribute11
       ,p_attribute12                 => p_attribute12
       ,p_attribute13                 => p_attribute13
       ,p_attribute14                 => p_attribute14
       ,p_attribute15                 => p_attribute15
       ,p_attribute16                 => p_attribute16
       ,p_attribute17                 => p_attribute17
       ,p_attribute18                 => p_attribute18
       ,p_attribute19                 => p_attribute19
       ,p_attribute20                 => p_attribute20
       ,p_pds_information_category    => p_pds_information_category
       ,p_pds_information1            => p_pds_information1
       ,p_pds_information2            => p_pds_information2
       ,p_pds_information3            => p_pds_information3
       ,p_pds_information4            => p_pds_information4
       ,p_pds_information5            => p_pds_information5
       ,p_pds_information6            => p_pds_information6
       ,p_pds_information7            => p_pds_information7
       ,p_pds_information8            => p_pds_information8
       ,p_pds_information9            => p_pds_information9
       ,p_pds_information10           => p_pds_information10
       ,p_pds_information11           => p_pds_information11
       ,p_pds_information12           => p_pds_information12
       ,p_pds_information13           => p_pds_information13
       ,p_pds_information14           => p_pds_information14
       ,p_pds_information15           => p_pds_information15
       ,p_pds_information16           => p_pds_information16
       ,p_pds_information17           => p_pds_information17
       ,p_pds_information18           => p_pds_information18
       ,p_pds_information19           => p_pds_information19
       ,p_pds_information20           => p_pds_information20
       ,p_pds_information21           => p_pds_information21
       ,p_pds_information22           => p_pds_information22
       ,p_pds_information23           => p_pds_information23
       ,p_pds_information24           => p_pds_information24
       ,p_pds_information25           => p_pds_information25
       ,p_pds_information26           => p_pds_information26
       ,p_pds_information27           => p_pds_information27
       ,p_pds_information28           => p_pds_information28
       ,p_pds_information29           => p_pds_information29
       ,p_pds_information30           => p_pds_information30
--
-- 120.2 (START)
--
       ,p_org_now_no_manager_warning  => p_org_now_no_manager_warning
       ,p_asg_future_changes_warning  => p_asg_future_changes_warning
       ,p_entries_changed_warning     => p_entries_changed_warning
--
-- 120.2 (END)
--
       );
--
-- 120.2 (START)
--
    -- For all associated assignments invoke PAY POG processing.
    for lr_asg_rec in csr_asg_rec(l_pds_rec.person_id,
                                  p_period_of_service_id,
                                  l_pds_rec.final_process_date)
    loop
      --
      -- If the FPD has been made null, invoke PAY POG processing to handle this
      --
      if (l_pds_rec.final_process_date is not null and
          p_final_process_date is null)
      then
        -- Invoke pay pog processing
        pay_pog_all_assignments_pkg.after_delete
          (p_effective_date               => p_effective_date
          ,p_datetrack_mode               => 'DELETE_NEXT_CHANGE'
          ,p_validation_start_date        => lr_asg_rec.effective_start_date
          ,p_validation_end_date          => lr_asg_rec.effective_end_date
          ,p_assignment_id                => lr_asg_rec.assignment_id
          ,p_effective_end_date           => hr_api.g_eot
          ,p_effective_start_date         => lr_asg_rec.effective_start_date
          ,p_object_version_number        => lr_asg_rec.object_version_number
          ,p_org_now_no_manager_warning   => null
          ,p_applicant_rank_o             => null
          ,p_application_id_o             => null
          ,p_assignment_category_o        => null
          ,p_assignment_number_o          => null
          ,p_assignment_sequence_o        => null
          ,p_assignment_status_type_id_o  => null
          ,p_assignment_type_o            => null
          ,p_ass_attribute1_o             => null
          ,p_ass_attribute10_o            => null
          ,p_ass_attribute11_o            => null
          ,p_ass_attribute12_o            => null
          ,p_ass_attribute13_o            => null
          ,p_ass_attribute14_o            => null
          ,p_ass_attribute15_o            => null
          ,p_ass_attribute16_o            => null
          ,p_ass_attribute17_o            => null
          ,p_ass_attribute18_o            => null
          ,p_ass_attribute19_o            => null
          ,p_ass_attribute2_o             => null
          ,p_ass_attribute20_o            => null
          ,p_ass_attribute21_o            => null
          ,p_ass_attribute22_o            => null
          ,p_ass_attribute23_o            => null
          ,p_ass_attribute24_o            => null
          ,p_ass_attribute25_o            => null
          ,p_ass_attribute26_o            => null
          ,p_ass_attribute27_o            => null
          ,p_ass_attribute28_o            => null
          ,p_ass_attribute29_o            => null
          ,p_ass_attribute3_o             => null
          ,p_ass_attribute30_o            => null
          ,p_ass_attribute4_o             => null
          ,p_ass_attribute5_o             => null
          ,p_ass_attribute6_o             => null
          ,p_ass_attribute7_o             => null
          ,p_ass_attribute8_o             => null
          ,p_ass_attribute9_o             => null
          ,p_ass_attribute_category_o     => null
          ,p_bargaining_unit_code_o       => null
          ,p_business_group_id_o          => lr_asg_rec.business_group_id
          ,p_cagr_grade_def_id_o          => null
          ,p_cagr_id_flex_num_o           => null
          ,p_change_reason_o              => null
          ,p_collective_agreement_id_o    => null
          ,p_comment_id_o                 => null
          ,p_contract_id_o                => null
          ,p_date_probation_end_o         => null
          ,p_default_code_comb_id_o       => null
          ,p_effective_end_date_o         => l_pds_rec.final_process_date
          ,p_effective_start_date_o       => lr_asg_rec.effective_start_date
          ,p_employee_category_o          => null
          ,p_employment_category_o        => null
          ,p_establishment_id_o           => null
          ,p_frequency_o                  => null
          ,p_grade_id_o                   => null
          ,p_hourly_salaried_code_o       => null
          ,p_internal_address_line_o      => null
          ,p_job_id_o                     => null
          ,p_job_post_source_name_o       => null
          ,p_labour_union_member_flag_o   => null
          ,p_location_id_o                => null
          ,p_manager_flag_o               => null
          ,p_normal_hours_o               => null
          ,p_notice_period_o              => null
          ,p_notice_period_uom_o          => null
          ,p_object_version_number_o      => null
          ,p_organization_id_o            => null
          ,p_payroll_id_o                 => lr_asg_rec.payroll_id
          ,p_pay_basis_id_o               => null
          ,p_people_group_id_o            => null
          ,p_perf_review_period_o         => null
          ,p_perf_review_period_frequen_o => null
          ,p_period_of_service_id_o       => null
          ,p_person_id_o                  => null
          ,p_person_referred_by_id_o      => null
          ,p_placement_date_start_o       => null
          ,p_position_id_o                => null
          ,p_posting_content_id_o         => null
          ,p_primary_flag_o               => null
          ,p_probation_period_o           => null
          ,p_probation_unit_o             => null
          ,p_program_application_id_o     => null
          ,p_program_id_o                 => null
          ,p_program_update_date_o        => null
          ,p_project_title_o              => null
          ,p_recruiter_id_o               => null
          ,p_recruitment_activity_id_o    => null
          ,p_request_id_o                 => null
          ,p_sal_review_period_o          => null
          ,p_sal_review_period_frequen_o  => null
          ,p_set_of_books_id_o            => null
          ,p_soft_coding_keyflex_id_o     => null
          ,p_source_organization_id_o     => null
          ,p_source_type_o                => null
          ,p_special_ceiling_step_id_o    => null
          ,p_supervisor_id_o              => null
          ,p_time_normal_finish_o         => null
          ,p_time_normal_start_o          => null
          ,p_title_o                      => null
          ,p_vacancy_id_o                 => null
          ,p_vendor_assignment_number_o   => null
          ,p_vendor_employee_number_o     => null
          ,p_vendor_id_o                  => null
          ,p_work_at_home_o               => null
          ,p_grade_ladder_pgm_id_o        => null
          ,p_supervisor_assignment_id_o   => null
          ,p_vendor_site_id_o             => null
          ,p_po_header_id_o               => null
          ,p_po_line_id_o                 => null
          ,p_projected_assignment_end_o   => null
          );
      end if; -- FPD has been nulled from not null
      --
      -- If the FPD has been changed
      --
      if (l_pds_rec.final_process_date is not null and
          p_final_process_date is not null and
          l_pds_rec.final_process_date <> p_final_process_date)
      then
        -- Invoke pay pog processing
        pay_pog_all_assignments_pkg.after_delete
          (p_effective_date               => p_effective_date
          ,p_datetrack_mode               => 'DELETE_NEXT_CHANGE'
          ,p_validation_start_date        => lr_asg_rec.effective_start_date
          ,p_validation_end_date          => lr_asg_rec.effective_end_date
          ,p_assignment_id                => lr_asg_rec.assignment_id
          ,p_effective_end_date           => lr_asg_rec.effective_end_date
          ,p_effective_start_date         => lr_asg_rec.effective_start_date
          ,p_object_version_number        => lr_asg_rec.object_version_number
          ,p_org_now_no_manager_warning   => null
          ,p_applicant_rank_o             => null
          ,p_application_id_o             => null
          ,p_assignment_category_o        => null
          ,p_assignment_number_o          => null
          ,p_assignment_sequence_o        => null
          ,p_assignment_status_type_id_o  => null
          ,p_assignment_type_o            => null
          ,p_ass_attribute1_o             => null
          ,p_ass_attribute10_o            => null
          ,p_ass_attribute11_o            => null
          ,p_ass_attribute12_o            => null
          ,p_ass_attribute13_o            => null
          ,p_ass_attribute14_o            => null
          ,p_ass_attribute15_o            => null
          ,p_ass_attribute16_o            => null
          ,p_ass_attribute17_o            => null
          ,p_ass_attribute18_o            => null
          ,p_ass_attribute19_o            => null
          ,p_ass_attribute2_o             => null
          ,p_ass_attribute20_o            => null
          ,p_ass_attribute21_o            => null
          ,p_ass_attribute22_o            => null
          ,p_ass_attribute23_o            => null
          ,p_ass_attribute24_o            => null
          ,p_ass_attribute25_o            => null
          ,p_ass_attribute26_o            => null
          ,p_ass_attribute27_o            => null
          ,p_ass_attribute28_o            => null
          ,p_ass_attribute29_o            => null
          ,p_ass_attribute3_o             => null
          ,p_ass_attribute30_o            => null
          ,p_ass_attribute4_o             => null
          ,p_ass_attribute5_o             => null
          ,p_ass_attribute6_o             => null
          ,p_ass_attribute7_o             => null
          ,p_ass_attribute8_o             => null
          ,p_ass_attribute9_o             => null
          ,p_ass_attribute_category_o     => null
          ,p_bargaining_unit_code_o       => null
          ,p_business_group_id_o          => lr_asg_rec.business_group_id
          ,p_cagr_grade_def_id_o          => null
          ,p_cagr_id_flex_num_o           => null
          ,p_change_reason_o              => null
          ,p_collective_agreement_id_o    => null
          ,p_comment_id_o                 => null
          ,p_contract_id_o                => null
          ,p_date_probation_end_o         => null
          ,p_default_code_comb_id_o       => null
          ,p_effective_end_date_o         => l_pds_rec.final_process_date
          ,p_effective_start_date_o       => lr_asg_rec.effective_start_date
          ,p_employee_category_o          => null
          ,p_employment_category_o        => null
          ,p_establishment_id_o           => null
          ,p_frequency_o                  => null
          ,p_grade_id_o                   => null
          ,p_hourly_salaried_code_o       => null
          ,p_internal_address_line_o      => null
          ,p_job_id_o                     => null
          ,p_job_post_source_name_o       => null
          ,p_labour_union_member_flag_o   => null
          ,p_location_id_o                => null
          ,p_manager_flag_o               => null
          ,p_normal_hours_o               => null
          ,p_notice_period_o              => null
          ,p_notice_period_uom_o          => null
          ,p_object_version_number_o      => null
          ,p_organization_id_o            => null
          ,p_payroll_id_o                 => lr_asg_rec.payroll_id
          ,p_pay_basis_id_o               => null
          ,p_people_group_id_o            => null
          ,p_perf_review_period_o         => null
          ,p_perf_review_period_frequen_o => null
          ,p_period_of_service_id_o       => null
          ,p_person_id_o                  => null
          ,p_person_referred_by_id_o      => null
          ,p_placement_date_start_o       => null
          ,p_position_id_o                => null
          ,p_posting_content_id_o         => null
          ,p_primary_flag_o               => null
          ,p_probation_period_o           => null
          ,p_probation_unit_o             => null
          ,p_program_application_id_o     => null
          ,p_program_id_o                 => null
          ,p_program_update_date_o        => null
          ,p_project_title_o              => null
          ,p_recruiter_id_o               => null
          ,p_recruitment_activity_id_o    => null
          ,p_request_id_o                 => null
          ,p_sal_review_period_o          => null
          ,p_sal_review_period_frequen_o  => null
          ,p_set_of_books_id_o            => null
          ,p_soft_coding_keyflex_id_o     => null
          ,p_source_organization_id_o     => null
          ,p_source_type_o                => null
          ,p_special_ceiling_step_id_o    => null
          ,p_supervisor_id_o              => null
          ,p_time_normal_finish_o         => null
          ,p_time_normal_start_o          => null
          ,p_title_o                      => null
          ,p_vacancy_id_o                 => null
          ,p_vendor_assignment_number_o   => null
          ,p_vendor_employee_number_o     => null
          ,p_vendor_id_o                  => null
          ,p_work_at_home_o               => null
          ,p_grade_ladder_pgm_id_o        => null
          ,p_supervisor_assignment_id_o   => null
          ,p_vendor_site_id_o             => null
          ,p_po_header_id_o               => null
          ,p_po_line_id_o                 => null
          ,p_projected_assignment_end_o   => null
          );
      end if; -- FPD has changed
      --
    end loop; -- Loop through assignments
--
-- 120.2 (END)
--
    /*
    ** Process actual termination date if it's set for the first time....
    */
    if (    l_pds_rec.actual_termination_date is null
        and p_actual_termination_date is not null)
     OR
       (    l_pds_rec.last_standard_process_date is null
        and p_last_standard_process_date is not null)
    then
      l_last_std_process_date_in := p_last_standard_process_date;
--
-- 120.2 (START)
--
      if l_pds_rec.actual_termination_date is null then
        l_atd_new := 1;
      else
        l_atd_new := 0;
      end if;
      if l_pds_rec.last_standard_process_date is null then
        l_lspd_new := 1;
      else
        l_lspd_new := 0;
      end if;
--
-- 120.2 (END)
--
-- added for bug6892097
if p_actual_termination_date = p_final_process_date then
open csr_get_asg_end_date(p_actual_termination_date);
fetch csr_get_asg_end_date into l_max_asg_date1;
close csr_get_asg_end_date;
end if ;

-- end of bug6892097
--
      hr_ex_employee_api.actual_termination_emp
         (p_effective_date             => p_effective_date
         ,p_period_of_service_id       => p_period_of_service_id
         ,p_object_version_number      => p_object_version_number
         ,p_actual_termination_date    => p_actual_termination_date
         ,p_last_standard_process_date => l_last_std_process_date_in
         ,p_person_type_id             => p_person_type_id
         ,p_assignment_status_type_id  => p_assignment_status_type_id
         ,p_leaving_reason             => p_leaving_reason
--
-- 120.2 (START)
--
         ,p_atd_new                    => l_atd_new
         ,p_lspd_new                   => l_lspd_new
--
-- 120.2 (END)
--
         ,p_attribute_category          => p_attribute_category
         ,p_attribute1                  => p_attribute1
         ,p_attribute2                  => p_attribute2
         ,p_attribute3                  => p_attribute3
         ,p_attribute4                  => p_attribute4
         ,p_attribute5                  => p_attribute5
         ,p_attribute6                  => p_attribute6
         ,p_attribute7                  => p_attribute7
         ,p_attribute8                  => p_attribute8
         ,p_attribute9                  => p_attribute9
         ,p_attribute10                 => p_attribute10
         ,p_attribute11                 => p_attribute11
         ,p_attribute12                 => p_attribute12
         ,p_attribute13                 => p_attribute13
         ,p_attribute14                 => p_attribute14
         ,p_attribute15                 => p_attribute15
         ,p_attribute16                 => p_attribute16
         ,p_attribute17                 => p_attribute17
         ,p_attribute18                 => p_attribute18
         ,p_attribute19                 => p_attribute19
         ,p_attribute20                 => p_attribute20
         ,p_pds_information_category    => p_pds_information_category
         ,p_pds_information1            => p_pds_information1
         ,p_pds_information2            => p_pds_information2
         ,p_pds_information3            => p_pds_information3
         ,p_pds_information4            => p_pds_information4
         ,p_pds_information5            => p_pds_information5
         ,p_pds_information6            => p_pds_information6
         ,p_pds_information7            => p_pds_information7
         ,p_pds_information8            => p_pds_information8
         ,p_pds_information9            => p_pds_information9
         ,p_pds_information10           => p_pds_information10
         ,p_pds_information11           => p_pds_information11
         ,p_pds_information12           => p_pds_information12
         ,p_pds_information13           => p_pds_information13
         ,p_pds_information14           => p_pds_information14
         ,p_pds_information15           => p_pds_information15
         ,p_pds_information16           => p_pds_information16
         ,p_pds_information17           => p_pds_information17
         ,p_pds_information18           => p_pds_information18
         ,p_pds_information19           => p_pds_information19
         ,p_pds_information20           => p_pds_information20
         ,p_pds_information21           => p_pds_information21
         ,p_pds_information22           => p_pds_information22
         ,p_pds_information23           => p_pds_information23
         ,p_pds_information24           => p_pds_information24
         ,p_pds_information25           => p_pds_information25
         ,p_pds_information26           => p_pds_information26
         ,p_pds_information27           => p_pds_information27
         ,p_pds_information28           => p_pds_information28
         ,p_pds_information29           => p_pds_information29
         ,p_pds_information30           => p_pds_information30
    ,p_last_std_process_date_out  => l_last_std_process_date_out
         ,p_supervisor_warning         => p_supervisor_warning
         ,p_event_warning              => p_event_warning
         ,p_interview_warning          => p_interview_warning
         ,p_review_warning             => p_review_warning
         ,p_recruiter_warning          => p_recruiter_warning
         ,p_asg_future_changes_warning => p_asg_future_changes_warning
         ,p_entries_changed_warning    => p_entries_changed_warning
         ,p_pay_proposal_warning       => p_pay_proposal_warning
         ,p_dod_warning                => p_dod_warning
--
-- 120.2 (START)
--
         ,p_alu_change_warning         => l_alu_change_warning
--
-- 120.2 (END)
--
         );

      p_last_standard_process_date := l_last_std_process_date_out;
--
-- 120.2 (START)
--
      p_alu_change_warning := l_alu_change_warning;
--
-- 120.2 (END)
--

      -- fix 1370960
      -- Terminate the roles
      hr_utility.set_location('l_cur_pds.person_id' || l_cur_pds.person_id, 960);
      for roles_rec in csr_roles_to_terminate( l_cur_pds.person_id )
      loop
        per_supplementary_role_api.update_supplementary_role(
        p_effective_date                => p_effective_date
        ,p_role_id                      => roles_rec.role_id
        ,p_object_version_number        => roles_rec.object_version_number
        ,p_end_date                     => p_actual_termination_date
        ,p_old_end_date                 => roles_rec.end_date
        );
      end loop;

      -- Raise a warning if extra rights are there for the person
      open csr_chk_addl_rights( l_cur_pds.person_id );
      fetch csr_chk_addl_rights into dummy;
      if csr_chk_addl_rights%found then
        p_addl_rights_warning := TRUE;
      else
        p_addl_rights_warning := FALSE;
      end if;
      close csr_chk_addl_rights;
      -- end fix 1370960
     end if;

    /*
    ** If it's set process final process date....
    */
    if     l_pds_rec.final_process_date is null
       and p_final_process_date is not null
    then
      hr_ex_employee_api.final_process_emp
         (p_period_of_service_id        => p_period_of_service_id
         ,p_object_version_number       => p_object_version_number
         ,p_final_process_date          => p_final_process_date
         ,p_org_now_no_manager_warning  => p_org_now_no_manager_warning
         ,p_asg_future_changes_warning  => p_asg_future_changes_warning
         ,p_entries_changed_warning     => p_entries_changed_warning
         );
    end if;
--
-- fix for bug6892097
 hr_utility.set_location('p_asg_future ', 99);
 if p_asg_future_changes_warning = FALSE then
  hr_utility.set_location('p_asg_future ', 100);
    if l_max_asg_date1 is not null then
    hr_utility.set_location('p_asg_future ', 101);
          p_asg_future_changes_warning := TRUE;

    end if;
end if;
-- fix for bug6892097

    /*
    ** Now perform the PDS life event processing....
    */
    l_new_pds.person_id := l_cur_pds.person_id;
    l_new_pds.business_group_id := l_cur_pds.business_group_id;
    l_new_pds.date_start := l_cur_pds.date_start;
    l_new_pds.actual_termination_date := p_actual_termination_date;
    l_new_pds.leaving_reason := p_leaving_reason;
    l_new_pds.adjusted_svc_date := p_adjusted_svc_date;
    l_new_pds.attribute1 := p_attribute1;
    l_new_pds.attribute2 := p_attribute2;
    l_new_pds.attribute3 := p_attribute3;
    l_new_pds.attribute4 := p_attribute4;
    l_new_pds.attribute5 := p_attribute5;
    l_new_pds.final_process_date := p_final_process_date;
    l_new_pds.period_of_service_id := p_period_of_service_id;

    ben_pps_ler.ler_chk(p_old            => l_cur_pds
                       ,p_new            => l_new_pds
                       ,p_event          => 'UPDATING'
                       ,p_effective_date => p_effective_date);
--
--START WWBUG 2130950 HR/WF Synchronization  --tpapired

/* Bug 5504659
  open l_pds_cur;
  fetch l_pds_cur into l_pds_rec;
  close l_pds_cur;
    per_hrwf_synch.per_pds_wf(
                          p_rec     => l_pds_rec,
                          p_date    => p_actual_termination_date,
                          p_action  => 'TERMINATION');
Note : added p_date_start to test, earlier code does not work*/

--
--END   WWBUG 2130950 HR/WF Synchronization  --tpapired
--
  hr_utility.set_location('Leaving '||l_proc,100);
  exception
    when others then
      g_mask_pds_ler := FALSE;
      raise;
  end;
end terminate_employee;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< reverse_terminate_employee  >-------------------------|
-- ----------------------------------------------------------------------------

procedure reverse_terminate_employee
  (p_person_id                     in     number
  ,p_actual_termination_date       in     date
  ,p_clear_details                 in     varchar2
  ) is

  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'reverse_terminate_employee';

  begin
    hr_utility.set_location('Entering: hrempter.cancel_termination'|| l_proc, 5);

     --
     -- Process Logic
     --
          hrempter.cancel_termination(p_person_id
                                     ,p_actual_termination_date
                                     ,p_clear_details);
    hr_utility.set_location('After: hrempter.cancel_termination'|| l_proc, 10);

  exception
    when others then
    raise;
end reverse_terminate_employee;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< RETURN_TERM_TYPE >---------------------------|
-- ----------------------------------------------------------------------------
--
Function return_term_type (p_LEAVING_REASON  IN VARCHAR2,
      P_BUSINESS_GROUP_ID IN NUMBER default null)
return varchar2 IS

-- this cursor will be used to return the Status type code available globally
cursor csr_shared_types is
select SHARED_TYPE_CODE from
per_shared_types
where system_type_cd = p_LEAVING_REASON
and lookup_type='LEAV_REAS';

-- this cursor will be used to return the Status type code for the specific  business group.
cursor csr_shared_types_bg is
select SHARED_TYPE_CODE from
per_shared_types
where system_type_cd = p_LEAVING_REASON
and lookup_type='LEAV_REAS'
and business_group_id=p_business_group_id;


TERM_TYPE VARCHAR2(30);

begin

if P_BUSINESS_GROUP_ID is not null then

OPEN csr_shared_types_bg ;
FETCH csr_shared_types_bg INTO TERM_TYPE;
CLOSE csr_shared_types_bg;

else

OPEN csr_shared_types ;
FETCH csr_shared_types INTO TERM_TYPE;
CLOSE csr_shared_types;

end if;


hr_utility.set_location('l_proc'||TERM_TYPE, 2);
hr_utility.set_location('l_proc', 30);

return TERM_TYPE;


end return_term_type;

end hr_ex_employee_internal;

/
