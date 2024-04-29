--------------------------------------------------------
--  DDL for Package HR_CONTACT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTACT_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: pereiapi.pkh 120.1 2005/10/02 02:23:41 aroussel $ */
/*#
 * This package contains APIs to maintain contact extra information records
 * against a contact relationship.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Contact Extra Information
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_contact_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates extra information for a given contact relationship.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contact relationship must exist. The Contact Extra Information Type must
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The contact extra information record is created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the contact extra information record and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_contact_relationship_id Identifier for the contact relationship for
 * which the contact extra information record is to be created.
 * @param p_information_type Contact Extra Information Type.
 * @param p_cei_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_cei_information1 Developer Descriptive flexfield segment.
 * @param p_cei_information2 Developer Descriptive flexfield segment.
 * @param p_cei_information3 Developer Descriptive flexfield segment.
 * @param p_cei_information4 Developer Descriptive flexfield segment.
 * @param p_cei_information5 Developer Descriptive flexfield segment.
 * @param p_cei_information6 Developer Descriptive flexfield segment.
 * @param p_cei_information7 Developer Descriptive flexfield segment.
 * @param p_cei_information8 Developer Descriptive flexfield segment.
 * @param p_cei_information9 Developer Descriptive flexfield segment.
 * @param p_cei_information10 Developer Descriptive flexfield segment.
 * @param p_cei_information11 Developer Descriptive flexfield segment.
 * @param p_cei_information12 Developer Descriptive flexfield segment.
 * @param p_cei_information13 Developer Descriptive flexfield segment.
 * @param p_cei_information14 Developer Descriptive flexfield segment.
 * @param p_cei_information15 Developer Descriptive flexfield segment.
 * @param p_cei_information16 Developer Descriptive flexfield segment.
 * @param p_cei_information17 Developer Descriptive flexfield segment.
 * @param p_cei_information18 Developer Descriptive flexfield segment.
 * @param p_cei_information19 Developer Descriptive flexfield segment.
 * @param p_cei_information20 Developer Descriptive flexfield segment.
 * @param p_cei_information21 Developer Descriptive flexfield segment.
 * @param p_cei_information22 Developer Descriptive flexfield segment.
 * @param p_cei_information23 Developer Descriptive flexfield segment.
 * @param p_cei_information24 Developer Descriptive flexfield segment.
 * @param p_cei_information25 Developer Descriptive flexfield segment.
 * @param p_cei_information26 Developer Descriptive flexfield segment.
 * @param p_cei_information27 Developer Descriptive flexfield segment.
 * @param p_cei_information28 Developer Descriptive flexfield segment.
 * @param p_cei_information29 Developer Descriptive flexfield segment.
 * @param p_cei_information30 Developer Descriptive flexfield segment.
 * @param p_cei_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
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
 * the contact extra information record created. If p_validate is true, set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created contact extra information record. If
 * p_validate is true, then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created contact extra information
 * record. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created contact extra information record. If
 * p_validate is true, then set to null.
 * @rep:displayname Create Contact Extra Information
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_CONTACT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_contact_extra_info
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date,
--  ,p_business_group_id             in     number
--  ,p_non_mandatory_arg             in     number   default null
  p_contact_relationship_id	IN	NUMBER,
  p_information_type		IN	VARCHAR2,
  p_cei_information_category	IN	VARCHAR2	DEFAULT NULL,
  p_cei_information1		IN	VARCHAR2	DEFAULT NULL,
  p_cei_information2		IN	VARCHAR2	DEFAULT NULL,
  p_cei_information3		IN	VARCHAR2	DEFAULT NULL,
  p_cei_information4		IN	VARCHAR2	DEFAULT NULL,
  p_cei_information5		IN	VARCHAR2	DEFAULT NULL,
  p_cei_information6		IN	VARCHAR2        DEFAULT NULL,
  p_cei_information7            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information8            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information9            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information10           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information11           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information12           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information13           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information14           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information15           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information16           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information17           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information18           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information19           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information20           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information21           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information22           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information23           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information24           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information25           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information26           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information27           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information28           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information29           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information30           IN      VARCHAR2        DEFAULT NULL,
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
  p_cei_attribute20             IN      VARCHAR2        DEFAULT NULL
  ,p_contact_extra_info_id            out nocopy number
  ,p_object_version_number            out nocopy number,
--  ,p_some_warning                     out boolean
  p_effective_start_date OUT NOCOPY DATE,
  p_effective_end_date	 OUT NOCOPY DATE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_contact_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Contact Extra Information records.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contact extra information record must already exist.
 *
 * <p><b>Post Success</b><br>
 * The contact extra information record is updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the contact extra information record and raises an
 * error.
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
 * @param p_contact_extra_info_id Identifies the contact extra information
 * record to update.
 * @param p_contact_relationship_id Identifies the contact relationship to
 * which the extra information record pertains.
 * @param p_information_type The contact extra information type.
 * @param p_object_version_number Pass in the current version number of the
 * contact extra information record to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * contact extra information record. If p_validate is true will be set to the
 * same value which was passed in.
 * @param p_cei_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_cei_information1 Developer Descriptive flexfield segment.
 * @param p_cei_information2 Developer Descriptive flexfield segment.
 * @param p_cei_information3 Developer Descriptive flexfield segment.
 * @param p_cei_information4 Developer Descriptive flexfield segment.
 * @param p_cei_information5 Developer Descriptive flexfield segment.
 * @param p_cei_information6 Developer Descriptive flexfield segment.
 * @param p_cei_information7 Developer Descriptive flexfield segment.
 * @param p_cei_information8 Developer Descriptive flexfield segment.
 * @param p_cei_information9 Developer Descriptive flexfield segment.
 * @param p_cei_information10 Developer Descriptive flexfield segment.
 * @param p_cei_information11 Developer Descriptive flexfield segment.
 * @param p_cei_information12 Developer Descriptive flexfield segment.
 * @param p_cei_information13 Developer Descriptive flexfield segment.
 * @param p_cei_information14 Developer Descriptive flexfield segment.
 * @param p_cei_information15 Developer Descriptive flexfield segment.
 * @param p_cei_information16 Developer Descriptive flexfield segment.
 * @param p_cei_information17 Developer Descriptive flexfield segment.
 * @param p_cei_information18 Developer Descriptive flexfield segment.
 * @param p_cei_information19 Developer Descriptive flexfield segment.
 * @param p_cei_information20 Developer Descriptive flexfield segment.
 * @param p_cei_information21 Developer Descriptive flexfield segment.
 * @param p_cei_information22 Developer Descriptive flexfield segment.
 * @param p_cei_information23 Developer Descriptive flexfield segment.
 * @param p_cei_information24 Developer Descriptive flexfield segment.
 * @param p_cei_information25 Developer Descriptive flexfield segment.
 * @param p_cei_information26 Developer Descriptive flexfield segment.
 * @param p_cei_information27 Developer Descriptive flexfield segment.
 * @param p_cei_information28 Developer Descriptive flexfield segment.
 * @param p_cei_information29 Developer Descriptive flexfield segment.
 * @param p_cei_information30 Developer Descriptive flexfield segment.
 * @param p_cei_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
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
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated contact extra information row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated contact extra information row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Contact Extra Information
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_CONTACT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_contact_extra_info
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date,
--  ,p_business_group_id             in     number
--  ,p_non_mandatory_arg             in     number   default null
  p_datetrack_update_mode	IN	VARCHAR2,
  p_contact_extra_info_id	IN	NUMBER,
  p_contact_relationship_id	IN	NUMBER		DEFAULT hr_api.g_number,
  p_information_type		IN	VARCHAR2	DEFAULT hr_api.g_varchar2,
  p_object_version_number       IN OUT NOCOPY NUMBER,
  p_cei_information_category    IN      VARCHAR2	DEFAULT hr_api.g_varchar2,
  p_cei_information1            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information2            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information3            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information4            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information5            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information6            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information7            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information8            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information9            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information10           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information11           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information12           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information13           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information14           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information15           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information16           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information17           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information18           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information19           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information20           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information21           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information22           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information23           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information24           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information25           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information26           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information27           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information28           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information29           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information30           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
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
--  ,p_id                               out number
--  ,p_object_version_number            out number
--  ,p_some_warning                     out boolean
  p_effective_start_date OUT NOCOPY DATE,
  p_effective_end_date	 OUT NOCOPY DATE
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_contact_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Contact Extra Information records.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The contact extra information record must exist as of the effective date.
 *
 * <p><b>Post Success</b><br>
 * The contact extra information record is deleted according to the rules of
 * the datetrack delete mode specified.
 *
 * <p><b>Post Failure</b><br>
 * The contact extra information record is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_contact_extra_info_id Identifies the contact extra information
 * record to delete.
 * @param p_object_version_number Pass in the current version number of the
 * contact extra information record to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted contact extra information row which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted contact extra information row which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @rep:displayname Delete Contact Extra Information
 * @rep:category BUSINESS_ENTITY PER_PERSONAL_CONTACT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_contact_extra_info
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date,
--  ,p_business_group_id             in     number
--  ,p_non_mandatory_arg             in     number   default null
  p_datetrack_delete_mode	IN	VARCHAR2,
  p_contact_extra_info_id	IN	NUMBER,
  p_object_version_number	IN OUT NOCOPY NUMBER,
--  ,p_id                               out number
--  ,p_object_version_number            out number
--  ,p_some_warning                     out boolean
  p_effective_start_date OUT NOCOPY DATE,
  p_effective_end_date	 OUT NOCOPY DATE
  );
--
END hr_contact_extra_info_api;

 

/
