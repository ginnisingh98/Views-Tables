--------------------------------------------------------
--  DDL for Package PAY_TBC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TBC_RKI" AUTHID CURRENT_USER as
/* $Header: pytbcrhi.pkh 120.0 2005/05/29 09:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_balance_category_id          in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_category_name           in varchar2
  );
end pay_tbc_rki;

 

/
