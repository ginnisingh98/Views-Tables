--------------------------------------------------------
--  DDL for Package PAY_STATUS_PROCESSING_RULE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_STATUS_PROCESSING_RULE_BK1" AUTHID CURRENT_USER as
/* $Header: pypprapi.pkh 120.1 2005/10/02 02:46:29 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_status_process_rule_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_status_process_rule_b
(
   p_effective_date                 in     date
  ,p_element_type_id                in     number
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_assignment_status_type_id      in     number
  ,p_formula_id                     in     number
  ,p_comments                       in     varchar2
  ,p_legislation_subgroup           in     varchar2
);
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_status_process_rule_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure create_status_process_rule_a
(
   p_effective_date                 in     date
  ,p_element_type_id                in     number
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_assignment_status_type_id      in     number
  ,p_formula_id                     in     number
  ,p_comments                       in     varchar2
  ,p_legislation_subgroup           in     varchar2
  ,p_status_processing_rule_id      in     number
  ,p_effective_start_date           in     date
  ,p_effective_end_date             in     date
  ,p_object_version_number          in     number
  ,p_formula_mismatch_warning       in     boolean
);
end pay_status_processing_rule_bk1;

 

/
