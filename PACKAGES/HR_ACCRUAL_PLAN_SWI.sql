--------------------------------------------------------
--  DDL for Package HR_ACCRUAL_PLAN_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ACCRUAL_PLAN_SWI" AUTHID CURRENT_USER As
/* $Header: pypapswi.pkh 120.0 2005/05/29 07:15 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_accrual_plan >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_accrual_plan_api.create_accrual_plan
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
PROCEDURE create_accrual_plan
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_accrual_formula_id           in     number
  ,p_co_formula_id                in     number
  ,p_pto_input_value_id           in     number
  ,p_accrual_plan_name            in     varchar2
  ,p_accrual_units_of_measure     in     varchar2
  ,p_accrual_category             in     varchar2  default null
  ,p_accrual_start                in     varchar2  default null
  ,p_ineligible_period_length     in     number    default null
  ,p_ineligible_period_type       in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_ineligibility_formula_id     in     number    default null
  ,p_balance_dimension_id         in     number    default null
  ,p_information_category         in     varchar2  default null
  ,p_information1                 in     varchar2  default null
  ,p_information2                 in     varchar2  default null
  ,p_information3                 in     varchar2  default null
  ,p_information4                 in     varchar2  default null
  ,p_information5                 in     varchar2  default null
  ,p_information6                 in     varchar2  default null
  ,p_information7                 in     varchar2  default null
  ,p_information8                 in     varchar2  default null
  ,p_information9                 in     varchar2  default null
  ,p_information10                in     varchar2  default null
  ,p_information11                in     varchar2  default null
  ,p_information12                in     varchar2  default null
  ,p_information13                in     varchar2  default null
  ,p_information14                in     varchar2  default null
  ,p_information15                in     varchar2  default null
  ,p_information16                in     varchar2  default null
  ,p_information17                in     varchar2  default null
  ,p_information18                in     varchar2  default null
  ,p_information19                in     varchar2  default null
  ,p_information20                in     varchar2  default null
  ,p_information21                in     varchar2  default null
  ,p_information22                in     varchar2  default null
  ,p_information23                in     varchar2  default null
  ,p_information24                in     varchar2  default null
  ,p_information25                in     varchar2  default null
  ,p_information26                in     varchar2  default null
  ,p_information27                in     varchar2  default null
  ,p_information28                in     varchar2  default null
  ,p_information29                in     varchar2  default null
  ,p_information30                in     varchar2  default null
  ,p_accrual_plan_id                 out nocopy number
  ,p_accrual_plan_element_type_id    out nocopy number
  ,p_co_element_type_id              out nocopy number
  ,p_co_input_value_id               out nocopy number
  ,p_co_date_input_value_id          out nocopy number
  ,p_co_exp_date_input_value_id      out nocopy number
  ,p_residual_element_type_id        out nocopy number
  ,p_residual_input_value_id         out nocopy number
  ,p_residual_date_input_value_id    out nocopy number
  ,p_payroll_formula_id              out nocopy number
  ,p_defined_balance_id              out nocopy number
  ,p_balance_element_type_id         out nocopy number
  ,p_tagging_element_type_id         out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_no_link_message                 out nocopy number
  ,p_check_accrual_ff                out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_accrual_plan >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_accrual_plan_api.update_accrual_plan
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
PROCEDURE update_accrual_plan
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_accrual_plan_id              in     number
  ,p_pto_input_value_id           in     number    default hr_api.g_number
  ,p_accrual_category             in     varchar2  default hr_api.g_varchar2
  ,p_accrual_start                in     varchar2  default hr_api.g_varchar2
  ,p_ineligible_period_length     in     number    default hr_api.g_number
  ,p_ineligible_period_type       in     varchar2  default hr_api.g_varchar2
  ,p_accrual_formula_id           in     number    default hr_api.g_number
  ,p_co_formula_id                in     number    default hr_api.g_number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_ineligibility_formula_id     in     number    default hr_api.g_number
  ,p_balance_dimension_id         in     number    default hr_api.g_number
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_information11                in     varchar2  default hr_api.g_varchar2
  ,p_information12                in     varchar2  default hr_api.g_varchar2
  ,p_information13                in     varchar2  default hr_api.g_varchar2
  ,p_information14                in     varchar2  default hr_api.g_varchar2
  ,p_information15                in     varchar2  default hr_api.g_varchar2
  ,p_information16                in     varchar2  default hr_api.g_varchar2
  ,p_information17                in     varchar2  default hr_api.g_varchar2
  ,p_information18                in     varchar2  default hr_api.g_varchar2
  ,p_information19                in     varchar2  default hr_api.g_varchar2
  ,p_information20                in     varchar2  default hr_api.g_varchar2
  ,p_information21                in     varchar2  default hr_api.g_varchar2
  ,p_information22                in     varchar2  default hr_api.g_varchar2
  ,p_information23                in     varchar2  default hr_api.g_varchar2
  ,p_information24                in     varchar2  default hr_api.g_varchar2
  ,p_information25                in     varchar2  default hr_api.g_varchar2
  ,p_information26                in     varchar2  default hr_api.g_varchar2
  ,p_information27                in     varchar2  default hr_api.g_varchar2
  ,p_information28                in     varchar2  default hr_api.g_varchar2
  ,p_information29                in     varchar2  default hr_api.g_varchar2
  ,p_information30                in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_payroll_formula_id              out nocopy number
  ,p_defined_balance_id              out nocopy number
  ,p_balance_element_type_id         out nocopy number
  ,p_tagging_element_type_id         out nocopy number
  ,p_check_accrual_ff                out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_accrual_plan >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_accrual_plan_api.delete_accrual_plan
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
PROCEDURE delete_accrual_plan
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_accrual_plan_id              in     number
  ,p_accrual_plan_element_type_id in     number
  ,p_co_element_type_id           in     number
  ,p_residual_element_type_id     in     number
  ,p_balance_element_type_id      in     number
  ,p_tagging_element_type_id      in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end hr_accrual_plan_swi;

 

/
