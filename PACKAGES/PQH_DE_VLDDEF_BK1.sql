--------------------------------------------------------
--  DDL for Package PQH_DE_VLDDEF_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_VLDDEF_BK1" AUTHID CURRENT_USER as
/* $Header: pqdefapi.pkh 120.0 2005/05/29 01:46:34 appldev noship $ */
procedure Insert_Vldtn_Defn_b
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_VALIDATION_NAME               In  Varchar2
  ,p_EMPLOYMENT_TYPE               In  Varchar2
  ,p_REMUNERATION_REGULATION       In  Varchar2);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_Vldtn_Defn_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Insert_Vldtn_Defn_a
  (p_effective_date                in  date
  ,p_business_group_id             in  number
  ,p_VALIDATION_NAME               In  Varchar2
  ,p_EMPLOYMENT_TYPE               In  Varchar2
  ,p_REMUNERATION_REGULATION       In  Varchar2
  ,p_WRKPLC_VLDTN_ID               in  number
  ,p_object_version_number         in  number);


--
end PQH_DE_VLDDEF_BK1;

 

/
