--------------------------------------------------------
--  DDL for Package PAY_OPT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_OPT_RKI" AUTHID CURRENT_USER as
/* $Header: pyoptrhi.pkh 120.0 2005/05/29 07:11:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_org_payment_method_id        in number
  ,p_org_payment_method_name      in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end pay_opt_rki;

 

/
