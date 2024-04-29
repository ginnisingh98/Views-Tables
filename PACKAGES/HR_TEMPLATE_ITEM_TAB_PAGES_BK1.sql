--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_ITEM_TAB_PAGES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_ITEM_TAB_PAGES_BK1" AUTHID CURRENT_USER as
/* $Header: hrtfpapi.pkh 120.0 2005/05/31 03:07:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_template_item_tab_page_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_tip_b
  (p_effective_date                in     date
  ,p_template_item_id              in     number
  ,p_template_tab_page_id          in     number
  ,p_upd_template_item_contexts    in     boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_template_item_tab_page_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure create_tip_a
  (p_effective_date                in     date
  ,p_template_item_id              in     number
  ,p_template_tab_page_id          in     number
  ,p_upd_template_item_contexts    in     boolean
  ,p_template_item_tab_page_id     in     number
  ,p_object_version_number         in     number
  );
--
end hr_template_item_tab_pages_bk1;

 

/
