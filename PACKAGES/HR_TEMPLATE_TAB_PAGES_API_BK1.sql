--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_TAB_PAGES_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_TAB_PAGES_API_BK1" AUTHID CURRENT_USER as
/* $Header: hrttpapi.pkh 120.0 2005/05/31 03:33:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< copy_template_tab_page_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_tab_page_b
  (p_effective_date                in date
  ,p_language_code                 in varchar2
  ,p_template_tab_page_id_from     in number
  ,p_template_canvas_id            in number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< copy_template_tab_pages_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_tab_page_a
  (p_effective_date                in date
  ,p_language_code                 in varchar2
  ,p_template_tab_page_id_from     in number
  ,p_template_canvas_id            in number
  ,p_template_tab_page_id_to       in number
  ,p_object_version_number         in number
  --,p_override_value_warning        in boolean
  );
--
end hr_template_tab_pages_api_bk1;

 

/
