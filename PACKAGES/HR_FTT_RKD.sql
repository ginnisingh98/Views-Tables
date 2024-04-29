--------------------------------------------------------
--  DDL for Package HR_FTT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FTT_RKD" AUTHID CURRENT_USER as
/* $Header: hrfttrhi.pkh 120.0 2005/05/31 00:31:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_form_tab_page_id             in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_tab_page_name_o         in varchar2
  ,p_description_o                in varchar2
  );
--
end hr_ftt_rkd;

 

/
