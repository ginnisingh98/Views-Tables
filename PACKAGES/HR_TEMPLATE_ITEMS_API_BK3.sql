--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_ITEMS_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_ITEMS_API_BK3" AUTHID CURRENT_USER as
/* $Header: hrtimapi.pkh 120.0 2005/05/31 03:12:42 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_template_item_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_item_b
  (p_template_item_id             in    number
   ,p_object_version_number        in    number
   ,p_delete_children_flag         in    varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_template_item_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_item_a
  (p_template_item_id             in    number
   ,p_object_version_number        in    number
   ,p_delete_children_flag         in    varchar2
  );
--
end hr_template_items_api_bk3;

 

/
