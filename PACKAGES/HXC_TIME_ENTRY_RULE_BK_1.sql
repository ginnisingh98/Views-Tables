--------------------------------------------------------
--  DDL for Package HXC_TIME_ENTRY_RULE_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_ENTRY_RULE_BK_1" AUTHID CURRENT_USER as
/* $Header: hxcterapi.pkh 120.0 2005/05/29 05:59:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_time_entry_rule_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_entry_rule_b
  (p_time_entry_rule_id          in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_rule_usage                     in     varchar2
  ,p_start_date                      in     date
  ,p_mapping_id                     in     number
  ,p_formula_id                     in     number
  ,p_description                    in     varchar2
  ,p_end_date                        in     date
  ,p_effective_date                 in     date
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_time_entry_rule_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_entry_rule_a
  (p_time_entry_rule_id          in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  ,p_business_group_id             in     number
  ,p_legislation_code              in     varchar2
  ,p_rule_usage                     in     varchar2
  ,p_start_date                      in     date
  ,p_mapping_id                     in     number
  ,p_formula_id                     in     number
  ,p_description                    in     varchar2
  ,p_end_date                        in     date
  ,p_effective_date                 in     date
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  );
--
end hxc_time_entry_rule_bk_1;

 

/
