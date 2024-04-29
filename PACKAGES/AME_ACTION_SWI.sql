--------------------------------------------------------
--  DDL for Package AME_ACTION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACTION_SWI" AUTHID CURRENT_USER As
/* $Header: amatyswi.pkh 120.0 2005/09/02 03:53 mbocutt noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_ame_action_type >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.create_ame_action_type
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
PROCEDURE create_ame_action_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_language_code                in     varchar2  default null
  ,p_name                         in     varchar2
  ,p_procedure_name               in     varchar2
  ,p_dynamic_description          in     varchar2
  ,p_description                  in     varchar2
  ,p_description_query            in     varchar2  default null
  ,p_rule_type                    in     number    default null
  ,p_approver_type_id             in     number    default null
  ,p_action_type_id               in     number
  ,p_aty_object_version_number       out nocopy number
  ,p_aty_start_date                  out nocopy date
  ,p_aty_end_date                    out nocopy date
  ,p_apu_object_version_number       out nocopy number
  ,p_apu_start_date                  out nocopy date
  ,p_apu_end_date                    out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< create_ame_action_type_usage >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.create_ame_action_type_usage
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
PROCEDURE create_ame_action_type_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_type_id               in     number
  ,p_rule_type                    in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< create_ame_appr_type_usage >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.create_ame_appr_type_usage
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
PROCEDURE create_ame_appr_type_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_type_id               in     number
  ,p_approver_type_id             in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< create_ame_action_type_config >--------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.create_ame_action_type_config
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
PROCEDURE create_ame_action_type_config
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_type_id               in     number
  ,p_application_id               in     number
  ,p_voting_regime                in     varchar2  default null
  ,p_chain_ordering_mode          in     varchar2  default null
  ,p_order_number                 in     number    default null
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ame_req_attribute >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.create_ame_req_attribute
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
PROCEDURE create_ame_req_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_type_id               in     number
  ,p_attribute_id                 in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ame_action >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.create_ame_action
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
PROCEDURE create_ame_action
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_language_code                in     varchar2  default null
  ,p_action_type_id               in     number
  ,p_parameter                    in     varchar2
  ,p_description                  in     varchar2
  ,p_parameter_two                in     varchar2
  ,p_action_id                       out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_ame_action_type >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.update_ame_action_type
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
PROCEDURE update_ame_action_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_language_code                in     varchar2  default hr_api.userenv_lang
  ,p_action_type_id               in     number
  ,p_procedure_name               in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_description_query            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_ame_action_type_conf >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.update_ame_action_type_conf
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
PROCEDURE update_ame_action_type_conf
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_type_id               in     number
  ,p_application_id               in     number
  ,p_voting_regime                in     varchar2  default hr_api.g_varchar2
  ,p_chain_ordering_mode          in     varchar2  default hr_api.g_varchar2
  ,p_order_number                 in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_ame_action >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.update_ame_action
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
PROCEDURE update_ame_action
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_language_code                in     varchar2  default hr_api.userenv_lang
  ,p_action_id                    in     number
  ,p_action_type_id               in     number
  ,p_parameter                    in     varchar2  default hr_api.g_varchar2
  ,p_parameter_two                in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ame_action_type >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.delete_ame_action_type
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
PROCEDURE delete_ame_action_type
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_type_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ame_action_type_conf >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.delete_ame_action_type_conf
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
PROCEDURE delete_ame_action_type_conf
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_type_id               in     number
  ,p_application_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< delete_ame_action_type_usage >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.delete_ame_action_type_usage
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
PROCEDURE delete_ame_action_type_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_type_id               in     number
  ,p_rule_type                    in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ame_appr_type_usage >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.delete_ame_appr_type_usage
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
PROCEDURE delete_ame_appr_type_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_type_id               in     number
  ,p_approver_type_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ame_req_attribute >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.delete_ame_req_attribute
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
PROCEDURE delete_ame_req_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_type_id               in     number
  ,p_attribute_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_ame_action >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_action_api.delete_ame_action
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
PROCEDURE delete_ame_action
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_action_id                    in     number
  ,p_action_type_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end ame_action_swi;

 

/
