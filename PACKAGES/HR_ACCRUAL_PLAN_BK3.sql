--------------------------------------------------------
--  DDL for Package HR_ACCRUAL_PLAN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ACCRUAL_PLAN_BK3" AUTHID CURRENT_USER as
/* $Header: hrpapapi.pkh 120.1.12010000.1 2008/07/28 03:37:27 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_accrual_plan_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_accrual_plan_b
  (p_effective_date                in     date
  ,p_accrual_plan_id               in     number
  ,p_accrual_plan_element_type_id  in     number
  ,p_co_element_type_id            in     number
  ,p_residual_element_type_id      in     number
  ,p_balance_element_type_id       in     number
  ,p_tagging_element_type_id       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_accrual_plan_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_accrual_plan_a
  (p_effective_date                in     date
  ,p_accrual_plan_id               in     number
  ,p_accrual_plan_element_type_id  in     number
  ,p_co_element_type_id            in     number
  ,p_residual_element_type_id      in     number
  ,p_balance_element_type_id       in     number
  ,p_tagging_element_type_id       in     number
  ,p_object_version_number         in     number
  );
--
end hr_accrual_plan_bk3;

/
