--------------------------------------------------------
--  DDL for Package PQH_FTR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FTR_RKD" AUTHID CURRENT_USER as
/* $Header: pqftrrhi.pkh 120.0 2005/05/29 01:54:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_wrkplc_vldtn_jobftr_id       in number
  ,p_wrkplc_vldtn_opr_job_id_o    in number
  ,p_job_feature_code_o           in varchar2
  ,p_wrkplc_vldtn_opr_job_type_o  in varchar2
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end pqh_ftr_rkd;

 

/
