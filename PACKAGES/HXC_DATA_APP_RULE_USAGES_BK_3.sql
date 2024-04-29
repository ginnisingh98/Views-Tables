--------------------------------------------------------
--  DDL for Package HXC_DATA_APP_RULE_USAGES_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DATA_APP_RULE_USAGES_BK_3" AUTHID CURRENT_USER as
/* $Header: hxcdruapi.pkh 120.0 2005/05/29 05:29:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_data_app_rule_usages_b >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_data_app_rule_usages_b
  (p_data_app_rule_usage_id         in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_data_app_rule_usages_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_data_app_rule_usages_a
  (p_data_app_rule_usage_id         in  number
  ,p_object_version_number          in  number
  );
--
end hxc_data_app_rule_usages_bk_3;

 

/
