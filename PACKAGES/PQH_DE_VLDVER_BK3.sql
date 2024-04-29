--------------------------------------------------------
--  DDL for Package PQH_DE_VLDVER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDVER_BK3" AUTHID CURRENT_USER as
/* $Header: pqverapi.pkh 120.0 2005/05/29 02:53:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Vldtn_vern_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Vldtn_Vern_b
  (p_WRKPLC_VLDTN_VERID            In     Number
  ,p_object_version_number         In     number);

Procedure Delete_Vldtn_Vern_a
  (p_WRKPLC_VLDTN_VER_ID           In     Number
  ,p_object_version_number         In     number);

end PQH_DE_VLDVER_BK3;

 

/
