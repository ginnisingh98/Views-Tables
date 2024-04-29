--------------------------------------------------------
--  DDL for Package OTA_RESOURCE_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RESOURCE_USAGE_API" AUTHID CURRENT_USER as
/* $Header: otrudapi.pkh 120.1 2005/10/02 02:07:53 aroussel $ */
/*#
 * This package creates, updates, and deletes resource associations at the
 * offering level.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Resource Usage
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_resource >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API associates a resource with an offering.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Offering must exist.
 *
 * <p><b>Post Success</b><br>
 * Record for resource association with an offering is created.
 *
 * <p><b>Post Failure</b><br>
 * The record for resource association with an offering is not created and an
 * error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_activity_version_id Populates the activity_version_id corresponding
 * to the offering.
 * @param p_required_flag This flag identifies a resource as Required or
 * Useful. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_start_date {@rep:casecolumn OTA_RESOURCE_USAGES.START_DATE}
 * @param p_supplied_resource_id {@rep:casecolumn
 * OTA_RESOURCE_USAGES.SUPPLIED_RESOURCE_ID}
 * @param p_comments If profile 'HR:Use Standard Attachments
 * (PER_ATTACHMENT_USAGE)' is set to 'No', this text serves as HR-specific
 * attachment text.
 * @param p_end_date {@rep:casecolumn OTA_RESOURCE_USAGES.END_DATE}
 * @param p_quantity {@rep:casecolumn OTA_RESOURCE_USAGES.QUANTITY}
 * @param p_resource_type It identifies the type of the resource. Valid values
 * are defined by 'RESOURCE_TYPE' lookup type
 * @param p_role_to_play It identifies the role of the resource. Valid values
 * are defined by 'TRAINER_PARTICIPATION' lookup type.
 * @param p_usage_reason It identifies the reason for the resource. Valid
 * values are defined by the 'RESOURCE_USAGE_REASON' lookup type.
 * @param p_rud_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segment
 * @param p_rud_information1 Descriptive flexfield segment.
 * @param p_rud_information2 Descriptive flexfield segment.
 * @param p_rud_information3 Descriptive flexfield segment.
 * @param p_rud_information4 Descriptive flexfield segment.
 * @param p_rud_information5 Descriptive flexfield segment.
 * @param p_rud_information6 Descriptive flexfield segment.
 * @param p_rud_information7 Descriptive flexfield segment.
 * @param p_rud_information8 Descriptive flexfield segment.
 * @param p_rud_information9 Descriptive flexfield segment.
 * @param p_rud_information10 Descriptive flexfield segment.
 * @param p_rud_information11 Descriptive flexfield segment.
 * @param p_rud_information12 Descriptive flexfield segment.
 * @param p_rud_information13 Descriptive flexfield segment.
 * @param p_rud_information14 Descriptive flexfield segment.
 * @param p_rud_information15 Descriptive flexfield segment.
 * @param p_rud_information16 Descriptive flexfield segment.
 * @param p_rud_information17 Descriptive flexfield segment.
 * @param p_rud_information18 Descriptive flexfield segment.
 * @param p_rud_information19 Descriptive flexfield segment.
 * @param p_rud_information20 Descriptive flexfield segment.
 * @param p_resource_usage_id {@rep:casecolumn
 * OTA_RESOURCE_USAGES.RESOURCE_USAGE_ID}
 * @param p_object_version_number If p_validate is false, then the number is
 * set to the version number of the created external learning. If p_validate is
 * true, then the value is null.
 * @param p_offering_id The unique identifer of the offering for which the
 * resources are being defined
 * @rep:displayname Create Resource
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_OFFER_RES_CHKLST
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Create_resource
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_activity_version_id            in     number  default null
  ,p_required_flag                  in     varchar2
  ,p_start_date                     in     date
  ,p_supplied_resource_id           in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_end_date                       in     date     default null
  ,p_quantity                       in     number   default null
  ,p_resource_type                  in     varchar2 default null
  ,p_role_to_play                   in     varchar2 default null
  ,p_usage_reason                   in     varchar2 default null
  ,p_rud_information_category       in     varchar2 default null
  ,p_rud_information1               in     varchar2 default null
  ,p_rud_information2               in     varchar2 default null
  ,p_rud_information3               in     varchar2 default null
  ,p_rud_information4               in     varchar2 default null
  ,p_rud_information5               in     varchar2 default null
  ,p_rud_information6               in     varchar2 default null
  ,p_rud_information7               in     varchar2 default null
  ,p_rud_information8               in     varchar2 default null
  ,p_rud_information9               in     varchar2 default null
  ,p_rud_information10              in     varchar2 default null
  ,p_rud_information11              in     varchar2 default null
  ,p_rud_information12              in     varchar2 default null
  ,p_rud_information13              in     varchar2 default null
  ,p_rud_information14              in     varchar2 default null
  ,p_rud_information15              in     varchar2 default null
  ,p_rud_information16              in     varchar2 default null
  ,p_rud_information17              in     varchar2 default null
  ,p_rud_information18              in     varchar2 default null
  ,p_rud_information19              in     varchar2 default null
  ,p_rud_information20              in     varchar2 default null
  ,p_resource_usage_id                 out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_offering_id                    in     number   default null
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_resource >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a resource-to-offering association.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Record for resource must exist.
 *
 * <p><b>Post Success</b><br>
 * Record for resource association with an offering is updated.
 *
 * <p><b>Post Failure</b><br>
 * Record for resource association with an offering is not updated and an error
 * is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_resource_usage_id {@rep:casecolumn
 * OTA_RESOURCE_USAGES.RESOURCE_USAGE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * resource to be updated. When the API completes if p_validate is false, the
 * number is set to the new version number of the updated resource. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_activity_version_id Populates the activity_version_id corresponding
 * to the offering.
 * @param p_required_flag This flag identifies resource as Required or Useful.
 * Valid values are defined by the 'YES_NO' lookup type.
 * @param p_start_date {@rep:casecolumn OTA_RESOURCE_USAGES.START_DATE}
 * @param p_supplied_resource_id {@rep:casecolumn
 * OTA_RESOURCE_USAGES.SUPPLIED_RESOURCE_ID}
 * @param p_comments If the profile 'HR:Use Standard Attachments
 * (PER_ATTACHMENT_USAGE)' is set to 'No', this text serves as HR-specific
 * attachment text.
 * @param p_end_date {@rep:casecolumn OTA_RESOURCE_USAGES.END_DATE}
 * @param p_quantity {@rep:casecolumn OTA_RESOURCE_USAGES.QUANTITY}
 * @param p_resource_type Identifies the type of the resource. Valid values are
 * defined by the 'RESOURCE_TYPE' lookup type
 * @param p_role_to_play Identifies the role of the resource. Valid values are
 * defined by the 'TRAINER_PARTICIPATION' lookup type
 * @param p_usage_reason Identifies the reason for the resource. Valid values
 * are defined by the 'RESOURCE_USAGE_REASON' lookup type.
 * @param p_rud_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segment
 * @param p_rud_information1 Descriptive flexfield segment.
 * @param p_rud_information2 Descriptive flexfield segment.
 * @param p_rud_information3 Descriptive flexfield segment.
 * @param p_rud_information4 Descriptive flexfield segment.
 * @param p_rud_information5 Descriptive flexfield segment.
 * @param p_rud_information6 Descriptive flexfield segment.
 * @param p_rud_information7 Descriptive flexfield segment.
 * @param p_rud_information8 Descriptive flexfield segment.
 * @param p_rud_information9 Descriptive flexfield segment.
 * @param p_rud_information10 Descriptive flexfield segment.
 * @param p_rud_information11 Descriptive flexfield segment.
 * @param p_rud_information12 Descriptive flexfield segment.
 * @param p_rud_information13 Descriptive flexfield segment.
 * @param p_rud_information14 Descriptive flexfield segment.
 * @param p_rud_information15 Descriptive flexfield segment.
 * @param p_rud_information16 Descriptive flexfield segment.
 * @param p_rud_information17 Descriptive flexfield segment.
 * @param p_rud_information18 Descriptive flexfield segment.
 * @param p_rud_information19 Descriptive flexfield segment.
 * @param p_rud_information20 Descriptive flexfield segment.
 * @param p_offering_id The unique identifer of the offering for which the
 * resources are being defined
 * @rep:displayname Update Resource
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_OFFER_RES_CHKLST
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_resource
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_resource_usage_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_required_flag                in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_supplied_resource_id         in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_quantity                     in     number    default hr_api.g_number
  ,p_resource_type                in     varchar2  default hr_api.g_varchar2
  ,p_role_to_play                 in     varchar2  default hr_api.g_varchar2
  ,p_usage_reason                 in     varchar2  default hr_api.g_varchar2
  ,p_rud_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_rud_information1             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information2             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information3             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information4             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information5             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information6             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information7             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information8             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information9             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information10            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information11            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information12            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information13            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information14            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information15            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information16            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information17            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information18            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information19            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information20            in     varchar2  default hr_api.g_varchar2
  ,p_offering_id                  in     number    default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_resource >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a resource-to-offering association.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Record for the resource must exist.
 *
 * <p><b>Post Success</b><br>
 * Record for resource association with an offering is deleted from database.
 *
 * <p><b>Post Failure</b><br>
 * Record for resource association with an offering is not deleted and an error
 * is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_resource_usage_id {@rep:casecolumn
 * OTA_RESOURCE_USAGES.RESOURCE_USAGE_ID}
 * @param p_object_version_number Pass in the current version number of the
 * resource to be deleted.
 * @rep:displayname Delete Resource
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_OFFER_RES_CHKLST
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Delete_resource
  (p_validate                      in     boolean  default false
  ,p_resource_usage_id             in     number
  ,p_object_version_number         in     number
  );

end ota_resource_usage_api;

 

/
