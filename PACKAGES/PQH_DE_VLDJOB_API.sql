--------------------------------------------------------
--  DDL for Package PQH_DE_VLDJOB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDJOB_API" AUTHID CURRENT_USER as
/* $Header: pqwvjapi.pkh 120.0 2005/05/29 03:04:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <PQH_DE_VLDJOB_API> >--------------------------|
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
procedure Insert_Vldtn_JOb
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_WRKPLC_VLDTN_OP_ID            In  Number
  ,P_WRKPLC_JOB_ID                 In  Number
  ,P_DESCRIPTION                   In  Varchar2
  ,P_WRKPLC_VLDTN_JOb_ID           out nocopy Number
  ,p_object_version_number         out nocopy number);

procedure Update_Vldtn_JOb
  (p_validate                      in  boolean   default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number    Default hr_api.g_Number
  ,P_WRKPLC_VLDTN_OP_ID            In  Number    Default hr_api.g_Number
  ,P_WRKPLC_JOB_ID                 In  Number    Default hr_api.g_Number
  ,P_DESCRIPTION                   In  Varchar2  Default hr_api.g_Varchar2
  ,P_WRKPLC_VLDTN_Job_ID           In  Number
  ,p_object_version_number         In  out nocopy number);

Procedure Delete_Vldtn_Job
  (p_validate                      in     boolean  default false
  ,p_WRKPLC_VLDTN_Job_Id           In     Number
  ,p_object_version_number         In     number);
--
end  PQH_DE_VLDJOB_API;

 

/
