--------------------------------------------------------
--  DDL for Package PER_ALLOCATED_TASK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ALLOCATED_TASK_API" AUTHID CURRENT_USER as
/* $Header: pepatapi.pkh 120.2.12010000.2 2008/08/06 09:20:51 ubhat ship $ */
/*#
 * This package contains APIs for maintaining allocated tasks.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Allocated Task
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_alloc_task >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Allocated Task. These are tasks that are contained
 * within allocated checklists. Allocated checklists are checklists that are
 * attached to a person or an assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The allocated checklist into which the new allocated task is to be added
 * must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API creates the allocated task in the allocated checklist successfully
 * in the database.
 *
 * <p><b>Post Failure</b><br>
 * The allocated task is not created in the database and an error is
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date The date on which the allocated task is created
 * in the allocated checklist.
 * @param p_allocated_checklist_id The allocated checklist into which the
 * allocated task is to be added.
 * @param p_task_name The allocated task name.
 * @param p_description The allocated task description.
 * @param p_performer_orig_system Always set to string 'PER'.
 * @param p_performer_orig_sys_id Identifier for the person who will perform
 * the allocated task.
 * @param p_task_owner_person_id Identifier for the person who will own
 * the allocated task.
 * @param p_task_sequence This should always be left null.
 * @param p_target_start_date Target start date for the allocated task.
 * @param p_target_end_date Target end date for the allocated task.
 * @param p_actual_start_date Actual start date for the allocated task.
 * @param p_actual_end_date Actual end date for the allocated task.
 * @param p_action_url Web address for website to action the allocated task.
 * @param p_mandatory_flag Indicates whether the allocated task is mandatory
 * or optional. Set to 'Y' for mandatory and 'N' for optional.
 * @param p_status Status of the allocated task. Allowed values include all
 * lookup codes defined for lookup type 'PER_CHECKLIST_TASK_STATUS'.
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
 * @param p_allocated_task_id If p_validate is false, then this
 * uniquely identifies the allocated task created. If p_validate
 * is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created allocated task. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Allocated Task
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_ALLOC_TASK
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_allocated_checklist_id        in     number
  ,p_task_name                     in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_performer_orig_system         in     varchar2 default null
  ,p_performer_orig_sys_id      in     number   default null
  ,p_task_owner_person_id          in     number   default null
  ,p_task_sequence                 in     number   default null
  ,p_target_start_date             in     date     default null
  ,p_target_end_date               in     date     default null
  ,p_actual_start_date             in     date     default null
  ,p_actual_end_date               in     date     default null
  ,p_action_url                    in     varchar2 default null
  ,p_mandatory_flag                in     varchar2 default null
  ,p_status                        in     varchar2 default null
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
  ,p_allocated_task_id                out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_alloc_task >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing allocated task. These are tasks that are
 * contained within allocated checklists. These are checklists that are
 * attached to a person or an assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The allocated task that is to be updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the allocated task successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The allocated task is not updated in the database and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date The date on which the allocated task is updated.
 * @param p_allocated_task_id Identifies the allocated task to be updated.
 * @param p_allocated_checklist_id The allocated checklist containing the
 * allocated task being updated.
 * @param p_task_name The allocated task name.
 * @param p_description The allocated task description.
 * @param p_performer_orig_system Always set to string 'PER'.
 * @param p_performer_orig_sys_id Identifier for the person who will perform
 * the allocated task.
 * @param p_task_owner_person_id Identifier for the person who will own
 * the allocated task.
 * @param p_task_sequence This should always be left null.
 * @param p_target_start_date Target start date for the allocated task.
 * @param p_target_end_date Target end date for the allocated task.
 * @param p_actual_start_date Actual start date for the allocated task.
 * @param p_actual_end_date Actual end date for the allocated task.
 * @param p_action_url Web address for website to action the allocated task.
 * @param p_mandatory_flag Indicates whether the allocated task is mandatory
 * or optional. Set to 'Y' for mandatory and 'N' for optional.
 * @param p_status Status of the allocated task. Allowed values include all
 * lookup codes defined for lookup type 'PER_CHECKLIST_TASK_STATUS'.
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
 * allocated task to be updated. When the API completes if p_validate
 * is false, it will be set to the new version number of the updated allocated
 * task. If p_validate is true it will be set to the same value which was
 * passed in.
 * @rep:displayname Update Allocated Task
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_ALLOC_TASK
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_allocated_task_id             in     number
  ,p_allocated_checklist_id        in     number
  ,p_task_name                     in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_performer_orig_system         in     varchar2 default null
  ,p_performer_orig_sys_id         in     number   default null
  ,p_task_owner_person_id          in     number   default null
  ,p_task_sequence                 in     number   default null
  ,p_target_start_date             in     date     default null
  ,p_target_end_date               in     date     default null
  ,p_actual_start_date             in     date     default null
  ,p_actual_end_date               in     date     default null
  ,p_action_url                    in     varchar2 default null
  ,p_mandatory_flag                in     varchar2 default null
  ,p_status                        in     varchar2 default null
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
-- |----------------------------< delete_alloc_task >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing allocated task. These are tasks contained
 * within allocated checklists. These are checklists that are attached to a
 * person or an assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The allocated task that is to be deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the allocated task successfully from the database.
 *
 * <p><b>Post Failure</b><br>
 * The allocated task is not deleted from the database and an error is
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_allocated_task_id Identifies the allocated task to be deleted.
 * @param p_object_version_number Current version number of the allocated
 * task to be deleted.
 * @rep:displayname Delete Allocated Task
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_ALLOC_TASK
  (p_validate                      in     boolean  default false
  ,p_allocated_task_id             in     number
  ,p_object_version_number         in     number
  );


end PER_ALLOCATED_TASK_API;

/
