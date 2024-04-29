--------------------------------------------------------
--  DDL for Package PQH_DE_VLDJOB_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDJOB_BK1" AUTHID CURRENT_USER as
/* $Header: pqwvjapi.pkh 120.0 2005/05/29 03:04:38 appldev noship $ */
procedure Insert_Vldtn_Job_b
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_OP_ID            In  Number
  ,P_WRKPLC_JOB_ID                 In  Number
  ,P_DESCRIPTION                   In  Varchar2);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_Vldtn_Job_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Insert_Vldtn_Job_a
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_OP_ID            In  Number
  ,P_WRKPLC_JOB_ID                 In  Number
  ,P_DESCRIPTION                   In  Varchar2
  ,P_WRKPLC_VLDTN_JOB_ID           In  Number
  ,p_object_version_number         In  number);

 --
end PQH_DE_VLDJOB_BK1;

 

/
