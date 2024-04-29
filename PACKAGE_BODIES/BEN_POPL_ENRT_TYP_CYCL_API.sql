--------------------------------------------------------
--  DDL for Package Body BEN_POPL_ENRT_TYP_CYCL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_POPL_ENRT_TYP_CYCL_API" as
/* $Header: bepetapi.pkb 120.0 2005/05/28 10:40:41 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Popl_Enrt_Typ_Cycl_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Popl_Enrt_Typ_Cycl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Popl_Enrt_Typ_Cycl
  (p_validate                       in  boolean   default false
  ,p_popl_enrt_typ_cycl_id          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_enrt_typ_cycl_cd               in  varchar2  default null
  ,p_pl_id                          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pet_attribute_category         in  varchar2  default null
  ,p_pet_attribute1                 in  varchar2  default null
  ,p_pet_attribute2                 in  varchar2  default null
  ,p_pet_attribute3                 in  varchar2  default null
  ,p_pet_attribute4                 in  varchar2  default null
  ,p_pet_attribute5                 in  varchar2  default null
  ,p_pet_attribute6                 in  varchar2  default null
  ,p_pet_attribute7                 in  varchar2  default null
  ,p_pet_attribute8                 in  varchar2  default null
  ,p_pet_attribute9                 in  varchar2  default null
  ,p_pet_attribute10                in  varchar2  default null
  ,p_pet_attribute11                in  varchar2  default null
  ,p_pet_attribute12                in  varchar2  default null
  ,p_pet_attribute13                in  varchar2  default null
  ,p_pet_attribute14                in  varchar2  default null
  ,p_pet_attribute15                in  varchar2  default null
  ,p_pet_attribute16                in  varchar2  default null
  ,p_pet_attribute17                in  varchar2  default null
  ,p_pet_attribute18                in  varchar2  default null
  ,p_pet_attribute19                in  varchar2  default null
  ,p_pet_attribute20                in  varchar2  default null
  ,p_pet_attribute21                in  varchar2  default null
  ,p_pet_attribute22                in  varchar2  default null
  ,p_pet_attribute23                in  varchar2  default null
  ,p_pet_attribute24                in  varchar2  default null
  ,p_pet_attribute25                in  varchar2  default null
  ,p_pet_attribute26                in  varchar2  default null
  ,p_pet_attribute27                in  varchar2  default null
  ,p_pet_attribute28                in  varchar2  default null
  ,p_pet_attribute29                in  varchar2  default null
  ,p_pet_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_popl_enrt_typ_cycl_id ben_popl_enrt_typ_cycl_f.popl_enrt_typ_cycl_id%TYPE;
  l_effective_start_date ben_popl_enrt_typ_cycl_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_enrt_typ_cycl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Popl_Enrt_Typ_Cycl';
  l_object_version_number ben_popl_enrt_typ_cycl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Popl_Enrt_Typ_Cycl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Popl_Enrt_Typ_Cycl
    --
    ben_Popl_Enrt_Typ_Cycl_bk1.create_Popl_Enrt_Typ_Cycl_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pet_attribute_category         =>  p_pet_attribute_category
      ,p_pet_attribute1                 =>  p_pet_attribute1
      ,p_pet_attribute2                 =>  p_pet_attribute2
      ,p_pet_attribute3                 =>  p_pet_attribute3
      ,p_pet_attribute4                 =>  p_pet_attribute4
      ,p_pet_attribute5                 =>  p_pet_attribute5
      ,p_pet_attribute6                 =>  p_pet_attribute6
      ,p_pet_attribute7                 =>  p_pet_attribute7
      ,p_pet_attribute8                 =>  p_pet_attribute8
      ,p_pet_attribute9                 =>  p_pet_attribute9
      ,p_pet_attribute10                =>  p_pet_attribute10
      ,p_pet_attribute11                =>  p_pet_attribute11
      ,p_pet_attribute12                =>  p_pet_attribute12
      ,p_pet_attribute13                =>  p_pet_attribute13
      ,p_pet_attribute14                =>  p_pet_attribute14
      ,p_pet_attribute15                =>  p_pet_attribute15
      ,p_pet_attribute16                =>  p_pet_attribute16
      ,p_pet_attribute17                =>  p_pet_attribute17
      ,p_pet_attribute18                =>  p_pet_attribute18
      ,p_pet_attribute19                =>  p_pet_attribute19
      ,p_pet_attribute20                =>  p_pet_attribute20
      ,p_pet_attribute21                =>  p_pet_attribute21
      ,p_pet_attribute22                =>  p_pet_attribute22
      ,p_pet_attribute23                =>  p_pet_attribute23
      ,p_pet_attribute24                =>  p_pet_attribute24
      ,p_pet_attribute25                =>  p_pet_attribute25
      ,p_pet_attribute26                =>  p_pet_attribute26
      ,p_pet_attribute27                =>  p_pet_attribute27
      ,p_pet_attribute28                =>  p_pet_attribute28
      ,p_pet_attribute29                =>  p_pet_attribute29
      ,p_pet_attribute30                =>  p_pet_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Popl_Enrt_Typ_Cycl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Popl_Enrt_Typ_Cycl
    --
  end;
  --
  ben_pet_ins.ins
    (
     p_popl_enrt_typ_cycl_id         => l_popl_enrt_typ_cycl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_enrt_typ_cycl_cd              => p_enrt_typ_cycl_cd
    ,p_pl_id                         => p_pl_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pet_attribute_category        => p_pet_attribute_category
    ,p_pet_attribute1                => p_pet_attribute1
    ,p_pet_attribute2                => p_pet_attribute2
    ,p_pet_attribute3                => p_pet_attribute3
    ,p_pet_attribute4                => p_pet_attribute4
    ,p_pet_attribute5                => p_pet_attribute5
    ,p_pet_attribute6                => p_pet_attribute6
    ,p_pet_attribute7                => p_pet_attribute7
    ,p_pet_attribute8                => p_pet_attribute8
    ,p_pet_attribute9                => p_pet_attribute9
    ,p_pet_attribute10               => p_pet_attribute10
    ,p_pet_attribute11               => p_pet_attribute11
    ,p_pet_attribute12               => p_pet_attribute12
    ,p_pet_attribute13               => p_pet_attribute13
    ,p_pet_attribute14               => p_pet_attribute14
    ,p_pet_attribute15               => p_pet_attribute15
    ,p_pet_attribute16               => p_pet_attribute16
    ,p_pet_attribute17               => p_pet_attribute17
    ,p_pet_attribute18               => p_pet_attribute18
    ,p_pet_attribute19               => p_pet_attribute19
    ,p_pet_attribute20               => p_pet_attribute20
    ,p_pet_attribute21               => p_pet_attribute21
    ,p_pet_attribute22               => p_pet_attribute22
    ,p_pet_attribute23               => p_pet_attribute23
    ,p_pet_attribute24               => p_pet_attribute24
    ,p_pet_attribute25               => p_pet_attribute25
    ,p_pet_attribute26               => p_pet_attribute26
    ,p_pet_attribute27               => p_pet_attribute27
    ,p_pet_attribute28               => p_pet_attribute28
    ,p_pet_attribute29               => p_pet_attribute29
    ,p_pet_attribute30               => p_pet_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Popl_Enrt_Typ_Cycl
    --
    ben_Popl_Enrt_Typ_Cycl_bk1.create_Popl_Enrt_Typ_Cycl_a
      (
       p_popl_enrt_typ_cycl_id          =>  l_popl_enrt_typ_cycl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pet_attribute_category         =>  p_pet_attribute_category
      ,p_pet_attribute1                 =>  p_pet_attribute1
      ,p_pet_attribute2                 =>  p_pet_attribute2
      ,p_pet_attribute3                 =>  p_pet_attribute3
      ,p_pet_attribute4                 =>  p_pet_attribute4
      ,p_pet_attribute5                 =>  p_pet_attribute5
      ,p_pet_attribute6                 =>  p_pet_attribute6
      ,p_pet_attribute7                 =>  p_pet_attribute7
      ,p_pet_attribute8                 =>  p_pet_attribute8
      ,p_pet_attribute9                 =>  p_pet_attribute9
      ,p_pet_attribute10                =>  p_pet_attribute10
      ,p_pet_attribute11                =>  p_pet_attribute11
      ,p_pet_attribute12                =>  p_pet_attribute12
      ,p_pet_attribute13                =>  p_pet_attribute13
      ,p_pet_attribute14                =>  p_pet_attribute14
      ,p_pet_attribute15                =>  p_pet_attribute15
      ,p_pet_attribute16                =>  p_pet_attribute16
      ,p_pet_attribute17                =>  p_pet_attribute17
      ,p_pet_attribute18                =>  p_pet_attribute18
      ,p_pet_attribute19                =>  p_pet_attribute19
      ,p_pet_attribute20                =>  p_pet_attribute20
      ,p_pet_attribute21                =>  p_pet_attribute21
      ,p_pet_attribute22                =>  p_pet_attribute22
      ,p_pet_attribute23                =>  p_pet_attribute23
      ,p_pet_attribute24                =>  p_pet_attribute24
      ,p_pet_attribute25                =>  p_pet_attribute25
      ,p_pet_attribute26                =>  p_pet_attribute26
      ,p_pet_attribute27                =>  p_pet_attribute27
      ,p_pet_attribute28                =>  p_pet_attribute28
      ,p_pet_attribute29                =>  p_pet_attribute29
      ,p_pet_attribute30                =>  p_pet_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Popl_Enrt_Typ_Cycl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Popl_Enrt_Typ_Cycl
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
  p_popl_enrt_typ_cycl_id := l_popl_enrt_typ_cycl_id;
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
    ROLLBACK TO create_Popl_Enrt_Typ_Cycl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_popl_enrt_typ_cycl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
   ROLLBACK TO create_Popl_Enrt_Typ_Cycl;
   p_effective_start_date := null;
   p_effective_end_date := null;
   p_object_version_number  := null;

    raise;
    --
end create_Popl_Enrt_Typ_Cycl;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Popl_Enrt_Typ_Cycl >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Popl_Enrt_Typ_Cycl
  (p_validate                       in  boolean   default false
  ,p_popl_enrt_typ_cycl_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_enrt_typ_cycl_cd               in  varchar2  default hr_api.g_varchar2
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pet_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pet_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Popl_Enrt_Typ_Cycl';
  l_object_version_number ben_popl_enrt_typ_cycl_f.object_version_number%TYPE;
  l_effective_start_date ben_popl_enrt_typ_cycl_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_enrt_typ_cycl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Popl_Enrt_Typ_Cycl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Popl_Enrt_Typ_Cycl
    --
    ben_Popl_Enrt_Typ_Cycl_bk2.update_Popl_Enrt_Typ_Cycl_b
      (
       p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pet_attribute_category         =>  p_pet_attribute_category
      ,p_pet_attribute1                 =>  p_pet_attribute1
      ,p_pet_attribute2                 =>  p_pet_attribute2
      ,p_pet_attribute3                 =>  p_pet_attribute3
      ,p_pet_attribute4                 =>  p_pet_attribute4
      ,p_pet_attribute5                 =>  p_pet_attribute5
      ,p_pet_attribute6                 =>  p_pet_attribute6
      ,p_pet_attribute7                 =>  p_pet_attribute7
      ,p_pet_attribute8                 =>  p_pet_attribute8
      ,p_pet_attribute9                 =>  p_pet_attribute9
      ,p_pet_attribute10                =>  p_pet_attribute10
      ,p_pet_attribute11                =>  p_pet_attribute11
      ,p_pet_attribute12                =>  p_pet_attribute12
      ,p_pet_attribute13                =>  p_pet_attribute13
      ,p_pet_attribute14                =>  p_pet_attribute14
      ,p_pet_attribute15                =>  p_pet_attribute15
      ,p_pet_attribute16                =>  p_pet_attribute16
      ,p_pet_attribute17                =>  p_pet_attribute17
      ,p_pet_attribute18                =>  p_pet_attribute18
      ,p_pet_attribute19                =>  p_pet_attribute19
      ,p_pet_attribute20                =>  p_pet_attribute20
      ,p_pet_attribute21                =>  p_pet_attribute21
      ,p_pet_attribute22                =>  p_pet_attribute22
      ,p_pet_attribute23                =>  p_pet_attribute23
      ,p_pet_attribute24                =>  p_pet_attribute24
      ,p_pet_attribute25                =>  p_pet_attribute25
      ,p_pet_attribute26                =>  p_pet_attribute26
      ,p_pet_attribute27                =>  p_pet_attribute27
      ,p_pet_attribute28                =>  p_pet_attribute28
      ,p_pet_attribute29                =>  p_pet_attribute29
      ,p_pet_attribute30                =>  p_pet_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Popl_Enrt_Typ_Cycl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Popl_Enrt_Typ_Cycl
    --
  end;
  --
  ben_pet_upd.upd
    (
     p_popl_enrt_typ_cycl_id         => p_popl_enrt_typ_cycl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_enrt_typ_cycl_cd              => p_enrt_typ_cycl_cd
    ,p_pl_id                         => p_pl_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pet_attribute_category        => p_pet_attribute_category
    ,p_pet_attribute1                => p_pet_attribute1
    ,p_pet_attribute2                => p_pet_attribute2
    ,p_pet_attribute3                => p_pet_attribute3
    ,p_pet_attribute4                => p_pet_attribute4
    ,p_pet_attribute5                => p_pet_attribute5
    ,p_pet_attribute6                => p_pet_attribute6
    ,p_pet_attribute7                => p_pet_attribute7
    ,p_pet_attribute8                => p_pet_attribute8
    ,p_pet_attribute9                => p_pet_attribute9
    ,p_pet_attribute10               => p_pet_attribute10
    ,p_pet_attribute11               => p_pet_attribute11
    ,p_pet_attribute12               => p_pet_attribute12
    ,p_pet_attribute13               => p_pet_attribute13
    ,p_pet_attribute14               => p_pet_attribute14
    ,p_pet_attribute15               => p_pet_attribute15
    ,p_pet_attribute16               => p_pet_attribute16
    ,p_pet_attribute17               => p_pet_attribute17
    ,p_pet_attribute18               => p_pet_attribute18
    ,p_pet_attribute19               => p_pet_attribute19
    ,p_pet_attribute20               => p_pet_attribute20
    ,p_pet_attribute21               => p_pet_attribute21
    ,p_pet_attribute22               => p_pet_attribute22
    ,p_pet_attribute23               => p_pet_attribute23
    ,p_pet_attribute24               => p_pet_attribute24
    ,p_pet_attribute25               => p_pet_attribute25
    ,p_pet_attribute26               => p_pet_attribute26
    ,p_pet_attribute27               => p_pet_attribute27
    ,p_pet_attribute28               => p_pet_attribute28
    ,p_pet_attribute29               => p_pet_attribute29
    ,p_pet_attribute30               => p_pet_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Popl_Enrt_Typ_Cycl
    --
    ben_Popl_Enrt_Typ_Cycl_bk2.update_Popl_Enrt_Typ_Cycl_a
      (
       p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_enrt_typ_cycl_cd               =>  p_enrt_typ_cycl_cd
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pet_attribute_category         =>  p_pet_attribute_category
      ,p_pet_attribute1                 =>  p_pet_attribute1
      ,p_pet_attribute2                 =>  p_pet_attribute2
      ,p_pet_attribute3                 =>  p_pet_attribute3
      ,p_pet_attribute4                 =>  p_pet_attribute4
      ,p_pet_attribute5                 =>  p_pet_attribute5
      ,p_pet_attribute6                 =>  p_pet_attribute6
      ,p_pet_attribute7                 =>  p_pet_attribute7
      ,p_pet_attribute8                 =>  p_pet_attribute8
      ,p_pet_attribute9                 =>  p_pet_attribute9
      ,p_pet_attribute10                =>  p_pet_attribute10
      ,p_pet_attribute11                =>  p_pet_attribute11
      ,p_pet_attribute12                =>  p_pet_attribute12
      ,p_pet_attribute13                =>  p_pet_attribute13
      ,p_pet_attribute14                =>  p_pet_attribute14
      ,p_pet_attribute15                =>  p_pet_attribute15
      ,p_pet_attribute16                =>  p_pet_attribute16
      ,p_pet_attribute17                =>  p_pet_attribute17
      ,p_pet_attribute18                =>  p_pet_attribute18
      ,p_pet_attribute19                =>  p_pet_attribute19
      ,p_pet_attribute20                =>  p_pet_attribute20
      ,p_pet_attribute21                =>  p_pet_attribute21
      ,p_pet_attribute22                =>  p_pet_attribute22
      ,p_pet_attribute23                =>  p_pet_attribute23
      ,p_pet_attribute24                =>  p_pet_attribute24
      ,p_pet_attribute25                =>  p_pet_attribute25
      ,p_pet_attribute26                =>  p_pet_attribute26
      ,p_pet_attribute27                =>  p_pet_attribute27
      ,p_pet_attribute28                =>  p_pet_attribute28
      ,p_pet_attribute29                =>  p_pet_attribute29
      ,p_pet_attribute30                =>  p_pet_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Popl_Enrt_Typ_Cycl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Popl_Enrt_Typ_Cycl
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
    ROLLBACK TO update_Popl_Enrt_Typ_Cycl;
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
    ROLLBACK TO update_Popl_Enrt_Typ_Cycl;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;


    raise;
    --
end update_Popl_Enrt_Typ_Cycl;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Popl_Enrt_Typ_Cycl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Popl_Enrt_Typ_Cycl
  (p_validate                       in  boolean  default false
  ,p_popl_enrt_typ_cycl_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Popl_Enrt_Typ_Cycl';
  l_object_version_number ben_popl_enrt_typ_cycl_f.object_version_number%TYPE;
  l_effective_start_date ben_popl_enrt_typ_cycl_f.effective_start_date%TYPE;
  l_effective_end_date ben_popl_enrt_typ_cycl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Popl_Enrt_Typ_Cycl;
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
    -- Start of API User Hook for the before hook of delete_Popl_Enrt_Typ_Cycl
    --
    ben_Popl_Enrt_Typ_Cycl_bk3.delete_Popl_Enrt_Typ_Cycl_b
      (
       p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Popl_Enrt_Typ_Cycl'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Popl_Enrt_Typ_Cycl
    --
  end;
  --
  ben_pet_del.del
    (
     p_popl_enrt_typ_cycl_id         => p_popl_enrt_typ_cycl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Popl_Enrt_Typ_Cycl
    --
    ben_Popl_Enrt_Typ_Cycl_bk3.delete_Popl_Enrt_Typ_Cycl_a
      (
       p_popl_enrt_typ_cycl_id          =>  p_popl_enrt_typ_cycl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Popl_Enrt_Typ_Cycl'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Popl_Enrt_Typ_Cycl
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
    ROLLBACK TO delete_Popl_Enrt_Typ_Cycl;
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
    ROLLBACK TO delete_Popl_Enrt_Typ_Cycl;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    raise;
    --
end delete_Popl_Enrt_Typ_Cycl;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_popl_enrt_typ_cycl_id                   in     number
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
  ben_pet_shd.lck
    (
      p_popl_enrt_typ_cycl_id                 => p_popl_enrt_typ_cycl_id
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
end ben_Popl_Enrt_Typ_Cycl_api;

/
