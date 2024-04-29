--------------------------------------------------------
--  DDL for Package PQH_DE_VLDLVL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDLVL_BK2" AUTHID CURRENT_USER as
/* $Header: pqlvlapi.pkh 120.0 2005/05/29 02:12:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <Update_Vldtn_Lvl_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_Vldtn_Lvl_b
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_WRKPLC_VLDTN_VER_ID           In  Number
  ,p_Level_Number_id               In  Number
  ,P_Level_Code_Id                 In  Number
  ,P_WRKPLC_VLDTN_LVLNUM_ID        In  Number
  ,p_object_version_number         In  number);

procedure Update_Vldtn_Lvl_a
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_VER_ID           In  Number
  ,P_Level_Number_Id               In  Number
  ,P_Level_Code_ID                 In  Number
  ,P_WRKPLC_VLDTN_LVLNUM_ID        In  Number
  ,p_object_version_number         In number);

end PQH_DE_VLDLVL_BK2;

 

/
