--------------------------------------------------------
--  DDL for Package HXC_RESOURCE_RULES_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RESOURCE_RULES_BK_1" AUTHID CURRENT_USER as
/* $Header: hxchrrapi.pkh 120.0 2005/05/29 05:38:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_resource_rules_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_resource_rules_b
  (p_resource_rule_id              in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_eligibility_criteria_type     in     varchar2
  ,p_eligibility_criteria_id       in     varchar2
  ,p_pref_hierarchy_id             in     number
  ,p_rule_evaluation_order         in     number
  ,p_resource_type                 in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_resource_rules_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_resource_rules_a
  (p_resource_rule_id              in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_eligibility_criteria_type     in     varchar2
  ,p_eligibility_criteria_id       in     varchar2
  ,p_pref_hierarchy_id             in     number
  ,p_rule_evaluation_order         in     number
  ,p_resource_type                 in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_resource_rules_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_resource_rules_b
  (p_resource_rule_id              in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_eligibility_criteria_type     in     varchar2
  ,p_eligibility_criteria_id       in     varchar2
  ,p_pref_hierarchy_id             in     number
  ,p_rule_evaluation_order         in     number
  ,p_resource_type                 in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_resource_rules_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_resource_rules_a
  (p_resource_rule_id              in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_eligibility_criteria_type     in     varchar2
  ,p_eligibility_criteria_id       in     varchar2
  ,p_pref_hierarchy_id             in     number
  ,p_rule_evaluation_order         in     number
  ,p_resource_type                 in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_resource_rules_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_resource_rules_b
  (p_resource_rule_id               in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_resource_rules_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_resource_rules_a
  (p_resource_rule_id               in  number
  ,p_object_version_number          in  number
  );
--
end hxc_resource_rules_bk_1;

 

/
