--------------------------------------------------------
--  DDL for Package HXC_DATA_APP_RULE_USAGES_BK_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DATA_APP_RULE_USAGES_BK_2" AUTHID CURRENT_USER as
/* $Header: hxcdruapi.pkh 120.0 2005/05/29 05:29:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_data_app_rule_usages_b >----------------|
-- ----------------------------------------------------------------------------
--
procedure update_data_app_rule_usages_b
  (p_data_app_rule_usage_id        in     number
  ,p_object_version_number         in     number
  ,p_approval_style_id             in     number
  ,p_time_entry_rule_id            in     number
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_data_app_rule_usages_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure update_data_app_rule_usages_a
  (p_data_app_rule_usage_id        in     number
  ,p_object_version_number         in     number
  ,p_approval_style_id             in     number
  ,p_time_entry_rule_id            in     number
  ,p_time_recipient_id             in     number
  ,p_effective_date                in     date
  );
--
end hxc_data_app_rule_usages_bk_2;

 

/
