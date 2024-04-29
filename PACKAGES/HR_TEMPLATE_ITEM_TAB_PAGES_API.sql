--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_ITEM_TAB_PAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_ITEM_TAB_PAGES_API" AUTHID CURRENT_USER as
/* $Header: hrtfpapi.pkh 120.0 2005/05/31 03:07:05 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_template_item_tab_page >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new template item tab page
--              in the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_template_item_id             Y    Number
--   p_template_tab_page_id         Y    Number
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_template_item_tab_page_id    Number
--   p_object_version_number        Number
--
-- Post Failure:
--
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure create_template_item_tab_page
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_template_item_id              in     number
  ,p_template_tab_page_id          in     number
  ,p_upd_template_item_contexts    in     boolean  default false
  ,p_template_item_tab_page_id        out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_template_item_tab_page >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process deletes a template item
--              tab page from the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_template_item_tab_page_id    Y    Number
--   p_object_version_number        Y    Number
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
procedure delete_template_item_tab_page
  (p_validate                      in     boolean  default false
  ,p_template_item_tab_page_id     in     number
  ,p_object_version_number         in     number
  ,p_upd_template_item_contexts    in     boolean  default false
  );
--
end hr_template_item_tab_pages_api;

 

/
