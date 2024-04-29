--------------------------------------------------------
--  DDL for Package Body HR_EX_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EX_EMPLOYEE_API" as
/* $Header: peexeapi.pkb 120.9.12010000.2 2009/04/30 10:47:09 dparthas ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_ex_employee_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< pre_term_check >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure pre_term_check(p_status              IN OUT NOCOPY VARCHAR2
                        ,p_business_group_id   IN     NUMBER
                        ,p_person_id           IN     NUMBER
                        ,p_session_date        IN     DATE
                        )is
--
--
v_dummy VARCHAR2(1);
l_proc varchar2(45) := g_package||'pre_term_check';
--
begin
   if p_status = 'SUPERVISOR' then
      begin
         hr_utility.set_location(l_proc,10);
         Select 'X'
         into v_dummy
         from   sys.dual
         where  exists (select 'Assignments Exist'
                        from   per_assignments_f paf
                        where  paf.supervisor_id         = p_person_id
                        and    paf.business_group_id + 0 = p_business_group_id
                        and    p_session_date <= paf.effective_end_date);
                        --
                        -- Bug 2492106. check this person is supervisor
                        -- on after the p_effective_date.
                        --
         p_status := 'WARNING';
         return;
      exception
        when no_data_found then
          return;
      end;
   elsif p_status = 'EVENT' then
      begin
         hr_utility.set_location(l_proc,30);
         select 'X'
         into v_dummy
         from   sys.dual
         where  exists ( select 'Events exist'
                         from   per_events pe
                         ,      per_bookings pb
                         where  pe.business_group_id = pb.business_group_id
                         and    (pb.business_group_id = p_business_group_id OR
                      nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
                         and    pe.event_id           = pb.event_id
                         and    pe.event_or_interview = 'E'
                         and    pb.person_id          = p_person_id
                         and    pe.date_start         > p_session_date
                        );
         p_status := 'WARNING';
         return;
      exception
        when no_data_found then
          return;
      end;
   end if;
   if p_status = 'INTERVIEW' then
      begin
         hr_utility.set_location(l_proc,40);
         select 'X'
         into v_dummy
         from   sys.dual
         where  exists(select 'Interview rows exist'
                       from   per_events pe
                       where  pe.business_group_id + 0      = p_business_group_id
                       and    pe.event_or_interview         = 'I'
                       and    pe.internal_contact_person_id = p_person_id
                       and    pe.date_start                 > p_session_date
                      )
                 OR
                exists(select 'Interview rows exist'
                       from    per_events pe
                               ,per_bookings pb
                       where  pe.business_group_id = pb.business_group_id
                       and    (pb.business_group_id  = p_business_group_id OR
                       nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
                       and    pe.event_id           = pb.event_id
                       and    pe.event_or_interview = 'I'
                       and    pb.person_id          = p_person_id
                       and    pe.date_start         > p_session_date
                      );
         p_status := 'WARNING';
         return;
      exception
        when no_data_found then
          return;
      end;
   end if;
   if p_status = 'REVIEW' then
      begin
         hr_utility.set_location(l_proc,50);
         select 'X'
         into v_dummy
         from   sys.dual
         where  exists ( select 'Perf Review rows exist'
                      from   per_performance_reviews ppr
                      where  ppr.person_id          = p_person_id
                        and  review_date > p_session_date
                    );
         p_status := 'WARNING';
         return;
      exception
        when no_data_found then
          return;
      end;
   end if;
   if p_status = 'RECRUITER' then
      begin
         hr_utility.set_location(l_proc,60);
         select 'X'
         into v_dummy
         from   sys.dual
         where  exists (select 'Recruiter for vacancy'
                        from  per_vacancies pv
                        where
                         -- Fix for Bug 3446782 starts here. this condition is taken
                         -- care in view definition.
                         /*(pv.business_group_id = p_business_group_id OR
                             nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
                            and */
                              pv.recruiter_id         = p_person_id
                        and   nvl(pv.date_to, p_session_date) >= p_session_date);
         p_status := 'WARNING';
         return;
      exception
        when no_data_found then
          return;
      end;
   end if;
end pre_term_check;
--
-- 120.2 (START)
--
-- ----------------------------------------------------------------------------
-- |-------------------< actual_termination_emp (Overload)>-------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_termination_emp
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_period_of_service_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in out nocopy date
  ,p_person_type_id               in     number   default hr_api.g_number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_leaving_reason               in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_warning              out nocopy boolean
  ,p_event_warning                   out nocopy boolean
  ,p_interview_warning               out nocopy boolean
  ,p_review_warning                  out nocopy boolean
  ,p_recruiter_warning               out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  ,p_dod_warning                     out nocopy boolean
  ) is

  l_last_std_process_date_in   date;
  l_last_std_process_date_out  date;
  l_alu_change_warning         varchar2(1) := 'N';

  l_proc   varchar2(100) := g_package||'.actual_termination_emp';

begin

  hr_utility.set_location('Entering '||l_proc,10);

  if p_last_standard_process_date is null
  then
    /* No LSPD has been passed. To preserve the previous
    ** behaviour we need to pass g_date to the latest ATE API.
    */
    l_last_std_process_date_in := hr_api.g_date;
  else
    /* Otherwise pass through the value provided.
    */
    l_last_std_process_date_in := p_last_standard_process_date;
  end if;

  actual_termination_emp(
             p_validate                       => p_validate
            ,p_effective_date                 => p_effective_date
            ,p_period_of_service_id           => p_period_of_service_id
            ,p_object_version_number          => p_object_version_number
            ,p_actual_termination_date        => p_actual_termination_date
            ,p_last_standard_process_date     => l_last_std_process_date_in
            ,p_person_type_id                 => p_person_type_id
            ,p_assignment_status_type_id      => p_assignment_status_type_id
            ,p_leaving_reason                 => p_leaving_reason
            ,p_last_std_process_date_out      => l_last_std_process_date_out
            ,p_supervisor_warning             => p_supervisor_warning
            ,p_event_warning                  => p_event_warning
            ,p_interview_warning              => p_interview_warning
            ,p_review_warning                 => p_review_warning
            ,p_recruiter_warning              => p_recruiter_warning
            ,p_asg_future_changes_warning     => p_asg_future_changes_warning
            ,p_entries_changed_warning        => p_entries_changed_warning
            ,p_pay_proposal_warning           => p_pay_proposal_warning
            ,p_dod_warning                    => p_dod_warning
            ,p_alu_change_warning             => l_alu_change_warning);

  p_last_standard_process_date := l_last_std_process_date_out;

  hr_utility.set_location('Leaving '||l_proc,40);

end actual_termination_emp;
--
-- 120.2 (END)
--
-- ----------------------------------------------------------------------------
-- |-------------------< actual_termination_emp (Overload)>-------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_termination_emp
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_period_of_service_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in out nocopy date
  ,p_person_type_id               in     number   default hr_api.g_number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_leaving_reason               in     varchar2 default hr_api.g_varchar2
--
-- 120.2 (START)
--
  ,p_atd_new                      in     number   default hr_api.g_true_num
  ,p_lspd_new                     in     number   default hr_api.g_true_num
--
-- 120.2 (END)
--
  ,p_supervisor_warning              out nocopy boolean
  ,p_event_warning                   out nocopy boolean
  ,p_interview_warning               out nocopy boolean
  ,p_review_warning                  out nocopy boolean
  ,p_recruiter_warning               out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  ,p_dod_warning                     out nocopy boolean
--
-- 120.2 (START)
--
  ,p_alu_change_warning              out nocopy varchar2
--
-- 120.2 (END)
--
  ) is

  l_last_std_process_date_in   date;
  l_last_std_process_date_out  date;

  l_proc   varchar2(100) := g_package||'.actual_termination_emp';

begin

  hr_utility.set_location('Entering '||l_proc,10);

  if p_last_standard_process_date is null
  then
    /* No LSPD has been passed. To preserve the previous
    ** behaviour we need to pass g_date to the latest ATE API.
    */
    l_last_std_process_date_in := hr_api.g_date;
  else
    /* Otherwise pass through the value provided.
    */
    l_last_std_process_date_in := p_last_standard_process_date;
  end if;

  actual_termination_emp(
             p_validate                       => p_validate
            ,p_effective_date                 => p_effective_date
            ,p_period_of_service_id           => p_period_of_service_id
            ,p_object_version_number          => p_object_version_number
            ,p_actual_termination_date        => p_actual_termination_date
            ,p_last_standard_process_date     => l_last_std_process_date_in
            ,p_person_type_id                 => p_person_type_id
            ,p_assignment_status_type_id      => p_assignment_status_type_id
            ,p_leaving_reason                 => p_leaving_reason
--
-- 120.2 (START)
--
            ,p_atd_new                        => p_atd_new
            ,p_lspd_new                       => p_lspd_new
--
-- 120.2 (END)
--

            ,p_last_std_process_date_out      => l_last_std_process_date_out
            ,p_supervisor_warning             => p_supervisor_warning
            ,p_event_warning                  => p_event_warning
            ,p_interview_warning              => p_interview_warning
            ,p_review_warning                 => p_review_warning
            ,p_recruiter_warning              => p_recruiter_warning
            ,p_asg_future_changes_warning     => p_asg_future_changes_warning
            ,p_entries_changed_warning        => p_entries_changed_warning
            ,p_pay_proposal_warning           => p_pay_proposal_warning
--
-- 120.2 (START)
--
            --,p_dod_warning                  => p_dod_warning);
            ,p_dod_warning                    => p_dod_warning
            ,p_alu_change_warning             => p_alu_change_warning);
--
-- 120.2 (END)
--

  p_last_standard_process_date := l_last_std_process_date_out;

  hr_utility.set_location('Leaving '||l_proc,40);

end actual_termination_emp;

--
-- 120.2 (START)
--
-- ----------------------------------------------------------------------------
-- |----------------< actual_termination_emp (overload) >---------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_termination_emp
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_period_of_service_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in     date     default hr_api.g_date
  ,p_person_type_id               in     number   default hr_api.g_number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_leaving_reason               in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
  ,p_pds_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_pds_information1             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information2             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information3             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information4             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information5             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information6             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information7             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information8             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information9             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information10            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information11            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information12            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information13            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information14            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information15            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information16            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information17            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information18            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information19            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information20            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information21            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information22            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information23            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information24            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information25            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information26            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information27            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information28            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information29            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information30            in     varchar2 default hr_api.g_varchar2
  ,p_last_std_process_date_out       out nocopy date
  ,p_supervisor_warning              out nocopy boolean
  ,p_event_warning                   out nocopy boolean
  ,p_interview_warning               out nocopy boolean
  ,p_review_warning                  out nocopy boolean
  ,p_recruiter_warning               out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  ,p_dod_warning                     out nocopy boolean
  ) is
--
l_alu_change_warning VARCHAR2(1);
--
begin
  --
  actual_termination_emp
    (p_validate                   => p_validate
    ,p_effective_date             => p_effective_date
    ,p_period_of_service_id       => p_period_of_service_id
    ,p_object_version_number      => p_object_version_number
    ,p_actual_termination_date    => p_actual_termination_date
    ,p_last_standard_process_date => p_last_standard_process_date
    ,p_person_type_id             => p_person_type_id
    ,p_assignment_status_type_id  => p_assignment_status_type_id
    ,p_leaving_reason             => p_leaving_reason
    ,p_attribute_category         => p_attribute_category
    ,p_attribute1                 => p_attribute1
    ,p_attribute2                 => p_attribute2
    ,p_attribute3                 => p_attribute3
    ,p_attribute4                 => p_attribute4
    ,p_attribute5                 => p_attribute5
    ,p_attribute6                 => p_attribute6
    ,p_attribute7                 => p_attribute7
    ,p_attribute8                 => p_attribute8
    ,p_attribute9                 => p_attribute9
    ,p_attribute10                => p_attribute10
    ,p_attribute11                => p_attribute11
    ,p_attribute12                => p_attribute12
    ,p_attribute13                => p_attribute13
    ,p_attribute14                => p_attribute14
    ,p_attribute15                => p_attribute15
    ,p_attribute16                => p_attribute16
    ,p_attribute17                => p_attribute17
    ,p_attribute18                => p_attribute18
    ,p_attribute19                => p_attribute19
    ,p_attribute20                => p_attribute20
    ,p_pds_information_category   => p_pds_information_category
    ,p_pds_information1           => p_pds_information1
    ,p_pds_information2           => p_pds_information2
    ,p_pds_information3           => p_pds_information3
    ,p_pds_information4           => p_pds_information4
    ,p_pds_information5           => p_pds_information5
    ,p_pds_information6           => p_pds_information6
    ,p_pds_information7           => p_pds_information7
    ,p_pds_information8           => p_pds_information8
    ,p_pds_information9           => p_pds_information9
    ,p_pds_information10          => p_pds_information10
    ,p_pds_information11          => p_pds_information11
    ,p_pds_information12          => p_pds_information12
    ,p_pds_information13          => p_pds_information13
    ,p_pds_information14          => p_pds_information14
    ,p_pds_information15          => p_pds_information15
    ,p_pds_information16          => p_pds_information16
    ,p_pds_information17          => p_pds_information17
    ,p_pds_information18          => p_pds_information18
    ,p_pds_information19          => p_pds_information19
    ,p_pds_information20          => p_pds_information20
    ,p_pds_information21          => p_pds_information21
    ,p_pds_information22          => p_pds_information22
    ,p_pds_information23          => p_pds_information23
    ,p_pds_information24          => p_pds_information24
    ,p_pds_information25          => p_pds_information25
    ,p_pds_information26          => p_pds_information26
    ,p_pds_information27          => p_pds_information27
    ,p_pds_information28          => p_pds_information28
    ,p_pds_information29          => p_pds_information29
    ,p_pds_information30          => p_pds_information30
    ,p_last_std_process_date_out  => p_last_std_process_date_out
    ,p_supervisor_warning         => p_supervisor_warning
    ,p_event_warning              => p_event_warning
    ,p_interview_warning          => p_interview_warning
    ,p_review_warning             => p_review_warning
    ,p_recruiter_warning          => p_recruiter_warning
    ,p_asg_future_changes_warning => p_asg_future_changes_warning
    ,p_entries_changed_warning    => p_entries_changed_warning
    ,p_pay_proposal_warning       => p_pay_proposal_warning
    ,p_dod_warning                => p_dod_warning
    ,p_alu_change_warning         => l_alu_change_warning
    );
  --
end actual_termination_emp;
--
-- 120.2 (END)
--

--
-- 70.2 change a start.
--
-- ----------------------------------------------------------------------------
-- |-----------------------< actual_termination_emp >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_termination_emp
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_period_of_service_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in     date     default hr_api.g_date
  ,p_person_type_id               in     number   default hr_api.g_number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_leaving_reason               in     varchar2 default hr_api.g_varchar2
--
-- 120.2 (START)
--
  ,p_atd_new                      in     number   default hr_api.g_true_num
  ,p_lspd_new                     in     number   default hr_api.g_true_num
--
-- 120.2 (END)
--
  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
  ,p_pds_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_pds_information1             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information2             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information3             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information4             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information5             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information6             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information7             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information8             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information9             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information10            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information11            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information12            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information13            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information14            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information15            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information16            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information17            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information18            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information19            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information20            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information21            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information22            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information23            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information24            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information25            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information26            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information27            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information28            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information29            in     varchar2 default hr_api.g_varchar2
  ,p_pds_information30            in     varchar2 default hr_api.g_varchar2
  ,p_last_std_process_date_out       out nocopy date
  ,p_supervisor_warning              out nocopy boolean
  ,p_event_warning                   out nocopy boolean
  ,p_interview_warning               out nocopy boolean
  ,p_review_warning                  out nocopy boolean
  ,p_recruiter_warning               out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  ,p_dod_warning                     out nocopy boolean
--
-- 120.2 (START)
--
  ,p_alu_change_warning              out nocopy varchar2
--
-- 120.2 (END)
--
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean     := FALSE;
  l_entries_changed_warning    varchar2(1) := 'N';
  l_event_warning              boolean     := FALSE;
  l_interview_warning          boolean     := FALSE;
  l_last_standard_process_date per_periods_of_service.last_standard_process_date%TYPE;
  l_last_std_process_date_in   per_periods_of_service.last_standard_process_date%TYPE;
  l_pds_object_version_number  per_assignments_f.object_version_number%TYPE;
  l_ovn per_assignments_f.object_version_number%TYPE := p_object_version_number;
  l_recruiter_warning          boolean     := FALSE;
  l_review_warning             boolean     := FALSE;
  l_supervisor_warning         boolean     := FALSE;
  l_dod_warning                boolean     := FALSE;
--
-- 120.2 (START)
--
  l_alu_change_warning         varchar2(1) := 'N';
--
-- 120.2 (END)
--
  --
  l_assignment_status_type_id  per_assignments_f.assignment_status_type_id%TYPE;
  l_business_group_id          per_assignments_f.business_group_id%TYPE;
  l_comment_id                 per_assignments_f.comment_id%TYPE;
  l_cr_asg_future_changes_warn boolean     := FALSE;
  l_cr_entries_changed_warn    varchar2(1) := 'N';
  l_pay_proposal_warn          boolean     := FALSE;
  l_current_applicant_flag     varchar2(1);
  l_current_emp_or_apl_flag    varchar2(1);
  l_current_employee_flag      varchar2(1);
  l_dob_null_warning           boolean;
  l_effective_date             date;
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_employee_number            per_all_people_f.employee_number%TYPE;
  l_applicant_number           per_people_f.applicant_number%TYPE;
  l_npw_number                 per_people_f.npw_number%TYPE;
  l_exists                     varchar2(1);
  l_full_name                  per_all_people_f.full_name%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_max_tpe_end_date           per_assignments_f.effective_end_date%TYPE;
  l_name_combination_warning   boolean;
  l_orig_hire_warning          boolean;
  l_per_object_version_number  per_assignments_f.object_version_number%TYPE;
  l_per_system_status          per_assignment_status_types.per_system_status%TYPE;
  l_person_id                  per_all_people_f.person_id%TYPE;
  l_person_type_id             per_all_people_f.person_type_id%TYPE;
  l_person_type_id1            per_all_people_f.person_type_id%TYPE;
  l_proc                       varchar2(72)
                                       := g_package || 'actual_termination_emp';
  l_system_person_type         per_person_types.system_person_type%TYPE;
  l_system_person_type1        per_person_types.system_person_type%TYPE;
  l_per_effective_start_date   per_people_f.effective_start_date%TYPE;
  l_datetrack_mode             varchar2(30);
  l_validation_start_date      date;
  l_validation_end_date        date;
  l_actual_termination_date    date;
  l_status                     varchar2(11);
  l_current_dod                date;
  l_date_of_death              date;
  l_ptu_object_version_number  per_person_type_usages_f.object_version_number%TYPE;
  l_person_type_usage_id       per_person_type_usages_f.person_type_usage_id%TYPE;
  l_action_chk                 VARCHAR2(1) := 'N';

  l_saved_atd   per_periods_of_service.actual_termination_date%TYPE;
  l_saved_lspd  per_periods_of_service.last_standard_process_date%TYPE;
  l_person_id2 number := -1;
  --

  cursor csr_future_per_changes is
    select null
      from per_all_people_f per
     where per.person_id            = l_person_id
       and per.effective_start_date > l_actual_termination_date;
  --
  cursor csr_get_asgs_to_terminate is
    select asg.assignment_id
         , asg.object_version_number
      from per_assignments_f asg
     where asg.period_of_service_id      = p_period_of_service_id
       and l_actual_termination_date + 1 between asg.effective_start_date
                                         and     asg.effective_end_date
     order by asg.primary_flag;
  --
  cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
         , per.person_id
         , per.employee_number
         , per.effective_start_date
         , per.object_version_number
         , pet.system_person_type
         , per.npw_number
         , pds.actual_termination_date
         , pds.last_standard_process_date
      from per_all_people_f       per
         , per_business_groups    bus
         , per_periods_of_service pds
         , per_person_types       pet
     where pds.period_of_service_id  = p_period_of_service_id
     and   bus.business_group_id     = pds.business_group_id
     and   per.person_id             = pds.person_id
     and   l_actual_termination_date between per.effective_start_date
                                     and     per.effective_end_date
     and   pet.person_type_id        = per.person_type_id;
  --
  cursor csr_get_max_tpe_end_date is
    select max(tpe.end_date)
    from   per_time_periods  tpe
          ,per_assignments_f asg
    where  asg.period_of_service_id  = p_period_of_service_id
    and    l_actual_termination_date between asg.effective_start_date
                                     and     asg.effective_end_date
    and    asg.payroll_id            is not null
    and    tpe.payroll_id            = asg.payroll_id
    and    l_actual_termination_date between tpe.start_date
                                     and     tpe.end_date;
  --
  --
  cursor csr_date_of_death is
    select date_of_death
    from per_all_people_f
    where person_id = l_person_id;
  --
  -- Fix for bug 3829474 starts here.
  --
  l_pds_rec per_periods_of_service%rowtype;
  --
  cursor l_pds_cur is
  select *
  from per_periods_of_service
  where period_of_service_id = p_period_of_service_id;
  --
  -- Fix for bug 3829474 ends here.
  --
  --
  -- Fix for 4371218 starts here
  --
   -- new contract cursor start
 /* cursor l_ctc_cur is
  select contract_id
        ,reference
        ,type
        ,object_version_number
  from per_contracts_f
  where person_id = l_person_id;*/

-- 2 cursors for GOLD bug 5465050

cursor chk_pre_term_src_gold(p_src_bg_id number,p_gold_src_person_id number) is
select * from hr_person_deployments where
FROM_BUSINESS_GROUP_ID = p_src_bg_id and
FROM_PERSON_ID = p_gold_src_person_id;

cursor chk_pre_term_dest_gold(p_dest_bg_id number,p_gold_dest_person_id number) is
select * from hr_person_deployments where
TO_BUSINESS_GROUP_ID = p_dest_bg_id and
TO_PERSON_ID = p_gold_dest_person_id;

  --
  -- new contract cursor end
 /* l_contract_id        number;
  l_ctc_ovn            per_contracts_f.object_version_number%TYPE;
  l_ctc_status         varchar2(30);*/

-- 2 parameters for GOLD bug 5465050

  l_src_bg_rec hr_person_deployments%ROWTYPE;
  l_dest_bg_rec hr_person_deployments%ROWTYPE;
  --
   --
--dparthas
CURSOR get_person_info IS
select person_id from per_periods_of_service
where PERIOD_OF_SERVICE_ID = p_period_of_service_id;
--dparthas
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --dparthas
   OPEN get_person_info;
   FETCH get_person_info INTO l_person_id2;
   CLOSE get_person_info;
   --dparthas
  --
  -- Issue a savepoint.
  --
  savepoint actual_termination_emp;
  --
  -- Initialise local varaibles
  --
  l_assignment_status_type_id  := p_assignment_status_type_id;
  l_last_standard_process_date := trunc(p_last_standard_process_date);
  l_last_std_process_date_in   := l_last_standard_process_date;
  l_pds_object_version_number  := p_object_version_number;
  l_person_type_id             := p_person_type_id;
  l_actual_termination_date    := trunc(p_actual_termination_date);
  l_effective_date             := trunc(p_effective_date);
  l_applicant_number           := hr_api.g_varchar2;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Table Handlers
  --
  -- Check period of service and get business group details for validation.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'period_of_service_id'
     ,p_argument_value => p_period_of_service_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'actual_termination_date'
     ,p_argument_value => l_actual_termination_date
     );
  --
  -- Bug number 4900409 - validating actual termination date cannot be future date
  -- if leaving reason is 'D' Deceased

  hr_utility.set_location(' Check Actual termination date for Deceased Leaving Reason ' , 25);
  hr_utility.set_location( ' p_leaving_reason ' ||p_leaving_reason , 25);
  hr_utility.set_location( ' p_actual_termination_date' ||p_leaving_reason , 25);

  IF p_leaving_reason = 'D' THEN
    IF p_actual_termination_date > SYSDATE THEN

      fnd_message.set_name('PER','PER_449766_NO_FUT_ACTUAL_TERM');
      fnd_message.raise_error;

    END IF;
  END IF;

  hr_utility.set_location(l_proc, 30);
  --
  open  csr_get_derived_details;
  fetch csr_get_derived_details
   into l_business_group_id
      , l_legislation_code
      , l_person_id
      , l_employee_number
      , l_per_effective_start_date
      , l_per_object_version_number
      , l_system_person_type
      , l_npw_number
      , l_saved_atd
      , l_saved_lspd;
  --
  if csr_get_derived_details%NOTFOUND
  then
    --
    hr_utility.set_location(l_proc, 40);
    --
    close csr_get_derived_details;
    --
    hr_utility.set_message(801,'HR_6537_EMP_DATE_START'); --Bug 3929991.
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;

-- 5465050 Start

 -- chk in src bg for termination
for l_src_bg_rec in chk_pre_term_src_gold(l_business_group_id,l_person_id) LOOP
 if (l_src_bg_rec.PERMANENT = 'N'
 and l_src_bg_rec.status = 'ACTIVE')
  -- Commented for bug 5607315
/* and (p_actual_termination_date between l_src_bg_rec.START_DATE
      and nvl(l_src_bg_rec.END_DATE,hr_api.g_eot))) */
 then

 hr_utility.set_message(800, 'HR_449770_GLD_SRC_BG');
 hr_utility.raise_error;

 end if;
end LOOP;

-- for dest bg check

for l_dest_bg_rec in chk_pre_term_dest_gold(l_business_group_id,l_person_id) LOOP
 if (l_dest_bg_rec.PERMANENT = 'N'
 and l_dest_bg_rec.status = 'ACTIVE')
 -- Commented for bug 5607315
/* and (p_actual_termination_date between l_dest_bg_rec.START_DATE
      and nvl(l_dest_bg_rec.END_DATE,hr_api.g_eot))) */
 then

 hr_utility.set_message(800, 'HR_449771_GLD_DEST_BG');
 hr_utility.raise_error;

 end if;
end LOOP;

-- 5465050 End


--
-- 120.2 (START)
--
  if p_atd_new = 1 then
    l_saved_atd := null;
  end if;
  if p_lspd_new = 1 then
    l_saved_lspd := null;
  end if;
--
-- 120.2 (END)
--
  --
  -- Start of API User Hook for the before hook of actual_termination
  --
  begin
     hr_ex_employee_bk1.actual_termination_emp_b
       (p_effective_date                => l_effective_date
       ,p_period_of_service_id          => p_period_of_service_id
       ,p_object_version_number         => p_object_version_number
       ,p_actual_termination_date       => l_actual_termination_date
       ,p_last_standard_process_date    => l_last_standard_process_date
       ,p_person_type_id                => p_person_type_id
       ,p_assignment_status_type_id     => p_assignment_status_type_id
       ,p_business_group_id             => l_business_group_id
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
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACTUAL_TERMINATION_EMP',
          p_hook_type         => 'BP'
         );
  end;
  --
  -- End of API User Hook for the before hook of actual_termination
  --
  hr_utility.set_location(l_proc, 50);
  hr_utility.set_location('Saved ATD: '||l_saved_atd, 51);
  hr_utility.set_location('Saved LSPD: '||l_saved_lspd, 51);
  hr_utility.set_location('Passed LSPD: '||l_last_standard_process_date, 51);
  --
  -- Determine if we are setting LSPD as a separate call to the API. i.e. ATD
  -- has already been saved with a null LSPD,
  --
  if l_saved_atd is not null and
     l_saved_lspd is null    and
     l_last_standard_process_date is not null then
     --
     -- We are processing a save to LSPD as a separate call to this API.
     --
     if p_last_standard_process_date = hr_api.g_date
     then
       hr_utility.set_location(l_proc, 60);
       --
       -- Last standard process date is the default value i.e.
       -- it was not passed to the API => derive it.
       --
       -- Find the max tpe end date of any payrolls that are assigned.
       --
       open  csr_get_max_tpe_end_date;
       fetch csr_get_max_tpe_end_date
            into l_max_tpe_end_date;
       --
       if csr_get_max_tpe_end_date%NOTFOUND
       then
         --
         hr_utility.set_location(l_proc, 70);
         --
         close csr_get_max_tpe_end_date;
         --
         -- As the cursor should always return at least a null value, this
         -- should never happen!
         --
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE', l_proc);
         hr_utility.set_message_token('STEP','175');
         hr_utility.raise_error;
       end if;
       --
       close csr_get_max_tpe_end_date;
       --
       hr_utility.set_location(l_proc, 80);
       --
       if l_max_tpe_end_date is not null
       then
         --
         hr_utility.set_location(l_proc, 90);
         --
         -- A time period end date has been found, so set the last standard
         -- process date to that.
         --
         l_last_standard_process_date := l_max_tpe_end_date;
       else
         --
         hr_utility.set_location(l_proc, 100);
         --
         -- Either there was not an assignment assigned to a payroll, or
         -- there was no time period for that payroll as of the actual
         -- termination date. It doesn't matter which as we will default
         -- the LSPD to the ATD.
         --
         l_last_standard_process_date := l_actual_termination_date;
       end if;

     end if;
     --
     -- Save PDS update
     --
     per_pds_upd.upd
         (p_period_of_service_id       => p_period_of_service_id
         ,p_last_standard_process_date => l_last_standard_process_date
         ,p_object_version_number      => l_pds_object_version_number
         ,p_effective_date             => l_last_standard_process_date + 1
         ,p_validate                   => p_validate
         ,p_attribute_category         => p_attribute_category
         ,p_attribute1                 => p_attribute1
         ,p_attribute2                 => p_attribute2
         ,p_attribute3                 => p_attribute3
         ,p_attribute4                 => p_attribute4
         ,p_attribute5                 => p_attribute5
         ,p_attribute6                 => p_attribute6
         ,p_attribute7                 => p_attribute7
         ,p_attribute8                 => p_attribute8
         ,p_attribute9                 => p_attribute9
         ,p_attribute10                => p_attribute10
         ,p_attribute11                => p_attribute11
         ,p_attribute12                => p_attribute12
         ,p_attribute13                => p_attribute13
         ,p_attribute14                => p_attribute14
         ,p_attribute15                => p_attribute15
         ,p_attribute16                => p_attribute16
         ,p_attribute17                => p_attribute17
         ,p_attribute18                => p_attribute18
         ,p_attribute19                => p_attribute19
         ,p_attribute20                => p_attribute20
         ,p_pds_information_category   => p_pds_information_category
         ,p_pds_information1           => p_pds_information1
         ,p_pds_information2           => p_pds_information2
         ,p_pds_information3           => p_pds_information3
         ,p_pds_information4           => p_pds_information4
         ,p_pds_information5           => p_pds_information5
         ,p_pds_information6           => p_pds_information6
         ,p_pds_information7           => p_pds_information7
         ,p_pds_information8           => p_pds_information8
         ,p_pds_information9           => p_pds_information9
         ,p_pds_information10          => p_pds_information10
         ,p_pds_information11          => p_pds_information11
         ,p_pds_information12          => p_pds_information12
         ,p_pds_information13          => p_pds_information13
         ,p_pds_information14          => p_pds_information14
         ,p_pds_information15          => p_pds_information15
         ,p_pds_information16          => p_pds_information16
         ,p_pds_information17          => p_pds_information17
         ,p_pds_information18          => p_pds_information18
         ,p_pds_information19          => p_pds_information19
         ,p_pds_information20          => p_pds_information20
         ,p_pds_information21          => p_pds_information21
         ,p_pds_information22          => p_pds_information22
         ,p_pds_information23          => p_pds_information23
         ,p_pds_information24          => p_pds_information24
         ,p_pds_information25          => p_pds_information25
         ,p_pds_information26          => p_pds_information26
         ,p_pds_information27          => p_pds_information27
         ,p_pds_information28          => p_pds_information28
         ,p_pds_information29          => p_pds_information29
         ,p_pds_information30          => p_pds_information30
         );
     --
     -- Maintain EEs for each assignment.
     --
     for csr_rec in csr_get_asgs_to_terminate
     loop

       hrempter.terminate_entries_and_alus
           (p_assignment_id      => csr_rec.assignment_id
           ,p_actual_term_date   => l_saved_atd
           ,p_last_standard_date => l_last_standard_process_date
           ,p_final_process_date => null
           ,p_legislation_code   => l_legislation_code
           ,p_entries_changed_warning => l_cr_entries_changed_warn
--
-- 120.2 (START)
--
           ,p_alu_change_warning => l_alu_change_warning
--
-- 120.2 (END)
--
           );
       --
       -- Set entries changed warning using the precedence of 'S', then 'Y', then
       -- 'N'.
       --
       if l_cr_entries_changed_warn = 'S' or
          l_entries_changed_warning = 'S' then
         --
         hr_utility.set_location(l_proc, 110);
         --
         l_entries_changed_warning := 'S';
         --
       elsif l_cr_entries_changed_warn = 'Y' or
             l_entries_changed_warning = 'Y' then
         --
         hr_utility.set_location(l_proc, 120);
         --
         l_entries_changed_warning := 'Y';

       else
         --
         hr_utility.set_location(l_proc, 130);
         --
         l_entries_changed_warning := 'N';

       end if;

     end loop;

  else

    -- The saved ATD is null therefore this is the first call to this
    -- API for termination so process a full termination.
    --
    -- Check that the corresponding person is of 'employee' system person type.
    --
    if l_system_person_type <> 'EMP' and
       l_system_person_type <> 'EMP_APL'
    then
      --
      hr_utility.set_location(l_proc, 140);
      --
      hr_utility.set_message(801,'HR_51005_ASG_INV_PER_TYPE');
      hr_utility.raise_error;
    end if;
    --
    -- PTU changes: must maintain default of correct "ex-emp" type on
    -- per_all_people_f
    --
    if l_system_person_type = 'EMP' then
       l_system_person_type1 := 'EX_EMP';
    elsif l_system_person_type = 'EMP_APL' then
       l_system_person_type1 := 'EX_EMP_APL';
    end if;
    --
    l_person_type_id1  := hr_person_type_usage_info.get_default_person_type_id
                                          (l_business_group_id,
                                           l_system_person_type1);
    --
    -- PTU : End of Changes
    --
    hr_utility.set_location(l_proc, 150);
    --
    -- Check that there are not any future changes to the person.
    --
    open  csr_future_per_changes;
    fetch csr_future_per_changes
     into l_exists;
    --
    if csr_future_per_changes%FOUND
    then
      --
      hr_utility.set_location(l_proc, 160);
      --
      close csr_future_per_changes;
      --
      hr_utility.set_message(801,'HR_7957_PDS_INV_ATT_FUTURE');
      hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc, 170);
    --
    close csr_future_per_changes;
    --
    -- Process Logic
    --
    -- PTU changes: person_type_id must be of 'EX_EMP' so validate or derive the default
    --
    per_per_bus.chk_person_type
        (p_person_type_id    => l_person_type_id
        ,p_business_group_id => l_business_group_id
        ,p_expected_sys_type => 'EX_EMP'
        );
    --
    hr_utility.set_location(l_proc, 180);
    --
    -- If p_assignment_status_type_id is g_number then derive it's default value,
    -- otherwise validate it.
    --
    hr_utility.set_location(l_proc||' asg stat type : '||l_assignment_status_type_id||' per bg id '||l_business_group_id||' leg code '||l_legislation_code,900);
    --
    per_asg_bus1.chk_assignment_status_type
      (p_assignment_status_type_id => l_assignment_status_type_id
      ,p_business_group_id         => l_business_group_id
      ,p_legislation_code          => l_legislation_code
      ,p_expected_system_status    => 'TERM_ASSIGN'
      );
    --
    hr_utility.set_location(l_proc, 190);
    --
    -- Validate/derive the last standard process date.
    --
    --
    hr_utility.set_location(l_proc, 200);
    --
    -- At the end of the following code we will either have a valid date
    -- for l_last_standard_process_date or it will be NULL. It can only be
    -- NULL if explicitly passed as such to the API.
    --
    if l_last_standard_process_date is not null and
       l_last_standard_process_date <> hr_api.g_date
    then
        --
        hr_utility.set_location(l_proc, 210);
        --
        -- Check that the last standard process date is on or after the actual
        -- termination date.
        --
        if not l_last_standard_process_date >= l_actual_termination_date
        then
          --
          hr_utility.set_location(l_proc, 220);
          --
          hr_utility.set_message(801,'HR_7505_PDS_INV_LSP_ATT_DT');
          hr_utility.raise_error;
        end if;
    elsif l_last_standard_process_date = hr_api.g_date then
        --
        hr_utility.set_location(l_proc, 230);
        --
        -- Last standard process date is the default value i.e.
        -- it was not passed to the API => derive it.
        --
        -- Find the max tpe end date of any payrolls that are assigned.
        --
        open  csr_get_max_tpe_end_date;
        fetch csr_get_max_tpe_end_date
         into l_max_tpe_end_date;
        --
        if csr_get_max_tpe_end_date%NOTFOUND
        then
          --
          hr_utility.set_location(l_proc, 240);
          --
          close csr_get_max_tpe_end_date;
          --
          -- As the cursor should always return at least a null value, this
          -- should never happen!
          --
          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE', l_proc);
          hr_utility.set_message_token('STEP','175');
          hr_utility.raise_error;
        end if;
        --
        close csr_get_max_tpe_end_date;
        --
        hr_utility.set_location(l_proc, 250);
        --
        if l_max_tpe_end_date is not null
        then
          --
          hr_utility.set_location(l_proc, 260);
          --
          -- A time period end date has been found, so set the last standard
          -- process date to that.
          --
          l_last_standard_process_date := l_max_tpe_end_date;
        else
          --
          hr_utility.set_location(l_proc, 270);
          --
          -- Either there was not an assignment assigned to a payroll, or
          -- there was no time period for that payroll as of the actual
          -- termination date. It doesn't matter which as we will default
          -- the LSPD to the ATD.
          --
          l_last_standard_process_date := l_actual_termination_date;
        end if;
    end if;
    --
    --2478758 implement check for payroll actions
    --
    l_action_chk := hr_ex_employee_api.check_for_compl_actions
                        (p_person_id => l_person_id
                        ,p_act_date  => l_actual_termination_date
                        ,p_lsp_date  => l_last_standard_process_date
                        ,p_fpr_date  => null           --not known to this API
                         );
--
-- Bug# 2958006 Start Here
-- Description :  Added warning message for terminating an employee
-- with future payroll actions exists before final processing date
-- Bug# 3086210 Modified the Warning message.
--
    --
    IF l_action_chk = 'W' THEN
      hr_utility.set_message(800,'PER_449053_EMP_TERM_FUT_ERROR'); -- Modified from PER_289973 TO PER_449053
      hr_utility.set_warning;
    END IF;
    --
--
--Bug# 2958006 End Here
--
    if l_action_chk = 'Y' then
       hr_utility.set_message(801,'HR_6516_EMP_TERM_ACTIONS_EXIST');
       hr_utility.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc, 280);
    --
    -- Lock the person record in PER_PEOPLE_F ready for UPDATE at a later point.
    -- (Note: This is necessary because calling the table handlers in locking
    --        ladder order invokes an error in per_pds_upd.upd due to the person
    --        being modified by the per_per_upd.upd table handler.)
    --
    l_datetrack_mode     := 'UPDATE';
    --
    per_per_shd.lck
      (p_effective_date                 => l_actual_termination_date + 1
      ,p_datetrack_mode                 => l_datetrack_mode
      ,p_person_id                      => l_person_id
      ,p_object_version_number          => l_per_object_version_number
      ,p_validation_start_date          => l_validation_start_date
      ,p_validation_end_date            => l_validation_end_date
      );

    hr_utility.set_location(l_proc, 290);
    --
    -- Update actual termination date and last standard process date in
    -- periods of service table.

    per_pds_upd.upd
      (p_period_of_service_id       => p_period_of_service_id
      ,p_actual_termination_date    => l_actual_termination_date
      ,p_last_standard_process_date => l_last_standard_process_date
      ,p_leaving_reason             => p_leaving_reason
      ,p_object_version_number      => l_pds_object_version_number
      ,p_effective_date             => p_actual_termination_date + 1
      ,p_attribute_category         => p_attribute_category
      ,p_attribute1                 => p_attribute1
      ,p_attribute2                 => p_attribute2
      ,p_attribute3                 => p_attribute3
      ,p_attribute4                 => p_attribute4
      ,p_attribute5                 => p_attribute5
      ,p_attribute6                 => p_attribute6
      ,p_attribute7                 => p_attribute7
      ,p_attribute8                 => p_attribute8
      ,p_attribute9                 => p_attribute9
      ,p_attribute10                => p_attribute10
      ,p_attribute11                => p_attribute11
      ,p_attribute12                => p_attribute12
      ,p_attribute13                => p_attribute13
      ,p_attribute14                => p_attribute14
      ,p_attribute15                => p_attribute15
      ,p_attribute16                => p_attribute16
      ,p_attribute17                => p_attribute17
      ,p_attribute18                => p_attribute18
      ,p_attribute19                => p_attribute19
      ,p_attribute20                => p_attribute20
      ,p_pds_information_category   => p_pds_information_category
      ,p_pds_information1           => p_pds_information1
      ,p_pds_information2           => p_pds_information2
      ,p_pds_information3           => p_pds_information3
      ,p_pds_information4           => p_pds_information4
      ,p_pds_information5           => p_pds_information5
      ,p_pds_information6           => p_pds_information6
      ,p_pds_information7           => p_pds_information7
      ,p_pds_information8           => p_pds_information8
      ,p_pds_information9           => p_pds_information9
      ,p_pds_information10          => p_pds_information10
      ,p_pds_information11          => p_pds_information11
      ,p_pds_information12          => p_pds_information12
      ,p_pds_information13          => p_pds_information13
      ,p_pds_information14          => p_pds_information14
      ,p_pds_information15          => p_pds_information15
      ,p_pds_information16          => p_pds_information16
      ,p_pds_information17          => p_pds_information17
      ,p_pds_information18          => p_pds_information18
      ,p_pds_information19          => p_pds_information19
      ,p_pds_information20          => p_pds_information20
      ,p_pds_information21          => p_pds_information21
      ,p_pds_information22          => p_pds_information22
      ,p_pds_information23          => p_pds_information23
      ,p_pds_information24          => p_pds_information24
      ,p_pds_information25          => p_pds_information25
      ,p_pds_information26          => p_pds_information26
      ,p_pds_information27          => p_pds_information27
      ,p_pds_information28          => p_pds_information28
      ,p_pds_information29          => p_pds_information29
      ,p_pds_information30          => p_pds_information30
      ,p_validate                   => p_validate
      );
    --
    if p_leaving_reason = 'D' then
      open csr_date_of_death;
      fetch csr_date_of_death into l_current_dod;
      if l_current_dod is null then
        l_date_of_death := p_actual_termination_date;
        l_dod_warning := TRUE;
      else
        l_date_of_death := l_current_dod;
      end if;
      close csr_date_of_death;
    end if;
    --
    if l_dod_warning = TRUE then
      hr_utility.set_location(l_proc, 300);
    else
      hr_utility.set_location(l_proc,310);
    end if;
    --
    -- Update person type in person table.
    --
    hr_utility.set_location(l_proc, 320);
    per_per_upd.upd
      (p_person_id                => l_person_id
      ,p_effective_start_date     => l_effective_start_date
      ,p_effective_end_date       => l_effective_end_date
      ,p_person_type_id           => l_person_type_id1
      ,p_comment_id               => l_comment_id
      ,p_current_applicant_flag   => l_current_applicant_flag
      ,p_current_emp_or_apl_flag  => l_current_emp_or_apl_flag
      ,p_current_employee_flag    => l_current_employee_flag
      ,p_employee_number          => l_employee_number
      ,p_applicant_number         => l_applicant_number
      ,p_full_name                => l_full_name
      ,p_object_version_number    => l_per_object_version_number
      ,p_effective_date           => l_actual_termination_date + 1
      ,p_datetrack_mode           => 'UPDATE'
      ,p_date_of_death            => l_date_of_death
      ,p_validate                 => p_validate
      ,p_name_combination_warning => l_name_combination_warning
      ,p_dob_null_warning         => l_dob_null_warning
      ,p_orig_hire_warning        => l_orig_hire_warning
      ,p_npw_number               => l_npw_number
      );
    --
    hr_utility.set_location(l_proc, 330);
  --
  -- Fix for 4371218 starts here (Terminate contracts)
  --
/*  for ctc_rec in l_ctc_cur
      loop
        l_ctc_ovn := ctc_rec.object_version_number;
    --
      select hrl.lookup_code into l_ctc_status
        from hr_lookups hrl
       where hrl.lookup_type = 'CONTRACT_STATUS'
        and hrl.lookup_code = 'T-TERMINATION'
        and hrl.application_id = 800 AND hrl.enabled_flag = 'Y';
    --
    per_ctc_upd.upd
      (p_contract_id              => ctc_rec.contract_id
      ,p_reference                => ctc_rec.reference
      ,p_type                     => ctc_rec.type
      ,p_status                   => l_ctc_status --ctc_rec.status
      ,p_effective_start_date     => l_effective_start_date
      ,p_effective_end_date       => l_effective_end_date
      ,p_effective_date           => l_actual_termination_date + 1
      ,p_object_version_number    => l_ctc_ovn
      ,p_datetrack_mode           => 'UPDATE'
      );
      end loop;*/
    hr_utility.set_location(l_proc, 335);
    --
    -- end of contracts termination
    --
  --
  -- Fix for 4371218 ens here (Terminate contracts)
  --
    -- Terminate the assignments, ensuring that the non-primaries are
    -- processed before the primary (implemented via 'order by primary_flag'
    -- clause in cursor declaration).
    --
    for csr_rec in csr_get_asgs_to_terminate
    loop
      --
      hr_utility.set_location(l_proc, 340);
      --
      hr_assignment_internal.actual_term_emp_asg_sup
        (p_assignment_id              => csr_rec.assignment_id
        ,p_object_version_number      => csr_rec.object_version_number
        ,p_actual_termination_date    => l_actual_termination_date
        ,p_last_standard_process_date => l_last_standard_process_date
        ,p_assignment_status_type_id  => l_assignment_status_type_id
        ,p_effective_start_date       => l_effective_start_date
        ,p_effective_end_date         => l_effective_end_date
        ,p_asg_future_changes_warning => l_cr_asg_future_changes_warn
        ,p_entries_changed_warning    => l_cr_entries_changed_warn
        ,p_pay_proposal_warning       => l_pay_proposal_warn
--
-- 120.2 (START)
--
        ,p_alu_change_warning         => l_alu_change_warning
--
-- 120.2 (END)
--
        );
      --
      hr_utility.set_location(l_proc, 350);
      --
      -- Set entries changed warning using the precedence of 'S', then 'Y', then
      -- 'N'.
      --
      if l_cr_entries_changed_warn = 'S' or
         l_entries_changed_warning = 'S' then
        --
        hr_utility.set_location(l_proc, 360);
        --
         l_entries_changed_warning := 'S';
        --
      elsif l_cr_entries_changed_warn = 'Y' or
          l_entries_changed_warning = 'Y' then
        --
        hr_utility.set_location(l_proc, 370);
        --
        l_entries_changed_warning := 'Y';

      else
        --
        hr_utility.set_location(l_proc, 380);
        --
        l_entries_changed_warning := 'N';

      end if;
      --
      hr_utility.set_location(l_proc, 390);
      --
      -- Set future changes warning.
      --
      if l_cr_asg_future_changes_warn or l_asg_future_changes_warning
      then
        --
        hr_utility.set_location(l_proc, 400);
        --
        l_asg_future_changes_warning := TRUE;

      end if;

    end loop;
    --
    hr_utility.set_location(l_proc, 410);
    --
    -- Added code to support the following Out warning parameters.
    --
    l_status := 'SUPERVISOR';
    pre_term_check(l_status,
                   l_business_group_id,
                   l_person_id,
                   l_actual_termination_date);
    if l_status = 'WARNING' then
      p_supervisor_warning := TRUE;
    else
      p_supervisor_warning := FALSE;
    end if;
    --
    l_status := 'EVENT';
    pre_term_check(l_status,
                   l_business_group_id,
                   l_person_id,
                   l_actual_termination_date);
    if l_status = 'WARNING' then
      p_event_warning := TRUE;
    else
      p_event_warning := FALSE;
    end if;
    --
    l_status := 'INTERVIEW';
    pre_term_check(l_status,
                   l_business_group_id,
                   l_person_id,
                   l_actual_termination_date);
    if l_status = 'WARNING' then
      p_interview_warning := TRUE;
    else
      p_interview_warning := FALSE;
    end if;
    --
    l_status := 'REVIEW';
    pre_term_check(l_status,
                   l_business_group_id,
                   l_person_id,
                   l_actual_termination_date);
    if l_status = 'WARNING' then
      p_review_warning := TRUE;
    else
      p_review_warning := FALSE;
    end if;
    --
    l_status := 'RECRUITER';
    pre_term_check(l_status,
                   l_business_group_id,
                   l_person_id,
                   l_actual_termination_date);
    if l_status = 'WARNING' then
      p_recruiter_warning := TRUE;
    else
      p_recruiter_warning := FALSE;
    end if;
    --
    --
    -- Now maintain any PTU records if they exists. We are terminating
    -- possibly with a leaving_reason of 'R' so pass required information
    -- to maintain_ptu procedure
    --

    -- PTU : Following Code has been added (l_person_type_id holds validated flavour of EX_EMP)

    hr_per_type_usage_internal.maintain_person_type_usage
         (p_effective_date        =>  p_actual_termination_date +1
         ,p_person_id             => l_person_id
         ,p_person_type_id        => l_person_type_id
         ,p_datetrack_update_mode => 'UPDATE'
         );
    --
    if p_leaving_reason = 'R'
         then

         hr_utility.set_location('actual_termination_emp',420);

             hr_per_type_usage_internal.create_person_type_usage
                (p_person_id            => l_person_id
                ,p_person_type_id       =>
                hr_person_type_usage_info.get_default_person_type_id
                       (p_business_group_id    => l_business_group_id
                       ,p_system_person_type   => 'RETIREE')
                ,p_effective_date       => p_actual_termination_date+1
                ,p_person_type_usage_id => l_person_type_usage_id
                ,p_object_version_number=> l_ptu_object_version_number
                ,p_effective_start_date => l_effective_start_date
                ,p_effective_end_date   => l_effective_end_date);

         hr_utility.set_location('actual_termination_emp',430);

    end if;

  end if;
  --
  -- Fix for bug 3829474 starts here.
  --
  hr_utility.set_location('actual_termination_emp',435);
  --

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
  hr_utility.set_location('actual_termination_emp',440);
  --
  -- Fix for bug 3829474 ends here.
  --
  -- Start of API User Hook for the after hook of actual_termination
  -- Local vars are passed in for all OUT parms because the hook needs to
  -- be placed before the validate check and therefore before the code that
  -- sets all out parms.
  --
  begin
    hr_ex_employee_bk1.actual_termination_emp_a
      (p_effective_date                => l_effective_date
      ,p_period_of_service_id          => p_period_of_service_id
      ,p_object_version_number         => l_pds_object_version_number
      ,p_actual_termination_date       => l_actual_termination_date
      ,p_last_standard_process_date    => l_last_std_process_date_in
      ,p_person_type_id                => p_person_type_id
      ,p_assignment_status_type_id     => p_assignment_status_type_id
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
      ,p_last_std_process_date_out     => l_last_standard_process_date
      ,p_supervisor_warning            => l_supervisor_warning
      ,p_event_warning                 => l_event_warning
      ,p_interview_warning             => l_interview_warning
      ,p_review_warning                => l_review_warning
      ,p_recruiter_warning             => l_recruiter_warning
      ,p_asg_future_changes_warning    => l_asg_future_changes_warning
      ,p_entries_changed_warning       => l_entries_changed_warning
      ,p_pay_proposal_warning          => l_pay_proposal_warn
      ,p_dod_warning                   => l_dod_warning
      ,p_business_group_id             => l_business_group_id
      ,p_person_id                     => l_person_id2
      );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'ACTUAL_TERMINATION_EMP',
          p_hook_type         => 'AP'
         );
    --
    -- End of API User Hook for the after hook of actual_termination
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_asg_future_changes_warning     := l_asg_future_changes_warning;
  p_entries_changed_warning        := l_entries_changed_warning;
  p_pay_proposal_warning           := l_pay_proposal_warn;
  p_dod_warning                    := l_dod_warning;
--
-- 120.2 (START)
--
  p_alu_change_warning             := l_alu_change_warning;
--
-- 120.2 (END)
--
  p_last_std_process_date_out      := l_last_standard_process_date;
  p_object_version_number          := l_pds_object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 440);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO actual_termination_emp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_asg_future_changes_warning := l_asg_future_changes_warning;
    p_entries_changed_warning    := l_entries_changed_warning;
    p_pay_proposal_warning       := l_pay_proposal_warn;
    p_dod_warning                := l_dod_warning;
    --
    -- p_object_version_number and p_last_standard_process_date
    -- should return their IN values, they still hold their IN values
    -- so do nothing here.
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO actual_termination_emp;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number    := l_ovn;
    p_last_std_process_date_out       := null;
  p_supervisor_warning              := false;
  p_event_warning                   := false;
  p_interview_warning               := false;
  p_review_warning                  := false;
  p_recruiter_warning               := false;
  p_asg_future_changes_warning      := false;
  p_entries_changed_warning         := null;
  p_pay_proposal_warning            := false;
  p_dod_warning                     := false;
    raise;
    --
    -- End of fix.
    --
end actual_termination_emp;
--
-- 70.2 change a end.
--
-- 70.2 change b start.
--
-- ----------------------------------------------------------------------------
-- |-------------------------< final_process_emp >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure final_process_emp
  (p_validate                     in     boolean  default false
  ,p_period_of_service_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_final_process_date           in out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean     := FALSE;
  l_entries_changed_warning    varchar2(1) := 'N';
  l_final_process_date         per_periods_of_service.final_process_date%TYPE;
  l_temp_date per_periods_of_service.final_process_date%TYPE := p_final_process_date;
  l_ovn per_periods_of_service.object_version_number%type := p_object_version_number;
  l_org_now_no_manager_warning boolean     := FALSE;
  l_pds_object_version_number  per_periods_of_service.object_version_number%TYPE;
  --
  l_actual_termination_date    per_periods_of_service.actual_termination_date%TYPE;
  l_cr_asg_future_changes_warn boolean     := FALSE;
  l_cr_entries_changed_warn    varchar2(1) := 'N';
  l_cr_org_now_no_manager_warn boolean     := FALSE;
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_exists                     varchar2(1);
  l_last_standard_process_date per_periods_of_service.last_standard_process_date%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_object_version_number      per_periods_of_service.object_version_number%TYPE;
  l_person_id                  per_all_people_f.person_id%TYPE;
  l_proc                       varchar2(72) := g_package || 'final_process_emp';
  l_exemppet_eff_date          date;
  l_action_chk                 VARCHAR2(1) := 'N';
  --
  cursor csr_get_derived_details is
    select bus.legislation_code
         , pds.actual_termination_date
         , pds.last_standard_process_date
         , pds.person_id
         , pds.object_version_number
      from per_business_groups    bus
         , per_periods_of_service pds
     where pds.period_of_service_id = p_period_of_service_id
     and   bus.business_group_id    = pds.business_group_id;
  --
  cursor csr_get_asgs_to_final_proc is
    select asg.assignment_id
         , asg.object_version_number
         , asg.primary_flag
      from per_all_assignments_f asg
     where asg.period_of_service_id = p_period_of_service_id
       and l_final_process_date     between asg.effective_start_date
                                    and     asg.effective_end_date
       and exists (
                select 'X'
                  from per_all_assignments_f a1
                 where asg.assignment_id = a1.assignment_id
                   and l_final_process_date+1  between a1.effective_start_date
                                               and     a1.effective_end_date)
     order by asg.primary_flag;
  --
  cursor csr_valid_ex_emp is
    select null
      from per_all_people_f         per
         , per_person_type_usages_f ptu
         , per_person_types         pet
     where per.person_id          = l_person_id
     and   l_exemppet_eff_date    between per.effective_start_date
                                  and     per.effective_end_date
     and   per.person_id          = ptu.person_id
     and   l_exemppet_eff_date    between ptu.effective_start_date
                                  and     ptu.effective_end_date
     and   pet.person_type_id     = ptu.person_type_id
     and   pet.system_person_type = 'EX_EMP';
  --
  -- Fix for bug 3829474 starts here.
  --
  l_pds_rec per_periods_of_service%rowtype;
  --
  cursor l_pds_cur is
    select *
    from per_periods_of_service
    where period_of_service_id = p_period_of_service_id;
  --
  -- Fix for bug 3829474 ends here.
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
 -- l_pds_object_version_number := p_object_version_number;
  l_final_process_date          := trunc(p_final_process_date);
  --
  -- Issue a savepoint.
  --
  savepoint final_process_emp;
  --
  -- Start of API User Hook for the before hook of final_process_emp.
  --
  begin
     hr_ex_employee_bk2.final_process_emp_b
  (p_period_of_service_id          =>     p_period_of_service_id
  ,p_object_version_number         =>     p_object_version_number
  ,p_final_process_date            =>     l_final_process_date
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'FINAL_PROCESS_EMP',
          p_hook_type         => 'BP'
         );
  end;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- Check period of service.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'period_of_service_id'
     ,p_argument_value => p_period_of_service_id
     );
  --
  -- Check Object version number.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'object_version_number'
     ,p_argument_value => p_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 20);
  --
  open  csr_get_derived_details;
  fetch csr_get_derived_details
   into l_legislation_code
       ,l_actual_termination_date
       ,l_last_standard_process_date
       ,l_person_id
       ,l_object_version_number;
  --
  if csr_get_derived_details%NOTFOUND
  then
    --
    hr_utility.set_location(l_proc, 30);
    --
    close csr_get_derived_details;
    --
    hr_utility.set_message(801,'HR_7391_ASG_INV_PERIOD_OF_SERV');
    hr_utility.raise_error;
  end if;
  --
  close csr_get_derived_details;
  --
  -- Validate the derived OVN with passed OVN.

  if  l_object_version_number <> p_object_version_number
  then

    hr_utility.set_message(801,'HR_7155_OBJECT_INVALID');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 40);
  --
  -- Check that the actual termination date has already been set.
  --
  if l_actual_termination_date is null
  then
    --
    hr_utility.set_location(l_proc, 50);
    --
    hr_utility.set_message(801,'HR_51007_ASG_INV_NOT_ACT_TERM');
    hr_utility.raise_error;
  end if;
  --
  -- Check if the final process date is set
  --
  if l_legislation_code = 'US'
    and p_final_process_date is null
  then
    --
    -- Default the FPD to the LSPD
    --
    l_final_process_date := l_actual_termination_date;
    --
    -- Add one day to the last standard process date to get the
    -- validation date
    --
    -- Set the EX Employee effective date to the FPD + 1
    --
    --   Note: Since the FPD equals the ATD then the employee
    --         has not been Ex Employee for at least one day
    --
    l_exemppet_eff_date := l_final_process_date+1;
    --
  elsif p_final_process_date is null
  then
    --
    -- Default the FPD to the LSPD
    --
    l_final_process_date := l_last_standard_process_date;
    --
    -- Add one day to the last standard process date to get the
    -- validation date
    --
    -- Set the EX Employee effective date to the FPD + 1
    --
    --   Note: Since the FPD equals the LSPD then the employee
    --         has not been Ex Employee for at least one day
    --
    l_exemppet_eff_date := l_final_process_date+1;
    --
  elsif p_final_process_date = l_actual_termination_date then
    --
    l_final_process_date := p_final_process_date;
    --
    -- Set the EX Employee effective date to the FPD + 1
    --
    --   Note: Since the FPD equals the ATD then the employee
    --         has not been Ex Employee for at least one day
    --
    l_exemppet_eff_date := p_final_process_date+1;
    --
  else
    --
    l_final_process_date := p_final_process_date;
    --
    l_exemppet_eff_date := p_final_process_date;
    --
  end if;
  --
  hr_utility.set_location(l_proc, 90);
  --
  -- Check that the corresponding person is of EX_EMP system person type.
  --
  open  csr_valid_ex_emp;
  fetch csr_valid_ex_emp
   into l_exists;
  --
  if csr_valid_ex_emp%NOTFOUND
  then
    --
    hr_utility.set_location(l_proc, 100);
    --
    close csr_valid_ex_emp;
    --
    hr_utility.set_message(801,'HR_51008_ASG_INV_EX_EMP_TYPE');
    hr_utility.raise_error;
    --
  end if;
  --
  hr_utility.set_location(l_proc, 110);
  --
  close csr_valid_ex_emp;
  --
  --2478758 implement check for payroll actions
  --
  l_action_chk := hr_ex_employee_api.check_for_compl_actions
                      (p_person_id => l_person_id
                      ,p_act_date  => l_actual_termination_date
                      ,p_lsp_date  => l_last_standard_process_date
                      ,p_fpr_date  => l_final_process_date
                       );
  --
  IF l_action_chk = 'N' THEN
    --if this check suceeds, erase any possible warning from ATD check.
    hr_utility.clear_warning;
  END IF;
  IF l_action_chk = 'W' THEN
    --
    -- Fix for bug 3100620 starts here. changed the warning message.
    --
    --hr_utility.set_message(801,'HR_6516_EMP_TERM_ACTIONS_EXIST');
    hr_utility.set_message(800,'PER_449053_EMP_TERM_FUT_ERROR');
    --
    -- Fix for bug 3100620 ends here.
    --
    hr_utility.set_warning;
  END IF;
  --
  if l_action_chk = 'Y' then
     hr_utility.set_message(801,'HR_6517_EMP_FPD_ACTIONS_EXIST');
     hr_utility.raise_error;
  end if;
  --
  -- Check that there are no COBRA benefits after the final process date.
  --
  -- Not implemented yet due to outstanding issues.
  --
  -- Update final process date in periods of service table.
  --
  per_pds_upd.upd
    (p_period_of_service_id       => p_period_of_service_id
    ,p_final_process_date         => l_final_process_date
    ,p_object_version_number      => l_object_version_number
    ,p_effective_date             => l_final_process_date
    ,p_validate                   => p_validate
    );

--
  hr_utility.set_location(l_proc, 120);
  --
  -- Final process the assignments, ensuring that the non-primaries are
  -- processed before the primary (implemented via 'order by primary_flag'
  -- clause in cursor declaration).
  --

  --


  for csr_rec in csr_get_asgs_to_final_proc
  loop
    --
    hr_utility.set_location(l_proc, 130);
    hr_utility.set_location('assignment_id '||to_char(csr_rec.assignment_id),131);
    --
    hr_assignment_internal.final_process_emp_asg_sup
      (p_assignment_id              => csr_rec.assignment_id
      ,p_object_version_number      => csr_rec.object_version_number
      ,p_actual_termination_date    => l_actual_termination_date
      ,p_final_process_date         => l_final_process_date
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      ,p_org_now_no_manager_warning => l_cr_org_now_no_manager_warn
      ,p_asg_future_changes_warning => l_cr_asg_future_changes_warn
      ,p_entries_changed_warning    => l_cr_entries_changed_warn
      );
    --
    hr_utility.set_location(l_proc, 140);
    --
    -- Set entries changed warning using the precedence of 'S', then 'Y', then
    -- 'N'.
    --
    if l_cr_entries_changed_warn = 'S'
       or l_entries_changed_warning = 'S'
    then
      --
      hr_utility.set_location(l_proc, 150);
      --
      l_entries_changed_warning := 'S';
      --
    elsif l_cr_entries_changed_warn = 'Y'
     or  l_entries_changed_warning = 'Y'
    then
      --
      hr_utility.set_location(l_proc, 160);
      --
      l_entries_changed_warning := 'Y';
      --
     else
      --
      hr_utility.set_location(l_proc, 165);
      --
      l_entries_changed_warning := 'N';
      --
    end if;
    --
    hr_utility.set_location(l_proc, 170);
    --
    -- Set future changes warning.
    --
    if l_cr_asg_future_changes_warn
    then
      --
      hr_utility.set_location(l_proc, 180);
      --
      l_asg_future_changes_warning := TRUE;
    end if;
    --
    -- Set org now no manager warning.
    --
    if l_cr_org_now_no_manager_warn
    then
      --
      hr_utility.set_location(l_proc, 190);
      --
      l_org_now_no_manager_warning := TRUE;
    end if;
  end loop;
  --
  hr_utility.set_location(l_proc, 195);
  --
  -- Fix for bug 3829474 starts here.
  --

 /* Bug 5504659
  open l_pds_cur;
  fetch l_pds_cur into l_pds_rec;
  close l_pds_cur;
  per_hrwf_synch.per_pds_wf(
                         p_rec    => l_pds_rec,
                         p_date    => l_final_process_date,
                         p_action  => 'TERMINATION');
Note : added p_date_start to test, earlier code does not work*/


  --
  -- Fix for bug 3829474 ends here.
  --
  hr_utility.set_location(l_proc, 200);
  --
  -- Start of API User Hook for the after hook of final_process_emp.
  --
  begin
     hr_ex_employee_bk2.final_process_emp_a
  (p_period_of_service_id          =>   p_period_of_service_id
  ,p_object_version_number         =>   l_object_version_number
  ,p_final_process_date            =>   l_final_process_date
  ,p_org_now_no_manager_warning    =>   l_org_now_no_manager_warning
  ,p_asg_future_changes_warning    =>   l_asg_future_changes_warning
  ,p_entries_changed_warning       =>   l_entries_changed_warning
  );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'FINAL_PROCESS_EMP',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of create_secondary_apl_asg.
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_final_process_date         := l_final_process_date;
  p_asg_future_changes_warning := l_asg_future_changes_warning;
  p_entries_changed_warning    := l_entries_changed_warning;
  p_object_version_number      := l_object_version_number;
  p_org_now_no_manager_warning := l_org_now_no_manager_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 400);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO final_process_emp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_asg_future_changes_warning := l_asg_future_changes_warning;
    p_entries_changed_warning    := l_entries_changed_warning;
    p_org_now_no_manager_warning := l_org_now_no_manager_warning;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO final_process_emp;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    p_final_process_date    := l_temp_date;
    p_org_now_no_manager_warning      := false;
    p_asg_future_changes_warning      := false;
    p_entries_changed_warning         := null;
    raise;
    --
    -- End of fix.
    --
end final_process_emp;
--
-- 70.2 change b end.
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_term_details_emp >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_term_details_emp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_termination_accepted_person   in     number   default hr_api.g_number
  ,p_accepted_termination_date     in     date     default hr_api.g_date
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_notified_termination_date     in     date     default hr_api.g_date
  ,p_projected_termination_date    in     date     default hr_api.g_date
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_term_details_emp';
  l_object_version_number
                        number := p_object_version_number;
  l_ovn number := p_object_version_number;
  l_validate            boolean := false;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_term_details_emp;
  hr_utility.set_location(l_proc, 6);
  --
  --
  -- Start of API User Hook for the before hook of final_process_emp.
  --
  begin
   --
   hr_ex_employee_bk3.update_term_details_emp_b
     (p_effective_date                => p_effective_date
     ,p_period_of_service_id          => p_period_of_service_id
     ,p_object_version_number         => p_object_version_number
     ,p_termination_accepted_person   => p_termination_accepted_person
     ,p_accepted_termination_date     => p_accepted_termination_date
     ,p_comments                      => p_comments
     ,p_leaving_reason                => p_leaving_reason
     ,p_notified_termination_date     => p_notified_termination_date
     ,p_projected_termination_date    => p_projected_termination_date
     );
   exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_TERM_DETAILS_EMP',
          p_hook_type         => 'BP'
         );
  end;
  -- Process Logic
  --
  per_pds_upd.upd
  (p_period_of_service_id         => p_period_of_service_id
  ,p_termination_accepted_person  => p_termination_accepted_person
  ,p_accepted_termination_date    => p_accepted_termination_date
  ,p_comments                     => p_comments
  ,p_leaving_reason               => p_leaving_reason
  ,p_notified_termination_date    => p_notified_termination_date
  ,p_projected_termination_date   => p_projected_termination_date
  ,p_object_version_number        => p_object_version_number
  ,p_effective_date               => p_effective_date
  ,p_validate                     => l_validate
  );
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  --
  -- Start of API User Hook for the after hook of final_process_emp.
  --
  begin
   hr_ex_employee_bk3.update_term_details_emp_a
     (p_effective_date                =>  p_effective_date
     ,p_period_of_service_id          =>  p_period_of_service_id
     ,p_object_version_number         =>  p_object_version_number
     ,p_termination_accepted_person   =>  p_termination_accepted_person
     ,p_accepted_termination_date     =>  p_accepted_termination_date
     ,p_comments                      =>  p_comments
     ,p_leaving_reason                =>  p_leaving_reason
     ,p_notified_termination_date     =>  p_notified_termination_date
     ,p_projected_termination_date    =>  p_projected_termination_date
     );
   exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_TERM_DETAILS_EMP',
          p_hook_type         => 'AP'
         );
  end;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 8);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_term_details_emp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO update_term_details_emp;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    raise;
    --
    -- End of fix.
    --
end update_term_details_emp;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_for_compl_actions >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_for_compl_actions(p_person_id   NUMBER
                                ,p_act_date DATE
                                ,p_lsp_date DATE
                                ,p_fpr_date DATE
                                ) RETURN VARCHAR2 IS
--
l_action_chk VARCHAR2(1) := 'N';
l_action_date DATE;
--
l_proc varchar2(72):=g_package||'check_for_compl_actions';
begin
  hr_utility.trace('Entered check_for_compl_actions for '||p_person_id);
  hr_utility.trace('ATD: '||p_act_date);
  hr_utility.trace('LSP: '||p_lsp_date);
  hr_utility.trace('FPD: '||p_fpr_date);
  --
  IF p_lsp_date IS NOT NULL THEN
    IF p_act_date IS NOT NULL AND p_lsp_date >= p_act_date THEN
      l_action_date := p_lsp_date;
    ELSE
      l_action_date := null;
    END IF;
  ELSE
    l_action_date := p_act_date;
  END IF;
  hr_utility.set_location(l_proc,1);
  BEGIN
    SELECT 'Y'
    INTO   l_action_chk
    FROM   dual
    WHERE  exists
           (SELECT null
            FROM   pay_payroll_actions pac,
                   pay_assignment_actions act,
                   per_assignments_f asg
            WHERE  asg.person_id = p_person_id
            AND  act.assignment_id = asg.assignment_id
            AND  pac.payroll_action_id = act.payroll_action_id
            AND  pac.action_type NOT IN ('X','BEE')
            AND  pac.effective_date > nvl(p_fpr_date,hr_api.g_eot));
  EXCEPTION
      when NO_DATA_FOUND then null;
  END;
  --
  hr_utility.set_location(l_proc,5);
  IF l_action_chk = 'N' THEN
    BEGIN
      SELECT 'W'
      INTO   l_action_chk
      FROM   dual
      WHERE  exists
           (SELECT null
            FROM   pay_payroll_actions pac,
                   pay_assignment_actions act,
                   per_assignments_f asg
            WHERE  asg.person_id = p_person_id
            AND  act.assignment_id = asg.assignment_id
            AND  pac.payroll_action_id = act.payroll_action_id
            AND  pac.action_type <> 'BEE'
            AND  pac.action_status = 'C'
            AND  (   (p_fpr_date is null
                      AND pac.effective_date >= l_action_date)
                  OR (p_fpr_date is not null
                      AND (pac.effective_date >= l_action_date
                           AND pac.effective_date <= p_fpr_date))));
      --
      hr_utility.set_location(l_proc,7);
    EXCEPTION
        when NO_DATA_FOUND then null;
    END;
    END IF;
RETURN l_action_chk;
end check_for_compl_actions;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< reverse_terminate_employee  >-------------------------|
-- ----------------------------------------------------------------------------
procedure reverse_terminate_employee
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_actual_termination_date       in     date
  ,p_clear_details                 in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'reverse_terminate_employee';
  begin
    hr_utility.set_location('Entering:'|| l_proc, 5);
    --
    -- Issue a savepoint.
    --
    savepoint reverse_terminate_employee;
    --
      --
      -- Start of API User Hook for the before hook of reverse_terminate_employee.
      --
      begin
       --
       hr_ex_employee_bk4.reverse_terminate_employee_b
         (   p_person_id                =>  p_person_id
            ,p_actual_termination_date  =>  p_actual_termination_date
            ,p_clear_details            =>  p_clear_details
         );
       exception
         when hr_api.cannot_find_prog_unit then
           hr_api.cannot_find_prog_unit_error
             (p_module_name       => 'REVERSE_TERMINATE_EMPLOYEE',
              p_hook_type         => 'BP'
             );
     end;
  --
  -- Process Logic
  --
    hr_utility.set_location('Before:hr_ex_employee_internal.reverse_terminate_employee'|| l_proc, 10);
      hr_ex_employee_internal.reverse_terminate_employee
                                 (p_person_id
                                 ,p_actual_termination_date
                                 ,p_clear_details);
  --
  hr_utility.set_location('After:hr_ex_employee_internal.reverse_terminate_employee'|| l_proc, 15);
  -- When in validation only mode raise the Validate_Enabled exception
  --
  --
  -- Start of API User Hook for the after hook of reverse_terminate_employee.
  --
      begin
       hr_ex_employee_bk4.reverse_terminate_employee_a
               (   p_person_id                =>  p_person_id
                  ,p_actual_termination_date  =>  p_actual_termination_date
                  ,p_clear_details            =>  p_clear_details
               );
       exception
         when hr_api.cannot_find_prog_unit then
           hr_api.cannot_find_prog_unit_error
             (p_module_name       => 'REVERSE_TERMINATE_EMPLOYEE',
              p_hook_type         => 'AP'
             );
   end;

    if p_validate then
       raise hr_api.validate_enabled;
     end if;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 20);
     --
   exception
     when hr_api.validate_enabled then
       --
       -- As the Validate_Enabled exception has been raised
       -- we must rollback to the savepoint
       --
       ROLLBACK TO reverse_terminate_employee;
       --
       -- Only set output warning arguments
       -- (Any key or derived arguments must be set to null
       -- when validation only mode is being used.)
       --
       --
     when others then
       --
       --
       ROLLBACK TO reverse_terminate_employee;
       --
       -- set in out parameters and set out parameters
       --
       raise;
       --
end reverse_terminate_employee;
--
end hr_ex_employee_api;

/
