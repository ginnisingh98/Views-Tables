--------------------------------------------------------
--  DDL for Package HR_FSC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FSC_RKD" AUTHID CURRENT_USER as
/* $Header: hrfscrhi.pkh 120.0 2005/05/31 00:29:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_form_tab_stacked_canvas_id   in number
  ,p_object_version_number_o      in number
  ,p_form_tab_page_id_o           in number
  ,p_form_canvas_id_o             in number
  );
--
end hr_fsc_rkd;

 

/
