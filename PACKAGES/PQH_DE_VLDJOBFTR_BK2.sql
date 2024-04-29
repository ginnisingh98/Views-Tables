--------------------------------------------------------
--  DDL for Package PQH_DE_VLDJOBFTR_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDJOBFTR_BK2" AUTHID CURRENT_USER as
/* $Header: pqftrapi.pkh 120.0 2005/05/29 01:54:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <Update_Vldtn_JObftr_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_Vldtn_JObFTR_b
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_WRKPLC_VLDTN_OPR_JOB_ID       In  Number
  ,p_JOB_FEATURE_CODE              In  Varchar2
  ,P_Wrkplc_Vldtn_Opr_job_Type     In  Varchar2
  ,P_WRKPLC_VLDTN_JOBFTR_ID        In  Number
  ,p_object_version_number         IN  number);

procedure Update_Vldtn_JobFTR_a
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_OPR_JOB_ID       In  Number
  ,P_JOB_FEATURE_CODE              In  Varchar2
  ,P_Wrkplc_Vldtn_Opr_job_Type     In  Varchar2
  ,P_WRKPLC_VLDTN_JOBFTR_ID        In  Number
  ,p_object_version_number         IN number);

end PQH_DE_VLDJOBFTR_BK2;

 

/
