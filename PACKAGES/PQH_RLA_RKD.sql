--------------------------------------------------------
--  DDL for Package PQH_RLA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RLA_RKD" AUTHID CURRENT_USER as
/* $Header: pqrlarhi.pkh 120.0 2005/05/29 02:30:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_rule_attribute_id            in number
  ,p_rule_set_id_o                in number
  ,p_attribute_code_o             in varchar2
  ,p_operation_code_o             in varchar2
  ,p_attribute_value_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_rla_rkd;

 

/
