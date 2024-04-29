--------------------------------------------------------
--  DDL for Package PQH_DE_VLDDEF_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDDEF_BK3" AUTHID CURRENT_USER as
/* $Header: pqdefapi.pkh 120.0 2005/05/29 01:46:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Vldtn_Defn_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Vldtn_Defn_b
  (p_WRKPLC_VLDTN_ID               In     Number
  ,p_object_version_number         In     number);

Procedure Delete_Vldtn_Defn_a
  (p_WRKPLC_VLDTN_ID               In     Number
  ,p_object_version_number         In     number);

end PQH_DE_VLDDEF_BK3;

 

/
