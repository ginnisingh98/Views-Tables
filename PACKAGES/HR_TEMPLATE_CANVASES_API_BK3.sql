--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_CANVASES_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_CANVASES_API_BK3" AUTHID CURRENT_USER as
/* $Header: hrtcuapi.pkh 120.0 2005/05/31 03:02:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_template_canvas_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_canvas_b
  (p_template_canvas_id           in number
  ,p_delete_children_flag          in varchar2
  ,p_object_version_number         in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_template_canvas_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_canvas_a
  (p_template_canvas_id           in number
  ,p_delete_children_flag          in varchar2
  ,p_object_version_number         in number
  );
--
end hr_template_canvases_api_bk3;

 

/
