--------------------------------------------------------
--  DDL for Package PQH_DE_VLDOPR_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDOPR_BK3" AUTHID CURRENT_USER as
/* $Header: pqopsapi.pkh 120.0 2005/05/29 02:15:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Vldtn_Oprn_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Vldtn_Oprn_b
  (p_WRKPLC_VLDTN_OP_ID            In     Number
  ,p_object_version_number         In     number);

Procedure Delete_Vldtn_Oprn_a
  (p_WRKPLC_VLDTN_OP_ID            In     Number
  ,p_object_version_number         In     number);

end PQH_DE_VLDOPR_BK3;

 

/
