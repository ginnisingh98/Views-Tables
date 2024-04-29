--------------------------------------------------------
--  DDL for Package HR_KW_CONTINGENT_WORKER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KW_CONTINGENT_WORKER_API" AUTHID CURRENT_USER as
/* $Header: pecwkkwi.pkh 120.2 2005/10/02 02:40:33 aroussel $ */
/*#
 * This package contains contingent worker APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contingent Worker for Kuwait
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_kw_cwk >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The following procedure creates a Kuwaiti contingent worker.
 *
 * This procedure is used to create a person record and a default contingent
 * worker assignment for a new non-payroll worker.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for Kuwait legislation must already exist. Also a valid
 * person_type_id, with a corresponding system type of 'CWK', must be active
 * and in the same business group as that of the applicant being created.
 *
 * <p><b>Post Success</b><br>
 * The person, primary contingent worker assignment, and period of placement
 * will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The contingent worker will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date The start date for the person, default assignment, and
 * placement.
 * @param p_business_group_id The business group of the contingent worker.
 * @param p_family_name The contingent worker's family name.
 * @param p_person_type_id The person type id. If a person_type_id is not
 * specified, the API will use the default 'CWK' type for the business group.
 * @param p_npw_number The number of the non-payroll worker.
 * @param p_background_check_status The yes/no flag indicates whether the
 * background check has been performed.
 * @param p_background_date_check The date the background check was performed.
 * @param p_blood_type The person's blood type.
 * @param p_comments Contingent worker comment text.
 * @param p_correspondence_language The person's preferred correspondence
 * language.
 * @param p_country_of_birth The person's country of birth.
 * @param p_date_of_birth The person's date of birth.
 * @param p_date_of_death The person's date of death.
 * @param p_dpdnt_adoption_date The date the dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag The yes/no flag indicates whether the
 * dependent is on voluntary service.
 * @param p_email_address The person's email address.
 * @param p_first_name The person's first name.
 * @param p_fte_capacity The person's full time or part time availability for
 * work.
 * @param p_honors Honors or degrees the person holds.
 * @param p_internal_location The internal location of the office.
 * @param p_known_as The person's preferred name.
 * @param p_last_medical_test_by The name of the physician who performed the
 * last medical test.
 * @param p_last_medical_test_date The date of the last medical test.
 * @param p_mailstop The office identifier for internal mail.
 * @param p_marital_status The person's marital status.
 * @param p_national_identifier The person's national identifier.
 * @param p_nationality The person's nationality.
 * @param p_office_number The office number.
 * @param p_on_military_service The yes/no flag indicates whether the person is
 * employed in military service.
 * @param p_party_id The identifier of party.
 * @param p_previous_last_name The person's previous last name.
 * @param p_projected_placement_end The projected end date.
 * @param p_receipt_of_death_cert_date The date the death certificate was
 * received.
 * @param p_region_of_birth The person's geographical region of birth.
 * @param p_registered_disabled_flag The registered disabled flag. The valid
 * values are defined by the 'REGISTERED_DISABLED' lookup type.
 * @param p_resume_exists The yes/no flag indicates whether the resume exists.
 * @param p_resume_last_updated The date the resume was last updated.
 * @param p_second_passport_exists The yes/no flag indicates whether the person
 * has multiple passports.
 * @param p_sex The contingent worker's sex.
 * @param p_student_status The full time or part time status of the student.
 * @param p_title The contingent worker's title.
 * @param p_town_of_birth The person's town or city of birth.
 * @param p_uses_tobacco_flag The person's tobacco usage details.
 * @param p_vendor_id The identifier of workers that are supplying to the
 * organization.
 * @param p_work_schedule The type of work schedule that indicates which days
 * the person works.
 * @param p_work_telephone The person's work telephone.
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
 * @param p_father_name The father's name.
 * @param p_grandfather_name The grandfather's name.
 * @param p_alt_first_name The person's alternate first name.
 * @param p_alt_father_name The father's alternate name.
 * @param p_alt_grandfather_name The grandfather's alternate name.
 * @param p_alt_family_name The person's alternate family name.
 * @param p_previous_nationality The person's previous nationality.
 * @param p_religion The person's religion.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true, this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true, this will be
 * null.
 * @param p_pdp_object_version_number If p_validate is false, this will be set
 * to the version number of the person created. If p_validate is true, this
 * parameter will be set to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true, this will be null.
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
 * sequence number of the default assignment created. If p_validate is true,
 * this parameter will be set to null.
 * @param p_assignment_number If p_validate is false this will be set to the
 * assignment number of the primary assignment. If p_validate is true, this
 * will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @rep:displayname Create Contingent Worker for Kuwait
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_kw_cwk
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
  ,p_previous_nationality          in     varchar2 default null
  ,p_religion			   in     varchar2 default null
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

end hr_kw_contingent_worker_api;

 

/
