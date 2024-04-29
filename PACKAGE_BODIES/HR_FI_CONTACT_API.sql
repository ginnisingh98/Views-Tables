--------------------------------------------------------
--  DDL for Package Body HR_FI_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FI_CONTACT_API" AS
/* $Header: peconfii.pkb 120.1.12000000.2 2007/02/14 12:17:11 dbehera ship $ */
--
	-- Package Variables
   g_package  varchar2(33) := 'hr_fi_contact_api';
   g_debug boolean := hr_utility.debug_enabled;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_fi_person >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_fi_person
   (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                   in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_nationality                   in     varchar2
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2
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
  ,p_place_of_residence        	   in     varchar2 default null
  ,p_secondary_email      	   in     varchar2 default null
  ,p_epost_address 		   in     varchar2 default null
  ,p_speed_dial_number        	   in     varchar2 default null
  ,p_qualification                 in     varchar2 default null
  ,p_level	        	   in     varchar2 default null
  ,p_field	        	   in     varchar2 default null
  ,p_retirement_date        	   in     varchar2 default null
  ,p_union_name                    in     varchar2 default null
  ,p_membership_number             in     varchar2 default null
  ,p_payment_mode                  in     varchar2 default null
  ,p_fixed_amount                  in     varchar2 default null
  ,p_percentage                    in     varchar2 default null
  ,p_membership_start_date	   in     varchar2     default null
  ,p_membership_end_date	   in	  varchar2    default null
   ,p_mother_tongue         in      varchar2     default null
  ,p_foreign_personal_id	   in	  varchar2     default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_honors                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_on_military_service           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_person_id                        out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_comment_id                       out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  ) is

  l_proc                 varchar2(72) := g_package||'update_fi_person';
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
  -- Check that the legislation of the specified business group is 'FI'.
  --
  if l_legislation_code <> 'FI' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','FI');
    hr_utility.raise_error;
  end if;

  if p_membership_start_date is not null and p_membership_end_date is not null and
     p_membership_start_date > p_membership_end_date then
      hr_utility.set_message(801, 'HR_376639_FI_VALID_DATE');
      hr_utility.set_message_token('LEG_CODE','FI');
      hr_utility.raise_error;
  end if;

 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;

hr_contact_api.create_person
  (p_validate                      => p_validate
  ,p_start_date                    => p_start_date
  ,p_business_group_id             => p_business_group_id
  ,p_last_name                     => p_last_name
  ,p_sex                           => p_sex
  ,p_person_type_id                => p_person_type_id
  ,p_comments                      => p_comments
  ,p_date_employee_data_verified   => p_date_employee_data_verified
  ,p_date_of_birth                 => p_date_of_birth
  ,p_email_address                 => p_email_address
  ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
  ,p_first_name                    => p_first_name
  ,p_known_as                      => p_known_as
  ,p_marital_status                => p_marital_status
  ,p_nationality                   => p_nationality
  ,p_national_identifier           => p_national_identifier
  ,p_previous_last_name            => p_previous_last_name
  ,p_registered_disabled_flag      => p_registered_disabled_flag
  ,p_title                         => p_title
  ,p_vendor_id                     => p_vendor_id
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
  ,p_per_information_category      => 'FI'
  ,p_per_information1              => p_place_of_residence
  ,p_per_information2              => p_secondary_email
  ,p_per_information3              => p_epost_address
  ,p_per_information4              => p_speed_dial_number
  ,p_per_information5              => p_qualification
  ,p_per_information6              => p_level
  ,p_per_information7              => p_field
  ,p_per_information8              => p_retirement_date
  ,p_per_information9             => p_union_name
  ,p_per_information10            => p_membership_number
  ,p_per_information11            => p_payment_mode
  ,p_per_information12            => p_fixed_amount
  ,p_per_information13            => p_percentage
  ,p_per_information18            => p_membership_start_date
  ,p_per_information19            => p_membership_end_date
  ,p_per_information22	      => p_mother_tongue
  ,p_per_information23	      => p_foreign_personal_id
  ,p_correspondence_language       => p_correspondence_language
  ,p_honors                        => p_honors
  ,p_benefit_group_id              => p_benefit_group_id
  ,p_on_military_service           => p_on_military_service
  ,p_student_status                => p_student_status
  ,p_uses_tobacco_flag             => p_uses_tobacco_flag
  ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
  ,p_town_of_birth                 => p_town_of_birth
  ,p_region_of_birth               => p_region_of_birth
  ,p_country_of_birth              => p_country_of_birth
  ,p_global_person_id              => p_global_person_id
  ,p_person_id                     => p_person_id
  ,p_object_version_number         => p_object_version_number
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_full_name                     => p_full_name
  ,p_comment_id                    => p_comment_id
  ,p_name_combination_warning      => p_name_combination_warning
  ,p_orig_hire_warning             => p_orig_hire_warning);

  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 7);
 end if;
  --
end create_fi_person;

END hr_fi_contact_api;

/
