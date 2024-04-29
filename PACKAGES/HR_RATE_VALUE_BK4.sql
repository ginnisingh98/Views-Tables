--------------------------------------------------------
--  DDL for Package HR_RATE_VALUE_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATE_VALUE_BK4" AUTHID CURRENT_USER AS
/* $Header: pypgrapi.pkh 115.2 2002/06/12 10:20:34 pkm ship        $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_assignment_rate_value_b >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_assignment_rate_value_b
  (p_effective_date           IN     DATE
  ,p_business_group_id        IN     NUMBER
  ,p_rate_id                  IN     NUMBER
  ,p_assignment_id            IN     NUMBER
  ,p_rate_type                IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2
  ,p_value                    IN     VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_assignment_rate_value_a >-------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_assignment_rate_value_a
  (p_effective_date           IN     DATE
  ,p_grade_rule_Id            IN     NUMBER
  ,p_object_version_number    IN     NUMBER
  ,p_effective_start_date     IN     DATE
  ,p_effective_end_date       IN     DATE
  ,p_business_group_id        IN     NUMBER
  ,p_rate_id                  IN     NUMBER
  ,p_assignment_id            IN     NUMBER
  ,p_rate_type                IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2
  ,p_value                    IN     VARCHAR2);
--
END hr_rate_value_bk4;

 

/
