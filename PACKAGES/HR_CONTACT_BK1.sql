--------------------------------------------------------
--  DDL for Package HR_CONTACT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTACT_BK1" AUTHID CURRENT_USER as
/* $Header: peconapi.pkh 120.1 2005/10/02 02:13:15 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_person_b  >----------------------------|
-- ----------------------------------------------------------------------------
procedure create_person_b
  (p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number
  ,p_comments                      in     varchar2
  ,p_date_employee_data_verified   in     date
  ,p_date_of_birth                 in     date
  ,p_email_address                 in     varchar2
  ,p_expense_check_send_to_addres  in     varchar2
  ,p_first_name                    in     varchar2
  ,p_known_as                      in     varchar2
  ,p_marital_status                in     varchar2
  ,p_middle_names                  in     varchar2
  ,p_nationality                   in     varchar2
  ,p_national_identifier           in     varchar2
  ,p_previous_last_name            in     varchar2
  ,p_registered_disabled_flag      in     varchar2
  ,p_title                         in     varchar2
  ,p_vendor_id                     in     number
  ,p_work_telephone                in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_per_information_category      in     varchar2
  ,p_per_information1              in     varchar2
  ,p_per_information2              in     varchar2
  ,p_per_information3              in     varchar2
  ,p_per_information4              in     varchar2
  ,p_per_information5              in     varchar2
  ,p_per_information6              in     varchar2
  ,p_per_information7              in     varchar2
  ,p_per_information8              in     varchar2
  ,p_per_information9              in     varchar2
  ,p_per_information10             in     varchar2
  ,p_per_information11             in     varchar2
  ,p_per_information12             in     varchar2
  ,p_per_information13             in     varchar2
  ,p_per_information14             in     varchar2
  ,p_per_information15             in     varchar2
  ,p_per_information16             in     varchar2
  ,p_per_information17             in     varchar2
  ,p_per_information18             in     varchar2
  ,p_per_information19             in     varchar2
  ,p_per_information20             in     varchar2
  ,p_per_information21             in     varchar2
  ,p_per_information22             in     varchar2
  ,p_per_information23             in     varchar2
  ,p_per_information24             in     varchar2
  ,p_per_information25             in     varchar2
  ,p_per_information26             in     varchar2
  ,p_per_information27             in     varchar2
  ,p_per_information28             in     varchar2
  ,p_per_information29             in     varchar2
  ,p_per_information30             in     varchar2
  ,p_correspondence_language       in     varchar2
  ,p_honors                        in     varchar2
  ,p_benefit_group_id              in     number
  ,p_on_military_service           in     varchar2
  ,p_student_status                in     varchar2
  ,p_uses_tobacco_flag             in     varchar2
  ,p_coord_ben_no_cvg_flag         in     varchar2
  ,p_pre_name_adjunct              in     varchar2
  ,p_suffix                        in     varchar2
  ,p_town_of_birth                 in     varchar2
  ,p_region_of_birth               in     varchar2
  ,p_country_of_birth              in     varchar2
  ,p_global_person_id              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_person_a  >----------------------------|
-- ----------------------------------------------------------------------------
procedure create_person_a
  (p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number
  ,p_comments                      in     varchar2
  ,p_date_employee_data_verified   in     date
  ,p_date_of_birth                 in     date
  ,p_email_address                 in     varchar2
  ,p_expense_check_send_to_addres  in     varchar2
  ,p_first_name                    in     varchar2
  ,p_known_as                      in     varchar2
  ,p_marital_status                in     varchar2
  ,p_middle_names                  in     varchar2
  ,p_nationality                   in     varchar2
  ,p_national_identifier           in     varchar2
  ,p_previous_last_name            in     varchar2
  ,p_registered_disabled_flag      in     varchar2
  ,p_title                         in     varchar2
  ,p_vendor_id                     in     number
  ,p_work_telephone                in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_per_information_category      in     varchar2
  ,p_per_information1              in     varchar2
  ,p_per_information2              in     varchar2
  ,p_per_information3              in     varchar2
  ,p_per_information4              in     varchar2
  ,p_per_information5              in     varchar2
  ,p_per_information6              in     varchar2
  ,p_per_information7              in     varchar2
  ,p_per_information8              in     varchar2
  ,p_per_information9              in     varchar2
  ,p_per_information10             in     varchar2
  ,p_per_information11             in     varchar2
  ,p_per_information12             in     varchar2
  ,p_per_information13             in     varchar2
  ,p_per_information14             in     varchar2
  ,p_per_information15             in     varchar2
  ,p_per_information16             in     varchar2
  ,p_per_information17             in     varchar2
  ,p_per_information18             in     varchar2
  ,p_per_information19             in     varchar2
  ,p_per_information20             in     varchar2
  ,p_per_information21             in     varchar2
  ,p_per_information22             in     varchar2
  ,p_per_information23             in     varchar2
  ,p_per_information24             in     varchar2
  ,p_per_information25             in     varchar2
  ,p_per_information26             in     varchar2
  ,p_per_information27             in     varchar2
  ,p_per_information28             in     varchar2
  ,p_per_information29             in     varchar2
  ,p_per_information30             in     varchar2
  ,p_correspondence_language       in     varchar2
  ,p_honors                        in     varchar2
  ,p_benefit_group_id              in     number
  ,p_on_military_service           in     varchar2
  ,p_student_status                in     varchar2
  ,p_uses_tobacco_flag             in     varchar2
  ,p_coord_ben_no_cvg_flag         in     varchar2
  ,p_pre_name_adjunct              in     varchar2
  ,p_suffix                        in     varchar2
  ,p_town_of_birth                 in     varchar2
  ,p_region_of_birth               in     varchar2
  ,p_country_of_birth              in     varchar2
  ,p_global_person_id              in     varchar2
  ,p_person_id                     in     number
  ,p_object_version_number         in     number
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_full_name                     in     varchar2
  ,p_comment_id                    in     number
  ,p_name_combination_warning      in     boolean
  ,p_orig_hire_warning             in     boolean
  );
--
end hr_contact_bk1;

 

/