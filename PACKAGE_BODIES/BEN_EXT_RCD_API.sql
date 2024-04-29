--------------------------------------------------------
--  DDL for Package Body BEN_EXT_RCD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_RCD_API" as
/* $Header: bexrcapi.pkb 115.4 2003/05/14 01:17:27 tjesumic ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_RCD_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_RCD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_RCD
  (p_validate                       in  boolean   default false
  ,p_ext_rcd_id                     out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_xml_tag_name                   in  varchar2  default null
  ,p_rcd_type_cd                    in  varchar2  default null
  ,p_low_lvl_cd                     in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_xrc_attribute_category         in  varchar2  default null
  ,p_xrc_attribute1                 in  varchar2  default null
  ,p_xrc_attribute2                 in  varchar2  default null
  ,p_xrc_attribute3                 in  varchar2  default null
  ,p_xrc_attribute4                 in  varchar2  default null
  ,p_xrc_attribute5                 in  varchar2  default null
  ,p_xrc_attribute6                 in  varchar2  default null
  ,p_xrc_attribute7                 in  varchar2  default null
  ,p_xrc_attribute8                 in  varchar2  default null
  ,p_xrc_attribute9                 in  varchar2  default null
  ,p_xrc_attribute10                in  varchar2  default null
  ,p_xrc_attribute11                in  varchar2  default null
  ,p_xrc_attribute12                in  varchar2  default null
  ,p_xrc_attribute13                in  varchar2  default null
  ,p_xrc_attribute14                in  varchar2  default null
  ,p_xrc_attribute15                in  varchar2  default null
  ,p_xrc_attribute16                in  varchar2  default null
  ,p_xrc_attribute17                in  varchar2  default null
  ,p_xrc_attribute18                in  varchar2  default null
  ,p_xrc_attribute19                in  varchar2  default null
  ,p_xrc_attribute20                in  varchar2  default null
  ,p_xrc_attribute21                in  varchar2  default null
  ,p_xrc_attribute22                in  varchar2  default null
  ,p_xrc_attribute23                in  varchar2  default null
  ,p_xrc_attribute24                in  varchar2  default null
  ,p_xrc_attribute25                in  varchar2  default null
  ,p_xrc_attribute26                in  varchar2  default null
  ,p_xrc_attribute27                in  varchar2  default null
  ,p_xrc_attribute28                in  varchar2  default null
  ,p_xrc_attribute29                in  varchar2  default null
  ,p_xrc_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_rcd_id ben_ext_rcd.ext_rcd_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_RCD';
  l_object_version_number ben_ext_rcd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_EXT_RCD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_RCD
    --
    ben_EXT_RCD_bk1.create_EXT_RCD_b
      (
       p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_rcd_type_cd                    =>  p_rcd_type_cd
      ,p_low_lvl_cd                     =>  p_low_lvl_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xrc_attribute_category         =>  p_xrc_attribute_category
      ,p_xrc_attribute1                 =>  p_xrc_attribute1
      ,p_xrc_attribute2                 =>  p_xrc_attribute2
      ,p_xrc_attribute3                 =>  p_xrc_attribute3
      ,p_xrc_attribute4                 =>  p_xrc_attribute4
      ,p_xrc_attribute5                 =>  p_xrc_attribute5
      ,p_xrc_attribute6                 =>  p_xrc_attribute6
      ,p_xrc_attribute7                 =>  p_xrc_attribute7
      ,p_xrc_attribute8                 =>  p_xrc_attribute8
      ,p_xrc_attribute9                 =>  p_xrc_attribute9
      ,p_xrc_attribute10                =>  p_xrc_attribute10
      ,p_xrc_attribute11                =>  p_xrc_attribute11
      ,p_xrc_attribute12                =>  p_xrc_attribute12
      ,p_xrc_attribute13                =>  p_xrc_attribute13
      ,p_xrc_attribute14                =>  p_xrc_attribute14
      ,p_xrc_attribute15                =>  p_xrc_attribute15
      ,p_xrc_attribute16                =>  p_xrc_attribute16
      ,p_xrc_attribute17                =>  p_xrc_attribute17
      ,p_xrc_attribute18                =>  p_xrc_attribute18
      ,p_xrc_attribute19                =>  p_xrc_attribute19
      ,p_xrc_attribute20                =>  p_xrc_attribute20
      ,p_xrc_attribute21                =>  p_xrc_attribute21
      ,p_xrc_attribute22                =>  p_xrc_attribute22
      ,p_xrc_attribute23                =>  p_xrc_attribute23
      ,p_xrc_attribute24                =>  p_xrc_attribute24
      ,p_xrc_attribute25                =>  p_xrc_attribute25
      ,p_xrc_attribute26                =>  p_xrc_attribute26
      ,p_xrc_attribute27                =>  p_xrc_attribute27
      ,p_xrc_attribute28                =>  p_xrc_attribute28
      ,p_xrc_attribute29                =>  p_xrc_attribute29
      ,p_xrc_attribute30                =>  p_xrc_attribute30
      ,p_effective_date               => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_RCD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_RCD
    --
  end;
  --
  ben_xrc_ins.ins
    (
     p_ext_rcd_id                    => l_ext_rcd_id
    ,p_name                          => p_name
    ,p_xml_tag_name                  => p_xml_tag_name
    ,p_rcd_type_cd                   => p_rcd_type_cd
    ,p_low_lvl_cd                    => p_low_lvl_cd
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_xrc_attribute_category        => p_xrc_attribute_category
    ,p_xrc_attribute1                => p_xrc_attribute1
    ,p_xrc_attribute2                => p_xrc_attribute2
    ,p_xrc_attribute3                => p_xrc_attribute3
    ,p_xrc_attribute4                => p_xrc_attribute4
    ,p_xrc_attribute5                => p_xrc_attribute5
    ,p_xrc_attribute6                => p_xrc_attribute6
    ,p_xrc_attribute7                => p_xrc_attribute7
    ,p_xrc_attribute8                => p_xrc_attribute8
    ,p_xrc_attribute9                => p_xrc_attribute9
    ,p_xrc_attribute10               => p_xrc_attribute10
    ,p_xrc_attribute11               => p_xrc_attribute11
    ,p_xrc_attribute12               => p_xrc_attribute12
    ,p_xrc_attribute13               => p_xrc_attribute13
    ,p_xrc_attribute14               => p_xrc_attribute14
    ,p_xrc_attribute15               => p_xrc_attribute15
    ,p_xrc_attribute16               => p_xrc_attribute16
    ,p_xrc_attribute17               => p_xrc_attribute17
    ,p_xrc_attribute18               => p_xrc_attribute18
    ,p_xrc_attribute19               => p_xrc_attribute19
    ,p_xrc_attribute20               => p_xrc_attribute20
    ,p_xrc_attribute21               => p_xrc_attribute21
    ,p_xrc_attribute22               => p_xrc_attribute22
    ,p_xrc_attribute23               => p_xrc_attribute23
    ,p_xrc_attribute24               => p_xrc_attribute24
    ,p_xrc_attribute25               => p_xrc_attribute25
    ,p_xrc_attribute26               => p_xrc_attribute26
    ,p_xrc_attribute27               => p_xrc_attribute27
    ,p_xrc_attribute28               => p_xrc_attribute28
    ,p_xrc_attribute29               => p_xrc_attribute29
    ,p_xrc_attribute30               => p_xrc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_RCD
    --
    ben_EXT_RCD_bk1.create_EXT_RCD_a
      (
       p_ext_rcd_id                     =>  l_ext_rcd_id
      ,p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_rcd_type_cd                    =>  p_rcd_type_cd
      ,p_low_lvl_cd                     =>  p_low_lvl_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xrc_attribute_category         =>  p_xrc_attribute_category
      ,p_xrc_attribute1                 =>  p_xrc_attribute1
      ,p_xrc_attribute2                 =>  p_xrc_attribute2
      ,p_xrc_attribute3                 =>  p_xrc_attribute3
      ,p_xrc_attribute4                 =>  p_xrc_attribute4
      ,p_xrc_attribute5                 =>  p_xrc_attribute5
      ,p_xrc_attribute6                 =>  p_xrc_attribute6
      ,p_xrc_attribute7                 =>  p_xrc_attribute7
      ,p_xrc_attribute8                 =>  p_xrc_attribute8
      ,p_xrc_attribute9                 =>  p_xrc_attribute9
      ,p_xrc_attribute10                =>  p_xrc_attribute10
      ,p_xrc_attribute11                =>  p_xrc_attribute11
      ,p_xrc_attribute12                =>  p_xrc_attribute12
      ,p_xrc_attribute13                =>  p_xrc_attribute13
      ,p_xrc_attribute14                =>  p_xrc_attribute14
      ,p_xrc_attribute15                =>  p_xrc_attribute15
      ,p_xrc_attribute16                =>  p_xrc_attribute16
      ,p_xrc_attribute17                =>  p_xrc_attribute17
      ,p_xrc_attribute18                =>  p_xrc_attribute18
      ,p_xrc_attribute19                =>  p_xrc_attribute19
      ,p_xrc_attribute20                =>  p_xrc_attribute20
      ,p_xrc_attribute21                =>  p_xrc_attribute21
      ,p_xrc_attribute22                =>  p_xrc_attribute22
      ,p_xrc_attribute23                =>  p_xrc_attribute23
      ,p_xrc_attribute24                =>  p_xrc_attribute24
      ,p_xrc_attribute25                =>  p_xrc_attribute25
      ,p_xrc_attribute26                =>  p_xrc_attribute26
      ,p_xrc_attribute27                =>  p_xrc_attribute27
      ,p_xrc_attribute28                =>  p_xrc_attribute28
      ,p_xrc_attribute29                =>  p_xrc_attribute29
      ,p_xrc_attribute30                =>  p_xrc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_RCD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_RCD
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
  p_ext_rcd_id := l_ext_rcd_id;
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
    ROLLBACK TO create_EXT_RCD;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_rcd_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_EXT_RCD;
        p_ext_rcd_id := null; --nocopy change
        p_object_version_number  := null; --nocopy change

    raise;
    --
end create_EXT_RCD;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_RCD >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_RCD
  (p_validate                       in  boolean   default false
  ,p_ext_rcd_id                     in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_xml_tag_name                   in  varchar2  default hr_api.g_varchar2
  ,p_rcd_type_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_low_lvl_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_xrc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_RCD';
  l_object_version_number ben_ext_rcd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_RCD;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_RCD
    --
    ben_EXT_RCD_bk2.update_EXT_RCD_b
      (
       p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_rcd_type_cd                    =>  p_rcd_type_cd
      ,p_low_lvl_cd                     =>  p_low_lvl_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xrc_attribute_category         =>  p_xrc_attribute_category
      ,p_xrc_attribute1                 =>  p_xrc_attribute1
      ,p_xrc_attribute2                 =>  p_xrc_attribute2
      ,p_xrc_attribute3                 =>  p_xrc_attribute3
      ,p_xrc_attribute4                 =>  p_xrc_attribute4
      ,p_xrc_attribute5                 =>  p_xrc_attribute5
      ,p_xrc_attribute6                 =>  p_xrc_attribute6
      ,p_xrc_attribute7                 =>  p_xrc_attribute7
      ,p_xrc_attribute8                 =>  p_xrc_attribute8
      ,p_xrc_attribute9                 =>  p_xrc_attribute9
      ,p_xrc_attribute10                =>  p_xrc_attribute10
      ,p_xrc_attribute11                =>  p_xrc_attribute11
      ,p_xrc_attribute12                =>  p_xrc_attribute12
      ,p_xrc_attribute13                =>  p_xrc_attribute13
      ,p_xrc_attribute14                =>  p_xrc_attribute14
      ,p_xrc_attribute15                =>  p_xrc_attribute15
      ,p_xrc_attribute16                =>  p_xrc_attribute16
      ,p_xrc_attribute17                =>  p_xrc_attribute17
      ,p_xrc_attribute18                =>  p_xrc_attribute18
      ,p_xrc_attribute19                =>  p_xrc_attribute19
      ,p_xrc_attribute20                =>  p_xrc_attribute20
      ,p_xrc_attribute21                =>  p_xrc_attribute21
      ,p_xrc_attribute22                =>  p_xrc_attribute22
      ,p_xrc_attribute23                =>  p_xrc_attribute23
      ,p_xrc_attribute24                =>  p_xrc_attribute24
      ,p_xrc_attribute25                =>  p_xrc_attribute25
      ,p_xrc_attribute26                =>  p_xrc_attribute26
      ,p_xrc_attribute27                =>  p_xrc_attribute27
      ,p_xrc_attribute28                =>  p_xrc_attribute28
      ,p_xrc_attribute29                =>  p_xrc_attribute29
      ,p_xrc_attribute30                =>  p_xrc_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_RCD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_RCD
    --
  end;
  --
  ben_xrc_upd.upd
    (
     p_ext_rcd_id                    => p_ext_rcd_id
    ,p_name                          => p_name
    ,p_xml_tag_name                  => p_xml_tag_name
    ,p_rcd_type_cd                   => p_rcd_type_cd
    ,p_low_lvl_cd                    => p_low_lvl_cd
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_xrc_attribute_category        => p_xrc_attribute_category
    ,p_xrc_attribute1                => p_xrc_attribute1
    ,p_xrc_attribute2                => p_xrc_attribute2
    ,p_xrc_attribute3                => p_xrc_attribute3
    ,p_xrc_attribute4                => p_xrc_attribute4
    ,p_xrc_attribute5                => p_xrc_attribute5
    ,p_xrc_attribute6                => p_xrc_attribute6
    ,p_xrc_attribute7                => p_xrc_attribute7
    ,p_xrc_attribute8                => p_xrc_attribute8
    ,p_xrc_attribute9                => p_xrc_attribute9
    ,p_xrc_attribute10               => p_xrc_attribute10
    ,p_xrc_attribute11               => p_xrc_attribute11
    ,p_xrc_attribute12               => p_xrc_attribute12
    ,p_xrc_attribute13               => p_xrc_attribute13
    ,p_xrc_attribute14               => p_xrc_attribute14
    ,p_xrc_attribute15               => p_xrc_attribute15
    ,p_xrc_attribute16               => p_xrc_attribute16
    ,p_xrc_attribute17               => p_xrc_attribute17
    ,p_xrc_attribute18               => p_xrc_attribute18
    ,p_xrc_attribute19               => p_xrc_attribute19
    ,p_xrc_attribute20               => p_xrc_attribute20
    ,p_xrc_attribute21               => p_xrc_attribute21
    ,p_xrc_attribute22               => p_xrc_attribute22
    ,p_xrc_attribute23               => p_xrc_attribute23
    ,p_xrc_attribute24               => p_xrc_attribute24
    ,p_xrc_attribute25               => p_xrc_attribute25
    ,p_xrc_attribute26               => p_xrc_attribute26
    ,p_xrc_attribute27               => p_xrc_attribute27
    ,p_xrc_attribute28               => p_xrc_attribute28
    ,p_xrc_attribute29               => p_xrc_attribute29
    ,p_xrc_attribute30               => p_xrc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_RCD
    --
    ben_EXT_RCD_bk2.update_EXT_RCD_a
      (
       p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_name                           =>  p_name
      ,p_xml_tag_name                   =>  p_xml_tag_name
      ,p_rcd_type_cd                    =>  p_rcd_type_cd
      ,p_low_lvl_cd                     =>  p_low_lvl_cd
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xrc_attribute_category         =>  p_xrc_attribute_category
      ,p_xrc_attribute1                 =>  p_xrc_attribute1
      ,p_xrc_attribute2                 =>  p_xrc_attribute2
      ,p_xrc_attribute3                 =>  p_xrc_attribute3
      ,p_xrc_attribute4                 =>  p_xrc_attribute4
      ,p_xrc_attribute5                 =>  p_xrc_attribute5
      ,p_xrc_attribute6                 =>  p_xrc_attribute6
      ,p_xrc_attribute7                 =>  p_xrc_attribute7
      ,p_xrc_attribute8                 =>  p_xrc_attribute8
      ,p_xrc_attribute9                 =>  p_xrc_attribute9
      ,p_xrc_attribute10                =>  p_xrc_attribute10
      ,p_xrc_attribute11                =>  p_xrc_attribute11
      ,p_xrc_attribute12                =>  p_xrc_attribute12
      ,p_xrc_attribute13                =>  p_xrc_attribute13
      ,p_xrc_attribute14                =>  p_xrc_attribute14
      ,p_xrc_attribute15                =>  p_xrc_attribute15
      ,p_xrc_attribute16                =>  p_xrc_attribute16
      ,p_xrc_attribute17                =>  p_xrc_attribute17
      ,p_xrc_attribute18                =>  p_xrc_attribute18
      ,p_xrc_attribute19                =>  p_xrc_attribute19
      ,p_xrc_attribute20                =>  p_xrc_attribute20
      ,p_xrc_attribute21                =>  p_xrc_attribute21
      ,p_xrc_attribute22                =>  p_xrc_attribute22
      ,p_xrc_attribute23                =>  p_xrc_attribute23
      ,p_xrc_attribute24                =>  p_xrc_attribute24
      ,p_xrc_attribute25                =>  p_xrc_attribute25
      ,p_xrc_attribute26                =>  p_xrc_attribute26
      ,p_xrc_attribute27                =>  p_xrc_attribute27
      ,p_xrc_attribute28                =>  p_xrc_attribute28
      ,p_xrc_attribute29                =>  p_xrc_attribute29
      ,p_xrc_attribute30                =>  p_xrc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_RCD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_RCD
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
    ROLLBACK TO update_EXT_RCD;
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
    ROLLBACK TO update_EXT_RCD;
    raise;
    --
end update_EXT_RCD;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_RCD >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_RCD
  (p_validate                       in  boolean  default false
  ,p_ext_rcd_id                     in  number
  ,p_legislation_code               in  varchar2  default null
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_RCD';
  l_object_version_number ben_ext_rcd.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_RCD;
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
    -- Start of API User Hook for the before hook of delete_EXT_RCD
    --
    ben_EXT_RCD_bk3.delete_EXT_RCD_b
      (
       p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_RCD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_RCD
    --
  end;
  --
  ben_xrc_del.del
    (
     p_ext_rcd_id                    => p_ext_rcd_id
    ,p_legislation_code              => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_RCD
    --
    ben_EXT_RCD_bk3.delete_EXT_RCD_a
      (
       p_ext_rcd_id                     =>  p_ext_rcd_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_RCD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_RCD
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
    ROLLBACK TO delete_EXT_RCD;
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
    ROLLBACK TO delete_EXT_RCD;
    raise;
    --
end delete_EXT_RCD;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_rcd_id                   in     number
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
  ben_xrc_shd.lck
    (
      p_ext_rcd_id                 => p_ext_rcd_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_EXT_RCD_api;

/
