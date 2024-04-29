--------------------------------------------------------
--  DDL for Package HXC_ALIAS_VALUES_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_VALUES_BK_1" AUTHID CURRENT_USER as
/* $Header: hxchavapi.pkh 120.0 2005/05/29 05:34:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_alias_value_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alias_value_b
  (p_alias_value_name              in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date
  ,p_alias_definition_id           in     number
  ,p_enabled_flag                  in     varchar2
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
  ,p_language_code                 in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_alias_value_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alias_value_a
  (p_alias_value_id                in     number
  ,p_alias_value_name              in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date
  ,p_alias_definition_id           in     number
  ,p_enabled_flag                  in     varchar2
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
  ,p_object_version_number         in     number
  ,p_language_code                 in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_alias_value_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alias_value_b
  (p_alias_value_id                in     number
  ,p_alias_value_name              in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date
  ,p_alias_definition_id           in     number
  ,p_enabled_flag                  in     varchar2
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
  ,p_object_version_number         in     number
  ,p_language_code                 in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_alias_value_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alias_value_a
  (p_alias_value_id                in     number
  ,p_alias_value_name              in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date
  ,p_alias_definition_id           in     number
  ,p_enabled_flag                  in     varchar2
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
  ,p_object_version_number         in     number
  ,p_language_code                 in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_alias_value_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alias_value_b
  (p_alias_value_id                in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_alias_value_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alias_value_a
  (p_alias_value_id                in     number
  ,p_object_version_number         in     number
  );
--
end hxc_alias_values_bk_1;

 

/
