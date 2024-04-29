--------------------------------------------------------
--  DDL for Package Body BEN_CSS_RLTD_PER_IN_LER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CSS_RLTD_PER_IN_LER_API" as
/* $Header: becsrapi.pkb 115.3 2002/12/16 17:34:37 glingapp ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Css_Rltd_Per_in_Ler_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Css_Rltd_Per_in_Ler >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Css_Rltd_Per_in_Ler
  (p_validate                       in  boolean   default false
  ,p_css_rltd_per_per_in_ler_id     out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_to_prcs_num               in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_rsltg_ler_id                   in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_csr_attribute_category         in  varchar2  default null
  ,p_csr_attribute1                 in  varchar2  default null
  ,p_csr_attribute2                 in  varchar2  default null
  ,p_csr_attribute3                 in  varchar2  default null
  ,p_csr_attribute4                 in  varchar2  default null
  ,p_csr_attribute5                 in  varchar2  default null
  ,p_csr_attribute6                 in  varchar2  default null
  ,p_csr_attribute7                 in  varchar2  default null
  ,p_csr_attribute8                 in  varchar2  default null
  ,p_csr_attribute9                 in  varchar2  default null
  ,p_csr_attribute10                in  varchar2  default null
  ,p_csr_attribute11                in  varchar2  default null
  ,p_csr_attribute12                in  varchar2  default null
  ,p_csr_attribute13                in  varchar2  default null
  ,p_csr_attribute14                in  varchar2  default null
  ,p_csr_attribute15                in  varchar2  default null
  ,p_csr_attribute16                in  varchar2  default null
  ,p_csr_attribute17                in  varchar2  default null
  ,p_csr_attribute18                in  varchar2  default null
  ,p_csr_attribute19                in  varchar2  default null
  ,p_csr_attribute20                in  varchar2  default null
  ,p_csr_attribute21                in  varchar2  default null
  ,p_csr_attribute22                in  varchar2  default null
  ,p_csr_attribute23                in  varchar2  default null
  ,p_csr_attribute24                in  varchar2  default null
  ,p_csr_attribute25                in  varchar2  default null
  ,p_csr_attribute26                in  varchar2  default null
  ,p_csr_attribute27                in  varchar2  default null
  ,p_csr_attribute28                in  varchar2  default null
  ,p_csr_attribute29                in  varchar2  default null
  ,p_csr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_css_rltd_per_per_in_ler_id ben_css_rltd_per_per_in_ler_f.css_rltd_per_per_in_ler_id%TYPE;
  l_effective_start_date ben_css_rltd_per_per_in_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_css_rltd_per_per_in_ler_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Css_Rltd_Per_in_Ler';
  l_object_version_number ben_css_rltd_per_per_in_ler_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Css_Rltd_Per_in_Ler;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Css_Rltd_Per_in_Ler
    --
    ben_Css_Rltd_Per_in_Ler_bk1.create_Css_Rltd_Per_in_Ler_b
      (
       p_ordr_to_prcs_num               =>  p_ordr_to_prcs_num
      ,p_ler_id                         =>  p_ler_id
      ,p_rsltg_ler_id                   =>  p_rsltg_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_csr_attribute_category         =>  p_csr_attribute_category
      ,p_csr_attribute1                 =>  p_csr_attribute1
      ,p_csr_attribute2                 =>  p_csr_attribute2
      ,p_csr_attribute3                 =>  p_csr_attribute3
      ,p_csr_attribute4                 =>  p_csr_attribute4
      ,p_csr_attribute5                 =>  p_csr_attribute5
      ,p_csr_attribute6                 =>  p_csr_attribute6
      ,p_csr_attribute7                 =>  p_csr_attribute7
      ,p_csr_attribute8                 =>  p_csr_attribute8
      ,p_csr_attribute9                 =>  p_csr_attribute9
      ,p_csr_attribute10                =>  p_csr_attribute10
      ,p_csr_attribute11                =>  p_csr_attribute11
      ,p_csr_attribute12                =>  p_csr_attribute12
      ,p_csr_attribute13                =>  p_csr_attribute13
      ,p_csr_attribute14                =>  p_csr_attribute14
      ,p_csr_attribute15                =>  p_csr_attribute15
      ,p_csr_attribute16                =>  p_csr_attribute16
      ,p_csr_attribute17                =>  p_csr_attribute17
      ,p_csr_attribute18                =>  p_csr_attribute18
      ,p_csr_attribute19                =>  p_csr_attribute19
      ,p_csr_attribute20                =>  p_csr_attribute20
      ,p_csr_attribute21                =>  p_csr_attribute21
      ,p_csr_attribute22                =>  p_csr_attribute22
      ,p_csr_attribute23                =>  p_csr_attribute23
      ,p_csr_attribute24                =>  p_csr_attribute24
      ,p_csr_attribute25                =>  p_csr_attribute25
      ,p_csr_attribute26                =>  p_csr_attribute26
      ,p_csr_attribute27                =>  p_csr_attribute27
      ,p_csr_attribute28                =>  p_csr_attribute28
      ,p_csr_attribute29                =>  p_csr_attribute29
      ,p_csr_attribute30                =>  p_csr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Css_Rltd_Per_in_Ler'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Css_Rltd_Per_in_Ler
    --
  end;
  --
  ben_csr_ins.ins
    (
     p_css_rltd_per_per_in_ler_id    => l_css_rltd_per_per_in_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_to_prcs_num              => p_ordr_to_prcs_num
    ,p_ler_id                        => p_ler_id
    ,p_rsltg_ler_id                  => p_rsltg_ler_id
    ,p_business_group_id             => p_business_group_id
    ,p_csr_attribute_category        => p_csr_attribute_category
    ,p_csr_attribute1                => p_csr_attribute1
    ,p_csr_attribute2                => p_csr_attribute2
    ,p_csr_attribute3                => p_csr_attribute3
    ,p_csr_attribute4                => p_csr_attribute4
    ,p_csr_attribute5                => p_csr_attribute5
    ,p_csr_attribute6                => p_csr_attribute6
    ,p_csr_attribute7                => p_csr_attribute7
    ,p_csr_attribute8                => p_csr_attribute8
    ,p_csr_attribute9                => p_csr_attribute9
    ,p_csr_attribute10               => p_csr_attribute10
    ,p_csr_attribute11               => p_csr_attribute11
    ,p_csr_attribute12               => p_csr_attribute12
    ,p_csr_attribute13               => p_csr_attribute13
    ,p_csr_attribute14               => p_csr_attribute14
    ,p_csr_attribute15               => p_csr_attribute15
    ,p_csr_attribute16               => p_csr_attribute16
    ,p_csr_attribute17               => p_csr_attribute17
    ,p_csr_attribute18               => p_csr_attribute18
    ,p_csr_attribute19               => p_csr_attribute19
    ,p_csr_attribute20               => p_csr_attribute20
    ,p_csr_attribute21               => p_csr_attribute21
    ,p_csr_attribute22               => p_csr_attribute22
    ,p_csr_attribute23               => p_csr_attribute23
    ,p_csr_attribute24               => p_csr_attribute24
    ,p_csr_attribute25               => p_csr_attribute25
    ,p_csr_attribute26               => p_csr_attribute26
    ,p_csr_attribute27               => p_csr_attribute27
    ,p_csr_attribute28               => p_csr_attribute28
    ,p_csr_attribute29               => p_csr_attribute29
    ,p_csr_attribute30               => p_csr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Css_Rltd_Per_in_Ler
    --
    ben_Css_Rltd_Per_in_Ler_bk1.create_Css_Rltd_Per_in_Ler_a
      (
       p_css_rltd_per_per_in_ler_id     =>  l_css_rltd_per_per_in_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_to_prcs_num               =>  p_ordr_to_prcs_num
      ,p_ler_id                         =>  p_ler_id
      ,p_rsltg_ler_id                   =>  p_rsltg_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_csr_attribute_category         =>  p_csr_attribute_category
      ,p_csr_attribute1                 =>  p_csr_attribute1
      ,p_csr_attribute2                 =>  p_csr_attribute2
      ,p_csr_attribute3                 =>  p_csr_attribute3
      ,p_csr_attribute4                 =>  p_csr_attribute4
      ,p_csr_attribute5                 =>  p_csr_attribute5
      ,p_csr_attribute6                 =>  p_csr_attribute6
      ,p_csr_attribute7                 =>  p_csr_attribute7
      ,p_csr_attribute8                 =>  p_csr_attribute8
      ,p_csr_attribute9                 =>  p_csr_attribute9
      ,p_csr_attribute10                =>  p_csr_attribute10
      ,p_csr_attribute11                =>  p_csr_attribute11
      ,p_csr_attribute12                =>  p_csr_attribute12
      ,p_csr_attribute13                =>  p_csr_attribute13
      ,p_csr_attribute14                =>  p_csr_attribute14
      ,p_csr_attribute15                =>  p_csr_attribute15
      ,p_csr_attribute16                =>  p_csr_attribute16
      ,p_csr_attribute17                =>  p_csr_attribute17
      ,p_csr_attribute18                =>  p_csr_attribute18
      ,p_csr_attribute19                =>  p_csr_attribute19
      ,p_csr_attribute20                =>  p_csr_attribute20
      ,p_csr_attribute21                =>  p_csr_attribute21
      ,p_csr_attribute22                =>  p_csr_attribute22
      ,p_csr_attribute23                =>  p_csr_attribute23
      ,p_csr_attribute24                =>  p_csr_attribute24
      ,p_csr_attribute25                =>  p_csr_attribute25
      ,p_csr_attribute26                =>  p_csr_attribute26
      ,p_csr_attribute27                =>  p_csr_attribute27
      ,p_csr_attribute28                =>  p_csr_attribute28
      ,p_csr_attribute29                =>  p_csr_attribute29
      ,p_csr_attribute30                =>  p_csr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Css_Rltd_Per_in_Ler'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Css_Rltd_Per_in_Ler
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
  p_css_rltd_per_per_in_ler_id := l_css_rltd_per_per_in_ler_id;
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
    ROLLBACK TO create_Css_Rltd_Per_in_Ler;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_css_rltd_per_per_in_ler_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Css_Rltd_Per_in_Ler;
    p_css_rltd_per_per_in_ler_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_Css_Rltd_Per_in_Ler;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Css_Rltd_Per_in_Ler >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Css_Rltd_Per_in_Ler
  (p_validate                       in  boolean   default false
  ,p_css_rltd_per_per_in_ler_id     in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_to_prcs_num               in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_rsltg_ler_id                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_csr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_csr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Css_Rltd_Per_in_Ler';
  l_object_version_number ben_css_rltd_per_per_in_ler_f.object_version_number%TYPE;
  l_effective_start_date ben_css_rltd_per_per_in_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_css_rltd_per_per_in_ler_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Css_Rltd_Per_in_Ler;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Css_Rltd_Per_in_Ler
    --
    ben_Css_Rltd_Per_in_Ler_bk2.update_Css_Rltd_Per_in_Ler_b
      (
       p_css_rltd_per_per_in_ler_id     =>  p_css_rltd_per_per_in_ler_id
      ,p_ordr_to_prcs_num               =>  p_ordr_to_prcs_num
      ,p_ler_id                         =>  p_ler_id
      ,p_rsltg_ler_id                   =>  p_rsltg_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_csr_attribute_category         =>  p_csr_attribute_category
      ,p_csr_attribute1                 =>  p_csr_attribute1
      ,p_csr_attribute2                 =>  p_csr_attribute2
      ,p_csr_attribute3                 =>  p_csr_attribute3
      ,p_csr_attribute4                 =>  p_csr_attribute4
      ,p_csr_attribute5                 =>  p_csr_attribute5
      ,p_csr_attribute6                 =>  p_csr_attribute6
      ,p_csr_attribute7                 =>  p_csr_attribute7
      ,p_csr_attribute8                 =>  p_csr_attribute8
      ,p_csr_attribute9                 =>  p_csr_attribute9
      ,p_csr_attribute10                =>  p_csr_attribute10
      ,p_csr_attribute11                =>  p_csr_attribute11
      ,p_csr_attribute12                =>  p_csr_attribute12
      ,p_csr_attribute13                =>  p_csr_attribute13
      ,p_csr_attribute14                =>  p_csr_attribute14
      ,p_csr_attribute15                =>  p_csr_attribute15
      ,p_csr_attribute16                =>  p_csr_attribute16
      ,p_csr_attribute17                =>  p_csr_attribute17
      ,p_csr_attribute18                =>  p_csr_attribute18
      ,p_csr_attribute19                =>  p_csr_attribute19
      ,p_csr_attribute20                =>  p_csr_attribute20
      ,p_csr_attribute21                =>  p_csr_attribute21
      ,p_csr_attribute22                =>  p_csr_attribute22
      ,p_csr_attribute23                =>  p_csr_attribute23
      ,p_csr_attribute24                =>  p_csr_attribute24
      ,p_csr_attribute25                =>  p_csr_attribute25
      ,p_csr_attribute26                =>  p_csr_attribute26
      ,p_csr_attribute27                =>  p_csr_attribute27
      ,p_csr_attribute28                =>  p_csr_attribute28
      ,p_csr_attribute29                =>  p_csr_attribute29
      ,p_csr_attribute30                =>  p_csr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Css_Rltd_Per_in_Ler'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Css_Rltd_Per_in_Ler
    --
  end;
  --
  ben_csr_upd.upd
    (
     p_css_rltd_per_per_in_ler_id    => p_css_rltd_per_per_in_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_to_prcs_num              => p_ordr_to_prcs_num
    ,p_ler_id                        => p_ler_id
    ,p_rsltg_ler_id                  => p_rsltg_ler_id
    ,p_business_group_id             => p_business_group_id
    ,p_csr_attribute_category        => p_csr_attribute_category
    ,p_csr_attribute1                => p_csr_attribute1
    ,p_csr_attribute2                => p_csr_attribute2
    ,p_csr_attribute3                => p_csr_attribute3
    ,p_csr_attribute4                => p_csr_attribute4
    ,p_csr_attribute5                => p_csr_attribute5
    ,p_csr_attribute6                => p_csr_attribute6
    ,p_csr_attribute7                => p_csr_attribute7
    ,p_csr_attribute8                => p_csr_attribute8
    ,p_csr_attribute9                => p_csr_attribute9
    ,p_csr_attribute10               => p_csr_attribute10
    ,p_csr_attribute11               => p_csr_attribute11
    ,p_csr_attribute12               => p_csr_attribute12
    ,p_csr_attribute13               => p_csr_attribute13
    ,p_csr_attribute14               => p_csr_attribute14
    ,p_csr_attribute15               => p_csr_attribute15
    ,p_csr_attribute16               => p_csr_attribute16
    ,p_csr_attribute17               => p_csr_attribute17
    ,p_csr_attribute18               => p_csr_attribute18
    ,p_csr_attribute19               => p_csr_attribute19
    ,p_csr_attribute20               => p_csr_attribute20
    ,p_csr_attribute21               => p_csr_attribute21
    ,p_csr_attribute22               => p_csr_attribute22
    ,p_csr_attribute23               => p_csr_attribute23
    ,p_csr_attribute24               => p_csr_attribute24
    ,p_csr_attribute25               => p_csr_attribute25
    ,p_csr_attribute26               => p_csr_attribute26
    ,p_csr_attribute27               => p_csr_attribute27
    ,p_csr_attribute28               => p_csr_attribute28
    ,p_csr_attribute29               => p_csr_attribute29
    ,p_csr_attribute30               => p_csr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Css_Rltd_Per_in_Ler
    --
    ben_Css_Rltd_Per_in_Ler_bk2.update_Css_Rltd_Per_in_Ler_a
      (
       p_css_rltd_per_per_in_ler_id     =>  p_css_rltd_per_per_in_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_to_prcs_num               =>  p_ordr_to_prcs_num
      ,p_ler_id                         =>  p_ler_id
      ,p_rsltg_ler_id                   =>  p_rsltg_ler_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_csr_attribute_category         =>  p_csr_attribute_category
      ,p_csr_attribute1                 =>  p_csr_attribute1
      ,p_csr_attribute2                 =>  p_csr_attribute2
      ,p_csr_attribute3                 =>  p_csr_attribute3
      ,p_csr_attribute4                 =>  p_csr_attribute4
      ,p_csr_attribute5                 =>  p_csr_attribute5
      ,p_csr_attribute6                 =>  p_csr_attribute6
      ,p_csr_attribute7                 =>  p_csr_attribute7
      ,p_csr_attribute8                 =>  p_csr_attribute8
      ,p_csr_attribute9                 =>  p_csr_attribute9
      ,p_csr_attribute10                =>  p_csr_attribute10
      ,p_csr_attribute11                =>  p_csr_attribute11
      ,p_csr_attribute12                =>  p_csr_attribute12
      ,p_csr_attribute13                =>  p_csr_attribute13
      ,p_csr_attribute14                =>  p_csr_attribute14
      ,p_csr_attribute15                =>  p_csr_attribute15
      ,p_csr_attribute16                =>  p_csr_attribute16
      ,p_csr_attribute17                =>  p_csr_attribute17
      ,p_csr_attribute18                =>  p_csr_attribute18
      ,p_csr_attribute19                =>  p_csr_attribute19
      ,p_csr_attribute20                =>  p_csr_attribute20
      ,p_csr_attribute21                =>  p_csr_attribute21
      ,p_csr_attribute22                =>  p_csr_attribute22
      ,p_csr_attribute23                =>  p_csr_attribute23
      ,p_csr_attribute24                =>  p_csr_attribute24
      ,p_csr_attribute25                =>  p_csr_attribute25
      ,p_csr_attribute26                =>  p_csr_attribute26
      ,p_csr_attribute27                =>  p_csr_attribute27
      ,p_csr_attribute28                =>  p_csr_attribute28
      ,p_csr_attribute29                =>  p_csr_attribute29
      ,p_csr_attribute30                =>  p_csr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Css_Rltd_Per_in_Ler'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Css_Rltd_Per_in_Ler
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
    ROLLBACK TO update_Css_Rltd_Per_in_Ler;
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
    ROLLBACK TO update_Css_Rltd_Per_in_Ler;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_Css_Rltd_Per_in_Ler;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Css_Rltd_Per_in_Ler >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Css_Rltd_Per_in_Ler
  (p_validate                       in  boolean  default false
  ,p_css_rltd_per_per_in_ler_id     in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Css_Rltd_Per_in_Ler';
  l_object_version_number ben_css_rltd_per_per_in_ler_f.object_version_number%TYPE;
  l_effective_start_date ben_css_rltd_per_per_in_ler_f.effective_start_date%TYPE;
  l_effective_end_date ben_css_rltd_per_per_in_ler_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Css_Rltd_Per_in_Ler;
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
    -- Start of API User Hook for the before hook of delete_Css_Rltd_Per_in_Ler
    --
    ben_Css_Rltd_Per_in_Ler_bk3.delete_Css_Rltd_Per_in_Ler_b
      (
       p_css_rltd_per_per_in_ler_id     =>  p_css_rltd_per_per_in_ler_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Css_Rltd_Per_in_Ler'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Css_Rltd_Per_in_Ler
    --
  end;
  --
  ben_csr_del.del
    (
     p_css_rltd_per_per_in_ler_id    => p_css_rltd_per_per_in_ler_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Css_Rltd_Per_in_Ler
    --
    ben_Css_Rltd_Per_in_Ler_bk3.delete_Css_Rltd_Per_in_Ler_a
      (
       p_css_rltd_per_per_in_ler_id     =>  p_css_rltd_per_per_in_ler_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Css_Rltd_Per_in_Ler'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Css_Rltd_Per_in_Ler
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
    ROLLBACK TO delete_Css_Rltd_Per_in_Ler;
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
    ROLLBACK TO delete_Css_Rltd_Per_in_Ler;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_Css_Rltd_Per_in_Ler;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_css_rltd_per_per_in_ler_id                   in     number
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
  ben_csr_shd.lck
    (
      p_css_rltd_per_per_in_ler_id                 => p_css_rltd_per_per_in_ler_id
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
end ben_Css_Rltd_Per_in_Ler_api;

/
