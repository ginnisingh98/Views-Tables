--------------------------------------------------------
--  DDL for Package HR_FORM_CANVASES_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_CANVASES_API_BK2" AUTHID CURRENT_USER as
/* $Header: hrfcnapi.pkh 120.0 2005/05/31 00:12:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_form_canvas_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_canvas_b
  (p_form_canvas_id               in     number
   ,p_object_version_number        in     number);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_form_canvas_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_canvas_a
  (p_form_canvas_id               in     number
   ,p_object_version_number        in     number);
--
end hr_form_canvases_api_bk2;

 

/
