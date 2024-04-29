--------------------------------------------------------
--  DDL for Package HR_FWT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FWT_RKU" AUTHID CURRENT_USER as
/* $Header: hrfwtrhi.pkh 120.0 2005/05/31 00:35:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_form_window_id               in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_window_name             in varchar2
  ,p_description                  in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_window_name_o           in varchar2
  ,p_description_o                in varchar2
  );
--
end hr_fwt_rku;

 

/
