--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_TAB_PAGES_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_TAB_PAGES_API_BK3" AUTHID CURRENT_USER as
/* $Header: hrttpapi.pkh 120.0 2005/05/31 03:33:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_template_tab_page_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_tab_page_b
  (p_template_tab_page_id            in number
  ,p_object_version_number           in number
  ,p_delete_children_flag            in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_template_tab_page_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_tab_page_a
  (p_template_tab_page_id            in number
  ,p_object_version_number           in number
  ,p_delete_children_flag            in varchar2
  );
--
end hr_template_tab_pages_api_bk3;

 

/
