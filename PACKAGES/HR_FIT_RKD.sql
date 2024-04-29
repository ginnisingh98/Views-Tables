--------------------------------------------------------
--  DDL for Package HR_FIT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FIT_RKD" AUTHID CURRENT_USER as
/* $Header: hrfitrhi.pkh 120.0 2005/05/31 00:22:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_form_item_id                 in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_item_name_o             in varchar2
  ,p_description_o                in varchar2
  );
--
end hr_fit_rkd;

 

/
