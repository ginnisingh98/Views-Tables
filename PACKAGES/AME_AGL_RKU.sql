--------------------------------------------------------
--  DDL for Package AME_AGL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_AGL_RKU" AUTHID CURRENT_USER as
/* $Header: amaglrhi.pkh 120.0 2005/09/02 03:49 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_approval_group_id            in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_approval_group_name     in varchar2
  ,p_description                  in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_approval_group_name_o   in varchar2
  ,p_description_o                in varchar2
  );
--
end ame_agl_rku;

 

/
