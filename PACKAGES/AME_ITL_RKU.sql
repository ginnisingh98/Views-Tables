--------------------------------------------------------
--  DDL for Package AME_ITL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITL_RKU" AUTHID CURRENT_USER as
/* $Header: amitlrhi.pkh 120.0 2005/09/02 04:01 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_item_class_id                in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_item_class_name         in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_item_class_name_o       in varchar2
  );
--
end ame_itl_rku;

 

/
