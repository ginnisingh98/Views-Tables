--------------------------------------------------------
--  DDL for Package HR_IN_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IN_EMPLOYEE_API" AUTHID CURRENT_USER AS
/* $Header: peempini.pkh 120.2 2007/10/05 11:26:10 sivanara ship $ */
/*#
 * This package contains employee APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Employee for India
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_in_employee >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an employee.
 *
 * A new employee is created, along with a default primary assignment and a
 * period of service. Secure user functionality is included in this version of
 * the API.&lt;P&gt;The following parameters are currently unsupported and must
 * have a null value : p_fast_path_employee p_projected_start_date.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * If person_type_id is supplied, it must have a corresponding system person
 * type of 'EMP', must be active and be in the same business group as that of
 * the employee being created.
 *
 * <p><b>Post Success</b><br>
 * The person, primary assignment and period of service will be successfully
 * inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the person, primary assignment or period of service
 * and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date The employee hire date and thus the effective start date
 * of the person, primary assignment and period of service.
 * @param p_business_group_id The employee's business group.
 * @param p_last_name Employee's last name.
 * @param p_sex Employee's sex. Valid values are defined by 'SEX' lookup type.
 * @param p_person_type_id Person type id. If this value is omitted then the
 * person_type_id of the default `EMP' system person type in the employee's
 * business group is used.
 * @param p_per_comments Comments for person record.
 * @param p_date_employee_data_verified The date on which the employee data was
 * last verified.
 * @param p_date_of_birth Date of birth of the employee.
 * @param p_email_address Email address of the employee.
 * @param p_employee_number The business group's employee number generation
 * method determines when the API derives and passes out an employee number or
 * when the calling program should pass in a value. When the API call completes
 * if p_validate is false then will be set to the employee number. If
 * p_validate is true then will be set to the passed value.
 * @param p_expense_check_send_to_addres Type of mailing address. Valid values
 * are defined by 'HOME_OFFICE' lookup type.
 * @param p_first_name Employee's first name.
 * @param p_alias_name Alternative name of the employee.
 * @param p_marital_status Marital status of the employee. Valid values are
 * defined by 'MAR_STATUS' lookup type.
 * @param p_middle_names Employee middle name(s).
 * @param p_nationality Nationality of the person. Valid values are defined by
 * 'NATIONALITY' lookup type.
 * @param p_national_identifier National identifier of the employee.
 * @param p_previous_last_name Previous last name of the employee.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values are defined by 'REGISTERED_DISABLED' lookup type.
 * @param p_title Employee's title. Valid values are defined by 'TITLE' lookup
 * type.
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
 * @param p_NSSN of the person. Should be 14 digit number.
 * @param p_pan PAN of the person. Should be in correct format (XXXXX9999X).
 * @param p_pan_af PAN Applied for Flag. Valid values are defined by 'YES_NO'
 * lookup type. Has to be null if p_pan is populated.
 * @param p_ex_serviceman Military Status. Valid values are defined by 'YES_NO'
 * lookup type.
 * @param p_resident_status Residential Status of the person. Valid values are
 * defined by 'IN_RESIDENTIAL_STATUS' lookup type.
 * @param p_pf_number PF Number of the employee.
 * @param p_esi_number ESI Nnumber of the employee.
 * @param p_superannuation_number Superannuation Number of the employee.
 * @param p_group_ins_number Group Insurance Number of the employee.
 * @param p_gratuity_number Gratuity Number of the employee.
 * @param p_pension_number Pension Number of the employee.
 * @param p_date_of_death Date of death of the employee.
 * @param p_background_check_status Y/N flag indicates whether background check
 * has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_blood_type Type of blood group of the employee. Valid values are
 * defined by 'BLOOD_TYPE' lookup type.
 * @param p_correspondence_language Preferred language for correspondance.
 * Valid values are defined by FND_LANGUAGES.
 * @param p_fast_path_employee Obsolete parameter, do not use.
 * @param p_fte_capacity Full time/part time availability for work.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office.
 * @param p_last_medical_test_by Name of physician who performed last medical
 * test.
 * @param p_last_medical_test_date Date of last medical test.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Office number of the employee.
 * @param p_on_military_service Y/N flag indicating whether person is employed
 * in military service.
 * @param p_pre_name_adjunct Prefix in the name of the employee.
 * @param p_rehire_recommendation The employee can be rehired or not after
 * termination.
 * @param p_projected_start_date Obsolete parameter, do not use.
 * @param p_resume_exists Y/N flag indicating whether resume is on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_second_passport_exists Y/N flag indicating whether person has
 * multiple passports.
 * @param p_student_status Full time/part time status of student. Valid values
 * are defined by 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule Type of work schedule indicating which days the
 * person works. Valid values are defined by 'WORK_SCHEDULE' lookup type.
 * @param p_suffix Employee's suffix.
 * @param p_benefit_group_id Identification for benefit group of the employee.
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
 * @param p_coord_ben_med_insr_crr_ident Identifier for secondary medical
 * coverage insurance carrier.
 * @param p_coord_ben_med_cvg_strt_dt Secondary medical coverage effective
 * start date.
 * @param p_coord_ben_med_cvg_end_dt Secondary medical coverage effective end
 * date.
 * @param p_uses_tobacco_flag Tobacco type used by the employee. Valid values
 * are defined by 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Date dependent was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependent is on
 * voluntary service.
 * @param p_original_date_of_hire Original date of hire of the employee.
 * @param p_adjusted_svc_date Adjusted service date.
 * @param p_place_of_birth Town or city of birth of the employee.
 * @param p_region_of_birth Geographical region of birth of the employee.
 * @param p_country_of_birth Country of birth of the employee.
 * @param p_global_person_id Global Identification number for the employee.
 * @param p_party_id Identifier for the party.
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
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false this will be set to the id of
 * the corresponding person comment row, if any comment text exists. If
 * p_validate is true this will be null.
 * @param p_assignment_sequence If p_validate is false this will be set to the
 * sequence number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_assignment_number If p_validate is false this will be set to the
 * assignment number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Create Employee for India
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_in_employee
  (p_validate                      IN     boolean  default false
  ,p_hire_date                     IN     date
  ,p_business_group_id             IN     number
  ,p_last_name                     IN     varchar2
  ,p_sex                           IN     varchar2
  ,p_person_type_id                IN     number   default null
  ,p_per_comments                  IN     varchar2 default null
  ,p_date_employee_data_verified   IN     date     default null
  ,p_date_of_birth                 IN     date     default null
  ,p_email_address                 IN     varchar2 default null
  ,p_employee_number               IN out nocopy varchar2
  ,p_expense_check_send_to_addres  IN     varchar2 default null
  ,p_first_name                    IN     varchar2 default null
  ,p_alias_name                    IN     varchar2 default null --Bugfix 3762728
  ,p_marital_status                IN     varchar2 default null
  ,p_middle_names                  IN     varchar2 default null
  ,p_nationality                   IN     varchar2 default null
  ,p_national_identifier           IN     varchar2 default null
  ,p_previous_last_name            IN     varchar2 default null
  ,p_registered_disabled_flag      IN     varchar2 default null
  ,p_title                         IN     varchar2 default null
  ,p_vendor_id                     IN     number   default null
  ,p_work_telephone                IN     varchar2 default null
  ,p_attribute_category            IN     varchar2 default null
  ,p_attribute1                    IN     varchar2 default null
  ,p_attribute2                    IN     varchar2 default null
  ,p_attribute3                    IN     varchar2 default null
  ,p_attribute4                    IN     varchar2 default null
  ,p_attribute5                    IN     varchar2 default null
  ,p_attribute6                    IN     varchar2 default null
  ,p_attribute7                    IN     varchar2 default null
  ,p_attribute8                    IN     varchar2 default null
  ,p_attribute9                    IN     varchar2 default null
  ,p_attribute10                   IN     varchar2 default null
  ,p_attribute11                   IN     varchar2 default null
  ,p_attribute12                   IN     varchar2 default null
  ,p_attribute13                   IN     varchar2 default null
  ,p_attribute14                   IN     varchar2 default null
  ,p_attribute15                   IN     varchar2 default null
  ,p_attribute16                   IN     varchar2 default null
  ,p_attribute17                   IN     varchar2 default null
  ,p_attribute18                   IN     varchar2 default null
  ,p_attribute19                   IN     varchar2 default null
  ,p_attribute20                   IN     varchar2 default null
  ,p_attribute21                   IN     varchar2 default null
  ,p_attribute22                   IN     varchar2 default null
  ,p_attribute23                   IN     varchar2 default null
  ,p_attribute24                   IN     varchar2 default null
  ,p_attribute25                   IN     varchar2 default null
  ,p_attribute26                   IN     varchar2 default null
  ,p_attribute27                   IN     varchar2 default null
  ,p_attribute28                   IN     varchar2 default null
  ,p_attribute29                   IN     varchar2 default null
  ,p_attribute30                   IN     varchar2 default null
  ,p_pan                           IN     varchar2 default null
  ,p_pan_af                        IN     varchar2 default null
  ,p_ex_serviceman                 IN     varchar2 default null --Bugfix 3762728
  ,p_resident_status               IN     varchar2 default null
  ,p_pf_number                     IN     varchar2 default null
  ,p_esi_number                    IN     varchar2 default null
  ,p_superannuation_number         IN     varchar2 default null
  ,p_group_ins_number              IN     varchar2 default null
  ,p_gratuity_number               IN     varchar2 default null
  ,p_pension_number                IN     varchar2 default NULL
  ,p_NSSN                          IN     varchar2 default NULL
  --,p_employee_category           IN     varchar2 default null --Bugfix 3762728
  ,p_date_of_death                 IN     date     default null
  ,p_background_check_status       IN     varchar2 default null
  ,p_background_date_check         IN     date     default null
  ,p_blood_type                    IN     varchar2 default null
  ,p_correspondence_language       IN     varchar2 default null
  ,p_fast_path_employee            IN     varchar2 default null
  ,p_fte_capacity                  IN     number   default null
  ,p_honors                        IN     varchar2 default null
  ,p_internal_location             IN     varchar2 default null
  ,p_last_medical_test_by          IN     varchar2 default null
  ,p_last_medical_test_date        IN     date     default null
  ,p_mailstop                      IN     varchar2 default null
  ,p_office_number                 IN     varchar2 default null
  ,p_on_military_service           IN     varchar2 default null
  ,p_pre_name_adjunct              IN     varchar2 default null
  ,p_rehire_recommendation 	   IN     varchar2 default null
  ,p_projected_start_date          IN     date     default null
  ,p_resume_exists                 IN     varchar2 default null
  ,p_resume_last_updated           IN     date     default null
  ,p_second_passport_exists        IN     varchar2 default null
  ,p_student_status                IN     varchar2 default null
  ,p_work_schedule                 IN     varchar2 default null
  ,p_suffix                        IN     varchar2 default null
  ,p_benefit_group_id              IN     number   default null
  ,p_receipt_of_death_cert_date    IN     date     default null
  ,p_coord_ben_med_pln_no          IN     varchar2 default null
  ,p_coord_ben_no_cvg_flag         IN     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          IN     varchar2 default null
  ,p_coord_ben_med_pl_name         IN     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   IN     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  IN     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     IN     date default null
  ,p_coord_ben_med_cvg_end_dt      IN     date default null
  ,p_uses_tobacco_flag             IN     varchar2 default null
  ,p_dpdnt_adoption_date           IN     date     default null
  ,p_dpdnt_vlntry_svce_flag        IN     varchar2 default 'N'
  ,p_original_date_of_hire         IN     date     default null
  ,p_adjusted_svc_date             IN     date     default null
  ,p_place_of_birth                IN     varchar2 default null --Bugfix 3762728
  ,p_region_of_birth               IN     varchar2 default null
  ,p_country_of_birth              IN     varchar2 default null
  ,p_global_person_id              IN     varchar2 default null
  ,p_party_id                      IN     number default null
  ,p_person_id                     OUT NOCOPY number
  ,p_assignment_id                 OUT NOCOPY number
  ,p_per_object_version_number     OUT NOCOPY number
  ,p_asg_object_version_number     OUT NOCOPY number
  ,p_per_effective_start_date      OUT NOCOPY date
  ,p_per_effective_end_date        OUT NOCOPY date
  ,p_full_name                     OUT NOCOPY varchar2
  ,p_per_comment_id                OUT NOCOPY number
  ,p_assignment_sequence           OUT NOCOPY number
  ,p_assignment_number             OUT NOCOPY varchar2
  ,p_name_combination_warning      OUT NOCOPY boolean
  ,p_assign_payroll_warning        OUT NOCOPY boolean
  ,p_orig_hire_warning             OUT NOCOPY boolean
  );

END hr_in_employee_api;

/
