--------------------------------------------------------
--  DDL for Package Body HR_CN_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CN_CONTACT_API" AS
/* $Header: hrcnwrcc.pkb 115.1 2003/02/04 07:29:04 statkar noship $ */

  g_package  VARCHAR2(33) := 'hr_cn_contact_api.';

-- -----------------------------------------------------------------------------
-- |-----------------------< create_cn_person >--------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--      Calls standard API to create a contact.  Performs mapping of Developer
--      Descriptive Flexfield segments.  No need to include validation for the
--      national identifier as this is now being included as a legislative hook,
--      so the appropriate formula will be called depending on legislation.
--      Ensures appropriate identification information has been entered ie.
--      national identifier.Maps the legislation specific columns to the core API.
--
--  Pre Conditions:
--
--  In Arguments:
--
--  Post Success:
--
--  Post Failure:
--    A failure can only occur under two circumstances:
--    1) The value of reference field is not supported.
--    2) If when the reference field value is null and not all
--       the information arguments are not null(i.e. information
--       arguments cannot be set without a corresponding reference
--       field value).
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
PROCEDURE create_cn_person
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_family_or_last_name           in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_given_or_first_name           in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_citizen_identification_num    in     varchar2 default null
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
  ,p_hukou_type                    in     varchar2 default null
  ,p_hukou_location                in     varchar2 default null
  ,p_highest_education_level       in     varchar2 default null
  ,p_number_of_children            in     varchar2 default null
  ,p_expatriate_indicator          in     varchar2 default 'N'  -- Bug 2782045
  ,p_health_status                 in     varchar2 default null
  ,p_tax_exemption_indicator       in     varchar2 default null
  ,p_percentage                    in     varchar2 default null
  ,p_family_han_yu_pin_yin_name    in     varchar2 default null
  ,p_given_han_yu_pin_yin_name     in     varchar2 default null
  ,p_previous_name                 in     varchar2 default null
  ,p_race_ethnic_orgin             in     varchar2 default null
  ,p_social_security_ic_number     in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_honors                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_on_military_service           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_place_of_birth                in     varchar2 default null
  ,p_original_hometown             in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  --
  ,p_person_id                        out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_comment_id                       out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  )
AS
--
-- Declare cursors and local variables
--
  l_proc                 VARCHAR2(72) := g_package||'create_cn_person';

BEGIN

  hr_cn_api.set_location(g_trace, 'Entering: '||l_proc, 10);
--
  hr_cn_api.check_bus_grp (p_business_group_id, 'CN');
--
  hr_cn_api.set_location(g_trace, l_proc, 20);

  --
  -- Call the person business process
  --
  hr_contact_api.create_person
  (p_validate                      => p_validate
  ,p_start_date                    => p_start_date
  ,p_business_group_id             => p_business_group_id
  ,p_last_name                     => p_family_or_last_name
  ,p_sex                           => p_sex
  ,p_person_type_id                => p_person_type_id
  ,p_comments                      => p_comments
  ,p_date_employee_data_verified   => p_date_employee_data_verified
  ,p_date_of_birth                 => p_date_of_birth
  ,p_email_address                 => p_email_address
  ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
  ,p_first_name                    => p_given_or_first_name
  ,p_known_as                      => p_known_as
  ,p_marital_status                => p_marital_status
  ,p_middle_names                  => p_middle_names
  ,p_nationality                   => p_nationality
  ,p_national_identifier           => p_citizen_identification_num
  ,p_registered_disabled_flag      => p_registered_disabled_flag
  ,p_title                         => p_title
  ,p_vendor_id                     => p_vendor_id
  ,p_work_telephone                => p_work_telephone
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
  ,p_per_information_category     => 'CN'
  ,p_per_information4             => p_hukou_type
  ,p_per_information5             => p_hukou_location
  ,p_per_information6             => p_highest_education_level
  ,p_per_information7             => p_number_of_children
  ,p_per_information8             => p_expatriate_indicator
  ,p_per_information10            => p_health_status
  ,p_per_information11            => p_tax_exemption_indicator
  ,p_per_information12            => p_percentage
  ,p_per_information14            => p_family_han_yu_pin_yin_name
  ,p_per_information15            => p_given_han_yu_pin_yin_name
  ,p_per_information16            => p_previous_name
  ,p_per_information17            => p_race_ethnic_orgin
  ,p_per_information18            => p_social_security_ic_number
  ,p_correspondence_language      => p_correspondence_language
  ,p_honors                       => p_honors
  ,p_benefit_group_id             => p_benefit_group_id
  ,p_on_military_service          => p_on_military_service
  ,p_student_status               => p_student_status
  ,p_uses_tobacco_flag            => p_uses_tobacco_flag
  ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
  ,p_pre_name_adjunct             => p_pre_name_adjunct
  ,p_suffix                       => p_suffix
  ,p_town_of_birth                => p_place_of_birth
  ,p_region_of_birth              => p_original_hometown
  ,p_country_of_birth             => p_country_of_birth
  ,p_global_person_id             => p_global_person_id
  --
  ,p_person_id                     => p_person_id
  ,p_object_version_number         => p_object_version_number
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_full_name                     => p_full_name
  ,p_comment_id                    => p_comment_id
  ,p_name_combination_warning      => p_name_combination_warning
  ,p_orig_hire_warning             => p_orig_hire_warning
  );

  --
  hr_cn_api.set_location(g_trace, 'Leaving: '||l_proc, 30);
  --
END create_cn_person;
--
END hr_cn_contact_api;

/