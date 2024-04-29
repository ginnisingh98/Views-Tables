--------------------------------------------------------
--  DDL for Package PQH_RULE_ATTRIBUTES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RULE_ATTRIBUTES_BK3" AUTHID CURRENT_USER as
/* $Header: pqrlaapi.pkh 120.1 2005/10/02 02:27:26 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Delete_Rule_Attribute_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Delete_Rule_Attribute_b
  (p_rule_attribute_id                    in     number
  ,p_object_version_number                in     number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <Delete_Rule_Attribute_a> >---------------------|
-- ----------------------------------------------------------------------------

Procedure Delete_Rule_Attribute_a
  (p_rule_attribute_id                    in     number
  ,p_object_version_number                in     number);

end pqh_rule_attributes_bk3;

 

/
