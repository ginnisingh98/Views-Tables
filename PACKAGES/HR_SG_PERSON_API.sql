--------------------------------------------------------
--  DDL for Package HR_SG_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SG_PERSON_API" AUTHID CURRENT_USER as
/* $Header: hrsgwrpe.pkh 120.4 2007/10/26 00:04:46 jalin ship $ */
/*#
 * This API updates the Person details.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person for Singapore
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_sg_person >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the person record for Singapore.
 *
 * This API updates the SG person record as identified by p_person_id and
 * p_object_version_number. Note: The business group must have the SG
 * legislation code. This API is an alternative to the update_person API. See
 * that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 *
 * This API is licensed for use with Human Resources.
 * <p><b>Prerequisites</b><br>
 * The person record, identified by p_person_id and p_object_version_number,
 * must already exist.
 *
 * <p><b>Post Success</b><br>
 * Successfully updates the details of the person.
 *
 * <p><b>Post Failure</b><br>
 * The API will not update the person and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_person_id Identifies the person record to modify.
 * @param p_object_version_number Pass in the current version number of the
 * person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated person. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_person_type_id Indicates the person's ID.
 * @param p_last_name Indicates the last name of the person.
 * @param p_applicant_number Indicates the applicant number of the person.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified Indicates the DATE on which the
 * employee data was last verified.
 * @param p_date_of_birth Indicates the date of birth of the person.
 * @param p_email_address Indicates the Email address of the person.
 * @param p_employee_number {@rep:casecolumn PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER}
 * @param p_expense_check_send_to_addres Indicates the mailing address of the
 * person.
 * @param p_first_name Indicates the first name of the person.
 * @param p_known_as Indicates what the person is also known as.
 * @param p_marital_status Indicates the marital status of the person. Valid
 * values are defined by the 'MAR_STATUS' lookup type.
 * @param p_middle_names Indicates the middle name of the person.
 * @param p_nationality Indicates the person's nationality. Valid values are
 * defined by the 'NATIONALITY' lookup type.
 * @param p_national_identifier Indicates the person's national identifier.
 * @param p_previous_last_name Indicates the person's previous last name.
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled.
 * @param p_sex Indicates the gender of the person. Valid values are
 * Male,Female,Unknown Gender.
 * @param p_title Indicates the person's title. Valid values are defined by the
 * 'TITLE' lookup type.
 * @param p_vendor_id Foreign key to PO_VENDORS
 * @param p_work_telephone Indicates the work telephone number of the person.
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
 * @param p_date_of_death {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_DEATH}
 * @param p_background_check_status Indicates the Background check status of
 * the person. Valid values as applicable are defined by 'YES_NO' lookup type.
 * @param p_background_date_check {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BACKGROUND_DATE_CHECK}
 * @param p_blood_type Blood Type. Valid values are defined by the 'BLOOD_TYPE'
 * lookup type.
 * @param p_correspondence_language {@rep:casecolumn
 * PER_ALL_PEOPLE_F.CORRESPONDENCE_LANGUAGE}
 * @param p_fast_path_employee {@rep:casecolumn
 * PER_ALL_PEOPLE_F.FAST_PATH_EMPLOYEE}
 * @param p_fte_capacity {@rep:casecolumn PER_ALL_PEOPLE_F.FTE_CAPACITY}
 * @param p_hold_applicant_date_until {@rep:casecolumn
 * PER_ALL_PEOPLE_F.HOLD_APPLICANT_DATE_UNTIL}
 * @param p_honors {@rep:casecolumn PER_ALL_PEOPLE_F.HONORS}
 * @param p_internal_location {@rep:casecolumn
 * PER_ALL_PEOPLE_F.INTERNAL_LOCATION}
 * @param p_last_medical_test_by {@rep:casecolumn
 * PER_ALL_PEOPLE_F.LAST_MEDICAL_TEST_BY}
 * @param p_last_medical_test_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.LAST_MEDICAL_TEST_DATE}
 * @param p_mailstop {@rep:casecolumn PER_ALL_PEOPLE_F.MAILSTOP}
 * @param p_office_number {@rep:casecolumn PER_ALL_PEOPLE_F.OFFICE_NUMBER}
 * @param p_on_military_service Indicates whether the person was in the
 * military service. Valid values as applicable are defined by 'YES_NO' lookup
 * type.
 * @param p_pre_name_adjunct {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PRE_NAME_ADJUNCT}
 * @param p_projected_start_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PROJECTED_START_DATE}
 * @param p_rehire_authorizor {@rep:casecolumn
 * PER_ALL_PEOPLE_F.REHIRE_AUTHORIZOR}
 * @param p_rehire_recommendation {@rep:casecolumn
 * PER_ALL_PEOPLE_F.REHIRE_RECOMMENDATION}
 * @param p_resume_exists {@rep:casecolumn PER_ALL_PEOPLE_F.RESUME_EXISTS}
 * @param p_resume_last_updated {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RESUME_LAST_UPDATED}
 * @param p_second_passport_exists Indicates whether the person's second
 * passport is available. Valid values are defined by 'YES_NO' lookup type.
 * @param p_student_status Student Status. Valid values are defined by the
 * 'STUDENT_STATUS' lookup type.
 * @param p_work_schedule Indicates the person's Work schedule. Valid values
 * are defined by 'WORK_SCHEDULE' lookup type.
 * @param p_rehire_reason {@rep:casecolumn PER_ALL_PEOPLE_F.REHIRE_REASON}
 * @param p_suffix {@rep:casecolumn PER_ALL_PEOPLE_F.SUFFIX}
 * @param p_benefit_group_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BENEFIT_GROUP_ID}
 * @param p_receipt_of_death_cert_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RECEIPT_OF_DEATH_CERT_DATE}
 * @param p_coord_ben_med_pln_no {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COORD_BEN_MED_PLN_NO}
 * @param p_coord_ben_no_cvg_flag Indicates whether the person has any coverage
 * other than the Coordination of benefits. Valid values as applicable are
 * defined by 'YES_NO' lookup type.
 * @param p_uses_tobacco_flag Indicates whether the person uses tabacco. Valid
 * values as applicable are defined by 'YES_NO' lookup type.
 * @param p_dpdnt_adoption_date {@rep:casecolumn
 * PER_ALL_PEOPLE_F.DPDNT_ADOPTION_DATE}
 * @param p_dpdnt_vlntry_svce_flag Indicates whether the person was in the
 * dependent voluntary service. Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_original_date_of_hire {@rep:casecolumn
 * PER_ALL_PEOPLE_F.ORIGINAL_DATE_OF_HIRE}
 * @param p_adjusted_svc_date {@rep:casecolumn
 * PER_PERIODS_OF_SERVICE.ADJUSTED_SVC_DATE}
 * @param p_town_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.TOWN_OF_BIRTH}
 * @param p_region_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.REGION_OF_BIRTH}
 * @param p_country_of_birth {@rep:casecolumn
 * PER_ALL_PEOPLE_F.COUNTRY_OF_BIRTH}
 * @param p_global_person_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.GLOBAL_PERSON_ID}
 * @param p_party_id TCA party for whom you are modifying the person record.
 * @param p_npw_number The business group's contingent worker number generation
 * method determines when the API derives and passes out a contingent worker
 * number or when the calling program should pass in a value. When the API call
 * completes if p_validate is true then will be set to the contingent worker
 * number. If p_validate is true then will be set to the passed value.
 * @param p_payee_id_type {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION23}
 * @param p_ee_er_rate {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION20}
 * @param p_mbf {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION21}
 * @param p_mdk {@rep:casecolumn PER_ALL_PEOPLE_F.PER_INFORMATION22}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_full_name If p_validate is false, then set to the full name of the
 * person. If p_validate is true, then set to null.
 * @param p_comment_id If p_validate is false and new or existing comment text
 * exists, then will be set to the identifier of the person comment record. If
 * p_validate is true or no comment text exists, then will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning If p_validate is false, this will be set if an
 * warnings exists. If p_validate is true this will be null.
 * @rep:displayname Update Person for Singapore
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_sg_person
    ( p_validate                      in     boolean  default false
     ,p_effective_date                in     date
     ,p_datetrack_update_mode         in     varchar2
     ,p_person_id                     in     number
     ,p_object_version_number         in out nocopy number
     ,p_person_type_id                in     number   default hr_api.g_number
     ,p_last_name                     in     varchar2 default hr_api.g_varchar2
     ,p_applicant_number              in     varchar2 default hr_api.g_varchar2
     ,p_comments                      in     varchar2 default hr_api.g_varchar2
     ,p_date_employee_data_verified   in     date     default hr_api.g_date
     ,p_date_of_birth                 in     date     default hr_api.g_date
     ,p_email_address                 in     varchar2 default hr_api.g_varchar2
     ,p_employee_number               in out nocopy varchar2
     ,p_expense_check_send_to_addres  in     varchar2 default hr_api.g_varchar2
     ,p_first_name                    in     varchar2 default hr_api.g_varchar2
     ,p_known_as                      in     varchar2 default hr_api.g_varchar2
     ,p_marital_status                in     varchar2 default hr_api.g_varchar2
     ,p_middle_names                  in     varchar2 default hr_api.g_varchar2
     ,p_nationality                   in     varchar2 default hr_api.g_varchar2
     ,p_national_identifier           in     varchar2 default hr_api.g_varchar2
     ,p_previous_last_name            in     varchar2 default hr_api.g_varchar2
     ,p_registered_disabled_flag      in     varchar2 default hr_api.g_varchar2
     ,p_sex                           in     varchar2 default hr_api.g_varchar2
     ,p_title                         in     varchar2 default hr_api.g_varchar2
     ,p_vendor_id                     in     number   default hr_api.g_number
     ,p_work_telephone                in     varchar2 default hr_api.g_varchar2
     ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
     ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
     ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
     ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
     ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
     ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
     ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
     ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
     ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
     ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
     ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
     ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
     ,p_legal_name                    in     varchar2 default hr_api.g_varchar2
     ,p_passport_number               in     varchar2 default hr_api.g_varchar2
     ,p_passport_country_of_issue     in     varchar2 default hr_api.g_varchar2
     ,p_passport_date_issued          in     date     default hr_api.g_date
     ,p_passport_expiry_date          in     date     default hr_api.g_date
     ,p_permit_type                   in     varchar2 default hr_api.g_varchar2
     ,p_permit_number                 in     varchar2 default hr_api.g_varchar2
     ,p_permit_category               in     varchar2 default hr_api.g_varchar2
     ,p_permit_date_issued            in     date     default hr_api.g_date
     ,p_permit_expiry_date            in     date     default hr_api.g_date
     ,p_permit_date_cancelled         in     date     default hr_api.g_date
     ,p_income_tax_number             in     varchar2 default hr_api.g_varchar2
     ,p_income_tax_number_spouse      in     varchar2 default hr_api.g_varchar2
     ,p_cpf_account_number            in     varchar2 default hr_api.g_varchar2
     ,p_nric_colour                   in     varchar2 default hr_api.g_varchar2
     ,p_religion                      in     varchar2 default hr_api.g_varchar2
     ,p_cpf_category                  in     varchar2 default hr_api.g_varchar2
     ,p_race                          in     varchar2 default hr_api.g_varchar2
     ,p_community_fund_category       in     varchar2 default hr_api.g_varchar2
     ,p_date_of_death                 in     date     default hr_api.g_date
     ,p_background_check_status       in     varchar2 default hr_api.g_varchar2
     ,p_background_date_check         in     date     default hr_api.g_date
     ,p_blood_type                    in     varchar2 default hr_api.g_varchar2
     ,p_correspondence_language       in     varchar2 default hr_api.g_varchar2
     ,p_fast_path_employee            in     varchar2 default hr_api.g_varchar2
     ,p_fte_capacity                  in     number   default hr_api.g_number
     ,p_hold_applicant_date_until     in     date     default hr_api.g_date
     ,p_honors                        in     varchar2 default hr_api.g_varchar2
     ,p_internal_location             in     varchar2 default hr_api.g_varchar2
     ,p_last_medical_test_by          in     varchar2 default hr_api.g_varchar2
     ,p_last_medical_test_date        in     date     default hr_api.g_date
     ,p_mailstop                      in     varchar2 default hr_api.g_varchar2
     ,p_office_number                 in     varchar2 default hr_api.g_varchar2
     ,p_on_military_service           in     varchar2 default hr_api.g_varchar2
     ,p_pre_name_adjunct              in     varchar2 default hr_api.g_varchar2
     ,p_projected_start_date          in     date     default hr_api.g_date
     ,p_rehire_authorizor             in     varchar2 default hr_api.g_varchar2
     ,p_rehire_recommendation         in     varchar2 default hr_api.g_varchar2
     ,p_resume_exists                 in     varchar2 default hr_api.g_varchar2
     ,p_resume_last_updated           in     date     default hr_api.g_date
     ,p_second_passport_exists        in     varchar2 default hr_api.g_varchar2
     ,p_student_status                in     varchar2 default hr_api.g_varchar2
     ,p_work_schedule                 in     varchar2 default hr_api.g_varchar2
     ,p_rehire_reason                 in     varchar2 default hr_api.g_varchar2
     ,p_suffix                        in     varchar2 default hr_api.g_varchar2
     ,p_benefit_group_id              in     number   default hr_api.g_number
     ,p_receipt_of_death_cert_date    in     date     default hr_api.g_date
     ,p_coord_ben_med_pln_no          in     number   default hr_api.g_number
     ,p_coord_ben_no_cvg_flag         in     varchar2 default hr_api.g_varchar2
     ,p_uses_tobacco_flag             in     varchar2 default hr_api.g_varchar2
     ,p_dpdnt_adoption_date           in     date     default hr_api.g_date
     ,p_dpdnt_vlntry_svce_flag        in     varchar2 default hr_api.g_varchar2
     ,p_original_date_of_hire         in     date     default hr_api.g_date
     ,p_adjusted_svc_date             in     date     default hr_api.g_date
     ,p_town_of_birth                 in     varchar2 default hr_api.g_varchar2
     ,p_region_of_birth               in     varchar2 default hr_api.g_varchar2
     ,p_country_of_birth              in     varchar2 default hr_api.g_varchar2
     ,p_global_person_id              in     varchar2 default hr_api.g_varchar2
     ,p_party_id                      in     number   default hr_api.g_number /* 6393528 */
     ,p_npw_number                    in      varchar2 default hr_api.g_varchar2 /* 6393528 */
     ,p_payee_id_type                 in     varchar2 default hr_api.g_varchar2 /* 6393528 */
     ,p_ee_er_rate                    in     varchar2 default hr_api.g_varchar2 /* 6393528 */
     ,p_mbf                           in     varchar2 default hr_api.g_varchar2 /* 6393528, 6526444 */
     ,p_mdk                           in     varchar2 default hr_api.g_varchar2 /* 6393528, 6526444 */
     ,p_effective_start_date          out    nocopy date
     ,p_effective_end_date            out    nocopy date
     ,p_full_name                     out    nocopy varchar2
     ,p_comment_id                    out    nocopy number
     ,p_name_combination_warning      out    nocopy boolean
     ,p_assign_payroll_warning        out    nocopy boolean
     ,p_orig_hire_warning             out    nocopy boolean);
--
end hr_sg_person_api;

/
