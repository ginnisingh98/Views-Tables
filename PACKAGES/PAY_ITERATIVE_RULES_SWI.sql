--------------------------------------------------------
--  DDL for Package PAY_ITERATIVE_RULES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ITERATIVE_RULES_SWI" AUTHID CURRENT_USER As
/* $Header: pypitswi.pkh 120.0 2006/01/25 16:08 ndorai noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_iterative_rule >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_iterative_rules_api.create_iterative_rule
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
PROCEDURE create_iterative_rule
  (p_effective_date               in     date
  ,p_element_type_id              in     number
  ,p_result_name                  in     varchar2
  ,p_iterative_rule_type          in     varchar2
  ,p_input_value_id               in     number    default null
  ,p_severity_level               in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_iterative_rule_id               out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_iterative_rule >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_iterative_rules_api.delete_iterative_rule
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
PROCEDURE delete_iterative_rule
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_iterative_rule_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_iterative_rule >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_iterative_rules_api.update_iterative_rule
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
PROCEDURE update_iterative_rule
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_iterative_rule_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_element_type_id              in     number    default hr_api.g_number
  ,p_result_name                  in     varchar2  default hr_api.g_varchar2
  ,p_iterative_rule_type          in     varchar2  default hr_api.g_varchar2
  ,p_input_value_id               in     number    default hr_api.g_number
  ,p_severity_level               in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end pay_iterative_rules_swi;

 

/
