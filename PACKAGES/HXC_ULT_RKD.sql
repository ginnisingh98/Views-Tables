--------------------------------------------------------
--  DDL for Package HXC_ULT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ULT_RKD" AUTHID CURRENT_USER as
/* $Header: hxcultrhi.pkh 120.0 2005/05/29 06:06:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_layout_id                    in number
  ,p_language                     in varchar2
  ,p_display_layout_name_o        in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end hxc_ult_rkd;

 

/
