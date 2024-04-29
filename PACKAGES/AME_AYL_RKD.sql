--------------------------------------------------------
--  DDL for Package AME_AYL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_AYL_RKD" AUTHID CURRENT_USER as
/* $Header: amaylrhi.pkh 120.0 2005/09/02 03:53 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_action_type_id               in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_action_type_name_o      in varchar2
  ,p_description_o                in varchar2
  );
--
end ame_ayl_rkd;

 

/
