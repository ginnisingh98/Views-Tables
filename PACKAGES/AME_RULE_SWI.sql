--------------------------------------------------------
--  DDL for Package AME_RULE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RULE_SWI" AUTHID CURRENT_USER As
/* $Header: amrulswi.pkh 120.1 2005/10/11 04:22 tkolla noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------------< create_ame_rule >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_rule_api.create_ame_rule
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
PROCEDURE create_ame_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_key                     in     varchar2
  ,p_description                  in     varchar2
  ,p_rule_type                    in     varchar2
  ,p_item_class_id                in     number    default null
  ,p_condition_id                 in     number    default null
  ,p_action_id                    in     number    default null
  ,p_application_id               in     number    default null
  ,p_priority                     in     number    default null
  ,p_approver_category            in     varchar2  default null
  ,p_rul_start_date               in out nocopy date
  ,p_rul_end_date                 in out nocopy date
  ,p_rule_id                      in     number
  ,p_rul_object_version_number       out nocopy number
  ,p_rlu_object_version_number       out nocopy number
  ,p_rlu_start_date                  out nocopy date
  ,p_rlu_end_date                    out nocopy date
  ,p_cnu_object_version_number       out nocopy number
  ,p_cnu_start_date                  out nocopy date
  ,p_cnu_end_date                    out nocopy date
  ,p_acu_object_version_number       out nocopy number
  ,p_acu_start_date                  out nocopy date
  ,p_acu_end_date                    out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ame_rule_usage >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_rule_api.create_ame_rule_usage
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
PROCEDURE create_ame_rule_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_application_id               in     number
  ,p_priority                     in     number    default null
  ,p_approver_category            in     varchar2  default null
  ,p_start_date                   in out nocopy date
  ,p_end_date                     in out nocopy date
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< create_ame_condition_to_rule >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_rule_api.create_ame_condition_to_rule
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
PROCEDURE create_ame_condition_to_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_condition_id                 in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  ,p_effective_date               in     date      default null
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ame_action_to_rule >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_rule_api.create_ame_action_to_rule
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
PROCEDURE create_ame_action_to_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_action_id                    in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  ,p_effective_date               in     date      default null
  );
-- ----------------------------------------------------------------------------
-- |----------------------------< update_ame_rule >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_rule_api.update_ame_rule
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
PROCEDURE update_ame_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                   in out nocopy date
  ,p_end_date                     in out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_rule_usage >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_rule_api.update_ame_rule_usage
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
PROCEDURE update_ame_rule_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_application_id               in     number
  ,p_priority                     in     number    default hr_api.g_number
  ,p_approver_category            in     varchar2  default hr_api.g_varchar2
  ,p_old_start_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_start_date                   in out nocopy date
  ,p_end_date                     in out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_rule_usage >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_rule_api.delete_ame_rule_usage
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
PROCEDURE delete_ame_rule_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_application_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                   in out nocopy date
  ,p_end_date                     in out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ame_rule_condition >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_rule_api.delete_ame_rule_condition
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
PROCEDURE delete_ame_rule_condition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_condition_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ame_rule_action >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_rule_api.delete_ame_rule_action
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
PROCEDURE delete_ame_rule_action
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_action_id                    in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< set_effective_date >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is used to set the g_effective_date package variable.This
--  value is used in the api as the effective_date of delete operation
--  ( delete_ame_rule_condition and delete_ame_rule_action ).
--
-- Pre-requisites
--  None
--
-- Post Success:
--  None
--
-- Post Failure:
--  None
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE set_effective_date
  (p_effective_date                  in date
  );
--
-- Other Global Variables
--
g_effective_date		     date default null;
end ame_rule_swi;

 

/
