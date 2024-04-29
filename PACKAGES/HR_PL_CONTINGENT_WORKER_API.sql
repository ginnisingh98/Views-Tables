--------------------------------------------------------
--  DDL for Package HR_PL_CONTINGENT_WORKER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PL_CONTINGENT_WORKER_API" AUTHID CURRENT_USER as
/* $Header: pecwkpli.pkh 120.4 2006/05/12 00:00:10 mseshadr noship $ */
/*#
 * This package contains contingent worker  APIs for Poland.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contingent Worker for Poland
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_pl_cwk >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The following procedure(older version) creates a Polish contingent worker.
 *
 * This procedure is used to create a person record and a default contingent
 * worker assignment for a new non-payroll worker.
 *
 * <P> This version of the API is now out-of-date however it has been provided
 * to you for backward compatibility support and will be removed in the future.
 * Oracle recommends you to modify existing calling programs in advance of the
 * support being withdrawn thus avoiding any potential disruption.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for Poland legislation must already exist. Also a valid
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
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date Start date for person, default assignment and placement
 * record.
 * @param p_business_group_id The contingent worker's business group.
 * @param p_last_name Last name of the contingent worker.
 * @param p_person_type_id This is the identifier corrresponding to the type of
 * person. If an identification number is not specified, then the API will use
 * the default 'CWK' type for the business group.
 * @param p_npw_number Number of non-payroll worker.
 * @param p_background_check_status Y/N flag indicates whether background check
 * has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_blood_type Blood type of the contingent worker.
 * @param p_comments Contingent worker comment text.
 * @param p_correspondence_language Preferred language for correspondance.
 * @param p_country_of_birth Country of birth of the contingent worker.
 * @param p_date_of_birth Date of birth of the contingent worker.
 * @param p_date_of_death Date of death of the contingent worker.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_email_address Email address of the contingent worker.
 * @param p_first_name First name of the contingent worker.
 * @param p_fte_capacity Full-time employment capacity of the contingent
 * worker.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office of the contingent
 * worker.
 * @param p_preferred_name Alternative name of the contingent worker.
 * @param p_last_medical_test_by Name of physician who performed last medical
 * test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Internal mail location for the contingent worker.
 * @param p_marital_status Marital status of the contingent worker. Valid
 * values are defined by 'MAR_STATUS' lookup type.
 * @param p_middle_names Contingent worker's middle name(s).
 * @param p_pesel_number National identifier of the contingent worker.
 * @param p_nationality Contingent worker's nationality. Valid values are
 * defined by 'NATIONALITY' lookup type.
 * @param p_office_number Office Number of the contingent worker.
 * @param p_on_military_service Y/N flag indicating whether the contingent
 * worker is employed in military service.
 * @param p_party_id Identifier for the party.
 * @param p_prefix Obsolete parameter, do not use.
 * @param p_maiden_name Previous last name of the contingent worker.
 * @param p_projected_placement_end Obsolete parameter, do not use.
 * @param p_receipt_of_death_cert_date Date when the death certificate is
 * received.
 * @param p_region_of_birth Geographical region of birth of the contingent
 * worker.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values are defined by 'REGISTERED_DISABLED' lookup type.
 * @param p_resume_exists Y/N flag indicating whether resume is on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_second_passport_exists Y/N flag indicaing whether the person has
 * multiple passports.
 * @param p_sex Contingent worker's gender.
 * @param p_student_status Full time/part time status of the contingent worker.
 * @param p_suffix Obsolete parameter, do not use.
 * @param p_title Title of the contingent worker. Valid values are defined by
 * 'TITLE' lookup type.
 * @param p_town_of_birth Town or city of birth of the contingent worker.
 * @param p_uses_tobacco_flag Tobacoo type used by the contingent worker. Valid
 * values are defined by 'TOBACCO_USER' lookup type.
 * @param p_vendor_id Identifier for the organisation supplying contingent
 * workers.
 * @param p_work_schedule Type of work schedule indicating which days the
 * contingent worker works. Valid values are defined by 'WORK_SCHEDULE' lookup
 * type.
 * @param p_work_telephone Work telephone of the contingent worker.
 * @param p_exp_check_send_to_address Mailing address of the contingent worker.
 * @param p_hold_applicant_date_until Date until which the applicant should be
 * put on hold.
 * @param p_date_employee_data_verified Date when the employee last verified
 * the data.
 * @param p_benefit_group_id Identification for benefit group.
 * @param p_coord_ben_med_pln_no Coordination of benefits medical group plan
 * number.
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag.
 * @param p_original_date_of_hire Original date of hire of the contingent
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
 * @param p_per_information_category Obsolete parameter, do not use.
 * @param p_nip_number The National Polish Tax identifier of the contingent
 * worker.
 * @param p_per_information2 Developer descriptive flexfield segment.
 * @param p_per_information3 Developer descriptive flexfield segment.
 * @param p_per_information4 Developer descriptive flexfield segment.
 * @param p_per_information5 Developer descriptive flexfield segment.
 * @param p_per_information6 Developer descriptive flexfield segment.
 * @param p_per_information7 Developer descriptive flexfield segment.
 * @param p_per_information8 Developer descriptive flexfield segment.
 * @param p_per_information9 Developer descriptive flexfield segment.
 * @param p_per_information10 Developer descriptive flexfield segment.
 * @param p_per_information11 Developer descriptive flexfield segment.
 * @param p_per_information12 Developer descriptive flexfield segment.
 * @param p_per_information13 Developer descriptive flexfield segment.
 * @param p_per_information14 Developer descriptive flexfield segment.
 * @param p_per_information15 Developer descriptive flexfield segment.
 * @param p_per_information16 Developer descriptive flexfield segment.
 * @param p_per_information17 Developer descriptive flexfield segment.
 * @param p_per_information18 Developer descriptive flexfield segment.
 * @param p_per_information19 Developer descriptive flexfield segment.
 * @param p_per_information20 Developer descriptive flexfield segment.
 * @param p_per_information21 Developer descriptive flexfield segment.
 * @param p_per_information22 Developer descriptive flexfield segment.
 * @param p_per_information23 Developer descriptive flexfield segment.
 * @param p_per_information24 Developer descriptive flexfield segment.
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
 * @rep:displayname Create Contigent Worker for Poland
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:scope public
 * @rep:lifecycle deprecated
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pl_cwk
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
  ,p_first_name                    in     varchar2
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_preferred_name                in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_pesel_number                  in     varchar2 default null
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
  ,p_per_information_category      in     varchar2 default null
  ,p_nip_number                    in     varchar2 default null
  ,p_per_information2              in     varchar2 default null
  ,p_per_information3              in     varchar2 default null
  ,p_per_information4              in     varchar2 default null
  ,p_per_information5              in     varchar2 default null
  ,p_per_information6              in     varchar2 default null
  ,p_per_information7              in     varchar2 default null
  ,p_per_information8              in     varchar2 default null
  ,p_per_information9              in     varchar2 default null
  ,p_per_information10             in     varchar2 default null
  ,p_per_information11             in     varchar2 default null
  ,p_per_information12             in     varchar2 default null
  ,p_per_information13             in     varchar2 default null
  ,p_per_information14             in     varchar2 default null
  ,p_per_information15             in     varchar2 default null
  ,p_per_information16             in       varchar2 default null
  ,p_per_information17             in       varchar2 default null
  ,p_per_information18             in       varchar2 default null
  ,p_per_information19             in       varchar2 default null
  ,p_per_information20             in       varchar2 default null
  ,p_per_information21             in       varchar2 default null
  ,p_per_information22             in       varchar2 default null
  ,p_per_information23             in       varchar2 default null
  ,p_per_information24             in       varchar2 default null
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
-- ----------------------------------------------------------------------------
-- |----------------------------< create_pl_cwk >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * The following procedure creates a Polish contingent worker.
 *
 * This procedure is used to create a person record and a default contingent
 * worker assignment for a new non-payroll worker.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for Poland legislation must already exist. Also a valid
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
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date Start date for person, default assignment and placement
 * record.
 * @param p_business_group_id The contingent worker's business group.
 * @param p_last_name Last name of the contingent worker.
 * @param p_person_type_id This is the identifier corrresponding to the type of
 * person. If an identification number is not specified, then the API will use
 * the default 'CWK' type for the business group.
 * @param p_npw_number Number of non-payroll worker.
 * @param p_background_check_status Yes/No flag indicates whether
 * background check has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_blood_type Blood type of the contingent worker.
 * @param p_comments Contingent worker comment text.
 * @param p_correspondence_language Preferred language for correspondance.
 * @param p_country_of_birth Country of birth of the contingent worker.
 * @param p_date_of_birth Date of birth of the contingent worker.
 * @param p_date_of_death Date of death of the contingent worker.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_email_address Email address of the contingent worker.
 * @param p_first_name First name of the contingent worker.
 * @param p_fte_capacity Full-time employment capacity of the contingent
 * worker.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office of the contingent
 * worker.
 * @param p_preferred_name Alternative name of the contingent worker.
 * @param p_last_medical_test_by Name of physician who performed last medical
 * test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Internal mail location for the contingent worker.
 * @param p_marital_status Marital status of the contingent worker. Valid
 * values are defined by 'MAR_STATUS' lookup type.
 * @param p_middle_names Contingent worker's middle name(s).
 * @param p_pesel National identifier of the contingent worker.
 * @param p_nationality Contingent worker's nationality. Valid values are
 * defined by 'NATIONALITY' lookup type.
 * @param p_office_number Office Number of the contingent worker.
 * @param p_on_military_service Yes/No flag indicating whether the contingent
 * worker is employed in military service.
 * @param p_party_id Identifier for the party.
 * @param p_prefix Obsolete parameter, do not use.
 * @param p_maiden_name Previous last name of the contingent worker.
 * @param p_projected_placement_end Obsolete parameter, do not use.
 * @param p_receipt_of_death_cert_date Date when the death certificate is
 * received.
 * @param p_region_of_birth Geographical region of birth of the contingent
 * worker.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values are defined by 'REGISTERED_DISABLED' lookup type.
 * @param p_resume_exists Yes/No flag indicating whether resume is on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_second_passport_exists Yes/No flag indicaing whether the person has
 * multiple passports.
 * @param p_sex Contingent worker's gender.
 * @param p_student_status Full time/part time status of the contingent worker.
 * @param p_suffix Obsolete parameter, do not use.
 * @param p_title Title of the contingent worker. Valid values are defined by
 * 'TITLE' lookup type.
 * @param p_town_of_birth Town or city of birth of the contingent worker.
 * @param p_uses_tobacco_flag Tobacoo type used by the contingent worker. Valid
 * values are defined by 'TOBACCO_USER' lookup type.
 * @param p_vendor_id Identifier for the organisation supplying contingent
 * workers.
 * @param p_work_schedule Type of work schedule indicating which days the
 * contingent worker works. Valid values are defined by 'WORK_SCHEDULE' lookup
 * type.
 * @param p_work_telephone Work telephone of the contingent worker.
 * @param p_exp_check_send_to_address Mailing address of the contingent worker.
 * @param p_hold_applicant_date_until Date until which the applicant should be
 * put on hold.
 * @param p_date_employee_data_verified Date when the employee last verified
 * the data.
 * @param p_benefit_group_id Identification for benefit group.
 * @param p_coord_ben_med_pln_no Coordination of benefits medical group plan
 * number.
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag.
 * @param p_original_date_of_hire Original date of hire of the contingent
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
 * @param p_per_information_category Obsolete parameter, do not use.
 * @param p_nip Contingent worker's national Polish tax
 * identifier.
 * @param p_oldage_pension_rights This indicates whether the  contingent worker
 * has old age or pension rights.'Valid values are defined by
 * 'PL_OLDAGE_PENSION_RIGHTS' lookup type.
 * @param p_national_fund_of_health This indicates the national fund of health
 * to which the contingent worker belongs.Valid values are defined by
 * 'PL_NATIONAL_FUND_OF_HEALTH' lookup type.
 * @param p_tax_office Specifies the tax office of the contingent worker.
 * @param p_legal_employer Specifies the legal employer of the contingent worker.
 * @param p_citizenship This indicates the citizenship of the contingent worker.
 * Valid values are defined by 'PL_CITIZENSHIP' lookup type.
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
 * @rep:displayname Create Contigent Worker for Poland
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure create_pl_cwk
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
  ,p_first_name                    in     varchar2
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_preferred_name                in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_pesel                         in     varchar2 default null
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
  ,p_per_information_category      in     varchar2 default null
  ,p_nip                           in     varchar2 default null
  ,p_oldage_pension_rights         in     varchar2 default null
  ,p_national_fund_of_health       in     varchar2 default null
  ,p_tax_office                    in     varchar2 default null
  ,p_legal_employer                in     varchar2 default null
  ,p_citizenship                   in     varchar2 default null
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
End hr_pl_contingent_worker_api;

 

/
