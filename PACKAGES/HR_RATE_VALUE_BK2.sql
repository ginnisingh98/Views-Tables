--------------------------------------------------------
--  DDL for Package HR_RATE_VALUE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATE_VALUE_BK2" AUTHID CURRENT_USER AS
/* $Header: pypgrapi.pkh 120.1 2005/10/02 02:32:48 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_rate_values_b >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_rate_value_b
  (p_grade_rule_id            IN     NUMBER
  ,p_effective_date           IN     DATE
  ,p_currency_code            IN     VARCHAR2
  ,p_maximum                  IN     VARCHAR2
  ,p_mid_value                IN     VARCHAR2
  ,p_minimum                  IN     VARCHAR2
  ,p_sequence                 IN     NUMBER
  ,p_value                    IN     VARCHAR2
  ,p_object_version_number    IN     NUMBER);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_rate_values_a >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_rate_value_a
  (p_grade_rule_id            IN     NUMBER
  ,p_effective_date           IN     DATE
  ,p_currency_code            IN     VARCHAR2
  ,p_maximum                  IN     VARCHAR2
  ,p_mid_value                IN     VARCHAR2
  ,p_minimum                  IN     VARCHAR2
  ,p_sequence                 IN     NUMBER
  ,p_value                    IN     VARCHAR2
  ,p_object_version_number    IN     NUMBER
  ,p_effective_start_date     IN     DATE
  ,p_effective_end_date       IN     DATE);
--
END hr_rate_value_bk2;

 

/
