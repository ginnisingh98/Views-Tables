--------------------------------------------------------
--  DDL for Package HR_FSC_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FSC_API_BK2" AUTHID CURRENT_USER as
/* $Header: hrfscapi.pkh 120.0 2005/05/31 00:27:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_form_tab_stacked_canvas_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_fsc_b
  (p_form_tab_stacked_canvas_id    in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_form_tab_stacked_canvas_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_fsc_a
  (p_form_tab_stacked_canvas_id    in     number
  ,p_object_version_number         in     number
  );
--
end hr_fsc_api_bk2;

 

/
