--------------------------------------------------------
--  DDL for Package PAY_BTT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BTT_RKU" AUTHID CURRENT_USER as
/* $Header: pybttrhi.pkh 120.0 2005/05/29 03:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_balance_type_id              in number
  ,p_balance_name                 in varchar2
  ,p_reporting_name               in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_balance_name_o               in varchar2
  ,p_reporting_name_o             in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end pay_btt_rku;

 

/
