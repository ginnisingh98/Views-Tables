--------------------------------------------------------
--  DDL for Package PQH_RFE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RFE_RKD" AUTHID CURRENT_USER as
/* $Header: pqrferhi.pkh 120.0 2005/10/06 14:54 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_rate_factor_on_elmnt_id      in number
  ,p_criteria_rate_element_id_o   in number
  ,p_criteria_rate_factor_id_o    in number
  ,p_rate_factor_val_record_tbl_o in varchar2
  ,p_rate_factor_val_record_col_o in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_rfe_rkd;

 

/
