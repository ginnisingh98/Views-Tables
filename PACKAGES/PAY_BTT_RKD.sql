--------------------------------------------------------
--  DDL for Package PAY_BTT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BTT_RKD" AUTHID CURRENT_USER as
/* $Header: pybttrhi.pkh 120.0 2005/05/29 03:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_balance_type_id              in number
  ,p_language                     in varchar2
  ,p_balance_name_o               in varchar2
  ,p_reporting_name_o             in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end pay_btt_rkd;

 

/
