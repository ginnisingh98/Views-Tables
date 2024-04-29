--------------------------------------------------------
--  DDL for Package Body BEN_CWB_WKSHT_GRP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_WKSHT_GRP_API" as
/* $Header: becwgapi.pkb 120.0 2005/05/28 01:29:32 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_cwb_wksht_grp_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_cwb_wksht_grp >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwb_wksht_grp
(
   p_validate                       in boolean    default false
  ,p_business_group_id              in number
  ,p_pl_id                          in number
  ,p_ordr_num                       in number
  ,p_wksht_grp_cd                   in varchar2
  ,p_label                          in varchar2
  ,p_cwg_attribute_category         in varchar2     default null
  ,p_cwg_attribute1                 in varchar2     default null
  ,p_cwg_attribute2                 in varchar2     default null
  ,p_cwg_attribute3                 in varchar2     default null
  ,p_cwg_attribute4                 in varchar2     default null
  ,p_cwg_attribute5                 in varchar2     default null
  ,p_cwg_attribute6                 in varchar2     default null
  ,p_cwg_attribute7                 in varchar2     default null
  ,p_cwg_attribute8                 in varchar2     default null
  ,p_cwg_attribute9                 in varchar2     default null
  ,p_cwg_attribute10                in varchar2     default null
  ,p_cwg_attribute11                in varchar2     default null
  ,p_cwg_attribute12                in varchar2     default null
  ,p_cwg_attribute13                in varchar2     default null
  ,p_cwg_attribute14                in varchar2     default null
  ,p_cwg_attribute15                in varchar2     default null
  ,p_cwg_attribute16                in varchar2     default null
  ,p_cwg_attribute17                in varchar2     default null
  ,p_cwg_attribute18                in varchar2     default null
  ,p_cwg_attribute19                in varchar2     default null
  ,p_cwg_attribute20                in varchar2     default null
  ,p_cwg_attribute21                in varchar2     default null
  ,p_cwg_attribute22                in varchar2     default null
  ,p_cwg_attribute23                in varchar2     default null
  ,p_cwg_attribute24                in varchar2     default null
  ,p_cwg_attribute25                in varchar2     default null
  ,p_cwg_attribute26                in varchar2     default null
  ,p_cwg_attribute27                in varchar2     default null
  ,p_cwg_attribute28                in varchar2     default null
  ,p_cwg_attribute29                in varchar2     default null
  ,p_cwg_attribute30                in varchar2     default null
  ,p_status_cd                      in varchar2     default null
  ,p_hidden_cd                    in varchar2     default null
  ,p_effective_date                 in  date
  ,p_cwb_wksht_grp_id               out nocopy number
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cwb_wksht_grp_id  number;
  l_proc varchar2(72) := g_package||'create_cwb_wksht_grp';
  l_object_version_number  number;
  --

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_cwb_wksht_grp;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_cwb_wksht_grp
    --
    ben_cwb_wksht_grp_bk1.create_cwb_wksht_grp_b
      (
       p_cwb_wksht_grp_id           => p_cwb_wksht_grp_id
      ,p_business_group_id          =>  p_business_group_id
      ,p_pl_id                      => p_pl_id
      ,p_ordr_num                   => p_ordr_num
      ,p_wksht_grp_cd               => p_wksht_grp_cd
      ,p_label                      => p_label
      ,p_cwg_attribute_category     => p_cwg_attribute_category
      ,p_cwg_attribute1             => p_cwg_attribute1
      ,p_cwg_attribute2             => p_cwg_attribute2
      ,p_cwg_attribute3             => p_cwg_attribute3
      ,p_cwg_attribute4             => p_cwg_attribute4
      ,p_cwg_attribute5             => p_cwg_attribute5
      ,p_cwg_attribute6             => p_cwg_attribute6
      ,p_cwg_attribute7             => p_cwg_attribute7
      ,p_cwg_attribute8             => p_cwg_attribute8
      ,p_cwg_attribute9             => p_cwg_attribute9
      ,p_cwg_attribute10            => p_cwg_attribute10
      ,p_cwg_attribute11            => p_cwg_attribute11
      ,p_cwg_attribute12            => p_cwg_attribute12
      ,p_cwg_attribute13            => p_cwg_attribute13
      ,p_cwg_attribute14            => p_cwg_attribute14
      ,p_cwg_attribute15            => p_cwg_attribute15
      ,p_cwg_attribute16            => p_cwg_attribute16
      ,p_cwg_attribute17            => p_cwg_attribute17
      ,p_cwg_attribute18            => p_cwg_attribute18
      ,p_cwg_attribute19            => p_cwg_attribute19
      ,p_cwg_attribute20            => p_cwg_attribute20
      ,p_cwg_attribute21            => p_cwg_attribute21
      ,p_cwg_attribute22            => p_cwg_attribute22
      ,p_cwg_attribute23            => p_cwg_attribute23
      ,p_cwg_attribute24            => p_cwg_attribute24
      ,p_cwg_attribute25            => p_cwg_attribute25
      ,p_cwg_attribute26            => p_cwg_attribute26
      ,p_cwg_attribute27            => p_cwg_attribute27
      ,p_cwg_attribute28            => p_cwg_attribute28
      ,p_cwg_attribute29            => p_cwg_attribute29
      ,p_cwg_attribute30            => p_cwg_attribute30
      ,p_status_cd                  => p_status_cd
      ,p_hidden_cd                => p_hidden_cd
      ,p_object_version_number      => p_object_version_number
      ,p_effective_date             => p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_cwb_wksht_grp'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_cwb_wksht_grp
    --
  end;
  --
  hr_utility.set_location('hiden flag ' || p_hidden_cd , 99 );
  ---
  ben_cwg_ins.ins
  (
     p_effective_date             => p_effective_date
    ,p_business_group_id          => p_business_group_id
    ,p_pl_id                      => p_pl_id
    ,p_ordr_num                   => p_ordr_num
    ,p_wksht_grp_cd               => p_wksht_grp_cd
    ,p_label                      => p_label
    ,p_cwg_attribute_category     => p_cwg_attribute_category
    ,p_cwg_attribute1             => p_cwg_attribute1
    ,p_cwg_attribute2             => p_cwg_attribute2
    ,p_cwg_attribute3             => p_cwg_attribute3
    ,p_cwg_attribute4             => p_cwg_attribute4
    ,p_cwg_attribute5             => p_cwg_attribute5
    ,p_cwg_attribute6             => p_cwg_attribute6
    ,p_cwg_attribute7             => p_cwg_attribute7
    ,p_cwg_attribute8             => p_cwg_attribute8
    ,p_cwg_attribute9             => p_cwg_attribute9
    ,p_cwg_attribute10            => p_cwg_attribute10
    ,p_cwg_attribute11            => p_cwg_attribute11
    ,p_cwg_attribute12            => p_cwg_attribute12
    ,p_cwg_attribute13            => p_cwg_attribute13
    ,p_cwg_attribute14            => p_cwg_attribute14
    ,p_cwg_attribute15            => p_cwg_attribute15
    ,p_cwg_attribute16            => p_cwg_attribute16
    ,p_cwg_attribute17            => p_cwg_attribute17
    ,p_cwg_attribute18            => p_cwg_attribute18
    ,p_cwg_attribute19            => p_cwg_attribute19
    ,p_cwg_attribute20            => p_cwg_attribute20
    ,p_cwg_attribute21            => p_cwg_attribute21
    ,p_cwg_attribute22            => p_cwg_attribute22
    ,p_cwg_attribute23            => p_cwg_attribute23
    ,p_cwg_attribute24            => p_cwg_attribute24
    ,p_cwg_attribute25            => p_cwg_attribute25
    ,p_cwg_attribute26            => p_cwg_attribute26
    ,p_cwg_attribute27            => p_cwg_attribute27
    ,p_cwg_attribute28            => p_cwg_attribute28
    ,p_cwg_attribute29            => p_cwg_attribute29
    ,p_cwg_attribute30            => p_cwg_attribute30
    ,p_status_cd                  => p_status_cd
    ,p_hidden_cd                => p_hidden_cd
    ,p_cwb_wksht_grp_id           => l_cwb_wksht_grp_id
    ,p_object_version_number      => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_cwb_wksht_grp
    --
    ben_cwb_wksht_grp_bk1.create_cwb_wksht_grp_a
      (
       p_cwb_wksht_grp_id           => p_cwb_wksht_grp_id
      ,p_business_group_id          =>  p_business_group_id
      ,p_pl_id                      => p_pl_id
      ,p_ordr_num                   => p_ordr_num
      ,p_wksht_grp_cd               => p_wksht_grp_cd
      ,p_label                      => p_label
      ,p_cwg_attribute_category     => p_cwg_attribute_category
      ,p_cwg_attribute1             => p_cwg_attribute1
      ,p_cwg_attribute2             => p_cwg_attribute2
      ,p_cwg_attribute3             => p_cwg_attribute3
      ,p_cwg_attribute4             => p_cwg_attribute4
      ,p_cwg_attribute5             => p_cwg_attribute5
      ,p_cwg_attribute6             => p_cwg_attribute6
      ,p_cwg_attribute7             => p_cwg_attribute7
      ,p_cwg_attribute8             => p_cwg_attribute8
      ,p_cwg_attribute9             => p_cwg_attribute9
      ,p_cwg_attribute10            => p_cwg_attribute10
      ,p_cwg_attribute11            => p_cwg_attribute11
      ,p_cwg_attribute12            => p_cwg_attribute12
      ,p_cwg_attribute13            => p_cwg_attribute13
      ,p_cwg_attribute14            => p_cwg_attribute14
      ,p_cwg_attribute15            => p_cwg_attribute15
      ,p_cwg_attribute16            => p_cwg_attribute16
      ,p_cwg_attribute17            => p_cwg_attribute17
      ,p_cwg_attribute18            => p_cwg_attribute18
      ,p_cwg_attribute19            => p_cwg_attribute19
      ,p_cwg_attribute20            => p_cwg_attribute20
      ,p_cwg_attribute21            => p_cwg_attribute21
      ,p_cwg_attribute22            => p_cwg_attribute22
      ,p_cwg_attribute23            => p_cwg_attribute23
      ,p_cwg_attribute24            => p_cwg_attribute24
      ,p_cwg_attribute25            => p_cwg_attribute25
      ,p_cwg_attribute26            => p_cwg_attribute26
      ,p_cwg_attribute27            => p_cwg_attribute27
      ,p_cwg_attribute28            => p_cwg_attribute28
      ,p_cwg_attribute29            => p_cwg_attribute29
      ,p_cwg_attribute30            => p_cwg_attribute30
      ,p_status_cd                  => p_status_cd
      ,p_hidden_cd                => p_hidden_cd
      ,p_object_version_number      => p_object_version_number
      ,p_effective_date             => p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cwb_wksht_grp'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_cwb_wksht_grp
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
  p_cwb_wksht_grp_id := l_cwb_wksht_grp_id;
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
    ROLLBACK TO create_cwb_wksht_grp;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cwb_wksht_grp_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_cwb_wksht_grp;
    raise;
    --
end create_cwb_wksht_grp;
-- ----------------------------------------------------------------------------
-- |------------------------< update_cwb_wksht_grp >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cwb_wksht_grp
  (
   p_validate                       in boolean      default false
  ,p_business_group_id              in number
  ,p_cwb_wksht_grp_id               in number
  ,p_pl_id                          in number       default hr_api.g_number
  ,p_ordr_num                       in number       default hr_api.g_number
  ,p_wksht_grp_cd                   in varchar2     default hr_api.g_varchar2
  ,p_label                          in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute_category         in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute1                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute2                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute3                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute4                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute5                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute6                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute7                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute8                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute9                 in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute10                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute11                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute12                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute13                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute14                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute15                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute16                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute17                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute18                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute19                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute20                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute21                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute22                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute23                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute24                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute25                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute26                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute27                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute28                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute29                in varchar2     default hr_api.g_varchar2
  ,p_cwg_attribute30                in varchar2     default hr_api.g_varchar2
  ,p_status_cd                      in varchar2     default hr_api.g_varchar2
  ,p_hidden_cd                    in varchar2     default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_cwb_wksht_grp_id number;
  l_proc varchar2(72) := g_package||'update_cwb_wksht_grp';
  l_object_version_number ben_cwb_wksht_grp.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_cwb_wksht_grp;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_cwb_wksht_grp_id := p_cwb_wksht_grp_id;
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_cwb_wksht_grp
    --
    ben_cwb_wksht_grp_bk2.update_cwb_wksht_grp_b
      (
        p_cwb_wksht_grp_id         => p_cwb_wksht_grp_id
       ,p_business_group_id        =>  p_business_group_id
       ,p_pl_id                    => p_pl_id
       ,p_ordr_num                 => p_ordr_num
       ,p_wksht_grp_cd             => p_wksht_grp_cd
       ,p_label                    => p_label
       ,p_cwg_attribute_category   => p_cwg_attribute_category
       ,p_cwg_attribute1           => p_cwg_attribute1
       ,p_cwg_attribute2           => p_cwg_attribute2
       ,p_cwg_attribute3           => p_cwg_attribute3
       ,p_cwg_attribute4           => p_cwg_attribute4
       ,p_cwg_attribute5           => p_cwg_attribute5
       ,p_cwg_attribute6           => p_cwg_attribute6
       ,p_cwg_attribute7           => p_cwg_attribute7
       ,p_cwg_attribute8           => p_cwg_attribute8
       ,p_cwg_attribute9           => p_cwg_attribute9
       ,p_cwg_attribute10          => p_cwg_attribute10
       ,p_cwg_attribute11          => p_cwg_attribute11
       ,p_cwg_attribute12          => p_cwg_attribute12
       ,p_cwg_attribute13          => p_cwg_attribute13
       ,p_cwg_attribute14          => p_cwg_attribute14
       ,p_cwg_attribute15          => p_cwg_attribute15
       ,p_cwg_attribute16          => p_cwg_attribute16
       ,p_cwg_attribute17          => p_cwg_attribute17
       ,p_cwg_attribute18          => p_cwg_attribute18
       ,p_cwg_attribute19          => p_cwg_attribute19
       ,p_cwg_attribute20          => p_cwg_attribute20
       ,p_cwg_attribute21          => p_cwg_attribute21
       ,p_cwg_attribute22          => p_cwg_attribute22
       ,p_cwg_attribute23          => p_cwg_attribute23
       ,p_cwg_attribute24          => p_cwg_attribute24
       ,p_cwg_attribute25          => p_cwg_attribute25
       ,p_cwg_attribute26          => p_cwg_attribute26
       ,p_cwg_attribute27          => p_cwg_attribute27
       ,p_cwg_attribute28          => p_cwg_attribute28
       ,p_cwg_attribute29          => p_cwg_attribute29
       ,p_cwg_attribute30          => p_cwg_attribute30
       ,p_status_cd                  => p_status_cd
       ,p_hidden_cd                 => p_hidden_cd
       ,p_object_version_number    => p_object_version_number
       ,p_effective_date           => p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cwb_wksht_grp'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_cwb_wksht_grp
    --
  end;
  ---
  ben_cwg_upd.upd
  (
     p_effective_date             => p_effective_date
    ,p_ordr_num                   => p_ordr_num
    ,p_wksht_grp_cd               => p_wksht_grp_cd
    ,p_label                      => p_label
    ,p_cwb_wksht_grp_id           => l_cwb_wksht_grp_id
    ,p_cwg_attribute_category     => p_cwg_attribute_category
    ,p_cwg_attribute1             => p_cwg_attribute1
    ,p_cwg_attribute2             => p_cwg_attribute2
    ,p_cwg_attribute3             => p_cwg_attribute3
    ,p_cwg_attribute4             => p_cwg_attribute4
    ,p_cwg_attribute5             => p_cwg_attribute5
    ,p_cwg_attribute6             => p_cwg_attribute6
    ,p_cwg_attribute7             => p_cwg_attribute7
    ,p_cwg_attribute8             => p_cwg_attribute8
    ,p_cwg_attribute9             => p_cwg_attribute9
    ,p_cwg_attribute10            => p_cwg_attribute10
    ,p_cwg_attribute11            => p_cwg_attribute11
    ,p_cwg_attribute12            => p_cwg_attribute12
    ,p_cwg_attribute13            => p_cwg_attribute13
    ,p_cwg_attribute14            => p_cwg_attribute14
    ,p_cwg_attribute15            => p_cwg_attribute15
    ,p_cwg_attribute16            => p_cwg_attribute16
    ,p_cwg_attribute17            => p_cwg_attribute17
    ,p_cwg_attribute18            => p_cwg_attribute18
    ,p_cwg_attribute19            => p_cwg_attribute19
    ,p_cwg_attribute20            => p_cwg_attribute20
    ,p_cwg_attribute21            => p_cwg_attribute21
    ,p_cwg_attribute22            => p_cwg_attribute22
    ,p_cwg_attribute23            => p_cwg_attribute23
    ,p_cwg_attribute24            => p_cwg_attribute24
    ,p_cwg_attribute25            => p_cwg_attribute25
    ,p_cwg_attribute26            => p_cwg_attribute26
    ,p_cwg_attribute27            => p_cwg_attribute27
    ,p_cwg_attribute28            => p_cwg_attribute28
    ,p_cwg_attribute29            => p_cwg_attribute29
    ,p_cwg_attribute30            => p_cwg_attribute30
    ,p_status_cd                  => p_status_cd
    ,p_hidden_cd                => p_hidden_cd
    ,p_object_version_number      => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_cwb_wksht_grp
    --
    ben_cwb_wksht_grp_bk2.update_cwb_wksht_grp_a
      (
        p_cwb_wksht_grp_id         => p_cwb_wksht_grp_id
       ,p_business_group_id        => p_business_group_id
       ,p_pl_id                    => p_pl_id
       ,p_ordr_num                 => p_ordr_num
       ,p_wksht_grp_cd             => p_wksht_grp_cd
       ,p_label                    => p_label
       ,p_cwg_attribute_category   => p_cwg_attribute_category
       ,p_cwg_attribute1           => p_cwg_attribute1
       ,p_cwg_attribute2           => p_cwg_attribute2
       ,p_cwg_attribute3           => p_cwg_attribute3
       ,p_cwg_attribute4           => p_cwg_attribute4
       ,p_cwg_attribute5           => p_cwg_attribute5
       ,p_cwg_attribute6           => p_cwg_attribute6
       ,p_cwg_attribute7           => p_cwg_attribute7
       ,p_cwg_attribute8           => p_cwg_attribute8
       ,p_cwg_attribute9           => p_cwg_attribute9
       ,p_cwg_attribute10          => p_cwg_attribute10
       ,p_cwg_attribute11          => p_cwg_attribute11
       ,p_cwg_attribute12          => p_cwg_attribute12
       ,p_cwg_attribute13          => p_cwg_attribute13
       ,p_cwg_attribute14          => p_cwg_attribute14
       ,p_cwg_attribute15          => p_cwg_attribute15
       ,p_cwg_attribute16          => p_cwg_attribute16
       ,p_cwg_attribute17          => p_cwg_attribute17
       ,p_cwg_attribute18          => p_cwg_attribute18
       ,p_cwg_attribute19          => p_cwg_attribute19
       ,p_cwg_attribute20          => p_cwg_attribute20
       ,p_cwg_attribute21          => p_cwg_attribute21
       ,p_cwg_attribute22          => p_cwg_attribute22
       ,p_cwg_attribute23          => p_cwg_attribute23
       ,p_cwg_attribute24          => p_cwg_attribute24
       ,p_cwg_attribute25          => p_cwg_attribute25
       ,p_cwg_attribute26          => p_cwg_attribute26
       ,p_cwg_attribute27          => p_cwg_attribute27
       ,p_cwg_attribute28          => p_cwg_attribute28
       ,p_cwg_attribute29          => p_cwg_attribute29
       ,p_cwg_attribute30          => p_cwg_attribute30
       ,p_status_cd                => p_status_cd
       ,p_hidden_cd                => p_hidden_cd
       ,p_object_version_number    => p_object_version_number
       ,p_effective_date           => p_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cwb_wksht_grp'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_cwb_wksht_grp
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
    ROLLBACK TO update_cwb_wksht_grp;
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
    ROLLBACK TO update_cwb_wksht_grp;
    p_object_version_number  := l_object_version_number;
    raise;
    --
end update_cwb_wksht_grp;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_cwb_wksht_grp >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cwb_wksht_grp
  (p_validate                       in  boolean  default false
  ,p_cwb_wksht_grp_id               in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_cwb_wksht_grp';
  l_object_version_number ben_cwb_wksht_grp.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_cwb_wksht_grp;
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
    -- Start of API User Hook for the before hook of delete_cwb_wksht_grp
    --
    ben_cwb_wksht_grp_bk3.delete_cwb_wksht_grp_b
      (
       p_cwb_wksht_grp_id                =>  p_cwb_wksht_grp_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cwb_wksht_grp'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_cwb_wksht_grp
    --
  end;
  --
  ben_cwg_del.del
    (
     p_cwb_wksht_grp_id          => p_cwb_wksht_grp_id
    ,p_object_version_number     => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_cwb_wksht_grp
    --
    ben_cwb_wksht_grp_bk3.delete_cwb_wksht_grp_a
      (
       p_cwb_wksht_grp_id                =>  p_cwb_wksht_grp_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cwb_wksht_grp'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_cwb_wksht_grp
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
    ROLLBACK TO delete_cwb_wksht_grp;
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
    ROLLBACK TO delete_cwb_wksht_grp;
    p_object_version_number  := l_object_version_number;
    raise;
    --
end delete_cwb_wksht_grp;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_cwb_wksht_grp_id               in     number
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
  ben_cwg_shd.lck
    (
      p_cwb_wksht_grp_id           => p_cwb_wksht_grp_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_cwb_wksht_grp_api;

/
