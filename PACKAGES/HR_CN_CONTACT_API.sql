--------------------------------------------------------
--  DDL for Package HR_CN_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CN_CONTACT_API" AUTHID CURRENT_USER AS
/* $Header: hrcnwrcc.pkh 120.3 2005/11/04 05:36:51 jcolman noship $ */
/*#
 * This package contains the contact APIs for China.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Personal Contact for China
*/
  g_trace boolean := FALSE;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_cn_person >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a person for business groups using the legislation for
 * China.
 *
 * This API calls the generic create_person API. It maps certain columns to
 * user-friendly names appropriate for China so as to ensure easy
 * identification. As this API is an alternative API, see the generic
 * create_person API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A business group for the China legislation must be present as on the
 * effective date. See the corresponding generic API for further details.
 *
 * <p><b>Post Success</b><br>
 * The person will be created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the person and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date The date from which the person is assumed to be present
 * in the records.
 * @param p_business_group_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BUSINESS_GROUP_ID}
 * @param p_family_or_last_name {@rep:casecolumn PER_ALL_PEOPLE_F.LAST_NAME}
 * @param p_sex Legal gender. Valid values are defined by the 'SEX' lookup
 * type.
 * @param p_person_type_id {@rep:casecolumn PER_ALL_PEOPLE_F.PERSON_TYPE_ID}
 * @param p_comments Person comment text.
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
 * 'NATIONALITY' lookup type.
 * @param p_citizen_identification_num {@rep:casecolumn
 * PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER}
 * @param p_registered_disabled_flag This indicates whether the person is
 * classified as disabled. Valid values are defined by the
 * 'REGISTERED_DISABLED' lookup type.
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
 * @param p_previous_name Previous Name of the person in case of change in
 * name.
 * @param p_race_ethnic_orgin Race ethnic origin. Valid values are defined by
 * the 'CN_RACE' lookup type.
 * @param p_social_security_ic_number Social Security Identification Number.
 * @param p_correspondence_language {@rep:casecolumn
 * PER_ALL_PEOPLE_F.CORRESPONDENCE_LANGUAGE}
 * @param p_honors {@rep:casecolumn PER_ALL_PEOPLE_F.HONORS}
 * @param p_benefit_group_id {@rep:casecolumn
 * PER_ALL_PEOPLE_F.BENEFIT_GROUP_ID}
 * @param p_on_military_service Indicates if the person is on military service.
 * Valid values are defined by the 'YES_NO' lookup type.
 * @param p_student_status Indicates the student status of the applicant. Valid
 * values are defined by the 'STUDENT_STATUS' lookup type.
 * @param p_uses_tobacco_flag Indicates if the person uses tabacco. Valid
 * values are defined by the 'YES_NO' lookup type.
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag. Valid values are defined by 'YES_NO' lookup type.
 * @param p_pre_name_adjunct Prefix for the person name
 * @param p_suffix Suffix for the person name
 * @param p_place_of_birth Indicates town of birth
 * @param p_original_hometown Indicates region of birth
 * @param p_country_of_birth Indicates the country of birth of Person. Valid
 * values are defined by the view FND_TERRITORIES_VL
 * @param p_global_person_id Global Person Id
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Person. If p_validate is true, then the value
 * will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person. If p_validate is true,
 * then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created person comment record. If
 * p_validate is true or no comment text was provided, then will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning If p_validate is false, this will be set if an
 * warnings exists. If p_validate is true this will be null.
 * @rep:displayname Create Contact Person for China
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_CONTACT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_cn_person
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_family_or_last_name           in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_given_or_first_name           in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_citizen_identification_num    in     varchar2 default null
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
  ,p_hukou_type                    in     varchar2 default null
  ,p_hukou_location                in     varchar2 default null
  ,p_highest_education_level       in     varchar2 default null
  ,p_number_of_children            in     varchar2 default null
  ,p_expatriate_indicator          in     varchar2 default 'N'  -- Bug 2782045
  ,p_health_status                 in     varchar2 default null
  ,p_tax_exemption_indicator       in     varchar2 default null
  ,p_percentage                    in     varchar2 default null
  ,p_family_han_yu_pin_yin_name    in     varchar2 default null
  ,p_given_han_yu_pin_yin_name     in     varchar2 default null
  ,p_previous_name                 in     varchar2 default null
  ,p_race_ethnic_orgin             in     varchar2 default null
  ,p_social_security_ic_number     in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_honors                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_on_military_service           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_place_of_birth                in     varchar2 default null
  ,p_original_hometown             in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  --
  ,p_person_id                        out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_comment_id                       out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  );
--
END hr_cn_contact_api;

/
