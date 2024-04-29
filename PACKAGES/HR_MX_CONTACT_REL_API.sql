--------------------------------------------------------
--  DDL for Package HR_MX_CONTACT_REL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MX_CONTACT_REL_API" AUTHID CURRENT_USER AS
/* $Header: hrmxwrcr.pkh 120.1 2005/10/02 02:36:20 aroussel $ */
/*#
 * This package contains APIs to maintain contact relationship information for
 * Mexico.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contact Relationship for Mexico
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_mx_contact >-------------------------|
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
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date The start date on which to create the contact's person
 * record, if the contact person does not already exist.
 * @param p_business_group_id Business group of the person.
 * @param p_person_id Identifies the person for whom you create the contact
 * record.
 * @param p_contact_person_id If passed, identifies the contact person of the
 * contact relationship. If not passed, then a contact will be created in the
 * system.
 * @param p_contact_type Contact Type. Valid values are defined in the CONTACT
 * lookup type.
 * @param p_ctr_comments Comments for the contact relationship.
 * @param p_primary_contact_flag Value 'Y' identifies if this is the primary
 * contact relationship. Value 'N' identifies that this is not. There can only
 * be one primary contact relationship between the same person and contact.
 * @param p_date_start Start date of the contact relationship.
 * @param p_start_life_reason_id Identifies the reason for the start of the
 * contact relationship for Benefits purposes.
 * @param p_date_end End date of the contact relationship.
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
 * @param p_third_party_pay_flag Value 'Y' indicates that the contact receives
 * third party payments from the person.
 * @param p_bondholder_flag Value 'Y' indicates that the contact is a
 * bondholder.
 * @param p_dependent_flag Value 'Y' indicates that the contact is a dependent
 * of the person.
 * @param p_beneficiary_flag Value 'Y' indicates that the contact is a
 * beneficiary.
 * @param p_paternal_last_name Paternal last name of the person.
 * @param p_sex Sex of contact, if a contact is to be created. Valid values are
 * defined in the SEX lookup type.
 * @param p_person_type_id Person Type of contact, if a contact is to be
 * created. Must be of system person type of OTHER.
 * @param p_per_comments Comments for contact's person record.
 * @param p_date_of_birth Date of birth of contact, if a contact is to be
 * created.
 * @param p_email_address Email address of contact, if a contact is to be
 * created.
 * @param p_first_name First name of contact, if a contact is to be created.
 * @param p_known_as Preferred name of contact, if a contact is to be created.
 * @param p_marital_status Marital status of contact, if a contact is to be
 * created. Valid values are defined in the MAR_STATUS lookup type.
 * @param p_second_name Second name of the person.
 * @param p_nationality Nationality of contact, if a contact is to be created.
 * Valid values are defined in the NATIONALITY lookup type.
 * @param p_curp_id Mexican national identifier.
 * @param p_previous_last_name Obsolete parameter, do not use.
 * @param p_registered_disabled_flag Indicates registered disabled value of
 * contact, if a contact is to be created. Valid values are defined in the
 * REGISTERED_DISABLED lookup type.
 * @param p_title Title of contact, if a contact is to be created. Valid values
 * are defined in the TITLE lookup type.
 * @param p_work_telephone Work telephone number of contact, if a contact is to
 * be created.
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
 * @param p_maternal_last_name Maternal last name of the person.
 * @param p_correspondence_language Correspondence language of contact, if a
 * contact is to be created.
 * @param p_honors Honors of contact, if a contact is to be created.
 * @param p_pre_name_adjunct Prefix before the person's name.
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
 * @param p_contact_relationship_id If p_validate is false, then set to the
 * unique identifier of the relationship created. If p_validate is true, then
 * the value will be null.
 * @param p_ctr_object_version_number If p_validate is false, then set to the
 * version number of the contact relationship created. If p_validate is true,
 * then the value will be null.
 * @param p_per_person_id If p_validate is false, then set to the unique
 * identifier of the contact's person record, if a contact was created. If
 * p_validate is true, then the value will be null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created contact. If p_validate is true, then the value
 * will be null.
 * @param p_per_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created person record for the contact,
 * if a contact was to be created. If p_validate is true, then the value will
 * be null.
 * @param p_per_effective_end_date If p_validate is false, then set to the
 * effective end date for the created person record for the contact, if a
 * contact was to be created. If p_validate is true, then the value will be
 * null.
 * @param p_full_name If p_validate is false, then set to the complete full
 * name of the contact if a contact was to be created. If p_validate is true,
 * then the value will be null.
 * @param p_per_comment_id If p_validate is false and comment text was
 * provided, then set to the identifier of the created contact's comment
 * record. If p_validate is true or no comment text was provided, then the
 * value will be null.
 * @param p_name_combination_warning If set to true, then the combination of
 * last name, first name and date of birth existed prior to calling this API.
 * @param p_orig_hire_warning Will always be set to false as a result of
 * calling this API.
 * @rep:displayname Create Contact Relationship for Mexico
 * @rep:category BUSINESS_ENTITY PER_CONTACT_RELATIONSHIP
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
*/
--
-- {End Of Comments}
--
PROCEDURE CREATE_MX_CONTACT
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
    ,p_third_party_pay_flag         in        varchar2    default 'N'
    ,p_bondholder_flag              in        varchar2    default 'N'
    ,p_dependent_flag               in        varchar2    default 'N'
    ,p_beneficiary_flag             in        varchar2    default 'N'
    ,p_paternal_last_name           in        varchar2    default null
    ,p_sex                          in        varchar2    default null
    ,p_person_type_id               in        number      default null
    ,p_per_comments                 in        varchar2    default null
    ,p_date_of_birth                in        date        default null
    ,p_email_address                in        varchar2    default null
    ,p_first_name                   in        varchar2    default null
    ,p_known_as                     in        varchar2    default null
    ,p_marital_status               in        varchar2    default null
    ,p_second_name                  in        varchar2    default null
    ,p_nationality                  in        varchar2    default null
    ,p_curp_id                      in        varchar2    default null
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
    ,p_maternal_last_name           in        varchar2    default null
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
END HR_MX_CONTACT_REL_API;

 

/
