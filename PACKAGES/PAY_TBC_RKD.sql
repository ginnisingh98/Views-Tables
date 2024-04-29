--------------------------------------------------------
--  DDL for Package PAY_TBC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TBC_RKD" AUTHID CURRENT_USER as
/* $Header: pytbcrhi.pkh 120.0 2005/05/29 09:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_balance_category_id          in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_category_name_o         in varchar2
  );
--
end pay_tbc_rkd;

 

/
