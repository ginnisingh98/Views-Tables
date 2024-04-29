--------------------------------------------------------
--  DDL for Package HXC_VTL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_VTL_RKD" AUTHID CURRENT_USER as
/* $Header: hxcvtlrhi.pkh 120.0 2005/05/29 06:07:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_alias_value_id               in number
  ,p_language                     in varchar2
  ,p_alias_value_name_o           in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end hxc_vtl_rkd;

 

/
