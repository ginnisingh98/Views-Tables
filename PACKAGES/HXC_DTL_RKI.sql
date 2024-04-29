--------------------------------------------------------
--  DDL for Package HXC_DTL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DTL_RKI" AUTHID CURRENT_USER as
/* $Header: hxcdtlrhi.pkh 120.1 2006/08/28 10:58:02 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_alias_definition_id          in number
  ,p_alias_definition_name        in varchar2
  ,p_description                  in varchar2
  ,p_prompt                       in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end hxc_dtl_rki;

 

/
