--------------------------------------------------------
--  DDL for Package PQH_DE_INS_END_REASONS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_INS_END_REASONS_BK3" AUTHID CURRENT_USER as
/* $Header: pqpreapi.pkh 120.0 2005/05/29 02:17:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_PENSION_END_REASONS_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_PENSION_END_REASONS_b
  (p_ins_end_reason_id           In     Number
  ,p_object_version_number           In     number);

Procedure Delete_PENSION_END_REASONS_a
  (p_ins_end_reason_id           In     Number
  ,p_object_version_number           In     number);

end PQH_DE_iNs_END_REASONS_BK3;

 

/
