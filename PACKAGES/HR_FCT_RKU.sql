--------------------------------------------------------
--  DDL for Package HR_FCT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FCT_RKU" AUTHID CURRENT_USER as
/* $Header: hrfctrhi.pkh 120.0 2005/05/31 00:16:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_form_canvas_id               in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_user_canvas_name             in varchar2
  ,p_description                  in varchar2
  ,p_source_lang_o                in varchar2
  ,p_user_canvas_name_o           in varchar2
  ,p_description_o                in varchar2
  );
--
end hr_fct_rku;

 

/
