--------------------------------------------------------
--  DDL for Package OTA_CONFERENCE_SERVER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CONFERENCE_SERVER_API" AUTHID CURRENT_USER as
/* $Header: otcfsapi.pkh 120.3 2006/07/13 12:24:25 niarora noship $ */
/*#
 * This package contains the Conference server APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Conference Server
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_conference_server >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the Conference server.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The OWC site record must exist.
 *
 * <p><b>Post Success</b><br>
 *  The Conference server is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a Conference server record, and raises an error.
 *
 * @param p_effective_date Reference date for validating that lookup values are applicable
 * during the start to end active date range. This date does not determine when the changes take effect.
 * @param p_conference_server_id The unique identifier for the Conference server.
 * @param p_name The name of the Conference server.
 * @param p_description The description of the Conference server.
 * @param p_url The url of the Conference server.
 * @param p_type The type of the conference server.
 * @param p_owc_site_id The OWC site.
 * @param p_owc_auth_token The OWC site authorization token.
 * @param p_end_date_active If p_validate is false, then set to the effective end date
 * for the created Conference server. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the version number
 * of the created Conference server. If p_validate is true, then the value will be null.
 * @param p_business_group_id The business group owning the conference server.
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
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Create Conference Server.
 * @rep:category BUSINESS_ENTITY OTA_CONFERENCE_SERVER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure create_conference_server
  (p_effective_date               in  date
  ,p_conference_server_id         out nocopy number
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2         default null
  ,p_url                          in  varchar2
  ,p_type                         in  varchar2
  ,p_owc_site_id                  in  varchar2         default null
  ,p_owc_auth_token               in  varchar2         default null
  ,p_end_date_active              in  date             default null
  ,p_object_version_number        out nocopy number
  ,p_business_group_id            in  number
  ,p_attribute_category           in  varchar2         default null
  ,p_attribute1                   in  varchar2         default null
  ,p_attribute2                   in  varchar2         default null
  ,p_attribute3                   in  varchar2         default null
  ,p_attribute4                   in  varchar2         default null
  ,p_attribute5                   in  varchar2         default null
  ,p_attribute6                   in  varchar2         default null
  ,p_attribute7                   in  varchar2         default null
  ,p_attribute8                   in  varchar2         default null
  ,p_attribute9                   in  varchar2         default null
  ,p_attribute10                  in  varchar2         default null
  ,p_attribute11                  in  varchar2         default null
  ,p_attribute12                  in  varchar2         default null
  ,p_attribute13                  in  varchar2         default null
  ,p_attribute14                  in  varchar2         default null
  ,p_attribute15                  in  varchar2         default null
  ,p_attribute16                  in  varchar2         default null
  ,p_attribute17                  in  varchar2         default null
  ,p_attribute18                  in  varchar2         default null
  ,p_attribute19                  in  varchar2         default null
  ,p_attribute20                  in  varchar2         default null
  ,p_validate                     in  boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_conference_server >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Conference server.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Conference server record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Conference server record is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API did not update a Conference server record, and raised an error.
 *
 * @param p_effective_date Reference date for validating that lookup values are applicable during the
 * start to end active date range. This date does not determine when the changes take effect.
 * @param p_conference_server_id The unique identifier for the Conference server.
 * @param p_name The name of the Conference server.
 * @param p_description The description of the Conference server.
 * @param p_url The url of the Conference server.
 * @param p_type The type of the conference server.
 * @param p_owc_site_id The OWC site.
 * @param p_owc_auth_token The OWC site authorization token.
 * @param p_end_date_active If p_validate is false, then set to the effective end date for
 * the created Conference server. If p_validate is true, then set to null.
 * @param p_business_group_id If p_validate is false, then set to the version number of the
 * created Conference server. If p_validate is true, then the value will be null.
 * @param p_object_version_number The business group owning the conference server.
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
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Updates Conference server.
 * @rep:category BUSINESS_ENTITY OTA_CONFERENCE_SERVER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_conference_server
  (p_effective_date               in  date
  ,p_conference_server_id         in  number
  ,p_name                         in  varchar2
  ,p_description                  in  varchar2
  ,p_url                          in  varchar2         default hr_api.g_varchar2
  ,p_type                         in  varchar2         default hr_api.g_varchar2
  ,p_owc_site_id                  in  varchar2         default hr_api.g_varchar2
  ,p_owc_auth_token               in  varchar2         default hr_api.g_varchar2
  ,p_end_date_active              in  date             default hr_api.g_date
  ,p_business_group_id            in  number
  ,p_object_version_number        in out nocopy number
  ,p_attribute_category           in  varchar2         default hr_api.g_varchar2
  ,p_attribute1                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute2                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute3                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute4                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute5                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute6                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute7                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute8                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute9                   in  varchar2         default hr_api.g_varchar2
  ,p_attribute10                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute11                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute12                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute13                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute14                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute15                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute16                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute17                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute18                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute19                  in  varchar2         default hr_api.g_varchar2
  ,p_attribute20                  in  varchar2         default hr_api.g_varchar2
  ,p_validate                     in  boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_conference_server >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the Conference server.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Conference server record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The Conference server is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Conference server record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_conference_server_id The unique identifier for the Conference server.
 * @param p_object_version_number The business group owning the conference server.
 * @rep:displayname Deletes Conference Server.
 * @rep:category BUSINESS_ENTITY OTA_CONFERENCE_SERVER
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_conference_server
  (p_validate                      in     boolean  default false
  ,p_conference_server_id          in     number
  ,p_object_version_number         in     number
  );
end ota_conference_server_api;

 

/
