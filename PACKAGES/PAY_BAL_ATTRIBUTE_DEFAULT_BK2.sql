--------------------------------------------------------
--  DDL for Package PAY_BAL_ATTRIBUTE_DEFAULT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BAL_ATTRIBUTE_DEFAULT_BK2" AUTHID CURRENT_USER as
/* $Header: pypbdapi.pkh 120.1 2005/10/02 02:32:32 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------< delete_bal_attribute_default_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bal_attribute_default_b
  (p_bal_attribute_default_id      in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< delete_bal_attribute_default_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_bal_attribute_default_a
  (p_bal_attribute_default_id      in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
end PAY_BAL_ATTRIBUTE_DEFAULT_BK2;

 

/
