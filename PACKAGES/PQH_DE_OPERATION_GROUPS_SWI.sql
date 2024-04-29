--------------------------------------------------------
--  DDL for Package PQH_DE_OPERATION_GROUPS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_OPERATION_GROUPS_SWI" AUTHID CURRENT_USER As
/* $Header: pqopgswi.pkh 115.1 2002/12/03 00:09:21 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< delete_operation_groups >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_operation_groups_api.delete_operation_groups
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
PROCEDURE delete_operation_groups
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_operation_group_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< insert_operation_groups >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_operation_groups_api.insert_operation_groups
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
PROCEDURE insert_operation_groups
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_operation_group_code         in     varchar2
  ,p_description                  in     varchar2
  ,p_business_group_id            in     number
  ,p_operation_group_id              out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_operation_groups >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_operation_groups_api.update_operation_groups
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
PROCEDURE update_operation_groups
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_operation_group_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_operation_group_code         in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  );
end pqh_de_operation_groups_swi;

 

/
