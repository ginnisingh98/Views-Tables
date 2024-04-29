--------------------------------------------------------
--  DDL for Package HR_PL_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PL_CONTACT_API" AUTHID CURRENT_USER as
/* $Header: peconpli.pkh 120.4 2005/11/30 05:28:16 mseshadr noship $ */
/*#
 * This package contains contact APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contact for Poland
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_pl_person >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The following procedure(older version) creates a Polish contact.
 *
 * This API is an alternative to the API create_person. If p_validate is set to
 * false, a person of type 'OTHER' is created. No information is stored in any
 * other tables.
 *
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
 * The business group for Poland legislation must already exist. Also a valid
 * person_type_id, with a corresponding system type of 'OTHER', must be active
 * and in the same business group as that of the person being created.
 *
 * <p><b>Post Success</b><br>
 * The contact person will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The contact person will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date The effective start date of the person.
 * @param p_business_group_id The person's business group.
 * @param p_last_name Person's last name.
 * @param p_sex Person's gender.
 * @param p_person_type_id This is the identifier corrresponding to the type of
 * person. If an identification number is not specified, then the API will use
 * the default 'OTHER' type for the business group.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified Date when the contact last verified the
 * data.
 * @param p_date_of_birth Date of birth of the contact. Also if the contact
 * person is Insured by an Employee, then the date of birth is mandatory.
 * @param p_email_address Email address of the contact.
 * @param p_expense_check_send_to_addres Address to use as mailing address.
 * @param p_first_name Person's first name.
 * @param p_known_as Preferred name, if different from first name.
 * @param p_marital_status Marital status of the person.
 * @param p_middle_names Person's middle name(s).
 * @param p_nationality Person's nationality.
 * @param p_inn National identifier of the contact. If the contact person of
 * nationality 'Polish' is Insured by an Employee, then a PESEL value is
 * mandatory.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Flag indicating whether person is
 * classified as disabled.
 * @param p_title Person's title. Valid values are defined by 'TITLE' lookup
 * type.
 * @param p_vendor_id Identification for information about suppliers.
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
 * @param nip The National Polish Tax identifier of the contact. Also if the
 * contact person is an 'Inheritor', then the Polish Tax identifier is
 * mandatory for the contact person.
 * @param insured_by_employee Indicates if the contact person is insured by
 * employee (health insurance). Valid values are defined by 'YES_NO' lookup
 * type.
 * @param inheritor Indicates if the contact person is an inheritor. Valid
 * values are defined by 'YES_NO' lookup type.
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
 * @param p_correspondence_language Preferred language for correspondance.
 * @param p_honors Honors or degrees awarded.
 * @param p_benefit_group_id Identification for benefit group.
 * @param p_on_military_service Type of military service.
 * @param p_student_status Type of student status.
 * @param p_uses_tobacco_flag Tobacoo type used by the contact. Valid values
 * are defined by 'TOBACCO_USER' lookup type.
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag.
 * @param p_pre_name_adjunct Name prefix.
 * @param p_suffix Obsolete parameter, do not use.
 * @param p_town_of_birth Town or city of birth of the contact.
 * @param p_region_of_birth Geographical region of birth of the contact.
 * @param p_country_of_birth Country of birth of the contact.
 * @param p_global_person_id Global Identification number for the person.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created contact. If p_validate is true, then the value
 * will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created contact. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created contact. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created contact comment record. If
 * p_validate is true or no comment text was provided, then will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the person type is not EMP,
 * EMP_APL, EX_EMP or EX_EMP_APL and the original_date_of_hire is not null.
 * @rep:displayname Create Contact for Poland
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_CONTACT
 * @rep:lifecycle deprecated
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pl_person
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
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
  ,p_per_information_category      in     varchar2 default null
  ,NIP	                           in     varchar2 default null
  ,Insured_by_Employee             in     varchar2 default null
  ,Inheritor                       in     varchar2 default null
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
  ,p_correspondence_language       in     varchar2 default null
  ,p_honors                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_on_military_service           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_person_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_comment_id                       out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  );

--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_pl_person  >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * The following procedure creates a Polish contact.
 *
 * This API is an alternative to the API create_person. If p_validate is set to
 * false, a person of type 'OTHER' is created. No information is stored in any
 * other tables.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for Poland legislation must already exist. Also a valid
 * person_type_id, with a corresponding system type of 'OTHER', must be active
 * and in the same business group as that of the person being created.
 *
 * <p><b>Post Success</b><br>
 * The contact person will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The contact person will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date The effective start date of the person.
 * @param p_business_group_id The person's business group.
 * @param p_last_name Person's last name.
 * @param p_sex Person's gender.
 * @param p_person_type_id This is the identifier corrresponding to the type of
 * person. If an identification number is not specified, then the API will use
 * the default 'OTHER' type for the business group.
 * @param p_comments Comment text.
 * @param p_date_employee_data_verified Date when the contact last verified the
 * data.
 * @param p_date_of_birth Date of birth of the contact. Also if the contact
 * person is Insured by an Employee, then the date of birth is mandatory.
 * @param p_email_address Email address of the contact.
 * @param p_expense_check_send_to_addres Address to use as mailing address.
 * @param p_first_name Person's first name.
 * @param p_known_as Preferred name, if different from first name.
 * @param p_marital_status Marital status of the person.
 * @param p_middle_names Person's middle name(s).
 * @param p_nationality Person's nationality.
 * @param p_pesel Contact's national identifier.If a contact's
 * nationality and citizenship are both  Polish
 * and is insured by an employee, then PESEL or NIP has to be specified.
 * @param p_previous_last_name Previous last name.
 * @param p_registered_disabled_flag Flag indicating whether person is
 * classified as disabled.
 * @param p_title Person's title. Valid values are defined by 'TITLE' lookup
 * type.
 * @param p_vendor_id Identification for information about suppliers.
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
 * @param p_nip Contact's national Polish tax identifier. If the contact is an
 * inheritor and nationality and citizenship are both Polish
 * then the Polish tax identifier is mandatory.
 * @param p_insured_by_employee Indicates if the contact is insured by the
 * employee (health insurance). The lookup type 'YES_NO' defines the valid
 * values.
 * @param p_inheritor Indicates if the contact is an inheritor. The lookup type
 * 'YES_NO' defines the valid values.
 * @param p_oldage_pension_rights This indicates whether the contact
 * has old age or pension rights.The lookup type 'PL_OLDAGE_PENSION_RIGHTS'
 * defines the valid values for the Polish legislation.
 * @param p_national_fund_of_health This indicates the national fund of health
 * to which the contact belongs.The lookup type 'PL_NATIONAL_FUND_OF_HEALTH'
 * defines the valid values for the Polish legislation.
 * @param p_tax_office Specifies the tax office of the contact.
 * @param p_legal_employer Specifies the legal employer of the contact.
 * @param p_citizenship This indicates the citizenship of the contact.
 * The lookup type 'PL_CITIZENSHIP' defines the valid values for the
 * Polish legislation.
 * @param p_correspondence_language Preferred language for correspondance.
 * @param p_honors Honors or degrees awarded.
 * @param p_benefit_group_id Identification for benefit group.
 * @param p_on_military_service Type of military service.
 * @param p_student_status Type of student status.
 * @param p_uses_tobacco_flag Tobacoo type used by the contact. Valid values
 * are defined by 'TOBACCO_USER' lookup type.
 * @param p_coord_ben_no_cvg_flag Coordination of benefits no other coverage
 * flag.
 * @param p_pre_name_adjunct Name prefix.
 * @param p_suffix Obsolete parameter, do not use.
 * @param p_town_of_birth Town or city of birth of the contact.
 * @param p_region_of_birth Geographical region of birth of the contact.
 * @param p_country_of_birth Country of birth of the contact.
 * @param p_global_person_id Global Identification number for the person.
 * @param p_person_id If p_validate is false, then this uniquely identifies the
 * person created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created contact. If p_validate is true, then the value
 * will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created contact. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created contact. If p_validate is true, then set
 * to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created contact comment record. If
 * p_validate is true or no comment text was provided, then will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the person type is not EMP,
 * EMP_APL, EX_EMP or EX_EMP_APL and the original_date_of_hire is not null.
 * @rep:displayname Create Contact for Poland
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_CONTACT
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
-- {End Of Comments}
--


procedure create_pl_person
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
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
  ,p_pesel                         in     varchar2 default null
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
  ,p_per_information_category      in     varchar2 default null
  ,p_nip                           in     varchar2 default null
  ,p_insured_by_employee           in     varchar2 default null
  ,p_inheritor                     in     varchar2 default null
  ,p_oldage_pension_rights         in     varchar2 default null
  ,p_national_fund_of_health       in     varchar2 default null
  ,p_tax_office                    in     varchar2 default null
  ,p_legal_employer                in     varchar2 default null
  ,p_citizenship                   in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_honors                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_on_military_service           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_person_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_comment_id                       out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  );

end hr_pl_contact_api;

 

/
