--------------------------------------------------------
--  DDL for Package HR_SA_CONTINGENT_WORKER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SA_CONTINGENT_WORKER_API" AUTHID CURRENT_USER as
/* $Header: pecwksai.pkh 120.4 2005/10/02 02:14:41 aroussel $ */
/*#
 * This package contains contingent worker APIs for Saudi Arabia.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Contingent Worker for Saudi Arabia
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_sa_cwk >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a contingent worker record for Saudi Arabia.
 *
 * The API calls the generic API create_cwk, with parameters set as appropriate
 * for the Saudi person. As this API is effectively an alternative to the API
 * create_cwk, see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_cwk
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates the contingent worker record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the contingent worker record and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date Start Date.
 * @param p_business_group_id Business group of the person.
 * @param p_family_name Family Name
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
 * @param p_known_as Preferred name.
 * @param p_last_medical_test_by Name of physician who performed last medical
 * test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Internal mail location.
 * @param p_marital_status Marital status. Valid values are defined by the
 * MAR_STATUS lookup type.
 * @param p_national_identifier Number by which a person is identified in a
 * given legislation.
 * @param p_nationality Nationality. Valid values are defined by the
 * NATIONALITY lookup type.
 * @param p_office_number Office number.
 * @param p_on_military_service Flag indicating whether the person is on
 * military service.
 * @param p_party_id TCA party for whom you create the person record.
 * @param p_previous_last_name Previous last name.
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
 * @param p_title Title. Valid values are defined by the TITLE lookup type.
 * @param p_town_of_birth Town or city of birth.
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
 * @param p_father_name Father's Name
 * @param p_grandfather_name Grandfather's Name
 * @param p_alt_first_name Specifies First Name in alternative language
 * @param p_alt_father_name Specifies Father's Name in alternative language
 * @param p_alt_grandfather_name Specifies Grandfather's Name in alternative
 * language
 * @param p_alt_family_name Specifies Family Name in alternative language
 * @param p_religion Religion
 * @param p_hijrah_birth_date Date of birth according to the Hijrah calendar.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then set to
 * null.
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
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created person comment record. If
 * p_validate is true or no comment text was provided, then will be null.
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
 * @param p_education_level New parameter, available on the latest version of this API
 * @rep:displayname Create Contingent Worker for Saudi Arabia
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_sa_cwk
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_family_name                   in     varchar2
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
  ,p_known_as                      in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
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
  ,p_title                         in     varchar2 default null
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
  ,p_father_name             	   in     varchar2 default null
  ,p_grandfather_name              in     varchar2 default null
  ,p_alt_first_name                in     varchar2 default null
  ,p_alt_father_name               in     varchar2 default null
  ,p_alt_grandfather_name          in     varchar2 default null
  ,p_alt_family_name           	   in     varchar2 default null
  ,p_religion                      in     varchar2 default null
  ,p_hijrah_birth_date             in     varchar2 default null
  ,p_education_level               in     varchar2 default null
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

end hr_sa_contingent_worker_api;

 

/
