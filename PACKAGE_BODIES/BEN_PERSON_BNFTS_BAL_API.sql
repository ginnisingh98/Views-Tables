--------------------------------------------------------
--  DDL for Package Body BEN_PERSON_BNFTS_BAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERSON_BNFTS_BAL_API" as
/* $Header: bepbbapi.pkb 115.3 2002/12/16 09:36:54 hnarayan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_person_bnfts_bal_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_person_bnfts_bal >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_bnfts_bal
  (p_validate                       in  boolean   default false
  ,p_per_bnfts_bal_id               out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_val                            in  number    default null
  ,p_bnfts_bal_id                   in  number    default null
  ,p_person_id                      in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pbb_attribute_category         in  varchar2  default null
  ,p_pbb_attribute1                 in  varchar2  default null
  ,p_pbb_attribute2                 in  varchar2  default null
  ,p_pbb_attribute3                 in  varchar2  default null
  ,p_pbb_attribute4                 in  varchar2  default null
  ,p_pbb_attribute5                 in  varchar2  default null
  ,p_pbb_attribute6                 in  varchar2  default null
  ,p_pbb_attribute7                 in  varchar2  default null
  ,p_pbb_attribute8                 in  varchar2  default null
  ,p_pbb_attribute9                 in  varchar2  default null
  ,p_pbb_attribute10                in  varchar2  default null
  ,p_pbb_attribute11                in  varchar2  default null
  ,p_pbb_attribute12                in  varchar2  default null
  ,p_pbb_attribute13                in  varchar2  default null
  ,p_pbb_attribute14                in  varchar2  default null
  ,p_pbb_attribute15                in  varchar2  default null
  ,p_pbb_attribute16                in  varchar2  default null
  ,p_pbb_attribute17                in  varchar2  default null
  ,p_pbb_attribute18                in  varchar2  default null
  ,p_pbb_attribute19                in  varchar2  default null
  ,p_pbb_attribute20                in  varchar2  default null
  ,p_pbb_attribute21                in  varchar2  default null
  ,p_pbb_attribute22                in  varchar2  default null
  ,p_pbb_attribute23                in  varchar2  default null
  ,p_pbb_attribute24                in  varchar2  default null
  ,p_pbb_attribute25                in  varchar2  default null
  ,p_pbb_attribute26                in  varchar2  default null
  ,p_pbb_attribute27                in  varchar2  default null
  ,p_pbb_attribute28                in  varchar2  default null
  ,p_pbb_attribute29                in  varchar2  default null
  ,p_pbb_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_per_bnfts_bal_id ben_per_bnfts_bal_f.per_bnfts_bal_id%TYPE;
  l_effective_start_date ben_per_bnfts_bal_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_bnfts_bal_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_person_bnfts_bal';
  l_object_version_number ben_per_bnfts_bal_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_person_bnfts_bal;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_person_bnfts_bal
    --
    ben_person_bnfts_bal_bk1.create_person_bnfts_bal_b
      (
       p_val                            =>  p_val
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbb_attribute_category         =>  p_pbb_attribute_category
      ,p_pbb_attribute1                 =>  p_pbb_attribute1
      ,p_pbb_attribute2                 =>  p_pbb_attribute2
      ,p_pbb_attribute3                 =>  p_pbb_attribute3
      ,p_pbb_attribute4                 =>  p_pbb_attribute4
      ,p_pbb_attribute5                 =>  p_pbb_attribute5
      ,p_pbb_attribute6                 =>  p_pbb_attribute6
      ,p_pbb_attribute7                 =>  p_pbb_attribute7
      ,p_pbb_attribute8                 =>  p_pbb_attribute8
      ,p_pbb_attribute9                 =>  p_pbb_attribute9
      ,p_pbb_attribute10                =>  p_pbb_attribute10
      ,p_pbb_attribute11                =>  p_pbb_attribute11
      ,p_pbb_attribute12                =>  p_pbb_attribute12
      ,p_pbb_attribute13                =>  p_pbb_attribute13
      ,p_pbb_attribute14                =>  p_pbb_attribute14
      ,p_pbb_attribute15                =>  p_pbb_attribute15
      ,p_pbb_attribute16                =>  p_pbb_attribute16
      ,p_pbb_attribute17                =>  p_pbb_attribute17
      ,p_pbb_attribute18                =>  p_pbb_attribute18
      ,p_pbb_attribute19                =>  p_pbb_attribute19
      ,p_pbb_attribute20                =>  p_pbb_attribute20
      ,p_pbb_attribute21                =>  p_pbb_attribute21
      ,p_pbb_attribute22                =>  p_pbb_attribute22
      ,p_pbb_attribute23                =>  p_pbb_attribute23
      ,p_pbb_attribute24                =>  p_pbb_attribute24
      ,p_pbb_attribute25                =>  p_pbb_attribute25
      ,p_pbb_attribute26                =>  p_pbb_attribute26
      ,p_pbb_attribute27                =>  p_pbb_attribute27
      ,p_pbb_attribute28                =>  p_pbb_attribute28
      ,p_pbb_attribute29                =>  p_pbb_attribute29
      ,p_pbb_attribute30                =>  p_pbb_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_person_bnfts_bal'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_person_bnfts_bal
    --
  end;
  --
  ben_pbb_ins.ins
    (
     p_per_bnfts_bal_id              => l_per_bnfts_bal_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_val                           => p_val
    ,p_bnfts_bal_id                  => p_bnfts_bal_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_pbb_attribute_category        => p_pbb_attribute_category
    ,p_pbb_attribute1                => p_pbb_attribute1
    ,p_pbb_attribute2                => p_pbb_attribute2
    ,p_pbb_attribute3                => p_pbb_attribute3
    ,p_pbb_attribute4                => p_pbb_attribute4
    ,p_pbb_attribute5                => p_pbb_attribute5
    ,p_pbb_attribute6                => p_pbb_attribute6
    ,p_pbb_attribute7                => p_pbb_attribute7
    ,p_pbb_attribute8                => p_pbb_attribute8
    ,p_pbb_attribute9                => p_pbb_attribute9
    ,p_pbb_attribute10               => p_pbb_attribute10
    ,p_pbb_attribute11               => p_pbb_attribute11
    ,p_pbb_attribute12               => p_pbb_attribute12
    ,p_pbb_attribute13               => p_pbb_attribute13
    ,p_pbb_attribute14               => p_pbb_attribute14
    ,p_pbb_attribute15               => p_pbb_attribute15
    ,p_pbb_attribute16               => p_pbb_attribute16
    ,p_pbb_attribute17               => p_pbb_attribute17
    ,p_pbb_attribute18               => p_pbb_attribute18
    ,p_pbb_attribute19               => p_pbb_attribute19
    ,p_pbb_attribute20               => p_pbb_attribute20
    ,p_pbb_attribute21               => p_pbb_attribute21
    ,p_pbb_attribute22               => p_pbb_attribute22
    ,p_pbb_attribute23               => p_pbb_attribute23
    ,p_pbb_attribute24               => p_pbb_attribute24
    ,p_pbb_attribute25               => p_pbb_attribute25
    ,p_pbb_attribute26               => p_pbb_attribute26
    ,p_pbb_attribute27               => p_pbb_attribute27
    ,p_pbb_attribute28               => p_pbb_attribute28
    ,p_pbb_attribute29               => p_pbb_attribute29
    ,p_pbb_attribute30               => p_pbb_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_person_bnfts_bal
    --
    ben_person_bnfts_bal_bk1.create_person_bnfts_bal_a
      (
       p_per_bnfts_bal_id               =>  l_per_bnfts_bal_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_val                            =>  p_val
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbb_attribute_category         =>  p_pbb_attribute_category
      ,p_pbb_attribute1                 =>  p_pbb_attribute1
      ,p_pbb_attribute2                 =>  p_pbb_attribute2
      ,p_pbb_attribute3                 =>  p_pbb_attribute3
      ,p_pbb_attribute4                 =>  p_pbb_attribute4
      ,p_pbb_attribute5                 =>  p_pbb_attribute5
      ,p_pbb_attribute6                 =>  p_pbb_attribute6
      ,p_pbb_attribute7                 =>  p_pbb_attribute7
      ,p_pbb_attribute8                 =>  p_pbb_attribute8
      ,p_pbb_attribute9                 =>  p_pbb_attribute9
      ,p_pbb_attribute10                =>  p_pbb_attribute10
      ,p_pbb_attribute11                =>  p_pbb_attribute11
      ,p_pbb_attribute12                =>  p_pbb_attribute12
      ,p_pbb_attribute13                =>  p_pbb_attribute13
      ,p_pbb_attribute14                =>  p_pbb_attribute14
      ,p_pbb_attribute15                =>  p_pbb_attribute15
      ,p_pbb_attribute16                =>  p_pbb_attribute16
      ,p_pbb_attribute17                =>  p_pbb_attribute17
      ,p_pbb_attribute18                =>  p_pbb_attribute18
      ,p_pbb_attribute19                =>  p_pbb_attribute19
      ,p_pbb_attribute20                =>  p_pbb_attribute20
      ,p_pbb_attribute21                =>  p_pbb_attribute21
      ,p_pbb_attribute22                =>  p_pbb_attribute22
      ,p_pbb_attribute23                =>  p_pbb_attribute23
      ,p_pbb_attribute24                =>  p_pbb_attribute24
      ,p_pbb_attribute25                =>  p_pbb_attribute25
      ,p_pbb_attribute26                =>  p_pbb_attribute26
      ,p_pbb_attribute27                =>  p_pbb_attribute27
      ,p_pbb_attribute28                =>  p_pbb_attribute28
      ,p_pbb_attribute29                =>  p_pbb_attribute29
      ,p_pbb_attribute30                =>  p_pbb_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_person_bnfts_bal'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_person_bnfts_bal
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
  p_per_bnfts_bal_id := l_per_bnfts_bal_id;
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
    ROLLBACK TO create_person_bnfts_bal;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_per_bnfts_bal_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_person_bnfts_bal;
    p_per_bnfts_bal_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_person_bnfts_bal;
-- ----------------------------------------------------------------------------
-- |------------------------< update_person_bnfts_bal >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person_bnfts_bal
  (p_validate                       in  boolean   default false
  ,p_per_bnfts_bal_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_val                            in  number    default hr_api.g_number
  ,p_bnfts_bal_id                   in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pbb_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pbb_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_person_bnfts_bal';
  l_object_version_number ben_per_bnfts_bal_f.object_version_number%TYPE;
  l_effective_start_date ben_per_bnfts_bal_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_bnfts_bal_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_person_bnfts_bal;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_person_bnfts_bal
    --
    ben_person_bnfts_bal_bk2.update_person_bnfts_bal_b
      (
       p_per_bnfts_bal_id               =>  p_per_bnfts_bal_id
      ,p_val                            =>  p_val
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbb_attribute_category         =>  p_pbb_attribute_category
      ,p_pbb_attribute1                 =>  p_pbb_attribute1
      ,p_pbb_attribute2                 =>  p_pbb_attribute2
      ,p_pbb_attribute3                 =>  p_pbb_attribute3
      ,p_pbb_attribute4                 =>  p_pbb_attribute4
      ,p_pbb_attribute5                 =>  p_pbb_attribute5
      ,p_pbb_attribute6                 =>  p_pbb_attribute6
      ,p_pbb_attribute7                 =>  p_pbb_attribute7
      ,p_pbb_attribute8                 =>  p_pbb_attribute8
      ,p_pbb_attribute9                 =>  p_pbb_attribute9
      ,p_pbb_attribute10                =>  p_pbb_attribute10
      ,p_pbb_attribute11                =>  p_pbb_attribute11
      ,p_pbb_attribute12                =>  p_pbb_attribute12
      ,p_pbb_attribute13                =>  p_pbb_attribute13
      ,p_pbb_attribute14                =>  p_pbb_attribute14
      ,p_pbb_attribute15                =>  p_pbb_attribute15
      ,p_pbb_attribute16                =>  p_pbb_attribute16
      ,p_pbb_attribute17                =>  p_pbb_attribute17
      ,p_pbb_attribute18                =>  p_pbb_attribute18
      ,p_pbb_attribute19                =>  p_pbb_attribute19
      ,p_pbb_attribute20                =>  p_pbb_attribute20
      ,p_pbb_attribute21                =>  p_pbb_attribute21
      ,p_pbb_attribute22                =>  p_pbb_attribute22
      ,p_pbb_attribute23                =>  p_pbb_attribute23
      ,p_pbb_attribute24                =>  p_pbb_attribute24
      ,p_pbb_attribute25                =>  p_pbb_attribute25
      ,p_pbb_attribute26                =>  p_pbb_attribute26
      ,p_pbb_attribute27                =>  p_pbb_attribute27
      ,p_pbb_attribute28                =>  p_pbb_attribute28
      ,p_pbb_attribute29                =>  p_pbb_attribute29
      ,p_pbb_attribute30                =>  p_pbb_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_person_bnfts_bal'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_person_bnfts_bal
    --
  end;
  --
  ben_pbb_upd.upd
    (
     p_per_bnfts_bal_id              => p_per_bnfts_bal_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_val                           => p_val
    ,p_bnfts_bal_id                  => p_bnfts_bal_id
    ,p_person_id                     => p_person_id
    ,p_business_group_id             => p_business_group_id
    ,p_pbb_attribute_category        => p_pbb_attribute_category
    ,p_pbb_attribute1                => p_pbb_attribute1
    ,p_pbb_attribute2                => p_pbb_attribute2
    ,p_pbb_attribute3                => p_pbb_attribute3
    ,p_pbb_attribute4                => p_pbb_attribute4
    ,p_pbb_attribute5                => p_pbb_attribute5
    ,p_pbb_attribute6                => p_pbb_attribute6
    ,p_pbb_attribute7                => p_pbb_attribute7
    ,p_pbb_attribute8                => p_pbb_attribute8
    ,p_pbb_attribute9                => p_pbb_attribute9
    ,p_pbb_attribute10               => p_pbb_attribute10
    ,p_pbb_attribute11               => p_pbb_attribute11
    ,p_pbb_attribute12               => p_pbb_attribute12
    ,p_pbb_attribute13               => p_pbb_attribute13
    ,p_pbb_attribute14               => p_pbb_attribute14
    ,p_pbb_attribute15               => p_pbb_attribute15
    ,p_pbb_attribute16               => p_pbb_attribute16
    ,p_pbb_attribute17               => p_pbb_attribute17
    ,p_pbb_attribute18               => p_pbb_attribute18
    ,p_pbb_attribute19               => p_pbb_attribute19
    ,p_pbb_attribute20               => p_pbb_attribute20
    ,p_pbb_attribute21               => p_pbb_attribute21
    ,p_pbb_attribute22               => p_pbb_attribute22
    ,p_pbb_attribute23               => p_pbb_attribute23
    ,p_pbb_attribute24               => p_pbb_attribute24
    ,p_pbb_attribute25               => p_pbb_attribute25
    ,p_pbb_attribute26               => p_pbb_attribute26
    ,p_pbb_attribute27               => p_pbb_attribute27
    ,p_pbb_attribute28               => p_pbb_attribute28
    ,p_pbb_attribute29               => p_pbb_attribute29
    ,p_pbb_attribute30               => p_pbb_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_person_bnfts_bal
    --
    ben_person_bnfts_bal_bk2.update_person_bnfts_bal_a
      (
       p_per_bnfts_bal_id               =>  p_per_bnfts_bal_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_val                            =>  p_val
      ,p_bnfts_bal_id                   =>  p_bnfts_bal_id
      ,p_person_id                      =>  p_person_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pbb_attribute_category         =>  p_pbb_attribute_category
      ,p_pbb_attribute1                 =>  p_pbb_attribute1
      ,p_pbb_attribute2                 =>  p_pbb_attribute2
      ,p_pbb_attribute3                 =>  p_pbb_attribute3
      ,p_pbb_attribute4                 =>  p_pbb_attribute4
      ,p_pbb_attribute5                 =>  p_pbb_attribute5
      ,p_pbb_attribute6                 =>  p_pbb_attribute6
      ,p_pbb_attribute7                 =>  p_pbb_attribute7
      ,p_pbb_attribute8                 =>  p_pbb_attribute8
      ,p_pbb_attribute9                 =>  p_pbb_attribute9
      ,p_pbb_attribute10                =>  p_pbb_attribute10
      ,p_pbb_attribute11                =>  p_pbb_attribute11
      ,p_pbb_attribute12                =>  p_pbb_attribute12
      ,p_pbb_attribute13                =>  p_pbb_attribute13
      ,p_pbb_attribute14                =>  p_pbb_attribute14
      ,p_pbb_attribute15                =>  p_pbb_attribute15
      ,p_pbb_attribute16                =>  p_pbb_attribute16
      ,p_pbb_attribute17                =>  p_pbb_attribute17
      ,p_pbb_attribute18                =>  p_pbb_attribute18
      ,p_pbb_attribute19                =>  p_pbb_attribute19
      ,p_pbb_attribute20                =>  p_pbb_attribute20
      ,p_pbb_attribute21                =>  p_pbb_attribute21
      ,p_pbb_attribute22                =>  p_pbb_attribute22
      ,p_pbb_attribute23                =>  p_pbb_attribute23
      ,p_pbb_attribute24                =>  p_pbb_attribute24
      ,p_pbb_attribute25                =>  p_pbb_attribute25
      ,p_pbb_attribute26                =>  p_pbb_attribute26
      ,p_pbb_attribute27                =>  p_pbb_attribute27
      ,p_pbb_attribute28                =>  p_pbb_attribute28
      ,p_pbb_attribute29                =>  p_pbb_attribute29
      ,p_pbb_attribute30                =>  p_pbb_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_person_bnfts_bal'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_person_bnfts_bal
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
    ROLLBACK TO update_person_bnfts_bal;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_person_bnfts_bal;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_person_bnfts_bal;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_person_bnfts_bal >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_bnfts_bal
  (p_validate                       in  boolean  default false
  ,p_per_bnfts_bal_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_person_bnfts_bal';
  l_object_version_number ben_per_bnfts_bal_f.object_version_number%TYPE;
  l_effective_start_date ben_per_bnfts_bal_f.effective_start_date%TYPE;
  l_effective_end_date ben_per_bnfts_bal_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_person_bnfts_bal;
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
    -- Start of API User Hook for the before hook of delete_person_bnfts_bal
    --
    ben_person_bnfts_bal_bk3.delete_person_bnfts_bal_b
      (
       p_per_bnfts_bal_id               =>  p_per_bnfts_bal_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_person_bnfts_bal'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_person_bnfts_bal
    --
  end;
  --
  ben_pbb_del.del
    (
     p_per_bnfts_bal_id              => p_per_bnfts_bal_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_person_bnfts_bal
    --
    ben_person_bnfts_bal_bk3.delete_person_bnfts_bal_a
      (
       p_per_bnfts_bal_id               =>  p_per_bnfts_bal_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_person_bnfts_bal'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_person_bnfts_bal
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
    ROLLBACK TO delete_person_bnfts_bal;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_person_bnfts_bal;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_person_bnfts_bal;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_per_bnfts_bal_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
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
  ben_pbb_shd.lck
    (
      p_per_bnfts_bal_id                 => p_per_bnfts_bal_id
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
procedure set_foreign_key_locking(p_expression in boolean) is
  --
  l_proc varchar2(72) := g_package||'set_foreign_key_locking';
  --
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 70);
  --
  -- This procedure enables the changing of a global to turn off foreign
  -- key locking of a benefit balance type. The routine should be called
  -- once at the start of the migration and then again at the end of the
  -- migration. The expression should be boolean and a true would enable
  -- the foreign key locking and a false disable locking.
  --
  g_lock_row := p_expression;
  --
  hr_utility.set_location('Leaving:'||l_proc, 70);
  --
end set_foreign_key_locking;
--
end ben_person_bnfts_bal_api;

/
