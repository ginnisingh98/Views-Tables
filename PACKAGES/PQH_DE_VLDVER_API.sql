--------------------------------------------------------
--  DDL for Package PQH_DE_VLDVER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDVER_API" AUTHID CURRENT_USER as
/* $Header: pqverapi.pkh 120.0 2005/05/29 02:53:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <PQH_DE_VLDVER_API> >--------------------------|
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
procedure Insert_Vldtn_Vern
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_WRKPLC_VLDTN_ID               In  Number
  ,P_VERSION_NUMBER                In  Number   Default NULL
  ,P_REMUNERATION_JOB_DESCRIPTION  In  VarChar2 Default NULL
  ,P_TARIFF_CONTRACT_CODE          In  Varchar2
  ,P_TARIFF_GROUP_CODE             In  Varchar2
  ,P_JOB_GROUP_ID                  In  Number   Default NULL
  ,P_REMUNERATION_JOB_ID           In  Number   Default NULL
  ,P_DERIVED_GRADE_ID              In  Number   Default NULL
  ,P_DERIVED_CASE_GROUP_ID         In  Number   Default NULL
  ,P_DERIVED_SUBCASGRP_ID          In  Number   Default NULL
  ,P_USER_ENTERABLE_GRADE_ID       In  Number   Default NULL
  ,P_USER_ENTERABLE_CASE_GROUP_ID  In  Number   Default NULL
  ,P_USER_ENTERABLE_SUBCASGRP_ID   In  Number   Default NULL
  ,P_FREEZE                        In  Varchar2 Default NULL
  ,p_WRKPLC_VLDTN_VER_ID           out nocopy Number
  ,p_object_version_number         out nocopy number);


procedure Update_Vldtn_Vern
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_WRKPLC_VLDTN_ID               In  Number   Default hr_api.g_Number
  ,P_VERSION_NUMBER                In  Number   Default hr_api.g_Number
  ,P_REMUNERATION_JOB_DESCRIPTION  In  VarChar2 Default hr_api.g_Varchar2
  ,P_TARIFF_CONTRACT_CODE          In  Varchar2 Default hr_api.g_Varchar2
  ,P_TARIFF_GROUP_CODE             In  Varchar2 Default hr_api.g_Varchar2
  ,P_JOB_GROUP_ID                  In  Number   Default hr_api.g_Number
  ,P_REMUNERATION_JOB_ID           In  Number   Default hr_api.g_Number
  ,P_DERIVED_GRADE_ID              In  Number   Default hr_api.g_Number
  ,P_DERIVED_CASE_GROUP_ID         In  Number   Default hr_api.g_Number
  ,P_DERIVED_SUBCASGRP_ID          In  Number   Default hr_api.g_Number
  ,P_USER_ENTERABLE_GRADE_ID       In  Number   Default hr_api.g_Number
  ,P_USER_ENTERABLE_CASE_GROUP_ID  In  Number   Default hr_api.g_Number
  ,P_USER_ENTERABLE_SUBCASGRP_ID   In  Number   Default hr_api.g_Number
  ,P_FREEZE                        In  Varchar2 Default hr_api.g_Varchar2
  ,p_WRKPLC_VLDTN_VER_ID           In  Number
  ,p_object_version_number         in  out nocopy number);

Procedure Delete_Vldtn_Vern
  (p_validate                      in     boolean  default false
  ,p_WRKPLC_VLDTN_VER_ID           In     Number
  ,p_object_version_number         In     number);
--
end  PQH_DE_VLDVER_API;

 

/
