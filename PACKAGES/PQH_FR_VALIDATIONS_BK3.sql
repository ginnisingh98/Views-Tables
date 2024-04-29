--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATIONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATIONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqvldapi.pkh 120.1 2005/10/02 02:28:42 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Validation_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Validation_b
  (p_validation_id                        in     number
  ,p_object_version_number                in     number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <Delete_Validation_a> >---------------------|
-- ----------------------------------------------------------------------------

Procedure Delete_Validation_a
  (p_validation_id                        in     number
  ,p_object_version_number                in     number);

end pqh_fr_validations_bk3;

 

/
