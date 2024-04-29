--------------------------------------------------------
--  DDL for Package PAY_AU_PROCESSES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PROCESSES_SWI" AUTHID CURRENT_USER As
/* $Header: pyaprswi.pkh 120.0 2005/05/29 02:59 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< create_au_process >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_au_processes_api.create_au_process
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
PROCEDURE create_au_process
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_short_name                   in     varchar2
  ,p_name                         in     varchar2
  ,p_enabled_flag                 in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_accrual_category             in     varchar2  default null
  ,p_process_id                      out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_au_process >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_au_processes_api.delete_au_process
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
PROCEDURE delete_au_process
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_process_id                   in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_au_process >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_au_processes_api.update_au_process
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
PROCEDURE update_au_process
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_process_id                   in     number
  ,p_short_name                   in     varchar2  default hr_api.g_varchar2
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_accrual_category             in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
 end pay_au_processes_swi;

 

/
