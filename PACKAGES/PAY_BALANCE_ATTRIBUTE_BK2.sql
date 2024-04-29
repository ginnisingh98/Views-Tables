--------------------------------------------------------
--  DDL for Package PAY_BALANCE_ATTRIBUTE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_ATTRIBUTE_BK2" AUTHID CURRENT_USER as
/* $Header: pypbaapi.pkh 120.1 2005/10/02 02:32:22 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------< delete_balance_attribute_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_attribute_b
  (p_balance_attribute_id          in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< delete_balance_attribute_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_attribute_a
  (p_balance_attribute_id          in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
end PAY_BALANCE_ATTRIBUTE_BK2;

 

/
