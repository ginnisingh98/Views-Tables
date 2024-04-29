--------------------------------------------------------
--  DDL for Package HR_CN_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CN_EMPLOYEE_API" AUTHID CURRENT_USER AS
/* $Header: hrcnwree.pkh 120.3 2005/11/04 05:36:16 jcolman noship $ */
/*#
 * This package contains employee APIs for China.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Employee for China
*/
  g_trace boolean := FALSE;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_cn_employee >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an employee for business groups using the legislation for
 * China.
 *
 * This API calls the generic create_employee API. It maps certain columns to
 * user-friendly names appropriate for China so as to ensure easy
 * identification. As this API is an alternative API, see the generic
 * create_employee API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A business group for the China legislation must be present as on the
 * effective date. See the corresponding generic API for further details.
 *
 * <p><b>Post Success</b><br>
 * The person, primary assignment and period of service will be created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the person and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_hire_date The date on which the employee is hired.
 * @param p_business_group_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BUSINESS_GROUP_ID}
 * @param p_family_or_last_name {@rep:casecolumn PER_ALL_PEOPLE_F.LAST_NAME}
 * @param p_sex Legal gender. Valid values are defined by the 'SEX' lookup
 * type.
 * @param p_person_type_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_TYPE_ID}
 * @param p_per_comments Employee comment text.
 * @param p_date_employee_data_verified {@rep:casecolumn
 * PER_ALL_PEOPLE_F.DATE_EMPLOYEE_DATA_VERIFIED}
 * @param p_date_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_BIRTH}
 * @param p_email_address {@rep:casecolumn PER_ALL_PEOPLE_F.EMAIL_ADDRESS}
 * @param p_employee_number The business group's employee number generation
 * method determines when the API derives and passes out an applicant number or
 * when the calling program should pass in a value. When the API call completes
 * if p_validate is false then this will be set to the generated employee
 * number or passed value. If p_validate is true then will be set to null.
 * @param p_expense_check_send_to_addres Address to which the expense should be
 * sent. Valid values are determined by the 'HOME_OFFICE' lookup type.
 * @param p_given_or_first_name {@rep:casecolumn PER_ALL_PEOPLE_F.FIRST_NAME}
 * @param p_known_as {@rep:casecolumn PER_ALL_PEOPLE_F.KNOWN_AS}
 * @param p_marital_status Marital status. Valid values are defined by the
 * 'MAR_STATUS' lookup type.
 * @param p_middle_names {@rep:casecolumn PER_ALL_PEOPLE_F.MIDDLE_NAMES}
 * @param p_nationality Nationality. Valid values are defined by the
 * 'NATIONALITY' lookup type.
 * @param p_citizen_identification_num {@rep:casecolumn
 * PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER}
 * @param p_previous_last_name {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PREVIOUS_LAST_NAME}
 * @param p_registered_disabled_flag Indicates whether the person is classified
 * as disabled. Valid values are defined by the 'REGISTERED_DISABLED' lookup
 * type.
 * @param p_title Title e.g. Mr, Mrs, Dr. Valid values are defined by the
 * 'TITLE' lookup type.
 * @param p_vendor_id {@rep:casecolumn PER_ALL_PEOPLE_F.VENDOR_ID}
 * @param p_work_telephone {@rep:casecolumn PER_ALL_PEOPLE_F.WORK_TELEPHONE}
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
 * @param p_hukou_type Hukou Type. Valid values are defined by the
 * 'CN_HUKOU_TYPE' lookup type.
 * @param p_hukou_location Hukou Location. Valid values are defined by the
 * 'CN_HUKOU_LOCN' lookup type.
 * @param p_highest_education_level Highest education level. Valid values are
 * defined by the 'CN_HIGH_EDU_LEVEL' lookup type.
 * @param p_number_of_children Number of children. This fields stores the
 * number of children of the person. Valid values are whole numbers.
 * @param p_expatriate_indicator Expatriate indicator. Valid values are defined
 * by the 'YES_NO' lookup type.
 * @param p_health_status Health status. Valid values are defined by the
 * 'CN_HEALTH_STATUS' lookup type.
 * @param p_tax_exemption_indicator Tax exempt indicator.Valid values are
 * defined by the 'YES_NO' lookup type.
 * @param p_percentage Tax exemption percentage. Determines the percentage of
 * Special Tax Exemption based on the Tax Exemption Indicator. If left blank
 * this defaults to a global value defined by MOLSS as per the current tax
 * regulations
 * @param p_family_han_yu_pin_yin_name Han Yu Pin Yin Last Name as specified on
 * the Passport for Chinese residents.
 * @param p_given_han_yu_pin_yin_name Han Yu Pin Yin First Name as specified on
 * the Passport for Chinese residents.
 * @param p_previous_name Previous Name of the applicant in case of a change in
 * name.
 * @param p_race_ethnic_orgin Race ethnic origin. Valid values are defined by
 * the 'CN_RACE' lookup type.
 * @param p_social_security_ic_number Social Security Identification Number.
 * @param p_date_of_death {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_DEATH}
 * @param p_background_check_status Background check status. Valid values are
 * defined by the 'YES_NO' lookup type.
 * @param p_background_date_check {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BACKGROUND_DATE_CHECK}
 * @param p_blood_type Indicates the blood type of the person. Valid values are
 * defined by the 'BLOOD_TYPE' lookup type.
 * @param p_correspondence_language {@rep:casecolumn
 * PER_ALL_PEOPLE_F.CORRESPONDENCE_LANGUAGE}
 * @param p_fast_path_employee {@rep:casecolumn
 * PER_ALL_PEOPLE_F.FAST_PATH_EMPLOYEE}
 * @param p_fte_capacity {@rep:casecolumn PER_ALL_PEOPLE_F.FTE_CAPACITY}
 * @param p_honors {@rep:casecolumn PER_ALL_PEOPLE_F.HONORS}
 * @param p_internal_location {@rep:casecolumn
 * PER_ALL_PEOPLE_F.INTERNAL_LOCATION}
 * @param p_last_medical_test_by {@rep:casecolumn
 * PER_ALL_PEOPLE_F.LAST_MEDICAL_TEST_BY}
 * @param p_last_medical_test_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.LAST_MEDICAL_TEST_DATE}
 * @param p_mailstop {@rep:casecolumn PER_ALL_PEOPLE_F.MAILSTOP}
 * @param p_office_number {@rep:casecolumn PER_ALL_PEOPLE_F.OFFICE_NUMBER}
 * @param p_on_military_service Indicates if the person is on military service.
 * Valid values are defined by the 'YES_NO' lookup type.
 * @param p_pre_name_adjunct Prefix for the employee name
 * @param p_projected_start_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PROJECTED_START_DATE}
 * @param p_resume_exists Indicates whether a resume for the person exists.
 * Valid values are defined by the 'YES_NO' lookup type.
 * @param p_resume_last_updated {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RESUME_LAST_UPDATED}
 * @param p_second_passport_exists Indicates if the person has a second
 * passport available. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_student_status Indicates the student status of the applicant. Valid
 * values are defined by the 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule Work schedule. Valid values are defined by the
 * 'WORK_SCHEDULE' lookup type.
 * @param p_suffix Suffix for the employee name
 * @param p_benefit_group_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BENEFIT_GROUP_ID}
 * @param p_receipt_of_death_cert_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RECEIPT_OF_DEATH_CERT_DATE}
 * @param p_coord_ben_med_pln_no {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COORD_BEN_MED_PLN_NO}
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag. Valid values are defined by 'YES_NO' lookup type.
 * @param p_coord_ben_med_ext_er {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COORD_BEN_MED_EXT_ER}
 * @param p_coord_ben_med_pl_name {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COORD_BEN_MED_PL_NAME}
 * @param p_coord_ben_med_insr_crr_name {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COORD_BEN_MED_INSR_CRR_NAME}
 * @param p_coord_ben_med_insr_crr_ident {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COORD_BEN_MED_INSR_CRR_IDENT}
 * @param p_coord_ben_med_cvg_strt_dt {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COORD_BEN_MED_CVG_STRT_DT}
 * @param p_coord_ben_med_cvg_end_dt {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COORD_BEN_MED_CVG_END_DT}
 * @param p_uses_tobacco_flag Indicates if the person uses tabacco. Valid
 * values are defined by the 'YES_NO' lookup type.
 * @param p_dpdnt_adoption_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.DPDNT_ADOPTION_DATE}
 * @param p_dpdnt_vlntry_svce_flag Indicates if the person's dependent is on
 * voluntary service. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_original_date_of_hire {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE}
 * @param p_adjusted_svc_date {@rep:casecolumn
 * PER_PERIODS_OF_SERVICE.ADJUSTED_SVC_DATE}
 * @param p_place_of_birth Indicates town of birth
 * @param p_original_hometown Indicates region of birth
 * @param p_country_of_birth Indicates the country of birth of Employee. Valid
 * values are defined by the view FND_TERRITORIES_VL
 * @param p_global_person_id Global Person Id
 * @param p_party_id Party for whom the address applies.
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
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created Employee. If p_validate is
 * true, then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date for the created Employee. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false, this will be set to the
 * comments for the person. If p_validate is true this will be null.
 * @param p_assignment_sequence If p_validate is false, this will be set to the
 * assignment sequence for the person. If p_validate is true this will be null.
 * @param p_assignment_number If p_validate is false, this will be set to the
 * assignment number of the person. If p_validate is true this will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning If p_validate is false, this will be set if an
 * warnings exists. If p_validate is true this will be null.
 * @rep:displayname Create Employee for China
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_cn_employee
  (p_validate                       in      boolean  default false
  ,p_hire_date                      in      date
  ,p_business_group_id              in      number
  ,p_family_or_last_name            in      varchar2
  ,p_sex                            in      varchar2
  ,p_person_type_id                 in      number   default null
  ,p_per_comments                   in      varchar2 default null
  ,p_date_employee_data_verified    in      date     default null
  ,p_date_of_birth                  in      date     default null
  ,p_email_address                  in      varchar2 default null
  ,p_employee_number                in out  nocopy varchar2
  ,p_expense_check_send_to_addres   in      varchar2 default null
  ,p_given_or_first_name            in      varchar2 default null
  ,p_known_as                       in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
  ,p_middle_names                   in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_citizen_identification_num     in      varchar2 default null
  ,p_previous_last_name             in      varchar2 default null
  ,p_registered_disabled_flag       in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_vendor_id                      in      number   default null
  ,p_work_telephone                 in      varchar2 default null
  ,p_attribute_category             in      varchar2 default null
  ,p_attribute1                     in      varchar2 default null
  ,p_attribute2                     in      varchar2 default null
  ,p_attribute3                     in      varchar2 default null
  ,p_attribute4                     in      varchar2 default null
  ,p_attribute5                     in      varchar2 default null
  ,p_attribute6                     in      varchar2 default null
  ,p_attribute7                     in      varchar2 default null
  ,p_attribute8                     in      varchar2 default null
  ,p_attribute9                     in      varchar2 default null
  ,p_attribute10                    in      varchar2 default null
  ,p_attribute11                    in      varchar2 default null
  ,p_attribute12                    in      varchar2 default null
  ,p_attribute13                    in      varchar2 default null
  ,p_attribute14                    in      varchar2 default null
  ,p_attribute15                    in      varchar2 default null
  ,p_attribute16                    in      varchar2 default null
  ,p_attribute17                    in      varchar2 default null
  ,p_attribute18                    in      varchar2 default null
  ,p_attribute19                    in      varchar2 default null
  ,p_attribute20                    in      varchar2 default null
  ,p_attribute21                    in      varchar2 default null
  ,p_attribute22                    in      varchar2 default null
  ,p_attribute23                    in      varchar2 default null
  ,p_attribute24                    in      varchar2 default null
  ,p_attribute25                    in      varchar2 default null
  ,p_attribute26                    in      varchar2 default null
  ,p_attribute27                    in      varchar2 default null
  ,p_attribute28                    in      varchar2 default null
  ,p_attribute29                    in      varchar2 default null
  ,p_attribute30                    in      varchar2 default null
  ,p_hukou_type                     in      varchar2
  ,p_hukou_location                 in      varchar2
  ,p_highest_education_level        in      varchar2 default null
  ,p_number_of_children             in      varchar2 default null
  ,p_expatriate_indicator           in      varchar2 default 'N'  -- Bug 2782045
  ,p_health_status                  in      varchar2 default null
  ,p_tax_exemption_indicator        in      varchar2 default null
  ,p_percentage                     in      varchar2 default null
  ,p_family_han_yu_pin_yin_name     in      varchar2 default null
  ,p_given_han_yu_pin_yin_name      in      varchar2 default null
  ,p_previous_name                  in      varchar2 default null
  ,p_race_ethnic_orgin              in      varchar2 default null
  ,p_social_security_ic_number      in      varchar2 default null
  ,p_date_of_death                  in      date     default null
  ,p_background_check_status        in      varchar2 default null
  ,p_background_date_check          in      date     default null
  ,p_blood_type                     in      varchar2 default null
  ,p_correspondence_language        in      varchar2 default null
  ,p_fast_path_employee             in      varchar2 default null
  ,p_fte_capacity                   in      number   default null
  ,p_honors                         in      varchar2 default null
  ,p_internal_location              in      varchar2 default null
  ,p_last_medical_test_by           in      varchar2 default null
  ,p_last_medical_test_date         in      date     default null
  ,p_mailstop                       in      varchar2 default null
  ,p_office_number                  in      varchar2 default null
  ,p_on_military_service            in      varchar2 default null
  ,p_pre_name_adjunct               in      varchar2 default null
  ,p_projected_start_date           in      date     default null
  ,p_resume_exists                  in      varchar2 default null
  ,p_resume_last_updated            in      date     default null
  ,p_second_passport_exists         in      varchar2 default null
  ,p_student_status                 in      varchar2 default null
  ,p_work_schedule                  in      varchar2 default null
  ,p_suffix                         in      varchar2 default null
  ,p_benefit_group_id               in      number   default null
  ,p_receipt_of_death_cert_date     in      date     default null
  ,p_coord_ben_med_pln_no           in      varchar2 default null
  ,p_coord_ben_no_cvg_flag          in      varchar2 default 'N'
  ,p_coord_ben_med_ext_er           in      varchar2 default null
  ,p_coord_ben_med_pl_name          in      varchar2 default null
  ,p_coord_ben_med_insr_crr_name    in      varchar2 default null
  ,p_coord_ben_med_insr_crr_ident   in      varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt      in      date     default null
  ,p_coord_ben_med_cvg_end_dt       in      date     default null
  ,p_uses_tobacco_flag              in      varchar2 default null
  ,p_dpdnt_adoption_date            in      date     default null
  ,p_dpdnt_vlntry_svce_flag         in      varchar2 default 'N'
  ,p_original_date_of_hire          in      date     default null
  ,p_adjusted_svc_date              in      date     default null
  ,p_place_of_birth                 in      varchar2 default null
  ,p_original_hometown              in      varchar2 default null
  ,p_country_of_birth               in      varchar2 default null
  ,p_global_person_id               in      varchar2 default null
  ,p_party_id                       in      number   default null
  ,p_person_id                      out     nocopy   number
  ,p_assignment_id                  out     nocopy   number
  ,p_per_object_version_number      out     nocopy   number
  ,p_asg_object_version_number      out     nocopy   number
  ,p_per_effective_start_date       out     nocopy   date
  ,p_per_effective_end_date         out     nocopy   date
  ,p_full_name                      out     nocopy   varchar2
  ,p_per_comment_id                 out     nocopy   number
  ,p_assignment_sequence            out     nocopy   number
  ,p_assignment_number              out     nocopy   varchar2
  ,p_name_combination_warning       out     nocopy   boolean
  ,p_assign_payroll_warning         out     nocopy   boolean
  ,p_orig_hire_warning              out     nocopy   boolean);
--

END hr_cn_employee_api;

/
