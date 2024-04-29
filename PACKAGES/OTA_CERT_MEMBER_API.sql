--------------------------------------------------------
--  DDL for Package OTA_CERT_MEMBER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_MEMBER_API" AUTHID CURRENT_USER as
/* $Header: otcmbapi.pkh 120.3 2006/07/13 11:48:43 niarora noship $ */
/*#
 * This package contains learning certification member APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Certification Member
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_certification_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the certification member.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Learning certification record must exist.
 *
 * <p><b>Post Success</b><br>
 * The certification member is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a certification member record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_certification_id The unique identifier for the parent certification record.
 * @param p_object_id The unique identifier for the catalog object, Course.
 * @param p_object_type Object type for the certification member. Valid values are
 * defined by 'OTA_OBJECT_TYPE'  lookup type.
 * @param p_member_sequence The sequence number of the member under certification.
 * @param p_business_group_id The business group owning the certification member record of the certification.
 * @param p_start_date_active From this date the object would become active.
 * @param p_end_date_active After this date the object would no longer be active.
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
 * @param p_certification_member_id The unique identifier for the certification member record.
 * @param p_object_version_number If p_validate is false, then set to the version number of the
 * created certification member. If p_validate is true, then the value will be null.
 * @rep:displayname Create Certification Member
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_certification_member
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_certification_id               in     number
  ,p_object_id                      in     number
  ,p_object_type                    in     varchar2
  ,p_member_sequence                in     number
  ,p_business_group_id              in     number
  ,p_start_date_active              in     date     default null
  ,p_end_date_active                in     date     default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_certification_member_id           out nocopy number
  ,p_object_version_number             out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_certification_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the certification member.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The certification member record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The certification member is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the certification member record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_certification_member_id The unique identifier for the certification member record.
 * @param p_object_version_number Passes in the current version number of the certification
 * member to be updated. When the API completes if p_validate is false, will be set to the
 * new version number of the updated certification member. If p_validate is true will be set
 * to the same value which was passed in.
 * @param p_object_id The unique identifier for the catalog object, Course.
 * @param p_object_type Object type for the certification member. Valid values are defined
 * by 'OTA_OBJECT_TYPE'  lookup type.
 * @param p_member_sequence The sequence number of the member under certification.
 * @param p_start_date_active From this date the object becomes active.
 * @param p_end_date_active After this date the object is no longer active.
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
 * @rep:displayname Update Certification Member
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_certification_member
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_certification_member_id        in     number
  ,p_object_version_number          in out nocopy number
  ,p_object_id                      in     number
  ,p_object_type                    in     varchar2
  ,p_member_sequence                in     number
  ,p_start_date_active              in     date     default null
  ,p_end_date_active                in     date     default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_certification_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the certification member.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The certification member record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The certification member is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the certification member record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_certification_member_id The unique identifier for the certification member record.
 * @param p_object_version_number Current version number of the certification member to be deleted.
 * @rep:displayname Delete Certification Member
 * @rep:category BUSINESS_ENTITY OTA_CERTIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_certification_member
  (p_validate                      in     boolean  default false
  ,p_certification_member_id       in     number
  ,p_object_version_number         in     number
  );
end ota_cert_member_api;

 

/
