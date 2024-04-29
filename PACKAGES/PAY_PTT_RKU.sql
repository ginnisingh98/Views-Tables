--------------------------------------------------------
--  DDL for Package PAY_PTT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PTT_RKU" AUTHID CURRENT_USER as
/* $Header: pypttrhi.pkh 120.0 2005/05/29 07:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_user_table_id                in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_table_name              in varchar2
  ,p_user_row_title               in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_table_name_o            in varchar2
  ,p_user_row_title_o             in varchar2
  );
--
end pay_ptt_rku;

 

/
