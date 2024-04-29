--------------------------------------------------------
--  DDL for Package PAY_BAL_ATTRIBUTE_DEFAULT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BAL_ATTRIBUTE_DEFAULT_BK1" AUTHID CURRENT_USER as
/* $Header: pypbdapi.pkh 120.1 2005/10/02 02:32:32 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------< create_bal_attribute_default_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_bal_attribute_default_b
  (p_balance_category_id           in     number
  ,p_balance_dimension_id          in     number
  ,p_attribute_id                  in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_bal_attribute_default_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_bal_attribute_default_a
  (p_balance_category_id           in     number
  ,p_balance_dimension_id          in     number
  ,p_attribute_id                  in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_bal_attribute_default_id      in     number
  );
--
end PAY_BAL_ATTRIBUTE_DEFAULT_BK1;

 

/
