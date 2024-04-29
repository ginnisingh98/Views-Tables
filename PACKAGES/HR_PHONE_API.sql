--------------------------------------------------------
--  DDL for Package HR_PHONE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PHONE_API" AUTHID CURRENT_USER as
/* $Header: pephnapi.pkh 120.1.12010000.2 2009/03/12 10:03:48 dparthas ship $ */
/*#
 * This package contains phone APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Phone
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_phone >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a phone record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * A person must exist before a phone can be created for them.
 *
 * <p><b>Restricted Usage Notes</b><br>
 * Each phone is linked to a parent table; currently the only supported table
 * is PER_PEOPLE_F. By HR/TCA merge, party_id is supported. This doesn't
 * require parent_id and parent_table.
 *
 * <p><b>Post Success</b><br>
 * The phone record is created.
 *
 * <p><b>Post Failure</b><br>
 * Phone record is not created and an error is raised.
 * @param p_date_from Date phone number becomes effective.
 * @param p_date_to Date phone number is no longer effective.
 * @param p_phone_type Type of phone. Valid values are defines by PHONE_TYPE
 * lookup type.
 * @param p_phone_number Phone number
 * @param p_parent_id Identification number of the parent row that this phone
 * number relates to. Currently the parent_id must relate to a valid person_id
 * on the PER_PEOPLE_F table.
 * @param p_parent_table Name of the parent table. Currently, only
 * PER_ALL_PEOPLE_F table is supported.
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
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_party_id Identification of the party record that this phone number
 * relates to.
 * @param p_validity Valid times phone numbers can be used. Valid values are
 * defined by IRC_CONTACT_TIMES lookup type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created person. If p_validate is true, then the value
 * will be null.
 * @param p_phone_id If p_validate is false, then this uniquely identifies the
 * phone created. If p_validate is true, then set to null.
 * @rep:displayname Create Phone
 * @rep:category BUSINESS_ENTITY PER_PHONE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_phone
  (p_date_from                   in     date,
  p_date_to                      in     date             default null,
  p_phone_type                   in     varchar2,
  p_phone_number                 in     varchar2,
  p_parent_id                    in     number           default null,
  p_parent_table                 in     varchar2         default null,
  p_attribute_category           in     varchar2         default null,
  p_attribute1                   in     varchar2         default null,
  p_attribute2                   in     varchar2         default null,
  p_attribute3                   in     varchar2         default null,
  p_attribute4                   in     varchar2         default null,
  p_attribute5                   in     varchar2         default null,
  p_attribute6                   in     varchar2         default null,
  p_attribute7                   in     varchar2         default null,
  p_attribute8                   in     varchar2         default null,
  p_attribute9                   in     varchar2         default null,
  p_attribute10                  in     varchar2         default null,
  p_attribute11                  in     varchar2         default null,
  p_attribute12                  in     varchar2         default null,
  p_attribute13                  in     varchar2         default null,
  p_attribute14                  in     varchar2         default null,
  p_attribute15                  in     varchar2         default null,
  p_attribute16                  in     varchar2         default null,
  p_attribute17                  in     varchar2         default null,
  p_attribute18                  in     varchar2         default null,
  p_attribute19                  in     varchar2         default null,
  p_attribute20                  in     varchar2         default null,
  p_attribute21                  in     varchar2         default null,
  p_attribute22                  in     varchar2         default null,
  p_attribute23                  in     varchar2         default null,
  p_attribute24                  in     varchar2         default null,
  p_attribute25                  in     varchar2         default null,
  p_attribute26                  in     varchar2         default null,
  p_attribute27                  in     varchar2         default null,
  p_attribute28                  in     varchar2         default null,
  p_attribute29                  in     varchar2         default null,
  p_attribute30                  in     varchar2         default null,
  p_validate                     in     boolean          default false,
  p_effective_date               in     date,
  p_party_id                     in     number           default null,
  p_validity                     in     varchar2         default null,
  p_object_version_number           out nocopy number,
  p_phone_id                        out nocopy number
  );    -- HR/TCA merge
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_phone >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the phone record for a person.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The phone record to be updated must exist.
 *
 * <p><b>Post Success</b><br>
 * Phone record is updated.
 *
 * <p><b>Post Failure</b><br>
 * Phone record is not updated and an error is raised.
 * @param p_phone_id Identifies the phone record to be updated.
 * @param p_date_from Date from which the phone number is valid.
 * @param p_date_to Date when the phone number is no longer valid.
 * @param p_phone_type Type of phone. Valid values are defines by PHONE_TYPE
 * lookup type.
 * @param p_phone_number Phone number
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
 * @param p_object_version_number Pass in the current version number of the
 * phone record to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated phone record. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_party_id Identification of the party record that this phone number
 * relates to
 * @param p_validity Valid times phone numbers can be used. Valid values are
 * defined by IRC_CONTACT_TIMES lookup type.
 * @rep:displayname Update Phone
 * @rep:category BUSINESS_ENTITY PER_PHONE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_phone
 (p_phone_id                     in number,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_phone_type                   in varchar2         default hr_api.g_varchar2,
  p_phone_number                 in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean          default false,
  p_effective_date               in date,
  p_party_id                     in number           default hr_api.g_number,
  p_validity                     in varchar2         default hr_api.g_varchar2
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_phone >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a phone record.
 *
 * Use this API to delete a phone record on the PER_PHONES table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The phone record to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * Phone record is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Phone record is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_phone_id Identifies the phone record to delete.
 * @param p_object_version_number Current version number of the phone to be
 * deleted.
 * @rep:displayname Delete Phone
 * @rep:category BUSINESS_ENTITY PER_PHONE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_phone
  (p_validate                       in     boolean  default false
  ,p_phone_id                       in     number
  ,p_object_version_number          in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_or_update_phone >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the phone record if exists, else creates a new phone
 * record.
 *
 * This API creates a new phone record if one does not exist. If the phone
 * record exists, then this API updates that phone record. This API helps in
 * case the user is not sure whether the phone record already exists or not. By
 * calling this API, if the record exists, then that record is updated,
 * otherwise a new phone record is created for that person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The parent entity specified by p_parent_id must exist on the parent table
 * specified by p_parent_table.
 *
 * <p><b>Post Success</b><br>
 * Creates the phone if phone record doesn't exist or updates the existing
 * phone record.
 *
 * <p><b>Post Failure</b><br>
 * Phone record is not created or updated and an error is raised.
 * @param p_update_mode If an existing PHONE record is being modified,
 * indicates which mode to use when updating the record. You must set to either
 * UPDATE or CORRECT. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_phone_id Identifies the phone record.
 * @param p_object_version_number Pass in the current version number of the
 * phone to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated phone. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_date_from Date from which the phone number is valid.
 * @param p_date_to Date when the phone number is no longer valid.
 * @param p_phone_type Type of phone. Valid values are defines by PHONE_TYPE
 * lookup type.
 * @param p_phone_number Phone number
 * @param p_parent_id Identification number of the parent row that this phone
 * number relates to. Currently the parent_id must relate to a valid person_id
 * on the PER_PEOPLE_F table.
 * @param p_parent_table Name of the parent table. Currently, only
 * PER_ALL_PEOPLE_F table is supported.
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
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_party_id Identification of the party record that this phone number
 * relates to.
 * @param p_validity Valid times phone numbers can be used. Valid values are
 * defined by IRC_CONTACT_TIMES lookup type.
 * @rep:displayname Create or Update Phone
 * @rep:category BUSINESS_ENTITY PER_PHONE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_or_update_phone
 (p_update_mode                  in     varchar2     default hr_api.g_correction,
  p_phone_id                     in out nocopy number,
  p_object_version_number        in out nocopy number,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_phone_type                   in varchar2         default hr_api.g_varchar2,
  p_phone_number                 in varchar2         default hr_api.g_varchar2,
  p_parent_id                    in number           default hr_api.g_number,
  p_parent_table                 in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false,
  p_effective_date               in date,
  p_party_id                     in number           default hr_api.g_number,
  p_validity                     in varchar2         default hr_api.g_varchar2
 );
--
end hr_phone_api;

/
