--------------------------------------------------------
--  DDL for Package HXC_TIME_ENTRY_RULE_GROUP_BK_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_ENTRY_RULE_GROUP_BK_2" AUTHID CURRENT_USER as
/* $Header: hxctegapi.pkh 120.0 2005/05/29 05:58:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------<update_time_entry_rule_group_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_entry_rule_group_b
  (p_time_entry_rule_group_id       in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_time_entry_rule_group_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_entry_rule_group_a
  (p_time_entry_rule_group_id       in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  );
--
end hxc_time_entry_rule_group_bk_2;

 

/
