--------------------------------------------------------
--  DDL for Package PAY_PL_SII_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_SII_SWI" AUTHID CURRENT_USER As
/* $Header: pypsdswi.pkh 120.0 2005/10/16 22:22 mseshadr noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_sii_details >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_pl_sii_api.create_pl_sii_details
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
PROCEDURE create_pl_sii_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_contract_category            in     varchar2
  ,p_per_or_asg_id                in     number
  ,p_business_group_id            in     number
  ,p_emp_social_security_info     in     varchar2
  ,p_old_age_contribution         in     varchar2  default null
  ,p_pension_contribution         in     varchar2  default null
  ,p_sickness_contribution        in     varchar2  default null
  ,p_work_injury_contribution     in     varchar2  default null
  ,p_labor_contribution           in     varchar2  default null
  ,p_health_contribution          in     varchar2  default null
  ,p_unemployment_contribution    in     varchar2  default null
  ,p_old_age_cont_end_reason      in     varchar2  default null
  ,p_pension_cont_end_reason      in     varchar2  default null
  ,p_sickness_cont_end_reason     in     varchar2  default null
  ,p_work_injury_cont_end_reason  in     varchar2  default null
  ,p_labor_fund_cont_end_reason   in     varchar2  default null
  ,p_health_cont_end_reason       in     varchar2  default null
  ,p_unemployment_cont_end_reason in     varchar2  default null
  ,p_sii_details_id               in     number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ,p_effective_date_warning          out nocopy   boolean
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pl_sii_details >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_pl_sii_api.update_pl_sii_details
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
PROCEDURE update_pl_sii_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_sii_details_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_emp_social_security_info     in     varchar2  default hr_api.g_varchar2
  ,p_old_age_contribution         in     varchar2  default hr_api.g_varchar2
  ,p_pension_contribution         in     varchar2  default hr_api.g_varchar2
  ,p_sickness_contribution        in     varchar2  default hr_api.g_varchar2
  ,p_work_injury_contribution     in     varchar2  default hr_api.g_varchar2
  ,p_labor_contribution           in     varchar2  default hr_api.g_varchar2
  ,p_health_contribution          in     varchar2  default hr_api.g_varchar2
  ,p_unemployment_contribution    in     varchar2  default hr_api.g_varchar2
  ,p_old_age_cont_end_reason      in     varchar2  default hr_api.g_varchar2
  ,p_pension_cont_end_reason      in     varchar2  default hr_api.g_varchar2
  ,p_sickness_cont_end_reason     in     varchar2  default hr_api.g_varchar2
  ,p_work_injury_cont_end_reason  in     varchar2  default hr_api.g_varchar2
  ,p_labor_fund_cont_end_reason   in     varchar2  default hr_api.g_varchar2
  ,p_health_cont_end_reason       in     varchar2  default hr_api.g_varchar2
  ,p_unemployment_cont_end_reason in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pl_sii_details >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_pl_sii_api.delete_pl_sii_details
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
PROCEDURE delete_pl_sii_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_delete_mode        in     varchar2
  ,p_sii_details_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end pay_pl_sii_swi;

 

/
