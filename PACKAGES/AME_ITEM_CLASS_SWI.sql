--------------------------------------------------------
--  DDL for Package AME_ITEM_CLASS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITEM_CLASS_SWI" AUTHID CURRENT_USER As
/* $Header: amitcswi.pkh 120.1 2005/12/08 21:13 santosin noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ame_item_class >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_item_class_api.create_ame_item_class
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
PROCEDURE create_ame_item_class
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_name                         in     varchar2
  ,p_user_item_class_name         in     varchar2
  ,p_item_class_id                in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_item_class >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_item_class_api.update_ame_item_class
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
PROCEDURE update_ame_item_class
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_item_class_id                in     number
  ,p_user_item_class_name         in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_item_class >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_item_class_api.delete_ame_item_class
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
PROCEDURE delete_ame_item_class
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_item_class_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< create_ame_item_class_usage >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_item_class_api.create_ame_item_class_usage
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
PROCEDURE create_ame_item_class_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_item_id_query                in     varchar2
  ,p_item_class_order_number      in     number
  ,p_item_class_par_mode          in     varchar2
  ,p_item_class_sublist_mode      in     varchar2
  ,p_application_id               in out nocopy number
  ,p_item_class_id                in out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_ame_item_class_usage >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_item_class_api.update_ame_item_class_usage
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
PROCEDURE update_ame_item_class_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_application_id               in     number
  ,p_item_class_id                in     number
  ,p_item_id_query                in     varchar2  default hr_api.g_varchar2
  ,p_item_class_order_number      in     number    default hr_api.g_number
  ,p_item_class_par_mode          in     varchar2  default hr_api.g_varchar2
  ,p_item_class_sublist_mode      in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_ame_item_class_usage >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_item_class_api.delete_ame_item_class_usage
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
PROCEDURE delete_ame_item_class_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_application_id               in     number
  ,p_item_class_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end ame_item_class_swi;

 

/
