--------------------------------------------------------
--  DDL for Package HR_IN_CONTACT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IN_CONTACT_EXTRA_INFO_API" AUTHID CURRENT_USER AS
/* $Header: pereiini.pkh 120.1 2005/10/02 02:44 aroussel $ */
/*#
 * This package contains contact extra information APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Contact Extra Information for India
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_in_contact_extra_info >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates extra information for a contact relationship.
 *
 * For an existing contact relationship, an extra information record is
 * inserted for the information category 'IN_NOMINATION_DETAILS'.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Contact Relationship and Contact Information Type must exist.
 *
 * <p><b>Post Success</b><br>
 * The contact extra information will be created for the contact relationship.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the contact extra info and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_contact_relationship_id Contact relationship for which the extra
 * information applies.
 * @param p_information_type Information type to which the extra information
 * applies.
 * @param p_nomination_type Benefit Type for the contact in the nomination.
 * Valid values are defined by 'IN_NOMINATION_TYPES' lookup type.
 * @param p_percent_share Percent Share in the nomination of the contact.
 * @param p_nomination_change_reason Nomination change reason.
 * @param p_cei_attribute_category Determines context of the cei_attribute
 * descriptive flexfield in parameters.
 * @param p_cei_attribute1 Descriptive flexfield segment.
 * @param p_cei_attribute2 Descriptive flexfield segment.
 * @param p_cei_attribute3 Descriptive flexfield segment.
 * @param p_cei_attribute4 Descriptive flexfield segment.
 * @param p_cei_attribute5 Descriptive flexfield segment.
 * @param p_cei_attribute6 Descriptive flexfield segment.
 * @param p_cei_attribute7 Descriptive flexfield segment.
 * @param p_cei_attribute8 Descriptive flexfield segment.
 * @param p_cei_attribute9 Descriptive flexfield segment.
 * @param p_cei_attribute10 Descriptive flexfield segment.
 * @param p_cei_attribute11 Descriptive flexfield segment.
 * @param p_cei_attribute12 Descriptive flexfield segment.
 * @param p_cei_attribute13 Descriptive flexfield segment.
 * @param p_cei_attribute14 Descriptive flexfield segment.
 * @param p_cei_attribute15 Descriptive flexfield segment.
 * @param p_cei_attribute16 Descriptive flexfield segment.
 * @param p_cei_attribute17 Descriptive flexfield segment.
 * @param p_cei_attribute18 Descriptive flexfield segment.
 * @param p_cei_attribute19 Descriptive flexfield segment.
 * @param p_cei_attribute20 Descriptive flexfield segment.
 * @param p_contact_extra_info_id If p_validate is false, uniquely identifies
 * the contact extra info created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created contact extra information. If p_validate is
 * true, then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created contact extra information. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created contact extra information. If p_validate
 * is true, then set to null.
 * @rep:displayname Create Contact Extra Information for India
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_CONTACT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_in_contact_extra_info
 (p_validate                    IN      boolean  default false,
  p_effective_date              IN      date,
  p_contact_relationship_id	IN	NUMBER,
  p_information_type		IN	VARCHAR2,

  p_nomination_type             IN	VARCHAR2,
  p_percent_share		IN	VARCHAR2,
  p_nomination_change_reason    IN	VARCHAR2	DEFAULT NULL,
  p_cei_attribute_category      IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute1              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute2              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute3              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute4              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute5              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute6              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute7              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute8              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute9              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute10             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute11             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute12             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute13             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute14             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute15             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute16             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute17             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute18             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute19             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute20             IN      VARCHAR2        DEFAULT NULL,
  p_contact_extra_info_id       OUT NOCOPY number,
  p_object_version_number       OUT NOCOPY number,
  p_effective_start_date        OUT NOCOPY DATE,
  p_effective_end_date	        OUT NOCOPY DATE
  ) ;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_in_contact_extra_info >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates extra information for a contact relationship.
 *
 * For an existing contact relationship extra information, the record is
 * updated for the information category 'IN_NOMINATION_DETAILS'.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contact extra info as identified by the in parameter
 * p_contact_extra_info_id and the in out parameter p_object_version_number
 * must already exist.
 *
 * <p><b>Post Success</b><br>
 * The contact extra information will be updated for the contact relationship.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the contact extra info and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_contact_relationship_id Primary key of the parent contact
 * relationship.
 * @param p_information_type Information type the extra info applies to.
 * @param p_nomination_type Benefit Type for the contact in the nomination.
 * Valid values are defined by 'IN_NOMINATION_TYPES' lookup type.
 * @param p_percent_share Percent Share in the nomination of the contact.
 * @param p_nomination_change_reason Nomination change reason.
 * @param p_cei_attribute_category Determines context of the cei_attribute
 * descriptive flexfield in parameters.
 * @param p_cei_attribute1 Descriptive flexfield segment.
 * @param p_cei_attribute2 Descriptive flexfield segment.
 * @param p_cei_attribute3 Descriptive flexfield segment.
 * @param p_cei_attribute4 Descriptive flexfield segment.
 * @param p_cei_attribute5 Descriptive flexfield segment.
 * @param p_cei_attribute6 Descriptive flexfield segment.
 * @param p_cei_attribute7 Descriptive flexfield segment.
 * @param p_cei_attribute8 Descriptive flexfield segment.
 * @param p_cei_attribute9 Descriptive flexfield segment.
 * @param p_cei_attribute10 Descriptive flexfield segment.
 * @param p_cei_attribute11 Descriptive flexfield segment.
 * @param p_cei_attribute12 Descriptive flexfield segment.
 * @param p_cei_attribute13 Descriptive flexfield segment.
 * @param p_cei_attribute14 Descriptive flexfield segment.
 * @param p_cei_attribute15 Descriptive flexfield segment.
 * @param p_cei_attribute16 Descriptive flexfield segment.
 * @param p_cei_attribute17 Descriptive flexfield segment.
 * @param p_cei_attribute18 Descriptive flexfield segment.
 * @param p_cei_attribute19 Descriptive flexfield segment.
 * @param p_cei_attribute20 Descriptive flexfield segment.
 * @param p_contact_extra_info_id Primary key of the contact extra information.
 * @param p_object_version_number Pass in the current version number of the
 * contact extra information to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * contact extra information. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated contact extra information row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated contact extra information row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Contact Extra Information for India
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_CONTACT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_in_contact_extra_info
 (p_validate                    IN      boolean        DEFAULT false,
  p_effective_date              IN      date,
  p_datetrack_update_mode	IN	VARCHAR2,
  p_contact_relationship_id	IN	NUMBER          DEFAULT hr_api.g_number,
  p_information_type		IN	VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_nomination_type             IN	VARCHAR2	DEFAULT hr_api.g_varchar2,
  p_percent_share		IN	VARCHAR2	DEFAULT hr_api.g_varchar2,
  p_nomination_change_reason    IN	VARCHAR2	DEFAULT hr_api.g_varchar2,
  p_cei_attribute_category      IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute1              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute2              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute3              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute4              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute5              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute6              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute7              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute8              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute9              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute10             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute11             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute12             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute13             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute14             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute15             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute16             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute17             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute18             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute19             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute20             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_contact_extra_info_id       IN      number,
  p_object_version_number       IN OUT NOCOPY number,
  p_effective_start_date        OUT NOCOPY DATE,
  p_effective_end_date	        OUT NOCOPY DATE
  ) ;
   END hr_in_contact_extra_info_api;

 

/
