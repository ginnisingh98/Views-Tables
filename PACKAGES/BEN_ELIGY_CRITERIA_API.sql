--------------------------------------------------------
--  DDL for Package BEN_ELIGY_CRITERIA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIGY_CRITERIA_API" AUTHID CURRENT_USER as
/* $Header: beeglapi.pkh 120.1 2005/07/29 09:06 rbingi noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_eligy_criteria >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_validate                     Yes  boolean   Commit or Rollback.
--   p_name                         Yes  varchar2
--   p_short_code                   Yes  varchar2
--   p_description                  No   varchar2
--   p_criteria_type		    Yes  varchar2
--   p_crit_col1_val_type_cd	    Yes  varchar2
--   p_crit_col1_datatype	    Yes  varchar2
--   p_col1_lookup_type		         varchar2
--   p_col1_value_set_id                 number
--   p_access_table_name1                varchar2
--   p_access_column_name1	         varchar2
--   p_time_entry_access_tab_nam1     varchar2
--   p_time_entry_access_col_nam1       varchar2
--   p_crit_col2_val_type_cd		 varchar2
--   p_crit_col2_datatype		 varchar2
--   p_col2_lookup_type		         varchar2
--   p_col2_value_set_id                 number
--   p_access_table_name2		 varchar2
--   p_access_column_name2		 varchar2
--   p_time_entry_access_tab_nam2	 varchar2
--   p_time_entry_access_col_nam2	 varchar2
--   p_access_calc_rule		         number
--   p_allow_range_validation_flg	 varchar2
--   p_user_defined_flag                 varchar2
--   p_business_group_id 	     Yes number    Business Group of Record
--   p_legislation_code 	     No  varchar2
--   p_egl_attribute_category        No  varchar2  Descriptive Flexfield
--   p_egl_attribute1                No  varchar2  Descriptive Flexfield
--   p_egl_attribute2                No  varchar2  Descriptive Flexfield
--   p_egl_attribute3                No  varchar2  Descriptive Flexfield
--   p_egl_attribute4                No  varchar2  Descriptive Flexfield
--   p_egl_attribute5                No  varchar2  Descriptive Flexfield
--   p_egl_attribute6                No  varchar2  Descriptive Flexfield
--   p_egl_attribute7                No  varchar2  Descriptive Flexfield
--   p_egl_attribute8                No  varchar2  Descriptive Flexfield
--   p_egl_attribute9                No  varchar2  Descriptive Flexfield
--   p_egl_attribute10               No  varchar2  Descriptive Flexfield
--   p_egl_attribute11               No  varchar2  Descriptive Flexfield
--   p_egl_attribute12               No  varchar2  Descriptive Flexfield
--   p_egl_attribute13               No  varchar2  Descriptive Flexfield
--   p_egl_attribute14               No  varchar2  Descriptive Flexfield
--   p_egl_attribute15               No  varchar2  Descriptive Flexfield
--   p_egl_attribute16               No  varchar2  Descriptive Flexfield
--   p_egl_attribute17               No  varchar2  Descriptive Flexfield
--   p_egl_attribute18               No  varchar2  Descriptive Flexfield
--   p_egl_attribute19               No  varchar2  Descriptive Flexfield
--   p_egl_attribute20               No  varchar2  Descriptive Flexfield
--   p_egl_attribute21               No  varchar2  Descriptive Flexfield
--   p_egl_attribute22               No  varchar2  Descriptive Flexfield
--   p_egl_attribute23               No  varchar2  Descriptive Flexfield
--   p_egl_attribute24               No  varchar2  Descriptive Flexfield
--   p_egl_attribute25               No  varchar2  Descriptive Flexfield
--   p_egl_attribute26               No  varchar2  Descriptive Flexfield
--   p_egl_attribute27               No  varchar2  Descriptive Flexfield
--   p_egl_attribute28               No  varchar2  Descriptive Flexfield
--   p_egl_attribute29               No  varchar2  Descriptive Flexfield
--   p_egl_attribute30               No  varchar2  Descriptive Flexfield
--   p_effective_date          Yes  date       Session Date.
-- Post Success:
--
-- Out Parameters:
--   Name                          Reqd      Type     Description
--   p_eligy_criteria_id            Yes     number    PK of record
--   p_object_version_number        No      number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_criteria
(
   p_validate                       in boolean       default false
  ,p_eligy_criteria_id              out nocopy number
  ,p_name                           in  varchar2     default null
  ,p_short_code                     in  varchar2     default null
  ,p_description                    in  varchar2     default null
  ,p_criteria_type		    in  varchar2     default null
  ,p_crit_col1_val_type_cd	    in  varchar2     default null
  ,p_crit_col1_datatype	    	    in  varchar2     default null
  ,p_col1_lookup_type		    in  varchar2     default null
  ,p_col1_value_set_id              in  number	     default null
  ,p_access_table_name1             in  varchar2     default null
  ,p_access_column_name1	    in  varchar2     default null
  ,p_time_entry_access_tab_nam1     in  varchar2     default null
  ,p_time_entry_access_col_nam1     in  varchar2     default null
  ,p_crit_col2_val_type_cd	    in	varchar2     default null
  ,p_crit_col2_datatype		    in  varchar2     default null
  ,p_col2_lookup_type		    in  varchar2     default null
  ,p_col2_value_set_id              in  number	     default null
  ,p_access_table_name2		    in  varchar2     default null
  ,p_access_column_name2	    in  varchar2     default null
  ,p_time_entry_access_tab_nam2     in	varchar2     default null
  ,p_time_entry_access_col_nam2     in  varchar2     default null
  ,p_access_calc_rule		    in  number	     default null
  ,p_allow_range_validation_flg     in  varchar2     default 'N'
  ,p_user_defined_flag              in  varchar2     default 'N'
  ,p_business_group_id 	    	    in  number       default null
  ,p_legislation_code 	    	    in  varchar2     default null
  ,p_egl_attribute_category         in  varchar2     default null
  ,p_egl_attribute1                 in  varchar2     default null
  ,p_egl_attribute2                 in  varchar2     default null
  ,p_egl_attribute3                 in  varchar2     default null
  ,p_egl_attribute4                 in  varchar2     default null
  ,p_egl_attribute5                 in  varchar2     default null
  ,p_egl_attribute6                 in  varchar2     default null
  ,p_egl_attribute7                 in  varchar2     default null
  ,p_egl_attribute8                 in  varchar2     default null
  ,p_egl_attribute9                 in  varchar2     default null
  ,p_egl_attribute10                in  varchar2     default null
  ,p_egl_attribute11                in  varchar2     default null
  ,p_egl_attribute12                in  varchar2     default null
  ,p_egl_attribute13                in  varchar2     default null
  ,p_egl_attribute14                in  varchar2     default null
  ,p_egl_attribute15                in  varchar2     default null
  ,p_egl_attribute16                in  varchar2     default null
  ,p_egl_attribute17                in  varchar2     default null
  ,p_egl_attribute18                in  varchar2     default null
  ,p_egl_attribute19                in  varchar2     default null
  ,p_egl_attribute20                in  varchar2     default null
  ,p_egl_attribute21                in  varchar2     default null
  ,p_egl_attribute22                in  varchar2     default null
  ,p_egl_attribute23                in  varchar2     default null
  ,p_egl_attribute24                in  varchar2     default null
  ,p_egl_attribute25                in  varchar2     default null
  ,p_egl_attribute26                in  varchar2     default null
  ,p_egl_attribute27                in  varchar2     default null
  ,p_egl_attribute28                in  varchar2     default null
  ,p_egl_attribute29                in  varchar2     default null
  ,p_egl_attribute30                in  varchar2     default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_allow_range_validation_flag2   in  varchar2     default null
  ,p_access_calc_rule2              in  number       default null
  ,p_time_access_calc_rule1         in  number       default null
  ,p_time_access_calc_rule2         in  number       default null
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_eligy_criteria >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_eligy_criteria_id            Yes  number    PK of record
--   p_name                         Yes  varchar2
--   p_short_code                   Yes  varchar2
--   p_description                  No   varchar2
--   p_criteria_type		    Yes  varchar2
--   p_crit_col1_val_type_cd	    Yes  varchar2
--   p_crit_col1_datatype	    Yes  varchar2
--   p_col1_lookup_type		         varchar2
--   p_col1_value_set_id                 number
--   p_access_table_name1                varchar2
--   p_access_column_name1	         varchar2
--   p_time_entry_access_tab_nam1     varchar2
--   p_time_entry_access_col_nam1       varchar2
--   p_crit_col2_val_type_cd		 varchar2
--   p_crit_col2_datatype		 varchar2
--   p_col2_lookup_type		         varchar2
--   p_col2_value_set_id                 number
--   p_access_table_name2		 varchar2
--   p_access_column_name2		 varchar2
--   p_time_entry_access_tab_nam2	 varchar2
--   p_time_entry_access_col_nam2	 varchar2
--   p_access_calc_rule		         number
--   p_allow_range_validation_flg	 varchar2
--   p_user_defined_flag                 varchar2
--   p_business_group_id 	     Yes number    Business Group of Record
--   p_legislation_code 	     No  varchar2
--   p_egl_attribute_category        No  varchar2  Descriptive Flexfield
--   p_egl_attribute1                No  varchar2  Descriptive Flexfield
--   p_egl_attribute2                No  varchar2  Descriptive Flexfield
--   p_egl_attribute3                No  varchar2  Descriptive Flexfield
--   p_egl_attribute4                No  varchar2  Descriptive Flexfield
--   p_egl_attribute5                No  varchar2  Descriptive Flexfield
--   p_egl_attribute6                No  varchar2  Descriptive Flexfield
--   p_egl_attribute7                No  varchar2  Descriptive Flexfield
--   p_egl_attribute8                No  varchar2  Descriptive Flexfield
--   p_egl_attribute9                No  varchar2  Descriptive Flexfield
--   p_egl_attribute10               No  varchar2  Descriptive Flexfield
--   p_egl_attribute11               No  varchar2  Descriptive Flexfield
--   p_egl_attribute12               No  varchar2  Descriptive Flexfield
--   p_egl_attribute13               No  varchar2  Descriptive Flexfield
--   p_egl_attribute14               No  varchar2  Descriptive Flexfield
--   p_egl_attribute15               No  varchar2  Descriptive Flexfield
--   p_egl_attribute16               No  varchar2  Descriptive Flexfield
--   p_egl_attribute17               No  varchar2  Descriptive Flexfield
--   p_egl_attribute18               No  varchar2  Descriptive Flexfield
--   p_egl_attribute19               No  varchar2  Descriptive Flexfield
--   p_egl_attribute20               No  varchar2  Descriptive Flexfield
--   p_egl_attribute21               No  varchar2  Descriptive Flexfield
--   p_egl_attribute22               No  varchar2  Descriptive Flexfield
--   p_egl_attribute23               No  varchar2  Descriptive Flexfield
--   p_egl_attribute24               No  varchar2  Descriptive Flexfield
--   p_egl_attribute25               No  varchar2  Descriptive Flexfield
--   p_egl_attribute26               No  varchar2  Descriptive Flexfield
--   p_egl_attribute27               No  varchar2  Descriptive Flexfield
--   p_egl_attribute28               No  varchar2  Descriptive Flexfield
--   p_egl_attribute29               No  varchar2  Descriptive Flexfield
--   p_egl_attribute30               No  varchar2  Descriptive Flexfield

--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_criteria
  (
   p_validate                       in boolean    default false
  ,p_eligy_criteria_id              in  number
   ,p_name                          in  varchar2  default hr_api.g_varchar2
  ,p_short_code                     in  varchar2  default hr_api.g_varchar2
  ,p_description                    in  varchar2  default hr_api.g_varchar2
  ,p_criteria_type		    in  varchar2  default hr_api.g_varchar2
  ,p_crit_col1_val_type_cd	    in  varchar2  default hr_api.g_varchar2
  ,p_crit_col1_datatype	    	    in  varchar2  default hr_api.g_varchar2
  ,p_col1_lookup_type		    in  varchar2  default hr_api.g_varchar2
  ,p_col1_value_set_id              in  number	  default hr_api.g_number
  ,p_access_table_name1             in  varchar2  default hr_api.g_varchar2
  ,p_access_column_name1	    in  varchar2  default hr_api.g_varchar2
  ,p_time_entry_access_tab_nam1     in  varchar2  default hr_api.g_varchar2
  ,p_time_entry_access_col_nam1     in  varchar2  default hr_api.g_varchar2
  ,p_crit_col2_val_type_cd	    in	varchar2  default hr_api.g_varchar2
  ,p_crit_col2_datatype		    in  varchar2  default hr_api.g_varchar2
  ,p_col2_lookup_type		    in  varchar2  default hr_api.g_varchar2
  ,p_col2_value_set_id              in  number	  default hr_api.g_number
  ,p_access_table_name2		    in  varchar2  default hr_api.g_varchar2
  ,p_access_column_name2	    in  varchar2  default hr_api.g_varchar2
  ,p_time_entry_access_tab_nam2     in	varchar2  default hr_api.g_varchar2
  ,p_time_entry_access_col_nam2     in  varchar2  default hr_api.g_varchar2
  ,p_access_calc_rule		    in  number	  default hr_api.g_number
  ,p_allow_range_validation_flg     in  varchar2  default hr_api.g_varchar2
  ,p_user_defined_flag              in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id 	    	    in  number    default hr_api.g_number
  ,p_legislation_code 	    	    in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_egl_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  ,p_allow_range_validation_flag2   in  varchar2  default hr_api.g_varchar2
  ,p_access_calc_rule2              in  number    default hr_api.g_number
  ,p_time_access_calc_rule1         in  number    default hr_api.g_number
  ,p_time_access_calc_rule2         in  number    default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_eligy_criteria >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_eligy_criteria_id            Yes  number    PK of record
--
-- Post Success:
--
--   Name                           Type           Description
--   p_object_version_number        No   number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_criteria
  (
   p_validate                       in boolean        default false
  ,p_eligy_criteria_id              in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_criteria_id            Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_eligy_criteria_id            in number
   ,p_object_version_number        in number
  );
--
end ben_eligy_criteria_api;

 

/
