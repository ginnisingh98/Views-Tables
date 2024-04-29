--------------------------------------------------------
--  DDL for Package PQH_RER_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RER_RKD" AUTHID CURRENT_USER as
/* $Header: pqrerrhi.pkh 120.0 2005/10/06 14:53 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_rate_element_relation_id     in number
  ,p_criteria_rate_element_id_o   in number
  ,p_relation_type_cd_o           in varchar2
  ,p_rel_element_type_id_o        in number
  ,p_rel_input_value_id_o         in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_rer_rkd;

 

/
