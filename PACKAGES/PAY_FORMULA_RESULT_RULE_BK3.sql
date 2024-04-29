--------------------------------------------------------
--  DDL for Package PAY_FORMULA_RESULT_RULE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FORMULA_RESULT_RULE_BK3" AUTHID CURRENT_USER as
/* $Header: pyfrrapi.pkh 120.1 2005/10/02 02:46:12 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< DELETE_FORMULA_RESULT_RULE_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_FORMULA_RESULT_RULE_b
 (p_effective_date              in     date
 ,p_datetrack_delete_mode       in     varchar2
 ,p_formula_result_rule_id      in     number
 ,p_object_version_number       in     number
 );
--
-- ----------------------------------------------------------------------------
-- |----------------------< DELETE_FORMULA_RESULT_RULE_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_FORMULA_RESULT_RULE_a
 (p_effective_date              in     date
 ,p_datetrack_delete_mode       in     varchar2
 ,p_formula_result_rule_id      in     number
 ,p_object_version_number       in     number
 ,p_effective_start_date        in     date
 ,p_effective_end_date          in     date
 );
--
end PAY_FORMULA_RESULT_RULE_bk3;

 

/
