--------------------------------------------------------
--  DDL for Package Body HR_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPLICANT_API" as
/* $Header: peappapi.pkb 120.18.12010000.13 2009/08/24 15:11:41 sgundoju ship $ */
--
-- Package Variables
--
g_package  constant varchar2(33) := 'hr_applicant_api.';
g_debug    constant boolean      := hr_utility.debug_enabled;
--
-- Package cursor
--
  CURSOR csr_future_asgs
    (p_person_id                    IN     per_all_people_f.person_id%TYPE
    ,p_effective_date               IN     DATE
    )
  IS
    SELECT asg.assignment_id
          ,asg.object_version_number
      FROM per_assignments_f asg
     WHERE asg.person_id             = csr_future_asgs.p_person_id
       AND asg.effective_start_date >= csr_future_asgs.p_effective_date;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< future_asgs_count >----------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   Determines the number of assignments for a person which start on or after
--   a date.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    No   number   Person id
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--   The number of assignments for the person starting on or after a date is
--   returned.
--
-- Post Failure:
--   An error is raised.
--
-- Access Status:
--   Internal Development Use Only
--
-- {End Of Comments}
--
FUNCTION future_asgs_count
  (p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN INTEGER
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'future_asgs_count';
  --
  l_future_asgs_count            INTEGER := 0;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  FOR l_future_asgs_rec IN
  csr_future_asgs
    (p_person_id                    => p_person_id
    ,p_effective_date               => p_effective_date
    )
  LOOP
     l_future_asgs_count := l_future_asgs_count + 1;
  END LOOP;
  --
  hr_utility.set_location(' Leaving:'||l_proc,100);
  --
  RETURN(l_future_asgs_count);
--
EXCEPTION
  WHEN OTHERS
  THEN
    IF csr_future_asgs%ISOPEN
    THEN
      CLOSE csr_future_asgs;
    END IF;
    RAISE;
--
END future_asgs_count;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< create_applicant >---------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_applicant
  (p_validate                     in     boolean  --default false
  ,p_date_received                in     date
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_person_type_id               in     number   --default null
  ,p_applicant_number             in out nocopy varchar2
  ,p_per_comments                 in     varchar2 --default null
  ,p_date_employee_data_verified  in     date     --default null
  ,p_date_of_birth                in     date     --default null
  ,p_email_address                in     varchar2 --default null
  ,p_expense_check_send_to_addres in     varchar2 --default null
  ,p_first_name                   in     varchar2 --default null
  ,p_known_as                     in     varchar2 --default null
  ,p_marital_status               in     varchar2 --default null
  ,p_middle_names                 in     varchar2 --default null
  ,p_nationality                  in     varchar2 --default null
  ,p_national_identifier          in     varchar2 --default null
  ,p_previous_last_name           in     varchar2 --default null
  ,p_registered_disabled_flag     in     varchar2 --default null
  ,p_sex                          in     varchar2 --default null
  ,p_title                        in     varchar2 --default null
  ,p_work_telephone               in     varchar2 --default null
  ,p_attribute_category           in     varchar2 --default null
  ,p_attribute1                   in     varchar2 --default null
  ,p_attribute2                   in     varchar2 --default null
  ,p_attribute3                   in     varchar2 --default null
  ,p_attribute4                   in     varchar2 --default null
  ,p_attribute5                   in     varchar2 --default null
  ,p_attribute6                   in     varchar2 --default null
  ,p_attribute7                   in     varchar2 --default null
  ,p_attribute8                   in     varchar2 --default null
  ,p_attribute9                   in     varchar2 --default null
  ,p_attribute10                  in     varchar2 --default null
  ,p_attribute11                  in     varchar2 --default null
  ,p_attribute12                  in     varchar2 --default null
  ,p_attribute13                  in     varchar2 --default null
  ,p_attribute14                  in     varchar2 --default null
  ,p_attribute15                  in     varchar2 --default null
  ,p_attribute16                  in     varchar2 --default null
  ,p_attribute17                  in     varchar2 --default null
  ,p_attribute18                  in     varchar2 --default null
  ,p_attribute19                  in     varchar2 --default null
  ,p_attribute20                  in     varchar2 --default null
  ,p_attribute21                  in     varchar2 --default null
  ,p_attribute22                  in     varchar2 --default null
  ,p_attribute23                  in     varchar2 --default null
  ,p_attribute24                  in     varchar2 --default null
  ,p_attribute25                  in     varchar2 --default null
  ,p_attribute26                  in     varchar2 --default null
  ,p_attribute27                  in     varchar2 --default null
  ,p_attribute28                  in     varchar2 --default null
  ,p_attribute29                  in     varchar2 --default null
  ,p_attribute30                  in     varchar2 --default null
  ,p_per_information_category     in     varchar2 --default null
  ,p_per_information1             in     varchar2 --default null
  ,p_per_information2             in     varchar2 --default null
  ,p_per_information3             in     varchar2 --default null
  ,p_per_information4             in     varchar2 --default null
  ,p_per_information5             in     varchar2 --default null
  ,p_per_information6             in     varchar2 --default null
  ,p_per_information7             in     varchar2 --default null
  ,p_per_information8             in     varchar2 --default null
  ,p_per_information9             in     varchar2 --default null
  ,p_per_information10            in     varchar2 --default null
  ,p_per_information11            in     varchar2 --default null
  ,p_per_information12            in     varchar2 --default null
  ,p_per_information13            in     varchar2 --default null
  ,p_per_information14            in     varchar2 --default null
  ,p_per_information15            in     varchar2 --default null
  ,p_per_information16            in     varchar2 --default null
  ,p_per_information17            in     varchar2 --default null
  ,p_per_information18            in     varchar2 --default null
  ,p_per_information19            in     varchar2 --default null
  ,p_per_information20            in     varchar2 --default null
  ,p_per_information21            in     varchar2 --default null
  ,p_per_information22            in     varchar2 --default null
  ,p_per_information23            in     varchar2 --default null
  ,p_per_information24            in     varchar2 --default null
  ,p_per_information25            in     varchar2 --default null
  ,p_per_information26            in     varchar2 --default null
  ,p_per_information27            in     varchar2 --default null
  ,p_per_information28            in     varchar2 --default null
  ,p_per_information29            in     varchar2 --default null
  ,p_per_information30            in     varchar2 --default null
  ,p_background_check_status      in     varchar2 --default null
  ,p_background_date_check        in     date     --default null
  ,p_correspondence_language      in     varchar2 --default null
  ,p_fte_capacity                 in     number   --default null
  ,p_hold_applicant_date_until    in     date     --default null
  ,p_honors                       in     varchar2 --default null
  ,p_mailstop                     in     varchar2 --default null
  ,p_office_number                in     varchar2 --default null
  ,p_on_military_service          in     varchar2 --default null
  ,p_pre_name_adjunct             in     varchar2 --default null
  ,p_projected_start_date         in     date     --default null
  ,p_resume_exists                in     varchar2 --default null
  ,p_resume_last_updated          in     date     --default null
  ,p_student_status               in     varchar2 --default null
  ,p_work_schedule                in     varchar2 --default null
  ,p_suffix                       in     varchar2 --default null
  ,p_date_of_death                in     date     --default null
  ,p_benefit_group_id             in     number   --default null
  ,p_receipt_of_death_cert_date   in     date     --default null
  ,p_coord_ben_med_pln_no         in     varchar2 --default null
  ,p_coord_ben_no_cvg_flag        in     varchar2 --default 'N'
  ,p_uses_tobacco_flag            in     varchar2 --default null
  ,p_dpdnt_adoption_date          in     date     --default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2 --default 'N'
  ,p_original_date_of_hire        in     date     --default null
  ,p_town_of_birth                in     varchar2 --default null
  ,p_region_of_birth              in     varchar2 --default null
  ,p_country_of_birth             in     varchar2 --default null
  ,p_global_person_id             in     varchar2 --default null
  ,p_party_id                     in     number   --default null
  ,p_vacancy_id                   in     number  -- Added for bug 3680947.
  ,p_person_id                       out nocopy number
  ,p_assignment_id                   out nocopy number
  ,p_application_id                  out nocopy number
  ,p_per_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_apl_object_version_number       out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_full_name                       out nocopy varchar2
  ,p_per_comment_id                  out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_name_combination_warning        out nocopy boolean
  ,p_orig_hire_warning               out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                        varchar2(72) := g_package||'create_applicant';
  l_date_received               per_applications.date_received%TYPE;
  l_applicant_number            per_all_people_f.applicant_number%TYPE;
  l_date_employee_data_verified per_all_people_f.date_employee_data_verified%TYPE;
  l_date_of_birth               per_all_people_f.date_of_birth%TYPE;
  l_background_date_check       per_all_people_f.background_date_check%TYPE;
  l_hold_applicant_date_until   per_all_people_f.hold_applicant_date_until%TYPE;
  l_projected_start_date        per_all_people_f.projected_start_date%TYPE;
  l_resume_last_updated         per_all_people_f.resume_last_updated%TYPE;
  l_person_id                   per_all_people_f.person_id%TYPE;
  l_assignment_id               per_all_assignments_f.assignment_id%TYPE;
  l_application_id              per_applications.application_id%TYPE;
  l_per_object_version_number   per_all_people_f.object_version_number%TYPE;
  l_asg_object_version_number   per_all_assignments_f.object_version_number%TYPE;
  l_apl_object_version_number   per_applications.object_version_number%TYPE;
  l_per_effective_start_date    per_all_people_f.effective_start_date%TYPE;
  l_per_effective_end_date      per_all_people_f.effective_end_date%TYPE;
  l_full_name                   per_all_people_f.full_name%TYPE;
  l_per_comment_id              per_all_people_f.comment_id%TYPE;
  l_employee_number             per_all_people_f.employee_number%TYPE;
  l_npw_number                  per_all_people_f.npw_number%TYPE;
  l_assignment_sequence         per_all_assignments_f.assignment_sequence%TYPE;
  l_name_combination_warning    boolean;
  l_orig_hire_warning           boolean;
  l_current_applicant_flag      per_all_people_f.current_applicant_flag%TYPE;
  l_current_emp_or_apl_flag     per_all_people_f.current_emp_or_apl_flag%TYPE;
  l_current_employee_flag       per_all_people_f.current_employee_flag%TYPE;
  l_date_of_death               per_all_people_f.date_of_death%TYPE;
  l_receipt_of_death_cert_date  per_all_people_f.receipt_of_death_cert_date%TYPE;
  l_dpdnt_adoption_date         per_all_people_f.dpdnt_adoption_date%TYPE;
  l_original_date_of_hire       per_all_people_f.original_date_of_hire%TYPE;
  l_person_type_id              per_all_people_f.person_type_id%TYPE;
  l_person_type_id1             per_all_people_f.person_type_id%TYPE;
  l_dob_null_warning            boolean;
  l_phn_object_version_number   per_phones.object_version_number%TYPE;
  l_phone_id                    per_phones.phone_id%TYPE;
  --
  --
  lv_applicant_number           varchar2(2000)  := p_applicant_number ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_applicant;
  --
  -- Process Logic
  --
  l_date_received               := trunc(p_date_received);
  l_date_received               := trunc(p_date_received);
  l_date_employee_data_verified := trunc(p_date_employee_data_verified);
  l_date_of_birth               := trunc(p_date_of_birth);
  l_background_date_check       := trunc(p_background_date_check);
  l_hold_applicant_date_until   := trunc(p_hold_applicant_date_until);
  l_projected_start_date        := trunc(p_projected_start_date);
  l_resume_last_updated         := trunc(p_resume_last_updated);
  l_per_effective_start_date    := null;
  l_per_effective_end_date      := null;
  l_person_type_id              := p_person_type_id;
  l_person_type_id1             := hr_person_type_usage_info.get_default_person_type_id
                                        (p_business_group_id,
                                         'APL');
  l_applicant_number            := p_applicant_number;
  l_npw_number                  := null;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Perform Business Process additional validation, if required derive
  -- the person_type_id value.
  --
  per_per_bus.chk_person_type
          (p_person_type_id    => l_person_type_id
          ,p_business_group_id => p_business_group_id
          ,p_expected_sys_type => 'APL');
  --
  --
  -- Call Before Process User Hook for create_applicant
  --
  begin
    hr_applicant_bk1.create_applicant_b
      (
       p_date_received                 => l_date_received
      ,p_business_group_id             => p_business_group_id
      ,p_last_name                     => p_last_name
      ,p_person_type_id                => l_person_type_id
      ,p_applicant_number              => p_applicant_number
      ,p_per_comments                  => p_per_comments
      ,p_date_employee_data_verified   => l_date_employee_data_verified
      ,p_date_of_birth                 => l_date_of_birth
      ,p_email_address                 => p_email_address
      ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
      ,p_first_name                    => p_first_name
      ,p_known_as                      => p_known_as
      ,p_marital_status                => p_marital_status
      ,p_middle_names                  => p_middle_names
      ,p_nationality                   => p_nationality
      ,p_national_identifier           => p_national_identifier
      ,p_previous_last_name            => p_previous_last_name
      ,p_registered_disabled_flag      => p_registered_disabled_flag
      ,p_sex                           => p_sex
      ,p_title                         => p_title
      ,p_work_telephone                => p_work_telephone
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
      ,p_attribute21                   => p_attribute21
      ,p_attribute22                   => p_attribute22
      ,p_attribute23                   => p_attribute23
      ,p_attribute24                   => p_attribute24
      ,p_attribute25                   => p_attribute25
      ,p_attribute26                   => p_attribute26
      ,p_attribute27                   => p_attribute27
      ,p_attribute28                   => p_attribute28
      ,p_attribute29                   => p_attribute29
      ,p_attribute30                   => p_attribute30
      ,p_per_information_category      => p_per_information_category
      ,p_per_information1              => p_per_information1
      ,p_per_information2              => p_per_information2
      ,p_per_information3              => p_per_information3
      ,p_per_information4              => p_per_information4
      ,p_per_information5              => p_per_information5
      ,p_per_information6              => p_per_information6
      ,p_per_information7              => p_per_information7
      ,p_per_information8              => p_per_information8
      ,p_per_information9              => p_per_information9
      ,p_per_information10             => p_per_information10
      ,p_per_information11             => p_per_information11
      ,p_per_information12             => p_per_information12
      ,p_per_information13             => p_per_information13
      ,p_per_information14             => p_per_information14
      ,p_per_information15             => p_per_information15
      ,p_per_information16             => p_per_information16
      ,p_per_information17             => p_per_information17
      ,p_per_information18             => p_per_information18
      ,p_per_information19             => p_per_information19
      ,p_per_information20             => p_per_information20
      ,p_per_information21             => p_per_information21
      ,p_per_information22             => p_per_information22
      ,p_per_information23             => p_per_information23
      ,p_per_information24             => p_per_information24
      ,p_per_information25             => p_per_information25
      ,p_per_information26             => p_per_information26
      ,p_per_information27             => p_per_information27
      ,p_per_information28             => p_per_information28
      ,p_per_information29             => p_per_information29
      ,p_per_information30             => p_per_information30
      ,p_background_check_status       => p_background_check_status
      ,p_background_date_check         => l_background_date_check
      ,p_correspondence_language       => p_correspondence_language
      ,p_fte_capacity                  => p_fte_capacity
      ,p_hold_applicant_date_until     => l_hold_applicant_date_until
      ,p_honors                        => p_honors
      ,p_mailstop                      => p_mailstop
      ,p_office_number                 => p_office_number
      ,p_on_military_service           => p_on_military_service
      ,p_pre_name_adjunct              => p_pre_name_adjunct
      ,p_projected_start_date          => l_projected_start_date
      ,p_resume_exists                 => p_resume_exists
      ,p_resume_last_updated           => l_resume_last_updated
      ,p_student_status                => p_student_status
      ,p_work_schedule                 => p_work_schedule
      ,p_suffix                        => p_suffix
      ,p_date_of_death                 => l_date_of_death
      ,p_benefit_group_id              => p_benefit_group_id
      ,p_receipt_of_death_cert_date    => l_receipt_of_death_cert_date
      ,p_coord_ben_med_pln_no          => p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
      ,p_uses_tobacco_flag             => p_uses_tobacco_flag
      ,p_dpdnt_adoption_date           => l_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag        => p_dpdnt_vlntry_svce_flag
      ,p_original_date_of_hire         => l_original_date_of_hire
         ,p_town_of_birth                 => p_town_of_birth
         ,p_region_of_birth               => p_region_of_birth
         ,p_country_of_birth              => p_country_of_birth
         ,p_global_person_id              => p_global_person_id
         ,p_party_id                      => p_party_id
         ,p_vacancy_id                    => p_vacancy_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_APPLICANT'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of API User Hook for the before hook of create_applicant
  --
  end;
  --
  -- Insert the person using the person RH...
  --
  per_per_ins.ins
              (p_person_id                    => l_person_id
              ,p_effective_start_date         => l_per_effective_start_date
              ,p_effective_end_date           => l_per_effective_end_date
              ,p_business_group_id            => p_business_group_id
              ,p_person_type_id               => l_person_type_id1
              ,p_last_name                    => p_last_name
              ,p_start_date                   => l_date_received
              ,p_applicant_number             => l_applicant_number
              ,p_comment_id                   => l_per_comment_id
              ,p_comments                     => p_per_comments
              ,p_current_applicant_flag       => l_current_applicant_flag
              ,p_current_emp_or_apl_flag      => l_current_emp_or_apl_flag
              ,p_current_employee_flag        => l_current_employee_flag
              ,p_date_employee_data_verified  => l_date_employee_data_verified
              ,p_date_of_birth                => l_date_of_birth
              ,p_email_address                => p_email_address
              ,p_employee_number              => l_employee_number
              ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
              ,p_first_name                   => p_first_name
              ,p_full_name                    => p_full_name
              ,p_known_as                     => p_known_as
              ,p_marital_status               => p_marital_status
              ,p_middle_names                 => p_middle_names
              ,p_nationality                  => p_nationality
              ,p_national_identifier          => p_national_identifier
              ,p_previous_last_name           => p_previous_last_name
              ,p_registered_disabled_flag     => p_registered_disabled_flag
              ,p_sex                          => p_sex
              ,p_title                        => p_title
 --           ,p_work_telephone               => p_work_telephone -- Handled by Create_phone
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
              ,p_attribute21                  => p_attribute21
              ,p_attribute22                  => p_attribute22
              ,p_attribute23                  => p_attribute23
              ,p_attribute24                  => p_attribute24
              ,p_attribute25                  => p_attribute25
              ,p_attribute26                  => p_attribute26
              ,p_attribute27                  => p_attribute27
              ,p_attribute28                  => p_attribute28
              ,p_attribute29                  => p_attribute29
              ,p_attribute30                  => p_attribute30
              ,p_per_information_category     => p_per_information_category
              ,p_per_information1             => p_per_information1
              ,p_per_information2             => p_per_information2
              ,p_per_information3             => p_per_information3
              ,p_per_information4             => p_per_information4
              ,p_per_information5             => p_per_information5
              ,p_per_information6             => p_per_information6
              ,p_per_information7             => p_per_information7
              ,p_per_information8             => p_per_information8
              ,p_per_information9             => p_per_information9
              ,p_per_information10            => p_per_information10
              ,p_per_information11            => p_per_information11
              ,p_per_information12            => p_per_information12
              ,p_per_information13            => p_per_information13
              ,p_per_information14            => p_per_information14
              ,p_per_information15            => p_per_information15
              ,p_per_information16            => p_per_information16
              ,p_per_information17            => p_per_information17
              ,p_per_information18            => p_per_information18
              ,p_per_information19            => p_per_information19
              ,p_per_information20            => p_per_information20
              ,p_per_information21            => p_per_information21
              ,p_per_information22            => p_per_information22
              ,p_per_information23            => p_per_information23
              ,p_per_information24            => p_per_information24
              ,p_per_information25            => p_per_information25
              ,p_per_information26            => p_per_information26
              ,p_per_information27            => p_per_information27
              ,p_per_information28            => p_per_information28
              ,p_per_information29            => p_per_information29
              ,p_per_information30            => p_per_information30
              ,p_background_check_status      => p_background_check_status
              ,p_background_date_check        => l_background_date_check
              ,p_correspondence_language      => p_correspondence_language
              ,p_fte_capacity                 => p_fte_capacity
              ,p_hold_applicant_date_until    => l_hold_applicant_date_until
              ,p_honors                       => p_honors
              ,p_mailstop                     => p_mailstop
              ,p_office_number                => p_office_number
              ,p_on_military_service          => p_on_military_service
              ,p_pre_name_adjunct             => p_pre_name_adjunct
              ,p_projected_start_date         => l_projected_start_date
              ,p_resume_exists                => p_resume_exists
              ,p_resume_last_updated          => l_resume_last_updated
              ,p_student_status               => p_student_status
              ,p_work_schedule                => p_work_schedule
              ,p_suffix                       => p_suffix
              ,p_date_of_death                => l_date_of_death
              ,p_benefit_group_id             => p_benefit_group_id
              ,p_receipt_of_death_cert_date   => l_receipt_of_death_cert_date
              ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
              ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
              ,p_uses_tobacco_flag            => p_uses_tobacco_flag
              ,p_dpdnt_adoption_date          => l_dpdnt_adoption_date
              ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
              ,p_original_date_of_hire        => p_original_date_of_hire
                 ,p_town_of_birth                => p_town_of_birth
                 ,p_region_of_birth              => p_region_of_birth
                 ,p_country_of_birth             => p_country_of_birth
                 ,p_global_person_id             => p_global_person_id
                 ,p_party_id                     => p_party_id
              ,p_npw_number                   => l_npw_number
              ,p_object_version_number        => p_per_object_version_number
              ,p_effective_date               => l_date_received
              ,p_name_combination_warning     => l_name_combination_warning
              ,p_dob_null_warning             => l_dob_null_warning
              ,p_orig_hire_warning            => l_orig_hire_warning
              );
  hr_utility.set_location(l_proc, 20);
  --
  -- add the new applicant to the security lists
  --
  hr_security_internal.populate_new_person(p_business_group_id,l_person_id);
  --
  hr_utility.set_location(l_proc, 25);
  --
  -- Insert the application using the application RH...
  --
  per_apl_ins.ins(p_application_id        => l_application_id
                 ,p_business_group_id     => p_business_group_id
                 ,p_person_id             => l_person_id
                 ,p_date_received         => l_date_received
                 ,p_object_version_number => p_apl_object_version_number
                 ,p_effective_date        => l_date_received
                 ,p_validate              => FALSE
                 );
  hr_utility.set_location(l_proc, 30);
  --
  -- Insert the default applicant assignment using the business support layer
  -- process create_default_apl_asg.
  --
-- PTU : Following Code has been added

hr_per_type_usage_internal.maintain_person_type_usage
(p_effective_date       => l_date_received
,p_person_id            => l_person_id
,p_person_type_id       => l_person_type_id
);

-- PTU : End of changes


  hr_assignment_internal.create_default_apl_asg
                 (p_effective_date        => l_date_received
                 ,p_person_id             => l_person_id
                 ,p_business_group_id     => p_business_group_id
                 ,p_application_id        => l_application_id
                 ,p_vacancy_id            => p_vacancy_id -- Passed for bug 3680947.
                 ,p_assignment_id         => l_assignment_id
                 ,p_object_version_number => l_asg_object_version_number
                 ,p_assignment_sequence   => l_assignment_sequence
                 );
  hr_utility.set_location(l_proc, 40);
  --
  -- Create a phone row using the newly created person as the parent row.
  -- This phone row replaces the work_telephone column on the person.
  --
  if p_work_telephone is not null then
     hr_phone_api.create_phone
       (p_date_from                 => l_date_received
       ,p_date_to                   => null
       ,p_phone_type                => 'W1'
       ,p_phone_number              => p_work_telephone
       ,p_parent_id                 => l_person_id
       ,p_parent_table              => 'PER_ALL_PEOPLE_F'
       ,p_validate                  => FALSE
       ,p_effective_date            => l_date_received
       ,p_object_version_number     => l_phn_object_version_number  --out
       ,p_phone_id                  => l_phone_id                   --out
       );
  end if;
  --
  -- Call After Process User Hook create_applicant
  --
  begin
    hr_applicant_bk1.create_applicant_a
      (
       p_date_received                 => l_date_received
      ,p_business_group_id             => p_business_group_id
      ,p_last_name                     => p_last_name
      ,p_person_type_id                => l_person_type_id
      ,p_applicant_number              => p_applicant_number
      ,p_per_comments                  => p_per_comments
      ,p_date_employee_data_verified   => l_date_employee_data_verified
      ,p_date_of_birth                 => l_date_of_birth
      ,p_email_address                 => p_email_address
      ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
      ,p_first_name                    => p_first_name
      ,p_known_as                      => p_known_as
      ,p_marital_status                => p_marital_status
      ,p_middle_names                  => p_middle_names
      ,p_nationality                   => p_nationality
      ,p_national_identifier           => p_national_identifier
      ,p_previous_last_name            => p_previous_last_name
      ,p_registered_disabled_flag      => p_registered_disabled_flag
      ,p_sex                           => p_sex
      ,p_title                         => p_title
      ,p_work_telephone                => p_work_telephone
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
      ,p_attribute21                   => p_attribute21
      ,p_attribute22                   => p_attribute22
      ,p_attribute23                   => p_attribute23
      ,p_attribute24                   => p_attribute24
      ,p_attribute25                   => p_attribute25
      ,p_attribute26                   => p_attribute26
      ,p_attribute27                   => p_attribute27
      ,p_attribute28                   => p_attribute28
      ,p_attribute29                   => p_attribute29
      ,p_attribute30                   => p_attribute30
      ,p_per_information_category      => p_per_information_category
      ,p_per_information1              => p_per_information1
      ,p_per_information2              => p_per_information2
      ,p_per_information3              => p_per_information3
      ,p_per_information4              => p_per_information4
      ,p_per_information5              => p_per_information5
      ,p_per_information6              => p_per_information6
      ,p_per_information7              => p_per_information7
      ,p_per_information8              => p_per_information8
      ,p_per_information9              => p_per_information9
      ,p_per_information10             => p_per_information10
      ,p_per_information11             => p_per_information11
      ,p_per_information12             => p_per_information12
      ,p_per_information13             => p_per_information13
      ,p_per_information14             => p_per_information14
      ,p_per_information15             => p_per_information15
      ,p_per_information16             => p_per_information16
      ,p_per_information17             => p_per_information17
      ,p_per_information18             => p_per_information18
      ,p_per_information19             => p_per_information19
      ,p_per_information20             => p_per_information20
      ,p_per_information21             => p_per_information21
      ,p_per_information22             => p_per_information22
      ,p_per_information23             => p_per_information23
      ,p_per_information24             => p_per_information24
      ,p_per_information25             => p_per_information25
      ,p_per_information26             => p_per_information26
      ,p_per_information27             => p_per_information27
      ,p_per_information28             => p_per_information28
      ,p_per_information29             => p_per_information29
      ,p_per_information30             => p_per_information30
      ,p_background_check_status       => p_background_check_status
      ,p_background_date_check         => l_background_date_check
      ,p_correspondence_language       => p_correspondence_language
      ,p_fte_capacity                  => p_fte_capacity
      ,p_hold_applicant_date_until     => l_hold_applicant_date_until
      ,p_honors                        => p_honors
      ,p_mailstop                      => p_mailstop
      ,p_office_number                 => p_office_number
      ,p_on_military_service           => p_on_military_service
      ,p_pre_name_adjunct              => p_pre_name_adjunct
      ,p_projected_start_date          => l_projected_start_date
      ,p_resume_exists                 => p_resume_exists
      ,p_resume_last_updated           => l_resume_last_updated
      ,p_student_status                => p_student_status
      ,p_work_schedule                 => p_work_schedule
      ,p_suffix                        => p_suffix
      ,p_date_of_death                 => l_date_of_death
      ,p_benefit_group_id              => p_benefit_group_id
      ,p_receipt_of_death_cert_date    => l_receipt_of_death_cert_date
      ,p_coord_ben_med_pln_no          => p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
      ,p_uses_tobacco_flag             => p_uses_tobacco_flag
      ,p_dpdnt_adoption_date           => l_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag        => p_dpdnt_vlntry_svce_flag
      ,p_original_date_of_hire         => l_original_date_of_hire
         ,p_town_of_birth                 => p_town_of_birth
         ,p_region_of_birth               => p_region_of_birth
         ,p_country_of_birth              => p_country_of_birth
         ,p_global_person_id              => p_global_person_id
         ,p_party_id                      => p_party_id
         ,p_vacancy_id                    => p_vacancy_id
      ,p_person_id                     => l_person_id
      ,p_assignment_id                 => l_assignment_id
      ,p_application_id                => l_application_id
      ,p_per_object_version_number     => l_per_object_version_number
      ,p_asg_object_version_number     => l_asg_object_version_number
      ,p_apl_object_version_number     => l_apl_object_version_number
      ,p_per_effective_start_date      => l_per_effective_start_date
      ,p_per_effective_end_date        => l_per_effective_end_date
      ,p_full_name                     => l_full_name
      ,p_per_comment_id                => l_per_comment_id
      ,p_assignment_sequence           => l_assignment_sequence
      ,p_name_combination_warning      => l_name_combination_warning
      ,p_orig_hire_warning             => l_orig_hire_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_APPLICANT'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of after hook for create_applicant
  --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set OUT parameters
  --

--
-- Start of fix for bug 3062967
--
  SELECT object_version_number
        INTO p_per_object_Version_number
        FROM per_all_people_f
        WHERE person_id = l_person_id
        And effective_start_Date = l_per_effective_start_date
        and effective_end_Date = l_per_effective_end_date;
--
-- Start of fix for bug 3062967
--

  p_person_id                       := l_person_id ;
  p_assignment_id                   := l_assignment_id ;
  p_application_id                  := l_application_id ;
  p_asg_object_version_number       := l_asg_object_version_number;
  p_per_effective_start_date        := l_per_effective_start_date ;
  p_per_effective_end_date          := l_per_effective_end_date ;
  p_per_comment_id                  := l_per_comment_id ;
  p_assignment_sequence             := l_assignment_sequence ;
  p_name_combination_warning        := l_name_combination_warning;
  p_orig_hire_warning               := l_orig_hire_warning;
  -- Added for Bug 1275358
  p_applicant_number                := l_applicant_number;

  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_applicant;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_person_id                       := null;
    p_assignment_id                   := null;
    p_application_id                  := null;
    p_applicant_number                := null;
    p_per_object_version_number       := null;
    p_asg_object_version_number       := null;
    p_apl_object_version_number       := null;
    p_per_effective_start_date        := null;
    p_per_effective_end_date          := null;
    p_full_name                       := null;
    p_per_comment_id                  := null;
    p_assignment_sequence             := null;
    p_name_combination_warning        := l_name_combination_warning;
    p_orig_hire_warning               := l_orig_hire_warning;

    --
    hr_utility.set_location(' Leaving:'||l_proc, 35);
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO create_applicant;

    p_person_id                       := null;
    p_assignment_id                   := null;
    p_application_id                  := null;
    p_per_object_version_number       := null;
    p_asg_object_version_number       := null;
    p_apl_object_version_number       := null;
    p_per_effective_start_date        := null;
    p_per_effective_end_date          := null;
    p_full_name                       := null;
    p_per_comment_id                  := null;
    p_assignment_sequence             := null;
    p_name_combination_warning        := l_name_combination_warning;
    p_orig_hire_warning               := l_orig_hire_warning;

    p_applicant_number                := lv_applicant_number;

    raise;
    --
    -- End of fix.
    --
end create_applicant;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_gb_applicant >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_gb_applicant
  (p_validate                      in     boolean  --default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2 --default null
  ,p_person_type_id                in     number   --default null
  ,p_applicant_number              in out nocopy varchar2
  ,p_comments                      in     varchar2 --default null
  ,p_date_employee_data_verified   in     date     --default null
  ,p_date_of_birth                 in     date     --default null
  ,p_email_address                 in     varchar2 --default null
  ,p_expense_check_send_to_addres  in     varchar2 --default null
  ,p_first_name                    in     varchar2 --default null
  ,p_known_as                      in     varchar2 --default null
  ,p_marital_status                in     varchar2 --default null
  ,p_middle_names                  in     varchar2 --default null
  ,p_nationality                   in     varchar2 --default null
  ,p_ni_number                     in     varchar2 --default null
  ,p_previous_last_name            in     varchar2 --default null
  ,p_registered_disabled_flag      in     varchar2 --default null
  ,p_title                         in     varchar2 --default null
  ,p_work_telephone                in     varchar2 --default null
  ,p_attribute_category            in     varchar2 --default null
  ,p_attribute1                    in     varchar2 --default null
  ,p_attribute2                    in     varchar2 --default null
  ,p_attribute3                    in     varchar2 --default null
  ,p_attribute4                    in     varchar2 --default null
  ,p_attribute5                    in     varchar2 --default null
  ,p_attribute6                    in     varchar2 --default null
  ,p_attribute7                    in     varchar2 --default null
  ,p_attribute8                    in     varchar2 --default null
  ,p_attribute9                    in     varchar2 --default null
  ,p_attribute10                   in     varchar2 --default null
  ,p_attribute11                   in     varchar2 --default null
  ,p_attribute12                   in     varchar2 --default null
  ,p_attribute13                   in     varchar2 --default null
  ,p_attribute14                   in     varchar2 --default null
  ,p_attribute15                   in     varchar2 --default null
  ,p_attribute16                   in     varchar2 --default null
  ,p_attribute17                   in     varchar2 --default null
  ,p_attribute18                   in     varchar2 --default null
  ,p_attribute19                   in     varchar2 --default null
  ,p_attribute20                   in     varchar2 --default null
  ,p_attribute21                   in     varchar2 --default null
  ,p_attribute22                   in     varchar2 --default null
  ,p_attribute23                   in     varchar2 --default null
  ,p_attribute24                   in     varchar2 --default null
  ,p_attribute25                   in     varchar2 --default null
  ,p_attribute26                   in     varchar2 --default null
  ,p_attribute27                   in     varchar2 --default null
  ,p_attribute28                   in     varchar2 --default null
  ,p_attribute29                   in     varchar2 --default null
  ,p_attribute30                   in     varchar2 --default null
  ,p_ethnic_origin                 in     varchar2 --default null
  ,p_director                      in     varchar2 --default 'N'
  ,p_pensioner                     in     varchar2 --default 'N'
  ,p_work_permit_number            in     varchar2 --default null
  ,p_addl_pension_years            in     varchar2 --default null
  ,p_addl_pension_months           in     varchar2 --default null
  ,p_addl_pension_days             in     varchar2 --default null
  ,p_ni_multiple_asg               in     varchar2 --default null
  ,p_background_check_status       in     varchar2 --default null
  ,p_background_date_check         in     date     --default null
  ,p_correspondence_language       in     varchar2 --default null
  ,p_fte_capacity                  in     number   --default null
  ,p_hold_applicant_date_until     in     date     --default null
  ,p_honors                        in     varchar2 --default null
  ,p_mailstop                      in     varchar2 --default null
  ,p_office_number                 in     varchar2 --default null
  ,p_on_military_service           in     varchar2 --default null
  ,p_pre_name_adjunct              in     varchar2 --default null
  ,p_projected_start_date          in     date     --default null
  ,p_resume_exists                 in     varchar2 --default null
  ,p_resume_last_updated           in     date     --default null
  ,p_student_status                in     varchar2 --default null
  ,p_work_schedule                 in     varchar2 --default null
  ,p_suffix                        in     varchar2 --default null
  ,p_date_of_death                in     date     --default null
  ,p_benefit_group_id             in     number   --default null
  ,p_receipt_of_death_cert_date   in     date     --default null
  ,p_coord_ben_med_pln_no         in     varchar2 --default null
  ,p_coord_ben_no_cvg_flag        in     varchar2 --default 'N'
  ,p_uses_tobacco_flag            in     varchar2 --default null
  ,p_dpdnt_adoption_date          in     date     --default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2 --default 'N'
  ,p_original_date_of_hire        in     date     --default null
  ,p_town_of_birth                in     varchar2 --default null
  ,p_region_of_birth              in     varchar2 --default null
  ,p_country_of_birth             in     varchar2 --default null
  ,p_global_person_id             in     varchar2 --default null
  ,p_party_id                     in     number --default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_application_id                   out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'create_gb_applicant';
  l_legislation_code     varchar2(30);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Validation in addition to Table Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  --
  -- Call the person business process
  --
  hr_applicant_api.create_applicant
  (p_validate                     => p_validate
  ,p_date_received                => p_date_received
  ,p_business_group_id            => p_business_group_id
  ,p_last_name                    => p_last_name
  ,p_sex                          => p_sex
  ,p_person_type_id               => p_person_type_id
  ,p_per_comments                 => p_comments
  ,p_date_employee_data_verified  => p_date_employee_data_verified
  ,p_date_of_birth                => p_date_of_birth
  ,p_email_address                => p_email_address
  ,p_applicant_number             => p_applicant_number
  ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
  ,p_first_name                   => p_first_name
  ,p_known_as                     => p_known_as
  ,p_marital_status               => p_marital_status
  ,p_middle_names                 => p_middle_names
  ,p_nationality                  => p_nationality
  ,p_national_identifier          => p_ni_number
  ,p_previous_last_name           => p_previous_last_name
  ,p_registered_disabled_flag     => p_registered_disabled_flag
  ,p_title                        => p_title
  ,p_work_telephone               => p_work_telephone
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
  ,p_attribute21                  => p_attribute21
  ,p_attribute22                  => p_attribute22
  ,p_attribute23                  => p_attribute23
  ,p_attribute24                  => p_attribute24
  ,p_attribute25                  => p_attribute25
  ,p_attribute26                  => p_attribute26
  ,p_attribute27                  => p_attribute27
  ,p_attribute28                  => p_attribute28
  ,p_attribute29                  => p_attribute29
  ,p_attribute30                  => p_attribute30
  ,p_per_information_category     => 'GB'
  ,p_per_information1             => p_ethnic_origin
  ,p_per_information2             => p_director
  ,p_per_information4             => p_pensioner
  ,p_per_information5             => p_work_permit_number
  ,p_per_information6             => p_addl_pension_years
  ,p_per_information7             => p_addl_pension_months
  ,p_per_information8             => p_addl_pension_days
  ,p_per_information9             => p_ni_multiple_asg
  ,p_background_check_status      => p_background_check_status
  ,p_background_date_check        => p_background_date_check
  ,p_correspondence_language      => p_correspondence_language
  ,p_fte_capacity                 => p_fte_capacity
  ,p_hold_applicant_date_until    => p_hold_applicant_date_until
  ,p_honors                       => p_honors
  ,p_mailstop                     => p_mailstop
  ,p_office_number                => p_office_number
  ,p_on_military_service          => p_on_military_service
  ,p_pre_name_adjunct             => p_pre_name_adjunct
  ,p_projected_start_date         => p_projected_start_date
  ,p_resume_exists                => p_resume_exists
  ,p_resume_last_updated          => p_resume_last_updated
  ,p_student_status               => p_student_status
  ,p_work_schedule                => p_work_schedule
  ,p_suffix                       => p_suffix
  ,p_date_of_death                => p_date_of_death
  ,p_benefit_group_id             => p_benefit_group_id
  ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
  ,p_uses_tobacco_flag            => p_uses_tobacco_flag
  ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire        => p_original_date_of_hire
  ,p_town_of_birth                 => p_town_of_birth
  ,p_region_of_birth               => p_region_of_birth
  ,p_country_of_birth              => p_country_of_birth
  ,p_global_person_id              => p_global_person_id
  ,p_party_id                      => p_party_id
  --
  ,p_person_id                    => p_person_id
  ,p_assignment_id                => p_assignment_id
  ,p_application_id               => p_application_id
  ,p_per_object_version_number    => p_per_object_version_number
  ,p_asg_object_version_number    => p_asg_object_version_number
  ,p_apl_object_version_number    => p_apl_object_version_number
  ,p_per_effective_start_date     => p_per_effective_start_date
  ,p_per_effective_end_date       => p_per_effective_end_date
  ,p_full_name                    => p_full_name
  ,p_per_comment_id               => p_per_comment_id
  ,p_assignment_sequence          => p_assignment_sequence
  ,p_name_combination_warning     => p_name_combination_warning
  ,p_orig_hire_warning            => p_orig_hire_warning
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
end create_gb_applicant;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_us_applicant >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_us_applicant
  (p_validate                      in     boolean  --default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2 --default null
  ,p_person_type_id                in     number   --default null
  ,p_applicant_number              in out nocopy varchar2
  ,p_comments                      in     varchar2 --default null
  ,p_date_employee_data_verified   in     date     --default null
  ,p_date_of_birth                 in     date     --default null
  ,p_email_address                 in     varchar2 --default null
  ,p_expense_check_send_to_addres  in     varchar2 --default null
  ,p_first_name                    in     varchar2 --default null
  ,p_known_as                      in     varchar2 --default null
  ,p_marital_status                in     varchar2 --default null
  ,p_middle_names                  in     varchar2 --default null
  ,p_nationality                   in     varchar2 --default null
  ,p_ss_number                     in     varchar2 --default null
  ,p_previous_last_name            in     varchar2 --default null
  ,p_registered_disabled_flag      in     varchar2 --default null
  ,p_title                         in     varchar2 --default null
  ,p_work_telephone                in     varchar2 --default null
  ,p_attribute_category            in     varchar2 --default null
  ,p_attribute1                    in     varchar2 --default null
  ,p_attribute2                    in     varchar2 --default null
  ,p_attribute3                    in     varchar2 --default null
  ,p_attribute4                    in     varchar2 --default null
  ,p_attribute5                    in     varchar2 --default null
  ,p_attribute6                    in     varchar2 --default null
  ,p_attribute7                    in     varchar2 --default null
  ,p_attribute8                    in     varchar2 --default null
  ,p_attribute9                    in     varchar2 --default null
  ,p_attribute10                   in     varchar2 --default null
  ,p_attribute11                   in     varchar2 --default null
  ,p_attribute12                   in     varchar2 --default null
  ,p_attribute13                   in     varchar2 --default null
  ,p_attribute14                   in     varchar2 --default null
  ,p_attribute15                   in     varchar2 --default null
  ,p_attribute16                   in     varchar2 --default null
  ,p_attribute17                   in     varchar2 --default null
  ,p_attribute18                   in     varchar2 --default null
  ,p_attribute19                   in     varchar2 --default null
  ,p_attribute20                   in     varchar2 --default null
  ,p_attribute21                   in     varchar2 --default null
  ,p_attribute22                   in     varchar2 --default null
  ,p_attribute23                   in     varchar2 --default null
  ,p_attribute24                   in     varchar2 --default null
  ,p_attribute25                   in     varchar2 --default null
  ,p_attribute26                   in     varchar2 --default null
  ,p_attribute27                   in     varchar2 --default null
  ,p_attribute28                   in     varchar2 --default null
  ,p_attribute29                   in     varchar2 --default null
  ,p_attribute30                   in     varchar2 --default null
  ,p_ethnic_origin                 in     varchar2 --default null
  ,p_I_9                           in     varchar2 --default 'N'
  ,p_I_9_expiration_date           in     varchar2 --default null
--  ,p_visa_type                     in     varchar2 --default null
  ,p_veteran_status                in     varchar2 --default null
  ,p_new_hire                      in     varchar2 --default null
  ,p_exception_reason              in     varchar2 --default null
  ,p_child_support_obligation      in     varchar2 --default 'N'
  ,p_opted_for_medicare_flag       in     varchar2 --default 'N'
  ,p_background_check_status       in     varchar2 --default null
  ,p_background_date_check         in     date     --default null
  ,p_correspondence_language       in     varchar2 --default null
  ,p_fte_capacity                  in     number   --default null
  ,p_hold_applicant_date_until     in     date     --default null
  ,p_honors                        in     varchar2 --default null
  ,p_mailstop                      in     varchar2 --default null
  ,p_office_number                 in     varchar2 --default null
  ,p_on_military_service           in     varchar2 --default null
  ,p_pre_name_adjunct              in     varchar2 --default null
  ,p_projected_start_date          in     date     --default null
  ,p_resume_exists                 in     varchar2 --default null
  ,p_resume_last_updated           in     date     --default null
  ,p_student_status                in     varchar2 --default null
  ,p_work_schedule                 in     varchar2 --default null
  ,p_suffix                        in     varchar2 --default null
  ,p_date_of_death                in     date     --default null
  ,p_benefit_group_id             in     number   --default null
  ,p_receipt_of_death_cert_date   in     date     --default null
  ,p_coord_ben_med_pln_no         in     varchar2 --default null
  ,p_coord_ben_no_cvg_flag        in     varchar2 --default 'N'
  ,p_uses_tobacco_flag            in     varchar2 --default null
  ,p_dpdnt_adoption_date          in     date     --default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2 --default 'N'
  ,p_original_date_of_hire        in     date     --default null
  ,p_town_of_birth                in     varchar2 --default null
  ,p_region_of_birth              in     varchar2 --default null
  ,p_country_of_birth             in     varchar2 --default null
  ,p_global_person_id             in     varchar2 --default null
  ,p_party_id                     in     number --default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_application_id                   out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  )
is

l_vets100A varchar2(100);
  --
  -- Declare cursors and local variables
  --
/*  l_proc                 varchar2(72) := g_package||'create_us_applicant';
  l_legislation_code     varchar2(30);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
    */
  --
begin
  /* hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Validation in addition to Table Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'US'.
  --
  if l_legislation_code <> 'US' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','US');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  */
  --
  -- Call the person business process
  --
  hr_applicant_api.create_us_applicant
  (p_validate                     => p_validate
  ,p_date_received                => p_date_received
  ,p_business_group_id            => p_business_group_id
  ,p_last_name                    => p_last_name
  ,p_sex                          => p_sex
  ,p_person_type_id               => p_person_type_id
  ,p_applicant_number              => p_applicant_number
  ,p_comments                 => p_comments
  ,p_date_employee_data_verified  => p_date_employee_data_verified
  ,p_date_of_birth                => p_date_of_birth
  ,p_email_address                => p_email_address
  ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
  ,p_first_name                   => p_first_name
  ,p_known_as                     => p_known_as
  ,p_marital_status               => p_marital_status
  ,p_middle_names                 => p_middle_names
  ,p_nationality                  => p_nationality
  ,p_ss_number          => p_ss_number
  ,p_previous_last_name           => p_previous_last_name
  ,p_registered_disabled_flag     => p_registered_disabled_flag
  ,p_title                        => p_title
  ,p_work_telephone               => p_work_telephone
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
  ,p_attribute21                  => p_attribute21
  ,p_attribute22                  => p_attribute22
  ,p_attribute23                  => p_attribute23
  ,p_attribute24                  => p_attribute24
  ,p_attribute25                  => p_attribute25
  ,p_attribute26                  => p_attribute26
  ,p_attribute27                  => p_attribute27
  ,p_attribute28                  => p_attribute28
  ,p_attribute29                  => p_attribute29
  ,p_attribute30                  => p_attribute30
--  ,p_per_information_category     => 'US'
  ,p_ethnic_origin             => p_ethnic_origin
  ,p_i_9             => p_i_9
  ,p_i_9_expiration_date             => p_i_9_expiration_date
--  ,p_visa_type             => p_visa_type
  ,p_veteran_status             => p_veteran_status
  ,p_vets100A             => l_vets100A
  ,p_new_hire             => p_new_hire
  ,p_exception_reason             => p_exception_reason
  ,p_child_support_obligation             => p_child_support_obligation
  ,p_opted_for_medicare_flag            => p_opted_for_medicare_flag
  ,p_background_check_status      => p_background_check_status
  ,p_background_date_check        => p_background_date_check
  ,p_correspondence_language      => p_correspondence_language
  ,p_fte_capacity                 => p_fte_capacity
  ,p_hold_applicant_date_until    => p_hold_applicant_date_until
  ,p_honors                       => p_honors
  ,p_mailstop                     => p_mailstop
  ,p_office_number                => p_office_number
  ,p_on_military_service          => p_on_military_service
  ,p_pre_name_adjunct             => p_pre_name_adjunct
  ,p_projected_start_date         => p_projected_start_date
  ,p_resume_exists                => p_resume_exists
  ,p_resume_last_updated          => p_resume_last_updated
  ,p_student_status               => p_student_status
  ,p_work_schedule                => p_work_schedule
  ,p_suffix                       => p_suffix
  ,p_date_of_death                => p_date_of_death
  ,p_benefit_group_id             => p_benefit_group_id
  ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
  ,p_uses_tobacco_flag            => p_uses_tobacco_flag
  ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire        => p_original_date_of_hire
  ,p_town_of_birth                => p_town_of_birth
  ,p_region_of_birth              => p_region_of_birth
  ,p_country_of_birth             => p_country_of_birth
  ,p_global_person_id             => p_global_person_id
  ,p_party_id                     => p_party_id
  --
  ,p_person_id                    => p_person_id
  ,p_assignment_id                => p_assignment_id
  ,p_application_id               => p_application_id
  ,p_per_object_version_number    => p_per_object_version_number
  ,p_asg_object_version_number    => p_asg_object_version_number
  ,p_apl_object_version_number    => p_apl_object_version_number
  ,p_per_effective_start_date     => p_per_effective_start_date
  ,p_per_effective_end_date       => p_per_effective_end_date
  ,p_full_name                    => p_full_name
  ,p_per_comment_id               => p_per_comment_id
  ,p_assignment_sequence          => p_assignment_sequence
  ,p_name_combination_warning     => p_name_combination_warning
  ,p_orig_hire_warning            => p_orig_hire_warning
  );
  --
--  hr_utility.set_location(' Leaving:'||l_proc, 7);
end create_us_applicant;
--

-- Overloaded the function Create_US_employee for bug 8277596

procedure create_us_applicant
  (p_validate                      in     boolean  --default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2 --default null
  ,p_person_type_id                in     number   --default null
  ,p_applicant_number              in out nocopy varchar2
  ,p_comments                      in     varchar2 --default null
  ,p_date_employee_data_verified   in     date     --default null
  ,p_date_of_birth                 in     date     --default null
  ,p_email_address                 in     varchar2 --default null
  ,p_expense_check_send_to_addres  in     varchar2 --default null
  ,p_first_name                    in     varchar2 --default null
  ,p_known_as                      in     varchar2 --default null
  ,p_marital_status                in     varchar2 --default null
  ,p_middle_names                  in     varchar2 --default null
  ,p_nationality                   in     varchar2 --default null
  ,p_ss_number                     in     varchar2 --default null
  ,p_previous_last_name            in     varchar2 --default null
  ,p_registered_disabled_flag      in     varchar2 --default null
  ,p_title                         in     varchar2 --default null
  ,p_work_telephone                in     varchar2 --default null
  ,p_attribute_category            in     varchar2 --default null
  ,p_attribute1                    in     varchar2 --default null
  ,p_attribute2                    in     varchar2 --default null
  ,p_attribute3                    in     varchar2 --default null
  ,p_attribute4                    in     varchar2 --default null
  ,p_attribute5                    in     varchar2 --default null
  ,p_attribute6                    in     varchar2 --default null
  ,p_attribute7                    in     varchar2 --default null
  ,p_attribute8                    in     varchar2 --default null
  ,p_attribute9                    in     varchar2 --default null
  ,p_attribute10                   in     varchar2 --default null
  ,p_attribute11                   in     varchar2 --default null
  ,p_attribute12                   in     varchar2 --default null
  ,p_attribute13                   in     varchar2 --default null
  ,p_attribute14                   in     varchar2 --default null
  ,p_attribute15                   in     varchar2 --default null
  ,p_attribute16                   in     varchar2 --default null
  ,p_attribute17                   in     varchar2 --default null
  ,p_attribute18                   in     varchar2 --default null
  ,p_attribute19                   in     varchar2 --default null
  ,p_attribute20                   in     varchar2 --default null
  ,p_attribute21                   in     varchar2 --default null
  ,p_attribute22                   in     varchar2 --default null
  ,p_attribute23                   in     varchar2 --default null
  ,p_attribute24                   in     varchar2 --default null
  ,p_attribute25                   in     varchar2 --default null
  ,p_attribute26                   in     varchar2 --default null
  ,p_attribute27                   in     varchar2 --default null
  ,p_attribute28                   in     varchar2 --default null
  ,p_attribute29                   in     varchar2 --default null
  ,p_attribute30                   in     varchar2 --default null
  ,p_ethnic_origin                 in     varchar2 --default null
  ,p_I_9                           in     varchar2 --default 'N'
  ,p_I_9_expiration_date           in     varchar2 --default null
--  ,p_visa_type                     in     varchar2 --default null
  ,p_veteran_status                in     varchar2 --default null
  ,p_vets100A                in     varchar2 --default null
  ,p_new_hire                      in     varchar2 --default null
  ,p_exception_reason              in     varchar2 --default null
  ,p_child_support_obligation      in     varchar2 --default 'N'
  ,p_opted_for_medicare_flag       in     varchar2 --default 'N'
  ,p_background_check_status       in     varchar2 --default null
  ,p_background_date_check         in     date     --default null
  ,p_correspondence_language       in     varchar2 --default null
  ,p_fte_capacity                  in     number   --default null
  ,p_hold_applicant_date_until     in     date     --default null
  ,p_honors                        in     varchar2 --default null
  ,p_mailstop                      in     varchar2 --default null
  ,p_office_number                 in     varchar2 --default null
  ,p_on_military_service           in     varchar2 --default null
  ,p_pre_name_adjunct              in     varchar2 --default null
  ,p_projected_start_date          in     date     --default null
  ,p_resume_exists                 in     varchar2 --default null
  ,p_resume_last_updated           in     date     --default null
  ,p_student_status                in     varchar2 --default null
  ,p_work_schedule                 in     varchar2 --default null
  ,p_suffix                        in     varchar2 --default null
  ,p_date_of_death                in     date     --default null
  ,p_benefit_group_id             in     number   --default null
  ,p_receipt_of_death_cert_date   in     date     --default null
  ,p_coord_ben_med_pln_no         in     varchar2 --default null
  ,p_coord_ben_no_cvg_flag        in     varchar2 --default 'N'
  ,p_uses_tobacco_flag            in     varchar2 --default null
  ,p_dpdnt_adoption_date          in     date     --default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2 --default 'N'
  ,p_original_date_of_hire        in     date     --default null
  ,p_town_of_birth                in     varchar2 --default null
  ,p_region_of_birth              in     varchar2 --default null
  ,p_country_of_birth             in     varchar2 --default null
  ,p_global_person_id             in     varchar2 --default null
  ,p_party_id                     in     number --default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_application_id                   out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'create_us_applicant';
  l_legislation_code     varchar2(30);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Validation in addition to Table Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'US'.
  --
  if l_legislation_code <> 'US' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','US');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  --
  -- Call the person business process
  --
  hr_applicant_api.create_applicant
  (p_validate                     => p_validate
  ,p_date_received                => p_date_received
  ,p_business_group_id            => p_business_group_id
  ,p_last_name                    => p_last_name
  ,p_sex                          => p_sex
  ,p_person_type_id               => p_person_type_id
  ,p_per_comments                 => p_comments
  ,p_date_employee_data_verified  => p_date_employee_data_verified
  ,p_date_of_birth                => p_date_of_birth
  ,p_email_address                => p_email_address
  ,p_applicant_number              => p_applicant_number
  ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
  ,p_first_name                   => p_first_name
  ,p_known_as                     => p_known_as
  ,p_marital_status               => p_marital_status
  ,p_middle_names                 => p_middle_names
  ,p_nationality                  => p_nationality
  ,p_national_identifier          => p_ss_number
  ,p_previous_last_name           => p_previous_last_name
  ,p_registered_disabled_flag     => p_registered_disabled_flag
  ,p_title                        => p_title
  ,p_work_telephone               => p_work_telephone
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
  ,p_attribute21                  => p_attribute21
  ,p_attribute22                  => p_attribute22
  ,p_attribute23                  => p_attribute23
  ,p_attribute24                  => p_attribute24
  ,p_attribute25                  => p_attribute25
  ,p_attribute26                  => p_attribute26
  ,p_attribute27                  => p_attribute27
  ,p_attribute28                  => p_attribute28
  ,p_attribute29                  => p_attribute29
  ,p_attribute30                  => p_attribute30
  ,p_per_information_category     => 'US'
  ,p_per_information1             => p_ethnic_origin
  ,p_per_information2             => p_i_9
  ,p_per_information3             => p_i_9_expiration_date
--  ,p_per_information4             => p_visa_type
  ,p_per_information5             => p_veteran_status
  ,p_per_information25             => p_vets100A
  ,p_per_information7             => p_new_hire
  ,p_per_information8             => p_exception_reason
  ,p_per_information9             => p_child_support_obligation
  ,p_per_information10            => p_opted_for_medicare_flag
  ,p_background_check_status      => p_background_check_status
  ,p_background_date_check        => p_background_date_check
  ,p_correspondence_language      => p_correspondence_language
  ,p_fte_capacity                 => p_fte_capacity
  ,p_hold_applicant_date_until    => p_hold_applicant_date_until
  ,p_honors                       => p_honors
  ,p_mailstop                     => p_mailstop
  ,p_office_number                => p_office_number
  ,p_on_military_service          => p_on_military_service
  ,p_pre_name_adjunct             => p_pre_name_adjunct
  ,p_projected_start_date         => p_projected_start_date
  ,p_resume_exists                => p_resume_exists
  ,p_resume_last_updated          => p_resume_last_updated
  ,p_student_status               => p_student_status
  ,p_work_schedule                => p_work_schedule
  ,p_suffix                       => p_suffix
  ,p_date_of_death                => p_date_of_death
  ,p_benefit_group_id             => p_benefit_group_id
  ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
  ,p_uses_tobacco_flag            => p_uses_tobacco_flag
  ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire        => p_original_date_of_hire
  ,p_town_of_birth                => p_town_of_birth
  ,p_region_of_birth              => p_region_of_birth
  ,p_country_of_birth             => p_country_of_birth
  ,p_global_person_id             => p_global_person_id
  ,p_party_id                     => p_party_id
  --
  ,p_person_id                    => p_person_id
  ,p_assignment_id                => p_assignment_id
  ,p_application_id               => p_application_id
  ,p_per_object_version_number    => p_per_object_version_number
  ,p_asg_object_version_number    => p_asg_object_version_number
  ,p_apl_object_version_number    => p_apl_object_version_number
  ,p_per_effective_start_date     => p_per_effective_start_date
  ,p_per_effective_end_date       => p_per_effective_end_date
  ,p_full_name                    => p_full_name
  ,p_per_comment_id               => p_per_comment_id
  ,p_assignment_sequence          => p_assignment_sequence
  ,p_name_combination_warning     => p_name_combination_warning
  ,p_orig_hire_warning            => p_orig_hire_warning
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
end create_us_applicant;

-- ---------------------------------------------------------------------------
-- |-----------------------------< hire_applicant >---------------------------|
-- ---------------------------------------------------------------------------
-- This is the overloaded version of hire_applicant that matches the
-- base release
procedure hire_applicant
  (p_validate                  in      boolean ,  --default false,
   p_hire_date                 in      date,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_assignment_id             in      number, --default null,
   p_person_type_id            in      number,   --default null,
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_employee_number           in out nocopy  per_all_people_f.employee_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean,
   p_original_date_of_hire     in      date,  --default null
   p_migrate                   in      boolean   default true,
   p_source                    in      boolean   default false
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'hire__applicant';
  --
  l_per_object_version_number      per_all_people_f.object_version_number%TYPE;
  l_employee_number                per_all_people_f.employee_number%TYPE;
  l_per_effective_start_date       date;
  l_per_effective_end_date         date;
  l_unaccepted_asg_del_warning     boolean;
  l_assign_payroll_warning         boolean;
  l_oversubscribed_vacancy_id      number;
--  l_original_date_of_hire          date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_per_object_version_number:=p_per_object_version_number;
  l_employee_number:=p_employee_number;
  --
  hr_applicant_api.hire_applicant
  (p_validate                   => p_validate
  ,p_hire_date                  => p_hire_date
  ,p_person_id                  => p_person_id
  ,p_assignment_id              => p_assignment_id
  ,p_person_type_id             => p_person_type_id
  ,p_per_object_version_number  => l_per_object_version_number
  ,p_employee_number            => l_employee_number
  ,p_per_effective_start_date   => l_per_effective_start_date
  ,p_per_effective_end_date     => l_per_effective_end_date
  ,p_unaccepted_asg_del_warning => l_unaccepted_asg_del_warning
  ,p_assign_payroll_warning     => l_assign_payroll_warning
  ,p_oversubscribed_vacancy_id  => l_oversubscribed_vacancy_id
  ,p_original_date_of_hire      => p_original_date_of_hire
  ,p_migrate                    => p_migrate
  ,p_source           		=> p_source
  );
  --
  p_employee_number              := l_employee_number;
  p_per_object_version_number    := l_per_object_version_number;
  p_per_effective_start_date     := l_per_effective_start_date;
  p_per_effective_end_date       := l_per_effective_end_date;
  p_unaccepted_asg_del_warning   := l_unaccepted_asg_del_warning;
  p_assign_payroll_warning       := l_assign_payroll_warning;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
  --
end hire_applicant;
--
-- ---------------------------------------------------------------------------
-- |-----------------------------< hire_applicant >---------------------------|
-- ---------------------------------------------------------------------------
--
procedure hire_applicant
  (p_validate                  in      boolean,   --default false,
   p_hire_date                 in      date,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_assignment_id             in      number, --default null,
   p_person_type_id            in      number,  --default null,
   p_national_identifier       in      per_all_people_f.national_identifier%type, --default hr_api.g_varchar2,
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_employee_number           in out nocopy  per_all_people_f.employee_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean,
   p_oversubscribed_vacancy_id    out nocopy  number,
   p_original_date_of_hire     in      date, --default null ,
   p_migrate                   in      boolean   default true,
   p_source                    in      boolean   default false
)
is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'hire_applicant';
  --
  l_exists                     varchar2(1);
  l_count                      number;
  l_multi_flag                 boolean;
  l_chk_system_status          per_assignment_status_types.per_system_status%TYPE;
  l_chk_person_id              per_all_people_f.person_id%TYPE;
  --
  l_person_type_id             number  := p_person_type_id;
  l_person_type_id1            number;
  l_unaccepted_asg_del_warning boolean;
  --
  l_system_person_type         per_person_types.system_person_type%TYPE;
  l_business_group_id          per_all_people_f.business_group_id%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_applicant_number           per_all_people_f.applicant_number%TYPE;
  l_application_id             per_applications.application_id%TYPE;
  l_apl_object_version_number  per_applications.application_id%TYPE;
  --
  l_hire_date                  date;
  l_original_date_of_hire      date;
  --
  l_per_system_status          per_assignment_status_types.per_system_status%TYPE;
  l_assignment_id              per_assignments_f.assignment_id%TYPE;
  l_asg_object_version_number  per_assignments_f.object_version_number%TYPE;
  --
  l_per_object_version_number  per_all_people_f.object_version_number%TYPE;
  l_employee_number            per_all_people_f.employee_number%TYPE;
  l_npw_number                 per_all_people_f.npw_number%TYPE;
  l_per_effective_start_date   per_all_people_f.effective_start_date%TYPE;
  l_per_effective_end_date     per_all_people_f.effective_end_date%TYPE;
  l_comment_id                 per_assignments_f.comment_id%TYPE;
  l_current_applicant_flag     varchar2(1);
  l_current_emp_or_apl_flag    varchar2(1);
  l_current_employee_flag      varchar2(1);
  l_full_name                  per_all_people_f.full_name%TYPE;
  l_name_combination_warning   boolean;
  l_assign_payroll_warning     boolean;
  l_orig_hire_warning          boolean;
  l_hourly_salaried_warning    boolean;
  --
  l_assignment_status_id       number;
  L_ASG_STATUS_OVN             number;
 l_period_of_service_id       per_periods_of_service.period_of_service_id%TYPE;
  l_pds_object_version_number  per_periods_of_service.object_version_number%TYPE;
  --
  l_assignment_status_type_id  per_assignments_f.assignment_status_type_id%TYPE;
  --
  l_primary_flag               per_assignments_f.primary_flag%TYPE;
  --
  l_effective_start_date       per_assignments_f.effective_start_date%TYPE;
  l_effective_end_date         per_assignments_f.effective_end_date%TYPE;
  l_validation_start_date      date;
  l_validation_end_date        date;
  l_payroll_id_updated         boolean;
  l_other_manager_warning      boolean;
  l_no_managers_warning        boolean;
  l_org_now_no_manager_warning boolean;
  l_oversubscribed_vacancy_id  number;
  l_vacancy_id                 per_all_assignments_f.vacancy_id%type;
  l_dummy                      number;
  --
--bug no 5105005
l_datetrack_mode  			varchar2(10):='UPDATE';
cursor csr_pps_ended_ystrdy
  is
  select final_process_date
  from  per_periods_of_service pps
  where pps.person_id  = p_person_id
  and pps.actual_termination_date = p_hire_date-1;
--bug no 5105005

  lv_per_object_version_number per_all_people_f.object_version_number%TYPE := p_per_object_version_number ;
  lv_employee_number           per_all_people_f.employee_number%TYPE := p_employee_number ;
  --
  --
  -- Bug# 2273304 Start Here
  --
  l_date_of_birth  date;         --2273304
  l_age            number(3);    --2273304
  l_minimum_age    number(3);    --2273304
  l_maximum_age    number(3);    --2273304
  --
  cursor csr_date_of_birth is
    select date_of_birth
    from per_all_people_f ppf
    where ppf.person_id = p_person_id
    and l_business_group_id = ppf.business_group_id
    and p_hire_date between effective_start_date
            and nvl(effective_end_date,p_hire_date);

  cursor csr_bg_age_range is
    select hoi1.org_information12, hoi1.org_information13
    from hr_organization_information hoi1
    where l_business_group_id +0 = hoi1.organization_id
    and    hoi1.org_information_context = 'Business Group Information';

  --
  -- Bug# 2273304 End Here
  --
  cursor csr_future_asg_changes is
    select 'x'
      from per_assignments_f asg
     where asg.person_id = p_person_id
--bug no 5105005
       and asg.effective_start_date > p_hire_date;
--bug no 5105005
  --
  cursor csr_get_devived_details is
    select ppt.system_person_type,
           per.business_group_id,
           bus.legislation_code,
           per.applicant_number,
           pap.application_id,
           pap.object_version_number,
           per.npw_number,
           per.original_date_of_hire   -- #2978566
      from per_all_people_f per,
           per_business_groups bus,
           per_person_types ppt,
           per_applications pap
     where per.person_type_id    = ppt.person_type_id
       and per.business_group_id = bus.business_group_id
       and per.person_id         = pap.person_id
       and per.person_id         = p_person_id
       and l_hire_date       between per.effective_start_date
                               and per.effective_end_date
       and l_hire_date       between pap.date_received
                               and nvl(pap.date_end,hr_api.g_eot);
  --
  cursor csr_chk_asg_status is
    select count(asg.assignment_id)
      from per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and pas.per_system_status         = 'ACCEPTED'
       and l_hire_date             between asg.effective_start_date
                                                   and asg.effective_end_date;
  --
  cursor csr_chk_assignment_id is
    select per.person_id,
           pas.per_system_status
      from per_all_people_f per,
           per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and per.person_id                 = asg.person_id
       and l_hire_date             between per.effective_start_date
                                       and per.effective_end_date
       and asg.assignment_id             = p_assignment_id
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date;
  --
  cursor csr_get_un_accepted is
    select asg.assignment_id,
           asg.object_version_number
      from per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status        <> 'ACCEPTED'
       and asg.assignment_type          =  'A' --Fix for bug 2881076
     order by asg.assignment_id;
  --
  cursor csr_get_accepted is
    select asg.assignment_id,
           asg.object_version_number,
           asg.vacancy_id
      from per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status         = 'ACCEPTED'
	  and asg.assignment_type = 'A' --changed for bug 6501961
       order by asg.assignment_id;
  --
  -- added for the bug 4681211
   cursor csr_get_accepted_pmry is
    select asg.assignment_id,
           asg.object_version_number,
           asg.vacancy_id
      from per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status         = 'ACCEPTED'
        and asg.assignment_id=p_assignment_id;
  --
  cursor csr_get_accepted_non is
    select asg.assignment_id,
           asg.object_version_number,
           asg.vacancy_id
      from per_assignments_f asg,
           per_assignment_status_types pas
     where asg.assignment_status_type_id = pas.assignment_status_type_id
       and asg.person_id                 = p_person_id
       and l_hire_date             between asg.effective_start_date
                                       and asg.effective_end_date
       and pas.per_system_status         = 'ACCEPTED'
        and  asg.assignment_id <> p_assignment_id
	   and asg.assignment_type = 'A' --changed for bug 6501961
       order by asg.assignment_id;
  -- end of bug 4681211
  --
  cursor csr_vacs(p_vacancy_id number) is
  select 1
  from per_all_vacancies vac
  where vac.vacancy_id=p_vacancy_id
  and vac.number_of_openings <
    (select count(distinct assignment_id)
     from per_all_assignments_f asg
     where asg.vacancy_id=p_vacancy_id
     and asg.assignment_type='E');
  --
  --start for i-rec enhancement ww bug # 2675202
  -- Cursor,for the applicant who has an address which has a party_id on it,
  -- but not a person_id.
  --
  cursor csr_add(p_party_id number) is
  select address_id, object_version_number
  from per_addresses
  where party_id=p_party_id
  and person_id is null;
  --
  -- Cursor for the applicant who has phone numbers which have a party_id on it,
  -- but not a person_id.
  --
  cursor csr_phn(p_party_id number) is
  select phone_id, object_version_number
  from per_phones
  where party_id=p_party_id
  and parent_id is null;
  --
  -- Cursor for the applicant who has previous employers which have a party_id on it,
  -- but not a person_id.
  --
  cursor csr_pem(p_party_id number) is
  select previous_employer_id, object_version_number
  from per_previous_employers
  where party_id=p_party_id
  and person_id is null;
  --
  -- Cursor for the applicant who has qualifications which have a party_id on it,
  -- but not a person_id.
  --
  cursor csr_qua(p_party_id number) is
  select qualification_id, object_version_number
  from per_qualifications
  where party_id=p_party_id
  and person_id is null;
  --
  -- Cursor for the applicant who has establishment attendances which have a
  -- party_id on it, but not a person_id.
  --
  cursor csr_esa(p_party_id number) is
  select attendance_id, object_version_number
  from per_establishment_attendances
  where party_id=p_party_id
  and person_id is null;
  --
  --

  l_add_ovn      per_addresses.OBJECT_VERSION_NUMBER%type;
  l_phn_ovn      per_phones.OBJECT_VERSION_NUMBER%type;
  l_parent_table per_phones.PARENT_TABLE%type;
  l_pem_ovn      per_previous_employers.OBJECT_VERSION_NUMBER%type;
  l_qua_ovn      per_qualifications.OBJECT_VERSION_NUMBER%type;
  l_esa_ovn      per_establishment_attendances.OBJECT_VERSION_NUMBER%type;
  --
  --end for i-rec enhancement ww bug # 2675202
  --
  --
  -- Fix for bug 2881076. Check if there are any old pps with either FPD null
  -- or FPD later than new hire date.
  cursor csr_pps_not_ended
  is
  select final_process_date
  from  per_periods_of_service pps
  where pps.person_id  = p_person_id
  and pps.actual_termination_date is not null
  and   pps.date_start < p_hire_date
  and nvl(pps.final_process_date,p_hire_date) >= p_hire_date;
  --
  l_pps date;
  -- Fix for bug 288076 end.
  --

  -- start of bug3572499
  l_new_hire_code        varchar2(30);
  --
  cursor csr_get_legislation_code is
    select legislation_code
    from per_business_groups_perf pbg
        ,per_all_people_f    ppf
    where ppf.person_id = p_person_id
    and   pbg.business_group_id+0 = ppf.business_group_id;

  cursor csr_get_new_hire_code is
    SELECT per_information7
          FROM per_all_people_f
          WHERE person_id = p_person_id
          AND effective_start_date =
            (select max(effective_start_date)
             from per_all_people_f
             where person_id = p_person_id
          );
  -- end of bug3572499

  -- Fix For Bug 5749371 Starts

  cursor csr_existing_SCL (crs_asg_id number) is
    select soft_coding_keyflex_id,payroll_id
    from per_all_assignments_f asg
    where asg.assignment_id = crs_asg_id
 -- and asg.primary_flag = 'Y'
    and trunc(sysdate) between asg.effective_start_date
    and asg.effective_end_date;
 --and asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;

  cursor get_scl is
    select soft_coding_keyflex_id
    from hr_soft_coding_keyflex
    where rownum=1;

     l_soft_coding_keyflex_id hr_soft_coding_keyflex.soft_coding_keyflex_id%type;
     l_payroll_id per_all_assignments_f.payroll_id%type;
     l_dummy_soft_coding_keyflex_id hr_soft_coding_keyflex.soft_coding_keyflex_id%type;

  -- Fix For Bug 5749371 Ends

  -- Bug 8831084 Fix Starts
     cursor csr_get_ex_ass_entmnt is
        select asg.assignment_id
        from per_assignments_f asg,per_assignment_status_types pas
        where asg.assignment_status_type_id = pas.assignment_status_type_id
          and asg.person_id  = p_person_id
          and p_hire_date     between asg.effective_start_date
                                  and asg.effective_end_date
          and pas.per_system_status         = 'ACCEPTED'
	        and asg.assignment_type = 'A' ;

     cursor get_business_group(p_asg_id number) is
        select distinct PAAF.business_group_id
        from   per_all_assignments_f PAAF
        where  PAAF.assignment_id=p_asg_id;
     l_bg_id number;
     l_ass_id number;
  -- Bug 8831084 Fix Ends

  -- Bug 2833630
  PROCEDURE update_salary_proposal(p_assignment_id number
                                 , p_effective_date date) IS

     l_pay_proposal_id           per_pay_proposals.pay_proposal_id%TYPE;
     l_pyp_object_version_number per_pay_proposals.object_version_number%TYPE;
     l_change_date               per_pay_proposals.change_date%TYPE;
     l_proposed_salary           per_pay_proposals.PROPOSED_SALARY_N%TYPE;
     l_approved_flag             varchar2(1) := 'N';  ---- Changed from Y to N for ER: 6136609
     l_inv_next_sal_date_warning boolean;
     l_proposed_salary_warning   boolean;
     l_approved_warning          boolean;
     l_payroll_warning           boolean;

---- Fix For ER: 6136609 Starts ----

     l_autoApprove               varchar2(1);

---- Fix For ER: 6136609 Ends ----

     cursor csr_payproposal is
        select pay_proposal_id, object_version_number, change_date
              ,PROPOSED_SALARY_N
          from per_pay_proposals
          where assignment_id = p_assignment_id
          order by change_date DESC;
  BEGIN
    open csr_payproposal;
    fetch csr_payproposal into l_pay_proposal_id, l_pyp_object_version_number
                              ,l_change_date, l_proposed_salary;
    if csr_payproposal%found and l_change_date < p_effective_date then

---- Fix For ER: 6136609 Starts ----

    l_autoApprove:=fnd_profile.value('HR_AUTO_APPROVE_FIRST_PROPOSAL');
    if(l_autoApprove is null or l_autoApprove ='Y') then
       hr_utility.set_location(l_proc, 32);
       l_approved_flag:='Y';
    end if;

---- Fix For ER: 6136609 Ends ----

        hr_maintain_proposal_api.cre_or_upd_salary_proposal
          (p_pay_proposal_id              => l_pay_proposal_id
          ,p_object_version_number        => l_pyp_object_version_number
          ,p_change_date                  => p_effective_date
          ,p_approved                     => l_approved_flag
          ,p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning
          ,p_proposed_salary_warning      => l_proposed_salary_warning
          ,p_approved_warning             => l_approved_warning
          ,p_payroll_warning              => l_payroll_warning
        );
    end if;
    close csr_payproposal;
  END update_salary_proposal;
  -- End bug 2833630
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'hire_date'
     ,p_argument_value => p_hire_date
     );
  --
  -- Issue a savepoint.
  --
--bug no 5105005
  open csr_pps_ended_ystrdy;
  fetch csr_pps_ended_ystrdy into l_pps;
  --
  if csr_pps_ended_ystrdy%found then
    --
    hr_utility.set_location(l_proc,11);
    l_datetrack_mode:='CORRECTION';
  end if;
 close csr_pps_ended_ystrdy;
--bug no 5105005
  savepoint hire_applicant;
  --
  hr_utility.set_location(l_proc, 80);

  -- Bug 8831084 Fix Starts

    if p_assignment_id is null then
       open csr_get_ex_ass_entmnt;
       loop
        fetch csr_get_ex_ass_entmnt into l_ass_id;
       exit when csr_get_ex_ass_entmnt%notfound;
       end loop;
    else
       l_ass_id:=p_assignment_id;
    end if;

  --Bug 8831084 Fix ends


  --
  -- Process Logic
  --
  l_per_object_version_number  := p_per_object_version_number;
  l_employee_number            := p_employee_number;
  -- Truncate the time portion from all date parameters
  -- which are passed in.
  --
  l_hire_date                  := trunc(p_hire_date);

  -- #2978566
  --
  -- Get the derived details for the person DT instance
  --
  hr_utility.set_location(l_proc,40);

  open  csr_get_devived_details;
  fetch csr_get_devived_details
   into l_system_person_type,
        l_business_group_id,
        l_legislation_code,
        l_applicant_number,
        l_application_id,
        l_apl_object_version_number,
        l_npw_number,
        l_original_date_of_hire;
  if csr_get_devived_details%NOTFOUND
  then
    --
    hr_utility.set_location(l_proc,50);
    --
    close csr_get_devived_details;
    --
    hr_utility.set_message(800,'PER_52097_APL_INV_PERSON_ID');
    hr_utility.raise_error;
    --
  end if;
  close csr_get_devived_details;
  --
  -- #2978566
  -- Set the original date of hire
  --
  if p_original_date_of_hire is not null then
     l_original_date_of_hire := trunc(p_original_date_of_hire);
  elsif l_original_date_of_hire is null then
     l_original_date_of_hire := l_hire_date;
  end if;

  --
  -- Call Before Process User Hook for hire_applicant
  --

  begin
    hr_applicant_bk2.hire_applicant_b
      (
       p_hire_date                 => l_hire_date,
       p_person_id                 => p_person_id,
       p_assignment_id             => p_assignment_id,
       p_person_type_id            => p_person_type_id,
       p_national_identifier       => p_national_identifier,
       p_per_object_version_number => p_per_object_version_number,
       p_employee_number           => p_employee_number,
       p_original_date_of_hire     => l_original_date_of_hire
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HIRE_APPLICANT'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of the before hook for hire_applicant
  --
  end;

  --
  -- Check that there are not any future changes to the assignment
  --

  open csr_future_asg_changes;
  fetch csr_future_asg_changes into l_exists;
  --
  if csr_future_asg_changes%FOUND then
    --
    hr_utility.set_location(l_proc,30);
    close csr_future_asg_changes;
    --
    hr_utility.set_message(801,'HR_7975_ASG_INV_FUTURE_ASA');
    hr_utility.raise_error;
    --
  end if;
  --
  --
  hr_utility.set_location(l_proc,270);
  --
  -- Validation in addition to Row Handlers
  --
  -- If the specified person type id is not null then check that it
  -- corresponds to type 'EMP', is currently active and is in the correct
  -- business group, otherwise set person type to the active default for EMP
  -- in the current business group.
  --
   per_per_bus.chk_person_type
    (p_person_type_id    => l_person_type_id
    ,p_business_group_id => l_business_group_id
    ,p_expected_sys_type => 'EMP'
    );
  --
  hr_utility.set_location(l_proc,60);
  --
  -- Check that corresponding person is of 'APL', 'APL_EX_APL' or 'EX_EMP_APL'
  -- system person type.
  --
  if l_system_person_type <> 'APL' and
     l_system_person_type <> 'APL_EX_APL' and
     l_system_person_type <> 'EX_EMP_APL'
  then
    --
    hr_utility.set_location(l_proc,70);
    --
    hr_utility.set_message(800,'PER_52096_APL_INV_PERSON_TYPE');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,80);
  --
  -- Bug# 2273304 Start Here
  --
  open csr_date_of_birth;
  fetch csr_date_of_birth into l_date_of_birth;
  close csr_date_of_birth;

  l_age := trunc(months_between(p_hire_date,l_date_of_birth)/12);

  open csr_bg_age_range;
  fetch csr_bg_age_range into l_minimum_age, l_maximum_age;
  close csr_bg_age_range;

  if l_age not between nvl(l_minimum_age,l_age) and
                           nvl(l_maximum_age,l_age) then
     hr_utility.set_message(801, 'HR_7426_EMP_AGE_ILLEGAL');
     hr_utility.set_message_token('MIN',to_char(l_minimum_age));
     hr_utility.set_message_token('MAX',to_char(l_maximum_age));
     hr_utility.raise_error;
  end if;
hr_utility.set_location('age:'||l_age||'min:'||l_minimum_age||'max:'||l_maximum_age,91);

  --
  -- Bug# 2273304 End Here
  --
  --
  -- Check that corresponding person is of 'ACCEPTED' of
  -- assignment status type.
  --
  open csr_chk_asg_status;
  fetch csr_chk_asg_status into l_count;
  if l_count = 0 then
     --
     hr_utility.set_location(l_proc,90);
     --
     close csr_chk_asg_status;
     --
     hr_utility.set_message(800,'PER_52098_APL_INV_ASG_STATUS');
     hr_utility.raise_error;
     --
  end if;
  --
  -- If the accepted assignment record is multiple, ASSIGNMENT_ID
  -- must be not null.
  --
  if l_count > 1 then
    --
    hr_utility.set_location(l_proc,100);
    --
    --close csr_chk_asg_status;
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id
    );
    --
    hr_utility.set_location(l_proc,110);
    --
    l_multi_flag  := TRUE;
    --
  end if;
  --
  close csr_chk_asg_status;
  --
  hr_utility.set_location(l_proc,120);
  --
  -- Check p_assignment is corresponding data.
  -- The assignment record specified by P_ASSIGNMENT_ID on the hire
  -- date in the PER_ASSIGNMENTS_F table has assignment status
  -- 'ACCEPTED'.
  --
  if p_assignment_id is not null then
    --
    hr_utility.set_location(l_proc,130);
    --
    open  csr_chk_assignment_id;
    fetch csr_chk_assignment_id
     into l_chk_person_id,
          l_chk_system_status;
    if csr_chk_assignment_id%NOTFOUND then
       --
       hr_utility.set_location(l_proc,140);
       --
       close csr_chk_assignment_id;
       --
       hr_utility.set_message(800,'PER_52099_ASG_INV_ASG_ID');
       hr_utility.raise_error;
       --
    end if;
    --
    if l_chk_person_id <> p_person_id then
       --
       hr_utility.set_location(l_proc,150);
       --
       close csr_chk_assignment_id;
       --
       hr_utility.set_message(800,'PER_52101_ASG_INV_PER_ID_COMB');
       hr_utility.raise_error;
       --
    end if;
    --
    if l_chk_system_status <> 'ACCEPTED' then
       --
       hr_utility.set_location(l_proc,150);
       --
       close csr_chk_assignment_id;
       --
       hr_utility.set_message(800,'PER_52100_ASG_INV_PER_TYPE');
       hr_utility.raise_error;
       --
    end if;
    --
    hr_utility.set_location(l_proc,160);
    --
    close csr_chk_assignment_id;
    --
  end if;
  --
  -- Fix for bug 2881076.
  -- check whether the person has periods_of_service record with a value
  -- ATD and but no FPD
  --
  open csr_pps_not_ended;
  fetch csr_pps_not_ended into l_pps;
  --
  if csr_pps_not_ended%found then
    --
    hr_utility.set_location(l_proc,165);
    close csr_pps_not_ended;
    --
    -- Fix 5196352 - Now we allow rehire before FPD
    -- hence do not throw error PER_289308_FUTURE_ENDED_FPD
    -- Here we just check FPD should never be null.

    if l_pps is null then
       hr_utility.set_message('800','HR_449756_FPD_PREV_PDS');
       hr_utility.raise_error;
    end if;
  end if;
  --
  -- Fix for bug 2881076 end.
  hr_utility.set_location(l_proc,170);
  --
  -- Lock the person record in PER_ALL_PEOPLE_F ready for UPDATE at a later point.
  -- (Note: This is necessary because calling the table handlers in locking
  --        ladder order invokes an error in per_apl_upd.upd due to the person
  --        being modified by the per_per_upd.upd table handler.)
  per_per_shd.lck
    (p_effective_date                 => l_hire_date
--bug no 5105005
    ,p_datetrack_mode                 => l_datetrack_mode
--bug no 5105005
    ,p_person_id                      => p_person_id
    ,p_object_version_number          => p_per_object_version_number
    ,p_validation_start_date          => l_validation_start_date
    ,p_validation_end_date            => l_validation_end_date
    );
  --
  hr_utility.set_location(l_proc,180);
  --
  --start changes for i-rec enhancement ww bug # 2675202
  --
  if (p_migrate) then
    for add_rec in csr_add(per_per_shd.g_old_rec.party_id) loop
      l_add_ovn:=add_rec.object_version_number;
      per_add_upd.upd(p_address_id            => add_rec.address_id
                     ,p_person_id             => per_per_shd.g_old_rec.person_id
                     ,p_business_group_id     => l_business_group_id
                     ,p_object_version_number => l_add_ovn
                     ,p_effective_date        => l_hire_date);
    end loop;
    --
    hr_utility.set_location(l_proc,181);
    --
    for phn_rec in csr_phn(per_per_shd.g_old_rec.party_id) loop
      l_phn_ovn:=phn_rec.object_version_number;
      l_parent_table := 'PER_ALL_PEOPLE_F';
      per_phn_upd.upd(p_phone_id              => phn_rec.phone_id
                     ,p_parent_id             => per_per_shd.g_old_rec.person_id
                     ,p_parent_table          => l_parent_table
                     ,p_object_version_number => l_phn_ovn
                     ,p_effective_date        => l_hire_date);
    end loop;
    --
    hr_utility.set_location(l_proc,182);
    --
    for pem_rec in csr_pem(per_per_shd.g_old_rec.party_id) loop
      l_pem_ovn:=pem_rec.object_version_number;
      per_pem_upd.upd(p_previous_employer_id  => pem_rec.previous_employer_id
                     ,p_person_id             => per_per_shd.g_old_rec.person_id
                     ,p_business_group_id     => l_business_group_id
                     ,p_object_version_number => l_pem_ovn
                     ,p_effective_date        => l_hire_date);
    end loop;
    --
    hr_utility.set_location(l_proc,183);
    --
    for qua_rec in csr_qua(per_per_shd.g_old_rec.party_id) loop
      l_qua_ovn:=qua_rec.object_version_number;
      per_qua_upd.upd(p_qualification_id      => qua_rec.qualification_id
                     ,p_person_id             => per_per_shd.g_old_rec.person_id
                     ,p_business_group_id     => l_business_group_id
                     ,p_object_version_number => l_qua_ovn
                     ,p_effective_date        => l_hire_date);
    end loop;
    --
    hr_utility.set_location(l_proc,184);
    --
    for esa_rec in csr_esa(per_per_shd.g_old_rec.party_id) loop
      l_esa_ovn:=esa_rec.object_version_number;
      per_esa_upd.upd(p_attendance_id         => esa_rec.attendance_id
                     ,p_person_id             => per_per_shd.g_old_rec.person_id
                     ,p_business_group_id     => l_business_group_id
                     ,p_object_version_number => l_esa_ovn
                     ,p_effective_date        => l_hire_date);
    end loop;
    --
    hr_utility.set_location(l_proc,185);
    --
  end if;
  --
  --End changes for i-rec enhancement ww bug # 2675202
  --
  -- Update the application details by calling the upd procedure in the
  -- application table handler:
  -- Date_end is set to l_hire_date - 1;
  --
  per_apl_upd.upd
  (p_application_id                    => l_application_id
  ,p_date_end                          => l_hire_date - 1
  ,p_object_version_number             => l_apl_object_version_number
  ,p_effective_date                    => l_hire_date
  ,p_validate                          => false
  );
  hr_utility.set_location(l_proc,190);
-- PTU : Commented
-- Added to terminate APL record
-- Bug 1253785
--  hr_per_type_usage_internal.maintain_ptu(
--     p_action => 'HIRE_APL',
--     p_person_id => p_person_id,
--     p_actual_termination_date => p_hire_date-1);
  --
  --
  -- Set all unaccepted applicant assignments to have end date = p_hire_date -1
  -- by calling the del procedure in the PER_ASSIGNMENTS_F table handler
  -- (This is a datetrack DELETE mode operation)
  --
  open csr_get_un_accepted;
  loop
    fetch csr_get_un_accepted
     into  l_assignment_id,
           l_asg_object_version_number;
    exit when csr_get_un_accepted%NOTFOUND;
    --
    hr_utility.set_location(l_proc,210);
    --
    hr_utility.set_location(l_proc,240);
    --
    per_asg_del.del
    (p_assignment_id              => l_assignment_id
    ,p_effective_start_date       => l_effective_start_date
    ,p_effective_end_date         => l_effective_end_date
    ,p_business_group_id          => l_business_group_id
    ,p_object_version_number      => l_asg_object_version_number
    ,p_effective_date             => l_hire_date -1
    ,p_validation_start_date      => l_validation_start_date
    ,p_validation_end_date        => l_validation_end_date
    ,p_datetrack_mode             => 'DELETE'
    ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
    );
    --
    per_people3_pkg.get_default_person_type
      (p_required_type     => 'TERM_APL'
      ,p_business_group_id => l_business_group_id
      ,p_legislation_code  => l_legislation_code
      ,p_person_type       => l_assignment_status_type_id
      );

   IRC_ASG_STATUS_API.create_irc_asg_status
       (p_assignment_id               => l_assignment_id
       , p_assignment_status_type_id  => l_assignment_status_type_id
       , p_status_change_date         => l_hire_date -- Fix for bug 6036285
       , p_assignment_status_id       => l_assignment_status_id
       , p_object_version_number      => l_asg_status_ovn);

    hr_utility.set_location(l_proc,250);
    --
 -- Added the below api call for bug 7540870.
       IRC_OFFERS_API.close_offer
       ( p_validate                   => false
        ,p_effective_date             => l_hire_date-1
        ,p_applicant_assignment_id    => l_assignment_id
        ,p_change_reason              => 'MANUAL_CLOSURE'
       );

    l_unaccepted_asg_del_warning := TRUE;
    --
  end loop;
  --
  close csr_get_un_accepted;
  --
  hr_utility.set_location(l_proc, 260);

  -- bug3572499
  open csr_get_legislation_code;
  fetch csr_get_legislation_code  into l_legislation_code;
  close csr_get_legislation_code;
  -- enf of bug3572499

  --
  -- Update the person details by calling upd procedure in
  -- the per_all_people_f table.
  --
 l_person_type_id1 :=
           hr_person_type_usage_info.get_default_person_type_id
                        (l_business_group_id
                        ,'EMP');


  if (l_legislation_code <> 'US') then
  hr_utility.set_location(l_proc, 270);
  per_per_upd.upd(p_person_id     => p_person_id
  ,p_effective_date               => l_hire_date
  ,p_applicant_number             => l_applicant_number
  ,p_person_type_id               => l_person_type_id1
  ,p_object_version_number        => l_per_object_version_number
  ,p_national_identifier          => p_national_identifier
  ,p_employee_number              => l_employee_number
  ,p_datetrack_mode               => 'UPDATE'
  ,p_effective_start_date         => l_per_effective_start_date
  ,p_effective_end_date           => l_per_effective_end_date
  ,p_comment_id                   => l_comment_id
  ,p_current_applicant_flag       => l_current_applicant_flag
  ,p_current_emp_or_apl_flag      => l_current_emp_or_apl_flag
  ,p_current_employee_flag        => l_current_employee_flag
  ,p_full_name                    => l_full_name
  ,p_name_combination_warning     => l_name_combination_warning
  ,p_dob_null_warning             => p_assign_payroll_warning
  ,p_orig_hire_warning            => l_orig_hire_warning
  ,p_npw_number                   => l_npw_number
  ,p_original_date_of_hire        => l_original_date_of_hire
 );
 else
  hr_utility.set_location(l_proc, 272);
  -- start of bug3572499
  --
  -- US legislation specific
  --
  open  csr_get_new_hire_code;
  fetch csr_get_new_hire_code into l_new_hire_code;
  close csr_get_new_hire_code;
  --

  --Fix For Bug 5749371 Starts

  if p_source=true then
  open get_scl;
  fetch get_scl into l_dummy_soft_coding_keyflex_id;
  close get_scl;
  end if;

  --Fix For Bug 5749371 Ends

  if (l_new_hire_code is NULL) then
     hr_utility.set_location(l_proc,274);
     l_new_hire_code := 'INCL';
  end if;
  per_per_upd.upd(p_person_id     => p_person_id
  ,p_effective_date               => l_hire_date
  ,p_applicant_number             => l_applicant_number
  ,p_person_type_id               => l_person_type_id1
  ,p_object_version_number        => l_per_object_version_number
  ,p_national_identifier          => p_national_identifier
  ,p_employee_number              => l_employee_number
  ,p_datetrack_mode               => l_datetrack_mode
  ,p_effective_start_date         => l_per_effective_start_date
  ,p_effective_end_date           => l_per_effective_end_date
  ,p_comment_id                   => l_comment_id
  ,p_current_applicant_flag       => l_current_applicant_flag
  ,p_current_emp_or_apl_flag      => l_current_emp_or_apl_flag
  ,p_current_employee_flag        => l_current_employee_flag
  ,p_full_name                    => l_full_name
  ,p_name_combination_warning     => l_name_combination_warning
  ,p_dob_null_warning             => p_assign_payroll_warning
  ,p_orig_hire_warning            => l_orig_hire_warning
  ,p_npw_number                   => l_npw_number
  ,p_original_date_of_hire        => l_original_date_of_hire
  ,p_per_information7             => l_new_hire_code
  );
 end if;
  -- end of bug3572499
  --
  hr_utility.set_location(l_proc,284);
  --
-- PTU : Following Code has been added

  hr_per_type_usage_internal.maintain_person_type_usage
  (p_effective_date       => l_hire_date
  ,p_person_id            => p_person_id
  ,p_person_type_id       => l_person_type_id
 --bug no 5105005
,p_datetrack_update_mode=> l_datetrack_mode
--bug no 5105005
  );
  --
  hr_utility.set_location(l_proc,286);
  --
 l_person_type_id1 :=
           hr_person_type_usage_info.get_default_person_type_id
                        (l_business_group_id
                        ,'EX_APL');

  hr_utility.set_location(l_proc,288);
  --
hr_per_type_usage_internal.maintain_person_type_usage
(p_effective_date       => l_hire_date
,p_person_id            => p_person_id
,p_person_type_id       => l_person_type_id1
);

-- PTU : End of changes

  hr_utility.set_location(l_proc,290);
  --
  -- Insert the period of service into per_periods_of_service by calling the
  -- Periods of Service table handler:
  --
  per_pds_ins.ins
  (p_business_group_id            => l_business_group_id
  ,p_person_id                    => p_person_id
  ,p_date_start                   => l_hire_date
  ,p_effective_date               => l_hire_date
  --
  ,p_period_of_service_id         => l_period_of_service_id
  ,p_object_version_number        => l_pds_object_version_number
  ,p_validate_df_flex             => false
);
  --
  hr_utility.set_location(l_proc,310);
  -- -----------------------------------------------------------------------+
  --                  Processing ACCEPTED APL ASG                           +
  -- -----------------------------------------------------------------------+
  --
  --  All accepted applicant assignments are changed to employee assignments
  --  with default employee assignment.(ACTIVE_ASSIGN)
  --  1) Derive assignment_status_type_id for default 'ACTIVE_ASSIGN'.
  --  2) Update the assignments by calling the upd procedure in the
  --     PER_ASSIGNMENTS_F table handler(This is a datetrack UPDATE mode
  --     operation)
  --  3) When the accepted assignments are multiple, the primary flag of the
  --     record not specified by P_ASSIGNMENT_ID is set to 'N'.
  --
  -- reset l_assignment_status_type_id for updating the accepted assignments
  l_assignment_status_type_id := hr_api.g_number;
  --
  per_asg_bus1.chk_assignment_status_type
  (p_assignment_status_type_id => l_assignment_status_type_id
  ,p_business_group_id         => l_business_group_id
  ,p_legislation_code          => l_legislation_code
  ,p_expected_system_status    => 'ACTIVE_ASSIGN'
  );
  --
  hr_utility.set_location(l_proc,320);
  l_oversubscribed_vacancy_id:=null;
  --
  --
  -- start of bug 4681211
  -- added an if condition to support the bug 4681211
  -- and the ' else ' part of the the api will work as it was previously
 if p_assignment_id is not null then
 -- first process the primary assignment id
 -- so that it can generate the assignment Number correctly.
 -- bug 4681211 added
  hr_utility.set_location(l_proc,321);
     open csr_get_accepted_pmry;
         fetch csr_get_accepted_pmry
         into  l_assignment_id,
               l_asg_object_version_number,
               l_vacancy_id;
     if csr_get_accepted_pmry%FOUND then
        --
        hr_utility.set_location(l_proc,340);
        --
        l_primary_flag       := 'Y';
        --
        if l_multi_flag = TRUE then
          --
          if l_assignment_id <> p_assignment_id then
             --
             hr_utility.set_location(l_proc,360);
             --
             l_primary_flag := 'N';
             --
          end if;
          --
          hr_utility.set_location(l_proc,370);
          --
        end if;
        --
        hr_utility.set_location(l_proc,380);
        --

  --Fix For Bug 5749371 Starts

        open csr_existing_SCL(l_assignment_id);
        fetch csr_existing_SCL into l_soft_coding_keyflex_id,l_payroll_id;
        close csr_existing_SCL;

        if l_soft_coding_keyflex_id is null and l_payroll_id is not null and p_source=true then
            l_soft_coding_keyflex_id := l_dummy_soft_coding_keyflex_id;
            else
            l_soft_coding_keyflex_id := hr_api.g_number;
        end if;

  --Fix For Bug 5749371 Ends

        per_asg_upd.upd
        (p_assignment_id                => l_assignment_id,
         p_object_version_number        => l_asg_object_version_number,
         p_effective_date               => l_hire_date,
         p_datetrack_mode               => 'UPDATE',
         p_assignment_status_type_id    => l_assignment_status_type_id,
         p_assignment_type              => 'E',
         p_primary_flag                 => l_primary_flag,
         p_period_of_service_id         => l_period_of_service_id,
         --
         p_effective_start_date         => l_effective_start_date,
         p_effective_end_date           => l_effective_end_date,
         p_business_group_id            => l_business_group_id,
         p_comment_id                   => l_comment_id,
         p_validation_start_date        => l_validation_start_date,
         p_validation_end_date          => l_validation_end_date,
         p_payroll_id_updated           => l_payroll_id_updated,
         p_other_manager_warning        => l_other_manager_warning,
         p_no_managers_warning          => l_no_managers_warning,
         p_org_now_no_manager_warning   => l_org_now_no_manager_warning,
         p_hourly_salaried_warning      => l_hourly_salaried_warning,
         p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id  --Fix For Bug 5749371
        );
        --
    --
    -- 115.71 (START)
    --
        hr_utility.set_location(l_proc,385);
        --
        -- Handle potentially overlapping PDS due to rehire before FPD
        --
        hr_employee_api.manage_rehire_primary_asgs
          (p_person_id   => p_person_id
          ,p_rehire_date => l_hire_date
          ,p_cancel      => 'N'
          );
        --

    --
    -- 115.71 (END)
    --
        --
       IRC_ASG_STATUS_API.create_irc_asg_status
           (p_assignment_id               => l_assignment_id
           , p_assignment_status_type_id  => l_assignment_status_type_id

    -- Bug: 2416817 Starts here.
    -- Replaced l_effective_end_date with l_effective_start_date to ensure
    -- Assignment status change is recorded properly in IRC tables.

           , p_status_change_date         => l_effective_start_date

    -- Bug :2416817 Ends here.

           , p_assignment_status_id       => l_assignment_status_id
           , p_object_version_number      => l_asg_status_ovn);

 -- Added the below api call for bug 7540870.

 IRC_OFFERS_API.close_offer
       ( p_validate                   => false
        ,p_effective_date             => l_effective_start_date-1
        ,p_applicant_assignment_id    => l_assignment_id
        ,p_change_reason              => 'APL_HIRED'
       );


       open csr_vacs(l_vacancy_id);
        fetch csr_vacs into l_dummy;
        if csr_vacs%found then
          close csr_vacs;
          l_oversubscribed_vacancy_id:=l_vacancy_id;
        else
          close csr_vacs;
        end if;
        hr_utility.set_location(l_proc,390);
        --
        -- 2833630: Any salary proposals attached to the APL assignment should have
        -- the salary change date updated to be >= the hire date.
        --
             if p_source = false then
                  update_salary_proposal(l_assignment_id, l_hire_date);
             end if;--fix for bug 5354681
        --
        hr_utility.set_location(l_proc,395);
       --
        hr_utility.set_location(l_proc,410);
      --
             close csr_get_accepted_pmry;
        else
            close csr_get_accepted_pmry;
       end if;

 hr_utility.set_location(l_proc,322);
  open csr_get_accepted_non;
  loop
    fetch csr_get_accepted_non
     into  l_assignment_id,
           l_asg_object_version_number,
           l_vacancy_id;
    exit when csr_get_accepted_non%NOTFOUND;
    --
    hr_utility.set_location(l_proc,340);
    --
    l_primary_flag       := 'Y';
    --
    if l_multi_flag = TRUE then
      --
      if l_assignment_id <> p_assignment_id then
         --
         hr_utility.set_location(l_proc,360);
         --
         l_primary_flag := 'N';
         --
      end if;
      --
      hr_utility.set_location(l_proc,370);
      --
    end if;
    --
    hr_utility.set_location(l_proc,380);
    --

  --Fix For Bug 5749371 Starts

      open csr_existing_SCL(l_assignment_id);
        fetch csr_existing_SCL into l_soft_coding_keyflex_id,l_payroll_id;
        close csr_existing_SCL;

        if l_soft_coding_keyflex_id is null and l_payroll_id is not null and p_source=true then
            l_soft_coding_keyflex_id := l_dummy_soft_coding_keyflex_id;
            else
            l_soft_coding_keyflex_id := hr_api.g_number;
        end if;

  --Fix For Bug 5749371 Ends

    per_asg_upd.upd
    (p_assignment_id                => l_assignment_id,
     p_object_version_number        => l_asg_object_version_number,
     p_effective_date               => l_hire_date,
     p_datetrack_mode               => 'UPDATE',
     p_assignment_status_type_id    => l_assignment_status_type_id,
     p_assignment_type              => 'E',
     p_primary_flag                 => l_primary_flag,
     p_period_of_service_id         => l_period_of_service_id,
     --
     p_effective_start_date         => l_effective_start_date,
     p_effective_end_date           => l_effective_end_date,
     p_business_group_id            => l_business_group_id,
     p_comment_id                   => l_comment_id,
     p_validation_start_date        => l_validation_start_date,
     p_validation_end_date          => l_validation_end_date,
     p_payroll_id_updated           => l_payroll_id_updated,
     p_other_manager_warning        => l_other_manager_warning,
     p_no_managers_warning          => l_no_managers_warning,
     p_org_now_no_manager_warning   => l_org_now_no_manager_warning,
     p_hourly_salaried_warning      => l_hourly_salaried_warning,
     p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id  --Fix For Bug 5749371
    );
    --
--
-- 115.71 (START)
--
    hr_utility.set_location(l_proc,385);
    --
    -- Handle potentially overlapping PDS due to rehire before FPD
    --
    hr_employee_api.manage_rehire_primary_asgs
      (p_person_id   => p_person_id
      ,p_rehire_date => l_hire_date
      ,p_cancel      => 'N'
      );
    --

--
-- 115.71 (END)
--
    --
   IRC_ASG_STATUS_API.create_irc_asg_status
       (p_assignment_id               => l_assignment_id
       , p_assignment_status_type_id  => l_assignment_status_type_id

-- Bug: 2416817 Starts here.
-- Replaced l_effective_end_date with l_effective_start_date to ensure
-- Assignment status change is recorded properly in IRC tables.

       , p_status_change_date         => l_effective_start_date

-- Bug :2416817 Ends here.

       , p_assignment_status_id       => l_assignment_status_id
       , p_object_version_number      => l_asg_status_ovn);


 -- Added the below api call for bug 7540870.
 IRC_OFFERS_API.close_offer
       ( p_validate                   => false
        ,p_effective_date             => l_effective_start_date-1
        ,p_applicant_assignment_id    => l_assignment_id
        ,p_change_reason              => 'APL_HIRED'
       );

   open csr_vacs(l_vacancy_id);
    fetch csr_vacs into l_dummy;
    if csr_vacs%found then
      close csr_vacs;
      l_oversubscribed_vacancy_id:=l_vacancy_id;
    else
      close csr_vacs;
    end if;
    hr_utility.set_location(l_proc,390);
    --
    -- 2833630: Any salary proposals attached to the APL assignment should have
    -- the salary change date updated to be >= the hire date.
    --
    if p_source = false then
    update_salary_proposal(l_assignment_id, l_hire_date);
    end if;--fix for bug 5354681
    --
    hr_utility.set_location(l_proc,395);
  end loop;
  --
  hr_utility.set_location(l_proc,410);
  --
  close csr_get_accepted_non;

else
-- case when p_assignment_id is null
-- this works as how it was previoulsy
 hr_utility.set_location(l_proc,323);
  hr_utility.set_location('inside the else part',910);
open csr_get_accepted;
  loop
    fetch csr_get_accepted
     into  l_assignment_id,
           l_asg_object_version_number,
           l_vacancy_id;
    exit when csr_get_accepted%NOTFOUND;
    --
    hr_utility.set_location(l_proc,340);
    --
    l_primary_flag       := 'Y';
    --
    if l_multi_flag = TRUE then
      --
      if l_assignment_id <> p_assignment_id then
         --
         hr_utility.set_location(l_proc,360);
         --
         l_primary_flag := 'N';
         --
      end if;
      --
      hr_utility.set_location(l_proc,370);
      --
    end if;
    --
    hr_utility.set_location(l_proc,380);
    --
    per_asg_upd.upd
    (p_assignment_id                => l_assignment_id,
     p_object_version_number        => l_asg_object_version_number,
     p_effective_date               => l_hire_date,
     p_datetrack_mode               => 'UPDATE',
     p_assignment_status_type_id    => l_assignment_status_type_id,
     p_assignment_type              => 'E',
     p_primary_flag                 => l_primary_flag,
     p_period_of_service_id         => l_period_of_service_id,
     --
     p_effective_start_date         => l_effective_start_date,
     p_effective_end_date           => l_effective_end_date,
     p_business_group_id            => l_business_group_id,
     p_comment_id                   => l_comment_id,
     p_validation_start_date        => l_validation_start_date,
     p_validation_end_date          => l_validation_end_date,
     p_payroll_id_updated           => l_payroll_id_updated,
     p_other_manager_warning        => l_other_manager_warning,
     p_no_managers_warning          => l_no_managers_warning,
     p_org_now_no_manager_warning   => l_org_now_no_manager_warning,
     p_hourly_salaried_warning      => l_hourly_salaried_warning
    );
    --
--
-- 115.71 (START)
--
    hr_utility.set_location(l_proc,385);
    --
    -- Handle potentially overlapping PDS due to rehire before FPD
    --
    hr_employee_api.manage_rehire_primary_asgs
      (p_person_id   => p_person_id
      ,p_rehire_date => l_hire_date
      ,p_cancel      => 'N'
      );
    --

--
-- 115.71 (END)
--
    --
   IRC_ASG_STATUS_API.create_irc_asg_status
       (p_assignment_id               => l_assignment_id
       , p_assignment_status_type_id  => l_assignment_status_type_id

-- Bug: 2416817 Starts here.
-- Replaced l_effective_end_date with l_effective_start_date to ensure
-- Assignment status change is recorded properly in IRC tables.

       , p_status_change_date         => l_effective_start_date

-- Bug :2416817 Ends here.

       , p_assignment_status_id       => l_assignment_status_id
       , p_object_version_number      => l_asg_status_ovn);
 -- Added the below api call for bug 7540870.
 IRC_OFFERS_API.close_offer
       ( p_validate                   => false
        ,p_effective_date             => l_effective_start_date-1
        ,p_applicant_assignment_id    => l_assignment_id
        ,p_change_reason              => 'APL_HIRED'
       );

 hr_utility.set_location(l_proc,386);
   open csr_vacs(l_vacancy_id);
    fetch csr_vacs into l_dummy;
    if csr_vacs%found then
      close csr_vacs;
      l_oversubscribed_vacancy_id:=l_vacancy_id;
    else
      close csr_vacs;
    end if;
    hr_utility.set_location(l_proc,390);
    --
    -- 2833630: Any salary proposals attached to the APL assignment should have
    -- the salary change date updated to be >= the hire date.
    --
    if p_source = false then
    update_salary_proposal(l_assignment_id, l_hire_date);
    end if;--fix for bug 5354681
    --
    hr_utility.set_location(l_proc,395);
  end loop;
  --
  hr_utility.set_location(l_proc,410);
  --
  close csr_get_accepted;

end if;
-- end of the bug 4681211
--
  -- 1766066: added call for contact start date enh.
  --
  per_people12_pkg.maintain_coverage(p_person_id      => p_person_id
                                    ,p_type           => 'EMP'
                                    );
  -- 1766066 end.

  --start changes for bug 6598795
  hr_assignment.update_assgn_context_value (l_business_group_id,
				   p_person_id,
				   l_assignment_id,
				   p_hire_date);

  SELECT object_version_number
  INTO l_asg_object_Version_number
  FROM per_all_assignments_f
  WHERE business_group_id  = l_business_group_id
  and person_id = p_person_id
  and assignment_id = l_assignment_id
  and effective_start_Date = p_hire_date;
  --end changes for bug 6598795

  --Bug 8831084  Fix Starts

   open get_business_group(l_ass_id);
   fetch get_business_group into l_bg_id;
  --
   if get_business_group%NOTFOUND then
      close get_business_group;
      l_bg_id := hr_general.get_business_group_id;
   else
      close get_business_group;
   end if;
    --

   hrentmnt.maintain_entries_asg (
    p_assignment_id         => l_ass_id,
    p_business_group_id     => l_bg_id,
    p_operation             => 'ASG_CRITERIA',
    p_actual_term_date      => null,
    p_last_standard_date    => null,
    p_final_process_date    => null,
    p_dt_mode               => 'UPDATE',
    p_validation_start_date => p_per_effective_start_date,
    p_validation_end_date   => p_per_effective_end_date
   );

   --
   --Bug 8831084 Fix ends

  --
  -- Call After Process User Hook for hire_applicant
  --
  begin
    hr_applicant_bk2.hire_applicant_a
      (
       p_hire_date                  => l_hire_date,
       p_person_id                  => p_person_id,
       p_assignment_id              => p_assignment_id,
       p_person_type_id             => p_person_type_id,
       p_national_identifier        => p_national_identifier,
       p_per_object_version_number  => l_per_object_version_number,
       p_employee_number            => l_employee_number,
       p_per_effective_start_date   => l_per_effective_start_date,
       p_per_effective_end_date     => l_per_effective_end_date,
       p_unaccepted_asg_del_warning => l_unaccepted_asg_del_warning,
       p_assign_payroll_warning     => l_assign_payroll_warning,
       p_oversubscribed_vacancy_id  => l_oversubscribed_vacancy_id,
       p_original_date_of_hire      => l_original_date_of_hire
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HIRE_APPLICANT'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of the after hook for hire_applicant
  --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
    --
    p_employee_number              := l_employee_number;
    p_per_object_version_number    := l_per_object_version_number;
    p_per_effective_start_date     := l_per_effective_start_date;
    p_per_effective_end_date       := l_per_effective_end_date;
    p_unaccepted_asg_del_warning   := l_unaccepted_asg_del_warning;
    p_assign_payroll_warning       := l_assign_payroll_warning;
    p_oversubscribed_vacancy_id    := l_oversubscribed_vacancy_id;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 250);
    --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO hire_applicant;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Set OUT parameters to null
    --
    p_employee_number              := null;
    p_per_object_version_number    := null;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_unaccepted_asg_del_warning   := l_unaccepted_asg_del_warning;
    p_assign_payroll_warning       := l_assign_payroll_warning;
    p_oversubscribed_vacancy_id    := l_oversubscribed_vacancy_id;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 250);
   --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --

    p_per_object_version_number    := lv_per_object_version_number ;
    p_employee_number              := lv_employee_number ;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_unaccepted_asg_del_warning   := null;
    p_assign_payroll_warning       := null;
    p_oversubscribed_vacancy_id    := null;

    ROLLBACK TO hire_applicant;

    --
    hr_utility.set_location(' Leaving:'||l_proc, 255);
    raise;
    -- End of fix.
    --
end hire_applicant;
--
-- OLD
-- ----------------------------------------------------------------------------
-- |-------------------------< terminate_applicant >--------------------------|
-- ----------------------------------------------------------------------------
-- OLD
PROCEDURE terminate_applicant
  (p_validate                     IN     BOOLEAN                                     --DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        --DEFAULT hr_api.g_number
  ,p_termination_reason           IN     per_applications.termination_reason%TYPE    --DEFAULT NULL
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  )
IS
Begin
  hr_applicant_api.terminate_applicant
   (p_validate                   => p_validate
   ,p_effective_date             => p_effective_date
   ,p_person_id                  => p_person_id
   ,p_object_version_number      => p_object_version_number
   ,p_person_type_id             => p_person_type_id
   ,p_termination_reason         => p_termination_reason
   ,p_effective_start_date       => p_effective_start_date
   ,p_effective_end_date         => p_effective_end_date
   ,p_assignment_status_type_id  => Null
   );
end terminate_applicant;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< terminate_applicant(New1) >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE terminate_applicant
  (p_validate                     IN     BOOLEAN
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE
  ,p_termination_reason           IN     per_applications.termination_reason%TYPE
  ,p_assignment_status_type_id    IN     per_all_assignments_f.assignment_status_type_id%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  )
IS
  l_warning boolean;
BEGIN
   hr_applicant_api.terminate_applicant
   (p_validate                   => p_validate
   ,p_effective_date             => p_effective_date
   ,p_person_id                  => p_person_id
   ,p_object_version_number      => p_object_version_number
   ,p_person_type_id             => p_person_type_id
   ,p_termination_reason         => p_termination_reason
   ,p_effective_start_date       => p_effective_start_date
   ,p_effective_end_date         => p_effective_end_date
   ,p_assignment_status_type_id  => p_assignment_status_type_id
   ,p_remove_fut_asg_warning     => l_warning  -- 3652025
   );
END terminate_applicant;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< terminate_applicant(New2) >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE terminate_applicant
  (p_validate                     IN     BOOLEAN
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE
  ,p_termination_reason           IN     per_applications.termination_reason%TYPE
  ,p_assignment_status_type_id    IN     per_all_assignments_f.assignment_status_type_id%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_remove_fut_asg_warning          OUT NOCOPY BOOLEAN  -- 3652025
  )
IS
BEGIN
   hr_applicant_api.terminate_applicant
   (p_validate                   => p_validate
   ,p_effective_date             => p_effective_date
   ,p_person_id                  => p_person_id
   ,p_object_version_number      => p_object_version_number
   ,p_person_type_id             => p_person_type_id
   ,p_termination_reason         => p_termination_reason
   ,p_change_reason              => NULL -- 4066579
   ,p_effective_start_date       => p_effective_start_date
   ,p_effective_end_date         => p_effective_end_date
   ,p_assignment_status_type_id  => p_assignment_status_type_id
   ,p_remove_fut_asg_warning     => p_remove_fut_asg_warning
   );
END terminate_applicant;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< terminate_applicant(New3) >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE terminate_applicant
  (p_validate                     IN     BOOLEAN
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE
  ,p_termination_reason           IN     per_applications.termination_reason%TYPE
  ,p_assignment_status_type_id    IN     per_all_assignments_f.assignment_status_type_id%TYPE
  ,p_change_reason                IN     per_all_assignments_f.change_reason%TYPE -- 4066579
  ,p_status_change_comments       IN  irc_assignment_statuses.status_change_comments%TYPE -- 8732296
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_remove_fut_asg_warning          OUT NOCOPY BOOLEAN  -- 3652025
  )
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'terminate_applicant';
  --
  l_legislation_code             varchar2(30);
  l_asg_status_ovn               number;
  l_effective_date               DATE;
  --
  l_object_version_number        CONSTANT per_all_people_f.object_version_number%TYPE := p_object_version_number;
  l_person_type_id               per_person_types.person_type_id%TYPE                 := p_person_type_id;
  l_person_type_id1              per_person_types.person_type_id%TYPE;
  --
  l_assignment_status_id    number;
  l_assignment_status_type_id    number;
  l_validation_start_date        DATE;
  l_validation_end_date          DATE;
  l_effective_start_date         DATE;
  l_effective_end_date           DATE;
  --
  l_business_group_id            hr_all_organization_units.organization_id%TYPE;
  l_org_now_no_manager_warning   BOOLEAN;
  l_system_person_type           per_person_types.system_person_type%TYPE;
  l_comment_id                   hr_comments.comment_id%TYPE;
  l_current_applicant_flag       per_all_people_f.current_applicant_flag%TYPE;
  l_current_emp_or_apl_flag      per_all_people_f.current_emp_or_apl_flag%TYPE;
  l_current_employee_flag        per_all_people_f.current_employee_flag%TYPE;
  l_full_name                    per_all_people_f.full_name%TYPE;
  l_name_combination_warning     BOOLEAN;
  l_dob_null_warning             BOOLEAN;
  l_orig_hire_warning            BOOLEAN;
  --
  lv_object_version_number       per_all_people_f.object_version_number%TYPE := p_object_version_number ;
  l_remove_future_asg_warning    BOOLEAN;
  l_count                        NUMBER;
  --fix for bug 7229710 Starts here.
  l_vacancy_id                   number;



  --
  -- Local cursors
  --
  Cursor csr_vacancy_id(l_assg_id number) is
  Select vacancy_id
  From per_all_assignments_f
  Where assignment_id = l_assg_id
  And p_effective_date between effective_start_date and effective_end_date;
  --fix for bug 7229710 Ends here.

  CURSOR csr_applications
    (p_effective_date               IN     DATE
    ,p_person_id                    IN     per_all_people_f.person_id%TYPE
    )
  IS
    SELECT apl.application_id
          ,apl.object_version_number
          ,per.business_group_id
          ,per.applicant_number
          ,per.employee_number
          ,pet.system_person_type
          ,per.npw_number
      FROM per_applications apl
          ,per_person_types pet
          ,per_people_f per
     WHERE p_effective_date BETWEEN apl.date_received
                                AND NVL(apl.date_end,p_effective_date)
       AND apl.person_id = per.person_id
       AND pet.person_type_id = per.person_type_id
       AND p_effective_date BETWEEN per.effective_start_date
                                AND per.effective_end_date
       AND per.person_id = p_person_id;
  l_application                  csr_applications%ROWTYPE;
  --
  CURSOR csr_assignments
    (p_effective_date               IN     DATE
    ,p_person_id                    IN     per_all_people_f.person_id%TYPE
    )
  IS
    SELECT asg.assignment_id
          ,asg.object_version_number
          ,asg.effective_end_date     -- 3652025
          ,asg.assignment_status_type_id --7229710
      FROM per_all_assignments_f asg
     WHERE asg.person_id = p_person_id
       AND p_effective_date+1 BETWEEN asg.effective_start_date
                                AND asg.effective_end_date
       AND asg.assignment_type = 'A';
  --
  -- 3652025 >>
  CURSOR csr_get_future_apl_asg(cp_person_id      number
                              , cp_effective_date date
                              , cp_application_id number) IS
    SELECT as2.assignment_id, as2.effective_start_date, as2.object_version_number
    FROM per_all_assignments_f as2
    WHERE as2.person_id     = cp_person_id
    AND as2.application_id  = cp_application_id
    AND as2.assignment_type = 'A'
    AND as2.effective_start_date > cp_effective_date
    AND not exists
    (select 'N'
       from per_all_assignments_f as1
      where as1.assignment_id = as2.assignment_id
        and as1.effective_start_date < as2.effective_start_date)
    ORDER BY as2.effective_start_date, as2.assignment_id ASC;

      CURSOR csr_lock_person(cp_person_id number, cp_termination_date date) IS
        SELECT null
          FROM per_all_people_f
         WHERE person_id = cp_person_id
           AND (effective_start_date > cp_termination_date
                OR
                cp_termination_date between effective_start_date
                                        and effective_end_date)
         for update nowait;
    --
    CURSOR csr_lock_ptu(cp_person_id number, cp_termination_date date) IS
        SELECT null
          FROM per_person_type_usages_f ptu
              ,per_person_types         ppt
         WHERE person_id = cp_person_id
           AND (effective_start_date > cp_termination_date
                OR
                cp_termination_date between effective_start_date
                                        and effective_end_date)
           AND ptu.person_type_id = ppt.person_type_id
           AND ppt.system_person_type in ('APL','EX_APL')
         -- for update nowait;     for bug 6433245
  	    for update of ptu.person_id nowait;
   -- <<
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Ensure mandatory arguments have been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'person_id'
    ,p_argument_value               => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  -- Truncate all date parameters passed in
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Issue savepoint
  --
  SAVEPOINT terminate_applicant;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Call Before Process User Hook
  --
  BEGIN
    hr_applicant_bk3.terminate_applicant_b
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_object_version_number        => p_object_version_number
      ,p_person_type_id               => p_person_type_id
      ,p_termination_reason           => p_termination_reason
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'TERMINATE_APPLICANT'
         ,p_hook_type         => 'B'
         );
  END;
  --
  hr_utility.set_location(l_proc,30);
  --
  -- Derive application details
  --
  OPEN csr_applications
    (p_effective_date           => l_effective_date
    ,p_person_id                => p_person_id
    );
  FETCH csr_applications INTO l_application;
  IF (csr_applications%NOTFOUND)
  THEN
    CLOSE csr_applications;
    hr_utility.set_message(801,'HR_51011_PER_NOT_EXIST_DATE');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_applications;
  --
  hr_utility.set_location(l_proc,40);
  --
  -- If person_type_id is not null check it corresponds to the correct type
  -- of ex-applicant is currently active and in the correct business group,
  -- otherwise set the person type id the active default for 'ex-applicant'
  -- in the correct business group.
  -- With PTU changes, the person_type_id must be flavour of EX_APL, so modify chk call
  -- so that l_person_type_id passes the validated flavour to PTU
  --
--
-- Bug Number : 2929504. Added condition for EX_EM_APL
--
-- not needed, these conditions are handled within the
-- update_per_ptu_to_EX_APL procedure
--
--  IF l_application.system_person_type = 'EMP_APL'
--  THEN
--    l_system_person_type := 'EMP';
--     hr_utility.set_location(l_proc,42);
--  ELSIF l_application.system_person_type = 'EX_EMP_APL'
--  THEN
--    l_system_person_type := 'EX_EMP';
--    hr_utility.set_location(l_proc,44);
--  ELSE
--    l_system_person_type := 'EX_APL';
--    hr_utility.set_location(l_proc,46);
--  END IF;
--
-- End of Bug 2929504.
--
  per_per_bus.chk_person_type
    (p_person_type_id               => l_person_type_id
    ,p_business_group_id            => l_application.business_group_id
    ,p_expected_sys_type            => 'EX_APL'
    );
  --
  hr_utility.set_location(l_proc,50);
  --
  --
  -- Lock person record
  --
  open csr_lock_person(p_person_id, l_effective_date);
  close csr_lock_person;
  --
  -- Lock the PTU records
  --
  open csr_lock_ptu(p_person_id, l_effective_date);
  close csr_lock_ptu;
  /*
  per_per_shd.lck
    (p_effective_date           => l_effective_date + 1
    ,p_datetrack_mode           => hr_api.g_update
    ,p_person_id                => p_person_id
    ,p_object_version_number    => p_object_version_number
    ,p_validation_start_date    => l_validation_start_date
    ,p_validation_end_date      => l_validation_end_date
    );
  */
  --
  hr_utility.set_location(l_proc,60);
  --
  -- Lock application record
  --
  per_apl_shd.lck
    (p_application_id           => l_application.application_id
    ,p_object_version_number    => l_application.object_version_number
    );
  --
  hr_utility.set_location(l_proc,70);
  --
  -- Terminate all applicant assignments for person
  --
  -- Remove future-dated assignments
  l_count := 0;
  FOR l_fut_asg in csr_get_future_apl_asg
            (cp_person_id      => p_person_id
            ,cp_effective_date => l_effective_date
            ,cp_application_id => l_application.application_id)
  LOOP
        per_asg_del.del
          (p_assignment_id                => l_fut_asg.assignment_id
          ,p_object_version_number        => l_fut_asg.object_version_number
          ,p_effective_date               => l_fut_asg.effective_start_date
          ,p_datetrack_mode               => hr_api.g_zap
          ,p_effective_start_date         => l_effective_start_date
          ,p_effective_end_date           => l_effective_end_date
          ,p_business_group_id            => l_business_group_id
          ,p_validation_start_date        => l_validation_start_date
          ,p_validation_end_date          => l_validation_end_date
          ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
          );
        l_count := l_count + 1;
  END LOOP;
  --
  FOR l_assignment IN csr_assignments
    (p_effective_date               => l_effective_date
    ,p_person_id                    => p_person_id
    )
  LOOP
    if l_assignment.effective_end_date <> hr_api.g_eot then
       -- delete future DT updates
       per_asg_del.del
         (p_assignment_id                => l_assignment.assignment_id
         ,p_object_version_number        => l_assignment.object_version_number
         ,p_effective_date               => l_effective_date
         ,p_datetrack_mode               => hr_api.g_future_change
         ,p_effective_start_date         => l_effective_start_date
         ,p_effective_end_date           => l_effective_end_date
         ,p_business_group_id            => l_business_group_id
         ,p_validation_start_date        => l_validation_start_date
         ,p_validation_end_date          => l_validation_end_date
         ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
         );

       per_asg_del.del
         (p_assignment_id                => l_assignment.assignment_id
         ,p_object_version_number        => l_assignment.object_version_number
         ,p_effective_date               => l_effective_date
         ,p_datetrack_mode               => hr_api.g_delete
         ,p_effective_start_date         => l_effective_start_date
         ,p_effective_end_date           => l_effective_end_date
         ,p_business_group_id            => l_business_group_id
         ,p_validation_start_date        => l_validation_start_date
         ,p_validation_end_date          => l_validation_end_date
         ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
         );

       l_count := l_count + 1;
    else
       per_asg_del.del
         (p_assignment_id                => l_assignment.assignment_id
         ,p_object_version_number        => l_assignment.object_version_number
         ,p_effective_date               => l_effective_date
         ,p_datetrack_mode               => hr_api.g_delete
         ,p_effective_start_date         => l_effective_start_date
         ,p_effective_end_date           => l_effective_end_date
         ,p_business_group_id            => l_business_group_id
         ,p_validation_start_date        => l_validation_start_date
         ,p_validation_end_date          => l_validation_end_date
         ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
         );
    end if;
    --
    l_legislation_code := per_asg_bus1.return_legislation_code
      (l_assignment.assignment_id);
--
    if p_assignment_status_type_id is NULL then -- #3371944
         per_people3_pkg.get_default_person_type
         (p_required_type     => 'TERM_APL'
         ,p_business_group_id => l_business_group_id
         ,p_legislation_code  => l_legislation_code
         ,p_person_type       => l_assignment_status_type_id
         );
   --
   -- #3371944 start
    else
         l_assignment_status_type_id := p_assignment_status_type_id;
         per_asg_bus1.chk_assignment_status_type
         (p_assignment_status_type_id => l_assignment_status_type_id
         ,p_business_group_id         => l_business_group_id
         ,p_legislation_code          => l_legislation_code
         ,p_expected_system_status    => 'TERM_APL'
         );
    end if;
    -- #3371944 end
    --

    --fix for bug 7229710 Starts here.

    delete from per_letter_request_lines plrl
    where plrl.assignment_id = l_assignment.assignment_id
    and   plrl.assignment_status_type_id = l_assignment.assignment_status_type_id
    and   exists
         (select null
          from per_letter_requests plr
          where plr.letter_request_id = plrl.letter_request_id
          and   plr.request_status = 'PENDING'
          and   plr.auto_or_manual = 'AUTO');

    per_app_asg_pkg.cleanup_letters
    (p_assignment_id => l_assignment.assignment_id);
  --
  -- Check if a letter request is necessary for the assignment.
  --
open csr_vacancy_id(l_assignment.assignment_id);
fetch csr_vacancy_id into l_vacancy_id;
if csr_vacancy_id%NOTFOUND then null;
end if;
close csr_vacancy_id;

  per_applicant_pkg.check_for_letter_requests
    (p_business_group_id            => l_business_group_id
    ,p_per_system_status            => null
    ,p_assignment_status_type_id    => l_assignment_status_type_id
    ,p_person_id                    => p_person_id
    ,p_assignment_id                => l_assignment.assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_validation_start_date        => l_validation_start_date
    ,p_vacancy_id 		    => l_vacancy_id
    );


 --fix for bug 7229710 Ends here.

    IRC_ASG_STATUS_API.create_irc_asg_status
       (p_assignment_id               => l_assignment.assignment_id
       , p_assignment_status_type_id  => l_assignment_status_type_id
       , p_status_change_date         => p_effective_date -- CHANGE FOR THE BUG 5630218 l_effective_start_date --2754362 l_effective_end_date
       , p_status_change_reason       => p_change_reason  -- 4066579
       , p_assignment_status_id       => l_assignment_status_id
       , p_status_change_comments     => p_status_change_comments -- 8732296
       , p_object_version_number      => l_asg_status_ovn);
    --
    -- Close the offers (if any) for this applicant
    --
    IRC_OFFERS_API.close_offer
       ( p_validate                   => p_validate
        ,p_effective_date             => p_effective_date
        ,p_applicant_assignment_id    => l_assignment.assignment_id
        ,p_change_reason              => 'WITHDRAWAL' -- fix for bug 8635684 'MANUAL_CLOSURE' --fix for bug 7540870.
       );

  END LOOP;
  --
  if l_count > 0 then
     l_remove_future_asg_warning := TRUE;
  else
     l_remove_future_asg_warning := FALSE;
  end if;
  --
  hr_utility.set_location(l_proc,80);
  --
  -- Update person and ptu records
  --
  hr_applicant_internal.Update_PER_PTU_To_EX_APL
     (p_business_group_id         => l_application.business_group_id
     ,p_person_id                 => p_person_id
     ,p_effective_date            => l_effective_date+1 -- when becomes EX_APL
     ,p_person_type_id            => l_person_type_id
     ,p_per_effective_start_date  => l_effective_start_date
     ,p_per_effective_end_date    => l_effective_end_date
     );
  --
  hr_utility.set_location(l_proc,90);
  --
  -- End the application
  --
  UPDATE per_applications
    set date_end = l_effective_date
       ,termination_reason = p_termination_reason
   WHERE application_id = l_application.application_id;
  /*
  this raises error when calling per_apl_bus.chk_date_end
  per_apl_upd.upd
    (p_application_id               => l_application.application_id
    ,p_object_version_number        => l_application.object_version_number
    ,p_effective_date               => l_effective_date
    ,p_date_end                     => l_effective_date
    ,p_termination_reason           => p_termination_reason
    );
   */
  --
  hr_utility.set_location(l_proc,100);

-- PTU : Added
-- l_person_type_id1 :=
--           hr_person_type_usage_info.get_default_person_type_id
--                        (l_business_group_id
--                        ,l_system_person_type
--                      );
-- PTU : End of Changes
  -- Update person details
  --
  --
  --per_per_upd.upd
  --  (p_person_id                    => p_person_id
  --  ,p_object_version_number        => p_object_version_number
  --  ,p_effective_date               => l_effective_date + 1
  --  ,p_applicant_number             => l_application.applicant_number
  --   ,p_employee_number              => l_application.employee_number
  --  ,p_datetrack_mode               => hr_api.g_update
  --  ,p_person_type_id               => l_person_type_id1
  --  ,p_effective_start_date         => l_effective_start_date
  --  ,p_effective_end_date           => l_effective_end_date
  --  ,p_comment_id                   => l_comment_id
  --  ,p_current_applicant_flag       => l_current_applicant_flag
  --  ,p_current_emp_or_apl_flag      => l_current_emp_or_apl_flag
  --  ,p_current_employee_flag        => l_current_employee_flag
  --  ,p_full_name                    => l_full_name
  --  ,p_name_combination_warning     => l_name_combination_warning
  --  ,p_dob_null_warning             => l_dob_null_warning
  --  ,p_orig_hire_warning            => l_orig_hire_warning
  --  ,p_npw_number                   => l_application.npw_number
  --  );
  --
  --
  -- Maintain person type usage records
  --
  -- PTU : Commented

--  hr_per_type_usage_internal.maintain_ptu
--    (p_person_id                    => p_person_id
--    ,p_action                       => 'TERM_APL'
--    ,p_business_group_id            => l_application.business_group_id
--    ,p_actual_termination_date      => l_effective_date
--    );
  --
-- PTU : Following Code has been added
--
--  hr_utility.set_location(l_proc,100);
  --
  --  hr_per_type_usage_internal.maintain_person_type_usage
  --  (p_effective_date       => l_effective_date + 1
  --  ,p_person_id            => p_person_id
  --  ,p_person_type_id       => l_person_type_id
  --  );

-- PTU : End of changes

--  hr_utility.set_location(l_proc,110);
  --
  -- Call After Process User Hook
  --
  BEGIN
    hr_applicant_bk3.terminate_applicant_a
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_object_version_number        => p_object_version_number
      ,p_person_type_id               => p_person_type_id
      ,p_termination_reason           => p_termination_reason
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_remove_fut_asg_warning       => l_remove_future_asg_warning
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'TERMINATE_APPLICANT'
         ,p_hook_type         => 'A'
         );
  END;
  --
  hr_utility.set_location(l_proc,120);
  --
  -- When in validation only mode raise validate enabled exception
  --
  IF p_validate
  THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set OUT parameters
  --
  p_effective_start_date         := l_effective_start_date;
  p_effective_end_date           := l_effective_end_date;
  p_remove_fut_asg_warning       := l_remove_future_asg_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc,1000);
--
EXCEPTION
  WHEN hr_api.validate_enabled
  THEN
    --
    -- In validation only mode
    -- Rollback to savepoint
    -- Set relevant output warning arguments
    -- Reset any key or derived arguments
    --
    ROLLBACK TO terminate_applicant;
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;
    p_remove_fut_asg_warning       := NULL;
  --
  WHEN OTHERS
  THEN
    --
    -- Validation or unexpected error occured
    -- Rollback to savepoint
    -- Re-raise exception
    --
    p_object_version_number        := lv_object_version_number;
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;

    ROLLBACK TO terminate_applicant;
    RAISE;
--
END terminate_applicant;
--
-- OLD
-- ----------------------------------------------------------------------------
-- |-------------------------< convert_to_applicant >-------------------------|
-- ----------------------------------------------------------------------------
-- OLD
PROCEDURE convert_to_applicant
  (p_validate                     IN     BOOLEAN                                     --DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_applicant_number             IN OUT NOCOPY per_all_people_f.applicant_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        --DEFAULT NULL
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ) IS
  l_warning boolean;
BEGIN
   hr_applicant_api.convert_to_applicant
     (p_validate                     => p_validate
     ,p_effective_date               => p_effective_date
     ,p_person_id                    => p_person_id
     ,p_object_version_number        => p_object_version_number
     ,p_applicant_number             => p_applicant_number
     ,p_person_type_id               => p_person_type_id
     ,p_effective_start_date         => p_effective_start_date
     ,p_effective_end_date           => p_effective_end_date
     ,p_appl_override_warning        => l_warning
     );
END;
-- NEW
-- ----------------------------------------------------------------------------
-- |-------------------------< convert_to_applicant >-------------------------|
-- ----------------------------------------------------------------------------
-- NEW
PROCEDURE convert_to_applicant
  (p_validate                     IN     BOOLEAN                                     --DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     per_all_people_f.person_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
  ,p_applicant_number             IN OUT NOCOPY per_all_people_f.applicant_number%TYPE
  ,p_person_type_id               IN     per_person_types.person_type_id%TYPE        --DEFAULT NULL
  ,p_effective_start_date            OUT NOCOPY per_all_people_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_people_f.effective_end_date%TYPE
  ,p_appl_override_warning           OUT NOCOPY boolean                -- 3652025
  )
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'convert_to_applicant';
  --
  l_effective_date               DATE;
  --
  l_object_version_number        CONSTANT per_all_assignments_f.object_version_number%TYPE := p_object_version_number;
  l_applicant_number             CONSTANT per_all_people_f.applicant_number%TYPE           := p_applicant_number;
  l_per_effective_start_date     per_all_people_f.effective_start_date%TYPE;
  l_per_effective_end_date       per_all_people_f.effective_end_date%TYPE;
  --
  l_person_type_id               per_person_types.person_type_id%TYPE;
  l_person_type_id1              per_person_types.person_type_id%TYPE;
  --
  l_future_asgs_count            INTEGER;
  l_system_person_type           per_person_types.system_person_type%TYPE;
  l_effective_start_date         DATE;
  l_effective_end_date           DATE;
  l_comment_id                   hr_comments.comment_id%TYPE;
  l_current_applicant_flag       per_all_people_f.current_applicant_flag%TYPE;
  l_current_emp_or_apl_flag      per_all_people_f.current_emp_or_apl_flag%TYPE;
  l_current_employee_flag        per_all_people_f.current_employee_flag%TYPE;
  l_full_name                    per_all_people_f.full_name%TYPE;
  l_name_combination_warning     BOOLEAN;
  l_dob_null_warning             BOOLEAN;
  l_orig_hire_warning            BOOLEAN;
  l_application_id               per_applications.application_id%TYPE;
  l_apl_object_version_number    per_applications.object_version_number%TYPE;
  l_assignment_id                per_all_assignments_f.assignment_id%TYPE;
  l_asg_object_version_number    per_all_assignments_f.object_version_number%TYPE;
  l_assignment_sequence          per_all_assignments_f.assignment_sequence%TYPE;
  l_person_type_usage_id         per_person_type_usages.person_type_usage_id%TYPE;
  l_ptu_object_version_number    per_person_type_usages.object_version_number%TYPE;
  --
  lv_object_version_number       per_all_people_f.object_version_number%TYPE := p_object_version_number ;
  lv_applicant_number            per_all_people_f.applicant_number%TYPE := p_applicant_number ;
  l_datetrack_mode               varchar2(30); -- Bug 2738584
  --
  l_per_effective_start_date     per_all_people_f.effective_end_date%TYPE;
  l_per_effective_end_date       per_all_people_f.effective_start_date%TYPE;
  l_appl_override_warning        boolean;
  --
  -- Local cursors
  --
  CURSOR csr_per_details
    (p_person_id                    IN     per_all_people_f.person_id%TYPE
    ,p_effective_date               IN     DATE
    )
  IS
    SELECT pet.person_type_id
          ,pet.system_person_type
          ,per.effective_start_date
          ,per.effective_end_date
          ,per.applicant_number
          ,per.employee_number
          ,per.npw_number
          ,bus.business_group_id
          ,bus.legislation_code
      FROM per_people_f per
          ,per_business_groups bus
          ,per_person_types pet
     WHERE per.person_type_id      = pet.person_type_id
       AND per.business_group_id+0 = bus.business_group_id
       AND per.person_id           = csr_per_details.p_person_id
       AND csr_per_details.p_effective_date BETWEEN per.effective_start_date
                                                AND per.effective_end_date;
  l_per_details_rec              csr_per_details%ROWTYPE;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Ensure mandatory arguments have been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'person_id'
    ,p_argument_value               => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  -- Truncate all date parameters passed in
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Issue savepoint
  --
  SAVEPOINT convert_to_applicant;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Get dervied details for person on effective date
  --
  OPEN csr_per_details
    (p_person_id                    => p_person_id
    ,p_effective_date               => p_effective_date
    );
  FETCH csr_per_details INTO l_per_details_rec;
  IF csr_per_details%NOTFOUND
  THEN
    CLOSE csr_per_details;
    hr_utility.set_message(800,'PER_52097_APL_INV_PERSON_ID');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_per_details;
  --
  hr_utility.set_location(l_proc,30);
  --
  -- Call Before Process User Hook
  --
  BEGIN
    hr_applicant_bk4.convert_to_applicant_b
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_business_group_id            => l_per_details_rec.business_group_id
      ,p_object_version_number        => p_object_version_number
      ,p_applicant_number             => p_applicant_number
      ,p_person_type_id               => p_person_type_id
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'APPLY_FOR_VACANCY'
        ,p_hook_type   => 'BP'
        );
  END;
  --
  -- hr_utility.set_location(l_proc,40);
  --
  -- Check the person is of a correct system person type
  --
  IF l_per_details_rec.system_person_type NOT IN ('EX_APL','EX_EMP','OTHER')
  THEN
    hr_utility.set_location(l_proc,50);
    hr_utility.set_message(800,'PER_52096_APL_INV_PERSON_TYPE');
    hr_utility.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc,60);
  --
  -- Ensure the applicant number will not be changed if it exists
  --
  IF    l_per_details_rec.applicant_number IS NOT NULL
    AND NVL(p_applicant_number,hr_api.g_number) <> l_per_details_rec.applicant_number
  THEN
     hr_utility.set_location(l_proc,70);
     p_applicant_number := l_per_details_rec.applicant_number;
  END IF;
  --
  hr_utility.set_location(l_proc,80);
  --
  -- 3652025: Create an applicant, generate the application and
  --          the applicant assignment
  --
  hr_applicant_internal.create_applicant_anytime
      (p_effective_date                => l_effective_date
      ,p_person_id                     => p_person_id
      ,p_applicant_number              => p_applicant_number
      ,p_per_object_version_number     => p_object_version_number
      ,p_vacancy_id                    => NULL
      ,p_person_type_id                => p_person_type_id
      ,p_assignment_status_type_id     => NULL
      ,p_application_id                => l_application_id
      ,p_assignment_id                 => l_assignment_id
      ,p_apl_object_version_number     => l_apl_object_version_number
      ,p_asg_object_version_number     => l_asg_object_version_number
      ,p_assignment_sequence           => l_assignment_sequence
      ,p_per_effective_start_date      => l_effective_start_date
      ,p_per_effective_end_date        => l_effective_end_date
      ,p_appl_override_warning         => l_appl_override_warning);
  --
  hr_utility.set_location(l_proc,90);
  --
  -- Update the security lists
  --
  hr_security_internal.populate_new_person(l_per_details_rec.business_group_id,p_person_id);
  --
  hr_utility.set_location(l_proc,100);
  --
  -- Call After Process User Hook
  --
  BEGIN
    hr_applicant_bk4.convert_to_applicant_a
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_business_group_id            => l_per_details_rec.business_group_id
      ,p_object_version_number        => p_object_version_number
      ,p_applicant_number             => p_applicant_number
      ,p_person_type_id               => p_person_type_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_appl_override_warning        => l_appl_override_warning
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'APPLY_FOR_VACANCY'
        ,p_hook_type   => 'AP'
        );
  END;
  --
  hr_utility.set_location(l_proc,180);
  --
  -- When in validation only mode raise validate_enabled exception
  --
  IF p_validate
  THEN
    RAISE hr_api.validate_enabled;
  END IF;
  --
  -- Set OUT parameters
  --
  p_effective_start_date         := l_effective_start_date;
  p_effective_end_date           := l_effective_end_date;
  p_appl_override_warning        := l_appl_override_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc,1000);
--
EXCEPTION
  --
  WHEN hr_api.validate_enabled
  THEN
    --
    -- In validation only mode
    -- Rollback to savepoint
    -- Set relevant output warning arguments
    -- Reset any key or derived arguments
    --
    ROLLBACK TO convert_to_applicant;
    p_object_version_number        := l_object_version_number;
    p_applicant_number             := l_applicant_number;
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;
    p_appl_override_warning        := NULL;
  --
  WHEN OTHERS
  THEN
    --
    -- Validation or unexpected error occured
    -- Ensure opened non-local cursors are closed
    -- Rollback to savepoint
    -- Re-raise exception
    --
    p_object_version_number        := lv_object_version_number;
    p_applicant_number             := lv_applicant_number;
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;
    p_appl_override_warning        := NULL;

    ROLLBACK TO convert_to_applicant;
    IF csr_per_details%ISOPEN
    THEN
      CLOSE csr_per_details;
    END IF;
    RAISE;
--
END convert_to_applicant;
--
--
FUNCTION override_future_applications
   (p_person_id  IN NUMBER
   ,p_effective_date IN DATE
   )
 RETURN VARCHAR2 IS

    cursor csr_fut_apl is
    select application_id
    from per_applications
    where person_id = p_person_id
    and   date_received > p_effective_date
    order by date_received asc;

    cursor csr_current_apl is
    select application_id
    from per_applications
    where person_id = p_person_id
    and   date_received < p_effective_date
    and   nvl(date_end,hr_api.g_eot) >= p_effective_date;

    cursor csr_apl_yesterday is
    select application_id
    from per_applications
    where person_id = p_person_id
    and   date_end = p_effective_date-1;

    l_future_apl_id    per_applications.application_id%type;
    l_current_apl_id   per_applications.application_id%type;
    l_yesterday_apl_id per_applications.application_id%type;
    l_raise_warning    VARCHAR2(10);

BEGIN
    l_raise_warning := 'N';
    open csr_fut_apl;
    fetch csr_fut_apl into l_future_apl_id;
    if csr_fut_apl%found then
      open csr_current_apl;
      fetch csr_current_apl into l_current_apl_id;
      if csr_current_apl%notfound then        --yes future, no current
        close csr_current_apl;
        fetch csr_fut_apl INTO l_future_apl_id;
        IF csr_fut_apl%FOUND then
          l_raise_warning := 'Y';
        end if;
      else                                     --yes future, yes current
        close csr_current_apl;
        l_raise_warning := 'Y';
      END IF;
    end if;
    close csr_fut_apl;

    RETURN l_raise_warning;
    --
END override_future_applications;
--
-- ----------------------------------------------------------------------------
-- |-----------------< apply_for_job_anytime >-------------------------|
-- ----------------------------------------------------------------------------
procedure apply_for_job_anytime
  (p_validate                      in     boolean
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_applicant_number              in out nocopy varchar2
  ,p_per_object_version_number     in out nocopy number
  ,p_vacancy_id                    in     number
  ,p_person_type_id                in     number
  ,p_assignment_status_type_id     in     number
  ,p_application_id                   out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_appl_override_warning            out nocopy boolean
  ) is
  --
  -- declare local variables
  --
  l_proc                      varchar2(72) := g_package||'apply_for_job_anytime';
  l_business_group_id         per_people_f.business_group_id%type;
  l_name_combination_warning  boolean;
  l_dob_null_warning          boolean;
  l_orig_hire_warning         boolean;
  l_organization_id           per_business_groups.organization_id%type;
  l_legislation_code          per_business_groups.legislation_code%type;
  l_person_type_id            per_people_f.person_type_id%type  := p_person_type_id;
  l_person_type_id1           per_people_f.person_type_id%type;
  l_application_id            per_applications.application_id%type;
  l_comment_id                per_assignments_f.comment_id%type;
  l_assignment_sequence       per_assignments_f.assignment_sequence%type;
  l_assignment_id         per_assignments_f.assignment_id%type;
  l_object_version_number     per_assignments_f.object_version_number%type;
  l_current_applicant_flag    per_people_f.current_applicant_flag%type;
  l_current_emp_or_apl_flag   per_people_f.current_emp_or_apl_flag%type;
  l_current_employee_flag     per_people_f.current_employee_flag%type;
  l_employee_number           per_people_f.employee_number%type;
  l_applicant_number          per_people_f.applicant_number%TYPE;
  l_npw_number                per_people_f.npw_number%TYPE;
  l_per_object_version_number per_people_f.object_version_number%TYPE;
  l_full_name                 per_people_f.full_name%type;
  l_system_person_type        per_person_types.system_person_type%type;
  l_effective_date            date;
  l_effective_start_date      date;
  l_effective_end_date        date;
  l_default_start_time        per_business_groups.default_start_time%type;
  l_default_end_time          per_business_groups.default_end_time%type;
  l_normal_hours              number;
  l_frequency                 per_business_groups.frequency%type;
  l_recruiter_id              per_vacancies.recruiter_id%type;
  l_grade_id                  per_vacancies.grade_id%type;
  l_position_id               per_vacancies.position_id%type;
  l_job_id                    per_vacancies.job_id%type;
  l_location_id               per_vacancies.location_id%type;
  l_people_group_id           per_vacancies.people_group_id%type;
  l_vac_organization_id       per_vacancies.organization_id%type;
  l_vac_business_group_id     per_vacancies.business_group_id%type;
  l_group_name            pay_people_groups.group_name%type;
  l_appl_override_warning     boolean;
--
--         Local variable added for the before and after business process
--         apply_for_job_anytime
--
  l_apl_object_version_number          per_applications.object_version_number%TYPE;
  l_asg_object_version_number          per_all_assignments_f.object_version_number%TYPE;
  l_per_effective_start_date           per_all_people_f.effective_start_date%TYPE;
  l_per_effective_end_date             per_all_people_f.effective_end_date%TYPE;
--
    --
    -- select and validate the person
    --
    cursor csr_chk_person_exists is
      select   ppf.business_group_id
              ,ppf.employee_number
              ,ppf.npw_number
              ,ppt.system_person_type
      from     per_person_types ppt
              ,per_people_f ppf
      where   ppf.person_id = p_person_id
      and     ppt.person_type_id        = ppf.person_type_id
      and     ppt.business_group_id + 0 = ppf.business_group_id
      and     (l_effective_date
      between ppf.effective_start_date
      and     ppf.effective_end_date or ppf.effective_start_date > l_effective_date);
    --
    --
  begin
    --
    -- Issue a savepoint if operating in validation only mode.
    --
    if p_validate then
      savepoint apply_for_job_anytime;
    end if;
    --
    if g_debug then
       hr_utility.set_location('Entering:'|| l_proc, 5);
    end if;
    --
    -- Truncate p_effective_date
    --
    l_effective_date := trunc(p_effective_date);
    -- Initialise local variables
    --
    l_applicant_number          := p_applicant_number;
    l_per_object_version_number := p_per_object_version_number;
    --
    --
    -- Validation Logic
    --
    --  Ensure that the mandatory parameter, p_person_id
    --  is not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'person id'
      ,p_argument_value => p_person_id);
    --
   if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 10);
   end if;
    --
    -- Check that this person (p_person_id) exists as of l_effective_date
    -- the current person type (per_people_f.person_type_id)
    --
    open  csr_chk_person_exists;
    fetch csr_chk_person_exists into
       l_business_group_id
      ,l_employee_number
      ,l_npw_number
      ,l_system_person_type;
    if csr_chk_person_exists%notfound then
      close csr_chk_person_exists;
      hr_utility.set_message(800, 'HR_51011_PER_NOT_EXIST_DATE');
      hr_utility.raise_error;
    end if;
    close csr_chk_person_exists;
    --
    --
   if g_debug then
      hr_utility.set_location(l_proc, 15);
   end if;

  --
  -- Initialise local variables
  --
  l_applicant_number          := p_applicant_number;
  l_per_object_version_number := p_per_object_version_number;
  --
begin
    --
    -- Start of call API User Hook for the before hook of apply_for_job_anytime_b
    --
    hr_applicant_bk5.apply_for_job_anytime_b
   (
    p_business_group_id                => l_business_group_id
   ,p_effective_date                   => l_effective_date
   ,p_person_id                        => p_person_id
   ,p_applicant_number                 => p_applicant_number
   ,p_per_object_version_number        => p_per_object_version_number
   ,p_vacancy_id                       => p_vacancy_id
   ,p_person_type_id                   => p_person_type_id
   ,p_assignment_status_type_id        => p_assignment_status_type_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'apply_for_job_anytime'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of apply_for_job_anytime
    --
  end;
  -- processing logic
  --
   if g_debug then
      hr_utility.set_location(l_proc, 20);
   end if;
  --

    -- Validate that the person_type_id passed is a flavour of 'APL' or derive the default
    --
    per_per_bus.chk_person_type
    (p_person_type_id     => l_person_type_id,
     p_business_group_id  => l_business_group_id,
     p_expected_sys_type  => 'APL');
    --
   if g_debug then
      hr_utility.set_location(l_proc, 25);
   end if;
  --
  hr_applicant_internal.create_applicant_anytime
     (p_effective_date                => l_effective_date
     ,p_person_id                     => p_person_id
     ,p_applicant_number              => l_applicant_number
     ,p_per_object_version_number     => l_per_object_version_number
     ,p_vacancy_id                    => p_vacancy_id
     ,p_person_type_id                => p_person_type_id
     ,p_assignment_status_type_id     => p_assignment_status_type_id
     ,p_application_id                => l_application_id
     ,p_assignment_id                 => l_assignment_id
     ,p_apl_object_version_number     => l_apl_object_version_number
     ,p_asg_object_version_number     => l_object_version_number
     ,p_assignment_sequence           => l_assignment_sequence
     ,p_per_effective_start_date      => l_per_effective_start_date
     ,p_per_effective_end_date        => l_per_effective_end_date
     ,p_appl_override_warning         => l_appl_override_warning);
   --
   hr_security_internal.add_to_person_list(l_effective_date,l_assignment_id);
    --
   if g_debug then
      hr_utility.set_location(l_proc, 30);
   end if;
   --
   --
  begin
    --
    -- Start of call API User Hook for the after hook of apply_for_anytime_a
    --
    hr_applicant_bk5.apply_for_job_anytime_a
     (
      p_business_group_id             => l_business_group_id
     ,p_effective_date                => l_effective_date
     ,p_person_id                     => p_person_id
     ,p_applicant_number              => p_applicant_number
     ,p_per_object_version_number     => p_per_object_version_number
     ,p_vacancy_id                    => p_vacancy_id
     ,p_person_type_id                => p_person_type_id
     ,p_assignment_status_type_id     => p_assignment_status_type_id
     ,p_application_id                => l_application_id
     ,p_assignment_id                 => l_assignment_id
     ,p_apl_object_version_number     => l_apl_object_version_number
     ,p_asg_object_version_number     => l_asg_object_version_number
     ,p_assignment_sequence           => l_assignment_sequence
     ,p_per_effective_start_date      => l_per_effective_start_date
     ,p_per_effective_end_date        => l_per_effective_end_date
     ,p_appl_override_warning         => l_appl_override_warning
    );
   --
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'apply_for_job_anytime'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of apply_for_job_anytime_a
    --
  end;
  --
  --  Set all output arguments
  --
  -- fix for bug 7172879 start here.
   p_applicant_number                 := l_applicant_number;
   p_per_object_version_number        := l_per_object_version_number;
  -- fix for bug 7172879 ends here.
   p_application_id                   := l_application_id;
   p_assignment_id                    := l_assignment_id;
   p_apl_object_version_number        := l_apl_object_version_number;
   p_asg_object_version_number        := l_object_version_number;   -- l_asg_object_version_number ,fix for bug 7172879
   p_assignment_sequence              := l_assignment_sequence;
   p_per_effective_start_date         := l_per_effective_start_date;
   p_per_effective_end_date           := l_per_effective_end_date;
   p_appl_override_warning            := l_appl_override_warning;
  --
  -- when in validation only mode raise the Validate_Enabled exception
  --

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 50);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO apply_for_job_anytime;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_per_object_version_number := l_per_object_version_number;
    p_applicant_number          := l_applicant_number;
    p_application_id            := null;
    p_assignment_id             := null;
    p_apl_object_version_number := null;
    p_asg_object_version_number := null;
    p_assignment_sequence       := null;
    p_per_effective_start_date  := null;
    p_per_effective_end_date    := null;
    p_appl_override_warning     := null;
    --
    if g_debug then
       hr_utility.set_location(' Leaving:'||l_proc, 55);
    end if;
    --
end apply_for_job_anytime;
--
--
end hr_applicant_api;

/
