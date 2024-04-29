--------------------------------------------------------
--  DDL for Package PQH_CRF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRF_RKD" AUTHID CURRENT_USER as
/* $Header: pqcrfrhi.pkh 120.0 2005/10/06 14:52 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_criteria_rate_factor_id      in number
  ,p_criteria_rate_defn_id_o      in number
  ,p_parent_rate_matrix_id_o      in number
  ,p_parent_criteria_rate_defn__o in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_crf_rkd;

 

/
