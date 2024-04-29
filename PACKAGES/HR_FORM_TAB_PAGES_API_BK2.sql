--------------------------------------------------------
--  DDL for Package HR_FORM_TAB_PAGES_API_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_TAB_PAGES_API_BK2" AUTHID CURRENT_USER as
/* $Header: hrftpapi.pkh 120.0 2005/05/31 00:30:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_form_tab_page_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_tab_page_b
  ( p_form_tab_page_id               in number
   ,p_object_version_number          in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_form_tab_page_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_tab_page_a
  ( p_form_tab_page_id               in number
   ,p_object_version_number          in number
  );
--
end hr_form_tab_pages_api_bk2;

 

/
