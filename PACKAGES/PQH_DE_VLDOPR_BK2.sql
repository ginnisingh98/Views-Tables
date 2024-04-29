--------------------------------------------------------
--  DDL for Package PQH_DE_VLDOPR_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDOPR_BK2" AUTHID CURRENT_USER as
/* $Header: pqopsapi.pkh 120.0 2005/05/29 02:15:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <Update_Vldtn_OPrn_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_Vldtn_Oprn_b
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_WRKPLC_VLDTN_VER_ID           In  Number
  ,p_WRKPLC_OPERATION_ID           In  Number
  ,p_DESCRIPTION                   In  Varchar2
  ,P_UNIT_PERCENTAGE               In  Number
  ,P_WRKPLC_VLDTN_OP_ID            In  Number
  ,p_object_version_number         In  number);

procedure Update_Vldtn_Oprn_a
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_VER_ID           In  Number
  ,P_WRKPLC_OPERATION_ID           In  Number
  ,P_DESCRIPTION                   In  Varchar2
  ,P_UNIT_PERCENTAGE               In  Number
  ,P_WRKPLC_VLDTN_OP_ID            In  Number
  ,p_object_version_number         IN number);

end PQH_DE_VLDOPR_BK2;

 

/
