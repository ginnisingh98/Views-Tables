--------------------------------------------------------
--  DDL for Package AME_ITL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITL_RKD" AUTHID CURRENT_USER as
/* $Header: amitlrhi.pkh 120.0 2005/09/02 04:01 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_item_class_id                in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_item_class_name_o       in varchar2
  );
--
end ame_itl_rkd;

 

/
