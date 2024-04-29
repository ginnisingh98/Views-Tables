--------------------------------------------------------
--  DDL for Package Body BEN_ENRT_PREM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENRT_PREM_API" as
/* $Header: beeprapi.pkb 115.2 2002/12/11 11:16:06 lakrish ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_enrt_prem_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_enrt_prem >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_enrt_prem
  (p_validate                       in  boolean   default false
  ,p_enrt_prem_id                   out nocopy number
  ,p_val                            in  number    default null
  ,p_uom                            in  varchar2  default null
  ,p_elig_per_elctbl_chc_id         in  number    default null
  ,p_enrt_bnft_id                   in  number    default null
  ,p_actl_prem_id                   in  number
  ,p_business_group_id              in  number
  ,p_epr_attribute_category         in  varchar2  default null
  ,p_epr_attribute1                 in  varchar2  default null
  ,p_epr_attribute2                 in  varchar2  default null
  ,p_epr_attribute3                 in  varchar2  default null
  ,p_epr_attribute4                 in  varchar2  default null
  ,p_epr_attribute5                 in  varchar2  default null
  ,p_epr_attribute6                 in  varchar2  default null
  ,p_epr_attribute7                 in  varchar2  default null
  ,p_epr_attribute8                 in  varchar2  default null
  ,p_epr_attribute9                 in  varchar2  default null
  ,p_epr_attribute10                in  varchar2  default null
  ,p_epr_attribute11                in  varchar2  default null
  ,p_epr_attribute12                in  varchar2  default null
  ,p_epr_attribute13                in  varchar2  default null
  ,p_epr_attribute14                in  varchar2  default null
  ,p_epr_attribute15                in  varchar2  default null
  ,p_epr_attribute16                in  varchar2  default null
  ,p_epr_attribute17                in  varchar2  default null
  ,p_epr_attribute18                in  varchar2  default null
  ,p_epr_attribute19                in  varchar2  default null
  ,p_epr_attribute20                in  varchar2  default null
  ,p_epr_attribute21                in  varchar2  default null
  ,p_epr_attribute22                in  varchar2  default null
  ,p_epr_attribute23                in  varchar2  default null
  ,p_epr_attribute24                in  varchar2  default null
  ,p_epr_attribute25                in  varchar2  default null
  ,p_epr_attribute26                in  varchar2  default null
  ,p_epr_attribute27                in  varchar2  default null
  ,p_epr_attribute28                in  varchar2  default null
  ,p_epr_attribute29                in  varchar2  default null
  ,p_epr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_enrt_prem_id ben_enrt_prem.enrt_prem_id%TYPE;
  l_proc varchar2(72) := g_package||'create_enrt_prem';
  l_object_version_number ben_enrt_prem.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_enrt_prem;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_enrt_prem
    --
    ben_enrt_prem_bk1.create_enrt_prem_b
      (
       p_val                            =>  p_val
      ,p_uom                            =>  p_uom
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_epr_attribute_category         =>  p_epr_attribute_category
      ,p_epr_attribute1                 =>  p_epr_attribute1
      ,p_epr_attribute2                 =>  p_epr_attribute2
      ,p_epr_attribute3                 =>  p_epr_attribute3
      ,p_epr_attribute4                 =>  p_epr_attribute4
      ,p_epr_attribute5                 =>  p_epr_attribute5
      ,p_epr_attribute6                 =>  p_epr_attribute6
      ,p_epr_attribute7                 =>  p_epr_attribute7
      ,p_epr_attribute8                 =>  p_epr_attribute8
      ,p_epr_attribute9                 =>  p_epr_attribute9
      ,p_epr_attribute10                =>  p_epr_attribute10
      ,p_epr_attribute11                =>  p_epr_attribute11
      ,p_epr_attribute12                =>  p_epr_attribute12
      ,p_epr_attribute13                =>  p_epr_attribute13
      ,p_epr_attribute14                =>  p_epr_attribute14
      ,p_epr_attribute15                =>  p_epr_attribute15
      ,p_epr_attribute16                =>  p_epr_attribute16
      ,p_epr_attribute17                =>  p_epr_attribute17
      ,p_epr_attribute18                =>  p_epr_attribute18
      ,p_epr_attribute19                =>  p_epr_attribute19
      ,p_epr_attribute20                =>  p_epr_attribute20
      ,p_epr_attribute21                =>  p_epr_attribute21
      ,p_epr_attribute22                =>  p_epr_attribute22
      ,p_epr_attribute23                =>  p_epr_attribute23
      ,p_epr_attribute24                =>  p_epr_attribute24
      ,p_epr_attribute25                =>  p_epr_attribute25
      ,p_epr_attribute26                =>  p_epr_attribute26
      ,p_epr_attribute27                =>  p_epr_attribute27
      ,p_epr_attribute28                =>  p_epr_attribute28
      ,p_epr_attribute29                =>  p_epr_attribute29
      ,p_epr_attribute30                =>  p_epr_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_enrt_prem'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_enrt_prem
    --
  end;
  --
  ben_epr_ins.ins
    (
     p_enrt_prem_id                  => l_enrt_prem_id
    ,p_val                           => p_val
    ,p_uom                           => p_uom
    ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
    ,p_enrt_bnft_id                  => p_enrt_bnft_id
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_business_group_id             => p_business_group_id
    ,p_epr_attribute_category        => p_epr_attribute_category
    ,p_epr_attribute1                => p_epr_attribute1
    ,p_epr_attribute2                => p_epr_attribute2
    ,p_epr_attribute3                => p_epr_attribute3
    ,p_epr_attribute4                => p_epr_attribute4
    ,p_epr_attribute5                => p_epr_attribute5
    ,p_epr_attribute6                => p_epr_attribute6
    ,p_epr_attribute7                => p_epr_attribute7
    ,p_epr_attribute8                => p_epr_attribute8
    ,p_epr_attribute9                => p_epr_attribute9
    ,p_epr_attribute10               => p_epr_attribute10
    ,p_epr_attribute11               => p_epr_attribute11
    ,p_epr_attribute12               => p_epr_attribute12
    ,p_epr_attribute13               => p_epr_attribute13
    ,p_epr_attribute14               => p_epr_attribute14
    ,p_epr_attribute15               => p_epr_attribute15
    ,p_epr_attribute16               => p_epr_attribute16
    ,p_epr_attribute17               => p_epr_attribute17
    ,p_epr_attribute18               => p_epr_attribute18
    ,p_epr_attribute19               => p_epr_attribute19
    ,p_epr_attribute20               => p_epr_attribute20
    ,p_epr_attribute21               => p_epr_attribute21
    ,p_epr_attribute22               => p_epr_attribute22
    ,p_epr_attribute23               => p_epr_attribute23
    ,p_epr_attribute24               => p_epr_attribute24
    ,p_epr_attribute25               => p_epr_attribute25
    ,p_epr_attribute26               => p_epr_attribute26
    ,p_epr_attribute27               => p_epr_attribute27
    ,p_epr_attribute28               => p_epr_attribute28
    ,p_epr_attribute29               => p_epr_attribute29
    ,p_epr_attribute30               => p_epr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_enrt_prem
    --
    ben_enrt_prem_bk1.create_enrt_prem_a
      (
       p_enrt_prem_id                   =>  l_enrt_prem_id
      ,p_val                            =>  p_val
      ,p_uom                            =>  p_uom
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_epr_attribute_category         =>  p_epr_attribute_category
      ,p_epr_attribute1                 =>  p_epr_attribute1
      ,p_epr_attribute2                 =>  p_epr_attribute2
      ,p_epr_attribute3                 =>  p_epr_attribute3
      ,p_epr_attribute4                 =>  p_epr_attribute4
      ,p_epr_attribute5                 =>  p_epr_attribute5
      ,p_epr_attribute6                 =>  p_epr_attribute6
      ,p_epr_attribute7                 =>  p_epr_attribute7
      ,p_epr_attribute8                 =>  p_epr_attribute8
      ,p_epr_attribute9                 =>  p_epr_attribute9
      ,p_epr_attribute10                =>  p_epr_attribute10
      ,p_epr_attribute11                =>  p_epr_attribute11
      ,p_epr_attribute12                =>  p_epr_attribute12
      ,p_epr_attribute13                =>  p_epr_attribute13
      ,p_epr_attribute14                =>  p_epr_attribute14
      ,p_epr_attribute15                =>  p_epr_attribute15
      ,p_epr_attribute16                =>  p_epr_attribute16
      ,p_epr_attribute17                =>  p_epr_attribute17
      ,p_epr_attribute18                =>  p_epr_attribute18
      ,p_epr_attribute19                =>  p_epr_attribute19
      ,p_epr_attribute20                =>  p_epr_attribute20
      ,p_epr_attribute21                =>  p_epr_attribute21
      ,p_epr_attribute22                =>  p_epr_attribute22
      ,p_epr_attribute23                =>  p_epr_attribute23
      ,p_epr_attribute24                =>  p_epr_attribute24
      ,p_epr_attribute25                =>  p_epr_attribute25
      ,p_epr_attribute26                =>  p_epr_attribute26
      ,p_epr_attribute27                =>  p_epr_attribute27
      ,p_epr_attribute28                =>  p_epr_attribute28
      ,p_epr_attribute29                =>  p_epr_attribute29
      ,p_epr_attribute30                =>  p_epr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_enrt_prem'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_enrt_prem
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
  p_enrt_prem_id := l_enrt_prem_id;
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
    ROLLBACK TO create_enrt_prem;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_enrt_prem_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_enrt_prem;

    -- NOCOPY, Reset out parameters
    p_enrt_prem_id := null;
    p_object_version_number  := null;

    raise;
    --
end create_enrt_prem;
-- ----------------------------------------------------------------------------
-- |------------------------< update_enrt_prem >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_enrt_prem
  (p_validate                       in  boolean   default false
  ,p_enrt_prem_id                   in  number
  ,p_val                            in  number    default hr_api.g_number
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_enrt_bnft_id                   in  number    default hr_api.g_number
  ,p_actl_prem_id                   in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_epr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_epr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_enrt_prem';
  l_object_version_number ben_enrt_prem.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_enrt_prem;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_enrt_prem
    --
    ben_enrt_prem_bk2.update_enrt_prem_b
      (
       p_enrt_prem_id                   =>  p_enrt_prem_id
      ,p_val                            =>  p_val
      ,p_uom                            =>  p_uom
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_epr_attribute_category         =>  p_epr_attribute_category
      ,p_epr_attribute1                 =>  p_epr_attribute1
      ,p_epr_attribute2                 =>  p_epr_attribute2
      ,p_epr_attribute3                 =>  p_epr_attribute3
      ,p_epr_attribute4                 =>  p_epr_attribute4
      ,p_epr_attribute5                 =>  p_epr_attribute5
      ,p_epr_attribute6                 =>  p_epr_attribute6
      ,p_epr_attribute7                 =>  p_epr_attribute7
      ,p_epr_attribute8                 =>  p_epr_attribute8
      ,p_epr_attribute9                 =>  p_epr_attribute9
      ,p_epr_attribute10                =>  p_epr_attribute10
      ,p_epr_attribute11                =>  p_epr_attribute11
      ,p_epr_attribute12                =>  p_epr_attribute12
      ,p_epr_attribute13                =>  p_epr_attribute13
      ,p_epr_attribute14                =>  p_epr_attribute14
      ,p_epr_attribute15                =>  p_epr_attribute15
      ,p_epr_attribute16                =>  p_epr_attribute16
      ,p_epr_attribute17                =>  p_epr_attribute17
      ,p_epr_attribute18                =>  p_epr_attribute18
      ,p_epr_attribute19                =>  p_epr_attribute19
      ,p_epr_attribute20                =>  p_epr_attribute20
      ,p_epr_attribute21                =>  p_epr_attribute21
      ,p_epr_attribute22                =>  p_epr_attribute22
      ,p_epr_attribute23                =>  p_epr_attribute23
      ,p_epr_attribute24                =>  p_epr_attribute24
      ,p_epr_attribute25                =>  p_epr_attribute25
      ,p_epr_attribute26                =>  p_epr_attribute26
      ,p_epr_attribute27                =>  p_epr_attribute27
      ,p_epr_attribute28                =>  p_epr_attribute28
      ,p_epr_attribute29                =>  p_epr_attribute29
      ,p_epr_attribute30                =>  p_epr_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_enrt_prem'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_enrt_prem
    --
  end;
  --
  ben_epr_upd.upd
    (
     p_enrt_prem_id                  => p_enrt_prem_id
    ,p_val                           => p_val
    ,p_uom                           => p_uom
    ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
    ,p_enrt_bnft_id                  => p_enrt_bnft_id
    ,p_actl_prem_id                  => p_actl_prem_id
    ,p_business_group_id             => p_business_group_id
    ,p_epr_attribute_category        => p_epr_attribute_category
    ,p_epr_attribute1                => p_epr_attribute1
    ,p_epr_attribute2                => p_epr_attribute2
    ,p_epr_attribute3                => p_epr_attribute3
    ,p_epr_attribute4                => p_epr_attribute4
    ,p_epr_attribute5                => p_epr_attribute5
    ,p_epr_attribute6                => p_epr_attribute6
    ,p_epr_attribute7                => p_epr_attribute7
    ,p_epr_attribute8                => p_epr_attribute8
    ,p_epr_attribute9                => p_epr_attribute9
    ,p_epr_attribute10               => p_epr_attribute10
    ,p_epr_attribute11               => p_epr_attribute11
    ,p_epr_attribute12               => p_epr_attribute12
    ,p_epr_attribute13               => p_epr_attribute13
    ,p_epr_attribute14               => p_epr_attribute14
    ,p_epr_attribute15               => p_epr_attribute15
    ,p_epr_attribute16               => p_epr_attribute16
    ,p_epr_attribute17               => p_epr_attribute17
    ,p_epr_attribute18               => p_epr_attribute18
    ,p_epr_attribute19               => p_epr_attribute19
    ,p_epr_attribute20               => p_epr_attribute20
    ,p_epr_attribute21               => p_epr_attribute21
    ,p_epr_attribute22               => p_epr_attribute22
    ,p_epr_attribute23               => p_epr_attribute23
    ,p_epr_attribute24               => p_epr_attribute24
    ,p_epr_attribute25               => p_epr_attribute25
    ,p_epr_attribute26               => p_epr_attribute26
    ,p_epr_attribute27               => p_epr_attribute27
    ,p_epr_attribute28               => p_epr_attribute28
    ,p_epr_attribute29               => p_epr_attribute29
    ,p_epr_attribute30               => p_epr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_enrt_prem
    --
    ben_enrt_prem_bk2.update_enrt_prem_a
      (
       p_enrt_prem_id                   =>  p_enrt_prem_id
      ,p_val                            =>  p_val
      ,p_uom                            =>  p_uom
      ,p_elig_per_elctbl_chc_id         =>  p_elig_per_elctbl_chc_id
      ,p_enrt_bnft_id                   =>  p_enrt_bnft_id
      ,p_actl_prem_id                   =>  p_actl_prem_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_epr_attribute_category         =>  p_epr_attribute_category
      ,p_epr_attribute1                 =>  p_epr_attribute1
      ,p_epr_attribute2                 =>  p_epr_attribute2
      ,p_epr_attribute3                 =>  p_epr_attribute3
      ,p_epr_attribute4                 =>  p_epr_attribute4
      ,p_epr_attribute5                 =>  p_epr_attribute5
      ,p_epr_attribute6                 =>  p_epr_attribute6
      ,p_epr_attribute7                 =>  p_epr_attribute7
      ,p_epr_attribute8                 =>  p_epr_attribute8
      ,p_epr_attribute9                 =>  p_epr_attribute9
      ,p_epr_attribute10                =>  p_epr_attribute10
      ,p_epr_attribute11                =>  p_epr_attribute11
      ,p_epr_attribute12                =>  p_epr_attribute12
      ,p_epr_attribute13                =>  p_epr_attribute13
      ,p_epr_attribute14                =>  p_epr_attribute14
      ,p_epr_attribute15                =>  p_epr_attribute15
      ,p_epr_attribute16                =>  p_epr_attribute16
      ,p_epr_attribute17                =>  p_epr_attribute17
      ,p_epr_attribute18                =>  p_epr_attribute18
      ,p_epr_attribute19                =>  p_epr_attribute19
      ,p_epr_attribute20                =>  p_epr_attribute20
      ,p_epr_attribute21                =>  p_epr_attribute21
      ,p_epr_attribute22                =>  p_epr_attribute22
      ,p_epr_attribute23                =>  p_epr_attribute23
      ,p_epr_attribute24                =>  p_epr_attribute24
      ,p_epr_attribute25                =>  p_epr_attribute25
      ,p_epr_attribute26                =>  p_epr_attribute26
      ,p_epr_attribute27                =>  p_epr_attribute27
      ,p_epr_attribute28                =>  p_epr_attribute28
      ,p_epr_attribute29                =>  p_epr_attribute29
      ,p_epr_attribute30                =>  p_epr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_enrt_prem'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_enrt_prem
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
    ROLLBACK TO update_enrt_prem;
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
    ROLLBACK TO update_enrt_prem;
    raise;
    --
end update_enrt_prem;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrt_prem >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_prem
  (p_validate                       in  boolean  default false
  ,p_enrt_prem_id                   in  number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_enrt_prem';
  l_object_version_number ben_enrt_prem.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_enrt_prem;
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
    -- Start of API User Hook for the before hook of delete_enrt_prem
    --
    ben_enrt_prem_bk3.delete_enrt_prem_b
      (
       p_enrt_prem_id                   =>  p_enrt_prem_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_enrt_prem'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_enrt_prem
    --
  end;
  --
  ben_epr_del.del
    (
     p_enrt_prem_id                  => p_enrt_prem_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_enrt_prem
    --
    ben_enrt_prem_bk3.delete_enrt_prem_a
      (
       p_enrt_prem_id                   =>  p_enrt_prem_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_enrt_prem'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_enrt_prem
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
    ROLLBACK TO delete_enrt_prem;
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
    ROLLBACK TO delete_enrt_prem;
    raise;
    --
end delete_enrt_prem;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_enrt_prem_id                   in     number
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
  ben_epr_shd.lck
    (
      p_enrt_prem_id                 => p_enrt_prem_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_enrt_prem_api;

/
