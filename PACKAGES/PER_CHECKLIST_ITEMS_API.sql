--------------------------------------------------------
--  DDL for Package PER_CHECKLIST_ITEMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CHECKLIST_ITEMS_API" AUTHID CURRENT_USER as
/* $Header: pechkapi.pkh 120.1 2005/10/02 02:13:06 aroussel $ */
/*#
 * This package contains checklist item APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Checklist Item
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_checklist_items >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates checklist items for a person.
 *
 * A checklist is a list of user actions related to people management and
 * recruitment, such as "Check References" and "Reimburse Expenses". Against
 * each check item, users can record a status, date due, date achieved, and any
 * notes. The checklists are for user reference only; they do not perform any
 * actions
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person and checklist item must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The checklist item for the person is successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the checklist item and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person for whom you create the checklist
 * item record.
 * @param p_item_code Item Code. Valid values are defined by the CHECKLIST_ITEM
 * lookup type.
 * @param p_date_due Due date.
 * @param p_date_done Date completed.
 * @param p_status Status of the checklist item. Valid values are defined by
 * the CHECKLIST_STATUS lookup type.
 * @param p_notes Comment text.
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
 * @param p_checklist_item_id If p_validate is false, then this uniquely
 * identifies the created checklist item. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created checklist. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Checklist Item
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_checklist_items
( p_validate                       in boolean    default false
  ,p_effective_date                 in  date
  ,p_person_id                      in  number
  ,p_item_code                      in  varchar2
  ,p_date_due                       in  date      default null
  ,p_date_done                      in  date      default null
  ,p_status                         in  varchar2  default null
  ,p_notes                          in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_checklist_item_id              out nocopy number
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_checklist_items >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates checklist items for a person.
 *
 * A checklist is a list of user actions related to people management and
 * recruitment, such as "Check References" and "Reimburse Expenses". Against
 * each check item, users can record a status, date due, date achieved, and any
 * notes. The checklists are for user reference only; they do not perform any
 * actions
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The checklist item must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The checklist item for the person is successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the checklist item and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_checklist_item_id Identifies the checklist item record to be
 * modified.
 * @param p_person_id Identifies the person for whom you modify the checklist
 * item record.
 * @param p_item_code Item Code. Valid values are defined by the CHECKLIST_ITEM
 * lookup type.
 * @param p_date_due Due date.
 * @param p_date_done Date completed.
 * @param p_status Status of the checklist item. Valid values are defined by
 * the CHECKLIST_STATUS lookup type.
 * @param p_notes Comment text.
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
 * checklist to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated checklist. If p_validate is
 * true will be set to the same value which was passed in.
 * @rep:displayname Update Checklist Item
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_checklist_items
  (
   p_validate                       in boolean    default false
  ,p_effective_date                 in  date
  ,p_checklist_item_id              in  number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_item_code                      in  varchar2  default hr_api.g_varchar2
  ,p_date_due                       in  date      default hr_api.g_date
  ,p_date_done                      in  date      default hr_api.g_date
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_notes                          in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_checklist_items >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes checklist items for a person.
 *
 * A checklist is a list of user actions related to people management and
 * recruitment, such as "Check References" and "Reimburse Expenses". Against
 * each check item, users can record a status, date due, date achieved, and any
 * notes. The checklists are for user reference only; they do not perform any
 * actions
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The checklist item must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The checklist item for the person is successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the checklist item and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_checklist_item_id Identifies the checklist item record to be
 * deleted.
 * @param p_object_version_number Current version number of the checklist to be
 * deleted.
 * @rep:displayname Delete Checklist Item
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_checklist_items
  (
   p_validate                       in boolean        default false
  ,p_checklist_item_id              in  number
  ,p_object_version_number          in number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_checklist_item_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_checklist_item_id                 in number
   ,p_object_version_number        in number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< cre_upd_checklist_items >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This procedure is a wrapper used for creating or updating an
--              checklist item, depending on the data passed to it
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_effective_date               Yes  date
--   p_checklist_item_id            Yes  number    PK of record
--   p_person_id                    Yes  number
--   p_item_code                    Yes  varchar2
--   p_date_due                     No   date
--   p_date_done                    No   date
--   p_status                       Yes  varchar2
--   p_notes                        No   varchar2
--   p_attribute_category           No   varchar2  Descriptive Flexfield
--   p_attribute1                   No   varchar2  Descriptive Flexfield
--   p_attribute2                   No   varchar2  Descriptive Flexfield
--   p_attribute3                   No   varchar2  Descriptive Flexfield
--   p_attribute4                   No   varchar2  Descriptive Flexfield
--   p_attribute5                   No   varchar2  Descriptive Flexfield
--   p_attribute6                   No   varchar2  Descriptive Flexfield
--   p_attribute7                   No   varchar2  Descriptive Flexfield
--   p_attribute8                   No   varchar2  Descriptive Flexfield
--   p_attribute9                   No   varchar2  Descriptive Flexfield
--   p_attribute10                  No   varchar2  Descriptive Flexfield
--   p_attribute11                  No   varchar2  Descriptive Flexfield
--   p_attribute12                  No   varchar2  Descriptive Flexfield
--   p_attribute13                  No   varchar2  Descriptive Flexfield
--   p_attribute14                  No   varchar2  Descriptive Flexfield
--   p_attribute15                  No   varchar2  Descriptive Flexfield
--   p_attribute16                  No   varchar2  Descriptive Flexfield
--   p_attribute17                  No   varchar2  Descriptive Flexfield
--   p_attribute18                  No   varchar2  Descriptive Flexfield
--   p_attribute19                  No   varchar2  Descriptive Flexfield
--   p_attribute20                  No   varchar2  Descriptive Flexfield
--   p_attribute21                  No   varchar2  Descriptive Flexfield
--   p_attribute22                  No   varchar2  Descriptive Flexfield
--   p_attribute23                  No   varchar2  Descriptive Flexfield
--   p_attribute24                  No   varchar2  Descriptive Flexfield
--   p_attribute25                  No   varchar2  Descriptive Flexfield
--   p_attribute26                  No   varchar2  Descriptive Flexfield
--   p_attribute27                  No   varchar2  Descriptive Flexfield
--   p_attribute28                  No   varchar2  Descriptive Flexfield
--   p_attribute29                  No   varchar2  Descriptive Flexfield
--   p_attribute30                  No   varchar2  Descriptive Flexfield
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure cre_or_upd_checklist_items
  (
   p_validate                       in boolean    default false
  ,p_effective_date                 in  date
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_item_code                      in  varchar2  default hr_api.g_varchar2
  ,p_date_due                       in  date      default hr_api.g_date
  ,p_date_done                      in  date      default hr_api.g_date
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_notes                          in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in  varchar2  default hr_api.g_varchar2
  ,p_checklist_item_id              in out nocopy  number
  ,p_object_version_number          in out nocopy number
  );
--
--
end per_checklist_items_api;

 

/
