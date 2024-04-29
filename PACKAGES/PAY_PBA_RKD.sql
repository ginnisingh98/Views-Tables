--------------------------------------------------------
--  DDL for Package PAY_PBA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PBA_RKD" AUTHID CURRENT_USER as
/* $Header: pypbarhi.pkh 120.0 2005/05/29 07:18:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_balance_attribute_id         in number
  ,p_attribute_id_o               in number
  ,p_defined_balance_id_o         in number
  ,p_legislation_code_o           in varchar2
  ,p_business_group_id_o          in number
  );
--
end pay_pba_rkd;

 

/
