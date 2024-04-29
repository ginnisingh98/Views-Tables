--------------------------------------------------------
--  DDL for Package HR_RU_CONTINGENT_WORKER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RU_CONTINGENT_WORKER_API" AUTHID CURRENT_USER as
/* $Header: pecwkrui.pkh 120.1 2005/10/02 02:40:53 aroussel $ */
/*#
 * This package contains contingent worker APIs for Russia.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contingent Worker for Russia
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_ru_cwk >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new contingent worker for Russia.
 *
 * This API creates a new contingent worker including a default primary
 * assignment for the contingent worker.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for Russian legislation must already exist.
 *
 * <p><b>Post Success</b><br>
 * A contingent worker is successfully inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the contingent worker and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date Start date for person, default assignment, and placement
 * record.
 * @param p_business_group_id Contingent worker's business group.
 * @param p_last_name Contingent worker's last name.
 * @param p_person_type_id Identifies the type of person. If an identification
 * number is not specified, then the API will use the default 'CWK' type for
 * the business group.
 * @param p_npw_number Number of non-payrolled worker.
 * @param p_background_check_status Y/N flag indicates whether background check
 * has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_blood_type Type of blood group of the contingent worker. Valid
 * values are defined by the 'BLOOD_TYPE' lookup type.
 * @param p_comments Contingent Worker comment text.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_country_of_birth Country of birth of the contingent worker.
 * @param p_date_of_birth Date of birth.
 * @param p_date_of_death Date of death of the contingent worker.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_email_address E-mail address of the contingent worker.
 * @param p_first_name Contingent worker's first name.
 * @param p_fte_capacity Full-time employment capacity of the contingent
 * worker.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office.
 * @param p_known_as Alternative name of the contingent worker.
 * @param p_last_medical_test_by Name of the physician who performed last
 * medical test.
 * @param p_last_medical_test_date Date of the last medical test.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_marital_status Marital status of the contingent worker. Valid
 * values are defined by the 'MAR_STATUS' lookup type.
 * @param p_middle_names Contingent worker's middle name(s).
 * @param p_inn National identifier.
 * @param p_nationality Contingent worker's nationality. Valid values are
 * defined by 'NATIONALITY' lookup type.
 * @param p_office_number Office number of the contingent worker.
 * @param p_on_military_service Y/N flag indicating whether the contingent
 * worker is employed in military service.
 * @param p_party_id Identifies the party.
 * @param p_genitive_last_name Genitive last name of the contingent worker.
 * @param p_previous_last_name Previous last name.
 * @param p_projected_placement_end Obsolete parameter, do not use.
 * @param p_receipt_of_death_cert_date Date when the death certificate was
 * received.
 * @param p_region_of_birth Geographical region of birth of the contingent
 * worker.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values are defined by the 'REGISTERED_DISABLED' lookup type.
 * @param p_resume_exists Y/N flag indicating whether resume is on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_second_passport_exists Y/N flag indicating whether person has
 * multiple passports.
 * @param p_sex Contingent worker's sex.
 * @param p_student_status Full time/part time status of student. Valid values
 * are defined by the 'STUDENT_STATUS' lookup type.
 * @param p_suffix This parameter is currently unsupported.
 * @param p_title Contingent worker's title. Valid values are defined by
 * 'TITLE' lookup type.
 * @param p_town_of_birth Town or city of birth of the contingent worker.
 * @param p_uses_tobacco_flag Tobacco type used by the contingent worker. Valid
 * values are defined by the 'TOBACCO_USER' lookup type.
 * @param p_vendor_id Unique identifier of supplier.
 * @param p_work_schedule Type of work schedule indicating which days the
 * person works. Valid values are defined by the 'WORK_SCHEDULE' lookup type.
 * @param p_work_telephone Work telephone of the contingent worker.
 * @param p_exp_check_send_to_address Mailing address of the contingent worker.
 * @param p_hold_applicant_date_until Date until which the applicant should be
 * put on hold.
 * @param p_date_employee_data_verified Date when the employee last verified
 * the data.
 * @param p_benefit_group_id Identifies the benefit group.
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
 * @param p_place_of_birth Contingent worker's place of birth.Valid values are
 * defined by the 'RU_OKATO' lookup type.
 * @param p_references References for the contingent worker in case of rehire.
 * @param p_local_coefficient Valid for contingent workers who live in Last
 * North or regions that are equated to the Last North region.
 * @param p_citizenship Contingent worker's citizenship. Valid values exist in
 * the 'RU_CITIZENSHIP' lookup type.
 * @param p_military_doc Military documents for the contingent worker. Valid
 * values exist in the 'RU_MILITARY_DOC_TYPE' lookup type.
 * @param p_reserve_category Reserve category of the contingent worker. Valid
 * values exist in the 'RU_RESERVE_CATEGORY' lookup type.
 * @param p_military_rank Military rank of the contingent worker. Valid values
 * exist in the 'RU_MILITARY_RANK' lookup type.
 * @param p_military_profile Military profile of the contingent worker. Valid
 * values exist in the 'RU_MILITARY_PROFILE' lookup type.
 * @param p_military_reg_code Military registration board code of the
 * contingent worker.
 * @param p_mil_srvc_readiness_category Military readiness service category of
 * the contingent worker. Valid values exist in the
 * 'RU_MILITARY_SERVICE_READINESS' lookup type.
 * @param p_military_commissariat Military commissariat of the contingent
 * worker.
 * @param p_quitting_mark Conscription dismissal mark of the contingent worker.
 * Valid values exist in 'RU_QUITTING_MARK' lookup_type.
 * @param p_military_unit_number Military unit number of the contingent worker.
 * @param p_military_reg_type Military registration type. Valid values exist in
 * the 'RU_MILITARY_REGISTRATION' lookup type.
 * @param p_military_reg_details Military registration details.
 * @param p_pension_fund_number Pension fund number of the contingent worker.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the contingent worker. If p_validate is true,
 * this will be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the contingent worker. If p_validate is true, this
 * will be null.
 * @param p_pdp_object_version_number If p_validate is false, this will be set
 * to the version number of the person created. If p_validate is true, this
 * parameter will be set to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the contingent worker. If p_validate is true, this will be
 * null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created contingent worker record.
 * If p_validate is true or no comment text was provided, then this will be
 * null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_assignment_sequence If p_validate is false, then this will be set
 * to the assignment sequence of the assignment created. If p_validate is true,
 * this parameter is set to null.
 * @param p_assignment_number If p_validate is false this will be set to the
 * assignment number of the primary assignment. If p_validate is true, this
 * will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @rep:displayname Create Contingent Worker for Russia
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ru_cwk
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
  ,p_known_as                      in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_inn		           in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_party_id                      in     number   default null
  ,p_genitive_last_name            in     varchar2 default null
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
  ,p_place_of_birth		   in     varchar2 default null
  ,p_references		           in     varchar2 default null
  ,p_local_coefficient		   in     varchar2 default null
  ,p_citizenship		   in     varchar2
  ,p_military_doc		   in     varchar2 default null
  ,p_reserve_category		   in     varchar2 default null
  ,p_military_rank		   in     varchar2 default null
  ,p_military_profile		   in     varchar2 default null
  ,p_military_reg_code		   in     varchar2 default null
  ,p_mil_srvc_readiness_category   in     varchar2 default null
  ,p_military_commissariat	   in     varchar2 default null
  ,p_quitting_mark		   in     varchar2 default null
  ,p_military_unit_number	   in     varchar2 default null
  ,p_military_reg_type		   in     varchar2 default null
  ,p_military_reg_details	   in     varchar2 default null
  ,p_pension_fund_number	   in     varchar2 default null
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
end hr_ru_contingent_worker_api;

 

/
