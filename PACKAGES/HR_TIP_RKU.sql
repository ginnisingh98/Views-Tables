--------------------------------------------------------
--  DDL for Package HR_TIP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TIP_RKU" AUTHID CURRENT_USER as
/* $Header: hrtiprhi.pkh 120.0 2005/05/31 03:17:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_template_item_tab_page_id    in number
  ,p_object_version_number        in number
  ,p_template_item_id             in number
  ,p_template_tab_page_id         in number
  ,p_object_version_number_o      in number
  ,p_template_item_id_o           in number
  ,p_template_tab_page_id_o       in number
  );
--
end hr_tip_rku;

 

/
