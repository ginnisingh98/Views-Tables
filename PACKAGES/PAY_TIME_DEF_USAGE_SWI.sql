--------------------------------------------------------
--  DDL for Package PAY_TIME_DEF_USAGE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TIME_DEF_USAGE_SWI" AUTHID CURRENT_USER As
/* $Header: pytduswi.pkh 120.1 2005/06/14 14:36 tvankayl noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_time_def_usage >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_time_def_usage_api.create_time_def_usage
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
PROCEDURE create_time_def_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_time_definition_id           in     number
  ,p_usage_type                   in     varchar2
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_def_usage >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_time_def_usage_api.delete_time_def_usage
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
PROCEDURE delete_time_def_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_time_definition_id           in     number
  ,p_usage_type                   in     varchar2
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end pay_time_def_usage_swi;

 

/
