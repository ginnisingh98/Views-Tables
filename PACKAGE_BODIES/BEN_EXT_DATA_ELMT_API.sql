--------------------------------------------------------
--  DDL for Package Body BEN_EXT_DATA_ELMT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_DATA_ELMT_API" as
/* $Header: bexelapi.pkb 120.1 2005/06/08 13:17:21 tjesumic noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_DATA_ELMT_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_DATA_ELMT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_DATA_ELMT
  (p_validate                       in  boolean   default false
  ,p_ext_data_elmt_id               out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_xml_tag_name                   in  varchar2  default null
  ,p_data_elmt_typ_cd               in  varchar2  default null
  ,p_data_elmt_rl                   in  number    default null
  ,p_frmt_mask_cd                   in  varchar2  default null
  ,p_string_val                     in  varchar2  default null
  ,p_dflt_val                       in  varchar2  default null
  ,p_max_length_num                 in  number    default null
  ,p_just_cd                        in  varchar2  default null
  ,p_ttl_fnctn_cd                   in  varchar2  default null
  ,p_ttl_cond_oper_cd                       in  varchar2  default null
  ,p_ttl_cond_val                      in  varchar2  default null
  ,p_ttl_sum_ext_data_elmt_id                     in  number    default null
  ,p_ttl_cond_ext_data_elmt_id                     in  number    default null
  ,p_ext_fld_id                     in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_xel_attribute_category         in  varchar2  default null
  ,p_xel_attribute1                 in  varchar2  default null
  ,p_xel_attribute2                 in  varchar2  default null
  ,p_xel_attribute3                 in  varchar2  default null
  ,p_xel_attribute4                 in  varchar2  default null
  ,p_xel_attribute5                 in  varchar2  default null
  ,p_xel_attribute6                 in  varchar2  default null
  ,p_xel_attribute7                 in  varchar2  default null
  ,p_xel_attribute8                 in  varchar2  default null
  ,p_xel_attribute9                 in  varchar2  default null
  ,p_xel_attribute10                in  varchar2  default null
  ,p_xel_attribute11                in  varchar2  default null
  ,p_xel_attribute12                in  varchar2  default null
  ,p_xel_attribute13                in  varchar2  default null
  ,p_xel_attribute14                in  varchar2  default null
  ,p_xel_attribute15                in  varchar2  default null
  ,p_xel_attribute16                in  varchar2  default null
  ,p_xel_attribute17                in  varchar2  default null
  ,p_xel_attribute18                in  varchar2  default null
  ,p_xel_attribute19                in  varchar2  default null
  ,p_xel_attribute20                in  varchar2  default null
  ,p_xel_attribute21                in  varchar2  default null
  ,p_xel_attribute22                in  varchar2  default null
  ,p_xel_attribute23                in  varchar2  default null
  ,p_xel_attribute24                in  varchar2  default null
  ,p_xel_attribute25                in  varchar2  default null
  ,p_xel_attribute26                in  varchar2  default null
  ,p_xel_attribute27                in  varchar2  default null
  ,p_xel_attribute28                in  varchar2  default null
  ,p_xel_attribute29                in  varchar2  default null
  ,p_xel_attribute30                in  varchar2  default null
  ,p_defined_balance_id             in  number  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_data_elmt_id ben_ext_data_elmt.ext_data_elmt_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_DATA_ELMT';
  l_object_version_number ben_ext_data_elmt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_EXT_DATA_ELMT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_DATA_ELMT
    --
    ben_EXT_DATA_ELMT_bk1.create_EXT_DATA_ELMT_b
      (
       p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_data_elmt_typ_cd               =>  p_data_elmt_typ_cd
      ,p_data_elmt_rl                   =>  p_data_elmt_rl
      ,p_frmt_mask_cd                   =>  p_frmt_mask_cd
      ,p_string_val                     =>  p_string_val
      ,p_dflt_val                       =>  p_dflt_val
      ,p_max_length_num                 =>  p_max_length_num
      ,p_just_cd                       =>  p_just_cd
      ,p_ttl_fnctn_cd                 => p_ttl_fnctn_cd
      ,p_ttl_cond_oper_cd                       =>p_ttl_cond_oper_cd
      ,p_ttl_cond_val                      =>p_ttl_cond_val
      ,p_ttl_sum_ext_data_elmt_id                    =>p_ttl_sum_ext_data_elmt_id
      ,p_ttl_cond_ext_data_elmt_id                   =>p_ttl_cond_ext_data_elmt_id
      ,p_ext_fld_id                     =>  p_ext_fld_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xel_attribute_category         =>  p_xel_attribute_category
      ,p_xel_attribute1                 =>  p_xel_attribute1
      ,p_xel_attribute2                 =>  p_xel_attribute2
      ,p_xel_attribute3                 =>  p_xel_attribute3
      ,p_xel_attribute4                 =>  p_xel_attribute4
      ,p_xel_attribute5                 =>  p_xel_attribute5
      ,p_xel_attribute6                 =>  p_xel_attribute6
      ,p_xel_attribute7                 =>  p_xel_attribute7
      ,p_xel_attribute8                 =>  p_xel_attribute8
      ,p_xel_attribute9                 =>  p_xel_attribute9
      ,p_xel_attribute10                =>  p_xel_attribute10
      ,p_xel_attribute11                =>  p_xel_attribute11
      ,p_xel_attribute12                =>  p_xel_attribute12
      ,p_xel_attribute13                =>  p_xel_attribute13
      ,p_xel_attribute14                =>  p_xel_attribute14
      ,p_xel_attribute15                =>  p_xel_attribute15
      ,p_xel_attribute16                =>  p_xel_attribute16
      ,p_xel_attribute17                =>  p_xel_attribute17
      ,p_xel_attribute18                =>  p_xel_attribute18
      ,p_xel_attribute19                =>  p_xel_attribute19
      ,p_xel_attribute20                =>  p_xel_attribute20
      ,p_xel_attribute21                =>  p_xel_attribute21
      ,p_xel_attribute22                =>  p_xel_attribute22
      ,p_xel_attribute23                =>  p_xel_attribute23
      ,p_xel_attribute24                =>  p_xel_attribute24
      ,p_xel_attribute25                =>  p_xel_attribute25
      ,p_xel_attribute26                =>  p_xel_attribute26
      ,p_xel_attribute27                =>  p_xel_attribute27
      ,p_xel_attribute28                =>  p_xel_attribute28
      ,p_xel_attribute29                =>  p_xel_attribute29
      ,p_xel_attribute30                =>  p_xel_attribute30
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_DATA_ELMT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_DATA_ELMT
    --
  end;
  --
  ben_xel_ins.ins
    (
     p_ext_data_elmt_id              => l_ext_data_elmt_id
    ,p_name                          => p_name
    ,p_xml_tag_name                  => p_xml_tag_name
    ,p_data_elmt_typ_cd              => p_data_elmt_typ_cd
    ,p_data_elmt_rl                  => p_data_elmt_rl
    ,p_frmt_mask_cd                  => p_frmt_mask_cd
    ,p_string_val                    => p_string_val
    ,p_dflt_val                      => p_dflt_val
    ,p_max_length_num                => p_max_length_num
    ,p_just_cd                       => p_just_cd
      ,p_ttl_fnctn_cd                 => p_ttl_fnctn_cd
      ,p_ttl_cond_oper_cd                       =>p_ttl_cond_oper_cd
      ,p_ttl_cond_val                      =>p_ttl_cond_val
      ,p_ttl_sum_ext_data_elmt_id                    =>p_ttl_sum_ext_data_elmt_id
      ,p_ttl_cond_ext_data_elmt_id                   =>p_ttl_cond_ext_data_elmt_id
    ,p_ext_fld_id                    => p_ext_fld_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_xel_attribute_category        => p_xel_attribute_category
    ,p_xel_attribute1                => p_xel_attribute1
    ,p_xel_attribute2                => p_xel_attribute2
    ,p_xel_attribute3                => p_xel_attribute3
    ,p_xel_attribute4                => p_xel_attribute4
    ,p_xel_attribute5                => p_xel_attribute5
    ,p_xel_attribute6                => p_xel_attribute6
    ,p_xel_attribute7                => p_xel_attribute7
    ,p_xel_attribute8                => p_xel_attribute8
    ,p_xel_attribute9                => p_xel_attribute9
    ,p_xel_attribute10               => p_xel_attribute10
    ,p_xel_attribute11               => p_xel_attribute11
    ,p_xel_attribute12               => p_xel_attribute12
    ,p_xel_attribute13               => p_xel_attribute13
    ,p_xel_attribute14               => p_xel_attribute14
    ,p_xel_attribute15               => p_xel_attribute15
    ,p_xel_attribute16               => p_xel_attribute16
    ,p_xel_attribute17               => p_xel_attribute17
    ,p_xel_attribute18               => p_xel_attribute18
    ,p_xel_attribute19               => p_xel_attribute19
    ,p_xel_attribute20               => p_xel_attribute20
    ,p_xel_attribute21               => p_xel_attribute21
    ,p_xel_attribute22               => p_xel_attribute22
    ,p_xel_attribute23               => p_xel_attribute23
    ,p_xel_attribute24               => p_xel_attribute24
    ,p_xel_attribute25               => p_xel_attribute25
    ,p_xel_attribute26               => p_xel_attribute26
    ,p_xel_attribute27               => p_xel_attribute27
    ,p_xel_attribute28               => p_xel_attribute28
    ,p_xel_attribute29               => p_xel_attribute29
    ,p_xel_attribute30               => p_xel_attribute30
    ,p_defined_balance_id            => p_defined_balance_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_DATA_ELMT
    --
    ben_EXT_DATA_ELMT_bk1.create_EXT_DATA_ELMT_a
      (
       p_ext_data_elmt_id               =>  l_ext_data_elmt_id
      ,p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_data_elmt_typ_cd               =>  p_data_elmt_typ_cd
      ,p_data_elmt_rl                   =>  p_data_elmt_rl
      ,p_frmt_mask_cd                   =>  p_frmt_mask_cd
      ,p_string_val                     =>  p_string_val
      ,p_dflt_val                       =>  p_dflt_val
      ,p_max_length_num                 =>  p_max_length_num
      ,p_just_cd                        =>  p_just_cd
      ,p_ttl_fnctn_cd                 => p_ttl_fnctn_cd
      ,p_ttl_cond_oper_cd                       =>p_ttl_cond_oper_cd
      ,p_ttl_cond_val                      =>p_ttl_cond_val
      ,p_ttl_sum_ext_data_elmt_id                    =>p_ttl_sum_ext_data_elmt_id
      ,p_ttl_cond_ext_data_elmt_id                   =>p_ttl_cond_ext_data_elmt_id
      ,p_ext_fld_id                     =>  p_ext_fld_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xel_attribute_category         =>  p_xel_attribute_category
      ,p_xel_attribute1                 =>  p_xel_attribute1
      ,p_xel_attribute2                 =>  p_xel_attribute2
      ,p_xel_attribute3                 =>  p_xel_attribute3
      ,p_xel_attribute4                 =>  p_xel_attribute4
      ,p_xel_attribute5                 =>  p_xel_attribute5
      ,p_xel_attribute6                 =>  p_xel_attribute6
      ,p_xel_attribute7                 =>  p_xel_attribute7
      ,p_xel_attribute8                 =>  p_xel_attribute8
      ,p_xel_attribute9                 =>  p_xel_attribute9
      ,p_xel_attribute10                =>  p_xel_attribute10
      ,p_xel_attribute11                =>  p_xel_attribute11
      ,p_xel_attribute12                =>  p_xel_attribute12
      ,p_xel_attribute13                =>  p_xel_attribute13
      ,p_xel_attribute14                =>  p_xel_attribute14
      ,p_xel_attribute15                =>  p_xel_attribute15
      ,p_xel_attribute16                =>  p_xel_attribute16
      ,p_xel_attribute17                =>  p_xel_attribute17
      ,p_xel_attribute18                =>  p_xel_attribute18
      ,p_xel_attribute19                =>  p_xel_attribute19
      ,p_xel_attribute20                =>  p_xel_attribute20
      ,p_xel_attribute21                =>  p_xel_attribute21
      ,p_xel_attribute22                =>  p_xel_attribute22
      ,p_xel_attribute23                =>  p_xel_attribute23
      ,p_xel_attribute24                =>  p_xel_attribute24
      ,p_xel_attribute25                =>  p_xel_attribute25
      ,p_xel_attribute26                =>  p_xel_attribute26
      ,p_xel_attribute27                =>  p_xel_attribute27
      ,p_xel_attribute28                =>  p_xel_attribute28
      ,p_xel_attribute29                =>  p_xel_attribute29
      ,p_xel_attribute30                =>  p_xel_attribute30
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_DATA_ELMT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_DATA_ELMT
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
  p_ext_data_elmt_id := l_ext_data_elmt_id;
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
    ROLLBACK TO create_EXT_DATA_ELMT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_data_elmt_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_EXT_DATA_ELMT;
    raise;
    --
end create_EXT_DATA_ELMT;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_DATA_ELMT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_DATA_ELMT
  (p_validate                       in  boolean   default false
  ,p_ext_data_elmt_id               in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_xml_tag_name                   in  varchar2  default hr_api.g_varchar2
  ,p_data_elmt_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_data_elmt_rl                   in  number    default hr_api.g_number
  ,p_frmt_mask_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_string_val                     in  varchar2  default hr_api.g_varchar2
  ,p_dflt_val                       in  varchar2  default hr_api.g_varchar2
  ,p_max_length_num                 in  number    default hr_api.g_number
  ,p_just_cd                        in  varchar2  default hr_api.g_varchar2
      ,p_ttl_fnctn_cd               in  varchar2  default hr_api.g_varchar2
      ,p_ttl_cond_oper_cd            in  varchar2  default hr_api.g_varchar2
      ,p_ttl_cond_val                 in  varchar2  default hr_api.g_varchar2
      ,p_ttl_sum_ext_data_elmt_id         in  number    default hr_api.g_number
      ,p_ttl_cond_ext_data_elmt_id        in  number    default hr_api.g_number
  ,p_ext_fld_id                     in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in varchar2   default hr_api.g_varchar2
  ,p_xel_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_xel_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_defined_balance_id             in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_DATA_ELMT';
  l_object_version_number ben_ext_data_elmt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_DATA_ELMT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_DATA_ELMT
    --
    ben_EXT_DATA_ELMT_bk2.update_EXT_DATA_ELMT_b
      (
       p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_data_elmt_typ_cd               =>  p_data_elmt_typ_cd
      ,p_data_elmt_rl                   =>  p_data_elmt_rl
      ,p_frmt_mask_cd                   =>  p_frmt_mask_cd
      ,p_string_val                     =>  p_string_val
      ,p_dflt_val                       =>  p_dflt_val
      ,p_max_length_num                 =>  p_max_length_num
      ,p_just_cd                        =>  p_just_cd
      ,p_ttl_fnctn_cd               =>p_ttl_fnctn_cd
      ,p_ttl_cond_oper_cd           =>p_ttl_cond_oper_cd
      ,p_ttl_cond_val              =>p_ttl_cond_val
      ,p_ttl_sum_ext_data_elmt_id      =>p_ttl_sum_ext_data_elmt_id
      ,p_ttl_cond_ext_data_elmt_id    =>p_ttl_cond_ext_data_elmt_id
      ,p_ext_fld_id                     =>  p_ext_fld_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xel_attribute_category         =>  p_xel_attribute_category
      ,p_xel_attribute1                 =>  p_xel_attribute1
      ,p_xel_attribute2                 =>  p_xel_attribute2
      ,p_xel_attribute3                 =>  p_xel_attribute3
      ,p_xel_attribute4                 =>  p_xel_attribute4
      ,p_xel_attribute5                 =>  p_xel_attribute5
      ,p_xel_attribute6                 =>  p_xel_attribute6
      ,p_xel_attribute7                 =>  p_xel_attribute7
      ,p_xel_attribute8                 =>  p_xel_attribute8
      ,p_xel_attribute9                 =>  p_xel_attribute9
      ,p_xel_attribute10                =>  p_xel_attribute10
      ,p_xel_attribute11                =>  p_xel_attribute11
      ,p_xel_attribute12                =>  p_xel_attribute12
      ,p_xel_attribute13                =>  p_xel_attribute13
      ,p_xel_attribute14                =>  p_xel_attribute14
      ,p_xel_attribute15                =>  p_xel_attribute15
      ,p_xel_attribute16                =>  p_xel_attribute16
      ,p_xel_attribute17                =>  p_xel_attribute17
      ,p_xel_attribute18                =>  p_xel_attribute18
      ,p_xel_attribute19                =>  p_xel_attribute19
      ,p_xel_attribute20                =>  p_xel_attribute20
      ,p_xel_attribute21                =>  p_xel_attribute21
      ,p_xel_attribute22                =>  p_xel_attribute22
      ,p_xel_attribute23                =>  p_xel_attribute23
      ,p_xel_attribute24                =>  p_xel_attribute24
      ,p_xel_attribute25                =>  p_xel_attribute25
      ,p_xel_attribute26                =>  p_xel_attribute26
      ,p_xel_attribute27                =>  p_xel_attribute27
      ,p_xel_attribute28                =>  p_xel_attribute28
      ,p_xel_attribute29                =>  p_xel_attribute29
      ,p_xel_attribute30                =>  p_xel_attribute30
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_DATA_ELMT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_DATA_ELMT
    --
  end;
  --
  ben_xel_upd.upd
    (
     p_ext_data_elmt_id              => p_ext_data_elmt_id
    ,p_name                          => p_name
    ,p_xml_tag_name                  => p_xml_tag_name
    ,p_data_elmt_typ_cd              => p_data_elmt_typ_cd
    ,p_data_elmt_rl                  => p_data_elmt_rl
    ,p_frmt_mask_cd                  => p_frmt_mask_cd
    ,p_string_val                    => p_string_val
    ,p_dflt_val                      => p_dflt_val
    ,p_max_length_num                => p_max_length_num
      ,p_just_cd                        =>  p_just_cd
      ,p_ttl_fnctn_cd               =>p_ttl_fnctn_cd
      ,p_ttl_cond_oper_cd           =>p_ttl_cond_oper_cd
      ,p_ttl_cond_val              =>p_ttl_cond_val
      ,p_ttl_sum_ext_data_elmt_id      =>p_ttl_sum_ext_data_elmt_id
      ,p_ttl_cond_ext_data_elmt_id    =>p_ttl_cond_ext_data_elmt_id
    ,p_ext_fld_id                    => p_ext_fld_id
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_xel_attribute_category        => p_xel_attribute_category
    ,p_xel_attribute1                => p_xel_attribute1
    ,p_xel_attribute2                => p_xel_attribute2
    ,p_xel_attribute3                => p_xel_attribute3
    ,p_xel_attribute4                => p_xel_attribute4
    ,p_xel_attribute5                => p_xel_attribute5
    ,p_xel_attribute6                => p_xel_attribute6
    ,p_xel_attribute7                => p_xel_attribute7
    ,p_xel_attribute8                => p_xel_attribute8
    ,p_xel_attribute9                => p_xel_attribute9
    ,p_xel_attribute10               => p_xel_attribute10
    ,p_xel_attribute11               => p_xel_attribute11
    ,p_xel_attribute12               => p_xel_attribute12
    ,p_xel_attribute13               => p_xel_attribute13
    ,p_xel_attribute14               => p_xel_attribute14
    ,p_xel_attribute15               => p_xel_attribute15
    ,p_xel_attribute16               => p_xel_attribute16
    ,p_xel_attribute17               => p_xel_attribute17
    ,p_xel_attribute18               => p_xel_attribute18
    ,p_xel_attribute19               => p_xel_attribute19
    ,p_xel_attribute20               => p_xel_attribute20
    ,p_xel_attribute21               => p_xel_attribute21
    ,p_xel_attribute22               => p_xel_attribute22
    ,p_xel_attribute23               => p_xel_attribute23
    ,p_xel_attribute24               => p_xel_attribute24
    ,p_xel_attribute25               => p_xel_attribute25
    ,p_xel_attribute26               => p_xel_attribute26
    ,p_xel_attribute27               => p_xel_attribute27
    ,p_xel_attribute28               => p_xel_attribute28
    ,p_xel_attribute29               => p_xel_attribute29
    ,p_xel_attribute30               => p_xel_attribute30
    ,p_defined_balance_id            => p_defined_balance_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_DATA_ELMT
    --
    ben_EXT_DATA_ELMT_bk2.update_EXT_DATA_ELMT_a
      (
       p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_data_elmt_typ_cd               =>  p_data_elmt_typ_cd
      ,p_data_elmt_rl                   =>  p_data_elmt_rl
      ,p_frmt_mask_cd                   =>  p_frmt_mask_cd
      ,p_string_val                     =>  p_string_val
      ,p_dflt_val                       =>  p_dflt_val
      ,p_max_length_num                 =>  p_max_length_num
      ,p_just_cd                       =>  p_just_cd
      ,p_ttl_fnctn_cd               =>p_ttl_fnctn_cd
      ,p_ttl_cond_oper_cd           =>p_ttl_cond_oper_cd
      ,p_ttl_cond_val              =>p_ttl_cond_val
      ,p_ttl_sum_ext_data_elmt_id      =>p_ttl_sum_ext_data_elmt_id
      ,p_ttl_cond_ext_data_elmt_id    =>p_ttl_cond_ext_data_elmt_id
      ,p_ext_fld_id                     =>  p_ext_fld_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xel_attribute_category         =>  p_xel_attribute_category
      ,p_xel_attribute1                 =>  p_xel_attribute1
      ,p_xel_attribute2                 =>  p_xel_attribute2
      ,p_xel_attribute3                 =>  p_xel_attribute3
      ,p_xel_attribute4                 =>  p_xel_attribute4
      ,p_xel_attribute5                 =>  p_xel_attribute5
      ,p_xel_attribute6                 =>  p_xel_attribute6
      ,p_xel_attribute7                 =>  p_xel_attribute7
      ,p_xel_attribute8                 =>  p_xel_attribute8
      ,p_xel_attribute9                 =>  p_xel_attribute9
      ,p_xel_attribute10                =>  p_xel_attribute10
      ,p_xel_attribute11                =>  p_xel_attribute11
      ,p_xel_attribute12                =>  p_xel_attribute12
      ,p_xel_attribute13                =>  p_xel_attribute13
      ,p_xel_attribute14                =>  p_xel_attribute14
      ,p_xel_attribute15                =>  p_xel_attribute15
      ,p_xel_attribute16                =>  p_xel_attribute16
      ,p_xel_attribute17                =>  p_xel_attribute17
      ,p_xel_attribute18                =>  p_xel_attribute18
      ,p_xel_attribute19                =>  p_xel_attribute19
      ,p_xel_attribute20                =>  p_xel_attribute20
      ,p_xel_attribute21                =>  p_xel_attribute21
      ,p_xel_attribute22                =>  p_xel_attribute22
      ,p_xel_attribute23                =>  p_xel_attribute23
      ,p_xel_attribute24                =>  p_xel_attribute24
      ,p_xel_attribute25                =>  p_xel_attribute25
      ,p_xel_attribute26                =>  p_xel_attribute26
      ,p_xel_attribute27                =>  p_xel_attribute27
      ,p_xel_attribute28                =>  p_xel_attribute28
      ,p_xel_attribute29                =>  p_xel_attribute29
      ,p_xel_attribute30                =>  p_xel_attribute30
      ,p_defined_balance_id             =>  p_defined_balance_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_DATA_ELMT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_DATA_ELMT
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
    ROLLBACK TO update_EXT_DATA_ELMT;
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
    ROLLBACK TO update_EXT_DATA_ELMT;
    raise;
    --
end update_EXT_DATA_ELMT;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_DATA_ELMT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_DATA_ELMT
  (p_validate                       in  boolean  default false
  ,p_ext_data_elmt_id               in  number
  ,p_legislation_code               in  varchar2 default null
  ,p_object_version_number          in  out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_DATA_ELMT';
  l_object_version_number ben_ext_data_elmt.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_DATA_ELMT;
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
    -- Start of API User Hook for the before hook of delete_EXT_DATA_ELMT
    --
    ben_EXT_DATA_ELMT_bk3.delete_EXT_DATA_ELMT_b
      (
       p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_DATA_ELMT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_DATA_ELMT
    --
  end;
  --
  ben_xel_del.del
    (
     p_ext_data_elmt_id              => p_ext_data_elmt_id
    ,p_legislation_code               =>  p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_DATA_ELMT
    --
    ben_EXT_DATA_ELMT_bk3.delete_EXT_DATA_ELMT_a
      (
       p_ext_data_elmt_id               =>  p_ext_data_elmt_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_DATA_ELMT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_DATA_ELMT
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
    ROLLBACK TO delete_EXT_DATA_ELMT;
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
    ROLLBACK TO delete_EXT_DATA_ELMT;
    raise;
    --
end delete_EXT_DATA_ELMT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_data_elmt_id                   in     number
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
  ben_xel_shd.lck
    (
      p_ext_data_elmt_id                 => p_ext_data_elmt_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_EXT_DATA_ELMT_api;

/
