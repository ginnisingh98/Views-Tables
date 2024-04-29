--------------------------------------------------------
--  DDL for Package OTA_TPM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TPM_API" AUTHID CURRENT_USER as
/* $Header: ottpmapi.pkh 120.1 2005/10/02 02:08:35 aroussel $ */
/*#
 * The APIs in this package create, update, and delete Personal and
 * Organization Training Plan components.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Training Plan Component
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_training_plan_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This business process creates a personal or organization training plan
 * component record within a training plan.
 *
 * This API, called from Self-Service as well as PUI forms, inserts a record
 * into the OTA_TRAINING_PLAN_MEMBERS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * A valid training plan should exist under which training plan components can
 * be created.
 *
 * <p><b>Post Success</b><br>
 * The training plan member record is created in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a training plan component record, and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group owning the component record
 * and the training plan.
 * @param p_training_plan_id The target training plan.
 * @param p_activity_version_id The Identifier of a course to be added to the
 * plan. Either this or the activity (course) definition must be specified, not
 * both. The default is null.
 * @param p_activity_definition_id The Identifier of an activity (course)
 * definition that is to be added to the plan. Either this or the course must
 * be specified, not both. The default is null.
 * @param p_member_status_type_id The Training Plan Component's Type. Valid
 * values are defined by the 'OTA_MEMBER_USER_STATUS_TYPE' lookup type.
 * @param p_target_completion_date The date at which the component is expected
 * to be completed by. The default is null.
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
 * @param p_assignment_id Identifies the assignment for which you create the
 * Ota_training_plan_members record.
 * @param p_source_id Training Plan Component source identifier
 * @param p_source_function Training Plan Component's source function. Valid
 * values are defined by the 'OTA_PLAN_COMPONENT_SOURCE' lookup type.
 * @param p_cancellation_reason Training Plan Component's cancellation reason.
 * Valid values are defined by the 'OTA_PLAN_CANCELLATION_SOURCE' lookup type.
 * @param p_earliest_start_date The Training Plan Component's start date.
 * @param p_creator_person_id Person who creates the training plan component.
 * @param p_training_plan_member_id The unique identifier for the component
 * record.
 * @param p_object_version_number If p_validate is false, then the number is
 * set to the version number of the created training plan component. If
 * p_validate is true, then the value is null.
 * @rep:displayname Create Training Plan Component
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_training_plan_member
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_training_plan_id              in     number
  ,p_activity_version_id           in     number   default null
  ,p_activity_definition_id        in     number   default null
  ,p_member_status_type_id         in     varchar2
  ,p_target_completion_date        in     date     default null
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
  ,p_assignment_id                 in     number default null
  ,p_source_id                     in     number default  null
  ,p_source_function               in     varchar2 default null
  ,p_cancellation_reason           in     varchar2 default null
  ,p_earliest_start_date           in     date default null
  ,p_creator_person_id             in    number default null
  ,p_training_plan_member_id          out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_training_plan_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This business process updates a personal or organization training plan
 * component record.
 *
 * This API, called from Self-Service as well as PUI forms, updates a record in
 * the OTA_TRAINING_PLAN_MEMBERS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * A valid training plan component must exist.
 *
 * <p><b>Post Success</b><br>
 * The training plan component record of the user is updated
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the training plan component record, and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_training_plan_member_id The unique identifier for the component
 * record.
 * @param p_object_version_number Pass in the current version number of the
 * training plan component to be updated. When the API completes, if p_validate
 * is false, will be set to the new version number of the updated training plan
 * component. If p_validate is true will be set to the same value which is
 * passed in.
 * @param p_activity_version_id The Identifier of a course that is to be added
 * to the plan. Either this or an activity definition must be specified, not
 * both. The default is null.
 * @param p_activity_definition_id The Identifier of an activity definition
 * that is to be added to the plan. Either this or a course must be specified,
 * not both. The default is null.
 * @param p_member_status_type_id Training Plan Component's Type. Valid values
 * are defined by the 'OTA_MEMBER_USER_STATUS_TYPE' lookup type.
 * @param p_target_completion_date The date by which the component is expected
 * to be completed. The default is null.
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
 * @param p_assignment_id Identifies the assignment for which you create the
 * Ota_training_plan_members record.
 * @param p_source_id Training Plan Component source identifier
 * @param p_source_function Training Plan Component's source function.Valid
 * values are defined by the 'OTA_PLAN_COMPONENT_SOURCE' lookup type.
 * @param p_cancellation_reason Training Plan Component's cancellation
 * reason.Valid values are defined by the 'OTA_PLAN_CANCELLATION_SOURCE' lookup
 * type.
 * @param p_earliest_start_date Training Plan Component's start date.
 * @param p_creator_person_id Person who creates the training plan component.
 * @rep:displayname Update Training Plan Component
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_training_plan_member
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_training_plan_member_id       in     number
  ,p_object_version_number         in out nocopy number
  ,p_activity_version_id           in     number   default hr_api.g_number
  ,p_activity_definition_id        in     number   default hr_api.g_number
  ,p_member_status_type_id         in     varchar2 default hr_api.g_varchar2
  ,p_target_completion_date        in     date     default hr_api.g_date
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
  ,p_assignment_id                 in     number default hr_api.g_number
  ,p_source_id                     in     number default  hr_api.g_number
  ,p_source_function               in     varchar2 default hr_api.g_varchar2
  ,p_cancellation_reason           in     varchar2 default hr_api.g_varchar2
  ,p_earliest_start_date           in     date default hr_api.g_date
  ,p_creator_person_id             in    number default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_training_plan_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This business process deletes a component record from a personal or
 * organization training plan.
 *
 * This API, called from Self-Service as well as PUI forms, deletes a record in
 * the OTA_TRAINING_PLAN_MEMBERS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * A valid training plan component must exist.
 *
 * <p><b>Post Success</b><br>
 * The training plan component record of the user is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the training plan component record, and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_training_plan_member_id The unique identifier for the component
 * record.
 * @param p_object_version_number Current version number of the
 * ota_training_plan_members to be deleted.
 * @rep:displayname Delete Training Plan component
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_training_plan_member
  (p_validate                      in     boolean  default false
  ,p_training_plan_member_id       in     number
  ,p_object_version_number         in     number
  );
end ota_tpm_api;

 

/
