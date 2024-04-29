--------------------------------------------------------
--  DDL for Package PAY_PBD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PBD_RKI" AUTHID CURRENT_USER as
/* $Header: pypbdrhi.pkh 120.0 2005/05/29 07:21:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_bal_attribute_default_id     in number
  ,p_attribute_id                 in number
  ,p_balance_dimension_id         in number
  ,p_balance_category_id          in number
  ,p_legislation_code             in varchar2
  ,p_business_group_id            in number
  );
end pay_pbd_rki;

 

/
