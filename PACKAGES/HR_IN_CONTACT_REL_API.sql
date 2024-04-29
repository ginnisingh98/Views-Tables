--------------------------------------------------------
--  DDL for Package HR_IN_CONTACT_REL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IN_CONTACT_REL_API" AUTHID CURRENT_USER AS
/* $Header: pecrlini.pkh 120.1 2005/10/02 02:39 aroussel $ */
/*#
 * This package contains contact relationship APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contact Relationship for India
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_in_contact >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a main contact relationship between a person and a contact.
 *
 * It is effectively an alternative to the API hr_contact_rel_api. Creating a
 * contact involves using two people's identification numbers, the main person
 * and their contact. If the contact does not exist, HRMS sets up a new person
 * with the system person type of 'OTHER'.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contact person's identification number must be a valid value from
 * PER_PEOPLE_F or be blank.
 *
 * <p><b>Post Success</b><br>
 * Creates a main contact relationship between the person and the contact.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the contact relationship and raises and error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_start_date The effective start date of the contact person.
 * @param p_business_group_id Identifier for the business group of the contact
 * person.
 * @param p_person_id Identifies the person for whom you create the contact
 * relationship record.
 * @param p_contact_person_id Identifies the contact person for whom you create
 * the contact relationship record.
 * @param p_contact_type Type of contact. Valid values are defined by 'CONTACT'
 * lookup type.
 * @param p_ctr_comments Comments for the main contact relationship.
 * @param p_primary_contact_flag Indicates whether contact is primary contact
 * for the employee.
 * @param p_date_start The start date of the relationship
 * @param p_start_life_reason_id Identifier for the reason the relationship
 * started.
 * @param p_date_end The end date of the relationship.
 * @param p_end_life_reason_id Identifier for the reason the relationship
 * ended.
 * @param p_rltd_per_rsds_w_dsgntr_flag Indicates whether the two people in the
 * relationship live at the same address. Defaults 'N'.
 * @param p_personal_flag Indicates whether the relationship is a personal
 * relationship.
 * @param p_sequence_number The unique sequence number for the relationship
 * used to identify contacts with a third party organization.
 * @param p_cont_attribute_category Contact Attribute Category
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
 * @param p_guardian_name Guardian Name
 * @param p_guardian_birth_date Guardian Birth Date
 * @param p_guardian_address Guardian Address
 * @param p_guardian_telephone Guardian Telephone Number
 * @param p_third_party_pay_flag Indicates whether the contact receives third
 * party payment from the employee. Default 'N'
 * @param p_bondholder_flag Indicates whether a contact person is a potential
 * EE bondholder. Default 'N'
 * @param p_dependent_flag Dependent flag. Default 'N'
 * @param p_beneficiary_flag Beneficiary flag. Default 'N'
 * @param p_last_name The last name of the contact person.
 * @param p_sex Gender of the contact person.
 * @param p_person_type_id Identifier corresponding to Person Type. If this
 * value is omitted (new record) then the person_type_id of the default `OTHER'
 * system person type in the person's business group is used.
 * @param p_per_comments Comments for the person record.
 * @param p_date_of_birth The date of birth of the contact person.
 * @param p_email_address Email address of the contact person.
 * @param p_first_name The first name of the contact person.
 * @param p_alias_name Preferred name of the contact person if different from
 * first name.
 * @param p_marital_status Marital status of the contact person. Valid values
 * are defined by 'MAR_STATUS' lookup type
 * @param p_middle_names Middle name(s) of the contact person
 * @param p_nationality Nationality of the contact person. Valid values are
 * defined by 'NATIONALITY' lookup type
 * @param p_national_identifier National identifier of the contact.
 * @param p_previous_last_name The previous last name of the contact person.
 * @param p_registered_disabled_flag Indicates whether contact person is
 * classified as disabled. Valid values are defined by 'REGISTERED_DISABLED'
 * lookup type.
 * @param p_title The title of the contact person. Valid values are defined by
 * 'TITLE' lookup type
 * @param p_work_telephone Work telephone of the contact person.
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
 * @param p_resident_status Residential status of the contact. Valid values are
 * defined by 'IN_RESIDENTIAL_STATUS' lookup type. Default 'RO'
 * @param p_correspondence_language Correspondence language
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
 * @param p_contact_relationship_id Identifier of the main contact
 * relationship. If p_validate is false, this uniquely identifies the
 * relationship created. If p_validate is true this parameter will be null.
 * @param p_ctr_object_version_number If p_validate is false, this will be set
 * to the version number of the created contact relationship. If p_validate is
 * true, then value will be set to null.
 * @param p_per_person_id If p_validate is false, then this uniquely identifies
 * the person created. If p_validate is true, then set to null.
 * @param p_per_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
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
 * null and the person type is not EMP,EMP_APL, EX_EMP or EX_EMP_APL.
 * @rep:displayname Create Contact for India
 * @rep:category BUSINESS_ENTITY PER_CONTACT_RELATIONSHIP
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_in_contact
  (p_validate                     IN        BOOLEAN     default false
  ,p_start_date                   IN        DATE
  ,p_business_group_id            IN        NUMBER
  ,p_person_id                    IN        NUMBER
  ,p_contact_person_id            IN        NUMBER      default null
  ,p_contact_type                 IN        varchar2
  ,p_ctr_comments                 IN        varchar2    default null
  ,p_primary_contact_flag         IN        varchar2    default 'N'
  ,p_date_start                   IN        DATE        default null
  ,p_start_life_reason_id         IN        NUMBER      default null
  ,p_date_end                     IN        DATE        default null
  ,p_end_life_reason_id           IN        NUMBER      default null
  ,p_rltd_per_rsds_w_dsgntr_flag  IN        VARCHAR2    default 'N'
  ,p_personal_flag                IN        VARCHAR2    default 'N'
  ,p_sequence_number              IN        NUMBER      default null
  ,p_cont_attribute_category      IN        VARCHAR2    default null
  ,p_cont_attribute1              IN        VARCHAR2    default null
  ,p_cont_attribute2              IN        VARCHAR2    default null
  ,p_cont_attribute3              IN        VARCHAR2    default null
  ,p_cont_attribute4              IN        VARCHAR2    default null
  ,p_cont_attribute5              IN        VARCHAR2    default null
  ,p_cont_attribute6              IN        VARCHAR2    default null
  ,p_cont_attribute7              IN        VARCHAR2    default null
  ,p_cont_attribute8              IN        VARCHAR2    default null
  ,p_cont_attribute9              IN        VARCHAR2    default null
  ,p_cont_attribute10             IN        VARCHAR2    default null
  ,p_cont_attribute11             IN        VARCHAR2    default null
  ,p_cont_attribute12             IN        VARCHAR2    default null
  ,p_cont_attribute13             IN        VARCHAR2    default null
  ,p_cont_attribute14             IN        VARCHAR2    default null
  ,p_cont_attribute15             IN        VARCHAR2    default null
  ,p_cont_attribute16             IN        VARCHAR2    default null
  ,p_cont_attribute17             IN        VARCHAR2    default null
  ,p_cont_attribute18             IN        VARCHAR2    default null
  ,p_cont_attribute19             IN        VARCHAR2    default null
  ,p_cont_attribute20             IN        VARCHAR2    default null
  ,p_guardian_name                IN        VARCHAR2    default null
  ,p_guardian_birth_date          IN        VARCHAR2    default null
  ,p_guardian_address             IN        VARCHAR2    default null
  ,p_guardian_telephone           IN        VARCHAR2    default null
  ,p_third_party_pay_flag         IN        VARCHAR2    default 'N'
  ,p_bondholder_flag              IN        VARCHAR2    default 'N'
  ,p_dependent_flag               IN        VARCHAR2    default 'N'
  ,p_beneficiary_flag             IN        VARCHAR2    default 'N'
  ,p_last_name                    IN        VARCHAR2    default null
  ,p_sex                          IN        VARCHAR2    default null
  ,p_person_type_id               IN        NUMBER      default null
  ,p_per_comments                 IN        VARCHAR2    default null
  ,p_date_of_birth                IN        DATE        default null
  ,p_email_address                IN        VARCHAR2    default null
  ,p_first_name                   IN        VARCHAR2    default null
  ,p_alias_name                   IN        VARCHAR2    default null
  ,p_marital_status               IN        VARCHAR2    default null
  ,p_middle_names                 IN        VARCHAR2    default null
  ,p_nationality                  IN        VARCHAR2    default null
  ,p_national_identifier          IN        VARCHAR2    default null
  ,p_previous_last_name           IN        VARCHAR2    default null
  ,p_registered_disabled_flag     IN        VARCHAR2    default null
  ,p_title                        IN        VARCHAR2    default null
  ,p_work_telephone               IN        VARCHAR2    default null
  ,p_attribute_category           IN        VARCHAR2    default null
  ,p_attribute1                   IN        VARCHAR2    default null
  ,p_attribute2                   IN        VARCHAR2    default null
  ,p_attribute3                   IN        VARCHAR2    default null
  ,p_attribute4                   IN        VARCHAR2    default null
  ,p_attribute5                   IN        VARCHAR2    default null
  ,p_attribute6                   IN        VARCHAR2    default null
  ,p_attribute7                   IN        VARCHAR2    default null
  ,p_attribute8                   IN        VARCHAR2    default null
  ,p_attribute9                   IN        VARCHAR2    default null
  ,p_attribute10                  IN        VARCHAR2    default null
  ,p_attribute11                  IN        VARCHAR2    default null
  ,p_attribute12                  IN        VARCHAR2    default null
  ,p_attribute13                  IN        VARCHAR2    default null
  ,p_attribute14                  IN        VARCHAR2    default null
  ,p_attribute15                  IN        VARCHAR2    default null
  ,p_attribute16                  IN        VARCHAR2    default null
  ,p_attribute17                  IN        VARCHAR2    default null
  ,p_attribute18                  IN        VARCHAR2    default null
  ,p_attribute19                  IN        VARCHAR2    default null
  ,p_attribute20                  IN        VARCHAR2    default null
  ,p_attribute21                  IN        VARCHAR2    default null
  ,p_attribute22                  IN        VARCHAR2    default null
  ,p_attribute23                  IN        VARCHAR2    default null
  ,p_attribute24                  IN        VARCHAR2    default null
  ,p_attribute25                  IN        VARCHAR2    default null
  ,p_attribute26                  IN        VARCHAR2    default null
  ,p_attribute27                  IN        VARCHAR2    default null
  ,p_attribute28                  IN        VARCHAR2    default null
  ,p_attribute29                  IN        VARCHAR2    default null
  ,p_attribute30                  IN        VARCHAR2    default null
  ,p_resident_status              IN        VARCHAR2    DEFAULT null
  ,p_correspondence_language      IN        VARCHAR2    default null
  ,p_honors                       IN        VARCHAR2    default null
  ,p_pre_name_adjunct             IN        VARCHAR2    default null
  ,p_suffix                       IN        VARCHAR2    default null
  ,p_create_mirror_flag           IN        VARCHAR2    default 'N'
  ,p_mirror_type                  IN        VARCHAR2    default null
  ,p_mirror_cont_attribute_cat    IN        VARCHAR2    default null
  ,p_mirror_cont_attribute1       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute2       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute3       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute4       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute5       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute6       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute7       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute8       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute9       IN        VARCHAR2    default null
  ,p_mirror_cont_attribute10      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute11      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute12      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute13      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute14      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute15      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute16      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute17      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute18      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute19      IN        VARCHAR2    default null
  ,p_mirror_cont_attribute20      IN        VARCHAR2    default null
  ,p_contact_relationship_id      OUT NOCOPY NUMBER
  ,p_ctr_object_version_number    OUT NOCOPY NUMBER
  ,p_per_person_id                OUT NOCOPY NUMBER
  ,p_per_object_version_number    OUT NOCOPY NUMBER
  ,p_per_effective_start_date     OUT NOCOPY DATE
  ,p_per_effective_end_date       OUT NOCOPY DATE
  ,p_full_name                    OUT NOCOPY VARCHAR2
  ,p_per_comment_id               OUT NOCOPY NUMBER
  ,p_name_combination_warning     OUT NOCOPY BOOLEAN
  ,p_orig_hire_warning            OUT NOCOPY BOOLEAN
  ) ;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_in_contact_relationship >------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the main contact relationship details of a contact.
 *
 * It modifies all contact relationship details for a contact. Use this API to
 * update the contact relationship record as identified by
 * p_contact_relationship_id. If you update the contact type, the link to the
 * mirror relationship is removed and the mirror contact relationship is not
 * updated. If you update the relationship type of contact relationship or the
 * mirror relationship, the link between relationships is removed and the
 * reciprocal relationship is not updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contact relationship record, identified by p_contact_relationship_id
 * must already exist.
 *
 * <p><b>Post Success</b><br>
 * Updates the main contact relationship of the contact.
 *
 * <p><b>Post Failure</b><br>
 * The API will not update the contact relationship and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_contact_relationship_id Identifies the contact relationship record
 * to be modified.
 * @param p_contact_type Type of contact. Valid values are defined by 'CONTACT'
 * lookup type
 * @param p_comments Contact relationship comment text.
 * @param p_primary_contact_flag Indicates whether contact is primary contact
 * for the employee.
 * @param p_third_party_pay_flag Indicates whether the contact receives third
 * party payment from the employee.
 * @param p_bondholder_flag Indicates whether a contact person is a potential
 * EE bondholder.
 * @param p_date_start The start date of the relationship.
 * @param p_start_life_reason_id Identifier for the reason the relationship
 * started.
 * @param p_date_end The end date of the relationship.
 * @param p_end_life_reason_id Identifier for the reason the relationship
 * ended.
 * @param p_rltd_per_rsds_w_dsgntr_flag Indicates whether the two people in the
 * relationship live at the same address. Defaults 'N'.
 * @param p_personal_flag Indicates whether relationship is a personal
 * relationship. Defaults 'N'.
 * @param p_sequence_number The unique sequence number for the relationship
 * used to identify contacts with a third party organization.
 * @param p_dependent_flag Dependent flag. Default 'N'.
 * @param p_beneficiary_flag Beneficiary flag. Default 'N'.
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
 * @param p_guardian_name Guardian Name.
 * @param p_guardian_birth_date Guardian Birth Date.
 * @param p_guardian_address Guardian Address.
 * @param p_guardian_telephone Guardian Telephone Number.
 * @param p_object_version_number Pass in the current version number of the
 * Contact Relationship to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Contact
 * Relationship. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Contact Relationship for India
 * @rep:category BUSINESS_ENTITY PER_CONTACT_RELATIONSHIP
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_in_contact_relationship
  (p_validate                          IN        BOOLEAN   default false
  ,p_effective_date                    IN        DATE
  ,p_contact_relationship_id           IN        NUMBER
  ,p_contact_type                      IN        VARCHAR2  default hr_api.g_varchar2
  ,p_comments                          IN        LONG      default hr_api.g_varchar2
  ,p_primary_contact_flag              IN        VARCHAR2  default hr_api.g_varchar2
  ,p_third_party_pay_flag              IN        VARCHAR2  default hr_api.g_varchar2
  ,p_bondholder_flag                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_date_start                        IN        DATE      default hr_api.g_date
  ,p_start_life_reason_id              IN        NUMBER    default hr_api.g_number
  ,p_date_end                          IN        DATE      default hr_api.g_date
  ,p_end_life_reason_id                IN        NUMBER    default hr_api.g_number
  ,p_rltd_per_rsds_w_dsgntr_flag       IN        VARCHAR2  default hr_api.g_varchar2
  ,p_personal_flag                     IN        VARCHAR2  default hr_api.g_varchar2
  ,p_sequence_number                   IN        NUMBER    default hr_api.g_number
  ,p_dependent_flag                    IN        VARCHAR2  default hr_api.g_varchar2
  ,p_beneficiary_flag                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute_category           IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute1                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute2                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute3                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute4                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute5                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute6                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute7                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute8                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute9                   IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute10                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute11                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute12                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute13                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute14                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute15                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute16                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute17                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute18                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute19                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_cont_attribute20                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_guardian_name                     IN        VARCHAR2  default hr_api.g_varchar2
  ,p_guardian_birth_date               IN        VARCHAR2  default hr_api.g_varchar2
  ,p_guardian_address                  IN        VARCHAR2  default hr_api.g_varchar2
  ,p_guardian_telephone                IN        VARCHAR2  default hr_api.g_varchar2
  ,p_object_version_number             IN OUT NOCOPY    number
  );
     END hr_in_contact_rel_api;

 

/
