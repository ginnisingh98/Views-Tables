--------------------------------------------------------
--  DDL for Package AME_AGL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_AGL_RKI" AUTHID CURRENT_USER as
/* $Header: amaglrhi.pkh 120.0 2005/09/02 03:49 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_approval_group_id            in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_approval_group_name     in varchar2
  ,p_description                  in varchar2
  );
end ame_agl_rki;

 

/
