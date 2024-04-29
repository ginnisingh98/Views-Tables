--------------------------------------------------------
--  DDL for Package PAY_AU_PROCESS_MODULES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PROCESS_MODULES_SWI" AUTHID CURRENT_USER As
/* $Header: pyapmswi.pkh 120.0 2005/05/29 02:57 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_au_process_module >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_au_process_modules_api.create_au_process_module
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
PROCEDURE create_au_process_module
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_process_id                   in     number
  ,p_module_id                    in     number
  ,p_process_sequence             in     number
  ,p_enabled_flag                 in     varchar2
  ,p_process_module_id               out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_au_process_module >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_au_process_modules_api.delete_au_process_module
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
PROCEDURE delete_au_process_module
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_process_module_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_au_process_module >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_au_process_modules_api.update_au_process_module
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
PROCEDURE update_au_process_module
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_process_module_id            in     number
  ,p_process_id                   in     number
  ,p_module_id                    in     number
  ,p_process_sequence             in     number
  ,p_enabled_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
 end pay_au_process_modules_swi;

 

/
