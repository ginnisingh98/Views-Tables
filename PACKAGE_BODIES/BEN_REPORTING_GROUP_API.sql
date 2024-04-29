--------------------------------------------------------
--  DDL for Package Body BEN_REPORTING_GROUP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_REPORTING_GROUP_API" as
/* $Header: bebnrapi.pkb 120.0 2005/05/28 00:45:43 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Reporting_Group_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Reporting_Group >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Reporting_Group
  (p_validate                       in  boolean   default false
  ,p_rptg_grp_id                    out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_rptg_prps_cd                   in  varchar2  default null
  ,p_rpg_desc                       in  varchar2  default null
  ,p_bnr_attribute_category         in  varchar2  default null
  ,p_bnr_attribute1                 in  varchar2  default null
  ,p_bnr_attribute2                 in  varchar2  default null
  ,p_bnr_attribute3                 in  varchar2  default null
  ,p_bnr_attribute4                 in  varchar2  default null
  ,p_bnr_attribute5                 in  varchar2  default null
  ,p_bnr_attribute6                 in  varchar2  default null
  ,p_bnr_attribute7                 in  varchar2  default null
  ,p_bnr_attribute8                 in  varchar2  default null
  ,p_bnr_attribute9                 in  varchar2  default null
  ,p_bnr_attribute10                in  varchar2  default null
  ,p_bnr_attribute11                in  varchar2  default null
  ,p_bnr_attribute12                in  varchar2  default null
  ,p_bnr_attribute13                in  varchar2  default null
  ,p_bnr_attribute14                in  varchar2  default null
  ,p_bnr_attribute15                in  varchar2  default null
  ,p_bnr_attribute16                in  varchar2  default null
  ,p_bnr_attribute17                in  varchar2  default null
  ,p_bnr_attribute18                in  varchar2  default null
  ,p_bnr_attribute19                in  varchar2  default null
  ,p_bnr_attribute20                in  varchar2  default null
  ,p_bnr_attribute21                in  varchar2  default null
  ,p_bnr_attribute22                in  varchar2  default null
  ,p_bnr_attribute23                in  varchar2  default null
  ,p_bnr_attribute24                in  varchar2  default null
  ,p_bnr_attribute25                in  varchar2  default null
  ,p_bnr_attribute26                in  varchar2  default null
  ,p_bnr_attribute27                in  varchar2  default null
  ,p_bnr_attribute28                in  varchar2  default null
  ,p_bnr_attribute29                in  varchar2  default null
  ,p_bnr_attribute30                in  varchar2  default null
  ,p_function_code                  in  varchar2  default null
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_ordr_num                       in  number    default null            --iRec
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_rptg_grp_id ben_rptg_grp.rptg_grp_id%TYPE;
  l_proc varchar2(72) := g_package||'create_Reporting_Group';
  l_object_version_number ben_rptg_grp.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Reporting_Group;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Reporting_Group
    --
    ben_Reporting_Group_bk1.create_Reporting_Group_b
      (
       p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_rptg_prps_cd                   =>  p_rptg_prps_cd
      ,p_rpg_desc                       =>  p_rpg_desc
      ,p_bnr_attribute_category         =>  p_bnr_attribute_category
      ,p_bnr_attribute1                 =>  p_bnr_attribute1
      ,p_bnr_attribute2                 =>  p_bnr_attribute2
      ,p_bnr_attribute3                 =>  p_bnr_attribute3
      ,p_bnr_attribute4                 =>  p_bnr_attribute4
      ,p_bnr_attribute5                 =>  p_bnr_attribute5
      ,p_bnr_attribute6                 =>  p_bnr_attribute6
      ,p_bnr_attribute7                 =>  p_bnr_attribute7
      ,p_bnr_attribute8                 =>  p_bnr_attribute8
      ,p_bnr_attribute9                 =>  p_bnr_attribute9
      ,p_bnr_attribute10                =>  p_bnr_attribute10
      ,p_bnr_attribute11                =>  p_bnr_attribute11
      ,p_bnr_attribute12                =>  p_bnr_attribute12
      ,p_bnr_attribute13                =>  p_bnr_attribute13
      ,p_bnr_attribute14                =>  p_bnr_attribute14
      ,p_bnr_attribute15                =>  p_bnr_attribute15
      ,p_bnr_attribute16                =>  p_bnr_attribute16
      ,p_bnr_attribute17                =>  p_bnr_attribute17
      ,p_bnr_attribute18                =>  p_bnr_attribute18
      ,p_bnr_attribute19                =>  p_bnr_attribute19
      ,p_bnr_attribute20                =>  p_bnr_attribute20
      ,p_bnr_attribute21                =>  p_bnr_attribute21
      ,p_bnr_attribute22                =>  p_bnr_attribute22
      ,p_bnr_attribute23                =>  p_bnr_attribute23
      ,p_bnr_attribute24                =>  p_bnr_attribute24
      ,p_bnr_attribute25                =>  p_bnr_attribute25
      ,p_bnr_attribute26                =>  p_bnr_attribute26
      ,p_bnr_attribute27                =>  p_bnr_attribute27
      ,p_bnr_attribute28                =>  p_bnr_attribute28
      ,p_bnr_attribute29                =>  p_bnr_attribute29
      ,p_bnr_attribute30                =>  p_bnr_attribute30
      ,p_function_code                  =>  p_function_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_ordr_num                       =>  p_ordr_num               --iRec
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Reporting_Group'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Reporting_Group
    --
  end;
  --
  ben_bnr_ins.ins
    (
     p_rptg_grp_id                   => l_rptg_grp_id
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_rptg_prps_cd                  => p_rptg_prps_cd
    ,p_rpg_desc                      => p_rpg_desc
    ,p_bnr_attribute_category        => p_bnr_attribute_category
    ,p_bnr_attribute1                => p_bnr_attribute1
    ,p_bnr_attribute2                => p_bnr_attribute2
    ,p_bnr_attribute3                => p_bnr_attribute3
    ,p_bnr_attribute4                => p_bnr_attribute4
    ,p_bnr_attribute5                => p_bnr_attribute5
    ,p_bnr_attribute6                => p_bnr_attribute6
    ,p_bnr_attribute7                => p_bnr_attribute7
    ,p_bnr_attribute8                => p_bnr_attribute8
    ,p_bnr_attribute9                => p_bnr_attribute9
    ,p_bnr_attribute10               => p_bnr_attribute10
    ,p_bnr_attribute11               => p_bnr_attribute11
    ,p_bnr_attribute12               => p_bnr_attribute12
    ,p_bnr_attribute13               => p_bnr_attribute13
    ,p_bnr_attribute14               => p_bnr_attribute14
    ,p_bnr_attribute15               => p_bnr_attribute15
    ,p_bnr_attribute16               => p_bnr_attribute16
    ,p_bnr_attribute17               => p_bnr_attribute17
    ,p_bnr_attribute18               => p_bnr_attribute18
    ,p_bnr_attribute19               => p_bnr_attribute19
    ,p_bnr_attribute20               => p_bnr_attribute20
    ,p_bnr_attribute21               => p_bnr_attribute21
    ,p_bnr_attribute22               => p_bnr_attribute22
    ,p_bnr_attribute23               => p_bnr_attribute23
    ,p_bnr_attribute24               => p_bnr_attribute24
    ,p_bnr_attribute25               => p_bnr_attribute25
    ,p_bnr_attribute26               => p_bnr_attribute26
    ,p_bnr_attribute27               => p_bnr_attribute27
    ,p_bnr_attribute28               => p_bnr_attribute28
    ,p_bnr_attribute29               => p_bnr_attribute29
    ,p_bnr_attribute30               => p_bnr_attribute30
    ,p_function_code                 => p_function_code
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_ordr_num                      => p_ordr_num                           --iRec
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Reporting_Group
    --
    ben_Reporting_Group_bk1.create_Reporting_Group_a
      (
       p_rptg_grp_id                    =>  l_rptg_grp_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_rptg_prps_cd                   =>  p_rptg_prps_cd
      ,p_rpg_desc                       =>  p_rpg_desc
      ,p_bnr_attribute_category         =>  p_bnr_attribute_category
      ,p_bnr_attribute1                 =>  p_bnr_attribute1
      ,p_bnr_attribute2                 =>  p_bnr_attribute2
      ,p_bnr_attribute3                 =>  p_bnr_attribute3
      ,p_bnr_attribute4                 =>  p_bnr_attribute4
      ,p_bnr_attribute5                 =>  p_bnr_attribute5
      ,p_bnr_attribute6                 =>  p_bnr_attribute6
      ,p_bnr_attribute7                 =>  p_bnr_attribute7
      ,p_bnr_attribute8                 =>  p_bnr_attribute8
      ,p_bnr_attribute9                 =>  p_bnr_attribute9
      ,p_bnr_attribute10                =>  p_bnr_attribute10
      ,p_bnr_attribute11                =>  p_bnr_attribute11
      ,p_bnr_attribute12                =>  p_bnr_attribute12
      ,p_bnr_attribute13                =>  p_bnr_attribute13
      ,p_bnr_attribute14                =>  p_bnr_attribute14
      ,p_bnr_attribute15                =>  p_bnr_attribute15
      ,p_bnr_attribute16                =>  p_bnr_attribute16
      ,p_bnr_attribute17                =>  p_bnr_attribute17
      ,p_bnr_attribute18                =>  p_bnr_attribute18
      ,p_bnr_attribute19                =>  p_bnr_attribute19
      ,p_bnr_attribute20                =>  p_bnr_attribute20
      ,p_bnr_attribute21                =>  p_bnr_attribute21
      ,p_bnr_attribute22                =>  p_bnr_attribute22
      ,p_bnr_attribute23                =>  p_bnr_attribute23
      ,p_bnr_attribute24                =>  p_bnr_attribute24
      ,p_bnr_attribute25                =>  p_bnr_attribute25
      ,p_bnr_attribute26                =>  p_bnr_attribute26
      ,p_bnr_attribute27                =>  p_bnr_attribute27
      ,p_bnr_attribute28                =>  p_bnr_attribute28
      ,p_bnr_attribute29                =>  p_bnr_attribute29
      ,p_bnr_attribute30                =>  p_bnr_attribute30
      ,p_function_code                  =>  p_function_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_ordr_num                       =>  p_ordr_num                       --iRec
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Reporting_Group'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Reporting_Group
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
  p_rptg_grp_id := l_rptg_grp_id;
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
    ROLLBACK TO create_Reporting_Group;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_rptg_grp_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Reporting_Group;
    p_rptg_grp_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_Reporting_Group;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Reporting_Group >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Reporting_Group
  (p_validate                       in  boolean   default false
  ,p_rptg_grp_id                    in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_rptg_prps_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_rpg_desc                       in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bnr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_function_code                  in  varchar2  default hr_api.g_varchar2
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_ordr_num                       in  number    default hr_api.g_number           --iRec
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Reporting_Group';
  l_object_version_number ben_rptg_grp.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Reporting_Group;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Reporting_Group
    --
    ben_Reporting_Group_bk2.update_Reporting_Group_b
      (
       p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_rptg_prps_cd                   =>  p_rptg_prps_cd
      ,p_rpg_desc                       =>  p_rpg_desc
      ,p_bnr_attribute_category         =>  p_bnr_attribute_category
      ,p_bnr_attribute1                 =>  p_bnr_attribute1
      ,p_bnr_attribute2                 =>  p_bnr_attribute2
      ,p_bnr_attribute3                 =>  p_bnr_attribute3
      ,p_bnr_attribute4                 =>  p_bnr_attribute4
      ,p_bnr_attribute5                 =>  p_bnr_attribute5
      ,p_bnr_attribute6                 =>  p_bnr_attribute6
      ,p_bnr_attribute7                 =>  p_bnr_attribute7
      ,p_bnr_attribute8                 =>  p_bnr_attribute8
      ,p_bnr_attribute9                 =>  p_bnr_attribute9
      ,p_bnr_attribute10                =>  p_bnr_attribute10
      ,p_bnr_attribute11                =>  p_bnr_attribute11
      ,p_bnr_attribute12                =>  p_bnr_attribute12
      ,p_bnr_attribute13                =>  p_bnr_attribute13
      ,p_bnr_attribute14                =>  p_bnr_attribute14
      ,p_bnr_attribute15                =>  p_bnr_attribute15
      ,p_bnr_attribute16                =>  p_bnr_attribute16
      ,p_bnr_attribute17                =>  p_bnr_attribute17
      ,p_bnr_attribute18                =>  p_bnr_attribute18
      ,p_bnr_attribute19                =>  p_bnr_attribute19
      ,p_bnr_attribute20                =>  p_bnr_attribute20
      ,p_bnr_attribute21                =>  p_bnr_attribute21
      ,p_bnr_attribute22                =>  p_bnr_attribute22
      ,p_bnr_attribute23                =>  p_bnr_attribute23
      ,p_bnr_attribute24                =>  p_bnr_attribute24
      ,p_bnr_attribute25                =>  p_bnr_attribute25
      ,p_bnr_attribute26                =>  p_bnr_attribute26
      ,p_bnr_attribute27                =>  p_bnr_attribute27
      ,p_bnr_attribute28                =>  p_bnr_attribute28
      ,p_bnr_attribute29                =>  p_bnr_attribute29
      ,p_bnr_attribute30                =>  p_bnr_attribute30
      ,p_function_code                  =>  p_function_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
      ,p_ordr_num                       =>  p_ordr_num                    --iRec
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Reporting_Group'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Reporting_Group
    --
  end;
  --
  ben_bnr_upd.upd
    (
     p_rptg_grp_id                   => p_rptg_grp_id
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_rptg_prps_cd                  => p_rptg_prps_cd
    ,p_rpg_desc                      => p_rpg_desc
    ,p_bnr_attribute_category        => p_bnr_attribute_category
    ,p_bnr_attribute1                => p_bnr_attribute1
    ,p_bnr_attribute2                => p_bnr_attribute2
    ,p_bnr_attribute3                => p_bnr_attribute3
    ,p_bnr_attribute4                => p_bnr_attribute4
    ,p_bnr_attribute5                => p_bnr_attribute5
    ,p_bnr_attribute6                => p_bnr_attribute6
    ,p_bnr_attribute7                => p_bnr_attribute7
    ,p_bnr_attribute8                => p_bnr_attribute8
    ,p_bnr_attribute9                => p_bnr_attribute9
    ,p_bnr_attribute10               => p_bnr_attribute10
    ,p_bnr_attribute11               => p_bnr_attribute11
    ,p_bnr_attribute12               => p_bnr_attribute12
    ,p_bnr_attribute13               => p_bnr_attribute13
    ,p_bnr_attribute14               => p_bnr_attribute14
    ,p_bnr_attribute15               => p_bnr_attribute15
    ,p_bnr_attribute16               => p_bnr_attribute16
    ,p_bnr_attribute17               => p_bnr_attribute17
    ,p_bnr_attribute18               => p_bnr_attribute18
    ,p_bnr_attribute19               => p_bnr_attribute19
    ,p_bnr_attribute20               => p_bnr_attribute20
    ,p_bnr_attribute21               => p_bnr_attribute21
    ,p_bnr_attribute22               => p_bnr_attribute22
    ,p_bnr_attribute23               => p_bnr_attribute23
    ,p_bnr_attribute24               => p_bnr_attribute24
    ,p_bnr_attribute25               => p_bnr_attribute25
    ,p_bnr_attribute26               => p_bnr_attribute26
    ,p_bnr_attribute27               => p_bnr_attribute27
    ,p_bnr_attribute28               => p_bnr_attribute28
    ,p_bnr_attribute29               => p_bnr_attribute29
    ,p_bnr_attribute30               => p_bnr_attribute30
    ,p_function_code                 => p_function_code
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_ordr_num                      => p_ordr_num           --iRec
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Reporting_Group
    --
    ben_Reporting_Group_bk2.update_Reporting_Group_a
      (
       p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_rptg_prps_cd                   =>  p_rptg_prps_cd
      ,p_rpg_desc                       =>  p_rpg_desc
      ,p_bnr_attribute_category         =>  p_bnr_attribute_category
      ,p_bnr_attribute1                 =>  p_bnr_attribute1
      ,p_bnr_attribute2                 =>  p_bnr_attribute2
      ,p_bnr_attribute3                 =>  p_bnr_attribute3
      ,p_bnr_attribute4                 =>  p_bnr_attribute4
      ,p_bnr_attribute5                 =>  p_bnr_attribute5
      ,p_bnr_attribute6                 =>  p_bnr_attribute6
      ,p_bnr_attribute7                 =>  p_bnr_attribute7
      ,p_bnr_attribute8                 =>  p_bnr_attribute8
      ,p_bnr_attribute9                 =>  p_bnr_attribute9
      ,p_bnr_attribute10                =>  p_bnr_attribute10
      ,p_bnr_attribute11                =>  p_bnr_attribute11
      ,p_bnr_attribute12                =>  p_bnr_attribute12
      ,p_bnr_attribute13                =>  p_bnr_attribute13
      ,p_bnr_attribute14                =>  p_bnr_attribute14
      ,p_bnr_attribute15                =>  p_bnr_attribute15
      ,p_bnr_attribute16                =>  p_bnr_attribute16
      ,p_bnr_attribute17                =>  p_bnr_attribute17
      ,p_bnr_attribute18                =>  p_bnr_attribute18
      ,p_bnr_attribute19                =>  p_bnr_attribute19
      ,p_bnr_attribute20                =>  p_bnr_attribute20
      ,p_bnr_attribute21                =>  p_bnr_attribute21
      ,p_bnr_attribute22                =>  p_bnr_attribute22
      ,p_bnr_attribute23                =>  p_bnr_attribute23
      ,p_bnr_attribute24                =>  p_bnr_attribute24
      ,p_bnr_attribute25                =>  p_bnr_attribute25
      ,p_bnr_attribute26                =>  p_bnr_attribute26
      ,p_bnr_attribute27                =>  p_bnr_attribute27
      ,p_bnr_attribute28                =>  p_bnr_attribute28
      ,p_bnr_attribute29                =>  p_bnr_attribute29
      ,p_bnr_attribute30                =>  p_bnr_attribute30
      ,p_function_code                  =>  p_function_code
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_ordr_num                       =>  p_ordr_num                        --iRec
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Reporting_Group'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Reporting_Group
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
    ROLLBACK TO update_Reporting_Group;
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
    ROLLBACK TO update_Reporting_Group;
    raise;
    --
end update_Reporting_Group;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Reporting_Group >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Reporting_Group
  (p_validate                       in  boolean  default false
  ,p_rptg_grp_id                    in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Reporting_Group';
  l_object_version_number ben_rptg_grp.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Reporting_Group;
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
    -- Start of API User Hook for the before hook of delete_Reporting_Group
    --
    ben_Reporting_Group_bk3.delete_Reporting_Group_b
      (
       p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Reporting_Group'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Reporting_Group
    --
  end;
  --
  ben_bnr_del.del
    (
     p_rptg_grp_id                   => p_rptg_grp_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Reporting_Group
    --
    ben_Reporting_Group_bk3.delete_Reporting_Group_a
      (
       p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Reporting_Group'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Reporting_Group
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
    ROLLBACK TO delete_Reporting_Group;
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
    ROLLBACK TO delete_Reporting_Group;
    raise;
    --
end delete_Reporting_Group;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_rptg_grp_id                   in     number
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
  ben_bnr_shd.lck
    (
      p_rptg_grp_id                 => p_rptg_grp_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Reporting_Group_api;

/
