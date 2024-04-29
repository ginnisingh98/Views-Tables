--------------------------------------------------------
--  DDL for Package OTA_TPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPS_API" AUTHID CURRENT_USER as
/* $Header: ottpsapi.pkh 120.1 2005/10/02 02:08:40 aroussel $ */
/*#
 * The APIs in this package create, update, and delete personal or organization
 * training plans.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Training Plan
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_training_plan >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This business process creates a personal training plan or an organization
 * training plan for using against budget or cost values.
 *
 * This API, called from Self-Service as well as PUI forms, creates a record in
 * the OTA_TRAINING_PLANS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * User should be a valid employee on effective date
 *
 * <p><b>Post Success</b><br>
 * Training Plan record for the user is created in the database
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a training plan, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The businees group owning the plan.
 * @param p_time_period_id The time period within the calendar. Defines the
 * start and end date of the period.
 * @param p_plan_status_type_id Training Plan's status. Valid values are
 * defined by 'OTA_PLAN_USER_STATUS_TYPE' lookup type.
 * @param p_organization_id Foreign key to HR_ALL_ORGANIZATIONS. The
 * organization to which this plan applies.
 * @param p_person_id Identifies the person for whom you create the training
 * plan record.
 * @param p_budget_currency The currency for monetary budget values, and the
 * default currency for monetary cost values.
 * @param p_name The name of the training plan.
 * @param p_description Description of the training plan.
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
 * @param p_plan_source Training Plan's source. Valid values are defined by
 * 'OTA_TRAINING_PLAN_SOURCE' lookup type.
 * @param p_start_date Training Plan's start date.
 * @param p_end_date Training Plan's end date.
 * @param p_creator_person_id The person who has created the training plan
 * @param p_additional_member_flag Flag to identify if new components can be
 * added to a training plan. Value of 'N' means no new component can be added.
 * @param p_learning_path_id Learning path associated with the training plan.
 * @param p_contact_id Contact person for external Learners for whom training
 * plan(Learning path) has been created
 * @param p_training_plan_id The unique identifier for the training plan.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created ota training plan. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Training Plan
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Create_training_plan
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_time_period_id                in     number
  ,p_plan_status_type_id           in     varchar2
  ,p_organization_id               in     number   default null
  ,p_person_id                     in     number   default null
  ,p_budget_currency               in     varchar2
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_plan_source                   in     varchar2 default null --changed
  ,p_start_date                    in     date default null
  ,p_end_date                      in     date default null
  ,p_creator_person_id             in    number default null
  ,p_additional_member_flag       in varchar2 default null
  ,p_learning_path_id             in      number default null
  -- Modified for Bug#3479186
  ,p_contact_id                         in number default null
  ,p_training_plan_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_training_plan >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This business process updates a personal or organization training plan.
 *
 * This API, called from Self Service as well as PUI forms, updates a record in
 * the OTA_TRAINING_PLANS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * A valid training plan should exist
 *
 * <p><b>Post Success</b><br>
 * Training plan record is updated in the database
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the training plan, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_training_plan_id The unique identifier for the training plan record
 * @param p_object_version_number Pass in the current version number of the
 * training plan to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated training plan. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_time_period_id The time period within the calendar. Defines the
 * start and end date of the period.
 * @param p_plan_status_type_id Training Plan's status. Valid values are
 * defined by 'OTA_PLAN_USER_STATUS_TYPE' lookup type.
 * @param p_budget_currency The currency for monetary budget values, and the
 * default currency for monetary cost values.
 * @param p_name The name of the training plan.
 * @param p_description Description of the training plan.
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
 * @param p_plan_source Training Plan's source. Valid values are defined by the
 * 'OTA_TRAINING_PLAN_SOURCE' lookup type.
 * @param p_start_date Training Plan's start date.
 * @param p_end_date Training Plan's end date.
 * @param p_creator_person_id The person who has created the training plan.
 * @param p_additional_member_flag Flag to identify if new components can be
 * added to a training plan. Value of 'N' means no new component can be added.
 * @param p_learning_path_id Learning path associated with the training plan.
 * @param p_contact_id Contact person for external Learners for whom training
 * plan(Learning path) has been updated
 * @rep:displayname Update Training Plan
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_training_plan
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_training_plan_id              in     number
  ,p_object_version_number         in out nocopy number
  ,p_time_period_id                in     number
  ,p_plan_status_type_id           in     varchar2
  ,p_budget_currency               in     varchar2
  ,p_name                          in     varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_plan_source                   in     varchar2 default hr_api.g_varchar2  --changed
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_creator_person_id             in    number    default hr_api.g_number
  ,p_additional_member_flag        in varchar2     default hr_api.g_varchar2
  ,p_learning_path_id              in    number    default hr_api.g_number
  ,p_contact_id              in    number    default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_training_plan >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This business process deletes a training plan record.
 *
 * This API, called from Self Service as well as PUI forms, deletes a record
 * from the OTA_TRAINING_PLANS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * A valid training plan should exist for the user with no components under it.
 *
 * <p><b>Post Success</b><br>
 * Training plan record of the user is deleted
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the training plan record, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_training_plan_id The unique identifier for the training plan
 * record.
 * @param p_object_version_number Current version number of the
 * ota_training_plan to be deleted.
 * @rep:displayname Delete Training Plan
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_training_plan
  (p_validate                      in     boolean  default false
  ,p_training_plan_id              in     number
  ,p_object_version_number         in     number
  );
end ota_tps_api;

 

/
