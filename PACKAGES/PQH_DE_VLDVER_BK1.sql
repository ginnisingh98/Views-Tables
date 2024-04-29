--------------------------------------------------------
--  DDL for Package PQH_DE_VLDVER_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDVER_BK1" AUTHID CURRENT_USER as
/* $Header: pqverapi.pkh 120.0 2005/05/29 02:53:13 appldev noship $ */
procedure Insert_Vldtn_Vern_b
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_ID               In  Number
  ,P_VERSION_NUMBER                In  Number
  ,P_REMUNERATION_JOB_DESCRIPTION  In  VarChar2
  ,P_TARIFF_CONTRACT_CODE          In  Varchar2
  ,P_TARIFF_GROUP_CODE             In  Varchar2
  ,P_JOB_GROUP_ID                  In  Number
  ,P_REMUNERATION_JOB_ID           In  Number
  ,P_DERIVED_GRADE_ID              In  Number
  ,P_DERIVED_CASE_GROUP_ID         In  Number
  ,P_DERIVED_SUBCASGRP_ID          In  Number
  ,P_USER_ENTERABLE_GRADE_ID       In  Number
  ,P_USER_ENTERABLE_CASE_GROUP_ID  In  Number
  ,P_USER_ENTERABLE_SUBCASGRP_ID   In  Number
  ,P_FREEZE                        In  Varchar2);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_Vldtn_Vern_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Insert_Vldtn_Vern_a
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,P_WRKPLC_VLDTN_ID               In  Number
  ,P_VERSION_NUMBER                In  Number
  ,P_REMUNERATION_JOB_DESCRIPTION  In  VarChar2
  ,P_TARIFF_CONTRACT_CODE          In  Varchar2
  ,P_TARIFF_GROUP_CODE             In  Varchar2
  ,P_JOB_GROUP_ID                  In  Number
  ,P_REMUNERATION_JOB_ID           In  Number
  ,P_DERIVED_GRADE_ID              In  Number
  ,P_DERIVED_CASE_GROUP_ID         In  Number
  ,P_DERIVED_SUBCASGRP_ID          In  Number
  ,P_USER_ENTERABLE_GRADE_ID       In  Number
  ,P_USER_ENTERABLE_CASE_GROUP_ID  In  Number
  ,P_USER_ENTERABLE_SUBCASGRP_ID   In  Number
  ,P_FREEZE                        In  Varchar2
  ,p_WRKPLC_VLDTN_VER_ID           In  Number
  ,p_object_version_number         in number);
 --
end PQH_DE_VLDVER_BK1;

 

/
