--------------------------------------------------------
--  DDL for Package HR_RATE_VALUE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATE_VALUE_BK3" AUTHID CURRENT_USER AS
/* $Header: pypgrapi.pkh 120.1 2005/10/02 02:32:48 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_rate_value_b >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_rate_value_b
  (p_grade_rule_id                  IN  NUMBER
  ,p_object_version_number          IN  NUMBER
  ,p_effective_date                 IN  DATE);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_rate_value_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rate_value_a
  (p_grade_rule_id                  IN  NUMBER
  ,p_effective_start_date           IN  DATE
  ,p_effective_end_date             IN  DATE
  ,p_object_version_number          IN  NUMBER
  ,p_effective_date                 IN  DATE);
--
END hr_rate_value_bk3;

 

/
