--------------------------------------------------------
--  DDL for Package HR_TTP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TTP_RKI" AUTHID CURRENT_USER as
/* $Header: hrttprhi.pkh 120.0 2005/05/31 03:34:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_template_tab_page_id         in number
  ,p_object_version_number        in number
  ,p_template_canvas_id           in number
  ,p_form_tab_page_id             in number
  );
end hr_ttp_rki;

 

/
