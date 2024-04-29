--------------------------------------------------------
--  DDL for Package HR_FIM_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FIM_RKD" AUTHID CURRENT_USER as
/* $Header: hrfimrhi.pkh 120.0 2005/05/31 00:21:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_form_item_id                 in number
  ,p_object_version_number_o      in number
  ,p_application_id_o             in number
  ,p_form_id_o                    in number
  ,p_form_canvas_id_o             in number
  ,p_full_item_name_o             in varchar2
  ,p_item_type_o                  in varchar2
  ,p_form_tab_page_id_o           in number
  ,p_radio_button_name_o          in varchar2
  ,p_required_override_o          in number
  ,p_form_tab_page_id_override_o  in number
  ,p_visible_override_o           in number
  );
--
end hr_fim_rkd;

 

/
