--------------------------------------------------------
--  DDL for Package PAY_OPT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_OPT_RKD" AUTHID CURRENT_USER as
/* $Header: pyoptrhi.pkh 120.0 2005/05/29 07:11:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_org_payment_method_id        in number
  ,p_language                     in varchar2
  ,p_org_payment_method_name_o    in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end pay_opt_rkd;

 

/
