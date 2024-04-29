--------------------------------------------------------
--  DDL for Package HR_IPT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IPT_RKI" AUTHID CURRENT_USER as
/* $Header: hriptrhi.pkh 120.0 2005/05/31 00:54:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_item_property_id             in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_default_value                in varchar2
  ,p_information_prompt           in varchar2
  ,p_label                        in varchar2
  ,p_prompt_text                  in varchar2
  ,p_tooltip_text                 in varchar2
  );
end hr_ipt_rki;

 

/
