--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATION_PERIODS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATION_PERIODS_BK3" AUTHID CURRENT_USER as
/* $Header: pqvlpapi.pkh 120.1 2005/10/02 02:28:53 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Validation_Period_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Validation_Period_b
  (p_validation_period_id                        in     number
  ,p_object_version_number                in     number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <Delete_Validation_Period_a> >---------------------|
-- ----------------------------------------------------------------------------

Procedure Delete_Validation_Period_a
  (p_validation_period_id                        in     number
  ,p_object_version_number                in     number);

end pqh_fr_validation_periods_bk3;

 

/
