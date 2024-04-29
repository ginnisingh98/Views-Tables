--------------------------------------------------------
--  DDL for Package AME_RTL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_RTL_RKD" AUTHID CURRENT_USER as
/* $Header: amrtlrhi.pkh 120.0 2005/09/02 04:02 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_rule_id                      in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_description_o                in varchar2
  );
--
end ame_rtl_rkd;

 

/
