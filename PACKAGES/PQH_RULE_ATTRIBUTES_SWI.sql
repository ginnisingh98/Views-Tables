--------------------------------------------------------
--  DDL for Package PQH_RULE_ATTRIBUTES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RULE_ATTRIBUTES_SWI" AUTHID CURRENT_USER As
/* $Header: pqrlaswi.pkh 115.0 2003/01/26 01:40:58 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_rule_attribute >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_rule_attributes_api.delete_rule_attribute
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
PROCEDURE delete_rule_attribute
  (p_rule_attribute_id            in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< insert_rule_attribute >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_rule_attributes_api.insert_rule_attribute
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
PROCEDURE insert_rule_attribute
  (p_rule_set_id                  in     number
  ,p_attribute_code               in     varchar2
  ,p_operation_code               in     varchar2
  ,p_attribute_value              in     varchar2
  ,p_rule_attribute_id               out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_rule_attribute >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_rule_attributes_api.update_rule_attribute
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
PROCEDURE update_rule_attribute
  (p_rule_attribute_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_rule_set_id                  in     number    default hr_api.g_number
  ,p_attribute_code               in     varchar2  default hr_api.g_varchar2
  ,p_operation_code               in     varchar2  default hr_api.g_varchar2
  ,p_attribute_value              in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
end pqh_rule_attributes_swi;

 

/
