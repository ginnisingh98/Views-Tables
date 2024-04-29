--------------------------------------------------------
--  DDL for Package HR_HU_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HU_CONTACT_API" AUTHID CURRENT_USER as
/* $Header: peconhui.pkh 120.1 2005/10/02 02:13:27 aroussel $ */
/*#
 * This package contains contact APIs for Hungary.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Personal Contact for Hungary
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_hu_person >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new contact for Hungary.
 *
 * This Hungarian Contact API calls the generic API create_person, with the
 * parameters set as appropriate for a Hungarian Contact. See the create_person
 * API for further documentation as this API is effectively an alternative.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Valid business group for Hungary.
 *
 * <p><b>Post Success</b><br>
 * Hungarian contact is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the contact and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date Start Date.
 * @param p_business_group_id Business group of the person.
 * @param p_last_name Last name.
 * @param p_sex Legal gender. Valid values are defined by the SEX lookup type.
 * @param p_person_type_id Type of person being created.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified Date on which the person data was last
 * verified.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address Email address.
 * @param p_expense_check_send_to_addres Mailing address.
 * @param p_first_name First name.
 * @param p_preferred_name Contact's Alternative name
 * @param p_marital_status Marital status. Valid values are defined by the
 * MAR_STATUS lookup type.
 * @param p_middle_names Middle names.
 * @param p_nationality Nationality. Valid values are defined by the
 * NATIONALITY lookup type.
 * @param p_ss_number National identifier
 * @param p_maiden_name Contact's previous last name.
 * @param p_registered_disabled_flag Flag indicating whether the person is
 * classified as disabled.
 * @param p_title Title. Valid values are defined by the TITLE lookup type.
 * @param p_vendor_id Obsolete parameter, do not use.
 * @param p_work_telephone Obsolete parameter, do not use.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_per_information_category Obsolete parameter, do not use.
 * @param p_mothers_maiden_name Mother's Maiden Name
 * @param p_tax_identification_no Tax Identification Number
 * @param p_personal_identity_no Personal Identity Number
 * @param p_pensioner_registration_no Pensioner Registration Number
 * @param p_contact_employers_name Name of the contact's employer
 * @param p_per_information6 Developer descriptive flexfield segment.
 * @param p_service_completed Military Service Completed. Valid values exist in
 * the 'YES_NO' lookup type.
 * @param p_reason_not_completed Reason military service not completed
 * @param p_service_start_date Military Service Start Date
 * @param p_service_end_date Military Service End Date
 * @param p_mandate_code Mandate Code. Valid values exist in
 * 'HR_HU_MILITARY_MANDATE_CODE' lookup type.
 * @param p_mandate_date Mandate Date
 * @param p_command_type Command Type. Valid values exist in
 * 'HR_HU_MILITARY_COMMAND_TYPE' lookup type.
 * @param p_command_color Command Color. Valid values exist in
 * 'HR_HU_MILITARY_COMMAND_COLOR' lookup type.
 * @param p_command_number Command Number
 * @param p_rank Military Rank. Valid values exist in 'HR_HU_MILITARY_RANK'
 * lookup type.
 * @param p_position Civil defence position
 * @param p_organization Civil Defence Organization. Valid values exist in
 * 'HR_HU_CIVIL_DEFENCE_ORG' lookup type.
 * @param p_local_department Local Department. Valid values exist in
 * 'HR_HU_CIVIL_LOCAL_DEPT' lookup type.
 * @param p_local_sub_department Local Sub-Department. Valid values exist in
 * 'HR_HU_CIVIL_LOCAL_SUB_DEP' lookup type. T
 * @param p_group Civil Defence Group. Valid values exist in
 * 'HR_HU_CIVIL_GROUP' lookup type.
 * @param p_sub_group Civil Defence Sub-Group. Valid values exist in
 * 'HR_HU_CIVIL_SUB_GROUP' lookup type.
 * @param p_ss_start_date Social Security Start Date
 * @param p_ss_end_date Social Security End Date
 * @param p_per_information25 Developer descriptive flexfield segment.
 * @param p_per_information26 Developer descriptive flexfield segment.
 * @param p_per_information27 Developer descriptive flexfield segment.
 * @param p_per_information28 Developer descriptive flexfield segment.
 * @param p_per_information29 Developer descriptive flexfield segment.
 * @param p_per_information30 Developer descriptive flexfield segment.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_honors Honors awarded.
 * @param p_benefit_group_id Benefit group to which this person will belong.
 * @param p_on_military_service Flag indicating whether the person is on
 * military service.
 * @param p_student_status If this person is a student, this field is used to
 * capture their status. Valid values are defined by the STUDENT_STATUS lookup
 * type.
 * @param p_uses_tobacco_flag Flag indicating whether the person uses tobacco.
 * @param p_coord_ben_no_cvg_flag No secondary medical plan coverage. Column
 * used for external processing.
 * @param p_prefix Name prefix
 * @param p_suffix Suffix after the person's last name e.g. Sr., Jr., III.
 * @param p_place_of_birth Town or city of birth
 * @param p_region_of_birth Geographical region of birth.
 * @param p_country_of_birth Country of birth.
 * @param p_global_person_id Obsolete parameter, do not use.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person. If p_validate is true,
 * then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, then set to the complete full
 * name of the person. If p_validate is true, then set to null.
 * @param p_comment_id Comment text.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning If set to true, an orginal date of hire exists
 * for a person who has never been an employee.
 * @rep:displayname Create Contact Person for Hungary
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_CONTACT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_hu_person
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_preferred_name                in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_ss_number                     in     varchar2 default null
  ,p_maiden_name                   in     varchar2 default null
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
  ,p_mothers_maiden_name           in     varchar2 default null
  ,p_tax_identification_no         in     varchar2 default null
  ,p_personal_identity_no          in     varchar2 default null
  ,p_pensioner_registration_no     in     varchar2 default null
  ,p_contact_employers_name        in     varchar2 default null
  ,p_per_information6              in     varchar2 default null
  ,p_service_completed            in     varchar2 default null
  ,p_reason_not_completed         in     varchar2 default null
  ,p_service_start_date           in     varchar2 default null
  ,p_service_end_date             in     varchar2 default null
  ,p_mandate_code                 in     varchar2 default null
  ,p_mandate_date                 in     varchar2 default null
  ,p_command_type                 in     varchar2 default null
  ,p_command_color                in     varchar2 default null
  ,p_command_number               in     varchar2 default null
  ,p_rank                         in     varchar2 default null
  ,p_position                     in     varchar2 default null
  ,p_organization                 in     varchar2 default null
  ,p_local_department             in     varchar2 default null
  ,p_local_sub_department         in     varchar2 default null
  ,p_group                        in     varchar2 default null
  ,p_sub_group                    in     varchar2 default null
  ,p_ss_start_date                in     varchar2 default null
  ,p_ss_end_date                  in     varchar2 default null
  ,p_per_information25             in     varchar2 default null
  ,p_per_information26             in     varchar2 default null
  ,p_per_information27             in     varchar2 default null
  ,p_per_information28             in     varchar2 default null
  ,p_per_information29             in     varchar2 default null
  ,p_per_information30             in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_honors                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_on_military_service           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_prefix                        in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_place_of_birth                in     varchar2 default null
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
  );
--
end hr_hu_contact_api;

 

/
