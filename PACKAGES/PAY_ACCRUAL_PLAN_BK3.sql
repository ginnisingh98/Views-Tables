--------------------------------------------------------
--  DDL for Package PAY_ACCRUAL_PLAN_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ACCRUAL_PLAN_BK3" AUTHID CURRENT_USER as
/* $Header: pypapapi.pkh 115.11 2002/04/22 10:28:56 pkm ship   $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_pay_accrual_plan_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pay_accrual_plan_b
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
-- |------------------------< delete_pay_accrual_plan_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pay_accrual_plan_a
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
end pay_accrual_plan_bk3;

 

/
