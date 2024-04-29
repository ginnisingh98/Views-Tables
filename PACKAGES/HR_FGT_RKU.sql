--------------------------------------------------------
--  DDL for Package HR_FGT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FGT_RKU" AUTHID CURRENT_USER as
/* $Header: hrfgtrhi.pkh 120.0 2005/05/31 00:19:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_form_data_group_id           in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_data_group_name         in varchar2
  ,p_description                  in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_data_group_name_o       in varchar2
  ,p_description_o                in varchar2
  );
--
end hr_fgt_rku;

 

/
