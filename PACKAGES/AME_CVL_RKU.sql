--------------------------------------------------------
--  DDL for Package AME_CVL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CVL_RKU" AUTHID CURRENT_USER as
/* $Header: amcvlrhi.pkh 120.0 2005/09/02 03:56 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_variable_name                in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_config_var_name         in varchar2
  ,p_description                  in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_config_var_name_o       in varchar2
  ,p_description_o                in varchar2
  );
--
end ame_cvl_rku;

 

/
