--------------------------------------------------------
--  DDL for Package PQH_FTR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FTR_RKI" AUTHID CURRENT_USER as
/* $Header: pqftrrhi.pkh 120.0 2005/05/29 01:54:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_wrkplc_vldtn_jobftr_id       in number
  ,p_wrkplc_vldtn_opr_job_id      in number
  ,p_job_feature_code             in varchar2
  ,p_wrkplc_vldtn_opr_job_type    in varchar2
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  );
end pqh_ftr_rki;

 

/
