--------------------------------------------------------
--  DDL for Package HXC_PREF_HIERARCHIES_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_PREF_HIERARCHIES_BK_1" AUTHID CURRENT_USER as
/* $Header: hxchphapi.pkh 120.0 2005/05/29 05:36:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pref_hierarchies_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pref_hierarchies_b
  (p_pref_hierarchy_id             in     number
  ,p_object_version_number         in     number
  ,p_type                          in     varchar2
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_parent_pref_hierarchy_id      in     number
  ,p_edit_allowed                  in     varchar2
  ,p_displayed                     in     varchar2
  ,p_pref_definition_id            in     number
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
  ,p_orig_pref_hierarchy_id        in     number
  ,p_orig_parent_hierarchy_id      in     number
  ,p_effective_date                in     date
  ,p_top_level_parent_id           in     number    --Performance Fix
  ,p_code	                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pref_hierarchies_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_pref_hierarchies_a
  (p_pref_hierarchy_id             in     number
  ,p_object_version_number         in     number
  ,p_type                          in     varchar2
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_parent_pref_hierarchy_id      in     number
  ,p_edit_allowed                  in     varchar2
  ,p_displayed                     in     varchar2
  ,p_pref_definition_id            in     number
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
  ,p_orig_pref_hierarchy_id        in     number
  ,p_orig_parent_hierarchy_id      in     number
  ,p_effective_date                in     date
  ,p_top_level_parent_id           in     number   --Performance Fix
  ,p_code	                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pref_hierarchies_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pref_hierarchies_b
  (p_pref_hierarchy_id             in     number
  ,p_object_version_number         in     number
  ,p_type                          in     varchar2
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_parent_pref_hierarchy_id      in     number
  ,p_edit_allowed                  in     varchar2
  ,p_displayed                     in     varchar2
  ,p_pref_definition_id            in     number
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
  ,p_orig_pref_hierarchy_id        in     number
  ,p_orig_parent_hierarchy_id      in     number
  ,p_effective_date                in     date
  ,p_top_level_parent_id           in     number  --Performance Fix
  ,p_code	                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pref_hierarchies_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_pref_hierarchies_a
  (p_pref_hierarchy_id             in     number
  ,p_object_version_number         in     number
  ,p_type                          in     varchar2
  ,p_name                          in     varchar2
  ,p_business_group_id	           in     number
  ,p_legislation_code              in     varchar2
  ,p_parent_pref_hierarchy_id      in     number
  ,p_edit_allowed                  in     varchar2
  ,p_displayed                     in     varchar2
  ,p_pref_definition_id            in     number
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
  ,p_orig_pref_hierarchy_id        in     number
  ,p_orig_parent_hierarchy_id      in     number
  ,p_effective_date                in     date
  ,p_top_level_parent_id           in     number   --Performance Fix
  ,p_code	                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pref_hierarchies_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pref_hierarchies_b
  (p_pref_hierarchy_id              in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pref_hierarchies_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_pref_hierarchies_a
  (p_pref_hierarchy_id              in  number
  ,p_object_version_number          in  number
  );
--
end hxc_pref_hierarchies_bk_1;

 

/
