--------------------------------------------------------
--  DDL for Package PQH_DE_VLDOPR_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDOPR_SWI" AUTHID CURRENT_USER As
/* $Header: pqopsswi.pkh 120.0 2005/05/29 02:16:20 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_vldtn_oprn >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_vldopr_api.delete_vldtn_oprn
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
PROCEDURE delete_vldtn_oprn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_wrkplc_vldtn_op_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_vldtn_oprn >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_vldopr_api.insert_vldtn_oprn
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
PROCEDURE insert_vldtn_oprn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_wrkplc_vldtn_ver_id          in     number
  ,p_wrkplc_operation_id          in     number
  ,p_description                  in     varchar2
  ,p_unit_percentage              in     number
  ,p_wrkplc_vldtn_op_id              out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_vldtn_oprn >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_vldopr_api.update_vldtn_oprn
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
PROCEDURE update_vldtn_oprn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_wrkplc_vldtn_ver_id          in     number    default hr_api.g_number
  ,p_wrkplc_operation_id          in     number    default hr_api.g_number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_unit_percentage              in     number    default hr_api.g_number
  ,p_wrkplc_vldtn_op_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end pqh_de_vldopr_swi;

 

/
