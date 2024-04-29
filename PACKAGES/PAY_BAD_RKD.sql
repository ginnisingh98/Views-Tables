--------------------------------------------------------
--  DDL for Package PAY_BAD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BAD_RKD" AUTHID CURRENT_USER as
/* $Header: pybadrhi.pkh 120.0 2005/05/29 03:14:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_attribute_id                 in number
  ,p_attribute_name_o             in varchar2
  ,p_alterable_o                  in varchar2
  ,p_legislation_code_o           in varchar2
  ,p_business_group_id_o          in number
  ,p_user_attribute_name_o        in varchar2
  );
--
end pay_bad_rkd;

 

/
