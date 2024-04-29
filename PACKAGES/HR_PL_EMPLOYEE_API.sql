--------------------------------------------------------
--  DDL for Package HR_PL_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PL_EMPLOYEE_API" AUTHID CURRENT_USER as
/* $Header: peemppli.pkh 120.3 2006/05/08 06:38:36 mseshadr noship $ */
/*#
 * This package contains employee APIs for Poland.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Employee for Poland
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_pl_employee >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API(older version) creates a new employee, including a default primary
 * assignment and a period of service for the employee.
 *
 * This API is effectively an alternative to the API create_employee. If
 * p_validate is set to false, an employee is created.
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
 * The business group for the Poland legislation must already exist. Also, a
 * valid person_type_id, with a corresponding system type of EMP, must be
 * active and in the same business group as the employee being created.
 *
 * <p><b>Post Success</b><br>
 * The person, primary assignment, and period of service will have been
 * successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The person, primary assignment, or period of service will not be created,
 * and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date Employee's hire date, and thus the effective start date
 * of the primary assignment, and period of service.
 * @param p_business_group_id Employee's business group.
 * @param p_last_name Employee's last name.
 * @param p_sex Employee's gender.
 * @param p_person_type_id This is the identifier of the person type. If an
 * identification number is not specified, then the API uses the default EMP
 * type for the business group.
 * @param p_per_comments Comments for the person record.
 * @param p_date_employee_data_verified The date on which the employee last
 * verified the data.
 * @param p_date_of_birth Employee's date of birth.
 * @param p_email_address Employee's email address.
 * @param p_employee_number Employee number. If the number generation method is
 * manual, then this parameter is mandatory. If the number generation method is
 * automatic, then the value of this parameter must be NULL. If p_validate is
 * false and the employee number generation method is automatic, then this
 * parameter is set to the employee number generated for the person created. If
 * p_validate is false and the employee number generation method is manual,
 * then this parameter is set to the value passed in. If p_validate is true,
 * then this parameter is set to the value passed in.
 * @param p_expense_check_send_to_addres Type of mailing address. Valid values
 * are defined by the HOME_OFFICE lookup type.
 * @param p_first_name Employee's first name.
 * @param p_preferred_name Alternative name of the employee.
 * @param p_marital_status Employee's marital status. Valid values are defined
 * by the MAR_STATUS lookup type.
 * @param p_middle_names Employee's middle name(s).
 * @param p_nationality Employee's nationality. Valid values are defined by the
 * NATIONALITY lookup type.
 * @param p_pesel_number The National Polish Identifier of the employee. This
 * field is mandatory for a person of Polish nationality.
 * @param p_maiden_name Previous last name of the employee.
 * @param p_registered_disabled_flag Indicates whether the person is classified
 * as disabled. Valid values are defined by the REGISTERED_DISABLED lookup
 * type.
 * @param p_title Employee's title. Valid values are defined by the TITLE
 * lookup type.
 * @param p_vendor_id Unique identifier of supplier.
 * @param p_work_telephone Work telephone.
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
 * @param p_nip_number The National Polish Tax identifier of the employee.
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
 * @param p_date_of_death Employee's date of death.
 * @param p_background_check_status Y/N flag indicating whether a background
 * check has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_blood_type Employee's blood group. Valid values are defined by the
 * BLOOD_TYPE lookup type.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fast_path_employee This parameter is currently not supported.
 * @param p_fte_capacity Full-time or part-time availability for work.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office.
 * @param p_last_medical_test_by Name of the physician who performed the last
 * medical test.
 * @param p_last_medical_test_date Date of the last medical test.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Employee's office number.
 * @param p_on_military_service Y/N flag indicating whether the person is
 * employed in military service.
 * @param p_prefix Obsolete parameter, do not use.
 * @param p_projected_start_date This parameter is currently unsupported.
 * @param p_resume_exists Y/N flag indicating whether the employee's resume is
 * on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_second_passport_exists Y/N flag indicating whether the person has
 * multiple passports.
 * @param p_student_status Full-time or part-time student status. Valid values
 * are defined by the STUDENT_STATUS lookup type.
 * @param p_work_schedule Work schedule indicating which days the person works.
 * Valid values are defined by the WORK_SCHEDULE lookup type.
 * @param p_suffix Obsolete parameter, do not use.
 * @param p_benefit_group_id Identifier of the benefit group.
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
 * @param p_coord_ben_med_insr_crr_ident Identifier of the secondary medical
 * coverage insurance carrier.
 * @param p_coord_ben_med_cvg_strt_dt Secondary medical coverage effective
 * start date.
 * @param p_coord_ben_med_cvg_end_dt Secondary medical coverage effective end
 * date.
 * @param p_uses_tobacco_flag Tobacco type used by the employee. Valid values
 * are defined by the TOBACCO_USER lookup type.
 * @param p_dpdnt_adoption_date Date dependant was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependant is on
 * voluntary service.
 * @param p_original_date_of_hire Original hire date of the employee.
 * @param p_adjusted_svc_date Adjusted service date.
 * @param p_town_of_birth Employee's town or city of birth.
 * @param p_region_of_birth Geographical region of birth of the employee.
 * @param p_country_of_birth Employee's country of birth.
 * @param p_global_person_id Global identification number for the employee.
 * @param p_party_id Trading Community Architecture (TCA) party identifier.
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
 * @param p_per_effective_start_date If p_validate is false, then this will be
 * set to the effective start date of the person. If p_validate is true, then
 * this will be null.
 * @param p_per_effective_end_date If p_validate is false, then this will be
 * set to the effective end date of the person. If p_validate is true, then
 * this will be null.
 * @param p_full_name If p_validate is false, then this will be set to the full
 * name of the person. If p_validate is true, then this will be null.
 * @param p_per_comment_id If p_validate is false, then this will be set to the
 * id of the corresponding person comment row, if any comment text exists. If
 * p_validate is true, then this will be null.
 * @param p_assignment_sequence If p_validate is false, then this will be set
 * to the sequence number of the primary assignment. If p_validate is true,
 * then this will be null.
 * @param p_assignment_number If p_validate is false, then this will be set to
 * the assignment number of the primary assignment. If p_validate is true, then
 * this will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP, EMP_APL, EX_EMP, or EX_EMP_APL.
 * @rep:displayname Create Employee for Poland
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:scope public
 * @rep:lifecycle deprecated
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pl_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2
  ,p_preferred_name                in     varchar2 default null
  ,p_marital_status                in     varchar2
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2
  ,p_pesel_number                  in     varchar2 default null
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
  ,p_per_information16             in     varchar2 default null
  ,p_per_information17             in     varchar2 default null
  ,p_per_information18             in     varchar2 default null
  ,p_per_information19             in     varchar2 default null
  ,p_per_information20             in     varchar2 default null
  ,p_per_information21             in     varchar2 default null
  ,p_per_information22             in     varchar2 default null
  ,p_per_information23             in     varchar2 default null
  ,p_per_information24             in     varchar2 default null
  ,p_per_information25             in     varchar2 default null
  ,p_per_information26             in     varchar2 default null
  ,p_per_information27             in     varchar2 default null
  ,p_per_information28             in     varchar2 default null
  ,p_per_information29             in     varchar2 default null
  ,p_per_information30             in     varchar2 default null
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
  ,p_prefix                        in     varchar2 default null
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
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          in     varchar2 default null
  ,p_coord_ben_med_pl_name         in     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   in     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  in     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     in     date default null
  ,p_coord_ben_med_cvg_end_dt      in     date default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                 in      varchar2 default null
  ,p_region_of_birth               in      varchar2 default null
  ,p_country_of_birth              in      varchar2 default null
  ,p_global_person_id              in      varchar2 default null
  ,p_party_id                      in      number default null
  ,p_person_id                     out nocopy number
  ,p_assignment_id                 out nocopy number
  ,p_per_object_version_number     out nocopy number
  ,p_asg_object_version_number     out nocopy number
  ,p_per_effective_start_date      out nocopy date
  ,p_per_effective_end_date        out nocopy date
  ,p_full_name                     out nocopy varchar2
  ,p_per_comment_id                out nocopy number
  ,p_assignment_sequence           out nocopy number
  ,p_assignment_number             out nocopy varchar2
  ,p_name_combination_warning      out nocopy boolean
  ,p_assign_payroll_warning        out nocopy boolean
  ,p_orig_hire_warning             out nocopy boolean
   );
--

-- ----------------------------------------------------------------------------
-- |--------------------------< create_pl_employee >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new employee, including a default primary assignment and
 * a period of service for the employee.
 *
 * This API is effectively an alternative to the API create_employee. If
 * p_validate is set to false, an employee is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for the Poland legislation must already exist. Also, a
 * valid person_type_id, with a corresponding system type of EMP, must be
 * active and in the same business group as the employee being created.
 *
 * <p><b>Post Success</b><br>
 * The person, primary assignment, and period of service will have been
 * successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The person, primary assignment, or period of service will not be created,
 * and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date Employee's hire date, and thus the effective start date
 * of the primary assignment, and period of service.
 * @param p_business_group_id Employee's business group.
 * @param p_last_name Employee's last name.
 * @param p_sex Employee's gender.
 * @param p_person_type_id This is the identifier of the person type. If an
 * identification number is not specified, then the API uses the default EMP
 * type for the business group.
 * @param p_per_comments Comments for the person record.
 * @param p_date_employee_data_verified The date on which the employee last
 * verified the data.
 * @param p_date_of_birth Employee's date of birth.
 * @param p_email_address Employee's email address.
 * @param p_employee_number Employee number. If the number generation method is
 * manual, then this parameter is mandatory. If the number generation method is
 * automatic, then the value of this parameter must be NULL. If p_validate is
 * false and the employee number generation method is automatic, then this
 * parameter is set to the employee number generated for the person created. If
 * p_validate is false and the employee number generation method is manual,
 * then this parameter is set to the value passed in. If p_validate is true,
 * then this parameter is set to the value passed in.
 * @param p_expense_check_send_to_addres Type of mailing address. Valid values
 * are defined by the HOME_OFFICE lookup type.
 * @param p_first_name Employee's first name.
 * @param p_preferred_name Alternative name of the employee.
 * @param p_marital_status Employee's marital status. Valid values are defined
 * by the MAR_STATUS lookup type.
 * @param p_middle_names Employee's middle name(s).
 * @param p_nationality Employee's nationality. Valid values are defined by the
 * 'NATIONALITY' lookup type.
 * @param p_pesel The National Polish Identifier of the employee. This
 * field is mandatory for an employee whose citizenship and nationality are
 * both Polish.
 * @param p_maiden_name Previous last name of the employee.
 * @param p_registered_disabled_flag Indicates whether the person is classified
 * as disabled. Valid values are defined by the REGISTERED_DISABLED lookup
 * type.
 * @param p_title Employee's title. Valid values are defined by the TITLE
 * lookup type.
 * @param p_vendor_id Unique identifier of supplier.
 * @param p_work_telephone Work telephone.
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
 * @param p_nip Employee's national Polish tax identifier.If the employee's
 * nationality and citizenship are both Polish then the Polish tax identifier
 * is mandatory.
 * @param p_oldage_pension_rights This indicates whether the employee
 * has old age or pension rights.Valid values are defined by
 * the 'PL_OLDAGE_PENSION_RIGHTS' lookup type.
 * @param p_national_fund_of_health This indicates the national fund of health
 * to which the employee belongs.Valid values are defined by
 * the 'PL_NATIONAL_FUND_OF_HEALTH' lookup type.
 * @param p_tax_office Specifies the tax office of the employee.
 * @param p_legal_employer Specifies the legal employer of the employee.
 * @param p_citizenship This indicates the citizenship of the employee.
 * Valid values are defined by the 'PL_CITIZENSHIP' lookup type.
 * @param p_date_of_death Employee's date of death.
 * @param p_background_check_status Yes/No flag indicating whether a background
 * check has been performed.
 * @param p_background_date_check Date background check was performed.
 * @param p_blood_type Employee's blood group. Valid values are defined by the
 * BLOOD_TYPE lookup type.
 * @param p_correspondence_language Preferred language for correspondence.
 * @param p_fast_path_employee This parameter is currently not supported.
 * @param p_fte_capacity Full-time or part-time availability for work.
 * @param p_honors Honors or degrees awarded.
 * @param p_internal_location Internal location of office.
 * @param p_last_medical_test_by Name of the physician who performed the last
 * medical test.
 * @param p_last_medical_test_date Date of the last medical test.
 * @param p_mailstop Office identifier for internal mail.
 * @param p_office_number Employee's office number.
 * @param p_on_military_service Yes/No flag indicating whether the person is
 * employed in military service.
 * @param p_prefix Obsolete parameter, do not use.
 * @param p_projected_start_date This parameter is currently unsupported.
 * @param p_resume_exists Yes/No flag indicating whether the employee's resume is
 * on file.
 * @param p_resume_last_updated Date when the resume was last updated.
 * @param p_second_passport_exists Yes/No flag indicating whether the person has
 * multiple passports.
 * @param p_student_status Full-time or part-time student status. Valid values
 * are defined by the STUDENT_STATUS lookup type.
 * @param p_work_schedule Work schedule indicating which days the person works.
 * Valid values are defined by the WORK_SCHEDULE lookup type.
 * @param p_suffix Obsolete parameter, do not use.
 * @param p_benefit_group_id Identifier of the benefit group.
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
 * @param p_coord_ben_med_insr_crr_ident Identifier of the secondary medical
 * coverage insurance carrier.
 * @param p_coord_ben_med_cvg_strt_dt Secondary medical coverage effective
 * start date.
 * @param p_coord_ben_med_cvg_end_dt Secondary medical coverage effective end
 * date.
 * @param p_uses_tobacco_flag Tobacco type used by the employee. Valid values
 * are defined by the 'TOBACCO_USER' lookup type.
 * @param p_dpdnt_adoption_date Date dependant was adopted.
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the dependant is on
 * voluntary service.
 * @param p_original_date_of_hire Original hire date of the employee.
 * @param p_adjusted_svc_date Adjusted service date.
 * @param p_town_of_birth Employee's town or city of birth.
 * @param p_region_of_birth Geographical region of birth of the employee.
 * @param p_country_of_birth Employee's country of birth.
 * @param p_global_person_id Global identification number for the employee.
 * @param p_party_id Trading Community Architecture (TCA) party identifier.
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
 * @param p_per_effective_start_date If p_validate is false, then this will be
 * set to the effective start date of the person. If p_validate is true, then
 * this will be null.
 * @param p_per_effective_end_date If p_validate is false, then this will be
 * set to the effective end date of the person. If p_validate is true, then
 * this will be null.
 * @param p_full_name If p_validate is false, then this will be set to the full
 * name of the person. If p_validate is true, then this will be null.
 * @param p_per_comment_id If p_validate is false, then this will be set to the
 * id of the corresponding person comment row, if any comment text exists. If
 * p_validate is true, then this will be null.
 * @param p_assignment_sequence If p_validate is false, then this will be set
 * to the sequence number of the primary assignment. If p_validate is true,
 * then this will be null.
 * @param p_assignment_number If p_validate is false, then this will be set to
 * the assignment number of the primary assignment. If p_validate is true, then
 * this will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP, EMP_APL, EX_EMP, or EX_EMP_APL.
 * @rep:displayname Create Employee for Poland
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure create_pl_employee
  (p_validate                      in     boolean  default false
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               out    nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2
  ,p_preferred_name                in     varchar2 default null
  ,p_marital_status                in     varchar2
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2
  ,p_pesel                         in     varchar2 default null
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
  ,p_nip                           in     varchar2 default null
  ,p_oldage_pension_rights         in     varchar2 default null
  ,p_national_fund_of_health       in     varchar2
  ,p_tax_office                    in     varchar2 default null
  ,p_legal_employer                in     varchar2
  ,p_citizenship                   in     varchar2
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
  ,p_prefix                        in     varchar2 default null
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
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          in     varchar2 default null
  ,p_coord_ben_med_pl_name         in     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   in     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  in     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     in     date default null
  ,p_coord_ben_med_cvg_end_dt      in     date default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_party_id                      in     number default null
  ,p_person_id                     out nocopy number
  ,p_assignment_id                 out nocopy number
  ,p_per_object_version_number     out nocopy number
  ,p_asg_object_version_number     out nocopy number
  ,p_per_effective_start_date      out nocopy date
  ,p_per_effective_end_date        out nocopy date
  ,p_full_name                     out nocopy varchar2
  ,p_per_comment_id                out nocopy number
  ,p_assignment_sequence           out nocopy number
  ,p_assignment_number             out nocopy varchar2
  ,p_name_combination_warning      out nocopy boolean
  ,p_assign_payroll_warning        out nocopy boolean
  ,p_orig_hire_warning             out nocopy boolean
   );

END hr_pl_employee_api;

 

/
