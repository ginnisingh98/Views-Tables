--------------------------------------------------------
--  DDL for Package PAY_BTT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BTT_RKI" AUTHID CURRENT_USER as
/* $Header: pybttrhi.pkh 120.0 2005/05/29 03:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_balance_type_id              in number
  ,p_balance_name                 in varchar2
  ,p_reporting_name               in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end pay_btt_rki;

 

/
