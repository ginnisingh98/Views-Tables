--------------------------------------------------------
--  DDL for Package Body HR_RU_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RU_APPLICANT_API" as
/* $Header: peapprui.pkb 120.0 2005/05/31 05:26:31 appldev noship $ */

--Package variables
  g_package    CONSTANT varchar2(33):='hr_ru_applicant_api.';
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ru_applicant >--------------------------|
-- ----------------------------------------------------------------------------

procedure create_ru_applicant(
   p_validate                     in     boolean  default false
  ,p_date_received                in     date
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_person_type_id               in     number   default null
  ,p_applicant_number             in out nocopy varchar2
  ,p_per_comments                 in     varchar2 default null
  ,p_date_employee_data_verified  in     date     default null
  ,p_date_of_birth                in     date     default null
  ,p_email_address                in     varchar2 default null
  ,p_expense_check_send_to_addres in     varchar2 default null
  ,p_first_name                   in     varchar2
  ,p_known_as                     in     varchar2 default null
  ,p_marital_status               in     varchar2 default null
  ,p_middle_names                 in     varchar2 default null
  ,p_nationality                  in     varchar2 default null
  ,p_inn                          in     varchar2 default null
  ,p_previous_last_name           in     varchar2 default null
  ,p_registered_disabled_flag     in     varchar2 default null
  ,p_sex                          in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_work_telephone               in     varchar2 default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_attribute21                  in     varchar2 default null
  ,p_attribute22                  in     varchar2 default null
  ,p_attribute23                  in     varchar2 default null
  ,p_attribute24                  in     varchar2 default null
  ,p_attribute25                  in     varchar2 default null
  ,p_attribute26                  in     varchar2 default null
  ,p_attribute27                  in     varchar2 default null
  ,p_attribute28                  in     varchar2 default null
  ,p_attribute29                  in     varchar2 default null
  ,p_attribute30                  in     varchar2 default null
  ,p_place_of_birth		  in     varchar2 default null
  ,p_references		          in     varchar2 default null
  ,p_local_coefficient		  in     varchar2 default null
  ,p_citizenship		  in     varchar2
  ,p_military_doc		  in     varchar2 default null
  ,p_reserve_category		  in     varchar2 default null
  ,p_military_rank		  in     varchar2 default null
  ,p_military_profile		  in     varchar2 default null
  ,p_military_reg_code		  in     varchar2 default null
  ,p_mil_srvc_readiness_category  in     varchar2 default null
  ,p_military_commissariat	  in     varchar2 default null
  ,p_quitting_mark		  in     varchar2 default null
  ,p_military_unit_number	  in     varchar2 default null
  ,p_military_reg_type		  in     varchar2 default null
  ,p_military_reg_details	  in     varchar2 default null
  ,p_pension_fund_number	  in     varchar2 default null
  ,p_background_check_status      in     varchar2 default null
  ,p_background_date_check        in     date     default null
  ,p_correspondence_language      in     varchar2 default null
  ,p_fte_capacity                 in     number   default null
  ,p_hold_applicant_date_until    in     date     default null
  ,p_honors                       in     varchar2 default null
  ,p_mailstop                     in     varchar2 default null
  ,p_office_number                in     varchar2 default null
  ,p_on_military_service          in     varchar2 default null
  ,p_genitive_last_name           in     varchar2 default null
  ,p_projected_start_date         in     date     default null
  ,p_resume_exists                in     varchar2 default null
  ,p_resume_last_updated          in     date     default null
  ,p_student_status               in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_suffix                       in     varchar2 default null
  ,p_date_of_death                in     date     default null
  ,p_benefit_group_id             in     number   default null
  ,p_receipt_of_death_cert_date   in     date     default null
  ,p_coord_ben_med_pln_no         in     varchar2 default null
  ,p_coord_ben_no_cvg_flag        in     varchar2 default null
  ,p_uses_tobacco_flag            in     varchar2 default null
  ,p_dpdnt_adoption_date          in     date     default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2 default null
  ,p_original_date_of_hire        in     date     default null
  ,p_town_of_birth                in      varchar2 default null
  ,p_region_of_birth              in      varchar2 default null
  ,p_country_of_birth             in      varchar2 default null
  ,p_global_person_id             in      varchar2 default null
  ,p_party_id                     in      number default null
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
  ) IS
  --
  -- Declare cursors and local variables
  --

  l_proc    CONSTANT     varchar2(72)  := g_package||'create_ru_applicant';
  l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 45);
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
  -- Check that the legislation of the specified business group is 'RU'.
  --
  if l_legislation_code <> 'RU' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','RU');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 50);
  --
  -- Call the person business process
  --
       hr_utility.set_location (l_proc, 50);
      --
      -- Call the person business process
      --
      hr_applicant_api.create_applicant
                                  (p_validate                          => p_validate
                                  ,p_date_received                     => p_date_received
                                  ,p_business_group_id                 => p_business_group_id
                                  ,p_last_name                         => p_last_name
                                  ,p_person_type_id                    => p_person_type_id
                                  ,p_applicant_number                  => p_applicant_number
                                  ,p_per_comments                      => p_per_comments
                                  ,p_date_employee_data_verified       => p_date_employee_data_verified
                                  ,p_date_of_birth                     => p_date_of_birth
                                  ,p_email_address                     => p_email_address
                                  ,p_expense_check_send_to_addres      => p_expense_check_send_to_addres
                                  ,p_first_name                        => p_first_name
                                  ,p_known_as                          => p_known_as
                                  ,p_marital_status                    => p_marital_status
                                  ,p_middle_names                      => p_middle_names
                                  ,p_nationality                       => p_nationality
                                  ,p_national_identifier               => p_inn
                                  ,p_previous_last_name                => p_previous_last_name
                                  ,p_registered_disabled_flag          => p_registered_disabled_flag
                                  ,p_sex                               => p_sex
                                  ,p_title                             => p_title
                                  ,p_work_telephone                    => p_work_telephone
                                  ,p_attribute_category                => p_attribute_category
                                  ,p_attribute1                        => p_attribute1
                                  ,p_attribute2                        => p_attribute2
                                  ,p_attribute3                        => p_attribute3
                                  ,p_attribute4                        => p_attribute4
                                  ,p_attribute5                        => p_attribute5
                                  ,p_attribute6                        => p_attribute6
                                  ,p_attribute7                        => p_attribute7
                                  ,p_attribute8                        => p_attribute8
                                  ,p_attribute9                        => p_attribute9
                                  ,p_attribute10                       => p_attribute10
                                  ,p_attribute11                       => p_attribute11
                                  ,p_attribute12                       => p_attribute12
                                  ,p_attribute13                       => p_attribute13
                                  ,p_attribute14                       => p_attribute14
                                  ,p_attribute15                       => p_attribute15
                                  ,p_attribute16                       => p_attribute16
                                  ,p_attribute17                       => p_attribute17
                                  ,p_attribute18                       => p_attribute18
                                  ,p_attribute19                       => p_attribute19
                                  ,p_attribute20                       => p_attribute20
                                  ,p_attribute21                       => p_attribute21
                                  ,p_attribute22                       => p_attribute22
                                  ,p_attribute23                       => p_attribute23
                                  ,p_attribute24                       => p_attribute24
                                  ,p_attribute25                       => p_attribute25
                                  ,p_attribute26                       => p_attribute26
                                  ,p_attribute27                       => p_attribute27
                                  ,p_attribute28                       => p_attribute28
                                  ,p_attribute29                       => p_attribute29
                                  ,p_attribute30                       => p_attribute30
                                  ,p_per_information_category          => 'RU'
                                  ,p_per_information1                  => p_place_of_birth
                                  ,p_per_information2                  => p_references
                                  ,p_per_information3                  => p_local_coefficient
                                  ,p_per_information4                  => p_citizenship
                                  ,p_per_information5                  => p_military_doc
                                  ,p_per_information6                  => p_reserve_category
                                  ,p_per_information7                  => p_military_rank
                                  ,p_per_information8                  => p_military_profile
                                  ,p_per_information9                  => p_military_reg_code
                                  ,p_per_information10                 => p_mil_srvc_readiness_category
                                  ,p_per_information11                 => p_military_commissariat
                                  ,p_per_information12                 => p_quitting_mark
                                  ,p_per_information14                 => p_military_unit_number
				  ,p_per_information18                 => p_military_reg_type
				  ,p_per_information15                 => p_military_reg_details
                                  ,p_per_information13                 => p_pension_fund_number
                                  ,p_background_check_status           => p_background_check_status
                                  ,p_background_date_check             => p_background_date_check
                                  ,p_correspondence_language           => p_correspondence_language
                                  ,p_fte_capacity                      => p_fte_capacity
                                  ,p_hold_applicant_date_until         => p_hold_applicant_date_until
                                  ,p_honors                            => p_honors
                                  ,p_mailstop                          => p_mailstop
                                  ,p_office_number                     => p_office_number
                                  ,p_on_military_service               => p_on_military_service
                                  ,p_pre_name_adjunct                  => p_genitive_last_name
                                  ,p_projected_start_date              => p_projected_start_date
                                  ,p_resume_exists                     => p_resume_exists
                                  ,p_resume_last_updated               => p_resume_last_updated
                                  ,p_student_status                    => p_student_status
                                  ,p_work_schedule                     => p_work_schedule
                                  ,p_suffix                            => p_suffix
                                  ,p_date_of_death                     => p_date_of_death
                                  ,p_benefit_group_id                  => p_benefit_group_id
                                  ,p_receipt_of_death_cert_date        => p_receipt_of_death_cert_date
                                  ,p_coord_ben_med_pln_no              => p_coord_ben_med_pln_no
                                  ,p_coord_ben_no_cvg_flag             => p_coord_ben_no_cvg_flag
                                  ,p_uses_tobacco_flag                 => p_uses_tobacco_flag
                                  ,p_dpdnt_adoption_date               => p_dpdnt_adoption_date
                                  ,p_dpdnt_vlntry_svce_flag            => p_dpdnt_vlntry_svce_flag
                                  ,p_original_date_of_hire             => p_original_date_of_hire
                                  ,p_town_of_birth                     => p_town_of_birth
                                  ,p_region_of_birth                   => p_region_of_birth
                                  ,p_country_of_birth                  => p_country_of_birth
                                  ,p_global_person_id                  => p_global_person_id
                                  ,p_party_id                          => p_party_id
                                  ,p_person_id                         => p_person_id
                                  ,p_assignment_id                     => p_assignment_id
                                  ,p_application_id                    => p_application_id
                                  ,p_per_object_version_number         => p_per_object_version_number
                                  ,p_asg_object_version_number         => p_asg_object_version_number
                                  ,p_apl_object_version_number         => p_apl_object_version_number
                                  ,p_per_effective_start_date          => p_per_effective_start_date
                                  ,p_per_effective_end_date            => p_per_effective_end_date
                                  ,p_full_name                         => p_full_name
                                  ,p_per_comment_id                    => p_per_comment_id
                                  ,p_assignment_sequence               => p_assignment_sequence
                                  ,p_name_combination_warning          => p_name_combination_warning
                                  ,p_orig_hire_warning                 => p_orig_hire_warning
                                  );
 --
  hr_utility.set_location(' Leaving:'||l_proc, 55);
end create_ru_applicant;
--
end hr_ru_applicant_api;

/
