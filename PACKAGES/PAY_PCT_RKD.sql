--------------------------------------------------------
--  DDL for Package PAY_PCT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PCT_RKD" AUTHID CURRENT_USER as
/* $Header: pypctrhi.pkh 120.0 2005/05/29 07:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_user_column_id               in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_column_name_o           in varchar2
  );
--
end pay_pct_rkd;

 

/
