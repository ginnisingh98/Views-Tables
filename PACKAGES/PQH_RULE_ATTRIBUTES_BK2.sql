--------------------------------------------------------
--  DDL for Package PQH_RULE_ATTRIBUTES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RULE_ATTRIBUTES_BK2" AUTHID CURRENT_USER as
/* $Header: pqrlaapi.pkh 120.1 2005/10/02 02:27:26 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< <Update_Rule_Attribute_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure Update_Rule_Attribute_b
  (p_rule_attribute_id            in     number
  ,p_object_version_number        in     number
  ,p_rule_set_id                  in     number
  ,p_attribute_code               in     varchar2
  ,p_operation_code               in     varchar2
  ,p_attribute_value              in     varchar2
);

--
-- ----------------------------------------------------------------------------
-- |--------------------------< <Update_Rule_Attribute_a> >---------------------|
-- ----------------------------------------------------------------------------
procedure Update_Rule_Attribute_a
  (p_rule_attribute_id            in     number
  ,p_object_version_number        in     number
  ,p_rule_set_id                  in     number
  ,p_attribute_code               in     varchar2
  ,p_operation_code               in     varchar2
  ,p_attribute_value              in     varchar2
);

end pqh_rule_attributes_bk2;

 

/
