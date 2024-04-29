--------------------------------------------------------
--  DDL for Package PAY_FORMULA_RESULT_RULE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FORMULA_RESULT_RULE_BK2" AUTHID CURRENT_USER as
/* $Header: pyfrrapi.pkh 120.1 2005/10/02 02:46:12 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< UPDATE_FORMULA_RESULT_RULE_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_FORMULA_RESULT_RULE_b
  (p_effective_date              in     date
  ,p_datetrack_update_mode       in     varchar2
  ,p_formula_result_rule_id      in     number
  ,p_object_version_number       in     number
  ,p_result_rule_type            in     varchar2
  ,p_element_type_id             in     number
  ,p_severity_level              in     varchar2
  ,p_input_value_id              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< UPDATE_FORMULA_RESULT_RULE_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_FORMULA_RESULT_RULE_a
  (p_effective_date              in     date
  ,p_datetrack_update_mode       in     varchar2
  ,p_formula_result_rule_id      in     number
  ,p_object_version_number       in     number
  ,p_result_rule_type            in     varchar2
  ,p_element_type_id             in     number
  ,p_severity_level              in     varchar2
  ,p_input_value_id              in     number
  ,p_effective_start_date        in     date
  ,p_effective_end_date          in     date
  );
--
end PAY_FORMULA_RESULT_RULE_bk2;

 

/
