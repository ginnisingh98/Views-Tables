--------------------------------------------------------
--  DDL for Package HR_IPT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IPT_RKD" AUTHID CURRENT_USER as
/* $Header: hriptrhi.pkh 120.0 2005/05/31 00:54:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_item_property_id             in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_default_value_o              in varchar2
  ,p_information_prompt_o         in varchar2
  ,p_label_o                      in varchar2
  ,p_prompt_text_o                in varchar2
  ,p_tooltip_text_o               in varchar2
  );
--
end hr_ipt_rkd;

 

/
