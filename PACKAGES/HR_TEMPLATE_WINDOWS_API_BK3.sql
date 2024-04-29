--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_WINDOWS_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_WINDOWS_API_BK3" AUTHID CURRENT_USER as
/* $Header: hrtwuapi.pkh 120.0 2005/05/31 03:36:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_template_window_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_window_b
  (p_template_window_id              in number
  ,p_object_version_number           in number
  ,p_delete_children_flag            in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_template_window_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_window_a
  (p_template_window_id              in number
  ,p_object_version_number           in number
  ,p_delete_children_flag            in varchar2
  );
--
end hr_template_windows_api_bk3;

 

/
