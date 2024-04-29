--------------------------------------------------------
--  DDL for Package HR_FWT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FWT_RKD" AUTHID CURRENT_USER as
/* $Header: hrfwtrhi.pkh 120.0 2005/05/31 00:35:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_form_window_id               in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_window_name_o           in varchar2
  ,p_description_o                in varchar2
  );
--
end hr_fwt_rkd;

 

/
