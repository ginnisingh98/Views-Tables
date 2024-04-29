--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_CANVASES_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_CANVASES_API_BK1" AUTHID CURRENT_USER as
/* $Header: hrtcuapi.pkh 120.0 2005/05/31 03:02:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< copy_template_canvas_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_canvas_b
  (p_effective_date                in     date
  ,p_language_code                 in     varchar2
  ,p_template_canvas_id_from       in     number
  ,p_template_window_id            in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< copy_template_canvas_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_canvas_a
  (p_effective_date                in     date
  ,p_language_code                 in     varchar2
  ,p_template_canvas_id_from       in     number
  ,p_template_window_id            in     number
  ,p_template_canvas_id_to         in     number
  ,p_object_version_number         in     number
  );
--
end hr_template_canvases_api_bk1;

 

/
