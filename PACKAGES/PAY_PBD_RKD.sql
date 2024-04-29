--------------------------------------------------------
--  DDL for Package PAY_PBD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PBD_RKD" AUTHID CURRENT_USER as
/* $Header: pypbdrhi.pkh 120.0 2005/05/29 07:21:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_bal_attribute_default_id     in number
  ,p_attribute_id_o               in number
  ,p_balance_dimension_id_o       in number
  ,p_balance_category_id_o        in number
  ,p_legislation_code_o           in varchar2
  ,p_business_group_id_o          in number
  );
--
end pay_pbd_rkd;

 

/
