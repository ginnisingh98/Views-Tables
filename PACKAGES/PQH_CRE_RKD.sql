--------------------------------------------------------
--  DDL for Package PQH_CRE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRE_RKD" AUTHID CURRENT_USER as
/* $Header: pqcrerhi.pkh 120.0 2005/10/06 14:52 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_criteria_rate_element_id     in number
  ,p_criteria_rate_defn_id_o      in number
  ,p_element_type_id_o            in number
  ,p_input_value_id_o             in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_cre_rkd;

 

/
