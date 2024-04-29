--------------------------------------------------------
--  DDL for Package HR_FSC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FSC_API" AUTHID CURRENT_USER as
/* $Header: hrfscapi.pkh 120.0 2005/05/31 00:27:36 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |--------------< create_form_tab_stacked_canvas >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new form tab stacked canvas
--              in the HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                          Reqd Type     Description
--
--  p_form_tab_page_id             Y    Number
--  p_form_canvas_id               Y    Number
--
-- Post Success:
--
--
--   Name                           Type     Description
--
--  p_form_tab_stacked_canvas_id   Number
--  p_object_version_number        Number
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure create_form_tab_stacked_canvas
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_form_tab_page_id              in     number
  ,p_form_canvas_id                in     number
  ,p_form_tab_stacked_canvas_id       out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_form_tab_stacked_canvas >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process deletes a form tab stacked canvas
--              from the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_form_tab_stacked_canvas_id    Y    Number
--  p_object_version_number         Y    Number
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure delete_form_tab_stacked_canvas
  (p_validate                      in     boolean  default false
  ,p_form_tab_stacked_canvas_id    in     number
  ,p_object_version_number         in     number
  );
--
end hr_fsc_api;

 

/
