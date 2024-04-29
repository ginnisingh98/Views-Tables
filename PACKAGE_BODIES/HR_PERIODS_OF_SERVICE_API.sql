--------------------------------------------------------
--  DDL for Package Body HR_PERIODS_OF_SERVICE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERIODS_OF_SERVICE_API" as
/* $Header: pepdsapi.pkb 120.11.12010000.4 2009/07/16 11:35:34 pchowdav ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_periods_of_service_api.';
--
-- ----------------------------------------------------------------------------
-- |----------------< update_pds_details (overloaded) >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pds_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_termination_accepted_person   in     number   default hr_api.g_number
  ,p_accepted_termination_date     in     date     default hr_api.g_date
  ,p_object_version_number         in out nocopy number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_notified_termination_date     in     date     default hr_api.g_date
  ,p_projected_termination_date    in     date     default hr_api.g_date
  ,p_actual_termination_date       in     date     default hr_api.g_date
  ,p_last_standard_process_date    in     date     default hr_api.g_date
  ,p_final_process_date            in     date     default hr_api.g_date
  ,p_attribute_category            in varchar2     default hr_api.g_varchar2
  ,p_attribute1                    in varchar2     default hr_api.g_varchar2
  ,p_attribute2                    in varchar2     default hr_api.g_varchar2
  ,p_attribute3                    in varchar2     default hr_api.g_varchar2
  ,p_attribute4                    in varchar2     default hr_api.g_varchar2
  ,p_attribute5                    in varchar2     default hr_api.g_varchar2
  ,p_attribute6                    in varchar2     default hr_api.g_varchar2
  ,p_attribute7                    in varchar2     default hr_api.g_varchar2
  ,p_attribute8                    in varchar2     default hr_api.g_varchar2
  ,p_attribute9                    in varchar2     default hr_api.g_varchar2
  ,p_attribute10                   in varchar2     default hr_api.g_varchar2
  ,p_attribute11                   in varchar2     default hr_api.g_varchar2
  ,p_attribute12                   in varchar2     default hr_api.g_varchar2
  ,p_attribute13                   in varchar2     default hr_api.g_varchar2
  ,p_attribute14                   in varchar2     default hr_api.g_varchar2
  ,p_attribute15                   in varchar2     default hr_api.g_varchar2
  ,p_attribute16                   in varchar2     default hr_api.g_varchar2
  ,p_attribute17                   in varchar2     default hr_api.g_varchar2
  ,p_attribute18                   in varchar2     default hr_api.g_varchar2
  ,p_attribute19                   in varchar2     default hr_api.g_varchar2
  ,p_attribute20                   in varchar2     default hr_api.g_varchar2
  ,p_pds_information_category      in varchar2     default hr_api.g_varchar2
  ,p_pds_information1              in varchar2     default hr_api.g_varchar2
  ,p_pds_information2              in varchar2     default hr_api.g_varchar2
  ,p_pds_information3              in varchar2     default hr_api.g_varchar2
  ,p_pds_information4              in varchar2     default hr_api.g_varchar2
  ,p_pds_information5              in varchar2     default hr_api.g_varchar2
  ,p_pds_information6              in varchar2     default hr_api.g_varchar2
  ,p_pds_information7              in varchar2     default hr_api.g_varchar2
  ,p_pds_information8              in varchar2     default hr_api.g_varchar2
  ,p_pds_information9              in varchar2     default hr_api.g_varchar2
  ,p_pds_information10             in varchar2     default hr_api.g_varchar2
  ,p_pds_information11             in varchar2     default hr_api.g_varchar2
  ,p_pds_information12             in varchar2     default hr_api.g_varchar2
  ,p_pds_information13             in varchar2     default hr_api.g_varchar2
  ,p_pds_information14             in varchar2     default hr_api.g_varchar2
  ,p_pds_information15             in varchar2     default hr_api.g_varchar2
  ,p_pds_information16             in varchar2     default hr_api.g_varchar2
  ,p_pds_information17             in varchar2     default hr_api.g_varchar2
  ,p_pds_information18             in varchar2     default hr_api.g_varchar2
  ,p_pds_information19             in varchar2     default hr_api.g_varchar2
  ,p_pds_information20             in varchar2     default hr_api.g_varchar2
  ,p_pds_information21             in varchar2     default hr_api.g_varchar2
  ,p_pds_information22             in varchar2     default hr_api.g_varchar2
  ,p_pds_information23             in varchar2     default hr_api.g_varchar2
  ,p_pds_information24             in varchar2     default hr_api.g_varchar2
  ,p_pds_information25             in varchar2     default hr_api.g_varchar2
  ,p_pds_information26             in varchar2     default hr_api.g_varchar2
  ,p_pds_information27             in varchar2     default hr_api.g_varchar2
  ,p_pds_information28             in varchar2     default hr_api.g_varchar2
  ,p_pds_information29             in varchar2     default hr_api.g_varchar2
  ,p_pds_information30             in varchar2     default hr_api.g_varchar2
   ) is
  --
  l_org_now_no_manager_warning BOOLEAN := FALSE;
  l_asg_future_changes_warning BOOLEAN := FALSE;
  l_entries_changed_warning    VARCHAR2(200) := '';
  --
begin
  --
  update_pds_details
    (p_validate                      => p_validate
    ,p_effective_date                => p_effective_date
    ,p_period_of_service_id          => p_period_of_service_id
    ,p_termination_accepted_person   => p_termination_accepted_person
    ,p_accepted_termination_date     => p_accepted_termination_date
    ,p_object_version_number         => p_object_version_number
    ,p_comments                      => p_comments
    ,p_leaving_reason                => p_leaving_reason
    ,p_notified_termination_date     => p_notified_termination_date
    ,p_projected_termination_date    => p_projected_termination_date
    ,p_actual_termination_date       => p_actual_termination_date
    ,p_last_standard_process_date    => p_last_standard_process_date
    ,p_final_process_date            => p_final_process_date
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
    ,p_org_now_no_manager_warning    => l_org_now_no_manager_warning
    ,p_asg_future_changes_warning    => l_asg_future_changes_warning
    ,p_entries_changed_warning       => l_entries_changed_warning
    );
  --
end update_pds_details;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_pds_details >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pds_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_termination_accepted_person   in     number   default hr_api.g_number
  ,p_accepted_termination_date     in     date     default hr_api.g_date
  ,p_object_version_number         in out nocopy number
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_notified_termination_date     in     date     default hr_api.g_date
  ,p_projected_termination_date    in     date     default hr_api.g_date
--
-- 115.9 (START)
--
  ,p_actual_termination_date       in     date     default hr_api.g_date
  ,p_last_standard_process_date    in     date     default hr_api.g_date
  ,p_final_process_date            in     date     default hr_api.g_date
--
-- 115.9 (END)
--
  ,p_attribute_category            in varchar2     default hr_api.g_varchar2
  ,p_attribute1                    in varchar2     default hr_api.g_varchar2
  ,p_attribute2                    in varchar2     default hr_api.g_varchar2
  ,p_attribute3                    in varchar2     default hr_api.g_varchar2
  ,p_attribute4                    in varchar2     default hr_api.g_varchar2
  ,p_attribute5                    in varchar2     default hr_api.g_varchar2
  ,p_attribute6                    in varchar2     default hr_api.g_varchar2
  ,p_attribute7                    in varchar2     default hr_api.g_varchar2
  ,p_attribute8                    in varchar2     default hr_api.g_varchar2
  ,p_attribute9                    in varchar2     default hr_api.g_varchar2
  ,p_attribute10                   in varchar2     default hr_api.g_varchar2
  ,p_attribute11                   in varchar2     default hr_api.g_varchar2
  ,p_attribute12                   in varchar2     default hr_api.g_varchar2
  ,p_attribute13                   in varchar2     default hr_api.g_varchar2
  ,p_attribute14                   in varchar2     default hr_api.g_varchar2
  ,p_attribute15                   in varchar2     default hr_api.g_varchar2
  ,p_attribute16                   in varchar2     default hr_api.g_varchar2
  ,p_attribute17                   in varchar2     default hr_api.g_varchar2
  ,p_attribute18                   in varchar2     default hr_api.g_varchar2
  ,p_attribute19                   in varchar2     default hr_api.g_varchar2
  ,p_attribute20                   in varchar2     default hr_api.g_varchar2
  ,p_pds_information_category      in varchar2     default hr_api.g_varchar2
  ,p_pds_information1              in varchar2     default hr_api.g_varchar2
  ,p_pds_information2              in varchar2     default hr_api.g_varchar2
  ,p_pds_information3              in varchar2     default hr_api.g_varchar2
  ,p_pds_information4              in varchar2     default hr_api.g_varchar2
  ,p_pds_information5              in varchar2     default hr_api.g_varchar2
  ,p_pds_information6              in varchar2     default hr_api.g_varchar2
  ,p_pds_information7              in varchar2     default hr_api.g_varchar2
  ,p_pds_information8              in varchar2     default hr_api.g_varchar2
  ,p_pds_information9              in varchar2     default hr_api.g_varchar2
  ,p_pds_information10             in varchar2     default hr_api.g_varchar2
  ,p_pds_information11             in varchar2     default hr_api.g_varchar2
  ,p_pds_information12             in varchar2     default hr_api.g_varchar2
  ,p_pds_information13             in varchar2     default hr_api.g_varchar2
  ,p_pds_information14             in varchar2     default hr_api.g_varchar2
  ,p_pds_information15             in varchar2     default hr_api.g_varchar2
  ,p_pds_information16             in varchar2     default hr_api.g_varchar2
  ,p_pds_information17             in varchar2     default hr_api.g_varchar2
  ,p_pds_information18             in varchar2     default hr_api.g_varchar2
  ,p_pds_information19             in varchar2     default hr_api.g_varchar2
  ,p_pds_information20             in varchar2     default hr_api.g_varchar2
  ,p_pds_information21             in varchar2     default hr_api.g_varchar2
  ,p_pds_information22             in varchar2     default hr_api.g_varchar2
  ,p_pds_information23             in varchar2     default hr_api.g_varchar2
  ,p_pds_information24             in varchar2     default hr_api.g_varchar2
  ,p_pds_information25             in varchar2     default hr_api.g_varchar2
  ,p_pds_information26             in varchar2     default hr_api.g_varchar2
  ,p_pds_information27             in varchar2     default hr_api.g_varchar2
  ,p_pds_information28             in varchar2     default hr_api.g_varchar2
  ,p_pds_information29             in varchar2     default hr_api.g_varchar2
  ,p_pds_information30             in varchar2     default hr_api.g_varchar2
--
-- 115.9 (START)
--
  ,p_org_now_no_manager_warning    OUT NOCOPY      BOOLEAN
  ,p_asg_future_changes_warning    OUT NOCOPY      BOOLEAN
  ,p_entries_changed_warning       OUT NOCOPY      VARCHAR2
--
-- 115.9 (END)
--
   ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                       varchar2(72) := g_package||'update_pds_details';
  l_object_version_number      number := p_object_version_number;
  l_ovn                        number := p_object_version_number;
  l_validate                   boolean := false;
  l_person_type_usage_id       per_person_type_usages_f.person_type_usage_id%TYPE;
  l_ptu_object_version_number  per_person_type_usages_f.object_version_number%TYPE;
  l_effective_start_date       DATE;
  l_effective_end_date         DATE;

--
-- 115.9 (START)
--
  l_old_final_process_date per_periods_of_service.final_process_date%TYPE;
--
-- 115.9 (END)
--
-- Fix for Bug 5152193 Starts here

l_pds_rec per_periods_of_service%rowtype;
l_per_rec per_all_people_f%rowtype;
l_orig_hire_warning boolean;
l_dob_null_warning boolean;
l_name_combination_warning boolean;

cursor csr_get_pds_details is
select * from per_periods_of_service
where period_of_service_id = p_period_of_service_id;

cursor csr_get_per_rec(p_person_id number,p_date date) is
select * from per_all_people_f
where person_id = p_person_id
and effective_start_date >= p_date;


-- Fix for Bug 5152193 Ends here

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_pds_details;
  hr_utility.set_location(l_proc, 6);
  --
  -- Start of API User Hook for the before hook of final_process_emp.
  --
  begin
   --
   hr_periods_of_service_bk1.update_pds_details_b
     (p_effective_date                => p_effective_date
     ,p_period_of_service_id          => p_period_of_service_id
     ,p_termination_accepted_person   => p_termination_accepted_person
     ,p_accepted_termination_date     => p_accepted_termination_date
     ,p_comments                      => p_comments
     ,p_leaving_reason                => p_leaving_reason
     ,p_notified_termination_date     => p_notified_termination_date
     ,p_projected_termination_date    => p_projected_termination_date
     ,p_actual_termination_date       => p_actual_termination_date
     ,p_last_standard_process_date    => p_last_standard_process_date
     ,p_final_process_date            => p_final_process_date
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
     ,p_object_version_number         => p_object_version_number
     );
   exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_PDS_DETAILS',
          p_hook_type         => 'BP'
         );
  end;
  --
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
--
-- 115.9 (START)
--
  ,p_actual_termination_date      => p_actual_termination_date
  ,p_last_standard_process_date   => p_last_standard_process_date
  ,p_final_process_date           => p_final_process_date
--
-- 115.9 (END)
--
  ,p_object_version_number        => p_object_version_number
  ,p_effective_date               => p_effective_date
  ,p_validate                     => l_validate
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
  ,p_pds_information_category     => p_pds_information_category
  ,p_pds_information1             => p_pds_information1
  ,p_pds_information2             => p_pds_information2
  ,p_pds_information3             => p_pds_information3
  ,p_pds_information4             => p_pds_information4
  ,p_pds_information5             => p_pds_information5
  ,p_pds_information6             => p_pds_information6
  ,p_pds_information7             => p_pds_information7
  ,p_pds_information8             => p_pds_information8
  ,p_pds_information9             => p_pds_information9
  ,p_pds_information10            => p_pds_information10
  ,p_pds_information11            => p_pds_information11
  ,p_pds_information12            => p_pds_information12
  ,p_pds_information13            => p_pds_information13
  ,p_pds_information14            => p_pds_information14
  ,p_pds_information15            => p_pds_information15
  ,p_pds_information16            => p_pds_information16
  ,p_pds_information17            => p_pds_information17
  ,p_pds_information18            => p_pds_information18
  ,p_pds_information19            => p_pds_information19
  ,p_pds_information20            => p_pds_information20
  ,p_pds_information21            => p_pds_information21
  ,p_pds_information22            => p_pds_information22
  ,p_pds_information23            => p_pds_information23
  ,p_pds_information24            => p_pds_information24
  ,p_pds_information25            => p_pds_information25
  ,p_pds_information26            => p_pds_information26
  ,p_pds_information27            => p_pds_information27
  ,p_pds_information28            => p_pds_information28
  ,p_pds_information29            => p_pds_information29
  ,p_pds_information30            => p_pds_information30
  );

--
-- 115.9 (START)
--
  --
  -- Retain old value of FPD
  --
  l_old_final_process_date := per_pds_shd.g_old_rec.final_process_date;
  --
  -- Handle maintenance of records linked to PDS
  --
  move_term_assignments(p_period_of_service_id       => p_period_of_service_id
                       ,p_old_final_process_date     => l_old_final_process_date
                       ,p_new_final_process_date     => p_final_process_date
                       ,p_org_now_no_manager_warning => p_org_now_no_manager_warning
                       ,p_asg_future_changes_warning => p_asg_future_changes_warning
                       ,p_entries_changed_warning    => p_entries_changed_warning
                       );
--
-- 115.9 (END)
--

  if per_pds_shd.g_old_rec.actual_termination_date is not null
       then
       --
       -- Fix for bug 3882918. check with nvl for the leaving_reason.
       --
       hr_utility.set_location('Update_pds_details ',800);
       --
       if nvl(per_pds_shd.g_old_rec.leaving_reason, hr_api.g_varchar2)
         <> nvl(p_leaving_reason,hr_api.g_varchar2)
       then
         --
         -- Fix for bug 3882918. If this proc is called without leaving_reason parameter
         -- then no need to check further as it means, user doesn't want to change this value.
         --
         hr_utility.set_location('Update_pds_details ',810);

          --
          -- Bug number 4900409 - validating actual termination date cannot be future date
          -- if leaving reason is 'D' Deceased

         IF nvl(p_leaving_reason,hr_api.g_varchar2)='D' AND
		(per_pds_shd.g_old_rec.actual_termination_date > SYSDATE) THEN

            hr_utility.set_location('Update_pds_details ',812);
            fnd_message.set_name('PER','PER_449766_NO_FUT_ACTUAL_TERM');
            fnd_message.raise_error;

          END IF;

         hr_utility.set_location('Update_pds_details ',818);

         -- End of changes for 4900409

         IF  not (p_leaving_reason = hr_api.g_varchar2 and p_leaving_reason is not null) THEN
           --
           hr_utility.set_location('Update_pds_details ',820);
           --
           if (nvl(p_leaving_reason, hr_api.g_varchar2) = 'R' and
                 nvl(per_pds_shd.g_old_rec.leaving_reason, hr_api.g_varchar2) <> 'R' )
                 then

                 hr_utility.set_location('Update_pds_details ',900);

                 hr_per_type_usage_internal.create_person_type_usage
                 (p_person_id            => per_pds_shd.g_old_rec.person_id
                 ,p_person_type_id       =>
              	 hr_person_type_usage_info.get_default_person_type_id
                     (p_business_group_id    => per_pds_shd.g_old_rec.business_group_id
                     ,p_system_person_type   => 'RETIREE')
                 ,p_effective_date       => per_pds_shd.g_old_rec.actual_termination_date+1
                 ,p_person_type_usage_id => l_person_type_usage_id
                 ,p_object_version_number=> l_ptu_object_version_number
                 ,p_effective_start_date => l_effective_start_date
                 ,p_effective_end_date   => l_effective_end_date);

           elsif (nvl(p_leaving_reason, hr_api.g_varchar2) <> 'R' and
                 nvl(per_pds_shd.g_old_rec.leaving_reason,hr_api.g_varchar2) = 'R' )
                 then

                 hr_utility.set_location('Update_pds_details ',910);

                 hr_per_type_usage_internal.maintain_person_type_usage
                 (p_effective_date   => per_pds_shd.g_old_rec.actual_termination_date+1
                 ,p_person_id        => per_pds_shd.g_old_rec.person_id
                 ,p_person_type_id   =>
           		hr_person_type_usage_info.get_default_person_type_id
                    (p_business_group_id    => per_pds_shd.g_old_rec.business_group_id
                    ,p_system_person_type   => 'RETIREE')
                 ,p_datetrack_delete_mode  => 'ZAP');

-- Fix for Bug 5152193 Starts here

           elsif (nvl(p_leaving_reason, hr_api.g_varchar2) = 'D') then
            open csr_get_pds_details;
            fetch csr_get_pds_details into l_pds_rec;
            close csr_get_pds_details;

             open csr_get_per_rec(l_pds_rec.person_id,l_pds_rec.actual_termination_date);
             loop
	     fetch csr_get_per_rec into l_per_rec;
             exit when csr_get_per_rec%NOTFOUND ;

-- Invoke per_per_upd.upd only to update Date of Death in per_all_people_f ONLY
-- when leaving reason has been set to Deceased and Date of Death has NOT been
-- previously set.

-- per_per_upd.upd updates the Date of Death to Actual Termination Date(ATD)

	     if (l_per_rec.date_of_death is null) then
              hr_utility.set_location('Update PER Details ',920);
		per_per_upd.upd
		(p_person_id		  => l_pds_rec.person_id
		,p_effective_start_date	  => l_per_rec.effective_start_date
	        ,p_effective_end_date	  => l_per_rec.effective_end_date
	        ,p_person_type_id 	  => l_per_rec.person_type_id
		,p_comment_id		  => l_per_rec.comment_id
	        ,p_current_applicant_flag => l_per_rec.current_applicant_flag
		,p_current_emp_or_apl_flag => l_per_rec.current_emp_or_apl_flag
	        ,p_current_employee_flag  => l_per_rec.current_employee_flag
	        ,p_employee_number	  => l_per_rec.employee_number
	        ,p_applicant_number	  => l_per_rec.applicant_number
	        ,p_full_name		  => l_per_rec.full_name
	        ,p_object_version_number  => l_per_rec.object_version_number
	        ,p_effective_date 	  => l_pds_rec.actual_termination_date + 1
	        ,p_datetrack_mode 	  => 'CORRECTION'
	        ,p_date_of_death  	  => l_pds_rec.actual_termination_date
		,p_validate		  => p_validate
	        ,p_name_combination_warning => l_name_combination_warning
	        ,p_dob_null_warning	  => l_dob_null_warning
		,p_orig_hire_warning	  => l_orig_hire_warning
	        ,p_npw_number		  => l_per_rec.npw_number
		);
               end if;
               end loop;
               close csr_get_per_rec;

-- Fix for Bug 5152193 Ends here
           end if;
           --
         END IF;

       end if;

  end if;

  --
  hr_utility.set_location(l_proc, 7);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  --
  -- Start of API User Hook for the after hook of final_process_emp.
  --
  begin
   hr_periods_of_service_bk1.update_pds_details_a
     (p_effective_date                =>  p_effective_date
     ,p_period_of_service_id          =>  p_period_of_service_id
     ,p_object_version_number         =>  p_object_version_number
     ,p_termination_accepted_person   =>  p_termination_accepted_person
     ,p_accepted_termination_date     =>  p_accepted_termination_date
     ,p_comments                      =>  p_comments
     ,p_leaving_reason                =>  p_leaving_reason
     ,p_notified_termination_date     =>  p_notified_termination_date
     ,p_projected_termination_date    =>  p_projected_termination_date
     ,p_actual_termination_date       => p_actual_termination_date
     ,p_last_standard_process_date    => p_last_standard_process_date
     ,p_final_process_date            => p_final_process_date
     ,p_attribute_category            =>  p_attribute_category
     ,p_attribute1                    =>  p_attribute1
     ,p_attribute2                    =>  p_attribute2
     ,p_attribute3                    =>  p_attribute3
     ,p_attribute4                    =>  p_attribute4
     ,p_attribute5                    =>  p_attribute5
     ,p_attribute6                    =>  p_attribute6
     ,p_attribute7                    =>  p_attribute7
     ,p_attribute8                    =>  p_attribute8
     ,p_attribute9                    =>  p_attribute9
     ,p_attribute10                   =>  p_attribute10
     ,p_attribute11                   =>  p_attribute11
     ,p_attribute12                   =>  p_attribute12
     ,p_attribute13                   =>  p_attribute13
     ,p_attribute14                   =>  p_attribute14
     ,p_attribute15                   =>  p_attribute15
     ,p_attribute16                   =>  p_attribute16
     ,p_attribute17                   =>  p_attribute17
     ,p_attribute18                   =>  p_attribute18
     ,p_attribute19                   =>  p_attribute19
     ,p_attribute20                   =>  p_attribute20
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
         (p_module_name       => 'UPDATE_PDS_DETAILS',
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
    ROLLBACK TO update_pds_details;
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
    ROLLBACK TO update_pds_details;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number  := l_ovn;
    raise;
    --
    -- End of fix.
    --
end update_pds_details;
--
-- 115.9 (START)
--
-- ----------------------------------------------------------------------------
-- |--------------------------< MOVE_TERM_ASSIGNMENTS >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:   This procedure keeps assignment children and the TERM_ASSIGN
--                record in sync with any allowable change in FPD. It also
--                validates that the change does not adversely impact any of
--                the child records.
--
-- Prerequisites: None
--
--
-- In Parameters:
--   Name                       Reqd Type     Description
--   P_PERIOD_OF_SERVICE_ID     Yes  NUMBER   PDS Identifier
--   P_OLD_FINAL_PROCESS_DATE   Yes  DATE     Old FPD
--   P_NEW_FINAL_PROCESS_DATE   Yes  DATE     New FPD
--
-- Out Parameters:
--   Name                          Type     Description
--   P_ORG_NOW_NO_MANAGER_WARNING  BOOLEAN  Org now no manager flag
--   P_ASG_FUTURE_CHANGES_WARNING  BOOLEAN  Future Assignment changes flag
--   P_ENTRIES_CHANGED_WARNING     VARCHAR2 Element entries changed flag
--
-- Post Success:
--   The TERM_ASSIGN assignment record and its children will be in sync with
--   the Final Process Date on the Period Of Service associated with that
--   assignment.
--
--   Name                           Type     Description
--   -                              -        -
-- Post Failure:
--   An exception will be raised depending on the nature of failure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
PROCEDURE move_term_assignments
  (p_period_of_service_id   IN NUMBER
  ,p_old_final_process_date IN DATE
  ,p_new_final_process_date IN DATE
--
-- 115.16 (START)
--
  ,p_org_now_no_manager_warning OUT NOCOPY BOOLEAN
  ,p_asg_future_changes_warning OUT NOCOPY BOOLEAN
  ,p_entries_changed_warning    OUT NOCOPY VARCHAR2
--
-- 115.16 (END)
--
  ) IS
  --
  l_proc VARCHAR2(80) := g_package||'move_term_assignments';
  --
  -- Cursor to check for any Payroll actions existing after
  -- the new FPD
  --
  CURSOR csr_compl_pay_act IS
    SELECT NULL
    FROM   pay_payroll_actions ppa
          ,pay_assignment_actions paa
          ,per_assignments_f asg
          ,per_periods_of_service pds
    WHERE pds.period_of_service_id = p_period_of_service_id
    AND   pds.person_id = asg.person_id
    AND   asg.period_of_service_id = pds.period_of_service_id
    AND   asg.assignment_id = paa.assignment_id
    AND   paa.payroll_action_id = ppa.payroll_action_id
    AND   ppa.action_type NOT IN ('X','BEE')
    AND   ppa.effective_date > p_new_final_process_date;
  --
  l_dummy VARCHAR2(1);
  --
  -- Cursor to get all assignments attached to the current
  -- PDS that used to end on the old FPD
  --
  CURSOR csr_pds_asgs IS
    SELECT asg.assignment_id
          ,asg.effective_start_date
          ,asg.effective_end_date
          ,asg.object_version_number
          ,pds.actual_termination_date
    FROM   per_assignments_f asg
          ,per_periods_of_service pds
    WHERE pds.period_of_service_id = p_period_of_service_id
    AND   pds.person_id = asg.person_id
    AND   pds.period_of_service_id = asg.period_of_service_id
    AND   asg.effective_end_date = p_old_final_process_date;
  --
  l_assignment_id              per_assignments_f.assignment_id%TYPE;
  l_object_version_number      per_assignments_f.object_version_number%TYPE;
  l_actual_termination_date    per_periods_of_service.actual_termination_date%TYPE;
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_new_final_process_date     per_periods_of_service.final_process_date%TYPE;

  l_system_status              per_assignment_status_types.per_system_status%TYPE;
  l_assignment_status_type_id  per_all_assignments_f.assignment_status_type_id%TYPE;
  l_rec                        per_all_assignments_f%ROWTYPE;
  l_created_by                 per_all_assignments_f.created_by%TYPE;
  l_creation_date              per_all_assignments_f.creation_date%TYPE;
  l_last_update_date           per_all_assignments_f.last_update_date%TYPE;
  l_last_updated_by            per_all_assignments_f.last_updated_by%TYPE;
  l_last_update_login          per_all_assignments_f.last_update_login%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
--
-- 115.16 (START)
--
  --l_org_now_no_manager_warning BOOLEAN;
  --l_asg_future_changes_warning BOOLEAN;
  --l_entries_changed_warning    VARCHAR2(200);
  --
  -- Get correct ASG OVN
  --
  CURSOR csr_asg_ovn (p_assignment_id  NUMBER
                     ,p_effective_date DATE) IS
    SELECT asg.object_version_number
    FROM   per_assignments_f asg
    WHERE  asg.assignment_id = csr_asg_ovn.p_assignment_id
    AND    csr_asg_ovn.p_effective_date BETWEEN asg.effective_start_date
                                            AND asg.effective_end_date;
--
-- 115.16 (END)
--
  --
  -- Locking ladder cursors
  --
  CURSOR csr_asgs IS
  SELECT NULL
  FROM per_assignments_f asg
      ,per_periods_of_service pds
  WHERE pds.period_of_service_id = p_period_of_service_id
  AND   pds.period_of_service_id = asg.period_of_service_id
  AND   pds.person_id = asg.person_id
  AND   asg.effective_end_date = p_old_final_process_date;
  --
  CURSOR csr_lock_csa (p_assignment_id NUMBER) IS
  SELECT NULL
  FROM   pay_cost_allocations_f csa
  WHERE  csa.assignment_id = csr_lock_csa.p_assignment_id
  FOR    UPDATE NOWAIT;
  --
  CURSOR csr_lock_alu (p_assignment_id NUMBER) IS
  SELECT NULL
  FROM   pay_assignment_link_usages_f alu
  WHERE  alu.assignment_id = csr_lock_alu.p_assignment_id
  FOR    UPDATE NOWAIT;
  --
  CURSOR csr_lock_ele (p_assignment_id NUMBER) IS
  SELECT NULL
  FROM   pay_element_entries_f ele
  WHERE  ele.assignment_id = csr_lock_ele.p_assignment_id
  FOR    UPDATE NOWAIT;
  --
  CURSOR csr_lock_eev (p_assignment_id NUMBER) IS
  SELECT eev.element_entry_id
  FROM   pay_element_entry_values_f eev,
         pay_element_entries_f ele
  WHERE  ele.assignment_id    = p_assignment_id
  AND    eev.element_entry_id = ele.element_entry_id
  FOR    UPDATE NOWAIT;
  --
  CURSOR csr_lock_spp (p_assignment_id NUMBER) IS
  SELECT NULL
  FROM   per_spinal_point_placements_f spp
  WHERE  spp.assignment_id = csr_lock_spp.p_assignment_id
  FOR    UPDATE NOWAIT;
  --
  CURSOR csr_lock_ppm (p_assignment_id NUMBER) IS
  SELECT NULL
  FROM   pay_personal_payment_methods_f ppm
  WHERE  ppm.assignment_id = csr_lock_ppm.p_assignment_id
  FOR    UPDATE NOWAIT;
  --
  CURSOR csr_lock_sas (p_assignment_id NUMBER) IS
  SELECT NULL
  FROM   per_secondary_ass_statuses sas
  WHERE  sas.assignment_id = csr_lock_sas.p_assignment_id
  FOR    UPDATE NOWAIT;
  --
  CURSOR csr_lock_pyp (p_assignment_id NUMBER) IS
  SELECT NULL
  FROM   per_pay_proposals pyp
  WHERE  pyp.assignment_id = csr_lock_pyp.p_assignment_id
  FOR    UPDATE NOWAIT;
  --
  CURSOR csr_lock_asa (p_assignment_id NUMBER) IS
  SELECT asa.assignment_action_id
  FROM   pay_assignment_actions asa
  WHERE  asa.assignment_id = csr_lock_asa.p_assignment_id
  FOR    UPDATE NOWAIT;
  --
  CURSOR csr_lock_abv (p_assignment_id NUMBER) IS
  SELECT assignment_budget_value_id
  FROM   per_assignment_budget_values_f
  WHERE  assignment_id = csr_lock_abv.p_assignment_id
  AND    p_new_final_process_date BETWEEN effective_start_date
                                  AND     effective_end_date
  FOR    UPDATE NOWAIT;
  --

  CURSOR csr_get_ast_status_details(p_assignment_id NUMBER) IS
  SELECT ast.per_system_status
  FROM per_assignment_status_types ast,per_all_assignments_f paaf
  WHERE ast.assignment_status_type_id = paaf.assignment_status_type_id
  AND paaf.assignment_id=p_assignment_id
  AND ast.per_system_status='TERM_ASSIGN'
  AND paaf.effective_end_date=p_old_final_process_date;

  CURSOR assgn_rec (p_assignment_id NUMBER) is
  SELECT * from per_all_assignments_f paaf
  WHERE paaf.assignment_id=p_assignment_id
  AND paaf.effective_end_date=p_old_final_process_date;


BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  hr_utility.set_location('Old FPD:'|| p_old_final_process_date, 6);
  hr_utility.set_location('New FPD:'|| p_new_final_process_date, 7);
  --
  -- Issue a savepoint.
  --
  SAVEPOINT move_term_assignments;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- FPD is changing to an earlier value
  --
  IF p_new_final_process_date IS NOT NULL
  AND p_old_final_process_date IS NOT NULL
  AND p_new_final_process_date < p_old_final_process_date
  THEN
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Check if for any Payroll actions existing after
    -- the new FPD
    --
    OPEN csr_compl_pay_act;
    FETCH csr_compl_pay_act INTO l_dummy;
    IF csr_compl_pay_act%FOUND THEN
      CLOSE csr_compl_pay_act;
      hr_utility.set_message(800,'HR_449742_EMP_FPD_PAYACT');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_compl_pay_act;
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- For all assignments in the current PDS that ended on
    -- the old FPD
    --
    OPEN csr_pds_asgs;
    LOOP
      --
      hr_utility.set_location(l_proc, 40);
      --
      FETCH csr_pds_asgs INTO l_assignment_id
                             ,l_effective_start_date
                             ,l_effective_end_date
                             ,l_object_version_number
                             ,l_actual_termination_date;
      EXIT WHEN csr_pds_asgs%NOTFOUND;
--
-- 115.16 (START)
--
      --
      -- Get the correct assignment ovn in case of future assignment changes
      --
      OPEN csr_asg_ovn(l_assignment_id
                      ,p_new_final_process_date);
      FETCH csr_asg_ovn INTO l_object_version_number;
      CLOSE csr_asg_ovn;
--
-- 115.16 (END)
--
      --
      -- Invoke internal process to validate and then perform the
      -- appropriate updates to effective end date and delete any
      -- rows now starting after the new FPD
      --
      hr_assignment_internal.final_process_emp_asg_sup
        (p_assignment_id              => l_assignment_id
        ,p_object_version_number      => l_object_version_number
        ,p_final_process_date         => p_new_final_process_date
        ,p_actual_termination_date    => l_actual_termination_date
        ,p_effective_start_date       => l_effective_start_date
        ,p_effective_end_date         => l_effective_end_date
        ,p_org_now_no_manager_warning => p_org_now_no_manager_warning
        ,p_asg_future_changes_warning => p_asg_future_changes_warning
        ,p_entries_changed_warning    => p_entries_changed_warning
        );
      --
      hr_utility.set_location(l_proc, 45);
      --
    END LOOP;
    CLOSE csr_pds_asgs;
    --
  END IF; -- new FPD < old FPD
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- FPD is changing to a later value or FPD has been made null
  --
  IF (p_new_final_process_date IS NOT NULL
  AND p_old_final_process_date IS NOT NULL
  AND p_new_final_process_date > p_old_final_process_date)
  OR (p_new_final_process_date IS NULL
  AND p_old_final_process_date IS NOT NULL)
  THEN
    --
    hr_utility.set_location(l_proc, 60);
    --
    IF p_new_final_process_date IS NOT NULL
    AND p_old_final_process_date IS NOT NULL
    AND p_new_final_process_date > p_old_final_process_date
    THEN
      l_new_final_process_date := p_new_final_process_date;
    ELSE
      l_new_final_process_date := hr_api.g_eot;
    END IF;
    --
    -- Lock assignment records
    --
    OPEN csr_asgs;
    CLOSE csr_asgs;
    --
    -- For all assignments in the current PDS that ended on
    -- the old FPD
    --
    OPEN csr_pds_asgs;
    LOOP
      --
      hr_utility.set_location(l_proc, 70);
      --
      FETCH csr_pds_asgs INTO l_assignment_id
                             ,l_effective_start_date
                             ,l_effective_end_date
                             ,l_object_version_number
                             ,l_actual_termination_date;
      EXIT WHEN csr_pds_asgs%NOTFOUND;
      --
      hr_utility.set_location('RowCount:'||SQL%ROWCOUNT, 75);
      --
      OPEN csr_lock_csa(l_assignment_id); -- Locking ladder step 970
      CLOSE csr_lock_csa;
      --
      OPEN csr_lock_alu(l_assignment_id); -- Locking ladder step 1110
      CLOSE csr_lock_alu;
      --
      OPEN csr_lock_asa(l_assignment_id); -- Locking ladder step 1190
      CLOSE csr_lock_asa;
      --
      OPEN csr_lock_ele(l_assignment_id); -- Locking ladder step 1440
      CLOSE csr_lock_ele;
      --
      OPEN csr_lock_eev(l_assignment_id); -- Locking ladder step 1450
      CLOSE csr_lock_eev;
      --
      OPEN csr_lock_spp(l_assignment_id); -- Locking ladder step 1470
      CLOSE csr_lock_spp;
      --
      OPEN csr_lock_ppm(l_assignment_id); -- Locking ladder step 1490
      CLOSE csr_lock_ppm;
      --
      OPEN csr_lock_abv(l_assignment_id); -- Locking ladder step 1550
      CLOSE csr_lock_abv;
      --
      OPEN csr_lock_sas(l_assignment_id); -- Locking ladder step 1590
      CLOSE csr_lock_sas;
      --
      hr_utility.set_location(l_proc, 80);
      --

      OPEN csr_get_ast_status_details(l_assignment_id);
      FETCH csr_get_ast_status_details INTO l_system_status;
      IF csr_get_ast_status_details%FOUND THEN

      hr_utility.set_location(l_proc, 81);

      UPDATE per_assignments_f
      SET effective_end_date = l_new_final_process_date
      WHERE assignment_id = l_assignment_id
      AND effective_start_date = l_effective_start_date
      AND effective_end_date = l_effective_end_date
      AND object_version_number = l_object_version_number;

      else
      hr_utility.set_location(l_proc, 82);

      l_created_by := fnd_global.user_id;
      l_creation_date := sysdate;
      l_last_update_date   := sysdate;
      l_last_updated_by    := fnd_global.user_id;
      l_last_update_login  := fnd_global.login_id;


      OPEN assgn_rec(l_assignment_id);
      FETCH assgn_rec INTO l_rec;
      CLOSE assgn_rec;

      hr_utility.set_location(l_proc, 83);

      SELECT legislation_code INTO l_legislation_code
      FROM per_business_groups
      WHERE business_group_id=l_rec.business_group_id;

      hr_utility.set_location(l_proc, 84);

      per_people3_pkg.get_default_person_type
      (p_required_type     => 'TERM_ASSIGN'
      ,p_business_group_id => l_rec.business_group_id
      ,p_legislation_code  => l_legislation_code
      ,p_person_type       => l_assignment_status_type_id);

      hr_utility.set_location(l_proc, 85);

      INSERT INTO per_all_assignments_f
      ( assignment_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      recruiter_id,
      grade_id,
      position_id,
      job_id,
      assignment_status_type_id,
      payroll_id,
      location_id,
      person_referred_by_id,
      supervisor_id,
      special_ceiling_step_id,
      person_id,
      recruitment_activity_id,
      source_organization_id,
      organization_id,
      people_group_id,
      soft_coding_keyflex_id,
      vacancy_id,
      pay_basis_id,
      assignment_sequence,
      assignment_type,
      primary_flag,
      application_id,
      assignment_number,
      change_reason,
      comment_id,
      date_probation_end,
      default_code_comb_id,
      employment_category,
      frequency,
      internal_address_line,
      manager_flag,
      normal_hours,
      perf_review_period,
      perf_review_period_frequency,
      period_of_service_id,
      probation_period,
      probation_unit,
      sal_review_period,
      sal_review_period_frequency,
      set_of_books_id,
      source_type,
      time_normal_finish,
      time_normal_start,
      bargaining_unit_code,
      labour_union_member_flag,
      hourly_salaried_code,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      ass_attribute_category,
      ass_attribute1,
      ass_attribute2,
      ass_attribute3,
      ass_attribute4,
      ass_attribute5,
      ass_attribute6,
      ass_attribute7,
      ass_attribute8,
      ass_attribute9,
      ass_attribute10,
      ass_attribute11,
      ass_attribute12,
      ass_attribute13,
      ass_attribute14,
      ass_attribute15,
      ass_attribute16,
      ass_attribute17,
      ass_attribute18,
      ass_attribute19,
      ass_attribute20,
      ass_attribute21,
      ass_attribute22,
      ass_attribute23,
      ass_attribute24,
      ass_attribute25,
      ass_attribute26,
      ass_attribute27,
      ass_attribute28,
      ass_attribute29,
      ass_attribute30,
      title,
      contract_id,
      establishment_id,
      collective_agreement_id,
      cagr_grade_def_id,
      cagr_id_flex_num,
      object_version_number,
      created_by,
      creation_date,
      last_update_date,
      last_updated_by,
      last_update_login,
      notice_period,
      notice_period_uom,
      employee_category,
      work_at_home,
      job_post_source_name,
      posting_content_id,
      period_of_placement_date_start,
      vendor_id,
      vendor_employee_number,
      vendor_assignment_number,
      assignment_category,
      project_title,
      applicant_rank,
      grade_ladder_pgm_id,
      supervisor_assignment_id,
      vendor_site_id,
      po_header_id,
      po_line_id,
      projected_assignment_end
      )
     VALUES
     ( l_rec.assignment_id,
     p_old_final_process_date+1,
     l_new_final_process_date,
     l_rec.business_group_id,
     l_rec.recruiter_id,
     l_rec.grade_id,
     l_rec.position_id,
     l_rec.job_id,
     l_assignment_status_type_id,
     l_rec.payroll_id,
     l_rec.location_id,
     l_rec.person_referred_by_id,
     l_rec.supervisor_id,
     l_rec.special_ceiling_step_id,
     l_rec.person_id,
     l_rec.recruitment_activity_id,
     l_rec.source_organization_id,
     l_rec.organization_id,
     l_rec.people_group_id,
     l_rec.soft_coding_keyflex_id,
     l_rec.vacancy_id,
     l_rec.pay_basis_id,
     l_rec.assignment_sequence,
     l_rec.assignment_type,
     l_rec.primary_flag,
     l_rec.application_id,
     l_rec.assignment_number,
     l_rec.change_reason,
     l_rec.comment_id,
     l_rec.date_probation_end,
     l_rec.default_code_comb_id,
     l_rec.employment_category,
     l_rec.frequency,
     l_rec.internal_address_line,
     l_rec.manager_flag,
     l_rec.normal_hours,
     l_rec.perf_review_period,
     l_rec.perf_review_period_frequency,
     l_rec.period_of_service_id,
     l_rec.probation_period,
     l_rec.probation_unit,
     l_rec.sal_review_period,
     l_rec.sal_review_period_frequency,
     l_rec.set_of_books_id,
     l_rec.source_type,
     l_rec.time_normal_finish,
     l_rec.time_normal_start,
     l_rec.bargaining_unit_code,
     l_rec.labour_union_member_flag,
     l_rec.hourly_salaried_code,
     l_rec.request_id,
     l_rec.program_application_id,
     l_rec.program_id,
     l_rec.program_update_date,
     l_rec.ass_attribute_category,
     l_rec.ass_attribute1,
     l_rec.ass_attribute2,
     l_rec.ass_attribute3,
     l_rec.ass_attribute4,
     l_rec.ass_attribute5,
     l_rec.ass_attribute6,
     l_rec.ass_attribute7,
     l_rec.ass_attribute8,
     l_rec.ass_attribute9,
     l_rec.ass_attribute10,
     l_rec.ass_attribute11,
     l_rec.ass_attribute12,
     l_rec.ass_attribute13,
     l_rec.ass_attribute14,
     l_rec.ass_attribute15,
     l_rec.ass_attribute16,
     l_rec.ass_attribute17,
     l_rec.ass_attribute18,
     l_rec.ass_attribute19,
     l_rec.ass_attribute20,
     l_rec.ass_attribute21,
     l_rec.ass_attribute22,
     l_rec.ass_attribute23,
     l_rec.ass_attribute24,
     l_rec.ass_attribute25,
     l_rec.ass_attribute26,
     l_rec.ass_attribute27,
     l_rec.ass_attribute28,
     l_rec.ass_attribute29,
     l_rec.ass_attribute30,
     l_rec.title,
     l_rec.contract_id,
     l_rec.establishment_id,
     l_rec.collective_agreement_id,
     l_rec.cagr_grade_def_id,
     l_rec.cagr_id_flex_num,
     l_rec.object_version_number,
     l_created_by,
     l_creation_date,
     l_last_update_date,
     l_last_updated_by,
     l_last_update_login,
     l_rec.notice_period,
     l_rec.notice_period_uom,
     l_rec.employee_category,
     l_rec.work_at_home,
     l_rec.job_post_source_name,
     l_rec.posting_content_id,
     l_rec.period_of_placement_date_start,
     l_rec.vendor_id,
     l_rec.vendor_employee_number,
     l_rec.vendor_assignment_number,
     l_rec.assignment_category,
     l_rec.project_title,
     l_rec.applicant_rank,
     l_rec.grade_ladder_pgm_id,
     l_rec.supervisor_assignment_id,
     l_rec.vendor_site_id,
     l_rec.po_header_id,
     l_rec.po_line_id,
     l_rec.projected_assignment_end
     );

      hr_utility.set_location(l_proc, 86);

     END IF;

      hr_utility.set_location(l_proc, 87);

     CLOSE  csr_get_ast_status_details;

      hr_utility.set_location(l_proc, 88);
      --
      UPDATE pay_cost_allocations_f
      SET    effective_end_date = l_new_final_process_date
      WHERE  assignment_id = l_assignment_id
      AND    p_old_final_process_date BETWEEN effective_start_date
                                          AND effective_end_date;
      --
      UPDATE per_spinal_point_placements_f
      SET    effective_end_date = l_new_final_process_date
      WHERE  assignment_id = l_assignment_id
      AND    p_old_final_process_date BETWEEN effective_start_date
                                          AND effective_end_date;
      --
      UPDATE per_assignment_budget_values_f
      SET    effective_end_date = l_new_final_process_date
      WHERE  assignment_id = l_assignment_id
      AND    p_old_final_process_date BETWEEN effective_start_date
                                          AND effective_end_date;
      --
      UPDATE pay_assignment_link_usages_f
      SET    effective_end_date = l_new_final_process_date
      WHERE  assignment_id = l_assignment_id
      AND    p_old_final_process_date BETWEEN effective_start_date
                                          AND effective_end_date;
      --
      UPDATE pay_assignment_actions
      SET    end_date = l_new_final_process_date
      WHERE  assignment_id = l_assignment_id
      AND    p_old_final_process_date BETWEEN start_date
                                          AND end_date;
      --
--
-- 115.14 (START)
--
--      UPDATE pay_element_entry_values_f
--      SET    effective_end_date = l_new_final_process_date
--      WHERE  p_old_final_process_date BETWEEN effective_start_date
--                                          AND effective_end_date
--      AND    element_entry_id IN (SELECT element_entry_id
--                                  FROM   pay_element_entries_f
--                                  WHERE  assignment_id = l_assignment_id);
      --
--      UPDATE pay_element_entries_f
--      SET    effective_end_date = l_new_final_process_date
--      WHERE  assignment_id = l_assignment_id
--      AND    p_old_final_process_date BETWEEN effective_start_date
--                                          AND effective_end_date;
--
-- 115.14 (END)
--
-- 115.15 (START)
--
      per_pds_utils.move_elements_with_fpd
        (p_assignment_id          => l_assignment_id
        ,p_periods_of_service_id  => p_period_of_service_id
        ,p_old_final_process_date => p_old_final_process_date
        ,p_new_final_process_date => l_new_final_process_date
        );
--
-- 115.15 (END)
--
      --
      UPDATE pay_personal_payment_methods_f ppm
      SET    effective_end_date = l_new_final_process_date
      WHERE  assignment_id = l_assignment_id
      AND    p_old_final_process_date BETWEEN effective_start_date
                                          AND effective_end_date;
      --
      UPDATE per_secondary_ass_statuses
      SET    end_date = l_new_final_process_date
      WHERE  assignment_id = l_assignment_id
      AND    NVL(end_date,p_old_final_process_date) = p_old_final_process_date;
      --
      hr_utility.set_location(l_proc, 90);
      --
    END LOOP;
    CLOSE csr_pds_asgs;
  END IF; -- new FPD > old FPD
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    -- An unexpected error has occurred
    --
    hr_utility.set_location(l_proc, 9999);
    ROLLBACK TO move_term_assignments;
    RAISE;
    --
END move_term_assignments;
--
-- 115.9 (END)
--
--
end hr_periods_of_service_api;

/
