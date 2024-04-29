--------------------------------------------------------
--  DDL for Package PAY_PL_PAYE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_PAYE_SWI" AUTHID CURRENT_USER As
/* $Header: pyppdswi.pkh 120.0 2005/10/14 05:12 mseshadr noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_pl_paye_details >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_pl_paye_api.create_pl_paye_details
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
PROCEDURE create_pl_paye_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_contract_category            in     varchar2
  ,p_per_or_asg_id                in     number
  ,p_business_group_id            in     number
  ,p_tax_reduction                in     varchar2
  ,p_tax_calc_with_spouse_child   in     varchar2
  ,p_income_reduction             in     varchar2
  ,p_income_reduction_amount      in     number    default null
  ,p_rate_of_tax                  in     varchar2
  ,p_paye_details_id              in     number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_pl_paye_details >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_pl_paye_api.update_pl_paye_details
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
PROCEDURE update_pl_paye_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_paye_details_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_tax_reduction                in     varchar2  default hr_api.g_varchar2
  ,p_tax_calc_with_spouse_child   in     varchar2  default hr_api.g_varchar2
  ,p_income_reduction             in     varchar2  default hr_api.g_varchar2
  ,p_income_reduction_amount      in     number    default hr_api.g_number
  ,p_rate_of_tax                  in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pl_paye_details >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_pl_paye_api.delete_pl_paye_details
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
PROCEDURE delete_pl_paye_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_delete_mode        in     varchar2
  ,p_paye_details_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end pay_pl_paye_swi;

 

/
