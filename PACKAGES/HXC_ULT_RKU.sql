--------------------------------------------------------
--  DDL for Package HXC_ULT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ULT_RKU" AUTHID CURRENT_USER as
/* $Header: hxcultrhi.pkh 120.0 2005/05/29 06:06:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_layout_id                    in number
  ,p_display_layout_name          in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_display_layout_name_o        in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end hxc_ult_rku;

 

/
