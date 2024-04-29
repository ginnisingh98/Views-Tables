--------------------------------------------------------
--  DDL for Package PQH_DE_VLDOPR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDOPR_API" AUTHID CURRENT_USER as
/* $Header: pqopsapi.pkh 120.0 2005/05/29 02:15:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <PQH_DE_VLDOPR_API> >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This API Creates the the Validation Definition for the Workplace Validation Proess
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure Insert_Vldtn_Oprn
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_WRKPLC_VLDTN_VER_ID           In  Number
  ,P_WRKPLC_OPERATION_ID           In  Number
  ,P_DESCRIPTION                   In  Varchar2
  ,P_UNIT_PERCENTAGE               In  Number
  ,P_WRKPLC_VLDTN_OP_ID            out nocopy Number
  ,p_object_version_number         out nocopy number);


procedure Update_Vldtn_Oprn
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number   Default hr_api.g_Number
  ,P_WRKPLC_VLDTN_VER_ID           In  Number   Default hr_api.g_Number
  ,P_WRKPLC_OPERATION_ID           In  Number   Default hr_api.g_Number
  ,P_DESCRIPTION                   In  Varchar2 Default hr_api.g_Varchar2
  ,P_UNIT_PERCENTAGE               In  Number   Default hr_api.g_Number
  ,P_WRKPLC_VLDTN_OP_ID            In  Number
  ,p_object_version_number         In  out nocopy Number);

Procedure Delete_Vldtn_Oprn
  (p_validate                      in     boolean  default false
  ,p_WRKPLC_VLDTN_Op_Id            In     Number
  ,p_object_version_number         In     number);
--
end  PQH_DE_VLDOPR_API;

 

/
