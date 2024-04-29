--------------------------------------------------------
--  DDL for Package PAY_BAL_ATTRIB_DEFINITION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BAL_ATTRIB_DEFINITION_BK1" AUTHID CURRENT_USER as
/* $Header: pyatdapi.pkh 120.1 2005/10/02 02:29:17 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_bal_attrib_definition_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_bal_attrib_definition_b
  (p_effective_date                in     date
  ,p_attribute_name                in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_user_attribute_name           in     varchar2
  ,p_alterable                     in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_bal_attrib_definition_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_bal_attrib_definition_a
  (p_effective_date                in     date
  ,p_attribute_name                in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_alterable                     in     varchar2
  ,p_user_attribute_name           in     varchar2
  ,p_attribute_id                  in     number
  );
--
end PAY_BAL_ATTRIB_DEFINITION_BK1;

 

/
