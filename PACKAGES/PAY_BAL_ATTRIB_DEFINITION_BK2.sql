--------------------------------------------------------
--  DDL for Package PAY_BAL_ATTRIB_DEFINITION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BAL_ATTRIB_DEFINITION_BK2" AUTHID CURRENT_USER as
/* $Header: pyatdapi.pkh 120.1 2005/10/02 02:29:17 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_bal_attrib_definition_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bal_attrib_definition_b
  (p_attribute_id                  in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_bal_attrib_definition_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bal_attrib_definition_a
  (p_attribute_id                  in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
end PAY_BAL_ATTRIB_DEFINITION_BK2;

 

/
