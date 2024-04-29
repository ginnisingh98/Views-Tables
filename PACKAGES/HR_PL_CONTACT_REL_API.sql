--------------------------------------------------------
--  DDL for Package HR_PL_CONTACT_REL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PL_CONTACT_REL_API" AUTHID CURRENT_USER as
-- $Header: pecrlpli.pkh 120.4 2005/12/06 21:25:08 psingla noship $  */
/*#
 * This package contains contact relationship APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contact Relationship for Poland
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_pl_contact >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API(older version) creates a new Polish contact relationship.
 *
 * The API is effectively an alternative to the API hr_contact_rel_api. If
 * p_validate is set to false, a contact relationship is created.
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
 * The business group for Poland legislation must already exist. A valid
 * person_type_id with a corresponding system type of 'CONTACT', must be active
 * and in the same business group as that of the contact being created.
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates a contact relationship into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a contact relationship and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date The effective start date of the contact person.
 * @param p_business_group_id Identifies the contact person's business group.
 * @param p_person_id Identifies the person for whom you create the contact
 * relationship record.
 * @param p_contact_person_id Identifies the contact person for whom you create
 * the contact relationship record.
 * @param p_contact_type Identifies the contact type. The lookup type 'CONTACT'
 * defines the valid values.
 * @param p_ctr_comments Comments for the main contact relationship.
 * @param p_primary_contact_flag Indicates whether contact is primary contact
 * for the employee.
 * @param p_date_start The start date of the contact relationship.
 * @param p_start_life_reason_id Identifies the reason the relationship
 * started.
 * @param p_date_end The end date of the relationship.
 * @param p_end_life_reason_id Identifies the reason the relationship ended.
 * @param p_rltd_per_rsds_w_dsgntr_flag Indicates if the employee and the
 * contact live at the same address.
 * @param p_personal_flag Indicates whether the relationship is a personal
 * relationship.
 * @param p_sequence_number The unique sequence number for the relationship
 * used to identify contacts with a third party organization.
 * @param p_cont_attribute_category Contact attribute category.
 * @param p_cont_attribute1 Descriptive flexfield segment.
 * @param p_cont_attribute2 Descriptive flexfield segment.
 * @param p_cont_attribute3 Descriptive flexfield segment.
 * @param p_cont_attribute4 Descriptive flexfield segment.
 * @param p_cont_attribute5 Descriptive flexfield segment.
 * @param p_cont_attribute6 Descriptive flexfield segment.
 * @param p_cont_attribute7 Descriptive flexfield segment.
 * @param p_cont_attribute8 Descriptive flexfield segment.
 * @param p_cont_attribute9 Descriptive flexfield segment.
 * @param p_cont_attribute10 Descriptive flexfield segment.
 * @param p_cont_attribute11 Descriptive flexfield segment.
 * @param p_cont_attribute12 Descriptive flexfield segment.
 * @param p_cont_attribute13 Descriptive flexfield segment.
 * @param p_cont_attribute14 Descriptive flexfield segment.
 * @param p_cont_attribute15 Descriptive flexfield segment.
 * @param p_cont_attribute16 Descriptive flexfield segment.
 * @param p_cont_attribute17 Descriptive flexfield segment.
 * @param p_cont_attribute18 Descriptive flexfield segment.
 * @param p_cont_attribute19 Descriptive flexfield segment.
 * @param p_cont_attribute20 Descriptive flexfield segment.
 * @param p_cont_information_category Contact information category.
 * @param relationship_info Additional relationship information.
 * @param address_info Additional address information.
 * @param p_cont_information3 Descriptive flexfield segment.
 * @param p_cont_information4 Descriptive flexfield segment.
 * @param p_cont_information5 Descriptive flexfield segment.
 * @param p_cont_information6 Descriptive flexfield segment.
 * @param p_cont_information7 Descriptive flexfield segment.
 * @param p_cont_information8 Descriptive flexfield segment.
 * @param p_cont_information9 Descriptive flexfield segment.
 * @param p_cont_information10 Descriptive flexfield segment.
 * @param p_cont_information11 Descriptive flexfield segment.
 * @param p_cont_information12 Descriptive flexfield segment.
 * @param p_cont_information13 Descriptive flexfield segment.
 * @param p_cont_information14 Descriptive flexfield segment.
 * @param p_cont_information15 Descriptive flexfield segment.
 * @param p_cont_information16 Descriptive flexfield segment.
 * @param p_cont_information17 Descriptive flexfield segment.
 * @param p_cont_information18 Descriptive flexfield segment.
 * @param p_cont_information19 Descriptive flexfield segment.
 * @param p_cont_information20 Descriptive flexfield segment.
 * @param p_third_party_pay_flag Indicates whether the contact receives third
 * party payment from the employee.
 * @param p_bondholder_flag Indicates whether the contact person is a potential
 * EE bondholder.
 * @param p_dependent_flag Dependent flag.
 * @param p_beneficiary_flag Beneficiary flag.
 * @param p_last_name Contact's last name.
 * @param p_sex Contact's gender.
 * @param p_person_type_id Identifies the person type id. If a person_type_id
 * is not specified, then the API will use the default 'OTHER' system person
 * type for the business group.
 * @param p_per_comments Comments for the person record.
 * @param p_date_of_birth The date of birth of the contact. If the employee has
 * insured the contact the date of birth is mandatory.
 * @param p_email_address Contact's e-mail address.
 * @param p_first_name Contact's first name.
 * @param p_known_as Contact's preferred name, if different from first name.
 * @param p_marital_status Contact's marital status. The lookup type
 * 'MAR_STATUS' defines the valid values.
 * @param p_middle_names Contact's middle name(s).
 * @param p_nationality Contact's nationality. The lookup type 'NATIONALITY'
 * defines the valid values.
 * @param p_national_identifier Contact's national identifier. If the contact's
 * nationality is Polish and is insured by an employee, then PESEL is
 * mandatory.
 * @param p_previous_last_name Contact's previous last name.
 * @param p_registered_disabled_flag Indicates whether contact is classified as
 * disabled. The lookup type 'REGISTERED_DISABLED' defines the valid values.
 * @param p_title Contact's title. The lookup type 'TITLE' defines the valid
 * values.
 * @param p_work_telephone Contact's work telephone.
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
 * @param nip Contact's national Polish tax identifier. If the contact is an
 * inheritor, then the Polish tax identifier is mandatory.
 * @param insured_by_employee Indicates if the contact is insured by the
 * employee (health insurance). The lookup type 'YES_NO' defines the valid
 * values.
 * @param inheritor Indicates if the contact is an inheritor. The lookup type
 * 'YES_NO' defines the valid values.
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
 * @param p_pre_name_adjunct Obsolete parameter, do not use.
 * @param p_suffix Obsolete parameter, do not use.
 * @param p_create_mirror_flag Create mirror flag.
 * @param p_mirror_type Mirror relationship type.
 * @param p_mirror_cont_attribute_cat Mirror contact attribute category.
 * @param p_mirror_cont_attribute1 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute2 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute3 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute4 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute5 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute6 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute7 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute8 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute9 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute10 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute11 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute12 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute13 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute14 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute15 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute16 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute17 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute18 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute19 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute20 Descriptive flexfield segment.
 * @param p_mirror_cont_information_cat Mirror contact information category.
 * @param p_mirror_cont_information1 Descriptive flexfield segment.
 * @param p_mirror_cont_information2 Descriptive flexfield segment.
 * @param p_mirror_cont_information3 Descriptive flexfield segment.
 * @param p_mirror_cont_information4 Descriptive flexfield segment.
 * @param p_mirror_cont_information5 Descriptive flexfield segment.
 * @param p_mirror_cont_information6 Descriptive flexfield segment.
 * @param p_mirror_cont_information7 Descriptive flexfield segment.
 * @param p_mirror_cont_information8 Descriptive flexfield segment.
 * @param p_mirror_cont_information9 Descriptive flexfield segment.
 * @param p_mirror_cont_information10 Descriptive flexfield segment.
 * @param p_mirror_cont_information11 Descriptive flexfield segment.
 * @param p_mirror_cont_information12 Descriptive flexfield segment.
 * @param p_mirror_cont_information13 Descriptive flexfield segment.
 * @param p_mirror_cont_information14 Descriptive flexfield segment.
 * @param p_mirror_cont_information15 Descriptive flexfield segment.
 * @param p_mirror_cont_information16 Descriptive flexfield segment.
 * @param p_mirror_cont_information17 Descriptive flexfield segment.
 * @param p_mirror_cont_information18 Descriptive flexfield segment.
 * @param p_mirror_cont_information19 Descriptive flexfield segment.
 * @param p_mirror_cont_information20 Descriptive flexfield segment.
 * @param p_contact_relationship_id Identifies the main contact relationship.
 * If p_validate is false, this uniquely identifies the relationship created.
 * If p_validate is true this parameter will be null.
 * @param p_ctr_object_version_number If p_validate is false, this will be set
 * to the version number of the created contact relationship. If p_validate is
 * true, then value will be set to null.
 * @param p_per_person_id If p_validate is false, then this uniquely identifies
 * the person created. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created Person Address. If p_validate is true, then
 * the value will be null.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then will be set to the identifier of the created contact
 * relationship comment record. If p_validate is true or no comment text was
 * provided, then will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP, EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Create Contact Relationship for Poland
 * @rep:category BUSINESS_ENTITY PER_CONTACT_RELATIONSHIP
 * @rep:lifecycle deprecated
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_pl_contact
  (p_validate                     in        boolean     default false
  ,p_start_date                   in        date
  ,p_business_group_id            in        number
  ,p_person_id                    in        number
  ,p_contact_person_id            in        number      default null
  ,p_contact_type                 in        varchar2
  ,p_ctr_comments                 in        varchar2    default null
  ,p_primary_contact_flag         in        varchar2    default 'N'
  ,p_date_start                   in        date        default null
  ,p_start_life_reason_id         in        number      default null
  ,p_date_end                     in        date        default null
  ,p_end_life_reason_id           in        number      default null
  ,p_rltd_per_rsds_w_dsgntr_flag  in        varchar2    default 'N'
  ,p_personal_flag                in        varchar2    default 'N'
  ,p_sequence_number              in        number      default null
  ,p_cont_attribute_category      in        varchar2    default null
  ,p_cont_attribute1              in        varchar2    default null
  ,p_cont_attribute2              in        varchar2    default null
  ,p_cont_attribute3              in        varchar2    default null
  ,p_cont_attribute4              in        varchar2    default null
  ,p_cont_attribute5              in        varchar2    default null
  ,p_cont_attribute6              in        varchar2    default null
  ,p_cont_attribute7              in        varchar2    default null
  ,p_cont_attribute8              in        varchar2    default null
  ,p_cont_attribute9              in        varchar2    default null
  ,p_cont_attribute10             in        varchar2    default null
  ,p_cont_attribute11             in        varchar2    default null
  ,p_cont_attribute12             in        varchar2    default null
  ,p_cont_attribute13             in        varchar2    default null
  ,p_cont_attribute14             in        varchar2    default null
  ,p_cont_attribute15             in        varchar2    default null
  ,p_cont_attribute16             in        varchar2    default null
  ,p_cont_attribute17             in        varchar2    default null
  ,p_cont_attribute18             in        varchar2    default null
  ,p_cont_attribute19             in        varchar2    default null
  ,p_cont_attribute20             in        varchar2    default null
  ,p_cont_information_category      in        varchar2    default null
  ,Relationship_Info                in        varchar2    default null
  ,Address_Info                     in        varchar2    default null
  ,p_cont_information3              in        varchar2    default null
  ,p_cont_information4              in        varchar2    default null
  ,p_cont_information5              in        varchar2    default null
  ,p_cont_information6              in        varchar2    default null
  ,p_cont_information7              in        varchar2    default null
  ,p_cont_information8              in        varchar2    default null
  ,p_cont_information9              in        varchar2    default null
  ,p_cont_information10             in        varchar2    default null
  ,p_cont_information11             in        varchar2    default null
  ,p_cont_information12             in        varchar2    default null
  ,p_cont_information13             in        varchar2    default null
  ,p_cont_information14             in        varchar2    default null
  ,p_cont_information15             in        varchar2    default null
  ,p_cont_information16             in        varchar2    default null
  ,p_cont_information17             in        varchar2    default null
  ,p_cont_information18             in        varchar2    default null
  ,p_cont_information19             in        varchar2    default null
  ,p_cont_information20             in        varchar2    default null
  ,p_third_party_pay_flag         in        varchar2    default 'N'
  ,p_bondholder_flag              in        varchar2    default 'N'
  ,p_dependent_flag               in        varchar2    default 'N'
  ,p_beneficiary_flag             in        varchar2    default 'N'
  ,p_last_name                    in        varchar2    default null
  ,p_sex                          in        varchar2    default null
  ,p_person_type_id               in        number      default null
  ,p_per_comments                 in        varchar2    default null
  ,p_date_of_birth                in        date        default null
  ,p_email_address                in        varchar2    default null
  ,p_first_name                   in        varchar2    default null
  ,p_known_as                     in        varchar2    default null
  ,p_marital_status               in        varchar2    default null
  ,p_middle_names                 in        varchar2    default null
  ,p_nationality                  in        varchar2    default null
  ,p_national_identifier          in        varchar2    default null
  ,p_previous_last_name           in        varchar2    default null
  ,p_registered_disabled_flag     in        varchar2    default null
  ,p_title                        in        varchar2    default null
  ,p_work_telephone               in        varchar2    default null
  ,p_attribute_category           in        varchar2    default null
  ,p_attribute1                   in        varchar2    default null
  ,p_attribute2                   in        varchar2    default null
  ,p_attribute3                   in        varchar2    default null
  ,p_attribute4                   in        varchar2    default null
  ,p_attribute5                   in        varchar2    default null
  ,p_attribute6                   in        varchar2    default null
  ,p_attribute7                   in        varchar2    default null
  ,p_attribute8                   in        varchar2    default null
  ,p_attribute9                   in        varchar2    default null
  ,p_attribute10                  in        varchar2    default null
  ,p_attribute11                  in        varchar2    default null
  ,p_attribute12                  in        varchar2    default null
  ,p_attribute13                  in        varchar2    default null
  ,p_attribute14                  in        varchar2    default null
  ,p_attribute15                  in        varchar2    default null
  ,p_attribute16                  in        varchar2    default null
  ,p_attribute17                  in        varchar2    default null
  ,p_attribute18                  in        varchar2    default null
  ,p_attribute19                  in        varchar2    default null
  ,p_attribute20                  in        varchar2    default null
  ,p_attribute21                  in        varchar2    default null
  ,p_attribute22                  in        varchar2    default null
  ,p_attribute23                  in        varchar2    default null
  ,p_attribute24                  in        varchar2    default null
  ,p_attribute25                  in        varchar2    default null
  ,p_attribute26                  in        varchar2    default null
  ,p_attribute27                  in        varchar2    default null
  ,p_attribute28                  in        varchar2    default null
  ,p_attribute29                  in        varchar2    default null
  ,p_attribute30                  in        varchar2    default null
  ,p_per_information_category     in        varchar2    default null
  ,NIP                            in        varchar2    default null
  ,Insured_by_Employee            in        varchar2
  ,Inheritor                      in        varchar2
  ,p_per_information4             in        varchar2    default null
  ,p_per_information5             in        varchar2    default null
  ,p_per_information6             in        varchar2    default null
  ,p_per_information7             in        varchar2    default null
  ,p_per_information8             in        varchar2    default null
  ,p_per_information9             in        varchar2    default null
  ,p_per_information10            in        varchar2    default null
  ,p_per_information11            in        varchar2    default null
  ,p_per_information12            in        varchar2    default null
  ,p_per_information13            in        varchar2    default null
  ,p_per_information14            in        varchar2    default null
  ,p_per_information15            in        varchar2    default null
  ,p_per_information16            in        varchar2    default null
  ,p_per_information17            in        varchar2    default null
  ,p_per_information18            in        varchar2    default null
  ,p_per_information19            in        varchar2    default null
  ,p_per_information20            in        varchar2    default null
  ,p_per_information21            in        varchar2    default null
  ,p_per_information22            in        varchar2    default null
  ,p_per_information23            in        varchar2    default null
  ,p_per_information24            in        varchar2    default null
  ,p_per_information25            in        varchar2    default null
  ,p_per_information26            in        varchar2    default null
  ,p_per_information27            in        varchar2    default null
  ,p_per_information28            in        varchar2    default null
  ,p_per_information29            in        varchar2    default null
  ,p_per_information30            in        varchar2    default null
  ,p_correspondence_language      in        varchar2    default null
  ,p_honors                       in        varchar2    default null
  ,p_pre_name_adjunct             in        varchar2    default null
  ,p_suffix                       in        varchar2    default null
  ,p_create_mirror_flag           in        varchar2    default 'N'
  ,p_mirror_type                  in        varchar2    default null
  ,p_mirror_cont_attribute_cat    in        varchar2    default null
  ,p_mirror_cont_attribute1       in        varchar2    default null
  ,p_mirror_cont_attribute2       in        varchar2    default null
  ,p_mirror_cont_attribute3       in        varchar2    default null
  ,p_mirror_cont_attribute4       in        varchar2    default null
  ,p_mirror_cont_attribute5       in        varchar2    default null
  ,p_mirror_cont_attribute6       in        varchar2    default null
  ,p_mirror_cont_attribute7       in        varchar2    default null
  ,p_mirror_cont_attribute8       in        varchar2    default null
  ,p_mirror_cont_attribute9       in        varchar2    default null
  ,p_mirror_cont_attribute10      in        varchar2    default null
  ,p_mirror_cont_attribute11      in        varchar2    default null
  ,p_mirror_cont_attribute12      in        varchar2    default null
  ,p_mirror_cont_attribute13      in        varchar2    default null
  ,p_mirror_cont_attribute14      in        varchar2    default null
  ,p_mirror_cont_attribute15      in        varchar2    default null
  ,p_mirror_cont_attribute16      in        varchar2    default null
  ,p_mirror_cont_attribute17      in        varchar2    default null
  ,p_mirror_cont_attribute18      in        varchar2    default null
  ,p_mirror_cont_attribute19      in        varchar2    default null
  ,p_mirror_cont_attribute20      in        varchar2    default null
  ,p_mirror_cont_information_cat    in        varchar2    default null
  ,p_mirror_cont_information1       in        varchar2    default null
  ,p_mirror_cont_information2       in        varchar2    default null
  ,p_mirror_cont_information3       in        varchar2    default null
  ,p_mirror_cont_information4       in        varchar2    default null
  ,p_mirror_cont_information5       in        varchar2    default null
  ,p_mirror_cont_information6       in        varchar2    default null
  ,p_mirror_cont_information7       in        varchar2    default null
  ,p_mirror_cont_information8       in        varchar2    default null
  ,p_mirror_cont_information9       in        varchar2    default null
  ,p_mirror_cont_information10      in        varchar2    default null
  ,p_mirror_cont_information11      in        varchar2    default null
  ,p_mirror_cont_information12      in        varchar2    default null
  ,p_mirror_cont_information13      in        varchar2    default null
  ,p_mirror_cont_information14      in        varchar2    default null
  ,p_mirror_cont_information15      in        varchar2    default null
  ,p_mirror_cont_information16      in        varchar2    default null
  ,p_mirror_cont_information17      in        varchar2    default null
  ,p_mirror_cont_information18      in        varchar2    default null
  ,p_mirror_cont_information19      in        varchar2    default null
  ,p_mirror_cont_information20      in        varchar2    default null
  ,p_contact_relationship_id      out nocopy number
  ,p_ctr_object_version_number    out nocopy number
  ,p_per_person_id                out nocopy number
  ,p_per_object_version_number    out nocopy number
  ,p_per_effective_start_date     out nocopy date
  ,p_per_effective_end_date       out nocopy date
  ,p_full_name                    out nocopy varchar2
  ,p_per_comment_id               out nocopy number
  ,p_name_combination_warning     out nocopy boolean
  ,p_orig_hire_warning            out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_pl_contact_relationship >------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure modifies a contact relationship.
 *
 * This API is effectively an alternative to the API hr_contact_rel_api.If
 * p_validate is set to false, the contact relationship is updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contact relationship record identified by p_contact_relationship_id must
 * already exist.
 *
 * <p><b>Post Success</b><br>
 * The contact relationship is successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The contact relationship will not be updated and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_contact_relationship_id Identifies the contact relationship record
 * to be modified.
 * @param p_contact_type Type of contact. The lookup type 'CONTACT' defines the
 * valid values.
 * @param p_comments Contact relationship comment text.
 * @param p_primary_contact_flag Indicates whether contact is primary contact
 * for the employee.
 * @param p_third_party_pay_flag Indicates whether the contact receives third
 * party payment from the employee.
 * @param p_bondholder_flag Indicates whether a contact person is a potential
 * EE bondholder.
 * @param p_date_start The start date of the relationship.
 * @param p_start_life_reason_id Identifies the reason the relationship
 * started.
 * @param p_date_end The end date of the relationship.
 * @param p_end_life_reason_id Identifies the reason the relationship ended.
 * @param p_rltd_per_rsds_w_dsgntr_flag Indicates whether the two people in the
 * relationship live at the same address.
 * @param p_personal_flag Indicates whether relationship is a personal
 * relationship.
 * @param p_sequence_number The unique sequence number for the relationship
 * used to identify contacts with a third party organization.
 * @param p_dependent_flag Dependent flag.
 * @param p_beneficiary_flag Beneficiary flag.
 * @param p_cont_attribute_category Contact attribute category.
 * @param p_cont_attribute1 Descriptive flexfield segment.
 * @param p_cont_attribute2 Descriptive flexfield segment.
 * @param p_cont_attribute3 Descriptive flexfield segment.
 * @param p_cont_attribute4 Descriptive flexfield segment.
 * @param p_cont_attribute5 Descriptive flexfield segment.
 * @param p_cont_attribute6 Descriptive flexfield segment.
 * @param p_cont_attribute7 Descriptive flexfield segment.
 * @param p_cont_attribute8 Descriptive flexfield segment.
 * @param p_cont_attribute9 Descriptive flexfield segment.
 * @param p_cont_attribute10 Descriptive flexfield segment.
 * @param p_cont_attribute11 Descriptive flexfield segment.
 * @param p_cont_attribute12 Descriptive flexfield segment.
 * @param p_cont_attribute13 Descriptive flexfield segment.
 * @param p_cont_attribute14 Descriptive flexfield segment.
 * @param p_cont_attribute15 Descriptive flexfield segment.
 * @param p_cont_attribute16 Descriptive flexfield segment.
 * @param p_cont_attribute17 Descriptive flexfield segment.
 * @param p_cont_attribute18 Descriptive flexfield segment.
 * @param p_cont_attribute19 Descriptive flexfield segment.
 * @param p_cont_attribute20 Descriptive flexfield segment.
 * @param p_cont_information_category Contact information category.
 * @param relationship_info Additional relationship information.
 * @param address_info Additional address information.
 * @param p_cont_information3 Descriptive flexfield segment.
 * @param p_cont_information4 Descriptive flexfield segment.
 * @param p_cont_information5 Descriptive flexfield segment.
 * @param p_cont_information6 Descriptive flexfield segment.
 * @param p_cont_information7 Descriptive flexfield segment.
 * @param p_cont_information8 Descriptive flexfield segment.
 * @param p_cont_information9 Descriptive flexfield segment.
 * @param p_cont_information10 Descriptive flexfield segment.
 * @param p_cont_information11 Descriptive flexfield segment.
 * @param p_cont_information12 Descriptive flexfield segment.
 * @param p_cont_information13 Descriptive flexfield segment.
 * @param p_cont_information14 Descriptive flexfield segment.
 * @param p_cont_information15 Descriptive flexfield segment.
 * @param p_cont_information16 Descriptive flexfield segment.
 * @param p_cont_information17 Descriptive flexfield segment.
 * @param p_cont_information18 Descriptive flexfield segment.
 * @param p_cont_information19 Descriptive flexfield segment.
 * @param p_cont_information20 Descriptive flexfield segment.
 * @param p_object_version_number Pass in the current version number of the
 * Contact Relationship to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Contact
 * Relationship. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Contact Relationship for Poland
 * @rep:category BUSINESS_ENTITY PER_CONTACT_RELATIONSHIP
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  PROCEDURE update_pl_contact_relationship
  (p_validate                          in        boolean   default false
  ,p_effective_date                    in        date
  ,p_contact_relationship_id           in        number
  ,p_contact_type                      in        varchar2  default hr_api.g_varchar2
  ,p_comments                          in        long      default hr_api.g_varchar2
  ,p_primary_contact_flag              in        varchar2  default hr_api.g_varchar2
  ,p_third_party_pay_flag              in        varchar2  default hr_api.g_varchar2
  ,p_bondholder_flag                   in        varchar2  default hr_api.g_varchar2
  ,p_date_start                        in        date      default hr_api.g_date
  ,p_start_life_reason_id              in        number    default hr_api.g_number
  ,p_date_end                          in        date      default hr_api.g_date
  ,p_end_life_reason_id                in        number    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag       in        varchar2  default hr_api.g_varchar2
  ,p_personal_flag                     in        varchar2  default hr_api.g_varchar2
  ,p_sequence_number                   in        number    default hr_api.g_number
  ,p_dependent_flag                    in        varchar2  default hr_api.g_varchar2
  ,p_beneficiary_flag                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute_category           in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute1                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute2                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute3                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute4                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute5                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute6                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute7                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute8                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute9                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute10                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute11                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute12                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute13                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute14                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute15                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute16                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute17                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute18                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute19                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_attribute20                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information_category           in        varchar2  default hr_api.g_varchar2
  ,Relationship_Info                     in        varchar2  default hr_api.g_varchar2
  ,Address_Info                          in        varchar2  default hr_api.g_varchar2
  ,p_cont_information3                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information4                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information5                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information6                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information7                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information8                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information9                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information10                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information11                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information12                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information13                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information14                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information15                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information16                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information17                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information18                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information19                  in        varchar2  default hr_api.g_varchar2
  ,p_cont_information20                  in        varchar2  default hr_api.g_varchar2
  ,p_object_version_number             in out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_pl_contact >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Polish contact relationship.
 *
 * The API is effectively an alternative to the API hr_contact_rel_api. If
 * p_validate is set to false, a contact relationship is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group for Poland legislation must already exist. A valid
 * person_type_id with a corresponding system type of 'CONTACT', must be active
 * and in the same business group as that of the contact being created.
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates a contact relationship into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a contact relationship and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date The effective start date of the contact person.
 * @param p_business_group_id Identifies the contact person's business group.
 * @param p_person_id Identifies the person for whom you create the contact
 * relationship record.
 * @param p_contact_person_id Identifies the contact person for whom you create
 * the contact relationship record.
 * @param p_contact_type Identifies the contact type. The lookup type 'CONTACT'
 * defines the valid values.
 * @param p_ctr_comments Comments for the main contact relationship.
 * @param p_primary_contact_flag Indicates whether contact is primary contact
 * for the employee.
 * @param p_date_start The start date of the contact relationship.
 * @param p_start_life_reason_id Identifies the reason the relationship
 * started.
 * @param p_date_end The end date of the relationship.
 * @param p_end_life_reason_id Identifies the reason the relationship ended.
 * @param p_rltd_per_rsds_w_dsgntr_flag Indicates if the employee and the
 * contact live at the same address.
 * @param p_personal_flag Indicates whether the relationship is a personal
 * relationship.
 * @param p_sequence_number The unique sequence number for the relationship
 * used to identify contacts with a third party organization.
 * @param p_cont_attribute_category Contact attribute category.
 * @param p_cont_attribute1 Descriptive flexfield segment.
 * @param p_cont_attribute2 Descriptive flexfield segment.
 * @param p_cont_attribute3 Descriptive flexfield segment.
 * @param p_cont_attribute4 Descriptive flexfield segment.
 * @param p_cont_attribute5 Descriptive flexfield segment.
 * @param p_cont_attribute6 Descriptive flexfield segment.
 * @param p_cont_attribute7 Descriptive flexfield segment.
 * @param p_cont_attribute8 Descriptive flexfield segment.
 * @param p_cont_attribute9 Descriptive flexfield segment.
 * @param p_cont_attribute10 Descriptive flexfield segment.
 * @param p_cont_attribute11 Descriptive flexfield segment.
 * @param p_cont_attribute12 Descriptive flexfield segment.
 * @param p_cont_attribute13 Descriptive flexfield segment.
 * @param p_cont_attribute14 Descriptive flexfield segment.
 * @param p_cont_attribute15 Descriptive flexfield segment.
 * @param p_cont_attribute16 Descriptive flexfield segment.
 * @param p_cont_attribute17 Descriptive flexfield segment.
 * @param p_cont_attribute18 Descriptive flexfield segment.
 * @param p_cont_attribute19 Descriptive flexfield segment.
 * @param p_cont_attribute20 Descriptive flexfield segment.
 * @param p_cont_information_category Contact information category.
 * @param relationship_info Additional relationship information.
 * @param address_info Additional address information.
 * @param p_cont_information3 Descriptive flexfield segment.
 * @param p_cont_information4 Descriptive flexfield segment.
 * @param p_cont_information5 Descriptive flexfield segment.
 * @param p_cont_information6 Descriptive flexfield segment.
 * @param p_cont_information7 Descriptive flexfield segment.
 * @param p_cont_information8 Descriptive flexfield segment.
 * @param p_cont_information9 Descriptive flexfield segment.
 * @param p_cont_information10 Descriptive flexfield segment.
 * @param p_cont_information11 Descriptive flexfield segment.
 * @param p_cont_information12 Descriptive flexfield segment.
 * @param p_cont_information13 Descriptive flexfield segment.
 * @param p_cont_information14 Descriptive flexfield segment.
 * @param p_cont_information15 Descriptive flexfield segment.
 * @param p_cont_information16 Descriptive flexfield segment.
 * @param p_cont_information17 Descriptive flexfield segment.
 * @param p_cont_information18 Descriptive flexfield segment.
 * @param p_cont_information19 Descriptive flexfield segment.
 * @param p_cont_information20 Descriptive flexfield segment.
 * @param p_third_party_pay_flag Indicates whether the contact receives third
 * party payment from the employee.
 * @param p_bondholder_flag Indicates whether the contact person is a potential
 * EE bondholder.
 * @param p_dependent_flag Dependent flag.
 * @param p_beneficiary_flag Beneficiary flag.
 * @param p_last_name Contact's last name.
 * @param p_sex Contact's gender.
 * @param p_person_type_id Identifies the person type id. If a person_type_id
 * is not specified, then the API will use the default 'OTHER' system person
 * type for the business group.
 * @param p_per_comments Comments for the person record.
 * @param p_date_of_birth The date of birth of the contact. If the employee has
 * insured the contact the date of birth is mandatory.
 * @param p_email_address Contact's e-mail address.
 * @param p_first_name Contact's first name.
 * @param p_known_as Contact's preferred name, if different from first name.
 * @param p_marital_status Contact's marital status. The lookup type
 * 'MAR_STATUS' defines the valid values.
 * @param p_middle_names Contact's middle name(s).
 * @param p_nationality Contact's nationality. The lookup type 'NATIONALITY'
 * defines the valid values.
 * @param p_pesel Contact's national identifier.If a contact's
 * nationality and citizenship are both  Polish
 * and is insured by an employee, then PESEL or NIP has to be specified.
 * @param p_previous_last_name Contact's previous last name.
 * @param p_registered_disabled_flag Indicates whether contact is classified as
 * disabled. The lookup type 'REGISTERED_DISABLED' defines the valid values.
 * @param p_title Contact's title. The lookup type 'TITLE' defines the valid
 * values.
 * @param p_work_telephone Contact's work telephone.
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
 * @param p_pre_name_adjunct Obsolete parameter, do not use.
 * @param p_suffix Obsolete parameter, do not use.
 * @param p_create_mirror_flag Create mirror flag.
 * @param p_mirror_type Mirror relationship type.
 * @param p_mirror_cont_attribute_cat Mirror contact attribute category.
 * @param p_mirror_cont_attribute1 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute2 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute3 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute4 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute5 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute6 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute7 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute8 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute9 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute10 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute11 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute12 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute13 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute14 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute15 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute16 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute17 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute18 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute19 Descriptive flexfield segment.
 * @param p_mirror_cont_attribute20 Descriptive flexfield segment.
 * @param p_mirror_cont_information_cat Mirror contact information category.
 * @param p_mirror_cont_information1 Descriptive flexfield segment.
 * @param p_mirror_cont_information2 Descriptive flexfield segment.
 * @param p_mirror_cont_information3 Descriptive flexfield segment.
 * @param p_mirror_cont_information4 Descriptive flexfield segment.
 * @param p_mirror_cont_information5 Descriptive flexfield segment.
 * @param p_mirror_cont_information6 Descriptive flexfield segment.
 * @param p_mirror_cont_information7 Descriptive flexfield segment.
 * @param p_mirror_cont_information8 Descriptive flexfield segment.
 * @param p_mirror_cont_information9 Descriptive flexfield segment.
 * @param p_mirror_cont_information10 Descriptive flexfield segment.
 * @param p_mirror_cont_information11 Descriptive flexfield segment.
 * @param p_mirror_cont_information12 Descriptive flexfield segment.
 * @param p_mirror_cont_information13 Descriptive flexfield segment.
 * @param p_mirror_cont_information14 Descriptive flexfield segment.
 * @param p_mirror_cont_information15 Descriptive flexfield segment.
 * @param p_mirror_cont_information16 Descriptive flexfield segment.
 * @param p_mirror_cont_information17 Descriptive flexfield segment.
 * @param p_mirror_cont_information18 Descriptive flexfield segment.
 * @param p_mirror_cont_information19 Descriptive flexfield segment.
 * @param p_mirror_cont_information20 Descriptive flexfield segment.
 * @param p_contact_relationship_id Identifies the main contact relationship.
 * If p_validate is false, this uniquely identifies the relationship created.
 * If p_validate is true this parameter will be null.
 * @param p_ctr_object_version_number If p_validate is false, this will be set
 * to the version number of the created contact relationship. If p_validate is
 * true, then value will be set to null.
 * @param p_per_person_id If p_validate is false, then this uniquely identifies
 * the person created. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created Person Address. If p_validate is true, then
 * the value will be null.
 * @param p_per_effective_start_date If p_validate is false, this will be set
 * to the effective start date of the person. If p_validate is true this will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, this will be set to
 * the effective end date of the person. If p_validate is true this will be
 * null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the person. If p_validate is true this will be null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then will be set to the identifier of the created contact
 * relationship comment record. If p_validate is true or no comment text was
 * provided, then will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Set to true if the original date of hire is not
 * null and the person type is not EMP, EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Create Contact Relationship for Poland
 * @rep:category BUSINESS_ENTITY PER_CONTACT_RELATIONSHIP
 * @rep:lifecycle active
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_pl_contact
  (p_validate                     in        boolean     default false
  ,p_start_date                   in        date
  ,p_business_group_id            in        number
  ,p_person_id                    in        number
  ,p_contact_person_id            in        number      default null
  ,p_contact_type                 in        varchar2
  ,p_ctr_comments                 in        varchar2    default null
  ,p_primary_contact_flag         in        varchar2    default 'N'
  ,p_date_start                   in        date        default null
  ,p_start_life_reason_id         in        number      default null
  ,p_date_end                     in        date        default null
  ,p_end_life_reason_id           in        number      default null
  ,p_rltd_per_rsds_w_dsgntr_flag  in        varchar2    default 'N'
  ,p_personal_flag                in        varchar2    default 'N'
  ,p_sequence_number              in        number      default null
  ,p_cont_attribute_category      in        varchar2    default null
  ,p_cont_attribute1              in        varchar2    default null
  ,p_cont_attribute2              in        varchar2    default null
  ,p_cont_attribute3              in        varchar2    default null
  ,p_cont_attribute4              in        varchar2    default null
  ,p_cont_attribute5              in        varchar2    default null
  ,p_cont_attribute6              in        varchar2    default null
  ,p_cont_attribute7              in        varchar2    default null
  ,p_cont_attribute8              in        varchar2    default null
  ,p_cont_attribute9              in        varchar2    default null
  ,p_cont_attribute10             in        varchar2    default null
  ,p_cont_attribute11             in        varchar2    default null
  ,p_cont_attribute12             in        varchar2    default null
  ,p_cont_attribute13             in        varchar2    default null
  ,p_cont_attribute14             in        varchar2    default null
  ,p_cont_attribute15             in        varchar2    default null
  ,p_cont_attribute16             in        varchar2    default null
  ,p_cont_attribute17             in        varchar2    default null
  ,p_cont_attribute18             in        varchar2    default null
  ,p_cont_attribute19             in        varchar2    default null
  ,p_cont_attribute20             in        varchar2    default null
  ,p_cont_information_category      in        varchar2    default null
  ,Relationship_Info                in        varchar2    default null
  ,Address_Info                     in        varchar2    default null
  ,p_cont_information3              in        varchar2    default null
  ,p_cont_information4              in        varchar2    default null
  ,p_cont_information5              in        varchar2    default null
  ,p_cont_information6              in        varchar2    default null
  ,p_cont_information7              in        varchar2    default null
  ,p_cont_information8              in        varchar2    default null
  ,p_cont_information9              in        varchar2    default null
  ,p_cont_information10             in        varchar2    default null
  ,p_cont_information11             in        varchar2    default null
  ,p_cont_information12             in        varchar2    default null
  ,p_cont_information13             in        varchar2    default null
  ,p_cont_information14             in        varchar2    default null
  ,p_cont_information15             in        varchar2    default null
  ,p_cont_information16             in        varchar2    default null
  ,p_cont_information17             in        varchar2    default null
  ,p_cont_information18             in        varchar2    default null
  ,p_cont_information19             in        varchar2    default null
  ,p_cont_information20             in        varchar2    default null
  ,p_third_party_pay_flag         in        varchar2    default 'N'
  ,p_bondholder_flag              in        varchar2    default 'N'
  ,p_dependent_flag               in        varchar2    default 'N'
  ,p_beneficiary_flag             in        varchar2    default 'N'
  ,p_last_name                    in        varchar2
  ,p_sex                          in        varchar2    default null
  ,p_person_type_id               in        number      default null
  ,p_per_comments                 in        varchar2    default null
  ,p_date_of_birth                in        date        default null
  ,p_email_address                in        varchar2    default null
  ,p_first_name                   in        varchar2    default null
  ,p_known_as                     in        varchar2    default null
  ,p_marital_status               in        varchar2    default null
  ,p_middle_names                 in        varchar2    default null
  ,p_nationality                  in        varchar2    default null
  ,p_pesel                        in        varchar2    default null
  ,p_previous_last_name           in        varchar2    default null
  ,p_registered_disabled_flag     in        varchar2    default null
  ,p_title                        in        varchar2    default null
  ,p_work_telephone               in        varchar2    default null
  ,p_attribute_category           in        varchar2    default null
  ,p_attribute1                   in        varchar2    default null
  ,p_attribute2                   in        varchar2    default null
  ,p_attribute3                   in        varchar2    default null
  ,p_attribute4                   in        varchar2    default null
  ,p_attribute5                   in        varchar2    default null
  ,p_attribute6                   in        varchar2    default null
  ,p_attribute7                   in        varchar2    default null
  ,p_attribute8                   in        varchar2    default null
  ,p_attribute9                   in        varchar2    default null
  ,p_attribute10                  in        varchar2    default null
  ,p_attribute11                  in        varchar2    default null
  ,p_attribute12                  in        varchar2    default null
  ,p_attribute13                  in        varchar2    default null
  ,p_attribute14                  in        varchar2    default null
  ,p_attribute15                  in        varchar2    default null
  ,p_attribute16                  in        varchar2    default null
  ,p_attribute17                  in        varchar2    default null
  ,p_attribute18                  in        varchar2    default null
  ,p_attribute19                  in        varchar2    default null
  ,p_attribute20                  in        varchar2    default null
  ,p_attribute21                  in        varchar2    default null
  ,p_attribute22                  in        varchar2    default null
  ,p_attribute23                  in        varchar2    default null
  ,p_attribute24                  in        varchar2    default null
  ,p_attribute25                  in        varchar2    default null
  ,p_attribute26                  in        varchar2    default null
  ,p_attribute27                  in        varchar2    default null
  ,p_attribute28                  in        varchar2    default null
  ,p_attribute29                  in        varchar2    default null
  ,p_attribute30                  in        varchar2    default null
  ,p_per_information_category     in        varchar2    default null
  ,p_nip                          in        varchar2    default null
  ,p_insured_by_employee          in        varchar2    default null
  ,p_inheritor                    in        varchar2    default null
  ,p_oldage_pension_rights        in        varchar2    default null
  ,p_national_fund_of_health      in        varchar2    default null
  ,p_tax_office                   in        varchar2    default null
  ,p_legal_employer               in        varchar2    default null
  ,p_citizenship                  in        varchar2    default null
  ,p_correspondence_language      in        varchar2    default null
  ,p_honors                       in        varchar2    default null
  ,p_pre_name_adjunct             in        varchar2    default null
  ,p_suffix                       in        varchar2    default null
  ,p_create_mirror_flag           in        varchar2    default 'N'
  ,p_mirror_type                  in        varchar2    default null
  ,p_mirror_cont_attribute_cat    in        varchar2    default null
  ,p_mirror_cont_attribute1       in        varchar2    default null
  ,p_mirror_cont_attribute2       in        varchar2    default null
  ,p_mirror_cont_attribute3       in        varchar2    default null
  ,p_mirror_cont_attribute4       in        varchar2    default null
  ,p_mirror_cont_attribute5       in        varchar2    default null
  ,p_mirror_cont_attribute6       in        varchar2    default null
  ,p_mirror_cont_attribute7       in        varchar2    default null
  ,p_mirror_cont_attribute8       in        varchar2    default null
  ,p_mirror_cont_attribute9       in        varchar2    default null
  ,p_mirror_cont_attribute10      in        varchar2    default null
  ,p_mirror_cont_attribute11      in        varchar2    default null
  ,p_mirror_cont_attribute12      in        varchar2    default null
  ,p_mirror_cont_attribute13      in        varchar2    default null
  ,p_mirror_cont_attribute14      in        varchar2    default null
  ,p_mirror_cont_attribute15      in        varchar2    default null
  ,p_mirror_cont_attribute16      in        varchar2    default null
  ,p_mirror_cont_attribute17      in        varchar2    default null
  ,p_mirror_cont_attribute18      in        varchar2    default null
  ,p_mirror_cont_attribute19      in        varchar2    default null
  ,p_mirror_cont_attribute20      in        varchar2    default null
  ,p_mirror_cont_information_cat    in        varchar2    default null
  ,p_mirror_cont_information1       in        varchar2    default null
  ,p_mirror_cont_information2       in        varchar2    default null
  ,p_mirror_cont_information3       in        varchar2    default null
  ,p_mirror_cont_information4       in        varchar2    default null
  ,p_mirror_cont_information5       in        varchar2    default null
  ,p_mirror_cont_information6       in        varchar2    default null
  ,p_mirror_cont_information7       in        varchar2    default null
  ,p_mirror_cont_information8       in        varchar2    default null
  ,p_mirror_cont_information9       in        varchar2    default null
  ,p_mirror_cont_information10      in        varchar2    default null
  ,p_mirror_cont_information11      in        varchar2    default null
  ,p_mirror_cont_information12      in        varchar2    default null
  ,p_mirror_cont_information13      in        varchar2    default null
  ,p_mirror_cont_information14      in        varchar2    default null
  ,p_mirror_cont_information15      in        varchar2    default null
  ,p_mirror_cont_information16      in        varchar2    default null
  ,p_mirror_cont_information17      in        varchar2    default null
  ,p_mirror_cont_information18      in        varchar2    default null
  ,p_mirror_cont_information19      in        varchar2    default null
  ,p_mirror_cont_information20      in        varchar2    default null
  ,p_contact_relationship_id      out nocopy number
  ,p_ctr_object_version_number    out nocopy number
  ,p_per_person_id                out nocopy number
  ,p_per_object_version_number    out nocopy number
  ,p_per_effective_start_date     out nocopy date
  ,p_per_effective_end_date       out nocopy date
  ,p_full_name                    out nocopy varchar2
  ,p_per_comment_id               out nocopy number
  ,p_name_combination_warning     out nocopy boolean
  ,p_orig_hire_warning            out nocopy boolean
  );

  END hr_pl_contact_rel_api;

 

/
