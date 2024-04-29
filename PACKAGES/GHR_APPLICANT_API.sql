--------------------------------------------------------
--  DDL for Package GHR_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_APPLICANT_API" AUTHID CURRENT_USER as
/* $Header: ghappapi.pkh 120.0.12010000.1 2009/05/25 12:03:45 utokachi noship $ */
--
-- Package Variables
--
-- ---------------------------------------------------------------------------
-- |--------------------------< create_applicant >---------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_applicant
  (p_validate                     in     boolean  default false
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
  ,p_first_name                   in     varchar2 default null
  ,p_known_as                     in     varchar2 default null
  ,p_marital_status               in     varchar2 default null
  ,p_middle_names                 in     varchar2 default null
  ,p_nationality                  in     varchar2 default null
  ,p_national_identifier          in     varchar2 default null
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
  ,p_per_information_category     in     varchar2 default null -- Obsolete parameter, do not use
  ,p_per_information1             in     varchar2 default null
  ,p_per_information2             in     varchar2 default null
  ,p_per_information3             in     varchar2 default null
  ,p_per_information4             in     varchar2 default null
  ,p_per_information5             in     varchar2 default null
  ,p_per_information6             in     varchar2 default null
  ,p_per_information7             in     varchar2 default null
  ,p_per_information8             in     varchar2 default null
  ,p_per_information9             in     varchar2 default null
  ,p_per_information10            in     varchar2 default null
  ,p_per_information11            in     varchar2 default null
  ,p_per_information12            in     varchar2 default null
  ,p_per_information13            in     varchar2 default null
  ,p_per_information14            in     varchar2 default null
  ,p_per_information15            in     varchar2 default null
  ,p_per_information16            in     varchar2 default null
  ,p_per_information17            in     varchar2 default null
  ,p_per_information18            in     varchar2 default null
  ,p_per_information19            in     varchar2 default null
  ,p_per_information20            in     varchar2 default null
  ,p_per_information21            in     varchar2 default null
  ,p_per_information22            in     varchar2 default null
  ,p_per_information23            in     varchar2 default null
  ,p_per_information24            in     varchar2 default null
  ,p_per_information25            in     varchar2 default null
  ,p_per_information26            in     varchar2 default null
  ,p_per_information27            in     varchar2 default null
  ,p_per_information28            in     varchar2 default null
  ,p_per_information29            in     varchar2 default null
  ,p_per_information30            in     varchar2 default null
  ,p_background_check_status      in     varchar2 default null
  ,p_background_date_check        in     date     default null
  ,p_correspondence_language      in     varchar2 default null
  ,p_fte_capacity                 in     number   default null
  ,p_hold_applicant_date_until    in     date     default null
  ,p_honors                       in     varchar2 default null
  ,p_mailstop                     in     varchar2 default null
  ,p_office_number                in     varchar2 default null
  ,p_pre_name_adjunct             in     varchar2 default null
  ,p_projected_start_date         in     date     default null
  ,p_resume_exists                in     varchar2 default null
  ,p_resume_last_updated          in     date     default null
  ,p_work_schedule                in     varchar2 default null
  ,p_suffix                       in     varchar2 default null
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
  ) ;
end ghr_applicant_api;

/
