--------------------------------------------------------
--  DDL for Package Body BEN_ELIGY_CRITERIA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIGY_CRITERIA_API" as
/* $Header: beeglapi.pkb 120.1 2005/07/29 09:06 rbingi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_eligy_criteria_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_eligy_criteria >----------------------|
-- ----------------------------------------------------------------------------
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
  ,p_access_calc_rule2              in  number	     default null
  ,p_time_access_calc_rule1         in  number	     default null
  ,p_time_access_calc_rule2         in  number	     default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_eligy_criteria_id       ben_eligy_criteria.eligy_criteria_id%TYPE;
  l_proc varchar2(72) :=    g_package||'create_eligy_criteria';
  l_object_version_number   ben_eligy_criteria.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_eligy_criteria;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_eligy_criteria
    --
    ben_eligy_criteria_bk1.create_eligy_criteria_b
      (
        p_name                               => p_name
       ,p_short_code                         => p_short_code
       ,p_description                        => p_description
       ,p_criteria_type		             => p_criteria_type
       ,p_crit_col1_val_type_cd	             => p_crit_col1_val_type_cd
       ,p_crit_col1_datatype	    	     => p_crit_col1_datatype
       ,p_col1_lookup_type		     => p_col1_lookup_type
       ,p_col1_value_set_id                  => p_col1_value_set_id
       ,p_access_table_name1                 => p_access_table_name1
       ,p_access_column_name1	             => p_access_column_name1
       ,p_time_entry_access_tab_nam1         => p_time_entry_access_tab_nam1
       ,p_time_entry_access_col_nam1         => p_time_entry_access_col_nam1
       ,p_crit_col2_val_type_cd	             => p_crit_col2_val_type_cd
       ,p_crit_col2_datatype		     => p_crit_col2_datatype
       ,p_col2_lookup_type		     => p_col2_lookup_type
       ,p_col2_value_set_id                  => p_col2_value_set_id
       ,p_access_table_name2		     => p_access_table_name2
       ,p_access_column_name2	             => p_access_column_name2
       ,p_time_entry_access_tab_nam2         => p_time_entry_access_tab_nam2
       ,p_time_entry_access_col_nam2         => p_time_entry_access_col_nam2
       ,p_access_calc_rule		     => p_access_calc_rule
       ,p_allow_range_validation_flg         => p_allow_range_validation_flg
       ,p_user_defined_flag                  => p_user_defined_flag
       ,p_business_group_id 	    	     => p_business_group_id
       ,p_legislation_code 	    	     => p_legislation_code
       ,p_egl_attribute_category             => p_egl_attribute_category
       ,p_egl_attribute1                     => p_egl_attribute1
       ,p_egl_attribute2                     => p_egl_attribute2
       ,p_egl_attribute3                     => p_egl_attribute3
       ,p_egl_attribute4                     => p_egl_attribute4
       ,p_egl_attribute5                     => p_egl_attribute5
       ,p_egl_attribute6                     => p_egl_attribute6
       ,p_egl_attribute7                     => p_egl_attribute7
       ,p_egl_attribute8                     => p_egl_attribute8
       ,p_egl_attribute9                     => p_egl_attribute9
       ,p_egl_attribute10                    => p_egl_attribute10
       ,p_egl_attribute11                    => p_egl_attribute11
       ,p_egl_attribute12                    => p_egl_attribute12
       ,p_egl_attribute13                    => p_egl_attribute13
       ,p_egl_attribute14                    => p_egl_attribute14
       ,p_egl_attribute15                    => p_egl_attribute15
       ,p_egl_attribute16                    => p_egl_attribute16
       ,p_egl_attribute17                    => p_egl_attribute17
       ,p_egl_attribute18                    => p_egl_attribute18
       ,p_egl_attribute19                    => p_egl_attribute19
       ,p_egl_attribute20                    => p_egl_attribute20
       ,p_egl_attribute21                    => p_egl_attribute21
       ,p_egl_attribute22                    => p_egl_attribute22
       ,p_egl_attribute23                    => p_egl_attribute23
       ,p_egl_attribute24                    => p_egl_attribute24
       ,p_egl_attribute25                    => p_egl_attribute25
       ,p_egl_attribute26                    => p_egl_attribute26
       ,p_egl_attribute27                    => p_egl_attribute27
       ,p_egl_attribute28                    => p_egl_attribute28
       ,p_egl_attribute29                    =>	p_egl_attribute29
       ,p_egl_attribute30                    =>	p_egl_attribute30
       ,p_effective_date                     => trunc(p_effective_date)
       ,p_allow_range_validation_flag2       => p_allow_range_validation_flag2
       ,p_access_calc_rule2                  => p_access_calc_rule2
       ,p_time_access_calc_rule1             => p_time_access_calc_rule1
       ,p_time_access_calc_rule2             => p_time_access_calc_rule2
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_eligy_criteria'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_eligy_criteria
    --
  end;
  --
  ben_egl_ins.ins
    (
     p_eligy_criteria_id             => l_eligy_criteria_id
    ,p_name                          => p_name
    ,p_short_code                    => p_short_code
    ,p_description                   => p_description
    ,p_criteria_type		     => p_criteria_type
    ,p_crit_col1_val_type_cd	     => p_crit_col1_val_type_cd
    ,p_crit_col1_datatype	     => p_crit_col1_datatype
    ,p_col1_lookup_type		     => p_col1_lookup_type
    ,p_col1_value_set_id             => p_col1_value_set_id
    ,p_access_table_name1            => p_access_table_name1
    ,p_access_column_name1	     => p_access_column_name1
    ,p_time_entry_access_tab_nam1    => p_time_entry_access_tab_nam1
    ,p_time_entry_access_col_nam1    => p_time_entry_access_col_nam1
    ,p_crit_col2_val_type_cd	     => p_crit_col2_val_type_cd
    ,p_crit_col2_datatype	     => p_crit_col2_datatype
    ,p_col2_lookup_type		     => p_col2_lookup_type
    ,p_col2_value_set_id             => p_col2_value_set_id
    ,p_access_table_name2	     => p_access_table_name2
    ,p_access_column_name2	     => p_access_column_name2
    ,p_time_entry_access_tab_nam2    => p_time_entry_access_tab_nam2
    ,p_time_entry_access_col_nam2    => p_time_entry_access_col_nam2
    ,p_access_calc_rule		     => p_access_calc_rule
    ,p_allow_range_validation_flg    => p_allow_range_validation_flg
    ,p_user_defined_flag             => p_user_defined_flag
    ,p_business_group_id 	     => p_business_group_id
    ,p_legislation_code 	     => p_legislation_code
    ,p_egl_attribute_category        => p_egl_attribute_category
    ,p_egl_attribute1                => p_egl_attribute1
    ,p_egl_attribute2                => p_egl_attribute2
    ,p_egl_attribute3                => p_egl_attribute3
    ,p_egl_attribute4                => p_egl_attribute4
    ,p_egl_attribute5                => p_egl_attribute5
    ,p_egl_attribute6                => p_egl_attribute6
    ,p_egl_attribute7                => p_egl_attribute7
    ,p_egl_attribute8                => p_egl_attribute8
    ,p_egl_attribute9                => p_egl_attribute9
    ,p_egl_attribute10               => p_egl_attribute10
    ,p_egl_attribute11               => p_egl_attribute11
    ,p_egl_attribute12               => p_egl_attribute12
    ,p_egl_attribute13               => p_egl_attribute13
    ,p_egl_attribute14               => p_egl_attribute14
    ,p_egl_attribute15               => p_egl_attribute15
    ,p_egl_attribute16               => p_egl_attribute16
    ,p_egl_attribute17               => p_egl_attribute17
    ,p_egl_attribute18               => p_egl_attribute18
    ,p_egl_attribute19               => p_egl_attribute19
    ,p_egl_attribute20               => p_egl_attribute20
    ,p_egl_attribute21               => p_egl_attribute21
    ,p_egl_attribute22               => p_egl_attribute22
    ,p_egl_attribute23               => p_egl_attribute23
    ,p_egl_attribute24               => p_egl_attribute24
    ,p_egl_attribute25               => p_egl_attribute25
    ,p_egl_attribute26               => p_egl_attribute26
    ,p_egl_attribute27               => p_egl_attribute27
    ,p_egl_attribute28               => p_egl_attribute28
    ,p_egl_attribute29               => p_egl_attribute29
    ,p_egl_attribute30               => p_egl_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_allow_range_validation_flag2  => p_allow_range_validation_flag2
    ,p_access_calc_rule2             => p_access_calc_rule2
    ,p_time_access_calc_rule1        => p_time_access_calc_rule1
    ,p_time_access_calc_rule2        => p_time_access_calc_rule2
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_eligy_criteria
    --
    ben_eligy_criteria_bk1.create_eligy_criteria_a
      (
     p_eligy_criteria_id             => l_eligy_criteria_id
    ,p_name                          => p_name
    ,p_short_code                    => p_short_code
    ,p_description                   => p_description
    ,p_criteria_type		     => p_criteria_type
    ,p_crit_col1_val_type_cd	     => p_crit_col1_val_type_cd
    ,p_crit_col1_datatype	     => p_crit_col1_datatype
    ,p_col1_lookup_type		     => p_col1_lookup_type
    ,p_col1_value_set_id             => p_col1_value_set_id
    ,p_access_table_name1            => p_access_table_name1
    ,p_access_column_name1	     => p_access_column_name1
    ,p_time_entry_access_tab_nam1    => p_time_entry_access_tab_nam1
    ,p_time_entry_access_col_nam1    => p_time_entry_access_col_nam1
    ,p_crit_col2_val_type_cd	     => p_crit_col2_val_type_cd
    ,p_crit_col2_datatype	     => p_crit_col2_datatype
    ,p_col2_lookup_type		     => p_col2_lookup_type
    ,p_col2_value_set_id             => p_col2_value_set_id
    ,p_access_table_name2	     => p_access_table_name2
    ,p_access_column_name2	     => p_access_column_name2
    ,p_time_entry_access_tab_nam2    => p_time_entry_access_tab_nam2
    ,p_time_entry_access_col_nam2    => p_time_entry_access_col_nam2
    ,p_access_calc_rule		     => p_access_calc_rule
    ,p_allow_range_validation_flg    => p_allow_range_validation_flg
    ,p_user_defined_flag             => p_user_defined_flag
    ,p_business_group_id 	     => p_business_group_id
    ,p_legislation_code 	     => p_legislation_code
    ,p_egl_attribute_category        => p_egl_attribute_category
    ,p_egl_attribute1                => p_egl_attribute1
    ,p_egl_attribute2                => p_egl_attribute2
    ,p_egl_attribute3                => p_egl_attribute3
    ,p_egl_attribute4                => p_egl_attribute4
    ,p_egl_attribute5                => p_egl_attribute5
    ,p_egl_attribute6                => p_egl_attribute6
    ,p_egl_attribute7                => p_egl_attribute7
    ,p_egl_attribute8                => p_egl_attribute8
    ,p_egl_attribute9                => p_egl_attribute9
    ,p_egl_attribute10               => p_egl_attribute10
    ,p_egl_attribute11               => p_egl_attribute11
    ,p_egl_attribute12               => p_egl_attribute12
    ,p_egl_attribute13               => p_egl_attribute13
    ,p_egl_attribute14               => p_egl_attribute14
    ,p_egl_attribute15               => p_egl_attribute15
    ,p_egl_attribute16               => p_egl_attribute16
    ,p_egl_attribute17               => p_egl_attribute17
    ,p_egl_attribute18               => p_egl_attribute18
    ,p_egl_attribute19               => p_egl_attribute19
    ,p_egl_attribute20               => p_egl_attribute20
    ,p_egl_attribute21               => p_egl_attribute21
    ,p_egl_attribute22               => p_egl_attribute22
    ,p_egl_attribute23               => p_egl_attribute23
    ,p_egl_attribute24               => p_egl_attribute24
    ,p_egl_attribute25               => p_egl_attribute25
    ,p_egl_attribute26               => p_egl_attribute26
    ,p_egl_attribute27               => p_egl_attribute27
    ,p_egl_attribute28               => p_egl_attribute28
    ,p_egl_attribute29               => p_egl_attribute29
    ,p_egl_attribute30               => p_egl_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
    ,p_allow_range_validation_flag2  => p_allow_range_validation_flag2
    ,p_access_calc_rule2             => p_access_calc_rule2
    ,p_time_access_calc_rule1        => p_time_access_calc_rule1
    ,p_time_access_calc_rule2        => p_time_access_calc_rule2
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_eligy_criteria'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_eligy_criteria
    --
  end;
  --

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_eligy_criteria_id     := l_eligy_criteria_id;
  p_object_version_number := l_object_version_number;
  --

  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_eligy_criteria;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_eligy_criteria_id      := null;
    p_object_version_number  := null;

    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_eligy_criteria;
    p_eligy_criteria_id      := null;
    p_object_version_number  := null;
    raise;
    --
end create_eligy_criteria;
-- ----------------------------------------------------------------------------
-- |------------------------< update_eligy_criteria >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_eligy_criteria
  (
     p_validate                        in boolean    default false
     ,p_eligy_criteria_id              in  number
     ,p_name                           in  varchar2  default hr_api.g_varchar2
     ,p_short_code                     in  varchar2  default hr_api.g_varchar2
     ,p_description                    in  varchar2  default hr_api.g_varchar2
     ,p_criteria_type		       in  varchar2  default hr_api.g_varchar2
     ,p_crit_col1_val_type_cd	       in  varchar2  default hr_api.g_varchar2
     ,p_crit_col1_datatype	       in  varchar2  default hr_api.g_varchar2
     ,p_col1_lookup_type	       in  varchar2  default hr_api.g_varchar2
     ,p_col1_value_set_id              in  number    default hr_api.g_number
     ,p_access_table_name1             in  varchar2  default hr_api.g_varchar2
     ,p_access_column_name1	       in  varchar2  default hr_api.g_varchar2
     ,p_time_entry_access_tab_nam1     in  varchar2  default hr_api.g_varchar2
     ,p_time_entry_access_col_nam1     in  varchar2  default hr_api.g_varchar2
     ,p_crit_col2_val_type_cd	       in  varchar2  default hr_api.g_varchar2
     ,p_crit_col2_datatype	       in  varchar2  default hr_api.g_varchar2
     ,p_col2_lookup_type	       in  varchar2  default hr_api.g_varchar2
     ,p_col2_value_set_id              in  number    default hr_api.g_number
     ,p_access_table_name2	       in  varchar2  default hr_api.g_varchar2
     ,p_access_column_name2	       in  varchar2  default hr_api.g_varchar2
     ,p_time_entry_access_tab_nam2     in  varchar2  default hr_api.g_varchar2
     ,p_time_entry_access_col_nam2     in  varchar2  default hr_api.g_varchar2
     ,p_access_calc_rule	       in  number    default hr_api.g_number
     ,p_allow_range_validation_flg     in  varchar2  default hr_api.g_varchar2
     ,p_user_defined_flag              in  varchar2  default hr_api.g_varchar2
     ,p_business_group_id 	       in  number    default hr_api.g_number
     ,p_legislation_code 	       in  varchar2  default hr_api.g_varchar2
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
     ,p_effective_date                 in  date
     ,p_allow_range_validation_flag2   in  varchar2  default hr_api.g_varchar2
     ,p_access_calc_rule2              in  number    default hr_api.g_number
     ,p_time_access_calc_rule1         in  number    default hr_api.g_number
     ,p_time_access_calc_rule2         in  number    default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_eligy_criteria_id       ben_eligy_criteria.eligy_criteria_id%TYPE;
  l_proc varchar2(72)      := g_package||'update_eligy_criteria';
  l_object_version_number  ben_eligy_criteria.object_version_number%TYPE;
  --
begin

----hr_utility.trace_on(null,'TRACE-file');
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_eligy_criteria;
  --

  --
  -- Process Logic
  --
  l_eligy_criteria_id     := p_eligy_criteria_id;
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_eligy_criteria
    --
    ben_eligy_criteria_bk2.update_eligy_criteria_b
      (
            p_eligy_criteria_id             => l_eligy_criteria_id
           ,p_name                          => p_name
           ,p_short_code                    => p_short_code
           ,p_description                   => p_description
           ,p_criteria_type		    => p_criteria_type
           ,p_crit_col1_val_type_cd	    => p_crit_col1_val_type_cd
           ,p_crit_col1_datatype	    => p_crit_col1_datatype
           ,p_col1_lookup_type		    => p_col1_lookup_type
           ,p_col1_value_set_id             => p_col1_value_set_id
           ,p_access_table_name1            => p_access_table_name1
           ,p_access_column_name1	    => p_access_column_name1
           ,p_time_entry_access_tab_nam1    => p_time_entry_access_tab_nam1
           ,p_time_entry_access_col_nam1    => p_time_entry_access_col_nam1
           ,p_crit_col2_val_type_cd	    => p_crit_col2_val_type_cd
           ,p_crit_col2_datatype	    => p_crit_col2_datatype
           ,p_col2_lookup_type		    => p_col2_lookup_type
           ,p_col2_value_set_id             => p_col2_value_set_id
           ,p_access_table_name2	    => p_access_table_name2
           ,p_access_column_name2	    => p_access_column_name2
           ,p_time_entry_access_tab_nam2    => p_time_entry_access_tab_nam2
           ,p_time_entry_access_col_nam2    => p_time_entry_access_col_nam2
           ,p_access_calc_rule		    => p_access_calc_rule
           ,p_allow_range_validation_flg    => p_allow_range_validation_flg
           ,p_user_defined_flag             => p_user_defined_flag
           ,p_business_group_id 	    => p_business_group_id
           ,p_legislation_code 	            => p_legislation_code
           ,p_egl_attribute_category        => p_egl_attribute_category
           ,p_egl_attribute1                => p_egl_attribute1
           ,p_egl_attribute2                => p_egl_attribute2
           ,p_egl_attribute3                => p_egl_attribute3
           ,p_egl_attribute4                => p_egl_attribute4
           ,p_egl_attribute5                => p_egl_attribute5
           ,p_egl_attribute6                => p_egl_attribute6
           ,p_egl_attribute7                => p_egl_attribute7
           ,p_egl_attribute8                => p_egl_attribute8
           ,p_egl_attribute9                => p_egl_attribute9
           ,p_egl_attribute10               => p_egl_attribute10
           ,p_egl_attribute11               => p_egl_attribute11
           ,p_egl_attribute12               => p_egl_attribute12
           ,p_egl_attribute13               => p_egl_attribute13
           ,p_egl_attribute14               => p_egl_attribute14
           ,p_egl_attribute15               => p_egl_attribute15
           ,p_egl_attribute16               => p_egl_attribute16
           ,p_egl_attribute17               => p_egl_attribute17
           ,p_egl_attribute18               => p_egl_attribute18
           ,p_egl_attribute19               => p_egl_attribute19
           ,p_egl_attribute20               => p_egl_attribute20
           ,p_egl_attribute21               => p_egl_attribute21
           ,p_egl_attribute22               => p_egl_attribute22
           ,p_egl_attribute23               => p_egl_attribute23
           ,p_egl_attribute24               => p_egl_attribute24
           ,p_egl_attribute25               => p_egl_attribute25
           ,p_egl_attribute26               => p_egl_attribute26
           ,p_egl_attribute27               => p_egl_attribute27
           ,p_egl_attribute28               => p_egl_attribute28
           ,p_egl_attribute29               => p_egl_attribute29
           ,p_egl_attribute30               => p_egl_attribute30
          ,p_object_version_number          => l_object_version_number
          ,p_effective_date                 => trunc(p_effective_date)
           ,p_allow_range_validation_flag2  =>  p_allow_range_validation_flag2
           ,p_access_calc_rule2             =>  p_access_calc_rule2
           ,p_time_access_calc_rule1        =>  p_time_access_calc_rule1
           ,p_time_access_calc_rule2        =>  p_time_access_calc_rule2
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_eligy_criteria'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_eligy_criteria
    --
  end;
  --
  ben_egl_upd.upd
    (
          p_eligy_criteria_id             => l_eligy_criteria_id
         ,p_name                          => p_name
         ,p_short_code                    => p_short_code
         ,p_description                   => p_description
         ,p_criteria_type		  => p_criteria_type
         ,p_crit_col1_val_type_cd	  => p_crit_col1_val_type_cd
         ,p_crit_col1_datatype	          => p_crit_col1_datatype
         ,p_col1_lookup_type		  => p_col1_lookup_type
         ,p_col1_value_set_id             => p_col1_value_set_id
         ,p_access_table_name1            => p_access_table_name1
         ,p_access_column_name1	          => p_access_column_name1
         ,p_time_entry_access_tab_nam1    => p_time_entry_access_tab_nam1
         ,p_time_entry_access_col_nam1    => p_time_entry_access_col_nam1
         ,p_crit_col2_val_type_cd	  => p_crit_col2_val_type_cd
         ,p_crit_col2_datatype	          => p_crit_col2_datatype
         ,p_col2_lookup_type		  => p_col2_lookup_type
         ,p_col2_value_set_id             => p_col2_value_set_id
         ,p_access_table_name2	          => p_access_table_name2
         ,p_access_column_name2	          => p_access_column_name2
         ,p_time_entry_access_tab_nam2    => p_time_entry_access_tab_nam2
         ,p_time_entry_access_col_nam2    => p_time_entry_access_col_nam2
         ,p_access_calc_rule		  => p_access_calc_rule
         ,p_allow_range_validation_flg    => p_allow_range_validation_flg
         ,p_user_defined_flag             => p_user_defined_flag
         ,p_business_group_id 	          => p_business_group_id
         ,p_legislation_code 	          => p_legislation_code
         ,p_egl_attribute_category        => p_egl_attribute_category
         ,p_egl_attribute1                => p_egl_attribute1
         ,p_egl_attribute2                => p_egl_attribute2
         ,p_egl_attribute3                => p_egl_attribute3
         ,p_egl_attribute4                => p_egl_attribute4
         ,p_egl_attribute5                => p_egl_attribute5
         ,p_egl_attribute6                => p_egl_attribute6
         ,p_egl_attribute7                => p_egl_attribute7
         ,p_egl_attribute8                => p_egl_attribute8
         ,p_egl_attribute9                => p_egl_attribute9
         ,p_egl_attribute10               => p_egl_attribute10
         ,p_egl_attribute11               => p_egl_attribute11
         ,p_egl_attribute12               => p_egl_attribute12
         ,p_egl_attribute13               => p_egl_attribute13
         ,p_egl_attribute14               => p_egl_attribute14
         ,p_egl_attribute15               => p_egl_attribute15
         ,p_egl_attribute16               => p_egl_attribute16
         ,p_egl_attribute17               => p_egl_attribute17
         ,p_egl_attribute18               => p_egl_attribute18
         ,p_egl_attribute19               => p_egl_attribute19
         ,p_egl_attribute20               => p_egl_attribute20
         ,p_egl_attribute21               => p_egl_attribute21
         ,p_egl_attribute22               => p_egl_attribute22
         ,p_egl_attribute23               => p_egl_attribute23
         ,p_egl_attribute24               => p_egl_attribute24
         ,p_egl_attribute25               => p_egl_attribute25
         ,p_egl_attribute26               => p_egl_attribute26
         ,p_egl_attribute27               => p_egl_attribute27
         ,p_egl_attribute28               => p_egl_attribute28
         ,p_egl_attribute29               => p_egl_attribute29
         ,p_egl_attribute30               => p_egl_attribute30
         ,p_object_version_number         => l_object_version_number
	 ,p_effective_date                => trunc(p_effective_date)
         ,p_allow_range_validation_flag2  =>  p_allow_range_validation_flag2
         ,p_access_calc_rule2             =>  p_access_calc_rule2
         ,p_time_access_calc_rule1        =>  p_time_access_calc_rule1
         ,p_time_access_calc_rule2        =>  p_time_access_calc_rule2
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_eligy_criteria
    --
    ben_eligy_criteria_bk2.update_eligy_criteria_a
      (
            p_eligy_criteria_id             => l_eligy_criteria_id
           ,p_name                          => p_name
           ,p_short_code                    => p_short_code
           ,p_description                   => p_description
           ,p_criteria_type		    => p_criteria_type
           ,p_crit_col1_val_type_cd	    => p_crit_col1_val_type_cd
           ,p_crit_col1_datatype	    => p_crit_col1_datatype
           ,p_col1_lookup_type		    => p_col1_lookup_type
           ,p_col1_value_set_id             => p_col1_value_set_id
           ,p_access_table_name1            => p_access_table_name1
           ,p_access_column_name1	    => p_access_column_name1
           ,p_time_entry_access_tab_nam1    => p_time_entry_access_tab_nam1
           ,p_time_entry_access_col_nam1    => p_time_entry_access_col_nam1
           ,p_crit_col2_val_type_cd	    => p_crit_col2_val_type_cd
           ,p_crit_col2_datatype	    => p_crit_col2_datatype
           ,p_col2_lookup_type		    => p_col2_lookup_type
           ,p_col2_value_set_id             => p_col2_value_set_id
           ,p_access_table_name2	    => p_access_table_name2
           ,p_access_column_name2	    => p_access_column_name2
           ,p_time_entry_access_tab_nam2    => p_time_entry_access_tab_nam2
           ,p_time_entry_access_col_nam2    => p_time_entry_access_col_nam2
           ,p_access_calc_rule		    => p_access_calc_rule
           ,p_allow_range_validation_flg    => p_allow_range_validation_flg
           ,p_user_defined_flag             => p_user_defined_flag
           ,p_business_group_id 	    => p_business_group_id
           ,p_legislation_code 	            => p_legislation_code
           ,p_egl_attribute_category        => p_egl_attribute_category
           ,p_egl_attribute1                => p_egl_attribute1
           ,p_egl_attribute2                => p_egl_attribute2
           ,p_egl_attribute3                => p_egl_attribute3
           ,p_egl_attribute4                => p_egl_attribute4
           ,p_egl_attribute5                => p_egl_attribute5
           ,p_egl_attribute6                => p_egl_attribute6
           ,p_egl_attribute7                => p_egl_attribute7
           ,p_egl_attribute8                => p_egl_attribute8
           ,p_egl_attribute9                => p_egl_attribute9
           ,p_egl_attribute10               => p_egl_attribute10
           ,p_egl_attribute11               => p_egl_attribute11
           ,p_egl_attribute12               => p_egl_attribute12
           ,p_egl_attribute13               => p_egl_attribute13
           ,p_egl_attribute14               => p_egl_attribute14
           ,p_egl_attribute15               => p_egl_attribute15
           ,p_egl_attribute16               => p_egl_attribute16
           ,p_egl_attribute17               => p_egl_attribute17
           ,p_egl_attribute18               => p_egl_attribute18
           ,p_egl_attribute19               => p_egl_attribute19
           ,p_egl_attribute20               => p_egl_attribute20
           ,p_egl_attribute21               => p_egl_attribute21
           ,p_egl_attribute22               => p_egl_attribute22
           ,p_egl_attribute23               => p_egl_attribute23
           ,p_egl_attribute24               => p_egl_attribute24
           ,p_egl_attribute25               => p_egl_attribute25
           ,p_egl_attribute26               => p_egl_attribute26
           ,p_egl_attribute27               => p_egl_attribute27
           ,p_egl_attribute28               => p_egl_attribute28
           ,p_egl_attribute29               => p_egl_attribute29
           ,p_egl_attribute30               => p_egl_attribute30
           ,p_object_version_number         => l_object_version_number
	   ,p_effective_date                => trunc(p_effective_date)
           ,p_allow_range_validation_flag2  =>  p_allow_range_validation_flag2
           ,p_access_calc_rule2             =>  p_access_calc_rule2
           ,p_time_access_calc_rule1        =>  p_time_access_calc_rule1
           ,p_time_access_calc_rule2        =>  p_time_access_calc_rule2
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_eligy_criteria'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_eligy_criteria
    --
  end;
  --

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --

  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_eligy_criteria;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_eligy_criteria;
    raise;
    --
end update_eligy_criteria;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_eligy_criteria >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_eligy_criteria
  (p_validate                       in  boolean  default false
  ,p_eligy_criteria_id              in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_eligy_criteria';
  l_object_version_number ben_eligy_criteria.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_eligy_criteria;
  --

  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_eligy_criteria
    --
    ben_eligy_criteria_bk3.delete_eligy_criteria_b
      (
       p_eligy_criteria_id              =>  p_eligy_criteria_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_eligy_criteria'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_eligy_criteria
    --
  end;
  --
  ben_egl_del.del
    (
     p_eligy_criteria_id             => p_eligy_criteria_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_eligy_criteria
    --
    ben_eligy_criteria_bk3.delete_eligy_criteria_a
      (
       p_eligy_criteria_id              =>  p_eligy_criteria_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_eligy_criteria'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_eligy_criteria
    --
  end;
  --

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --

  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_eligy_criteria;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_eligy_criteria;
    raise;
    --
end delete_eligy_criteria;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_eligy_criteria_id              in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_egl_shd.lck
    (
      p_eligy_criteria_id          => p_eligy_criteria_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
end lck;
--
end ben_eligy_criteria_api;

/
