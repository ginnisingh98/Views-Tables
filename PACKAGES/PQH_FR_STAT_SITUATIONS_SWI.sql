--------------------------------------------------------
--  DDL for Package PQH_FR_STAT_SITUATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_STAT_SITUATIONS_SWI" AUTHID CURRENT_USER As
/* $Header: pqstsswi.pkh 120.0 2005/05/29 02:43 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_statutory_situation >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_stat_situations_api.create_statutory_situation
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
PROCEDURE create_statutory_situation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default null
  ,p_business_group_id            in     number
  ,p_situation_name               in     varchar2
  ,p_type_of_ps                   in     varchar2
  ,p_situation_type               in     varchar2
  ,p_sub_type                     in     varchar2  default null
  ,p_source                       in     varchar2  default null
  ,p_location                     in     varchar2  default null
  ,p_reason                       in     varchar2  default null
  ,p_is_default                   in     varchar2  default null
  ,p_date_from                    in     date      default null
  ,p_date_to                      in     date      default null
  ,p_request_type                 in     varchar2  default null
  ,p_employee_agreement_needed    in     varchar2  default null
  ,p_manager_agreement_needed     in     varchar2  default null
  ,p_print_arrette                in     varchar2  default null
  ,p_reserve_position             in     varchar2  default null
  ,p_allow_progressions           in     varchar2  default null
  ,p_extend_probation_period      in     varchar2  default null
  ,p_remuneration_paid            in     varchar2  default null
  ,p_pay_share                    in     number    default null
  ,p_pay_periods                  in     number    default null
  ,p_frequency                    in     varchar2  default null
  ,p_first_period_max_duration    in     number    default null
  ,p_min_duration_per_request     in     number    default null
  ,p_max_duration_per_request     in     number    default null
  ,p_max_duration_whole_career    in     number    default null
  ,p_renewable_allowed            in     varchar2  default null
  ,p_max_no_of_renewals           in     number    default null
  ,p_max_duration_per_renewal     in     number    default null
  ,p_max_tot_continuous_duration  in     number    default null
  ,p_remunerate_assign_status_id  in     number    default null
  ,p_statutory_situation_id          out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_statutory_situation >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_stat_situations_api.delete_statutory_situation
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
PROCEDURE delete_statutory_situation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_statutory_situation_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_statutory_situation >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_stat_situations_api.update_statutory_situation
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
PROCEDURE update_statutory_situation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_statutory_situation_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_situation_name               in     varchar2  default hr_api.g_varchar2
  ,p_type_of_ps                   in     varchar2  default hr_api.g_varchar2
  ,p_situation_type               in     varchar2  default hr_api.g_varchar2
  ,p_sub_type                     in     varchar2  default hr_api.g_varchar2
  ,p_source                       in     varchar2  default hr_api.g_varchar2
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_reason                       in     varchar2  default hr_api.g_varchar2
  ,p_is_default                   in     varchar2  default hr_api.g_varchar2
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_request_type                 in     varchar2  default hr_api.g_varchar2
  ,p_employee_agreement_needed    in     varchar2  default hr_api.g_varchar2
  ,p_manager_agreement_needed     in     varchar2  default hr_api.g_varchar2
  ,p_print_arrette                in     varchar2  default hr_api.g_varchar2
  ,p_reserve_position             in     varchar2  default hr_api.g_varchar2
  ,p_allow_progressions           in     varchar2  default hr_api.g_varchar2
  ,p_extend_probation_period      in     varchar2  default hr_api.g_varchar2
  ,p_remuneration_paid            in     varchar2  default hr_api.g_varchar2
  ,p_pay_share                    in     number    default hr_api.g_number
  ,p_pay_periods                  in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_first_period_max_duration    in     number    default hr_api.g_number
  ,p_min_duration_per_request     in     number    default hr_api.g_number
  ,p_max_duration_per_request     in     number    default hr_api.g_number
  ,p_max_duration_whole_career    in     number    default hr_api.g_number
  ,p_renewable_allowed            in     varchar2  default hr_api.g_varchar2
  ,p_max_no_of_renewals           in     number    default hr_api.g_number
  ,p_max_duration_per_renewal     in     number    default hr_api.g_number
  ,p_max_tot_continuous_duration  in     number    default hr_api.g_number
  ,p_remunerate_assign_status_id  in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  );
end pqh_fr_stat_situations_swi;

 

/
