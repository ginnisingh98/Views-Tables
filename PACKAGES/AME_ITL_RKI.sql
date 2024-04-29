--------------------------------------------------------
--  DDL for Package AME_ITL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITL_RKI" AUTHID CURRENT_USER as
/* $Header: amitlrhi.pkh 120.0 2005/09/02 04:01 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_item_class_id                in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_item_class_name         in varchar2
  );
end ame_itl_rki;

 

/
