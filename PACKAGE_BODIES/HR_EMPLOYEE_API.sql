--------------------------------------------------------
--  DDL for Package Body HR_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EMPLOYEE_API" as
/* $Header: peempapi.pkb 120.8.12010000.6 2009/09/29 13:25:02 brsinha ship $ */
  --
  -- Package Variables
  --
  g_package  varchar2(33) := 'hr_employee_api.';
 g_debug boolean := hr_utility.debug_enabled;
  --
  -- Package cursors
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
--
-- 115.58 (START)
--
       AND asg.assignment_type <> 'B'
--
-- 115.58 (START)
--
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
  l_proc                         VARCHAR2(72);
  --
  l_future_asgs_count            INTEGER := 0;
--
-- 115.58 (START)
--
  CURSOR csr_back_to_back IS
    SELECT 'x'
    FROM per_assignments_f asg1
        ,per_assignments_f asg2
        ,per_assignment_status_types pas1
        ,per_assignment_status_types pas2
        ,per_periods_of_service pds
    WHERE pds.person_id = p_person_id
      AND pds.person_id = asg1.person_id
      AND pds.person_id = asg2.person_id
      AND asg1.assignment_status_type_id = pas1.assignment_status_type_id
      AND asg2.assignment_status_type_id = pas2.assignment_status_type_id
      AND pds.final_process_date > pds.actual_termination_date
      AND pds.actual_termination_date+1 = p_effective_date
      AND asg1.effective_start_date = p_effective_date
      AND pas1.per_system_status = 'TERM_ASSIGN'
      AND asg2.effective_end_date+1 = p_effective_date
      AND pas2.per_system_status = 'ACTIVE_ASSIGN';
--
  l_dummy VARCHAR2(1);
--
-- 115.58 (END)
--
--
BEGIN
  --
 if g_debug then
  l_proc  := g_package||'future_asgs_count';
  hr_utility.set_location('Entering:'||l_proc,10);
 end if;
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
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,100);
 end if;
  --
--
-- 115.58 (START)
--
  -- Check if this is a back-to-back scenario with FPD > ATD and ED = ATD+1
  -- and ASG1-ESD = ED and ASG1-TYPE = 'TERM_ASSIGN' and ASG2-EED+1 = ED and
  -- ASG2-TYPE = 'ACTIVE_ASSIGN' and l_future_asgs_count = 1
  -- If so, this does not consitute an assignment change.
  -- Make l_future_asgs_count = 0
  IF l_future_asgs_count = 1 THEN
    OPEN csr_back_to_back;
    FETCH csr_back_to_back INTO l_dummy;
    IF csr_back_to_back%FOUND THEN
      l_future_asgs_count := 0;
    END IF;
    CLOSE csr_back_to_back;
  END IF;
--
-- 115.58 (END)
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
-- ----------------------------------------------------------------------------
-- |--------------------------< create_employee >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_per_information_category      in     varchar2 default null
  ,p_per_information1              in     varchar2 default null
  ,p_per_information2              in     varchar2 default null
  ,p_per_information3              in     varchar2 default null
  ,p_per_information4              in     varchar2 default null
  ,p_per_information5              in     varchar2 default null
  ,p_per_information6              in     varchar2 default null
  ,p_per_information7              in     varchar2 default null
  ,p_per_information8              in     varchar2 default null
  ,p_per_information9              in     varchar2 default null
  ,p_per_information10             in     varchar2 default null
  ,p_per_information11             in     varchar2 default null
  ,p_per_information12             in     varchar2 default null
  ,p_per_information13             in     varchar2 default null
  ,p_per_information14             in     varchar2 default null
  ,p_per_information15             in     varchar2 default null
  ,p_per_information16             in     varchar2 default null
  ,p_per_information17             in     varchar2 default null
  ,p_per_information18             in     varchar2 default null
  ,p_per_information19             in     varchar2 default null
  ,p_per_information20             in     varchar2 default null
  ,p_per_information21             in     varchar2 default null
  ,p_per_information22             in     varchar2 default null
  ,p_per_information23             in     varchar2 default null
  ,p_per_information24             in     varchar2 default null
  ,p_per_information25             in     varchar2 default null
  ,p_per_information26             in     varchar2 default null
  ,p_per_information27             in     varchar2 default null
  ,p_per_information28             in     varchar2 default null
  ,p_per_information29             in     varchar2 default null
  ,p_per_information30             in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_rehire_recommendation 	   in     varchar2 default null  -- Bug 3210500
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          in     varchar2 default null
  ,p_coord_ben_med_pl_name         in     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   in     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  in     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     in     date default null
  ,p_coord_ben_med_cvg_end_dt      in     date default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_party_id                      in     number default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy boolean
  ,p_assign_payroll_warning           out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                        varchar2(72);
  l_person_type_id              per_person_types.person_type_id%type  := p_person_type_id;
  l_person_type_id1             per_person_types.person_type_id%type;
  l_person_id                   per_people_f.person_id%type;
  l_period_of_service_id        per_periods_of_service.period_of_service_id%type;
  l_employee_number             per_people_f.employee_number%type;
  l_emp_num per_people_f.employee_number%type := p_employee_number;
  l_applicant_number            per_people_f.applicant_number%TYPE;
  l_npw_number                  per_people_f.npw_number%TYPE;
  l_assignment_sequence         per_assignments_f.assignment_sequence%type;
  l_assignment_number           per_assignments_f.assignment_number%type;
  l_hire_date                   date;
  l_discard_number              number;
  l_discard_date                date;
  l_discard_varchar2            varchar2(30);
  l_assignment_id               number;
  l_per_object_version_number   number;
  l_asg_object_version_number   number;
  l_per_effective_start_date    date;
  l_per_effective_end_date      date;
  l_full_name                   per_people_f.full_name%type;
  l_per_comment_id              number;
  l_name_combination_warning    boolean;
  l_assign_payroll_warning      boolean;
  l_orig_hire_warning           boolean;
  l_date_employee_data_verified date;
  l_date_of_birth               date;
  l_phn_object_version_number  per_phones.object_version_number%TYPE;
  l_phone_id                   per_phones.phone_id%TYPE;
  l_date_of_death               date;
  l_receipt_of_death_cert_date  date;
  l_dpdnt_adoption_date         date;
  l_original_date_of_hire       date;
  l_adjusted_svc_date           date;
  --
begin
 if g_debug then
  l_proc := g_package||'create_employee';
  hr_utility.set_location('Entering:'|| l_proc, 10);
 end if;
  --
  -- Issue a savepoint.
  --
  savepoint create_employee;
  --
  --
  -- Truncate the time portion from all date parameters
  -- which are passed in.
  --
  l_hire_date                   := trunc(p_hire_date);
  l_date_employee_data_verified := trunc(p_date_employee_data_verified);
  l_date_of_birth               := trunc(p_date_of_birth);
  l_date_of_death               := trunc(p_date_of_death);
  l_receipt_of_death_cert_date  := trunc(p_receipt_of_death_cert_date);
  l_dpdnt_adoption_date         := trunc(p_dpdnt_adoption_date);
  l_original_date_of_hire       := trunc(p_original_date_of_hire);
  l_adjusted_svc_date           := trunc(p_adjusted_svc_date);
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_employee
    --
    hr_employee_bk1.create_employee_b
      (p_hire_date                    => l_hire_date
      ,p_business_group_id            => p_business_group_id
      ,p_last_name                    => p_last_name
      ,p_sex                          => p_sex
      ,p_person_type_id               => p_person_type_id
      ,p_per_comments                 => p_per_comments
      ,p_date_employee_data_verified  => l_date_employee_data_verified
      ,p_date_of_birth                => l_date_of_birth
      ,p_email_address                => p_email_address
      ,p_employee_number              => p_employee_number
      ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
      ,p_first_name                   => p_first_name
      ,p_known_as                     => p_known_as
      ,p_marital_status               => p_marital_status
      ,p_middle_names                 => p_middle_names
      ,p_nationality                  => p_nationality
      ,p_national_identifier          => p_national_identifier
      ,p_previous_last_name           => p_previous_last_name
      ,p_registered_disabled_flag     => p_registered_disabled_flag
      ,p_title                        => p_title
      ,p_vendor_id                    => p_vendor_id
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
      ,p_date_of_death                => l_date_of_death
      ,p_background_check_status      => p_background_check_status
      ,p_background_date_check        => p_background_date_check
      ,p_blood_type                   => p_blood_type
      ,p_correspondence_language      => p_correspondence_language
      ,p_fast_path_employee           => p_fast_path_employee
      ,p_fte_capacity                 => p_fte_capacity
      ,p_honors                       => p_honors
      ,p_internal_location            => p_internal_location
      ,p_last_medical_test_by         => p_last_medical_test_by
      ,p_last_medical_test_date       => p_last_medical_test_date
      ,p_mailstop                     => p_mailstop
      ,p_office_number                => p_office_number
      ,p_on_military_service          => p_on_military_service
      ,p_pre_name_adjunct             => p_pre_name_adjunct
      ,p_rehire_recommendation 	      => p_rehire_recommendation  -- Bug 3210500
      ,p_projected_start_date         => p_projected_start_date
      ,p_resume_exists                => p_resume_exists
      ,p_resume_last_updated          => p_resume_last_updated
      ,p_second_passport_exists       => p_second_passport_exists
      ,p_student_status               => p_student_status
      ,p_work_schedule                => p_work_schedule
      ,p_suffix                       => p_suffix
      ,p_benefit_group_id             => p_benefit_group_id
      ,p_receipt_of_death_cert_date   => l_receipt_of_death_cert_date
      ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
      ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
      ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
      ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
      ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
      ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
      ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
      ,p_uses_tobacco_flag            => p_uses_tobacco_flag
      ,p_dpdnt_adoption_date          => l_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
      ,p_original_date_of_hire        => l_original_date_of_hire
      ,p_adjusted_svc_date            => l_adjusted_svc_date
      ,p_town_of_birth                => p_town_of_birth
      ,p_region_of_birth              => p_region_of_birth
      ,p_country_of_birth             => p_country_of_birth
      ,p_global_person_id             => p_global_person_id
      ,p_party_id                     => p_party_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EMPLOYEE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_employee
    --
  end;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Truncate the time portion from all date parameters
  -- which are passed in.
  --
  l_hire_date                   := trunc(p_hire_date);
  --
  -- Set the original hire date to sysdate if not passed in.

  if (l_original_date_of_hire is null) THEN
    l_original_date_of_hire       := l_hire_date;
  end if;

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
    ,p_business_group_id => p_business_group_id
    ,p_expected_sys_type => 'EMP'
    );
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Initialise local variables as appropriate
  --
  l_applicant_number := null;
  l_npw_number := null;
  l_employee_number  := p_employee_number;
  --
-- PTU : Changes

  l_person_type_id1   := hr_person_type_usage_info.get_default_person_type_id
                                         (p_business_group_id,
                                          'EMP');
-- PTU : End of Changes

  -- Create the person details
  --
  per_per_ins.ins
    (p_business_group_id            => p_business_group_id
    ,p_person_type_id               => l_person_type_id1
    ,p_last_name                    => p_last_name
    ,p_start_date                   => l_hire_date
    ,p_effective_date          => l_hire_date
    --
    ,p_comments                     => p_per_comments
    ,p_date_employee_data_verified  => l_date_employee_data_verified
    ,p_date_of_birth                => l_date_of_birth
    ,p_email_address                => p_email_address
    ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
    ,p_first_name                   => p_first_name
    ,p_known_as                     => p_known_as
    ,p_marital_status               => p_marital_status
    ,p_middle_names                 => p_middle_names
    ,p_nationality                  => p_nationality
    ,p_national_identifier          => p_national_identifier
    ,p_previous_last_name           => p_previous_last_name
    ,p_registered_disabled_flag     => p_registered_disabled_flag
    ,p_sex                          => p_sex
    ,p_title                        => p_title
    ,p_vendor_id                    => p_vendor_id
--  ,p_work_telephone               => p_work_telephone -- Now Handled by Create_phone
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
    ,p_date_of_death                => l_date_of_death
    ,p_background_check_status      => p_background_check_status
    ,p_background_date_check        => p_background_date_check
    ,p_blood_type                   => p_blood_type
    ,p_correspondence_language      => p_correspondence_language
    ,p_fast_path_employee           => p_fast_path_employee
    ,p_fte_capacity                 => p_fte_capacity
    ,p_honors                       => p_honors
    ,p_internal_location            => p_internal_location
    ,p_last_medical_test_by         => p_last_medical_test_by
    ,p_last_medical_test_date       => p_last_medical_test_date
    ,p_mailstop                     => p_mailstop
    ,p_office_number                => p_office_number
    ,p_on_military_service          => p_on_military_service
    ,p_pre_name_adjunct             => p_pre_name_adjunct
    ,p_projected_start_date         => p_projected_start_date
    ,p_rehire_recommendation        => p_rehire_recommendation  -- Bug 3210500
    ,p_resume_exists                => p_resume_exists
    ,p_resume_last_updated          => p_resume_last_updated
    ,p_second_passport_exists       => p_second_passport_exists
    ,p_student_status               => p_student_status
    ,p_work_schedule                => p_work_schedule
    ,p_suffix                       => p_suffix
    ,p_benefit_group_id             => p_benefit_group_id
    ,p_receipt_of_death_cert_date   => l_receipt_of_death_cert_date
    ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
    ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
    ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
    ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
    ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
    ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
    ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
    ,p_uses_tobacco_flag            => p_uses_tobacco_flag
    ,p_dpdnt_adoption_date          => l_dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
    ,p_original_date_of_hire        => l_original_date_of_hire
    ,p_town_of_birth                => p_town_of_birth
    ,p_region_of_birth              => p_region_of_birth
    ,p_country_of_birth             => p_country_of_birth
    ,p_global_person_id             => p_global_person_id
    ,p_party_id                     => p_party_id
    ,p_validate             => false
    --
    ,p_applicant_number             => l_applicant_number
    ,p_employee_number              => p_employee_number

    ,p_person_id                    => l_person_id
    ,p_effective_start_date         => l_per_effective_start_date
    ,p_effective_end_date           => l_per_effective_end_date
    ,p_comment_id                   => l_per_comment_id
    ,p_current_applicant_flag       => l_discard_varchar2
    ,p_current_emp_or_apl_flag      => l_discard_varchar2
    ,p_current_employee_flag        => l_discard_varchar2
    ,p_full_name                    => l_full_name
    ,p_object_version_number        => l_per_object_version_number
    ,p_name_combination_warning     => l_name_combination_warning
    ,p_dob_null_warning             => l_assign_payroll_warning
    ,p_orig_hire_warning            => l_orig_hire_warning
    ,p_npw_number                   => l_npw_number
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc, 40);
 end if;
  --
  -- insert the person in to the security list
  --
  hr_security_internal.populate_new_person(p_business_group_id,l_person_id);
  --
-- PTU : Following Code has been added

hr_per_type_usage_internal.maintain_person_type_usage
(p_effective_date       => l_hire_date
,p_person_id            => l_person_id
,p_person_type_id       => l_person_type_id
);

-- PTU : End of changes

 if g_debug then
  hr_utility.set_location(l_proc, 50);
 end if;
  --
  -- Create the period of service record
  --
  per_pds_ins.ins
    (p_business_group_id            => p_business_group_id
    ,p_person_id                    => l_person_id
    ,p_date_start                   => l_hire_date
    ,p_effective_date               => l_hire_date
    ,p_adjusted_svc_date            => l_adjusted_svc_date
    --
    ,p_validate                     => false
    ,p_validate_df_flex             => false
    --
    ,p_period_of_service_id         => l_period_of_service_id
    ,p_object_version_number        => l_discard_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 50);
 end if;
  --
  -- Create the default primary employee assignment
  --
  hr_assignment_internal.create_default_emp_asg
    (p_effective_date                => l_hire_date
    ,p_person_id                     => l_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_period_of_service_id          => l_period_of_service_id
    --
    ,p_assignment_id                 => l_assignment_id
    ,p_object_version_number         => l_asg_object_version_number
    ,p_assignment_sequence           => l_assignment_sequence
    ,p_assignment_number             => l_assignment_number
    );
 if g_debug then
  hr_utility.set_location(l_proc, 60);
 end if;
    --
  -- Create a phone row using the newly created person as the parent row.
  -- This phone row replaces the work_telephone column on the person.
  --
  if p_work_telephone is not null then
     hr_phone_api.create_phone
       (p_date_from                 => l_hire_date
       ,p_date_to                   => null
       ,p_phone_type                => 'W1'
       ,p_phone_number              => p_work_telephone
       ,p_parent_id                 => l_person_id
       ,p_parent_table              => 'PER_ALL_PEOPLE_F'
       ,p_validate                  => FALSE
       ,p_effective_date            => l_hire_date
       ,p_object_version_number     => l_phn_object_version_number  --out
       ,p_phone_id                  => l_phone_id                   --out
       );
  end if;
  --
  --
  -- Start of fix for bug 3684087
  --
  SELECT object_version_number
  INTO l_per_object_Version_number
  FROM per_all_people_f
  WHERE person_id = l_person_id
  And effective_start_Date = l_per_effective_start_date
  and effective_end_Date =  l_per_effective_end_date;
  --
  -- Start of fix for bug 3684087

  --start changes for bug 6598795
  hr_assignment.update_assgn_context_value (p_business_group_id,
				   l_person_id,
				   l_assignment_id,
				   p_hire_date);

  SELECT object_version_number
  INTO l_asg_object_Version_number
  FROM per_all_assignments_f
  WHERE business_group_id  = p_business_group_id
  and person_id = l_person_id
  and assignment_id = l_assignment_id
  and effective_start_Date = p_hire_date;
  --end changes for bug 6598795
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_employee
    --
    hr_employee_bk1.create_employee_a
      (p_hire_date                    => l_hire_date
      ,p_business_group_id            => p_business_group_id
      ,p_last_name                    => p_last_name
      ,p_sex                          => p_sex
      ,p_person_type_id               => p_person_type_id
      ,p_per_comments                 => p_per_comments
      ,p_date_employee_data_verified  => l_date_employee_data_verified
      ,p_date_of_birth                => l_date_of_birth
      ,p_email_address                => p_email_address
      ,p_employee_number              => p_employee_number
      ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
      ,p_first_name                   => p_first_name
      ,p_known_as                     => p_known_as
      ,p_marital_status               => p_marital_status
      ,p_middle_names                 => p_middle_names
      ,p_nationality                  => p_nationality
      ,p_national_identifier          => p_national_identifier
      ,p_previous_last_name           => p_previous_last_name
      ,p_registered_disabled_flag     => p_registered_disabled_flag
      ,p_title                        => p_title
      ,p_vendor_id                    => p_vendor_id
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
      ,p_date_of_death                => l_date_of_death
      ,p_background_check_status      => p_background_check_status
      ,p_background_date_check        => p_background_date_check
      ,p_blood_type                   => p_blood_type
      ,p_correspondence_language      => p_correspondence_language
      ,p_fast_path_employee           => p_fast_path_employee
      ,p_fte_capacity                 => p_fte_capacity
      ,p_honors                       => p_honors
      ,p_internal_location            => p_internal_location
      ,p_last_medical_test_by         => p_last_medical_test_by
      ,p_last_medical_test_date       => p_last_medical_test_date
      ,p_mailstop                     => p_mailstop
      ,p_office_number                => p_office_number
      ,p_on_military_service          => p_on_military_service
      ,p_pre_name_adjunct             => p_pre_name_adjunct
      ,p_projected_start_date         => p_projected_start_date
      ,p_rehire_recommendation	      => p_rehire_recommendation  -- Bug 3210500
      ,p_resume_exists                => p_resume_exists
      ,p_resume_last_updated          => p_resume_last_updated
      ,p_second_passport_exists       => p_second_passport_exists
      ,p_student_status               => p_student_status
      ,p_work_schedule                => p_work_schedule
      ,p_suffix                       => p_suffix
      ,p_benefit_group_id             => p_benefit_group_id
      ,p_receipt_of_death_cert_date   => l_receipt_of_death_cert_date
      ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
      ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
      ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
      ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
      ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
      ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
      ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
      ,p_uses_tobacco_flag            => p_uses_tobacco_flag
      ,p_dpdnt_adoption_date          => l_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
      ,p_original_date_of_hire        => l_original_date_of_hire
      ,p_adjusted_svc_date            => l_adjusted_svc_date
      ,p_person_id                    => l_person_id
      ,p_assignment_id                => l_assignment_id
      ,p_per_object_version_number    => l_per_object_version_number
      ,p_asg_object_version_number    => l_asg_object_version_number
      ,p_per_effective_start_date     => l_per_effective_start_date
      ,p_per_effective_end_date       => l_per_effective_end_date
      ,p_full_name                    => l_full_name
      ,p_per_comment_id               => l_per_comment_id
      ,p_assignment_sequence          => l_assignment_sequence
      ,p_assignment_number            => l_assignment_number
      ,p_town_of_birth                => p_town_of_birth
      ,p_region_of_birth              => p_region_of_birth
      ,p_country_of_birth             => p_country_of_birth
      ,p_global_person_id             => p_global_person_id
      ,p_party_id                     => p_party_id
      ,p_name_combination_warning     => l_name_combination_warning
      ,p_assign_payroll_warning       => l_assign_payroll_warning
      ,p_orig_hire_warning            => l_orig_hire_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EMPLOYEE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_employee
    --
  end;
  --
  -- Set all output arguments
  --
  p_person_id                 := l_person_id;
  p_assignment_sequence       := l_assignment_sequence;
  p_assignment_number         := l_assignment_number;
  p_assignment_id             := l_assignment_id;
  p_per_object_version_number := l_per_object_version_number;
  p_asg_object_version_number := l_asg_object_version_number;
  p_per_effective_start_date  := l_per_effective_start_date;
  p_per_effective_end_date    := l_per_effective_end_date;
  p_full_name                 := l_full_name;
  p_per_comment_id            := l_per_comment_id;
  p_name_combination_warning  := l_name_combination_warning;
  p_assign_payroll_warning    := l_assign_payroll_warning;
  p_orig_hire_warning         := l_orig_hire_warning;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 70);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_employee;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_employee_number           := l_employee_number;
    p_person_id                 := null;
    p_assignment_id             := null;
    p_per_object_version_number := null;
    p_asg_object_version_number := null;
    p_per_effective_start_date  := null;
    p_per_effective_end_date    := null;
    p_full_name                 := null;
    p_per_comment_id            := null;
    p_assignment_sequence       := null;
    p_assignment_number         := null;
    p_name_combination_warning  := FALSE;
    p_assign_payroll_warning    := FALSE;
    p_orig_hire_warning         := FALSE;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO create_employee;
    --
    -- set in out parameters and set out parameters
    --
    p_employee_number           := l_emp_num;
    p_person_id                 := null;
    p_assignment_id             := null;
    p_per_object_version_number := null;
    p_asg_object_version_number := null;
    p_per_effective_start_date  := null;
    p_per_effective_end_date    := null;
    p_full_name                 := null;
    p_per_comment_id            := null;
    p_assignment_sequence       := null;
    p_assignment_number         := null;
    p_name_combination_warning  := FALSE;
    p_assign_payroll_warning    := FALSE;
    p_orig_hire_warning         := FALSE;
    raise;
    --
    -- End of fix.
    --
end create_employee;
-- --------------------------------------------------------------------------
--
-- Begin fix for bug 899720
--
-- overload procedure for create_employee
--
procedure create_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_per_information_category      in     varchar2 default null
  ,p_per_information1              in     varchar2 default null
  ,p_per_information2              in     varchar2 default null
  ,p_per_information3              in     varchar2 default null
  ,p_per_information4              in     varchar2 default null
  ,p_per_information5              in     varchar2 default null
  ,p_per_information6              in     varchar2 default null
  ,p_per_information7              in     varchar2 default null
  ,p_per_information8              in     varchar2 default null
  ,p_per_information9              in     varchar2 default null
  ,p_per_information10             in     varchar2 default null
  ,p_per_information11             in     varchar2 default null
  ,p_per_information12             in     varchar2 default null
  ,p_per_information13             in     varchar2 default null
  ,p_per_information14             in     varchar2 default null
  ,p_per_information15             in     varchar2 default null
  ,p_per_information16             in     varchar2 default null
  ,p_per_information17             in     varchar2 default null
  ,p_per_information18             in     varchar2 default null
  ,p_per_information19             in     varchar2 default null
  ,p_per_information20             in     varchar2 default null
  ,p_per_information21             in     varchar2 default null
  ,p_per_information22             in     varchar2 default null
  ,p_per_information23             in     varchar2 default null
  ,p_per_information24             in     varchar2 default null
  ,p_per_information25             in     varchar2 default null
  ,p_per_information26             in     varchar2 default null
  ,p_per_information27             in     varchar2 default null
  ,p_per_information28             in     varchar2 default null
  ,p_per_information29             in     varchar2 default null
  ,p_per_information30             in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_rehire_recommendation	   in     varchar2 default null  -- Bug3210500
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          in     varchar2 default null
  ,p_coord_ben_med_pl_name         in     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   in     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  in     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     in     date     default null
  ,p_coord_ben_med_cvg_end_dt      in     date     default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_party_id                      in     number default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy boolean
  ,p_assign_payroll_warning           out nocopy boolean
  )
is
--
-- Declare cursors and local variables
--
l_proc                        varchar2(72);
l_orig_hire_warning           boolean := false;
--
begin
--
 if g_debug then
 l_proc := g_package||'create_employee';
hr_utility.set_location('Entering:'||l_proc,111);
 end if;
--
  hr_employee_api.create_employee
  (p_validate                     => p_validate
  ,p_hire_date                    => p_hire_date
  ,p_business_group_id            => p_business_group_id
  ,p_last_name                    => p_last_name
  ,p_sex                          => p_sex
  ,p_person_type_id               => p_person_type_id
  ,p_per_comments                 => p_per_comments
  ,p_date_employee_data_verified  => p_date_employee_data_verified
  ,p_date_of_birth                => p_date_of_birth
  ,p_email_address                => p_email_address
  ,p_employee_number              => p_employee_number
  ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
  ,p_first_name                   => p_first_name
  ,p_known_as                     => p_known_as
  ,p_marital_status               => p_marital_status
  ,p_middle_names                 => p_middle_names
  ,p_nationality                  => p_nationality
  ,p_national_identifier          => p_national_identifier
  ,p_previous_last_name           => p_previous_last_name
  ,p_registered_disabled_flag     => p_registered_disabled_flag
  ,p_title                        => p_title
  ,p_vendor_id                    => p_vendor_id
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
  ,p_date_of_death                => p_date_of_death
  ,p_background_check_status      => p_background_check_status
  ,p_background_date_check        => p_background_date_check
  ,p_blood_type                   => p_blood_type
  ,p_correspondence_language      => p_correspondence_language
  ,p_fast_path_employee           => p_fast_path_employee
  ,p_fte_capacity                 => p_fte_capacity
  ,p_honors                       => p_honors
  ,p_internal_location            => p_internal_location
  ,p_last_medical_test_by         => p_last_medical_test_by
  ,p_last_medical_test_date       => p_last_medical_test_date
  ,p_mailstop                     => p_mailstop
  ,p_office_number                => p_office_number
  ,p_on_military_service          => p_on_military_service
  ,p_pre_name_adjunct             => p_pre_name_adjunct
  ,p_rehire_recommendation	  => p_rehire_recommendation  -- Bug 3210500
  ,p_projected_start_date         => p_projected_start_date
  ,p_resume_exists                => p_resume_exists
  ,p_resume_last_updated          => p_resume_last_updated
  ,p_second_passport_exists       => p_second_passport_exists
  ,p_student_status               => p_student_status
  ,p_work_schedule                => p_work_schedule
  ,p_suffix                       => p_suffix
  ,p_benefit_group_id             => p_benefit_group_id
  ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
  ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
  ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
  ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
  ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
  ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
  ,p_uses_tobacco_flag            => p_uses_tobacco_flag
  ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire        => p_original_date_of_hire
  ,p_adjusted_svc_date            => p_adjusted_svc_date
  ,p_town_of_birth                => p_town_of_birth
  ,p_region_of_birth              => p_region_of_birth
  ,p_country_of_birth             => p_country_of_birth
  ,p_global_person_id             => p_global_person_id
  ,p_party_id                     => p_party_id
  ,p_person_id                    => p_person_id
  ,p_assignment_id                => p_assignment_id
  ,p_per_object_version_number    => p_per_object_version_number
  ,p_asg_object_version_number    => p_asg_object_version_number
  ,p_per_effective_start_date     => p_per_effective_start_date
  ,p_per_effective_end_date       => p_per_effective_end_date
  ,p_full_name                    => p_full_name
  ,p_per_comment_id               => p_per_comment_id
  ,p_assignment_sequence          => p_assignment_sequence
  ,p_assignment_number            => p_assignment_number
  ,p_name_combination_warning     => p_name_combination_warning
  ,p_assign_payroll_warning       => p_assign_payroll_warning
  ,p_orig_hire_warning            => l_orig_hire_warning
  );
  --
 if g_debug then
hr_utility.set_location('Leaving:'||l_proc,111);
 end if;
--
end create_employee;
--
-- End of fix for bug 899720
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_gb_employee >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_gb_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_ni_number                     in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_ethnic_origin                 in     varchar2 default null
  ,p_director                      in     varchar2 default 'N'
  ,p_pensioner                     in     varchar2 default 'N'
  ,p_work_permit_number            in     varchar2 default null
  ,p_addl_pension_years            in     varchar2 default null
  ,p_addl_pension_months           in     varchar2 default null
  ,p_addl_pension_days             in     varchar2 default null
  ,p_ni_multiple_asg               in     varchar2 default 'N'
  ,p_date_of_death                 in     date     default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_rehire_recommendation	   in     varchar2 default null  -- Bug 3210500
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          in     varchar2 default null
  ,p_coord_ben_med_pl_name         in     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   in     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  in     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     in     date default null
  ,p_coord_ben_med_cvg_end_dt      in     date default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_party_id                      in     number default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy boolean
  ,p_assign_payroll_warning           out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72);
  l_legislation_code        varchar2(2);
  l_hire_date               date := trunc(p_hire_date);
  l_original_date_of_hire   date := trunc(p_original_date_of_hire);

  -- Used for GB session id
  l_session_c               number(1):=2;

  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin

 if g_debug then
  l_proc := g_package||'create_gb_employee';
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;

 begin
   select 1 into l_session_c from fnd_sessions
    where session_id=userenv('sessionid');
  exception
   when no_data_found then
     insert into fnd_sessions(session_id,effective_date) values(userenv('sessionid'),p_hire_date);
     l_session_c:=0;
 end;

  --
  -- Validation in addition to Row Handlers
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

 if g_debug then
  hr_utility.set_location(l_proc, 6);
 end if;
  --
  -- set the original date of hire to hire date if null
  --
  if p_original_date_of_hire is null then
     l_original_date_of_hire := l_hire_date;
  end if;
  --
  -- Call the person business process
  --
  hr_employee_api.create_employee
  (p_validate                     => p_validate
  ,p_hire_date                    => p_hire_date
  ,p_business_group_id            => p_business_group_id
  ,p_last_name                    => p_last_name
  ,p_sex                          => p_sex
  ,p_person_type_id               => p_person_type_id
  ,p_per_comments                 => p_comments
  ,p_date_employee_data_verified  => p_date_employee_data_verified
  ,p_date_of_birth                => p_date_of_birth
  ,p_email_address                => p_email_address
  ,p_employee_number              => p_employee_number
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
  ,p_vendor_id                    => p_vendor_id
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
  ,p_date_of_death                => p_date_of_death
  ,p_background_check_status      => p_background_check_status
  ,p_background_date_check        => p_background_date_check
  ,p_blood_type                   => p_blood_type
  ,p_correspondence_language      => p_correspondence_language
  ,p_fast_path_employee           => p_fast_path_employee
  ,p_fte_capacity                 => p_fte_capacity
  ,p_honors                       => p_honors
  ,p_internal_location            => p_internal_location
  ,p_last_medical_test_by         => p_last_medical_test_by
  ,p_last_medical_test_date       => p_last_medical_test_date
  ,p_mailstop                     => p_mailstop
  ,p_office_number                => p_office_number
  ,p_on_military_service          => p_on_military_service
  ,p_pre_name_adjunct             => p_pre_name_adjunct
  ,p_rehire_recommendation	  => p_rehire_recommendation  -- Bug 3210500
  ,p_projected_start_date         => p_projected_start_date
  ,p_resume_exists                => p_resume_exists
  ,p_resume_last_updated          => p_resume_last_updated
  ,p_second_passport_exists       => p_second_passport_exists
  ,p_student_status               => p_student_status
  ,p_work_schedule                => p_work_schedule
  ,p_suffix                       => p_suffix
  ,p_benefit_group_id             => p_benefit_group_id
  ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
  ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
  ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
  ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
  ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
  ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
  ,p_uses_tobacco_flag            => p_uses_tobacco_flag
  ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire        => l_original_date_of_hire
  ,p_adjusted_svc_date            => p_adjusted_svc_date
  ,p_town_of_birth                => p_town_of_birth
  ,p_region_of_birth              => p_region_of_birth
  ,p_country_of_birth             => p_country_of_birth
  ,p_global_person_id             => p_global_person_id
  ,p_party_id                     => p_party_id
  --
  ,p_person_id                    => p_person_id
  ,p_assignment_id                => p_assignment_id
  ,p_per_object_version_number    => p_per_object_version_number
  ,p_asg_object_version_number    => p_asg_object_version_number
  ,p_per_effective_start_date     => p_per_effective_start_date
  ,p_per_effective_end_date       => p_per_effective_end_date
  ,p_full_name                    => p_full_name
  ,p_per_comment_id               => p_per_comment_id
  ,p_assignment_sequence          => p_assignment_sequence
  ,p_assignment_number            => p_assignment_number
  ,p_name_combination_warning     => p_name_combination_warning
  ,p_assign_payroll_warning       => p_assign_payroll_warning
  ,p_orig_hire_warning            => p_orig_hire_warning
  );
  --

   if(l_session_c = 0) then
   delete from fnd_sessions where session_id=userenv('sessionid');
  end if;

end create_gb_employee;
-- --------------------------------------------------------------------------
--
-- Begin fix for bug 899720
--
-- overload procedure for create_gb_employee
--
procedure create_gb_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_ni_number                     in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_ethnic_origin                 in     varchar2 default null
  ,p_director                      in     varchar2 default 'N'
  ,p_pensioner                     in     varchar2 default 'N'
  ,p_work_permit_number            in     varchar2 default null
  ,p_addl_pension_years            in     varchar2 default null
  ,p_addl_pension_months           in     varchar2 default null
  ,p_addl_pension_days             in     varchar2 default null
  ,p_ni_multiple_asg               in     varchar2 default 'N'
  ,p_date_of_death                 in     date     default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_rehire_recommendation	   in     varchar2 default null  -- Bug 3210500
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          in     varchar2 default null
  ,p_coord_ben_med_pl_name         in     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   in     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  in     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     in     date default null
  ,p_coord_ben_med_cvg_end_dt      in     date default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_party_id                      in     number   default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy boolean
  ,p_assign_payroll_warning           out nocopy boolean
  )
is
--
-- Declare cursors and local variables
--
l_proc                        varchar2(72);
l_orig_hire_warning           boolean := false;
--
begin
--
 if g_debug then
 l_proc := g_package||'create_gb_employee';
hr_utility.set_location('Entering:'||l_proc,222);
 end if;
--
  hr_employee_api.create_gb_employee
  (p_validate                     => p_validate
  ,p_hire_date                    => p_hire_date
  ,p_business_group_id            => p_business_group_id
  ,p_last_name                    => p_last_name
  ,p_sex                          => p_sex
  ,p_person_type_id               => p_person_type_id
  ,p_comments                     => p_comments
  ,p_date_employee_data_verified  => p_date_employee_data_verified
  ,p_date_of_birth                => p_date_of_birth
  ,p_email_address                => p_email_address
  ,p_employee_number              => p_employee_number
  ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
  ,p_first_name                   => p_first_name
  ,p_known_as                     => p_known_as
  ,p_marital_status               => p_marital_status
  ,p_middle_names                 => p_middle_names
  ,p_nationality                  => p_nationality
  ,p_ni_number                    => p_ni_number
  ,p_previous_last_name           => p_previous_last_name
  ,p_registered_disabled_flag     => p_registered_disabled_flag
  ,p_title                        => p_title
  ,p_vendor_id                    => p_vendor_id
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
  ,p_ethnic_origin                => p_ethnic_origin
  ,p_director                     => p_director
  ,p_pensioner                    => p_pensioner
  ,p_work_permit_number           => p_work_permit_number
  ,p_addl_pension_years           => p_addl_pension_years
  ,p_addl_pension_months          => p_addl_pension_months
  ,p_addl_pension_days            => p_addl_pension_days
  ,p_ni_multiple_asg              => p_ni_multiple_asg
  ,p_date_of_death                => p_date_of_death
  ,p_background_check_status      => p_background_check_status
  ,p_background_date_check        => p_background_date_check
  ,p_blood_type                   => p_blood_type
  ,p_correspondence_language      => p_correspondence_language
  ,p_fast_path_employee           => p_fast_path_employee
  ,p_fte_capacity                 => p_fte_capacity
  ,p_honors                       => p_honors
  ,p_internal_location            => p_internal_location
  ,p_last_medical_test_by         => p_last_medical_test_by
  ,p_last_medical_test_date       => p_last_medical_test_date
  ,p_mailstop                     => p_mailstop
  ,p_office_number                => p_office_number
  ,p_on_military_service          => p_on_military_service
  ,p_pre_name_adjunct             => p_pre_name_adjunct
  ,p_rehire_recommendation	  => p_rehire_recommendation  -- Bug 3210500
  ,p_projected_start_date         => p_projected_start_date
  ,p_resume_exists                => p_resume_exists
  ,p_resume_last_updated          => p_resume_last_updated
  ,p_second_passport_exists       => p_second_passport_exists
  ,p_student_status               => p_student_status
  ,p_work_schedule                => p_work_schedule
  ,p_suffix                       => p_suffix
  ,p_benefit_group_id             => p_benefit_group_id
  ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
  ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
  ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
  ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
  ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
  ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
  ,p_uses_tobacco_flag            => p_uses_tobacco_flag
  ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire        => p_original_date_of_hire
  ,p_adjusted_svc_date            => p_adjusted_svc_date
  ,p_town_of_birth                => p_town_of_birth
  ,p_region_of_birth              => p_region_of_birth
  ,p_country_of_birth             => p_country_of_birth
  ,p_global_person_id             => p_global_person_id
  ,p_party_id                     => p_party_id
  ,p_person_id                    => p_person_id
  ,p_assignment_id                => p_assignment_id
  ,p_per_object_version_number    => p_per_object_version_number
  ,p_asg_object_version_number    => p_asg_object_version_number
  ,p_per_effective_start_date     => p_per_effective_start_date
  ,p_per_effective_end_date       => p_per_effective_end_date
  ,p_full_name                    => p_full_name
  ,p_per_comment_id               => p_per_comment_id
  ,p_assignment_sequence          => p_assignment_sequence
  ,p_assignment_number            => p_assignment_number
  ,p_name_combination_warning     => p_name_combination_warning
  ,p_assign_payroll_warning       => p_assign_payroll_warning
  ,p_orig_hire_warning            => l_orig_hire_warning
  );
--
 if g_debug then
hr_utility.set_location('Leaving:'||l_proc,222);
 end if;
--
end create_gb_employee;
--
-- End of fix for bug 899720
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_us_employee >---------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Begin fix for bug 899720
--
-- overload procedure for create_us_employee
--
procedure create_us_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_ss_number                     in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_ethnic_origin                 in     varchar2 default null
  ,p_I_9                           in     varchar2 default 'N'
  ,p_I_9_expiration_date           in     varchar2 default null
--  ,p_visa_type                     in     varchar2 default null
  ,p_veteran_status                in     varchar2 default null
  ,p_new_hire                      in     varchar2 default null
  ,p_exception_reason              in     varchar2 default null
  ,p_child_support_obligation      in     varchar2 default 'N'
  ,p_opted_for_medicare_flag       in     varchar2 default 'N'
  ,p_date_of_death                 in     date     default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_rehire_recommendation	   in     varchar2 default null  -- Bug 3210500
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          in     varchar2 default null
  ,p_coord_ben_med_pl_name         in     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   in     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  in     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     in     date default null
  ,p_coord_ben_med_cvg_end_dt      in     date default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_party_id                      in     number default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy boolean
  ,p_assign_payroll_warning           out nocopy boolean
  )
is
--
-- Declare cursors and local variables
--
l_proc                 varchar2(72) ;
l_orig_hire_warning    boolean      := false;
--
begin
--
 if g_debug then
 l_proc := g_package||'create_us_employee';
hr_utility.set_location('Entering:'||l_proc,333);
 end if;
--

  hr_employee_api.create_us_employee
    (p_validate                     => p_validate
    ,p_hire_date                    => p_hire_date
    ,p_business_group_id            => p_business_group_id
    ,p_last_name                    => p_last_name
    ,p_sex                          => p_sex
    ,p_person_type_id               => p_person_type_id
    ,p_comments                     => p_comments
    ,p_date_employee_data_verified  => p_date_employee_data_verified
    ,p_date_of_birth                => p_date_of_birth
    ,p_email_address                => p_email_address
    ,p_employee_number              => p_employee_number
    ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
    ,p_first_name                   => p_first_name
    ,p_known_as                     => p_known_as
    ,p_marital_status               => p_marital_status
    ,p_middle_names                 => p_middle_names
    ,p_nationality                  => p_nationality
    ,p_ss_number                    => p_ss_number
    ,p_previous_last_name           => p_previous_last_name
    ,p_registered_disabled_flag     => p_registered_disabled_flag
    ,p_title                        => p_title
    ,p_vendor_id                    => p_vendor_id
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
    ,p_ethnic_origin                => p_ethnic_origin
    ,p_I_9                          => p_I_9
    ,p_I_9_expiration_date          => p_I_9_expiration_date
--    ,p_visa_type                    => p_visa_type
    ,p_veteran_status               => p_veteran_status
    ,p_new_hire                     => p_new_hire
    ,p_exception_reason             => p_exception_reason
    ,p_child_support_obligation     => p_child_support_obligation
    ,p_opted_for_medicare_flag      => p_opted_for_medicare_flag
    ,p_date_of_death                => p_date_of_death
    ,p_background_check_status      => p_background_check_status
    ,p_background_date_check        => p_background_date_check
    ,p_blood_type                   => p_blood_type
    ,p_correspondence_language      => p_correspondence_language
    ,p_fast_path_employee           => p_fast_path_employee
    ,p_fte_capacity                 => p_fte_capacity
    ,p_honors                       => p_honors
    ,p_internal_location            => p_internal_location
    ,p_last_medical_test_by         => p_last_medical_test_by
    ,p_last_medical_test_date       => p_last_medical_test_date
    ,p_mailstop                     => p_mailstop
    ,p_office_number                => p_office_number
    ,p_on_military_service          => p_on_military_service
    ,p_pre_name_adjunct             => p_pre_name_adjunct
    ,p_rehire_recommendation	    => p_rehire_recommendation  -- Bug 3210500
    ,p_projected_start_date         => p_projected_start_date
    ,p_resume_exists                => p_resume_exists
    ,p_resume_last_updated          => p_resume_last_updated
    ,p_second_passport_exists       => p_second_passport_exists
    ,p_student_status               => p_student_status
    ,p_work_schedule                => p_work_schedule
    ,p_suffix                       => p_suffix
    ,p_benefit_group_id             => p_benefit_group_id
    ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
    ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
    ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
    ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
    ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
    ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
    ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
    ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
    ,p_uses_tobacco_flag            => p_uses_tobacco_flag
    ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
    ,p_original_date_of_hire        => p_original_date_of_hire
    ,p_adjusted_svc_date            => p_adjusted_svc_date
    ,p_town_of_birth                => p_town_of_birth
    ,p_region_of_birth              => p_region_of_birth
    ,p_country_of_birth             => p_country_of_birth
    ,p_global_person_id             => p_global_person_id
    ,p_party_id                     => p_party_id
    ,p_person_id                    => p_person_id
    ,p_assignment_id                => p_assignment_id
    ,p_per_object_version_number    => p_per_object_version_number
    ,p_asg_object_version_number    => p_asg_object_version_number
    ,p_per_effective_start_date     => p_per_effective_start_date
    ,p_per_effective_end_date       => p_per_effective_end_date
    ,p_full_name                    => p_full_name
    ,p_per_comment_id               => p_per_comment_id
    ,p_assignment_sequence          => p_assignment_sequence
    ,p_assignment_number            => p_assignment_number
    ,p_name_combination_warning     => p_name_combination_warning
    ,p_assign_payroll_warning       => p_assign_payroll_warning
    ,p_orig_hire_warning            => l_orig_hire_warning
  );
--
 if g_debug then
hr_utility.set_location('Leaving:'||l_proc,333);
 end if;
--
end create_us_employee;
--
-- End of fix for bug 899720
--


procedure create_us_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_ss_number                     in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_ethnic_origin                 in     varchar2 default null
  ,p_I_9                           in     varchar2 default 'N'
  ,p_I_9_expiration_date           in     varchar2 default null
--  ,p_visa_type                     in     varchar2 default null
  ,p_veteran_status                in     varchar2 default null
  ,p_new_hire                      in     varchar2 default null
  ,p_exception_reason              in     varchar2 default null
  ,p_child_support_obligation      in     varchar2 default 'N'
  ,p_opted_for_medicare_flag       in     varchar2 default 'N'
  ,p_date_of_death                 in     date     default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_rehire_recommendation	   in 	  varchar2 default null  -- Bug 3210500
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          in     varchar2 default null
  ,p_coord_ben_med_pl_name         in     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   in     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  in     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     in     date default null
  ,p_coord_ben_med_cvg_end_dt      in     date default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_party_id                      in     number default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy boolean
  ,p_assign_payroll_warning           out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  )
is

l_vets100A varchar2(100);
  --
  -- Declare cursors and local variables
  --
 /* l_proc                 varchar2(72) ;
  l_legislation_code     varchar2(2);
  l_asg_object_version_number  number(9);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
    */
  --
begin
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
/*  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
 if g_debug then
  l_proc := g_package||'create_us_employee';
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'US'.
  --
  if l_legislation_code <> 'US' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','US');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
 */
  --
  -- Call the person business process
  --


  hr_employee_api.create_us_employee
    (p_validate                     => p_validate
    ,p_hire_date                    => p_hire_date
    ,p_business_group_id            => p_business_group_id
    ,p_last_name                    => p_last_name
    ,p_sex                          => p_sex
    ,p_person_type_id               => p_person_type_id
    ,p_comments                 => p_comments
    ,p_date_employee_data_verified  => p_date_employee_data_verified
    ,p_date_of_birth                => p_date_of_birth
    ,p_email_address                => p_email_address
    ,p_employee_number              => p_employee_number
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
    ,p_vendor_id                    => p_vendor_id
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
 --   ,p_per_information_category     => 'US'
    ,p_ethnic_origin             => p_ethnic_origin
    ,p_I_9             => p_I_9
    ,p_I_9_expiration_date             => p_I_9_expiration_date
--    ,p_visa_type             => p_visa_type
    ,p_veteran_status             => p_veteran_status
    ,p_vets100A             => l_vets100A
    ,p_new_hire             => p_new_hire
    ,p_exception_reason             => p_exception_reason
    ,p_child_support_obligation             => p_child_support_obligation
    ,p_opted_for_medicare_flag            => p_opted_for_medicare_flag
    ,p_date_of_death                => p_date_of_death
    ,p_background_check_status      => p_background_check_status
    ,p_background_date_check        => p_background_date_check
    ,p_blood_type                   => p_blood_type
    ,p_correspondence_language      => p_correspondence_language
    ,p_fast_path_employee           => p_fast_path_employee
    ,p_fte_capacity                 => p_fte_capacity
    ,p_honors                       => p_honors
    ,p_internal_location            => p_internal_location
    ,p_last_medical_test_by         => p_last_medical_test_by
    ,p_last_medical_test_date       => p_last_medical_test_date
    ,p_mailstop                     => p_mailstop
    ,p_office_number                => p_office_number
    ,p_on_military_service          => p_on_military_service
    ,p_pre_name_adjunct             => p_pre_name_adjunct
    ,p_rehire_recommendation	    => p_rehire_recommendation  -- Bug 3210500
    ,p_projected_start_date         => p_projected_start_date
    ,p_resume_exists                => p_resume_exists
    ,p_resume_last_updated          => p_resume_last_updated
    ,p_second_passport_exists       => p_second_passport_exists
    ,p_student_status               => p_student_status
    ,p_work_schedule                => p_work_schedule
    ,p_suffix                       => p_suffix
    ,p_benefit_group_id             => p_benefit_group_id
    ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
    ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
    ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
    ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
    ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
    ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
    ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
    ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
    ,p_uses_tobacco_flag            => p_uses_tobacco_flag
    ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
    ,p_original_date_of_hire        => p_original_date_of_hire
    ,p_adjusted_svc_date            => p_adjusted_svc_date
    ,p_town_of_birth                => p_town_of_birth
    ,p_region_of_birth              => p_region_of_birth
    ,p_country_of_birth             => p_country_of_birth
    ,p_global_person_id             => p_global_person_id
    ,p_party_id                     => p_party_id
    ,p_person_id                    => p_person_id
    ,p_assignment_id                => p_assignment_id
    ,p_per_object_version_number    => p_per_object_version_number
    ,p_asg_object_version_number    => p_asg_object_version_number
    ,p_per_effective_start_date     => p_per_effective_start_date
    ,p_per_effective_end_date       => p_per_effective_end_date
    ,p_full_name                    => p_full_name
    ,p_per_comment_id               => p_per_comment_id
    ,p_assignment_sequence          => p_assignment_sequence
    ,p_assignment_number            => p_assignment_number
    ,p_name_combination_warning     => p_name_combination_warning
    ,p_assign_payroll_warning       => p_assign_payroll_warning
    ,p_orig_hire_warning            => p_orig_hire_warning
  );
  --
/* if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;
 */
end create_us_employee;

-- Bug 8277596.

procedure create_us_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_ss_number                     in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_ethnic_origin                 in     varchar2 default null
  ,p_I_9                           in     varchar2 default 'N'
  ,p_I_9_expiration_date           in     varchar2 default null
--  ,p_visa_type                     in     varchar2 default null
  ,p_veteran_status                in     varchar2 default null
  ,p_vets100A                in     varchar2
  ,p_new_hire                      in     varchar2 default null
  ,p_exception_reason              in     varchar2 default null
  ,p_child_support_obligation      in     varchar2 default 'N'
  ,p_opted_for_medicare_flag       in     varchar2 default 'N'
  ,p_date_of_death                 in     date     default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_rehire_recommendation	   in 	  varchar2 default null  -- Bug 3210500
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          in     varchar2 default null
  ,p_coord_ben_med_pl_name         in     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   in     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  in     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     in     date default null
  ,p_coord_ben_med_cvg_end_dt      in     date default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_party_id                      in     number default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy boolean
  ,p_assign_payroll_warning           out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) ;
  l_legislation_code     varchar2(2);
  l_asg_object_version_number  number(9);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  --
  -- Validation in addition to Row Handlers
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
 if g_debug then
  l_proc := g_package||'create_us_employee';
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'US'.
  --
  if l_legislation_code <> 'US' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','US');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Call the person business process
  --
  hr_employee_api.create_employee
    (p_validate                     => p_validate
    ,p_hire_date                    => p_hire_date
    ,p_business_group_id            => p_business_group_id
    ,p_last_name                    => p_last_name
    ,p_sex                          => p_sex
    ,p_person_type_id               => p_person_type_id
    ,p_per_comments                 => p_comments
    ,p_date_employee_data_verified  => p_date_employee_data_verified
    ,p_date_of_birth                => p_date_of_birth
    ,p_email_address                => p_email_address
    ,p_employee_number              => p_employee_number
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
    ,p_vendor_id                    => p_vendor_id
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
    ,p_per_information2             => p_I_9
    ,p_per_information3             => p_I_9_expiration_date
--    ,p_per_information4             => p_visa_type
    ,p_per_information5             => p_veteran_status
    ,p_per_information25             => p_vets100A
    ,p_per_information7             => p_new_hire
    ,p_per_information8             => p_exception_reason
    ,p_per_information9             => p_child_support_obligation
    ,p_per_information10            => p_opted_for_medicare_flag
    ,p_date_of_death                => p_date_of_death
    ,p_background_check_status      => p_background_check_status
    ,p_background_date_check        => p_background_date_check
    ,p_blood_type                   => p_blood_type
    ,p_correspondence_language      => p_correspondence_language
    ,p_fast_path_employee           => p_fast_path_employee
    ,p_fte_capacity                 => p_fte_capacity
    ,p_honors                       => p_honors
    ,p_internal_location            => p_internal_location
    ,p_last_medical_test_by         => p_last_medical_test_by
    ,p_last_medical_test_date       => p_last_medical_test_date
    ,p_mailstop                     => p_mailstop
    ,p_office_number                => p_office_number
    ,p_on_military_service          => p_on_military_service
    ,p_pre_name_adjunct             => p_pre_name_adjunct
    ,p_rehire_recommendation	    => p_rehire_recommendation  -- Bug 3210500
    ,p_projected_start_date         => p_projected_start_date
    ,p_resume_exists                => p_resume_exists
    ,p_resume_last_updated          => p_resume_last_updated
    ,p_second_passport_exists       => p_second_passport_exists
    ,p_student_status               => p_student_status
    ,p_work_schedule                => p_work_schedule
    ,p_suffix                       => p_suffix
    ,p_benefit_group_id             => p_benefit_group_id
    ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
    ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
    ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
    ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
    ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
    ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
    ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
    ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
    ,p_uses_tobacco_flag            => p_uses_tobacco_flag
    ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
    ,p_original_date_of_hire        => p_original_date_of_hire
    ,p_adjusted_svc_date            => p_adjusted_svc_date
    ,p_town_of_birth                => p_town_of_birth
    ,p_region_of_birth              => p_region_of_birth
    ,p_country_of_birth             => p_country_of_birth
    ,p_global_person_id             => p_global_person_id
    ,p_party_id                     => p_party_id
    --
    ,p_person_id                    => p_person_id
    ,p_assignment_id                => p_assignment_id
    ,p_per_object_version_number    => p_per_object_version_number
    ,p_asg_object_version_number    => p_asg_object_version_number
    ,p_per_effective_start_date     => p_per_effective_start_date
    ,p_per_effective_end_date       => p_per_effective_end_date
    ,p_full_name                    => p_full_name
    ,p_per_comment_id               => p_per_comment_id
    ,p_assignment_sequence          => p_assignment_sequence
    ,p_assignment_number            => p_assignment_number
    ,p_name_combination_warning     => p_name_combination_warning
    ,p_assign_payroll_warning       => p_assign_payroll_warning
    ,p_orig_hire_warning            => p_orig_hire_warning
  );
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;
end create_us_employee;
-- --------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- |--------------------------< re_hire_ex_employee >-------------------------|
-- ----------------------------------------------------------------------------
procedure re_hire_ex_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_person_id                     in     number
  ,p_per_object_version_number     in out nocopy number
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_rehire_reason                 in     varchar2
  ,p_assignment_id                    out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_assign_payroll_warning           out nocopy boolean
  ) is
  --
  -- declare local variables
  --
  l_proc                      varchar2(72) := g_package||'re_hire_ex_employee';
  l_business_group_id         per_people_f.business_group_id%type;
  l_ovn per_people_f.object_version_number%type := p_per_object_version_number;
  l_name_combination_warning  boolean;
  l_orig_hire_warning         boolean;
  l_person_type_id            per_people_f.person_type_id%type := p_person_type_id;
  l_person_type_id1           per_people_f.person_type_id%type;
  l_comment_id                per_people_f.comment_id%type;
  l_current_applicant_flag    per_people_f.current_applicant_flag%type;
  l_current_emp_or_apl_flag   per_people_f.current_emp_or_apl_flag%type;
  l_current_employee_flag     per_people_f.current_employee_flag%type;
  l_employee_number           per_people_f.employee_number%type;
  l_applicant_number          per_people_f.applicant_number%TYPE;
  l_npw_number                per_people_f.npw_number%type;
  l_full_name                 per_people_f.full_name%type;
  l_object_version_number     per_people_f.object_version_number%type;
  l_period_of_service_id      per_periods_of_service.period_of_service_id%type;
  l_pds_object_version_number per_periods_of_service.object_version_number%type;
  l_datetrack_mode            varchar2(12);
  l_effective_date            date;
  l_hire_date                 date;
  l_assign_payroll_warning    boolean :=FALSE;
--
-- Added local variables for after hook re_hire_ex_employee_a
--
-- Bug 1828850 starts here.
-- The l_assignment_id is declared as per_assignments_f.assignment_id%type.
--
  l_assignment_id                    per_assignments_f.assignment_id%type;
--
-- Bug 1828850 Ends here.
--
  l_asg_object_version_number        number(9);
  l_per_effective_start_date         date;
  l_per_effective_end_date           date;
  l_assignment_sequence              number(15);
  l_assignment_number                varchar2(30);
-- Bug 3611984 starts here
  l_ptu_datetrack_mode             varchar2(12);
  cursor c_ptu_start_date is
   select effective_start_date
   from per_person_type_usages_f ptu,per_person_types ppt
   where ptu.person_type_id = ppt.person_type_id
   and ptu.person_id = p_person_id
   and p_hire_date between ptu.effective_start_date and ptu.effective_end_date
   and ppt.system_person_type='EX_EMP';
  l_ptu_effective_start_date  date;

--
-- 115.57 (START)
--
  l_rule_value       pay_legislation_rules.rule_mode%TYPE;
  l_rule_found       BOOLEAN;
  l_legislation_code pay_legislation_rules.legislation_code%TYPE;
--
-- 115.57 (END)
--

-- Bug 3611984 starts here

  -- --------------------------------------------------------------------------
  -- |-------------------------< get_person_details >-------------------------|
  -- --------------------------------------------------------------------------
  --
  -- Description
  --   This procedure is used for 2 purposes; to validate that the person
  --   exists as of the specified effective date and to select the
  --   business group, effective start date and system person type information
  --
  -- --------------------------------------------------------------------------
  procedure get_person_details
    (p_person_id                 in     number,
     p_effective_date            in     date,
     p_business_group_id            out nocopy number,
     p_employee_number              out nocopy varchar2,
     p_effective_start_date         out nocopy date,
     p_system_person_type           out nocopy varchar2) is
    --
    l_proc      varchar2(72);
    --
    -- select and validate the person
    --
    -- Fix for 5045840 . Modified the cursor csr_chk_person_exists to
    -- use ptu table.
    cursor csr_chk_person_exists is
   /* select  per.business_group_id,
              per.employee_number,
              per.effective_start_date,
              pet.system_person_type
      from    per_person_types pet,
              per_people_f per
      where   per.person_id = p_person_id
      and     pet.person_type_id        = per.person_type_id
      and     pet.business_group_id + 0 = per.business_group_id
      and     p_effective_date
      between per.effective_start_date
      and     per.effective_end_date;*/
   select  per.business_group_id,
              per.employee_number,
              per.effective_start_date,
              pet.system_person_type
      from    per_person_types pet,
              per_people_f per,
              per_person_type_usages_f ptu
      where   per.person_id = p_person_id
      and     pet.person_type_id        = ptu.person_type_id
      and     ptu.person_id = per.person_id
      -- added this condition for 5601538
      and     p_effective_date between  ptu.effective_start_date and ptu.effective_end_date
      /*and     ptu.effective_start_date = per.effective_start_date
      and     ptu.effective_end_date   = per.effective_end_date commented for bug 5601538*/
      and     pet.business_group_id + 0 = per.business_group_id
      and     p_effective_date
      between per.effective_start_date
      and     per.effective_end_date;
    --
  begin
 if g_debug then
  l_proc := g_package||'get_person_details';
    hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
    --
    open  csr_chk_person_exists;
    fetch csr_chk_person_exists into
      p_business_group_id, p_employee_number, p_effective_start_date,
      p_system_person_type;
    if csr_chk_person_exists%notfound then
      close csr_chk_person_exists;
      --
      -- the person cannot exist as of the supplied effective_date therefore
      -- we must error
      --
      -- This person either does not exist at all or does not exist as of the
      -- date specified.
      --
      hr_utility.set_message(801, 'HR_51011_PER_NOT_EXIST_DATE');
      hr_utility.raise_error;
    end if;
 --changes for bug 5601538 starts here
    Loop
    if p_system_person_type ='EX_EMP' then
      exit;
    end if;
    fetch csr_chk_person_exists into
    p_business_group_id, p_employee_number, p_effective_start_date,
    p_system_person_type;
    EXIT when csr_chk_person_exists%notfound ;

    End loop;
 --changes for bug 5601538 ends here
    close csr_chk_person_exists;
 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
 end if;
  end get_person_details;
  -- --------------------------------------------------------------------------
  -- |-------------------------< perform_validation >-------------------------|
  -- --------------------------------------------------------------------------
  --
  -- Description
  --   This procedure controls and performs the following business process
  --   validation:
  --   1) ensure that the p_person_id and p_hire_date parameters are not null.
  --   2) check that this person (p_person_id) exists as of p_hire_date and
  --      the current person type (per_people_f.person_type_id) has a
  --      corresponding system person type of EX_EMP.
  --   3) ensure the most recent period of service for this person has been
  --      completely terminated.
  --
  -- --------------------------------------------------------------------------
  procedure perform_validation
    (p_person_id                 in     number,
     p_hire_date                 in     date,
     p_effective_date               out nocopy date,
     p_business_group_id            out nocopy number,
     p_employee_number              out nocopy varchar2) is
  --
    l_proc                  varchar2(72) := g_package||'perform_validation';
    l_system_person_type    per_person_types.system_person_type%type;
    l_final_process_date    per_periods_of_service.final_process_date%type;
    l_effective_start_date  per_people_f.effective_start_date%type;
    l_dummy_number          number;
    l_dummy_emp_number      varchar2(30);
    l_dummy_date            date;
  --
  cursor csr_chk_period_of_service is
--
-- 115.57 (START)
--
    --select pos.final_process_date
    select pos.actual_termination_date,
           pos.last_standard_process_date,
           pos.final_process_date
--
-- 115.57 (END)
--
    from   per_periods_of_service pos
    where  pos.person_id = p_person_id
    order by pos.date_start desc;
--
-- 115.57 (START)
--
    l_fpd        per_periods_of_service.final_process_date%TYPE;
    l_atd        per_periods_of_service.actual_termination_date%TYPE;
    l_lspd       per_periods_of_service.last_standard_process_date%TYPE;
    --
    -- Cursor to get legislation code
    --
    CURSOR csr_per_legislation
      (p_person_id      IN per_all_people_f.person_id%TYPE
      ,p_effective_date IN DATE
      ) IS
      SELECT bus.legislation_code
      FROM per_people_f per
          ,per_business_groups bus
     WHERE per.person_id = csr_per_legislation.p_person_id
       AND per.business_group_id+0 = bus.business_group_id
       AND csr_per_legislation.p_effective_date BETWEEN per.effective_start_date
                                                AND per.effective_end_date;
--
-- 115.57 (END)
--
  --
  begin
 if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
    --
    -- Validation Logic
    --
    -- 1. ensure that the mandatory parameters p_hire_date and p_person_id
    --    are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'person id'
      ,p_argument_value => p_person_id);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'hire date'
      ,p_argument_value => p_hire_date);
    --
    -- 2. check that this person (p_person_id) exists as of p_hire_date and the
    --    the current person type (per_people_f.person_type_id) has a
    --    corresponding system person type of EX_EMP.
    --
    get_person_details
      (p_person_id                 => p_person_id,
       p_effective_date            => p_hire_date,
       p_business_group_id         => p_business_group_id,
       p_employee_number           => p_employee_number,
       p_effective_start_date      => l_effective_start_date,
       p_system_person_type        => l_system_person_type);
--
-- 115.57 (START)
--
    --
    -- Get person legislation
    --
    OPEN csr_per_legislation(p_person_id
                            ,p_hire_date
                            );
    FETCH csr_per_legislation INTO l_legislation_code;
    CLOSE csr_per_legislation;
    --
    -- Check if rehire before FPD is enabled
    --
    pay_core_utils.get_legislation_rule('REHIRE_BEFORE_FPD'
                                       ,l_legislation_code
                                       ,l_rule_value
                                       ,l_rule_found
                                       );
    --
--
-- 115.57 (END)
--
    --
    -- ensure that the system person type is 'EX_EMP'
    --
    if (l_system_person_type <> 'EX_EMP') then
      --
      -- the system person type is not 'EX_EMP' therefore error
      -- You cannot Re-Hire a person who is not an Ex-Employee.
      --
      hr_utility.set_message(801, 'HR_51012_REHIRE_NOT_EX_EMP');
      hr_utility.raise_error;
    end if;
 if g_debug then
    hr_utility.set_location(l_proc, 10);
 end if;
    --
    -- 3. ensure the most recent period of service for this person has been
    --    completely terminated. i.e. check that
    --    period_of_service.final_process_date is not null and comes before
    --    p_hire_date.
    --    we only fetch the 1st row (which is the latest pos).
    --
    open csr_chk_period_of_service;
--
-- 115.57 (START)
--
    --fetch csr_chk_period_of_service into l_final_process_date;
    fetch csr_chk_period_of_service into l_atd, l_lspd, l_fpd;
--
-- 115.57 (END)
--
    if csr_chk_period_of_service%notfound then
      close csr_chk_period_of_service;
      --
      -- a period of service row does not exist for the person therefore
      -- we must error
      --
      -- This person does not have a previous period of service
      --
      hr_utility.set_message(801, 'HR_51013_PDS_NOT_EXIST');
      hr_utility.raise_error;
    end if;
    close csr_chk_period_of_service;
    --
--
-- 115.57 (START)
--
    if (l_fpd is null) then
      --
      -- the employee cannot be terminated as the final process date has not
      -- been set
      --
      -- You cannot re-hire a person who does not have a final processing date
      -- set for their most recent period of service
      --
      hr_utility.set_message(801, 'HR_51014_REHIRE_FINAL_DATE');
      hr_utility.raise_error;
    end if;
    --
    if l_rule_found and nvl(l_rule_value,'N') = 'Y' then
      --
      -- Rehire before FPD allowed (new behaviour)
      --
      if nvl(l_lspd,l_atd) >= p_hire_date then
        --
        -- the re hire date is before the current LSPD or ATD
        --
        -- You cannot re-hire an Ex-Employee before their LSPD.
        -- Please specify a Re-Hire date which is after the LSPD.
        --
        --hr_utility.set_message(801, 'HR_449759_REHIRE_AFTER_LSPD');
	hr_utility.set_message(800, 'HR_449759_REHIRE_AFTER_LSPD');		-- product ID corrected for bug fix 8929785
        hr_utility.raise_error;
      end if;
    else
      --
      -- Rehire before FPD is not allowed (old behaviour)
      --
      if l_fpd >= p_hire_date then
        --
        -- the re hire date is before the current final process date
        --
        -- You cannot re-hire an Ex-Employee before their final processing date.
        -- Please specify a Re-Hire date which is after the final processing date.
        --
        hr_utility.set_message(801, 'HR_51015_REHIRE_NEW_DATE');
        hr_utility.raise_error;
      end if;
    end if;
    --
    --if (l_final_process_date is null) then
    --  --
    --  -- the employee cannot be terminated as the final process date has not
    --  -- been set
    --  --
    --  -- You cannot re-hire a person who does not have a final processing date
    --  -- set for their most recent period of service
    --  --
    --  hr_utility.set_message(801, 'HR_51014_REHIRE_FINAL_DATE');
    --  hr_utility.raise_error;
    --elsif (l_final_process_date >= p_hire_date) then
    --  --
    --  -- the re hire date is before the current final process date
    --  --
    --  -- You cannot re-hire an Ex-Employee before their final processing date.
    --  -- Please specify a Re-Hire date which is after the final processing date.
    --  --
    --  hr_utility.set_message(801, 'HR_51015_REHIRE_NEW_DATE');
    --  hr_utility.raise_error;
    --end if;
--
-- 115.57 (START)
--
 if g_debug then
    hr_utility.set_location(l_proc, 20);
 end if;
    p_effective_date := l_effective_start_date;
    --

 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 25);
 end if;
end perform_validation;

begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  -- Issue a savepoint.
  --
  savepoint re_hire_ex_employee;
  --
  -- Initialise local variables
  --
  l_object_version_number := p_per_object_version_number;
  l_applicant_number := hr_api.g_varchar2;
  l_npw_number       := hr_api.g_varchar2;
  l_hire_date        := trunc(p_hire_date);
  --
  -- perform business process validation
  --
  perform_validation
    (p_person_id                 => p_person_id,
     p_hire_date                 => l_hire_date,
     p_effective_date            => l_effective_date,
     p_business_group_id         => l_business_group_id,
     p_employee_number           => l_employee_number);
  --
  -- processing logic
  --
 if g_debug then
  hr_utility.set_location(l_proc, 10);
 end if;
  l_person_type_id := p_person_type_id;
  --
 begin
    --
    -- Start of call API User Hook for the before hook of re_hire_ex_employee
    --
hr_employee_bk2.re_hire_ex_employee_b
  (
   p_business_group_id             =>l_business_group_id
  ,p_hire_date                     =>l_hire_date
  ,p_person_id                     =>p_person_id
  ,p_per_object_version_number     =>p_per_object_version_number
  ,p_person_type_id                =>p_person_type_id
  ,p_rehire_reason                 =>p_rehire_reason
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'RE_HIRE_EX_EMPLOYEE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of re_hire_ex_employee
    --
  end;
  --
  -- derive and/or validate the person type
  --
  per_per_bus.chk_person_type
    (p_person_type_id     => l_person_type_id,
     p_business_group_id  => l_business_group_id,
     p_expected_sys_type  => 'EMP');
  --
 if g_debug then
  hr_utility.set_location(l_proc, 15);
 end if;
  --
  if (l_effective_date = p_hire_date) then
    l_datetrack_mode := 'CORRECTION';
  else
    l_datetrack_mode := 'UPDATE';
  end if;

-- PTU : Added

  l_person_type_id1 := hr_person_type_usage_info.get_default_person_type_id
                                        (l_business_group_id,
                                         'EMP');
-- PTU : End

  -- update the person re-hiring as an employee as of the hire date
  --
  per_per_upd.upd
    (p_person_id                 => p_person_id,
     p_person_type_id            => l_person_type_id1,
     p_effective_date            => l_hire_date,
     p_datetrack_mode            => l_datetrack_mode,
     p_object_version_number     => p_per_object_version_number,
     p_dob_null_warning          => p_assign_payroll_warning,
     p_effective_start_date      => l_per_effective_start_date,
     p_effective_end_date        => l_per_effective_end_date,
     p_rehire_reason             => p_rehire_reason,
     p_name_combination_warning  => l_name_combination_warning,
     p_orig_hire_warning         => l_orig_hire_warning,
     p_comment_id                => l_comment_id,
     p_current_applicant_flag    => l_current_applicant_flag,
     p_current_emp_or_apl_flag   => l_current_emp_or_apl_flag,
     p_current_employee_flag     => l_current_employee_flag,
     p_employee_number           => l_employee_number,
     p_applicant_number          => l_applicant_number,
     p_full_name                 => l_full_name,
     p_npw_number                => l_npw_number);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- add to current security list
  -- when in validation only mode raise the Validate_Enabled exception
  --
  hr_security_internal.populate_new_person(l_business_group_id,p_person_id);
-- PTU : Following Code has been added
-- Bug 3611984 starts here
  begin
   open c_ptu_start_date;
   fetch c_ptu_start_date into l_ptu_effective_start_date;
   close c_ptu_start_date;
  end;

  if (l_ptu_effective_start_date = p_hire_date) then
    l_ptu_datetrack_mode := 'CORRECTION';
  else
    l_ptu_datetrack_mode := 'UPDATE';
  end if;
-- Bug 3611984 ends here
  hr_per_type_usage_internal.maintain_person_type_usage
  (p_effective_date        => l_hire_date
  ,p_person_id             => p_person_id
  ,p_person_type_id        => l_person_type_id
  ,p_datetrack_update_mode => l_ptu_datetrack_mode -- #3611984 l_datetrack_mode
  );

-- PTU : End of changes
  --
 if g_debug then
  hr_utility.set_location(l_proc, 22);
 end if;
  --
  -- create a new period of service for the re-hired employee
  --
  per_pds_ins.ins
    (p_business_group_id         => l_business_group_id,
     p_person_id                 => p_person_id,
     p_date_start                => l_hire_date,
     p_period_of_service_id      => l_period_of_service_id,
     p_effective_date            => p_hire_date,
     p_validate_df_flex          => false,
     p_object_version_number     => l_pds_object_version_number);
  --
 if g_debug then
  hr_utility.set_location(l_proc, 25);
 end if;
  --
  -- create a default primary assignment with any corresponding standard
  -- element entries for the re-hired employee
  --
  hr_assignment_internal.create_default_emp_asg
    (p_effective_date         => l_hire_date,
     p_person_id              => p_person_id,
     p_business_group_id      => l_business_group_id,
     p_period_of_service_id   => l_period_of_service_id,
     p_assignment_id          => l_assignment_id,
     p_object_version_number  => l_asg_object_version_number,
     p_assignment_sequence    => l_assignment_sequence,
     p_assignment_number      => l_assignment_number);
--
-- 115.57 (START)
--
  if g_debug then
    hr_utility.set_location(l_proc, 26);
  end if;
  --
  -- If rehire before FPD is allowed, any resulting overlapping PDS
  -- will require updating the terminated primary assignment to
  -- secondary.
  --
  if l_rule_found and nvl(l_rule_value,'N') = 'Y' then
    manage_rehire_primary_asgs(p_person_id   => p_person_id
                              ,p_rehire_date => l_hire_date
                              ,p_cancel      => 'N'
                              );
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 27);
  end if;
--
-- 115.57 (END)
--
  --
  -- when in validation only mode raise the Validate_Enabled exception
  --
  -- 1766066: added call for contact start date enh.
  --
  per_people12_pkg.maintain_coverage(p_person_id      => p_person_id
                                    ,p_type           => 'EMP'
                                    );
  -- 1766066 end.
begin
    --
    -- Start of call API User Hook for the after hook of re_hire_ex_employee
    --
hr_employee_bk2.re_hire_ex_employee_a
  (
   p_business_group_id             =>l_business_group_id
  ,p_hire_date                     =>l_hire_date
  ,p_person_id                     =>p_person_id
  ,p_per_object_version_number     =>p_per_object_version_number
  ,p_person_type_id                =>p_person_type_id
  ,p_rehire_reason                 =>p_rehire_reason
  ,p_assignment_id                 =>l_assignment_id
  ,p_asg_object_version_number     =>l_asg_object_version_number
  ,p_per_effective_start_date      =>l_per_effective_start_date
  ,p_per_effective_end_date        =>l_per_effective_end_date
  ,p_assignment_sequence           =>l_assignment_sequence
  ,p_assignment_number             =>l_assignment_number
  ,p_assign_payroll_warning        =>l_assign_payroll_warning
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'RE_HIRE_EX_EMPLOYEE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the after hook of re_hire_ex_employee
    --
  end;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
   p_assignment_id                    := l_assignment_id;
   p_asg_object_version_number        := l_asg_object_version_number;
   p_per_effective_start_date         := l_per_effective_start_date;
   p_per_effective_end_date           := l_per_effective_end_date;
   p_assignment_sequence              := l_assignment_sequence;
   p_assignment_number                := l_assignment_number;
   p_assign_payroll_warning           := l_assign_payroll_warning;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO re_hire_ex_employee;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_per_object_version_number := l_object_version_number;
    p_assignment_id             := null;
    p_asg_object_version_number := null;
    p_per_effective_start_date  := null;
    p_per_effective_end_date    := null;
    p_assignment_sequence       := null;
    p_assignment_number         := null;
    p_assign_payroll_warning    := l_assign_payroll_warning;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_per_object_version_number := l_ovn;
    p_assignment_id             := null;
    p_asg_object_version_number := null;
    p_per_effective_start_date  := null;
    p_per_effective_end_date    := null;
    p_assignment_sequence       := null;
    p_assignment_number         := null;
    p_assign_payroll_warning    := false;
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO re_hire_ex_employee;
    --
    -- set in out parameters and set out parameters
    --
    raise;
    --
    -- End of fix.
    --
 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 35);
 end if;
end re_hire_ex_employee;
--
-- OLD
-- ----------------------------------------------------------------------------
-- |-----------------< apply_for_internal_vacancy >-------------------------|
-- ----------------------------------------------------------------------------
-- OLD
procedure apply_for_internal_vacancy
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_applicant_number              in out nocopy varchar2
  ,p_per_object_version_number     in out nocopy number
  ,p_vacancy_id                    in     number   default null
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_application_id                   out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ) is
  --
  l_warning boolean;
  --
begin
  hr_employee_api.apply_for_internal_vacancy
  (p_validate                    => p_validate
  ,p_effective_date              => p_effective_date
  ,p_person_id                   => p_person_id
  ,p_applicant_number            => p_applicant_number
  ,p_per_object_version_number   => p_per_object_version_number
  ,p_vacancy_id                  => p_vacancy_id
  ,p_person_type_id              => p_person_type_id
  ,p_application_id              => p_application_id
  ,p_assignment_id               => p_assignment_id
  ,p_apl_object_version_number   => p_apl_object_version_number
  ,p_asg_object_version_number   => p_asg_object_version_number
  ,p_assignment_sequence         => p_assignment_sequence
  ,p_per_effective_start_date    => p_per_effective_start_date
  ,p_per_effective_end_date      => p_per_effective_end_date
  ,p_appl_override_warning       => l_warning
  );
end apply_for_internal_vacancy;
-- NEW
-- ----------------------------------------------------------------------------
-- |-----------------< apply_for_internal_vacancy >-------------------------|
-- ----------------------------------------------------------------------------
-- NEW
procedure apply_for_internal_vacancy
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_applicant_number              in out nocopy varchar2
  ,p_per_object_version_number     in out nocopy number
  ,p_vacancy_id                    in     number   default null
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_application_id                   out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_appl_override_warning            out nocopy boolean -- 3652025
  ) is
  --
  -- declare local variables
  --
  l_proc                      varchar2(72) := g_package||'apply_for_internal_vacancy';
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
--         apply_for_internal_vacancy
--
  l_apl_object_version_number          number; -- THESE NEED TO BE CHANGED
  l_asg_object_version_number          number; -- THESE NEED TO BE CHANGED
  l_per_effective_start_date           date;
  l_per_effective_end_date             date;
--
    --
    -- select and validate the person
    --
    -- now returns employee number which is needed by upd.upd - thayden
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
      and     l_effective_date
      between ppf.effective_start_date
      and     ppf.effective_end_date;
    --
    --  Get default person type id for a system person type EMP_APL
    --
    cursor csr_get_person_type_id is
      select   person_type_id
      from     per_person_types
      where business_group_id = l_business_group_id
      and   active_flag = 'Y'
      and   default_flag = 'Y'
      and   system_person_type = 'EMP_APL';
    --
    -- Get organization id for business group.
    --
    cursor csr_get_organization_id is
      select  organization_id
             ,legislation_code
             ,default_start_time
             ,default_end_time
             ,fnd_number.canonical_to_number(working_hours)
             ,frequency
              from per_business_groups
      where business_group_id = l_business_group_id;
    --
    -- Get vacancy information.
    --
    cursor csr_get_vacancy_details is
      select  recruiter_id
             ,grade_id
             ,position_id
             ,job_id
             ,location_id
             ,people_group_id
             ,organization_id   -- added org id to cursor. thayden 7/10.
             ,business_group_id  -- added business_group_id to cursor lma 7/11
       from per_vacancies
      where vacancy_id = p_vacancy_id;
    --
  begin
    -- Bug 665566 Savepoint issued before validations start
    --
    -- Issue a savepoint if operating in validation only mode.
    --
    if p_validate then
      savepoint apply_for_internal_vacancy;
    end if;
    -- Bug 665566 End

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
    -- the current person type (per_people_f.person_type_id) has a
    -- corresponding system person type of EMP.
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
    -- ensure that the system person type is 'EMP'
    -- added and l_system_person_type <> 'EMP_APL' to if 15-Jul-97 lma
    if (l_system_person_type <> 'EMP' and l_system_person_type <> 'EMP_APL') then
      --
      -- the system person type is not 'EMP'.
      --
      hr_utility.set_message(800, 'PER_52788_PER_INV_PER_TYPE');
      hr_utility.raise_error;
    end if;
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
    -- Start of call API User Hook for the before hook of apply_for_internal_vacancy_b
    --
hr_employee_bk3.apply_for_internal_vacancy_b
   (
    p_business_group_id                => l_business_group_id
   ,p_effective_date                   => l_effective_date
   ,p_person_id                        => p_person_id
   ,p_applicant_number                 => p_applicant_number
   ,p_per_object_version_number        => p_per_object_version_number
   ,p_vacancy_id                       => p_vacancy_id
   ,p_person_type_id                   => p_person_type_id
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'APPLY_FOR_INTERNAL_VACANCY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of apply_for_internal_vacancy
    --
  end;
  -- processing logic
  --
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
    -- PTU : Following Code has been added
    -- Validate that the person_type_id passed is a flavour of 'APL' or derive the default
    --
    per_per_bus.chk_person_type
    (p_person_type_id     => l_person_type_id,
     p_business_group_id  => l_business_group_id,
     p_expected_sys_type  => 'APL');
    --
    --  Get default person type id for EMP_APL.
    --
    l_person_type_id1 :=  hr_person_type_usage_info.get_default_person_type_id
            (l_business_group_id,
          'EMP_APL');
    -- PTU end of changes
    --
--  open  csr_get_person_type_id;
--  fetch csr_get_person_type_id into
--      l_person_type_id;
--    if csr_get_person_type_id%notfound then
--      close csr_get_person_type_id;
--      hr_utility.set_message(801, 'HR_7513_PER_TYPE_INVALID');
--      hr_utility.raise_error;
--    end if;
--  close csr_get_person_type_id;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 25);
 end if;
  --
  --  Get organization id
  --
  open  csr_get_organization_id;
  fetch csr_get_organization_id into
      l_organization_id
     ,l_legislation_code
     ,l_default_start_time
     ,l_default_end_time
     ,l_normal_hours
     ,l_frequency;
    if csr_get_organization_id%notfound then
      close csr_get_organization_id;
      hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
      hr_utility.raise_error;
    end if;
    close csr_get_organization_id;
  --
  --  Get vacancy details.
  --
  if p_vacancy_id is not null then
    open  csr_get_vacancy_details;
    fetch csr_get_vacancy_details into
      l_recruiter_id
     ,l_grade_id
     ,l_position_id
     ,l_job_id
     ,l_location_id
     ,l_people_group_id
     ,l_vac_organization_id  -- added org id. thayden 7/10.
     ,l_vac_business_group_id;   -- added business_group_id. thayden 7/11.
    if csr_get_vacancy_details%notfound then
      close csr_get_vacancy_details;
      hr_utility.set_message(801, 'HR_51001_THE_VAC_NOT_FOUND');
      hr_utility.raise_error;
    end if;
    close csr_get_vacancy_details;
    --added if ... end if (Rod's sugguestion)
    if l_vac_organization_id is null then
      l_vac_organization_id := l_vac_business_group_id;
    end if;
  else
   l_vac_organization_id  := l_business_group_id;
  end if;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- 3652025: Create an applicant, generate the application and
  --          the applicant assignment
  --
  hr_applicant_internal.create_applicant_anytime
      (p_effective_date                => l_effective_date
      ,p_person_id                     => p_person_id
      ,p_applicant_number              => p_applicant_number
      ,p_per_object_version_number     => p_per_object_version_number
      ,p_vacancy_id                    => p_vacancy_id
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
  if g_debug then
     hr_utility.set_location(l_proc, 35);
  end if;
  --
  hr_security_internal.add_to_person_list(l_effective_date,l_assignment_id);
  --
  if g_debug then
     hr_utility.set_location(l_proc, 40);
  end if;
  --
  --
  begin
    --
    -- Start of call API User Hook for the after hook of re_hire_ex_employee
    --
    hr_employee_bk3.apply_for_internal_vacancy_a
     (
      p_business_group_id             => l_business_group_id
     ,p_effective_date                => l_effective_date
     ,p_person_id                     => p_person_id
     ,p_applicant_number              => p_applicant_number
     ,p_per_object_version_number     => p_per_object_version_number
     ,p_vacancy_id                    => p_vacancy_id
     ,p_person_type_id                => p_person_type_id
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
        (p_module_name => 'APPLY_FOR_INTERNAL_VACANCY'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the after hook of apply_for_internal_vacancy
    --
  end;
  --
  --  Set all output arguments
  --
   p_application_id                   := l_application_id;
   p_assignment_id                    := l_assignment_id;
   p_apl_object_version_number        := l_apl_object_version_number;
   p_asg_object_version_number        := l_asg_object_version_number;
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
    ROLLBACK TO apply_for_internal_vacancy;
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

 if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 55);
 end if;
end apply_for_internal_vacancy;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< hire_into_job - old >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE hire_into_job
  (p_validate                     IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_employee_number              IN OUT NOCOPY VARCHAR2
  ,p_datetrack_update_mode        IN     VARCHAR2 DEFAULT NULL
  ,p_person_type_id               IN     NUMBER   DEFAULT NULL
  ,p_national_identifier          IN     VARCHAR2 DEFAULT NULL
  ,p_per_information7             IN     VARCHAR2 DEFAULT NULL -- 3414724
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  ,p_orig_hire_warning               OUT NOCOPY BOOLEAN
  )
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'hire_into_job';
  l_assignment_id                per_all_assignments_f.assignment_id%TYPE;
  --
BEGIN
  --
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc,10);
  end if;
  --
  hr_employee_api.hire_into_job
  (p_validate                   => p_validate
  ,p_effective_date             => p_effective_date
  ,p_person_id                  => p_person_id
  ,p_object_version_number      => p_object_version_number
  ,p_employee_number            => p_employee_number
  ,p_datetrack_update_mode      => p_datetrack_update_mode
  ,p_person_type_id             => p_person_type_id
  ,p_national_identifier        => p_national_identifier
  ,p_per_information7           => p_per_information7
  ,p_assignment_id              => l_assignment_id
  ,p_effective_start_date       => p_effective_start_date
  ,p_effective_end_date         => p_effective_end_date
  ,p_assign_payroll_warning     => p_assign_payroll_warning
  ,p_orig_hire_warning          => p_orig_hire_warning
  );
  --
  if g_debug then
     hr_utility.set_location('Leaving:'||l_proc,999);
  end if;

  --
END hire_into_job;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< hire_into_job - new >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE hire_into_job
  (p_validate                     IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_employee_number              IN OUT NOCOPY VARCHAR2
  ,p_datetrack_update_mode        IN     VARCHAR2 DEFAULT NULL
  ,p_person_type_id               IN     NUMBER   DEFAULT NULL
  ,p_national_identifier          IN     VARCHAR2 DEFAULT NULL
  ,p_per_information7             IN     VARCHAR2 DEFAULT NULL -- 3414724
  ,p_assignment_id                   OUT NOCOPY NUMBER   --Bug#3919096
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
  ,p_orig_hire_warning               OUT NOCOPY BOOLEAN
  )
IS
  --
  -- Local variables
  --
  l_proc                         VARCHAR2(72) := g_package||'hire_into_job';
  --
  l_effective_date               DATE;
  --
  l_object_version_number        CONSTANT per_all_assignments_f.object_version_number%TYPE := p_object_version_number;
  l_datetrack_update_mode        VARCHAR2(30) := p_datetrack_update_mode;
  l_employee_number              CONSTANT per_all_people_f.applicant_number%TYPE           := p_employee_number;
  l_emp_num per_all_people_f.applicant_number%TYPE  := p_employee_number;
  l_ovn per_all_people_f.object_version_number%TYPE := p_object_version_number;
  l_per_effective_start_date     per_all_people_f.effective_start_date%TYPE;
  l_per_effective_end_date       per_all_people_f.effective_end_date%TYPE;
  l_assign_payroll_warning       BOOLEAN;
  l_orig_hire_warning            BOOLEAN;
  --
  l_person_type_id               per_person_types.person_type_id%TYPE    := p_person_type_id;
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
  l_period_of_service_id         per_periods_of_service.period_of_service_id%TYPE;
  l_pds_object_version_number    per_periods_of_service.object_version_number%TYPE;
  l_assignment_id                per_all_assignments_f.assignment_id%TYPE;
  l_asg_object_version_number    per_all_assignments_f.object_version_number%TYPE;
  l_assignment_sequence          per_all_assignments_f.assignment_sequence%TYPE;
  l_assignment_number            per_all_assignments_f.assignment_number%TYPE;
  l_person_type_usage_id         per_person_type_usages.person_type_usage_id%TYPE;
  l_ptu_object_version_number    per_person_type_usages.object_version_number%TYPE;
  --
  -- Start of fix for bug 3143299
  l_final_process_date      per_periods_of_service.final_process_date%type;
  --
  -- Local cursors
  cursor csr_chk_period_of_service is
--
-- 115.57 (START)
--
  --select pos.final_process_date
  select pos.actual_termination_date,
         pos.last_standard_process_date,
         pos.final_process_date
--
-- 115.57 (END)
--
  from   per_periods_of_service pos
  where  pos.person_id = p_person_id
  order by pos.date_start desc;
--
-- 115.57 (START)
--
  l_fpd        per_periods_of_service.final_process_date%TYPE;
  l_atd        per_periods_of_service.actual_termination_date%TYPE;
  l_lspd       per_periods_of_service.last_standard_process_date%TYPE;
  l_rule_value pay_legislation_rules.rule_mode%TYPE;
  l_rule_found BOOLEAN;
--
-- 115.57 (END)
--
  --
  -- End of fix for bug 3143299
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
 if g_debug then
  hr_utility.set_location('Entering:'||l_proc,10);
 end if;
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
  SAVEPOINT hire_into_job;
  --
 if g_debug then
  hr_utility.set_location(l_proc,20);
 end if;
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
 if g_debug then
  hr_utility.set_location(l_proc,30);
 end if;
  --
  -- Call Before Process User Hook
  --
  BEGIN
    hr_employee_bk4.hire_into_job_b
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_business_group_id            => l_per_details_rec.business_group_id
      ,p_object_version_number        => p_object_version_number
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_employee_number              => p_employee_number
      ,p_person_type_id               => p_person_type_id
      ,p_national_identifier          => p_national_identifier
      ,p_per_information7             => p_per_information7 --3414274
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HIRE_INTO_JOB'
        ,p_hook_type   => 'BP'
        );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,40);
 end if;
  --
  -- Check the person is of a correct system person type
  --
  IF l_per_details_rec.system_person_type NOT IN ('EX_APL','EX_EMP','OTHER')
  THEN
 if g_debug then
    hr_utility.set_location(l_proc,50);
 end if;
    hr_utility.set_message(800,'PER_52096_APL_INV_PERSON_TYPE');
    hr_utility.raise_error;
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc,60);
 end if;
  -- Start of fix for bug 3143299.
  --
--
-- 115.57 (START)
--
  pay_core_utils.get_legislation_rule('REHIRE_BEFORE_FPD'
                                     ,l_per_details_rec.legislation_code
                                     ,l_rule_value
                                     ,l_rule_found
                                     );
  --
  if g_debug then
    hr_utility.set_location(l_proc,62);
  end if;
--
-- 115.57 (END)
--
  --
  -- if the person is of type Ex-employee then ensure the most recent period
  -- of service for this person has been completely terminated. i.e. check
  -- that period_of_service.final_process_date is not null and comes before
  -- p_hire_date. we only fetch the 1st row (which is the latest pos).
  --
  if l_per_details_rec.system_person_type = 'EX_EMP' then
  --
     open csr_chk_period_of_service;
--
-- 115.57 (START)
--
     --fetch csr_chk_period_of_service into l_final_process_date;
     fetch csr_chk_period_of_service into l_atd, l_lspd, l_fpd;
--
-- 115.57 (END)
--
     if csr_chk_period_of_service%notfound then
        close csr_chk_period_of_service;
        --
        -- a period of service row does not exist for the person therefore
        -- we must error
        --
        -- This person does not have a previous period of service
        --
        hr_utility.set_message(801, 'HR_51013_PDS_NOT_EXIST');
        hr_utility.raise_error;
     end if;
     close csr_chk_period_of_service;
     --
--
-- 115.57 (START)
--
     if (l_fpd is null) then
        --
        -- the employee cannot be terminated as the final process date has not
        -- been set
        --
        -- You cannot re-hire a person who does not have a final processing date
        -- set for their most recent period of service
        --
        hr_utility.set_message(801, 'HR_51014_REHIRE_FINAL_DATE');
        hr_utility.raise_error;
     end if;
     --
     if l_rule_found and nvl(l_rule_value,'N') = 'Y' then
       --
       -- Rehire before FPD allowed (new behaviour)
       --
       if nvl(l_lspd,l_atd) >= l_effective_date then
         --
         -- the re hire date is before the current LSPD or ATD
         --
         -- You cannot re-hire an Ex-Employee before their LSPD.
         -- Please specify a Re-Hire date which is after the LSPD.
         --
         -- hr_utility.set_message(801, 'HR_449759_REHIRE_AFTER_LSPD');
	 hr_utility.set_message(800, 'HR_449759_REHIRE_AFTER_LSPD');		-- product ID corrected for bug fix 8929785
         hr_utility.raise_error;
       end if;
     else
       --
       -- Rehire before FPD is not allowed (old behaviour)
       --
       if l_fpd >= l_effective_date then
         --
         -- the re hire date is before the current final process date
         --
         -- You cannot re-hire an Ex-Employee before their final processing date.
         -- Please specify a Re-Hire date which is after the final processing date.
         --
         hr_utility.set_message(801, 'HR_51015_REHIRE_NEW_DATE');
         hr_utility.raise_error;
       end if;
     end if;
     --
     --if (l_final_process_date is null) then
     --   --
     --   -- the employee cannot be terminated as the final process date has not
     --   -- been set
     --   --
     --   -- You cannot re-hire a person who does not have a final processing date
     --   -- set for their most recent period of service
     --   --
     --   hr_utility.set_message(801, 'HR_51014_REHIRE_FINAL_DATE');
     --   hr_utility.raise_error;
     --elsif (l_final_process_date >= l_effective_date) then
     --   --
     --   -- the re hire date is before the current final process date
     --   --
     --   -- You cannot re-hire an Ex-Employee before their final processing date.
     --   -- Please specify a Re-Hire date which is after the final processing date.
     --   --
     --   hr_utility.set_message(801, 'HR_51015_REHIRE_NEW_DATE');
     --   hr_utility.raise_error;
     --end if;
--
-- 115.57 (END)
--
  end if;
 --
 if g_debug then
     hr_utility.set_location(l_proc,65);
 end if;
 -- End of fix for bug 3143299

  -- Ensure the employee number will not be changed if it exists
  --
  IF    l_per_details_rec.employee_number IS NOT NULL
    AND NVL(p_employee_number,hr_api.g_number) <> l_per_details_rec.employee_number
  THEN
 if g_debug then
     hr_utility.set_location(l_proc,70);
 end if;
     p_employee_number := l_per_details_rec.employee_number;
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc,80);
 end if;
  --
  -- Check the person does not have future assignment changes
  --
  l_future_asgs_count := future_asgs_count
                           (p_person_id                    => p_person_id
                           ,p_effective_date               => l_effective_date
                           );
  IF l_future_asgs_count > 0
  THEN
 if g_debug then
    hr_utility.set_location(l_proc,90);
 end if;
    hr_utility.set_message(800,'HR_7975_ASG_INV_FUTURE_ASA');
    hr_utility.raise_error;
  END IF;
  --
 if g_debug then
  hr_utility.set_location(l_proc,100);
 end if;
  --
  -- If person type id is not null check it corresponds to the correct type for
  -- the persons current system person type is currently active and in the
  -- correct business group, otherwise set person type id to the active default
  -- for the correct system person type in the correct business group
  --
 if g_debug then
  hr_utility.set_location(l_proc,110);
 end if;
  l_system_person_type := 'EMP';
  per_per_bus.chk_person_type
    (p_person_type_id               => l_person_type_id
    ,p_business_group_id            => l_per_details_rec.business_group_id
    ,p_expected_sys_type            => l_system_person_type
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc,120);
 end if;
  --
  -- Check the datetrack mode
  --
  IF (l_per_details_rec.system_person_type IN ('OTHER','EX_EMP'))  -- Bug 3230389
  THEN
    IF (l_datetrack_update_mode IS NULL)
    THEN
      if l_effective_date = l_per_details_rec.effective_start_date then -- 3194314
         l_datetrack_update_mode := hr_api.g_correction;
      else
         l_datetrack_update_mode := hr_api.g_update;
      end if;
    ELSE
      IF (l_datetrack_update_mode NOT IN (hr_api.g_update,hr_api.g_correction))
      THEN
        hr_utility.set_message(800,'HR_7203_DT_UPD_MODE_INVALID');
        hr_utility.raise_error;
      END IF;
    END IF;
  ELSE
    l_datetrack_update_mode := hr_api.g_update;
  END IF;
  --
  -- PTU : Added

  l_person_type_id1 := hr_person_type_usage_info.get_default_person_type_id
                                ( l_per_details_rec.business_group_id,
                                'EMP');
  -- PTU : End

  -- Update the person details to the new person type
  --
  per_per_upd.upd
    (p_person_id                    => p_person_id
    ,p_effective_start_date         => l_per_effective_start_date
    ,p_effective_end_date           => l_per_effective_end_date
    ,p_person_type_id               => l_person_type_id1
    ,p_applicant_number             => l_per_details_rec.applicant_number
    ,p_comment_id                   => l_comment_id
    ,p_current_applicant_flag       => l_current_applicant_flag
    ,p_current_emp_or_apl_flag      => l_current_emp_or_apl_flag
    ,p_current_employee_flag        => l_current_employee_flag
    ,p_employee_number              => p_employee_number
    ,p_national_identifier          => p_national_identifier
    ,p_full_name                    => l_full_name
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => l_effective_date
    ,p_datetrack_mode               => l_datetrack_update_mode
    ,p_name_combination_warning     => l_name_combination_warning
    ,p_dob_null_warning             => l_assign_payroll_warning
    ,p_orig_hire_warning            => l_orig_hire_warning
    ,p_npw_number                   => l_per_details_rec.npw_number
    ,p_per_information7             => p_per_information7 --3414274
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc,130);
 end if;
  --
  -- add to current security list
  --
  hr_security_internal.populate_new_person(l_per_details_rec.business_group_id,p_person_id);
  --
 if g_debug then
  hr_utility.set_location(l_proc,135);
 end if;
  --
  -- Create an period of service for the person
  --
  per_pds_ins.ins
    (p_effective_date               => l_effective_date
    ,p_business_group_id            => l_per_details_rec.business_group_id
    ,p_person_id                    => p_person_id
    ,p_date_start                   => l_effective_date
    ,p_validate_df_flex             => false
    ,p_period_of_service_id         => l_period_of_service_id
    ,p_object_version_number        => l_pds_object_version_number
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc,140);
 end if;
  --
  -- Create a default employee assignment for the person
  --
  hr_assignment_internal.create_default_emp_asg
    (p_effective_date               => l_effective_date
    ,p_business_group_id            => l_per_details_rec.business_group_id
    ,p_person_id                    => p_person_id
    ,p_period_of_service_id         => l_period_of_service_id
    ,p_assignment_id                => l_assignment_id
    ,p_object_version_number        => l_asg_object_version_number
    ,p_assignment_sequence          => l_assignment_sequence
    ,p_assignment_number            => l_assignment_number
    );
  --
 if g_debug then
  hr_utility.set_location(l_proc,150);
 end if;
--
-- 115.57 (START)
--
  --
  -- If rehire before FPD is allowed, any resulting overlapping PDS
  -- will require updating the terminated primary assignment to
  -- secondary.
  --
  if l_rule_found and nvl(l_rule_value,'N') = 'Y' then
    manage_rehire_primary_asgs(p_person_id   => p_person_id
                              ,p_rehire_date => l_effective_date
                              ,p_cancel      => 'N'
                              );
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc,155);
  end if;
--
-- 115.57 (END)
--
  --
  -- Create person type usage record
  -- No Longer Required: This is automatically created on insert of
  -- a period of service record above.
  --
/*
  hr_per_type_usage_internal.create_person_type_usage
    (p_effective_date               => l_effective_date
    ,p_person_id                    => p_person_id
    ,p_person_type_id               => l_person_type_id
    ,p_person_type_usage_id         => l_person_type_usage_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_object_version_number        => l_ptu_object_version_number
    );
*/

-- PTU : Following Code has been added

  --start changes for bug8506648
  if per_periods_of_service_pkg_v2.IsBackToBackContract(p_person_id, l_effective_date) then
   hr_per_type_usage_internal.maintain_person_type_usage
   (p_effective_date        => l_effective_date
   ,p_person_id             => p_person_id
   ,p_person_type_id        => l_person_type_id
   ,p_datetrack_update_mode => l_datetrack_update_mode  -- Bug 3230389
   );
  else
   hr_per_type_usage_internal.maintain_person_type_usage
   (p_effective_date        => l_effective_date
   ,p_person_id             => p_person_id
   ,p_person_type_id        => l_person_type_id
   ,p_datetrack_update_mode => hr_api.g_update
   );
  end if;
  --end changes for bug8506648

-- PTU : End of changes
  -- 1766066: added call for contact start date enh.
  --
  per_people12_pkg.maintain_coverage(p_person_id      => p_person_id
                                    ,p_type           => 'EMP'
                                    );
  -- 1766066 end.
  --
  -- Call After Process User Hook
  --
  BEGIN
    hr_employee_bk4.hire_into_job_a
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      ,p_business_group_id            => l_per_details_rec.business_group_id
      ,p_object_version_number        => p_object_version_number
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_employee_number              => p_employee_number
      ,p_person_type_id               => p_person_type_id
      ,p_national_identifier          => p_national_identifier
      ,p_per_information7             => p_per_information7      -- 3414274
      ,p_assignment_id                => l_assignment_id         --Bug#3919096
      ,p_effective_start_date         => l_per_effective_start_date
      ,p_effective_end_date           => l_per_effective_end_date
      ,p_assign_payroll_warning       => l_assign_payroll_warning
      ,p_orig_hire_warning            => l_orig_hire_warning
      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit
    THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HIRE_INTO_JOB'
        ,p_hook_type   => 'AP'
        );
  END;
  --
 if g_debug then
  hr_utility.set_location(l_proc,160);
 end if;
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
  p_assignment_id                := l_assignment_id; --Bug#3919096
  p_effective_start_date         := l_per_effective_start_date;
  p_effective_end_date           := l_per_effective_end_date;
  p_assign_payroll_warning       := l_assign_payroll_warning;
  p_orig_hire_warning            := l_orig_hire_warning;
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc,1000);
 end if;
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
    ROLLBACK TO hire_into_job;
    p_object_version_number        := l_object_version_number;
    p_employee_number              := l_employee_number;
    p_assignment_id                := NULL;  --Bug#3919096
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;
    p_assign_payroll_warning       := l_assign_payroll_warning;
    p_orig_hire_warning            := l_orig_hire_warning;
  --
  WHEN OTHERS
  THEN
    --
    -- Validation or unexpected error occured
    -- Ensure opened non-local cursors are closed
    -- Rollback to savepoint
    -- Re-raise exception
    --
    ROLLBACK TO hire_into_job;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number        := l_ovn;
    p_employee_number              := l_emp_num;
    p_assignment_id                := NULL;  --Bug#3919096
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;
    p_assign_payroll_warning       := false;
    p_orig_hire_warning            := false;
    --
    IF csr_per_details%ISOPEN
    THEN
      CLOSE csr_per_details;
    END IF;
    RAISE;
--
END hire_into_job;
--
-- 115.57 (START)
--
-- ----------------------------------------------------------------------------
-- |---------------------< Update_Rehire_Primary_Asgs >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Handles the update of ASG records for rehire before FPD which leads to
--   overlapping PDS and cancel rehire with overlapping PDS. This is intended
--   to be invoked from MANAGE_REHIRE_PRIMARY_ASGS
--
-- Prerequisites:
--   The person assignments and periods of service must already be present.
--
-- In Parameters:
--   Name               Reqd  Type      Description
--   p_person_id        Yes   number    Identifier for the person
--   p_rehire_date      Yes   date      Re-Hire Date
--   p_cancel           Yes   varchar2  'Y' indicates cancel rehire
--                                      'N' indicates rehire
--
-- Post Success:
--   No error is raised if the new hire date is validSG records are updated
--   with correct primary flag values for rehire and cancel rehire.
--
-- Post Failure:
--   An error is raised and control returned.
--
-- Access Status:
--   For Oracle Internal use only.
--
-- {End Of Comments}
--
PROCEDURE update_rehire_primary_asgs
  (p_person_id          IN     NUMBER
  ,p_rehire_date        IN     DATE
  ,p_cancel             IN     VARCHAR2
  ) IS
  --
  l_proc VARCHAR2(80) := g_package||'update_rehire_primary_asgs';
  --
  -- Cursor to get primary assignment on specified date
  --
  CURSOR c_prim_asg
    (p_person_id      IN     per_all_people_f.person_id%TYPE
    ,p_effective_date IN     DATE
    ) IS
    SELECT assignment_id
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
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,created_by
          ,creation_date
          ,title
          ,object_version_number
          ,contract_id
          ,cagr_id_flex_num
          ,cagr_grade_def_id
          ,establishment_id
          ,collective_agreement_id
          ,notice_period
          ,notice_period_uom
          ,employee_category
          ,work_at_home
          ,job_post_source_name
          ,period_of_placement_date_start
          ,vendor_id
          ,vendor_site_id
          ,po_header_id
          ,po_line_id
          ,projected_assignment_end
          ,vendor_employee_number
          ,vendor_assignment_number
          ,assignment_category
          ,project_title
          ,grade_ladder_pgm_id
          ,supervisor_assignment_id
      FROM per_assignments_f
     WHERE person_id = c_prim_asg.p_person_id
       AND primary_flag = 'Y'
       AND assignment_type <> 'B' -- 115.59
       AND c_prim_asg.p_effective_date BETWEEN effective_start_date
                                           AND effective_end_date;
  --
  lr_prim_asg c_prim_asg%ROWTYPE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  SAVEPOINT update_rehire_primary_asgs;
  --
  IF p_cancel = 'Y' THEN
    --
    -- Perform Cancel Rehire updates to ASG records
    --
    hr_utility.set_location(l_proc, 10);
    --
    -- Get the primary assignment on (rehire date - 1)
    --
    OPEN c_prim_asg (p_person_id
                    ,(p_rehire_date-1)
                    );
    FETCH c_prim_asg INTO lr_prim_asg;
    IF c_prim_asg%NOTFOUND THEN
      hr_utility.set_message(800,'PER_52595_PRIM_ASG_INV');
      hr_utility.raise_error;
    END IF;
    CLOSE c_prim_asg;
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Update all assignments records for this assignment with
    -- ESD >= rehire date setting primary flag to 'Y'
    --
    UPDATE per_assignments_f
       SET primary_flag = 'Y'
          ,object_version_number = object_version_number + 1
     WHERE assignment_id = lr_prim_asg.assignment_id
       AND assignment_type <> 'B' -- 115.59
       AND effective_start_date >= p_rehire_date;
    --
  ELSIF p_cancel = 'N' THEN
    --
    -- Perform Rehire updates to ASG records
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- Get the primary assignment on rehire date
    --
    OPEN c_prim_asg (p_person_id
                    ,p_rehire_date
                    );
    FETCH c_prim_asg INTO lr_prim_asg;
    IF c_prim_asg%NOTFOUND THEN
      hr_utility.set_message(800,'PER_52595_PRIM_ASG_INV');
      hr_utility.raise_error;
    END IF;
    CLOSE c_prim_asg;
    --
    IF p_rehire_date = lr_prim_asg.effective_start_date THEN
      --
      hr_utility.set_location(l_proc, 40);
      --
      -- Set the primary assignment flag to 'N' for this record.
      --
      UPDATE per_assignments_f
         SET primary_flag = 'N'
            ,object_version_number = object_version_number + 1
       WHERE assignment_id = lr_prim_asg.assignment_id
         AND assignment_type <> 'B' -- 115.59
         AND effective_start_date = p_rehire_date;
      --
    ELSIF p_rehire_date = lr_prim_asg.effective_end_date THEN
      --
      hr_utility.set_location(l_proc, 50);
      --
      -- Update EED to rehire date - 1
      --
      UPDATE per_assignments_f
         SET effective_end_date = (p_rehire_date - 1)
            ,object_version_number = object_version_number + 1
       WHERE assignment_id = lr_prim_asg.assignment_id
         AND assignment_type <> 'B' -- 115.59
         AND effective_end_date = p_rehire_date;
      --
      hr_utility.set_location(l_proc, 60);
      --
      -- Insert new record with primary flag 'N' and ESD
      -- same as EED same as rehire date
      --
      INSERT INTO per_all_assignments_f
      (assignment_id
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
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,created_by
      ,creation_date
      ,title
      ,object_version_number
      ,contract_id
      ,cagr_id_flex_num
      ,cagr_grade_def_id
      ,establishment_id
      ,collective_agreement_id
      ,notice_period
      ,notice_period_uom
      ,employee_category
      ,work_at_home
      ,job_post_source_name
      ,period_of_placement_date_start
      ,vendor_id
      ,vendor_site_id
      ,po_header_id
      ,po_line_id
      ,projected_assignment_end
      ,vendor_employee_number
      ,vendor_assignment_number
      ,assignment_category
      ,project_title
      ,grade_ladder_pgm_id
      ,supervisor_assignment_id
      )
      VALUES
      (lr_prim_asg.assignment_id
      ,p_rehire_date       -- New ESD
      ,p_rehire_date       -- New EED
      ,lr_prim_asg.business_group_id
      ,lr_prim_asg.recruiter_id
      ,lr_prim_asg.grade_id
      ,lr_prim_asg.position_id
      ,lr_prim_asg.job_id
      ,lr_prim_asg.assignment_status_type_id
      ,lr_prim_asg.payroll_id
      ,lr_prim_asg.location_id
      ,lr_prim_asg.person_referred_by_id
      ,lr_prim_asg.supervisor_id
      ,lr_prim_asg.special_ceiling_step_id
      ,lr_prim_asg.person_id
      ,lr_prim_asg.recruitment_activity_id
      ,lr_prim_asg.source_organization_id
      ,lr_prim_asg.organization_id
      ,lr_prim_asg.people_group_id
      ,lr_prim_asg.soft_coding_keyflex_id
      ,lr_prim_asg.vacancy_id
      ,lr_prim_asg.pay_basis_id
      ,lr_prim_asg.assignment_sequence
      ,lr_prim_asg.assignment_type
      ,'N'        -- New Primary Flag
      ,lr_prim_asg.application_id
      ,lr_prim_asg.assignment_number
      ,lr_prim_asg.change_reason
      ,lr_prim_asg.comment_id
      ,lr_prim_asg.date_probation_end
      ,lr_prim_asg.default_code_comb_id
      ,lr_prim_asg.employment_category
      ,lr_prim_asg.frequency
      ,lr_prim_asg.internal_address_line
      ,lr_prim_asg.manager_flag
      ,lr_prim_asg.normal_hours
      ,lr_prim_asg.perf_review_period
      ,lr_prim_asg.perf_review_period_frequency
      ,lr_prim_asg.period_of_service_id
      ,lr_prim_asg.probation_period
      ,lr_prim_asg.probation_unit
      ,lr_prim_asg.sal_review_period
      ,lr_prim_asg.sal_review_period_frequency
      ,lr_prim_asg.set_of_books_id
      ,lr_prim_asg.source_type
      ,lr_prim_asg.time_normal_finish
      ,lr_prim_asg.time_normal_start
      ,lr_prim_asg.bargaining_unit_code
      ,lr_prim_asg.labour_union_member_flag
      ,lr_prim_asg.hourly_salaried_code
      ,lr_prim_asg.request_id
      ,lr_prim_asg.program_application_id
      ,lr_prim_asg.program_id
      ,lr_prim_asg.program_update_date
      ,lr_prim_asg.ass_attribute_category
      ,lr_prim_asg.ass_attribute1
      ,lr_prim_asg.ass_attribute2
      ,lr_prim_asg.ass_attribute3
      ,lr_prim_asg.ass_attribute4
      ,lr_prim_asg.ass_attribute5
      ,lr_prim_asg.ass_attribute6
      ,lr_prim_asg.ass_attribute7
      ,lr_prim_asg.ass_attribute8
      ,lr_prim_asg.ass_attribute9
      ,lr_prim_asg.ass_attribute10
      ,lr_prim_asg.ass_attribute11
      ,lr_prim_asg.ass_attribute12
      ,lr_prim_asg.ass_attribute13
      ,lr_prim_asg.ass_attribute14
      ,lr_prim_asg.ass_attribute15
      ,lr_prim_asg.ass_attribute16
      ,lr_prim_asg.ass_attribute17
      ,lr_prim_asg.ass_attribute18
      ,lr_prim_asg.ass_attribute19
      ,lr_prim_asg.ass_attribute20
      ,lr_prim_asg.ass_attribute21
      ,lr_prim_asg.ass_attribute22
      ,lr_prim_asg.ass_attribute23
      ,lr_prim_asg.ass_attribute24
      ,lr_prim_asg.ass_attribute25
      ,lr_prim_asg.ass_attribute26
      ,lr_prim_asg.ass_attribute27
      ,lr_prim_asg.ass_attribute28
      ,lr_prim_asg.ass_attribute29
      ,lr_prim_asg.ass_attribute30
      ,TRUNC(SYSDATE) -- New Last Update Date
      ,-1             -- New Updated By
      ,-1             -- New Update Login
      ,-1             -- New Created By
      ,TRUNC(SYSDATE) -- New Creation Date
      ,lr_prim_asg.title
      ,1              -- New OVN
      ,lr_prim_asg.contract_id
      ,lr_prim_asg.cagr_id_flex_num
      ,lr_prim_asg.cagr_grade_def_id
      ,lr_prim_asg.establishment_id
      ,lr_prim_asg.collective_agreement_id
      ,lr_prim_asg.notice_period
      ,lr_prim_asg.notice_period_uom
      ,lr_prim_asg.employee_category
      ,lr_prim_asg.work_at_home
      ,lr_prim_asg.job_post_source_name
      ,lr_prim_asg.period_of_placement_date_start
      ,lr_prim_asg.vendor_id
      ,lr_prim_asg.vendor_site_id
      ,lr_prim_asg.po_header_id
      ,lr_prim_asg.po_line_id
      ,lr_prim_asg.projected_assignment_end
      ,lr_prim_asg.vendor_employee_number
      ,lr_prim_asg.vendor_assignment_number
      ,lr_prim_asg.assignment_category
      ,lr_prim_asg.project_title
      ,lr_prim_asg.grade_ladder_pgm_id
      ,lr_prim_asg.supervisor_assignment_id
      );
      --
    ELSE -- rehire date between but not inclusive of ESD and EED
      --
      hr_utility.set_location(l_proc, 70);
      --
      -- Update EED to rehire date - 1
      --
      UPDATE per_assignments_f
         SET effective_end_date = (p_rehire_date - 1)
            ,object_version_number = object_version_number + 1
       WHERE assignment_id = lr_prim_asg.assignment_id
         AND assignment_type <> 'B' -- 115.59
         AND effective_start_date = lr_prim_asg.effective_start_date;
      --
      hr_utility.set_location(l_proc, 80);
      --
      -- Insert new record primary flag 'N' and ESD
      -- same as rehire date
      --
      INSERT INTO per_all_assignments_f
      (assignment_id
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
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,created_by
      ,creation_date
      ,title
      ,object_version_number
      ,contract_id
      ,cagr_id_flex_num
      ,cagr_grade_def_id
      ,establishment_id
      ,collective_agreement_id
      ,notice_period
      ,notice_period_uom
      ,employee_category
      ,work_at_home
      ,job_post_source_name
      ,period_of_placement_date_start
      ,vendor_id
      ,vendor_site_id
      ,po_header_id
      ,po_line_id
      ,projected_assignment_end
      ,vendor_employee_number
      ,vendor_assignment_number
      ,assignment_category
      ,project_title
      ,grade_ladder_pgm_id
      ,supervisor_assignment_id
      )
      VALUES
      (lr_prim_asg.assignment_id
      ,p_rehire_date     -- New ESD
      ,lr_prim_asg.effective_end_date
      ,lr_prim_asg.business_group_id
      ,lr_prim_asg.recruiter_id
      ,lr_prim_asg.grade_id
      ,lr_prim_asg.position_id
      ,lr_prim_asg.job_id
      ,lr_prim_asg.assignment_status_type_id
      ,lr_prim_asg.payroll_id
      ,lr_prim_asg.location_id
      ,lr_prim_asg.person_referred_by_id
      ,lr_prim_asg.supervisor_id
      ,lr_prim_asg.special_ceiling_step_id
      ,lr_prim_asg.person_id
      ,lr_prim_asg.recruitment_activity_id
      ,lr_prim_asg.source_organization_id
      ,lr_prim_asg.organization_id
      ,lr_prim_asg.people_group_id
      ,lr_prim_asg.soft_coding_keyflex_id
      ,lr_prim_asg.vacancy_id
      ,lr_prim_asg.pay_basis_id
      ,lr_prim_asg.assignment_sequence
      ,lr_prim_asg.assignment_type
      ,'N'        -- New Primary Flag
      ,lr_prim_asg.application_id
      ,lr_prim_asg.assignment_number
      ,lr_prim_asg.change_reason
      ,lr_prim_asg.comment_id
      ,lr_prim_asg.date_probation_end
      ,lr_prim_asg.default_code_comb_id
      ,lr_prim_asg.employment_category
      ,lr_prim_asg.frequency
      ,lr_prim_asg.internal_address_line
      ,lr_prim_asg.manager_flag
      ,lr_prim_asg.normal_hours
      ,lr_prim_asg.perf_review_period
      ,lr_prim_asg.perf_review_period_frequency
      ,lr_prim_asg.period_of_service_id
      ,lr_prim_asg.probation_period
      ,lr_prim_asg.probation_unit
      ,lr_prim_asg.sal_review_period
      ,lr_prim_asg.sal_review_period_frequency
      ,lr_prim_asg.set_of_books_id
      ,lr_prim_asg.source_type
      ,lr_prim_asg.time_normal_finish
      ,lr_prim_asg.time_normal_start
      ,lr_prim_asg.bargaining_unit_code
      ,lr_prim_asg.labour_union_member_flag
      ,lr_prim_asg.hourly_salaried_code
      ,lr_prim_asg.request_id
      ,lr_prim_asg.program_application_id
      ,lr_prim_asg.program_id
      ,lr_prim_asg.program_update_date
      ,lr_prim_asg.ass_attribute_category
      ,lr_prim_asg.ass_attribute1
      ,lr_prim_asg.ass_attribute2
      ,lr_prim_asg.ass_attribute3
      ,lr_prim_asg.ass_attribute4
      ,lr_prim_asg.ass_attribute5
      ,lr_prim_asg.ass_attribute6
      ,lr_prim_asg.ass_attribute7
      ,lr_prim_asg.ass_attribute8
      ,lr_prim_asg.ass_attribute9
      ,lr_prim_asg.ass_attribute10
      ,lr_prim_asg.ass_attribute11
      ,lr_prim_asg.ass_attribute12
      ,lr_prim_asg.ass_attribute13
      ,lr_prim_asg.ass_attribute14
      ,lr_prim_asg.ass_attribute15
      ,lr_prim_asg.ass_attribute16
      ,lr_prim_asg.ass_attribute17
      ,lr_prim_asg.ass_attribute18
      ,lr_prim_asg.ass_attribute19
      ,lr_prim_asg.ass_attribute20
      ,lr_prim_asg.ass_attribute21
      ,lr_prim_asg.ass_attribute22
      ,lr_prim_asg.ass_attribute23
      ,lr_prim_asg.ass_attribute24
      ,lr_prim_asg.ass_attribute25
      ,lr_prim_asg.ass_attribute26
      ,lr_prim_asg.ass_attribute27
      ,lr_prim_asg.ass_attribute28
      ,lr_prim_asg.ass_attribute29
      ,lr_prim_asg.ass_attribute30
      ,TRUNC(SYSDATE) -- New Last Update Date
      ,-1             -- New Updated By
      ,-1             -- New Update Login
      ,-1             -- New Created By
      ,TRUNC(SYSDATE) -- New Creation Date
      ,lr_prim_asg.title
      ,1              -- New OVN
      ,lr_prim_asg.contract_id
      ,lr_prim_asg.cagr_id_flex_num
      ,lr_prim_asg.cagr_grade_def_id
      ,lr_prim_asg.establishment_id
      ,lr_prim_asg.collective_agreement_id
      ,lr_prim_asg.notice_period
      ,lr_prim_asg.notice_period_uom
      ,lr_prim_asg.employee_category
      ,lr_prim_asg.work_at_home
      ,lr_prim_asg.job_post_source_name
      ,lr_prim_asg.period_of_placement_date_start
      ,lr_prim_asg.vendor_id
      ,lr_prim_asg.vendor_site_id
      ,lr_prim_asg.po_header_id
      ,lr_prim_asg.po_line_id
      ,lr_prim_asg.projected_assignment_end
      ,lr_prim_asg.vendor_employee_number
      ,lr_prim_asg.vendor_assignment_number
      ,lr_prim_asg.assignment_category
      ,lr_prim_asg.project_title
      ,lr_prim_asg.grade_ladder_pgm_id
      ,lr_prim_asg.supervisor_assignment_id
      );
      --
    END IF;
    --
    hr_utility.set_location(l_proc, 90);
    --
    -- Update assignments where ESD > rehire date setting the
    -- primary flag to 'N'
    --
    UPDATE per_assignments_f
       SET primary_flag = 'N'
          ,object_version_number = object_version_number + 1
     WHERE assignment_id = lr_prim_asg.assignment_id
       AND effective_start_date > p_rehire_date;
    --
  END IF; -- check p_cancel
  --
  hr_utility.set_location('Leaving:'|| l_proc, 9998);
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    --
    -- An unexpected error has occurred
    -- No OUT parameters need to be set
    -- No cursors need to be closed
    --
    hr_utility.set_location('Leaving:'|| l_proc, 9999);
    ROLLBACK TO update_rehire_primary_asgs;
    RAISE;
    --
END update_rehire_primary_asgs;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< MANAGE_REHIRE_PRIMARY_ASGS >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:   This procedure manages the switching of the primary but
--                terminated terminated assignment of an employee on the old
--                period of service to a secondary assignment during rehire
--                and swithcing it back should the rehire be cancelled.
--
-- Prerequisites: None
--
-- In Parameters:
--   Name                       Reqd Type     Description
--   P_PERSON_ID                Yes  NUMBER   Person Identifier
--   P_REHIRE_DATE              Yes  DATE     Employee Re-hire date
--   P_CANCEL                   Yes  VARCHAR2 Flags whether rehire or cancel
--                                            rehire invocation.
--
-- Post Success:
--   The TERM_ASSIGN assignment record will be flipped from primary to
--   secondary if rehire before FPD and flipped back to primary if the
--   rehire is being cancelled.
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
procedure manage_rehire_primary_asgs
  (p_person_id   in number
  ,p_rehire_date in date
  ,p_cancel      in varchar2
  ) IS
  --
  l_proc VARCHAR2(80) := g_package||'manage_rehire_primary_asgs';
  --
  -- Cursor to get previous PDS that is the latest PDS before
  -- rehire date
  --
  CURSOR csr_prev_pds IS
    SELECT pds.period_of_service_id
          ,pds.date_start
          ,pds.actual_termination_date
          ,pds.last_standard_process_date
          ,pds.final_process_date
    FROM   per_periods_of_service pds
    WHERE  pds.person_id = p_person_id
    AND    pds.date_start < p_rehire_date
    ORDER BY pds.date_start DESC;
  --
  lr_prev_pds csr_prev_pds%ROWTYPE;
  --
  -- Cursor to get primary assignment for given PDS
  -- on given date
  --
  CURSOR csr_prim_asg(p_period_of_service_id IN NUMBER
                     ,p_person_id            IN NUMBER
                     ,p_effective_date       IN DATE
                     ) IS
    SELECT asg.assignment_id
          ,asg.effective_start_date
          ,asg.effective_end_date
    FROM   per_assignments_f asg
    WHERE  asg.period_of_service_id = csr_prim_asg.p_period_of_service_id
    AND    asg.person_id = csr_prim_asg.p_person_id
    AND    csr_prim_asg.p_effective_date BETWEEN asg.effective_start_date
                                         AND     asg.effective_end_date
    AND    asg.primary_flag = 'Y';
  --
  lr_prim_asg csr_prim_asg%ROWTYPE;
  --
  e_nothing_to_manage EXCEPTION;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  SAVEPOINT manage_rehire_primary_asgs;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Get the previous PDS that is the latest PDS before
  -- rehire date
  --
  OPEN csr_prev_pds;
  FETCH csr_prev_pds INTO lr_prev_pds;
  IF csr_prev_pds%NOTFOUND THEN
    CLOSE csr_prev_pds;
    --
    -- This is not a rehire
    --
    RAISE e_nothing_to_manage;
  END IF;
  CLOSE csr_prev_pds;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check if overlap condition
  --
  IF lr_prev_pds.final_process_date < p_rehire_date THEN
    --
    -- This is not an overlap condition
    --
    RAISE e_nothing_to_manage;
  END IF;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Get the associated primary assignment on rehire date
  --
  OPEN csr_prim_asg(lr_prev_pds.period_of_service_id
                   ,p_person_id
                   ,p_rehire_date
                   );
  FETCH csr_prim_asg INTO lr_prim_asg;
  IF csr_prim_asg%NOTFOUND THEN
    CLOSE csr_prim_asg;
    --
    hr_utility.set_location(l_proc, 35);
    --
    -- Get the associated primary assignment on actual term date
    --
    OPEN csr_prim_asg(lr_prev_pds.period_of_service_id
                     ,p_person_id
                     ,lr_prev_pds.actual_termination_date
                     );
    FETCH csr_prim_asg INTO lr_prim_asg;
    IF csr_prim_asg%NOTFOUND THEN
      CLOSE csr_prim_asg;
      --
      RAISE e_nothing_to_manage;
    END IF;
  END IF;
  CLOSE csr_prim_asg;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- if p_cancel = 'Y', this is a cancel rehire scenario
  --   find primary assignment on rehire date - 1
  --   DT CORRECTION to ASG records with ESD >= rehire date to primary
  -- else if p_cancel = 'N', this is a rehire scenario
  --   DT UPDATE this ASG to secondary on rehire date
  --   DT CORRECTION ASG records with ESD > rehire date to secondary
  --
  update_rehire_primary_asgs
    (p_person_id     => p_person_id
    ,p_rehire_date   => p_rehire_date
    ,p_cancel        => p_cancel
    );
  --
  hr_utility.set_location('Leaving:'|| l_proc, 50);
  --
EXCEPTION
  --
  WHEN e_nothing_to_manage THEN
    --
    hr_utility.set_location('Leaving:'|| l_proc, 60);
    ROLLBACK TO manage_rehire_primary_asgs;
    --
  WHEN OTHERS THEN
    --
    -- An unexpected error has occurred
    -- No OUT parameters need to be set
    -- No cursors need to be closed
    --
    hr_utility.set_location('Leaving:'|| l_proc, 70);
    ROLLBACK TO manage_rehire_primary_asgs;
    RAISE;
    --
END manage_rehire_primary_asgs;
--
-- 115.57 (END)
--
--
end hr_employee_api;

/
