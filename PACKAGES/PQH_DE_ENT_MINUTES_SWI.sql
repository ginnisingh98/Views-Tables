--------------------------------------------------------
--  DDL for Package PQH_DE_ENT_MINUTES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_ENT_MINUTES_SWI" AUTHID CURRENT_USER As
/* $Header: pqetmswi.pkh 115.1 2002/11/27 23:43:28 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_ent_minutes >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_ent_minutes_api.delete_ent_minutes
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
PROCEDURE delete_ent_minutes
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_ent_minutes_id               in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_ent_minutes >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_ent_minutes_api.insert_ent_minutes
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
PROCEDURE insert_ent_minutes
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_tariff_group_cd              in     varchar2
  ,p_ent_minutes_cd               in     varchar2
  ,p_description                  in     varchar2
  ,p_business_group_id            in     number
  ,p_ent_minutes_id                  out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_ent_minutes >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_ent_minutes_api.update_ent_minutes
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
PROCEDURE update_ent_minutes
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_ent_minutes_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_tariff_group_cd              in     varchar2  default hr_api.g_varchar2
  ,p_ent_minutes_cd               in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  );
end pqh_de_ent_minutes_swi;

 

/
