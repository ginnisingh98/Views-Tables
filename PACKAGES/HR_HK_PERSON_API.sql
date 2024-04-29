--------------------------------------------------------
--  DDL for Package HR_HK_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HK_PERSON_API" AUTHID CURRENT_USER AS
/* $Header: hrhkwrpe.pkh 120.1 2005/10/02 02:02:40 aroussel $ */
/*#
 * This package contains API for updation of Person details.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person for Hong Kong
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_hk_person >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the person record for Hong Kong.
 *
 * The details of the person for whom the details have to be updated is
 * identified by using the person_id and object_version_number for the record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person record and object version number should already exist.
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
 * Person to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated Person . If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_person_type_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_TYPE_ID}
 * @param p_last_name {@rep:casecolumn PER_ALL_PEOPLE_F.LAST_NAME}
 * @param p_applicant_number {@rep:casecolumn
 * PER_ALL_PEOPLE_F.APPLICANT_NUMBER}
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified {@rep:casecolumn
 * PER_ALL_PEOPLE_F.DATE_EMPLOYEE_DATA_VERIFIED}
 * @param p_date_of_birth {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_BIRTH}
 * @param p_email_address {@rep:casecolumn PER_ALL_PEOPLE_F.EMAIL_ADDRESS}
 * @param p_employee_number The business group's employee number generation
 * method determines when you can update the employee value. To keep the
 * existing employee number pass in hr_api.g_varchar2. When the API call
 * completes if p_validate is false >then will be set to the employee number.
 * If p_validate is true then will be set to the passed value.
 * @param p_expense_check_send_to_addres Person's Address to which the expense
 * should be sent. Valid values are determined by 'HOME_OFFICE' lookup type.
 * @param p_first_name {@rep:casecolumn PER_ALL_PEOPLE_F.FIRST_NAME}
 * @param p_known_as {@rep:casecolumn PER_ALL_PEOPLE_F.KNOWN_AS}
 * @param p_marital_status Indicates the Person's Marital status. Valid values
 * are defined by 'MAR_STATUS' lookup type.
 * @param p_middle_names {@rep:casecolumn PER_ALL_PEOPLE_F.MIDDLE_NAMES}
 * @param p_nationality Indicates the Person's Nationality. Valid values are
 * defined by 'NATIONALITY' lookup type.
 * @param p_hkid_number {@rep:casecolumn PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER}
 * @param p_previous_last_name {@rep:casecolumn
 * PER_ALL_PEOPLE_F.PREVIOUS_LAST_NAME}
 * @param p_registered_disabled_flag Indicates whether person is classified as
 * disabled. Valid values are defined by 'REGISTERED_DISABLED' lookup type.
 * @param p_sex Indicates the Person's Legal gender. Valid values are defined
 * by 'SEX' lookup type.
 * @param p_title Person's Title e.g. Mr, Mrs, Dr. Valid values are defined by
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
 * @param p_passport_number identifies the person with the passport number.
 * @param p_country_of_issue Indicates the country where Passport was issued.
 * @param p_work_permit_number Identifies the person by the work permit number
 * @param p_work_permit_expiry_date Indicates the Person's work permit expiry
 * date
 * @param p_chinese_name Indicates the person's name in Chinese.
 * @param p_hk_full_name Indicates the person's Full Name from Hong Kong ID
 * Card or Passport.
 * @param p_previous_employer_name Indicates the Name of Previous Employer.
 * @param p_previous_employer_address Indicates the Address of Previous
 * Employer.
 * @param p_employee_tax_file_number Indicates the person's Tax File Number.
 * @param p_date_of_death {@rep:casecolumn PER_ALL_PEOPLE_F.DATE_OF_DEATH}
 * @param p_background_check_status Indicates the Background check status of
 * the person. Valid values as applicable are defined by 'YES_NO' lookup type.
 * @param p_background_date_check {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BACKGROUND_DATE_CHECK}
 * @param p_blood_type Identifies the person's Blood Group. Valid values are
 * defined by 'BLOOD_TYPE' lookup type.
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
 * @param p_rehire_recommendation Indicates the person's Re-hire recommendation
 * details. Valid values as applicable are defined by 'YES_NO' lookup type.
 * @param p_resume_exists Indicates whether the person's Resume already exists
 * in the database. Valid values as applicable are defined by 'YES_NO' lookup
 * type.
 * @param p_resume_last_updated {@rep:casecolumn
 * PER_ALL_PEOPLE_F.RESUME_LAST_UPDATED}
 * @param p_second_passport_exists Indicates the availability of the Person's
 * Second passport. Valid values as applicable are defined by 'YES_NO' lookup
 * type.
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
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated Person row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created Person. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, set to the complete full name of
 * the person. If p_validate is true, set to null.
 * @param p_comment_id If p_validate is false and new or existing comment text
 * exists, then will be set to the identifier of the Person comment record. If
 * p_validate is true or no comment text exists, then will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_assign_payroll_warning If set to true, then the date of birth is
 * not entered. If set to false, then the date of birth has been entered.
 * Indicates if it will be possible to set the payroll on any of this person's
 * assignments.
 * @param p_orig_hire_warning If p_validate is false, the original date of hire
 * is provided and the person type is not
 * Employee,Employee-Applicant,Ex-Employee or Ex-Employee Applicant, then set
 * to true.
 * @rep:displayname Update Person for Hong Kong
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_hk_person
  (p_validate                     IN      BOOLEAN   DEFAULT FALSE
  ,p_effective_date               IN      DATE
  ,p_datetrack_update_mode        IN      VARCHAR2
  ,p_person_id                    IN      NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_person_type_id               IN      NUMBER   DEFAULT hr_api.g_number
  ,p_last_name                    IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_applicant_number             IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_comments                     IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_date_employee_data_verified  IN      DATE     DEFAULT hr_api.g_date
  ,p_date_of_birth                IN      DATE     DEFAULT hr_api.g_date
  ,p_email_address                IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_employee_number              IN OUT NOCOPY VARCHAR2
  ,p_expense_check_send_to_addres IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_first_name                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_known_as                     IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_marital_status               IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_middle_names                 IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_nationality                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_hkid_number                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_previous_last_name           IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_registered_disabled_flag     IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_sex                          IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_title                        IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_vendor_id                    IN      NUMBER   DEFAULT hr_api.g_number
  ,p_work_telephone               IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute_category           IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute1                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute2                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute3                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute4                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute5                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute6                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute7                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute8                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute9                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute10                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute11                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute12                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute13                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute14                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute15                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute16                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute17                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute18                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute19                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute20                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute21                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute22                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute23                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute24                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute25                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute26                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute27                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute28                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute29                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute30                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_passport_number              IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_country_of_issue             IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_work_permit_number           IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_work_permit_expiry_date      IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_chinese_name                 IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_hk_full_name                 IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_previous_employer_name       IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_previous_employer_address    IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_employee_tax_file_number       IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_date_of_death                IN      DATE     DEFAULT hr_api.g_date
  ,p_background_check_status      IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_background_date_check        IN      DATE     DEFAULT hr_api.g_date
  ,p_blood_type                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_correspondence_language      IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_fast_path_employee           IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_fte_capacity                 IN      NUMBER   DEFAULT hr_api.g_number
  ,p_hold_applicant_date_until    IN      DATE     DEFAULT hr_api.g_date
  ,p_honors                       IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_internal_location            IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_last_medical_test_by         IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_last_medical_test_date       IN      DATE     DEFAULT hr_api.g_date
  ,p_mailstop                     IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_office_number                IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_on_military_service          IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_pre_name_adjunct             IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_projected_start_date         IN      DATE     DEFAULT hr_api.g_date
  ,p_rehire_authorizor            IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_rehire_recommendation        IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_resume_exists                IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_resume_last_updated          IN      DATE     DEFAULT hr_api.g_date
  ,p_second_passport_exists       IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_student_status               IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_work_schedule                IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_rehire_reason                IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_suffix                       IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_adjusted_svc_date            in      date     default hr_api.g_date
  ,p_effective_start_date         OUT NOCOPY DATE
  ,p_effective_end_date           OUT NOCOPY DATE
  ,p_full_name                    OUT NOCOPY VARCHAR2
  ,p_comment_id                   OUT NOCOPY NUMBER
  ,p_name_combination_warning     OUT NOCOPY BOOLEAN
  ,p_assign_payroll_warning       OUT NOCOPY BOOLEAN
  ,p_orig_hire_warning            OUT NOCOPY BOOLEAN
  );

--
END hr_hk_person_api;

 

/
