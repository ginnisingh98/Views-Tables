--------------------------------------------------------
--  DDL for Package PQH_DE_VLDLVL_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDLVL_BK1" AUTHID CURRENT_USER as
/* $Header: pqlvlapi.pkh 120.0 2005/05/29 02:12:14 appldev noship $ */

procedure Insert_Vldtn_Lvl_b
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_VER_ID           In  Number
  ,P_LEVEL_NUMBER_ID               In  Number
  ,P_LEVEL_CODE_ID                 In  Number);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_Vldtn_LVL_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Insert_Vldtn_Lvl_a
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_VER_ID           In  Number
  ,P_LEVEL_NUMBER_ID               In  Number
  ,P_Level_Code_Id                 In  Number
  ,P_WRKPLC_VLDTN_LVLNUM_ID        In  Number
  ,p_object_version_number         In  number);

 --
end PQH_DE_VLDLVL_BK1;

 

/
