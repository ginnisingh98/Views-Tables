--------------------------------------------------------
--  DDL for Package PQH_DE_VLDJOBFTR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDJOBFTR_API" AUTHID CURRENT_USER as
/* $Header: pqftrapi.pkh 120.0 2005/05/29 01:54:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <PQH_DE_VLDJOBFTRS_API> >---------------------|
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
procedure Insert_Vldtn_JObftr
  (p_validate                      in  boolean  default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_WRKPLC_VLDTN_OPR_JOB_ID       In  Number
  ,P_JOB_FEATURE_CODE              In  Varchar2
  ,P_Wrkplc_Vldtn_Opr_job_Type     In  Varchar2
  ,P_WRKPLC_VLDTN_JObFTR_ID        out nocopy Number
  ,p_object_version_number         out nocopy number);

procedure Update_Vldtn_JObFtr
  (p_validate                      in  boolean   default false
  ,p_effective_date                in  date
  ,p_business_group_id             in  number    Default hr_api.g_Number
  ,P_WRKPLC_VLDTN_OPR_JOB_ID       In  Number    Default hr_api.g_Number
  ,P_JOB_FEATURE_CODE              In  Varchar2  Default hr_api.g_Varchar2
  ,P_Wrkplc_Vldtn_Opr_job_Type     In  Varchar2  Default hr_api.g_Varchar2
  ,P_WRKPLC_VLDTN_Jobftr_ID        In  Number
  ,p_object_version_number         In  out nocopy number);

Procedure Delete_Vldtn_JobFtr
  (p_validate                      in     boolean  default false
  ,p_WRKPLC_VLDTN_JobFtr_Id        In     Number
  ,p_object_version_number         In     number);
--
end  PQH_DE_VLDJOBFTR_API;

 

/
