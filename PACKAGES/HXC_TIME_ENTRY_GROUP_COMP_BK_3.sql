--------------------------------------------------------
--  DDL for Package HXC_TIME_ENTRY_GROUP_COMP_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_ENTRY_GROUP_COMP_BK_3" AUTHID CURRENT_USER as
/* $Header: hxctecapi.pkh 120.0 2005/05/29 05:58:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_time_entry_group_comp_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_entry_group_comp_b
  (p_time_entry_group_comp_id in  number
  ,p_object_version_number         in  number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_time_entry_group_comp_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_entry_group_comp_a
  (p_time_entry_group_comp_id      in  number
  ,p_object_version_number         in  number
  );
--
end hxc_time_entry_group_comp_bk_3;

 

/
