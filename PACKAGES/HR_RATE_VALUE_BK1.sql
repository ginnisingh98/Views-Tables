--------------------------------------------------------
--  DDL for Package HR_RATE_VALUE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATE_VALUE_BK1" AUTHID CURRENT_USER AS
/* $Header: pypgrapi.pkh 120.1 2005/10/02 02:32:48 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_rate_value_b >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_rate_value_b
  (p_effective_date           IN     DATE
  ,p_business_group_id        IN     NUMBER
  ,p_rate_id                  IN     NUMBER
  ,p_grade_or_spinal_point_id IN     NUMBER
  ,p_rate_type                IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2
  ,p_maximum                  IN     VARCHAR2
  ,p_mid_value                IN     VARCHAR2
  ,p_minimum                  IN     VARCHAR2
  ,p_sequence                 IN     NUMBER
  ,p_value                    IN     VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_rate_value_a >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_rate_value_a
  (p_effective_date           IN     DATE
  ,p_grade_rule_Id            IN     NUMBER
  ,p_object_version_number    IN     NUMBER
  ,p_effective_start_date     IN     DATE
  ,p_effective_end_date       IN     DATE
  ,p_business_group_id        IN     NUMBER
  ,p_rate_id                  IN     NUMBER
  ,p_grade_or_spinal_point_id IN     NUMBER
  ,p_rate_type                IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2
  ,p_maximum                  IN     VARCHAR2
  ,p_mid_value                IN     VARCHAR2
  ,p_minimum                  IN     VARCHAR2
  ,p_sequence                 IN     NUMBER
  ,p_value                    IN     VARCHAR2);
--
END hr_rate_value_bk1;

 

/
