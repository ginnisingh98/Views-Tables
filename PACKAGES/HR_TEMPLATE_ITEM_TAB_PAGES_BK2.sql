--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_ITEM_TAB_PAGES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_ITEM_TAB_PAGES_BK2" AUTHID CURRENT_USER as
/* $Header: hrtfpapi.pkh 120.0 2005/05/31 03:07:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_template_item_tab_page_b >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_tip_b
  (p_template_item_tab_page_id     in     number
  ,p_object_version_number         in     number
  ,p_upd_template_item_contexts    in     boolean
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_template_item_tab_page_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_tip_a
  (p_template_item_tab_page_id     in     number
  ,p_object_version_number         in     number
  ,p_upd_template_item_contexts    in     boolean
  );
--
end hr_template_item_tab_pages_bk2;

 

/
