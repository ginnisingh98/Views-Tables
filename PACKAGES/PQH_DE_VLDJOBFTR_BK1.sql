--------------------------------------------------------
--  DDL for Package PQH_DE_VLDJOBFTR_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDJOBFTR_BK1" AUTHID CURRENT_USER as
/* $Header: pqftrapi.pkh 120.0 2005/05/29 01:54:28 appldev noship $ */
procedure Insert_Vldtn_Jobftr_b
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_OPR_JOB_ID       In  Number
  ,P_Job_Feature_Code              In  Varchar2
  ,P_Wrkplc_Vldtn_Opr_job_Type     In  Varchar2);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_Vldtn_JobFtr_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Insert_Vldtn_JobFtr_a
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_OPR_JOB_ID       In  Number
  ,P_JOB_FEATURE_CODE              In  Varchar2
  ,P_Wrkplc_Vldtn_Opr_job_Type     In  Varchar2
  ,P_WRKPLC_VLDTN_JOBFTR_ID        In  Number
  ,p_object_version_number         In  number);

 --
end PQH_DE_VLDJOBFTR_BK1;

 

/
