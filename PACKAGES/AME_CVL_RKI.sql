--------------------------------------------------------
--  DDL for Package AME_CVL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CVL_RKI" AUTHID CURRENT_USER as
/* $Header: amcvlrhi.pkh 120.0 2005/09/02 03:56 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_variable_name                in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_config_var_name         in varchar2
  ,p_description                  in varchar2
  );
end ame_cvl_rki;

 

/
