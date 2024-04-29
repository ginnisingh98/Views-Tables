--------------------------------------------------------
--  DDL for Package PQH_DE_VLDLVL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDLVL_BK3" AUTHID CURRENT_USER as
/* $Header: pqlvlapi.pkh 120.0 2005/05/29 02:12:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Vldtn_Lvl_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Vldtn_Lvl_b
  (p_WRKPLC_VLDTN_LvlNum_ID         In     Number
  ,p_object_version_number          In     number);

Procedure Delete_Vldtn_Lvl_a
  (p_WRKPLC_VLDTN_LvlNum_ID         In     Number
  ,p_object_version_number          In     number);

end PQH_DE_VLDLVL_BK3;

 

/
