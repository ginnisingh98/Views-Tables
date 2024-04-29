--------------------------------------------------------
--  DDL for Package PQH_CRE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRE_RKI" AUTHID CURRENT_USER as
/* $Header: pqcrerhi.pkh 120.0 2005/10/06 14:52 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_criteria_rate_element_id     in number
  ,p_criteria_rate_defn_id        in number
  ,p_element_type_id              in number
  ,p_input_value_id               in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_object_version_number        in number
  );
end pqh_cre_rki;

 

/
