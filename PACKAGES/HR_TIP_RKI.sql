--------------------------------------------------------
--  DDL for Package HR_TIP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TIP_RKI" AUTHID CURRENT_USER as
/* $Header: hrtiprhi.pkh 120.0 2005/05/31 03:17:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_template_item_tab_page_id    in number
  ,p_object_version_number        in number
  ,p_template_item_id             in number
  ,p_template_tab_page_id         in number
  );
end hr_tip_rki;

 

/
