--------------------------------------------------------
--  DDL for Package PAY_PBA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PBA_RKI" AUTHID CURRENT_USER as
/* $Header: pypbarhi.pkh 120.0 2005/05/29 07:18:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_balance_attribute_id         in number
  ,p_attribute_id                 in number
  ,p_defined_balance_id           in number
  ,p_legislation_code             in varchar2
  ,p_business_group_id            in number
  );
end pay_pba_rki;

 

/
