--------------------------------------------------------
--  DDL for Package PQH_DE_VLDVER_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDVER_SWI" AUTHID CURRENT_USER As
/* $Header: pqverswi.pkh 120.0 2005/05/29 02:53:54 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_vldtn_vern >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_vldver_api.delete_vldtn_vern
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
PROCEDURE delete_vldtn_vern
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_wrkplc_vldtn_ver_id          in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_vldtn_vern >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_vldver_api.insert_vldtn_vern
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
PROCEDURE insert_vldtn_vern
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_wrkplc_vldtn_id              in     number
  ,p_version_number               in     number    default NULL
  ,p_remuneration_job_description in     varchar2  default NULL
  ,p_tariff_contract_code         in     varchar2
  ,p_tariff_group_code            in     varchar2
  ,p_job_group_id                 in     number    default NULL
  ,p_remuneration_job_id          in     number    default NULL
  ,p_derived_grade_id             in     number    default NULL
  ,p_derived_case_group_id        in     number    default NULL
  ,p_derived_subcasgrp_id         in     number    default NULL
  ,p_user_enterable_grade_id      in     number    default NULL
  ,p_user_enterable_case_group_id in     number    default NULL
  ,p_user_enterable_subcasgrp_id  in     number    default NULL
  ,p_freeze                       in     varchar2  default NULL
  ,p_wrkplc_vldtn_ver_id             out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_vldtn_vern >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_vldver_api.update_vldtn_vern
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
PROCEDURE update_vldtn_vern
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_wrkplc_vldtn_id              in     number    default hr_api.g_number
  ,p_version_number               in     number    default hr_api.g_number
  ,p_remuneration_job_description in     varchar2  default hr_api.g_varchar2
  ,p_tariff_contract_code         in     varchar2  default hr_api.g_varchar2
  ,p_tariff_group_code            in     varchar2  default hr_api.g_varchar2
  ,p_job_group_id                 in     number    default hr_api.g_number
  ,p_remuneration_job_id          in     number    default hr_api.g_number
  ,p_derived_grade_id             in     number    default hr_api.g_number
  ,p_derived_case_group_id        in     number    default hr_api.g_number
  ,p_derived_subcasgrp_id         in     number    default hr_api.g_number
  ,p_user_enterable_grade_id      in     number    default hr_api.g_number
  ,p_user_enterable_case_group_id in     number    default hr_api.g_number
  ,p_user_enterable_subcasgrp_id  in     number    default hr_api.g_number
  ,p_freeze                       in     varchar2  default hr_api.g_varchar2
  ,p_wrkplc_vldtn_ver_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end pqh_de_vldver_swi;

 

/
