--------------------------------------------------------
--  DDL for Package HR_RATE_VALUE_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATE_VALUE_BK5" AUTHID CURRENT_USER AS
/* $Header: pypgrapi.pkh 115.2 2002/06/12 10:20:34 pkm ship        $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_assignment_rate_values_b >------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_assignment_rate_value_b
  (p_grade_rule_id            IN     NUMBER
  ,p_effective_date           IN     DATE
  ,p_currency_code            IN     VARCHAR2
  ,p_value                    IN     VARCHAR2
  ,p_object_version_number    IN     NUMBER);
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_assignment_rate_values_a >------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_assignment_rate_value_a
  (p_grade_rule_id            IN     NUMBER
  ,p_effective_date           IN     DATE
  ,p_currency_code            IN     VARCHAR2
  ,p_value                    IN     VARCHAR2
  ,p_object_version_number    IN     NUMBER
  ,p_effective_start_date     IN     DATE
  ,p_effective_end_date       IN     DATE);
--
END hr_rate_value_bk5;

 

/
