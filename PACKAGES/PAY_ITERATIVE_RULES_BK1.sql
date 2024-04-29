--------------------------------------------------------
--  DDL for Package PAY_ITERATIVE_RULES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ITERATIVE_RULES_BK1" AUTHID CURRENT_USER as
/* $Header: pyitrapi.pkh 120.2 2005/10/24 00:42:53 adkumar noship $ */
--
-- ---------------------------------------------------------------------
-- |-------------------< create_iterative_rule_b >------------------|
-- ---------------------------------------------------------------------
--
procedure create_iterative_rule_b
  (
   p_effective_date                 in     date
  ,p_element_type_id                in     number
  ,p_result_name                    in     varchar2
  ,p_iterative_rule_type            in     varchar2
  ,p_input_value_id                 in     number
  ,p_severity_level                 in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  );
--
-- ----------------------------------------------------------------------
-- |------------------< create_iterative_rule_a >------------------|
-- ---------------------------------------------------------------------
--
procedure create_iterative_rule_a
  (
   p_effective_date                 in     date
  ,p_element_type_id                in     number
  ,p_result_name                    in     varchar2
  ,p_iterative_rule_type            in     varchar2
  ,p_input_value_id                 in     number
  ,p_severity_level                 in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_iterative_rule_id              in      number
  ,p_object_version_number          in      number
  ,p_effective_start_date           in      date
  ,p_effective_end_date             in      date
  );
end pay_iterative_rules_bk1;

 

/
