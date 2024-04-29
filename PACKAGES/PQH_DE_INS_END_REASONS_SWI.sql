--------------------------------------------------------
--  DDL for Package PQH_DE_INS_END_REASONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_INS_END_REASONS_SWI" AUTHID CURRENT_USER As
/* $Header: pqpreswi.pkh 115.1 2002/12/03 20:42:17 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pension_end_reasons >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_ins_end_reasons_api.delete_pension_end_reasons
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
PROCEDURE delete_pension_end_reasons
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_ins_end_reason_id            in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< insert_pension_end_reasons >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_ins_end_reasons_api.insert_pension_end_reasons
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
PROCEDURE insert_pension_end_reasons
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_provider_organization_id     in     number
  ,p_end_reason_number            in     varchar2
  ,p_end_reason_short_name        in     varchar2
  ,p_end_reason_description       in     varchar2
  ,p_ins_end_reason_id               out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_pension_end_reasons >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_ins_end_reasons_api.update_pension_end_reasons
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
PROCEDURE update_pension_end_reasons
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_ins_end_reason_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_provider_organization_id     in     number    default hr_api.g_number
  ,p_end_reason_number            in     varchar2  default hr_api.g_varchar2
  ,p_end_reason_short_name        in     varchar2  default hr_api.g_varchar2
  ,p_end_reason_description       in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
end pqh_de_ins_end_reasons_swi;

 

/
