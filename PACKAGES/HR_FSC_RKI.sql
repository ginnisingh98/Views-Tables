--------------------------------------------------------
--  DDL for Package HR_FSC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FSC_RKI" AUTHID CURRENT_USER as
/* $Header: hrfscrhi.pkh 120.0 2005/05/31 00:29:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_form_tab_stacked_canvas_id   in number
  ,p_object_version_number        in number
  ,p_form_tab_page_id             in number
  ,p_form_canvas_id               in number
  );
end hr_fsc_rki;

 

/
