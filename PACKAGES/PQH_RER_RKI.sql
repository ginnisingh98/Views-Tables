--------------------------------------------------------
--  DDL for Package PQH_RER_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RER_RKI" AUTHID CURRENT_USER as
/* $Header: pqrerrhi.pkh 120.0 2005/10/06 14:53 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_rate_element_relation_id     in number
  ,p_criteria_rate_element_id     in number
  ,p_relation_type_cd             in varchar2
  ,p_rel_element_type_id          in number
  ,p_rel_input_value_id           in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  );
end pqh_rer_rki;

 

/
