--------------------------------------------------------
--  DDL for Package AME_CONFIG_VAR_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONFIG_VAR_SWI" AUTHID CURRENT_USER As
/* $Header: amcfvswi.pkh 120.0 2005/09/02 03:55 mbocutt noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< update_ame_config_variable >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_config_var_api.update_ame_config_variable
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
PROCEDURE update_ame_config_variable
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_application_id               in     number
  ,p_variable_name                in     varchar2
  ,p_variable_value               in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ame_config_variable >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_config_var_api.delete_ame_config_variable
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
PROCEDURE delete_ame_config_variable
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_application_id               in     number
  ,p_variable_name                in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end ame_config_var_swi;

 

/
