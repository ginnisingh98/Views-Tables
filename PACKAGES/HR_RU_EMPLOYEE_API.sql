--------------------------------------------------------
--  DDL for Package HR_RU_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RU_EMPLOYEE_API" AUTHID CURRENT_USER as
/* $Header: peemprui.pkh 120.1 2005/10/02 02:41:47 aroussel $ */
/*#
 * This package contains employee APIs for Russia.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Employee for Russia
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_ru_employee >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new employee for Russia.
 *
 * This API creates a new employee including a default primary assignment and a
 * period of service for the employee.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for Russian legislation must already exist. Also a valid
 * person_type_id, with a corresponding system type of 'EMP', must be active
 * and in the same business group as that of the employee being created.
 *
 * <p><b>Post Success</b><br>
 * An employee is successfully inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the employee and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date The employee hire date and therfore the effective start
 * date of the person, primary assignment, and period of service.
 * @param p_business_group_id Identifies the employee business group.
 * @param p_last_name Employee's last name.
 * @param p_sex Employee's sex.
 * @param p_person_type_id Identifies the type of person. If an identification
 * number is not specified, then the API will use the default 'EMP' type for
 * the business group.
 * @param p_comments Comments for person record.
 * @param p_date_employee_data_verified The date on which the employee last
 * verified the data.
 * @param p_date_of_birth Date of birth.
 * @param p_email_address E-mail address of the applicant.
 * @param p_employee_number Employee number. If the number generation method is
 * Manual, then this parameter is mandatory. If the number generation method is
 * Automatic, then the value of this parameter must be NULL. If p_validate is
 * false and the employee number generation method is Automatic, this will be
 * set to to the generated employee number of the person created. If p_validate
 * is false and the employee number generation method is manual, this will be
 * set to the same value passed in. If p_validate is true this will be set to
 * the same value as passed in.
 * @param p_expense_check_send_to_addres Type of mailing address. Valid values
 * are defined by the 'HOME_OFFICE' lookup type.
 * @param p_first_name Employee's first name.
 * @param p_known_as Alternative name of the employee.
 * @param p_marital_status Marital status of the employee. Valid values are
 * defined by the 'MAR_STATUS' lookup type.
 * @param p_middle_names Employee's middle name(s).
 * @param p_nationality Employee's nationality. Valid values are defined by the
 * 'NATIONALITY' lookup type.
 * @param p_inn National identifier.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Indicates whether the person is classified
 * as disabled. Valid values are defined by the 'REGISTERED_DISABLED' lookup
 * type.
 * @param p_title Employee's title. Valid values are defined by the 'TITLE'
 * lookup type.
 * @param p_vendor_id Unique identifier of supplier.
 * @param p_work_telephone Work telephone of the employee.
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
 * @param p_place_of_birth Employee's place of birth.Valid values are defined
 * by the 'RU_OKATO' lookup type.
 * @param p_references References for the employee in case of rehire.
 * @param p_local_coefficient Valid for employees who live in Last North or
 * regions that are equated to the Last North region.
 * @param p_citizenship Employee's citizenship. Valid values exist in the
 * 'RU_CITIZENSHIP' lookup type.
 * @param p_military_doc Military documents for the employee. Valid values
 * exist in the 'RU_MILITARY_DOC_TYPE' lookup type.
 * @param p_reserve_category Reserve category of the employee. Valid values
 * exist in the 'RU_RESERVE_CATEGORY' lookup type.
 * @param p_military_rank Military rank of the employee. Valid value exists in
 * the 'RU_MILITARY_RANK' lookup type.
 * @param p_military_profile Military profile of the employee. Valid values
 * exist in the 'RU_MILITARY_PROFILE' lookup type.
 * @param p_military_reg_code Military registration board code of the employee.
 * @param p_mil_srvc_readiness_category Military readiness service category of
 * the employee. Valid values exist in the 'RU_MILITARY_SERVICE_READINESS'
 * lookup type.
 * @param p_military_commissariat Military commissariat of the employee.
 * @param p_quitting_mark Conscription dismissal mark of the employee. Valid
 * values exist in the 'RU_QUITTING_MARK' lookup type.
 * @param p_military_unit_number Military unit number of the employee.
 * @param p_military_reg_type Military registration type. Valid values exist in
 * the 'RU_MILITARY_REGISTRATION' lookup type.
 * @param p_military_reg_details Military registration details.
 * @param p_pension_fund_number Pension fund number of the employee.
 * @param p_date_of_death Date of death of the employee.
 * @param p_background_check_status Y/N flag indicates whether background check
 * has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_blood_type Type of blood group of the employee. Valid values are
 * defined by the 'BLOOD_TYPE' lookup type.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fast_path_employee This parameter is currently unsupported.
 * @param p_fte_capacity Full time/part time availability for work.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office.
 * @param p_last_medical_test_by Name of the physician who performed last
 * medical test.
 * @param p_last_medical_test_date Date of the last medical test.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Office Number of the employee.
 * @param p_on_military_service Y/N flag indicating whether the employee is
 * employed in military service.
 * @param p_genitive_last_name Genitive last name of the employee.
 * @param p_projected_start_date This parameter is currently unsupported.
 * @param p_resume_exists Y/N flag indicating whether resume is on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_second_passport_exists Y/N flag indicating whether person has
 * multiple passports.
 * @param p_student_status Full time/part time status of student. Valid values
 * are defined by the 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule Type of work schedule indicating which days the
 * person works. Valid values are defined by the 'WORK_SCHEDULE' lookup type.
 * @param p_suffix This parameter is currently unsupported.
 * @param p_benefit_group_id Identifies the benefit group.
 * @param p_receipt_of_death_cert_date Date when the death certificate was
 * received.
 * @param p_coord_ben_med_pln_no Coordination of benefits medical group plan
 * number.
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag.
 * @param p_coord_ben_med_ext_er Secondary medical coverage external employer.
 * @param p_coord_ben_med_pl_name Secondary medical coverage name.
 * @param p_coord_ben_med_insr_crr_name Secondary medical coverage insurance
 * carrier name.
 * @param p_coord_ben_med_insr_crr_ident Identifies the secondary medical
 * coverage insurance carrier.
 * @param p_coord_ben_med_cvg_strt_dt Secondary medical coverage effective
 * start date.
 * @param p_coord_ben_med_cvg_end_dt Secondary medical coverage effective end
 * date.
 * @param p_uses_tobacco_flag Tobacco type used by the employee. Valid values
 * are defined by the 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire of the employee.
 * @param p_adjusted_svc_date Adjusted service date.
 * @param p_town_of_birth Town or city of birth of the employee.
 * @param p_region_of_birth Geographical region of birth of the employee.
 * @param p_country_of_birth Country of birth of the employee.
 * @param p_global_person_id Global identification number for the person.
 * @param p_party_id Identifies the party.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the employee. If p_validate is true, this
 * will be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the employee. If p_validate is true, this will be
 * null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the employee. If p_validate is true, this will be null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then will be set to the identifier of the created employee record.
 * If p_validate is true or no comment text was provided, then this will be
 * null.
 * @param p_assignment_sequence If p_validate is false, then this will be set
 * to the assignment sequence of the assignment created. If p_validate is true,
 * this parameter is set to null.
 * @param p_assignment_number Assignment number of an employee
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP, EMP_APL, EX_EMP, or EX_EMP_APL.
 * @rep:displayname Create Employee for Russia
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ru_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_inn		           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
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
  ,p_date_of_death                 in     date     default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_genitive_last_name            in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_coord_ben_med_ext_er          in     varchar2 default null
  ,p_coord_ben_med_pl_name         in     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   in     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  in     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     in     date default null
  ,p_coord_ben_med_cvg_end_dt      in     date default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default null
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_party_id                      in     number default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy boolean
  ,p_assign_payroll_warning           out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
);

--

--
end hr_ru_employee_api;

 

/
