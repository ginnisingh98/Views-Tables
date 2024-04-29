--------------------------------------------------------
--  DDL for Package PQH_RTL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RTL_RKU" AUTHID CURRENT_USER as
/* $Header: pqrtlrhi.pkh 120.0 2005/05/29 02:39:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_rule_set_id                    in number
 ,p_rule_set_name                  in varchar2
 ,p_description		 	   in varchar2
 ,p_language                       in varchar2
 ,p_source_lang                    in varchar2
 ,p_rule_set_name_o                in varchar2
 ,p_description_o		   in varchar2
 ,p_language_o                     in varchar2
 ,p_source_lang_o                  in varchar2
  );
--
end pqh_rtl_rku;

 

/
