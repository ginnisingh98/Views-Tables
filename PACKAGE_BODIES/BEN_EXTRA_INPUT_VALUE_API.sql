--------------------------------------------------------
--  DDL for Package Body BEN_EXTRA_INPUT_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXTRA_INPUT_VALUE_API" as
/* $Header: beeivapi.pkb 120.0 2005/05/28 02:16:14 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_extra_input_value_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_extra_input_value >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_extra_input_value
(
   p_validate                       in boolean    default false
  ,p_extra_input_value_id           out nocopy number
  ,p_acty_base_rt_id                in  number
  ,p_input_value_id                 in  number
  ,p_input_text                     in  varchar2  default null
  ,p_upd_when_ele_ended_cd          in  varchar2  default 'C'
  ,p_return_var_name                in  varchar2
  ,p_business_group_id              in  number
  ,p_eiv_attribute_category         in  varchar2  default null
  ,p_eiv_attribute1                 in  varchar2  default null
  ,p_eiv_attribute2                 in  varchar2  default null
  ,p_eiv_attribute3                 in  varchar2  default null
  ,p_eiv_attribute4                 in  varchar2  default null
  ,p_eiv_attribute5                 in  varchar2  default null
  ,p_eiv_attribute6                 in  varchar2  default null
  ,p_eiv_attribute7                 in  varchar2  default null
  ,p_eiv_attribute8                 in  varchar2  default null
  ,p_eiv_attribute9                 in  varchar2  default null
  ,p_eiv_attribute10                in  varchar2  default null
  ,p_eiv_attribute11                in  varchar2  default null
  ,p_eiv_attribute12                in  varchar2  default null
  ,p_eiv_attribute13                in  varchar2  default null
  ,p_eiv_attribute14                in  varchar2  default null
  ,p_eiv_attribute15                in  varchar2  default null
  ,p_eiv_attribute16                in  varchar2  default null
  ,p_eiv_attribute17                in  varchar2  default null
  ,p_eiv_attribute18                in  varchar2  default null
  ,p_eiv_attribute19                in  varchar2  default null
  ,p_eiv_attribute20                in  varchar2  default null
  ,p_eiv_attribute21                in  varchar2  default null
  ,p_eiv_attribute22                in  varchar2  default null
  ,p_eiv_attribute23                in  varchar2  default null
  ,p_eiv_attribute24                in  varchar2  default null
  ,p_eiv_attribute25                in  varchar2  default null
  ,p_eiv_attribute26                in  varchar2  default null
  ,p_eiv_attribute27                in  varchar2  default null
  ,p_eiv_attribute28                in  varchar2  default null
  ,p_eiv_attribute29                in  varchar2  default null
  ,p_eiv_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_extra_input_value_id ben_extra_input_values.extra_input_value_id%TYPE;
  l_proc varchar2(72) := g_package||'create_extra_input_value';
  l_object_version_number ben_extra_input_values.object_version_number%TYPE;
  --

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_extra_input_value;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_extra_input_value
    --
    ben_extra_input_value_bk1.create_extra_input_value_b
      (
       p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_input_value_id                 =>  p_input_value_id
      ,p_input_text                     =>  p_input_text
      ,p_upd_when_ele_ended_cd          =>  p_upd_when_ele_ended_cd
      ,p_return_var_name                =>  p_return_var_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_eiv_attribute_category         =>  p_eiv_attribute_category
      ,p_eiv_attribute1                 =>  p_eiv_attribute1
      ,p_eiv_attribute2                 =>  p_eiv_attribute2
      ,p_eiv_attribute3                 =>  p_eiv_attribute3
      ,p_eiv_attribute4                 =>  p_eiv_attribute4
      ,p_eiv_attribute5                 =>  p_eiv_attribute5
      ,p_eiv_attribute6                 =>  p_eiv_attribute6
      ,p_eiv_attribute7                 =>  p_eiv_attribute7
      ,p_eiv_attribute8                 =>  p_eiv_attribute8
      ,p_eiv_attribute9                 =>  p_eiv_attribute9
      ,p_eiv_attribute10                =>  p_eiv_attribute10
      ,p_eiv_attribute11                =>  p_eiv_attribute11
      ,p_eiv_attribute12                =>  p_eiv_attribute12
      ,p_eiv_attribute13                =>  p_eiv_attribute13
      ,p_eiv_attribute14                =>  p_eiv_attribute14
      ,p_eiv_attribute15                =>  p_eiv_attribute15
      ,p_eiv_attribute16                =>  p_eiv_attribute16
      ,p_eiv_attribute17                =>  p_eiv_attribute17
      ,p_eiv_attribute18                =>  p_eiv_attribute18
      ,p_eiv_attribute19                =>  p_eiv_attribute19
      ,p_eiv_attribute20                =>  p_eiv_attribute20
      ,p_eiv_attribute21                =>  p_eiv_attribute21
      ,p_eiv_attribute22                =>  p_eiv_attribute22
      ,p_eiv_attribute23                =>  p_eiv_attribute23
      ,p_eiv_attribute24                =>  p_eiv_attribute24
      ,p_eiv_attribute25                =>  p_eiv_attribute25
      ,p_eiv_attribute26                =>  p_eiv_attribute26
      ,p_eiv_attribute27                =>  p_eiv_attribute27
      ,p_eiv_attribute28                =>  p_eiv_attribute28
      ,p_eiv_attribute29                =>  p_eiv_attribute29
      ,p_eiv_attribute30                =>  p_eiv_attribute30
      ,p_effective_date                 =>  p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_extra_input_value'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_extra_input_value
    --
  end;
  --

  ---
  ben_eiv_ins.ins
  (
     p_effective_date                 =>  p_effective_date
    ,p_extra_input_value_id           =>  l_extra_input_value_id
    ,p_acty_base_rt_id                =>  p_acty_base_rt_id
    ,p_input_value_id                 =>  p_input_value_id
    ,p_input_text                     =>  p_input_text
    ,p_upd_when_ele_ended_cd          =>  p_upd_when_ele_ended_cd
    ,p_return_var_name                =>  p_return_var_name
    ,p_business_group_id              =>  p_business_group_id
    ,p_eiv_attribute_category         =>  p_eiv_attribute_category
    ,p_eiv_attribute1                 =>  p_eiv_attribute1
    ,p_eiv_attribute2                 =>  p_eiv_attribute2
    ,p_eiv_attribute3                 =>  p_eiv_attribute3
    ,p_eiv_attribute4                 =>  p_eiv_attribute4
    ,p_eiv_attribute5                 =>  p_eiv_attribute5
    ,p_eiv_attribute6                 =>  p_eiv_attribute6
    ,p_eiv_attribute7                 =>  p_eiv_attribute7
    ,p_eiv_attribute8                 =>  p_eiv_attribute8
    ,p_eiv_attribute9                 =>  p_eiv_attribute9
    ,p_eiv_attribute10                =>  p_eiv_attribute10
    ,p_eiv_attribute11                =>  p_eiv_attribute11
    ,p_eiv_attribute12                =>  p_eiv_attribute12
    ,p_eiv_attribute13                =>  p_eiv_attribute13
    ,p_eiv_attribute14                =>  p_eiv_attribute14
    ,p_eiv_attribute15                =>  p_eiv_attribute15
    ,p_eiv_attribute16                =>  p_eiv_attribute16
    ,p_eiv_attribute17                =>  p_eiv_attribute17
    ,p_eiv_attribute18                =>  p_eiv_attribute18
    ,p_eiv_attribute19                =>  p_eiv_attribute19
    ,p_eiv_attribute20                =>  p_eiv_attribute20
    ,p_eiv_attribute21                =>  p_eiv_attribute21
    ,p_eiv_attribute22                =>  p_eiv_attribute22
    ,p_eiv_attribute23                =>  p_eiv_attribute23
    ,p_eiv_attribute24                =>  p_eiv_attribute24
    ,p_eiv_attribute25                =>  p_eiv_attribute25
    ,p_eiv_attribute26                =>  p_eiv_attribute26
    ,p_eiv_attribute27                =>  p_eiv_attribute27
    ,p_eiv_attribute28                =>  p_eiv_attribute28
    ,p_eiv_attribute29                =>  p_eiv_attribute29
    ,p_eiv_attribute30                =>  p_eiv_attribute30
    ,p_object_version_number          => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_extra_input_value
    --
    ben_extra_input_value_bk1.create_extra_input_value_a
      (
       p_extra_input_value_id           => l_extra_input_value_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_input_value_id                 =>  p_input_value_id
      ,p_input_text                     =>  p_input_text
      ,p_upd_when_ele_ended_cd          =>  p_upd_when_ele_ended_cd
      ,p_return_var_name                =>  p_return_var_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_eiv_attribute_category         =>  p_eiv_attribute_category
      ,p_eiv_attribute1                 =>  p_eiv_attribute1
      ,p_eiv_attribute2                 =>  p_eiv_attribute2
      ,p_eiv_attribute3                 =>  p_eiv_attribute3
      ,p_eiv_attribute4                 =>  p_eiv_attribute4
      ,p_eiv_attribute5                 =>  p_eiv_attribute5
      ,p_eiv_attribute6                 =>  p_eiv_attribute6
      ,p_eiv_attribute7                 =>  p_eiv_attribute7
      ,p_eiv_attribute8                 =>  p_eiv_attribute8
      ,p_eiv_attribute9                 =>  p_eiv_attribute9
      ,p_eiv_attribute10                =>  p_eiv_attribute10
      ,p_eiv_attribute11                =>  p_eiv_attribute11
      ,p_eiv_attribute12                =>  p_eiv_attribute12
      ,p_eiv_attribute13                =>  p_eiv_attribute13
      ,p_eiv_attribute14                =>  p_eiv_attribute14
      ,p_eiv_attribute15                =>  p_eiv_attribute15
      ,p_eiv_attribute16                =>  p_eiv_attribute16
      ,p_eiv_attribute17                =>  p_eiv_attribute17
      ,p_eiv_attribute18                =>  p_eiv_attribute18
      ,p_eiv_attribute19                =>  p_eiv_attribute19
      ,p_eiv_attribute20                =>  p_eiv_attribute20
      ,p_eiv_attribute21                =>  p_eiv_attribute21
      ,p_eiv_attribute22                =>  p_eiv_attribute22
      ,p_eiv_attribute23                =>  p_eiv_attribute23
      ,p_eiv_attribute24                =>  p_eiv_attribute24
      ,p_eiv_attribute25                =>  p_eiv_attribute25
      ,p_eiv_attribute26                =>  p_eiv_attribute26
      ,p_eiv_attribute27                =>  p_eiv_attribute27
      ,p_eiv_attribute28                =>  p_eiv_attribute28
      ,p_eiv_attribute29                =>  p_eiv_attribute29
      ,p_eiv_attribute30                =>  p_eiv_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_extra_input_value'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_extra_input_value
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
  p_extra_input_value_id := l_extra_input_value_id;
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
    ROLLBACK TO create_extra_input_value;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_extra_input_value_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_extra_input_value;
    raise;
    --
end create_extra_input_value;
-- ----------------------------------------------------------------------------
-- |------------------------< update_extra_input_value >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_extra_input_value
  (
   p_validate                       in boolean    default false
  ,p_extra_input_value_id           in  number
  ,p_acty_base_rt_id                in  number    default hr_api.g_number
  ,p_input_value_id                 in  number    default hr_api.g_number
  ,p_input_text                     in  varchar2  default hr_api.g_varchar2
  ,p_upd_when_ele_ended_cd          in  varchar2  default hr_api.g_varchar2
  ,p_return_var_name                in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eiv_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_eiv_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_extra_input_value';
  l_object_version_number ben_extra_input_values.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_extra_input_value;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_extra_input_value
    --
    ben_extra_input_value_bk2.update_extra_input_value_b
      (
       p_extra_input_value_id           =>  p_extra_input_value_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_input_value_id                 =>  p_input_value_id
      ,p_input_text                     =>  p_input_text
      ,p_upd_when_ele_ended_cd          =>  p_upd_when_ele_ended_cd
      ,p_return_var_name                =>  p_return_var_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_eiv_attribute_category         =>  p_eiv_attribute_category
      ,p_eiv_attribute1                 =>  p_eiv_attribute1
      ,p_eiv_attribute2                 =>  p_eiv_attribute2
      ,p_eiv_attribute3                 =>  p_eiv_attribute3
      ,p_eiv_attribute4                 =>  p_eiv_attribute4
      ,p_eiv_attribute5                 =>  p_eiv_attribute5
      ,p_eiv_attribute6                 =>  p_eiv_attribute6
      ,p_eiv_attribute7                 =>  p_eiv_attribute7
      ,p_eiv_attribute8                 =>  p_eiv_attribute8
      ,p_eiv_attribute9                 =>  p_eiv_attribute9
      ,p_eiv_attribute10                =>  p_eiv_attribute10
      ,p_eiv_attribute11                =>  p_eiv_attribute11
      ,p_eiv_attribute12                =>  p_eiv_attribute12
      ,p_eiv_attribute13                =>  p_eiv_attribute13
      ,p_eiv_attribute14                =>  p_eiv_attribute14
      ,p_eiv_attribute15                =>  p_eiv_attribute15
      ,p_eiv_attribute16                =>  p_eiv_attribute16
      ,p_eiv_attribute17                =>  p_eiv_attribute17
      ,p_eiv_attribute18                =>  p_eiv_attribute18
      ,p_eiv_attribute19                =>  p_eiv_attribute19
      ,p_eiv_attribute20                =>  p_eiv_attribute20
      ,p_eiv_attribute21                =>  p_eiv_attribute21
      ,p_eiv_attribute22                =>  p_eiv_attribute22
      ,p_eiv_attribute23                =>  p_eiv_attribute23
      ,p_eiv_attribute24                =>  p_eiv_attribute24
      ,p_eiv_attribute25                =>  p_eiv_attribute25
      ,p_eiv_attribute26                =>  p_eiv_attribute26
      ,p_eiv_attribute27                =>  p_eiv_attribute27
      ,p_eiv_attribute28                =>  p_eiv_attribute28
      ,p_eiv_attribute29                =>  p_eiv_attribute29
      ,p_eiv_attribute30                =>  p_eiv_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_extra_input_value'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_extra_input_value
    --
  end;
  ---
  ben_eiv_upd.upd
    (
     p_effective_date                 =>  p_effective_date
    ,p_extra_input_value_id           =>  p_extra_input_value_id
    ,p_acty_base_rt_id                =>  p_acty_base_rt_id
    ,p_input_value_id                 =>  p_input_value_id
    ,p_input_text                     =>  p_input_text
    ,p_upd_when_ele_ended_cd          =>  p_upd_when_ele_ended_cd
    ,p_return_var_name                =>  p_return_var_name
    ,p_business_group_id              =>  p_business_group_id
    ,p_eiv_attribute_category         =>  p_eiv_attribute_category
    ,p_eiv_attribute1                 =>  p_eiv_attribute1
    ,p_eiv_attribute2                 =>  p_eiv_attribute2
    ,p_eiv_attribute3                 =>  p_eiv_attribute3
    ,p_eiv_attribute4                 =>  p_eiv_attribute4
    ,p_eiv_attribute5                 =>  p_eiv_attribute5
    ,p_eiv_attribute6                 =>  p_eiv_attribute6
    ,p_eiv_attribute7                 =>  p_eiv_attribute7
    ,p_eiv_attribute8                 =>  p_eiv_attribute8
    ,p_eiv_attribute9                 =>  p_eiv_attribute9
    ,p_eiv_attribute10                =>  p_eiv_attribute10
    ,p_eiv_attribute11                =>  p_eiv_attribute11
    ,p_eiv_attribute12                =>  p_eiv_attribute12
    ,p_eiv_attribute13                =>  p_eiv_attribute13
    ,p_eiv_attribute14                =>  p_eiv_attribute14
    ,p_eiv_attribute15                =>  p_eiv_attribute15
    ,p_eiv_attribute16                =>  p_eiv_attribute16
    ,p_eiv_attribute17                =>  p_eiv_attribute17
    ,p_eiv_attribute18                =>  p_eiv_attribute18
    ,p_eiv_attribute19                =>  p_eiv_attribute19
    ,p_eiv_attribute20                =>  p_eiv_attribute20
    ,p_eiv_attribute21                =>  p_eiv_attribute21
    ,p_eiv_attribute22                =>  p_eiv_attribute22
    ,p_eiv_attribute23                =>  p_eiv_attribute23
    ,p_eiv_attribute24                =>  p_eiv_attribute24
    ,p_eiv_attribute25                =>  p_eiv_attribute25
    ,p_eiv_attribute26                =>  p_eiv_attribute26
    ,p_eiv_attribute27                =>  p_eiv_attribute27
    ,p_eiv_attribute28                =>  p_eiv_attribute28
    ,p_eiv_attribute29                =>  p_eiv_attribute29
    ,p_eiv_attribute30                =>  p_eiv_attribute30
    ,p_object_version_number          => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_extra_input_value
    --
    ben_extra_input_value_bk2.update_extra_input_value_a
      (
       p_extra_input_value_id           =>  p_extra_input_value_id
      ,p_acty_base_rt_id                =>  p_acty_base_rt_id
      ,p_input_value_id                 =>  p_input_value_id
      ,p_input_text                     =>  p_input_text
      ,p_upd_when_ele_ended_cd          =>  p_upd_when_ele_ended_cd
      ,p_return_var_name                =>  p_return_var_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_eiv_attribute_category         =>  p_eiv_attribute_category
      ,p_eiv_attribute1                 =>  p_eiv_attribute1
      ,p_eiv_attribute2                 =>  p_eiv_attribute2
      ,p_eiv_attribute3                 =>  p_eiv_attribute3
      ,p_eiv_attribute4                 =>  p_eiv_attribute4
      ,p_eiv_attribute5                 =>  p_eiv_attribute5
      ,p_eiv_attribute6                 =>  p_eiv_attribute6
      ,p_eiv_attribute7                 =>  p_eiv_attribute7
      ,p_eiv_attribute8                 =>  p_eiv_attribute8
      ,p_eiv_attribute9                 =>  p_eiv_attribute9
      ,p_eiv_attribute10                =>  p_eiv_attribute10
      ,p_eiv_attribute11                =>  p_eiv_attribute11
      ,p_eiv_attribute12                =>  p_eiv_attribute12
      ,p_eiv_attribute13                =>  p_eiv_attribute13
      ,p_eiv_attribute14                =>  p_eiv_attribute14
      ,p_eiv_attribute15                =>  p_eiv_attribute15
      ,p_eiv_attribute16                =>  p_eiv_attribute16
      ,p_eiv_attribute17                =>  p_eiv_attribute17
      ,p_eiv_attribute18                =>  p_eiv_attribute18
      ,p_eiv_attribute19                =>  p_eiv_attribute19
      ,p_eiv_attribute20                =>  p_eiv_attribute20
      ,p_eiv_attribute21                =>  p_eiv_attribute21
      ,p_eiv_attribute22                =>  p_eiv_attribute22
      ,p_eiv_attribute23                =>  p_eiv_attribute23
      ,p_eiv_attribute24                =>  p_eiv_attribute24
      ,p_eiv_attribute25                =>  p_eiv_attribute25
      ,p_eiv_attribute26                =>  p_eiv_attribute26
      ,p_eiv_attribute27                =>  p_eiv_attribute27
      ,p_eiv_attribute28                =>  p_eiv_attribute28
      ,p_eiv_attribute29                =>  p_eiv_attribute29
      ,p_eiv_attribute30                =>  p_eiv_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_extra_input_value'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_extra_input_value
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
    ROLLBACK TO update_extra_input_value;
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
    ROLLBACK TO update_extra_input_value;
    raise;
    --
end update_extra_input_value;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_extra_input_value >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_extra_input_value
  (p_validate                       in  boolean  default false
  ,p_extra_input_value_id           in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_extra_input_value';
  l_object_version_number ben_extra_input_values.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_extra_input_value;
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
    -- Start of API User Hook for the before hook of delete_extra_input_value
    --
    ben_extra_input_value_bk3.delete_extra_input_value_b
      (
       p_extra_input_value_id                =>  p_extra_input_value_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_extra_input_value'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_extra_input_value
    --
  end;
  --
  ben_eiv_del.del
    (
     p_effective_date                => p_effective_date
    ,p_extra_input_value_id          => p_extra_input_value_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_extra_input_value
    --
    ben_extra_input_value_bk3.delete_extra_input_value_a
      (
       p_extra_input_value_id                =>  p_extra_input_value_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_extra_input_value'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_extra_input_value
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_extra_input_value;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
/*
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_extra_input_value;
    raise;
    --
*/
end delete_extra_input_value;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_extra_input_value_id                   in     number
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
  ben_eiv_shd.lck
    (
      p_extra_input_value_id                 => p_extra_input_value_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_extra_input_value_api;

/
