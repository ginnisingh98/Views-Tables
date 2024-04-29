--------------------------------------------------------
--  DDL for Package PER_TASKS_IN_CHECKLIST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_TASKS_IN_CHECKLIST_API" AUTHID CURRENT_USER as
/* $Header: pectkapi.pkh 120.3 2006/01/13 05:10:20 lsilveir noship $ */
/*#
 * This package contains APIs for maintaining checklist tasks.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Checklist Task
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_task_in_ckl >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new checklist task within an existing checklist.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The checklist within which the task is being created must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API creates the checklist task successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The checklist task is not created in the database and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date The date on which the checklist task is created.
 * @param p_checklist_id Identifies the checklist in which the checklist
 * task is created.
 * @param p_checklist_task_name Checklist task name.
 * @param p_eligibility_object_id Identifies the eligibility object
 * associated with the checklist task.
 * @param p_eligibility_profile_id identifies the eligibility profile
 * attached to the checklist task.
 * @param p_ame_attribute_identifier Identifies the AME attribute used for
 * approvals management.
 * @param p_description Checklist task description.
 * @param p_task_sequence This should always be left null.
 * @param p_mandatory Indicates whether the task is mandatory or optional.
 * Set to 'Y' for mandatory and 'N' for optional.
 * @param p_target_duration Target duration within which the task must
 * be completed.
 * @param p_target_duration_uom Unit of measure for the specified target
 * duration.
 * @param p_action_url URL of website to action the task.
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_task_in_checklist_id If p_validate is false, then this
 * uniquely identifies the checklist task created. If p_validate
 * is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created checklist task. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Checklist Task
 * @rep:category BUSINESS_ENTITY PER_CHECKLIST
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_task_in_ckl
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_checklist_id                  in     number
  ,p_checklist_task_name           in     varchar2
  ,p_eligibility_object_id         in     number default null
  ,p_eligibility_profile_id        in     number default null
  ,p_ame_attribute_identifier      in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_task_sequence                 in     number default null
  ,p_mandatory                     in     varchar2 default null
  ,p_target_duration               in     number   default null
  ,p_target_duration_uom           in     varchar2 default null
  ,p_action_url                    in     varchar2 default null
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
  ,p_information_category          in     varchar2 default null
  ,p_information1                  in     varchar2 default null
  ,p_information2                  in     varchar2 default null
  ,p_information3                  in     varchar2 default null
  ,p_information4                  in     varchar2 default null
  ,p_information5                  in     varchar2 default null
  ,p_information6                  in     varchar2 default null
  ,p_information7                  in     varchar2 default null
  ,p_information8                  in     varchar2 default null
  ,p_information9                  in     varchar2 default null
  ,p_information10                 in     varchar2 default null
  ,p_information11                 in     varchar2 default null
  ,p_information12                 in     varchar2 default null
  ,p_information13                 in     varchar2 default null
  ,p_information14                 in     varchar2 default null
  ,p_information15                 in     varchar2 default null
  ,p_information16                 in     varchar2 default null
  ,p_information17                 in     varchar2 default null
  ,p_information18                 in     varchar2 default null
  ,p_information19                 in     varchar2 default null
  ,p_information20                 in     varchar2 default null
  ,p_task_in_checklist_id             out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_task_in_ckl >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing checklist task.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The checklist task that is to be updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the checklist task successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The checklist task is not updated in the database and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date The date on which the checklist task is updated.
 * @param p_task_in_checklist_id Identifies the checklist task to be updated.
 * @param p_checklist_id Identifies the checklist containing the checklist
 * task.
 * @param p_checklist_task_name Checklist task name.
 * @param p_eligibility_object_id Identifies the eligibility object
 * associated with the checklist task.
 * @param p_eligibility_profile_id identifies the eligibility profile
 * attached to the checklist task.
 * @param p_ame_attribute_identifier Identifies the AME attribute used for
 * approvals management.
 * @param p_description Checklist task description.
 * @param p_task_sequence This should always be left null.
 * @param p_mandatory Indicates whether the task is mandatory or optional.
 * Set to 'Y' for mandatory and 'N' for optional.
 * @param p_target_duration Target duration within which the task must
 * be completed.
 * @param p_target_duration_uom Unit of measure for the specified target
 * duration.
 * @param p_action_url URL of website to action the task.
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_object_version_number Pass in the current version number of the
 * checklist task to be updated. When the API completes if p_validate
 * is false, it will be set to the new version number of the updated checklist
 * task. If p_validate is true it will be set to the same value which was
 * passed in.
 * @rep:displayname Update Checklist Task
 * @rep:category BUSINESS_ENTITY PER_CHECKLIST
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_TASK_IN_CKL
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_task_in_checklist_id          in     number
  ,p_checklist_id                  in     number
  ,p_checklist_task_name           in     varchar2
  ,p_eligibility_object_id         in     number default null
  ,p_eligibility_profile_id        in     number default null
  ,p_ame_attribute_identifier      in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_task_sequence                 in     number default null
  ,p_mandatory                     in     varchar2 default null
  ,p_target_duration               in     number   default null
  ,p_target_duration_uom           in     varchar2 default null
  ,p_action_url                    in     varchar2 default null
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
  ,p_information_category          in     varchar2 default null
  ,p_information1                  in     varchar2 default null
  ,p_information2                  in     varchar2 default null
  ,p_information3                  in     varchar2 default null
  ,p_information4                  in     varchar2 default null
  ,p_information5                  in     varchar2 default null
  ,p_information6                  in     varchar2 default null
  ,p_information7                  in     varchar2 default null
  ,p_information8                  in     varchar2 default null
  ,p_information9                  in     varchar2 default null
  ,p_information10                 in     varchar2 default null
  ,p_information11                 in     varchar2 default null
  ,p_information12                 in     varchar2 default null
  ,p_information13                 in     varchar2 default null
  ,p_information14                 in     varchar2 default null
  ,p_information15                 in     varchar2 default null
  ,p_information16                 in     varchar2 default null
  ,p_information17                 in     varchar2 default null
  ,p_information18                 in     varchar2 default null
  ,p_information19                 in     varchar2 default null
  ,p_information20                 in     varchar2 default null
  ,p_object_version_number         in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_task_in_ckl >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing checklist task.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The checklist task that is to be deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the checklist task successfully from the database.
 *
 * <p><b>Post Failure</b><br>
 * The checklist task is not deleted from the database and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_task_in_checklist_id Identifies the checklist task to be deleted.
 * @param p_object_version_number Current version number of the checklist
 * task to be deleted.
 * @rep:displayname Delete Checklist Task
 * @rep:category BUSINESS_ENTITY PER_CHECKLIST
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_TASK_IN_CKL
  (p_validate                      in     boolean  default false
  ,p_task_in_checklist_id          in     number
  ,p_object_version_number         in     number
  );


end PER_TASKS_IN_CHECKLIST_API;

 

/
