--------------------------------------------------------
--  DDL for Package PQH_RER_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RER_RKU" AUTHID CURRENT_USER as
/* $Header: pqrerrhi.pkh 120.0 2005/10/06 14:53 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_rate_element_relation_id     in number
  ,p_criteria_rate_element_id     in number
  ,p_relation_type_cd             in varchar2
  ,p_rel_element_type_id          in number
  ,p_rel_input_value_id           in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  ,p_criteria_rate_element_id_o   in number
  ,p_relation_type_cd_o           in varchar2
  ,p_rel_element_type_id_o        in number
  ,p_rel_input_value_id_o         in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_rer_rku;

 

/
