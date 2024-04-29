--------------------------------------------------------
--  DDL for Package PAY_TIME_DEFINITION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TIME_DEFINITION_SWI" AUTHID CURRENT_USER As
/* $Header: pytdfswi.pkh 120.1 2005/06/14 14:13 tvankayl noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_time_definition >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_time_definition_api.create_time_definition
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
PROCEDURE create_time_definition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_short_name                   in     varchar2
  ,p_definition_name              in     varchar2
  ,p_period_type                  in     varchar2  default null
  ,p_period_unit                  in     varchar2  default null
  ,p_day_adjustment               in     varchar2  default null
  ,p_dynamic_code                 in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_definition_type              in     varchar2  default null
  ,p_number_of_years              in     number    default null
  ,p_start_date                   in     date      default null
  ,p_period_time_definition_id    in     number    default null
  ,p_creator_id                   in     number    default null
  ,p_creator_type                 in     varchar2  default null
  ,p_time_definition_id           in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_time_definition >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_time_definition_api.update_time_definition
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
PROCEDURE update_time_definition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_time_definition_id           in     number
  ,p_definition_name              in     varchar2  default hr_api.g_varchar2
  ,p_period_type                  in     varchar2  default hr_api.g_varchar2
  ,p_period_unit                  in     varchar2  default hr_api.g_varchar2
  ,p_day_adjustment               in     varchar2  default hr_api.g_varchar2
  ,p_dynamic_code                 in     varchar2  default hr_api.g_varchar2
  ,p_number_of_years              in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_period_time_definition_id    in     number    default hr_api.g_number
  ,p_creator_id                   in     number    default hr_api.g_number
  ,p_creator_type                 in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_time_definition >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_time_definition_api.delete_time_definition
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
PROCEDURE delete_time_definition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_time_definition_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_time_def_usage >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_tdf_bus.chk_time_def_usage
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  Processing continues.
--
-- Post Failure:
--  An error message is raised.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
FUNCTION chk_time_def_usage
  (p_time_definition_id  IN number
  ,p_definition_type     IN varchar2
  ) Return Number;

end pay_time_definition_swi;

 

/
