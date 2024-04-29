--------------------------------------------------------
--  DDL for Package Body BEN_ELIGY_CRIT_VALUES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIGY_CRIT_VALUES_API" as
/* $Header: beecvapi.pkb 120.1 2005/07/29 09:50:56 rbingi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_eligy_crit_values_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_eligy_crit_values >----------------------|
-- ----------------------------------------------------------------------------
--

procedure create_eligy_crit_values
(
   p_validate                     In  Boolean      default false
  ,p_eligy_crit_values_id         Out nocopy Number
  ,p_eligy_prfl_id                In  Number       default NULL
  ,p_eligy_criteria_id            In  Number       default NULL
  ,p_effective_start_date         Out nocopy Date
  ,p_effective_end_date           Out nocopy Date
  ,p_ordr_num                     In  Number       default NULL
  ,p_number_value1                In  Number       default NULL
  ,p_number_value2                In  Number       default NULL
  ,p_char_value1                  In  Varchar2     default NULL
  ,p_char_value2                  In  Varchar2     default NULL
  ,p_date_value1                  In  Date         default NULL
  ,p_date_value2                  In  Date         default NULL
  ,p_excld_flag                   In  Varchar2     default 'N'
  ,p_business_group_id            In  Number       default NULL
  ,p_ecv_attribute_category       In  Varchar2     default NULL
  ,p_ecv_attribute1               In  Varchar2     default NULL
  ,p_ecv_attribute2               In  Varchar2     default NULL
  ,p_ecv_attribute3               In  Varchar2     default NULL
  ,p_ecv_attribute4               In  Varchar2     default NULL
  ,p_ecv_attribute5               In  Varchar2     default NULL
  ,p_ecv_attribute6               In  Varchar2     default NULL
  ,p_ecv_attribute7               In  Varchar2     default NULL
  ,p_ecv_attribute8               In  Varchar2     default NULL
  ,p_ecv_attribute9               In  Varchar2     default NULL
  ,p_ecv_attribute10              In  Varchar2     default NULL
  ,p_ecv_attribute11              In  Varchar2     default NULL
  ,p_ecv_attribute12              In  Varchar2     default NULL
  ,p_ecv_attribute13              In  Varchar2     default NULL
  ,p_ecv_attribute14              In  Varchar2     default NULL
  ,p_ecv_attribute15              In  Varchar2     default NULL
  ,p_ecv_attribute16              In  Varchar2     default NULL
  ,p_ecv_attribute17              In  Varchar2     default NULL
  ,p_ecv_attribute18              In  Varchar2     default NULL
  ,p_ecv_attribute19              In  Varchar2     default NULL
  ,p_ecv_attribute20              In  Varchar2     default NULL
  ,p_ecv_attribute21              In  Varchar2     default NULL
  ,p_ecv_attribute22              In  Varchar2     default NULL
  ,p_ecv_attribute23              In  Varchar2     default NULL
  ,p_ecv_attribute24              In  Varchar2     default NULL
  ,p_ecv_attribute25              In  Varchar2     default NULL
  ,p_ecv_attribute26              In  Varchar2     default NULL
  ,p_ecv_attribute27              In  Varchar2     default NULL
  ,p_ecv_attribute28              In  Varchar2     default NULL
  ,p_ecv_attribute29              In  Varchar2     default NULL
  ,p_ecv_attribute30              In  Varchar2     default NULL
  ,p_object_version_number        Out nocopy Number
  ,p_effective_date               In  Date
  ,p_criteria_score               In  Number       default NULL
  ,p_criteria_weight              In  Number       default NULL
  ,p_char_value3                  In  Varchar2     default NULL
  ,p_char_value4                  In  Varchar2	   default NULL
  ,p_number_value3                In  Number  	   default NULL
  ,p_number_value4                In  Number  	   default NULL
  ,p_date_value3                  In  Date    	   default NULL
  ,p_date_value4                  In  Date    	   default NULL
 ) is
 --
 -- Declare cursors and local variables
 --
 l_eligy_crit_values_id ben_eligy_crit_values_f.eligy_crit_values_id%TYPE;
 l_effective_start_date ben_eligy_crit_values_f.effective_start_date%TYPE;
 l_effective_end_date ben_eligy_crit_values_f.effective_end_date%TYPE;
 l_proc varchar2(72) := g_package||'create_eligy_crit_values';
 l_object_version_number ben_eligy_crit_values_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_eligy_crit_values;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_eligy_crit_values
    --

    ben_eligy_crit_values_bk1.create_eligy_crit_values_b
      (
       p_eligy_prfl_id               	=>   p_eligy_prfl_id,
       p_eligy_criteria_id           	=>   p_eligy_criteria_id,
       p_ordr_num                       =>   p_ordr_num,
       p_number_value1               	=>   p_number_value1,
       p_number_value2               	=>   p_number_value2,
       p_char_value1                 	=>   p_char_value1,
       p_char_value2                 	=>   p_char_value2,
       p_date_value1                 	=>   p_date_value1,
       p_date_value2                 	=>   p_date_value2,
       p_excld_flag                     =>   p_excld_flag,
       p_business_group_id           	=>   p_business_group_id,
       p_ecv_attribute_category      	=>   p_ecv_attribute_category,
       p_ecv_attribute1              	=>   p_ecv_attribute1,
       p_ecv_attribute2              	=>   p_ecv_attribute2,
       p_ecv_attribute3              	=>   p_ecv_attribute3,
       p_ecv_attribute4              	=>   p_ecv_attribute4,
       p_ecv_attribute5              	=>   p_ecv_attribute5,
       p_ecv_attribute6              	=>   p_ecv_attribute6,
       p_ecv_attribute7              	=>   p_ecv_attribute7,
       p_ecv_attribute8              	=>   p_ecv_attribute8,
       p_ecv_attribute9              	=>   p_ecv_attribute9,
       p_ecv_attribute10             	=>   p_ecv_attribute10,
       p_ecv_attribute11             	=>   p_ecv_attribute11,
       p_ecv_attribute12             	=>   p_ecv_attribute12,
       p_ecv_attribute13             	=>   p_ecv_attribute13,
       p_ecv_attribute14             	=>   p_ecv_attribute14,
       p_ecv_attribute15             	=>   p_ecv_attribute15,
       p_ecv_attribute16             	=>   p_ecv_attribute16,
       p_ecv_attribute17             	=>   p_ecv_attribute17,
       p_ecv_attribute18             	=>   p_ecv_attribute18,
       p_ecv_attribute19             	=>   p_ecv_attribute19,
       p_ecv_attribute20             	=>   p_ecv_attribute20,
       p_ecv_attribute21             	=>   p_ecv_attribute21,
       p_ecv_attribute22             	=>   p_ecv_attribute22,
       p_ecv_attribute23             	=>   p_ecv_attribute23,
       p_ecv_attribute24             	=>   p_ecv_attribute24,
       p_ecv_attribute25             	=>   p_ecv_attribute25,
       p_ecv_attribute26             	=>   p_ecv_attribute26,
       p_ecv_attribute27             	=>   p_ecv_attribute27,
       p_ecv_attribute28             	=>   p_ecv_attribute28,
       p_ecv_attribute29             	=>   p_ecv_attribute29,
       p_ecv_attribute30             	=>   p_ecv_attribute30,
       p_effective_date              	=>   trunc(p_effective_date),
       p_criteria_score                 =>   p_criteria_score,
       p_criteria_weight                =>   p_criteria_weight,
       p_char_value3                    =>   p_char_value3,
       p_char_value4                  	=>   p_char_value4,
       p_number_value3                	=>   p_number_value3,
       p_number_value4                	=>   p_number_value4,
       p_date_value3                  	=>   p_date_value3,
       p_date_value4                  	=>   p_date_value4
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_eligy_crit_values'
         ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_eligy_crit_values
    --
  end;
  --
  ben_ecv_ins.ins
       (
       p_eligy_crit_values_id        	=>   l_eligy_crit_values_id,
       p_eligy_prfl_id               	=>   p_eligy_prfl_id,
       p_eligy_criteria_id           	=>   p_eligy_criteria_id,
       p_effective_start_date        	=>   l_effective_start_date,
       p_effective_end_date          	=>   l_effective_end_date,
       p_ordr_num                       =>   p_ordr_num,
       p_number_value1               	=>   p_number_value1,
       p_number_value2               	=>   p_number_value2,
       p_char_value1                 	=>   p_char_value1,
       p_char_value2                 	=>   p_char_value2,
       p_date_value1                 	=>   p_date_value1,
       p_date_value2                 	=>   p_date_value2,
       p_excld_flag                     =>   p_excld_flag,
       p_business_group_id           	=>   p_business_group_id,
       p_ecv_attribute_category      	=>   p_ecv_attribute_category,
       p_ecv_attribute1              	=>   p_ecv_attribute1,
       p_ecv_attribute2              	=>   p_ecv_attribute2,
       p_ecv_attribute3              	=>   p_ecv_attribute3,
       p_ecv_attribute4              	=>   p_ecv_attribute4,
       p_ecv_attribute5              	=>   p_ecv_attribute5,
       p_ecv_attribute6              	=>   p_ecv_attribute6,
       p_ecv_attribute7              	=>   p_ecv_attribute7,
       p_ecv_attribute8              	=>   p_ecv_attribute8,
       p_ecv_attribute9              	=>   p_ecv_attribute9,
       p_ecv_attribute10             	=>   p_ecv_attribute10,
       p_ecv_attribute11             	=>   p_ecv_attribute11,
       p_ecv_attribute12             	=>   p_ecv_attribute12,
       p_ecv_attribute13             	=>   p_ecv_attribute13,
       p_ecv_attribute14             	=>   p_ecv_attribute14,
       p_ecv_attribute15             	=>   p_ecv_attribute15,
       p_ecv_attribute16             	=>   p_ecv_attribute16,
       p_ecv_attribute17             	=>   p_ecv_attribute17,
       p_ecv_attribute18             	=>   p_ecv_attribute18,
       p_ecv_attribute19             	=>   p_ecv_attribute19,
       p_ecv_attribute20             	=>   p_ecv_attribute20,
       p_ecv_attribute21             	=>   p_ecv_attribute21,
       p_ecv_attribute22             	=>   p_ecv_attribute22,
       p_ecv_attribute23             	=>   p_ecv_attribute23,
       p_ecv_attribute24             	=>   p_ecv_attribute24,
       p_ecv_attribute25             	=>   p_ecv_attribute25,
       p_ecv_attribute26             	=>   p_ecv_attribute26,
       p_ecv_attribute27             	=>   p_ecv_attribute27,
       p_ecv_attribute28             	=>   p_ecv_attribute28,
       p_ecv_attribute29             	=>   p_ecv_attribute29,
       p_ecv_attribute30             	=>   p_ecv_attribute30,
       p_object_version_number       	=>   l_object_version_number,
       p_effective_date              	=>   trunc(p_effective_date),
       p_criteria_score                 =>   p_criteria_score,
       p_criteria_weight                =>   p_criteria_weight,
       p_char_value3                    =>   p_char_value3,
       p_char_value4                  	=>   p_char_value4,
       p_number_value3                	=>   p_number_value3,
       p_number_value4                	=>   p_number_value4,
       p_date_value3                  	=>   p_date_value3,
       p_date_value4                  	=>   p_date_value4
       );

  begin

    --
    -- Start of API User Hook for the after hook of create_eligy_crit_values
    --

    ben_eligy_crit_values_bk1.create_eligy_crit_values_a
      (
       p_eligy_crit_values_id        	=>   l_eligy_crit_values_id,
       p_eligy_prfl_id               	=>   p_eligy_prfl_id,
       p_eligy_criteria_id           	=>   p_eligy_criteria_id,
       p_effective_start_date        	=>   l_effective_start_date,
       p_effective_end_date          	=>   l_effective_end_date,
       p_ordr_num                       =>   p_ordr_num,
       p_number_value1               	=>   p_number_value1,
       p_number_value2               	=>   p_number_value2,
       p_char_value1                 	=>   p_char_value1,
       p_char_value2                 	=>   p_char_value2,
       p_date_value1                 	=>   p_date_value1,
       p_date_value2                 	=>   p_date_value2,
       p_excld_flag                     =>   p_excld_flag,
       p_business_group_id           	=>   p_business_group_id,
       p_ecv_attribute_category      	=>   p_ecv_attribute_category,
       p_ecv_attribute1              	=>   p_ecv_attribute1,
       p_ecv_attribute2              	=>   p_ecv_attribute2,
       p_ecv_attribute3              	=>   p_ecv_attribute3,
       p_ecv_attribute4              	=>   p_ecv_attribute4,
       p_ecv_attribute5              	=>   p_ecv_attribute5,
       p_ecv_attribute6              	=>   p_ecv_attribute6,
       p_ecv_attribute7              	=>   p_ecv_attribute7,
       p_ecv_attribute8              	=>   p_ecv_attribute8,
       p_ecv_attribute9              	=>   p_ecv_attribute9,
       p_ecv_attribute10             	=>   p_ecv_attribute10,
       p_ecv_attribute11             	=>   p_ecv_attribute11,
       p_ecv_attribute12             	=>   p_ecv_attribute12,
       p_ecv_attribute13             	=>   p_ecv_attribute13,
       p_ecv_attribute14             	=>   p_ecv_attribute14,
       p_ecv_attribute15             	=>   p_ecv_attribute15,
       p_ecv_attribute16             	=>   p_ecv_attribute16,
       p_ecv_attribute17             	=>   p_ecv_attribute17,
       p_ecv_attribute18             	=>   p_ecv_attribute18,
       p_ecv_attribute19             	=>   p_ecv_attribute19,
       p_ecv_attribute20             	=>   p_ecv_attribute20,
       p_ecv_attribute21             	=>   p_ecv_attribute21,
       p_ecv_attribute22             	=>   p_ecv_attribute22,
       p_ecv_attribute23             	=>   p_ecv_attribute23,
       p_ecv_attribute24             	=>   p_ecv_attribute24,
       p_ecv_attribute25             	=>   p_ecv_attribute25,
       p_ecv_attribute26             	=>   p_ecv_attribute26,
       p_ecv_attribute27             	=>   p_ecv_attribute27,
       p_ecv_attribute28             	=>   p_ecv_attribute28,
       p_ecv_attribute29             	=>   p_ecv_attribute29,
       p_ecv_attribute30             	=>   p_ecv_attribute30,
       p_object_version_number       	=>   l_object_version_number,
       p_effective_date              	=>   trunc(p_effective_date),
       p_criteria_score                 =>   p_criteria_score,
       p_criteria_weight                =>   p_criteria_weight,
       p_char_value3                    =>   p_char_value3,
       p_char_value4                  	=>   p_char_value4,
       p_number_value3                	=>   p_number_value3,
       p_number_value4                	=>   p_number_value4,
       p_date_value3                  	=>   p_date_value3,
       p_date_value4                  	=>   p_date_value4
       );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_eligy_crit_values'
        ,p_hook_type   => 'AP'
        );

    --
    -- End of API User Hook for the after hook of create_eligy_crit_values
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_ELIGY_PRFL_F',
     p_base_table_column           => 'ELIGY_PRFL_ID',
     p_base_table_column_value     => p_eligy_prfl_id,
     p_base_table_reference_column => 'ELIG_CRIT_VALUES_FLAG',
     p_reference_table             => 'BEN_ELIGY_CRIT_VALUES_F',
     p_reference_table_column      => 'ELIGY_PRFL_ID');
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_eligy_crit_values_id := l_eligy_crit_values_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_eligy_crit_values;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_eligy_crit_values_id := NULL;
  p_effective_start_date := NULL;
  p_effective_end_date := NULL;
  p_object_version_number  := NULL;
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_eligy_crit_values;
    	-- Added the following code for NOCOPY Changes.
    	p_eligy_crit_values_id := NULL;
        p_effective_start_date := NULL;
        p_effective_end_date := NULL;
        p_object_version_number  := NULL;
       	-- Added the above code for NOCOPY Changes.
    raise;
    --
end create_eligy_crit_values;

-- ----------------------------------------------------------------------------
-- |------------------------< update_eligy_crit_values >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_eligy_crit_values
  (
   p_validate                     In  Boolean      default false
  ,p_eligy_crit_values_id         In  Number
  ,p_eligy_prfl_id                In  Number       default hr_api.g_number
  ,p_eligy_criteria_id            In  Number       default hr_api.g_number
  ,p_effective_start_date         Out nocopy Date
  ,p_effective_end_date           Out nocopy Date
  ,p_ordr_num                     In  Number       default hr_api.g_number
  ,p_number_value1                In  Number       default hr_api.g_number
  ,p_number_value2                In  Number       default hr_api.g_number
  ,p_char_value1                  In  Varchar2     default hr_api.g_varchar2
  ,p_char_value2                  In  Varchar2     default hr_api.g_varchar2
  ,p_date_value1                  In  Date         default hr_api.g_date
  ,p_date_value2                  In  Date         default hr_api.g_date
  ,p_excld_flag                   In  Varchar2     default hr_api.g_varchar2
  ,p_business_group_id            In  Number       default hr_api.g_number
  ,p_ecv_attribute_category       In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute1               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute2               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute3               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute4               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute5               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute6               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute7               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute8               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute9               In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute10              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute11              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute12              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute13              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute14              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute15              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute16              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute17              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute18              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute19              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute20              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute21              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute22              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute23              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute24              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute25              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute26              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute27              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute28              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute29              In  Varchar2     default hr_api.g_varchar2
  ,p_ecv_attribute30              In  Varchar2     default hr_api.g_varchar2
  ,p_object_version_number        In  Out nocopy Number
  ,p_effective_date               In  Date
  ,p_datetrack_mode               In  varchar2
  ,p_criteria_score               In  Number       default hr_api.g_number
  ,p_criteria_weight              In  Number       default hr_api.g_number
  ,p_char_value3                  In  Varchar2     default hr_api.g_varchar2
  ,p_char_value4                  In  Varchar2     default hr_api.g_varchar2
  ,p_number_value3                In  Number       default hr_api.g_number
  ,p_number_value4                In  Number       default hr_api.g_number
  ,p_date_value3                  In  Date         default hr_api.g_date
  ,p_date_value4                  In  Date         default hr_api.g_date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_eligy_crit_values';
  l_object_version_number ben_eligy_crit_values_f.object_version_number%TYPE;
  l_effective_start_date ben_eligy_crit_values_f.effective_start_date%TYPE;
  l_effective_end_date ben_eligy_crit_values_f.effective_end_date%TYPE;
  --
  begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_eligy_crit_values;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
   --
  begin
    --
    -- Start of API User Hook for the before hook of update_eligy_crit_values
    --
    ben_eligy_crit_values_bk2.update_eligy_crit_values_b
       (
       p_eligy_crit_values_id        	=>   p_eligy_crit_values_id,
       p_eligy_prfl_id               	=>   p_eligy_prfl_id,
       p_eligy_criteria_id           	=>   p_eligy_criteria_id,
       p_ordr_num                       =>   p_ordr_num,
       p_number_value1               	=>   p_number_value1,
       p_number_value2               	=>   p_number_value2,
       p_char_value1                 	=>   p_char_value1,
       p_char_value2                 	=>   p_char_value2,
       p_date_value1                 	=>   p_date_value1,
       p_date_value2                 	=>   p_date_value2,
       p_excld_flag                     =>   p_excld_flag,
       p_business_group_id           	=>   p_business_group_id,
       p_ecv_attribute_category      	=>   p_ecv_attribute_category,
       p_ecv_attribute1              	=>   p_ecv_attribute1,
       p_ecv_attribute2              	=>   p_ecv_attribute2,
       p_ecv_attribute3              	=>   p_ecv_attribute3,
       p_ecv_attribute4              	=>   p_ecv_attribute4,
       p_ecv_attribute5              	=>   p_ecv_attribute5,
       p_ecv_attribute6              	=>   p_ecv_attribute6,
       p_ecv_attribute7              	=>   p_ecv_attribute7,
       p_ecv_attribute8              	=>   p_ecv_attribute8,
       p_ecv_attribute9              	=>   p_ecv_attribute9,
       p_ecv_attribute10             	=>   p_ecv_attribute10,
       p_ecv_attribute11             	=>   p_ecv_attribute11,
       p_ecv_attribute12             	=>   p_ecv_attribute12,
       p_ecv_attribute13             	=>   p_ecv_attribute13,
       p_ecv_attribute14             	=>   p_ecv_attribute14,
       p_ecv_attribute15             	=>   p_ecv_attribute15,
       p_ecv_attribute16             	=>   p_ecv_attribute16,
       p_ecv_attribute17             	=>   p_ecv_attribute17,
       p_ecv_attribute18             	=>   p_ecv_attribute18,
       p_ecv_attribute19             	=>   p_ecv_attribute19,
       p_ecv_attribute20             	=>   p_ecv_attribute20,
       p_ecv_attribute21             	=>   p_ecv_attribute21,
       p_ecv_attribute22             	=>   p_ecv_attribute22,
       p_ecv_attribute23             	=>   p_ecv_attribute23,
       p_ecv_attribute24             	=>   p_ecv_attribute24,
       p_ecv_attribute25             	=>   p_ecv_attribute25,
       p_ecv_attribute26             	=>   p_ecv_attribute26,
       p_ecv_attribute27             	=>   p_ecv_attribute27,
       p_ecv_attribute28             	=>   p_ecv_attribute28,
       p_ecv_attribute29             	=>   p_ecv_attribute29,
       p_ecv_attribute30             	=>   p_ecv_attribute30,
       p_object_version_number       	=>   p_object_version_number,
       p_effective_date              	=>   trunc(p_effective_date),
       p_datetrack_mode                 =>   p_datetrack_mode,
       p_criteria_score                 =>   p_criteria_score,
       p_criteria_weight                =>   p_criteria_weight,
       p_char_value3                    =>   p_char_value3,
       p_char_value4                  	=>   p_char_value4,
       p_number_value3                	=>   p_number_value3,
       p_number_value4                	=>   p_number_value4,
       p_date_value3                  	=>   p_date_value3,
       p_date_value4                  	=>   p_date_value4
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_eligy_crit_values'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_eligy_crit_values
    --
  end;
  --
    ben_ecv_upd.upd
       (
       p_eligy_crit_values_id        	=>   p_eligy_crit_values_id,
       p_effective_start_date           =>   l_effective_start_date,
       p_effective_end_date             =>   l_effective_end_date,
       p_eligy_prfl_id               	=>   p_eligy_prfl_id,
       p_eligy_criteria_id           	=>   p_eligy_criteria_id,
       p_ordr_num                       =>   p_ordr_num,
       p_number_value1               	=>   p_number_value1,
       p_number_value2               	=>   p_number_value2,
       p_char_value1                 	=>   p_char_value1,
       p_char_value2                 	=>   p_char_value2,
       p_date_value1                 	=>   p_date_value1,
       p_date_value2                 	=>   p_date_value2,
       p_excld_flag                     =>   p_excld_flag,
       p_business_group_id           	=>   p_business_group_id,
       p_ecv_attribute_category      	=>   p_ecv_attribute_category,
       p_ecv_attribute1              	=>   p_ecv_attribute1,
       p_ecv_attribute2              	=>   p_ecv_attribute2,
       p_ecv_attribute3              	=>   p_ecv_attribute3,
       p_ecv_attribute4              	=>   p_ecv_attribute4,
       p_ecv_attribute5              	=>   p_ecv_attribute5,
       p_ecv_attribute6              	=>   p_ecv_attribute6,
       p_ecv_attribute7              	=>   p_ecv_attribute7,
       p_ecv_attribute8              	=>   p_ecv_attribute8,
       p_ecv_attribute9              	=>   p_ecv_attribute9,
       p_ecv_attribute10             	=>   p_ecv_attribute10,
       p_ecv_attribute11             	=>   p_ecv_attribute11,
       p_ecv_attribute12             	=>   p_ecv_attribute12,
       p_ecv_attribute13             	=>   p_ecv_attribute13,
       p_ecv_attribute14             	=>   p_ecv_attribute14,
       p_ecv_attribute15             	=>   p_ecv_attribute15,
       p_ecv_attribute16             	=>   p_ecv_attribute16,
       p_ecv_attribute17             	=>   p_ecv_attribute17,
       p_ecv_attribute18             	=>   p_ecv_attribute18,
       p_ecv_attribute19             	=>   p_ecv_attribute19,
       p_ecv_attribute20             	=>   p_ecv_attribute20,
       p_ecv_attribute21             	=>   p_ecv_attribute21,
       p_ecv_attribute22             	=>   p_ecv_attribute22,
       p_ecv_attribute23             	=>   p_ecv_attribute23,
       p_ecv_attribute24             	=>   p_ecv_attribute24,
       p_ecv_attribute25             	=>   p_ecv_attribute25,
       p_ecv_attribute26             	=>   p_ecv_attribute26,
       p_ecv_attribute27             	=>   p_ecv_attribute27,
       p_ecv_attribute28             	=>   p_ecv_attribute28,
       p_ecv_attribute29             	=>   p_ecv_attribute29,
       p_ecv_attribute30             	=>   p_ecv_attribute30,
       p_object_version_number       	=>   l_object_version_number,
       p_effective_date              	=>   trunc(p_effective_date),
       p_datetrack_mode                 =>   p_datetrack_mode,
       p_criteria_score                 =>   p_criteria_score,
       p_criteria_weight                =>   p_criteria_weight,
       p_char_value3                    =>   p_char_value3,
       p_char_value4                  	=>   p_char_value4,
       p_number_value3                	=>   p_number_value3,
       p_number_value4                	=>   p_number_value4,
       p_date_value3                  	=>   p_date_value3,
       p_date_value4                  	=>   p_date_value4
       );
  --
  begin
    NULL;
    --
    -- Start of API User Hook for the after hook of update_eligy_crit_values
    --

    ben_eligy_crit_values_bk2.update_eligy_crit_values_a
      (
       p_eligy_crit_values_id       	=>   p_eligy_crit_values_id,
       p_eligy_prfl_id              	=>   p_eligy_prfl_id,
       p_eligy_criteria_id           	=>   p_eligy_criteria_id,
       p_effective_start_date           =>   p_effective_start_date,
       p_effective_end_date             =>   p_effective_end_date,
       p_ordr_num                       =>   p_ordr_num,
       p_number_value1               	=>   p_number_value1,
       p_number_value2               	=>   p_number_value2,
       p_char_value1                 	=>   p_char_value1,
       p_char_value2                 	=>   p_char_value2,
       p_date_value1                 	=>   p_date_value1,
       p_date_value2                 	=>   p_date_value2,
       p_excld_flag                     =>   p_excld_flag,
       p_business_group_id           	=>   p_business_group_id,
       p_ecv_attribute_category      	=>   p_ecv_attribute_category,
       p_ecv_attribute1              	=>   p_ecv_attribute1,
       p_ecv_attribute2              	=>   p_ecv_attribute2,
       p_ecv_attribute3              	=>   p_ecv_attribute3,
       p_ecv_attribute4              	=>   p_ecv_attribute4,
       p_ecv_attribute5              	=>   p_ecv_attribute5,
       p_ecv_attribute6              	=>   p_ecv_attribute6,
       p_ecv_attribute7              	=>   p_ecv_attribute7,
       p_ecv_attribute8              	=>   p_ecv_attribute8,
       p_ecv_attribute9              	=>   p_ecv_attribute9,
       p_ecv_attribute10             	=>   p_ecv_attribute10,
       p_ecv_attribute11             	=>   p_ecv_attribute11,
       p_ecv_attribute12             	=>   p_ecv_attribute12,
       p_ecv_attribute13             	=>   p_ecv_attribute13,
       p_ecv_attribute14             	=>   p_ecv_attribute14,
       p_ecv_attribute15             	=>   p_ecv_attribute15,
       p_ecv_attribute16             	=>   p_ecv_attribute16,
       p_ecv_attribute17             	=>   p_ecv_attribute17,
       p_ecv_attribute18             	=>   p_ecv_attribute18,
       p_ecv_attribute19             	=>   p_ecv_attribute19,
       p_ecv_attribute20             	=>   p_ecv_attribute20,
       p_ecv_attribute21             	=>   p_ecv_attribute21,
       p_ecv_attribute22             	=>   p_ecv_attribute22,
       p_ecv_attribute23             	=>   p_ecv_attribute23,
       p_ecv_attribute24             	=>   p_ecv_attribute24,
       p_ecv_attribute25             	=>   p_ecv_attribute25,
       p_ecv_attribute26             	=>   p_ecv_attribute26,
       p_ecv_attribute27             	=>   p_ecv_attribute27,
       p_ecv_attribute28             	=>   p_ecv_attribute28,
       p_ecv_attribute29             	=>   p_ecv_attribute29,
       p_ecv_attribute30             	=>   p_ecv_attribute30,
       p_object_version_number       	=>   l_object_version_number,
       p_effective_date              	=>   trunc(p_effective_date),
       p_datetrack_mode                 =>   p_datetrack_mode,
       p_criteria_score                 =>   p_criteria_score,
       p_criteria_weight                =>   p_criteria_weight,
       p_char_value3                    =>   p_char_value3,
       p_char_value4                  	=>   p_char_value4,
       p_number_value3                	=>   p_number_value3,
       p_number_value4                	=>   p_number_value4,
       p_date_value3                  	=>   p_date_value3,
       p_date_value4                  	=>   p_date_value4
       );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_eligy_crit_values'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_eligy_crit_values
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
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
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_eligy_crit_values;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_eligy_crit_values;
      -- Added the following code for NOCOPY Changes.
	  p_object_version_number := l_object_version_number;
	  p_effective_start_date := NULL;
      p_effective_end_date := NULL;
  	  -- Added the above code for NOCOPY Changes.
    raise;
    --
end update_eligy_crit_values;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_eligy_crit_values >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_eligy_crit_values
(
   p_validate                       In Boolean        default false
  ,p_eligy_crit_values_id           In Number
  ,p_effective_start_date           Out nocopy date
  ,p_effective_end_date             Out nocopy date
  ,p_object_version_number          In Out nocopy number
  ,p_effective_date                 In Date
  ,p_datetrack_mode                 In Varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_eligy_crit_values';
  l_object_version_number ben_eligy_crit_values_f.object_version_number%TYPE;
  l_effective_start_date ben_eligy_crit_values_f.effective_start_date%TYPE;
  l_effective_end_date ben_eligy_crit_values_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_eligy_crit_values;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_eligy_crit_values
    --
    ben_eligy_crit_values_bk3.delete_eligy_crit_values_b
       (
        p_eligy_crit_values_id              =>  p_eligy_crit_values_id
       ,p_object_version_number             =>  p_object_version_number
       ,p_effective_date                    =>  trunc(p_effective_date)
       ,p_datetrack_mode                    =>  p_datetrack_mode
       );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_eligy_crit_values'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_eligy_crit_values
    --
  end;
  --
  ben_ecv_del.del
  (
     p_eligy_crit_values_id          => p_eligy_crit_values_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_eligy_crit_values
    --
    ben_eligy_crit_values_bk3.delete_eligy_crit_values_a
      (
       p_eligy_crit_values_id           =>  p_eligy_crit_values_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_datetrack_mode                 => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_eligy_crit_values'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_eligy_crit_values
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_ELIGY_PRFL_F',
     p_base_table_column           => 'ELIGY_PRFL_ID',
     p_base_table_column_value     => ben_ecv_shd.g_old_rec.eligy_prfl_id,
     p_base_table_reference_column => 'ELIG_CRIT_VALUES_FLAG',
     p_reference_table             => 'BEN_ELIGY_CRIT_VALUES_F',
     p_reference_table_column      => 'ELIGY_PRFL_ID');
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_eligy_crit_values;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := NULL;
    p_effective_end_date := NULL;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_eligy_crit_values;
      -- Added the following code for NOCOPY Changes.
	  p_object_version_number := l_object_version_number;
	  p_effective_start_date := NULL;
      p_effective_end_date := NULL;
  	  -- Added the above code for NOCOPY Changes.

    raise;
    --
end delete_eligy_crit_values;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_eligy_crit_values_id           In     Number
  ,p_object_version_number          In     Number
  ,p_effective_date                 In     Date
  ,p_datetrack_mode                 In     Varchar2
  ,p_validation_start_date          Out nocopy    Date
  ,p_validation_end_date            Out nocopy    Date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_ecv_shd.lck
    (
      p_eligy_crit_values_id       => p_eligy_crit_values_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_eligy_crit_values_api;

/
