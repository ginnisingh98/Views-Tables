--------------------------------------------------------
--  DDL for Package HR_HU_CONTINGENT_WORKER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HU_CONTINGENT_WORKER_API" AUTHID CURRENT_USER as
/* $Header: pecwkhui.pkh 120.1 2005/10/02 02:14:35 aroussel $ */
/*#
 * This package contains Contingent Worker APIs for Hungary.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Contingent Worker for Hungary
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_hu_cwk >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new contingent worker for Hungary.
 *
 * This API creates a new contingent worker. It creates the contingent worker
 * personal details, and a default contingent worker assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Valid business group for Hungary.
 *
 * <p><b>Post Success</b><br>
 * Contingent worker is created without any errors.
 *
 * <p><b>Post Failure</b><br>
 * Contingent Worker is not created and an error message is generated.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date Start Date.
 * @param p_business_group_id Business group of the person.
 * @param p_last_name Last name.
 * @param p_person_type_id Type of contingent worker being created.
 * @param p_npw_number The business group's contingent worker number generation
 * method determines when the API derives and passes out a contingent worker
 * number or when the calling program should pass in a value. When the API call
 * completes if p_validate is true then will be set to the contingent worker
 * number. If p_validate is true then will be set to the passed value.
 * @param p_background_check_status Flag indicating whether the person's
 * background has been checked.
 * @param p_background_date_check Date on which the background check was
 * performed.
 * @param p_blood_type Blood type.
 * @param p_comments Comment text.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_country_of_birth Country of birth.
 * @param p_date_of_birth Date of birth.
 * @param p_date_of_death Date of death.
 * @param p_dpdnt_adoption_date Date on which the dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Flag indicating whether the dependent is on
 * voluntary service.
 * @param p_email_address Email address.
 * @param p_first_name First name.
 * @param p_fte_capacity Obsolete parameter, do not use.
 * @param p_honors Honors awarded.
 * @param p_internal_location Internal location of office.
 * @param p_preferred_name Alternative name
 * @param p_last_medical_test_by Name of physician who performed last medical
 * test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Internal mail location.
 * @param p_marital_status Marital status. Valid values are defined by the
 * MAR_STATUS lookup type.
 * @param p_middle_names Middle names.
 * @param p_ss_number National identifier.
 * @param p_nationality Nationality. Valid values are defined by the
 * NATIONALITY lookup type.
 * @param p_office_number Office number.
 * @param p_on_military_service Flag indicating whether the person is on
 * military service.
 * @param p_party_id TCA party for whom you create the person record.
 * @param p_prefix Name prefix
 * @param p_maiden_name Previous last name
 * @param p_projected_placement_end Obsolete parameter, do not use.
 * @param p_receipt_of_death_cert_date Date death certificate was received.
 * @param p_region_of_birth Geographical region of birth.
 * @param p_registered_disabled_flag Flag indicating whether the person is
 * classified as disabled.
 * @param p_resume_exists Flag indicating whether the person's resume is on
 * file.
 * @param p_resume_last_updated Date on which the resume was last updated.
 * @param p_second_passport_exists Flag indicating whether a person has
 * multiple passports.
 * @param p_sex Legal gender. Valid values are defined by the SEX lookup type.
 * @param p_student_status If this contingent worker is a student, this field
 * is used to capture their status. Valid values are defined by the
 * STUDENT_STATUS lookup type.
 * @param p_suffix Suffix after the person's last name e.g. Sr., Jr., III.
 * @param p_title Title. Valid values are defined by the TITLE lookup type.
 * @param p_place_of_birth Town or city of birth
 * @param p_uses_tobacco_flag Flag indicating whether the person uses tobacco.
 * @param p_vendor_id Obsolete parameter, do not use.
 * @param p_work_schedule Days on which this person will work.
 * @param p_work_telephone Obsolete parameter, do not use.
 * @param p_exp_check_send_to_address Mailing address.
 * @param p_hold_applicant_date_until Date until when the applicant's
 * information is to be maintained.
 * @param p_date_employee_data_verified Date on which the contingent worker
 * data was last verified.
 * @param p_benefit_group_id Benefit group to which this person will belong.
 * @param p_coord_ben_med_pln_no Secondary medical plan name. Column used for
 * external processing.
 * @param p_coord_ben_no_cvg_flag No secondary medical plan coverage. Column
 * used for external processing.
 * @param p_original_date_of_hire Original date of hire.
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
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person. If p_validate is true,
 * then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person. If p_validate is true, then set
 * to null.
 * @param p_pdp_object_version_number If p_validate is false, this will be set
 * to the version number of the person created. If p_validate is true this
 * parameter will be set to null.
 * @param p_full_name If p_validate is false, then set to the complete full
 * name of the person. If p_validate is true, then set to null.
 * @param p_comment_id Comment text.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_assignment_sequence If p_validate is false, then set to the
 * sequence number of the default assignment. If p_validate is true, then set
 * to null.
 * @param p_assignment_number If p_validate is false, then set to the
 * assignment number of the default assignment. If p_validate is true, then set
 * to null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @rep:displayname Create Contingent Worker for Hungary
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_hu_cwk
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
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
  ,p_first_name                    in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_preferred_name                in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_ss_number                     in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_party_id                      in     number   default null
  ,p_prefix                        in     varchar2 default null
  ,p_maiden_name                   in     varchar2 default null
  ,p_projected_placement_end       in     date     default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_sex                           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_place_of_birth                in     varchar2 default null
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
  ,p_per_information25             in       varchar2 default null
  ,p_per_information26             in       varchar2 default null
  ,p_per_information27             in       varchar2 default null
  ,p_per_information28             in       varchar2 default null
  ,p_per_information29             in       varchar2 default null
  ,p_per_information30             in       varchar2 default null
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
  );
--
End hr_hu_contingent_worker_api;

 

/
