--------------------------------------------------------
--  DDL for Package PER_ALLOCATED_TASK_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ALLOCATED_TASK_SWI" AUTHID CURRENT_USER As
/* $Header: pepatswi.pkh 120.0 2005/09/28 07:48 lsilveir noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< create_alloc_task >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_allocated_task_api.create_alloc_task
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_alloc_task
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_allocated_checklist_id       in     number
  ,p_task_name                    in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_performer_orig_system        in     varchar2  default null
  ,p_performer_orig_sys_id        in     number    default null
  ,p_task_owner_person_id         in     number    default null
  ,p_task_sequence                in     number    default null
  ,p_target_start_date            in     date      default null
  ,p_target_end_date              in     date      default null
  ,p_actual_start_date            in     date      default null
  ,p_actual_end_date              in     date      default null
  ,p_action_url                   in     varchar2  default null
  ,p_mandatory_flag               in     varchar2  default null
  ,p_status                       in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_information_category         in     varchar2  default null
  ,p_information1                 in     varchar2  default null
  ,p_information2                 in     varchar2  default null
  ,p_information3                 in     varchar2  default null
  ,p_information4                 in     varchar2  default null
  ,p_information5                 in     varchar2  default null
  ,p_information6                 in     varchar2  default null
  ,p_information7                 in     varchar2  default null
  ,p_information8                 in     varchar2  default null
  ,p_information9                 in     varchar2  default null
  ,p_information10                in     varchar2  default null
  ,p_information11                in     varchar2  default null
  ,p_information12                in     varchar2  default null
  ,p_information13                in     varchar2  default null
  ,p_information14                in     varchar2  default null
  ,p_information15                in     varchar2  default null
  ,p_information16                in     varchar2  default null
  ,p_information17                in     varchar2  default null
  ,p_information18                in     varchar2  default null
  ,p_information19                in     varchar2  default null
  ,p_information20                in     varchar2  default null
  ,p_allocated_task_id            in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_alloc_task >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_allocated_task_api.delete_alloc_task
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_alloc_task
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_allocated_task_id            in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_alloc_task >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_allocated_task_api.update_alloc_task
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_alloc_task
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_allocated_task_id            in     number
  ,p_allocated_checklist_id       in     number
  ,p_task_name                    in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_performer_orig_system        in     varchar2  default hr_api.g_varchar2
  ,p_performer_orig_sys_id        in     number    default hr_api.g_number
  ,p_task_owner_person_id         in     number    default hr_api.g_number
  ,p_task_sequence                in     number    default hr_api.g_number
  ,p_target_start_date            in     date      default hr_api.g_date
  ,p_target_end_date              in     date      default hr_api.g_date
  ,p_actual_start_date            in     date      default hr_api.g_date
  ,p_actual_end_date              in     date      default hr_api.g_date
  ,p_action_url                   in     varchar2  default hr_api.g_varchar2
  ,p_mandatory_flag               in     varchar2  default hr_api.g_varchar2
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
 end per_allocated_task_swi;

 

/
