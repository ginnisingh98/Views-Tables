--------------------------------------------------------
--  DDL for Package HR_CN_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CN_APPLICANT_API" AUTHID CURRENT_USER AS
/* $Header: hrcnwraa.pkh 120.3 2005/11/04 05:36:22 jcolman noship $ */
/*#
 * This package contains applicant API for China.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Applicant for China
*/
  g_trace boolean := FALSE;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_cn_applicant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new applicant for business groups using the legislation
 * for China.
 *
 * This API calls the generic create_applicant API.It maps certain columns to
 * user-friendly names appropriate for China so as to ensure easy
 * identification. As this API is an alternative API, see the generic
 * create_applicant API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A business group for the legislation in China must be present as on the
 * effective date. See the corresponding generic API for further details
 *
 * <p><b>Post Success</b><br>
 * The person, application, default applicant assignment and if required
 * associated assignment budget values and a letter request are created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the applicant and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received The applicant hire date and thus the effective start
 * date of the person, primary assignment and application.
 * @param p_business_group_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BUSINESS_GROUP_ID}
 * @param p_family_or_last_name {@rep:casecolumn PER_ALL_PEOPLE_F.LAST_NAME}
 * @param p_person_type_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_TYPE_ID}
 * @param p_applicant_number The business group's applicant number generation
 * method determines when the API derives and passes out an applicant number or
 * when the calling program should pass in a value. When the API call completes
 * if p_validate is false then it will be set to the generated applicant number
 * or passed value. If p_validate is true then it will be set to null.
 * @param p_per_comments Applicant Comment Text
 * @param p_date_employee_data_verified {@rep:casecolumn
 * PER_ALL_PEOPLE_F.DATE_EMPLOYEE_DATA_VERIFIED}
 * @param p_date_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_BIRTH}
 * @param p_email_address {@rep:casecolumn PER_ALL_PEOPLE_F.EMAIL_ADDRESS}
 * @param p_expense_check_send_to_addres Mailing address. Valid values are
 * defined by the 'HOME_OFFICE' lookup type.
 * @param p_given_or_first_name {@rep:casecolumn PER_ALL_PEOPLE_F.FIRST_NAME}
 * @param p_known_as {@rep:casecolumn PER_ALL_PEOPLE_F.KNOWN_AS}
 * @param p_marital_status Marital status. Valid values are defined by the
 * 'MAR_STATUS' lookup type.
 * @param p_middle_names {@rep:casecolumn PER_ALL_PEOPLE_F.MIDDLE_NAMES}
 * @param p_nationality Nationality. Valid values are defined by the
 * 'NATIONALITY' lookup type
 * @param p_citizen_identification_num {@rep:casecolumn
 * PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER}
 * @param p_previous_last_name {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PREVIOUS_LAST_NAME}
 * @param p_registered_disabled_flag Indicates whether the person is classified
 * as disabled. Valid values are defined by the 'REGISTERED_DISABLED' lookup
 * type.
 * @param p_sex Legal gender. Valid values are defined by the 'SEX' lookup
 * type.
 * @param p_title Title e.g. Mr, Mrs, Dr. Valid values are defined by the
 * 'TITLE' lookup type
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
 * number of children of the applicant. Valid values are whole numbers.
 * @param p_expatriate_indicator Expatriate Indicator. Valid values are defined
 * by the 'YES_NO' lookup type.
 * @param p_health_status Health status. Valid values are defined by the
 * 'CN_HEALTH_STATUS' lookup type.
 * @param p_tax_exemption_indicator Tax exemption indicator.Valid values are
 * defined by the 'YES_NO' lookup type.
 * @param p_percentage Tax exemption percentage. Determines the percentage of
 * Special Tax Exemption based on the Tax Exemption Indicator. If left blank
 * this defaults to a global value defined by MOLSS as per the current tax
 * regulations
 * @param p_family_han_yu_pin_yin_name Han Yu Pin Yin Last Name as specified on
 * the Passport for Chinese residents.
 * @param p_given_han_yu_pin_yin_name Han Yu Pin Yin First Name as specified on
 * the Passport for Chinese residents.
 * @param p_previous_name Previous Name of the Applicant in case of change in
 * name.
 * @param p_race_ethnic_orgin Race ethnic origin. Valid values are defined by
 * the 'CN_RACE' lookup type.
 * @param p_social_security_ic_number Social Security Identification Number.
 * @param p_background_check_status Background check status. Valid values are
 * defined by the 'YES_NO' lookup type.
 * @param p_background_date_check {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BACKGROUND_DATE_CHECK}
 * @param p_correspondence_language {@rep:casecolumn
 * PER_ALL_PEOPLE_F.CORRESPONDENCE_LANGUAGE}
 * @param p_fte_capacity {@rep:casecolumn PER_ALL_PEOPLE_F.FTE_CAPACITY}
 * @param p_hold_applicant_date_until {@rep:casecolumn
 * PER_ALL_PEOPLE_F.HOLD_APPLICANT_DATE_UNTIL}
 * @param p_honors {@rep:casecolumn PER_ALL_PEOPLE_F.HONORS}
 * @param p_mailstop {@rep:casecolumn PER_ALL_PEOPLE_F.MAILSTOP}
 * @param p_office_number {@rep:casecolumn PER_ALL_PEOPLE_F.OFFICE_NUMBER}
 * @param p_on_military_service Indicates if the applicant is on military
 * service. Valid values are defined by 'YES_NO' lookup type.
 * @param p_pre_name_adjunct Prefix for the applicant name
 * @param p_projected_start_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PROJECTED_START_DATE}
 * @param p_resume_exists Indicates if a resume for the applicant exists. Valid
 * values are defined by 'YES_NO' lookup type.
 * @param p_resume_last_updated {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RESUME_LAST_UPDATED}
 * @param p_student_status Indicates the student status of the applicant. Valid
 * values are defined by the 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule {@rep:casecolumn PER_ALL_PEOPLE_F.WORK_SCHEDULE}
 * @param p_suffix Suffix for the applicant name
 * @param p_date_of_death {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_DEATH}
 * @param p_benefit_group_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BENEFIT_GROUP_ID}
 * @param p_receipt_of_death_cert_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RECEIPT_OF_DEATH_CERT_DATE}
 * @param p_coord_ben_med_pln_no {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COORD_BEN_MED_PLN_NO}
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_uses_tobacco_flag Indicates if the applicant uses tabacco. Valid
 * values are defined by the 'YES_NO' lookup type.
 * @param p_dpdnt_adoption_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.DPDNT_ADOPTION_DATE}
 * @param p_dpdnt_vlntry_svce_flag Indicates if the applicant's dependent is in
 * voluntary service. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_original_date_of_hire {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE}
 * @param p_place_of_birth Indicates town of birth
 * @param p_original_hometown Indicates region of birth
 * @param p_country_of_birth Indicates the country of birth of applicant. Valid
 * values are defined by the view FND_TERRITORIES_VL
 * @param p_global_person_id Global Person Id
 * @param p_party_id Party for whom the address applies.
 * @param p_person_id f p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_application_id If p_validate is false, then this uniquely
 * identifies the created applicant. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_asg_object_version_number If p_validate is false, then this
 * parameter is set to the version number of the assignment created. If
 * p_validate is true, then this parameter is null.
 * @param p_apl_object_version_number If p_validate is false, then set to the
 * version number of the created applicant. If p_validate is true, then the
 * value will be null.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person. If p_validate is true,
 * then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false, this will be set to the
 * corresponding person comment row, if any comment text exists. If p_validate
 * is true this will be null.
 * @param p_assignment_sequence If p_validate is false, this will be set to the
 * sequence number of the default assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning If the original date of hire is not null and the
 * person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL, then this value is set
 * to true.
 * @rep:displayname Create Applicant for China
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_cn_applicant
  (p_validate                       in      boolean  default false
  ,p_date_received                  in      date
  ,p_business_group_id              in      number
  ,p_family_or_last_name            in      varchar2
  ,p_person_type_id                 in      number   default null
  ,p_applicant_number               in out  nocopy   varchar2
  ,p_per_comments                   in      varchar2 default null
  ,p_date_employee_data_verified    in      date     default null
  ,p_date_of_birth                  in      date     default null
  ,p_email_address                  in      varchar2 default null
  ,p_expense_check_send_to_addres   in      varchar2 default null
  ,p_given_or_first_name            in      varchar2 default null
  ,p_known_as                       in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
  ,p_middle_names                   in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_citizen_identification_num     in      varchar2 default null
  ,p_previous_last_name             in      varchar2 default null
  ,p_registered_disabled_flag       in      varchar2 default null
  ,p_sex                            in      varchar2 default null
  ,p_title                          in      varchar2 default null
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
  ,p_background_check_status        in      varchar2 default null
  ,p_background_date_check          in      date     default null
  ,p_correspondence_language        in      varchar2 default null
  ,p_fte_capacity                   in      number   default null
  ,p_hold_applicant_date_until      in      date     default null
  ,p_honors                         in      varchar2 default null
  ,p_mailstop                       in      varchar2 default null
  ,p_office_number                  in      varchar2 default null
  ,p_on_military_service            in      varchar2 default null
  ,p_pre_name_adjunct               in      varchar2 default null
  ,p_projected_start_date           in      date     default null
  ,p_resume_exists                  in      varchar2 default null
  ,p_resume_last_updated            in      date     default null
  ,p_student_status                 in      varchar2 default null
  ,p_work_schedule                  in      varchar2 default null
  ,p_suffix                         in      varchar2 default null
  ,p_date_of_death                  in      date     default null
  ,p_benefit_group_id               in      number   default null
  ,p_receipt_of_death_cert_date     in      date     default null
  ,p_coord_ben_med_pln_no           in      varchar2 default null
  ,p_coord_ben_no_cvg_flag          in      varchar2 default 'N'
  ,p_uses_tobacco_flag              in      varchar2 default null
  ,p_dpdnt_adoption_date            in      date     default null
  ,p_dpdnt_vlntry_svce_flag         in      varchar2 default 'N'
  ,p_original_date_of_hire          in      date     default null
  ,p_place_of_birth                 in      varchar2 default null
  ,p_original_hometown              in      varchar2 default null
  ,p_country_of_birth               in      varchar2 default null
  ,p_global_person_id               in      varchar2 default null
  ,p_party_id                       in      number   default null
--
  ,p_person_id                      out     nocopy   number
  ,p_assignment_id                  out     nocopy   number
  ,p_application_id                 out     nocopy   number
  ,p_per_object_version_number      out     nocopy   number
  ,p_asg_object_version_number      out     nocopy   number
  ,p_apl_object_version_number      out     nocopy   number
  ,p_per_effective_start_date       out     nocopy   date
  ,p_per_effective_end_date         out     nocopy   date
  ,p_full_name                      out     nocopy   varchar2
  ,p_per_comment_id                 out     nocopy   number
  ,p_assignment_sequence            out     nocopy   number
  ,p_name_combination_warning       out     nocopy   boolean
  ,p_orig_hire_warning              out     nocopy   boolean);
--
END hr_cn_applicant_api;

/
