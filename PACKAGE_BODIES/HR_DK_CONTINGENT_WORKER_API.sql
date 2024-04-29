--------------------------------------------------------
--  DDL for Package Body HR_DK_CONTINGENT_WORKER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DK_CONTINGENT_WORKER_API" AS
  /* $Header: pecwkdki.pkb 120.2 2005/10/18 22:59:56 saurai noship $ */
--
	-- Package Variables
	g_package  varchar2(33) := '  hr_dk_contingent_worker_api.';
        g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_dk_cwk >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_dk_cwk
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                   in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_npw_number                    in out nocopy varchar2
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_date_of_birth                 in     date     default null
  ,p_date_of_death                 in     date     default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default null
  ,p_email_address                 in     varchar2 default null
  ,p_first_name                    in     varchar2
  -- Added for bug fix 4666216
  ,p_middle_names                  in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_nationality                   in     varchar2
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_party_id                      in     number   default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_projected_placement_end       in     date     default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_sex                           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_title                         in     varchar2
  ,p_town_of_birth                 in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_work_telephone                in     varchar2 default null
  ,p_exp_check_send_to_address     in     varchar2 default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_benefit_group_id              in     number   default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_original_date_of_hire         in     date     default null
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
  ,p_initials        	   in     varchar2 default null
  ,p_jubilee_date	   in	   date	default null
  ,p_trainee			   IN     VARCHAR2 DEFAULT null
  ,p_person_id                        out nocopy   number
  ,p_per_object_version_number        out nocopy   number
  ,p_per_effective_start_date         out nocopy   date
  ,p_per_effective_end_date           out nocopy   date
  ,p_pdp_object_version_number        out nocopy   number
  ,p_full_name                        out nocopy   varchar2
  ,p_comment_id                       out nocopy   number
  ,p_assignment_id                    out nocopy   number
  ,p_asg_object_version_number        out nocopy   number
  ,p_assignment_sequence              out nocopy   number
  ,p_assignment_number                out nocopy   varchar2
  ,p_name_combination_warning         out nocopy   boolean
  )  is

  l_proc                 varchar2(72) := g_package||'update_dk_person';
  l_legislation_code     per_business_groups.legislation_code%type;
  l_discard_varchar2     varchar2(30);
  --
  cursor check_legislation
    (c_business_group_id      per_people_f.person_id%TYPE
    )
  is
    select bgp.legislation_code
    from per_business_groups bgp
    where bgp.business_group_id = c_business_group_id;

begin

 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  -- Validation in addition to Row Handlers
  --
  --
  open check_legislation(p_business_group_id);
  fetch check_legislation into l_legislation_code;
  close check_legislation;
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'DK'.
  --
  if l_legislation_code <> 'DK' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','DK');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;

hr_contingent_worker_api.create_cwk
  (p_validate                      => p_validate
  ,p_start_date                    => p_start_date
  ,p_business_group_id             => p_business_group_id
  ,p_last_name                     => p_last_name
  ,p_person_type_id                => p_person_type_id
  ,p_npw_number                    => p_npw_number
  ,p_background_check_status       => p_background_check_status
  ,p_background_date_check         => p_background_date_check
  ,p_blood_type                    => p_blood_type
  ,p_comments                      => p_comments
  ,p_correspondence_language       => p_correspondence_language
  ,p_country_of_birth              => p_country_of_birth
  ,p_date_of_birth                 => p_date_of_birth
  ,p_date_of_death                 => p_date_of_death
  ,p_dpdnt_adoption_date           => p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag        => p_dpdnt_vlntry_svce_flag
  ,p_email_address                 => p_email_address
  ,p_first_name                    => p_first_name
   -- Added for bug fix 4666216
  ,p_middle_names                  => p_middle_names
  ,p_fte_capacity                  => p_fte_capacity
  ,p_honors                        => p_honors
  ,p_internal_location             => p_internal_location
  ,p_known_as                      => p_known_as
  ,p_last_medical_test_by          => p_last_medical_test_by
  ,p_last_medical_test_date        => p_last_medical_test_date
  ,p_mailstop                      => p_mailstop
  ,p_marital_status                => p_marital_status
  ,p_national_identifier           => p_national_identifier
  ,p_nationality                   => p_nationality
  ,p_office_number                 => p_office_number
  ,p_on_military_service           => p_on_military_service
  ,p_party_id                      => p_party_id
  ,p_previous_last_name            => p_previous_last_name
  ,p_projected_placement_end       => p_projected_placement_end
  ,p_receipt_of_death_cert_date    => p_receipt_of_death_cert_date
  ,p_region_of_birth               => p_region_of_birth
  ,p_registered_disabled_flag      => p_registered_disabled_flag
  ,p_resume_exists                 => p_resume_exists
  ,p_resume_last_updated           => p_resume_last_updated
  ,p_second_passport_exists        => p_second_passport_exists
  ,p_sex                           => p_sex
  ,p_student_status                => p_student_status
  ,p_title                         => p_title
  ,p_town_of_birth                 => p_town_of_birth
  ,p_uses_tobacco_flag             => p_uses_tobacco_flag
  ,p_vendor_id                     => p_vendor_id
  ,p_work_schedule                 => p_work_schedule
  ,p_work_telephone                => p_work_telephone
  ,p_exp_check_send_to_address     => p_exp_check_send_to_address
  ,p_hold_applicant_date_until     => p_hold_applicant_date_until
  ,p_date_employee_data_verified   => p_date_employee_data_verified
  ,p_benefit_group_id              => p_benefit_group_id
  ,p_coord_ben_med_pln_no          => p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
  ,p_original_date_of_hire         => p_original_date_of_hire
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
  ,p_per_information_category      => 'DK'
  ,p_per_information1              => p_initials
  ,p_per_information2	     => p_jubilee_date
  ,p_per_information3              => p_trainee
  ,p_person_id                     => p_person_id
  ,p_per_object_version_number     => p_per_object_version_number
  ,p_per_effective_start_date      => p_per_effective_start_date
  ,p_per_effective_end_date        => p_per_effective_end_date
  ,p_pdp_object_version_number     => p_pdp_object_version_number
  ,p_full_name                     => p_full_name
  ,p_comment_id                    => p_comment_id
  ,p_assignment_id                 => p_assignment_id
  ,p_asg_object_version_number     => p_asg_object_version_number
  ,p_assignment_sequence           => p_assignment_sequence
  ,p_assignment_number             => p_assignment_number
  ,p_name_combination_warning      => p_name_combination_warning
  );

  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 7);
 end if;
  --

end create_dk_cwk;
end hr_dk_contingent_worker_api;

/
