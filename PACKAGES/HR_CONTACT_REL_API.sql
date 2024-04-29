--------------------------------------------------------
--  DDL for Package HR_CONTACT_REL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTACT_REL_API" AUTHID CURRENT_USER as
/* $Header: pecrlapi.pkh 120.1 2005/10/02 02:14:06 aroussel $ */
/*#
 * This package contains APIs to maintain contact relationship information.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Contact Relationship
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_contact >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the first contact relationship between two people in the
 * database.
 *
 * If the contact person does not exist, a person record is created for the
 * contact.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person for whom the contact relationship is being created must exist.
 * The person who is the contact need not exist.
 *
 * <p><b>Post Success</b><br>
 * If p_contact_person_id is not passed, then a person is created with details
 * derived from the relevant parameters of this API call. Otherwise the contact
 * person must exist already. The contact relationship is then created between
 * the two people.
 *
 * <p><b>Post Failure</b><br>
 * No contact person record, or contact relationship between the original
 * person and contact is created, and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date The start date on which to create the contact's person
 * record, if the contact person does not already exist.
 * @param p_business_group_id Business group of the person
 * @param p_person_id Identifies the person for whom you create the contact
 * relationship.
 * @param p_contact_person_id If passed, identifies the contact person of the
 * contact relationship. If not passed, then a contact will be created in the
 * system.
 * @param p_contact_type Contact Type. Valid values are defined in the CONTACT
 * lookup type.
 * @param p_ctr_comments Comments for the contact relationship.
 * @param p_primary_contact_flag Value 'Y' identifies if this is the primary
 * contact relationship. Value 'N' identifies that this is not. There can only
 * be one primary contact relationship between the same person and contact.
 * @param p_date_start Start date of the contact relationship
 * @param p_start_life_reason_id Identifies the reason for the start of the
 * contact relationship for Benefits purposes.
 * @param p_date_end End date of the contact relationship
 * @param p_end_life_reason_id Identifies the reason for the end of the contact
 * relationship, for Benefits purposes.
 * @param p_rltd_per_rsds_w_dsgntr_flag Value 'Y' indicates if the contact
 * resides at the same address as the person, otherwise 'N'. For Benefits
 * purposes.
 * @param p_personal_flag Value 'Y' indicates that the contact relationship is
 * a personal relationship. Otherwise 'N'. For Benefits purposes.
 * @param p_sequence_number Unique number to identify this relationship from
 * other relationships the same person is in.
 * @param p_cont_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
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
 * @param p_cont_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_cont_information1 Developer Descriptive flexfield segment.
 * @param p_cont_information2 Developer Descriptive flexfield segment.
 * @param p_cont_information3 Developer Descriptive flexfield segment.
 * @param p_cont_information4 Developer Descriptive flexfield segment.
 * @param p_cont_information5 Developer Descriptive flexfield segment.
 * @param p_cont_information6 Developer Descriptive flexfield segment.
 * @param p_cont_information7 Developer Descriptive flexfield segment.
 * @param p_cont_information8 Developer Descriptive flexfield segment.
 * @param p_cont_information9 Developer Descriptive flexfield segment.
 * @param p_cont_information10 Developer Descriptive flexfield segment.
 * @param p_cont_information11 Developer Descriptive flexfield segment.
 * @param p_cont_information12 Developer Descriptive flexfield segment.
 * @param p_cont_information13 Developer Descriptive flexfield segment.
 * @param p_cont_information14 Developer Descriptive flexfield segment.
 * @param p_cont_information15 Developer Descriptive flexfield segment.
 * @param p_cont_information16 Developer Descriptive flexfield segment.
 * @param p_cont_information17 Developer Descriptive flexfield segment.
 * @param p_cont_information18 Developer Descriptive flexfield segment.
 * @param p_cont_information19 Developer Descriptive flexfield segment.
 * @param p_cont_information20 Developer Descriptive flexfield segment.
 * @param p_third_party_pay_flag Value 'Y' indicates that the contact receives
 * third party payments from the person.
 * @param p_bondholder_flag Value 'Y' indicates that the contact is a
 * bondholder
 * @param p_dependent_flag Value 'Y' indicates that the contact is a dependent
 * of the person
 * @param p_beneficiary_flag Value 'Y' indicates that the contact is a
 * beneficiary.
 * @param p_last_name Last name of contact, if a contact is to be created.
 * @param p_sex Sex of contact, if a contact is to be created. Valid values are
 * defined in the SEX lookup type.
 * @param p_person_type_id Person Type of contact, if a contact is to be
 * created. Must be of system person type of OTHER
 * @param p_per_comments Comments for contact's person record.
 * @param p_date_of_birth Date of birth of contact, if a contact is to be
 * created.
 * @param p_email_address Email address of contact, if a contact is to be
 * created.
 * @param p_first_name First name of contact, if a contact is to be created.
 * @param p_known_as Preferred name of contact, if a contact is to be created.
 * @param p_marital_status Marital status of contact, if a contact is to be
 * created. Valid values are defined in the MAR_STATUS lookup type.
 * @param p_middle_names Middle names of contact, if a contact is to be
 * created.
 * @param p_nationality Nationality of contact, if a contact is to be created.
 * Valid values are defined in the NATIONALITY lookup type
 * @param p_national_identifier National identification number of contact, if a
 * contact is to be created.
 * @param p_previous_last_name Previous last name of contact, if a contact is
 * to be created.
 * @param p_registered_disabled_flag Indicates registered disabled value of
 * contact, if a contact is to be created. Valid values are defined in the
 * REGISTERED_DISABLED lookup type.
 * @param p_title Title of contact, if a contact is to be created. Valid values
 * are defined in the TITLE lookup type.
 * @param p_work_telephone Work telephone number of contact, if a contact is to
 * be created.
 * @param p_attribute_category This context value determines which Flexfield
 * Structure to use with the Descriptive flexfield segments for the contact's
 * person record, if a contact is to be created.
 * @param p_attribute1 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute2 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute3 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute4 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute5 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute6 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute7 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute8 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute9 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute10 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute11 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute12 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute13 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute14 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute15 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute16 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute17 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute18 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute19 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute20 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute21 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute22 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute23 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute24 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute25 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute26 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute27 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute28 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute29 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_attribute30 Descriptive flexfield segment of the contact's person
 * record, if a contact is to be created.
 * @param p_per_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield segments
 * for the contact's person record, if a contact is to be created.
 * @param p_per_information1 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information2 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information3 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information4 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information5 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information6 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information7 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information8 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information9 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information10 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information11 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information12 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information13 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information14 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information15 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information16 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information17 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information18 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information19 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information20 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information21 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information22 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information23 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information24 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information25 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information26 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information27 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information28 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information29 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_per_information30 Developer Descriptive flexfield segment of the
 * contact's person record, if a contact is to be created.
 * @param p_correspondence_language Correspondence language of contact, if a
 * contact is to be created.
 * @param p_honors Honors of contact, if a contact is to be created.
 * @param p_pre_name_adjunct Pre name adjunct of contact, if a contact is to be
 * created.
 * @param p_suffix Suffix of contact, if a contact is to be created.
 * @param p_create_mirror_flag The value 'Y' indicates to create a mirror
 * contact relationship, which is a new record with the person and contact
 * reversed. Otherwise the mirror contact relationship is not created.
 * @param p_mirror_type Contact type of the mirror contact relationship. Valid
 * values are defined in the CONTACT lookup type, but the value passed to this
 * parameter must be appropriate to the value passed to p_contact_type. For
 * example, if the relationship is a parental one, the mirror must be a child
 * relationship.
 * @param p_mirror_cont_attribute_cat This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments for the
 * mirror contact relationship record.
 * @param p_mirror_cont_attribute1 Descriptive flexfield segment for the mirror
 * contact relationship.
 * @param p_mirror_cont_attribute2 Descriptive flexfield segment for the mirror
 * contact relationship.
 * @param p_mirror_cont_attribute3 Descriptive flexfield segment for the mirror
 * contact relationship.
 * @param p_mirror_cont_attribute4 Descriptive flexfield segment for the mirror
 * contact relationship.
 * @param p_mirror_cont_attribute5 Descriptive flexfield segment for the mirror
 * contact relationship.
 * @param p_mirror_cont_attribute6 Descriptive flexfield segment for the mirror
 * contact relationship.
 * @param p_mirror_cont_attribute7 Descriptive flexfield segment for the mirror
 * contact relationship.
 * @param p_mirror_cont_attribute8 Descriptive flexfield segment for the mirror
 * contact relationship.
 * @param p_mirror_cont_attribute9 Descriptive flexfield segment for the mirror
 * contact relationship.
 * @param p_mirror_cont_attribute10 Descriptive flexfield segment for the
 * mirror contact relationship.
 * @param p_mirror_cont_attribute11 Descriptive flexfield segment for the
 * mirror contact relationship.
 * @param p_mirror_cont_attribute12 Descriptive flexfield segment for the
 * mirror contact relationship.
 * @param p_mirror_cont_attribute13 Descriptive flexfield segment for the
 * mirror contact relationship.
 * @param p_mirror_cont_attribute14 Descriptive flexfield segment for the
 * mirror contact relationship.
 * @param p_mirror_cont_attribute15 Descriptive flexfield segment for the
 * mirror contact relationship.
 * @param p_mirror_cont_attribute16 Descriptive flexfield segment for the
 * mirror contact relationship.
 * @param p_mirror_cont_attribute17 Descriptive flexfield segment for the
 * mirror contact relationship.
 * @param p_mirror_cont_attribute18 Descriptive flexfield segment for the
 * mirror contact relationship.
 * @param p_mirror_cont_attribute19 Descriptive flexfield segment for the
 * mirror contact relationship.
 * @param p_mirror_cont_attribute20 Descriptive flexfield segment for the
 * mirror contact relationship.
 * @param p_mirror_cont_information_cat This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield segments
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information1 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information2 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information3 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information4 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information5 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information6 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information7 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information8 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information9 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information10 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information11 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information12 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information13 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information14 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information15 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information16 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information17 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information18 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information19 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_mirror_cont_information20 Developer Descriptive flexfield segment
 * for the mirror contact relationship record.
 * @param p_contact_relationship_id If p_validate is false, this uniquely
 * identifies the relationship created. If p_validate is true this parameter
 * will be null.
 * @param p_ctr_object_version_number If p_validate is false, this will be set
 * to the version number of the contact relationship created. If p_validate is
 * true this parameter will be set to null.
 * @param p_per_person_id If p_validate is false, this will be set to the
 * unique identifier of the contact's person record, if a contact was created.
 * If p_validate is true, this will be set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created contact person, if a contact was to be
 * created. If p_validate is true, then the value will be null.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person record for the contact,
 * if a contact was to be created. If p_validate is true, then set to null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person record for the contact, if a
 * contact was to be created. If p_validate is true, then set to null.
 * @param p_full_name If p_validate is false, this will be set to the complete
 * full name of the contact if a contact was to be created. If p_validate is
 * true this will be null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then will be set to the identifier of the created contact's
 * comment record. If p_validate is true or no comment text was provided, then
 * will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Will always be set to false as a result of
 * calling this API.
 * @rep:displayname Create Contact Relationship
 * @rep:category BUSINESS_ENTITY PER_CONTACT_RELATIONSHIP
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_contact
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
  ,p_cont_information1              in        varchar2    default null
  ,p_cont_information2              in        varchar2    default null
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
  -- p_per_information_category - Obsolete parameter, do not use
  ,p_per_information1             in        varchar2    default null
  ,p_per_information2             in        varchar2    default null
  ,p_per_information3             in        varchar2    default null
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
--
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
-- |-----------------------< update_contact_relationship >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates contact relationship details for a given relationship.
 *
 * If you update the contact type, the link to the mirror contact relationship
 * is removed and the mirror contact relationship is not updated. If you do not
 * change the contact type, updates to the following parameters on either the
 * contact relationship or the mirror relationship will cause the reciprocal
 * relationship to be updated: p_date_start, p_start_life_reason_id,
 * p_date_end, p_end_life_reason_id, p_rltd_per_rsds_w_dsgntr_flag,
 * p_personal_flag.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contact relationship record must already exist.
 *
 * <p><b>Post Success</b><br>
 * The contact relationship will be updated. If the contact type is not
 * changed, the mirror contact relationship will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The API will not update the contact relationship and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_contact_relationship_id Identifier of the contact relationship
 * record to update.
 * @param p_contact_type Contact Type. Valid values are defined in the CONTACT
 * lookup type.
 * @param p_comments Comments for the contact relationship.
 * @param p_primary_contact_flag Value 'Y' identifies if this is the primary
 * contact relationship. Value 'N' identifies that this is not. There can only
 * be one primary contact relationship between the same person and contact.
 * @param p_third_party_pay_flag Value 'Y' indicates that the contact receives
 * third party payments from the person.
 * @param p_bondholder_flag Value 'Y' indicates that the contact is a
 * bondholder
 * @param p_date_start Start date of the contact relationship
 * @param p_start_life_reason_id Identifies the reason for the start of the
 * contact relationship, for Benefits purposes.
 * @param p_date_end End date of the contact relationship
 * @param p_end_life_reason_id Identifies the reason for the end of the contact
 * relationship, for Benefits purposes.
 * @param p_rltd_per_rsds_w_dsgntr_flag Value 'Y' indicates if the contact
 * resides at the same address as the person, otherwise 'N'. For Benefits
 * purposes.
 * @param p_personal_flag Value 'Y' indicates that the contact relationship is
 * a personal relationship. Otherwise 'N'. For Benefits purposes.
 * @param p_sequence_number Unique number to identify this relationship from
 * other relationships the same person is in.
 * @param p_dependent_flag Value 'Y' indicates that the contact is a dependent
 * of the person
 * @param p_beneficiary_flag Value 'Y' indicates that the contact is a
 * beneficiary.
 * @param p_cont_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
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
 * @param p_cont_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_cont_information1 Developer Descriptive flexfield segment.
 * @param p_cont_information2 Developer Descriptive flexfield segment.
 * @param p_cont_information3 Developer Descriptive flexfield segment.
 * @param p_cont_information4 Developer Descriptive flexfield segment.
 * @param p_cont_information5 Developer Descriptive flexfield segment.
 * @param p_cont_information6 Developer Descriptive flexfield segment.
 * @param p_cont_information7 Developer Descriptive flexfield segment.
 * @param p_cont_information8 Developer Descriptive flexfield segment.
 * @param p_cont_information9 Developer Descriptive flexfield segment.
 * @param p_cont_information10 Developer Descriptive flexfield segment.
 * @param p_cont_information11 Developer Descriptive flexfield segment.
 * @param p_cont_information12 Developer Descriptive flexfield segment.
 * @param p_cont_information13 Developer Descriptive flexfield segment.
 * @param p_cont_information14 Developer Descriptive flexfield segment.
 * @param p_cont_information15 Developer Descriptive flexfield segment.
 * @param p_cont_information16 Developer Descriptive flexfield segment.
 * @param p_cont_information17 Developer Descriptive flexfield segment.
 * @param p_cont_information18 Developer Descriptive flexfield segment.
 * @param p_cont_information19 Developer Descriptive flexfield segment.
 * @param p_cont_information20 Developer Descriptive flexfield segment.
 * @param p_object_version_number Pass in the current version number of the
 * contact relationship record to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * contact relationship record. If p_validate is true will be set to the same
 * value which was passed in.
 * @rep:displayname Update Contact Relationship
 * @rep:category BUSINESS_ENTITY PER_CONTACT_RELATIONSHIP
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_contact_relationship
  (p_validate                          in        boolean   default false
  ,p_effective_date                    in        date
  ,p_contact_relationship_id           in        number
  ,p_contact_type                      in        varchar2  default hr_api.g_varchar2
  ,p_comments                          in        long    default hr_api.g_varchar2
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
  ,p_cont_information1                   in        varchar2  default hr_api.g_varchar2
  ,p_cont_information2                   in        varchar2  default hr_api.g_varchar2
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
-- |-----------------------< delete_contact_relationship >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes contact relationship details for a given relationship.
 *
 * This API deletes the contact relationship record as identified by
 * p_contact_relationship_id. If a mirror contact relationship exists then this
 * relationship will also be deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contact relationship record, identified by p_contact_relationship_id
 * must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API sets no out parameters. The relationship record gets deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API will not delete the contact relationship and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_contact_relationship_id Identifier of the contact relationship
 * record to be deleted.
 * @param p_object_version_number Current version number of the contact
 * relationship record to be deleted.
 * @rep:displayname Delete Contact Relationship
 * @rep:category BUSINESS_ENTITY PER_CONTACT_RELATIONSHIP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_contact_relationship
  (p_validate                          in        boolean   default false
  ,p_contact_relationship_id           in        number
  ,p_object_version_number             in        number
  );
end hr_contact_rel_api;

 

/
