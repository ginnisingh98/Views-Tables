--------------------------------------------------------
--  DDL for Package HR_FORM_DATA_GROUP_ITEMS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_DATA_GROUP_ITEMS_BK2" AUTHID CURRENT_USER as
/* $Header: hrfgiapi.pkh 120.0 2005/05/31 00:18:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_form_data_group_item_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_data_group_item_b
  (p_form_data_group_item_id       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_form_data_group_item_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_data_group_item_a
  (p_form_data_group_item_id       in     number
  ,p_object_version_number         in     number
  );
--
end hr_form_data_group_items_bk2;

 

/
