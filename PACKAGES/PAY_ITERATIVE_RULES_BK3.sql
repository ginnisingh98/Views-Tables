--------------------------------------------------------
--  DDL for Package PAY_ITERATIVE_RULES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ITERATIVE_RULES_BK3" AUTHID CURRENT_USER as
/* $Header: pyitrapi.pkh 120.2 2005/10/24 00:42:53 adkumar noship $ */
--
-- ---------------------------------------------------------------------
-- |---------------------< delete_iterative_rule_b  >-----------------------|
-- ---------------------------------------------------------------------
--
procedure delete_iterative_rule_b
  (
   p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_iterative_rule_id                in     number
  ,p_object_version_number            in     number
  );
--
-- ---------------------------------------------------------------------
-- |---------------------< delete_iterative_rule_a  >-----------------------|
-- ---------------------------------------------------------------------
--
procedure delete_iterative_rule_a
  (
   p_effective_date                   in     date
  ,p_datetrack_mode                   in     varchar2
  ,p_iterative_rule_id                in     number
  ,p_object_version_number            in     number
  ,p_effective_start_date             in     date
  ,p_effective_end_date               in     date
  );
end pay_iterative_rules_bk3;

 

/
