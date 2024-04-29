--------------------------------------------------------
--  DDL for Package HR_AE_CONTINGENT_WORKER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AE_CONTINGENT_WORKER_API" AUTHID CURRENT_USER as
/* $Header: pecwkaei.pkh 120.8 2006/04/26 23:50:26 spendhar noship $ */
/*#
 * This package contains contingent APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contingent Worker for UAE
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ae_cwk  >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * The following procedure creates a UAE contingent worker.
 *
 * This procedure is used to create a person record and a default contingent
 * worker assignment for a new non-payroll worker.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for UAE legislation must already exist. Also a valid
 * person_type_id, with a corresponding system type of 'CWK', must be active
 * and in the same business group as that of the applicant being created.
 *
 * <p><b>Post Success</b><br>
 * The person, primary contingent worker assignment and period of placement
 * will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The contingent worker will not be created and an error will be raised.
 *
 * @param p_validate If true, the database remains unchanged. If false a valid
 * Contingent worker is created in the database.
 * @param p_start_date Start date for person, default assignment, placement
 * @param p_business_group_id Business group of Contingent worker
 * @param p_family_name Family name
 * @param p_person_type_id Person type. If null, defaults for system type of Contingent worker
 * is chosen
 * @param p_npw_number Identification number of non-payroll worker
 * @param p_background_check_status Y/N flag indicates whether background check
 * has been performed
 * @param p_background_date_check Date background check was performed
 * @param p_blood_type Blood type
 * @param p_comments Comments for person record
 * @param p_correspondence_language Preferred language for correspondance
 * @param p_country_of_birth Country of birth
 * @param p_date_of_birth Date of birth
 * @param p_date_of_death Date of death
 * @param p_dpdnt_adoption_date Dependent's adoption date
 * @param p_dpdnt_vlntry_svce_flag Dependent's voluntary service flag
 * @param p_email_address varchar2 Email address.
 * @param p_first_name First name
 * @param p_fte_capacity Full time/part time availability for work
 * @param p_honors Honors or degrees awarded
 * @param p_internal_location Internal location of office
 * @param p_known_as Alternative name
 * @param p_last_medical_test_by Name of physician who performed last medical test
 * @param p_last_medical_test_date Date of last medical test
 * @param p_mailstop Office identifier for internal mail
 * @param p_marital_status Marital status.
 * @param p_national_identifier National identifier.
 * @param p_office_number Number of office
 * @param p_on_military_service Y/N flag indicating whether person is employed in
 * military service
 * @param p_party_id Party Id
 * @param p_previous_last_name Previous last name
 * @param p_projected_placement_end Projected end date
 * @param p_receipt_of_death_cert_date Date the death certificate is received.
 * @param p_region_of_birth Geographical region of birth
 * @param p_registered_disabled_flag Registered disabled flag.
 * @param p_resume_exists Y/N flag indicating whether resume is on file
 * @param p_resume_last_updated Date resume last updated
 * @param p_second_passport_exists Y/N flag indicaing whether person has multiple passports
 * @param p_sex Sex of worker
 * @param p_student_status Full time/part time status of student
 * @param p_title varchar2 Title of worker
 * @param p_place_of_birth Town or city of birth
 * @param p_uses_tobacco_flag Uses tobacco list of values
 * @param p_vendor_id Identifier of workers supplying Organization.
 * @param p_work_schedule Type of work schedule inndicating which days  person works
 * @param p_work_telephone Work telephone.
 * @param p_exp_check_send_to_address The contingent worker's mailing address.
 * @param p_hold_applicant_date_until The date until which the applicant should
 * be put on hold.
 * @param p_date_employee_data_verified The date when the employee last
 * verified the data.
 * @param p_benefit_group_id The identification for benefit group.
 * @param p_coord_ben_med_pln_no The coordination of the benefits medical group
 * plan number.
 * @param p_coord_ben_no_cvg_flag The coordination of the benefits no other
 * coverage flag.
 * @param p_original_date_of_hire The original date of hire of the contingent
 * worker.
 * @param p_attribute_category Determines the context of the descriptive flexfield
 * in the parameter list
 * @param p_attribute1 Descriptive flexfield
 * @param p_attribute2 Descriptive flexfield
 * @param p_attribute3 Descriptive flexfield
 * @param p_attribute4 Descriptive flexfield
 * @param p_attribute5 Descriptive flexfield
 * @param p_attribute6 Descriptive flexfield
 * @param p_attribute7 Descriptive flexfield
 * @param p_attribute8 Descriptive flexfield
 * @param p_attribute9 Descriptive flexfield
 * @param p_attribute10 Descriptive flexfield
 * @param p_attribute11 Descriptive flexfield
 * @param p_attribute12 Descriptive flexfield
 * @param p_attribute13 Descriptive flexfield
 * @param p_attribute14 Descriptive flexfield
 * @param p_attribute15 Descriptive flexfield
 * @param p_attribute16 Descriptive flexfield
 * @param p_attribute17 Descriptive flexfield
 * @param p_attribute18 Descriptive flexfield
 * @param p_attribute19 Descriptive flexfield
 * @param p_attribute20 Descriptive flexfield
 * @param p_attribute21 Descriptive flexfield
 * @param p_attribute22 Descriptive flexfield
 * @param p_attribute23 Descriptive flexfield
 * @param p_attribute24 Descriptive flexfield
 * @param p_attribute25 Descriptive flexfield
 * @param p_attribute26 Descriptive flexfield
 * @param p_attribute27 Descriptive flexfield
 * @param p_attribute28 Descriptive flexfield
 * @param p_attribute29 Descriptive flexfield
 * @param p_attribute30 Descriptive flexfield
 * @param p_father_name Father's Name.
 * @param p_grandfather_name Grandfather's Name.
 * @param p_mother_name Mother's Name.
 * @param p_alt_first_name Alternate first name.
 * @param p_alt_father_name Father's alternate name.
 * @param p_alt_grandfather_name Grandfather's alternate name.
 * @param p_alt_family_name Alternate family name.
 * @param p_alt_mother_name Alternate mother name.
 * @param p_previous_nationality Previous Nationality.
 * @param p_religion Religion.
 * @param p_education_level Education level.
 * @param p_alt_place_of_birth Alternate place of birth.
 * @param p_date_of_change Date of change of nationality.
 * @param p_reason_for_change Reason for change of nationality.
 * @param p_nationality Nationality
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_pdp_object_version_number If p_validate is false, this will be set
 * to the version number of the person created. If p_validate is true this
 * parameter will be set to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created contingent worker comment
 * record. If p_validate is true or no comment text was provided, then will be
 * null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_assignment_sequence If p_validate is false, this will be set to the
 * sequence number of the default assignment created. If p_validate is true
 * this parameter will be set to null.
 * @param p_assignment_number If p_validate is false this will be set to the
 * assignment number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @rep:displayname Create Contigent Worker for UAE
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ae_cwk
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
  ,p_place_of_birth                 in     varchar2 default null
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
  ,p_father_name                   in     varchar2 default null
  ,p_grandfather_name              in     varchar2 default null
  ,p_mother_name                   in     varchar2 default null
  ,p_alt_first_name                in     varchar2 default null
  ,p_alt_father_name               in     varchar2 default null
  ,p_alt_grandfather_name          in     varchar2 default null
  ,p_alt_family_name               in     varchar2 default null
  ,p_alt_mother_name               in     varchar2 default null
  ,p_previous_nationality          in     varchar2 default null
  ,p_religion                      in     varchar2 default null
  ,p_education_level               in     varchar2 default null
  ,p_alt_place_of_birth            in     varchar2 default null
  ,p_date_of_change                in     varchar2 default null
  ,p_reason_for_change             in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_person_id                     out nocopy   number
  ,p_per_object_version_number     out nocopy   number
  ,p_per_effective_start_date      out nocopy   date
  ,p_per_effective_end_date        out nocopy   date
  ,p_pdp_object_version_number     out nocopy   number
  ,p_full_name                     out nocopy   varchar2
  ,p_comment_id                    out nocopy   number
  ,p_assignment_id                 out nocopy   number
  ,p_asg_object_version_number     out nocopy   number
  ,p_assignment_sequence           out nocopy   number
  ,p_assignment_number             out nocopy   varchar2
  ,p_name_combination_warning      out nocopy   boolean
  );

end hr_ae_contingent_worker_api;

/
