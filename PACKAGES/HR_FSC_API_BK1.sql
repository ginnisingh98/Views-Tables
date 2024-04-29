--------------------------------------------------------
--  DDL for Package HR_FSC_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FSC_API_BK1" AUTHID CURRENT_USER as
/* $Header: hrfscapi.pkh 120.0 2005/05/31 00:27:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_form_tab_stacked_canvas_b >----------------|
-- ----------------------------------------------------------------------------
--
procedure create_fsc_b
  (p_effective_date                in     date
  ,p_form_tab_page_id              in     number
  ,p_form_canvas_id                in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_form_tab_stacked_canvas_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_fsc_a
  (p_effective_date                in     date
  ,p_form_tab_page_id              in     number
  ,p_form_canvas_id                in     number
  ,p_form_tab_stacked_canvas_id    in     number
  ,p_object_version_number         in     number
  );
--
end hr_fsc_api_bk1;

 

/
