--------------------------------------------------------
--  DDL for Package PER_RI_SETUP_SUB_TASK_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_SETUP_SUB_TASK_SWI" AUTHID CURRENT_USER As
/* $Header: pessbswi.pkh 115.1 2003/08/06 01:30:00 kavenkat noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_setup_sub_task >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_setup_sub_task_api.create_setup_sub_task
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
PROCEDURE create_setup_sub_task
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_setup_sub_task_code          in     varchar2
  ,p_setup_sub_task_name          in     varchar2
  ,p_setup_sub_task_description   in     varchar2
  ,p_setup_task_code              in     varchar2
  ,p_setup_sub_task_sequence      in     number
  ,p_setup_sub_task_status        in     varchar2
  ,p_setup_sub_task_type          in     varchar2
  ,p_setup_sub_task_dp_link       in     varchar2
  ,p_setup_sub_task_action        in     varchar2
  ,p_setup_sub_task_creation_date in     date
  ,p_setup_sub_task_last_mod_date in     date
  ,p_legislation_code             in     varchar2
  ,p_language_code                in     varchar2  default null
  ,p_effective_date               in     date
  ,p_object_version_number        out nocopy number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_setup_sub_task >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_setup_sub_task_api.delete_setup_sub_task
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
PROCEDURE delete_setup_sub_task
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_setup_sub_task_code          in     varchar2
  ,p_object_version_number        in     number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_setup_sub_task >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_setup_sub_task_api.update_setup_sub_task
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
PROCEDURE update_setup_sub_task
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_setup_sub_task_code          in     varchar2
  ,p_setup_sub_task_name          in     varchar2  default hr_api.g_varchar2
  ,p_setup_sub_task_description   in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_code              in     varchar2  default hr_api.g_varchar2
  ,p_setup_sub_task_sequence      in     number    default hr_api.g_number
  ,p_setup_sub_task_status        in     varchar2  default hr_api.g_varchar2
  ,p_setup_sub_task_type          in     varchar2  default hr_api.g_varchar2
  ,p_setup_sub_task_dp_link       in     varchar2  default hr_api.g_varchar2
  ,p_setup_sub_task_action        in     varchar2  default hr_api.g_varchar2
  ,p_setup_sub_task_creation_date in     date      default hr_api.g_date
  ,p_setup_sub_task_last_mod_date in     date      default hr_api.g_date
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end per_ri_setup_sub_task_swi;

 

/
