--------------------------------------------------------
--  DDL for Package AME_ATTRIBUTE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATTRIBUTE_SWI" AUTHID CURRENT_USER As
/* $Header: amatrswi.pkh 120.0 2005/09/02 03:51 mbocutt noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ame_attribute >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_attribute_api.create_ame_attribute
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
PROCEDURE create_ame_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_name                         in     varchar2
  ,p_description                  in     varchar2
  ,p_attribute_type               in     varchar2
  ,p_item_class_id                in     number
  ,p_approver_type_id             in     number    default null
  ,p_application_id               in     number    default null
  ,p_is_static                    in     varchar2  default ame_util.booleanTrue
  ,p_query_string                 in     varchar2  default null
  ,p_user_editable                in     varchar2  default ame_util.booleanTrue
  ,p_value_set_id                 in     number    default null
  ,p_attribute_id                 in     number
  ,p_atr_object_version_number       out nocopy number
  ,p_atr_start_date                  out nocopy date
  ,p_atr_end_date                    out nocopy date
  ,p_atu_object_version_number       out nocopy number
  ,p_atu_start_date                  out nocopy date
  ,p_atu_end_date                    out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< create_ame_attribute_usage >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_attribute_api.create_ame_attribute_usage
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
PROCEDURE create_ame_attribute_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_attribute_id                 in     number
  ,p_application_id               in     number
  ,p_is_static                    in     varchar2  default ame_util.booleanTrue
  ,p_query_string                 in     varchar2  default null
  ,p_user_editable                in     varchar2  default ame_util.booleanTrue
  ,p_value_set_id                 in     number    default null
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_attribute >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_attribute_api.update_ame_attribute
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
PROCEDURE update_ame_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_attribute_id                 in     number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_ame_attribute_usage >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_attribute_api.update_ame_attribute_usage
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
PROCEDURE update_ame_attribute_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_attribute_id                 in     number
  ,p_application_id               in     number
  ,p_is_static                    in     varchar2  default hr_api.g_varchar2
  ,p_query_string                 in     varchar2  default hr_api.g_varchar2
  ,p_value_set_id                 in     number    default null
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ame_attribute_usage >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_attribute_api.delete_ame_attribute_usage
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
PROCEDURE delete_ame_attribute_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_attribute_id                 in     number
  ,p_application_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end ame_attribute_swi;

 

/
