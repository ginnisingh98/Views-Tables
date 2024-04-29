--------------------------------------------------------
--  DDL for Package HXC_DTL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DTL_RKD" AUTHID CURRENT_USER as
/* $Header: hxcdtlrhi.pkh 120.1 2006/08/28 10:58:02 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_alias_definition_id          in number
  ,p_language                     in varchar2
  ,p_alias_definition_name_o      in varchar2
  ,p_description_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end hxc_dtl_rkd;

 

/
