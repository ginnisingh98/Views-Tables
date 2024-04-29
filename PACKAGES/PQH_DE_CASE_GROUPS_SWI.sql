--------------------------------------------------------
--  DDL for Package PQH_DE_CASE_GROUPS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_CASE_GROUPS_SWI" AUTHID CURRENT_USER As
/* $Header: pqcgnswi.pkh 115.2 2002/11/27 04:43:35 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_case_groups >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_case_groups_api.delete_case_groups
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
PROCEDURE delete_case_groups
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_case_group_id                in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_case_groups >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_case_groups_api.insert_case_groups
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
PROCEDURE insert_case_groups
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_case_group_number            in     varchar2
  ,p_description                  in     varchar2
  ,p_advanced_pay_grade           in     number
  ,p_entries_in_minute            in     varchar2
  ,p_period_of_prob_advmnt        in     number
  ,p_period_of_time_advmnt        in     number
  ,p_advancement_to               in     number
  ,p_advancement_additional_pyt   in     number
  ,p_time_advanced_pay_grade      in     number
  ,p_time_advancement_to          in     number
  ,p_business_group_id            in     number
  ,p_time_advn_units              in     varchar2
  ,p_prob_advn_units              in     varchar2
  ,p_SUB_CSGRP_DESCRIPTION        in     VARCHAR2
  ,p_case_group_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_case_groups >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_case_groups_api.update_case_groups
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
PROCEDURE update_case_groups
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_case_group_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_case_group_number            in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_advanced_pay_grade           in     number    default hr_api.g_number
  ,p_entries_in_minute            in     varchar2  default hr_api.g_varchar2
  ,p_period_of_prob_advmnt        in     number    default hr_api.g_number
  ,p_period_of_time_advmnt        in     number    default hr_api.g_number
  ,p_advancement_to               in     number    default hr_api.g_number
  ,p_advancement_additional_pyt   in     number    default hr_api.g_number
  ,p_time_advanced_pay_grade      in     number    default hr_api.g_number
  ,p_time_advancement_to          in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_time_advn_units              in     varchar2  default hr_api.g_varchar2
  ,p_prob_advn_units              in     varchar2  default hr_api.g_varchar2
  ,p_SUB_CSGRP_DESCRIPTION        in     VARCHAR2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
end pqh_de_case_groups_swi;

 

/
