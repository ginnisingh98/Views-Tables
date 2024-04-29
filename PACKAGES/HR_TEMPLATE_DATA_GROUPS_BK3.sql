--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_DATA_GROUPS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_DATA_GROUPS_BK3" AUTHID CURRENT_USER as
/* $Header: hrtdgapi.pkh 120.0 2005/05/31 03:03:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_template_data_group_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_data_group_b
  (p_template_data_group_id        in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_template_data_group_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_data_group_a
  (p_template_data_group_id        in     number
  ,p_object_version_number         in     number
  );
--
end hr_template_data_groups_bk3;

 

/
