--------------------------------------------------------
--  DDL for Package AME_CONDITION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONDITION_SWI" AUTHID CURRENT_USER As
/* $Header: amconswi.pkh 120.0 2005/09/02 03:56 mbocutt noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ame_condition >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_condition_api.create_ame_condition
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
PROCEDURE create_ame_condition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_condition_key                in     varchar2
  ,p_condition_type               in     varchar2
  ,p_attribute_id                 in     number    default null
  ,p_parameter_one                in     varchar2  default null
  ,p_parameter_two                in     varchar2  default null
  ,p_parameter_three              in     varchar2  default null
  ,p_include_upper_limit          in     varchar2  default null
  ,p_include_lower_limit          in     varchar2  default null
  ,p_string_value                 in     varchar2  default null
  ,p_condition_id                 in     number
  ,p_con_start_date                  out nocopy date
  ,p_con_end_date                    out nocopy date
  ,p_con_object_version_number       out nocopy number
  ,p_stv_start_date                  out nocopy date
  ,p_stv_end_date                    out nocopy date
  ,p_stv_object_version_number       out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_condition >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_condition_api.update_ame_condition
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
PROCEDURE update_ame_condition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_condition_id                 in     number
  ,p_parameter_one                in     varchar2  default hr_api.g_varchar2
  ,p_parameter_two                in     varchar2  default hr_api.g_varchar2
  ,p_parameter_three              in     varchar2  default hr_api.g_varchar2
  ,p_include_upper_limit          in     varchar2  default hr_api.g_varchar2
  ,p_include_lower_limit          in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_condition >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_condition_api.delete_ame_condition
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
PROCEDURE delete_ame_condition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_condition_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_ame_string_value >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_condition_api.create_ame_string_value
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
PROCEDURE create_ame_string_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_condition_id                 in     number
  ,p_string_value                 in     varchar2
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ame_string_value >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_condition_api.delete_ame_string_value
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
PROCEDURE delete_ame_string_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_condition_id                 in     number
  ,p_string_value                 in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end ame_condition_swi;

 

/
