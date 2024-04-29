--------------------------------------------------------
--  DDL for Package PAY_AU_MODULE_PARAMETERS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_MODULE_PARAMETERS_SWI" AUTHID CURRENT_USER As
/* $Header: pyampswi.pkh 120.0 2005/05/29 02:56 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_au_module_parameter >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_au_module_parameters_api.create_au_module_parameter
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
PROCEDURE create_au_module_parameter
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_module_id                    in     number
  ,p_internal_name                in     varchar2  default null
  ,p_data_type                    in     varchar2  default null
  ,p_input_flag                   in     varchar2  default null
  ,p_context_flag                 in     varchar2  default null
  ,p_output_flag                  in     varchar2  default null
  ,p_result_flag                  in     varchar2  default null
  ,p_error_message_flag           in     varchar2  default null
  ,p_enabled_flag                 in     varchar2  default null
  ,p_function_return_flag         in     varchar2  default null
  ,p_external_name                in     varchar2  default null
  ,p_database_item_name           in     varchar2  default null
  ,p_constant_value               in     varchar2  default null
  ,p_module_parameter_id             out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_au_module_parameter >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_au_module_parameters_api.delete_au_module_parameter
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
PROCEDURE delete_au_module_parameter
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_module_parameter_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_au_module_parameter >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_au_module_parameters_api.update_au_module_parameter
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
PROCEDURE update_au_module_parameter
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_module_parameter_id          in     number
  ,p_module_id                    in     number
  ,p_internal_name                in     varchar2  default hr_api.g_varchar2
  ,p_data_type                    in     varchar2  default hr_api.g_varchar2
  ,p_input_flag                   in     varchar2  default hr_api.g_varchar2
  ,p_context_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_output_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_result_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_error_message_flag           in     varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_function_return_flag         in     varchar2  default hr_api.g_varchar2
  ,p_external_name                in     varchar2  default hr_api.g_varchar2
  ,p_database_item_name           in     varchar2  default hr_api.g_varchar2
  ,p_constant_value               in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
 end pay_au_module_parameters_swi;

 

/
