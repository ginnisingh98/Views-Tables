--------------------------------------------------------
--  DDL for Package HR_FORM_DATA_GROUP_ITEMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FORM_DATA_GROUP_ITEMS_API" AUTHID CURRENT_USER as
/* $Header: hrfgiapi.pkh 120.0 2005/05/31 00:18:34 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_form_data_group_item >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process inserts a new form data group item
--              in the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_form_item_id                 Y    Number
--   p_form_data_group_id           Y    Number
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   p_form_data_group_item_id      Number
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
procedure create_form_data_group_item
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_form_item_id                  in     number
  ,p_form_data_group_id            in     number
  ,p_form_data_group_item_id          out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_form_data_group_item >--------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business process deletes a form data group item from the
--              HR Schema.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_form_data_group_item_id      Y    Number
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
procedure delete_form_data_group_item
  (p_validate                      in     boolean  default false
  ,p_form_data_group_item_id       in     number
  ,p_object_version_number         in     number
  );
--
end hr_form_data_group_items_api;

 

/
