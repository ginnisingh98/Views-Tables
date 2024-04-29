--------------------------------------------------------
--  DDL for Package HR_ACCRUAL_PLAN_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ACCRUAL_PLAN_BK2" AUTHID CURRENT_USER as
/* $Header: hrpapapi.pkh 120.1.12010000.1 2008/07/28 03:37:27 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_accrual_plan_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_accrual_plan_b
  (p_accrual_plan_id               in     number
  ,p_pto_input_value_id            in     number
  ,p_accrual_category              in     varchar2
  ,p_accrual_start                 in     varchar2
  ,p_ineligible_period_length      in     number
  ,p_ineligible_period_type        in     varchar2
  ,p_accrual_formula_id            in     number
  ,p_co_formula_id                 in     number
  ,p_description                   in     varchar2
  ,p_ineligibility_formula_id      in     number
  ,p_balance_dimension_id          in     number
  ,p_object_version_number         in     number
  ,p_information_category          in     varchar2
  ,p_information1                  in     varchar2
  ,p_information2                  in     varchar2
  ,p_information3                  in     varchar2
  ,p_information4                  in     varchar2
  ,p_information5                  in     varchar2
  ,p_information6                  in     varchar2
  ,p_information7                  in     varchar2
  ,p_information8                  in     varchar2
  ,p_information9                  in     varchar2
  ,p_information10                 in     varchar2
  ,p_information11                 in     varchar2
  ,p_information12                 in     varchar2
  ,p_information13                 in     varchar2
  ,p_information14                 in     varchar2
  ,p_information15                 in     varchar2
  ,p_information16                 in     varchar2
  ,p_information17                 in     varchar2
  ,p_information18                 in     varchar2
  ,p_information19                 in     varchar2
  ,p_information20                 in     varchar2
  ,p_information21                 in     varchar2
  ,p_information22                 in     varchar2
  ,p_information23                 in     varchar2
  ,p_information24                 in     varchar2
  ,p_information25                 in     varchar2
  ,p_information26                 in     varchar2
  ,p_information27                 in     varchar2
  ,p_information28                 in     varchar2
  ,p_information29                 in     varchar2
  ,p_information30                 in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_accrual_plan_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_accrual_plan_a
  (p_accrual_plan_id               in     number
  ,p_pto_input_value_id            in     number
  ,p_accrual_category              in     varchar2
  ,p_accrual_start                 in     varchar2
  ,p_ineligible_period_length      in     number
  ,p_ineligible_period_type        in     varchar2
  ,p_accrual_formula_id            in     number
  ,p_co_formula_id                 in     number
  ,p_description                   in     varchar2
  ,p_ineligibility_formula_id      in     number
  ,p_payroll_formula_id            in     number
  ,p_defined_balance_id            in     number
  ,p_balance_dimension_id          in     number
  ,p_tagging_element_type_id       in     number
  ,p_balance_element_type_id       in     number
  ,p_object_version_number         in     number
  ,p_information_category          in     varchar2
  ,p_information1                  in     varchar2
  ,p_information2                  in     varchar2
  ,p_information3                  in     varchar2
  ,p_information4                  in     varchar2
  ,p_information5                  in     varchar2
  ,p_information6                  in     varchar2
  ,p_information7                  in     varchar2
  ,p_information8                  in     varchar2
  ,p_information9                  in     varchar2
  ,p_information10                 in     varchar2
  ,p_information11                 in     varchar2
  ,p_information12                 in     varchar2
  ,p_information13                 in     varchar2
  ,p_information14                 in     varchar2
  ,p_information15                 in     varchar2
  ,p_information16                 in     varchar2
  ,p_information17                 in     varchar2
  ,p_information18                 in     varchar2
  ,p_information19                 in     varchar2
  ,p_information20                 in     varchar2
  ,p_information21                 in     varchar2
  ,p_information22                 in     varchar2
  ,p_information23                 in     varchar2
  ,p_information24                 in     varchar2
  ,p_information25                 in     varchar2
  ,p_information26                 in     varchar2
  ,p_information27                 in     varchar2
  ,p_information28                 in     varchar2
  ,p_information29                 in     varchar2
  ,p_information30                 in     varchar2
  );
--
end hr_accrual_plan_bk2;

/
