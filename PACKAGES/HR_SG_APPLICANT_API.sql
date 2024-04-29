--------------------------------------------------------
--  DDL for Package HR_SG_APPLICANT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SG_APPLICANT_API" AUTHID CURRENT_USER as
/* $Header: hrsgwraa.pkh 120.8 2007/10/26 01:36:28 jalin ship $ */
/*#
 * This package contains Applicant related APIs for Singapore.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Applicant for Singapore
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_sg_applicant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates new applicant record for Singapore.
 *
 * This API calls the generic create_applicant API, with the parameters set as
 * appropriate for an applicant in SIngapore. As this API is effectively an
 * alternative to the API create_applicant, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A business group for Singapore legislation must be specified.
 *
 * <p><b>Post Success</b><br>
 * The API successfully inserts a person, primary assignment and application in
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the applicant, DEFAULT assignment or application and
 * raises the error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_date_received Indicates the applicant hire DATE and thus the
 * effective start DATE of the person, primary assignment and application.
 * @param p_business_group_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BUSINESS_GROUP_ID}
 * @param p_last_name {@rep:casecolumn PER_ALL_PEOPLE_F.LAST_NAME}
 * @param p_person_type_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_TYPE_ID}
 * @param p_applicant_number If the number generation method is Manual, then
 * this parameter is mandatory. If the number generation method is Automatic,
 * then the value of this parameter must be NULL. When the API completes, if
 * p_validate is false and the applicant number generation method is Automatic,
 * then set the applicant number to the generated applicant number of the
 * person created. If p_validate is false and the applicant number generation
 * method is manual or if p_validate is true, then set the applicant number to
 * the same value that was passed.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified {@rep:casecolumn
 * PER_ALL_PEOPLE_F.DATE_EMPLOYEE_DATA_VERIFIED}
 * @param p_date_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_BIRTH}
 * @param p_email_address {@rep:casecolumn PER_ALL_PEOPLE_F.EMAIL_ADDRESS}
 * @param p_expense_check_send_to_addres Indicates the Applicant's Address to
 * which the expense should be sent. Valid values are determined by
 * 'HOME_OFFICE' lookup type.
 * @param p_first_name {@rep:casecolumn PER_ALL_PEOPLE_F.FIRST_NAME}
 * @param p_known_as {@rep:casecolumn PER_ALL_PEOPLE_F.KNOWN_AS}
 * @param p_marital_status Indicates the Applicant's Marital status. Valid
 * values are defined by 'MAR_STATUS' lookup type.
 * @param p_middle_names {@rep:casecolumn PER_ALL_PEOPLE_F.MIDDLE_NAMES}
 * @param p_nationality Indicates the Applicant' s Nationality. Valid values
 * are defined by 'NATIONALITY' lookup type.
 * @param p_national_identifier {@rep:casecolumn
 * PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER}
 * @param p_previous_last_name {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PREVIOUS_LAST_NAME}
 * @param p_registered_disabled_flag Indicates whether an Applicant is
 * classified as disabled. Valid values are defined by 'REGISTERED_DISABLED'
 * lookup type.
 * @param p_sex Indicates the Applicant's Legal gender. Valid values are
 * defined by 'SEX' lookup type.
 * @param p_title Title e.g. Mr, Mrs, Dr. Valid values are defined by 'TITLE'
 * lookup type.
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
 * @param p_legal_name {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION1}
 * @param p_passport_number {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION2}
 * @param p_passport_country_of_issue {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PER_INFORMATION3}
 * @param p_passport_date_issued {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PER_INFORMATION4}
 * @param p_passport_expiry_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PER_INFORMATION5}
 * @param p_permit_type {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION6}
 * @param p_permit_number {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION7}
 * @param p_permit_category {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION8}
 * @param p_permit_date_issued {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PER_INFORMATION9}
 * @param p_permit_expiry_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PER_INFORMATION10}
 * @param p_permit_date_cancelled {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PER_INFORMATION11}
 * @param p_income_tax_number {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PER_INFORMATION12}
 * @param p_income_tax_number_spouse {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PER_INFORMATION13}
 * @param p_cpf_account_number {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PER_INFORMATION14}
 * @param p_nric_colour {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION15}
 * @param p_religion {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION16}
 * @param p_cpf_category {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION17}
 * @param p_race {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION18}
 * @param p_community_fund_category {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PER_INFORMATION19}
 * @param p_background_check_status Background check status. Valid values are
 * defined by 'YES_NO' lookup type.
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
 * @param p_on_military_service Indicates whether the applicant was in the
 * military service. Valid values as applicable are defined by 'YES_NO' lookup
 * type.
 * @param p_pre_name_adjunct {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PRE_NAME_ADJUNCT}
 * @param p_projected_start_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PROJECTED_START_DATE}
 * @param p_resume_exists Indicates whether the Applicant's Resume alreay
 * exists in the database. Valid values as applicable are defined by 'YES_NO'
 * lookup type.
 * @param p_resume_last_updated {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RESUME_LAST_UPDATED}
 * @param p_student_status {@rep:casecolumn PER_ALL_PEOPLE_F.STUDENT_STATUS}
 * @param p_work_schedule Indicates the Applicant's Work schedule. Valid values
 * are defined by 'WORK_SCHEDULE' lookup type.
 * @param p_suffix {@rep:casecolumn PER_ALL_PEOPLE_F.SUFFIX}
 * @param p_date_of_death {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_DEATH}
 * @param p_benefit_group_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BENEFIT_GROUP_ID}
 * @param p_receipt_of_death_cert_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RECEIPT_OF_DEATH_CERT_DATE}
 * @param p_coord_ben_med_pln_no {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COORD_BEN_MED_PLN_NO}
 * @param p_coord_ben_no_cvg_flag Indicates whether the Applicant has any
 * coverage other than the Coordination of benefits. Valid values as applicable
 * are defined by 'YES_NO' lookup type.
 * @param p_uses_tobacco_flag Indicates whether the Applicant uses tabacco.
 * Valid values as applicable are defined by 'YES_NO' lookup type.
 * @param p_dpdnt_adoption_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.DPDNT_ADOPTION_DATE}
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the applicant was in the
 * dependent voluntary service. Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_original_date_of_hire {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE}
 * @param p_town_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.TOWN_OF_BIRTH}
 * @param p_region_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.REGION_OF_BIRTH}
 * @param p_country_of_birth {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COUNTRY_OF_BIRTH}
 * @param p_global_person_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.GLOBAL_PERSON_ID}
 * @param p_party_id {@rep:casecolumn PER_ALL_PEOPLE_F.PARTY_ID}
 * @param p_vacancy_id Identifies the vacancy for which the person has applied.
 * @param p_payee_id_type {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION23}
 * @param p_ee_er_rate {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION20}
 * @param p_mbf {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION21}
 * @param p_mdk {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION22}
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_application_id If p_validate is FALSE, this uniquely identifies the
 * application created. If p_validate is true this parameter will be NULL.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_asg_object_version_number If p_validate is false, then set to the
 * version number of the created assignment. If p_validate is true, then the
 * value will be null.
 * @param p_apl_object_version_number If p_validate is false, this will be set
 * to the version number of the application created. If p_validate is true this
 * parameter will be set to null.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_full_name If p_validate is false, then set to the full name of the
 * person. If p_validate is true, then set to null.
 * @param p_per_comment_id If p_validate is false and new or existing comment
 * text exists, then will be set to the identifier of the applicant comment
 * record. If p_validate is true or no comment text exists, then will be null.
 * @param p_assignment_sequence If p_validate is false, this will be set to the
 * sequence number of the default assignment. If p_validate is true this will
 * be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning If p_validate is false, the original date of hire
 * is provided and the person type is not
 * Employee,Employee-Applicant,Ex-Employee or Ex-Employee Applicant, then set
 * to true.
 * @rep:displayname Create Applicant for Singapore
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  PROCEDURE create_sg_applicant
  (p_validate                      in     boolean  default false
  ,p_date_received                 in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_applicant_number              in out nocopy varchar2
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_sex                           in     varchar2 default null
  ,p_title                         in     varchar2 default null
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
  ,p_legal_name                    in     varchar2 default null
  ,p_passport_number               in     varchar2 default null
  ,p_passport_country_of_issue     in     varchar2 default null
  ,p_passport_date_issued          in     date     default null
  ,p_passport_expiry_date          in     date     default null
  ,p_permit_type                   in     varchar2 default null
  ,p_permit_number                 in     varchar2 default null
  ,p_permit_category               in     varchar2 default null
  ,p_permit_date_issued            in     date     default null
  ,p_permit_expiry_date            in     date     default null
  ,p_permit_date_cancelled         in     date     default null
  ,p_income_tax_number             in     varchar2 default null
  ,p_income_tax_number_spouse      in     varchar2 default null
  ,p_cpf_account_number            in     varchar2 default null
  ,p_nric_colour                   in     varchar2 default null
  ,p_religion                      in     varchar2 default null
  ,p_cpf_category                  in     varchar2 default null
  ,p_race                          in     varchar2 default null
  ,p_community_fund_category       in     varchar2 default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_honors                        in     varchar2 default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_party_id                      in     number   default null/* 6393528 */
  ,p_vacancy_id                    in     number   default null/* 6393528 */
  ,p_payee_id_type                 in     varchar2 default null
  ,p_ee_er_rate                    in     varchar2 default null/* 6393528 */
  ,p_mbf                           in     varchar2 default null/* 6393528,6526444 */
  ,p_mdk                           in     varchar2 default null/* 6393528,6526444 */
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_application_id                   out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean);

end hr_sg_applicant_api;

/
