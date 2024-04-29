--------------------------------------------------------
--  DDL for Package HR_PERSON_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_ATT" AUTHID CURRENT_USER as
/* $Header: peperati.pkh 115.7 2002/12/02 15:59:07 eumenyio ship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< update_person >------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This API updates the person record as identified by p_person_id
--   and p_object_version_number using the pseudo datetrack modes of
--   ATTRIBUTE_UPDATE or ATTRIBUTE_CORRECTION. Depending on the pseudo mode
--   specified, the hr_person_api.update_person API is called with true
--   datetrack modes of either UPDATE, CORRECTION or UPDATE_CHANGE_INSERT.
--   It is important to note that the pseudo modes are not part of DateTrack
--   core. The pseudo mode corresponds to the p_attribute_update_mode
--   parameter.
--
--   The ATTRIBUTE_UPDATE will update the current and all rows in the future
--   where the attribute(s) have the same value. The future update of the
--   attribute(s) will only be completed when either the last row is selected
--   or the attribute(s) value has changed.
--
--   The ATTRIBUTE_CORRECTION works by first updating all rows in the
--   future where the attribute(s) have the same value. The future update of
--   the attribute will only be completed when either the last row is
--   selected or the attribute(s) value has changed. Next, the change has to
--   be applied in the past using the same logic as future rows except
--   it is only complete when either the first row is selected or the
--   attribute value has changed.
--
-- Prerequisites
--   The person record, identified by p_person_id and
--   p_object_version_number, must already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged. If false
--                                                then the person will be
--                                                updated.
--   p_effective_date               Yes  date     The effective date for this
--                                                change
--   p_attribute_update_mode        Yes  varchar2 Update attribute mode
--                                                Valid values are; ATTRIBUTE_UPDATE,
--                                                ATTRIBUTE_CORRECTION
--   p_person_id                    Yes  number   ID of person
--   p_object_version_number        Yes  number   Version number of the person
--                                                record
--   p_person_type_id               No   number   Person type ID
--   p_last_name                    No   varchar2 Last name
--   p_applicant_number             No   varchar2 Applicant number
--   p_comments                     No   varchar2 Comment text
--   p_date_employee_data_verified  No   date     Date when the employee
--                                                data was last verified
--   p_date_of_birth                No   date     Date of birth
--   p_email_address                No   varchar2 Email address
--   p_employee_number              No   varchar2 Employee number
--   p_expense_check_send_to_addres No   varchar2 Mailing address
--   p_first_name                   No   varchar2 First name
--   p_known_as                     No   varchar2 Known as
--   p_marital_status               No   varchar2 Marital status
--   p_middle_names                 No   varchar2 Middle names
--   p_nationality                  No   varchar2 Nationality
--   p_national_identifier          No   varchar2 National identifier
--   p_previous_last_name           No   varchar2 Previous last name
--   p_registered_disabled_flag     No   varchar2 Registered disabled flag
--   p_sex                          No   varchar2 Gender
--   p_title                        No   varchar2 Title
--   p_vendor_id                    No   number   Foreign key to PO_VENDORS
--   p_work_telephone               No   varchar2 Work telephone
--   p_attribute_category           No   varchar2 Determines the context of
--                                                the user-defined
--                                                descriptive flexfield
--   p_attribute1                   No   varchar2 Descriptive flexfield
--   p_attribute2                   No   varchar2 Descriptive flexfield
--   p_attribute3                   No   varchar2 Descriptive flexfield
--   p_attribute4                   No   varchar2 Descriptive flexfield
--   p_attribute5                   No   varchar2 Descriptive flexfield
--   p_attribute6                   No   varchar2 Descriptive flexfield
--   p_attribute7                   No   varchar2 Descriptive flexfield
--   p_attribute8                   No   varchar2 Descriptive flexfield
--   p_attribute9                   No   varchar2 Descriptive flexfield
--   p_attribute10                  No   varchar2 Descriptive flexfield
--   p_attribute11                  No   varchar2 Descriptive flexfield
--   p_attribute12                  No   varchar2 Descriptive flexfield
--   p_attribute13                  No   varchar2 Descriptive flexfield
--   p_attribute14                  No   varchar2 Descriptive flexfield
--   p_attribute15                  No   varchar2 Descriptive flexfield
--   p_attribute16                  No   varchar2 Descriptive flexfield
--   p_attribute17                  No   varchar2 Descriptive flexfield
--   p_attribute18                  No   varchar2 Descriptive flexfield
--   p_attribute19                  No   varchar2 Descriptive flexfield
--   p_attribute20                  No   varchar2 Descriptive flexfield
--   p_attribute21                  No   varchar2 Descriptive flexfield
--   p_attribute22                  No   varchar2 Descriptive flexfield
--   p_attribute23                  No   varchar2 Descriptive flexfield
--   p_attribute24                  No   varchar2 Descriptive flexfield
--   p_attribute25                  No   varchar2 Descriptive flexfield
--   p_attribute26                  No   varchar2 Descriptive flexfield
--   p_attribute27                  No   varchar2 Descriptive flexfield
--   p_attribute28                  No   varchar2 Descriptive flexfield
--   p_attribute29                  No   varchar2 Descriptive flexfield
--   p_attribute30                  No   varchar2 Descriptive flexfield
--   p_per_information_category     No   varchar2 Determines the context of
--                                                the developer descriptive
--                                                flexfield
--   p_per_information1             No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information2             No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information3             No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information4             No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information5             No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information6             No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information7             No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information8             No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information9             No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information10            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information11            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information12            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information13            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information14            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information15            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information16            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information17            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information18            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information19            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information20            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information21            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information22            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information23            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information24            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information25            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information26            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information27            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information28            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information29            No   varchar2 Developer descriptive
--                                                flexfield
--   p_per_information30            No   varchar2 Developer descriptive
--                                                flexfield
--   p_date_of_death                No   date     date of death
--   p_background_check_status      No   varchar2 background status check
--   p_background_date_check        No   date     background check date
--   p_blood_type                   No   varchar2 blood type
--   p_correspondence_language      No   varchar2 correspondence language
--   p_fast_path_employee           No   varchar2 fast path employee
--   p_fte_capacity                 No   number   fte capacity
--   p_hold_applicant_date_until    No   date     hold applicant date until
--   p_honors                       No   varchar2 honors
--   p_internal_location            No   varchar2 internal location
--   p_last_medical_test_by         No   varchar2 last medical test by
--   p_last_medical_test_date       No   date     last medical test date
--   p_mailstop                     No   varchar2 mailstop
--   p_office_number                No   varchar2 office number
--   p_on_military_service          No   varchar2 on military service
--   p_pre_name_adjunct             No   varchar2 pre name adjunct
--   p_projected_start_date         No   date     projected start date
--   p_rehire_authorizor            No   varchar2 rehire authorizor
--   p_rehire_recommendation        No   varchar2 rehire recommendation
--   p_resume_exists                No   varchar2 resume exists
--   p_resume_last_updated          No   date     resume last updated
--   p_second_passport_exists       No   varchar2 second passport exists
--   p_student_status               No   varchar2 student status
--   p_work_schedule                No   varchar2 work schedule
--   p_rehire_reason                No   varchar2 rehire reason
--   p_suffix                       No   varchar2 Person's suffix
--   p_benefit_group_id             No   number   Id for benefit group
--   p_receipt_of_death_cert_date   No   date     Date death certificate
--                                                was received
--   p_coord_ben_med_pln_no         No   varchar2 Number of an externally
--                                                provided medical plan
--   p_coord_ben_no_cvg_flag        No   varchar2 No other coverage flag
--   p_uses_tobacco_flag            No   varchar2 Uses tobacco flag
--   p_dpdnt_adoption_date          No   date     Date dependent was adopted
--   p_dpdnt_vlntry_svce_flag       No   varchar2 Dependent on voluntary
--                                                service flag
--   p_original_date_of_hire        No   date     Original date of hire
--   p_town_of_birth                No   varchar2 Town or city of birth
--   p_region_of_birth              No   varchar2 Geographical region of birth
--   p_country_of_birth             No   varchar2 Country of birth
--   p_global_person_id             No   varchar2 Global ID for the person
--
-- Post Success:
--   The API will set the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the new version number of the
--                                           updated person record. If
--                                           p_validate is true set to the
--                                           same value you passed in.
--   p_employee_number              varchar2 If p_validate is false, set to
--                                           the value of the employee number
--                                           after the person record has
--                                           been updated.
--                                           If p_validate is true, set to
--                                           the same value you passed in.
--                                           This parameter depends on the
--                                           employee number generation method
--                                           of the business group.
--   p_effective_start_date         date     If p_validate is false, set to
--                                           the effective start date of the
--                                           person. If p_validate is true, set
--                                           to null.
--   p_effective_end_date           date     If p_validate is false, set to
--                                           the effective end date of the
--                                           person.
--                                           If p_validate is true, set to
--                                           null.
--   p_full_name                    varchar2 If p_validate is false, set to
--                                           the complete full name of the
--                                           person.
--                                           If p_validate is true, set to
--                                           null.
--   p_comment_id                   number   If p_validate is false and any
--                                           comment text exists, set to the id
--                                           of the corresponding person
--                                           comment row.
--                                           If p_validate is true, or no
--                                           comment text exists this will be
--                                           null.
--   p_name_combination_warning     boolean  Set to true if the new
--                                           combination (if changed) of last
--                                           name, first name and date of
--                                           birth already existed prior to
--                                           the update. Else, set to false.
--   p_assign_payroll_warning       boolean  Set to true if the date of birth
--                                           has been updated to a null value,
--                                           and this person is an employee,
--                                           otherwise set to false.
--   p_orig_hire_warning            boolean  Set to true if the original date
--                                           of hire is not null and the
--                                           person_type is not EMP,EMP_APL,
--                                           EX_EMP,EX_EMP_APL.
--
-- Post Failure:
--   The API will not update the person and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_person
  (p_validate                     in      boolean   default false
  ,p_effective_date               in      date
  ,p_attribute_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_national_identifier          in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2 default hr_api.g_varchar2
  ,p_registered_disabled_flag     in      varchar2 default hr_api.g_varchar2
  ,p_sex                          in      varchar2 default hr_api.g_varchar2
  ,p_title                        in      varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in      number   default hr_api.g_number
  ,p_work_telephone               in      varchar2 default hr_api.g_varchar2
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in      varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in      varchar2 default hr_api.g_varchar2
  ,p_per_information_category     in      varchar2 default hr_api.g_varchar2
  ,p_per_information1             in      varchar2 default hr_api.g_varchar2
  ,p_per_information2             in      varchar2 default hr_api.g_varchar2
  ,p_per_information3             in      varchar2 default hr_api.g_varchar2
  ,p_per_information4             in      varchar2 default hr_api.g_varchar2
  ,p_per_information5             in      varchar2 default hr_api.g_varchar2
  ,p_per_information6             in      varchar2 default hr_api.g_varchar2
  ,p_per_information7             in      varchar2 default hr_api.g_varchar2
  ,p_per_information8             in      varchar2 default hr_api.g_varchar2
  ,p_per_information9             in      varchar2 default hr_api.g_varchar2
  ,p_per_information10            in      varchar2 default hr_api.g_varchar2
  ,p_per_information11            in      varchar2 default hr_api.g_varchar2
  ,p_per_information12            in      varchar2 default hr_api.g_varchar2
  ,p_per_information13            in      varchar2 default hr_api.g_varchar2
  ,p_per_information14            in      varchar2 default hr_api.g_varchar2
  ,p_per_information15            in      varchar2 default hr_api.g_varchar2
  ,p_per_information16            in      varchar2 default hr_api.g_varchar2
  ,p_per_information17            in      varchar2 default hr_api.g_varchar2
  ,p_per_information18            in      varchar2 default hr_api.g_varchar2
  ,p_per_information19            in      varchar2 default hr_api.g_varchar2
  ,p_per_information20            in      varchar2 default hr_api.g_varchar2
  ,p_per_information21            in      varchar2 default hr_api.g_varchar2
  ,p_per_information22            in      varchar2 default hr_api.g_varchar2
  ,p_per_information23            in      varchar2 default hr_api.g_varchar2
  ,p_per_information24            in      varchar2 default hr_api.g_varchar2
  ,p_per_information25            in      varchar2 default hr_api.g_varchar2
  ,p_per_information26            in      varchar2 default hr_api.g_varchar2
  ,p_per_information27            in      varchar2 default hr_api.g_varchar2
  ,p_per_information28            in      varchar2 default hr_api.g_varchar2
  ,p_per_information29            in      varchar2 default hr_api.g_varchar2
  ,p_per_information30            in      varchar2 default hr_api.g_varchar2
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_correspondence_language      in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_honors                       in      varchar2 default hr_api.g_varchar2
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_pre_name_adjunct             in      varchar2 default hr_api.g_varchar2
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
  ,p_region_of_birth              in      varchar2 default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2 default hr_api.g_varchar2
  ,p_global_person_id             in      varchar2 default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy  date
  ,p_effective_end_date              out nocopy  date
  ,p_full_name                       out nocopy  varchar2
  ,p_comment_id                      out nocopy  number
  ,p_name_combination_warning        out nocopy  boolean
  ,p_assign_payroll_warning          out nocopy  boolean
  ,p_orig_hire_warning               out nocopy  boolean);
--
end hr_person_att;

 

/
