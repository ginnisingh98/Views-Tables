--------------------------------------------------------
--  DDL for Package PAY_FORMULA_RESULT_RULE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FORMULA_RESULT_RULE_BK1" AUTHID CURRENT_USER as
/* $Header: pyfrrapi.pkh 120.1 2005/10/02 02:46:12 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< CREATE_FORMULA_RESULT_RULE_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_FORMULA_RESULT_RULE_b
  (p_effective_date              in     date
  ,p_status_processing_rule_id   in     number
  ,p_result_name                 in     varchar2
  ,p_result_rule_type            in     varchar2
  ,p_business_group_id           in     number
  ,p_legislation_code            in     varchar2
  ,p_element_type_id             in     number
  ,p_legislation_subgroup        in     varchar2
  ,p_severity_level              in     varchar2
  ,p_input_value_id              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< CREATE_FORMULA_RESULT_RULE_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_FORMULA_RESULT_RULE_a
  (p_effective_date              in     date
  ,p_status_processing_rule_id   in     number
  ,p_result_name                 in     varchar2
  ,p_result_rule_type            in     varchar2
  ,p_business_group_id           in     number
  ,p_legislation_code            in     varchar2
  ,p_element_type_id             in     number
  ,p_legislation_subgroup        in     varchar2
  ,p_severity_level              in     varchar2
  ,p_input_value_id              in     number
  ,p_formula_result_rule_id      in     number
  ,p_effective_start_date        in     date
  ,p_effective_end_date          in     date
  ,p_object_version_number       in     number
  );
--
end PAY_FORMULA_RESULT_RULE_bk1;

 

/
