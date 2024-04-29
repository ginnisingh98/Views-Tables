--------------------------------------------------------
--  DDL for Package HR_FIM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FIM_RKU" AUTHID CURRENT_USER as
/* $Header: hrfimrhi.pkh 120.0 2005/05/31 00:21:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_form_item_id                 in number
  ,p_object_version_number        in number
  ,p_application_id               in number
  ,p_form_id                      in number
  ,p_form_canvas_id               in number
  ,p_full_item_name               in varchar2
  ,p_item_type                    in varchar2
  ,p_form_tab_page_id             in number
  ,p_radio_button_name            in varchar2
  ,p_required_override            in number
  ,p_form_tab_page_id_override    in number
  ,p_visible_override             in number
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
end hr_fim_rku;

 

/
