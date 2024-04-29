--------------------------------------------------------
--  DDL for Package HXC_TIME_ENTRY_RULE_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_ENTRY_RULE_BK_3" AUTHID CURRENT_USER as
/* $Header: hxcterapi.pkh 120.0 2005/05/29 05:59:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_entry_rule_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_entry_rule_b
  (p_time_entry_rule_id          in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_entry_rule_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_entry_rule_a
  (p_time_entry_rule_id          in  number
  ,p_object_version_number          in  number
  );
--
end hxc_time_entry_rule_bk_3;

 

/
