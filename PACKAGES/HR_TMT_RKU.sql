--------------------------------------------------------
--  DDL for Package HR_TMT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TMT_RKU" AUTHID CURRENT_USER as
/* $Header: hrtmtrhi.pkh 120.0 2005/05/31 03:22:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_form_template_id             in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_template_name           in varchar2
  ,p_description                  in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_template_name_o         in varchar2
  ,p_description_o                in varchar2
  );
--
end hr_tmt_rku;

 

/
