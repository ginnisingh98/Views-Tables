--------------------------------------------------------
--  DDL for Package PAY_BALANCE_ATTRIBUTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_ATTRIBUTE_BK1" AUTHID CURRENT_USER as
/* $Header: pypbaapi.pkh 120.1 2005/10/02 02:32:22 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |----------------< create_balance_attribute_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_attribute_b
  (p_attribute_id                  in     varchar2
  ,p_defined_balance_id            in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< create_balance_attribute_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_attribute_a
  (p_attribute_id                  in     number
  ,p_defined_balance_id            in     number
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_balance_attribute_id          in     number
  );
--
end PAY_BALANCE_ATTRIBUTE_BK1;

 

/
